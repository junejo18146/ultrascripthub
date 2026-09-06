-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - ANIME ABILITY ARENA (OFFICIAL)
-- Game: Anime Ability Arena (Roblox)
-- Link: https://www.roblox.com/games/108567435288296/Anime-Ability-Arena
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- Universal Mobile (Delta / Codex / Fluxus) & PC Compatible
-- 100% Flat & Borderless Junejo Standard UI
-- ====================================================

local function elevate()
    if setthreadidentity then pcall(setthreadidentity, 8) end
end
elevate()

local rawSpawn = task.spawn
local function spawnTask(fn)
    return rawSpawn(function()
        elevate()
        pcall(fn)
    end)
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera", 5)

-- Safe GUI Parent Resolver (Instant 0s Rendering on Mobile & PC)
local function getSafeGui()
    if gethui then
        local success, res = pcall(gethui)
        if success and res then return res end
    end
    local core = nil
    pcall(function() core = game:GetService("CoreGui") end)
    if core then
        local ok = pcall(function()
            local test = Instance.new("Folder")
            test.Parent = core
            test:Destroy()
        end)
        if ok then return core end
    end
    return LocalPlayer:WaitForChild("PlayerGui", 10) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

local guiParent = getSafeGui()

-- Clean all previous UI instances safely
pcall(function()
    for _, name in ipairs({"JunejoHubUI_AnimeAbilityArena", "JunejoHub_AnimeAbilityArena", "JunejoAnimeAbilityUI"}) do
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        local lpGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if lpGui and lpGui:FindFirstChild(name) then lpGui[name]:Destroy() end
        if guiParent and guiParent:FindFirstChild(name) then guiParent[name]:Destroy() end
    end
end)

-- Screen Notification Helper
local function notify(title, message, dur)
    elevate()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "[JUNEJO] " .. tostring(title),
            Text = tostring(message),
            Duration = dur or 3
        })
    end)
end

-- ====================================================
-- GLOBAL STATE & SETTINGS
-- ====================================================
local Settings = {
    -- Combat
    KillAura = false,
    AuraRadius = 25,
    AutoCounter = true,
    AutoSkills = false,
    TargetLowestHP = false,
    HitboxExpander = false,
    HitboxSize = 18,

    -- Movement & Recovery
    InstantGetUp = true,
    AntiVoid = true,
    WalkSpeedBoost = false,
    WalkSpeed = 50,
    InfJump = false,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,

    -- Visuals & ESP
    PlayerESP = false,
    HealthTags = true,
    Tracers = false,

    -- System
    AntiAFK = true,
}

_G.Settings = Settings

local function getPlayerChar()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return char, root, hum
end

local function isAlive()
    local _, root, hum = getPlayerChar()
    return root ~= nil and hum ~= nil and hum.Health > 0
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
    return CFrame.new(0, 45, 0)
end

-- ====================================================
-- INSTANT ANTI-RAGDOLL & AUTO GET UP ENGINE (< 0.1s)
-- ====================================================
local function handleInstantGetUp()
    if not Settings.InstantGetUp or not isAlive() then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if hum and root then
        -- Check if knocked down, ragdolled, seated or falling
        local state = hum:GetState()
        if hum.Sit or hum.PlatformStand or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Physics then
            hum.Sit = false
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            hum:ChangeState(Enum.HumanoidStateType.Running)
            root.AssemblyAngularVelocity = Vector3.zero
        end

        -- Clean any ragdoll constraints or disable motors
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BallSocketConstraint") or obj.Name:lower():find("ragdoll") or obj.Name:lower():find("knockdown") then
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("Motor6D") and not obj.Enabled then
                obj.Enabled = true
            end
        end
    end
end

RunService.Heartbeat:Connect(handleInstantGetUp)
RunService.Stepped:Connect(handleInstantGetUp)

-- ====================================================
-- AUTO COUNTER-ATTACK & DAMAGE TRACKER
-- ====================================================
local lastHealth = 100
local lastAttacker = nil
local lastAttackedTime = 0

local function setupHealthTracker()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        lastHealth = hum.Health
        hum.HealthChanged:Connect(function(newHealth)
            if newHealth < lastHealth and isAlive() then
                lastAttackedTime = os.clock()
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local closest = nil
                    local closestDist = 55
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Humanoid.Health > 0 then
                            local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                            if d < closestDist then
                                closestDist = d
                                closest = p
                            end
                        end
                    end
                    if closest then
                        lastAttacker = closest
                    end
                end
            end
            lastHealth = newHealth
        end)
    end
end

setupHealthTracker()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    setupHealthTracker()
end)

-- ====================================================
-- ZERO-DELAY INSTANT ATTACK ENGINE
-- ====================================================
local function instantAttack(targetRoot)
    local char = LocalPlayer.Character
    if not char then return end

    -- 1. Tool Activate
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
    end

    -- 2. Touch Interest for direct melee damage packet
    if targetRoot and firetouchinterest then
        pcall(function()
            local rArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand") or char:FindFirstChild("HumanoidRootPart")
            if rArm then
                firetouchinterest(rArm, targetRoot, 0)
                firetouchinterest(rArm, targetRoot, 1)
            end
        end)
    end

    -- 3. Virtual Input Clicks (Zero Delay)
    if VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
    if VirtualUser then
        pcall(function()
            VirtualUser:ClickButton1(Vector2.new(0, 0))
        end)
    end
    if mouse1click then pcall(mouse1click) end
end

-- Auto Skills Trigger (Q, E, R)
local lastSkillTime = 0
local function triggerSkills()
    local now = os.clock()
    if now - lastSkillTime < 0.25 then return end
    lastSkillTime = now

    spawnTask(function()
        if VirtualInputManager then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.02)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end)
            task.wait(0.04)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                task.wait(0.02)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
            end)
            task.wait(0.04)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                task.wait(0.02)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
            end)
        end
    end)
end

-- Main Combat Loop
RunService.RenderStepped:Connect(function()
    local char, root, hum = getPlayerChar()
    if not root or not hum or hum.Health <= 0 then return end

    if Settings.KillAura or (Settings.AutoCounter and (os.clock() - lastAttackedTime < 4)) then
        local targetChar = nil
        local targetRoot = nil
        local bestHealth = math.huge
        local closestDist = Settings.AuraRadius

        -- 1. Counter Attack Priority (Attack the enemy who hit us)
        if Settings.AutoCounter and (os.clock() - lastAttackedTime < 4) and lastAttacker and lastAttacker.Character then
            local aChar = lastAttacker.Character
            local aHum = aChar:FindFirstChildOfClass("Humanoid")
            local aRoot = aChar:FindFirstChild("HumanoidRootPart") or aChar:FindFirstChild("Torso")
            if aHum and aHum.Health > 0 and aRoot then
                local dist = (root.Position - aRoot.Position).Magnitude
                if dist <= (Settings.AuraRadius + 20) then
                    targetChar = aChar
                    targetRoot = aRoot
                end
            end
        end

        -- 2. Target Search (Lowest HP or Closest)
        if not targetRoot and Settings.KillAura then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local pChar = player.Character
                    local pHum = pChar:FindFirstChildOfClass("Humanoid")
                    local pRoot = pChar:FindFirstChild("HumanoidRootPart") or pChar:FindFirstChild("Torso")
                    if pHum and pHum.Health > 0 and pRoot then
                        local dist = (root.Position - pRoot.Position).Magnitude
                        if dist <= Settings.AuraRadius then
                            if Settings.TargetLowestHP then
                                if pHum.Health < bestHealth then
                                    bestHealth = pHum.Health
                                    targetChar = pChar
                                    targetRoot = pRoot
                                end
                            else
                                if dist < closestDist then
                                    closestDist = dist
                                    targetChar = pChar
                                    targetRoot = pRoot
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Execute Instant Attacks
        if targetRoot then
            instantAttack(targetRoot)
            if Settings.AutoSkills then
                triggerSkills()
            end
        end
    end
end)

-- ====================================================
-- HITBOX EXPANDER ENGINE
-- ====================================================
local originalHitboxes = {}

local function updateHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local pRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if pRoot then
                if Settings.HitboxExpander then
                    if not originalHitboxes[pRoot] then
                        originalHitboxes[pRoot] = {Size = pRoot.Size, Transparency = pRoot.Transparency, CanCollide = pRoot.CanCollide}
                    end
                    pRoot.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    pRoot.Transparency = 0.65
                    pRoot.Color = Color3.fromRGB(255, 40, 40)
                    pRoot.Material = Enum.Material.Neon
                    pRoot.CanCollide = false
                else
                    if originalHitboxes[pRoot] then
                        pRoot.Size = originalHitboxes[pRoot].Size
                        pRoot.Transparency = originalHitboxes[pRoot].Transparency
                        pRoot.CanCollide = originalHitboxes[pRoot].CanCollide
                        pRoot.Material = Enum.Material.SmoothPlastic
                        originalHitboxes[pRoot] = nil
                    end
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if Settings.HitboxExpander then
        updateHitboxes()
    end
end)

-- ====================================================
-- MOVEMENT & ANTI-VOID ENGINE
-- ====================================================
local lastSafeGroundCFrame = nil

RunService.Heartbeat:Connect(function()
    local _, root, hum = getPlayerChar()
    if root and hum and hum.Health > 0 then
        -- Track last grounded position
        if root.Position.Y > 10 then
            lastSafeGroundCFrame = root.CFrame
        end

        -- Anti-Void Fall Saver
        if Settings.AntiVoid and root.Position.Y < -20 then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.CFrame = lastSafeGroundCFrame or GetSafeZoneCFrame()
            notify("Anti-Void", "Void fall saved! Teleported to ground.", 2)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local char, root, hum = getPlayerChar()
    if hum and root and Settings.WalkSpeedBoost and not Settings.Fly then
        hum.WalkSpeed = Settings.WalkSpeed
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local speedMultiplier = (Settings.WalkSpeed / 16)
            if speedMultiplier > 1 then
                root.CFrame = root.CFrame + (moveDir * (speedMultiplier - 1) * 0.35)
            end
        end
    elseif hum and not Settings.WalkSpeedBoost then
        hum.WalkSpeed = 16
    end
end)

RunService.Stepped:Connect(function()
    if Settings.NoClip then
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

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and isAlive() then
        local _, _, hum = getPlayerChar()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Flight Mechanics
local flyBodyVelocity, flyBodyGyro
local function startFly()
    local char, root, hum = getPlayerChar()
    if not root or not hum then return end
    
    hum.PlatformStand = true
    
    if not flyBodyVelocity or not flyBodyVelocity.Parent then
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.Name = "FlyVelocity"
        flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = root
    end
    
    if not flyBodyGyro or not flyBodyGyro.Parent then
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.Name = "FlyGyro"
        flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        flyBodyGyro.CFrame = root.CFrame
        flyBodyGyro.P = 10000
        flyBodyGyro.D = 500
        flyBodyGyro.Parent = root
    end
end

local function stopFly()
    local _, _, hum = getPlayerChar()
    if hum then hum.PlatformStand = false end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

RunService.RenderStepped:Connect(function()
    if Settings.Fly and isAlive() then
        local _, root, hum = getPlayerChar()
        if root and hum then
            if not flyBodyVelocity or not flyBodyGyro then
                startFly()
            else
                hum.PlatformStand = true
                local camCF = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame or CFrame.new()
                local moveDir = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit
                end
                
                flyBodyVelocity.Velocity = moveDir * (Settings.FlySpeed * 1.5)
                flyBodyGyro.CFrame = camCF
            end
        end
    else
        stopFly()
    end
end)

-- ====================================================
-- VISUALS & PLAYER ESP ENGINE
-- ====================================================
local PlayerESPCache = {}

local function createPlayerESP(player)
    if PlayerESPCache[player] then return PlayerESPCache[player] end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "JunejoESP_" .. player.Name
    highlight.FillColor = Color3.fromRGB(255, 45, 45)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = guiParent
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "JunejoESP_Tag"
    billboard.Size = UDim2.new(0, 140, 0, 30)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = guiParent
    
    local tag = Instance.new("TextLabel")
    tag.Size = UDim2.new(1, 0, 1, 0)
    tag.BackgroundTransparency = 1
    tag.Text = player.DisplayName
    tag.TextColor3 = Color3.fromRGB(255, 255, 255)
    tag.Font = Enum.Font.GothamBold
    tag.TextSize = 12
    tag.TextStrokeTransparency = 0.3
    tag.Parent = billboard

    local tracer = nil
    if Drawing and Drawing.new then
        pcall(function()
            tracer = Drawing.new("Line")
            tracer.Visible = false
            tracer.Color = Color3.fromRGB(255, 50, 50)
            tracer.Thickness = 1.5
            tracer.Transparency = 0.85
        end)
    end

    local record = {Highlight = highlight, Billboard = billboard, Tag = tag, Tracer = tracer}
    PlayerESPCache[player] = record
    return record
end

local function cleanESPCache()
    for player, record in pairs(PlayerESPCache) do
        pcall(function()
            if record.Highlight then record.Highlight:Destroy() end
            if record.Billboard then record.Billboard:Destroy() end
            if record.Tracer then record.Tracer:Remove() end
        end)
        PlayerESPCache[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    local _, root = getPlayerChar()
    if not root then return end
    local cam = Workspace.CurrentCamera

    if Settings.PlayerESP or Settings.Tracers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local pChar = player.Character
                local pRoot = pChar:FindFirstChild("HumanoidRootPart")
                local pHum = pChar:FindFirstChildOfClass("Humanoid")
                
                if pRoot and pHum and pHum.Health > 0 then
                    local record = PlayerESPCache[player] or createPlayerESP(player)
                    record.Highlight.Adornee = pChar
                    record.Billboard.Adornee = pRoot
                    
                    local dist = math.floor((root.Position - pRoot.Position).Magnitude)
                    record.Tag.Text = string.format("%s [%d HP] (%dm)", player.DisplayName, math.floor(pHum.Health), dist)
                    record.Highlight.Enabled = Settings.PlayerESP
                    record.Billboard.Enabled = Settings.PlayerESP and Settings.HealthTags
                    
                    if Settings.Tracers and record.Tracer and cam then
                        local pos, onScreen = cam:WorldToViewportPoint(pRoot.Position)
                        if onScreen then
                            record.Tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                            record.Tracer.To = Vector2.new(pos.X, pos.Y)
                            record.Tracer.Visible = true
                        else
                            record.Tracer.Visible = false
                        end
                    elseif record.Tracer then
                        record.Tracer.Visible = false
                    end
                end
            end
        end
    else
        cleanESPCache()
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK and VirtualUser then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ====================================================
-- OFFICIAL JUNEJO BORDERLESS UI (280x285px)
-- STRICT FLAT BORDERLESS ROWS ONLY
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_AnimeAbilityArena"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = guiParent

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

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local function enableHeaderDrag(dragHandle, targetFrame)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
enableHeaderDrag(Header, MainFrame)

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
CloseButton.MouseButton1Click:Connect(function()
    cleanESPCache()
    Settings.HitboxExpander = false
    updateHitboxes()
    ScreenGui:Destroy()
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Scrollable Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -16, 0, 205)
ContentFrame.Position = UDim2.new(0, 10, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 80)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper Function: Add Section Title
local function AddSectionHeader(title)
    local SecRow = Instance.new("Frame")
    SecRow.Size = UDim2.new(1, -6, 0, 18)
    SecRow.BackgroundTransparency = 1
    SecRow.Parent = ContentFrame

    local SecLabel = Instance.new("TextLabel")
    SecLabel.Size = UDim2.new(1, 0, 1, 0)
    SecLabel.BackgroundTransparency = 1
    SecLabel.Text = "• " .. string.upper(title) .. " •"
    SecLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    SecLabel.TextSize = 10
    SecLabel.Font = Enum.Font.GothamBold
    SecLabel.TextXAlignment = Enum.TextXAlignment.Center
    SecLabel.Parent = SecRow
end

-- Helper Function: Add Strictly Flat & Borderless Toggle Row
local function AddToggleRow(text, configKey, callback, defaultVal)
    if defaultVal ~= nil then Settings[configKey] = defaultVal end
    
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 23)
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
    CheckMark.BackgroundTransparency = Settings[configKey] and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox
    
    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark
    
    local lastClick = 0
    RowBtn.MouseButton1Click:Connect(function()
        local now = os.clock()
        if now - lastClick < 0.12 then return end
        lastClick = now
        Settings[configKey] = not Settings[configKey]
        CheckMark.BackgroundTransparency = Settings[configKey] and 0 or 1
        if callback then callback(Settings[configKey]) end
    end)

    return {
        Set = function(val)
            Settings[configKey] = val
            CheckMark.BackgroundTransparency = val and 0 or 1
            if callback then callback(val) end
        end
    }
end

-- Helper Function: Add Action / Click Button Row
local function AddActionRow(text, btnLabel, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -65, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(0, 58, 0, 20)
    ActionBtn.Position = UDim2.new(1, -58, 0.5, -10)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ActionBtn.BorderSizePixel = 0
    ActionBtn.Text = btnLabel or "▶"
    ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionBtn.TextSize = 11
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.Parent = Row

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ActionBtn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1.2
    BtnStroke.Parent = ActionBtn

    ActionBtn.MouseButton1Click:Connect(function()
        if callback then spawnTask(function() callback(ActionBtn) end) end
    end)
end

-- ====================================================
-- REGISTER FEATURES & CONTROLS
-- ====================================================

-- 1. COMBAT & AUTO ATTACK
AddSectionHeader("Combat & Auto Attack")

AddToggleRow("Auto Attack / Kill Aura", "KillAura", function(state)
    if state then
        notify("Kill Aura", "Zero-Delay Rapid Combat Aura Active!", 2)
    end
end)

AddToggleRow("Auto Counter Attack", "AutoCounter", function(state)
    if state then
        notify("Auto Counter", "Automatic Revenge Counter Active!", 2)
    end
end, true)

-- Aura Radius Pill Adjuster
local AuraRow = Instance.new("Frame")
AuraRow.Size = UDim2.new(1, -6, 0, 23)
AuraRow.BackgroundTransparency = 1
AuraRow.Parent = ContentFrame

local AuraLabel = Instance.new("TextLabel")
AuraLabel.Size = UDim2.new(0.55, 0, 1, 0)
AuraLabel.BackgroundTransparency = 1
AuraLabel.Text = "Aura Radius (Studs)"
AuraLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
AuraLabel.TextSize = 12
AuraLabel.Font = Enum.Font.GothamBold
AuraLabel.TextXAlignment = Enum.TextXAlignment.Left
AuraLabel.Parent = AuraRow

local AuraControlFrame = Instance.new("Frame")
AuraControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
AuraControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
AuraControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
AuraControlFrame.BorderSizePixel = 0
AuraControlFrame.Parent = AuraRow

local ACtrlCorner = Instance.new("UICorner")
ACtrlCorner.CornerRadius = UDim.new(0, 4)
ACtrlCorner.Parent = AuraControlFrame

local ACtrlStroke = Instance.new("UIStroke")
ACtrlStroke.Color = Color3.fromRGB(45, 45, 55)
ACtrlStroke.Thickness = 1
ACtrlStroke.Parent = AuraControlFrame

local AMinusBtn = Instance.new("TextButton")
AMinusBtn.Size = UDim2.new(0, 22, 1, 0)
AMinusBtn.Position = UDim2.new(0, 0, 0, 0)
AMinusBtn.BackgroundTransparency = 1
AMinusBtn.Text = "-"
AMinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
AMinusBtn.TextSize = 14
AMinusBtn.Font = Enum.Font.GothamBold
AMinusBtn.Parent = AuraControlFrame

local AuraDisplay = Instance.new("TextLabel")
AuraDisplay.Size = UDim2.new(1, -44, 1, 0)
AuraDisplay.Position = UDim2.new(0, 22, 0, 0)
AuraDisplay.BackgroundTransparency = 1
AuraDisplay.Text = tostring(Settings.AuraRadius)
AuraDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
AuraDisplay.TextSize = 11
AuraDisplay.Font = Enum.Font.GothamBold
AuraDisplay.Parent = AuraControlFrame

local APlusBtn = Instance.new("TextButton")
APlusBtn.Size = UDim2.new(0, 22, 1, 0)
APlusBtn.Position = UDim2.new(1, -22, 0, 0)
APlusBtn.BackgroundTransparency = 1
APlusBtn.Text = "+"
APlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
APlusBtn.TextSize = 14
APlusBtn.Font = Enum.Font.GothamBold
APlusBtn.Parent = AuraControlFrame

AMinusBtn.MouseButton1Click:Connect(function()
    Settings.AuraRadius = math.max(10, Settings.AuraRadius - 5)
    AuraDisplay.Text = tostring(Settings.AuraRadius)
end)

APlusBtn.MouseButton1Click:Connect(function()
    Settings.AuraRadius = math.min(100, Settings.AuraRadius + 5)
    AuraDisplay.Text = tostring(Settings.AuraRadius)
end)

AddToggleRow("Auto Cast Skills (Q, E, R)", "AutoSkills", function(state) end)
AddToggleRow("Target Lowest HP Player", "TargetLowestHP", function(state) end)
AddToggleRow("Hitbox Expander (18x18)", "HitboxExpander", function(state)
    if not state then updateHitboxes() end
end)

-- 2. SURVIVAL & RECOVERY
AddSectionHeader("Survival & Movement")

AddToggleRow("Instant Auto Get Up (<0.1s)", "InstantGetUp", function(state) end, true)
AddToggleRow("Anti-Void (Fall Saver)", "AntiVoid", function(state) end, true)

-- Integrated WalkSpeed Row with Pill Adjuster
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, -6, 0, 23)
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
SpeedCheckMark.BackgroundTransparency = Settings.WalkSpeedBoost and 0 or 1
SpeedCheckMark.BorderSizePixel = 0
SpeedCheckMark.Parent = SpeedCheckBox

local MarkCorner = Instance.new("UICorner")
MarkCorner.CornerRadius = UDim.new(0, 2)
MarkCorner.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Settings.WalkSpeedBoost = not Settings.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Settings.WalkSpeedBoost and 0 or 1
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
SpeedDisplay.Text = tostring(Settings.WalkSpeed)
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
    Settings.WalkSpeed = math.max(16, Settings.WalkSpeed - 5)
    SpeedDisplay.Text = tostring(Settings.WalkSpeed)
end)

PlusBtn.MouseButton1Click:Connect(function()
    Settings.WalkSpeed = math.min(150, Settings.WalkSpeed + 5)
    SpeedDisplay.Text = tostring(Settings.WalkSpeed)
end)

AddToggleRow("Infinite Jump", "InfJump", function(state) end)

-- Integrated Fly Mode Row with Pill Adjuster
local FlyRow = Instance.new("Frame")
FlyRow.Size = UDim2.new(1, -6, 0, 23)
FlyRow.BackgroundTransparency = 1
FlyRow.Parent = ContentFrame

local FlyToggleBtn = Instance.new("TextButton")
FlyToggleBtn.Size = UDim2.new(0.55, 0, 1, 0)
FlyToggleBtn.BackgroundTransparency = 1
FlyToggleBtn.Text = ""
FlyToggleBtn.ZIndex = 5
FlyToggleBtn.Parent = FlyRow

local FlyLabel = Instance.new("TextLabel")
FlyLabel.Size = UDim2.new(1, -26, 1, 0)
FlyLabel.BackgroundTransparency = 1
FlyLabel.Text = "Arena Fly Mode"
FlyLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
FlyLabel.TextSize = 12
FlyLabel.Font = Enum.Font.GothamBold
FlyLabel.TextXAlignment = Enum.TextXAlignment.Left
FlyLabel.Parent = FlyToggleBtn

local FlyCheckBox = Instance.new("Frame")
FlyCheckBox.Size = UDim2.new(0, 18, 0, 18)
FlyCheckBox.Position = UDim2.new(1, -18, 0.5, -9)
FlyCheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
FlyCheckBox.BorderSizePixel = 0
FlyCheckBox.Parent = FlyToggleBtn

local FlyCheckCorner = Instance.new("UICorner")
FlyCheckCorner.CornerRadius = UDim.new(0, 4)
FlyCheckCorner.Parent = FlyCheckBox

local FlyCheckStroke = Instance.new("UIStroke")
FlyCheckStroke.Color = Color3.fromRGB(45, 45, 55)
FlyCheckStroke.Thickness = 1.2
FlyCheckStroke.Parent = FlyCheckBox

local FlyCheckMark = Instance.new("Frame")
FlyCheckMark.Size = UDim2.new(0, 10, 0, 10)
FlyCheckMark.Position = UDim2.new(0.5, -5, 0.5, -5)
FlyCheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FlyCheckMark.BackgroundTransparency = Settings.Fly and 0 or 1
FlyCheckMark.BorderSizePixel = 0
FlyCheckMark.Parent = FlyCheckBox

local FMarkCorner = Instance.new("UICorner")
FMarkCorner.CornerRadius = UDim.new(0, 2)
FMarkCorner.Parent = FlyCheckMark

FlyToggleBtn.MouseButton1Click:Connect(function()
    Settings.Fly = not Settings.Fly
    FlyCheckMark.BackgroundTransparency = Settings.Fly and 0 or 1
end)

local FlyControlFrame = Instance.new("Frame")
FlyControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
FlyControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
FlyControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
FlyControlFrame.BorderSizePixel = 0
FlyControlFrame.Parent = FlyRow

local FCtrlCorner = Instance.new("UICorner")
FCtrlCorner.CornerRadius = UDim.new(0, 4)
FCtrlCorner.Parent = FlyControlFrame

local FCtrlStroke = Instance.new("UIStroke")
FCtrlStroke.Color = Color3.fromRGB(45, 45, 55)
FCtrlStroke.Thickness = 1
FCtrlStroke.Parent = FlyControlFrame

local FMinusBtn = Instance.new("TextButton")
FMinusBtn.Size = UDim2.new(0, 22, 1, 0)
FMinusBtn.Position = UDim2.new(0, 0, 0, 0)
FMinusBtn.BackgroundTransparency = 1
FMinusBtn.Text = "-"
FMinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
FMinusBtn.TextSize = 14
FMinusBtn.Font = Enum.Font.GothamBold
FMinusBtn.Parent = FlyControlFrame

local FlyDisplay = Instance.new("TextLabel")
FlyDisplay.Size = UDim2.new(1, -44, 1, 0)
FlyDisplay.Position = UDim2.new(0, 22, 0, 0)
FlyDisplay.BackgroundTransparency = 1
FlyDisplay.Text = tostring(Settings.FlySpeed)
FlyDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyDisplay.TextSize = 11
FlyDisplay.Font = Enum.Font.GothamBold
FlyDisplay.Parent = FlyControlFrame

local FPlusBtn = Instance.new("TextButton")
FPlusBtn.Size = UDim2.new(0, 22, 1, 0)
FPlusBtn.Position = UDim2.new(1, -22, 0, 0)
FPlusBtn.BackgroundTransparency = 1
FPlusBtn.Text = "+"
FPlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
FPlusBtn.TextSize = 14
FPlusBtn.Font = Enum.Font.GothamBold
FPlusBtn.Parent = FlyControlFrame

FMinusBtn.MouseButton1Click:Connect(function()
    Settings.FlySpeed = math.max(10, Settings.FlySpeed - 5)
    FlyDisplay.Text = tostring(Settings.FlySpeed)
end)

FPlusBtn.MouseButton1Click:Connect(function()
    Settings.FlySpeed = math.min(120, Settings.FlySpeed + 5)
    FlyDisplay.Text = tostring(Settings.FlySpeed)
end)

AddToggleRow("Auto NoClip", "NoClip", function(state) end)

-- 3. TELEPORTS & TACTICS
AddSectionHeader("Teleports & Tactics")

AddActionRow("Escape to Safe Zone", "TP", function()
    if isAlive() then
        LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        LocalPlayer.Character.HumanoidRootPart.CFrame = GetSafeZoneCFrame()
        notify("Teleport", "Escaped to Safe Zone!", 2)
    end
end)

AddActionRow("TP Behind Nearest Enemy", "TP", function()
    local _, root = getPlayerChar()
    if root then
        local nearest = nil
        local nearestDist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Humanoid.Health > 0 then
                local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    nearest = p.Character.HumanoidRootPart
                end
            end
        end
        if nearest then
            root.AssemblyLinearVelocity = Vector3.zero
            root.CFrame = nearest.CFrame * CFrame.new(0, 0, 4) * CFrame.Angles(0, math.rad(180), 0)
            notify("Teleport", "Teleported behind enemy!", 2)
        else
            notify("Error", "No enemy found nearby!", 2)
        end
    end
end)

AddActionRow("Click-to-TP Tool", "Get", function()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "Click Teleport"
        tool.Activated:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            if isAlive() and mouse.Hit then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
        tool.Parent = bp
        notify("Tool Given", "Click Teleport tool added to Backpack!", 2)
    end
end)

-- 4. VISUALS & ESP
AddSectionHeader("Visuals & Player ESP")

AddToggleRow("Player Highlights ESP", "PlayerESP", function(state)
    if not state then cleanESPCache() end
end)

AddToggleRow("Health & Distance Tags", "HealthTags", function(state) end, true)

AddToggleRow("ESP Tracers", "Tracers", function(state)
    if not state then
        for _, rec in pairs(PlayerESPCache) do
            if rec.Tracer then rec.Tracer.Visible = false end
        end
    end
end)

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

notify("Anime Ability Arena", "Junejo Ultra Script Hub Loaded!", 3)
