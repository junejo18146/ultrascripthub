-- Jump for Animals | Verified Route & Safe Auto-Train Edition
-- Integrated Teleport Sidebar Tab, Safe Waypoint Recorder, Floating Toggle & Death-Proof Training

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("JumpForAnimalsHub") then
    CoreGui.JumpForAnimalsHub:Destroy()
end

_G.Settings = {
    AutoFarmEggs = false,
    AutoTrain = false,
    EggESP = false,
    PlayerESP = false,
    InstantPrompt = true,
    AntiAFK = true,
    NoClip = false,
    InfJump = false,
    Fly = false,
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50,
    PlotCFrame = nil,
    EggNestCFrame = nil,
    TrainCFrame = nil
}

local function isAlive()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end

local function hasEggCarried()
    if not isAlive() then return false end
    local char = LocalPlayer.Character
    for _, obj in pairs(char:GetChildren()) do
        if obj:IsA("Tool") and obj.Name:lower():find("egg") then
            return true
        end
        if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("egg") then
            return true
        end
    end
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool.Name:lower():find("egg") then
            return true
        end
    end
    return false
end

local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration or 0)
        prompt:InputHoldEnd()
    end
end

local Screen = Instance.new("ScreenGui")
Screen.Name = "JumpForAnimalsHub"
Screen.ResetOnSpawn = false
Screen.Parent = CoreGui

local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.new(0, 45, 0, 45)
FloatingBtn.Position = UDim2.new(0, 15, 0.5, -22)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatingBtn.Text = "🐾"
FloatingBtn.TextSize = 22
FloatingBtn.Active = true
FloatingBtn.Parent = Screen
Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingBtn)
FloatStroke.Color = Color3.fromRGB(30, 237, 93)
FloatStroke.Thickness = 2

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 320)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = Screen
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local function enableDrag(frame, target)
    target = target or frame
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

enableDrag(FloatingBtn)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local GameTitle = Instance.new("TextLabel")
GameTitle.Size = UDim2.new(1, 0, 0, 45)
GameTitle.BackgroundTransparency = 1
GameTitle.Text = "  Jump for Animals"
GameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
GameTitle.Font = Enum.Font.GothamBold
GameTitle.TextSize = 12
GameTitle.TextXAlignment = Enum.TextXAlignment.Left
GameTitle.Active = true
GameTitle.Parent = Sidebar

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, -130, 0, 35)
TopBar.Position = UDim2.new(0, 130, 0, 0)
TopBar.BackgroundTransparency = 1
TopBar.Active = true
TopBar.Parent = MainFrame

enableDrag(TopBar, MainFrame)
enableDrag(GameTitle, MainFrame)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local ProfileText = Instance.new("TextLabel")
ProfileText.Size = UDim2.new(0, 120, 1, 0)
ProfileText.Position = UDim2.new(1, -165, 0, 0)
ProfileText.BackgroundTransparency = 1
ProfileText.Text = LocalPlayer.Name .. " | PRO"
ProfileText.TextColor3 = Color3.fromRGB(200, 200, 200)
ProfileText.Font = Enum.Font.Gotham
ProfileText.TextSize = 12
ProfileText.TextXAlignment = Enum.TextXAlignment.Right
ProfileText.Parent = TopBar

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -140, 1, -45)
ContentArea.Position = UDim2.new(0, 140, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Tabs = {}
local TabButtons = {}

local function CreateTab(name, isDefault)
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = isDefault
    TabFrame.Parent = ContentArea

    local Left = Instance.new("Frame", TabFrame)
    Left.Size = UDim2.new(0.5, -4, 1, 0)
    Left.BackgroundTransparency = 1
    local LeftLayout = Instance.new("UIListLayout", Left)
    LeftLayout.Padding = UDim.new(0, 6)

    local Right = Instance.new("Frame", TabFrame)
    Right.Size = UDim2.new(0.5, -4, 1, 0)
    Right.Position = UDim2.new(0.5, 4, 0, 0)
    Right.BackgroundTransparency = 1
    local RightLayout = Instance.new("UIListLayout", Right)
    RightLayout.Padding = UDim.new(0, 6)

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -16, 0, 28)
    TabBtn.Position = UDim2.new(0, 8, 0, 50 + (#TabButtons * 34))
    TabBtn.BackgroundColor3 = isDefault and Color3.fromRGB(30, 237, 93) or Color3.fromRGB(25, 25, 25)
    TabBtn.Text = "  " .. name
    TabBtn.TextColor3 = isDefault and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 11
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    table.insert(Tabs, TabFrame)
    table.insert(TabButtons, TabBtn)

    TabBtn.MouseButton1Click:Connect(function()
        for i, t in ipairs(Tabs) do
            t.Visible = (t == TabFrame)
            TabButtons[i].BackgroundColor3 = (t == TabFrame) and Color3.fromRGB(30, 237, 93) or Color3.fromRGB(25, 25, 25)
            TabButtons[i].TextColor3 = (t == TabFrame) and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
        end
    end)

    return Left, Right
end

local function CreateToggle(parent, title, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 38)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 40, 0, 20)
    Btn.Position = UDim2.new(1, -48, 0.5, -10)
    Btn.BackgroundColor3 = default and Color3.fromRGB(30, 237, 93) or Color3.fromRGB(50, 50, 50)
    Btn.Text = default and "ON" or "OFF"
    Btn.TextColor3 = default and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Btn.Parent = Container
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(30, 237, 93) or Color3.fromRGB(50, 50, 50)
        Btn.Text = state and "ON" or "OFF"
        Btn.TextColor3 = state and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
        callback(state)
    end)
end

local function CreateButton(parent, title, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 38)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 1, -10)
    Btn.Position = UDim2.new(0, 10, 0, 5)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Btn.Text = title
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.Parent = Container
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    Btn.MouseButton1Click:Connect(function()
        callback(Btn)
    end)
end

local function CreateSlider(parent, title, min, max, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 48)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 0.5, 0)
    Label.Position = UDim2.new(0, 10, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0.5, 0)
    ValueLabel.Position = UDim2.new(1, -58, 0, 4)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.TextSize = 11
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Container

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -20, 0, 4)
    Track.Position = UDim2.new(0, 10, 0.7, 2)
    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Track.Parent = Container
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(30, 237, 93)
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 10)
    Btn.Position = UDim2.new(0, 0, 0, -5)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Track

    local draggingSlider = false
    Btn.MouseButton1Down:Connect(function() draggingSlider = true end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UIS:GetMouseLocation().X
            local trackPos = Track.AbsolutePosition.X
            local trackSize = Track.AbsoluteSize.X
            local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            local val = math.floor(min + (max - min) * percent)
            ValueLabel.Text = tostring(val)
            callback(val)
        end
    end)
end

local MainLeft, MainRight = CreateTab("Main Farm", true)
local TPLeft, TPRight = CreateTab("Teleport", false)
local PlayerLeft, PlayerRight = CreateTab("Player", false)
local VisualsLeft, VisualsRight = CreateTab("Visuals", false)
local MiscLeft, MiscRight = CreateTab("Misc", false)

-- [ MAIN FARM ]
CreateToggle(MainLeft, "Auto Steal Loop", false, function(state) _G.Settings.AutoFarmEggs = state end)
CreateToggle(MainLeft, "Auto Train", false, function(state) _G.Settings.AutoTrain = state end)

CreateButton(MainRight, "Record Base / Plot", function(btn)
    if isAlive() then
        _G.Settings.PlotCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        btn.Text = "Base Recorded!"
        task.delay(1.5, function() btn.Text = "Record Base / Plot" end)
    end
end)

CreateButton(MainRight, "Record Egg Nest", function(btn)
    if isAlive() then
        _G.Settings.EggNestCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        btn.Text = "Nest Recorded!"
        task.delay(1.5, function() btn.Text = "Record Egg Nest" end)
    end
end)

CreateButton(MainRight, "Record Train Spot", function(btn)
    if isAlive() then
        _G.Settings.TrainCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        btn.Text = "Train Spot Set!"
        task.delay(1.5, function() btn.Text = "Record Train Spot" end)
    end
end)

-- [ TELEPORT TAB ]
CreateButton(TPLeft, "TP to Base", function()
    if isAlive() and _G.Settings.PlotCFrame then
        LocalPlayer.Character.HumanoidRootPart.CFrame = _G.Settings.PlotCFrame
    end
end)

CreateButton(TPLeft, "TP to Nest", function()
    if isAlive() and _G.Settings.EggNestCFrame then
        LocalPlayer.Character.HumanoidRootPart.CFrame = _G.Settings.EggNestCFrame
    end
end)

CreateButton(TPLeft, "TP to Training Spot", function()
    if isAlive() and _G.Settings.TrainCFrame then
        LocalPlayer.Character.HumanoidRootPart.CFrame = _G.Settings.TrainCFrame
    end
end)

CreateButton(TPRight, "Click-to-TP Tool", function()
    local tool = Instance.new("Tool")
    tool.RequiresHandle = false
    tool.Name = "Click Teleport"
    tool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        if isAlive() and mouse.Hit then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end)
    tool.Parent = LocalPlayer.Backpack
end)

-- [ PLAYER TAB ]
CreateToggle(PlayerLeft, "Infinite Jump", false, function(state) _G.Settings.InfJump = state end)
CreateToggle(PlayerLeft, "NoClip & De-Aggro", false, function(state) _G.Settings.NoClip = state end)
CreateToggle(PlayerLeft, "Fly Mode", false, function(state) _G.Settings.Fly = state end)

CreateSlider(PlayerRight, "WalkSpeed", 16, 250, 16, function(val) _G.Settings.WalkSpeed = val end)
CreateSlider(PlayerRight, "JumpPower", 50, 400, 50, function(val) _G.Settings.JumpPower = val end)
CreateSlider(PlayerRight, "Fly Speed", 20, 200, 50, function(val) _G.Settings.FlySpeed = val end)

-- [ VISUALS TAB ]
CreateToggle(VisualsLeft, "Egg Highlights", false, function(state)
    _G.Settings.EggESP = state
    if not state then
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "EggHighlight" then v:Destroy() end
        end
    end
end)

CreateToggle(VisualsRight, "Player ESP", false, function(state)
    _G.Settings.PlayerESP = state
    if not state then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("PlayerHighlight") then
                p.Character.PlayerHighlight:Destroy()
            end
        end
    end
end)

-- [ MISC TAB ]
CreateToggle(MiscLeft, "Instant Proximity", true, function(state) _G.Settings.InstantPrompt = state end)
CreateToggle(MiscLeft, "Anti-AFK", true, function(state) _G.Settings.AntiAFK = state end)

-- Egg Steal Route With Verification
task.spawn(function()
    while task.wait(0.5) do
        if _G.Settings.AutoFarmEggs and isAlive() then
            if _G.Settings.EggNestCFrame and _G.Settings.PlotCFrame then
                local hrp = LocalPlayer.Character.HumanoidRootPart

                if not hasEggCarried() then
                    hrp.CFrame = _G.Settings.EggNestCFrame
                    task.wait(0.3)

                    local pickAttempts = 0
                    repeat
                        for _, prompt in pairs(workspace:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and prompt.Parent then
                                local part = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                                if part and (part.Position - hrp.Position).Magnitude < 22 then
                                    triggerPrompt(prompt)
                                end
                            end
                        end
                        task.wait(0.2)
                        pickAttempts = pickAttempts + 1
                    until hasEggCarried() or pickAttempts > 15 or not _G.Settings.AutoFarmEggs or not isAlive()
                end

                if hasEggCarried() then
                    hrp.CFrame = _G.Settings.PlotCFrame
                    task.wait(0.3)

                    local dropAttempts = 0
                    repeat
                        for _, prompt in pairs(workspace:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and prompt.Parent then
                                local part = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                                if part and (part.Position - hrp.Position).Magnitude < 22 then
                                    local txt = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
                                    if txt:find("place") or txt:find("drop") or txt:find("deliver") or txt:find("deposit") or txt:find("hatch") then
                                        triggerPrompt(prompt)
                                    end
                                end
                            end
                        end
                        task.wait(0.2)
                        dropAttempts = dropAttempts + 1
                    until not hasEggCarried() or dropAttempts > 12 or not _G.Settings.AutoFarmEggs or not isAlive()
                    task.wait(0.4)
                end
            end
        end
    end
end)

-- Safe, Death-Proof Auto Train Loop
local isTeleportedToTrain = false

task.spawn(function()
    while task.wait(0.2) do
        if _G.Settings.AutoTrain and isAlive() then
            local char = LocalPlayer.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")

            if _G.Settings.TrainCFrame and not isTeleportedToTrain then
                if (hrp.Position - _G.Settings.TrainCFrame.Position).Magnitude > 5 then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.CFrame = _G.Settings.TrainCFrame * CFrame.new(0, 3, 0)
                    task.wait(0.4)
                end
                isTeleportedToTrain = true
            end

            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then
                for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and not t.Name:lower():find("egg") then
                        hum:EquipTool(t)
                        tool = t
                        task.wait(0.2)
                        break
                    end
                end
            end

            if tool then
                tool:Activate()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(500, 500))
                task.wait(0.05)
                VirtualUser:Button1Up(Vector2.new(500, 500))
            end
        else
            isTeleportedToTrain = false
        end
    end
end)

-- Instant Proximity & Distance Hook
RunService.Stepped:Connect(function()
    if _G.Settings.InstantPrompt then
        for _, prompt in pairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0
                prompt.MaxActivationDistance = 25
            end
        end
    end
end)

-- ESP Rendering
RunService.RenderStepped:Connect(function()
    if _G.Settings.EggESP then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("egg") and not obj:FindFirstChild("EggHighlight") then
                local h = Instance.new("Highlight")
                h.Name = "EggHighlight"
                h.FillColor = Color3.fromRGB(30, 237, 93)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.Parent = obj
            end
        end
    end

    if _G.Settings.PlayerESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("PlayerHighlight") then
                local h = Instance.new("Highlight")
                h.Name = "PlayerHighlight"
                h.FillColor = Color3.fromRGB(255, 50, 50)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.Parent = p.Character
            end
        end
    end
end)

-- Movement & NoClip Overrides
RunService.Stepped:Connect(function()
    if isAlive() then
        if _G.Settings.WalkSpeed > 16 then
            LocalPlayer.Character.Humanoid.WalkSpeed = _G.Settings.WalkSpeed
        end
        if _G.Settings.JumpPower > 50 then
            LocalPlayer.Character.Humanoid.JumpPower = _G.Settings.JumpPower
        end
        if _G.Settings.NoClip then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.CanTouch = false
                end
            end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if _G.Settings.InfJump and isAlive() then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Flight Mechanics
local bv, bg
RunService.RenderStepped:Connect(function()
    if _G.Settings.Fly and isAlive() then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local cam = workspace.CurrentCamera

        if not bv or not bv.Parent then
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Parent = hrp
        end
        if not bg or not bg.Parent then
            bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            bg.P = 10000
            bg.Parent = hrp
        end

        local moveDir = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + (cam.CFrame.LookVector) end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - (cam.CFrame.LookVector) end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - (cam.CFrame.RightVector) end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + (cam.CFrame.RightVector) end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        bv.Velocity = moveDir.Unit * _G.Settings.FlySpeed
        bg.CFrame = cam.CFrame
        if moveDir.Magnitude == 0 then bv.Velocity = Vector3.new(0, 0, 0) end
    else
        if bv then bv:Destroy(); bv = nil end
        if bg then bg:Destroy(); bg = nil end
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if _G.Settings.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)
