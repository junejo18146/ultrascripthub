-- =================================================================
-- JUNEJO ULTRA SCRIPT HUB: STEAL FISH EGGS (CUSTOM 7-FEATURE EDITION)
-- Game: Steal Fish Eggs (PlaceId: 99183404085821)
-- Creator: Made by Junejo (junejo18146)
-- Repository: ultrascripthub
-- UI Design: Official Junejo Classic Executive Dark Standard (100% Flat & Borderless)
-- Features: 3 Core (Auto Steal, Astral Steal, Remove Guards) + TP + 3 Normal (WalkSpeed, Fly, Rare ESP)
-- =================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera

-- Detect Game Title automatically
local GameName = "STEAL FISH EGGS"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info and info.Name and info.Name ~= "" then
        GameName = string.upper(info.Name)
    end
end)

-- Safe UI Container Resolver
local function GetSafeUIContainer()
    local container = nil
    pcall(function()
        if gethui then container = gethui() end
    end)
    if not container then
        pcall(function()
            if syn and syn.protect_gui then
                syn.protect_gui(CoreGui)
                container = CoreGui
            end
        end)
    end
    if not container then
        pcall(function() container = CoreGui end)
    end
    if not container or not pcall(function() local _ = container.Name end) then
        pcall(function() container = LocalPlayer:WaitForChild("PlayerGui", 5) end)
    end
    return container or LocalPlayer:WaitForChild("PlayerGui")
end

local UIContainer = GetSafeUIContainer()

-- Clean all previous UI instances safely
for _, name in ipairs({
    "JunejoHubUI_StealFishEggs",
    "RobloxScriptUI_Badshah_StealFishEggs",
    "StealFishEggsUI_Badshah",
    "BadshahHubUI_StealFishEggs"
}) do
    pcall(function()
        if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
        if gethui and gethui():FindFirstChild(name) then
            gethui()[name]:Destroy()
        end
    end)
end

-- =================================================================
-- ZONE DEFINITIONS & RARITY SCORES (Extracted from Game Core)
-- =================================================================
local AvailableZones = {
    "All Zones",
    "Coral Reef",
    "Deep Ocean",
    "Pearl Lagoon",
    "Snowy Sea",
    "Volcanic Sea",
    "Jelly Ocean",
    "Sunken Ruins",
    "Atlantis"
}

local ZoneInternalMap = {
    ["All Zones"] = "ALL",
    ["Coral Reef"] = "CoralReef",
    ["Deep Ocean"] = "DeepOcean",
    ["Pearl Lagoon"] = "PearlLagoon",
    ["Snowy Sea"] = "SnowySea",
    ["Volcanic Sea"] = "VolcanicSea",
    ["Jelly Ocean"] = "JellyOcean",
    ["Sunken Ruins"] = "SunkenRuins",
    ["Atlantis"] = "Atlantis"
}

local CurrentZoneIndex = 1

local RarityScores = {
    ["Astral"] = 7000,
    ["Abyssal"] = 6000,
    ["Mythic"] = 5000,
    ["Legendary"] = 4000,
    ["Epic"] = 3000,
    ["Rare"] = 2000,
    ["Basic"] = 1000
}

local RarityColors = {
    ["Astral"] = Color3.fromRGB(255, 0, 255),
    ["Abyssal"] = Color3.fromRGB(0, 255, 255),
    ["Mythic"] = Color3.fromRGB(255, 50, 50),
    ["Legendary"] = Color3.fromRGB(255, 170, 0),
    ["Epic"] = Color3.fromRGB(170, 0, 255),
    ["Rare"] = Color3.fromRGB(0, 150, 255),
    ["Basic"] = Color3.fromRGB(200, 200, 200)
}

-- =================================================================
-- GLOBAL TOGGLES & STATES
-- =================================================================
local Toggles = {
    AutoStealBest = false,
    AutoStealAstral = false,
    RemoveGuards = false,
    WalkSpeedBoost = false,
    FlyMode = false,
    RareEggESP = false,
    AntiAFK = true
}

local CustomSpeedValue = 50
local CustomFlySpeedValue = 60

local CooldownEggs = {}
local ToggleVisualUpdaters = {}
local ActiveESPItems = {}

-- Safe Alive Check
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

local function getRoot()
    if isAlive() then return LocalPlayer.Character.HumanoidRootPart end
    return nil
end

local function getHum()
    if isAlive() then return LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end
    return nil
end

-- Screen Toast Notification System
local ScreenGui = nil
local function ShowNotification(title, message)
    pcall(function()
        local sg = ScreenGui or UIContainer:FindFirstChild("JunejoHubUI_StealFishEggs") or CoreGui:FindFirstChild("JunejoHubUI_StealFishEggs")
        if not sg then return end

        local oldNotify = sg:FindFirstChild("JunejoToast")
        if oldNotify then oldNotify:Destroy() end

        local Toast = Instance.new("Frame")
        Toast.Name = "JunejoToast"
        Toast.Size = UDim2.new(0, 220, 0, 36)
        Toast.Position = UDim2.new(0.5, -110, 0.06, 0)
        Toast.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
        Toast.BorderSizePixel = 0
        Toast.ZIndex = 999
        Toast.Parent = sg

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 8)
        ToastCorner.Parent = Toast

        local ToastStroke = Instance.new("UIStroke")
        ToastStroke.Color = Color3.fromRGB(35, 35, 42)
        ToastStroke.Thickness = 1
        ToastStroke.Parent = Toast

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -12, 0, 15)
        TitleLbl.Position = UDim2.new(0, 8, 0, 3)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLbl.TextSize = 10
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.ZIndex = 1000
        TitleLbl.Parent = Toast

        local MsgLbl = Instance.new("TextLabel")
        MsgLbl.Size = UDim2.new(1, -12, 0, 14)
        MsgLbl.Position = UDim2.new(0, 8, 0, 18)
        MsgLbl.BackgroundTransparency = 1
        MsgLbl.Text = message
        MsgLbl.TextColor3 = Color3.fromRGB(180, 180, 195)
        MsgLbl.TextSize = 9
        MsgLbl.Font = Enum.Font.GothamMedium
        MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
        MsgLbl.ZIndex = 1000
        MsgLbl.Parent = Toast

        task.delay(2.5, function()
            if Toast and Toast.Parent then
                local tw = TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1
                })
                tw:Play()
                tw.Completed:Connect(function()
                    if Toast then Toast:Destroy() end
                end)
            end
        end)
    end)
end

-- =================================================================
-- GAME HELPER FUNCTIONS (Decompiled Game Architecture)
-- =================================================================
local function GetPlayerBase()
    local bases = Workspace:FindFirstChild("Bases") or Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("Tanks")
    if bases then
        for _, b in ipairs(bases:GetChildren()) do
            local owner = b:GetAttribute("OwnerUserId") or b:GetAttribute("Owner") or b:GetAttribute("UserId")
            if owner == LocalPlayer.UserId or owner == tostring(LocalPlayer.UserId) or owner == LocalPlayer.Name then
                return b
            end
            local ownerVal = b:FindFirstChild("Owner") or b:FindFirstChild("OwnerUserId")
            if ownerVal and (ownerVal.Value == LocalPlayer or ownerVal.Value == LocalPlayer.UserId or ownerVal.Value == LocalPlayer.Name) then
                return b
            end
        end
    end
    for _, item in ipairs(Workspace:GetChildren()) do
        if item:IsA("Model") and (item.Name:find(LocalPlayer.Name) or item.Name:find(tostring(LocalPlayer.UserId))) then
            return item
        end
    end
    return nil
end

local function GetPlayerPlacementZone()
    local base = GetPlayerBase()
    if base then
        local pz = base:FindFirstChild("PlacementZone", true) or base:FindFirstChild("PlaceZone", true) or base:FindFirstChild("EggZone", true) or base:FindFirstChild("TankArea", true)
        if pz and pz:IsA("BasePart") then return pz end
        for _, p in ipairs(base:GetDescendants()) do
            if p:IsA("BasePart") and (p.Name:lower():find("place") or p.Name:lower():find("drop") or p.Name:lower():find("zone") or p.Name:lower():find("pad")) then
                return p
            end
        end
    end
    return nil
end

local function GetPlayerPlacementWorldPosition()
    local pZone = GetPlayerPlacementZone()
    if pZone then
        local bounds = pZone.Size
        local randomOffsetX = (math.random() - 0.5) * (bounds.X * 0.7)
        local randomOffsetZ = (math.random() - 0.5) * (bounds.Z * 0.7)
        return pZone.Position + Vector3.new(randomOffsetX, 1.5, randomOffsetZ)
    end
    local base = GetPlayerBase()
    if base then
        local pivot = base:GetPivot()
        return pivot.Position + Vector3.new(0, 2, 0)
    end
    return nil
end

local function GetTheLinePart()
    local line = Workspace:FindFirstChild("TheLine", true) or Workspace:FindFirstChild("FinishLine", true) or Workspace:FindFirstChild("SafeLine", true) or Workspace:FindFirstChild("EscapeLine", true)
    if line and line:IsA("BasePart") then return line end
    if line and line:IsA("Model") then
        return line.PrimaryPart or line:FindFirstChildWhichIsA("BasePart")
    end
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name == "TheLine" or part.Name == "Line" or part.Name == "FinishPart" or part.Name == "EscapePart") then
            return part
        end
    end
    return nil
end

local function IsCarryingEgg()
    local char = LocalPlayer.Character
    if not char then return false end
    if char:GetAttribute("HoldingEgg") == true or char:GetAttribute("CarryingEgg") == true or char:GetAttribute("HasEgg") == true then
        return true
    end
    if char:FindFirstChild("CarriedEgg") or char:FindFirstChild("Egg") or char:FindFirstChild("EggModel") then
        return true
    end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("egg") or item:GetAttribute("IsEgg") == true) then
            return true
        end
        if item:IsA("Model") and (item.Name:lower():find("egg") or item:GetAttribute("EggType") ~= nil) then
            return true
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, t in ipairs(backpack:GetChildren()) do
            if t:IsA("Tool") and (t.Name:lower():find("egg") or t:GetAttribute("IsEgg") == true) then
                return true
            end
        end
    end
    return false
end

local function EquipCarriedEggTool()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local hum = getHum()
    if backpack and hum then
        for _, t in ipairs(backpack:GetChildren()) do
            if t:IsA("Tool") and (t.Name:lower():find("egg") or t:GetAttribute("IsEgg") == true) then
                hum:EquipTool(t)
                task.wait(0.05)
                break
            end
        end
    end
end

local function TouchWithCharacter(part)
    pcall(function()
        if not part or not isAlive() then return end
        local hrp = getRoot()
        if not hrp then return end
        if firetouchinterest then
            firetouchinterest(hrp, part, 0)
            task.wait(0.02)
            firetouchinterest(hrp, part, 1)
        end
    end)
end

local function InstantTriggerPrompt(prompt)
    pcall(function()
        if not prompt or not prompt.Parent then return end
        if fireproximityprompt then
            fireproximityprompt(prompt)
        elseif prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration > 0 and 0.05 or 0)
            prompt:InputHoldEnd()
        end
    end)
end

local function GetZoneBiomeFolder(zoneInternalName)
    local biomesFolder = Workspace:FindFirstChild("Biomes") or Workspace:FindFirstChild("Zones") or Workspace:FindFirstChild("Maps")
    if biomesFolder then
        for _, b in ipairs(biomesFolder:GetChildren()) do
            if b.Name:lower():find(zoneInternalName:lower()) then
                return b
            end
        end
    end
    for _, item in ipairs(Workspace:GetChildren()) do
        if item:IsA("Folder") or item:IsA("Model") then
            if item.Name:lower():find(zoneInternalName:lower()) then
                return item
            end
        end
    end
    return nil
end

local function GetTargetEgg(astralOnly)
    local candidates = {}
    local chosenBiomeName = AvailableZones[CurrentZoneIndex]
    local chosenBiomeInternal = ZoneInternalMap[chosenBiomeName] or "ALL"
    local biomeFolder = chosenBiomeInternal ~= "ALL" and GetZoneBiomeFolder(chosenBiomeInternal) or nil
    local biomeCenterPos = nil

    if biomeFolder then
        local bp = biomeFolder:FindFirstChild("BiomePart", true) or biomeFolder:FindFirstChildWhichIsA("BasePart", true)
        if bp then biomeCenterPos = bp.Position end
    end

    local eggContainers = {
        Workspace:FindFirstChild("SpawnedEggs"),
        Workspace:FindFirstChild("Eggs"),
        Workspace:FindFirstChild("EggSpawns"),
        Workspace:FindFirstChild("WorldEggs"),
        Workspace:FindFirstChild("Biomes"),
        Workspace:FindFirstChild("GameMap")
    }

    for _, container in ipairs(eggContainers) do
        if container then
            for _, egg in ipairs(container:GetDescendants()) do
                if egg:IsA("Model") and not CooldownEggs[egg] then
                    local isEgg = egg:GetAttribute("Rarity") ~= nil or egg:GetAttribute("EggType") ~= nil or egg.Name:lower():find("egg")
                    if isEgg and not egg.Name:lower():find("placed") and not egg.Name:lower():find("carried") then
                        local rarity = tostring(egg:GetAttribute("Rarity") or "Basic")
                        local score = RarityScores[rarity] or 1000

                        if astralOnly then
                            if rarity == "Astral" or rarity == "Abyssal" or score >= 6000 then
                                table.insert(candidates, { Model = egg, Score = score, Pivot = egg:GetPivot() })
                            end
                        else
                            local eggBiome = tostring(egg:GetAttribute("Biome") or "")
                            local isMatch = false
                            if chosenBiomeInternal == "ALL" then
                                isMatch = true
                            elseif eggBiome == chosenBiomeInternal or eggBiome:lower() == chosenBiomeInternal:lower() then
                                isMatch = true
                            elseif biomeCenterPos then
                                local pivot = egg:GetPivot()
                                if (pivot.Position - biomeCenterPos).Magnitude < 350 then isMatch = true end
                            end

                            if isMatch then
                                table.insert(candidates, { Model = egg, Score = score, Pivot = egg:GetPivot() })
                            end
                        end
                    end
                end
            end
        end
    end

    if #candidates == 0 then return nil end
    table.sort(candidates, function(a, b) return a.Score > b.Score end)
    return candidates[1].Model
end

local function RunEggStealLoop(astralOnly)
    pcall(function()
        if isAlive() then
            local hrp = getRoot()

            if IsCarryingEgg() then
                -- 1. CROSS ESCAPE LINE
                local linePart = GetTheLinePart()
                if linePart then
                    hrp.CFrame = linePart.CFrame + Vector3.new(0, 3, 0)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    TouchWithCharacter(linePart)
                    task.wait(0.2)
                end

                -- 2. DELIVER TO BASE TANK
                local placeZone = GetPlayerPlacementZone()
                local placePos = GetPlayerPlacementWorldPosition()
                local base = GetPlayerBase()
                local baseCF = placeZone and (placeZone.CFrame + Vector3.new(0, 3, 0)) or (base and base:GetPivot() + Vector3.new(0, 3, 0))

                if baseCF then
                    hrp.CFrame = baseCF
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    task.wait(0.15)

                    EquipCarriedEggTool()

                    local eggSys = ReplicatedStorage:FindFirstChild("EggSystem") or ReplicatedStorage
                    local placeEggRemote = eggSys:FindFirstChild("PlaceEgg", true) or eggSys:FindFirstChild("Place", true) or ReplicatedStorage:FindFirstChild("PlaceEgg", true)
                    if placeEggRemote and placeEggRemote:IsA("RemoteEvent") then
                        if placePos then
                            placeEggRemote:FireServer(placePos)
                        else
                            placeEggRemote:FireServer(baseCF.Position)
                        end
                        placeEggRemote:FireServer()
                    end

                    if placeZone then TouchWithCharacter(placeZone) end
                    task.wait(0.3)
                end
            else
                local targetEgg = GetTargetEgg(astralOnly)
                if targetEgg and targetEgg.Parent then
                    local pivot = targetEgg:GetPivot()
                    hrp.CFrame = pivot * CFrame.new(0, 0.5, 0)
                    hrp.AssemblyLinearVelocity = Vector3.zero

                    local prompt = targetEgg:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then InstantTriggerPrompt(prompt) end

                    for _, p in ipairs(targetEgg:GetDescendants()) do
                        if p:IsA("BasePart") then TouchWithCharacter(p) end
                    end

                    for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                        if rem:IsA("RemoteEvent") and (rem.Name:lower():find("take") or rem.Name:lower():find("steal") or rem.Name:lower():find("pickupegg")) then
                            pcall(function() rem:FireServer(targetEgg) end)
                        end
                    end

                    local waitTicks = 0
                    while waitTicks < 12 and not IsCarryingEgg() do
                        task.wait(0.05)
                        waitTicks = waitTicks + 1
                        if targetEgg and targetEgg.Parent then
                            hrp.CFrame = targetEgg:GetPivot()
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            local p = targetEgg:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if p then InstantTriggerPrompt(p) end
                        end
                    end

                    CooldownEggs[targetEgg] = true
                    task.delay(4, function() CooldownEggs[targetEgg] = nil end)
                else
                    task.wait(0.35)
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        if Toggles.AutoStealBest then
            RunEggStealLoop(false)
            task.wait(0.08)
        elseif Toggles.AutoStealAstral then
            RunEggStealLoop(true)
            task.wait(0.08)
        else
            task.wait(0.4)
        end
    end
end)

-- =================================================================
-- FEATURE 3: REMOVE ALL GUARDS (CHASER FISHES & HAZARDS)
-- =================================================================
local function NeutralizeTarget(target)
    if not target or target == LocalPlayer.Character or target.Parent == LocalPlayer.Character then return end
    if Players:GetPlayerFromCharacter(target) or Players:GetPlayerFromCharacter(target.Parent) then return end

    pcall(function()
        if target:IsA("Model") then
            target:PivotTo(CFrame.new(0, -99999, 0))
            for _, p in ipairs(target:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanTouch = false
                    p.CanCollide = false
                    p.CanQuery = false
                    p.Transparency = 1
                    p.Size = Vector3.new(0.001, 0.001, 0.001)
                    p.CFrame = CFrame.new(0, -99999, 0)
                    p.AssemblyLinearVelocity = Vector3.zero
                elseif p:IsA("TouchTransmitter") then
                    p:Destroy()
                end
            end
            local hum = target:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = 0
                hum.MaxHealth = 0
                hum:ChangeState(Enum.HumanoidStateType.Dead)
            end
            target:Destroy()
        elseif target:IsA("BasePart") then
            target.CanTouch = false
            target.CanCollide = false
            target.CanQuery = false
            target.Transparency = 1
            target.Size = Vector3.new(0.001, 0.001, 0.001)
            target.CFrame = CFrame.new(0, -99999, 0)
            target.AssemblyLinearVelocity = Vector3.zero
            for _, tt in ipairs(target:GetChildren()) do
                if tt:IsA("TouchTransmitter") then tt:Destroy() end
            end
            target:Destroy()
        end
    end)
end

local function IsGuardOrFish(instance)
    if not instance or instance == LocalPlayer.Character or instance.Parent == LocalPlayer.Character then return false end
    if Players:GetPlayerFromCharacter(instance) or Players:GetPlayerFromCharacter(instance.Parent) then return false end

    local name = instance.Name:lower()
    if name:find("egg") or name:find("spawn") or name:find("tank") or name:find("pad") or name:find("tread") or name:find("base") or name:find("theline") then
        return false
    end
    if instance:GetAttribute("EggType") ~= nil or instance:GetAttribute("OwnerUserId") ~= nil then
        return false
    end

    if instance:GetAttribute("ChaserAggroActive") ~= nil or instance:GetAttribute("IsGuard") ~= nil or instance:GetAttribute("IsChaser") ~= nil or instance:GetAttribute("Chaser") ~= nil then
        return true
    end

    local keywords = {
        "chaser", "guard", "fish", "shark", "piranha", "coralreef", "deepocean",
        "hazard", "enemy", "monster", "obstacle", "creature", "jellyfish", "angler",
        "dolphin", "killer", "attacker", "ray", "squid", "patrol", "leviathan",
        "killpart", "damagepart", "bitepart", "hitbox", "eel", "crab", "whale"
    }
    for _, kw in ipairs(keywords) do
        if name:find(kw) then return true end
    end

    if instance:IsA("Model") then
        local hum = instance:FindFirstChildOfClass("Humanoid")
        if hum and not Players:GetPlayerFromCharacter(instance) then return true end
    end

    return false
end

local function SweepAndRemoveAllGuards()
    pcall(function()
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if IsGuardOrFish(desc) then NeutralizeTarget(desc) end
        end
    end)
end

task.spawn(function()
    while true do
        if Toggles.RemoveGuards then
            SweepAndRemoveAllGuards()
            task.wait(0.2)
        else
            task.wait(1)
        end
    end
end)

Workspace.ChildAdded:Connect(function(child)
    if Toggles.RemoveGuards then
        task.wait(0.02)
        if IsGuardOrFish(child) then NeutralizeTarget(child) end
    end
end)

RunService.Heartbeat:Connect(function()
    if Toggles.RemoveGuards and isAlive() then
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, m in ipairs(Workspace:GetChildren()) do
            if m ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(m) then
                if IsGuardOrFish(m) then
                    local pivot = m:IsA("Model") and m:GetPivot() or (m:IsA("BasePart") and m.CFrame)
                    if pivot and (pivot.Position - myPos).Magnitude < 120 then
                        NeutralizeTarget(m)
                    end
                end
            end
        end
    end
end)

-- =================================================================
-- FEATURE 4: INSTANT TELEPORT TO ALL BIOMES (BASE + ESCAPE + 8 ZONES)
-- =================================================================
local function TeleportToLocation(targetName)
    pcall(function()
        if not isAlive() then return end
        local hrp = getRoot()

        if targetName == "Base" then
            local placeZone = GetPlayerPlacementZone()
            local base = GetPlayerBase()
            local baseCF = placeZone and (placeZone.CFrame + Vector3.new(0, 3, 0)) or (base and base:GetPivot() + Vector3.new(0, 3, 0))
            if baseCF then
                hrp.CFrame = baseCF
                hrp.AssemblyLinearVelocity = Vector3.zero
                ShowNotification("Teleport", "Teleported to Base Tank!")
            end
            return
        elseif targetName == "EscapeLine" then
            local linePart = GetTheLinePart()
            if linePart then
                hrp.CFrame = linePart.CFrame + Vector3.new(0, 3, 0)
                hrp.AssemblyLinearVelocity = Vector3.zero
                ShowNotification("Teleport", "Teleported to Escape Line!")
            end
            return
        end

        local internalName = ZoneInternalMap[targetName] or targetName
        local biomeFolder = GetZoneBiomeFolder(internalName)

        if biomeFolder then
            local bp = biomeFolder:FindFirstChild("BiomePart", true) or biomeFolder:FindFirstChildWhichIsA("BasePart", true) or biomeFolder:FindFirstChild("Spawn", true)
            if bp then
                hrp.CFrame = bp.CFrame + Vector3.new(0, 5, 0)
                hrp.AssemblyLinearVelocity = Vector3.zero
                ShowNotification("Teleport", "Teleported to " .. targetName .. "!")
                return
            end
        end

        local spawnedEggs = Workspace:FindFirstChild("SpawnedEggs") or Workspace:FindFirstChild("Eggs")
        if spawnedEggs then
            for _, egg in ipairs(spawnedEggs:GetChildren()) do
                if tostring(egg:GetAttribute("Biome") or ""):lower() == internalName:lower() then
                    hrp.CFrame = egg:GetPivot() + Vector3.new(0, 3, 0)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    ShowNotification("Teleport", "Teleported to " .. targetName .. "!")
                    return
                end
            end
        end

        ShowNotification("Teleport", targetName .. " reached!")
    end)
end

-- =================================================================
-- FEATURE 5: WALKSPEED BOOST ENGINE
-- =================================================================
local function UpdateCharacterSpeed()
    pcall(function()
        if isAlive() then
            local hum = getHum()
            if hum then
                if Toggles.WalkSpeedBoost then
                    hum.WalkSpeed = CustomSpeedValue
                else
                    hum.WalkSpeed = 16
                end
            end
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if Toggles.WalkSpeedBoost and isAlive() then
        local hum = getHum()
        if hum and hum.WalkSpeed ~= CustomSpeedValue then
            hum.WalkSpeed = CustomSpeedValue
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.6)
    if Toggles.WalkSpeedBoost then UpdateCharacterSpeed() end
end)

-- =================================================================
-- FEATURE 6: SMOOTH 3D FLY MODE ENGINE (WASD + MOBILE CONTROLS)
-- =================================================================
local FlyBodyGyro = nil
local FlyBodyVel = nil

local function StopFly()
    pcall(function()
        if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
        if FlyBodyVel then FlyBodyVel:Destroy() FlyBodyVel = nil end
        local hum = getHum()
        if hum then hum.PlatformStand = false end
    end)
end

local function StartFly()
    StopFly()
    pcall(function()
        if not isAlive() then return end
        local hrp = getRoot()
        local hum = getHum()
        if not hrp or not hum then return end

        hum.PlatformStand = true

        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.P = 9e4
        FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyGyro.CFrame = hrp.CFrame
        FlyBodyGyro.Parent = hrp

        FlyBodyVel = Instance.new("BodyVelocity")
        FlyBodyVel.Velocity = Vector3.zero
        FlyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyVel.Parent = hrp
    end)
end

RunService.RenderStepped:Connect(function()
    if Toggles.FlyMode and isAlive() and FlyBodyVel and FlyBodyGyro then
        local hrp = getRoot()
        local hum = getHum()
        if not hrp or not hum then return end

        hum.PlatformStand = true
        FlyBodyGyro.CFrame = Camera.CFrame

        local moveDir = hum.MoveDirection
        local vel = Vector3.zero

        if moveDir.Magnitude > 0 then
            vel = (Camera.CFrame.RightVector * (moveDir.X) + Camera.CFrame.LookVector * (-moveDir.Z)).Unit * CustomFlySpeedValue
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vel = vel + Vector3.new(0, CustomFlySpeedValue * 0.8, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            vel = vel - Vector3.new(0, CustomFlySpeedValue * 0.8, 0)
        end

        FlyBodyVel.Velocity = vel
    end
end)

-- =================================================================
-- FEATURE 7: RARE EGG ONLY ESP
-- =================================================================
local function ClearAllESP()
    for item, elements in pairs(ActiveESPItems) do
        if elements.Highlight then pcall(function() elements.Highlight:Destroy() end) end
        if elements.Billboard then pcall(function() elements.Billboard:Destroy() end) end
    end
    table.clear(ActiveESPItems)
end

local function UpdateRareEggESP()
    if not Toggles.RareEggESP then
        ClearAllESP()
        return
    end

    pcall(function()
        local myRoot = getRoot()
        local validObjects = {}

        local eggContainers = {
            Workspace:FindFirstChild("SpawnedEggs"),
            Workspace:FindFirstChild("Eggs"),
            Workspace:FindFirstChild("EggSpawns"),
            Workspace:FindFirstChild("WorldEggs"),
            Workspace:FindFirstChild("Biomes")
        }

        for _, container in ipairs(eggContainers) do
            if container then
                for _, egg in ipairs(container:GetDescendants()) do
                    if egg:IsA("Model") and (egg:GetAttribute("Rarity") ~= nil or egg.Name:lower():find("egg")) then
                        local rarity = tostring(egg:GetAttribute("Rarity") or "Basic")
                        if rarity ~= "Basic" then
                            validObjects[egg] = rarity
                        end
                    end
                end
            end
        end

        for item, elements in pairs(ActiveESPItems) do
            if not validObjects[item] or not item.Parent then
                if elements.Highlight then elements.Highlight:Destroy() end
                if elements.Billboard then elements.Billboard:Destroy() end
                ActiveESPItems[item] = nil
            end
        end

        for egg, rarity in pairs(validObjects) do
            local color = RarityColors[rarity] or Color3.fromRGB(255, 255, 0)
            if not ActiveESPItems[egg] then
                local hl = Instance.new("Highlight")
                hl.Adornee = egg
                hl.FillColor = color
                hl.FillTransparency = 0.4
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = egg

                local adornPart = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
                local bb = nil
                if adornPart then
                    bb = Instance.new("BillboardGui")
                    bb.Adornee = adornPart
                    bb.Size = UDim2.new(0, 100, 0, 30)
                    bb.StudsOffset = Vector3.new(0, 2.5, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = egg

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = "[" .. rarity .. "]"
                    lbl.TextColor3 = color
                    lbl.TextStrokeTransparency = 0
                    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    lbl.TextSize = 10
                    lbl.Font = Enum.Font.GothamBold
                    lbl.Parent = bb
                end

                ActiveESPItems[egg] = { Highlight = hl, Billboard = bb }
            else
                local elements = ActiveESPItems[egg]
                if elements.Billboard and myRoot then
                    local lbl = elements.Billboard:FindFirstChildOfClass("TextLabel")
                    local adornPart = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
                    if lbl and adornPart then
                        local dist = math.floor((adornPart.Position - myRoot.Position).Magnitude)
                        lbl.Text = "[" .. rarity .. "] " .. dist .. "m"
                    end
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        if Toggles.RareEggESP then
            UpdateRareEggESP()
            task.wait(0.35)
        else
            task.wait(1)
        end
    end
end)

-- =================================================================
-- UTILITY: ANTI-AFK (DEFAULT ON)
-- =================================================================
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end
end)

-- =================================================================
-- JUNEJO OFFICIAL STANDARD UI GENERATOR (100% FLAT & BORDERLESS)
-- =================================================================
ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_StealFishEggs"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = UIContainer

local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainFrame"
MainWindow.Size = UDim2.new(0, 285, 0, 345)
MainWindow.Position = UDim2.new(0.5, -142, 0.5, -172)
MainWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 17) -- Matte Black
MainWindow.BorderSizePixel = 0
MainWindow.Active = true
MainWindow.ClipsDescendants = true
MainWindow.Parent = ScreenGui

local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0, 10)
WindowCorner.Parent = MainWindow

local WindowStroke = Instance.new("UIStroke")
WindowStroke.Color = Color3.fromRGB(35, 35, 42)
WindowStroke.Thickness = 1
WindowStroke.Parent = MainWindow

-- Header (Height: 32)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainWindow

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -40, 1, 0)
HeaderTitle.Position = UDim2.new(0, 12, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = GameName
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 12
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.TextTruncate = Enum.TextTruncate.AtEnd
HeaderTitle.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 4)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    StopFly()
    ClearAllESP()
    ScreenGui:Destroy()
end)

-- Header Separation Line
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -24, 0, 1)
Divider.Position = UDim2.new(0, 12, 0, 32)
Divider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Divider.BorderSizePixel = 0
Divider.Parent = MainWindow

-- Scrolling Content Frame
local FeaturesContainer = Instance.new("ScrollingFrame")
FeaturesContainer.Name = "ContentScroll"
FeaturesContainer.Size = UDim2.new(1, -24, 1, -74)
FeaturesContainer.Position = UDim2.new(0, 12, 0, 36)
FeaturesContainer.BackgroundTransparency = 1
FeaturesContainer.BorderSizePixel = 0
FeaturesContainer.ScrollBarThickness = 2
FeaturesContainer.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
FeaturesContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
FeaturesContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
FeaturesContainer.Parent = MainWindow

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 4)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = FeaturesContainer

-- Footer (Height: 34)
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 34)
Footer.Position = UDim2.new(0, 0, 1, -36)
Footer.BackgroundTransparency = 1
Footer.Parent = MainWindow

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 14)
FooterTitle.Position = UDim2.new(0, 0, 0, 2)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 11
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 12)
FooterSub.Position = UDim2.new(0, 0, 0, 16)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 9
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.Parent = Footer

-- =================================================================
-- OFFICIAL JUNEJO UI BUILDERS (BORDERLESS FLAT ROWS)
-- =================================================================
local currentOrder = 0
local function getNextOrder()
    currentOrder = currentOrder + 1
    return currentOrder
end

-- Helper: Add Borderless Toggle Row
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = getNextOrder()
    Row.Parent = FeaturesContainer
    
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

    local function updateVisuals()
        CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
    end
    ToggleVisualUpdaters[configKey] = updateVisuals
    
    RowBtn.MouseButton1Click:Connect(function()
        Toggles[configKey] = not Toggles[configKey]
        updateVisuals()
        if callback then callback(Toggles[configKey]) end
    end)
    return Row
end

-- =================================================================
-- BUILD THE 7 REQUESTED HYBRID FEATURES IN ORDER
-- =================================================================

-- 1. Auto Steal Best Egg
AddToggleRow("1. Auto Steal Best Egg", "AutoStealBest", function(enabled)
    if enabled then
        Toggles.AutoStealAstral = false
        if ToggleVisualUpdaters["AutoStealAstral"] then ToggleVisualUpdaters["AutoStealAstral"]() end
        table.clear(CooldownEggs)
        ShowNotification("Auto Steal", "Stealing best eggs from " .. AvailableZones[CurrentZoneIndex])
    end
end)

-- Area Selector for Auto Steal Best Egg
local ZoneMainRow = Instance.new("Frame")
ZoneMainRow.Name = "ZoneMainRow"
ZoneMainRow.Size = UDim2.new(1, 0, 0, 24)
ZoneMainRow.BackgroundTransparency = 1
ZoneMainRow.LayoutOrder = getNextOrder()
ZoneMainRow.Parent = FeaturesContainer

local ZoneMainLabel = Instance.new("TextLabel")
ZoneMainLabel.Size = UDim2.new(0.38, 0, 1, 0)
ZoneMainLabel.BackgroundTransparency = 1
ZoneMainLabel.Text = "Select Area"
ZoneMainLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
ZoneMainLabel.TextSize = 12
ZoneMainLabel.Font = Enum.Font.GothamBold
ZoneMainLabel.TextXAlignment = Enum.TextXAlignment.Left
ZoneMainLabel.Parent = ZoneMainRow

local ZonePillFrame = Instance.new("Frame")
ZonePillFrame.Size = UDim2.new(0.6, 0, 1, 0)
ZonePillFrame.Position = UDim2.new(0.4, 0, 0, 0)
ZonePillFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
ZonePillFrame.BorderSizePixel = 0
ZonePillFrame.Parent = ZoneMainRow

local ZonePillCorner = Instance.new("UICorner")
ZonePillCorner.CornerRadius = UDim.new(0, 4)
ZonePillCorner.Parent = ZonePillFrame

local ZonePillStroke = Instance.new("UIStroke")
ZonePillStroke.Color = Color3.fromRGB(45, 45, 55)
ZonePillStroke.Thickness = 1
ZonePillStroke.Parent = ZonePillFrame

local PrevZoneBtn = Instance.new("TextButton")
PrevZoneBtn.Size = UDim2.new(0, 18, 1, 0)
PrevZoneBtn.Position = UDim2.new(0, 0, 0, 0)
PrevZoneBtn.BackgroundTransparency = 1
PrevZoneBtn.Text = "<"
PrevZoneBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
PrevZoneBtn.TextSize = 12
PrevZoneBtn.Font = Enum.Font.GothamBold
PrevZoneBtn.Parent = ZonePillFrame

local ZoneDropdownToggleBtn = Instance.new("TextButton")
ZoneDropdownToggleBtn.Size = UDim2.new(1, -36, 1, 0)
ZoneDropdownToggleBtn.Position = UDim2.new(0, 18, 0, 0)
ZoneDropdownToggleBtn.BackgroundTransparency = 1
ZoneDropdownToggleBtn.Text = AvailableZones[CurrentZoneIndex] .. " ▾"
ZoneDropdownToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ZoneDropdownToggleBtn.TextSize = 10
ZoneDropdownToggleBtn.Font = Enum.Font.GothamBold
ZoneDropdownToggleBtn.TextTruncate = Enum.TextTruncate.AtEnd
ZoneDropdownToggleBtn.Parent = ZonePillFrame

local NextZoneBtn = Instance.new("TextButton")
NextZoneBtn.Size = UDim2.new(0, 18, 1, 0)
NextZoneBtn.Position = UDim2.new(1, -18, 0, 0)
NextZoneBtn.BackgroundTransparency = 1
NextZoneBtn.Text = ">"
NextZoneBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
NextZoneBtn.TextSize = 12
NextZoneBtn.Font = Enum.Font.GothamBold
NextZoneBtn.Parent = ZonePillFrame

local ZoneOptionsContainer = Instance.new("Frame")
ZoneOptionsContainer.Name = "ZoneOptionsContainer"
ZoneOptionsContainer.Size = UDim2.new(1, 0, 0, 0)
ZoneOptionsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
ZoneOptionsContainer.BorderSizePixel = 0
ZoneOptionsContainer.Visible = false
ZoneOptionsContainer.ClipsDescendants = true
ZoneOptionsContainer.LayoutOrder = getNextOrder()
ZoneOptionsContainer.Parent = FeaturesContainer

local ZoneOptCorner = Instance.new("UICorner")
ZoneOptCorner.CornerRadius = UDim.new(0, 6)
ZoneOptCorner.Parent = ZoneOptionsContainer

local ZoneOptStroke = Instance.new("UIStroke")
ZoneOptStroke.Color = Color3.fromRGB(38, 38, 46)
ZoneOptStroke.Thickness = 1
ZoneOptStroke.Parent = ZoneOptionsContainer

local ZoneOptLayout = Instance.new("UIListLayout")
ZoneOptLayout.Padding = UDim.new(0, 3)
ZoneOptLayout.SortOrder = Enum.SortOrder.LayoutOrder
ZoneOptLayout.Parent = ZoneOptionsContainer

local ZoneOptPadding = Instance.new("UIPadding")
ZoneOptPadding.PaddingTop = UDim.new(0, 4)
ZoneOptPadding.PaddingBottom = UDim.new(0, 4)
ZoneOptPadding.PaddingLeft = UDim.new(0, 4)
ZoneOptPadding.PaddingRight = UDim.new(0, 4)
ZoneOptPadding.Parent = ZoneOptionsContainer

local isZoneDropdownOpen = false
local zoneButtons = {}

local function updateZoneSelection(newIdx, notify)
    CurrentZoneIndex = newIdx
    local zoneName = AvailableZones[CurrentZoneIndex]
    ZoneDropdownToggleBtn.Text = zoneName .. (isZoneDropdownOpen and " ▴" or " ▾")
    table.clear(CooldownEggs)
    
    for idx, btn in ipairs(zoneButtons) do
        if idx == CurrentZoneIndex then
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            local stroke = btn:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = Color3.fromRGB(80, 80, 100) end
        else
            btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
            btn.TextColor3 = Color3.fromRGB(200, 200, 210)
            local stroke = btn:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = Color3.fromRGB(38, 38, 46) end
        end
    end
    
    if notify then ShowNotification("Target Area", zoneName) end
end

for idx, zoneName in ipairs(AvailableZones) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 22)
    btn.BackgroundColor3 = idx == CurrentZoneIndex and Color3.fromRGB(45, 45, 58) or Color3.fromRGB(27, 27, 32)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = (zoneName == "All Zones" and "⭐ " or "🌊 ") .. zoneName
    btn.TextColor3 = idx == CurrentZoneIndex and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 210)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.LayoutOrder = idx
    btn.Parent = ZoneOptionsContainer

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 4)
    bCorner.Parent = btn

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = idx == CurrentZoneIndex and Color3.fromRGB(80, 80, 100) or Color3.fromRGB(38, 38, 46)
    bStroke.Thickness = 1
    bStroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        updateZoneSelection(idx, true)
        isZoneDropdownOpen = false
        ZoneDropdownToggleBtn.Text = AvailableZones[CurrentZoneIndex] .. " ▾"
        local tw = TweenService:Create(ZoneOptionsContainer, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 0)
        })
        tw:Play()
        tw.Completed:Connect(function()
            if not isZoneDropdownOpen then ZoneOptionsContainer.Visible = false end
        end)
    end)

    table.insert(zoneButtons, btn)
end

local totalOptHeight = #AvailableZones * 25 + 8

local function toggleZoneDropdown()
    isZoneDropdownOpen = not isZoneDropdownOpen
    ZoneDropdownToggleBtn.Text = AvailableZones[CurrentZoneIndex] .. (isZoneDropdownOpen and " ▴" or " ▾")
    if isZoneDropdownOpen then
        ZoneOptionsContainer.Visible = true
        TweenService:Create(ZoneOptionsContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, totalOptHeight)
        }):Play()
    else
        local tw = TweenService:Create(ZoneOptionsContainer, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 0)
        })
        tw:Play()
        tw.Completed:Connect(function()
            if not isZoneDropdownOpen then ZoneOptionsContainer.Visible = false end
        end)
    end
end

ZoneDropdownToggleBtn.MouseButton1Click:Connect(toggleZoneDropdown)

PrevZoneBtn.MouseButton1Click:Connect(function()
    local newIdx = CurrentZoneIndex - 1
    if newIdx < 1 then newIdx = #AvailableZones end
    updateZoneSelection(newIdx, true)
end)

NextZoneBtn.MouseButton1Click:Connect(function()
    local newIdx = CurrentZoneIndex + 1
    if newIdx > #AvailableZones then newIdx = 1 end
    updateZoneSelection(newIdx, true)
end)

-- 2. Auto Steal Astral Eggs Only
AddToggleRow("2. Auto Steal Astral Eggs Only", "AutoStealAstral", function(enabled)
    if enabled then
        Toggles.AutoStealBest = false
        if ToggleVisualUpdaters["AutoStealBest"] then ToggleVisualUpdaters["AutoStealBest"]() end
        table.clear(CooldownEggs)
        ShowNotification("VIP Steal", "Targeting God-Tier Astral & Abyssal Eggs Only!")
    end
end)

-- 3. Remove All Guards (Chaser Fishes)
AddToggleRow("3. Remove All Guards (Fishes)", "RemoveGuards", function(enabled)
    if enabled then
        SweepAndRemoveAllGuards()
        ShowNotification("Remove Guards", "All Guard Fishes & Sharks Neutralized!")
    end
end)

-- 4. Instant Teleport to All Biomes
local TPMainRow = Instance.new("Frame")
TPMainRow.Name = "TPMainRow"
TPMainRow.Size = UDim2.new(1, 0, 0, 24)
TPMainRow.BackgroundTransparency = 1
TPMainRow.LayoutOrder = getNextOrder()
TPMainRow.Parent = FeaturesContainer

local TPMainLabel = Instance.new("TextLabel")
TPMainLabel.Size = UDim2.new(0.5, 0, 1, 0)
TPMainLabel.BackgroundTransparency = 1
TPMainLabel.Text = "4. Biome Teleporter"
TPMainLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TPMainLabel.TextSize = 12
TPMainLabel.Font = Enum.Font.GothamBold
TPMainLabel.TextXAlignment = Enum.TextXAlignment.Left
TPMainLabel.Parent = TPMainRow

local TPOpenBtn = Instance.new("TextButton")
TPOpenBtn.Size = UDim2.new(0.48, 0, 1, 0)
TPOpenBtn.Position = UDim2.new(0.52, 0, 0, 0)
TPOpenBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
TPOpenBtn.BorderSizePixel = 0
TPOpenBtn.Text = "Open Teleports ▾"
TPOpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TPOpenBtn.Font = Enum.Font.GothamBold
TPOpenBtn.TextSize = 10
TPOpenBtn.Parent = TPMainRow

local TPOpenCorner = Instance.new("UICorner")
TPOpenCorner.CornerRadius = UDim.new(0, 4)
TPOpenCorner.Parent = TPOpenBtn

local TPOpenStroke = Instance.new("UIStroke")
TPOpenStroke.Color = Color3.fromRGB(45, 45, 55)
TPOpenStroke.Thickness = 1
TPOpenStroke.Parent = TPOpenBtn

local TPOptionsContainer = Instance.new("Frame")
TPOptionsContainer.Name = "TPOptionsContainer"
TPOptionsContainer.Size = UDim2.new(1, 0, 0, 0)
TPOptionsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
TPOptionsContainer.BorderSizePixel = 0
TPOptionsContainer.Visible = false
TPOptionsContainer.ClipsDescendants = true
TPOptionsContainer.LayoutOrder = getNextOrder()
TPOptionsContainer.Parent = FeaturesContainer

local TPOptCorner = Instance.new("UICorner")
TPOptCorner.CornerRadius = UDim.new(0, 6)
TPOptCorner.Parent = TPOptionsContainer

local TPOptStroke = Instance.new("UIStroke")
TPOptStroke.Color = Color3.fromRGB(38, 38, 46)
TPOptStroke.Thickness = 1
TPOptStroke.Parent = TPOptionsContainer

local TPOptLayout = Instance.new("UIGridLayout")
TPOptLayout.CellSize = UDim2.new(0.48, 0, 0, 22)
TPOptLayout.CellPadding = UDim2.new(0.04, 0, 0, 3)
TPOptLayout.SortOrder = Enum.SortOrder.LayoutOrder
TPOptLayout.Parent = TPOptionsContainer

local TPOptPadding = Instance.new("UIPadding")
TPOptPadding.PaddingTop = UDim.new(0, 4)
TPOptPadding.PaddingBottom = UDim.new(0, 4)
TPOptPadding.PaddingLeft = UDim.new(0, 4)
TPOptPadding.PaddingRight = UDim.new(0, 4)
TPOptPadding.Parent = TPOptionsContainer

local tpLocations = {
    { name = "🏠 Base Tank", target = "Base" },
    { name = "🏁 Escape Line", target = "EscapeLine" },
    { name = "🌊 Coral Reef", target = "Coral Reef" },
    { name = "🌊 Deep Ocean", target = "Deep Ocean" },
    { name = "🌊 Pearl Lagoon", target = "Pearl Lagoon" },
    { name = "🌊 Snowy Sea", target = "Snowy Sea" },
    { name = "🌊 Volcanic Sea", target = "Volcanic Sea" },
    { name = "🌊 Jelly Ocean", target = "Jelly Ocean" },
    { name = "🌊 Sunken Ruins", target = "Sunken Ruins" },
    { name = "🌊 Atlantis", target = "Atlantis" }
}

for idx, loc in ipairs(tpLocations) do
    local tpBtn = Instance.new("TextButton")
    tpBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    tpBtn.BorderSizePixel = 0
    tpBtn.AutoButtonColor = false
    tpBtn.Text = loc.name
    tpBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    tpBtn.Font = Enum.Font.GothamBold
    tpBtn.TextSize = 9
    tpBtn.LayoutOrder = idx
    tpBtn.Parent = TPOptionsContainer

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 4)
    bCorner.Parent = tpBtn

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(38, 38, 46)
    bStroke.Thickness = 1
    bStroke.Parent = tpBtn

    tpBtn.MouseButton1Click:Connect(function()
        TeleportToLocation(loc.target)
    end)
end

local isTPOpen = false
local totalTPHeight = 5 * 25 + 10

TPOpenBtn.MouseButton1Click:Connect(function()
    isTPOpen = not isTPOpen
    TPOpenBtn.Text = isTPOpen and "Close Teleports ▴" or "Open Teleports ▾"
    if isTPOpen then
        TPOptionsContainer.Visible = true
        TweenService:Create(TPOptionsContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, totalTPHeight)
        }):Play()
    else
        local tw = TweenService:Create(TPOptionsContainer, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 0)
        })
        tw:Play()
        tw.Completed:Connect(function()
            if not isTPOpen then TPOptionsContainer.Visible = false end
        end)
    end
end)

-- 5. Integrated WalkSpeed Boost Row (- / + Pill Adjuster)
local SpeedRow = Instance.new("Frame")
SpeedRow.Name = "SpeedRow"
SpeedRow.Size = UDim2.new(1, 0, 0, 23)
SpeedRow.BackgroundTransparency = 1
SpeedRow.LayoutOrder = getNextOrder()
SpeedRow.Parent = FeaturesContainer

local SpeedToggleBtn = Instance.new("TextButton")
SpeedToggleBtn.Size = UDim2.new(0.55, 0, 1, 0)
SpeedToggleBtn.BackgroundTransparency = 1
SpeedToggleBtn.Text = ""
SpeedToggleBtn.ZIndex = 5
SpeedToggleBtn.Parent = SpeedRow

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -26, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "5. WalkSpeed Boost"
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

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
    UpdateCharacterSpeed()
end)

MinusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.max(16, CustomSpeedValue - 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

-- 6. Fly Mode with Interactive Line Bar Slider
AddToggleRow("6. Fly Mode (WASD / Mobile)", "FlyMode", function(enabled)
    if enabled then
        StartFly()
        ShowNotification("Fly Mode", "Flying enabled! (Speed: " .. CustomFlySpeedValue .. ")")
    else
        StopFly()
        ShowNotification("Fly Mode", "Flying disabled")
    end
end)

-- Fly Speed Slider Row (Modern Line Bar Slider)
local FlySliderRow = Instance.new("Frame")
FlySliderRow.Name = "FlySliderRow"
FlySliderRow.Size = UDim2.new(1, 0, 0, 22)
FlySliderRow.BackgroundTransparency = 1
FlySliderRow.LayoutOrder = getNextOrder()
FlySliderRow.Parent = FeaturesContainer

local FlySliderLabel = Instance.new("TextLabel")
FlySliderLabel.Size = UDim2.new(0.48, 0, 1, 0)
FlySliderLabel.BackgroundTransparency = 1
FlySliderLabel.Text = "Fly Speed: " .. CustomFlySpeedValue
FlySliderLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
FlySliderLabel.TextSize = 10
FlySliderLabel.Font = Enum.Font.GothamMedium
FlySliderLabel.TextXAlignment = Enum.TextXAlignment.Left
FlySliderLabel.Parent = FlySliderRow

local SliderTrack = Instance.new("TextButton")
SliderTrack.Name = "SliderTrack"
SliderTrack.Size = UDim2.new(0.5, 0, 0, 6)
SliderTrack.Position = UDim2.new(0.5, 0, 0.5, -3)
SliderTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
SliderTrack.BorderSizePixel = 0
SliderTrack.Text = ""
SliderTrack.AutoButtonColor = false
SliderTrack.Parent = FlySliderRow

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(1, 0)
TrackCorner.Parent = SliderTrack

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new((CustomFlySpeedValue - 20) / (200 - 20), 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = SliderFill

local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 12, 0, 12)
SliderKnob.Position = UDim2.new(1, -6, 0.5, -6)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.BorderSizePixel = 0
SliderKnob.Parent = SliderFill

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = SliderKnob

local isDraggingFly = false
local function UpdateFlySlider(input)
    local trackPos = SliderTrack.AbsolutePosition.X
    local trackWidth = SliderTrack.AbsoluteSize.X
    if trackWidth <= 0 then return end
    local mousePos = input.Position.X
    local percent = math.clamp((mousePos - trackPos) / trackWidth, 0, 1)
    CustomFlySpeedValue = math.floor(20 + percent * (200 - 20))
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    FlySliderLabel.Text = "Fly Speed: " .. CustomFlySpeedValue
end

SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingFly = true
        UpdateFlySlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingFly and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        UpdateFlySlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingFly = false
    end
end)

-- 7. Rare Egg Only ESP
AddToggleRow("7. Rare Egg ESP (Highlights)", "RareEggESP", function(enabled)
    if enabled then
        UpdateRareEggESP()
        ShowNotification("ESP", "Highlighting Rare & Astral Eggs!")
    else
        ClearAllESP()
    end
end)

-- =================================================================
-- DRAGGABLE WINDOW HANDLING
-- =================================================================
local isDragging = false
local dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = MainWindow.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
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
    if input == dragInput and isDragging then
        local delta = input.Position - dragStart
        MainWindow.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

ShowNotification("Junejo Script Hub", "Steal Fish Eggs Custom Edition Loaded!")
print("Junejo Ultra Script Hub loaded successfully for Steal Fish Eggs!")
