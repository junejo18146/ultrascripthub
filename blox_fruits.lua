--[[
    ========================================================================
    ULTRA SCRIPT HUB - OFFICIAL PRODUCTION SCRIPT
    ========================================================================
    Game: Blox Fruits
    Game Link: https://www.roblox.com/games/2753915549/Blox-Fruits
    Creator: Made by Junejo (junejo18146)
    UI Style: UI 1 (Official Ultra Script Hub Classic Matte Dark - 280px)
    GitHub: https://github.com/junejo18146/ultrascripthub
    ========================================================================
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Safe Parent Selection for CoreGui / PlayerGui / gethui
local function GetSafeGuiParent()
    local success, parent = pcall(function()
        if gethui then return gethui() end
        if CoreGui and pcall(function() return CoreGui.Name end) then
            return CoreGui
        end
        return LocalPlayer:WaitForChild("PlayerGui")
    end)
    return (success and parent) or LocalPlayer:WaitForChild("PlayerGui")
end

local GuiParent = GetSafeGuiParent()

-- Cleanup Existing UI Instances
pcall(function()
    for _, name in ipairs({"UltraScriptHub_BloxFruits", "SakiScriptsBloxFruitsUI", "JunejoHubUI_BloxFruits"}) do
        if GuiParent:FindFirstChild(name) then GuiParent[name]:Destroy() end
        if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end
end)

-- Feature State Flags
_G.AutoFarmLevel = false
_G.InfJumpActive = false
_G.ChestESPActive = false
_G.FruitESPActive = false
_G.WalkSpeedActive = false
_G.WalkSpeedValue = 50

-- 24/7 Anti-AFK Idle Kick Protection
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraScriptHub_BloxFruits"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

-- =================================================================
-- UI 1 MASTER CONTAINER (280px Width Classic Matte Dark)
-- =================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 260)
MainFrame.Position = UDim2.new(0.5, -140, 0.45, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Draggable Logic (PC Mouse & Mobile Touch)
local dragging = false
local dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
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

MainFrame.InputChanged:Connect(function(input)
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

-- Mobile Floating Toggle Button
local FloatingToggle = Instance.new("ImageButton")
FloatingToggle.Name = "FloatingToggle"
FloatingToggle.Size = UDim2.new(0, 42, 0, 42)
FloatingToggle.Position = UDim2.new(0.04, 0, 0.45, 0)
FloatingToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
FloatingToggle.BorderSizePixel = 0
FloatingToggle.Visible = false
FloatingToggle.Active = true
FloatingToggle.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatingToggle

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(35, 35, 42)
FloatStroke.Thickness = 1
FloatStroke.Parent = FloatingToggle

local FloatIcon = Instance.new("TextLabel")
FloatIcon.Size = UDim2.new(1, 0, 1, 0)
FloatIcon.BackgroundTransparency = 1
FloatIcon.Text = "⚔️"
FloatIcon.TextSize = 20
FloatIcon.Font = Enum.Font.GothamBold
FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatIcon.Parent = FloatingToggle

-- Floating Toggle Dragging
local floatDragging = false
local floatDragStart, floatStartPos

FloatingToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        floatDragging = true
        floatDragStart = input.Position
        floatStartPos = FloatingToggle.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                floatDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if floatDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - floatDragStart
        FloatingToggle.Position = UDim2.new(floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X, floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y)
    end
end)

-- Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "BLOX FRUITS"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 22, 0, 22)
CloseButton.Position = UDim2.new(1, -32, 0.5, -11)
CloseButton.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(170, 170, 185)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.AutoButtonColor = false
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = Color3.fromRGB(45, 45, 55)
CloseStroke.Thickness = 1
CloseStroke.Parent = CloseButton

-- Close & Minimize Click Handling
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatingToggle.Visible = true
end)

FloatingToggle.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatingToggle.Visible = false
end)

-- Divider Line
local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.Size = UDim2.new(1, -28, 0, 1)
Divider.Position = UDim2.new(0, 14, 0, 36)
Divider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- Content Container
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -28, 0, 172)
Content.Position = UDim2.new(0, 14, 0, 44)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.Parent = Content

-- =================================================================
-- UI BUILDER FUNCTIONS (UI 1 BORDERLESS ROW WITH CHECKBOX & STEPPER)
-- =================================================================

-- Standard Feature Row (Left label, right rounded square checkbox)
local function CreateFeatureRow(name, defaultState, layoutOrder, onToggle)
    local state = defaultState or false

    local row = Instance.new("Frame")
    row.Name = name .. "Row"
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder
    row.Parent = Content

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -30, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(240, 240, 245)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local box = Instance.new("TextButton")
    box.Name = "Box"
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(1, -20, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    box.BorderSizePixel = 0
    box.Text = ""
    box.AutoButtonColor = false
    box.Parent = row

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 5)
    boxCorner.Parent = box

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(45, 45, 55)
    boxStroke.Thickness = 1
    boxStroke.Parent = box

    local check = Instance.new("Frame")
    check.Name = "Check"
    check.Size = UDim2.new(0, 12, 0, 12)
    check.Position = UDim2.new(0.5, -6, 0.5, -6)
    check.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    check.BorderSizePixel = 0
    check.Visible = state
    check.Parent = box

    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 3)
    checkCorner.Parent = check

    local function toggleState()
        state = not state
        check.Visible = state
        if onToggle then
            task.spawn(onToggle, state)
        end
    end

    box.MouseButton1Click:Connect(toggleState)

    local hitArea = Instance.new("TextButton")
    hitArea.Name = "HitArea"
    hitArea.Size = UDim2.new(1, -25, 1, 0)
    hitArea.BackgroundTransparency = 1
    hitArea.Text = ""
    hitArea.Parent = row
    hitArea.MouseButton1Click:Connect(toggleState)

    return row
end

-- Speed Row: Checkbox + Integrated Stepper Pill `[ - 50 + ]`
local function CreateSpeedRow(layoutOrder)
    local state = _G.WalkSpeedActive or false
    local current = _G.WalkSpeedValue or 50

    local row = Instance.new("Frame")
    row.Name = "WalkSpeedRow"
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder
    row.Parent = Content

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 85, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "WalkSpeed"
    label.TextColor3 = Color3.fromRGB(240, 240, 245)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    -- Checkbox
    local box = Instance.new("TextButton")
    box.Name = "Box"
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(0, 95, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    box.BorderSizePixel = 0
    box.Text = ""
    box.AutoButtonColor = false
    box.Parent = row

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 5)
    boxCorner.Parent = box

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(45, 45, 55)
    boxStroke.Thickness = 1
    boxStroke.Parent = box

    local check = Instance.new("Frame")
    check.Name = "Check"
    check.Size = UDim2.new(0, 12, 0, 12)
    check.Position = UDim2.new(0.5, -6, 0.5, -6)
    check.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    check.BorderSizePixel = 0
    check.Visible = state
    check.Parent = box

    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 3)
    checkCorner.Parent = check

    box.MouseButton1Click:Connect(function()
        state = not state
        check.Visible = state
        _G.WalkSpeedActive = state
        if not state then
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
                end
            end)
        end
    end)

    -- Stepper Pill Frame
    local pill = Instance.new("Frame")
    pill.Name = "Pill"
    pill.Size = UDim2.new(0, 105, 0, 24)
    pill.Position = UDim2.new(1, -105, 0.5, -12)
    pill.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    pill.BorderSizePixel = 0
    pill.Parent = row

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(0, 6)
    pillCorner.Parent = pill

    local pillStroke = Instance.new("UIStroke")
    pillStroke.Color = Color3.fromRGB(45, 45, 55)
    pillStroke.Thickness = 1
    pillStroke.Parent = pill

    local minus = Instance.new("TextButton")
    minus.Name = "Minus"
    minus.Size = UDim2.new(0, 28, 1, 0)
    minus.Position = UDim2.new(0, 0, 0, 0)
    minus.BackgroundTransparency = 1
    minus.Text = "-"
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 14
    minus.TextColor3 = Color3.fromRGB(200, 200, 210)
    minus.Parent = pill

    local valLabel = Instance.new("TextLabel")
    valLabel.Name = "Value"
    valLabel.Size = UDim2.new(1, -56, 1, 0)
    valLabel.Position = UDim2.new(0, 28, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(current)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 12
    valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valLabel.Parent = pill

    local plus = Instance.new("TextButton")
    plus.Name = "Plus"
    plus.Size = UDim2.new(0, 28, 1, 0)
    plus.Position = UDim2.new(1, -28, 0, 0)
    plus.BackgroundTransparency = 1
    plus.Text = "+"
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 14
    plus.TextColor3 = Color3.fromRGB(200, 200, 210)
    plus.Parent = pill

    minus.MouseButton1Click:Connect(function()
        current = math.max(16, current - 5)
        _G.WalkSpeedValue = current
        valLabel.Text = tostring(current)
    end)

    plus.MouseButton1Click:Connect(function()
        current = math.min(250, current + 5)
        _G.WalkSpeedValue = current
        valLabel.Text = tostring(current)
    end)
end

-- =================================================================
-- REGISTER FEATURE ROWS
-- =================================================================

-- 1. Auto Farm Level
CreateFeatureRow("Auto Farm Level", _G.AutoFarmLevel, 1, function(enabled)
    _G.AutoFarmLevel = enabled
end)

-- 2. Chest ESP
CreateFeatureRow("Chest ESP", _G.ChestESPActive, 2, function(enabled)
    _G.ChestESPActive = enabled
    if not enabled and chestESPFolder then
        chestESPFolder:ClearAllChildren()
    end
end)

-- 3. Fruit ESP
CreateFeatureRow("Fruit ESP", _G.FruitESPActive, 3, function(enabled)
    _G.FruitESPActive = enabled
    if not enabled and fruitESPFolder then
        fruitESPFolder:ClearAllChildren()
    end
end)

-- 4. Infinite Jump
CreateFeatureRow("Infinite Jump", _G.InfJumpActive, 4, function(enabled)
    _G.InfJumpActive = enabled
end)

-- 5. WalkSpeed (With Checkbox & Stepper Pill)
CreateSpeedRow(5)

-- =================================================================
-- MANDATORY FOOTER (CENTERED BRANDING)
-- =================================================================
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 32)
Footer.Position = UDim2.new(0, 0, 1, -34)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local HubTitle = Instance.new("TextLabel")
HubTitle.Name = "HubTitle"
HubTitle.Size = UDim2.new(1, 0, 0, 14)
HubTitle.Position = UDim2.new(0, 0, 0, 0)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "ULTRA SCRIPT HUB"
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 11
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextXAlignment = Enum.TextXAlignment.Center
HubTitle.Parent = Footer

local CreatorTitle = Instance.new("TextLabel")
CreatorTitle.Name = "CreatorTitle"
CreatorTitle.Size = UDim2.new(1, 0, 0, 14)
CreatorTitle.Position = UDim2.new(0, 0, 0, 14)
CreatorTitle.BackgroundTransparency = 1
CreatorTitle.Text = "Made by Junejo"
CreatorTitle.TextColor3 = Color3.fromRGB(136, 136, 153)
CreatorTitle.TextSize = 10
CreatorTitle.Font = Enum.Font.GothamMedium
CreatorTitle.TextXAlignment = Enum.TextXAlignment.Center
CreatorTitle.Parent = Footer

-- =================================================================
-- GAMEPLAY ENGINE & FEATURE IMPLEMENTATIONS (FROM PROVIDED CODE)
-- =================================================================

-- 1. WalkSpeed Bypass Engine (RenderStepped CFrame translation bypass)
RunService.RenderStepped:Connect(function(deltaTime)
    pcall(function()
        if _G.WalkSpeedActive and _G.WalkSpeedValue and _G.WalkSpeedValue > 16 then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                local hum = char.Humanoid
                local hrp = char.HumanoidRootPart
                if hum.MoveDirection.Magnitude > 0 then
                    local speedBoost = (_G.WalkSpeedValue - 16)
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (speedBoost * deltaTime))
                end
            end
        end
    end)
end)

-- 2. Reliable Infinite Jump (Mobile & PC)
UserInputService.JumpRequest:Connect(function()
    if _G.InfJumpActive then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- 3. Noclip Handler (Prevents getting stuck in terrain/objects during auto-farm)
RunService.Stepped:Connect(function()
    if _G.AutoFarmLevel then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- Helper: Auto-Equip Weapon / Combat Tool
local function equipCombatTool()
    pcall(function()
        local character = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not character or not backpack then return end
        
        local currentTool = character:FindFirstChildOfClass("Tool")
        if not currentTool then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    character.Humanoid:EquipTool(tool)
                    break
                end
            end
        end
    end)
end

-- Helper: Safe BodyPosition / CFrame movement for Farming
local function setFarmPosition(targetCFrame)
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local bv = rootPart:FindFirstChild("BF_FlyVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "BF_FlyVelocity"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.zero
            bv.Parent = rootPart
        end
        
        rootPart.CFrame = targetCFrame
    end)
end

local function removeFarmVelocity()
    pcall(function()
        local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart and rootPart:FindFirstChild("BF_FlyVelocity") then
            rootPart.BF_FlyVelocity:Destroy()
        end
    end)
end

-- Quest Database for Blox Fruits Leveling
local QuestList = {
    { Min = 1, Max = 9, Quest = "BanditQuest1", ID = 1, Mob = "Bandit" },
    { Min = 10, Max = 14, Quest = "JungleQuest", ID = 1, Mob = "Monkey" },
    { Min = 15, Max = 29, Quest = "JungleQuest", ID = 2, Mob = "Gorilla" },
    { Min = 30, Max = 39, Quest = "BuggyQuest1", ID = 1, Mob = "Pirate" },
    { Min = 40, Max = 59, Quest = "BuggyQuest1", ID = 2, Mob = "Brute" },
    { Min = 60, Max = 74, Quest = "DesertQuest", ID = 1, Mob = "Desert Bandit" },
    { Min = 75, Max = 89, Quest = "DesertQuest", ID = 2, Mob = "Desert Officer" },
    { Min = 90, Max = 99, Quest = "SnowQuest", ID = 1, Mob = "Snow Bandit" },
    { Min = 100, Max = 119, Quest = "SnowQuest", ID = 2, Mob = "Snowman" },
    { Min = 120, Max = 149, Quest = "MarineQuest2", ID = 1, Mob = "Chief Petty Officer" },
    { Min = 150, Max = 174, Quest = "SkyQuest", ID = 1, Mob = "Sky Bandit" },
    { Min = 175, Max = 189, Quest = "SkyQuest", ID = 2, Mob = "Dark Master" },
    { Min = 190, Max = 209, Quest = "PrisonerQuest", ID = 1, Mob = "Prisoner" },
    { Min = 210, Max = 249, Quest = "PrisonerQuest", ID = 2, Mob = "Dangerous Prisoner" },
    { Min = 250, Max = 274, Quest = "ColosseumQuest", ID = 1, Mob = "Toga Warrior" },
    { Min = 275, Max = 299, Quest = "ColosseumQuest", ID = 2, Mob = "Gladiator" },
    { Min = 300, Max = 324, Quest = "MagmaQuest", ID = 1, Mob = "Military Soldier" },
    { Min = 325, Max = 374, Quest = "MagmaQuest", ID = 2, Mob = "Military Spy" },
    { Min = 375, Max = 399, Quest = "FishmanQuest", ID = 1, Mob = "Fishman Warrior" },
    { Min = 400, Max = 449, Quest = "FishmanQuest", ID = 2, Mob = "Fishman Commando" },
    { Min = 450, Max = 474, Quest = "SkyQuest", ID = 1, Mob = "God's Guard" },
    { Min = 475, Max = 524, Quest = "SkyQuest", ID = 2, Mob = "Shanda" },
    { Min = 525, Max = 624, Quest = "SkyQuest", ID = 1, Mob = "Royal Squad" },
    { Min = 625, Max = 649, Quest = "FountainQuest", ID = 1, Mob = "Galley Pirate" },
    { Min = 650, Max = 700, Quest = "FountainQuest", ID = 2, Mob = "Galley Captain" },
}

local function getPlayerLevel()
    local level = 1
    pcall(function()
        if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") then
            level = LocalPlayer.Data.Level.Value
        elseif LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("Level") then
            local txt = LocalPlayer.PlayerGui.Main.Level.Text
            local num = tonumber(string.match(txt, "%d+"))
            if num then level = num end
        end
    end)
    return level
end

local function hasActiveQuest()
    local hasQuest = false
    pcall(function()
        if LocalPlayer.PlayerGui.Main.Quest.Visible == true then
            hasQuest = true
        end
    end)
    return hasQuest
end

local function getQuestDataForLevel(lvl)
    for _, q in ipairs(QuestList) do
        if lvl >= q.Min and lvl <= q.Max then
            return q
        end
    end
    return QuestList[#QuestList]
end

-- Auto Farm Level Execution Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoFarmLevel then
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
                    return
                end

                if character.Humanoid.Health <= 0 then
                    task.wait(2)
                    return
                end

                local myLevel = getPlayerLevel()
                local questInfo = getQuestDataForLevel(myLevel)

                -- Take active quest
                if not hasActiveQuest() then
                    local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                    if not commF and ReplicatedStorage:FindFirstChild("CommF_") then
                        commF = ReplicatedStorage.CommF_
                    end
                    if commF then
                        commF:InvokeServer("StartQuest", questInfo.Quest, questInfo.ID)
                        task.wait(0.3)
                    end
                end

                -- Target Mob search
                local targetMob = nil
                local enemiesFolder = Workspace:FindFirstChild("Enemies")

                if enemiesFolder then
                    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                            if enemy.Humanoid.Health > 0 then
                                if string.find(string.lower(enemy.Name), string.lower(questInfo.Mob)) then
                                    targetMob = enemy
                                    break
                                elseif not targetMob then
                                    targetMob = enemy
                                end
                            end
                        end
                    end
                end

                if not targetMob then
                    for _, enemy in ipairs(Workspace:GetChildren()) do
                        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy ~= character then
                            if enemy.Humanoid.Health > 0 and string.find(string.lower(enemy.Name), string.lower(questInfo.Mob)) then
                                targetMob = enemy
                                break
                            end
                        end
                    end
                end

                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    equipCombatTool()

                    -- Safe combat position: 10 studs above enemy facing down
                    local mobCFrame = targetMob.HumanoidRootPart.CFrame
                    local safeAttackCFrame = mobCFrame * CFrame.new(0, 10, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    setFarmPosition(safeAttackCFrame)

                    -- Trigger attack
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(500, 500), Workspace.CurrentCamera.CFrame)
                else
                    removeFarmVelocity()
                end
            end)
        else
            removeFarmVelocity()
        end
    end
end)

-- Chest ESP Holder & Loop
local chestESPFolder = Instance.new("Folder")
chestESPFolder.Name = "ChestESP_Holder"
chestESPFolder.Parent = ScreenGui

task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            chestESPFolder:ClearAllChildren()
            if _G.ChestESPActive then
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local nameLower = string.lower(obj.Name)
                        if string.find(nameLower, "chest") then
                            local part = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or obj
                            if part and part:IsA("BasePart") and part.Transparency < 1 then
                                local dist = rootPart and math.floor((rootPart.Position - part.Position).Magnitude) or 0

                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "ChestESP"
                                billboard.AlwaysOnTop = true
                                billboard.Size = UDim2.new(0, 100, 0, 30)
                                billboard.StudsOffset = Vector3.new(0, 2, 0)
                                billboard.Adornee = part
                                billboard.Parent = chestESPFolder

                                local label = Instance.new("TextLabel")
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1
                                label.Text = "💎 Chest [" .. tostring(dist) .. "m]"
                                label.TextColor3 = Color3.fromRGB(255, 215, 0)
                                label.Font = Enum.Font.GothamBold
                                label.TextSize = 12
                                label.TextStrokeTransparency = 0.3
                                label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                label.Parent = billboard
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Fruit ESP Holder & Loop
local fruitESPFolder = Instance.new("Folder")
fruitESPFolder.Name = "FruitESP_Holder"
fruitESPFolder.Parent = ScreenGui

task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            fruitESPFolder:ClearAllChildren()
            if _G.FruitESPActive then
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")

                for _, obj in ipairs(Workspace:GetChildren()) do
                    if (obj:IsA("Tool") or obj:IsA("Model")) and string.find(string.lower(obj.Name), "fruit") then
                        local part = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local dist = rootPart and math.floor((rootPart.Position - part.Position).Magnitude) or 0

                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "FruitESP"
                            billboard.AlwaysOnTop = true
                            billboard.Size = UDim2.new(0, 140, 0, 30)
                            billboard.StudsOffset = Vector3.new(0, 2, 0)
                            billboard.Adornee = part
                            billboard.Parent = fruitESPFolder

                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.Text = "🍎 " .. obj.Name .. " [" .. tostring(dist) .. "m]"
                            label.TextColor3 = Color3.fromRGB(255, 85, 255)
                            label.Font = Enum.Font.GothamBold
                            label.TextSize = 12
                            label.TextStrokeTransparency = 0.2
                            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            label.Parent = billboard
                        end
                    end
                end
            end
        end)
    end
end)

print("[ULTRA SCRIPT HUB] Blox Fruits Script Loaded Successfully!")
