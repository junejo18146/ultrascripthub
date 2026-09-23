-- ==============================================================================
-- JUNEJO ULTRA SCRIPT HUB - STEAL AN EGG
-- Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- UI Framework: UI 1 (Official Ultra Script Hub Classic Matte Dark)
-- Universal Mobile & PC Delta / Codex / Fluxus / PC Optimized
-- ==============================================================================

local GameName = "STEAL AN EGG"

-- ==============================================================================
-- 1. SERVICES & VARIABLES
-- ==============================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera

-- Anti-AFK Engine
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)
LocalPlayer.Idled:Connect(function()
    if VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

local State = {
    AutoSteal = false,
    AutoTreadmill = false,
    AutoHatch = false,
    RemoveGuards = false,
    ESP = false,
    FlyMode = false,
    FlySpeed = 60,
    WalkSpeedBoost = false,
    WalkSpeed = 50,
    NoClip = false,
    InfiniteJump = false
}

local SavedBaseCFrame = nil
local cachedTreadmill = nil

-- Character Helper Functions
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

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

-- Helper: Trigger Proximity Prompts Instant
local function triggerPrompt(prompt)
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

-- Base Position Auto-Saver
task.spawn(function()
    task.wait(0.5)
    local root = getRoot()
    if root and not SavedBaseCFrame then
        SavedBaseCFrame = root.CFrame
    end
end)

-- Safe Teleport to Base
local function teleportToBase()
    local root = getRoot()
    if root and SavedBaseCFrame then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = SavedBaseCFrame + Vector3.new(0, 2, 0)
    end
end

-- ==============================================================================
-- 2. BACKGROUND FEATURE LOOPS
-- ==============================================================================

-- 1. Auto Steal & Safe Teleport Engine
task.spawn(function()
    while true do
        task.wait(0.2)
        if State.AutoSteal then
            pcall(function()
                local root = getRoot()
                if root then
                    if not SavedBaseCFrame then
                        SavedBaseCFrame = root.CFrame
                    end

                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not State.AutoSteal then break end
                        if obj:IsA("ProximityPrompt") then
                            local parentName = string.lower(obj.Parent and obj.Parent.Name or "")
                            local actionText = string.lower(obj.ActionText or "")
                            local objText = string.lower(obj.ObjectText or "")

                            if string.find(parentName, "egg") or string.find(actionText, "steal") or string.find(actionText, "take") or string.find(objText, "egg") then
                                local eggPart = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                                if eggPart then
                                    root.AssemblyLinearVelocity = Vector3.zero
                                    root.CFrame = eggPart.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.1)
                                    triggerPrompt(obj)
                                    task.wait(0.12)
                                    if SavedBaseCFrame then
                                        root.AssemblyLinearVelocity = Vector3.zero
                                        root.CFrame = SavedBaseCFrame + Vector3.new(0, 1.5, 0)
                                    end
                                    task.wait(0.2)
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        else
            task.wait(0.3)
        end
    end
end)

-- 2. Bulletproof Auto Treadmill Engine (Physical Lock + Motion + Remote Sync)
local function findTreadmillPart()
    if cachedTreadmill and cachedTreadmill.Parent then
        return cachedTreadmill
    end

    -- 1. Search near player / in Bases
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("BasePart") then
            local n = desc.Name:lower()
            if n == "treadmill" or n:find("treadmill") or n == "speedpad" or n:find("speedpad") or n:find("speed_pad") or n == "trainpad" then
                cachedTreadmill = desc
                return desc
            end
        end
    end

    -- 2. Search TouchTransmitters
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("TouchTransmitter") and desc.Parent and desc.Parent:IsA("BasePart") then
            local pName = desc.Parent.Name:lower()
            if pName:find("tread") or pName:find("train") or pName:find("speed") then
                cachedTreadmill = desc.Parent
                return desc.Parent
            end
        end
    end

    return nil
end

task.spawn(function()
    while true do
        task.wait(0.15)
        if State.AutoTreadmill and not State.AutoSteal then
            pcall(function()
                local root = getRoot()
                local hum = getHum()
                if root and hum then
                    local tm = findTreadmillPart()
                    if tm and tm:IsA("BasePart") then
                        -- Position character directly on treadmill pad
                        local targetCF = tm.CFrame + Vector3.new(0, 2.5, 0)
                        if (root.Position - tm.Position).Magnitude > 6 then
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.CFrame = targetCF
                        end

                        -- Trigger touch interaction
                        if firetouchinterest then
                            pcall(function()
                                firetouchinterest(tm, root, 0)
                                task.wait()
                                firetouchinterest(tm, root, 1)
                            end)
                        end

                        -- Simulate slight motion so game detects movement on treadmill
                        pcall(function()
                            hum:Move(Vector3.new(0, 0, -1), true)
                        end)
                    end

                    -- Fire all speed/train remotes across ReplicatedStorage
                    for _, container in ipairs({ReplicatedStorage, LocalPlayer:FindFirstChild("PlayerGui")}) do
                        if container then
                            for _, remote in ipairs(container:GetDescendants()) do
                                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                    local rName = string.lower(remote.Name)
                                    if string.find(rName, "train") or string.find(rName, "treadmill") or string.find(rName, "addspeed") or string.find(rName, "speed") or string.find(rName, "velocity") then
                                        pcall(function()
                                            if remote:IsA("RemoteEvent") then
                                                remote:FireServer()
                                                remote:FireServer(true)
                                            else
                                                remote:InvokeServer()
                                                remote:InvokeServer(true)
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            task.wait(0.4)
        end
    end
end)

-- 3. Auto Hatch & Place Engine
task.spawn(function()
    while true do
        task.wait(0.4)
        if State.AutoHatch then
            pcall(function()
                for _, container in ipairs({ReplicatedStorage, LocalPlayer:FindFirstChild("PlayerGui"), Workspace}) do
                    if container then
                        for _, remote in ipairs(container:GetDescendants()) do
                            if not State.AutoHatch then break end
                            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                local rName = string.lower(remote.Name)
                                if string.find(rName, "hatch") or string.find(rName, "place") or string.find(rName, "openegg") or string.find(rName, "egghatch") then
                                    pcall(function()
                                        if remote:IsA("RemoteEvent") then
                                            remote:FireServer()
                                            remote:FireServer(true)
                                            remote:FireServer(1)
                                        else
                                            remote:InvokeServer()
                                            remote:InvokeServer(true)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not State.AutoHatch then break end
                    if obj:IsA("ProximityPrompt") then
                        local aText = string.lower(obj.ActionText or "")
                        local oText = string.lower(obj.ObjectText or "")
                        if string.find(aText, "hatch") or string.find(aText, "place") or string.find(oText, "hatch") then
                            triggerPrompt(obj)
                        end
                    end
                end
            end)
        else
            task.wait(0.5)
        end
    end
end)

-- 4. Remove Guards, Hazards & Lasers Engine
local function isHazardOrGuard(obj)
    if not obj or obj == LocalPlayer.Character then return false end

    -- Check Guard NPC Models
    if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
        if not Players:GetPlayerFromCharacter(obj) then
            local n = obj.Name:lower()
            if n:find("guard") or n:find("cop") or n:find("npc") or n:find("enemy") or n:find("bot") or n == "model" or n:find("security") then
                return true
            end
        end
    end

    -- Check Lasers, Traps, Killparts
    if obj:IsA("BasePart") then
        local n = obj.Name:lower()
        if n:find("laser") or n:find("kill") or n:find("barrier") or n:find("spike") or n:find("trap") or n:find("death") or n:find("danger") then
            return true
        end
    end

    return false
end

local function cleanHazards()
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if isHazardOrGuard(desc) then
            pcall(function()
                if desc:IsA("Model") then
                    desc:PivotTo(CFrame.new(0, -9999, 0))
                    desc:Destroy()
                elseif desc:IsA("BasePart") then
                    desc.CanCollide = false
                    desc.CanTouch = false
                    desc.Transparency = 1
                end
            end)
        end
    end
end

task.spawn(function()
    while true do
        if State.RemoveGuards then
            pcall(cleanHazards)
            task.wait(0.5)
        else
            task.wait(0.8)
        end
    end
end)

Workspace.DescendantAdded:Connect(function(desc)
    if State.RemoveGuards and isHazardOrGuard(desc) then
        task.wait(0.05)
        pcall(function()
            if desc:IsA("Model") then
                desc:PivotTo(CFrame.new(0, -9999, 0))
                desc:Destroy()
            elseif desc:IsA("BasePart") then
                desc.CanCollide = false
                desc.CanTouch = false
                desc.Transparency = 1
            end
        end)
    end
end)

-- 5. ESP System (Gold Egg ESP & Red Player ESP)
local function applyESP(target, color)
    if not target or target:FindFirstChild("UltraHub_ESP") then return end
    pcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = "UltraHub_ESP"
        hl.FillColor = color
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0
        hl.Adornee = target
        hl.Parent = target
    end)
end

local function clearESP()
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name == "UltraHub_ESP" and desc:IsA("Highlight") then
            desc:Destroy()
        end
    end
end

task.spawn(function()
    while true do
        if State.ESP then
            pcall(function()
                -- 1. Player ESP
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        applyESP(player.Character, Color3.fromRGB(255, 60, 60))
                    end
                end

                -- 2. Egg ESP
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not State.ESP then break end
                    local n = obj.Name:lower()
                    if (n:find("egg") or n:find("nest")) and (obj:IsA("Model") or obj:IsA("BasePart")) then
                        if not obj:FindFirstChild("UltraHub_ESP") and not obj:IsDescendantOf(LocalPlayer.Character) then
                            applyESP(obj, Color3.fromRGB(255, 215, 0))
                        end
                    end
                end
            end)
            task.wait(2)
        else
            task.wait(0.6)
        end
    end
end)

-- 6. Fly System (Mobile Touch & PC Keyboard Compatible)
local flyBodyVel = nil
local flyBodyGyro = nil

local function startFlying()
    local root = getRoot()
    if not root then return end

    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVel.Velocity = Vector3.new(0, 0, 0)
    flyBodyVel.Parent = root

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.P = 10000
    flyBodyGyro.CFrame = root.CFrame
    flyBodyGyro.Parent = root

    task.spawn(function()
        while State.FlyMode and flyBodyVel and flyBodyGyro do
            local currentRoot = getRoot()
            local hum = getHum()
            if not currentRoot or not hum then break end

            local moveDir = hum.MoveDirection
            local camCF = Camera.CFrame
            flyBodyGyro.CFrame = camCF

            if moveDir.Magnitude > 0 then
                flyBodyVel.Velocity = camCF.LookVector * State.FlySpeed
            else
                flyBodyVel.Velocity = Vector3.new(0, 0, 0)
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                flyBodyVel.Velocity = flyBodyVel.Velocity + Vector3.new(0, State.FlySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                flyBodyVel.Velocity = flyBodyVel.Velocity - Vector3.new(0, State.FlySpeed, 0)
            end

            task.wait()
        end

        if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    end)
end

local function stopFlying()
    if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

-- 7. Movement Hacks (NoClip, Infinite Jump, WalkSpeed)
RunService.Stepped:Connect(function()
    if State.NoClip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        pcall(function()
            local hum = getHum()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

local function UpdateCharacterSpeed()
    pcall(function()
        local hum = getHum()
        if hum then
            if State.WalkSpeedBoost then
                hum.WalkSpeed = State.WalkSpeed
            else
                hum.WalkSpeed = 16
            end
        end
    end)
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        local hum = getHum()
        if hum and State.WalkSpeedBoost and State.WalkSpeed then
            if hum.WalkSpeed ~= State.WalkSpeed then
                hum.WalkSpeed = State.WalkSpeed
            end
        end
    end)
end)

-- ==============================================================================
-- 3. JUNEJO OFFICIAL UI 1 - CLASSIC MATTE DARK INTERFACE
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_StealAnEgg"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local guiParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = guiParent

-- Main Window Frame (Matte Black Compact Container)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 310)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -155)
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

-- Draggable Logic (Mobile Touch & PC Mouse)
local dragging, dragInput, dragStart, startPos
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

-- 1. Header Frame
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = GameName
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
    stopFlying()
    clearESP()
    ScreenGui:Destroy()
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- 2. Scrollable Content Container
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -74)
ContentFrame.Position = UDim2.new(0, 10, 0, 36)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper Function: Action Button
local function AddActionButton(text, callback)
    local BtnFrame = Instance.new("Frame")
    BtnFrame.Size = UDim2.new(1, 0, 0, 26)
    BtnFrame.BackgroundTransparency = 1
    BtnFrame.Parent = ContentFrame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = BtnFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(40, 40, 50) }):Play()
        task.delay(0.12, function()
            TweenService:Create(Btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(27, 27, 32) }):Play()
        end)
        if callback then callback() end
    end)
end

-- Helper Function: Flat Toggle Row
local function AddToggleRow(text, stateKey, callback)
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
    Label.Position = UDim2.new(0, 4, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local CheckBox = Instance.new("Frame")
    CheckBox.Size = UDim2.new(0, 18, 0, 18)
    CheckBox.Position = UDim2.new(1, -20, 0.5, -9)
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
    CheckMark.BackgroundTransparency = State[stateKey] and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox

    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark

    RowBtn.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        CheckMark.BackgroundTransparency = State[stateKey] and 0 or 1
        if callback then
            callback(State[stateKey])
        end
    end)
end

-- ==============================================================================
-- BUILD FEATURE ROWS
-- ==============================================================================

-- 1. Action Button: Teleport to Base
AddActionButton("Teleport to My Base", function()
    teleportToBase()
end)

-- 2. Auto Steal & Return
AddToggleRow("Auto Steal & Return", "AutoSteal", function(state)
    if state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

-- 3. Auto Treadmill Train (Smart)
AddToggleRow("Auto Treadmill Train", "AutoTreadmill")

-- 4. Auto Hatch & Place
AddToggleRow("Auto Hatch & Place", "AutoHatch")

-- 5. Remove Guards & Lasers
AddToggleRow("Remove Guards & Lasers", "RemoveGuards")

-- 6. Egg & Player ESP
AddToggleRow("Egg & Player ESP", "ESP", function(enabled)
    if not enabled then
        clearESP()
    end
end)

-- 7. Fly Mode Toggle
AddToggleRow("Fly Mode", "FlyMode", function(enabled)
    if enabled then
        startFlying()
    else
        stopFlying()
    end
end)

-- 8. Fly Speed Stepper Row
local FlySpeedRow = Instance.new("Frame")
FlySpeedRow.Size = UDim2.new(1, 0, 0, 23)
FlySpeedRow.BackgroundTransparency = 1
FlySpeedRow.Parent = ContentFrame

local FlySpeedLabel = Instance.new("TextLabel")
FlySpeedLabel.Size = UDim2.new(0.55, 0, 1, 0)
FlySpeedLabel.Position = UDim2.new(0, 4, 0, 0)
FlySpeedLabel.BackgroundTransparency = 1
FlySpeedLabel.Text = "Fly Speed"
FlySpeedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
FlySpeedLabel.TextSize = 12
FlySpeedLabel.Font = Enum.Font.GothamBold
FlySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
FlySpeedLabel.Parent = FlySpeedRow

local FlyControlFrame = Instance.new("Frame")
FlyControlFrame.Size = UDim2.new(0, 95, 0, 22)
FlyControlFrame.Position = UDim2.new(1, -97, 0.5, -11)
FlyControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
FlyControlFrame.BorderSizePixel = 0
FlyControlFrame.Parent = FlySpeedRow

local FlyCtrlCorner = Instance.new("UICorner")
FlyCtrlCorner.CornerRadius = UDim.new(0, 4)
FlyCtrlCorner.Parent = FlyControlFrame

local FlyCtrlStroke = Instance.new("UIStroke")
FlyCtrlStroke.Color = Color3.fromRGB(45, 45, 55)
FlyCtrlStroke.Thickness = 1
FlyCtrlStroke.Parent = FlyControlFrame

local FlyMinusBtn = Instance.new("TextButton")
FlyMinusBtn.Size = UDim2.new(0, 22, 1, 0)
FlyMinusBtn.BackgroundTransparency = 1
FlyMinusBtn.Text = "-"
FlyMinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
FlyMinusBtn.TextSize = 14
FlyMinusBtn.Font = Enum.Font.GothamBold
FlyMinusBtn.Parent = FlyControlFrame

local FlySpeedDisplay = Instance.new("TextLabel")
FlySpeedDisplay.Size = UDim2.new(1, -44, 1, 0)
FlySpeedDisplay.Position = UDim2.new(0, 22, 0, 0)
FlySpeedDisplay.BackgroundTransparency = 1
FlySpeedDisplay.Text = tostring(State.FlySpeed)
FlySpeedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
FlySpeedDisplay.TextSize = 11
FlySpeedDisplay.Font = Enum.Font.GothamBold
FlySpeedDisplay.Parent = FlyControlFrame

local FlyPlusBtn = Instance.new("TextButton")
FlyPlusBtn.Size = UDim2.new(0, 22, 1, 0)
FlyPlusBtn.Position = UDim2.new(1, -22, 0, 0)
FlyPlusBtn.BackgroundTransparency = 1
FlyPlusBtn.Text = "+"
FlyPlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
FlyPlusBtn.TextSize = 14
FlyPlusBtn.Font = Enum.Font.GothamBold
FlyPlusBtn.Parent = FlyControlFrame

FlyMinusBtn.MouseButton1Click:Connect(function()
    State.FlySpeed = math.max(20, State.FlySpeed - 10)
    FlySpeedDisplay.Text = tostring(State.FlySpeed)
end)

FlyPlusBtn.MouseButton1Click:Connect(function()
    State.FlySpeed = math.min(250, State.FlySpeed + 10)
    FlySpeedDisplay.Text = tostring(State.FlySpeed)
end)

-- 9. WalkSpeed Row (Dual Toggle Checkbox + Stepper Pill)
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, 0, 0, 23)
SpeedRow.BackgroundTransparency = 1
SpeedRow.Parent = ContentFrame

local SpeedToggleBtn = Instance.new("TextButton")
SpeedToggleBtn.Size = UDim2.new(0.55, 0, 1, 0)
SpeedToggleBtn.BackgroundTransparency = 1
SpeedToggleBtn.Text = ""
SpeedToggleBtn.ZIndex = 5
SpeedToggleBtn.Parent = SpeedRow

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -28, 1, 0)
SpeedLabel.Position = UDim2.new(0, 4, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed"
SpeedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedToggleBtn

local SpeedCheckBox = Instance.new("Frame")
SpeedCheckBox.Size = UDim2.new(0, 18, 0, 18)
SpeedCheckBox.Position = UDim2.new(1, -20, 0.5, -9)
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
SpeedCheckMark.BackgroundTransparency = State.WalkSpeedBoost and 0 or 1
SpeedCheckMark.BorderSizePixel = 0
SpeedCheckMark.Parent = SpeedCheckBox

local SpeedMarkCorner = Instance.new("UICorner")
SpeedMarkCorner.CornerRadius = UDim.new(0, 2)
SpeedMarkCorner.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    State.WalkSpeedBoost = not State.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = State.WalkSpeedBoost and 0 or 1
    UpdateCharacterSpeed()
end)

local SpeedControlFrame = Instance.new("Frame")
SpeedControlFrame.Size = UDim2.new(0, 95, 0, 22)
SpeedControlFrame.Position = UDim2.new(1, -97, 0.5, -11)
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
SpeedDisplay.Text = tostring(State.WalkSpeed)
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
    State.WalkSpeed = math.max(16, State.WalkSpeed - 15)
    SpeedDisplay.Text = tostring(State.WalkSpeed)
    UpdateCharacterSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    State.WalkSpeed = math.min(300, State.WalkSpeed + 15)
    SpeedDisplay.Text = tostring(State.WalkSpeed)
    UpdateCharacterSpeed()
end)

-- 10. No Clip Toggle
AddToggleRow("No Clip", "NoClip")

-- 11. Infinite Jump Toggle
AddToggleRow("Infinite Jump", "InfiniteJump")

-- ==============================================================================
-- 4. FOOTER FRAME (MANDATORY ULTRA SCRIPT HUB FOOTER)
-- ==============================================================================
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

print("[ULTRA SCRIPT HUB] Steal An Egg loaded successfully!")
