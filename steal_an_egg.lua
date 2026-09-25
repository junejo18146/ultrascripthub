--[[
    ========================================================================
    ULTRA SCRIPT HUB - OFFICIAL PRODUCTION SCRIPT
    ========================================================================
    Game: Steal An Egg 🥚
    Creator: Made by Junejo (junejo18146)
    UI Style: UI 1 (Official Ultra Script Hub Classic Matte Dark - 280px)
    GitHub: https://github.com/junejo18146/ultrascripthub
    Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/junejo18146/ultrascripthub/main/steal_an_egg.lua"))()
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
    for _, name in ipairs({"UltraScriptHub_StealAnEgg", "JunejoHubUI_StealAnEgg", "Junejo_StealAnEgg_UI"}) do
        if GuiParent:FindFirstChild(name) then GuiParent[name]:Destroy() end
        if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end
end)

-- Global State Table
local State = {
    AutoSteal = false,
    RareEggESP = false,
    AllEggsESP = false,
    PlayerESP = false,
    WalkSpeed = false,
    WalkSpeedValue = 50,
    FlyMode = false,
    FlySpeed = 60,
    InfiniteJump = false
}

local SavedBaseCFrame = nil

-- Character Helper Functions
local function getRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function getHum()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- Save Base Position on Spawn
task.spawn(function()
    task.wait(0.8)
    local root = getRoot()
    if root and not SavedBaseCFrame then
        SavedBaseCFrame = root.CFrame
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    local root = getRoot()
    if root and not SavedBaseCFrame then
        SavedBaseCFrame = root.CFrame
    end
end)

-- 24/7 Anti-AFK Idle Kick Protection
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- Instant ProximityPrompt Trigger Helper
local function TriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 99999
        local origHold = prompt.HoldDuration or 0
        prompt.HoldDuration = 0

        if fireproximityprompt then
            pcall(function() fireproximityprompt(prompt, 0) end)
            pcall(function() fireproximityprompt(prompt) end)
        else
            prompt:InputHoldBegin()
            task.wait(0.04)
            prompt:InputHoldEnd()
        end
        prompt.HoldDuration = origHold
    end)
end

-- Safe Teleport with Anti-Fall Safety Platform
local function TeleportSafe(targetCFrame)
    pcall(function()
        local root = getRoot()
        if not root then return end

        local plat = Instance.new("Part")
        plat.Name = "JunejoSafePlat"
        plat.Size = Vector3.new(16, 1, 16)
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

-- Rare Egg Keywords Matcher
local rareKeywords = {
    "rare", "golden", "gold", "diamond", "legendary", "mythic", "dragon",
    "godly", "void", "huge", "ruby", "emerald", "rainbow", "secret", "tier"
}

local function IsRareEgg(name)
    local lower = string.lower(name)
    for _, kw in ipairs(rareKeywords) do
        if string.find(lower, kw) then
            return true
        end
    end
    return false
end

-- Find All Eggs Helper
local function GetAllEggs()
    local eggs = {}
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local pName = string.lower(desc.Parent and desc.Parent.Name or "")
            local act = string.lower(desc.ActionText or "")
            local obj = string.lower(desc.ObjectText or "")
            if string.find(pName, "egg") or string.find(act, "steal") or string.find(act, "take") or string.find(obj, "egg") then
                local part = desc.Parent:IsA("BasePart") and desc.Parent or desc.Parent:FindFirstChildWhichIsA("BasePart")
                if part then
                    table.insert(eggs, {Object = desc.Parent, Part = part, Prompt = desc, Name = desc.Parent.Name})
                end
            end
        elseif desc:IsA("BasePart") or desc:IsA("Model") then
            local n = string.lower(desc.Name)
            if string.find(n, "egg") and not desc:IsDescendantOf(LocalPlayer.Character or Workspace) and not Players:GetPlayerFromCharacter(desc) then
                local part = desc:IsA("BasePart") and desc or desc:FindFirstChildWhichIsA("BasePart")
                if part and part.Transparency < 1 then
                    table.insert(eggs, {Object = desc, Part = part, Prompt = desc:FindFirstChildOfClass("ProximityPrompt"), Name = desc.Name})
                end
            end
        end
    end
    return eggs
end

-- =================================================================
-- UI 1 MASTER CONTAINER (280px Width Classic Matte Dark)
-- =================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraScriptHub_StealAnEgg"
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

-- Bulletproof Click & Tap Event Binder (Delta Mobile & PC)
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

-- Draggable Logic
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
FloatIcon.Text = "🥚"
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
TitleLabel.Text = "STEAL AN EGG"
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

-- 1. STEAL SECTION (EXACTLY 1 STEAL FEATURE)
CreateSectionHeader("🥚 Steal Engine", nextOrder())

CreateFeatureRow("Auto Steal Egg", State.AutoSteal, nextOrder(), function(val)
    State.AutoSteal = val
end)

-- 2. TELEPORTS SECTION (EXACTLY 1 TELEPORT FEATURE)
CreateSectionHeader("🚀 Teleports", nextOrder())

CreateActionButton("⚡ Teleport to Rare Egg", nextOrder(), function()
    pcall(function()
        local root = getRoot()
        if not root then return end

        local allEggs = GetAllEggs()
        local targetEgg = nil

        -- 1. Priority: Find keyword-matched Rare Egg
        for _, eggData in ipairs(allEggs) do
            if IsRareEgg(eggData.Name) then
                targetEgg = eggData
                break
            end
        end

        -- 2. Fallback: Furthest Egg from spawn/base
        if not targetEgg and #allEggs > 0 then
            local maxDist = 0
            for _, eggData in ipairs(allEggs) do
                local d = (root.Position - eggData.Part.Position).Magnitude
                if d > maxDist then
                    maxDist = d
                    targetEgg = eggData
                end
            end
        end

        if targetEgg then
            TeleportSafe(targetEgg.Part.CFrame + Vector3.new(0, 2, 0))
            if targetEgg.Prompt then
                task.wait(0.1)
                TriggerPrompt(targetEgg.Prompt)
            end
        end
    end)
end)

-- 3. VISUALS & ESP SECTION
CreateSectionHeader("👁️ Visuals & ESP", nextOrder())

CreateFeatureRow("Rare Egg ESP", State.RareEggESP, nextOrder(), function(val)
    State.RareEggESP = val
end)

CreateFeatureRow("All Eggs ESP", State.AllEggsESP, nextOrder(), function(val)
    State.AllEggsESP = val
end)

CreateFeatureRow("Player ESP", State.PlayerESP, nextOrder(), function(val)
    State.PlayerESP = val
end)

-- 4. MOVEMENT & PLAYER UTILITIES (2-3 MOVEMENT FEATURES)
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
-- GAMEPLAY ENGINES & FEATURE IMPLEMENTATIONS
-- =================================================================

-- 1. BULLETPROOF AUTO STEAL EGG & BASE RETURN ENGINE
task.spawn(function()
    while true do
        task.wait(0.2)
        if State.AutoSteal then
            pcall(function()
                local root = getRoot()
                if not root then return end

                if not SavedBaseCFrame then
                    SavedBaseCFrame = root.CFrame
                end

                local allEggs = GetAllEggs()
                local targetEgg = nil
                local shortestDist = 99999

                -- Prioritize nearest stealable egg
                for _, eggData in ipairs(allEggs) do
                    local d = (root.Position - eggData.Part.Position).Magnitude
                    if d < shortestDist then
                        shortestDist = d
                        targetEgg = eggData
                    end
                end

                if targetEgg then
                    -- Warp to Egg
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.CFrame = targetEgg.Part.CFrame + Vector3.new(0, 2.5, 0)
                    task.wait(0.12)

                    -- Trigger Prompt & Touch
                    if targetEgg.Prompt then
                        TriggerPrompt(targetEgg.Prompt)
                    end
                    pcall(function()
                        if firetouchinterest then
                            firetouchinterest(root, targetEgg.Part, 0)
                            firetouchinterest(root, targetEgg.Part, 1)
                        end
                    end)
                    task.wait(0.15)

                    -- Warp safely back to Base to secure the egg
                    if SavedBaseCFrame then
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.CFrame = SavedBaseCFrame + Vector3.new(0, 2, 0)
                    end
                    task.wait(0.3)
                end
            end)
        else
            task.wait(0.3)
        end
    end
end)

-- 2. WALKSPEED CONTROLLER (HUMANOID SYNC + VELOCITY ASSIST)
RunService.Heartbeat:Connect(function()
    pcall(function()
        local root = getRoot()
        local hum = getHum()
        if hum and root then
            if State.WalkSpeed and State.WalkSpeedValue and State.WalkSpeedValue > 16 then
                hum.WalkSpeed = State.WalkSpeedValue
                if hum.MoveDirection.Magnitude > 0 then
                    local speed = State.WalkSpeedValue
                    root.AssemblyLinearVelocity = Vector3.new(
                        hum.MoveDirection.X * speed,
                        root.AssemblyLinearVelocity.Y,
                        hum.MoveDirection.Z * speed
                    )
                end
            end
        end
    end)
end)

-- 3. INFINITE JUMP (MOBILE TOUCH & PC KEYBOARD)
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        pcall(function()
            local hum = getHum()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

RunService.Heartbeat:Connect(function()
    if State.InfiniteJump then
        pcall(function()
            local hum = getHum()
            if hum and hum.Jump then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

-- 4. SMOOTH FLY ENGINE (3D DIRECTIONAL FLIGHT)
RunService.Heartbeat:Connect(function()
    pcall(function()
        local root = getRoot()
        local hum = getHum()
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
espFolder.Name = "Junejo_StealAnEgg_ESP"
espFolder.Parent = ScreenGui

task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            espFolder:ClearAllChildren()
            local root = getRoot()

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
                        lbl.TextColor3 = Color3.fromRGB(255, 75, 75)
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 11
                        lbl.TextStrokeTransparency = 0.3
                        lbl.Parent = bill
                    end
                end
            end

            -- B. RARE EGG ESP & ALL EGGS ESP
            if State.RareEggESP or State.AllEggsESP then
                local allEggs = GetAllEggs()
                for _, eggData in ipairs(allEggs) do
                    local isRare = IsRareEgg(eggData.Name)
                    local shouldRender = (isRare and State.RareEggESP) or (State.AllEggsESP and not isRare)

                    if shouldRender and eggData.Part then
                        local dist = root and math.floor((root.Position - eggData.Part.Position).Magnitude) or 0
                        local bill = Instance.new("BillboardGui")
                        bill.AlwaysOnTop = true
                        bill.Size = UDim2.new(0, 140, 0, 26)
                        bill.StudsOffset = Vector3.new(0, 2.5, 0)
                        bill.Adornee = eggData.Part
                        bill.Parent = espFolder

                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1

                        if isRare then
                            lbl.Text = "🌟 " .. eggData.Name .. " [" .. tostring(dist) .. "m]"
                            lbl.TextColor3 = Color3.fromRGB(255, 80, 220)
                        else
                            lbl.Text = "🥚 " .. eggData.Name .. " [" .. tostring(dist) .. "m]"
                            lbl.TextColor3 = Color3.fromRGB(80, 255, 140)
                        end

                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 11
                        lbl.TextStrokeTransparency = 0.3
                        lbl.Parent = bill
                    end
                end
            end
        end)
    end
end)

print("[ULTRA SCRIPT HUB] Steal An Egg Loaded Successfully!")
