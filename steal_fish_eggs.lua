-- =================================================================
-- JUNEJO SCRIPT HUB: STEAL FISH EGGS (ULTRA MASTER V3)
-- Game: Steal Fish Eggs (PlaceId: 99183404085821)
-- Creator: Made by Junejo (junejo18146)
-- Repository: ultrascripthub
-- UI Design: Official Junejo Classic Executive Dark Standard (100% Flat & Borderless)
-- 100% Core Decompiled Game Mechanics & Multi-Layer Fail-Proof Engine
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

-- Safe GUI Container Resolver
local function GetSafeUIContainer()
    local container = nil
    pcall(function()
        if gethui then
            container = gethui()
        end
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
        pcall(function()
            container = CoreGui
        end)
    end
    if not container or not pcall(function() local _ = container.Name end) then
        pcall(function()
            container = LocalPlayer:WaitForChild("PlayerGui", 5)
        end)
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
    ["Astral"] = Color3.fromRGB(255, 105, 180),
    ["Abyssal"] = Color3.fromRGB(0, 255, 255),
    ["Mythic"] = Color3.fromRGB(255, 60, 60),
    ["Legendary"] = Color3.fromRGB(255, 215, 0),
    ["Epic"] = Color3.fromRGB(168, 85, 247),
    ["Rare"] = Color3.fromRGB(60, 140, 255),
    ["Basic"] = Color3.fromRGB(180, 180, 180)
}

-- =================================================================
-- GLOBAL TOGGLES & STATES
-- =================================================================
local Toggles = {
    AutoSteal = false,
    RemoveGuards = false,
    AutoHatch = false,
    AutoPlace = false,
    AutoTrainSwimSpeed = false,
    AutoCollectMoney = false,
    AutoUpgradeBase = false,
    FlyMode = false,
    Noclip = false,
    RareEggOnlyESP = false,
    PlayerESP = false,
    AntiAFK = true
}

local FlySpeedValue = 50
local SavedBaseCFrame = nil
local CurrentRareEggESPInstances = {}
local CurrentPlayerESPInstances = {}
local CooldownEggs = {}
local ToggleVisualUpdaters = {}

-- Safe Alive Check
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

local function getRoot()
    if isAlive() then
        return LocalPlayer.Character.HumanoidRootPart
    end
    return nil
end

local function getHum()
    if isAlive() then
        return LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
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
        Toast.Size = UDim2.new(0, 210, 0, 36)
        Toast.Position = UDim2.new(0.5, -105, 0.08, 0)
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
        MsgLbl.Size = UDim2.new(1, -12, 0, 15)
        MsgLbl.Position = UDim2.new(0, 8, 0, 18)
        MsgLbl.BackgroundTransparency = 1
        MsgLbl.Text = message
        MsgLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
        MsgLbl.TextSize = 9
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

-- Multi-Layer ProximityPrompt Trigger
local function InstantTriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 999999
        prompt.HoldDuration = 0
        prompt.Enabled = true

        if fireproximityprompt then
            pcall(function() fireproximityprompt(prompt) end)
            pcall(function() fireproximityprompt(prompt, 0) end)
            pcall(function() fireproximityprompt(prompt, 1) end)
        end

        task.spawn(function()
            pcall(function()
                if prompt.InputHoldBegin and prompt.InputHoldEnd then
                    prompt:InputHoldBegin()
                    task.wait(0.04)
                    prompt:InputHoldEnd()
                end
            end)
        end)
    end)
end

-- Touch Interest Helper
local function InstantTouch(part, targetPart)
    if not part or not targetPart then return end
    pcall(function()
        if firetouchinterest then
            firetouchinterest(part, targetPart, 0)
            task.wait()
            firetouchinterest(part, targetPart, 1)
            firetouchinterest(targetPart, part, 0)
            task.wait()
            firetouchinterest(targetPart, part, 1)
        end
    end)
end

local function TouchWithCharacter(targetPart)
    if not targetPart or not isAlive() then return end
    local char = LocalPlayer.Character
    local partsToTouch = {
        char:FindFirstChild("HumanoidRootPart"),
        char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg"),
        char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg"),
        char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
        char:FindFirstChild("Head")
    }
    for _, p in ipairs(partsToTouch) do
        if p then
            InstantTouch(p, targetPart)
        end
    end
end

-- =================================================================
-- BASE & PLACEMENT RESOLUTION ENGINE (Multi-Layer Robust)
-- =================================================================
local function GetPlayerBase()
    -- 1. Check Workspace.Bases
    local basesFolder = Workspace:FindFirstChild("Bases") or Workspace:FindFirstChild("PlayerBases") or Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("Tycoons")
    if basesFolder then
        local baseName = LocalPlayer:GetAttribute("BaseName")
        if type(baseName) == "string" and baseName ~= "" then
            local b = basesFolder:FindFirstChild(baseName)
            if b then return b end
        end

        for _, b in ipairs(basesFolder:GetChildren()) do
            if b:IsA("Model") or b:IsA("Folder") then
                local ownerAttr = b:GetAttribute("OwnerUserId") or b:GetAttribute("Owner") or b:GetAttribute("Player")
                if tonumber(ownerAttr) == LocalPlayer.UserId or tostring(ownerAttr) == tostring(LocalPlayer.UserId) or tostring(ownerAttr) == LocalPlayer.Name then
                    return b
                end
                local ownerVal = b:FindFirstChild("Owner") or b:FindFirstChild("Player") or b:FindFirstChild("OwnerValue")
                if ownerVal then
                    if ownerVal:IsA("ObjectValue") and ownerVal.Value == LocalPlayer then
                        return b
                    elseif tostring(ownerVal.Value) == LocalPlayer.Name or tostring(ownerVal.Value) == tostring(LocalPlayer.UserId) then
                        return b
                    end
                end
            end
        end
    end

    -- 2. Global search for base belonging to player
    for _, item in ipairs(Workspace:GetChildren()) do
        if item:IsA("Model") and (item.Name:find("Base") or item.Name:find("Plot") or item.Name:find("Tycoon")) then
            local ownerAttr = item:GetAttribute("OwnerUserId") or item:GetAttribute("Owner")
            if tonumber(ownerAttr) == LocalPlayer.UserId or tostring(ownerAttr) == tostring(LocalPlayer.UserId) or tostring(ownerAttr) == LocalPlayer.Name then
                return item
            end
        end
    end

    return nil
end

local function GetPlayerPlacementZone()
    local base = GetPlayerBase()
    if base then
        local zone = base:FindFirstChild("EggPlacementZone", true) or base:FindFirstChild("PlacementZone", true) or base:FindFirstChild("PlaceZone", true)
        if zone and zone:IsA("BasePart") then
            return zone
        end
        local tank = base:FindFirstChild("FishTank", true) or base:FindFirstChild("Tank", true) or base:FindFirstChild("MainTank", true)
        if tank then
            local part = tank:FindFirstChildWhichIsA("BasePart", true)
            if part then return part end
        end
    end

    -- Fallback: Global search
    local globalZone = Workspace:FindFirstChild("EggPlacementZone", true)
    if globalZone and globalZone:IsA("BasePart") then return globalZone end

    return nil
end

local function GetPlayerPlacementWorldPosition()
    local zone = GetPlayerPlacementZone()
    if zone then
        local cf = zone.CFrame
        local halfY = zone.Size.Y * 0.5
        return cf:PointToWorldSpace(Vector3.new(0, halfY, 0))
    end
    return nil
end

local function GetPlayerBaseCFrame()
    if SavedBaseCFrame then return SavedBaseCFrame end
    local zone = GetPlayerPlacementZone()
    if zone then
        SavedBaseCFrame = zone.CFrame + Vector3.new(0, 3, 0)
        return SavedBaseCFrame
    end
    local base = GetPlayerBase()
    if base then
        local spawnPart = base:FindFirstChild("Spawn", true) or base:FindFirstChildWhichIsA("SpawnLocation", true) or base:FindFirstChildWhichIsA("BasePart", true)
        if spawnPart then
            SavedBaseCFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
            return SavedBaseCFrame
        end
        SavedBaseCFrame = base:GetPivot() + Vector3.new(0, 3, 0)
        return SavedBaseCFrame
    end
    if isAlive() then
        return LocalPlayer.Character.HumanoidRootPart.CFrame
    end
    return nil
end

-- Resolve "The Line" / Safe Escape Boundary Part
local function GetTheLinePart()
    local theLine = Workspace:FindFirstChild("TheLine") or Workspace:FindFirstChild("Line") or Workspace:FindFirstChild("FinishLine") or Workspace:FindFirstChild("SafeZone")
    if theLine then
        local part = theLine:FindFirstChild("TheLinePart", true) or theLine:FindFirstChild("LinePart", true) or theLine:FindFirstChildWhichIsA("BasePart", true)
        if part and part:IsA("BasePart") then
            return part
        end
    end
    local directPart = Workspace:FindFirstChild("TheLinePart", true) or Workspace:FindFirstChild("LinePart", true) or Workspace:FindFirstChild("SafeZonePart", true)
    if directPart and directPart:IsA("BasePart") then
        return directPart
    end
    return nil
end

-- Check if player is carrying an egg
local function IsCarryingEgg()
    if LocalPlayer:GetAttribute("CarryingEgg") == true or LocalPlayer:GetAttribute("TutorialCarryingEgg") == true or LocalPlayer:GetAttribute("HasEgg") == true then
        return true
    end

    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and (item:GetAttribute("EggType") ~= nil or item.Name:lower():find("egg")) then
                return true
            end
        end
    end

    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and (item:GetAttribute("EggType") ~= nil or item.Name:lower():find("egg")) then
                return true
            end
        end
    end

    local carriedEggs = Workspace:FindFirstChild("CarriedEggs")
    if carriedEggs then
        for _, egg in ipairs(carriedEggs:GetChildren()) do
            if tonumber(egg:GetAttribute("OwnerUserId")) == LocalPlayer.UserId or tostring(egg:GetAttribute("OwnerUserId")) == tostring(LocalPlayer.UserId) then
                return true
            end
        end
    end

    return false
end

-- Get equipped egg tool
local function GetEquippedEggTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and (item:GetAttribute("EggType") ~= nil or item.Name:lower():find("egg")) then
            return item
        end
    end
    return nil
end

-- Ensure egg tool is equipped
local function EquipCarriedEggTool()
    local char = LocalPlayer.Character
    local hum = getHum()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if char and hum and bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and (item:GetAttribute("EggType") ~= nil or item.Name:lower():find("egg")) then
                hum:EquipTool(item)
                task.wait(0.08)
                return item
            end
        end
    end
    return GetEquippedEggTool()
end

-- =================================================================
-- GAME FEATURE 1: AUTO STEAL EGGS (ZONE FILTER + LINE ESCAPE + TANK)
-- =================================================================
local function GetZoneBiomeFolder(internalName)
    local biomesFolder = Workspace:FindFirstChild("Biomes") or Workspace:FindFirstChild("Zones") or Workspace:FindFirstChild("Oceans")
    if biomesFolder and internalName ~= "ALL" then
        return biomesFolder:FindFirstChild(internalName)
    end
    return nil
end

local function GetBestEggInZone(chosenBiomeInternal)
    local candidates = {}

    local biomeFolder = GetZoneBiomeFolder(chosenBiomeInternal)
    local biomeCenterPos = nil
    if biomeFolder then
        local bp = biomeFolder:FindFirstChild("BiomePart", true) or biomeFolder:FindFirstChildWhichIsA("BasePart", true)
        if bp then
            biomeCenterPos = bp.Position
        end
    end

    -- 1. Check Workspace.SpawnedEggs / Eggs
    local eggFolders = {
        Workspace:FindFirstChild("SpawnedEggs"),
        Workspace:FindFirstChild("Eggs"),
        Workspace:FindFirstChild("WorldEggs"),
        Workspace:FindFirstChild("ActiveEggs")
    }

    for _, folder in ipairs(eggFolders) do
        if folder then
            for _, egg in ipairs(folder:GetChildren()) do
                if egg:IsA("Model") and not CooldownEggs[egg] then
                    local eggBiome = tostring(egg:GetAttribute("Biome") or "")
                    local isMatch = false

                    if chosenBiomeInternal == "ALL" then
                        isMatch = true
                    elseif eggBiome == chosenBiomeInternal or eggBiome:lower() == chosenBiomeInternal:lower() then
                        isMatch = true
                    elseif biomeCenterPos then
                        local pivot = egg:GetPivot()
                        if (pivot.Position - biomeCenterPos).Magnitude < 350 then
                            isMatch = true
                        end
                    end

                    if isMatch then
                        local rarity = tostring(egg:GetAttribute("Rarity") or "Basic")
                        local score = RarityScores[rarity] or 1000
                        table.insert(candidates, { Model = egg, Score = score, Pivot = egg:GetPivot() })
                    end
                end
            end
        end
    end

    -- 2. Fallback: Check Biome EggSpawns
    if #candidates == 0 and biomeFolder then
        for _, child in ipairs(biomeFolder:GetDescendants()) do
            if child:IsA("Model") and not CooldownEggs[child] and (child.Name:lower():find("egg") or child:GetAttribute("Rarity") ~= nil or child:FindFirstChildWhichIsA("ProximityPrompt", true)) then
                local rarity = tostring(child:GetAttribute("Rarity") or "Basic")
                local score = RarityScores[rarity] or 1000
                table.insert(candidates, { Model = child, Score = score, Pivot = child:GetPivot() })
            end
        end
    end

    -- 3. Ultimate Fallback: Global recursive search
    if #candidates == 0 then
        for _, item in ipairs(Workspace:GetChildren()) do
            if item:IsA("Model") and not CooldownEggs[item] and (item:GetAttribute("Rarity") ~= nil or (item.Name:lower():find("egg") and not item.Name:lower():find("placed") and not item.Name:lower():find("carried"))) then
                local rarity = tostring(item:GetAttribute("Rarity") or "Basic")
                local score = RarityScores[rarity] or 1000
                table.insert(candidates, { Model = item, Score = score, Pivot = item:GetPivot() })
            end
        end
    end

    if #candidates == 0 then return nil end

    table.sort(candidates, function(a, b)
        return a.Score > b.Score
    end)

    return candidates[1].Model
end

task.spawn(function()
    while true do
        if Toggles.AutoSteal then
            pcall(function()
                if isAlive() then
                    local hrp = getRoot()
                    local hum = getHum()

                    if IsCarryingEgg() then
                        -- STEP 1: CROSS "THE LINE" TO REGISTER ESCAPE
                        local linePart = GetTheLinePart()
                        if linePart then
                            hrp.CFrame = linePart.CFrame + Vector3.new(0, 3, 0)
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            TouchWithCharacter(linePart)
                            task.wait(0.2)
                        end

                        -- STEP 2: DELIVER EGG TO BASE TANK
                        local placeZone = GetPlayerPlacementZone()
                        local placePos = GetPlayerPlacementWorldPosition()
                        local baseCF = placeZone and (placeZone.CFrame + Vector3.new(0, 3, 0)) or GetPlayerBaseCFrame()

                        if baseCF then
                            hrp.CFrame = baseCF
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            task.wait(0.15)

                            EquipCarriedEggTool()

                            -- Fire exact place remote
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

                            if placeZone then
                                TouchWithCharacter(placeZone)
                            end

                            task.wait(0.3)
                        end
                    else
                        -- FIND AND STEAL BEST EGG IN CHOSEN ZONE
                        local chosenBiomeName = AvailableZones[CurrentZoneIndex]
                        local chosenBiomeInternal = ZoneInternalMap[chosenBiomeName] or "ALL"
                        local targetEgg = GetBestEggInZone(chosenBiomeInternal)

                        if targetEgg and targetEgg.Parent then
                            local pivot = targetEgg:GetPivot()
                            hrp.CFrame = pivot * CFrame.new(0, 0.5, 0)
                            hrp.AssemblyLinearVelocity = Vector3.zero

                            -- Multi-Layer Prompt & Touch
                            local prompt = targetEgg:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt then
                                InstantTriggerPrompt(prompt)
                            end

                            for _, p in ipairs(targetEgg:GetDescendants()) do
                                if p:IsA("BasePart") then
                                    TouchWithCharacter(p)
                                    InstantTouch(hrp, p)
                                end
                            end

                            -- Remote pickup try
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
                            task.delay(4, function()
                                CooldownEggs[targetEgg] = nil
                            end)
                        else
                            task.wait(0.35)
                        end
                    end
                end
            end)
            task.wait(0.08)
        else
            task.wait(0.4)
        end
    end
end)

-- =================================================================
-- GAME FEATURE 2: REMOVE GUARDS (COMPREHENSIVE MULTI-LAYER KILLER)
-- Neutralizes ALL guard fishes, chasers, sharks, hazards & obstacles!
-- =================================================================
local function NeutralizeGuard(guard)
    if not guard or not guard:IsA("Model") or guard == LocalPlayer.Character then return end
    -- Check if it is another player
    if Players:GetPlayerFromCharacter(guard) then return end

    pcall(function()
        -- 1. Teleport model far below world
        guard:PivotTo(CFrame.new(0, -99999, 0))

        -- 2. Strip collision, touching, query, transparency and size
        for _, p in ipairs(guard:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanTouch = false
                p.CanCollide = false
                p.CanQuery = false
                p.Transparency = 1
                p.Size = Vector3.new(0.001, 0.001, 0.001)
                p.CFrame = CFrame.new(0, -99999, 0)
                p.AssemblyLinearVelocity = Vector3.zero
                p.AssemblyAngularVelocity = Vector3.zero
            elseif p:IsA("TouchTransmitter") then
                p:Destroy()
            end
        end

        -- 3. Kill Humanoid if present
        local hum = guard:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
            hum.MaxHealth = 0
            hum:ChangeState(Enum.HumanoidStateType.Dead)
        end

        -- 4. Destroy client-side
        guard:Destroy()
    end)
end

local function IsGuardOrFish(model)
    if not model or not model:IsA("Model") or model == LocalPlayer.Character then return false end
    if Players:GetPlayerFromCharacter(model) then return false end

    local name = model.Name:lower()
    local isMatch = false

    -- Check attributes
    if model:GetAttribute("ChaserAggroActive") ~= nil or model:GetAttribute("IsGuard") ~= nil or model:GetAttribute("IsChaser") ~= nil or model:GetAttribute("Chaser") ~= nil then
        return true
    end

    -- Match fish/guard names
    local keywords = {
        "chaser", "guard", "fish", "shark", "piranha", "coralreef", "deepocean",
        "hazard", "enemy", "monster", "obstacle", "creature", "jellyfish", "angler",
        "dolphin", "killer", "attacker", "ray", "squid", "patrol", "leviathan"
    }
    for _, kw in ipairs(keywords) do
        if name:find(kw) then
            return true
        end
    end

    -- Check if model has a Humanoid and is an NPC swimming in workspace
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum and not Players:GetPlayerFromCharacter(model) then
        return true
    end

    return false
end

local function SweepAndRemoveAllGuards()
    pcall(function()
        -- 1. Check known specific folders
        local guardFolders = {
            Workspace:FindFirstChild("ChaserFishes"),
            Workspace:FindFirstChild("ActiveChaserFishes"),
            Workspace:FindFirstChild("Chasers"),
            Workspace:FindFirstChild("Guards"),
            Workspace:FindFirstChild("FishGuards"),
            Workspace:FindFirstChild("Fishes"),
            Workspace:FindFirstChild("Fish"),
            Workspace:FindFirstChild("Enemies"),
            Workspace:FindFirstChild("NPCs"),
            Workspace:FindFirstChild("Creatures"),
            Workspace:FindFirstChild("Hazards"),
            Workspace:FindFirstChild("Obstacles")
        }

        for _, folder in ipairs(guardFolders) do
            if folder then
                for _, g in ipairs(folder:GetChildren()) do
                    if g:IsA("Model") then
                        NeutralizeGuard(g)
                    end
                end
            end
        end

        -- 2. Sweep Workspace Biomes
        local biomesFolder = Workspace:FindFirstChild("Biomes") or Workspace:FindFirstChild("Zones") or Workspace:FindFirstChild("Oceans")
        if biomesFolder then
            for _, item in ipairs(biomesFolder:GetDescendants()) do
                if item:IsA("Model") and IsGuardOrFish(item) then
                    NeutralizeGuard(item)
                end
            end
        end

        -- 3. Sweep all Workspace Children
        for _, m in ipairs(Workspace:GetChildren()) do
            if m:IsA("Model") and IsGuardOrFish(m) then
                NeutralizeGuard(m)
            end
        end
    end)
end

-- Continuous Guard Removal Loop
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

-- Instant Neutralization on Spawn
Workspace.ChildAdded:Connect(function(child)
    if Toggles.RemoveGuards and child:IsA("Model") then
        task.wait(0.02)
        if IsGuardOrFish(child) then
            NeutralizeGuard(child)
        end
    end
end)

Workspace.DescendantAdded:Connect(function(desc)
    if Toggles.RemoveGuards and desc:IsA("Model") then
        if IsGuardOrFish(desc) then
            task.wait(0.02)
            NeutralizeGuard(desc)
        end
    end
end)

-- Proximity Kill Shield: Protects LocalPlayer every step
RunService.Heartbeat:Connect(function()
    if Toggles.RemoveGuards and isAlive() then
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, m in ipairs(Workspace:GetChildren()) do
            if m:IsA("Model") and m ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(m) then
                if IsGuardOrFish(m) then
                    local pivot = m:GetPivot()
                    if (pivot.Position - myPos).Magnitude < 100 then
                        NeutralizeGuard(m)
                    end
                end
            end
        end
    end
end)

-- =================================================================
-- GAME FEATURE 3: AUTO HATCH (DIRECT REMOTES + PROMPTS + UI)
-- =================================================================
task.spawn(function()
    while true do
        if Toggles.AutoHatch then
            pcall(function()
                local eggSys = ReplicatedStorage:FindFirstChild("EggSystem") or ReplicatedStorage
                local hatchRemote = eggSys:FindFirstChild("HatchEgg", true) or eggSys:FindFirstChild("Hatch", true) or ReplicatedStorage:FindFirstChild("HatchEgg", true)

                -- 1. Placed Eggs in Workspace
                local placedFolders = {
                    Workspace:FindFirstChild("PlacedEggs"),
                    Workspace:FindFirstChild("EggsPlaced"),
                    Workspace:FindFirstChild("PlayerPlacedEggs")
                }

                for _, folder in ipairs(placedFolders) do
                    if folder then
                        for _, egg in ipairs(folder:GetChildren()) do
                            if egg:IsA("Model") then
                                local ownerId = tonumber(egg:GetAttribute("OwnerUserId")) or tostring(egg:GetAttribute("OwnerUserId")) or tostring(egg:GetAttribute("Owner"))
                                if ownerId == LocalPlayer.UserId or ownerId == tostring(LocalPlayer.UserId) or ownerId == LocalPlayer.Name then
                                    if egg:GetAttribute("HatchReady") == true or egg:GetAttribute("Ready") == true or egg:GetAttribute("CanHatch") == true then
                                        if hatchRemote then hatchRemote:FireServer(egg) end
                                        local prompt = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
                                        if prompt then InstantTriggerPrompt(prompt) end
                                    end
                                end
                            end
                        end
                    end
                end

                -- 2. Placed Eggs inside Player's Base
                local base = GetPlayerBase()
                if base then
                    for _, child in ipairs(base:GetDescendants()) do
                        if child:IsA("Model") and child.Name:lower():find("egg") then
                            if child:GetAttribute("HatchReady") == true or child:GetAttribute("Ready") == true then
                                if hatchRemote then hatchRemote:FireServer(child) end
                                local prompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then InstantTriggerPrompt(prompt) end
                            end
                        end
                    end
                end

                -- 3. Click Open / Hatch UI Buttons in PlayerGui
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then
                    for _, btn in ipairs(pGui:GetDescendants()) do
                        if btn:IsA("GuiButton") and btn.Visible and (btn.Name:lower() == "open" or btn.Name:lower() == "hatch" or btn.Name:lower() == "claim") then
                            pcall(function()
                                if getconnections then
                                    for _, conn in ipairs(getconnections(btn.Activated)) do conn:Fire() end
                                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
                                end
                            end)
                        end
                    end
                end
            end)
            task.wait(0.3)
        else
            task.wait(1)
        end
    end
end)

-- =================================================================
-- GAME FEATURE 4: AUTO PLACE (AUTO EQUIP & TANK DEPOSIT)
-- =================================================================
task.spawn(function()
    while true do
        if Toggles.AutoPlace then
            pcall(function()
                if IsCarryingEgg() and isAlive() then
                    EquipCarriedEggTool()

                    local placeZone = GetPlayerPlacementZone()
                    local placePos = GetPlayerPlacementWorldPosition()
                    local eggSys = ReplicatedStorage:FindFirstChild("EggSystem") or ReplicatedStorage
                    local placeRemote = eggSys:FindFirstChild("PlaceEgg", true) or eggSys:FindFirstChild("Place", true) or ReplicatedStorage:FindFirstChild("PlaceEgg", true)

                    if placeRemote and placeRemote:IsA("RemoteEvent") then
                        if placePos then
                            placeRemote:FireServer(placePos)
                        end
                        placeRemote:FireServer()
                    end

                    if placeZone then
                        TouchWithCharacter(placeZone)
                    end
                end
            end)
            task.wait(0.25)
        else
            task.wait(0.8)
        end
    end
end)

-- =================================================================
-- GAME FEATURE 5: AUTO TRAIN SWIM SPEED (TREADPOOL AUTOMATION)
-- =================================================================
task.spawn(function()
    while true do
        if Toggles.AutoTrainSwimSpeed then
            pcall(function()
                if isAlive() then
                    local hrp = getRoot()
                    local hum = getHum()

                    -- 1. Find Own TreadPool
                    local wsPools = Workspace:FindFirstChild("LocalTreadPools") or Workspace:FindFirstChild("TreadPools") or Workspace:FindFirstChild("Pools")
                    local ownPool = wsPools and wsPools:FindFirstChild("OwnTreadPool")
                    local targetPool = ownPool or (wsPools and wsPools:FindFirstChild("AdminTreadPool")) or (Workspace:FindFirstChild("TreadPools") and Workspace.TreadPools:FindFirstChild("AdminTreadPool"))

                    if not targetPool then
                        local base = GetPlayerBase()
                        if base then
                            targetPool = base:FindFirstChild("TreadPool", true) or base:FindFirstChild("Pool", true)
                        end
                    end

                    if targetPool and hrp then
                        local actPart = targetPool:FindFirstChild("ActivationPart", true) or targetPool:FindFirstChildWhichIsA("BasePart", true)
                        if actPart then
                            hrp.CFrame = actPart.CFrame + Vector3.new(0, 1.5, 0)
                            hrp.AssemblyLinearVelocity = Vector3.zero
                        end
                    end

                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Swimming)
                    end

                    -- Fire TreadPool remotes
                    local tpFolder = ReplicatedStorage:FindFirstChild("TreadPools") or ReplicatedStorage
                    local tpRemote = tpFolder:FindFirstChild("TreadPoolRemote", true) or tpFolder:FindFirstChild("TrainRemote", true)
                    if tpRemote and tpRemote:IsA("RemoteEvent") then
                        tpRemote:FireServer("Start")
                    end

                    local adminRemote = tpFolder:FindFirstChild("AdminTreadPoolRemote", true)
                    if adminRemote and adminRemote:IsA("RemoteEvent") then
                        adminRemote:FireServer("Start")
                    end

                    -- If Level 0, purchase TreadPool
                    if tonumber(LocalPlayer:GetAttribute("TreadPoolLevel") or 0) == 0 then
                        local poolLevels = ReplicatedStorage:FindFirstChild("TreadPoolLevels") or ReplicatedStorage
                        local upPool = poolLevels:FindFirstChild("UpgradeTreadPool", true)
                        if upPool and upPool:IsA("RemoteEvent") then upPool:FireServer("PurchaseFirst") end
                    end
                end
            end)
            task.wait(0.2)
        else
            task.wait(0.8)
        end
    end
end)

-- =================================================================
-- GAME FEATURE 6: AUTO COLLECT MONEY
-- =================================================================
task.spawn(function()
    while true do
        if Toggles.AutoCollectMoney then
            pcall(function()
                local base = GetPlayerBase()
                if base and isAlive() then
                    for _, part in ipairs(base:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local pName = part.Name:lower()
                            if pName:find("cash") or pName:find("money") or pName:find("collect") or pName:find("pad") or pName:find("waitforcash") then
                                TouchWithCharacter(part)
                            end
                        end
                    end

                    -- Offline cash claim
                    local offCashSys = ReplicatedStorage:FindFirstChild("OfflineCashSystem") or ReplicatedStorage
                    local claimRemote = offCashSys:FindFirstChild("ClaimOfflineCash", true) or offCashSys:FindFirstChild("ClaimCash", true)
                    if claimRemote and claimRemote:IsA("RemoteEvent") then
                        claimRemote:FireServer()
                    end

                    -- Fire general money remotes
                    for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                        if rem:IsA("RemoteEvent") and (rem.Name:lower():find("cash") or rem.Name:lower():find("money") or rem.Name:lower():find("collect")) then
                            pcall(function() rem:FireServer() end)
                        end
                    end
                end
            end)
            task.wait(0.6)
        else
            task.wait(1.5)
        end
    end
end)

-- =================================================================
-- GAME FEATURE 7: AUTO UPGRADE BASE (TANK & TREADMILL)
-- =================================================================
task.spawn(function()
    while true do
        if Toggles.AutoUpgradeBase then
            pcall(function()
                -- Tank Upgrade Remote
                local tankLevels = ReplicatedStorage:FindFirstChild("TankLevels") or ReplicatedStorage
                local upTank = tankLevels:FindFirstChild("UpgradeTank", true) or ReplicatedStorage:FindFirstChild("UpgradeTank", true)
                if upTank and upTank:IsA("RemoteEvent") then
                    upTank:FireServer()
                end

                -- TreadPool Upgrade Remote
                local poolLevels = ReplicatedStorage:FindFirstChild("TreadPoolLevels") or ReplicatedStorage
                local upPool = poolLevels:FindFirstChild("UpgradeTreadPool", true) or ReplicatedStorage:FindFirstChild("UpgradeTreadPool", true)
                if upPool and upPool:IsA("RemoteEvent") then
                    local curLvl = tonumber(LocalPlayer:GetAttribute("TreadPoolLevel")) or 0
                    if curLvl == 0 then
                        upPool:FireServer("PurchaseFirst")
                    else
                        upPool:FireServer("Upgrade")
                    end
                end

                -- Physical Base Upgrade Buttons
                local base = GetPlayerBase()
                if base and isAlive() then
                    for _, btn in ipairs(base:GetDescendants()) do
                        if btn:IsA("BasePart") and btn.Name:lower():find("upgrade") then
                            TouchWithCharacter(btn)
                        end
                    end
                end
            end)
            task.wait(0.6)
        else
            task.wait(1.5)
        end
    end
end)

-- =================================================================
-- GAME FEATURE 8: INSTANT TP TO BASE
-- =================================================================
local function TeleportToBase()
    pcall(function()
        if isAlive() then
            local placeZone = GetPlayerPlacementZone()
            local baseCF = placeZone and (placeZone.CFrame + Vector3.new(0, 3, 0)) or GetPlayerBaseCFrame()
            if baseCF then
                LocalPlayer.Character.HumanoidRootPart.CFrame = baseCF
                LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                ShowNotification("Base Teleport", "Teleported to your Base!")
            else
                ShowNotification("Base Teleport", "Base location not found!")
            end
        end
    end)
end

-- =================================================================
-- GAME FEATURE 9: FLY MODE (PC KEYBOARD & MOBILE JOYSTICK 3D)
-- =================================================================
local flyBodyVel = nil
local flyBodyGyro = nil

local function startFlying()
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return end

    if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end

    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.Name = "JunejoFlyVel"
    flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVel.Velocity = Vector3.zero
    flyBodyVel.Parent = root

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.Name = "JunejoFlyGyro"
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.P = 10000
    flyBodyGyro.CFrame = root.CFrame
    flyBodyGyro.Parent = root

    task.spawn(function()
        while Toggles.FlyMode and flyBodyVel and flyBodyGyro do
            local currentRoot = getRoot()
            local currentHum = getHum()
            if not currentRoot or not currentHum then break end

            local moveDir = currentHum.MoveDirection
            local camCF = Camera.CFrame
            flyBodyGyro.CFrame = camCF

            if moveDir.Magnitude > 0.05 then
                local camLook = camCF.LookVector
                local camRight = camCF.RightVector
                local forwardAmount = moveDir:Dot(camLook)
                local rightAmount = moveDir:Dot(camRight)

                local targetVelocity = (camLook * forwardAmount + camRight * rightAmount) * FlySpeedValue
                flyBodyVel.Velocity = targetVelocity
            else
                flyBodyVel.Velocity = Vector3.zero
            end

            -- PC Vertical Controls
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                flyBodyVel.Velocity = flyBodyVel.Velocity + Vector3.new(0, FlySpeedValue, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                flyBodyVel.Velocity = flyBodyVel.Velocity - Vector3.new(0, FlySpeedValue, 0)
            end

            task.wait()
        end

        if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    end)
end

local function stopFlying()
    if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

-- =================================================================
-- GAME FEATURE 10: NOCLIP
-- =================================================================
RunService.Stepped:Connect(function()
    if Toggles.Noclip and isAlive() then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end
end)

-- =================================================================
-- GAME FEATURE 11: RARE EGG ONLY ESP
-- =================================================================
local function ClearRareEggESP()
    for _, item in pairs(CurrentRareEggESPInstances) do
        pcall(function()
            if item.Highlight then item.Highlight:Destroy() end
            if item.Billboard then item.Billboard:Destroy() end
        end)
    end
    table.clear(CurrentRareEggESPInstances)
end

task.spawn(function()
    while true do
        if Toggles.RareEggOnlyESP then
            pcall(function()
                if isAlive() then
                    local hrp = getRoot()
                    local spawnedFolders = {
                        Workspace:FindFirstChild("SpawnedEggs"),
                        Workspace:FindFirstChild("Eggs"),
                        Workspace:FindFirstChild("WorldEggs")
                    }

                    for _, folder in ipairs(spawnedFolders) do
                        if folder then
                            for _, egg in ipairs(folder:GetChildren()) do
                                if egg:IsA("Model") then
                                    local rarity = tostring(egg:GetAttribute("Rarity") or "Basic")

                                    if rarity ~= "Basic" then
                                        local pivot = egg:GetPivot()
                                        local dist = math.floor((pivot.Position - hrp.Position).Magnitude)

                                        if not CurrentRareEggESPInstances[egg] then
                                            local hl = Instance.new("Highlight")
                                            hl.Name = "RareEgg_HL"
                                            hl.Adornee = egg
                                            hl.FillColor = RarityColors[rarity] or Color3.fromRGB(168, 85, 247)
                                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                            hl.FillTransparency = 0.5
                                            hl.OutlineTransparency = 0
                                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                            hl.Parent = egg

                                            local bb = Instance.new("BillboardGui")
                                            bb.Name = "RareEgg_BB"
                                            bb.Adornee = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart") or egg
                                            bb.Size = UDim2.new(0, 110, 0, 32)
                                            bb.StudsOffset = Vector3.new(0, 2.5, 0)
                                            bb.AlwaysOnTop = true
                                            bb.Parent = egg

                                            local lbl = Instance.new("TextLabel")
                                            lbl.Size = UDim2.new(1, 0, 1, 0)
                                            lbl.BackgroundTransparency = 1
                                            lbl.Font = Enum.Font.GothamBold
                                            lbl.TextSize = 10
                                            lbl.TextColor3 = RarityColors[rarity] or Color3.fromRGB(255, 255, 255)
                                            lbl.TextStrokeTransparency = 0.3
                                            lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                            lbl.Text = string.format("[%s]\n%s [%dm]", rarity, egg.Name, dist)
                                            lbl.Parent = bb

                                            CurrentRareEggESPInstances[egg] = { Highlight = hl, Billboard = bb, Label = lbl }
                                        else
                                            local item = CurrentRareEggESPInstances[egg]
                                            if item and item.Label then
                                                item.Label.Text = string.format("[%s]\n%s [%dm]", rarity, egg.Name, dist)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            ClearRareEggESP()
            task.wait(1)
        end
    end
end)

-- =================================================================
-- GAME FEATURE 12: PLAYER ESP
-- =================================================================
local function ClearPlayerESP()
    for _, item in pairs(CurrentPlayerESPInstances) do
        pcall(function()
            if item.Highlight then item.Highlight:Destroy() end
            if item.Billboard then item.Billboard:Destroy() end
        end)
    end
    table.clear(CurrentPlayerESPInstances)
end

task.spawn(function()
    while true do
        if Toggles.PlayerESP then
            pcall(function()
                if isAlive() then
                    local myHrp = getRoot()

                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local char = p.Character
                            local pHrp = char.HumanoidRootPart
                            local dist = math.floor((pHrp.Position - myHrp.Position).Magnitude)

                            if not CurrentPlayerESPInstances[p] then
                                local hl = Instance.new("Highlight")
                                hl.Name = "Player_HL"
                                hl.Adornee = char
                                hl.FillColor = Color3.fromRGB(239, 68, 68)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.6
                                hl.OutlineTransparency = 0.1
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = char

                                local bb = Instance.new("BillboardGui")
                                bb.Name = "Player_BB"
                                bb.Adornee = pHrp
                                bb.Size = UDim2.new(0, 100, 0, 30)
                                bb.StudsOffset = Vector3.new(0, 3, 0)
                                bb.AlwaysOnTop = true
                                bb.Parent = char

                                local lbl = Instance.new("TextLabel")
                                lbl.Size = UDim2.new(1, 0, 1, 0)
                                lbl.BackgroundTransparency = 1
                                lbl.Font = Enum.Font.GothamBold
                                lbl.TextSize = 10
                                lbl.TextColor3 = Color3.fromRGB(255, 100, 100)
                                lbl.TextStrokeTransparency = 0.3
                                lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                lbl.Text = string.format("%s\n[%dm]", p.DisplayName or p.Name, dist)
                                lbl.Parent = bb

                                CurrentPlayerESPInstances[p] = { Highlight = hl, Billboard = bb, Label = lbl }
                            else
                                local item = CurrentPlayerESPInstances[p]
                                if item and item.Label then
                                    item.Label.Text = string.format("%s\n[%dm]", p.DisplayName or p.Name, dist)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            ClearPlayerESP()
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
MainWindow.Size = UDim2.new(0, 285, 0, 330)
MainWindow.Position = UDim2.new(0.5, -142, 0.5, -165)
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
    stopFlying()
    pcall(function()
        local tpRemote = ReplicatedStorage:FindFirstChild("TreadPools") and ReplicatedStorage.TreadPools:FindFirstChild("TreadPoolRemote")
        if tpRemote then tpRemote:FireServer("Stop") end
    end)
    ClearRareEggESP()
    ClearPlayerESP()
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

-- 1. Helper: Add Borderless Toggle Row
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
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
end

-- 2. Helper: Add 1-Click Action Row
local function AddActionRow(text, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
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
    
    local ActionBox = Instance.new("Frame")
    ActionBox.Size = UDim2.new(0, 18, 0, 18)
    ActionBox.Position = UDim2.new(1, -18, 0.5, -9)
    ActionBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ActionBox.BorderSizePixel = 0
    ActionBox.Parent = Row
    
    local ActionCorner = Instance.new("UICorner")
    ActionCorner.CornerRadius = UDim.new(0, 4)
    ActionCorner.Parent = ActionBox
    
    local ActionStroke = Instance.new("UIStroke")
    ActionStroke.Color = Color3.fromRGB(45, 45, 55)
    ActionStroke.Thickness = 1.2
    ActionStroke.Parent = ActionBox
    
    local ActionIcon = Instance.new("TextLabel")
    ActionIcon.Size = UDim2.new(1, 0, 1, 0)
    ActionIcon.BackgroundTransparency = 1
    ActionIcon.Text = "⚡"
    ActionIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionIcon.TextSize = 9
    ActionIcon.Font = Enum.Font.GothamBold
    ActionIcon.Parent = ActionBox
    
    RowBtn.MouseButton1Click:Connect(function()
        ActionBox.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
        task.delay(0.15, function() ActionBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32) end)
        if callback then callback() end
    end)
end

-- 3. Helper: Add Interactive Line Bar Slider Row
local function AddSliderRow(title, configKey, minVal, maxVal, defaultVal, onChangeCallback, onToggleCallback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 38)
    Container.BackgroundTransparency = 1
    Container.Parent = FeaturesContainer
    
    local TopRow = Instance.new("Frame")
    TopRow.Size = UDim2.new(1, 0, 0, 20)
    TopRow.BackgroundTransparency = 1
    TopRow.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TopRow
    
    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0.2, 0, 1, 0)
    ValLabel.Position = UDim2.new(0.6, 0, 0, 0)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = tostring(defaultVal)
    ValLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
    ValLabel.TextSize = 11
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.Parent = TopRow
    
    local CheckBox = Instance.new("Frame")
    CheckBox.Size = UDim2.new(0, 18, 0, 18)
    CheckBox.Position = UDim2.new(1, -18, 0.5, -9)
    CheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    CheckBox.BorderSizePixel = 0
    CheckBox.Parent = TopRow
    
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
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = ""
    ToggleBtn.ZIndex = 5
    ToggleBtn.Parent = TopRow
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Toggles[configKey] = not Toggles[configKey]
        CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
        if onToggleCallback then onToggleCallback(Toggles[configKey]) end
    end)
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, 0, 0, 6)
    SliderTrack.Position = UDim2.new(0, 0, 0, 24)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = Container
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = SliderTrack
    
    local TrackStroke = Instance.new("UIStroke")
    TrackStroke.Color = Color3.fromRGB(40, 40, 50)
    TrackStroke.Thickness = 1
    TrackStroke.Parent = SliderTrack
    
    local initialPercent = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill
    
    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(1, 0, 1, 8)
    SliderBtn.Position = UDim2.new(0, 0, 0, -4)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text = ""
    SliderBtn.ZIndex = 6
    SliderBtn.Parent = SliderTrack
    
    local isSliding = false
    local function UpdateSlider(input)
        local posX = input.Position.X - SliderTrack.AbsolutePosition.X
        local percent = math.clamp(posX / SliderTrack.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * percent)
        FlySpeedValue = val
        ValLabel.Text = tostring(val)
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        if onChangeCallback then onChangeCallback(val) end
    end
    
    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            UpdateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
end

-- =================================================================
-- ZONE SELECTOR ROW (JUNEJO EXECUTIVE PILL SELECTOR)
-- =================================================================
local ZoneRow = Instance.new("Frame")
ZoneRow.Size = UDim2.new(1, 0, 0, 23)
ZoneRow.BackgroundTransparency = 1
ZoneRow.Parent = FeaturesContainer

local ZoneLabel = Instance.new("TextLabel")
ZoneLabel.Size = UDim2.new(0.42, 0, 1, 0)
ZoneLabel.BackgroundTransparency = 1
ZoneLabel.Text = "Target Zone"
ZoneLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
ZoneLabel.TextSize = 12
ZoneLabel.Font = Enum.Font.GothamBold
ZoneLabel.TextXAlignment = Enum.TextXAlignment.Left
ZoneLabel.Parent = ZoneRow

local ZoneSelectorFrame = Instance.new("Frame")
ZoneSelectorFrame.Size = UDim2.new(0.55, 0, 1, 0)
ZoneSelectorFrame.Position = UDim2.new(0.45, 0, 0, 0)
ZoneSelectorFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
ZoneSelectorFrame.BorderSizePixel = 0
ZoneSelectorFrame.Parent = ZoneRow

local ZoneCorner = Instance.new("UICorner")
ZoneCorner.CornerRadius = UDim.new(0, 4)
ZoneCorner.Parent = ZoneSelectorFrame

local ZoneStroke = Instance.new("UIStroke")
ZoneStroke.Color = Color3.fromRGB(45, 45, 55)
ZoneStroke.Thickness = 1
ZoneStroke.Parent = ZoneSelectorFrame

local PrevZoneBtn = Instance.new("TextButton")
PrevZoneBtn.Size = UDim2.new(0, 20, 1, 0)
PrevZoneBtn.Position = UDim2.new(0, 0, 0, 0)
PrevZoneBtn.BackgroundTransparency = 1
PrevZoneBtn.Text = "<"
PrevZoneBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
PrevZoneBtn.TextSize = 12
PrevZoneBtn.Font = Enum.Font.GothamBold
PrevZoneBtn.Parent = ZoneSelectorFrame

local ZoneDisplay = Instance.new("TextLabel")
ZoneDisplay.Size = UDim2.new(1, -40, 1, 0)
ZoneDisplay.Position = UDim2.new(0, 20, 0, 0)
ZoneDisplay.BackgroundTransparency = 1
ZoneDisplay.Text = AvailableZones[CurrentZoneIndex]
ZoneDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
ZoneDisplay.TextSize = 10
ZoneDisplay.Font = Enum.Font.GothamBold
ZoneDisplay.TextTruncate = Enum.TextTruncate.AtEnd
ZoneDisplay.Parent = ZoneSelectorFrame

local NextZoneBtn = Instance.new("TextButton")
NextZoneBtn.Size = UDim2.new(0, 20, 1, 0)
NextZoneBtn.Position = UDim2.new(1, -20, 0, 0)
NextZoneBtn.BackgroundTransparency = 1
NextZoneBtn.Text = ">"
NextZoneBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
NextZoneBtn.TextSize = 12
NextZoneBtn.Font = Enum.Font.GothamBold
NextZoneBtn.Parent = ZoneSelectorFrame

local function updateZone(newIdx)
    CurrentZoneIndex = newIdx
    ZoneDisplay.Text = AvailableZones[CurrentZoneIndex]
    table.clear(CooldownEggs)
    ShowNotification("Target Zone", AvailableZones[CurrentZoneIndex])
end

PrevZoneBtn.MouseButton1Click:Connect(function()
    local newIdx = CurrentZoneIndex - 1
    if newIdx < 1 then newIdx = #AvailableZones end
    updateZone(newIdx)
end)

NextZoneBtn.MouseButton1Click:Connect(function()
    local newIdx = CurrentZoneIndex + 1
    if newIdx > #AvailableZones then newIdx = 1 end
    updateZone(newIdx)
end)

-- =================================================================
-- POPULATE FEATURES
-- =================================================================

-- 1. Auto Steal Eggs
AddToggleRow("Auto Steal Eggs", "AutoSteal", function(enabled)
    if enabled then
        table.clear(CooldownEggs)
        ShowNotification("Auto Steal", "Stealing best eggs from " .. AvailableZones[CurrentZoneIndex])
    end
end)

-- 2. Remove Guards (Fishes)
AddToggleRow("Remove Guards (Fishes)", "RemoveGuards", function(enabled)
    if enabled then
        SweepAndRemoveAllGuards()
        ShowNotification("Remove Guards", "All Guard Fishes & Chasers Neutralized!")
    end
end)

-- 3. Auto Hatch
AddToggleRow("Auto Hatch", "AutoHatch", function(enabled)
    if enabled then
        ShowNotification("Auto Hatch", "Auto Hatching Ready Eggs!")
    end
end)

-- 4. Auto Place
AddToggleRow("Auto Place", "AutoPlace", function(enabled)
    if enabled then
        ShowNotification("Auto Place", "Auto Placing Carried Eggs in Tank!")
    end
end)

-- 5. Auto Train Swim Speed
AddToggleRow("Auto Train Swim Speed", "AutoTrainSwimSpeed", function(enabled)
    if enabled then
        ShowNotification("TreadPool", "Swim Training Activated!")
    else
        pcall(function()
            local tpRemote = ReplicatedStorage:FindFirstChild("TreadPools") and ReplicatedStorage.TreadPools:FindFirstChild("TreadPoolRemote")
            if tpRemote then tpRemote:FireServer("Stop") end
        end)
    end
end)

-- 6. Auto Collect Money
AddToggleRow("Auto Collect Money", "AutoCollectMoney")

-- 7. Auto Upgrade Base
AddToggleRow("Auto Upgrade Base", "AutoUpgradeBase", function(enabled)
    if enabled then
        ShowNotification("Base Upgrades", "Auto Upgrading Tank & TreadPool!")
    end
end)

-- 8. Instant TP to Base
AddActionRow("⚡ Instant TP to Base", TeleportToBase)

-- 9. Fly Mode with Interactive Line Bar Slider
AddSliderRow("Fly Mode", "FlyMode", 20, 200, FlySpeedValue, function(val)
    FlySpeedValue = val
end, function(enabled)
    if enabled then
        startFlying()
    else
        stopFlying()
    end
end)

-- 10. Noclip
AddToggleRow("Noclip", "Noclip")

-- 11. Rare Egg Only ESP
AddToggleRow("Rare Egg Only ESP", "RareEggOnlyESP")

-- 12. Player ESP
AddToggleRow("Player ESP", "PlayerESP")

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

ShowNotification("Junejo Script Hub", "Steal Fish Eggs Loaded Successfully!")
print("Junejo Ultra Script Hub loaded successfully for Steal Fish Eggs!")
