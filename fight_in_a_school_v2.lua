--[[
    JUNEJO ULTRA SCRIPT HUB - FIGHT IN A SCHOOL V2
    Target Game: Fight in a School (Roblox)
    Game Link: https://www.roblox.com/games/17698425045/fight-in-a-school
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11) - Flat Borderless Rows Standard
    Features Included:
        1. Player ESP (Red Glow Highlight + Distance & Name Overlays)
        2. Health Bar ESP (Live Dynamic HP Bar & Health Values)
        3. Noclip (Walk through school walls, doors & lockers)
        4. Fly Mode (Smooth 3D flight with WASD & Mobile Touch support)
        5. Auto Target (Auto snap & track nearest enemy player)
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

-- 5 Core Feature Toggles
local Toggles = {
    PlayerESP = false,
    HealthBarESP = false,
    Noclip = false,
    Fly = false,
    AutoTarget = false
}

-- Safe UI Parent resolver (Delta Mobile, Arceus X, Fluxus, Codex, PC)
local function GetSafeUIContainer()
    local container = nil
    
    pcall(function()
        if gethui then
            container = gethui()
        end
    end)
    
    if not container then
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
            if playerGui then
                container = playerGui
            end
        end)
    end
    
    if not container then
        pcall(function()
            if syn and syn.protect_gui then
                container = CoreGui
            end
        end)
    end
    
    if not container then
        pcall(function()
            container = CoreGui
        end)
    end
    
    return container or LocalPlayer:WaitForChild("PlayerGui")
end

local UIContainer = GetSafeUIContainer()

-- Cleanup previous UI instances safely
pcall(function()
    local names = {"JunejoSchoolFightV2UI", "JunejoFightInASchoolUI", "JunejoHubUI"}
    for _, name in ipairs(names) do
        pcall(function()
            if CoreGui and CoreGui:FindFirstChild(name) then
                CoreGui[name]:Destroy()
            end
        end)
        pcall(function()
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
                LocalPlayer.PlayerGui[name]:Destroy()
            end
        end)
        pcall(function()
            if gethui and gethui():FindFirstChild(name) then
                gethui()[name]:Destroy()
            end
        end)
    end
end)

--------------------------------------------------------------------
-- GUI CREATION (JUNEJO ULTRA SCRIPT HUB - EXACT 5-ROW COMPACT SPEC)
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoSchoolFightV2UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true

-- Main Container Frame (Fixed Compact Standard 280px, Height: 218px for 5 rows)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 218)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -109)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Corner & Border Stroke
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Header Frame (Height: 34px)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundTransparency = 1
Header.Active = true
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "FIGHT IN A SCHOOL V2"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 34, 0, 34)
CloseButton.Position = UDim2.new(1, -34, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 170)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Draggable implementation attached to Header (Prevents click-swallowing on Mobile)
local dragging = false
local dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
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

Header.InputChanged:Connect(function(input)
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

-- Content Frame (Height: 136px for 5 rows with 4px gap)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -28, 0, 136)
ContentFrame.Position = UDim2.new(0, 14, 0, 36)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Forward function declarations
local StartFlying, StopFlying, ClearESP, ClearHealthESP

-- Helper function to generate clean, borderless toggle rows
local function AddToggleRow(text, configKey, onToggleCallback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 24)
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
        if onToggleCallback then
            pcall(function()
                onToggleCallback(Toggles[configKey])
            end)
        end
    end)
end

-- Generate 5 Active Toggle Rows (Requested User Specifications)
AddToggleRow("Player ESP", "PlayerESP", function(enabled)
    if not enabled then
        ClearESP()
    end
end)

AddToggleRow("Health Bar ESP", "HealthBarESP", function(enabled)
    if not enabled then
        ClearHealthESP()
    end
end)

AddToggleRow("Noclip", "Noclip")

AddToggleRow("Fly Mode", "Fly", function(enabled)
    if enabled then
        StartFlying()
    else
        StopFlying()
    end
end)

AddToggleRow("Auto Target", "AutoTarget")

-- Footer Frame (Pinned at bottom, Height: 44px)
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 44)
Footer.Position = UDim2.new(0, 0, 1, -44)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 16)
FooterTitle.Position = UDim2.new(0, 0, 0, 5)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 13
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 14)
FooterSub.Position = UDim2.new(0, 0, 0, 21)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 11
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.Parent = Footer

-- Safely Mount ScreenGui
local mounted = false
pcall(function()
    ScreenGui.Parent = UIContainer
    mounted = true
end)

if not mounted or not ScreenGui.Parent then
    pcall(function()
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        mounted = true
    end)
end

-- Success Notification Pop-up
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "ULTRA SCRIPT HUB",
        Text = "Fight In A School V2 Loaded!",
        Duration = 4
    })
end)

--------------------------------------------------------------------
-- ANTI-AFK SYSTEM (Prevents 20-minute idle disconnect)
--------------------------------------------------------------------
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

--------------------------------------------------------------------
-- 1. PLAYER ESP ENGINE (Highlight + Name & Distance Billboard)
--------------------------------------------------------------------
local function ApplyPlayerESP(player)
    if player == LocalPlayer then return end
    pcall(function()
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not head or not hum or hum.Health <= 0 then return end

        -- 1. Highlight / Chams
        local highlight = char:FindFirstChild("JunejoESPHighlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "JunejoESPHighlight"
            highlight.FillColor = Color3.fromRGB(255, 60, 60)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = char
            highlight.Parent = char
        end

        -- 2. Name & Distance Billboard
        local billboard = head:FindFirstChild("JunejoNameBillboard")
        if not billboard then
            billboard = Instance.new("BillboardGui")
            billboard.Name = "JunejoNameBillboard"
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 140, 0, 20)
            billboard.StudsOffset = Vector3.new(0, 2.4, 0)
            billboard.AlwaysOnTop = true
            billboard.ResetOnSpawn = false

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "NameLabel"
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.TextStrokeTransparency = 0.2
            nameLabel.TextSize = 11
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.Parent = billboard

            billboard.Parent = head
        end

        if billboard and billboard:FindFirstChild("NameLabel") then
            local dist = 0
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                dist = math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
            end
            billboard.NameLabel.Text = string.format("%s [%dm]", player.DisplayName or player.Name, dist)
        end
    end)
end

ClearESP = function()
    pcall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local hl = player.Character:FindFirstChild("JunejoESPHighlight")
                if hl then hl:Destroy() end
                local head = player.Character:FindFirstChild("Head")
                if head and head:FindFirstChild("JunejoNameBillboard") then
                    head.JunejoNameBillboard:Destroy()
                end
            end
        end
    end)
end

-- Fast ESP Loop
task.spawn(function()
    while true do
        task.wait(0.25)
        if Toggles.PlayerESP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    ApplyPlayerESP(player)
                end
            end
        end
    end
end)

--------------------------------------------------------------------
-- 2. HEALTH BAR ESP ENGINE (Live Visual Health Bar)
--------------------------------------------------------------------
local function ApplyHealthBarESP(player)
    if player == LocalPlayer then return end
    pcall(function()
        local char = player.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not head or not hum or hum.Health <= 0 then return end

        local healthGui = head:FindFirstChild("JunejoHealthBillboard")
        if not healthGui then
            healthGui = Instance.new("BillboardGui")
            healthGui.Name = "JunejoHealthBillboard"
            healthGui.Adornee = head
            healthGui.Size = UDim2.new(0, 70, 0, 10)
            healthGui.StudsOffset = Vector3.new(0, 3.4, 0)
            healthGui.AlwaysOnTop = true
            healthGui.ResetOnSpawn = false

            local bg = Instance.new("Frame")
            bg.Name = "Background"
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
            bg.BorderSizePixel = 0
            bg.Parent = healthGui

            local bgCorner = Instance.new("UICorner")
            bgCorner.CornerRadius = UDim.new(0, 3)
            bgCorner.Parent = bg

            local bgStroke = Instance.new("UIStroke")
            bgStroke.Color = Color3.fromRGB(40, 40, 50)
            bgStroke.Thickness = 1
            bgStroke.Parent = bg

            local fill = Instance.new("Frame")
            fill.Name = "Fill"
            fill.Size = UDim2.new(1, 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            fill.BorderSizePixel = 0
            fill.Parent = bg

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 3)
            fillCorner.Parent = fill

            local hpLabel = Instance.new("TextLabel")
            hpLabel.Name = "HpLabel"
            hpLabel.Size = UDim2.new(1, 0, 1, 0)
            hpLabel.BackgroundTransparency = 1
            hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            hpLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            hpLabel.TextStrokeTransparency = 0.3
            hpLabel.TextSize = 8
            hpLabel.Font = Enum.Font.GothamBold
            hpLabel.Parent = bg

            healthGui.Parent = head
        end

        if healthGui and healthGui:FindFirstChild("Background") then
            local bg = healthGui.Background
            local fill = bg:FindFirstChild("Fill")
            local hpLabel = bg:FindFirstChild("HpLabel")
            
            local curHp = math.clamp(hum.Health, 0, hum.MaxHealth)
            local maxHp = hum.MaxHealth > 0 and hum.MaxHealth or 100
            local percent = math.clamp(curHp / maxHp, 0, 1)

            if fill then
                fill.Size = UDim2.new(percent, 0, 1, 0)
                -- Color gradient from Green -> Yellow -> Red
                if percent > 0.5 then
                    fill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                elseif percent > 0.25 then
                    fill.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
                else
                    fill.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
                end
            end

            if hpLabel then
                hpLabel.Text = string.format("%d/%d HP", math.floor(curHp), math.floor(maxHp))
            end
        end
    end)
end

ClearHealthESP = function()
    pcall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head and head:FindFirstChild("JunejoHealthBillboard") then
                    head.JunejoHealthBillboard:Destroy()
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.HealthBarESP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    ApplyHealthBarESP(player)
                end
            end
        end
    end
end)

--------------------------------------------------------------------
-- 3. NOCLIP ENGINE (Walk Through School Walls & Doors)
--------------------------------------------------------------------
local NoclipConnection = nil
NoclipConnection = RunService.Stepped:Connect(function()
    if Toggles.Noclip and LocalPlayer.Character then
        pcall(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

--------------------------------------------------------------------
-- 4. SMOOTH 3D FLY MODE (WASD + Mobile Controls)
--------------------------------------------------------------------
local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local FlyConnection = nil
local FlySpeed = 60

StartFlying = function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end

        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.Name = "JunejoFlyVelocity"
        FlyBodyVelocity.Velocity = Vector3.zero
        FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyVelocity.Parent = hrp

        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.Name = "JunejoFlyGyro"
        FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyGyro.P = 10000
        FlyBodyGyro.D = 100
        FlyBodyGyro.CFrame = hrp.CFrame
        FlyBodyGyro.Parent = hrp

        hum.PlatformStand = true

        FlyConnection = RunService.RenderStepped:Connect(function()
            if not Toggles.Fly or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                return
            end

            local cam = Workspace.CurrentCamera
            local root = LocalPlayer.Character.HumanoidRootPart
            local moveDir = Vector3.zero

            -- Keyboard input
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end

            -- Mobile touch / thumbstick support
            if moveDir.Magnitude == 0 and hum.MoveDirection.Magnitude > 0 then
                local camLook = cam.CFrame.LookVector
                local camRight = cam.CFrame.RightVector
                local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
                local flatRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
                
                moveDir = (flatLook * hum.MoveDirection.Z * -1) + (flatRight * hum.MoveDirection.X)
            end

            if moveDir.Magnitude > 0 then
                FlyBodyVelocity.Velocity = moveDir.Unit * FlySpeed
            else
                FlyBodyVelocity.Velocity = Vector3.zero
            end

            FlyBodyGyro.CFrame = cam.CFrame
        end)
    end)
end

StopFlying = function()
    pcall(function()
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
        if FlyBodyVelocity then
            FlyBodyVelocity:Destroy()
            FlyBodyVelocity = nil
        end
        if FlyBodyGyro then
            FlyBodyGyro:Destroy()
            FlyBodyGyro = nil
        end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end)
end

--------------------------------------------------------------------
-- 5. AUTO TARGET ENGINE (Auto Snap/Track Nearest Enemy Player)
--------------------------------------------------------------------
local function GetClosestEnemy()
    local closestPlayer = nil
    local shortestDist = 150 -- Max auto target lock radius in studs

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local enemyHrp = player.Character:FindFirstChild("HumanoidRootPart")
            local enemyHum = player.Character:FindFirstChildOfClass("Humanoid")
            if enemyHrp and enemyHum and enemyHum.Health > 0 then
                local dist = (enemyHrp.Position - myHrp.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if Toggles.AutoTarget and LocalPlayer.Character and not Toggles.Fly then
        pcall(function()
            local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if not myHrp or not myHum or myHum.Health <= 0 then return end

            local target = GetClosestEnemy()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = target.Character.HumanoidRootPart.Position
                -- Smoothly face towards target on X-Z plane (prevents downward pitch tilt)
                local aimLookAt = Vector3.new(targetPos.X, myHrp.Position.Y, targetPos.Z)
                myHrp.CFrame = CFrame.lookAt(myHrp.Position, aimLookAt)
            end
        end)
    end
end)
