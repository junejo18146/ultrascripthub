--[[
    JUNEJO ULTRA SCRIPT HUB - 99 NIGHTS IN THE FOREST
    Target Game: 99 Nights in the Forest (Roblox)
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11) - Flat & Borderless Standard
    Status: Direct Standalone Executable
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- Global Feature State Flags (Strictly Preserved)
_G.KillAuraActive = false
_G.FlyActive = false
_G.FlySpeed = 60
_G.AutoFillCampfire = false
_G.FullBrightActive = false

-- Prevent duplicate UI
pcall(function()
    if CoreGui:FindFirstChild("Forest99UI_Badshah") then CoreGui.Forest99UI_Badshah:Destroy() end
    if CoreGui:FindFirstChild("JunejoHubUI_NightsForest") then CoreGui.JunejoHubUI_NightsForest:Destroy() end
    if CoreGui:FindFirstChild("JunejoHubUI") then CoreGui.JunejoHubUI:Destroy() end
end)
pcall(function()
    if LocalPlayer:FindFirstChild("PlayerGui") then
        if LocalPlayer.PlayerGui:FindFirstChild("Forest99UI_Badshah") then LocalPlayer.PlayerGui.Forest99UI_Badshah:Destroy() end
        if LocalPlayer.PlayerGui:FindFirstChild("JunejoHubUI_NightsForest") then LocalPlayer.PlayerGui.JunejoHubUI_NightsForest:Destroy() end
        if LocalPlayer.PlayerGui:FindFirstChild("JunejoHubUI") then LocalPlayer.PlayerGui.JunejoHubUI:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_NightsForest"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

-- Universal Safe Parenting
local function getParentUI()
    if gethui then
        local success, res = pcall(gethui)
        if success and res then return res end
    end
    local coreSuccess = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if coreSuccess and ScreenGui.Parent == CoreGui then
        return CoreGui
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

ScreenGui.Parent = getParentUI()

-- =================================================================
-- HELPER: FIND CAMPFIRE IN WORKSPACE (EXACT LOGIC PRESERVED)
-- =================================================================
local cachedCampfire = nil
local lastFireSearch = 0

local function getCampfire()
    local now = tick()
    if cachedCampfire and cachedCampfire.Parent and (now - lastFireSearch < 5) then
        return cachedCampfire
    end
    lastFireSearch = now

    -- Search for Campfire object
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "campfire") or string.find(nameLower, "fire_pit") or string.find(nameLower, "camp_fire") or string.find(nameLower, "firepit") then
                local part = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Fire") or obj:FindFirstChildWhichIsA("BasePart")) or obj
                if part and part:IsA("BasePart") then
                    cachedCampfire = part
                    return part
                end
            end
        end
    end

    -- Fallback: check for fire emitter / light
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Fire") or obj:IsA("PointLight") then
            if obj.Parent and obj.Parent:IsA("BasePart") and (string.find(string.lower(obj.Parent.Name), "fire") or string.find(string.lower(obj.Parent.Parent.Name), "camp")) then
                cachedCampfire = obj.Parent
                return obj.Parent
            end
        end
    end

    return nil
end

-- =================================================================
-- HELPER: BRING SPECIFIC ITEMS TO PLAYER (EXACT LOGIC PRESERVED)
-- =================================================================
local function bringItemCategory(keywords)
    task.spawn(function()
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local broughtCount = 0
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    local nameLower = string.lower(obj.Name)
                    local matches = false
                    
                    for _, kw in ipairs(keywords) do
                        if string.find(nameLower, kw) then
                            matches = true
                            break
                        end
                    end

                    if matches then
                        local part = obj:IsA("Model") and (obj:FindFirstChild("Handle") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")) or obj
                        if part and part:IsA("BasePart") and not part:IsA("Terrain") and (part.Position - hrp.Position).Magnitude > 4 then
                            part.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 4) + Vector3.new(0, 1.5, 0)
                            
                            pcall(function()
                                firetouchinterest(hrp, part, 0)
                                task.wait(0.02)
                                firetouchinterest(hrp, part, 1)
                            end)
                            
                            for _, prompt in ipairs(obj:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") then
                                    fireproximityprompt(prompt)
                                end
                            end

                            broughtCount = broughtCount + 1
                            if broughtCount >= 25 then
                                task.wait(0.1)
                                broughtCount = 0
                            end
                        end
                    end
                end
            end
        end)
    end)
end

-- Helper: Auto-Equip Weapon (Axe / Torch / Spear / Knife / Tool)
local function equipBestWeapon()
    pcall(function()
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not char or not backpack then return end
        
        local currentTool = char:FindFirstChildOfClass("Tool")
        if not currentTool then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    char.Humanoid:EquipTool(tool)
                    break
                end
            end
        end
    end)
end

-- =================================================================
-- OFFICIAL JUNEJO FLAT & BORDERLESS UI STANDARD
-- =================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 275)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -137)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "99 NIGHTS IN THE FOREST"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -28, 0, 4)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 160)
CloseButton.TextSize = 13
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header
CloseButton.MouseButton1Click:Connect(function()
    _G.KillAuraActive = false
    _G.FlyActive = false
    _G.AutoFillCampfire = false
    _G.FullBrightActive = false
    ScreenGui:Destroy()
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Content Frame (ScrollingFrame for seamless compact access)
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 0, 196)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper function for Flat & Borderless Toggle Rows
local function AddToggleRow(text, getStatus, setStatus)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame
    
    local RowBtn = Instance.new("TextButton")
    RowBtn.Size = UDim2.new(1, 0, 1, 0)
    RowBtn.BackgroundTransparency = 1
    RowBtn.Text = ""
    RowBtn.ZIndex = 5
    RowBtn.Parent = Row
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -28, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local CheckBox = Instance.new("Frame")
    CheckBox.Size = UDim2.new(0, 18, 0, 18)
    CheckBox.Position = UDim2.new(1, -18, 0.5, -9)
    CheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    CheckBox.BorderSizePixel = 0
    CheckBox.Parent = Row
    
    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 4)
    CheckCorner.Parent = CheckBox
    
    local CheckStroke = Instance.new("UIStroke")
    CheckStroke.Color = Color3.fromRGB(45, 45, 55)
    CheckStroke.Thickness = 1.2
    CheckStroke.Parent = CheckBox
    
    local CheckMark = Instance.new("Frame")
    CheckMark.Size = UDim2.new(0, 10, 0, 10)
    CheckMark.Position = UDim2.new(0.5, -5, 0.5, -5)
    CheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CheckMark.BackgroundTransparency = getStatus() and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox
    
    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark
    
    RowBtn.MouseButton1Click:Connect(function()
        local newState = not getStatus()
        setStatus(newState)
        CheckMark.BackgroundTransparency = newState and 0 or 1
    end)
end

-- Helper function for Flat & Borderless Action Button Rows
local function AddButtonRow(text, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame
    
    local RowBtn = Instance.new("TextButton")
    RowBtn.Size = UDim2.new(1, 0, 1, 0)
    RowBtn.BackgroundTransparency = 1
    RowBtn.Text = ""
    RowBtn.ZIndex = 5
    RowBtn.Parent = Row
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local ActionPill = Instance.new("Frame")
    ActionPill.Size = UDim2.new(0, 42, 0, 18)
    ActionPill.Position = UDim2.new(1, -42, 0.5, -9)
    ActionPill.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ActionPill.BorderSizePixel = 0
    ActionPill.Parent = Row
    
    local PillCorner = Instance.new("UICorner")
    PillCorner.CornerRadius = UDim.new(0, 4)
    PillCorner.Parent = ActionPill
    
    local PillStroke = Instance.new("UIStroke")
    PillStroke.Color = Color3.fromRGB(45, 45, 55)
    PillStroke.Thickness = 1.2
    PillStroke.Parent = ActionPill
    
    local PillText = Instance.new("TextLabel")
    PillText.Size = UDim2.new(1, 0, 1, 0)
    PillText.BackgroundTransparency = 1
    PillText.Text = "USE"
    PillText.TextColor3 = Color3.fromRGB(200, 200, 210)
    PillText.Font = Enum.Font.GothamBold
    PillText.TextSize = 9
    PillText.Parent = ActionPill
    
    RowBtn.MouseButton1Click:Connect(function()
        ActionPill.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        task.delay(0.12, function()
            ActionPill.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
        end)
        if callback then callback() end
    end)
end

-- =================================================================
-- FEATURE ROWS CONFIGURATION (ALL 11 FEATURES)
-- =================================================================

-- 1. Kill Aura Toggle
AddToggleRow("Kill Aura", function() return _G.KillAuraActive end, function(val)
    _G.KillAuraActive = val
end)

-- 2. Auto Fill Campfire Toggle
AddToggleRow("Auto Fill Campfire", function() return _G.AutoFillCampfire end, function(val)
    _G.AutoFillCampfire = val
end)

-- 3. Fly Mode Toggle
AddToggleRow("Fly", function() return _G.FlyActive end, function(val)
    _G.FlyActive = val
end)

-- 4. Integrated Fly Speed Row (- / + Pill Controller)
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, 0, 0, 23)
SpeedRow.BackgroundTransparency = 1
SpeedRow.Parent = ContentFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.55, 0, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Fly Speed"
SpeedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedRow

local SpeedControlFrame = Instance.new("Frame")
SpeedControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
SpeedControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
SpeedControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
SpeedControlFrame.BorderSizePixel = 0
SpeedControlFrame.Parent = SpeedRow

local CtrlCorner = Instance.new("UICorner")
CtrlCorner.CornerRadius = UDim.new(0, 4)
CtrlCorner.Parent = SpeedControlFrame

local CtrlStroke = Instance.new("UIStroke")
CtrlStroke.Color = Color3.fromRGB(45, 45, 55)
CtrlStroke.Thickness = 1
CtrlStroke.Parent = SpeedControlFrame

local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 22, 1, 0)
MinusBtn.Position = UDim2.new(0, 0, 0, 0)
MinusBtn.BackgroundTransparency = 1
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
MinusBtn.TextSize = 14
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Parent = SpeedControlFrame

local SpeedDisplay = Instance.new("TextLabel")
SpeedDisplay.Size = UDim2.new(1, -44, 1, 0)
SpeedDisplay.Position = UDim2.new(0, 22, 0, 0)
SpeedDisplay.BackgroundTransparency = 1
SpeedDisplay.Text = tostring(_G.FlySpeed)
SpeedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedDisplay.TextSize = 11
SpeedDisplay.Font = Enum.Font.GothamBold
SpeedDisplay.Parent = SpeedControlFrame

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 22, 1, 0)
PlusBtn.Position = UDim2.new(1, -22, 0, 0)
PlusBtn.BackgroundTransparency = 1
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
PlusBtn.TextSize = 14
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Parent = SpeedControlFrame

MinusBtn.MouseButton1Click:Connect(function()
    _G.FlySpeed = math.max(20, (_G.FlySpeed or 60) - 10)
    SpeedDisplay.Text = tostring(_G.FlySpeed)
end)

PlusBtn.MouseButton1Click:Connect(function()
    _G.FlySpeed = math.min(250, (_G.FlySpeed or 60) + 10)
    SpeedDisplay.Text = tostring(_G.FlySpeed)
end)

-- 5. FullBright Toggle
AddToggleRow("Bright", function() return _G.FullBrightActive end, function(state)
    _G.FullBrightActive = state
    pcall(function()
        if state then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 0
            Lighting.FogEnd = 500
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 50)
        end
    end)
end)

-- 6. Bring Fuel Action
AddButtonRow("Bring Fuel", function()
    bringItemCategory({"fuel", "gas", "oil", "igniter", "coal"})
end)

-- 7. Bring Food Action
AddButtonRow("Bring Food", function()
    bringItemCategory({"food", "carrot", "apple", "berry", "corn", "mushroom", "meat", "cooked"})
end)

-- 8. Bring Medicine Action
AddButtonRow("Bring Medicine", function()
    bringItemCategory({"medicine", "medkit", "med", "pill", "heal", "aid"})
end)

-- 9. Bring Scrap Action
AddButtonRow("Bring Scrap", function()
    bringItemCategory({"scrap", "metal", "gear", "iron", "wire", "pipe"})
end)

-- 10. Bring Bandages Action
AddButtonRow("Bring Bandages", function()
    bringItemCategory({"bandage", "bandages", "gauze"})
end)

-- 11. Teleport Campfire Action
AddButtonRow("Teleport Campfire", function()
    task.spawn(function()
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local fire = getCampfire()
            if fire then
                hrp.CFrame = fire.CFrame + Vector3.new(0, 3.5, 0)
            else
                hrp.CFrame = CFrame.new(0, 10, 0)
            end
        end)
    end)
end)

-- Footer (Pinned at bottom)
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 36)
Footer.Position = UDim2.new(0, 0, 1, -38)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 14)
FooterTitle.Position = UDim2.new(0, 0, 0, 4)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 11
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 12)
FooterSub.Position = UDim2.new(0, 0, 0, 18)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 9
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.Parent = Footer

-- Smooth Dragging Mechanism
local dragging = false
local dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- =================================================================
-- GAMEPLAY ENGINE & FEATURE IMPLEMENTATIONS (EXACT LOGIC PRESERVED)
-- =================================================================

-- 1. Fly Mode (Mobile Joystick & PC Keyboard Compatible)
task.spawn(function()
    while true do
        task.wait(0.03)
        if _G.FlyActive then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local camera = workspace.CurrentCamera
                
                if hrp and hum and camera then
                    local bv = hrp:FindFirstChild("ForestFlyBV") or Instance.new("BodyVelocity")
                    bv.Name = "ForestFlyBV"
                    bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                    bv.Parent = hrp
                    
                    local bg = hrp:FindFirstChild("ForestFlyBG") or Instance.new("BodyGyro")
                    bg.Name = "ForestFlyBG"
                    bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
                    bg.P = 10000
                    bg.Parent = hrp
                    
                    hum.PlatformStand = true
                    bg.CFrame = camera.CFrame
                    
                    local speed = _G.FlySpeed or 60
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        local flyVel = camera.CFrame.LookVector * speed
                        if math.abs(moveDir.Z) < 0.2 and math.abs(moveDir.X) > 0.5 then
                            flyVel = camera.CFrame.RightVector * speed * (moveDir.X > 0 and 1 or -1)
                        end
                        bv.Velocity = flyVel
                    else
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        else
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.PlatformStand then
                    hum.PlatformStand = false
                end
                if hrp then
                    if hrp:FindFirstChild("ForestFlyBV") then hrp.ForestFlyBV:Destroy() end
                    if hrp:FindFirstChild("ForestFlyBG") then hrp.ForestFlyBG:Destroy() end
                end
            end)
        end
    end
end)

-- 2. Powerful Multi-Method Kill Aura Engine (Attacks Animals & Mobs in 60 studs)
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.KillAuraActive then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                equipBestWeapon()
                local tool = char:FindFirstChildOfClass("Tool")

                -- Find all nearby animals and hostiles across workspace
                for _, model in ipairs(workspace:GetDescendants()) do
                    if model:IsA("Model") and model ~= char and not Players:GetPlayerFromCharacter(model) then
                        local enemyHum = model:FindFirstChildOfClass("Humanoid")
                        local enemyPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model:FindFirstChild("Torso") or model:FindFirstChildWhichIsA("BasePart")
                        
                        if enemyHum and enemyHum.Health > 0 and enemyPart then
                            local dist = (enemyPart.Position - hrp.Position).Magnitude
                            if dist <= 60 then
                                -- Aim and attack
                                local targetAimCFrame = CFrame.lookAt(hrp.Position, enemyPart.Position)

                                -- 1. Tool Activation
                                if tool then
                                    tool:Activate()
                                    for _, sub in ipairs(tool:GetDescendants()) do
                                        if sub:IsA("RemoteEvent") then
                                            sub:FireServer(enemyPart, enemyPart.Position)
                                        elseif sub:IsA("RemoteFunction") then
                                            sub:InvokeServer(enemyPart, enemyPart.Position)
                                        end
                                    end
                                end

                                -- 2. Virtual User Click towards target
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(500, 500), targetAimCFrame)
                                task.wait(0.02)
                                VirtualUser:Button1Up(Vector2.new(500, 500), targetAimCFrame)

                                -- 3. Trigger ProximityPrompts if animal has them
                                for _, prompt in ipairs(model:GetDescendants()) do
                                    if prompt:IsA("ProximityPrompt") then
                                        fireproximityprompt(prompt)
                                    end
                                end

                                -- 4. Remote attack hooks
                                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                                    if rem:IsA("RemoteEvent") then
                                        local rName = string.lower(rem.Name)
                                        if string.find(rName, "hurt") or string.find(rName, "attack") or string.find(rName, "damage") or string.find(rName, "hit") then
                                            rem:FireServer(model, enemyPart)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. Robust Auto Fill Campfire Engine (Gathers all Coal & Fuel from all folders directly into Campfire)
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoFillCampfire then
            pcall(function()
                local fire = getCampfire()
                if not fire then return end

                local firePos = fire.CFrame + Vector3.new(0, 1.5, 0)
                local fuelCount = 0

                -- Scan all workspace descendants for Coal, Fuel, Wood, Gas, Sticks
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local nameLower = string.lower(obj.Name)
                        if string.find(nameLower, "coal") or string.find(nameLower, "fuel") or string.find(nameLower, "gas") or string.find(nameLower, "wood") or string.find(nameLower, "log") or string.find(nameLower, "stick") then
                            local part = obj:IsA("Model") and (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")) or obj
                            if part and part:IsA("BasePart") and not part:IsA("Terrain") and part ~= fire then
                                local dist = (part.Position - fire.Position).Magnitude
                                if dist > 2 then
                                    part.CFrame = firePos
                                    part.Velocity = Vector3.new(0, -5, 0)
                                    
                                    pcall(function()
                                        firetouchinterest(part, fire, 0)
                                        task.wait(0.01)
                                        firetouchinterest(part, fire, 1)
                                    end)

                                    for _, prompt in ipairs(obj:GetDescendants()) do
                                        if prompt:IsA("ProximityPrompt") then
                                            fireproximityprompt(prompt)
                                        end
                                    end

                                    fuelCount = fuelCount + 1
                                    if fuelCount >= 20 then
                                        task.wait(0.05)
                                        fuelCount = 0
                                    end
                                end
                            end
                        end
                    end
                end

                -- Trigger campfire prompts
                if fire.Parent then
                    for _, prompt in ipairs(fire.Parent:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            fireproximityprompt(prompt)
                        end
                    end
                end
                for _, prompt in ipairs(fire:GetChildren()) do
                    if prompt:IsA("ProximityPrompt") then
                        fireproximityprompt(prompt)
                    end
                end
            end)
        end
    end
end)
