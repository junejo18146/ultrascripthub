--==============================================================--
--  JUNEJO ULTRA SCRIPT HUB - OFFICIAL STANDALONE SCRIPT
--  Game: Save Your Cat
--  Version: 5.0 (Smart Auto-Rebirth & Requirement Inspector, Inf Seed, Auto Button)
--  Branding: ULTRA SCRIPT HUB | Made by Junejo (junejo18146)
--==============================================================--

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

-- Feature Toggles & State
local Toggles = {
    InfSeed = false,
    AutoRebirth = false,
    AutoButton = false,
    FlyMode = false,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

local CustomSpeedValue = 50
local NormalWalkSpeed = 16
local FlySpeed = 60
local Flying = false
local FlyBodyGyro, FlyBodyVel

-- Clean Old UI Instances
pcall(function()
    if CoreGui and CoreGui:FindFirstChild("JunejoHub_SaveYourCat") then
        CoreGui:FindFirstChild("JunejoHub_SaveYourCat"):Destroy()
    end
    if CoreGui and CoreGui:FindFirstChild("UltraScriptHub_SaveYourCat") then
        CoreGui:FindFirstChild("UltraScriptHub_SaveYourCat"):Destroy()
    end
    local lpGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if lpGui then
        if lpGui:FindFirstChild("JunejoHub_SaveYourCat") then
            lpGui:FindFirstChild("JunejoHub_SaveYourCat"):Destroy()
        end
        if lpGui:FindFirstChild("UltraScriptHub_SaveYourCat") then
            lpGui:FindFirstChild("UltraScriptHub_SaveYourCat"):Destroy()
        end
    end
end)

-- Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    if VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

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

-- Universal Touch Simulation
local function safeTouch(part)
    if not part or not part:IsA("BasePart") then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = getRoot()
    local rLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightFoot") or root
    local lLeg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftFoot") or root

    pcall(function()
        if firetouchinterest then
            if root then
                firetouchinterest(root, part, 0)
                task.wait()
                firetouchinterest(root, part, 1)
            end
            if rLeg and rLeg ~= root then
                firetouchinterest(rLeg, part, 0)
                task.wait()
                firetouchinterest(rLeg, part, 1)
            end
            if lLeg and lLeg ~= root then
                firetouchinterest(lLeg, part, 0)
                task.wait()
                firetouchinterest(lLeg, part, 1)
            end
        end
    end)
end

-- Universal ProximityPrompt Trigger
local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.HoldDuration = 0
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
        else
            prompt:InputHoldBegin()
            task.wait(0.01)
            prompt:InputHoldEnd()
        end
    end)
end

-- Universal ClickDetector Simulation
local function safeClick(detector)
    if not detector or not detector:IsA("ClickDetector") then return end
    pcall(function()
        if fireclickdetector then
            fireclickdetector(detector)
        end
    end)
end

-- Universal GUI Button Click
local function clickGuiButton(btn)
    if not btn or not btn:IsA("GuiButton") then return end
    pcall(function()
        if getconnections then
            for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
            for _, conn in ipairs(getconnections(btn.Activated)) do conn:Fire() end
            for _, conn in ipairs(getconnections(btn.MouseButton1Down)) do conn:Fire() end
        end
    end)
end

-- Dynamic Remote Search
local function findRemotes(keywords)
    local found = {}
    local function search(parent)
        if not parent then return end
        for _, obj in ipairs(parent:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                for _, kw in ipairs(keywords) do
                    if name:find(kw:lower()) then
                        table.insert(found, obj)
                        break
                    end
                end
            end
        end
    end
    search(ReplicatedStorage)
    search(Workspace)
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then search(playerGui) end
    return found
end

-- Fast Auto Weapon Fire
local function fastAttack()
    local char = LocalPlayer.Character
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            local bTool = backpack:FindFirstChildOfClass("Tool")
            if bTool then
                bTool.Parent = char
                tool = bTool
            end
        end
    end

    if tool then
        pcall(function() tool:Activate() end)
    end

    if VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(500, 500))
        end)
    end
    if VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 0)
        end)
    end
end

-- WalkSpeed Engine
local function UpdateCharacterSpeed()
    local hum = getHum()
    if hum then
        if Toggles.WalkSpeedBoost then
            hum.WalkSpeed = CustomSpeedValue
        else
            hum.WalkSpeed = NormalWalkSpeed
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.6)
    UpdateCharacterSpeed()
end)

-- Infinite Jump Engine
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        local hum = getHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Smooth 3D Flight Engine
local function startFlying()
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return end

    Flying = true
    hum.PlatformStand = true

    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.CFrame = root.CFrame
    FlyBodyGyro.Parent = root

    FlyBodyVel = Instance.new("BodyVelocity")
    FlyBodyVel.Velocity = Vector3.new(0, 0, 0)
    FlyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVel.Parent = root

    task.spawn(function()
        while Flying and Toggles.FlyMode do
            RunService.RenderStepped:Wait()
            if not root or not FlyBodyGyro or not FlyBodyVel then break end
            
            FlyBodyGyro.CFrame = Camera.CFrame
            local direction = Vector3.new()

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + (Camera.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - (Camera.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - (Camera.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + (Camera.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            -- Mobile Touch / Thumbstick support
            if hum.MoveDirection.Magnitude > 0 and direction.Magnitude == 0 then
                direction = (Camera.CFrame.LookVector * hum.MoveDirection.Z * -1) + (Camera.CFrame.RightVector * hum.MoveDirection.X)
            end

            FlyBodyVel.Velocity = direction * FlySpeed
        end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if FlyBodyVel then FlyBodyVel:Destroy() end
        if hum then hum.PlatformStand = false end
        Flying = false
    end)
end

local function stopFlying()
    Flying = false
    if FlyBodyGyro then FlyBodyGyro:Destroy() end
    if FlyBodyVel then FlyBodyVel:Destroy() end
    local hum = getHum()
    if hum then hum.PlatformStand = false end
end

--==============================================================--
--  GUI CREATION (Official Junejo Ultra Script Hub Standard)
--==============================================================--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHub_SaveYourCat"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local parentGui = nil
if gethui then 
    pcall(function() parentGui = gethui() end) 
end
if not parentGui then 
    pcall(function() parentGui = CoreGui end) 
end
if not parentGui then 
    pcall(function()
        parentGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    end) 
end

pcall(function()
    ScreenGui.Parent = parentGui or CoreGui
end)
if not ScreenGui.Parent then
    pcall(function()
        ScreenGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end)
end

-- On-Screen Floating Notification Toast (Top-Center)
local ToastFrame = Instance.new("Frame")
ToastFrame.Name = "ToastFrame"
ToastFrame.Size = UDim2.new(0, 310, 0, 42)
ToastFrame.Position = UDim2.new(0.5, -155, 0, 18)
ToastFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
ToastFrame.BorderSizePixel = 0
ToastFrame.Visible = false
ToastFrame.ZIndex = 100
ToastFrame.Parent = ScreenGui

local ToastCorner = Instance.new("UICorner")
ToastCorner.CornerRadius = UDim.new(0, 8)
ToastCorner.Parent = ToastFrame

local ToastStroke = Instance.new("UIStroke")
ToastStroke.Color = Color3.fromRGB(45, 45, 58)
ToastStroke.Thickness = 1.2
ToastStroke.Parent = ToastFrame

local ToastIcon = Instance.new("TextLabel")
ToastIcon.Size = UDim2.new(0, 26, 1, 0)
ToastIcon.Position = UDim2.new(0, 8, 0, 0)
ToastIcon.BackgroundTransparency = 1
ToastIcon.Text = "ℹ️"
ToastIcon.TextSize = 14
ToastIcon.Font = Enum.Font.GothamBold
ToastIcon.ZIndex = 101
ToastIcon.Parent = ToastFrame

local ToastLabel = Instance.new("TextLabel")
ToastLabel.Size = UDim2.new(1, -42, 1, 0)
ToastLabel.Position = UDim2.new(0, 36, 0, 0)
ToastLabel.BackgroundTransparency = 1
ToastLabel.Text = "Rebirth Status Checking..."
ToastLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
ToastLabel.TextSize = 11
ToastLabel.Font = Enum.Font.GothamBold
ToastLabel.TextWrapped = true
ToastLabel.TextXAlignment = Enum.TextXAlignment.Left
ToastLabel.ZIndex = 101
ToastLabel.Parent = ToastFrame

local lastToastMsg = ""
local toastDismissTask = nil

local function ShowScreenToast(msg, isSuccess)
    if not ScreenGui or not ScreenGui.Parent then return end
    ToastLabel.Text = msg
    if isSuccess then
        ToastIcon.Text = "✅"
        ToastLabel.TextColor3 = Color3.fromRGB(80, 255, 140)
        ToastStroke.Color = Color3.fromRGB(40, 160, 80)
    else
        ToastIcon.Text = "⚠️"
        ToastLabel.TextColor3 = Color3.fromRGB(255, 190, 70)
        ToastStroke.Color = Color3.fromRGB(180, 120, 30)
    end
    ToastFrame.Visible = true

    -- Native Roblox Notification fallback
    if lastToastMsg ~= msg then
        lastToastMsg = msg
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = isSuccess and "Rebirth Ready / Success" or "Rebirth Requirement",
                Text = msg,
                Duration = 4
            })
        end)
    end

    if toastDismissTask then task.cancel(toastDismissTask) end
    toastDismissTask = task.delay(5, function()
        ToastFrame.Visible = false
    end)
end

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 238)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -119)
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

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "SAVE YOUR CAT"
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
CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 0, 160)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper function for Toggle Rows
local function AddToggleRow(text, configKey, callback)
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

-- 1. Inf Seed Toggle
AddToggleRow("Inf Seed", "InfSeed")

-- 2. Auto Rebirth Toggle
AddToggleRow("Auto Rebirth", "AutoRebirth", function(enabled)
    if enabled then
        ShowScreenToast("Auto Rebirth Activated! Checking Requirements...", false)
    else
        ToastFrame.Visible = false
    end
end)

-- 3. Auto Button Toggle
AddToggleRow("Auto Button", "AutoButton")

-- 4. Fly Mode Toggle
AddToggleRow("Fly Mode", "FlyMode", function(enabled)
    if enabled then
        startFlying()
    else
        stopFlying()
    end
end)

-- 5. Integrated WalkSpeed Row with Pill Adjuster
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
    CustomSpeedValue = math.max(16, CustomSpeedValue - 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(250, CustomSpeedValue + 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

-- 6. Infinite Jump Toggle
AddToggleRow("Infinite Jump", "InfiniteJump")

-- Footer
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
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

--==============================================================--
--  1. SUPER INSTANT INF SEED (Track Farm, Attack & Spawner Sweep)
--==============================================================--
task.spawn(function()
    while true do
        if Toggles.InfSeed then
            pcall(function()
                local root = getRoot()

                -- Fast Attack Spammer
                fastAttack()

                -- High-Speed Track & Seed Pickups Sweep
                if root then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not Toggles.InfSeed then break end
                        
                        if obj:IsA("BasePart") then
                            local n = obj.Name:lower()
                            local p = obj.Parent and obj.Parent.Name:lower() or ""
                            if n:find("seed") or n:find("drop") or n:find("collect") or n:find("arrow") or 
                               n:find("gem") or n:find("coin") or n:find("orb") or n:find("point") or
                               p:find("seed") or p:find("autorun") or p:find("track") or p:find("drop") then
                                safeTouch(obj)
                            end
                        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                            local adornee = obj.Adornee or obj.Parent
                            if adornee and adornee:IsA("BasePart") then
                                for _, txt in ipairs(obj:GetDescendants()) do
                                    if txt:IsA("TextLabel") and txt.Text:lower():find("seed") then
                                        safeTouch(adornee)
                                    end
                                end
                            end
                        elseif obj:IsA("ProximityPrompt") then
                            local act = (obj.ActionText .. " " .. obj.ObjectText):lower()
                            if act:find("seed") or act:find("harvest") or act:find("collect") or act:find("claim") or act:find("run") then
                                triggerPrompt(obj)
                            end
                        end
                    end
                end

                -- Fire All Seed, Dash & Attack Remotes
                local seedRemotes = findRemotes({
                    "seed", "seeds", "attack", "fire", "shoot", "hit", "dash", "run",
                    "giveseed", "addseed", "cat", "claim", "damage", "autorun", "farm", "drop"
                })
                for _, remote in ipairs(seedRemotes) do
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer()
                            remote:FireServer(1)
                            remote:FireServer(999999)
                            remote:FireServer(true)
                            remote:FireServer("Seed")
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer()
                            remote:InvokeServer(1)
                            remote:InvokeServer(999999)
                            remote:InvokeServer(true)
                        end
                    end)
                end
            end)
            task.wait(0.04)
        else
            task.wait(0.3)
        end
    end
end)

--==============================================================--
--  2. SMART AUTO REBIRTH & LIVE REQUIREMENT INSPECTOR
--==============================================================--
local lastRebirthCount = nil

-- Helper to inspect current player stats
local function GetPlayerStat(names)
    local function checkFolder(folder)
        if not folder then return nil end
        for _, n in ipairs(names) do
            local item = folder:FindFirstChild(n)
            if item then
                if item:IsA("IntValue") or item:IsA("NumberValue") or item:IsA("StringValue") then
                    return tonumber(item.Value) or item.Value
                end
            end
            for _, child in ipairs(folder:GetChildren()) do
                if child.Name:lower():find(n:lower()) then
                    if child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("StringValue") then
                        return tonumber(child.Value) or child.Value
                    end
                end
            end
        end
        return nil
    end

    local stats = checkFolder(LocalPlayer:FindFirstChild("leaderstats"))
    if stats then return stats end
    stats = checkFolder(LocalPlayer:FindFirstChild("Data"))
    if stats then return stats end
    stats = checkFolder(LocalPlayer:FindFirstChild("Stats"))
    if stats then return stats end

    for _, n in ipairs(names) do
        local attr = LocalPlayer:GetAttribute(n)
        if attr ~= nil then return attr end
    end
    return nil
end

-- Helper to scan Rebirth GUI requirements & text
local function ScanRebirthRequirements()
    local missingNotes = {}
    local currentSeeds = GetPlayerStat({"Seeds", "Seed", "Cash", "Money", "Points", "Power"})
    local currentRebirths = GetPlayerStat({"Rebirth", "Rebirths", "Stage", "Level", "Rank"})

    -- Scan UI frames for requirement indicators
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local foundGuiRequirement = nil
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                local txt = gui.Text
                local low = txt:lower()
                if (low:find("rebirth") or low:find("require") or low:find("need") or low:find("cost")) and not low:find("robux") and not low:find("ultra") then
                    if string.match(txt, "%d+") or low:find("seed") or low:find("reach") or low:find("pad") or low:find("end") then
                        foundGuiRequirement = txt
                    end
                end
            end
        end
    end

    -- Check Remaining Tycoon / Cleanup / Purchase buttons
    local unboughtButtonsCount = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            local p = obj.Parent and obj.Parent.Name:lower() or ""
            if (n:find("button") or n:find("cleanup") or n:find("pad") or p:find("tycoon")) and (n:find("buy") or n:find("unlock") or n:find("cleanup")) then
                unboughtButtonsCount = unboughtButtonsCount + 1
            end
        end
    end

    return currentSeeds, currentRebirths, foundGuiRequirement, unboughtButtonsCount
end

task.spawn(function()
    while true do
        if Toggles.AutoRebirth then
            pcall(function()
                local root = getRoot()
                local currentSeeds, currentRebirths, guiReq, unboughtCount = ScanRebirthRequirements()

                if lastRebirthCount == nil and currentRebirths ~= nil then
                    lastRebirthCount = tonumber(currentRebirths) or 0
                end

                -- Step A: Attempt Rebirth Execution (Remotes + Prompts + GUI Buttons)
                local rebirthRemotes = findRemotes({
                    "rebirth", "rebirths", "buyrebirth", "dorebirth", "requestrebirth", 
                    "catrebirth", "prestige", "evolve", "rankup", "upgradecat", "reset", "win"
                })
                
                local remoteFired = false
                for _, remote in ipairs(rebirthRemotes) do
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer()
                            remote:FireServer(1)
                            remote:FireServer(true)
                            remote:FireServer("Rebirth")
                            remoteFired = true
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer()
                            remote:InvokeServer(1)
                            remote:InvokeServer(true)
                            remoteFired = true
                        end
                    end)
                end

                -- Click Rebirth Buttons in PlayerGui
                local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                if playerGui then
                    for _, obj in ipairs(playerGui:GetDescendants()) do
                        if obj:IsA("GuiButton") and obj.Visible then
                            local name = obj.Name:lower()
                            local text = (obj:IsA("TextButton") and obj.Text:lower()) or ""
                            if (name:find("rebirth") or text:find("rebirth") or name:find("prestige") or text:find("prestige") or text:find("evolve")) and not name:find("robux") then
                                clickGuiButton(obj)
                            end
                        end
                    end
                end

                -- Step on Rebirth Pads / Prompts
                if root then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            local act = (obj.ActionText .. " " .. obj.ObjectText):lower()
                            if act:find("rebirth") or act:find("prestige") or act:find("rescue") or act:find("save") then
                                triggerPrompt(obj)
                            end
                        elseif obj:IsA("BasePart") then
                            local n = obj.Name:lower()
                            if n:find("rebirth") or n:find("prestige") or n:find("winpad") or n:find("endpad") then
                                safeTouch(obj)
                            end
                        end
                    end
                end

                -- Step B: Check Rebirth Success & Requirement Diagnostics
                task.wait(0.2)
                local newSeeds, newRebirths = ScanRebirthRequirements()

                local isReborn = false
                if lastRebirthCount ~= nil and newRebirths ~= nil and tonumber(newRebirths) and tonumber(newRebirths) > tonumber(lastRebirthCount) then
                    isReborn = true
                    lastRebirthCount = tonumber(newRebirths)
                end

                if isReborn then
                    ShowScreenToast("Reborn Successfully! Total Rebirths: " .. tostring(newRebirths), true)
                else
                    -- Format detailed missing requirement message
                    local statusMsg = ""
                    if guiReq then
                        statusMsg = "Requirement: " .. tostring(guiReq)
                    elseif unboughtCount > 0 then
                        statusMsg = "Need to clear " .. tostring(unboughtCount) .. " more Tycoon Buttons / Obstacles!"
                    elseif currentSeeds ~= nil then
                        statusMsg = "Current Seeds: " .. tostring(currentSeeds) .. " (Need more Seeds for Next Rebirth)"
                    else
                        statusMsg = "Rebirth Requirements not met! (Need more Seeds / Track Progress)"
                    end

                    ShowScreenToast(statusMsg, false)
                end
            end)
            task.wait(1.5)
        else
            task.wait(0.5)
        end
    end
end)

--==============================================================--
--  3. FULL AUTO-BUTTON & BASE TYCOON BUILDER
--==============================================================--
task.spawn(function()
    while true do
        if Toggles.AutoButton then
            pcall(function()
                local root = getRoot()
                if not root then return end

                local savedPos = root.CFrame

                -- Discover all Tycoon / Cleanup / Purchase Pads
                local buttonParts = {}
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoButton then break end

                    if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                        for _, txt in ipairs(obj:GetDescendants()) do
                            if txt:IsA("TextLabel") and txt.Text ~= "" then
                                local textLower = txt.Text:lower()
                                if textLower:find("cleanup") or textLower:find("buy") or textLower:find("unlock") or 
                                   textLower:find("cost") or textLower:find("%$") or string.match(txt.Text, "%d+") then
                                    local part = obj.Adornee or obj.Parent
                                    if part and part:IsA("BasePart") then
                                        table.insert(buttonParts, part)
                                    elseif part and part:IsA("Model") and part.PrimaryPart then
                                        table.insert(buttonParts, part.PrimaryPart)
                                    end
                                end
                            end
                        end
                    elseif obj:IsA("BasePart") then
                        local n = obj.Name:lower()
                        local p = obj.Parent and obj.Parent.Name:lower() or ""
                        if n:find("button") or n:find("pad") or n:find("buy") or n:find("upgrade") or 
                           n:find("unlock") or n:find("cleanup") or n:find("build") or 
                           p:find("button") or p:find("tycoon") or p:find("base") or p:find("pad") or p:find("plot") then
                            table.insert(buttonParts, obj)
                        end
                    elseif obj:IsA("ProximityPrompt") then
                        local act = (obj.ActionText .. " " .. obj.ObjectText):lower()
                        if act:find("buy") or act:find("build") or act:find("upgrade") or act:find("unlock") or act:find("button") or act:find("cleanup") then
                            triggerPrompt(obj)
                        end
                    elseif obj:IsA("ClickDetector") then
                        safeClick(obj)
                    end
                end

                -- Sort by distance
                local currentPos = root.Position
                table.sort(buttonParts, function(a, b)
                    return (a.Position - currentPos).Magnitude < (b.Position - currentPos).Magnitude
                end)

                -- Step on each Button Pad directly & trigger all purchases
                for _, btn in ipairs(buttonParts) do
                    if not Toggles.AutoButton then break end
                    if btn and btn.Parent and btn:IsA("BasePart") then
                        safeTouch(btn)
                        root.CFrame = CFrame.new(btn.Position + Vector3.new(0, 2.2, 0))
                        
                        local prompt = btn:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then triggerPrompt(prompt) end
                        local click = btn:FindFirstChildWhichIsA("ClickDetector", true)
                        if click then safeClick(click) end

                        task.wait(0.09)
                    end
                end

                -- Fire Button / Purchase Remotes
                local buttonRemotes = findRemotes({
                    "buybutton", "purchasebutton", "buy", "purchase", "build", 
                    "upgrade", "unlock", "place", "stepbutton", "touchbutton", "claimbutton", "cleanup"
                })
                for _, remote in ipairs(buttonRemotes) do
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer()
                            remote:FireServer(1)
                            remote:FireServer(true)
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer()
                            remote:InvokeServer(1)
                        end
                    end)
                end

                -- Return to original position
                if Toggles.AutoButton and savedPos and root then
                    root.CFrame = savedPos
                end
            end)
            task.wait(0.2)
        else
            task.wait(0.4)
        end
    end
end)

print("[ULTRA SCRIPT HUB] Save Your Cat v5.0 Loaded Successfully!")

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "ULTRA SCRIPT HUB",
        Text = "Save Your Cat v5.0 Ready! Made by Junejo",
        Duration = 5
    })
end)
