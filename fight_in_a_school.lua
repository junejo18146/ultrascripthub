--========================================================--
--               ULTRA SCRIPT HUB
--             FIGHT IN A SCHOOL (DELTA / PC / MOBILE)
-- Game Link: https://www.roblox.com/games/17698425045/fight-in-a-school
-- Theme: Official UI 1 - Classic Matte Dark (Made by Junejo)
--========================================================--

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

--========================================================--
-- SAFE UI PARENT SELECTION (Delta, Codex, Arceus, PC)
--========================================================--
local TargetParent = LocalPlayer:WaitForChild("PlayerGui")
pcall(function()
    if gethui then
        TargetParent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(CoreGui)
        TargetParent = CoreGui
    elseif CoreGui then
        TargetParent = CoreGui
    end
end)

-- Cleanup existing UI instances
pcall(function()
    for _, name in ipairs({"UltraScriptHub_SchoolFight", "SakiScriptsSchoolFightUI", "JunejoFightInASchoolUI", "JunejoHubUI"}) do
        if CoreGui and CoreGui:FindFirstChild(name) then
            CoreGui[name]:Destroy()
        end
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
        if gethui and gethui():FindFirstChild(name) then
            gethui()[name]:Destroy()
        end
    end
end)

--========================================================--
-- GLOBAL FEATURE STATES
--========================================================--
_G.HitboxExpanderActive = false
_G.PlayerESPActive = false
_G.InfJumpActive = false
_G.NoclipActive = false
_G.InstantGetUpActive = false
_G.InfiniteStaminaActive = false
_G.FlyActive = false
_G.FlySpeed = 50
_G.WalkSpeedActive = false
_G.WalkSpeedValue = 50

--========================================================--
-- ANTI-AFK SYSTEM
--========================================================--
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

-- Startup Notification
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "ULTRA SCRIPT HUB",
        Text = "Fight In A School Loaded Successfully!",
        Duration = 4
    })
end)

--========================================================--
-- SCREEN GUI SETUP
--========================================================--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraScriptHub_SchoolFight"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

pcall(function()
    ScreenGui.Parent = TargetParent
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

--========================================================--
-- FLOATING TOGGLE BUTTON (MOBILE / DELTA FRIENDLY)
--========================================================--
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "FloatingBtn"
FloatingBtn.Parent = ScreenGui
FloatingBtn.Size = UDim2.fromOffset(38, 38)
FloatingBtn.Position = UDim2.new(0, 16, 0.45, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
FloatingBtn.Text = "🥊"
FloatingBtn.TextSize = 18
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.Active = true
FloatingBtn.AutoButtonColor = false

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 10)
FloatCorner.Parent = FloatingBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(35, 35, 42)
FloatStroke.Thickness = 1
FloatStroke.Parent = FloatingBtn

-- Floating button dragging
local floatDragging, floatDragStart, floatStartPos
FloatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        floatDragging = true
        floatDragStart = input.Position
        floatStartPos = FloatingBtn.Position
    end
end)

FloatingBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        floatDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if floatDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - floatDragStart
        FloatingBtn.Position = UDim2.new(
            floatStartPos.X.Scale,
            floatStartPos.X.Offset + delta.X,
            floatStartPos.Y.Scale,
            floatStartPos.Y.Offset + delta.Y
        )
    end
end)

--========================================================--
-- MAIN CONTAINER (OFFICIAL UI 1: 280 x 290)
--========================================================--
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 280, 0, 290)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -145)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Floating button toggle visibility
FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

--========================================================--
-- HEADER BAR
--========================================================--
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundTransparency = 1
Header.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = Header
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.Size = UDim2.new(1, -44, 1, 0)
TitleLabel.Text = "FIGHT IN A SCHOOL"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextYAlignment = Enum.TextYAlignment.Center

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = Header
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -28, 0.5, -10)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(160, 160, 170)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local HeaderDivider = Instance.new("Frame")
HeaderDivider.Name = "HeaderDivider"
HeaderDivider.Parent = MainFrame
HeaderDivider.Position = UDim2.new(0, 0, 0, 36)
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderDivider.BorderSizePixel = 0

-- Window Draggable System
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--========================================================--
-- CONTENT AREA (SCROLLABLE FOR ALL FEATURES)
--========================================================--
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Parent = MainFrame
ScrollFrame.Position = UDim2.new(0, 14, 0, 42)
ScrollFrame.Size = UDim2.new(1, -28, 1, -86)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 2
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = ScrollFrame
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 6)

-- Helper: Standard Toggle Row
local function CreateToggleRow(name, default, order, callback)
    local state = default or false

    local Row = Instance.new("Frame")
    Row.Name = name .. "_Row"
    Row.Parent = ScrollFrame
    Row.Size = UDim2.new(1, -4, 0, 26)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Parent = Row
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(240, 240, 245)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center

    local Checkbox = Instance.new("TextButton")
    Checkbox.Name = "Checkbox"
    Checkbox.Parent = Row
    Checkbox.Size = UDim2.new(0, 20, 0, 20)
    Checkbox.Position = UDim2.new(1, -20, 0.5, -10)
    Checkbox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Checkbox.Text = ""
    Checkbox.AutoButtonColor = false

    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 5)
    CheckCorner.Parent = Checkbox

    local CheckStroke = Instance.new("UIStroke")
    CheckStroke.Color = Color3.fromRGB(45, 45, 55)
    CheckStroke.Thickness = 1
    CheckStroke.Parent = Checkbox

    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Parent = Checkbox
    Indicator.Size = state and UDim2.new(0, 10, 0, 10) or UDim2.new(0, 0, 0, 0)
    Indicator.Position = UDim2.new(0.5, 0, 0.5, 0)
    Indicator.AnchorPoint = Vector2.new(0.5, 0.5)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.BorderSizePixel = 0

    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 2)
    IndicatorCorner.Parent = Indicator

    local function updateVisuals()
        local targetSize = state and UDim2.new(0, 10, 0, 10) or UDim2.new(0, 0, 0, 0)
        TweenService:Create(Indicator, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = targetSize
        }):Play()
    end

    Checkbox.MouseButton1Click:Connect(function()
        state = not state
        updateVisuals()
        if callback then
            task.spawn(callback, state)
        end
    end)

    return Row
end

-- Helper: Dual-Control Speed Row (Checkbox + Stepper Pill)
local function CreateSpeedRow(name, defaultVal, order, toggleCallback, valueCallback)
    local active = false
    local currentVal = defaultVal or 50

    local Row = Instance.new("Frame")
    Row.Name = name .. "_Row"
    Row.Parent = ScrollFrame
    Row.Size = UDim2.new(1, -4, 0, 26)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Parent = Row
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Size = UDim2.new(1, -135, 1, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(240, 240, 245)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center

    -- Stepper Pill [ - 50 + ]
    local Stepper = Instance.new("Frame")
    Stepper.Name = "Stepper"
    Stepper.Parent = Row
    Stepper.Size = UDim2.new(0, 96, 0, 24)
    Stepper.Position = UDim2.new(1, -126, 0.5, -12)
    Stepper.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Stepper.BorderSizePixel = 0

    local StepCorner = Instance.new("UICorner")
    StepCorner.CornerRadius = UDim.new(0, 6)
    StepCorner.Parent = Stepper

    local StepStroke = Instance.new("UIStroke")
    StepStroke.Color = Color3.fromRGB(45, 45, 55)
    StepStroke.Thickness = 1
    StepStroke.Parent = Stepper

    local MinusBtn = Instance.new("TextButton")
    MinusBtn.Name = "Minus"
    MinusBtn.Parent = Stepper
    MinusBtn.Size = UDim2.new(0, 24, 1, 0)
    MinusBtn.Position = UDim2.new(0, 0, 0, 0)
    MinusBtn.BackgroundTransparency = 1
    MinusBtn.Text = "−"
    MinusBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    MinusBtn.TextSize = 14
    MinusBtn.Font = Enum.Font.GothamBold

    local ValueDisplay = Instance.new("TextLabel")
    ValueDisplay.Name = "ValueDisplay"
    ValueDisplay.Parent = Stepper
    ValueDisplay.Size = UDim2.new(1, -48, 1, 0)
    ValueDisplay.Position = UDim2.new(0, 24, 0, 0)
    ValueDisplay.BackgroundTransparency = 1
    ValueDisplay.Text = tostring(currentVal)
    ValueDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueDisplay.TextSize = 12
    ValueDisplay.Font = Enum.Font.GothamBold

    local PlusBtn = Instance.new("TextButton")
    PlusBtn.Name = "Plus"
    PlusBtn.Parent = Stepper
    PlusBtn.Size = UDim2.new(0, 24, 1, 0)
    PlusBtn.Position = UDim2.new(1, -24, 0, 0)
    PlusBtn.BackgroundTransparency = 1
    PlusBtn.Text = "+"
    PlusBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    PlusBtn.TextSize = 14
    PlusBtn.Font = Enum.Font.GothamBold

    -- Checkbox toggle
    local Checkbox = Instance.new("TextButton")
    Checkbox.Name = "Checkbox"
    Checkbox.Parent = Row
    Checkbox.Size = UDim2.new(0, 20, 0, 20)
    Checkbox.Position = UDim2.new(1, -20, 0.5, -10)
    Checkbox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Checkbox.Text = ""
    Checkbox.AutoButtonColor = false

    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 5)
    CheckCorner.Parent = Checkbox

    local CheckStroke = Instance.new("UIStroke")
    CheckStroke.Color = Color3.fromRGB(45, 45, 55)
    CheckStroke.Thickness = 1
    CheckStroke.Parent = Checkbox

    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Parent = Checkbox
    Indicator.Size = UDim2.new(0, 0, 0, 0)
    Indicator.Position = UDim2.new(0.5, 0, 0.5, 0)
    Indicator.AnchorPoint = Vector2.new(0.5, 0.5)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.BorderSizePixel = 0

    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 2)
    IndicatorCorner.Parent = Indicator

    local function updateToggle()
        local targetSize = active and UDim2.new(0, 10, 0, 10) or UDim2.new(0, 0, 0, 0)
        TweenService:Create(Indicator, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = targetSize
        }):Play()
    end

    MinusBtn.MouseButton1Click:Connect(function()
        currentVal = math.max(16, currentVal - 10)
        ValueDisplay.Text = tostring(currentVal)
        if valueCallback then
            task.spawn(valueCallback, currentVal)
        end
    end)

    PlusBtn.MouseButton1Click:Connect(function()
        currentVal = math.min(250, currentVal + 10)
        ValueDisplay.Text = tostring(currentVal)
        if valueCallback then
            task.spawn(valueCallback, currentVal)
        end
    end)

    Checkbox.MouseButton1Click:Connect(function()
        active = not active
        updateToggle()
        if toggleCallback then
            task.spawn(toggleCallback, active, currentVal)
        end
    end)

    return Row
end

--========================================================--
-- MANDATORY CENTERED FOOTER (JUNEJO BRANDING)
--========================================================--
local FooterDivider = Instance.new("Frame")
FooterDivider.Name = "FooterDivider"
FooterDivider.Parent = MainFrame
FooterDivider.Position = UDim2.new(0, 0, 1, -44)
FooterDivider.Size = UDim2.new(1, 0, 0, 1)
FooterDivider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
FooterDivider.BorderSizePixel = 0

local FooterFrame = Instance.new("Frame")
FooterFrame.Name = "FooterFrame"
FooterFrame.Parent = MainFrame
FooterFrame.Position = UDim2.new(0, 0, 1, -42)
FooterFrame.Size = UDim2.new(1, 0, 0, 38)
FooterFrame.BackgroundTransparency = 1

local HubTitle = Instance.new("TextLabel")
HubTitle.Name = "HubTitle"
HubTitle.Parent = FooterFrame
HubTitle.Size = UDim2.new(1, 0, 0, 16)
HubTitle.Position = UDim2.new(0, 0, 0, 3)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "ULTRA SCRIPT HUB"
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 11
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextXAlignment = Enum.TextXAlignment.Center

local SubTitle = Instance.new("TextLabel")
SubTitle.Name = "SubTitle"
SubTitle.Parent = FooterFrame
SubTitle.Size = UDim2.new(1, 0, 0, 14)
SubTitle.Position = UDim2.new(0, 0, 0, 18)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Made by Junejo"
SubTitle.TextColor3 = Color3.fromRGB(136, 136, 153)
SubTitle.TextSize = 10
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextXAlignment = Enum.TextXAlignment.Center

--========================================================--
-- 1. HITBOX EXPANDER ENGINE (14x14x14 RED NEON)
--========================================================--
local OriginalHitboxSizes = {}

local function ExpandHitboxes()
    pcall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:IsA("BasePart") then
                    if not OriginalHitboxSizes[player.UserId] then
                        OriginalHitboxSizes[player.UserId] = hrp.Size
                    end
                    hrp.Size = Vector3.new(14, 14, 14)
                    hrp.Transparency = 0.65
                    hrp.BrickColor = BrickColor.new("Really red")
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                end
            end
        end
    end)
end

local function RestoreHitboxes()
    pcall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:IsA("BasePart") then
                    local orig = OriginalHitboxSizes[player.UserId] or Vector3.new(2, 2, 1)
                    hrp.Size = orig
                    hrp.Transparency = 1
                    hrp.Material = Enum.Material.Plastic
                    hrp.CanCollide = false
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(1)
        if _G.HitboxExpanderActive then
            ExpandHitboxes()
        end
    end
end)

--========================================================--
-- 2. PLAYER ESP ENGINE (HIGHLIGHT & BILLBOARD HEALTH)
--========================================================--
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "Ultra_PlayerESP"
ESPFolder.Parent = ScreenGui

local function ClearPlayerESP()
    for _, obj in ipairs(ESPFolder:GetChildren()) do
        obj:Destroy()
    end
end

local function CreatePlayerESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local id = "ESP_" .. tostring(player.UserId)
    if ESPFolder:FindFirstChild(id) then return end

    local espHolder = Instance.new("Folder")
    espHolder.Name = id
    espHolder.Parent = ESPFolder

    -- Red Highlight Box
    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.FillColor = Color3.fromRGB(255, 45, 45)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.Parent = espHolder

    -- Billboard Gui
    local bb = Instance.new("BillboardGui")
    bb.Adornee = hrp
    bb.Size = UDim2.new(0, 160, 0, 36)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    bb.Parent = espHolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 60, 60)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.2
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.Text = player.DisplayName
    label.Parent = bb

    task.spawn(function()
        while espHolder.Parent and player.Parent and char.Parent and hum.Health > 0 do
            task.wait(0.25)
            pcall(function()
                local myChar = LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myHrp and hrp.Parent then
                    local dist = math.floor((myHrp.Position - hrp.Position).Magnitude)
                    local hp = math.floor(hum.Health)
                    label.Text = player.DisplayName .. "\n[" .. tostring(dist) .. "m | HP: " .. tostring(hp) .. "]"
                end
            end)
        end
        espHolder:Destroy()
    end)
end

task.spawn(function()
    while true do
        task.wait(1.5)
        if _G.PlayerESPActive then
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        CreatePlayerESP(player)
                    end
                end
            end)
        else
            ClearPlayerESP()
        end
    end
end)

--========================================================--
-- 3. INFINITE JUMP ENGINE
--========================================================--
UserInputService.JumpRequest:Connect(function()
    if _G.InfJumpActive then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
            end
        end)
    end
end)

--========================================================--
-- 4. NO CLIP ENGINE
--========================================================--
RunService.Stepped:Connect(function()
    if _G.NoclipActive and LocalPlayer.Character then
        pcall(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

--========================================================--
-- 5. INSTANT GET UP ENGINE (ANTI-RAGDOLL / QUICK RECOVERY)
--========================================================--
local function ProcessInstantGetUp()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Ragdoll or
           state == Enum.HumanoidStateType.FallingDown or
           state == Enum.HumanoidStateType.PlatformStanding or
           state == Enum.HumanoidStateType.Physics or
           state == Enum.HumanoidStateType.GettingUp then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end

        if hum.PlatformStand then
            hum.PlatformStand = false
        end
        if hum.Sit then
            hum.Sit = false
        end

        -- Cancel any ragdoll/knock attributes
        for attr, _ in pairs(char:GetAttributes()) do
            local lName = string.lower(attr)
            if string.find(lName, "ragdoll") or string.find(lName, "knock") or string.find(lName, "stun") or string.find(lName, "down") then
                char:SetAttribute(attr, false)
            end
        end

        -- Enable any motor6ds disabled by ragdoll
        for _, motor in ipairs(char:GetDescendants()) do
            if motor:IsA("Motor6D") and not motor.Enabled then
                motor.Enabled = true
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if _G.InstantGetUpActive then
            ProcessInstantGetUp()
        end
    end
end)

local function HookCharacterRagdoll(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.StateChanged:Connect(function(oldState, newState)
            if _G.InstantGetUpActive then
                if newState == Enum.HumanoidStateType.Ragdoll or
                   newState == Enum.HumanoidStateType.FallingDown or
                   newState == Enum.HumanoidStateType.PlatformStanding or
                   newState == Enum.HumanoidStateType.Physics or
                   newState == Enum.HumanoidStateType.GettingUp then
                    task.wait()
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    hum.PlatformStand = false
                    hum.Sit = false
                end
            end
        end)
    end
end

if LocalPlayer.Character then
    HookCharacterRagdoll(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(HookCharacterRagdoll)

--========================================================--
-- 6. INFINITE STAMINA ENGINE
--========================================================--
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.InfiniteStaminaActive then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    -- Reset Character Attributes
                    for attr, _ in pairs(char:GetAttributes()) do
                        local lName = string.lower(attr)
                        if string.find(lName, "stamina") or string.find(lName, "energy") then
                            char:SetAttribute(attr, 100)
                        end
                    end
                    -- Reset Descendant Values
                    for _, obj in ipairs(char:GetDescendants()) do
                        if obj:IsA("ValueBase") then
                            local name = string.lower(obj.Name)
                            if string.find(name, "stamina") or string.find(name, "energy") then
                                obj.Value = 100
                            end
                        end
                    end
                end
                -- Reset Player Attributes
                for attr, _ in pairs(LocalPlayer:GetAttributes()) do
                    local lName = string.lower(attr)
                    if string.find(lName, "stamina") or string.find(lName, "energy") then
                        LocalPlayer:SetAttribute(attr, 100)
                    end
                end
            end)
        end
    end
end)

--========================================================--
-- 7. FLY MODE ENGINE (SMOOTH 3D FLIGHT)
--========================================================--
local FlyBV, FlyBG

local function StopFly()
    pcall(function()
        if FlyBV then FlyBV:Destroy(); FlyBV = nil end
        if FlyBG then FlyBG:Destroy(); FlyBG = nil end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end)
end

local function UpdateFly()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local camera = Workspace.CurrentCamera
        if not hrp or not hum or not camera then return end

        if not FlyBV or FlyBV.Parent ~= hrp then
            FlyBV = Instance.new("BodyVelocity")
            FlyBV.Name = "UltraFlyBV"
            FlyBV.MaxForce = Vector3.new(1e7, 1e7, 1e7)
            FlyBV.Parent = hrp
        end
        if not FlyBG or FlyBG.Parent ~= hrp then
            FlyBG = Instance.new("BodyGyro")
            FlyBG.Name = "UltraFlyBG"
            FlyBG.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
            FlyBG.P = 10000
            FlyBG.Parent = hrp
        end

        hum.PlatformStand = true
        FlyBG.CFrame = camera.CFrame

        local speed = _G.FlySpeed or 50
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local vel = camera.CFrame.LookVector * speed
            if math.abs(moveDir.Z) < 0.2 and math.abs(moveDir.X) > 0.5 then
                vel = camera.CFrame.RightVector * speed * (moveDir.X > 0 and 1 or -1)
            end
            FlyBV.Velocity = vel
        else
            FlyBV.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.03)
        if _G.FlyActive then
            UpdateFly()
        else
            if FlyBV or FlyBG then
                StopFly()
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.3)
    if not _G.FlyActive then
        StopFly()
    end
end)

--========================================================--
-- 8. WALKSPEED CONTROLLER (CONTINUOUS ENFORCER)
--========================================================--
RunService.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if _G.WalkSpeedActive and _G.WalkSpeedValue and _G.WalkSpeedValue > 16 then
                    hum.WalkSpeed = _G.WalkSpeedValue
                end
            end
        end
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    pcall(function()
        local hum = char:WaitForChild("Humanoid", 5)
        if hum and _G.WalkSpeedActive and _G.WalkSpeedValue and _G.WalkSpeedValue > 16 then
            hum.WalkSpeed = _G.WalkSpeedValue
        end
    end)
end)

--========================================================--
-- REGISTER FEATURES INTO JUNEJO UI 1
--========================================================--

-- 1. Hitbox Expander
CreateToggleRow("Hitbox Expander", false, 1, function(state)
    _G.HitboxExpanderActive = state
    if state then
        ExpandHitboxes()
    else
        RestoreHitboxes()
    end
end)

-- 2. Player ESP
CreateToggleRow("Player ESP", false, 2, function(state)
    _G.PlayerESPActive = state
    if not state then
        ClearPlayerESP()
    end
end)

-- 3. Infinite Jump
CreateToggleRow("Infinite Jump", false, 3, function(state)
    _G.InfJumpActive = state
end)

-- 4. No Clip
CreateToggleRow("No Clip", false, 4, function(state)
    _G.NoclipActive = state
end)

-- 5. Instant Get Up
CreateToggleRow("Instant Get Up", false, 5, function(state)
    _G.InstantGetUpActive = state
    if state then
        ProcessInstantGetUp()
    end
end)

-- 6. Infinite Stamina
CreateToggleRow("Infinite Stamina", false, 6, function(state)
    _G.InfiniteStaminaActive = state
end)

-- 7. Fly Mode (Dual Control Stepper + Checkbox)
CreateSpeedRow("Fly Mode", 50, 7, function(active, value)
    _G.FlyActive = active
    _G.FlySpeed = value
    if not active then
        StopFly()
    end
end, function(value)
    _G.FlySpeed = value
end)

-- 8. WalkSpeed (Dual Control Stepper + Checkbox)
CreateSpeedRow("WalkSpeed", 50, 8, function(active, value)
    _G.WalkSpeedActive = active
    _G.WalkSpeedValue = value
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = active and value or 16
        end
    end)
end, function(value)
    _G.WalkSpeedValue = value
    if _G.WalkSpeedActive then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = value
            end
        end)
    end
end)
