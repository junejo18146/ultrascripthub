--[[
    JUNEJO ULTRA SCRIPT HUB - SLAYERS 2 (V3.5 DEFINITIVE EDITION)
    Target Game: Slayers 2 (Roblox)
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Official UI 1 - Classic Matte Dark (#0F0F11)
    Status: Unlocked Direct Standalone Execution (Key System Disabled)
    Layout: 5 Features Visible on Main Screen + Smooth Scrollable Slider
    Order:
      1. Instant Auto Get Up (Toggle)
      2. FullBright (Toggle) -- [DOSRE NUMBER PE / POSITION 2]
      3. Hitbox Expander (Toggle)
      4. Teleport to Low HP Player (Action Button)
      5. Teleport to Quest (Action Button)
      -- [Scroll for remaining features] --
      6. Teleport to Safe Zone (Action Button)
      7. Auto Farm Mobs / Demons (Toggle - Upright, Zero Shake)
      8. Auto Accept Quests (Toggle)
      9. Fast Auto Attack (Toggle)
      10. Fly Mode (Toggle)
      11. Infinite Jump (Toggle)
      12. Quest ESP (Toggle)
      13. Mob / Demon ESP (Toggle)
      14. Player ESP (Toggle)
      15. Trainers / NPC ESP (Toggle)
      16. WalkSpeed Stepper (+ / - Pill [16-250])
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Safe UI Parent getter (compatible with Delta, Codex, Fluxus, and PC Executors)
local function GetUIContainer()
    local success, res = pcall(function()
        if gethui then return gethui() end
        if syn and syn.protect_gui then return CoreGui end
        return CoreGui
    end)
    if success and res then return res end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local UIContainer = GetUIContainer()

-- Clean up any previous UI instances safely
for _, name in ipairs({"JunejoHubUI_Slayers2", "JunejoSlayers2UI", "JunejoUltraScriptHub_Slayers2"}) do
    pcall(function()
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end)
end

-- Global Configuration & State
local Toggles = {
    InstantGetUp = true,
    FullBright = false,
    HitboxExpander = false,
    AutoFarmMobs = false,
    AutoAcceptQuests = false,
    FastAutoAttack = false,
    Fly = false,
    InfiniteJump = false,
    QuestESP = false,
    MobESP = false,
    PlayerESP = false,
    TrainerESP = false,
    WalkSpeed = false,
    AntiAFK = true
}

local CustomSpeedValue = 50
local FlySpeed = 50
local SafePlatform = nil

-- Flight Components
local FlyBodyGyro = nil
local FlyBodyVelocity = nil

-- Target & ESP Storage
local CurrentFarmTarget = nil
local ActiveMobESP = {}
local ActivePlayerESP = {}
local ActiveTrainerESP = {}
local ActiveQuestESP = {}
local OriginalHitboxSizes = {}

-- Pre-Cached Remotes Storage (Prevents freezing & network spam)
local CachedCombatRemotes = {}
local CachedQuestRemotes = {}

-- Store original Lighting settings
local DefaultLightingSettings = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Ambient = Lighting.Ambient
}

-- Safe Alive Check
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- ====================================================
-- PRE-CACHING SYSTEM (RUNS ONCE IN BACKGROUND)
-- ====================================================
task.spawn(function()
    pcall(function()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:find("attack") or n:find("combat") or n:find("m1") or n:find("slash") or n:find("hit") or n:find("swing") or n:find("damage") or n:find("punch") then
                    table.insert(CachedCombatRemotes, obj)
                elseif n:find("quest") or n:find("mission") or n:find("task") or n:find("dialogue") or n:find("tonpc") or n:find("accept") then
                    table.insert(CachedQuestRemotes, obj)
                end
            end
        end
    end)
end)

-- Anti-AFK Handler
pcall(function()
    LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAFK then
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end
    end)
end)

-- Screen Toast Notification Helper
local function ShowToast(title, message)
    pcall(function()
        local sg = CoreGui:FindFirstChild("JunejoHubUI_Slayers2") or (LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("JunejoHubUI_Slayers2"))
        if not sg then return end

        local oldToast = sg:FindFirstChild("JunejoToast")
        if oldToast then oldToast:Destroy() end

        local Toast = Instance.new("Frame")
        Toast.Name = "JunejoToast"
        Toast.Size = UDim2.new(0, 230, 0, 36)
        Toast.Position = UDim2.new(0.5, -115, 0.08, 0)
        Toast.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        Toast.BorderSizePixel = 0
        Toast.ZIndex = 9999
        Toast.Parent = sg

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 8)
        ToastCorner.Parent = Toast

        local ToastStroke = Instance.new("UIStroke")
        ToastStroke.Color = Color3.fromRGB(50, 50, 65)
        ToastStroke.Thickness = 1
        ToastStroke.Parent = Toast

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -12, 0, 15)
        TitleLbl.Position = UDim2.new(0, 8, 0, 3)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
        TitleLbl.TextSize = 11
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.ZIndex = 10000
        TitleLbl.Parent = Toast

        local MsgLbl = Instance.new("TextLabel")
        MsgLbl.Size = UDim2.new(1, -12, 0, 15)
        MsgLbl.Position = UDim2.new(0, 8, 0, 17)
        MsgLbl.BackgroundTransparency = 1
        MsgLbl.Text = message
        MsgLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
        MsgLbl.TextSize = 10
        MsgLbl.Font = Enum.Font.GothamMedium
        MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
        MsgLbl.ZIndex = 10000
        MsgLbl.Parent = Toast

        task.delay(2.2, function()
            if Toast and Toast.Parent then
                local tween = TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                tween:Play()
                TitleLbl.TextTransparency = 1
                MsgLbl.TextTransparency = 1
                ToastStroke.Transparency = 1
                task.wait(0.35)
                if Toast then Toast:Destroy() end
            end
        end)
    end)
end

-- ====================================================
-- CORE FUNCTIONALITIES & ENGINES
-- ====================================================

-- 1. Instant Auto Get Up / Anti-Ragdoll Engine
local function SetupInstantGetUp(char)
    pcall(function()
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end

        hum.StateChanged:Connect(function(oldState, newState)
            if Toggles.InstantGetUp then
                if newState == Enum.HumanoidStateType.Ragdoll or 
                   newState == Enum.HumanoidStateType.FallingDown or 
                   newState == Enum.HumanoidStateType.PlatformStanding or 
                   newState == Enum.HumanoidStateType.Physics then
                    hum.PlatformStand = false
                    hum.Sit = false
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
        end)

        char.DescendantAdded:Connect(function(obj)
            if Toggles.InstantGetUp and obj:IsA("BallSocketConstraint") then
                obj.Enabled = false
            end
        end)
    end)
end

if LocalPlayer.Character then SetupInstantGetUp(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SetupInstantGetUp)

-- 2. FullBright Engine (Daytime Simulation & Fog Removal)
local function UpdateFullBright(enabled)
    pcall(function()
        if enabled then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = DefaultLightingSettings.Brightness
            Lighting.ClockTime = DefaultLightingSettings.ClockTime
            Lighting.FogEnd = DefaultLightingSettings.FogEnd
            Lighting.GlobalShadows = DefaultLightingSettings.GlobalShadows
            Lighting.OutdoorAmbient = DefaultLightingSettings.OutdoorAmbient
            Lighting.Ambient = DefaultLightingSettings.Ambient
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.FullBright then
            UpdateFullBright(true)
        end
    end
end)

-- 3. Fast Enemy Scanner Helper
local function GetAliveEnemies()
    local enemies = {}
    pcall(function()
        local function checkModel(model)
            if not model:IsA("Model") or model == LocalPlayer.Character then return end
            if Players:GetPlayerFromCharacter(model) then return end

            local hum = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
            
            if hum and hum.Health > 0 and root then
                table.insert(enemies, {
                    Model = model,
                    Humanoid = hum,
                    RootPart = root,
                    Name = model.Name
                })
            end
        end

        local humanoidsFolder = Workspace:FindFirstChild("Humanoids")
        if humanoidsFolder then
            for _, m in ipairs(humanoidsFolder:GetChildren()) do checkModel(m) end
        end

        local npcsFolder = Workspace:FindFirstChild("ActiveNpcs") or Workspace:FindFirstChild("Npcs")
        if npcsFolder then
            for _, m in ipairs(npcsFolder:GetChildren()) do checkModel(m) end
        end

        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") then checkModel(obj) end
        end
    end)
    return enemies
end

-- 4. Hitbox Expander Engine (Demons + Rival Players)
local function UpdateHitboxExpander()
    pcall(function()
        if not Toggles.HitboxExpander then
            for part, originalSize in pairs(OriginalHitboxSizes) do
                if part and part.Parent then
                    part.Size = originalSize
                    part.Transparency = 0
                    part.CanCollide = true
                end
            end
            OriginalHitboxSizes = {}
            return
        end

        local targets = GetAliveEnemies()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    table.insert(targets, { RootPart = hrp, Name = plr.Name })
                end
            end
        end

        for _, target in ipairs(targets) do
            local part = target.RootPart
            if part and part:IsA("BasePart") then
                if not OriginalHitboxSizes[part] then
                    OriginalHitboxSizes[part] = part.Size
                end
                part.Size = Vector3.new(18, 18, 18)
                part.Transparency = 0.7
                part.Material = Enum.Material.Neon
                part.Color = Color3.fromRGB(255, 40, 40)
                part.CanCollide = false
                part.Massless = true
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(1.0)
        if Toggles.HitboxExpander then
            UpdateHitboxExpander()
        end
    end
end)

-- 5. Teleport to Low Health Player Action
local function TeleportToLowHealthPlayer()
    pcall(function()
        if not isAlive() then
            ShowToast("Error", "Character not spawned!")
            return
        end

        local myHrp = LocalPlayer.Character.HumanoidRootPart
        local lowestPlayer = nil
        local lowestHealth = math.huge

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 and hum.Health < lowestHealth then
                    lowestHealth = hum.Health
                    lowestPlayer = plr
                end
            end
        end

        if lowestPlayer and lowestPlayer.Character and lowestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = lowestPlayer.Character.HumanoidRootPart
            myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
            myHrp.AssemblyLinearVelocity = Vector3.zero
            ShowToast("TP Low HP", "Warped to " .. lowestPlayer.DisplayName .. " [HP: " .. math.floor(lowestHealth) .. "]")
        else
            ShowToast("Notice", "No low HP players found!")
        end
    end)
end

-- 6. Teleport to Quest Action
local function TeleportToQuest()
    pcall(function()
        if not isAlive() then
            ShowToast("Error", "Character not spawned!")
            return
        end

        local hrp = LocalPlayer.Character.HumanoidRootPart
        local questTarget = nil

        -- 1. Check for Quest Pickups / Deposits / Gates
        for _, name in ipairs({"QuestPickup", "QuestDeposit", "QuestGate", "QuestObjective"}) do
            local found = Workspace:FindFirstChild(name, true)
            if found then
                local part = found:IsA("BasePart") and found or found:FindFirstChildWhichIsA("BasePart")
                if part then
                    questTarget = part
                    break
                end
            end
        end

        -- 2. Check for Quest NPCs in ActiveNpcs
        if not questTarget then
            local npcsFolder = Workspace:FindFirstChild("ActiveNpcs") or Workspace:FindFirstChild("Npcs")
            if npcsFolder then
                for _, npc in ipairs(npcsFolder:GetChildren()) do
                    if npc:FindFirstChild("Quests") or npc:FindFirstChild("Quest") or npc.Name:lower():find("quest") then
                        local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
                        if root then
                            questTarget = root
                            break
                        end
                    end
                end
            end
        end

        -- 3. Check for any NPC with active quest proximity prompt
        if not questTarget then
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    local t = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
                    if t:find("quest") or t:find("mission") then
                        local part = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                        if part then
                            questTarget = part
                            break
                        end
                    end
                end
            end
        end

        if questTarget then
            hrp.CFrame = questTarget.CFrame * CFrame.new(0, 3, 3)
            hrp.AssemblyLinearVelocity = Vector3.zero
            ShowToast("Teleport Success", "Warped to Quest: " .. (questTarget.Parent and questTarget.Parent.Name or questTarget.Name))
        else
            ShowToast("Notice", "No active Quest objective found nearby!")
        end
    end)
end

-- 7. Safe Zone Teleport Action
local function TeleportToSafeZone()
    pcall(function()
        if not isAlive() then
            ShowToast("Error", "Character not spawned!")
            return
        end

        local hrp = LocalPlayer.Character.HumanoidRootPart
        local safePos = Vector3.new(hrp.Position.X, hrp.Position.Y + 600, hrp.Position.Z)

        if not SafePlatform or not SafePlatform.Parent then
            SafePlatform = Instance.new("Part")
            SafePlatform.Name = "JunejoSafeZonePlatform"
            SafePlatform.Size = Vector3.new(40, 2, 40)
            SafePlatform.Anchored = true
            SafePlatform.CanCollide = true
            SafePlatform.Material = Enum.Material.SmoothPlastic
            SafePlatform.Color = Color3.fromRGB(25, 25, 30)
            SafePlatform.CFrame = CFrame.new(safePos - Vector3.new(0, 3, 0))
            SafePlatform.Parent = Workspace
        else
            SafePlatform.CFrame = CFrame.new(safePos - Vector3.new(0, 3, 0))
        end

        hrp.CFrame = CFrame.new(safePos)
        hrp.AssemblyLinearVelocity = Vector3.zero
        ShowToast("Safe Zone", "Teleported to Sky Safe Platform!")
    end)
end

-- Weapon Auto-Equip Helper
local function AutoEquipWeapon()
    pcall(function()
        if not isAlive() then return end
        local char = LocalPlayer.Character
        local hasToolEquipped = char:FindFirstChildOfClass("Tool")
        if not hasToolEquipped then
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp then
                local tool = bp:FindFirstChildOfClass("Tool")
                if tool then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:EquipTool(tool) end
                end
            end
        end
    end)
end

-- Safe Attack Executor
local function ExecuteAttack(targetRoot)
    pcall(function()
        if not isAlive() then return end
        AutoEquipWeapon()

        local char = LocalPlayer.Character
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Activate()
            end
        end

        for _, remote in ipairs(CachedCombatRemotes) do
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer()
                    if targetRoot and targetRoot.Parent then
                        remote:FireServer(targetRoot.Parent)
                    end
                end
            end)
        end
    end)
end

-- Fast Auto Attack Loop
task.spawn(function()
    while true do
        task.wait(0.18)
        if Toggles.FastAutoAttack and isAlive() then
            ExecuteAttack(nil)
        end
    end
end)

-- Auto Farm Mobs Loop (Upright, Zero Shake, Rock-Solid Hover)
task.spawn(function()
    while true do
        task.wait(0.12)
        if Toggles.AutoFarmMobs and isAlive() then
            pcall(function()
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local char = LocalPlayer.Character

                if not CurrentFarmTarget or 
                   not CurrentFarmTarget.Model.Parent or 
                   CurrentFarmTarget.Humanoid.Health <= 0 or 
                   not CurrentFarmTarget.RootPart.Parent then
                    
                    local enemies = GetAliveEnemies()
                    local closest = nil
                    local shortestDist = math.huge
                    for _, enemy in ipairs(enemies) do
                        local d = (enemy.RootPart.Position - hrp.Position).Magnitude
                        if d < shortestDist then
                            shortestDist = d
                            closest = enemy
                        end
                    end
                    CurrentFarmTarget = closest
                end

                if CurrentFarmTarget and CurrentFarmTarget.Humanoid.Health > 0 then
                    local targetPart = CurrentFarmTarget.RootPart
                    local targetPos = targetPart.Position

                    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0), targetPos)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero

                    for _, p in ipairs(char:GetChildren()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                        end
                    end

                    ExecuteAttack(targetPart)
                end
            end)
        else
            CurrentFarmTarget = nil
        end
    end
end)

-- Auto Accept Quests Engine
pcall(function()
    ProximityPromptService.PromptShown:Connect(function(prompt)
        if Toggles.AutoAcceptQuests and isAlive() then
            pcall(function()
                local text = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. (prompt.Parent and prompt.Parent.Name or "")):lower()
                if text:find("quest") or text:find("talk") or text:find("accept") or text:find("mission") or text:find("task") or text:find("interact") then
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    else
                        prompt:InputHoldBegin()
                        task.wait(0.05)
                        prompt:InputHoldEnd()
                    end
                end
            end)
        end
    end)
end)

task.spawn(function()
    while true do
        task.wait(1.0)
        if Toggles.AutoAcceptQuests and isAlive() then
            pcall(function()
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                if pg then
                    for _, gui in ipairs(pg:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.Enabled then
                            for _, btn in ipairs(gui:GetDescendants()) do
                                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                                    local t = (btn.Text or ""):lower()
                                    local bn = btn.Name:lower()
                                    if t:find("accept") or t:find("yes") or t:find("sure") or t:find("confirm") or t:find("take") or bn:find("accept") or bn:find("yes") then
                                        pcall(function()
                                            if getconnections then
                                                for _, conn in ipairs(getconnections(btn.MouseButton1Click) or {}) do conn:Fire() end
                                                for _, conn in ipairs(getconnections(btn.Activated) or {}) do conn:Fire() end
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end

                for _, remote in ipairs(CachedQuestRemotes) do
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer("Accept")
                            remote:FireServer(1)
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer("Accept")
                        end
                    end)
                end
            end)
        end
    end
end)

-- 8. Fly Mode Engine (Smooth 3D WASD & Mobile Touch Support)
local function UpdateFly(enabled)
    pcall(function()
        if not isAlive() then return end
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

        if enabled then
            if FlyBodyGyro then FlyBodyGyro:Destroy() end
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() end

            FlyBodyGyro = Instance.new("BodyGyro")
            FlyBodyGyro.Name = "JunejoFlyGyro"
            FlyBodyGyro.P = 9e4
            FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            FlyBodyGyro.CFrame = hrp.CFrame
            FlyBodyGyro.Parent = hrp

            FlyBodyVelocity = Instance.new("BodyVelocity")
            FlyBodyVelocity.Name = "JunejoFlyVelocity"
            FlyBodyVelocity.Velocity = Vector3.zero
            FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            FlyBodyVelocity.Parent = hrp

            hum.PlatformStand = true

            task.spawn(function()
                while Toggles.Fly and isAlive() do
                    task.wait()
                    pcall(function()
                        local cam = Workspace.CurrentCamera
                        local moveDir = hum.MoveDirection
                        local vel = Vector3.zero

                        if moveDir.Magnitude > 0 then
                            vel = (cam.CFrame.LookVector * (moveDir.Z * -1) + cam.CFrame.RightVector * moveDir.X).Unit * FlySpeed
                        end

                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            vel = vel + Vector3.new(0, FlySpeed * 0.8, 0)
                        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            vel = vel - Vector3.new(0, FlySpeed * 0.8, 0)
                        end

                        FlyBodyVelocity.Velocity = vel
                        FlyBodyGyro.CFrame = cam.CFrame
                    end)
                end
                if FlyBodyGyro then FlyBodyGyro:Destroy() end
                if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
                if isAlive() then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
                end
            end)
        else
            if FlyBodyGyro then FlyBodyGyro:Destroy() end
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
            if hum then hum.PlatformStand = false end
        end
    end)
end

-- 9. Infinite Jump Engine
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and isAlive() then
        pcall(function()
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- 10. Quest ESP Engine
local function UpdateQuestESP()
    pcall(function()
        if not Toggles.QuestESP then
            for obj, bg in pairs(ActiveQuestESP) do
                if bg and bg.Parent then bg:Destroy() end
            end
            ActiveQuestESP = {}
            return
        end

        local questParts = {}
        local npcsFolder = Workspace:FindFirstChild("ActiveNpcs") or Workspace:FindFirstChild("Npcs")
        if npcsFolder then
            for _, npc in ipairs(npcsFolder:GetChildren()) do
                if npc:FindFirstChild("Quests") or npc:FindFirstChild("Quest") or npc.Name:lower():find("quest") then
                    local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
                    if root then table.insert(questParts, { Part = root, Name = npc.Name }) end
                end
            end
        end

        for _, name in ipairs({"QuestPickup", "QuestDeposit", "QuestGate", "QuestObjective"}) do
            for _, found in ipairs(Workspace:GetDescendants()) do
                if found.Name == name and found:IsA("BasePart") then
                    table.insert(questParts, { Part = found, Name = name })
                end
            end
        end

        for _, item in ipairs(questParts) do
            local part = item.Part
            if part then
                if not ActiveQuestESP[part] then
                    local bg = Instance.new("BillboardGui")
                    bg.Name = "JunejoQuestESP"
                    bg.Adornee = part
                    bg.Size = UDim2.new(0, 140, 0, 28)
                    bg.StudsOffset = Vector3.new(0, 3.5, 0)
                    bg.AlwaysOnTop = true
                    bg.Parent = part

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.fromRGB(255, 170, 0)
                    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    lbl.TextStrokeTransparency = 0
                    lbl.TextSize = 10
                    lbl.Font = Enum.Font.GothamBold
                    lbl.Text = "[QUEST] " .. item.Name
                    lbl.Parent = bg

                    ActiveQuestESP[part] = bg
                else
                    local lbl = ActiveQuestESP[part]:FindFirstChildOfClass("TextLabel")
                    if lbl and isAlive() then
                        local dist = math.floor((part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                        lbl.Text = "[QUEST] " .. item.Name .. " [" .. dist .. "m]"
                    end
                end
            end
        end
    end)
end

-- 11. Mob / Demon ESP Engine
local function UpdateMobESP()
    pcall(function()
        if not Toggles.MobESP then
            for part, bg in pairs(ActiveMobESP) do
                if bg and bg.Parent then bg:Destroy() end
            end
            ActiveMobESP = {}
            return
        end

        local enemies = GetAliveEnemies()
        local validParts = {}

        for _, enemy in ipairs(enemies) do
            local part = enemy.RootPart
            if part then
                validParts[part] = true
                if not ActiveMobESP[part] then
                    local bg = Instance.new("BillboardGui")
                    bg.Name = "JunejoMobESP"
                    bg.Adornee = part
                    bg.Size = UDim2.new(0, 140, 0, 28)
                    bg.StudsOffset = Vector3.new(0, 3.5, 0)
                    bg.AlwaysOnTop = true
                    bg.Parent = part

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.fromRGB(255, 60, 80)
                    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    lbl.TextStrokeTransparency = 0
                    lbl.TextSize = 10
                    lbl.Font = Enum.Font.GothamBold
                    lbl.Text = "[DEMON] " .. enemy.Name .. " [HP: " .. math.floor(enemy.Humanoid.Health) .. "]"
                    lbl.Parent = bg

                    ActiveMobESP[part] = bg
                else
                    local lbl = ActiveMobESP[part]:FindFirstChildOfClass("TextLabel")
                    if lbl and isAlive() then
                        local dist = math.floor((part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                        lbl.Text = "[DEMON] " .. enemy.Name .. " [" .. dist .. "m] [HP: " .. math.floor(enemy.Humanoid.Health) .. "]"
                    end
                end
            end
        end

        for part, bg in pairs(ActiveMobESP) do
            if not validParts[part] or not part.Parent then
                if bg and bg.Parent then bg:Destroy() end
                ActiveMobESP[part] = nil
            end
        end
    end)
end

-- 12. Player ESP Engine
local function UpdatePlayerESP()
    pcall(function()
        if not Toggles.PlayerESP then
            for plr, bg in pairs(ActivePlayerESP) do
                if bg and bg.Parent then bg:Destroy() end
            end
            ActivePlayerESP = {}
            return
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local char = plr.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    if not ActivePlayerESP[plr] then
                        local bg = Instance.new("BillboardGui")
                        bg.Name = "JunejoPlayerESP"
                        bg.Adornee = hrp
                        bg.Size = UDim2.new(0, 140, 0, 28)
                        bg.StudsOffset = Vector3.new(0, 3.5, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = hrp

                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(0, 220, 255)
                        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        lbl.TextStrokeTransparency = 0
                        lbl.TextSize = 10
                        lbl.Font = Enum.Font.GothamBold
                        lbl.Text = "[PLAYER] " .. plr.DisplayName
                        lbl.Parent = bg

                        ActivePlayerESP[plr] = bg
                    else
                        local lbl = ActivePlayerESP[plr]:FindFirstChildOfClass("TextLabel")
                        if lbl and isAlive() then
                            local dist = math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                            lbl.Text = "[PLAYER] " .. plr.DisplayName .. " [" .. dist .. "m]"
                        end
                    end
                end
            end
        end
    end)
end

-- 13. Breathing Trainers / NPC ESP Engine
local function UpdateTrainerESP()
    pcall(function()
        if not Toggles.TrainerESP then
            for root, bg in pairs(ActiveTrainerESP) do
                if bg and bg.Parent then bg:Destroy() end
            end
            ActiveTrainerESP = {}
            return
        end

        local npcsFolder = Workspace:FindFirstChild("ActiveNpcs") or Workspace:FindFirstChild("Npcs")
        local trainersList = {}

        if npcsFolder then
            for _, obj in ipairs(npcsFolder:GetChildren()) do
                table.insert(trainersList, obj)
            end
        end

        for _, obj in ipairs(trainersList) do
            if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
                local name = obj.Name:lower()
                local isTrainer = name:find("trainee") or name:find("trainer") or name:find("master") or name:find("sensei") or name:find("expert") or name:find("breathing") or name:find("rengu") or name:find("muzan") or name:find("kuzan") or name:find("suzume") or name:find("zurinyz")
                
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildWhichIsA("BasePart")
                if isTrainer and root then
                    if not ActiveTrainerESP[root] then
                        local bg = Instance.new("BillboardGui")
                        bg.Name = "JunejoTrainerESP"
                        bg.Adornee = root
                        bg.Size = UDim2.new(0, 150, 0, 28)
                        bg.StudsOffset = Vector3.new(0, 4, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = root

                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
                        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        lbl.TextStrokeTransparency = 0
                        lbl.TextSize = 10
                        lbl.Font = Enum.Font.GothamBold
                        lbl.Text = "[TRAINER] " .. obj.Name
                        lbl.Parent = bg

                        ActiveTrainerESP[root] = bg
                    else
                        local lbl = ActiveTrainerESP[root]:FindFirstChildOfClass("TextLabel")
                        if lbl and isAlive() then
                            local dist = math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                            lbl.Text = "[TRAINER] " .. obj.Name .. " [" .. dist .. "m]"
                        end
                    end
                end
            end
        end
    end)
end

-- ESP Master Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        UpdateQuestESP()
        UpdateMobESP()
        UpdatePlayerESP()
        UpdateTrainerESP()
    end
end)

-- WalkSpeed Heartbeat Loop
RunService.Heartbeat:Connect(function()
    pcall(function()
        if isAlive() and Toggles.WalkSpeed then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = CustomSpeedValue
            end
        end
    end)
end)

-- ====================================================
-- OFFICIAL UI 1: ULTRA SCRIPT HUB CLASSIC MATTE DARK
-- (280x250px with Perfectly Sized 5-Row Visible Scrolling Frame)
-- ====================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_Slayers2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif CoreGui then
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = UIContainer end
else
    ScreenGui.Parent = UIContainer
end

-- Main Container: 280px width, 250px height
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 250)
MainFrame.Position = UDim2.new(0.5, -140, 0.45, -125)
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

-- Header Bar (32px)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -44, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "SLAYERS 2"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -32, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "x"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 175)
CloseButton.TextSize = 15
CloseButton.Font = Enum.Font.GothamMedium
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local HeaderDivider = Instance.new("Frame")
HeaderDivider.Name = "HeaderDivider"
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position = UDim2.new(0, 0, 0, 32)
HeaderDivider.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
HeaderDivider.BorderSizePixel = 0
HeaderDivider.Parent = MainFrame

-- Smooth Dragging System (Desktop & Mobile Touch)
local dragging, dragInput, dragStart, startPos
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
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Content Scroll Frame: Exactly 180px height to display 5 items cleanly at a time
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"
ContentScroll.Size = UDim2.new(1, 0, 0, 180)
ContentScroll.Position = UDim2.new(0, 0, 0, 34)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 80)
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.ScrollingDirection = Enum.ScrollingDirection.Y
ContentScroll.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.Parent = ContentScroll

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 6)
ContentPadding.PaddingBottom = UDim.new(0, 6)
ContentPadding.PaddingLeft = UDim.new(0, 14)
ContentPadding.PaddingRight = UDim.new(0, 14)
ContentPadding.Parent = ContentScroll

-- Helper: Create 1-Click Action Button Row (28px height)
local function CreateActionRow(order, name, callback)
    local Row = Instance.new("Frame")
    Row.Name = name .. "Row"
    Row.Size = UDim2.new(1, 0, 0, 28)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.Parent = ContentScroll

    local Btn = Instance.new("TextButton")
    Btn.Name = "ActionBtn"
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Btn.BorderSizePixel = 0
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = Row

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(45, 45, 55)
    Stroke.Thickness = 1
    Stroke.Parent = Btn

    Btn.MouseButton1Click:Connect(callback)
    return Row
end

-- Helper: Create Feature Toggle Row (26px height, flat borderless row with rounded-square checkbox)
local function CreateToggleRow(order, name, key, onToggle)
    local Row = Instance.new("Frame")
    Row.Name = name .. "Row"
    Row.Size = UDim2.new(1, 0, 0, 26)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.Parent = ContentScroll

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, -28, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Checkbox = Instance.new("TextButton")
    Checkbox.Name = "Checkbox"
    Checkbox.Size = UDim2.new(0, 18, 0, 18)
    Checkbox.Position = UDim2.new(1, -18, 0.5, -9)
    Checkbox.BackgroundColor3 = Toggles[key] and Color3.fromRGB(35, 35, 45) or Color3.fromRGB(27, 27, 32)
    Checkbox.BorderSizePixel = 0
    Checkbox.Text = ""
    Checkbox.Parent = Row

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = Checkbox

    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color = Toggles[key] and Color3.fromRGB(80, 80, 100) or Color3.fromRGB(45, 45, 55)
    BoxStroke.Thickness = 1
    BoxStroke.Parent = Checkbox

    local CheckMark = Instance.new("Frame")
    CheckMark.Name = "CheckMark"
    CheckMark.Size = UDim2.new(0, 8, 0, 8)
    CheckMark.Position = UDim2.new(0.5, -4, 0.5, -4)
    CheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CheckMark.BorderSizePixel = 0
    CheckMark.Visible = Toggles[key]
    CheckMark.Parent = Checkbox

    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark

    local function ToggleState()
        Toggles[key] = not Toggles[key]
        CheckMark.Visible = Toggles[key]
        if Toggles[key] then
            Checkbox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            BoxStroke.Color = Color3.fromRGB(80, 80, 100)
        else
            Checkbox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
            BoxStroke.Color = Color3.fromRGB(45, 45, 55)
        end
        if onToggle then onToggle(Toggles[key]) end
        ShowToast(name, Toggles[key] and "Enabled" or "Disabled")
    end

    Checkbox.MouseButton1Click:Connect(ToggleState)
    return Row
end

-- ====================================================
-- ROWS DEFINITION (TOP 5 VISIBLE ON SCREEN FIRST!)
-- ====================================================

-- 1. [TOP ITEM 1] Instant Auto Get Up
CreateToggleRow(1, "Instant Auto Get Up", "InstantGetUp")

-- 2. [TOP ITEM 2] FullBright (EXPLICITLY 2ND NUMBER AS REQUESTED)
CreateToggleRow(2, "FullBright", "FullBright", function(enabled)
    UpdateFullBright(enabled)
end)

-- 3. [TOP ITEM 3] Hitbox Expander
CreateToggleRow(3, "Hitbox Expander", "HitboxExpander", function(enabled)
    if not enabled then UpdateHitboxExpander() end
end)

-- 4. [TOP ITEM 4] Teleport to Low Health Player
CreateActionRow(4, "Teleport to Low HP Player", function()
    TeleportToLowHealthPlayer()
end)

-- 5. [TOP ITEM 5] Teleport to Quest
CreateActionRow(5, "Teleport to Quest", function()
    TeleportToQuest()
end)

-- ====================================================
-- SCROLLABLE ROWS (SCROLL DOWN TO ACCESS)
-- ====================================================

-- 6. Teleport to Safe Zone
CreateActionRow(6, "Teleport to Safe Zone", function()
    TeleportToSafeZone()
end)

-- 7. Auto Farm Mobs / Demons
CreateToggleRow(7, "Auto Farm Mobs / Demons", "AutoFarmMobs")

-- 8. Auto Accept Quests
CreateToggleRow(8, "Auto Accept Quests", "AutoAcceptQuests")

-- 9. Fast Auto Attack
CreateToggleRow(9, "Fast Auto Attack", "FastAutoAttack")

-- 10. Fly Mode
CreateToggleRow(10, "Fly Mode", "Fly", function(enabled)
    UpdateFly(enabled)
end)

-- 11. Infinite Jump
CreateToggleRow(11, "Infinite Jump", "InfiniteJump")

-- 12. Quest ESP
CreateToggleRow(12, "Quest ESP", "QuestESP")

-- 13. Mob / Demon ESP
CreateToggleRow(13, "Mob / Demon ESP", "MobESP")

-- 14. Player ESP
CreateToggleRow(14, "Player ESP", "PlayerESP")

-- 15. Trainers / NPC ESP
CreateToggleRow(15, "Trainers / NPC ESP", "TrainerESP")

-- 16. WalkSpeed Row (Checkbox + Pill Stepper: [ - 50 + ])
local SpeedRow = Instance.new("Frame")
SpeedRow.Name = "SpeedRow"
SpeedRow.Size = UDim2.new(1, 0, 0, 26)
SpeedRow.BackgroundTransparency = 1
SpeedRow.LayoutOrder = 16
SpeedRow.Parent = ContentScroll

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(1, -125, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed"
SpeedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamMedium
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedRow

local SpeedCheckbox = Instance.new("TextButton")
SpeedCheckbox.Name = "SpeedCheckbox"
SpeedCheckbox.Size = UDim2.new(0, 18, 0, 18)
SpeedCheckbox.Position = UDim2.new(1, -120, 0.5, -9)
SpeedCheckbox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
SpeedCheckbox.BorderSizePixel = 0
SpeedCheckbox.Text = ""
SpeedCheckbox.Parent = SpeedRow

local SpeedBoxCorner = Instance.new("UICorner")
SpeedBoxCorner.CornerRadius = UDim.new(0, 4)
SpeedBoxCorner.Parent = SpeedCheckbox

local SpeedBoxStroke = Instance.new("UIStroke")
SpeedBoxStroke.Color = Color3.fromRGB(45, 45, 55)
SpeedBoxStroke.Thickness = 1
SpeedBoxStroke.Parent = SpeedCheckbox

local SpeedMark = Instance.new("Frame")
SpeedMark.Name = "SpeedMark"
SpeedMark.Size = UDim2.new(0, 8, 0, 8)
SpeedMark.Position = UDim2.new(0.5, -4, 0.5, -4)
SpeedMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedMark.BorderSizePixel = 0
SpeedMark.Visible = Toggles.WalkSpeed
SpeedMark.Parent = SpeedCheckbox

local SpeedMarkCorner = Instance.new("UICorner")
SpeedMarkCorner.CornerRadius = UDim.new(0, 2)
SpeedMarkCorner.Parent = SpeedMark

SpeedCheckbox.MouseButton1Click:Connect(function()
    Toggles.WalkSpeed = not Toggles.WalkSpeed
    SpeedMark.Visible = Toggles.WalkSpeed
    if Toggles.WalkSpeed then
        SpeedCheckbox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        SpeedBoxStroke.Color = Color3.fromRGB(80, 80, 100)
    else
        SpeedCheckbox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
        SpeedBoxStroke.Color = Color3.fromRGB(45, 45, 55)
        if isAlive() then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
    ShowToast("WalkSpeed", Toggles.WalkSpeed and ("Enabled (" .. CustomSpeedValue .. ")") or "Disabled")
end)

local StepperPill = Instance.new("Frame")
StepperPill.Name = "StepperPill"
StepperPill.Size = UDim2.new(0, 95, 0, 22)
StepperPill.Position = UDim2.new(1, -95, 0.5, -11)
StepperPill.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
StepperPill.BorderSizePixel = 0
StepperPill.Parent = SpeedRow

local PillCorner = Instance.new("UICorner")
PillCorner.CornerRadius = UDim.new(0, 5)
PillCorner.Parent = StepperPill

local PillStroke = Instance.new("UIStroke")
PillStroke.Color = Color3.fromRGB(45, 45, 55)
PillStroke.Thickness = 1
PillStroke.Parent = StepperPill

local MinusBtn = Instance.new("TextButton")
MinusBtn.Name = "MinusBtn"
MinusBtn.Size = UDim2.new(0, 26, 1, 0)
MinusBtn.BackgroundTransparency = 1
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
MinusBtn.TextSize = 13
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Parent = StepperPill

local SpeedValLbl = Instance.new("TextLabel")
SpeedValLbl.Name = "SpeedValLbl"
SpeedValLbl.Size = UDim2.new(1, -52, 1, 0)
SpeedValLbl.Position = UDim2.new(0, 26, 0, 0)
SpeedValLbl.BackgroundTransparency = 1
SpeedValLbl.Text = tostring(CustomSpeedValue)
SpeedValLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedValLbl.TextSize = 11
SpeedValLbl.Font = Enum.Font.GothamBold
SpeedValLbl.Parent = StepperPill

local PlusBtn = Instance.new("TextButton")
PlusBtn.Name = "PlusBtn"
PlusBtn.Size = UDim2.new(0, 26, 1, 0)
PlusBtn.Position = UDim2.new(1, -26, 0, 0)
PlusBtn.BackgroundTransparency = 1
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
PlusBtn.TextSize = 13
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Parent = StepperPill

MinusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.max(16, CustomSpeedValue - 10)
    SpeedValLbl.Text = tostring(CustomSpeedValue)
    if Toggles.WalkSpeed and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = CustomSpeedValue end
    end
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(250, CustomSpeedValue + 10)
    SpeedValLbl.Text = tostring(CustomSpeedValue)
    if Toggles.WalkSpeed and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = CustomSpeedValue end
    end
end)

-- Mandatory Centered Branding Footer (UI 1 Standard)
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 34)
Footer.Position = UDim2.new(0, 0, 1, -34)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterDivider = Instance.new("Frame")
FooterDivider.Name = "FooterDivider"
FooterDivider.Size = UDim2.new(1, 0, 0, 1)
FooterDivider.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
FooterDivider.BorderSizePixel = 0
FooterDivider.Parent = Footer

local HubTitle = Instance.new("TextLabel")
HubTitle.Name = "HubTitle"
HubTitle.Size = UDim2.new(1, 0, 0, 15)
HubTitle.Position = UDim2.new(0, 0, 0, 2)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "ULTRA SCRIPT HUB"
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 11
HubTitle.Font = Enum.Font.GothamBold
HubTitle.Parent = Footer

local CreatorSubtitle = Instance.new("TextLabel")
CreatorSubtitle.Name = "CreatorSubtitle"
CreatorSubtitle.Size = UDim2.new(1, 0, 0, 14)
CreatorSubtitle.Position = UDim2.new(0, 0, 0, 17)
CreatorSubtitle.BackgroundTransparency = 1
CreatorSubtitle.Text = "Made by Junejo"
CreatorSubtitle.TextColor3 = Color3.fromRGB(136, 136, 153)
CreatorSubtitle.TextSize = 9
CreatorSubtitle.Font = Enum.Font.GothamMedium
CreatorSubtitle.Parent = Footer

ShowToast("ULTRA SCRIPT HUB", "Slayers 2 V3.5 Loaded!")
print("[Junejo Hub] Slayers 2 V3.5 initialized with FullBright & Fly!")
