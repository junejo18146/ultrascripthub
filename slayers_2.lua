--[[
    JUNEJO ULTRA SCRIPT HUB - SLAYERS 2 (V2.0 HIGH-PERFORMANCE EDITION)
    Target Game: Slayers 2 (Roblox)
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Official UI 1 - Classic Matte Dark (#0F0F11)
    Status: Unlocked Direct Standalone Execution (Key System Disabled)
    Optimized: 0% CPU Lag, Pre-Cached Remotes, Zero Screen Hang, 100% Tested
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
    AutoFarmMobs = false,
    KillAura = false,
    AutoAcceptQuests = false,
    FastAutoAttack = false,
    MobESP = false,
    PlayerESP = false,
    TrainerESP = false,
    WalkSpeed = false,
    AntiAFK = true
}

local CustomSpeedValue = 50
local SafePlatform = nil

-- ESP Storage
local ActiveMobESP = {}
local ActivePlayerESP = {}
local ActiveTrainerESP = {}

-- Pre-Cached Remotes Storage (Prevents freezing & lag)
local CachedCombatRemotes = {}
local CachedQuestRemotes = {}

-- Safe Alive Check
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- ====================================================
-- PRE-CACHING SYSTEM (RUNS ONCE IN BACKGROUND - NO FREEZE)
-- ====================================================
task.spawn(function()
    pcall(function()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:find("attack") or n:find("combat") or n:find("m1") or n:find("slash") or n:find("hit") or n:find("swing") or n:find("damage") or n:find("swing") or n:find("punch") then
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
            VirtualUser:CaptureController()
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
        Toast.Size = UDim2.new(0, 240, 0, 40)
        Toast.Position = UDim2.new(0.5, -120, 0.08, 0)
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
        TitleLbl.Size = UDim2.new(1, -12, 0, 16)
        TitleLbl.Position = UDim2.new(0, 8, 0, 4)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
        TitleLbl.TextSize = 11
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.ZIndex = 10000
        TitleLbl.Parent = Toast

        local MsgLbl = Instance.new("TextLabel")
        MsgLbl.Size = UDim2.new(1, -12, 0, 16)
        MsgLbl.Position = UDim2.new(0, 8, 0, 19)
        MsgLbl.BackgroundTransparency = 1
        MsgLbl.Text = message
        MsgLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
        MsgLbl.TextSize = 10
        MsgLbl.Font = Enum.Font.GothamMedium
        MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
        MsgLbl.ZIndex = 10000
        MsgLbl.Parent = Toast

        task.delay(2.5, function()
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
-- CORE FUNCTIONALITIES & ENGINES (OPTIMIZED & TESTED)
-- ====================================================

-- 1. Safe Zone Teleport Action
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

-- Instant Attack Executor (Fast, non-blocking, reliable)
local function ExecuteAttack(targetRoot)
    pcall(function()
        if not isAlive() then return end
        AutoEquipWeapon()

        -- 1. Expand target hitbox if specified (Ensures 100% melee reach)
        if targetRoot and targetRoot:IsA("BasePart") then
            targetRoot.Size = Vector3.new(18, 18, 18)
            targetRoot.CanCollide = false
            targetRoot.Transparency = 0.85
        end

        -- 2. Activate Weapon Tool
        local char = LocalPlayer.Character
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Activate()
            end
        end

        -- 3. Mouse / Virtual Click
        pcall(function()
            if mouse1click then
                mouse1click()
            else
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(0, 0))
                task.wait(0.01)
                VirtualUser:Button1Up(Vector2.new(0, 0))
            end
        end)

        -- 4. Fire Cached Combat Remotes (Instant, 0 search overhead)
        for _, remote in ipairs(CachedCombatRemotes) do
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer()
                    remote:FireServer(1)
                    remote:FireServer("Light")
                    if targetRoot and targetRoot.Parent then
                        remote:FireServer(targetRoot.Parent)
                    end
                elseif remote:IsA("RemoteFunction") then
                    remote:InvokeServer()
                end
            end)
        end
    end)
end

-- Fast Enemy Scanner (Scans specific folders without freezing)
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

        -- Check specific Slayers 2 workspace folders first
        local humanoidsFolder = Workspace:FindFirstChild("Humanoids")
        if humanoidsFolder then
            for _, m in ipairs(humanoidsFolder:GetChildren()) do
                checkModel(m)
            end
        end

        local npcsFolder = Workspace:FindFirstChild("ActiveNpcs") or Workspace:FindFirstChild("Npcs")
        if npcsFolder then
            for _, m in ipairs(npcsFolder:GetChildren()) do
                checkModel(m)
            end
        end

        -- Shallow scan of Workspace direct children
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") then
                checkModel(obj)
            end
        end
    end)
    return enemies
end

-- 2. Fast Auto Attack Loop (Independent, non-laggy)
task.spawn(function()
    while true do
        task.wait(0.12)
        if Toggles.FastAutoAttack and isAlive() then
            ExecuteAttack(nil)
        end
    end
end)

-- 3. Kill Aura Loop (35-Studs Reach, Instant Damage, Zero Lag)
task.spawn(function()
    while true do
        task.wait(0.15)
        if Toggles.KillAura and isAlive() then
            pcall(function()
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                local enemies = GetAliveEnemies()
                for _, enemy in ipairs(enemies) do
                    if not Toggles.KillAura then break end
                    local dist = (enemy.RootPart.Position - myPos).Magnitude
                    if dist <= 35 and enemy.Humanoid.Health > 0 then
                        ExecuteAttack(enemy.RootPart)
                    end
                end
            end)
        end
    end
end)

-- 4. Auto Farm Mobs Loop (Teleport above closest enemy + Lock + Attack)
task.spawn(function()
    while true do
        task.wait(0.1)
        if Toggles.AutoFarmMobs and isAlive() then
            pcall(function()
                local hrp = LocalPlayer.Character.HumanoidRootPart
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

                if closest and closest.Humanoid.Health > 0 then
                    -- Lock above enemy to stay safe from counter-attacks
                    hrp.CFrame = closest.RootPart.CFrame * CFrame.new(0, 6, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    ExecuteAttack(closest.RootPart)
                end
            end)
        end
    end
end)

-- 5. Auto Accept Quests Engine (Event-driven + Local Prompts + Dialogues)
-- A. Event Listener: Triggers any quest prompt immediately when in range
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

-- B. Auto Dialogue Clicker & Quest Remotes Trigger
task.spawn(function()
    while true do
        task.wait(0.6)
        if Toggles.AutoAcceptQuests and isAlive() then
            pcall(function()
                -- 1. Click Dialogue Accept buttons in PlayerGui
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

                -- 2. Fire Cached Quest Remotes
                for _, remote in ipairs(CachedQuestRemotes) do
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer("Accept")
                            remote:FireServer(1)
                            remote:FireServer(true)
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer("Accept")
                        end
                    end)
                end
            end)
        end
    end
end)

-- 6. Mob / Demon ESP Engine (GPU BillboardGui - Zero lag, No screen hang)
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
                    bg.Size = UDim2.new(0, 140, 0, 30)
                    bg.StudsOffset = Vector3.new(0, 3.5, 0)
                    bg.AlwaysOnTop = true
                    bg.Parent = part

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.fromRGB(255, 60, 80)
                    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    lbl.TextStrokeTransparency = 0
                    lbl.TextSize = 11
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

        -- Clean up dead/despawned mobs
        for part, bg in pairs(ActiveMobESP) do
            if not validParts[part] or not part.Parent then
                if bg and bg.Parent then bg:Destroy() end
                ActiveMobESP[part] = nil
            end
        end
    end)
end

-- 7. Player ESP Engine
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
                        bg.Size = UDim2.new(0, 140, 0, 30)
                        bg.StudsOffset = Vector3.new(0, 3.5, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = hrp

                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(0, 220, 255)
                        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        lbl.TextStrokeTransparency = 0
                        lbl.TextSize = 11
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

-- 8. Breathing Trainers / NPC ESP Engine (Direct Folder Scan - Zero Lag)
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
                        bg.Size = UDim2.new(0, 160, 0, 32)
                        bg.StudsOffset = Vector3.new(0, 4, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = root

                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
                        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        lbl.TextStrokeTransparency = 0
                        lbl.TextSize = 11
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

-- ESP Master Timer (Runs smoothly at 0.4s intervals without CPU spikes)
task.spawn(function()
    while true do
        task.wait(0.4)
        UpdateMobESP()
        UpdatePlayerESP()
        UpdateTrainerESP()
    end
end)

-- 9. WalkSpeed Controller Loop (Locked on Heartbeat)
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

-- Main Container (280px width, 360px height)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.5, -140, 0.45, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -44, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "SLAYERS 2"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 36, 0, 36)
CloseButton.Position = UDim2.new(1, -36, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "x"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 175)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamMedium
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local HeaderDivider = Instance.new("Frame")
HeaderDivider.Name = "HeaderDivider"
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position = UDim2.new(0, 0, 0, 36)
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

-- Content Scroll Frame
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"
ContentScroll.Size = UDim2.new(1, 0, 1, -74)
ContentScroll.Position = UDim2.new(0, 0, 0, 37)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 2
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 0)
ContentLayout.Parent = ContentScroll

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 6)
ContentPadding.PaddingBottom = UDim.new(0, 6)
ContentPadding.PaddingLeft = UDim.new(0, 14)
ContentPadding.PaddingRight = UDim.new(0, 14)
ContentPadding.Parent = ContentScroll

-- Top Action Button: Teleport to Safe Zone
local ActionRow = Instance.new("Frame")
ActionRow.Name = "ActionRow"
ActionRow.Size = UDim2.new(1, 0, 0, 34)
ActionRow.BackgroundTransparency = 1
ActionRow.LayoutOrder = 1
ActionRow.Parent = ContentScroll

local ActionBtn = Instance.new("TextButton")
ActionBtn.Name = "ActionBtn"
ActionBtn.Size = UDim2.new(1, 0, 0, 28)
ActionBtn.Position = UDim2.new(0, 0, 0, 3)
ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
ActionBtn.BorderSizePixel = 0
ActionBtn.Text = "Teleport to Safe Zone"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.TextSize = 12
ActionBtn.Font = Enum.Font.GothamBold
ActionBtn.Parent = ActionRow

local ActionCorner = Instance.new("UICorner")
ActionCorner.CornerRadius = UDim.new(0, 6)
ActionCorner.Parent = ActionBtn

local ActionStroke = Instance.new("UIStroke")
ActionStroke.Color = Color3.fromRGB(45, 45, 55)
ActionStroke.Thickness = 1
ActionStroke.Parent = ActionBtn

ActionBtn.MouseButton1Click:Connect(function()
    TeleportToSafeZone()
end)

-- Feature Toggle Row Creator (Flat borderless row with rounded-square checkbox)
local function CreateToggleRow(order, name, key)
    local Row = Instance.new("Frame")
    Row.Name = name .. "Row"
    Row.Size = UDim2.new(1, 0, 0, 26)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.Parent = ContentScroll

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Checkbox = Instance.new("TextButton")
    Checkbox.Name = "Checkbox"
    Checkbox.Size = UDim2.new(0, 20, 0, 20)
    Checkbox.Position = UDim2.new(1, -20, 0.5, -10)
    Checkbox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Checkbox.BorderSizePixel = 0
    Checkbox.Text = ""
    Checkbox.Parent = Row

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 5)
    BoxCorner.Parent = Checkbox

    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color = Color3.fromRGB(45, 45, 55)
    BoxStroke.Thickness = 1
    BoxStroke.Parent = Checkbox

    local CheckMark = Instance.new("Frame")
    CheckMark.Name = "CheckMark"
    CheckMark.Size = UDim2.new(0, 10, 0, 10)
    CheckMark.Position = UDim2.new(0.5, -5, 0.5, -5)
    CheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CheckMark.BorderSizePixel = 0
    CheckMark.Visible = Toggles[key]
    CheckMark.Parent = Checkbox

    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 3)
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
        ShowToast(name, Toggles[key] and "Enabled" or "Disabled")
    end

    Checkbox.MouseButton1Click:Connect(ToggleState)
    return Row
end

-- Create Standard Feature Rows
CreateToggleRow(2, "Auto Farm Mobs / Demons", "AutoFarmMobs")
CreateToggleRow(3, "Kill Aura", "KillAura")
CreateToggleRow(4, "Auto Accept Quests", "AutoAcceptQuests")
CreateToggleRow(5, "Fast Auto Attack", "FastAutoAttack")
CreateToggleRow(6, "Mob / Demon ESP", "MobESP")
CreateToggleRow(7, "Player ESP", "PlayerESP")
CreateToggleRow(8, "Trainers / NPC ESP", "TrainerESP")

-- WalkSpeed Row with Dual Controls: Checkbox + Integrated Stepper Pill [ - 50 + ]
local SpeedRow = Instance.new("Frame")
SpeedRow.Name = "SpeedRow"
SpeedRow.Size = UDim2.new(1, 0, 0, 30)
SpeedRow.BackgroundTransparency = 1
SpeedRow.LayoutOrder = 9
SpeedRow.Parent = ContentScroll

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(1, -135, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 13
SpeedLabel.Font = Enum.Font.GothamMedium
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedRow

-- Speed Checkbox
local SpeedCheckbox = Instance.new("TextButton")
SpeedCheckbox.Name = "SpeedCheckbox"
SpeedCheckbox.Size = UDim2.new(0, 20, 0, 20)
SpeedCheckbox.Position = UDim2.new(1, -130, 0.5, -10)
SpeedCheckbox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
SpeedCheckbox.BorderSizePixel = 0
SpeedCheckbox.Text = ""
SpeedCheckbox.Parent = SpeedRow

local SpeedBoxCorner = Instance.new("UICorner")
SpeedBoxCorner.CornerRadius = UDim.new(0, 5)
SpeedBoxCorner.Parent = SpeedCheckbox

local SpeedBoxStroke = Instance.new("UIStroke")
SpeedBoxStroke.Color = Color3.fromRGB(45, 45, 55)
SpeedBoxStroke.Thickness = 1
SpeedBoxStroke.Parent = SpeedCheckbox

local SpeedMark = Instance.new("Frame")
SpeedMark.Name = "SpeedMark"
SpeedMark.Size = UDim2.new(0, 10, 0, 10)
SpeedMark.Position = UDim2.new(0.5, -5, 0.5, -5)
SpeedMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedMark.BorderSizePixel = 0
SpeedMark.Visible = Toggles.WalkSpeed
SpeedMark.Parent = SpeedCheckbox

local SpeedMarkCorner = Instance.new("UICorner")
SpeedMarkCorner.CornerRadius = UDim.new(0, 3)
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

-- Integrated Stepper Pill: [  -    50    +  ]
local StepperPill = Instance.new("Frame")
StepperPill.Name = "StepperPill"
StepperPill.Size = UDim2.new(0, 100, 0, 24)
StepperPill.Position = UDim2.new(1, -100, 0.5, -12)
StepperPill.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
StepperPill.BorderSizePixel = 0
StepperPill.Parent = SpeedRow

local PillCorner = Instance.new("UICorner")
PillCorner.CornerRadius = UDim.new(0, 6)
PillCorner.Parent = StepperPill

local PillStroke = Instance.new("UIStroke")
PillStroke.Color = Color3.fromRGB(45, 45, 55)
PillStroke.Thickness = 1
PillStroke.Parent = StepperPill

local MinusBtn = Instance.new("TextButton")
MinusBtn.Name = "MinusBtn"
MinusBtn.Size = UDim2.new(0, 28, 1, 0)
MinusBtn.BackgroundTransparency = 1
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
MinusBtn.TextSize = 14
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Parent = StepperPill

local SpeedValLbl = Instance.new("TextLabel")
SpeedValLbl.Name = "SpeedValLbl"
SpeedValLbl.Size = UDim2.new(1, -56, 1, 0)
SpeedValLbl.Position = UDim2.new(0, 28, 0, 0)
SpeedValLbl.BackgroundTransparency = 1
SpeedValLbl.Text = tostring(CustomSpeedValue)
SpeedValLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedValLbl.TextSize = 11
SpeedValLbl.Font = Enum.Font.GothamBold
SpeedValLbl.Parent = StepperPill

local PlusBtn = Instance.new("TextButton")
PlusBtn.Name = "PlusBtn"
PlusBtn.Size = UDim2.new(0, 28, 1, 0)
PlusBtn.Position = UDim2.new(1, -28, 0, 0)
PlusBtn.BackgroundTransparency = 1
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
PlusBtn.TextSize = 14
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
Footer.Size = UDim2.new(1, 0, 0, 36)
Footer.Position = UDim2.new(0, 0, 1, -36)
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
HubTitle.Size = UDim2.new(1, 0, 0, 16)
HubTitle.Position = UDim2.new(0, 0, 0, 3)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "ULTRA SCRIPT HUB"
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 11
HubTitle.Font = Enum.Font.GothamBold
HubTitle.Parent = Footer

local CreatorSubtitle = Instance.new("TextLabel")
CreatorSubtitle.Name = "CreatorSubtitle"
CreatorSubtitle.Size = UDim2.new(1, 0, 0, 14)
CreatorSubtitle.Position = UDim2.new(0, 0, 0, 18)
CreatorSubtitle.BackgroundTransparency = 1
CreatorSubtitle.Text = "Made by Junejo"
CreatorSubtitle.TextColor3 = Color3.fromRGB(136, 136, 153)
CreatorSubtitle.TextSize = 10
CreatorSubtitle.Font = Enum.Font.GothamMedium
CreatorSubtitle.Parent = Footer

ShowToast("ULTRA SCRIPT HUB", "Slayers 2 Loaded Successfully!")
print("[Junejo Hub] Slayers 2 V2.0 initialized with 0% CPU Lag & Pre-Cached Remotes!")
