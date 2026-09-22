--========================================================--
--               ULTRA SCRIPT HUB
--             JAILBREAK (DELTA / PC / MOBILE)
-- Game Link: https://www.roblox.com/games/606849621/Jailbreak
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

local Camera = Workspace.CurrentCamera

--========================================================--
-- SAFE UI PARENT RESOLVER (Delta, Codex, Arceus, PC)
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

-- Cleanup existing instances
pcall(function()
    for _, name in ipairs({"UltraScriptHub_Jailbreak", "HamiHub_Jailbreak_MasterUI", "JunejoJailbreakUI", "JunejoHubUI"}) do
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
-- GLOBAL STATES & BACKEND LOGIC
--========================================================--
local State = {
    Flight = false,
    FlightSpeed = 50,
    WalkSpeed = false,
    WalkSpeedValue = 45,
    Noclip = false,
    InfiniteJump = false,
    ShiftDash = false,
    Invisibility = false,
    ESPEnabled = false,
    PreviousLocation = nil
}

-- Jailbreak POI Locations (CFrame Data)
local Locations = {
    ["Bank"] = CFrame.new(10, 18, 784),
    ["Jewelry Store"] = CFrame.new(142, 18, 1365),
    ["Museum"] = CFrame.new(1069, 117, 1258),
    ["Casino"] = CFrame.new(-246, 18, 4581),
    ["Volcano Base"] = CFrame.new(1652, 50, -1737),
    ["City Base"] = CFrame.new(-247, 18, 1569)
}

local flyBodyVel, flyBodyGyro
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "Ultra_Jailbreak_ESP"
pcall(function() ESPFolder.Parent = TargetParent end)
local ESPCache = {}

local function isAlive(player)
    player = player or LocalPlayer
    local char = player.Character
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end

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
        Text = "Jailbreak Engine Loaded Successfully!",
        Duration = 4
    })
end)

--========================================================--
-- 1. TELEPORTATION ENGINE (Anti-Cheat Bypass & Return)
--========================================================--
local function teleportTo(cframe)
    if isAlive() then
        local char = LocalPlayer.Character
        local root = char.HumanoidRootPart
        
        State.PreviousLocation = root.CFrame
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        char:PivotTo(cframe)
    end
end

--========================================================--
-- 2. GHOST INVISIBILITY
--========================================================--
local function toggleInvisibility(enabled)
    if not isAlive() then return end
    for _, obj in ipairs(LocalPlayer.Character:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") then
            if enabled then
                if not obj:GetAttribute("OrigTrans") then
                    obj:SetAttribute("OrigTrans", obj.Transparency)
                end
                if obj.Name ~= "HumanoidRootPart" then
                    obj.Transparency = 1
                end
            else
                local orig = obj:GetAttribute("OrigTrans")
                if orig then
                    obj.Transparency = orig
                end
            end
        end
    end
end

--========================================================--
-- 3. SHIFT DASH MECHANIC (PivotTo Smooth Boost)
--========================================================--
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift and State.ShiftDash and isAlive() then
        local char = LocalPlayer.Character
        local root = char.HumanoidRootPart
        local dashDir = Camera.CFrame.LookVector
        
        root.AssemblyLinearVelocity = Vector3.zero
        char:PivotTo(root.CFrame + (Vector3.new(dashDir.X, 0, dashDir.Z).Unit * 40))
    end
end)

--========================================================--
-- 4. INFINITE JUMP
--========================================================--
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and isAlive() then
        local char = LocalPlayer.Character
        local hum = char.Humanoid
        local root = char.HumanoidRootPart
        
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 50, root.AssemblyLinearVelocity.Z)
    end
end)

--========================================================--
-- 5. ESP ENGINE (BOX ESP HIGHLIGHT METHOD)
--========================================================--
local function CreateESP(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name .. "_ESP"
    billboard.Adornee = player.Character
    billboard.Size = UDim2.new(4, 0, 5.5, 0)
    billboard.AlwaysOnTop = true
    
    local box = Instance.new("Frame", billboard)
    box.Size = UDim2.new(1, 0, 1, 0)
    box.BackgroundTransparency = 1
    
    local stroke = Instance.new("UIStroke", box)
    stroke.Color = Color3.fromRGB(255, 50, 60)
    stroke.Thickness = 1.5
    
    billboard.Parent = ESPFolder
    return billboard
end

RunService.RenderStepped:Connect(function()
    if State.WalkSpeed and isAlive() then
        LocalPlayer.Character.Humanoid.WalkSpeed = State.WalkSpeedValue or 45
    end

    if State.ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if isAlive(player) then
                    if not ESPCache[player] or not ESPCache[player].Parent then
                        ESPCache[player] = CreateESP(player)
                    else
                        ESPCache[player].Adornee = player.Character.HumanoidRootPart
                        ESPCache[player].Enabled = true
                    end
                elseif ESPCache[player] then
                    ESPCache[player].Enabled = false
                end
            end
        end
    else
        for _, gui in pairs(ESPCache) do
            gui.Enabled = false
        end
    end

    if State.Flight and isAlive() and flyBodyVel and flyBodyGyro then
        local root = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character.Humanoid
        local moveDir = hum.MoveDirection
        local camCF = Camera.CFrame

        flyBodyGyro.CFrame = camCF
        if moveDir.Magnitude > 0.05 then
            local forwardAmount = moveDir:Dot(camCF.LookVector)
            local rightAmount = moveDir:Dot(camCF.RightVector)
            flyBodyVel.Velocity = (camCF.LookVector * forwardAmount + camCF.RightVector * rightAmount) * State.FlightSpeed
        else
            flyBodyVel.Velocity = Vector3.zero
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            flyBodyVel.Velocity = flyBodyVel.Velocity + Vector3.new(0, State.FlightSpeed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            flyBodyVel.Velocity = flyBodyVel.Velocity - Vector3.new(0, State.FlightSpeed, 0)
        end
    end
end)

--========================================================--
-- 6. NOCLIP
--========================================================--
RunService.Stepped:Connect(function()
    if State.Noclip and isAlive() then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

--========================================================--
-- SCREEN GUI SETUP
--========================================================--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraScriptHub_Jailbreak"
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
FloatingBtn.Text = "🚨"
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
-- MAIN CONTAINER (OFFICIAL UI 1: 280 x 310)
--========================================================--
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 280, 0, 310)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -155)
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
TitleLabel.Text = "JAILBREAK"
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
-- SCROLLABLE CONTENT CONTAINER
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

-- Section Header Builder
local function CreateSectionLabel(text, order)
    local Label = Instance.new("TextLabel")
    Label.Name = "Section_" .. text
    Label.Parent = ScrollFrame
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.Text = text:upper()
    Label.TextColor3 = Color3.fromRGB(136, 136, 153)
    Label.TextSize = 10
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Bottom
    Label.LayoutOrder = order
    return Label
end

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

-- Helper: Full-width Dark Rounded Action Button
local function CreateActionButton(name, order, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name .. "_Btn"
    Button.Parent = ScrollFrame
    Button.Size = UDim2.new(1, -4, 0, 26)
    Button.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Button.BorderSizePixel = 0
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(240, 240, 245)
    Button.TextSize = 12
    Button.Font = Enum.Font.GothamMedium
    Button.AutoButtonColor = false
    Button.LayoutOrder = order

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(45, 45, 55)
    Stroke.Thickness = 1
    Stroke.Parent = Button

    Button.MouseButton1Click:Connect(function()
        local orig = Button.BackgroundColor3
        Button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        task.wait(0.1)
        Button.BackgroundColor3 = orig
        if callback then
            task.spawn(callback)
        end
    end)

    return Button
end

-- Helper: 2-Column Action Buttons Row
local function CreateDualActionButtons(name1, cb1, name2, cb2, order)
    local Row = Instance.new("Frame")
    Row.Name = "DualBtn_" .. name1
    Row.Parent = ScrollFrame
    Row.Size = UDim2.new(1, -4, 0, 26)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order

    local b1 = Instance.new("TextButton")
    b1.Parent = Row
    b1.Size = UDim2.new(0.5, -3, 1, 0)
    b1.Position = UDim2.new(0, 0, 0, 0)
    b1.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    b1.BorderSizePixel = 0
    b1.Text = name1
    b1.TextColor3 = Color3.fromRGB(240, 240, 245)
    b1.TextSize = 11
    b1.Font = Enum.Font.GothamMedium
    b1.AutoButtonColor = false

    local c1 = Instance.new("UICorner", b1)
    c1.CornerRadius = UDim.new(0, 6)
    local s1 = Instance.new("UIStroke", b1)
    s1.Color = Color3.fromRGB(45, 45, 55)
    s1.Thickness = 1

    b1.MouseButton1Click:Connect(function()
        b1.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        task.wait(0.1)
        b1.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
        if cb1 then task.spawn(cb1) end
    end)

    local b2 = Instance.new("TextButton")
    b2.Parent = Row
    b2.Size = UDim2.new(0.5, -3, 1, 0)
    b2.Position = UDim2.new(0.5, 3, 0, 0)
    b2.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    b2.BorderSizePixel = 0
    b2.Text = name2
    b2.TextColor3 = Color3.fromRGB(240, 240, 245)
    b2.TextSize = 11
    b2.Font = Enum.Font.GothamMedium
    b2.AutoButtonColor = false

    local c2 = Instance.new("UICorner", b2)
    c2.CornerRadius = UDim.new(0, 6)
    local s2 = Instance.new("UIStroke", b2)
    s2.Color = Color3.fromRGB(45, 45, 55)
    s2.Thickness = 1

    b2.MouseButton1Click:Connect(function()
        b2.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        task.wait(0.1)
        b2.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
        if cb2 then task.spawn(cb2) end
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
-- REGISTER FEATURES INTO JUNEJO UI 1
--========================================================--

-- SECTION 1: MOVEMENT & MODIFIERS
CreateSectionLabel("Movement & Powers", 1)

-- 1. Player Flight
CreateSpeedRow("Player Flight", 50, 2, function(active, value)
    State.Flight = active
    State.FlightSpeed = value
    local char = LocalPlayer.Character
    if active and char and char:FindFirstChild("HumanoidRootPart") then
        flyBodyVel = Instance.new("BodyVelocity", char.HumanoidRootPart)
        flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBodyGyro = Instance.new("BodyGyro", char.HumanoidRootPart)
        flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBodyGyro.P = 10000
    else
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
    end
end, function(value)
    State.FlightSpeed = value
end)

-- 2. Fast WalkSpeed
CreateSpeedRow("WalkSpeed", 45, 3, function(active, value)
    State.WalkSpeed = active
    State.WalkSpeedValue = value
    if not active and isAlive() then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end, function(value)
    State.WalkSpeedValue = value
end)

-- 3. Noclip
CreateToggleRow("Noclip", false, 4, function(state)
    State.Noclip = state
end)

-- 4. Infinite Jump
CreateToggleRow("Infinite Jump", false, 5, function(state)
    State.InfiniteJump = state
end)

-- 5. Shift Dash
CreateToggleRow("Shift Dash", false, 6, function(state)
    State.ShiftDash = state
end)

-- 6. Ghost Invisibility
CreateToggleRow("Ghost Invisibility", false, 7, function(state)
    State.Invisibility = state
    toggleInvisibility(state)
end)

-- SECTION 2: VISUALS
CreateSectionLabel("Visuals & ESP", 8)

-- 7. Player ESP
CreateToggleRow("Player Box ESP", false, 9, function(state)
    State.ESPEnabled = state
end)

-- SECTION 3: TELEPORTATION
CreateSectionLabel("Teleports (Locations)", 10)

-- 8. Return to Previous
CreateActionButton("↩ Return to Previous Location", 11, function()
    if State.PreviousLocation and isAlive() then
        local char = LocalPlayer.Character
        char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        char:PivotTo(State.PreviousLocation)
    end
end)

-- 9. Dual Buttons for POIs
CreateDualActionButtons("Bank", function() teleportTo(Locations["Bank"]) end,
                       "Jewelry Store", function() teleportTo(Locations["Jewelry Store"]) end, 12)

CreateDualActionButtons("Museum", function() teleportTo(Locations["Museum"]) end,
                       "Casino", function() teleportTo(Locations["Casino"]) end, 13)

CreateDualActionButtons("Volcano Base", function() teleportTo(Locations["Volcano Base"]) end,
                       "City Base", function() teleportTo(Locations["City Base"]) end, 14)
