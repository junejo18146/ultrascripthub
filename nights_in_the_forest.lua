-- ====================================================================
-- ULTRA SCRIPT HUB - 99 NIGHTS IN THE FOREST
-- Creator: Junejo (junejo18146)
-- Target Game: 99 Nights in the Forest
-- ====================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- Feature Toggles
local Toggles = {
    KillAura = false,
    AutoFeedCampfire = false,
    ChildrenESP = false,
    FullBright = false,
    MonsterESP = false,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

local CustomSpeedValue = 32
local ESPStorage = {
    Children = {},
    Monsters = {}
}

-- Lighting Backup for FullBright
local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

-- Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Speed Enforcer Loop
local function UpdateCharacterSpeed()
    if Humanoid then
        Humanoid.WalkSpeed = Toggles.WalkSpeedBoost and CustomSpeedValue or 16
    end
end

RunService.Heartbeat:Connect(function()
    if Toggles.WalkSpeedBoost and Humanoid and Humanoid.WalkSpeed ~= CustomSpeedValue then
        Humanoid.WalkSpeed = CustomSpeedValue
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Instant Prompts Helper
local function PatchPrompt(prompt)
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 45
        prompt.RequiresLineOfSight = false
    end
end

task.spawn(function()
    while true do
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                PatchPrompt(prompt)
            end
        end
        task.wait(1)
    end
end)

-- Find Main Campfire
local function GetCampfire()
    local names = {"Campfire", "Fire", "FirePit", "MainFire", "CampFire", "Camp"}
    for _, name in ipairs(names) do
        local obj = Workspace:FindFirstChild(name, true)
        if obj then
            if obj:IsA("BasePart") then
                return obj
            elseif obj:IsA("Model") then
                return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            end
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if string.find(string.lower(obj.Name), "campfire") and obj:IsA("BasePart") then
            return obj
        end
    end
    return nil
end

-- ====================================================================
-- 1. KILL AURA (AUTO ATTACK MOBS)
-- ====================================================================

task.spawn(function()
    while true do
        if Toggles.KillAura and HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
            pcall(function()
                local tool = Character:FindFirstChildWhichIsA("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                if tool and tool.Parent ~= Character then
                    Humanoid:EquipTool(tool)
                end

                for _, model in ipairs(Workspace:GetDescendants()) do
                    if model:IsA("Model") and model ~= Character and not Players:GetPlayerFromCharacter(model) then
                        local mobHum = model:FindFirstChild("Humanoid")
                        local mobPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChildWhichIsA("BasePart")
                        if mobHum and mobHum.Health > 0 and mobPart then
                            local dist = (mobPart.Position - HumanoidRootPart.Position).Magnitude
                            if dist <= 55 then
                                if tool then
                                    tool:Activate()
                                end
                                -- Sweep Combat Remotes
                                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                                    if rem:IsA("RemoteEvent") then
                                        local rName = string.lower(rem.Name)
                                        if string.find(rName, "attack") or string.find(rName, "damage") or string.find(rName, "hit") or string.find(rName, "slash") or string.find(rName, "swing") then
                                            rem:FireServer(model, mobPart.Position)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.2)
    end
end)

-- ====================================================================
-- 2. AUTO FEED CAMPFIRE
-- ====================================================================

task.spawn(function()
    while true do
        if Toggles.AutoFeedCampfire then
            pcall(function()
                local fire = GetCampfire()
                if fire then
                    local fuelKeywords = {"log", "wood", "coal", "fuel", "gas", "oil", "branch"}
                    for _, item in ipairs(Workspace:GetDescendants()) do
                        if item:IsA("BasePart") or item:IsA("Model") then
                            local itemName = string.lower(item.Name)
                            for _, kw in ipairs(fuelKeywords) do
                                if string.find(itemName, kw) and not item:IsDescendantOf(Character) then
                                    local p = item:IsA("BasePart") and item or (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart"))
                                    if p then
                                        p.CFrame = fire.CFrame * CFrame.new(0, 1, 0)
                                        firetouchinterest(p, fire, 0)
                                        firetouchinterest(p, fire, 1)

                                        local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                        if prompt then
                                            PatchPrompt(prompt)
                                            fireproximityprompt(prompt, 0)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(1.5)
    end
end)

-- ====================================================================
-- 3-6. 1-CLICK ACTION FUNCTIONS (BRING & TELEPORT)
-- ====================================================================

local function TeleportToCampfireAction()
    if HumanoidRootPart then
        local fire = GetCampfire()
        if fire then
            HumanoidRootPart.Velocity = Vector3.zero
            HumanoidRootPart.CFrame = fire.CFrame * CFrame.new(0, 3, 4)
        end
    end
end

local function BringItemsByKeywords(keywords)
    if not HumanoidRootPart then return end
    pcall(function()
        local count = 0
        for _, item in ipairs(Workspace:GetDescendants()) do
            if (item:IsA("BasePart") or item:IsA("Model")) and not item:IsDescendantOf(Character) then
                local iName = string.lower(item.Name)
                for _, kw in ipairs(keywords) do
                    if string.find(iName, kw) then
                        local p = item:IsA("BasePart") and item or (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart"))
                        if p then
                            p.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 1, 0)
                            count = count + 1
                            local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt then
                                PatchPrompt(prompt)
                                fireproximityprompt(prompt, 0)
                            end
                        end
                        break
                    end
                end
            end
        end
    end)
end

local function BringFuelAction()
    BringItemsByKeywords({"log", "wood", "coal", "fuel", "gas", "oil", "branch"})
end

local function BringFoodAction()
    BringItemsByKeywords({"berry", "berries", "mushroom", "soup", "corn", "meat", "apple", "food", "stew", "bread"})
end

local function BringMedsAction()
    BringItemsByKeywords({"bandage", "medkit", "pill", "pills", "gauze", "med", "medicine", "aid", "firstaid"})
end

-- ====================================================================
-- 7. FULLBRIGHT (NIGHT VISION & NO FOG)
-- ====================================================================

local function UpdateFullBright(enable)
    if enable then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    else
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    end
end

RunService.RenderStepped:Connect(function()
    if Toggles.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end
end)

-- ====================================================================
-- 8-9. ESP SYSTEMS (CHILDREN & MONSTERS)
-- ====================================================================

local function ClearESPFolder(list)
    for _, item in ipairs(list) do
        if item then item:Destroy() end
    end
    return {}
end

-- 8. Missing Children ESP
task.spawn(function()
    while true do
        if Toggles.ChildrenESP then
            local childKeywords = {"child", "kid", "lost", "missing", "boy", "girl", "npc", "rescue"}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= Character and not Players:GetPlayerFromCharacter(obj) and not obj:FindFirstChild("JunejoChildHighlight") then
                    local name = string.lower(obj.Name)
                    local isChild = false
                    for _, kw in ipairs(childKeywords) do
                        if string.find(name, kw) then
                            isChild = true
                            break
                        end
                    end

                    if isChild then
                        local targetPart = obj.PrimaryPart or obj:FindFirstChild("Head") or obj:FindFirstChildWhichIsA("BasePart")
                        if targetPart then
                            local hl = Instance.new("Highlight")
                            hl.Name = "JunejoChildHighlight"
                            hl.FillColor = Color3.fromRGB(0, 255, 200)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.4
                            hl.Adornee = obj
                            hl.Parent = obj
                            table.insert(ESPStorage.Children, hl)

                            local bb = Instance.new("BillboardGui")
                            bb.Name = "JunejoChildBillboard"
                            bb.Adornee = targetPart
                            bb.Size = UDim2.new(0, 130, 0, 24)
                            bb.StudsOffset = Vector3.new(0, 3, 0)
                            bb.AlwaysOnTop = true
                            bb.Parent = targetPart

                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.Text = "👶 " .. obj.Name
                            txt.TextColor3 = Color3.fromRGB(0, 255, 220)
                            txt.TextSize = 11
                            txt.Font = Enum.Font.GothamBold
                            txt.Parent = bb

                            table.insert(ESPStorage.Children, bb)
                        end
                    end
                end
            end
        else
            ESPStorage.Children = ClearESPFolder(ESPStorage.Children)
        end
        task.wait(2.5)
    end
end)

-- 9. Monster & Entity ESP (The Deer / Cultists / Wolves)
task.spawn(function()
    while true do
        if Toggles.MonsterESP then
            local monsterKeywords = {"deer", "owl", "ram", "bat", "cultist", "wolf", "bear", "monster", "beast", "stalker", "wendigo", "mammoth", "enemy"}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= Character and not Players:GetPlayerFromCharacter(obj) and not obj:FindFirstChild("JunejoMonsterHighlight") then
                    local name = string.lower(obj.Name)
                    local isMonster = false
                    for _, kw in ipairs(monsterKeywords) do
                        if string.find(name, kw) then
                            isMonster = true
                            break
                        end
                    end

                    if isMonster then
                        local targetPart = obj.PrimaryPart or obj:FindFirstChild("Head") or obj:FindFirstChildWhichIsA("BasePart")
                        if targetPart then
                            local hl = Instance.new("Highlight")
                            hl.Name = "JunejoMonsterHighlight"
                            hl.FillColor = Color3.fromRGB(255, 40, 40)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.4
                            hl.Adornee = obj
                            hl.Parent = obj
                            table.insert(ESPStorage.Monsters, hl)

                            local bb = Instance.new("BillboardGui")
                            bb.Name = "JunejoMonsterBillboard"
                            bb.Adornee = targetPart
                            bb.Size = UDim2.new(0, 130, 0, 24)
                            bb.StudsOffset = Vector3.new(0, 3, 0)
                            bb.AlwaysOnTop = true
                            bb.Parent = targetPart

                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.Text = "👹 " .. obj.Name
                            txt.TextColor3 = Color3.fromRGB(255, 70, 70)
                            txt.TextSize = 11
                            txt.Font = Enum.Font.GothamBold
                            txt.Parent = bb

                            table.insert(ESPStorage.Monsters, bb)
                        end
                    end
                end
            end
        else
            ESPStorage.Monsters = ClearESPFolder(ESPStorage.Monsters)
        end
        task.wait(2.5)
    end
end)

-- ====================================================================
-- JUNEJO OFFICIAL COMPACT SCROLLING UI (5 FEATURES VISIBLE AT A TIME)
-- ====================================================================

local CoreGui = game:GetService("CoreGui")
local ExistingUI = CoreGui:FindFirstChild("JunejoHubUI")
if ExistingUI then ExistingUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = CoreGui

-- Compact Standard MainFrame (280x225px)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 225)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -112)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Header (32px)
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
TitleLabel.TextSize = 11
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
    ClearESPFolder(ESPStorage.Children)
    ClearESPFolder(ESPStorage.Monsters)
    UpdateFullBright(false)
    ScreenGui:Destroy() 
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Scrollable Content Frame (Shows Exactly 5 Items at a time, Scroll for rest!)
local ScrollingContent = Instance.new("ScrollingFrame")
ScrollingContent.Name = "ScrollingContent"
ScrollingContent.Size = UDim2.new(1, -24, 0, 145)
ScrollingContent.Position = UDim2.new(0, 12, 0, 38)
ScrollingContent.BackgroundTransparency = 1
ScrollingContent.BorderSizePixel = 0
ScrollingContent.ScrollBarThickness = 3
ScrollingContent.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 85)
ScrollingContent.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingContent.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollingContent.ClipsDescendants = true
ScrollingContent.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ScrollingContent

-- Helper function for Toggle Rows
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ScrollingContent
    
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
    CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox
    
    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark
    
    RowBtn.MouseButton1Click:Connect(function()
        Toggles[configKey] = not Toggles[configKey]
        CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
        if callback then callback(Toggles[configKey]) end
    end)
end

-- 1-Click Action Row Helper
local function AddActionRow(text, btnText, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ScrollingContent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(0.38, 0, 1, 0)
    ActionBtn.Position = UDim2.new(0.62, 0, 0, 0)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ActionBtn.Text = btnText
    ActionBtn.TextColor3 = Color3.fromRGB(255, 220, 50)
    ActionBtn.TextSize = 11
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.Parent = Row

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ActionBtn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = ActionBtn

    ActionBtn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

-- Add All Top 10 Features to the Scrolling List
AddToggleRow("Kill Aura (Auto Attack)", "KillAura")
AddToggleRow("Auto Feed Campfire", "AutoFeedCampfire")
AddActionRow("Teleport to Campfire", "Teleport", TeleportToCampfireAction)
AddActionRow("Bring Fuel (Wood/Gas)", "Bring Fuel", BringFuelAction)
AddActionRow("Bring Food (Berries/Meat)", "Bring Food", BringFoodAction)
AddActionRow("Bring Meds (Bandages)", "Bring Meds", BringMedsAction)
AddToggleRow("Missing Children ESP", "ChildrenESP")
AddToggleRow("FullBright (No Darkness)", "FullBright", UpdateFullBright)
AddToggleRow("Monster & Entity ESP", "MonsterESP")
AddToggleRow("Infinite Jump", "InfiniteJump")

-- Integrated WalkSpeed Row with Pill Adjuster
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, -6, 0, 23)
SpeedRow.BackgroundTransparency = 1
SpeedRow.Parent = ScrollingContent

local SpeedToggleBtn = Instance.new("TextButton")
SpeedToggleBtn.Size = UDim2.new(0.55, 0, 1, 0)
SpeedToggleBtn.BackgroundTransparency = 1
SpeedToggleBtn.Text = ""
SpeedToggleBtn.ZIndex = 5
SpeedToggleBtn.Parent = SpeedRow

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -26, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed"
SpeedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedToggleBtn

local SpeedCheckBox = Instance.new("Frame")
SpeedCheckBox.Size = UDim2.new(0, 18, 0, 18)
SpeedCheckBox.Position = UDim2.new(1, -18, 0.5, -9)
SpeedCheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
SpeedCheckBox.BorderSizePixel = 0
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
SpeedCheckMark.Parent = SpeedCheckBox

local MarkCorner = Instance.new("UICorner")
MarkCorner.CornerRadius = UDim.new(0, 2)
MarkCorner.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
    UpdateCharacterSpeed()
end)

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
SpeedDisplay.Text = tostring(CustomSpeedValue)
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
    CustomSpeedValue = math.max(16, CustomSpeedValue - 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(250, CustomSpeedValue + 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

-- Footer (Pinned at bottom, 36px)
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
