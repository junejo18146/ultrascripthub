-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - STEAL A BRAINROT EGG (CLICKABLE & AUTO SELL V6)
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- 100% Guaranteed Clickable UI (Mobile Delta/Codex + PC)
-- ====================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Clean previous UI instances safely
for _, uiName in ipairs({"JunejoHubUI_StealBrainrotEgg", "JunejoStealBrainrotEggUI"}) do
    pcall(function()
        if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(uiName) then
            LocalPlayer.PlayerGui[uiName]:Destroy()
        end
    end)
end

-- Global Configuration & State
local Toggles = {
    AutoSteal = false,
    AutoSell = false,
    AutoHatch = false,
    AutoCollectDrops = false,
    AutoUpgradeBase = false,
    AutoRebirth = false,
    Godmode = false,
    PlayerESP = false,
    FlyMode = false,
    EggESP = false,
    Noclip = false,
    InfiniteJump = false,
    WalkSpeedBoost = false,
    AntiAFK = true
}

local CustomSpeedValue = 100
local SavedBaseCFrame = nil
local CurrentEggESPInstances = {}
local CurrentPlayerESPInstances = {}
local CooldownEggs = {}

-- Safe Alive Check
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- Universal Instant ProximityPrompt Trigger
local function InstantTriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 150
        prompt.RequiresLineOfSight = false
        prompt.Enabled = true

        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt)
        end
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            task.wait(0.01)
            prompt:InputHoldEnd()
        end
    end)
end

-- Universal Touch Interest Trigger
local function InstantTouch(part, targetPart)
    if not part or not targetPart then return end
    pcall(function()
        if firetouchinterest then
            firetouchinterest(part, targetPart, 0)
            task.wait()
            firetouchinterest(part, targetPart, 1)
        end
    end)
end

-- Speed Update Helper
local function UpdateCharacterSpeed()
    pcall(function()
        if isAlive() then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if Toggles.WalkSpeedBoost then
                    hum.WalkSpeed = CustomSpeedValue
                else
                    hum.WalkSpeed = 16
                end
            end
        end
    end)
end

-- ====================================================
-- UI GENERATION (100% DIRECT CLICKABLE JUNEJO STANDARD)
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_StealBrainrotEgg"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local guiParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 285, 0, 345)
MainFrame.Position = UDim2.new(0.5, -142, 0.5, -172)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Header Frame (Draggable only from Header)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Active = true
Header.Parent = MainFrame

-- Smooth Dragging restricted to Header
local function enableHeaderDrag(dragHandle, targetFrame)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
enableHeaderDrag(Header, MainFrame)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "STEAL A BRAINROT EGG"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Active = false
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -28, 0, 4)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 160)
CloseButton.TextSize = 13
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Active = true
CloseButton.ZIndex = 10
CloseButton.Parent = Header

local function closeUI() ScreenGui:Destroy() end
CloseButton.MouseButton1Click:Connect(closeUI)
CloseButton.Activated:Connect(closeUI)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Scrollable Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -16, 0, 265)
ContentFrame.Position = UDim2.new(0, 10, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 80)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 430)
ContentFrame.Active = false
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper Function: Add Toggle Row (Direct Full-Width Button without blocking layers)
local function AddToggleRow(text, configKey, callback)
    local RowBtn = Instance.new("TextButton")
    RowBtn.Name = "Row_" .. configKey
    RowBtn.Size = UDim2.new(1, -6, 0, 24)
    RowBtn.BackgroundTransparency = 1
    RowBtn.AutoButtonColor = false
    RowBtn.Text = ""
    RowBtn.Active = true
    RowBtn.ZIndex = 5
    RowBtn.Parent = ContentFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -28, 1, 0)
    Label.Position = UDim2.new(0, 4, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Active = false
    Label.ZIndex = 6
    Label.Parent = RowBtn
    
    local CheckBox = Instance.new("Frame")
    CheckBox.Size = UDim2.new(0, 18, 0, 18)
    CheckBox.Position = UDim2.new(1, -22, 0.5, -9)
    CheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    CheckBox.BorderSizePixel = 0
    CheckBox.Active = false
    CheckBox.ZIndex = 6
    CheckBox.Parent = RowBtn
    
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
    CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Active = false
    CheckMark.ZIndex = 7
    CheckMark.Parent = CheckBox
    
    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark
    
    local function onToggle()
        Toggles[configKey] = not Toggles[configKey]
        CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
        if callback then callback(Toggles[configKey]) end
    end
    
    RowBtn.MouseButton1Click:Connect(onToggle)
    RowBtn.Activated:Connect(onToggle)
end

-- Helper Function: Add Action Button Row
local function AddActionButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -6, 0, 24)
    Btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.Active = true
    Btn.ZIndex = 5
    Btn.AutoButtonColor = true
    Btn.Parent = ContentFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Btn
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn
    
    local function onClick()
        if callback then callback(Btn) end
    end
    
    Btn.MouseButton1Click:Connect(onClick)
    Btn.Activated:Connect(onClick)
end

-- ====================================================
-- TOGGLE & ACTION BUTTON REGISTRATION
-- ====================================================

-- 1. Auto Steal Nearest Egg
AddToggleRow("Auto Steal Nearest Egg", "AutoSteal", function(state)
    if state and isAlive() then
        if not SavedBaseCFrame then
            SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end
end)

-- 2. Action Button: Set Current Base Position
AddActionButton("📍 Set Current Base Position", function(btn)
    if isAlive() then
        SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        btn.Text = "✓ Base Location Saved!"
        btn.TextColor3 = Color3.fromRGB(80, 255, 120)
        task.delay(1.5, function()
            btn.Text = "📍 Set Current Base Position"
            btn.TextColor3 = Color3.fromRGB(240, 240, 240)
        end)
    end
end)

-- 3. Action Button: Teleport to Base
AddActionButton("⚡ Teleport to Base", function(btn)
    if isAlive() then
        if not SavedBaseCFrame then
            SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = SavedBaseCFrame * CFrame.new(0, 2, 0)
        btn.Text = "✓ Teleported to Base!"
        task.delay(1.2, function()
            btn.Text = "⚡ Teleport to Base"
        end)
    end
end)

-- 4. Auto Sell Brainrots [NEW REQUESTED FEATURE]
AddToggleRow("Auto Sell Brainrots", "AutoSell", function(state) end)

-- 5. Auto Hatch & Incubate
AddToggleRow("Auto Hatch & Incubate", "AutoHatch", function(state) end)

-- 6. Auto Collect Drops & Base Cash (Magnet)
AddToggleRow("Auto Collect Drops / Cash", "AutoCollectDrops", function(state) end)

-- 7. Auto Upgrade Base & Speed
AddToggleRow("Auto Upgrade Base / Speed", "AutoUpgradeBase", function(state) end)

-- 8. Auto Rebirth Engine
AddToggleRow("Auto Rebirth", "AutoRebirth", function(state) end)

-- 9. Godmode & Anti-Stun / Laser Immunity
AddToggleRow("Godmode & Anti-Stun", "Godmode", function(state) end)

-- 10. Player ESP & Base Defense Radar
AddToggleRow("Player ESP & Radar", "PlayerESP", function(state)
    if not state then
        for _, inst in pairs(CurrentPlayerESPInstances) do
            pcall(function() inst:Destroy() end)
        end
        CurrentPlayerESPInstances = {}
    end
end)

-- 11. Fly Mode (Smooth 3D Flight)
AddToggleRow("Fly Mode (3D Flight)", "FlyMode", function(state) end)

-- 12. Best Egg ESP
AddToggleRow("Best Egg ESP", "EggESP", function(state)
    if not state then
        for _, highlight in pairs(CurrentEggESPInstances) do
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
        end
        CurrentEggESPInstances = {}
    end
end)

-- 13. Noclip Mode
AddToggleRow("Noclip (Phase Walls)", "Noclip", function(state) end)

-- 14. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump", function(state) end)

-- 15. Integrated WalkSpeed Row with - / + Pill Adjuster
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, -6, 0, 24)
SpeedRow.BackgroundTransparency = 1
SpeedRow.Parent = ContentFrame

local SpeedToggleBtn = Instance.new("TextButton")
SpeedToggleBtn.Size = UDim2.new(0.55, 0, 1, 0)
SpeedToggleBtn.BackgroundTransparency = 1
SpeedToggleBtn.Text = ""
SpeedToggleBtn.Active = true
SpeedToggleBtn.ZIndex = 5
SpeedToggleBtn.Parent = SpeedRow

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -26, 1, 0)
SpeedLabel.Position = UDim2.new(0, 4, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed"
SpeedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Active = false
SpeedLabel.ZIndex = 6
SpeedLabel.Parent = SpeedToggleBtn

local SpeedCheckBox = Instance.new("Frame")
SpeedCheckBox.Size = UDim2.new(0, 18, 0, 18)
SpeedCheckBox.Position = UDim2.new(1, -18, 0.5, -9)
SpeedCheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
SpeedCheckBox.BorderSizePixel = 0
SpeedCheckBox.Active = false
SpeedCheckBox.ZIndex = 6
SpeedCheckBox.Parent = SpeedToggleBtn

local SpeedCheckCorner = Instance.new("UICorner")
SpeedCheckCorner.CornerRadius = UDim.new(0, 4)
SpeedCheckCorner.Parent = SpeedCheckBox

local SpeedCheckStroke = Instance.new("UIStroke")
SpeedCheckStroke.Color = Color3.fromRGB(45, 45, 55)
SpeedCheckStroke.Thickness = 1.2
SpeedCheckStroke.Parent = SpeedCheckBox

local SpeedCheckMark = Instance.new("Frame")
SpeedCheckMark.Size = UDim2.new(0, 10, 0, 10)
SpeedCheckMark.Position = UDim2.new(0.5, -5, 0.5, -5)
SpeedCheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
SpeedCheckMark.BorderSizePixel = 0
SpeedCheckMark.Active = false
SpeedCheckMark.ZIndex = 7
SpeedCheckMark.Parent = SpeedCheckBox

local SpeedMarkCorner = Instance.new("UICorner")
SpeedMarkCorner.CornerRadius = UDim.new(0, 2)
SpeedMarkCorner.Parent = SpeedCheckMark

local function onSpeedToggle()
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
    UpdateCharacterSpeed()
end
SpeedToggleBtn.MouseButton1Click:Connect(onSpeedToggle)
SpeedToggleBtn.Activated:Connect(onSpeedToggle)

local SpeedControlFrame = Instance.new("Frame")
SpeedControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
SpeedControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
SpeedControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
SpeedControlFrame.BorderSizePixel = 0
SpeedControlFrame.ZIndex = 5
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
MinusBtn.Active = true
MinusBtn.ZIndex = 10
MinusBtn.Parent = SpeedControlFrame

local SpeedDisplay = Instance.new("TextLabel")
SpeedDisplay.Size = UDim2.new(1, -44, 1, 0)
SpeedDisplay.Position = UDim2.new(0, 22, 0, 0)
SpeedDisplay.BackgroundTransparency = 1
SpeedDisplay.Text = tostring(CustomSpeedValue)
SpeedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedDisplay.TextSize = 11
SpeedDisplay.Font = Enum.Font.GothamBold
SpeedDisplay.Active = false
SpeedDisplay.ZIndex = 6
SpeedDisplay.Parent = SpeedControlFrame

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 22, 1, 0)
PlusBtn.Position = UDim2.new(1, -22, 0, 0)
PlusBtn.BackgroundTransparency = 1
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
PlusBtn.TextSize = 14
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Active = true
PlusBtn.ZIndex = 10
PlusBtn.Parent = SpeedControlFrame

local function onMinus()
    CustomSpeedValue = math.max(16, CustomSpeedValue - 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end
MinusBtn.MouseButton1Click:Connect(onMinus)
MinusBtn.Activated:Connect(onMinus)

local function onPlus()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end
PlusBtn.MouseButton1Click:Connect(onPlus)
PlusBtn.Activated:Connect(onPlus)

-- Footer Frame
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

-- ====================================================
-- 1. CONTINUOUS MULTI-EGG AUTO STEAL & DEPOSIT ENGINE
-- ====================================================
local function GetLocationKey(pos)
    return math.floor(pos.X / 4) .. "_" .. math.floor(pos.Y / 4) .. "_" .. math.floor(pos.Z / 4)
end

local function FindNearestAvailableEgg(hrpPosition)
    local bestTargetCFrame = nil
    local bestPrompt = nil
    local bestPart = nil
    local bestLocKey = nil
    local shortestDist = math.huge
    local now = os.clock()

    -- 1. Scan ProximityPrompts for Steal / Egg prompts
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local pPart = prompt.Parent
            local targetPos = nil

            if pPart:IsA("BasePart") then
                targetPos = pPart.CFrame
            elseif pPart:IsA("Attachment") then
                targetPos = pPart.WorldCFrame
            elseif pPart:IsA("Model") and pPart.PrimaryPart then
                targetPos = pPart.PrimaryPart.CFrame
            end

            if targetPos then
                local locKey = GetLocationKey(targetPos.Position)
                local isCoolingDown = CooldownEggs[locKey] and (now < CooldownEggs[locKey])

                if not isCoolingDown then
                    local distFromBase = SavedBaseCFrame and (targetPos.Position - SavedBaseCFrame.Position).Magnitude or 100
                    if distFromBase > 12 then
                        local act = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
                        local pName = pPart.Name:lower()
                        
                        local isEggOrSteal = act:find("steal") or act:find("take") or act:find("grab") or act:find("egg") or act:find("brainrot") or act:find("pick") or act:find("collect") or pName:find("egg") or pName:find("brainrot") or act == "" or act == " "
                        
                        if isEggOrSteal then
                            local dist = (targetPos.Position - hrpPosition).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                bestTargetCFrame = targetPos
                                bestPrompt = prompt
                                bestPart = pPart:IsA("BasePart") and pPart or nil
                                bestLocKey = locKey
                            end
                        end
                    end
                end
            end
        end
    end

    -- 2. Fallback: Scan Workspace Models / BaseParts named Egg or Brainrot
    if not bestTargetCFrame then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if (name:find("egg") or name:find("brainrot")) and not name:find("gui") and not name:find("ui") then
                local tCFrame = nil
                local targetPart = nil
                
                if obj:IsA("BasePart") then
                    tCFrame = obj.CFrame
                    targetPart = obj
                elseif obj:IsA("Model") and obj.PrimaryPart then
                    tCFrame = obj.PrimaryPart.CFrame
                    targetPart = obj.PrimaryPart
                elseif obj:IsA("Model") then
                    local p = obj:FindFirstChildWhichIsA("BasePart")
                    if p then
                        tCFrame = p.CFrame
                        targetPart = p
                    end
                end

                if tCFrame then
                    local locKey = GetLocationKey(tCFrame.Position)
                    local isCoolingDown = CooldownEggs[locKey] and (now < CooldownEggs[locKey])

                    if not isCoolingDown then
                        local distFromBase = SavedBaseCFrame and (tCFrame.Position - SavedBaseCFrame.Position).Magnitude or 100
                        if distFromBase > 14 then
                            local dist = (tCFrame.Position - hrpPosition).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                bestTargetCFrame = tCFrame
                                bestPart = targetPart
                                bestLocKey = locKey
                                local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if p then bestPrompt = p end
                            end
                        end
                    end
                end
            end
        end
    end

    return bestTargetCFrame, bestPrompt, bestPart, bestLocKey
end

local function ReturnToBaseAndDeposit(hrp)
    if SavedBaseCFrame and isAlive() then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = SavedBaseCFrame * CFrame.new(0, 2, 0)
        task.wait(0.18)

        -- Deposit / Hatch trigger at Base
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Parent then
                local pos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or (prompt.Parent:IsA("Attachment") and prompt.Parent.WorldPosition or nil)
                if pos and (pos - hrp.Position).Magnitude < 50 then
                    InstantTriggerPrompt(prompt)
                end
            end
        end

        -- Base Touchpads trigger
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude < 45 then
                local n = part.Name:lower()
                if n:find("deposit") or n:find("hatch") or n:find("nest") or n:find("slot") or n:find("place") or n:find("base") or n:find("incub") then
                    InstantTouch(hrp, part)
                end
            end
        end
    end
end

-- Master Auto Steal Loop
task.spawn(function()
    while true do
        task.wait(0.15)
        if Toggles.AutoSteal and isAlive() then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                if not SavedBaseCFrame then
                    SavedBaseCFrame = hrp.CFrame
                end

                local targetCFrame, prompt, eggPart, locKey = FindNearestAvailableEgg(hrp.Position)

                if targetCFrame then
                    if locKey then
                        CooldownEggs[locKey] = os.clock() + 5
                    end

                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.CFrame = targetCFrame * CFrame.new(0, 1.8, 0)
                    task.wait(0.12)

                    if prompt then
                        InstantTriggerPrompt(prompt)
                    end

                    if eggPart then
                        InstantTouch(hrp, eggPart)
                    end

                    for _, p in ipairs(Workspace:GetDescendants()) do
                        if p:IsA("ProximityPrompt") and p.Parent then
                            local pPos = p.Parent:IsA("BasePart") and p.Parent.Position or nil
                            if pPos and (pPos - hrp.Position).Magnitude < 18 then
                                InstantTriggerPrompt(p)
                            end
                        end
                    end

                    task.wait(0.15)
                    ReturnToBaseAndDeposit(hrp)
                    task.wait(0.25)
                else
                    task.wait(0.35)
                end
            end
        end
    end
end)

-- ====================================================
-- 2. AUTO SELL BRAINROTS ENGINE (MULTI-LAYER FAST SELLER)
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoSell and isAlive() then
            local hrp = LocalPlayer.Character.HumanoidRootPart

            -- A. Fire Sell Remotes in ReplicatedStorage
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    local n = rem.Name:lower()
                    if n:find("sell") or n:find("sellall") or n:find("sellbrainrot") or n:find("sellegg") or n:find("cashout") or n:find("exchange") then
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer()
                            rem:FireServer("All")
                            rem:FireServer(true)
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer()
                            rem:InvokeServer("All")
                        end
                    end
                end
            end)

            -- B. Trigger Sell ProximityPrompts across base & map
            pcall(function()
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Parent then
                        local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                        if act:find("sell") or act:find("cash in") or act:find("exchange") or act:find("trade in") or act:find("deposit cash") then
                            local pPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or nil
                            if pPos and (pPos - hrp.Position).Magnitude < 180 then
                                InstantTriggerPrompt(prompt)
                            end
                        end
                    end
                end
            end)

            -- C. Touch Sell Pads / Merchant / Sell Zones
            pcall(function()
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local n = part.Name:lower()
                        if (n:find("sell") or n:find("sellpad") or n:find("sellzone") or n:find("dropzone") or n:find("merchant") or n:find("cashin")) and (part.Position - hrp.Position).Magnitude < 120 then
                            InstantTouch(hrp, part)
                        end
                    end
                end
            end)

            -- D. Trigger Sell GUI Buttons in PlayerGui
            pcall(function()
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui then
                    for _, btn in ipairs(pgui:GetDescendants()) do
                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                            local txt = (btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or "")):lower()
                            if (txt:find("sell all") or txt:find("sell") or txt:find("cash out")) and not txt:find("robux") and not txt:find("pass") then
                                if getconnections then
                                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
                                    for _, conn in ipairs(getconnections(btn.Activated)) do conn:Fire() end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================================================
-- 3. UNIVERSAL AUTO HATCH & INCUBATE ENGINE
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.3)
        if Toggles.AutoHatch and isAlive() then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local basePos = SavedBaseCFrame and SavedBaseCFrame.Position or hrp.Position

            -- A. Trigger all Hatch / Incubate Prompts across map and base
            pcall(function()
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Parent then
                        local pPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or (prompt.Parent:IsA("Attachment") and prompt.Parent.WorldPosition or nil)
                        if pPos then
                            local distToMe = (pPos - hrp.Position).Magnitude
                            local distToBase = (pPos - basePos).Magnitude
                            if distToMe < 150 or distToBase < 90 then
                                local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                                if act:find("hatch") or act:find("open") or act:find("incub") or act:find("craft") or act:find("place") or act:find("deposit") or act:find("egg") or act:find("trait") or act:find("claim") or act:find("slot") then
                                    InstantTriggerPrompt(prompt)
                                end
                            end
                        end
                    end
                end
            end)

            -- B. Touch All Incubators & Nests
            pcall(function()
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local n = part.Name:lower()
                        if n:find("incub") or n:find("hatch") or n:find("nest") or n:find("slot") or n:find("eggstand") then
                            if (part.Position - hrp.Position).Magnitude < 100 then
                                InstantTouch(hrp, part)
                            end
                        end
                    end
                end
            end)

            -- C. Fire All Hatch / Incubate Remotes in ReplicatedStorage
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    local n = rem.Name:lower()
                    if n:find("hatch") or n:find("openegg") or n:find("buyegg") or n:find("incub") or n:find("placeegg") or n:find("claimpet") or n:find("claimbrainrot") or n:find("traithatch") then
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer()
                            rem:FireServer(1)
                            rem:FireServer("Egg")
                            rem:FireServer("Basic")
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer()
                        end
                    end
                end
            end)

            -- D. Trigger UI Buttons for Hatching
            pcall(function()
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui then
                    for _, btn in ipairs(pgui:GetDescendants()) do
                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                            local txt = (btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or "")):lower()
                            if (txt:find("hatch") or txt:find("open 1") or txt:find("open") or txt:find("incubate")) and not txt:find("robux") and not txt:find("pass") then
                                if getconnections then
                                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
                                    for _, conn in ipairs(getconnections(btn.Activated)) do conn:Fire() end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================================================
-- 4. UNIVERSAL AUTO COLLECT DROPS & BASE CASH (MAGNET)
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoCollectDrops and isAlive() then
            local hrp = LocalPlayer.Character.HumanoidRootPart

            -- A. Collect All Map Drops
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local n = obj.Name:lower()
                    local isDrop = n:find("coin") or n:find("gem") or n:find("drop") or n:find("token") or n:find("cash") or n:find("star") or n:find("candy") or n:find("pickup") or n:find("reward") or n:find("money") or n:find("dollar") or n:find("bill")
                    if isDrop and not n:find("gui") and not n:find("ui") then
                        if obj:IsA("BasePart") and (obj.Position - hrp.Position).Magnitude < 350 then
                            InstantTouch(hrp, obj)
                        elseif obj:IsA("Model") and obj.PrimaryPart and (obj.PrimaryPart.Position - hrp.Position).Magnitude < 350 then
                            InstantTouch(hrp, obj.PrimaryPart)
                        elseif obj:IsA("ProximityPrompt") and obj.Parent then
                            local pPos = obj.Parent:IsA("BasePart") and obj.Parent.Position or nil
                            if pPos and (pPos - hrp.Position).Magnitude < 250 then
                                InstantTriggerPrompt(obj)
                            end
                        end
                    end
                end
            end)

            -- B. Collect Base Passive Income / ATM / Bank / Collector Pads
            pcall(function()
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local n = part.Name:lower()
                        if n:find("collector") or n:find("atm") or n:find("bank") or n:find("cashpad") or n:find("money") or n:find("income") or n:find("withdraw") then
                            if (part.Position - hrp.Position).Magnitude < 120 then
                                InstantTouch(hrp, part)
                            end
                        end
                    end
                end
            end)

            -- C. Fire Collection Remotes in ReplicatedStorage
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    local n = rem.Name:lower()
                    if n:find("collect") or n:find("pickup") or n:find("claimcash") or n:find("claimincome") or n:find("withdraw") or n:find("claimdrop") then
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer()
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer()
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================================================
-- 5. AUTO UPGRADE BASE, TREADMILL & STATS ENGINE
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.8)
        if Toggles.AutoUpgradeBase and isAlive() then
            local hrp = LocalPlayer.Character.HumanoidRootPart

            -- Trigger Upgrade ProximityPrompts & Pads in Base
            pcall(function()
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Parent then
                        local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                        if act:find("upgrade") or act:find("buy") or act:find("speed") or act:find("treadmill") or act:find("slot") or act:find("capacity") or act:find("base") then
                            local pPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or nil
                            if pPos and (pPos - hrp.Position).Magnitude < 150 then
                                InstantTriggerPrompt(prompt)
                            end
                        end
                    end
                end
            end)

            -- Touch Treadmill & Upgrade Buttons
            pcall(function()
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local n = part.Name:lower()
                        if (n:find("treadmill") or n:find("upgrade") or n:find("buyslot") or n:find("speedpad")) and (part.Position - hrp.Position).Magnitude < 100 then
                            InstantTouch(hrp, part)
                        end
                    end
                end
            end)

            -- Fire Upgrade Remotes in ReplicatedStorage
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    local n = rem.Name:lower()
                    if n:find("upgrade") or n:find("buyspeed") or n:find("buyslot") or n:find("treadmill") or n:find("upgradebase") or n:find("upgradetreadmill") then
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer()
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer()
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================================================
-- 6. AUTO REBIRTH ENGINE
-- ====================================================
task.spawn(function()
    while true do
        task.wait(1.2)
        if Toggles.AutoRebirth and isAlive() then
            pcall(function()
                for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
                    local n = desc.Name:lower()
                    if n:find("rebirth") or n:find("prestige") or n:find("ascend") then
                        if desc:IsA("RemoteEvent") then
                            desc:FireServer()
                        elseif desc:IsA("RemoteFunction") then
                            desc:InvokeServer()
                        end
                    end
                end
            end)
            pcall(function()
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui then
                    for _, btn in ipairs(pgui:GetDescendants()) do
                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                            local txt = (btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or "")):lower()
                            if txt:find("rebirth") or txt:find("prestige") then
                                if getconnections then
                                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
                                    for _, conn in ipairs(getconnections(btn.Activated)) do conn:Fire() end
                                end
                            end
                        end
                    end
                end
            end)
            pcall(function()
                local hrp = LocalPlayer.Character.HumanoidRootPart
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local n = part.Name:lower()
                        if (n:find("rebirth") or n:find("prestige")) and (part.Position - hrp.Position).Magnitude < 50 then
                            InstantTouch(hrp, part)
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================================================
-- 7. BULLETPROOF GODMODE & ANTI-STUN / LASER IMMUNITY
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.4)
        if Toggles.Godmode then
            pcall(function()
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local n = part.Name:lower()
                        local isKillOrTrap = n:find("kill") or n:find("laser") or n:find("trap") or n:find("death") or n:find("lava") or n:find("spike") or n:find("damage") or n:find("hazard")
                        if isKillOrTrap then
                            part.CanTouch = false
                            part.CanCollide = false
                            local tt = part:FindFirstChildWhichIsA("TouchTransmitter")
                            if tt then tt:Destroy() end
                        end
                    end
                end
            end)
        end
    end
end)

RunService.Stepped:Connect(function()
    if Toggles.Godmode and isAlive() then
        local char = LocalPlayer.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
            
            if hum.PlatformStand then hum.PlatformStand = false end
            if hum.Sit then hum.Sit = false end
            
            local currentState = hum:GetState()
            if currentState == Enum.HumanoidStateType.Ragdoll or currentState == Enum.HumanoidStateType.FallingDown or currentState == Enum.HumanoidStateType.PlatformStanding then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end

            if hum.WalkSpeed < 16 and not Toggles.WalkSpeedBoost then
                hum.WalkSpeed = 16
            end
            if hum.JumpPower == 0 then
                hum.JumpPower = 50
            end
        end

        for _, desc in ipairs(char:GetDescendants()) do
            if desc:IsA("BallSocketConstraint") or desc:IsA("HingeConstraint") or desc:IsA("NoCollisionConstraint") then
                if desc.Name:lower():find("ragdoll") or desc.Name:lower():find("stun") or desc.Name:lower():find("joint") then
                    pcall(function() desc:Destroy() end)
                end
            elseif desc:IsA("ValueBase") then
                local vn = desc.Name:lower()
                if vn:find("ragdoll") or vn:find("stun") or vn:find("knock") or vn:find("frozen") then
                    pcall(function() desc:Destroy() end)
                end
            end
        end

        if hrp then
            if hrp.Position.Y < -30 or hrp.AssemblyLinearVelocity.Y < -85 then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                if SavedBaseCFrame then
                    hrp.CFrame = SavedBaseCFrame * CFrame.new(0, 2, 0)
                else
                    hrp.CFrame = CFrame.new(hrp.Position.X, 15, hrp.Position.Z)
                end
            end
        end
    end
end)

-- ====================================================
-- 8. PLAYER ESP & BASE DEFENSE RADAR
-- ====================================================
RunService.RenderStepped:Connect(function()
    if Toggles.PlayerESP and isAlive() then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local char = plr.Character
                local hrp = char.HumanoidRootPart
                
                -- Highlight
                if not char:FindFirstChild("JunejoPlrHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "JunejoPlrHighlight"
                    hl.FillColor = Color3.fromRGB(255, 60, 60)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.3
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                    table.insert(CurrentPlayerESPInstances, hl)
                end
                
                -- Radar Billboard
                if not hrp:FindFirstChild("JunejoRadarBillboard") then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "JunejoRadarBillboard"
                    bb.Size = UDim2.new(0, 180, 0, 32)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = hrp
                    bb.Parent = hrp
                    
                    local label = Instance.new("TextLabel")
                    label.Name = "InfoLabel"
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(255, 80, 80)
                    label.TextStrokeTransparency = 0
                    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    label.TextSize = 11
                    label.Font = Enum.Font.GothamBold
                    label.Parent = bb
                    table.insert(CurrentPlayerESPInstances, bb)
                end
                
                local bb = hrp:FindFirstChild("JunejoRadarBillboard")
                if bb and bb:FindFirstChild("InfoLabel") and isAlive() then
                    local myHrp = LocalPlayer.Character.HumanoidRootPart
                    local distToMe = math.floor((hrp.Position - myHrp.Position).Magnitude)
                    local baseDistText = ""
                    if SavedBaseCFrame then
                        local distToBase = math.floor((hrp.Position - SavedBaseCFrame.Position).Magnitude)
                        baseDistText = " | Base: " .. distToBase .. "s"
                    end
                    bb.InfoLabel.Text = plr.DisplayName .. " [" .. distToMe .. "s" .. baseDistText .. "]"
                end
            end
        end
    end
end)

-- ====================================================
-- 9. FLY MODE (UNIVERSAL MOBILE & PC FLIGHT)
-- ====================================================
local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local FlySpeed = 65

local function EnableFly()
    if not isAlive() then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Name = "JunejoFlyVelocity"
    FlyBodyVelocity.MaxForce = Vector3.new(9e5, 9e5, 9e5)
    FlyBodyVelocity.Velocity = Vector3.zero
    FlyBodyVelocity.Parent = hrp
    
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.Name = "JunejoFlyGyro"
    FlyBodyGyro.MaxTorque = Vector3.new(9e5, 9e5, 9e5)
    FlyBodyGyro.CFrame = hrp.CFrame
    FlyBodyGyro.Parent = hrp
end

local function DisableFly()
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
    if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
end

RunService.RenderStepped:Connect(function()
    if Toggles.FlyMode and isAlive() then
        if not FlyBodyVelocity or not FlyBodyVelocity.Parent then
            EnableFly()
        end
        local cam = Workspace.CurrentCamera
        local moveDir = Vector3.zero
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        -- PC WASD Controls
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        -- Mobile Touch Thumbstick support
        if hum and hum.MoveDirection.Magnitude > 0 and moveDir.Magnitude == 0 then
            moveDir = (cam.CFrame.LookVector * hum.MoveDirection.Z * -1) + (cam.CFrame.RightVector * hum.MoveDirection.X)
            if hum.Jump then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
        end
        
        if FlyBodyGyro then FlyBodyGyro.CFrame = cam.CFrame end
        if FlyBodyVelocity then
            if moveDir.Magnitude > 0 then
                FlyBodyVelocity.Velocity = moveDir.Unit * (Toggles.WalkSpeedBoost and CustomSpeedValue or FlySpeed)
            else
                FlyBodyVelocity.Velocity = Vector3.zero
            end
        end
    else
        if FlyBodyVelocity or FlyBodyGyro then
            DisableFly()
        end
    end
end)

-- ====================================================
-- 10. BEST EGG ESP ENGINE
-- ====================================================
RunService.RenderStepped:Connect(function()
    if Toggles.EggESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if (obj:IsA("Model") or obj:IsA("BasePart")) and (name:find("egg") or name:find("brainrot")) and not name:find("gui") then
                if not obj:FindFirstChild("JunejoEggESP") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "JunejoEggESP"
                    highlight.FillColor = Color3.fromRGB(255, 215, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.25
                    highlight.OutlineTransparency = 0
                    highlight.Parent = obj
                    table.insert(CurrentEggESPInstances, highlight)
                end
            end
        end
    end
end)

-- ====================================================
-- 11. NOCLIP ENGINE & SPEED KEEPER
-- ====================================================
RunService.Stepped:Connect(function()
    if isAlive() then
        if Toggles.Noclip or Toggles.AutoSteal then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        if Toggles.WalkSpeedBoost then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = CustomSpeedValue end
        end
    end
end)

-- ====================================================
-- 12. INFINITE JUMP (MOBILE & PC UNIVERSAL)
-- ====================================================
UIS.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function()
    if Toggles.InfiniteJump and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Jump then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Character Added Re-hook
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateCharacterSpeed()
end)

-- ====================================================
-- 13. ANTI-AFK ENGINE
-- ====================================================
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end
end)
