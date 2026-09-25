--[[
    ========================================================================
    ULTRA SCRIPT HUB - OFFICIAL PRODUCTION SCRIPT
    ========================================================================
    Game: Blox Fruits ⚔️
    Game Link: https://www.roblox.com/games/2753915549/Blox-Fruits
    Creator: Made by Junejo (junejo18146)
    UI Style: UI 1 (Official Ultra Script Hub Classic Matte Dark - 280px)
    GitHub: https://github.com/junejo18146/ultrascripthub
    Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/junejo18146/ultrascripthub/main/blox_fruits.lua"))()
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
    local target = nil
    pcall(function()
        if gethui then
            target = gethui()
        elseif CoreGui and pcall(function() return CoreGui.Name end) then
            local test = Instance.new("Folder")
            test.Parent = CoreGui
            test:Destroy()
            target = CoreGui
        end
    end)
    if not target then
        target = LocalPlayer:WaitForChild("PlayerGui")
    end
    return target
end

local GuiParent = GetSafeGuiParent()

-- Cleanup Existing Instances
pcall(function()
    for _, name in ipairs({"UltraScriptHub_BloxFruits", "JunejoHubUI_BloxFruits", "SakiScriptsBloxFruitsUI"}) do
        if GuiParent:FindFirstChild(name) then GuiParent[name]:Destroy() end
        if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end
end)

-- Global State Table
local State = {
    AutoFarmLevel = false,
    AutoAttackPlayers = false,
    AutoChests = false,
    AutoRandomFruit = false,
    TeleportToFruits = false,
    AutoBusoHaki = false,
    AutoKenHaki = false,
    PlayerESP = false,
    ChestESP = false,
    FruitESP = false,
    FlowerESP = false,
    WalkSpeed = false,
    WalkSpeedValue = 50,
    FlyMode = false,
    FlySpeed = 60,
    InfiniteJump = false,
    InfiniteEnergy = false,
    Noclip = false
}

-- 24/7 Anti-AFK Idle Kick Protection
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- =================================================================
-- REMOTE RESOLUTION ENGINE (AUTO-DISCOVERY & BULLETPROOF FALLBACK)
-- =================================================================

local function GetCommF()
    local rem = ReplicatedStorage:FindFirstChild("Remotes")
    if rem and rem:FindFirstChild("CommF_") then
        return rem.CommF_
    end
    if ReplicatedStorage:FindFirstChild("CommF_") then
        return ReplicatedStorage.CommF_
    end
    for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
        if desc.Name == "CommF_" and desc:IsA("RemoteFunction") then
            return desc
        end
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
    for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
        if desc.Name == "CommE" and desc:IsA("RemoteEvent") then
            return desc
        end
    end
    return nil
end

-- Auto-Select Pirates Team if on Selection Screen
task.spawn(function()
    pcall(function()
        task.wait(1)
        if not LocalPlayer.Team then
            local commF = GetCommF()
            if commF then
                commF:InvokeServer("SetTeam", "Pirates")
            end
        end
    end)
end)

-- Safe Teleport with Anti-Fall Floating Platform
local function TeleportSafe(targetCFrame)
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local plat = Instance.new("Part")
        plat.Name = "JunejoSafePlat"
        plat.Size = Vector3.new(20, 1, 20)
        plat.Anchored = true
        plat.CanCollide = true
        plat.Transparency = 1
        plat.CFrame = targetCFrame - Vector3.new(0, 2.5, 0)
        plat.Parent = Workspace

        root.CFrame = targetCFrame + Vector3.new(0, 2, 0)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        task.delay(4, function()
            if plat and plat.Parent then plat:Destroy() end
        end)
    end)
end

-- =================================================================
-- UI 1 MASTER CONTAINER (280px Width Classic Matte Dark)
-- =================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraScriptHub_BloxFruits"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

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

-- Bulletproof Click & Tap Event Binder
local function BindClick(button, callback)
    local lastClick = 0
    local function trigger()
        local now = os.clock()
        if now - lastClick < 0.25 then return end
        lastClick = now
        pcall(callback)
    end
    button.Activated:Connect(trigger)
    button.MouseButton1Click:Connect(trigger)
end

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

BindClick(CloseButton, function()
    MainFrame.Visible = false
    FloatingToggle.Visible = true
end)

BindClick(FloatingToggle, function()
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
Content.Size = UDim2.new(1, -16, 0, 186)
Content.Position = UDim2.new(0, 8, 0, 40)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.Parent = Content

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingLeft = UDim.new(0, 6)
ContentPadding.PaddingRight = UDim.new(0, 6)
ContentPadding.PaddingTop = UDim.new(0, 4)
ContentPadding.PaddingBottom = UDim.new(0, 12)
ContentPadding.Parent = Content

-- Dynamic CanvasSize Update
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 24)
end)

-- =================================================================
-- UI BUILDER FUNCTIONS
-- =================================================================

local function CreateSectionHeader(text, layoutOrder)
    local header = Instance.new("TextLabel")
    header.Name = "Header_" .. text
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundTransparency = 1
    header.Text = string.upper(text)
    header.TextColor3 = Color3.fromRGB(150, 150, 170)
    header.TextSize = 10
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = layoutOrder
    header.Parent = Content
    return header
end

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

    BindClick(btn, function()
        if onClick then task.spawn(onClick) end
    end)
    return btn
end

local function CreateFeatureRow(name, defaultVal, layoutOrder, callback)
    local state = defaultVal or false

    local row = Instance.new("Frame")
    row.Name = name .. "_Row"
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder
    row.Parent = Content

    local rowBtn = Instance.new("TextButton")
    rowBtn.Name = "RowBtn"
    rowBtn.Size = UDim2.new(1, 0, 1, 0)
    rowBtn.BackgroundTransparency = 1
    rowBtn.Text = ""
    rowBtn.AutoButtonColor = false
    rowBtn.Parent = row

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -30, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(240, 240, 245)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = rowBtn

    local box = Instance.new("Frame")
    box.Name = "Box"
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(1, -20, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    box.BorderSizePixel = 0
    box.Parent = rowBtn

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

    BindClick(rowBtn, function()
        state = not state
        check.Visible = state
        if callback then task.spawn(callback, state) end
    end)

    return row
end

local function CreateSpeedRow(name, defaultSpeed, layoutOrder, toggleCallback, valueCallback)
    local active = false
    local currentSpeed = defaultSpeed or 50

    local row = Instance.new("Frame")
    row.Name = name .. "_Row"
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder
    row.Parent = Content

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 75, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(240, 240, 245)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    -- Checkbox Button
    local boxBtn = Instance.new("TextButton")
    boxBtn.Name = "BoxBtn"
    boxBtn.Size = UDim2.new(0, 20, 0, 20)
    boxBtn.Position = UDim2.new(0, 80, 0.5, -10)
    boxBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    boxBtn.BorderSizePixel = 0
    boxBtn.Text = ""
    boxBtn.AutoButtonColor = false
    boxBtn.Parent = row

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 5)
    boxCorner.Parent = boxBtn

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(45, 45, 55)
    boxStroke.Thickness = 1
    boxStroke.Parent = boxBtn

    local check = Instance.new("Frame")
    check.Name = "Check"
    check.Size = UDim2.new(0, 12, 0, 12)
    check.Position = UDim2.new(0.5, -6, 0.5, -6)
    check.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    check.BorderSizePixel = 0
    check.Visible = false
    check.Parent = boxBtn

    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 3)
    checkCorner.Parent = check

    BindClick(boxBtn, function()
        active = not active
        check.Visible = active
        if toggleCallback then task.spawn(toggleCallback, active, currentSpeed) end
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
    valLabel.Text = tostring(currentSpeed)
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

    BindClick(minus, function()
        currentSpeed = math.max(16, currentSpeed - 5)
        valLabel.Text = tostring(currentSpeed)
        if valueCallback then task.spawn(valueCallback, currentSpeed) end
        if active and toggleCallback then task.spawn(toggleCallback, true, currentSpeed) end
    end)

    BindClick(plus, function()
        currentSpeed = math.min(250, currentSpeed + 5)
        valLabel.Text = tostring(currentSpeed)
        if valueCallback then task.spawn(valueCallback, currentSpeed) end
        if active and toggleCallback then task.spawn(toggleCallback, true, currentSpeed) end
    end)

    return row
end

-- =================================================================
-- REGISTER ALL FEATURES IN UI
-- =================================================================

local order = 0
local function nextOrder()
    order = order + 1
    return order
end

-- 1. COMBAT & AUTO FARM SECTION
CreateSectionHeader("⚔️ Combat & Farming", nextOrder())

CreateFeatureRow("Auto Farm Level / Enemies", State.AutoFarmLevel, nextOrder(), function(val)
    State.AutoFarmLevel = val
end)

CreateFeatureRow("Auto Attack (Near Players)", State.AutoAttackPlayers, nextOrder(), function(val)
    State.AutoAttackPlayers = val
end)

CreateFeatureRow("Auto Collect Chests", State.AutoChests, nextOrder(), function(val)
    State.AutoChests = val
end)

CreateFeatureRow("Auto Buso Haki", State.AutoBusoHaki, nextOrder(), function(val)
    State.AutoBusoHaki = val
    if val then
        pcall(function()
            local commF = GetCommF()
            if commF then commF:InvokeServer("Buso") end
        end)
    end
end)

CreateFeatureRow("Auto Ken Haki", State.AutoKenHaki, nextOrder(), function(val)
    State.AutoKenHaki = val
    if val then
        pcall(function()
            local commE = GetCommE()
            if commE then commE:FireServer("Ken", true) end
        end)
    end
end)

-- 2. DEVIL FRUIT SECTION
CreateSectionHeader("🍎 Devil Fruit Utilities", nextOrder())

CreateActionButton("🎲 Buy Random Fruit (Zioles)", nextOrder(), function()
    local commF = GetCommF()
    if commF then
        local res = commF:InvokeServer("Cousin", "Buy")
        print("[ULTRA SCRIPT HUB] Random Fruit Gacha Result:", tostring(res))
    end
end)

CreateFeatureRow("Teleport To Fruits", State.TeleportToFruits, nextOrder(), function(val)
    State.TeleportToFruits = val
end)

-- 3. VISUALS & ESP SECTION
CreateSectionHeader("👁️ Visuals & ESP", nextOrder())

CreateFeatureRow("Player ESP", State.PlayerESP, nextOrder(), function(val)
    State.PlayerESP = val
end)

CreateFeatureRow("Chest ESP", State.ChestESP, nextOrder(), function(val)
    State.ChestESP = val
end)

CreateFeatureRow("Fruit ESP", State.FruitESP, nextOrder(), function(val)
    State.FruitESP = val
end)

CreateFeatureRow("Flower ESP (Race V2)", State.FlowerESP, nextOrder(), function(val)
    State.FlowerESP = val
end)

-- 4. MOVEMENT & PLAYER UTILITY SECTION
CreateSectionHeader("🏃 Movement & Utilities", nextOrder())

CreateSpeedRow("WalkSpeed", State.WalkSpeedValue, nextOrder(), function(enabled, speed)
    State.WalkSpeed = enabled
    State.WalkSpeedValue = speed
end, function(speed)
    State.WalkSpeedValue = speed
end)

CreateFeatureRow("Fly Mode", State.FlyMode, nextOrder(), function(val)
    State.FlyMode = val
end)

CreateFeatureRow("Infinite Jump", State.InfiniteJump, nextOrder(), function(val)
    State.InfiniteJump = val
end)

CreateFeatureRow("Infinite Energy", State.InfiniteEnergy, nextOrder(), function(val)
    State.InfiniteEnergy = val
end)

CreateFeatureRow("Noclip", State.Noclip, nextOrder(), function(val)
    State.Noclip = val
end)

-- 5. TELEPORTS SECTION
CreateSectionHeader("🌀 World & Island Teleports", nextOrder())

CreateActionButton("🛡️ Teleport to Safe Zone", nextOrder(), function()
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local safePos = root.Position + Vector3.new(0, 200, 0)
            local p = Workspace:FindFirstChild("JunejoSafeZonePart")
            if not p then
                p = Instance.new("Part")
                p.Name = "JunejoSafeZonePart"
                p.Size = Vector3.new(35, 2, 35)
                p.Anchored = true
                p.Color = Color3.fromRGB(20, 20, 25)
                p.Parent = Workspace
            end
            p.CFrame = CFrame.new(safePos - Vector3.new(0, 3, 0))
            root.CFrame = CFrame.new(safePos)
            root.AssemblyLinearVelocity = Vector3.zero
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
        TeleportSafe(islCFrame)
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
-- HIGH-PERFORMANCE GAME ENGINES & FEATURE IMPLEMENTATIONS
-- =================================================================

-- 1. Helper: Auto-Equip Best Combat Weapon
local function EquipCombatWeapon()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local equippedTool = char:FindFirstChildOfClass("Tool")
        if not equippedTool then
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp then
                for _, t in ipairs(bp:GetChildren()) do
                    if t:IsA("Tool") and (t.ToolTip == "Melee" or t.ToolTip == "Sword" or t.ToolTip == "Blox Fruit" or string.find(string.lower(t.Name), "combat") or string.find(string.lower(t.Name), "blade") or string.find(string.lower(t.Name), "katana") or string.find(string.lower(t.Name), "sword")) then
                        t.Parent = char
                        break
                    end
                end
            end
        end
    end)
end

-- 2. SMART AUTO FARM LEVEL / ENEMIES (ABOVE-MOB LOCK + RAPID STRIKE)
task.spawn(function()
    while true do
        task.wait(0.1)
        if State.AutoFarmLevel then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not root or not hum or hum.Health <= 0 then return end

                EquipCombatWeapon()

                -- Find Nearest Enemy
                local enemiesFolder = Workspace:FindFirstChild("Enemies")
                local targetEnemy = nil
                local shortestDist = 500

                if enemiesFolder then
                    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                        local eHum = enemy:FindFirstChildOfClass("Humanoid")
                        local eRoot = enemy:FindFirstChild("HumanoidRootPart")
                        if eHum and eHum.Health > 0 and eRoot then
                            local d = (root.Position - eRoot.Position).Magnitude
                            if d < shortestDist then
                                shortestDist = d
                                targetEnemy = enemy
                            end
                        end
                    end
                end

                -- Fallback to general workspace mobs if Enemies folder is empty
                if not targetEnemy then
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if obj:IsA("Model") and obj ~= char and not Players:GetPlayerFromCharacter(obj) then
                            local eHum = obj:FindFirstChildOfClass("Humanoid")
                            local eRoot = obj:FindFirstChild("HumanoidRootPart")
                            if eHum and eHum.Health > 0 and eRoot and eHum.MaxHealth > 100 then
                                local d = (root.Position - eRoot.Position).Magnitude
                                if d < shortestDist then
                                    shortestDist = d
                                    targetEnemy = obj
                                end
                            end
                        end
                    end
                end

                if targetEnemy then
                    local eRoot = targetEnemy:FindFirstChild("HumanoidRootPart")
                    local eHum = targetEnemy:FindFirstChildOfClass("Humanoid")
                    if eRoot and eHum and eHum.Health > 0 then
                        -- Safe Hover 8.5 studs above enemy (Immune to enemy melee)
                        root.CFrame = eRoot.CFrame * CFrame.new(0, 8.5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        root.AssemblyLinearVelocity = Vector3.zero

                        -- Disable enemy collision
                        pcall(function() eRoot.CanCollide = false end)

                        -- Attack
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(500, 500))
                    end
                end
            end)
        end
    end
end)

-- 3. AUTO ATTACK NEARBY PLAYERS (PROXIMITY ATTACK ENGINE)
task.spawn(function()
    while true do
        task.wait(0.08)
        if State.AutoAttackPlayers then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not root or not hum or hum.Health <= 0 then return end

                local nearestPlrChar = nil
                local shortestDist = 32

                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local pChar = plr.Character
                        local pHum = pChar:FindFirstChildOfClass("Humanoid")
                        local pRoot = pChar:FindFirstChild("HumanoidRootPart")
                        if pHum and pHum.Health > 0 and pRoot then
                            local d = (root.Position - pRoot.Position).Magnitude
                            if d < shortestDist then
                                shortestDist = d
                                nearestPlrChar = pChar
                            end
                        end
                    end
                end

                if nearestPlrChar then
                    local pRoot = nearestPlrChar:FindFirstChild("HumanoidRootPart")
                    if pRoot then
                        -- Smoothly turn/aim towards the approaching player
                        root.CFrame = CFrame.new(root.Position, Vector3.new(pRoot.Position.X, root.Position.Y, pRoot.Position.Z))

                        -- Auto-equip best weapon and attack
                        EquipCombatWeapon()
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(500, 500))
                    end
                end
            end)
        end
    end
end)

-- 4. AUTO COLLECT ALL MAP CHESTS
task.spawn(function()
    while true do
        task.wait(0.4)
        if State.AutoChests then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not State.AutoChests then break end
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local lowerName = string.lower(obj.Name)
                        if string.find(lowerName, "chest") then
                            local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart))
                            if part and part.Transparency < 1 then
                                root.CFrame = part.CFrame + Vector3.new(0, 1.2, 0)
                                root.AssemblyLinearVelocity = Vector3.zero
                                pcall(function()
                                    if firetouchinterest then
                                        firetouchinterest(root, part, 0)
                                        firetouchinterest(root, part, 1)
                                    end
                                end)
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 5. TELEPORT TO LIVE SPAWNED FRUITS
task.spawn(function()
    while true do
        task.wait(2)
        if State.TeleportToFruits then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not State.TeleportToFruits then break end
                    if (obj:IsA("Tool") or obj:IsA("Model")) and string.find(string.lower(obj.Name), "fruit") then
                        local part = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                        if part and not obj:IsDescendantOf(LocalPlayer.Character) and not obj:IsDescendantOf(LocalPlayer:FindFirstChild("Backpack")) then
                            root.CFrame = part.CFrame + Vector3.new(0, 1.5, 0)
                            root.AssemblyLinearVelocity = Vector3.zero
                            task.wait(0.8)
                        end
                    end
                end
            end)
        end
    end
end)

-- 6. AUTO BUSO & KEN HAKI RESPAWN WATCHER
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.5)
    pcall(function()
        if State.AutoBusoHaki then
            local commF = GetCommF()
            if commF then commF:InvokeServer("Buso") end
        end
        if State.AutoKenHaki then
            local commE = GetCommE()
            if commE then commE:FireServer("Ken", true) end
        end
    end)
end)

-- 7. WALKSPEED ENGINE (HUMANOID SYNC + VELOCITY ASSISTANCE)
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            if State.WalkSpeed and State.WalkSpeedValue and State.WalkSpeedValue > 16 then
                hum.WalkSpeed = State.WalkSpeedValue
                if hum.MoveDirection.Magnitude > 0 then
                    local speed = State.WalkSpeedValue
                    hrp.AssemblyLinearVelocity = Vector3.new(
                        hum.MoveDirection.X * speed,
                        hrp.AssemblyLinearVelocity.Y,
                        hum.MoveDirection.Z * speed
                    )
                end
            end
        end
    end)
end)

-- 8. INFINITE JUMP (MOBILE TOUCH & PC KEYBOARD)
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

RunService.Heartbeat:Connect(function()
    if State.InfiniteJump then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Jump then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

-- 9. NOCLIP ENGINE
RunService.Stepped:Connect(function()
    if State.Noclip then
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

-- 10. INFINITE ENERGY
RunService.Heartbeat:Connect(function()
    if State.InfiniteEnergy then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Energy") and char.Energy:IsA("NumberValue") then
                char.Energy.Value = 999999
            end
        end)
    end
end)

-- 11. SMOOTH FLY ENGINE (3D DIRECTIONAL FLIGHT)
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local cam = Workspace.CurrentCamera

        if State.FlyMode and root and hum and cam then
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local speed = State.FlySpeed or 60
                local forward = cam.CFrame.LookVector
                local right = cam.CFrame.RightVector
                local move = (forward * -moveDir.Z + right * moveDir.X).Unit
                root.AssemblyLinearVelocity = move * speed
            else
                root.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
end)

-- =================================================================
-- LIGHTWEIGHT, LAG-FREE ESP ENGINES
-- =================================================================

local espFolder = Instance.new("Folder")
espFolder.Name = "Junejo_BloxFruits_ESP"
espFolder.Parent = ScreenGui

task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            espFolder:ClearAllChildren()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            -- A. PLAYER ESP
            if State.PlayerESP then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local pChar = plr.Character
                        local hrp = pChar.HumanoidRootPart
                        local hum = pChar:FindFirstChildOfClass("Humanoid")
                        local dist = root and math.floor((root.Position - hrp.Position).Magnitude) or 0
                        local hp = hum and math.floor(hum.Health) or 0

                        local bill = Instance.new("BillboardGui")
                        bill.AlwaysOnTop = true
                        bill.Size = UDim2.new(0, 130, 0, 24)
                        bill.StudsOffset = Vector3.new(0, 3, 0)
                        bill.Adornee = hrp
                        bill.Parent = espFolder

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

            -- B. CHEST ESP
            if State.ChestESP then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local lowerName = string.lower(obj.Name)
                        if string.find(lowerName, "chest") then
                            local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart))
                            if part and part.Transparency < 1 then
                                local dist = root and math.floor((root.Position - part.Position).Magnitude) or 0
                                local bill = Instance.new("BillboardGui")
                                bill.AlwaysOnTop = true
                                bill.Size = UDim2.new(0, 100, 0, 24)
                                bill.StudsOffset = Vector3.new(0, 2, 0)
                                bill.Adornee = part
                                bill.Parent = espFolder

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
                end
            end

            -- C. FRUIT ESP
            if State.FruitESP then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if (obj:IsA("Tool") or obj:IsA("Model")) and string.find(string.lower(obj.Name), "fruit") then
                        local part = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                        if part and not obj:IsDescendantOf(LocalPlayer.Character) and not obj:IsDescendantOf(LocalPlayer:FindFirstChild("Backpack")) then
                            local dist = root and math.floor((root.Position - part.Position).Magnitude) or 0
                            local bill = Instance.new("BillboardGui")
                            bill.AlwaysOnTop = true
                            bill.Size = UDim2.new(0, 140, 0, 26)
                            bill.StudsOffset = Vector3.new(0, 2.5, 0)
                            bill.Adornee = part
                            bill.Parent = espFolder

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

            -- D. FLOWER ESP
            if State.FlowerESP then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if string.find(string.lower(obj.Name), "flower") then
                        local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart"))
                        if part then
                            local dist = root and math.floor((root.Position - part.Position).Magnitude) or 0
                            local bill = Instance.new("BillboardGui")
                            bill.AlwaysOnTop = true
                            bill.Size = UDim2.new(0, 110, 0, 24)
                            bill.StudsOffset = Vector3.new(0, 2, 0)
                            bill.Adornee = part
                            bill.Parent = espFolder

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
            end
        end)
    end
end)

print("[ULTRA SCRIPT HUB] Blox Fruits Ultra Engine v2 Loaded Successfully!")
