--==============================================================--
--  JUNEJO ULTRA SCRIPT HUB - OFFICIAL STANDALONE SCRIPT
--  Game: Anime Ability Arena (Roblox)
--  Version: 2.1 (Player ESP, Hitbox Expander, Safe Zone Teleport, Fly & Speed)
--  Branding: ULTRA SCRIPT HUB | Made by Junejo (junejo18146)
--==============================================================--

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera

local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

-- Feature Toggles & State
local Toggles = {
    PlayerESP = false,
    HitboxExpander = false,
    FlyMode = false,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

local CustomSpeedValue = 50
local NormalWalkSpeed = 16
local FlySpeed = 60
local Flying = false
local FlyBodyGyro, FlyBodyVel
local HitboxSize = Vector3.new(18, 18, 18)

-- Clean Old UI Instances
pcall(function()
    for _, name in ipairs({"JunejoHub_AnimeAbilityArena", "JunejoAnimeAbilityUI", "JunejoHubUI_AnimeAbility"}) do
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        local lpGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if lpGui and lpGui:FindFirstChild(name) then
            lpGui[name]:Destroy()
        end
    end
end)

-- Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    if VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

-- Character Helpers
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char.PrimaryPart
end

local function getHum()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- Find Safe Zone / Spawn CFrame
local function GetSafeZoneCFrame()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("safezone") or n:find("lobby") or n:find("spawn") or n:find("hub") then
                return obj.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end
    local spawnLoc = Workspace:FindFirstChildOfClass("SpawnLocation")
    if spawnLoc then
        return spawnLoc.CFrame + Vector3.new(0, 5, 0)
    end
    return CFrame.new(0, 35, 0)
end

local function TeleportToSafeZone()
    pcall(function()
        local root = getRoot()
        if root then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.CFrame = GetSafeZoneCFrame()
        end
    end)
end

-- WalkSpeed Multi-Layer Engine
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

RunService.RenderStepped:Connect(function()
    if Toggles.WalkSpeedBoost and CustomSpeedValue > 16 then
        pcall(function()
            local hum = getHum()
            if hum then
                hum.WalkSpeed = CustomSpeedValue
            end
        end)
    end
end)

RunService.Heartbeat:Connect(function()
    if Toggles.WalkSpeedBoost and CustomSpeedValue > 16 then
        pcall(function()
            local hum = getHum()
            local root = getRoot()
            if hum and root then
                if hum.WalkSpeed ~= CustomSpeedValue then
                    hum.WalkSpeed = CustomSpeedValue
                end
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    root.AssemblyLinearVelocity = Vector3.new(
                        moveDir.X * CustomSpeedValue,
                        root.AssemblyLinearVelocity.Y,
                        moveDir.Z * CustomSpeedValue
                    )
                end
            end
        end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    UpdateCharacterSpeed()
end)

-- Infinite Jump Engine
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        pcall(function()
            local hum = getHum()
            local root = getRoot()
            if hum and root then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                root.AssemblyLinearVelocity = Vector3.new(
                    root.AssemblyLinearVelocity.X,
                    50,
                    root.AssemblyLinearVelocity.Z
                )
            end
        end)
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
ScreenGui.Name = "JunejoHub_AnimeAbilityArena"
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

-- Floating Notification Toast
local ToastFrame = Instance.new("Frame")
ToastFrame.Name = "ToastFrame"
ToastFrame.Size = UDim2.new(0, 300, 0, 40)
ToastFrame.Position = UDim2.new(0.5, -150, 0, 18)
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
ToastLabel.Text = "Status Checking..."
ToastLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
ToastLabel.TextSize = 11
ToastLabel.Font = Enum.Font.GothamBold
ToastLabel.TextWrapped = true
ToastLabel.TextXAlignment = Enum.TextXAlignment.Left
ToastLabel.ZIndex = 101
ToastLabel.Parent = ToastFrame

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

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Anime Ability Arena",
            Text = msg,
            Duration = 3
        })
    end)

    if toastDismissTask then task.cancel(toastDismissTask) end
    toastDismissTask = task.delay(4, function()
        ToastFrame.Visible = false
    end)
end

-- Main Window Frame (280 x 245)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 245)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -122)
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
TitleLabel.Text = "ANIME ABILITY ARENA"
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
ContentFrame.Size = UDim2.new(1, -24, 0, 168)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- 1. Top Action: Teleport to Safe Zone Button
local SafeZoneBtn = Instance.new("TextButton")
SafeZoneBtn.Name = "SafeZoneBtn"
SafeZoneBtn.Size = UDim2.new(1, 0, 0, 24)
SafeZoneBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
SafeZoneBtn.BorderSizePixel = 0
SafeZoneBtn.Text = "TELEPORT TO SAFE ZONE"
SafeZoneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SafeZoneBtn.TextSize = 11
SafeZoneBtn.Font = Enum.Font.GothamBold
SafeZoneBtn.Parent = ContentFrame

local SafeZoneCorner = Instance.new("UICorner")
SafeZoneCorner.CornerRadius = UDim.new(0, 4)
SafeZoneCorner.Parent = SafeZoneBtn

local SafeZoneStroke = Instance.new("UIStroke")
SafeZoneStroke.Color = Color3.fromRGB(45, 45, 55)
SafeZoneStroke.Thickness = 1
SafeZoneStroke.Parent = SafeZoneBtn

SafeZoneBtn.MouseButton1Click:Connect(function()
    TeleportToSafeZone()
    SafeZoneBtn.Text = "TELEPORTED!"
    ShowScreenToast("Teleported to Safe Zone / Spawn!", true)
    task.delay(0.8, function()
        SafeZoneBtn.Text = "TELEPORT TO SAFE ZONE"
    end)
end)

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

-- 2. Player ESP Toggle
AddToggleRow("Player ESP", "PlayerESP", function(enabled)
    if enabled then
        ShowScreenToast("Player ESP Enabled!", true)
    else
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    if p.Character:FindFirstChild("JunejoESP_Highlight") then
                        p.Character.JunejoESP_Highlight:Destroy()
                    end
                    local head = p.Character:FindFirstChild("Head")
                    if head and head:FindFirstChild("JunejoESP_Tag") then
                        head.JunejoESP_Tag:Destroy()
                    end
                end
            end
        end)
    end
end)

-- 3. Hitbox Expander Toggle
AddToggleRow("Hitbox Expander", "HitboxExpander", function(enabled)
    if enabled then
        ShowScreenToast("Hitbox Expander Enabled (18x18 Studs)!", true)
    else
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.Size = Vector3.new(2, 2, 1)
                        root.Transparency = 1
                    end
                end
            end
        end)
    end
end)

-- 4. Fly Mode Toggle
AddToggleRow("Fly Mode", "FlyMode", function(enabled)
    if enabled then
        startFlying()
    else
        stopFlying()
    end
end)

-- 5. WalkSpeed Row with Pill Adjuster
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
-- 1. HITBOX EXPANDER (18x18 Studs Neon Red)
--==============================================================--
task.spawn(function()
    while true do
        if Toggles.HitboxExpander then
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local enemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        local enemyHum = player.Character:FindFirstChildOfClass("Humanoid")
                        if enemyRoot and enemyHum and enemyHum.Health > 0 then
                            enemyRoot.Size = HitboxSize
                            enemyRoot.Transparency = 0.65
                            enemyRoot.Color = Color3.fromRGB(255, 60, 60)
                            enemyRoot.Material = Enum.Material.Neon
                            enemyRoot.CanCollide = false
                        end
                    end
                end
            end)
            task.wait(0.4)
        else
            task.wait(1)
        end
    end
end)

--==============================================================--
-- 2. PLAYER ESP ENGINE (Highlight + Info Tag)
--==============================================================--
task.spawn(function()
    while true do
        if Toggles.PlayerESP then
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local char = player.Character
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        local head = char:FindFirstChild("Head")

                        if hum and hum.Health > 0 and head then
                            -- Highlight
                            local hl = char:FindFirstChild("JunejoESP_Highlight")
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = "JunejoESP_Highlight"
                                hl.FillColor = Color3.fromRGB(255, 50, 80)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.5
                                hl.OutlineTransparency = 0
                                hl.Parent = char
                            end

                            -- Billboard Tag
                            local bb = head:FindFirstChild("JunejoESP_Tag")
                            if not bb then
                                bb = Instance.new("BillboardGui")
                                bb.Name = "JunejoESP_Tag"
                                bb.Size = UDim2.new(0, 150, 0, 30)
                                bb.StudsOffset = Vector3.new(0, 2.5, 0)
                                bb.AlwaysOnTop = true
                                bb.Parent = head

                                local lbl = Instance.new("TextLabel")
                                lbl.Name = "ESPLabel"
                                lbl.Size = UDim2.new(1, 0, 1, 0)
                                lbl.BackgroundTransparency = 1
                                lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                                lbl.TextStrokeTransparency = 0
                                lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                lbl.TextSize = 11
                                lbl.Font = Enum.Font.GothamBold
                                lbl.Parent = bb
                            end

                            local myRoot = getRoot()
                            local dist = myRoot and math.floor((myRoot.Position - head.Position).Magnitude) or 0
                            local hp = math.floor((hum.Health / hum.MaxHealth) * 100)
                            local lbl = bb:FindFirstChild("ESPLabel")
                            if lbl then
                                lbl.Text = string.format("%s | %d HP | %dm", player.DisplayName, hp, dist)
                            end
                        end
                    end
                end
            end)
            task.wait(0.2)
        else
            task.wait(0.5)
        end
    end
end)

print("[ULTRA SCRIPT HUB] Anime Ability Arena Loaded Successfully!")

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "ULTRA SCRIPT HUB",
        Text = "Anime Ability Arena Ready! Made by Junejo",
        Duration = 5
    })
end)
