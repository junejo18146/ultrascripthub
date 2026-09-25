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
local Toggles = {
    AutoChests = false,
    AutoRandomFruit = false,
    AutoStoreFruit = false,
    TeleportToFruits = false,
    AutoBusoHaki = false,
    AutoKenHaki = false,
    FastAttack = false,
    PlayerESP = false,
    ChestESP = false,
    FruitESP = false,
    FlowerESP = false,
    MirageESP = false,
    AutoStatsMeleeDef = false,
    AutoStatsSwordFruit = false,
    AutoBuyRaidChip = false,
    AutoNextRaidIsland = false,
    AutoAwakenFruit = false,
    AutoSeaBeastHunter = false,
    InfiniteEnergy = false,
    FlyMode = false,
    Noclip = false,
    InfiniteJump = false,
    WalkSpeed = false
}

_G.WalkSpeedValue = 50
_G.FlySpeedValue = 60

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

-- Content Scrollable Container
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -16, 0, 184)
Content.Position = UDim2.new(0, 8, 0, 42)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
Content.CanvasSize = UDim2.new(0, 0, 0, 1050)
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.Parent = Content

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingLeft = UDim.new(0, 6)
ContentPadding.PaddingRight = UDim.new(0, 6)
ContentPadding.PaddingTop = UDim.new(0, 2)
ContentPadding.PaddingBottom = UDim.new(0, 8)
ContentPadding.Parent = Content

-- Auto Canvas Resizer
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 16)
end)

-- =================================================================
-- UI BUILDER FUNCTIONS (UI 1 BORDERLESS ROW WITH CHECKBOX & STEPPER)
-- =================================================================

-- Section Title Header
local function CreateSectionHeader(text, layoutOrder)
    local header = Instance.new("TextLabel")
    header.Name = "Header_" .. text
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundTransparency = 1
    header.Text = string.upper(text)
    header.TextColor3 = Color3.fromRGB(150, 150, 170)
    header.TextSize = 11
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = layoutOrder
    header.Parent = Content
    return header
end

-- Action Button Row (Full-width dark rounded action button)
local function CreateActionButton(name, layoutOrder, onClick)
    local btn = Instance.new("TextButton")
    btn.Name = "Btn_" .. name
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(240, 240, 245)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = true
    btn.LayoutOrder = layoutOrder
    btn.Parent = Content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 55)
    stroke.Thickness = 1
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if onClick then
            task.spawn(onClick)
        end
    end)
    return btn
end

-- Standard Feature Row (Left label, right rounded square checkbox)
local function CreateFeatureRow(name, toggleKey, layoutOrder, onToggle)
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
    label.TextSize = 12
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
    check.Visible = Toggles[toggleKey] or false
    check.Parent = box

    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 3)
    checkCorner.Parent = check

    local function toggleState()
        Toggles[toggleKey] = not Toggles[toggleKey]
        check.Visible = Toggles[toggleKey]
        if onToggle then
            task.spawn(onToggle, Toggles[toggleKey])
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
    local row = Instance.new("Frame")
    row.Name = "WalkSpeedRow"
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder
    row.Parent = Content

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 75, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "WalkSpeed"
    label.TextColor3 = Color3.fromRGB(240, 240, 245)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    -- Checkbox
    local box = Instance.new("TextButton")
    box.Name = "Box"
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(0, 80, 0.5, -10)
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
    check.Visible = Toggles.WalkSpeed
    check.Parent = box

    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 3)
    checkCorner.Parent = check

    box.MouseButton1Click:Connect(function()
        Toggles.WalkSpeed = not Toggles.WalkSpeed
        check.Visible = Toggles.WalkSpeed
        if not Toggles.WalkSpeed then
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
    valLabel.Text = tostring(_G.WalkSpeedValue)
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
        _G.WalkSpeedValue = math.max(16, _G.WalkSpeedValue - 5)
        valLabel.Text = tostring(_G.WalkSpeedValue)
    end)

    plus.MouseButton1Click:Connect(function()
        _G.WalkSpeedValue = math.min(250, _G.WalkSpeedValue + 5)
        valLabel.Text = tostring(_G.WalkSpeedValue)
    end)
end

-- =================================================================
-- BLOX FRUITS CORE REMOTES & NETWORK INTERACTION ENGINE
-- =================================================================

local function GetCommF()
    local rem = ReplicatedStorage:FindFirstChild("Remotes")
    if rem and rem:FindFirstChild("CommF_") then
        return rem.CommF_
    end
    if ReplicatedStorage:FindFirstChild("CommF_") then
        return ReplicatedStorage.CommF_
    end
    return nil
end

local function GetCommE()
    local rem = ReplicatedStorage:FindFirstChild("Remotes")
    if rem and rem:FindFirstChild("CommE") then
        return rem.CommE
    end
    if ReplicatedStorage:FindFirstChild("CommE") then
        return ReplicatedStorage.CommE
    end
    return nil
end

-- Safe Root Part & CFrame Teleport
local function GetRootPart()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart", 5)
end

local function TeleportTo(targetCFrame)
    pcall(function()
        local root = GetRootPart()
        if root then
            root.CFrame = targetCFrame
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

-- =================================================================
-- REGISTER ALL REQUESTED FEATURES & CONTROLS IN UI
-- =================================================================

local order = 0
local function nextOrder()
    order = order + 1
    return order
end

-- 1. DEVIL FRUIT SECTION
CreateSectionHeader("🍎 Devil Fruit Utilities", nextOrder())
CreateFeatureRow("Auto Random Fruit (Gacha)", "AutoRandomFruit", nextOrder())
CreateFeatureRow("Auto Store Fruits", "AutoStoreFruit", nextOrder())
CreateFeatureRow("Teleport To Fruits", "TeleportToFruits", nextOrder())

-- 2. COMBAT & FARM SECTION
CreateSectionHeader("⚔️ Combat & Farming", nextOrder())
CreateFeatureRow("Auto Collect Chests", "AutoChests", nextOrder())
CreateFeatureRow("Fast Attack", "FastAttack", nextOrder())
CreateFeatureRow("Auto Buso Haki", "AutoBusoHaki", nextOrder())
CreateFeatureRow("Auto Ken Haki", "AutoKenHaki", nextOrder())
CreateFeatureRow("Auto Sea Beast Hunter", "AutoSeaBeastHunter", nextOrder())

-- 3. RAIDS & AWAKENING SECTION
CreateSectionHeader("🔮 Raids & Awakening", nextOrder())
CreateFeatureRow("Auto Buy Raid Chip", "AutoBuyRaidChip", nextOrder())
CreateFeatureRow("Auto Next Raid Island", "AutoNextRaidIsland", nextOrder())
CreateFeatureRow("Auto Awaken Fruit", "AutoAwakenFruit", nextOrder())

-- 4. VISUALS & ESP SECTION
CreateSectionHeader("👁️ Visuals & ESP", nextOrder())
CreateFeatureRow("Player ESP", "PlayerESP", nextOrder())
CreateFeatureRow("Chest ESP", "ChestESP", nextOrder())
CreateFeatureRow("Fruit ESP", "FruitESP", nextOrder())
CreateFeatureRow("Flower ESP (Race V2)", "FlowerESP", nextOrder())
CreateFeatureRow("Mirage Island ESP", "MirageESP", nextOrder())

-- 5. STATS & PROGRESSION SECTION
CreateSectionHeader("📊 Stats & Progression", nextOrder())
CreateFeatureRow("Auto Stats (Melee + Defense)", "AutoStatsMeleeDef", nextOrder())
CreateFeatureRow("Auto Stats (Sword + Fruit)", "AutoStatsSwordFruit", nextOrder())
CreateActionButton("🎁 Redeem All Promo Codes", nextOrder(), function()
    local commF = GetCommF()
    if commF then
        local codes = {
            "NOOB2PRO", "KITT_RESET", "Sub2Fer999", "Enyu_is_Pro", "Magicbus",
            "JCWK", "Starcodeheo", "Bluxxy", "fudd10_v2", "SUB2GAMERROBOT_EXP1",
            "Sub2OfficialNoobie", "TheGreatAce", "Axiore", "Sub2Daigrock",
            "TantaiGaming", "StrawHatMaine", "Sub2UncleKizaru", "Bignews", "FUDD10"
        }
        for _, code in ipairs(codes) do
            pcall(function()
                commF:InvokeServer("RedeemCode", code)
            end)
            task.wait(0.1)
        end
    end
end)

-- 6. MOVEMENT & PLAYER UTILITY SECTION
CreateSectionHeader("🏃 Movement & Utilities", nextOrder())
CreateSpeedRow(nextOrder())
CreateFeatureRow("Fly Mode", "FlyMode", nextOrder())
CreateFeatureRow("Infinite Jump", "InfiniteJump", nextOrder())
CreateFeatureRow("Infinite Energy", "InfiniteEnergy", nextOrder())
CreateFeatureRow("Noclip", "Noclip", nextOrder())

-- 7. TELEPORTS SECTION
CreateSectionHeader("🌀 World & Island Teleports", nextOrder())
CreateActionButton("🛡️ Teleport to Safe Zone", nextOrder(), function()
    pcall(function()
        local root = GetRootPart()
        if root then
            -- Create floating platform high above
            local safePos = root.Position + Vector3.new(0, 150, 0)
            local platform = Workspace:FindFirstChild("JunejoSafeZonePart")
            if not platform then
                platform = Instance.new("Part")
                platform.Name = "JunejoSafeZonePart"
                platform.Size = Vector3.new(30, 2, 30)
                platform.Anchored = true
                platform.Color = Color3.fromRGB(20, 20, 25)
                platform.Parent = Workspace
            end
            platform.CFrame = CFrame.new(safePos - Vector3.new(0, 3, 0))
            root.CFrame = CFrame.new(safePos)
        end
    end)
end)

local IslandLocations = {
    {"Jungle Island", CFrame.new(-1612, 37, 149)},
    {"Pirate Village", CFrame.new(-1181, 40, 3850)},
    {"Desert Island", CFrame.new(894, 7, 4390)},
    {"Marine Fortress", CFrame.new(-5036, 21, 4290)},
    {"Skylands Island", CFrame.new(-4839, 718, -2619)},
    {"Prison", CFrame.new(4875, 6, 735)},
    {"Colosseum", CFrame.new(-1427, 8, -2982)},
    {"Magma Village", CFrame.new(-5247, 9, 8504)},
    {"Underwater City", CFrame.new(61163, 19, 1569)},
    {"Fountain City", CFrame.new(5127, 60, 4105)},
    {"Cafe (Sea 2)", CFrame.new(-380, 73, 298)},
    {"Mansion (Sea 3)", CFrame.new(-12463, 375, -7550)}
}

for _, isl in ipairs(IslandLocations) do
    local islName = isl[1]
    local islCFrame = isl[2]
    CreateActionButton("📍 " .. islName, nextOrder(), function()
        TeleportTo(islCFrame)
    end)
end

-- =================================================================
-- MANDATORY FOOTER (CENTERED BRANDING)
-- =================================================================
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 30)
Footer.Position = UDim2.new(0, 0, 1, -32)
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
CreatorTitle.Size = UDim2.new(1, 0, 0, 13)
CreatorTitle.Position = UDim2.new(0, 0, 0, 14)
CreatorTitle.BackgroundTransparency = 1
CreatorTitle.Text = "Made by Junejo"
CreatorTitle.TextColor3 = Color3.fromRGB(136, 136, 153)
CreatorTitle.TextSize = 10
CreatorTitle.Font = Enum.Font.GothamMedium
CreatorTitle.TextXAlignment = Enum.TextXAlignment.Center
CreatorTitle.Parent = Footer

-- =================================================================
-- GAMEPLAY ENGINE & FEATURE IMPLEMENTATIONS
-- =================================================================

-- 1. Auto Collect Chests (Iterates map chests, teleports & collects Beli/Frags)
task.spawn(function()
    while true do
        task.wait(0.25)
        if Toggles.AutoChests then
            pcall(function()
                local root = GetRootPart()
                if not root then return end

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoChests then break end
                    if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "chest") and obj.Transparency < 1 then
                        local startTime = tick()
                        while Toggles.AutoChests and obj and obj.Parent and (tick() - startTime < 1.2) do
                            root.CFrame = obj.CFrame + Vector3.new(0, 1.5, 0)
                            root.AssemblyLinearVelocity = Vector3.zero
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. Auto Random Fruit (Gacha Zioles roll)
task.spawn(function()
    while true do
        task.wait(10)
        if Toggles.AutoRandomFruit then
            pcall(function()
                local commF = GetCommF()
                if commF then
                    commF:InvokeServer("Cousin", "Buy")
                end
            end)
        end
    end
end)

-- 3. Auto Store Fruit (Safely stores any inventory or held fruits)
task.spawn(function()
    while true do
        task.wait(3)
        if Toggles.AutoStoreFruit then
            pcall(function()
                local commF = GetCommF()
                if not commF then return end
                
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local char = LocalPlayer.Character
                
                local function checkFruit(tool)
                    if tool and tool:IsA("Tool") and string.find(string.lower(tool.Name), "fruit") then
                        commF:InvokeServer("StoreFruit", tool.Name, tool)
                    end
                end

                if backpack then
                    for _, item in ipairs(backpack:GetChildren()) do checkFruit(item) end
                end
                if char then
                    for _, item in ipairs(char:GetChildren()) do checkFruit(item) end
                end
            end)
        end
    end
end)

-- 4. Teleport To Fruits (Finds spawned fruits on map and warps player to them)
task.spawn(function()
    while true do
        task.wait(2)
        if Toggles.TeleportToFruits then
            pcall(function()
                local root = GetRootPart()
                if not root then return end

                for _, obj in ipairs(Workspace:GetChildren()) do
                    if not Toggles.TeleportToFruits then break end
                    if (obj:IsA("Tool") or obj:IsA("Model")) and string.find(string.lower(obj.Name), "fruit") then
                        local part = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                        if part then
                            root.CFrame = part.CFrame + Vector3.new(0, 2, 0)
                            root.AssemblyLinearVelocity = Vector3.zero
                            task.wait(0.5)
                        end
                    end
                end
            end)
        end
    end
end)

-- 5. Auto Buso Haki (Maintains Armament Haki)
task.spawn(function()
    while true do
        task.wait(2)
        if Toggles.AutoBusoHaki then
            pcall(function()
                local char = LocalPlayer.Character
                if char and not char:FindFirstChild("HasBuso") then
                    local commF = GetCommF()
                    if commF then
                        commF:InvokeServer("Buso")
                    end
                end
            end)
        end
    end
end)

-- 6. Auto Ken Haki (Observation Haki / Instinct)
task.spawn(function()
    while true do
        task.wait(3)
        if Toggles.AutoKenHaki then
            pcall(function()
                local commE = GetCommE()
                if commE then
                    commE:FireServer("Ken", true)
                else
                    local commF = GetCommF()
                    if commF then
                        commF:InvokeServer("KenTalk", "Buy")
                    end
                end
            end)
        end
    end
end)

-- 7. Fast Attack Engine (Rapid attack burst with active weapon)
task.spawn(function()
    while true do
        task.wait(0.06)
        if Toggles.FastAttack then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(500, 500), Workspace.CurrentCamera.CFrame)
                end
            end)
        end
    end
end)

-- 8. Auto Stats Allocation (Melee, Defense, Sword, Demon Fruit)
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.AutoStatsMeleeDef or Toggles.AutoStatsSwordFruit then
            pcall(function()
                local commF = GetCommF()
                if not commF then return end
                
                local points = 3
                if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Points") then
                    points = math.min(LocalPlayer.Data.Points.Value, 50)
                end
                
                if points > 0 then
                    if Toggles.AutoStatsMeleeDef then
                        commF:InvokeServer("AddPoint", "Melee", math.ceil(points / 2))
                        commF:InvokeServer("AddPoint", "Defense", math.floor(points / 2))
                    elseif Toggles.AutoStatsSwordFruit then
                        commF:InvokeServer("AddPoint", "Sword", math.ceil(points / 2))
                        commF:InvokeServer("AddPoint", "Demon Fruit", math.floor(points / 2))
                    end
                end
            end)
        end
    end
end)

-- 9. Auto Buy Raid Chip & Next Raid Island & Awaken Fruit
task.spawn(function()
    while true do
        task.wait(2)
        local commF = GetCommF()
        if not commF then continue end

        if Toggles.AutoBuyRaidChip then
            pcall(function()
                commF:InvokeServer("RaidsNpc", "Select", "Flame")
            end)
        end

        if Toggles.AutoAwakenFruit then
            pcall(function()
                commF:InvokeServer("AwakenAbility", "Z")
            end)
        end

        if Toggles.AutoNextRaidIsland then
            pcall(function()
                local map = Workspace:FindFirstChild("Map")
                local raidIsland = map and map:FindFirstChild("RaidIsland")
                if raidIsland then
                    local gate = raidIsland:FindFirstChild("Gate") or raidIsland:FindFirstChildWhichIsA("BasePart")
                    if gate then
                        TeleportTo(gate.CFrame + Vector3.new(0, 5, 0))
                    end
                end
            end)
        end
    end
end)

-- 10. Auto Sea Beast Hunter (Sea 2 / Sea 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoSeaBeastHunter then
            pcall(function()
                local char = LocalPlayer.Character
                local root = GetRootPart()
                if not char or not root then return end

                local targetSB = nil
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj:IsA("Model") and (string.find(string.lower(obj.Name), "sea beast") or string.find(string.lower(obj.Name), "terror shark")) then
                        if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") then
                            targetSB = obj
                            break
                        end
                    end
                end

                if targetSB then
                    -- Hover 35 studs safely above Sea Beast
                    local sbRoot = targetSB.HumanoidRootPart
                    root.CFrame = sbRoot.CFrame * CFrame.new(0, 35, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    root.AssemblyLinearVelocity = Vector3.zero

                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(500, 500), Workspace.CurrentCamera.CFrame)
                end
            end)
        end
    end
end)

-- 11. Infinite Energy
RunService.Heartbeat:Connect(function()
    if Toggles.InfiniteEnergy then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Energy") and char.Energy:IsA("NumberValue") then
                char.Energy.Value = 999999
            end
        end)
    end
end)

-- 12. Noclip
RunService.Stepped:Connect(function()
    if Toggles.Noclip then
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

-- 13. WalkSpeed Bypass Engine
RunService.RenderStepped:Connect(function(deltaTime)
    pcall(function()
        if Toggles.WalkSpeed and _G.WalkSpeedValue and _G.WalkSpeedValue > 16 then
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

-- 14. Infinite Jump (Mobile & PC)
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- 15. Smooth Fly Mode (WASD & Camera Flight)
local flyBodyVel, flyBodyGyro
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            if Toggles.FlyMode then
                if not flyBodyVel then
                    flyBodyVel = Instance.new("BodyVelocity")
                    flyBodyVel.Name = "JunejoFlyVelocity"
                    flyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    flyBodyVel.Velocity = Vector3.zero
                    flyBodyVel.Parent = root
                end

                if not flyBodyGyro then
                    flyBodyGyro = Instance.new("BodyGyro")
                    flyBodyGyro.Name = "JunejoFlyGyro"
                    flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                    flyBodyGyro.P = 10000
                    flyBodyGyro.CFrame = root.CFrame
                    flyBodyGyro.Parent = root
                end

                local cam = Workspace.CurrentCamera
                local hum = char:FindFirstChildOfClass("Humanoid")
                local moveDir = hum and hum.MoveDirection or Vector3.zero
                flyBodyGyro.CFrame = cam.CFrame

                if moveDir.Magnitude > 0 then
                    flyBodyVel.Velocity = cam.CFrame:VectorToWorldSpace(Vector3.new(moveDir.X, 0, -moveDir.Z)) * _G.FlySpeedValue
                else
                    flyBodyVel.Velocity = Vector3.zero
                end
            else
                if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
                if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
            end
        end)
    end
end)

-- =================================================================
-- ESP ENGINES (CHEST, FRUIT, PLAYER, FLOWER, MIRAGE)
-- =================================================================

local espMasterFolder = Instance.new("Folder")
espMasterFolder.Name = "Junejo_BloxFruits_ESP"
espMasterFolder.Parent = ScreenGui

task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            espMasterFolder:ClearAllChildren()
            local root = GetRootPart()

            -- A. CHEST ESP
            if Toggles.ChestESP then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "chest") and obj.Transparency < 1 then
                        local dist = root and math.floor((root.Position - obj.Position).Magnitude) or 0
                        local bill = Instance.new("BillboardGui")
                        bill.AlwaysOnTop = true
                        bill.Size = UDim2.new(0, 100, 0, 24)
                        bill.StudsOffset = Vector3.new(0, 2, 0)
                        bill.Adornee = obj
                        bill.Parent = espMasterFolder

                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = "💎 Chest [" .. tostring(dist) .. "m]"
                        lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 11
                        lbl.TextStrokeTransparency = 0.3
                        lbl.Parent = bill
                    end
                end
            end

            -- B. FRUIT ESP
            if Toggles.FruitESP then
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if (obj:IsA("Tool") or obj:IsA("Model")) and string.find(string.lower(obj.Name), "fruit") then
                        local part = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local dist = root and math.floor((root.Position - part.Position).Magnitude) or 0
                            local bill = Instance.new("BillboardGui")
                            bill.AlwaysOnTop = true
                            bill.Size = UDim2.new(0, 140, 0, 26)
                            bill.StudsOffset = Vector3.new(0, 2.5, 0)
                            bill.Adornee = part
                            bill.Parent = espMasterFolder

                            local lbl = Instance.new("TextLabel")
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.Text = "🍎 " .. obj.Name .. " [" .. tostring(dist) .. "m]"
                            lbl.TextColor3 = Color3.fromRGB(255, 85, 255)
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 12
                            lbl.TextStrokeTransparency = 0.2
                            lbl.Parent = bill
                        end
                    end
                end
            end

            -- C. PLAYER ESP
            if Toggles.PlayerESP then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local char = plr.Character
                        local hrp = char.HumanoidRootPart
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        local dist = root and math.floor((root.Position - hrp.Position).Magnitude) or 0
                        local hp = hum and math.floor(hum.Health) or 0

                        local bill = Instance.new("BillboardGui")
                        bill.AlwaysOnTop = true
                        bill.Size = UDim2.new(0, 130, 0, 26)
                        bill.StudsOffset = Vector3.new(0, 3, 0)
                        bill.Adornee = hrp
                        bill.Parent = espMasterFolder

                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = plr.DisplayName .. " [" .. tostring(hp) .. " HP] (" .. tostring(dist) .. "m)"
                        lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 11
                        lbl.TextStrokeTransparency = 0.3
                        lbl.Parent = bill
                    end
                end
            end

            -- D. FLOWER ESP (Race V2 Red/Blue/Yellow Flowers)
            if Toggles.FlowerESP then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "flower") then
                        local dist = root and math.floor((root.Position - obj.Position).Magnitude) or 0
                        local bill = Instance.new("BillboardGui")
                        bill.AlwaysOnTop = true
                        bill.Size = UDim2.new(0, 110, 0, 24)
                        bill.StudsOffset = Vector3.new(0, 2, 0)
                        bill.Adornee = obj
                        bill.Parent = espMasterFolder

                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = "🌸 " .. obj.Name .. " [" .. tostring(dist) .. "m]"
                        lbl.TextColor3 = Color3.fromRGB(80, 255, 120)
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 11
                        lbl.TextStrokeTransparency = 0.3
                        lbl.Parent = bill
                    end
                end
            end

            -- E. MIRAGE ISLAND ESP
            if Toggles.MirageESP then
                local map = Workspace:FindFirstChild("Map") or Workspace
                for _, obj in ipairs(map:GetChildren()) do
                    if string.find(string.lower(obj.Name), "mirage") then
                        local part = obj:FindFirstChildWhichIsA("BasePart") or obj:FindFirstChild("Hitbox")
                        if part then
                            local dist = root and math.floor((root.Position - part.Position).Magnitude) or 0
                            local bill = Instance.new("BillboardGui")
                            bill.AlwaysOnTop = true
                            bill.Size = UDim2.new(0, 150, 0, 28)
                            bill.StudsOffset = Vector3.new(0, 10, 0)
                            bill.Adornee = part
                            bill.Parent = espMasterFolder

                            local lbl = Instance.new("TextLabel")
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.Text = "🌕 MIRAGE ISLAND [" .. tostring(dist) .. "m]"
                            lbl.TextColor3 = Color3.fromRGB(0, 255, 255)
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 13
                            lbl.TextStrokeTransparency = 0.2
                            lbl.Parent = bill
                        end
                    end
                end
            end
        end)
    end
end)

print("[ULTRA SCRIPT HUB] Blox Fruits Comprehensive Production Script Loaded Successfully!")
