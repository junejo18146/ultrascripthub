--[[
    ========================================================================
    JUNEJO ULTRA SCRIPT HUB - JUMP TO STEAL SCP MONSTERS
    ========================================================================
    Author: Made by Junejo (junejo18146)
    Target Game: Jump To Steal SCP Monsters (Roblox)
    Repository: junejo18146/ultrascripthub
    File: jump_to_steal_scp.lua
    UI Standard: Junejo Classic Dark UI (#0F0F11) - Flat & Borderless Standard
    
    Features Included (All Original Core Mechanics 100% Preserved):
        1. Instant Steal (1-Click Action)
        2. Auto Steal Loop (Lag-Free 2-Teleport Sequence)
        3. Zone Selector (Auto Highest & All Floor Zones)
        4. Auto Collect Cash (CollectPads & Remote Sweep)
        5. Auto Upgrade Jump (Speed & Jump Upgrades)
        6. Auto Upgrade Capacity (Carry Limit Multiplier)
        7. Auto Rebirth (Automatic Prestige Engine)
        8. Auto Open Lucky Blocks (Stands Sweep)
        9. Anti-Guard Godmode (Disable Guardian Touch)
        10. Monster ESP (Rarity Neon Highlights & Billboard Tags)
        11. Guard ESP (Red Threat Highlights & Name Tags)
        12. Player ESP & Health (Live HP & Distance Wallhack)
        13. WalkSpeed Boost + Integrated Pill Controller (- / +: 16 to 300)
        14. Infinite Jump (Continuous Multi-Jump)
        15. Fly Mode (Smooth 3D Flight)
        16. Noclip Mode (Phase Through Barriers & Doors)
        17. Anti-AFK Engine (20-min Disconnect Shield)
    ========================================================================
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- =================================================================
-- FAILSAFE REMOTE RESOLVER
-- =================================================================
local RemotesCache = {}
local function GetRemote(name)
    if RemotesCache[name] and RemotesCache[name].Parent then
        return RemotesCache[name]
    end

    local shared = ReplicatedStorage:FindFirstChild("SharedModules")
    local net = shared and shared:FindFirstChild("Network")
    local remotes = net and net:FindFirstChild("Remotes")
    if remotes and remotes:FindFirstChild(name) then
        RemotesCache[name] = remotes[name]
        return remotes[name]
    end

    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj.Name == name and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
            RemotesCache[name] = obj
            return obj
        end
    end
    return nil
end

-- Global States & Toggles
local Toggles = {
    AutoStealLoop = false,
    AutoCollectCash = false,
    AutoUpgradeJump = false,
    AutoUpgradeCapacity = false,
    AutoRebirth = false,
    AutoOpenBlocks = false,
    AntiGuard = true,
    MonsterESP = false,
    GuardESP = false,
    PlayerESP = false,
    WalkSpeedBoost = false,
    InfiniteJump = false,
    FlyMode = false,
    Noclip = false,
    AntiAFK = true
}

local CustomSpeedValue = 24
local SelectedZone = "Auto (Highest)"

-- Rarity Priority & Color Configs
local RarityPriority = {
    ["LIMITED"] = 15, ["Japan"] = 14, ["Icons"] = 13, ["Spain"] = 12,
    ["Champions"] = 11, ["OG"] = 10, ["Exclusive"] = 9, ["Divine"] = 8,
    ["Slime God"] = 7, ["Secret"] = 6, ["Mythic"] = 5, ["Legendary"] = 4,
    ["Epic"] = 3, ["Rare"] = 2, ["Common"] = 1
}

local RarityColors = {
    ["Common"] = Color3.fromRGB(176, 178, 182),
    ["Rare"] = Color3.fromRGB(88, 214, 96),
    ["Epic"] = Color3.fromRGB(118, 150, 255),
    ["Legendary"] = Color3.fromRGB(214, 72, 255),
    ["Mythic"] = Color3.fromRGB(255, 174, 62),
    ["Secret"] = Color3.fromRGB(120, 138, 175),
    ["Slime God"] = Color3.fromRGB(255, 214, 92),
    ["Divine"] = Color3.fromRGB(255, 235, 130),
    ["OG"] = Color3.fromRGB(255, 220, 100),
    ["Champions"] = Color3.fromRGB(255, 90, 90),
    ["Spain"] = Color3.fromRGB(255, 120, 50),
    ["Icons"] = Color3.fromRGB(200, 100, 255),
    ["Japan"] = Color3.fromRGB(255, 80, 120),
    ["Exclusive"] = Color3.fromRGB(0, 230, 255),
    ["LIMITED"] = Color3.fromRGB(255, 50, 80)
}

local TowerZones = {
    "Auto (Highest)",
    "OG (Floor 8)",
    "Slime God (Floor 7)",
    "Secret (Floor 6)",
    "Mythic (Floor 5)",
    "Legendary (Floor 4)",
    "Epic (Floor 3)",
    "Rare (Floor 2)",
    "Common (Floor 1)"
}

-- Safe Parent GUI Resolver
local function GetSafeGuiParent()
    if gethui then
        local s, r = pcall(gethui)
        if s and r then return r end
    end
    local s, _ = pcall(function() local _ = CoreGui.Name end)
    if s then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Cleanup previous UI instances
pcall(function()
    local names = {"JunejoHubUI_SCP", "Badshah_SCP_Master_UI", "JunejoHubUI"}
    for _, name in ipairs(names) do
        local old = GetSafeGuiParent():FindFirstChild(name)
        if old then old:Destroy() end
    end
end)

-- =================================================================
-- BUTTER-SMOOTH WALKSPEED SYSTEM (Zero Stutter / Zero Rubberband)
-- =================================================================
local function ApplySmoothSpeed()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Toggles.WalkSpeedBoost then
                if hum.WalkSpeed ~= CustomSpeedValue then
                    hum.WalkSpeed = CustomSpeedValue
                end
                LocalPlayer:SetAttribute("CarrySpeedMulti", CustomSpeedValue / 24)
            else
                hum.WalkSpeed = 16
                LocalPlayer:SetAttribute("CarrySpeedMulti", 1)
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 5)
    task.wait(0.2)
    ApplySmoothSpeed()
end)

RunService.Heartbeat:Connect(function()
    if Toggles.WalkSpeedBoost then
        ApplySmoothSpeed()
    end
end)

-- =================================================================
-- ROBUST PLAYER BASE (PLOT) DETECTOR
-- =================================================================
local CachedPlot = nil
local function GetMyPlot()
    if CachedPlot and CachedPlot.Parent == Workspace:FindFirstChild("Plots") then
        local o = CachedPlot:FindFirstChild("owner")
        if o and (o.Value == LocalPlayer.Name or o.Value == tostring(LocalPlayer.UserId)) then
            return CachedPlot
        end
    end

    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local o = plot:FindFirstChild("owner")
            if o and (o.Value == LocalPlayer.Name or o.Value == tostring(LocalPlayer.UserId)) then
                CachedPlot = plot
                return plot
            end

            local sign = plot:FindFirstChild("OwnerSign")
            if sign then
                for _, lbl in ipairs(sign:GetDescendants()) do
                    if lbl:IsA("TextLabel") and (lbl.Text == LocalPlayer.Name or lbl.Text == LocalPlayer.DisplayName) then
                        CachedPlot = plot
                        return plot
                    end
                end
            end
        end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local nearest = nil
            local dist = 9999
            for _, plot in ipairs(plots:GetChildren()) do
                local base = plot:FindFirstChild("Base")
                if base and base:IsA("BasePart") then
                    local d = (hrp.Position - base.Position).Magnitude
                    if d < dist and d < 130 then
                        dist = d
                        nearest = plot
                    end
                end
            end
            if nearest then
                CachedPlot = nearest
                return nearest
            end
        end
    end
    return nil
end

local function GetBaseCFrame()
    local plot = GetMyPlot()
    if plot then
        local base = plot:FindFirstChild("Base")
        if base then
            local tpAttach = base:FindFirstChild("Teleport")
            if tpAttach and tpAttach:IsA("Attachment") then
                return tpAttach.WorldCFrame + Vector3.new(0, 3, 0)
            end
            return base.CFrame + Vector3.new(0, 3.5, 0)
        end
        return plot:GetPivot() + Vector3.new(0, 3.5, 0)
    end
    return CFrame.new(318, 5, 338)
end

-- =================================================================
-- UNIVERSAL PROXIMITY PROMPT TRIGGER
-- =================================================================
local function UniversalTriggerPrompt(prompt)
    if not prompt or not prompt.Parent then return end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 99999
    end)
    if fireproximityprompt then
        pcall(function() fireproximityprompt(prompt, 0) end)
        pcall(function() fireproximityprompt(prompt) end)
    end
    pcall(function()
        prompt:InputHoldBegin()
        task.wait(0.06)
        prompt:InputHoldEnd()
    end)
end

-- =================================================================
-- FIND BEST MONSTER IN ZONE
-- =================================================================
local function GetBestMonsterInZone(zoneName)
    local liveFolder = Workspace:FindFirstChild("Live")
    local slimesFolder = liveFolder and liveFolder:FindFirstChild("Slimes")
    if not slimesFolder then return nil end

    local slimes = slimesFolder:GetChildren()
    if #slimes == 0 then return nil end

    local candidates = {}

    for _, slime in ipairs(slimes) do
        if slime:IsA("Model") and slime:FindFirstChild("RootPart") then
            local root = slime.RootPart
            local prompt = root:FindFirstChild("StealPrompt") or slime:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt.Enabled then
                local rarity = slime:GetAttribute("rarity") or "Common"
                local rootY = root.Position.Y

                local isMatch = false
                if zoneName == "Auto (Highest)" then
                    isMatch = true
                elseif zoneName:find("OG") and (rarity == "OG" or rootY > 800) then
                    isMatch = true
                elseif zoneName:find("Slime God") and (rarity == "Slime God" or (rootY >= 550 and rootY <= 800)) then
                    isMatch = true
                elseif zoneName:find("Secret") and (rarity == "Secret" or (rootY >= 350 and rootY < 550)) then
                    isMatch = true
                elseif zoneName:find("Mythic") and (rarity == "Mythic" or (rootY >= 210 and rootY < 350)) then
                    isMatch = true
                elseif zoneName:find("Legendary") and (rarity == "Legendary" or (rootY >= 105 and rootY < 210)) then
                    isMatch = true
                elseif zoneName:find("Epic") and (rarity == "Epic" or (rootY >= 45 and rootY < 105)) then
                    isMatch = true
                elseif zoneName:find("Rare") and (rarity == "Rare" or (rootY >= 12 and rootY < 45)) then
                    isMatch = true
                elseif zoneName:find("Common") and (rarity == "Common" or rootY < 12) then
                    isMatch = true
                end

                if isMatch then
                    local priority = RarityPriority[rarity] or 1
                    table.insert(candidates, {
                        Model = slime,
                        Root = root,
                        Prompt = prompt,
                        Priority = priority,
                        Y = rootY,
                        Name = slime.Name,
                        Rarity = rarity
                    })
                end
            end
        end
    end

    if #candidates == 0 then return nil end

    table.sort(candidates, function(a, b)
        if a.Priority == b.Priority then
            return a.Y > b.Y
        end
        return a.Priority > b.Priority
    end)

    return candidates[1]
end

-- =================================================================
-- LAG-FREE AUTO STEAL (2 Teleports: Monster -> Base Stand)
-- =================================================================
local IsStealingBusy = false

local function StealFromZone(zoneName)
    if IsStealingBusy then return end
    IsStealingBusy = true

    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local target = GetBestMonsterInZone(zoneName)
        if not target then
            target = GetBestMonsterInZone("Auto (Highest)")
        end

        if not target or not target.Root or not target.Prompt then return end

        -- 1. Teleport to monster directly (0-Velocity Smooth Teleport)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = target.Root.CFrame + Vector3.new(0, 1.2, 0)
        hrp.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.2)

        -- 2. Trigger Grab Prompt
        UniversalTriggerPrompt(target.Prompt)
        task.wait(0.45)

        -- 3. Teleport back to Base directly
        local baseCF = GetBaseCFrame()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = baseCF
        hrp.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.25)

        -- 4. Deposit on Stand
        local placeRemote = GetRemote("Place Slime")
        if placeRemote then
            for i = 1, 10 do
                placeRemote:FireServer(tostring(i))
            end
        end

        local plot = GetMyPlot()
        if plot and plot:FindFirstChild("Stands") then
            for _, stand in ipairs(plot.Stands:GetChildren()) do
                local holder = stand:FindFirstChild("Main") and stand.Main:FindFirstChild("Holder")
                local placePrompt = holder and holder:FindFirstChild("Place")
                if placePrompt and placePrompt.Enabled and (stand:GetPivot().Position - hrp.Position).Magnitude < 16 then
                    UniversalTriggerPrompt(placePrompt)
                    break
                end
            end
        else
            local dropRemote = GetRemote("Drop Slime")
            if dropRemote then
                dropRemote:FireServer()
            end
        end

        task.wait(0.2)
    end)

    IsStealingBusy = false
end

-- =================================================================
-- CONTINUOUS FEATURE LOOPS
-- =================================================================

-- 1. Continuous Auto Steal Loop
task.spawn(function()
    while true do
        task.wait(0.4)
        if Toggles.AutoStealLoop and not IsStealingBusy then
            StealFromZone(SelectedZone)
        end
    end
end)

-- 2. Auto Collect Cash
task.spawn(function()
    while true do
        task.wait(1.0)
        if Toggles.AutoCollectCash then
            pcall(function()
                local plot = GetMyPlot()
                local collectRemote = GetRemote("Collect Earnings")
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if plot and plot:FindFirstChild("CollectPads") then
                    for _, pad in ipairs(plot.CollectPads:GetChildren()) do
                        if not Toggles.AutoCollectCash then break end
                        if collectRemote then
                            collectRemote:FireServer(pad.Name)
                        end
                        local topPart = pad:FindFirstChild("Top")
                        if topPart and hrp and firetouchinterest then
                            firetouchinterest(hrp, topPart, 0)
                            task.wait(0.005)
                            firetouchinterest(hrp, topPart, 1)
                        end
                    end
                else
                    if collectRemote then
                        for i = 1, 100 do
                            if not Toggles.AutoCollectCash then break end
                            collectRemote:FireServer(tostring(i))
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. Auto Upgrade Jump
task.spawn(function()
    while true do
        task.wait(1.0)
        if Toggles.AutoUpgradeJump then
            pcall(function()
                local buyRemote = GetRemote("Buy Speed Upgrade")
                if buyRemote then
                    buyRemote:FireServer(1)
                    buyRemote:FireServer(2)
                end
            end)
        end
    end
end)

-- 4. Auto Upgrade Capacity
task.spawn(function()
    while true do
        task.wait(1.0)
        if Toggles.AutoUpgradeCapacity then
            pcall(function()
                local carryRemote = GetRemote("Upgrade Carry Limit")
                if carryRemote then
                    carryRemote:FireServer()
                end
            end)
        end
    end
end)

-- 5. Auto Rebirth
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.AutoRebirth then
            pcall(function()
                local rebirthRemote = GetRemote("Rebirth")
                if rebirthRemote then
                    rebirthRemote:FireServer()
                end
            end)
        end
    end
end)

-- 6. Auto Open Blocks
task.spawn(function()
    while true do
        task.wait(1.2)
        if Toggles.AutoOpenBlocks then
            pcall(function()
                local openRemote = GetRemote("Open Lucky Block")
                local plot = GetMyPlot()
                if openRemote and plot and plot:FindFirstChild("Stands") then
                    for _, stand in ipairs(plot.Stands:GetChildren()) do
                        if not Toggles.AutoOpenBlocks then break end
                        openRemote:FireServer(stand.Name)
                    end
                end
            end)
        end
    end
end)

-- 7. Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 54, hrp.AssemblyLinearVelocity.Z)
            end
        end)
    end
end)

-- 8. Anti-Guard (CanTouch = false)
task.spawn(function()
    while true do
        task.wait(1.2)
        if Toggles.AntiGuard then
            pcall(function()
                local guardians = Workspace:FindFirstChild("Live") and Workspace.Live:FindFirstChild("Guardians")
                if guardians then
                    for _, g in ipairs(guardians:GetChildren()) do
                        for _, part in ipairs(g:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanTouch = false
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- VISUALS: MONSTER ESP, GUARD ESP, PLAYER ESP
-- =================================================================
local MonsterESPTable = {}
local GuardESPTable = {}
local PlayerESPTable = {}

local function ClearMonsterESP()
    for _, el in pairs(MonsterESPTable) do
        if el.Hl then el.Hl:Destroy() end
        if el.Gui then el.Gui:Destroy() end
    end
    table.clear(MonsterESPTable)
end

local function ClearGuardESP()
    for _, el in pairs(GuardESPTable) do
        if el.Hl then el.Hl:Destroy() end
        if el.Gui then el.Gui:Destroy() end
    end
    table.clear(GuardESPTable)
end

local function ClearPlayerESP()
    for _, el in pairs(PlayerESPTable) do
        if el.Hl then el.Hl:Destroy() end
        if el.Gui then el.Gui:Destroy() end
    end
    table.clear(PlayerESPTable)
end

-- Monster ESP Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.MonsterESP then
            pcall(function()
                local slimesFolder = Workspace:FindFirstChild("Live") and Workspace.Live:FindFirstChild("Slimes")
                if slimesFolder then
                    for _, slime in ipairs(slimesFolder:GetChildren()) do
                        if slime:IsA("Model") and slime:FindFirstChild("RootPart") then
                            if not MonsterESPTable[slime] then
                                local rarity = slime:GetAttribute("rarity") or "Common"
                                local color = RarityColors[rarity] or Color3.fromRGB(168, 85, 247)

                                local hl = Instance.new("Highlight")
                                hl.Name = "ESP_Hl"
                                hl.FillColor = color
                                hl.FillTransparency = 0.65
                                hl.OutlineColor = color
                                hl.OutlineTransparency = 0.1
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Adornee = slime
                                hl.Parent = slime

                                local bb = Instance.new("BillboardGui")
                                bb.Name = "ESP_Gui"
                                bb.Size = UDim2.new(0, 130, 0, 32)
                                bb.StudsOffset = Vector3.new(0, 3.2, 0)
                                bb.AlwaysOnTop = true
                                bb.Adornee = slime.RootPart
                                bb.Parent = slime.RootPart

                                local txt = Instance.new("TextLabel")
                                txt.Size = UDim2.new(1, 0, 1, 0)
                                txt.BackgroundTransparency = 1
                                txt.Font = Enum.Font.GothamBold
                                txt.TextSize = 10
                                txt.TextColor3 = color
                                txt.TextStrokeTransparency = 0.2
                                txt.Text = string.format("[%s]\n%s", rarity, slime.Name)
                                txt.Parent = bb

                                MonsterESPTable[slime] = { Hl = hl, Gui = bb }
                            end
                        end
                    end
                end
            end)
        else
            ClearMonsterESP()
        end
    end
end)

-- Guard ESP Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.GuardESP then
            pcall(function()
                local guardians = Workspace:FindFirstChild("Live") and Workspace.Live:FindFirstChild("Guardians")
                if guardians then
                    for _, guard in ipairs(guardians:GetChildren()) do
                        local hrp = guard:FindFirstChild("HumanoidRootPart") or guard.PrimaryPart
                        if not GuardESPTable[guard] and hrp then
                            local guardName = guard.Name
                            local overhead = guard:FindFirstChild("GuardOverhead", true)
                            if overhead then
                                local nameLabel = overhead:FindFirstChild("DisplayName")
                                if nameLabel and nameLabel:IsA("TextLabel") and nameLabel.Text ~= "" then
                                    guardName = nameLabel.Text
                                end
                            end

                            local hl = Instance.new("Highlight")
                            hl.Name = "Guard_Hl"
                            hl.FillColor = Color3.fromRGB(239, 68, 68)
                            hl.FillTransparency = 0.6
                            hl.OutlineColor = Color3.fromRGB(255, 100, 100)
                            hl.OutlineTransparency = 0.05
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Adornee = guard
                            hl.Parent = guard

                            local bb = Instance.new("BillboardGui")
                            bb.Name = "Guard_Gui"
                            bb.Size = UDim2.new(0, 140, 0, 32)
                            bb.StudsOffset = Vector3.new(0, 4, 0)
                            bb.AlwaysOnTop = true
                            bb.Adornee = hrp
                            bb.Parent = hrp

                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.Font = Enum.Font.GothamBold
                            txt.TextSize = 10
                            txt.TextColor3 = Color3.fromRGB(239, 68, 68)
                            txt.TextStrokeTransparency = 0.2
                            txt.Text = string.format("[GUARD]\n%s", guardName)
                            txt.Parent = bb

                            GuardESPTable[guard] = { Hl = hl, Gui = bb }
                        end
                    end
                end
            end)
        else
            ClearGuardESP()
        end
    end
end)

-- Player ESP Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.PlayerESP then
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local char = player.Character
                        local hrp = char.HumanoidRootPart
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if not PlayerESPTable[player] then
                            local hl = Instance.new("Highlight")
                            hl.Name = "Player_Hl"
                            hl.FillColor = Color3.fromRGB(168, 85, 247)
                            hl.FillTransparency = 0.7
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.OutlineTransparency = 0.15
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Adornee = char
                            hl.Parent = char

                            local bb = Instance.new("BillboardGui")
                            bb.Name = "Player_Gui"
                            bb.Size = UDim2.new(0, 140, 0, 34)
                            bb.StudsOffset = Vector3.new(0, 3.8, 0)
                            bb.AlwaysOnTop = true
                            bb.Adornee = hrp
                            bb.Parent = hrp

                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.Font = Enum.Font.GothamBold
                            txt.TextSize = 10
                            txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                            txt.TextStrokeTransparency = 0.3
                            local hp = hum and math.floor(hum.Health) or 100
                            txt.Text = string.format("%s\n[%d HP]", player.DisplayName, hp)
                            txt.Parent = bb

                            PlayerESPTable[player] = { Hl = hl, Gui = bb }
                        end
                    end
                end
            end)
        else
            ClearPlayerESP()
        end
    end
end)

-- =================================================================
-- SMOOTH 3D FLY ENGINE & NOCLIP
-- =================================================================
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

-- Anti-AFK Engine (20-min Disconnect Shield)
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        pcall(function()
            local vu = game:GetService("VirtualUser")
            if vu then
                vu:CaptureController()
                vu:ClickButton2(Vector2.zero)
            end
        end)
    end
end)

------------------------------------------------------------------------
-- OFFICIAL JUNEJO CLASSIC DARK UI GENERATOR (#0F0F11 - 280x285px)
------------------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_SCP"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true

-- Main Frame (Width: 280, Height: 285)
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
TitleLabel.Text = "JUMP TO STEAL SCP"
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
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 440)
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

-- Helper: Add 1-Click Action Button Row
local function AddActionRow(text, buttonText, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
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
    ActionBtn.Text = buttonText
    ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionBtn.TextSize = 10
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
        ActionBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
        task.delay(0.15, function()
            ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
        end)
        if callback then callback() end
    end)
end

-- Helper: Interactive Zone Selector Row
local currentZoneIdx = 1
local function AddZoneSelectorRow()
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.4, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "Target Zone"
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ZonePill = Instance.new("TextButton")
    ZonePill.Size = UDim2.new(0.6, 0, 0, 20)
    ZonePill.Position = UDim2.new(0.4, 0, 0.5, -10)
    ZonePill.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ZonePill.BorderSizePixel = 0
    ZonePill.Text = SelectedZone
    ZonePill.TextColor3 = Color3.fromRGB(200, 200, 220)
    ZonePill.TextSize = 10
    ZonePill.Font = Enum.Font.GothamBold
    ZonePill.Parent = Row

    local PillCorner = Instance.new("UICorner")
    PillCorner.CornerRadius = UDim.new(0, 4)
    PillCorner.Parent = ZonePill

    local PillStroke = Instance.new("UIStroke")
    PillStroke.Color = Color3.fromRGB(45, 45, 55)
    PillStroke.Thickness = 1
    PillStroke.Parent = ZonePill

    ZonePill.MouseButton1Click:Connect(function()
        currentZoneIdx = (currentZoneIdx % #TowerZones) + 1
        SelectedZone = TowerZones[currentZoneIdx]
        ZonePill.Text = SelectedZone
    end)
end

------------------------------------------------------------------------
-- REGISTERING ALL FEATURES
------------------------------------------------------------------------

-- 1. Instant Steal (1-Click)
AddActionRow("Instant Steal", "STEAL", function()
    task.spawn(function()
        StealFromZone(SelectedZone)
    end)
end)

-- 2. Target Zone Selector (Click to cycle)
AddZoneSelectorRow()

-- 3. Auto Steal Loop
AddToggleRow("Auto Steal Loop", "AutoStealLoop", function(state)
    if state then
        task.spawn(function()
            StealFromZone(SelectedZone)
        end)
    end
end)

-- 4. Auto Collect Cash
AddToggleRow("Auto Collect Cash", "AutoCollectCash")

-- 5. Auto Upgrade Jump
AddToggleRow("Auto Upgrade Jump", "AutoUpgradeJump")

-- 6. Auto Upgrade Capacity
AddToggleRow("Auto Upgrade Capacity", "AutoUpgradeCapacity")

-- 7. Auto Rebirth
AddToggleRow("Auto Rebirth", "AutoRebirth")

-- 8. Auto Open Lucky Blocks
AddToggleRow("Auto Open Blocks", "AutoOpenBlocks")

-- 9. Anti-Guard (Godmode)
AddToggleRow("Anti-Guard (Godmode)", "AntiGuard")

-- 10. Monster ESP
AddToggleRow("Monster ESP", "MonsterESP")

-- 11. Guard ESP
AddToggleRow("Guard ESP", "GuardESP")

-- 12. Player ESP
AddToggleRow("Player ESP", "PlayerESP")

-- 13. WalkSpeed Boost + Integrated Pill Controller (- / +)
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
    ApplySmoothSpeed()
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
    ApplySmoothSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    ApplySmoothSpeed()
end)

-- 14. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump")

-- 15. Fly Mode
AddToggleRow("Fly Mode", "FlyMode", function(enabled)
    if enabled then EnableFly() else DisableFly() end
end)

-- 16. Noclip Mode
AddToggleRow("Noclip Mode", "Noclip")

-- 17. Anti-AFK Engine
AddToggleRow("Anti-AFK Engine", "AntiAFK")

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
ScreenGui.Parent = GetSafeGuiParent()
