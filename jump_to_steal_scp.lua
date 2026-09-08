-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - JUMP TO STEAL SCP MONSTERS 👹
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- Universal Compatibility (Mobile Delta / Fluxus / Codex & PC)
-- ====================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    while not LocalPlayer do
        LocalPlayer = Players.LocalPlayer
        task.wait(0.05)
    end
end

-- Clean old UI instances safely across CoreGui, gethui and PlayerGui
pcall(function()
    for _, name in ipairs({"JunejoHubUI_JumpToStealSCP", "Badshah_SCP_Master_UI", "JunejoSCPHub"}) do
        pcall(function()
            if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        end)
        pcall(function()
            if gethui and gethui():FindFirstChild(name) then gethui()[name]:Destroy() end
        end)
        pcall(function()
            local pg = LocalPlayer and (LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:FindFirstChildOfClass("PlayerGui"))
            if pg and pg:FindFirstChild(name) then pg[name]:Destroy() end
        end)
    end
end)

-- ====================================================
-- FAILSAFE REMOTE RESOLVER
-- ====================================================
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

-- Global Configuration & State
local Toggles = {
    AutoStealLoop = false,
    AutoCollectCash = false,
    AutoUpgradeJump = false,
    AutoUpgradeCapacity = false,
    AutoRebirth = false,
    AutoOpenBlocks = false,
    AntiGuardGodmode = true,
    MonsterESP = false,
    GuardESP = false,
    PlayerESP = false,
    InfiniteJump = false,
    WalkSpeedBoost = false,
    AntiAFK = true
}

local CustomSpeedValue = 50
local SelectedZone = "Auto (Highest)"
local IsStealingBusy = false

-- Rarity Configs
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

-- Safe Character Check
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- Butter-Smooth WalkSpeed Enforcer
local function ApplySmoothSpeed()
    pcall(function()
        if isAlive() then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if Toggles.WalkSpeedBoost then
                    if hum.WalkSpeed ~= CustomSpeedValue then
                        hum.WalkSpeed = CustomSpeedValue
                    end
                    LocalPlayer:SetAttribute("CarrySpeedMulti", CustomSpeedValue / 24)
                else
                    hum.WalkSpeed = 24
                    LocalPlayer:SetAttribute("CarrySpeedMulti", 1)
                end
            end
        end
    end)
end

RunService.Heartbeat:Connect(ApplySmoothSpeed)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 5)
    task.wait(0.2)
    ApplySmoothSpeed()
end)

-- Screen Notification Toast Helper
local function ShowNotification(title, message)
    pcall(function()
        local sg = CoreGui:FindFirstChild("JunejoHubUI_JumpToStealSCP") or (LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("JunejoHubUI_JumpToStealSCP"))
        if not sg then return end

        local oldNotify = sg:FindFirstChild("JunejoToast")
        if oldNotify then oldNotify:Destroy() end

        local Toast = Instance.new("Frame")
        Toast.Name = "JunejoToast"
        Toast.Size = UDim2.new(0, 260, 0, 42)
        Toast.Position = UDim2.new(0.5, -130, 0.12, 0)
        Toast.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        Toast.BorderSizePixel = 0
        Toast.ZIndex = 999
        Toast.Parent = sg

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 8)
        ToastCorner.Parent = Toast

        local ToastStroke = Instance.new("UIStroke")
        ToastStroke.Color = Color3.fromRGB(60, 60, 80)
        ToastStroke.Thickness = 1.2
        ToastStroke.Parent = Toast

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -12, 0, 16)
        TitleLbl.Position = UDim2.new(0, 8, 0, 4)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
        TitleLbl.TextSize = 11
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.ZIndex = 1000
        TitleLbl.Parent = Toast

        local MsgLbl = Instance.new("TextLabel")
        MsgLbl.Size = UDim2.new(1, -12, 0, 16)
        MsgLbl.Position = UDim2.new(0, 8, 0, 20)
        MsgLbl.BackgroundTransparency = 1
        MsgLbl.Text = message
        MsgLbl.TextColor3 = Color3.fromRGB(230, 230, 240)
        MsgLbl.TextSize = 10
        MsgLbl.Font = Enum.Font.GothamMedium
        MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
        MsgLbl.ZIndex = 1000
        MsgLbl.Parent = Toast

        task.delay(3, function()
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

-- Plot & Base Detector
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

-- Universal Proximity Prompt Trigger
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

-- Best Monster Finder
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

-- Lag-Free Steal Action
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

        if not target or not target.Root or not target.Prompt then
            ShowNotification("Auto Steal", "No target found in " .. zoneName)
            return
        end

        -- Teleport to monster
        hrp.CFrame = target.Root.CFrame + Vector3.new(0, 1.2, 0)
        hrp.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.2)

        -- Trigger Prompt
        UniversalTriggerPrompt(target.Prompt)
        task.wait(0.45)

        -- Teleport back to Base
        local baseCF = GetBaseCFrame()
        hrp.CFrame = baseCF
        hrp.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.25)

        -- Deposit
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
            if dropRemote then dropRemote:FireServer() end
        end

        ShowNotification("Steal Success", "Secured " .. target.Rarity .. " " .. target.Name .. " at Base!")
    end)

    IsStealingBusy = false
end

-- ====================================================
-- CONTINUOUS BACKGROUND LOOPS
-- ====================================================

-- 1. Auto Steal Loop
task.spawn(function()
    while true do
        task.wait(0.4)
        if Toggles.AutoStealLoop and not IsStealingBusy and isAlive() then
            StealFromZone(SelectedZone)
        end
    end
end)

-- 2. Auto Collect Cash Loop
task.spawn(function()
    while true do
        task.wait(1.0)
        if Toggles.AutoCollectCash and isAlive() then
            pcall(function()
                local plot = GetMyPlot()
                local collectRemote = GetRemote("Collect Earnings")
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if plot and plot:FindFirstChild("CollectPads") then
                    for _, pad in ipairs(plot.CollectPads:GetChildren()) do
                        if not Toggles.AutoCollectCash then break end
                        if collectRemote then collectRemote:FireServer(pad.Name) end
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

-- 3. Auto Upgrade Jump Loop
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

-- 4. Auto Upgrade Capacity Loop
task.spawn(function()
    while true do
        task.wait(1.0)
        if Toggles.AutoUpgradeCapacity then
            pcall(function()
                local carryRemote = GetRemote("Upgrade Carry Limit")
                if carryRemote then carryRemote:FireServer() end
            end)
        end
    end
end)

-- 5. Auto Rebirth Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.AutoRebirth then
            pcall(function()
                local rebirthRemote = GetRemote("Rebirth")
                if rebirthRemote then rebirthRemote:FireServer() end
            end)
        end
    end
end)

-- 6. Auto Open Lucky Blocks Loop
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

-- 7. Anti-Guard Godmode Loop
task.spawn(function()
    while true do
        task.wait(1.2)
        if Toggles.AntiGuardGodmode then
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

-- 8. Infinite Jump Hook
UIS.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and isAlive() then
        local char = LocalPlayer.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 54, hrp.AssemblyLinearVelocity.Z)
        end
    end
end)

-- 9. Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ====================================================
-- VISUALS: MONSTER ESP, GUARD ESP, PLAYER ESP
-- ====================================================
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

-- ====================================================
-- OFFICIAL JUNEJO COMPACT UI (280px Standard)
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_JumpToStealSCP"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local isParented = false
pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
        if ScreenGui.Parent then isParented = true end
    end
end)
if not isParented then
    pcall(function()
        ScreenGui.Parent = CoreGui
        if ScreenGui.Parent then isParented = true end
    end)
end
if not isParented then
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
        if pg then
            ScreenGui.Parent = pg
            isParented = true
        end
    end)
end

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

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

-- Draggable Header Logic
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
    UIS.InputChanged:Connect(function(input)
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
TitleLabel.Text = "JUMP TO STEAL SCP 👹"
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
    ClearMonsterESP()
    ClearGuardESP()
    ClearPlayerESP()
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
ContentFrame.Size = UDim2.new(1, -16, 0, 230)
ContentFrame.Position = UDim2.new(0, 10, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 80)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper Function: Add Flat Toggle Row
local function AddToggleRow(text, configKey, callback)
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
    CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
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
        Toggles[configKey] = not Toggles[configKey]
        CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
        if callback then callback(Toggles[configKey]) end
    end)
end

-- Helper Function: Add Action Button
local function AddActionButton(text, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 24)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.Parent = Row
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Btn
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn
    
    local lastClick = 0
    Btn.MouseButton1Click:Connect(function()
        local now = os.clock()
        if now - lastClick < 0.25 then return end
        lastClick = now
        if callback then callback(Btn) end
    end)
end

-- ====================================================
-- ROWS REGISTRATION
-- ====================================================

-- 1. Action: Instant Steal Highest Monster
AddActionButton("⚡ Instant Steal (Highest SCP)", function(btn)
    btn.Text = "⏳ Stealing Highest..."
    task.spawn(function()
        StealFromZone("Auto (Highest)")
        task.delay(1.2, function()
            btn.Text = "⚡ Instant Steal (Highest SCP)"
        end)
    end)
end)

-- 2. Action: Instant Steal OG Monster
AddActionButton("👑 Instant Steal (OG Floor 8)", function(btn)
    btn.Text = "⏳ Stealing OG Floor 8..."
    task.spawn(function()
        StealFromZone("OG (Floor 8)")
        task.delay(1.2, function()
            btn.Text = "👑 Instant Steal (OG Floor 8)"
        end)
    end)
end)

-- 3. Auto Steal Loop Toggle
AddToggleRow("Auto Steal Loop", "AutoStealLoop", function(state) end)

-- 4. Auto Collect Cash Toggle
AddToggleRow("Auto Collect Cash", "AutoCollectCash", function(state) end)

-- 5. Auto Upgrade Jump Toggle
AddToggleRow("Auto Upgrade Jump", "AutoUpgradeJump", function(state) end)

-- 6. Auto Upgrade Capacity Toggle
AddToggleRow("Auto Upgrade Capacity", "AutoUpgradeCapacity", function(state) end)

-- 7. Auto Rebirth Toggle
AddToggleRow("Auto Rebirth", "AutoRebirth", function(state) end)

-- 8. Auto Open Lucky Blocks Toggle
AddToggleRow("Auto Open Lucky Blocks", "AutoOpenBlocks", function(state) end)

-- 9. Anti-Guard (Godmode) Toggle
AddToggleRow("Anti-Guard (Godmode)", "AntiGuardGodmode", function(state) end)

-- 10. Monster ESP Toggle
AddToggleRow("Monster ESP (Rarity Glow)", "MonsterESP", function(state)
    if not state then ClearMonsterESP() end
end)

-- 11. Guard ESP Toggle
AddToggleRow("Guard ESP (Red Radar)", "GuardESP", function(state)
    if not state then ClearGuardESP() end
end)

-- 12. Player ESP Toggle
AddToggleRow("Player ESP", "PlayerESP", function(state)
    if not state then ClearPlayerESP() end
end)

-- 13. Infinite Jump Toggle
AddToggleRow("Infinite Jump", "InfiniteJump", function(state) end)

-- 14. Integrated WalkSpeed Row with - / + Pill Controller
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
SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
SpeedCheckMark.BorderSizePixel = 0
SpeedCheckMark.Parent = SpeedCheckBox

local SpeedMarkCorner = Instance.new("UICorner")
SpeedMarkCorner.CornerRadius = UDim.new(0, 2)
SpeedMarkCorner.Parent = SpeedCheckMark

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
    CustomSpeedValue = math.max(16, CustomSpeedValue - 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    ApplySmoothSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(250, CustomSpeedValue + 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    ApplySmoothSpeed()
end)

-- 15. Action: Teleport to Base
AddActionButton("📍 Teleport to Base (Plot)", function(btn)
    if isAlive() then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local baseCF = GetBaseCFrame()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = baseCF
        btn.Text = "✓ Teleported to Base!"
        task.delay(1.2, function()
            btn.Text = "📍 Teleport to Base (Plot)"
        end)
    end
end)

-- ====================================================
-- FOOTER
-- ====================================================
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
