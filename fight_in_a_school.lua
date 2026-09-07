--[[
    ========================================================================
    JUNEJO ULTRA SCRIPT HUB - FIGHT IN A SCHOOL (V4.0 ULTIMATE)
    ========================================================================
    Author: Made by Junejo (junejo18146)
    Target Game: Fight in a School (Roblox)
    Repository: junejo18146/ultrascripthub
    File: fight_in_a_school.lua
    UI Standard: Junejo Classic Dark UI (#0F0F11) - Flat & Borderless Standard
    
    Verified Features Included (11 Features):
        1. Hitbox Expander (15x15x15 Reach Multiplier)
        2. Fast Attack / Kill Aura (Auto Strike Nearby Enemies)
        3. Auto Throw Aimbot (Throwable Objects Direct Aim)
        4. Anti-Ragdoll & Anti-Knockback (Fall & Stun Shield)
        5. Auto Gym Trainer (Workout Farm)
        6. Player ESP & Live Health Wallhack
        7. Weapon & Item ESP (Bats, Boomboxes & Tools)
        8. WalkSpeed Boost (+ / - Pill Controller: 16 to 300)
        9. Fly Mode (Smooth 3D Flight)
        10. Noclip Mode (Phase Through Walls & Doors)
        11. Infinite Jump (Multi-Jump Bypass)
    ========================================================================
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

-- State & Settings
local Toggles = {
    HitboxExpander = false,
    KillAura = false,
    ThrowAimbot = false,
    AntiRagdoll = false,
    AutoGym = false,
    PlayerESP = false,
    WeaponESP = false,
    WalkSpeedBoost = false,
    FlyMode = false,
    Noclip = false,
    InfiniteJump = false
}

local CustomSpeedValue = 45
local HitboxSize = Vector3.new(15, 15, 15)
local ESPObjects = {}
local OriginalHitboxes = {}

-- Safe UI Container Resolver
local function GetSafeUIContainer()
    local container = nil
    pcall(function()
        if gethui then container = gethui() end
    end)
    if not container then
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
            if playerGui then container = playerGui end
        end)
    end
    if not container then
        pcall(function()
            if syn and syn.protect_gui then container = CoreGui end
        end)
    end
    if not container then
        pcall(function() container = CoreGui end)
    end
    return container or LocalPlayer:WaitForChild("PlayerGui")
end

local UIContainer = GetSafeUIContainer()

-- Cleanup Previous UI Instances
pcall(function()
    local names = {"JunejoFightInASchoolUI", "FightInASchoolUI", "JunejoHubUI"}
    for _, name in ipairs(names) do
        pcall(function()
            if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        end)
        pcall(function()
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
                LocalPlayer.PlayerGui[name]:Destroy()
            end
        end)
        pcall(function()
            if gethui and gethui():FindFirstChild(name) then gethui()[name]:Destroy() end
        end)
    end
end)

------------------------------------------------------------------------
-- SMOOTH ZERO-VIBRATION COMBAT & UTILITY ENGINES
------------------------------------------------------------------------

-- 1. Hitbox Expander Engine (Smooth Resize & Clean Restore)
local function UpdateHitboxes()
    pcall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChildWhichIsA("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    if Toggles.HitboxExpander then
                        if not OriginalHitboxes[player] then
                            OriginalHitboxes[player] = {
                                Size = hrp.Size,
                                Transparency = hrp.Transparency,
                                CanCollide = hrp.CanCollide,
                                Material = hrp.Material,
                                Color = hrp.Color
                            }
                        end
                        hrp.Size = HitboxSize
                        hrp.Transparency = 0.65
                        hrp.Color = Color3.fromRGB(255, 30, 30)
                        hrp.Material = Enum.Material.Neon
                        hrp.CanCollide = false
                    else
                        if OriginalHitboxes[player] then
                            hrp.Size = OriginalHitboxes[player].Size or Vector3.new(2, 2, 1)
                            hrp.Transparency = OriginalHitboxes[player].Transparency or 1
                            hrp.CanCollide = OriginalHitboxes[player].CanCollide or false
                            hrp.Material = OriginalHitboxes[player].Material or Enum.Material.Plastic
                            hrp.Color = OriginalHitboxes[player].Color or Color3.fromRGB(163, 162, 165)
                        end
                    end
                end
            end
        end
    end)
end

-- Hitbox Background Sweeper Loop
task.spawn(function()
    while true do
        if Toggles.HitboxExpander then
            UpdateHitboxes()
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

-- 2. Fast Attack / Kill Aura Engine (Smooth, Non-Jittering Hits)
local isAttacking = false
task.spawn(function()
    while true do
        if Toggles.KillAura and not isAttacking then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildWhichIsA("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    -- Find nearest enemy within 18 studs
                    local target = nil
                    local shortestDist = 18

                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local pHrp = player.Character:FindFirstChild("HumanoidRootPart")
                            local pHum = player.Character:FindFirstChildWhichIsA("Humanoid")
                            if pHrp and pHum and pHum.Health > 0 then
                                local dist = (pHrp.Position - hrp.Position).Magnitude
                                if dist < shortestDist then
                                    shortestDist = dist
                                    target = player.Character
                                end
                            end
                        end
                    end

                    if target then
                        isAttacking = true
                        
                        -- Equip tool if in backpack
                        local tool = char:FindFirstChildWhichIsA("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                        if tool and tool.Parent == LocalPlayer.Backpack then
                            hum:EquipTool(tool)
                        end

                        if tool and tool:IsA("Tool") then
                            tool:Activate()
                        end

                        -- Fire combat/punch remotes if available
                        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                            if remote:IsA("RemoteEvent") then
                                local rName = string.lower(remote.Name)
                                if string.find(rName, "punch") or string.find(rName, "attack") or string.find(rName, "hit") or string.find(rName, "strike") then
                                    remote:FireServer(target)
                                end
                            end
                        end

                        task.wait(0.12)
                        isAttacking = false
                    end
                end
            end)
            task.wait(0.1)
        else
            task.wait(0.4)
        end
    end
end)

-- 3. Auto Throw Aimbot (`ThrowableUnreliRemote`)
task.spawn(function()
    while true do
        if Toggles.ThrowAimbot then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local targetHead = nil
                    local shortestDist = 60

                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local head = player.Character:FindFirstChild("Head")
                            local hum = player.Character:FindFirstChildWhichIsA("Humanoid")
                            if head and hum and hum.Health > 0 then
                                local dist = (head.Position - hrp.Position).Magnitude
                                if dist < shortestDist then
                                    shortestDist = dist
                                    targetHead = head
                                end
                            end
                        end
                    end

                    if targetHead then
                        -- Check for ThrowableUnreliRemote in ReplicatedStorage or Workspace
                        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                            if remote:IsA("UnreliableRemoteEvent") or remote:IsA("RemoteEvent") then
                                if string.find(string.lower(remote.Name), "throw") then
                                    local throwVelocity = (targetHead.Position - hrp.Position).Unit * 85
                                    remote:FireServer(targetHead.Position, throwVelocity)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(0.8)
        end
    end
end)

-- 4. Anti-Ragdoll & Anti-Knockback Engine
RunService.Heartbeat:Connect(function()
    if Toggles.AntiRagdoll then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                local state = hum:GetState()
                if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.PlatformStanding or state == Enum.HumanoidStateType.FallingDown then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                end
                if hrp:IsA("BasePart") and hrp.AssemblyAngularVelocity.Magnitude > 15 then
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end)
    end
end)

-- 5. Auto Gym Trainer Loop
task.spawn(function()
    while true do
        if Toggles.AutoGym then
            pcall(function()
                local gymTarget = nil
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local name = string.lower(obj.Name)
                        if string.find(name, "gym") or string.find(name, "box") or string.find(name, "bench") or string.find(name, "weight") or string.find(name, "train") then
                            gymTarget = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if gymTarget then break end
                        end
                    end
                end

                if gymTarget then
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - gymTarget.Position).Magnitude > 6 then
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        hrp.CFrame = gymTarget.CFrame + Vector3.new(0, 2, 0)
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    end
                end

                -- Fire gym/workout remotes
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "train") or string.find(rName, "gym") or string.find(rName, "workout") or string.find(rName, "lift") then
                            remote:FireServer()
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(0.5)
        end
    end
end)

------------------------------------------------------------------------
-- VISUALS & ESP WALLHACK ENGINES
------------------------------------------------------------------------

local function CleanESPGroup(groupKey)
    if ESPObjects[groupKey] then
        for _, item in ipairs(ESPObjects[groupKey]) do
            pcall(function()
                if item and item.Destroy then item:Destroy() end
            end)
        end
    end
    ESPObjects[groupKey] = {}
end

local function CreatePlayerESP(player)
    if not player or not player.Character then return end
    pcall(function()
        local char = player.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if not hrp or not hum then return end

        local highlight = Instance.new("Highlight")
        highlight.Name = "JunejoPlayerESP"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(255, 45, 45)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = hrp

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "JunejoPlayerTag"
        billboard.Adornee = hrp
        billboard.Size = UDim2.new(0, 120, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = hrp

        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local dist = myHrp and math.floor((hrp.Position - myHrp.Position).Magnitude) or 0
        local hp = math.floor(hum.Health)
        local maxHp = math.floor(hum.MaxHealth)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.DisplayName .. "\n[" .. hp .. "/" .. maxHp .. " HP] [" .. dist .. "m]"
        label.TextColor3 = Color3.fromRGB(255, 80, 80)
        label.TextStrokeTransparency = 0.2
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextSize = 10
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard

        table.insert(ESPObjects["Player"], highlight)
        table.insert(ESPObjects["Player"], billboard)
    end)
end

local function CreateWeaponESP(toolPart, name)
    if not toolPart or not toolPart.Parent then return end
    pcall(function()
        local highlight = Instance.new("Highlight")
        highlight.Name = "JunejoWeaponESP"
        highlight.Adornee = toolPart.Parent:IsA("Model") and toolPart.Parent or toolPart
        highlight.FillColor = Color3.fromRGB(0, 220, 255)
        highlight.FillTransparency = 0.45
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = toolPart

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "JunejoWeaponTag"
        billboard.Adornee = toolPart
        billboard.Size = UDim2.new(0, 90, 0, 20)
        billboard.StudsOffset = Vector3.new(0, 1.8, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = toolPart

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "🗡️ " .. name
        label.TextColor3 = Color3.fromRGB(0, 240, 255)
        label.TextStrokeTransparency = 0.2
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextSize = 11
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard

        table.insert(ESPObjects["Weapon"], highlight)
        table.insert(ESPObjects["Weapon"], billboard)
    end)
end

-- Master ESP Worker Loop
task.spawn(function()
    while true do
        -- 6. Player ESP
        if Toggles.PlayerESP then
            CleanESPGroup("Player")
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        CreatePlayerESP(player)
                    end
                end
            end)
        else
            CleanESPGroup("Player")
        end

        -- 7. Weapon & Item ESP
        if Toggles.WeaponESP then
            CleanESPGroup("Weapon")
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Tool") and obj.Parent == Workspace then
                        local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                        if handle then
                            CreateWeaponESP(handle, obj.Name)
                        end
                    end
                end
            end)
        else
            CleanESPGroup("Weapon")
        end

        task.wait(1.5)
    end
end)

------------------------------------------------------------------------
-- MOVEMENT & QUALITY OF LIFE ENGINES
------------------------------------------------------------------------

-- 8. WalkSpeed Engine
local function UpdateSpeed()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            if Toggles.WalkSpeedBoost then
                hum.WalkSpeed = CustomSpeedValue
            else
                hum.WalkSpeed = 16
            end
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if Toggles.WalkSpeedBoost then
        UpdateSpeed()
    end
end)

-- 9. Smooth 3D Fly Engine (Zero Camera Shake)
local FlyBV = nil
local FlyBG = nil

local function EnableFly()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if FlyBV then FlyBV:Destroy() end
        if FlyBG then FlyBG:Destroy() end

        FlyBV = Instance.new("BodyVelocity")
        FlyBV.Velocity = Vector3.zero
        FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBV.Parent = hrp

        FlyBG = Instance.new("BodyGyro")
        FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBG.CFrame = hrp.CFrame
        FlyBG.Parent = hrp
    end)
end

local function DisableFly()
    pcall(function()
        if FlyBV then FlyBV:Destroy() FlyBV = nil end
        if FlyBG then FlyBG:Destroy() FlyBG = nil end
    end)
end

RunService.RenderStepped:Connect(function()
    if Toggles.FlyMode and FlyBV and FlyBG then
        pcall(function()
            local cam = Workspace.CurrentCamera
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            FlyBG.CFrame = cam.CFrame
            FlyBV.Velocity = moveDir.Magnitude > 0 and (moveDir.Unit * CustomSpeedValue) or Vector3.zero
        end)
    end
end)

-- 10. Noclip Engine
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

-- 11. Infinite Jump Engine
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

------------------------------------------------------------------------
-- OFFICIAL JUNEJO CLASSIC DARK UI GENERATOR (#0F0F11 - 280x285px)
------------------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoFightInASchoolUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 285)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -142)
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

-- Dragging Engine
local isDragging, dragStart, startPos = false, nil, nil
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Header Frame (Height: 32px)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "FIGHT IN A SCHOOL"
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
    ScreenGui:Destroy()
end)

-- Header Separation Line (1px)
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Scrolling Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 0, 210)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 310)
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper: Add Flat Borderless Toggle Row
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

------------------------------------------------------------------------
-- REGISTERING ALL 11 SELECTED FEATURES
------------------------------------------------------------------------

-- 1. Hitbox Expander
AddToggleRow("Hitbox Expander", "HitboxExpander", function(enabled)
    UpdateHitboxes()
end)

-- 2. Fast Attack / Kill Aura
AddToggleRow("Fast Attack / Aura", "KillAura")

-- 3. Auto Throw Aimbot
AddToggleRow("Auto Throw Aimbot", "ThrowAimbot")

-- 4. Anti-Ragdoll & Knockback
AddToggleRow("Anti-Ragdoll / Knockback", "AntiRagdoll")

-- 5. Auto Gym Trainer
AddToggleRow("Auto Gym Trainer", "AutoGym")

-- 6. Player ESP & Health
AddToggleRow("Player ESP & Health", "PlayerESP")

-- 7. Weapon & Item ESP
AddToggleRow("Weapon & Item ESP", "WeaponESP")

-- 8. WalkSpeed Boost + Integrated Pill Controller (- / +)
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

local MarkCorner2 = Instance.new("UICorner")
MarkCorner2.CornerRadius = UDim.new(0, 2)
MarkCorner2.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
    UpdateSpeed()
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
    UpdateSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateSpeed()
end)

-- 9. Fly Mode
AddToggleRow("Fly Mode", "FlyMode", function(enabled)
    if enabled then EnableFly() else DisableFly() end
end)

-- 10. Noclip Mode
AddToggleRow("Noclip Mode", "Noclip")

-- 11. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump")

-- Pinned Footer
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

-- Mount UI
ScreenGui.Parent = UIContainer
