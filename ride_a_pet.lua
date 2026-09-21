-- =================================================================
-- JUNEJO ULTRA SCRIPT HUB - RIDE A PET (OFFICIAL SCRIPT)
-- Target Game: Ride A Pet (Roblox ID: 124216119978534)
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- UI Standard: UI 1 (Official Ultra Script Hub Classic Matte Dark)
-- Universal Mobile (Delta / Codex / Fluxus) & PC Compatible
-- =================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")

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
    for _, name in ipairs({"FarhanScriptsHub", "RobloxScriptUI_RideAPet", "RideAPetMobileUI", "JunejoUltraScriptHub_RideAPet", "JunejoRideAPetUI"}) do
        if guiParent and guiParent:FindFirstChild(name) then pcall(function() guiParent[name]:Destroy() end) end
        pcall(function()
            if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        end)
        pcall(function()
            local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if pg and pg:FindFirstChild(name) then pg[name]:Destroy() end
        end)
    end
end)

-- Global Engine State Store
_G.JunejoRideAPetState = {
    -- Pet Farm
    AutoSteal            = false,
    SelectedStealZone    = "Best Egg (Auto Rarest)",
    AutoHatch            = false,
    AutoPlace            = false,
    AutoEquipBest        = false,
    SelectedTeleportZone = "Food Stall (Tim)",

    -- Movement
    WalkSpeedActive      = false,
    WalkSpeedValue       = 45,
    JumpPowerActive      = false,
    JumpPowerValue       = 50,
    InfJumpActive        = false,
    NoClipActive         = false,
    FlyActive            = false,
    FlySpeed             = 50,

    -- Visuals
    RareEggESP           = false,
    PlayerESP            = false,
    PlayerTags           = false,
    FullBrightActive     = false,
    FOV                  = 70,

    -- Utilities
    InstantPrompts       = false,
    AntiAFKActive        = true
}
local State = _G.JunejoRideAPetState

-- Internal Game References & Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local GameRemotes = Remotes and Remotes:WaitForChild("Game", 5)

local Remote_EggPickup      = GameRemotes and GameRemotes:FindFirstChild("EggPickup")
local Remote_EggPlaced      = GameRemotes and GameRemotes:FindFirstChild("EggPlaced")
local Remote_Hatch          = GameRemotes and GameRemotes:FindFirstChild("Hatch")
local Remote_TeleportToPlot = GameRemotes and GameRemotes:FindFirstChild("TeleportToPlot")
local Remote_Mounting       = GameRemotes and GameRemotes:FindFirstChild("Mounting")
local Remote_PetDismount    = GameRemotes and GameRemotes:FindFirstChild("PetDismount")
local Remote_FeedPet        = GameRemotes and GameRemotes:FindFirstChild("FeedPet")
local Remote_PetCollect     = GameRemotes and GameRemotes:FindFirstChild("PetCollect")

-- Dynamic Remote Resolver
local function GetRemote(...)
    local candidates = {...}
    for _, name in ipairs(candidates) do
        local r = nil
        pcall(function()
            if GameRemotes then r = GameRemotes:FindFirstChild(name) end
            if not r and Remotes then r = Remotes:FindFirstChild(name, true) end
            if not r then r = ReplicatedStorage:FindFirstChild(name, true) end
        end)
        if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
            return r
        end
    end
    return nil
end

-- Safe Remote Invoker
local function SafeFireRemote(rem, ...)
    if not rem then return end
    local args = {...}
    pcall(function()
        if rem:IsA("RemoteEvent") then
            rem:FireServer(unpack(args))
        elseif rem:IsA("RemoteFunction") then
            task.spawn(function()
                pcall(function()
                    rem:InvokeServer(unpack(args))
                end)
            end)
        end
    end)
end

-- Find all remotes across ReplicatedStorage matching keywords
local function FindAllRemotes(...)
    local patterns = {...}
    local found = {}
    pcall(function()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local oName = obj.Name:lower()
                for _, pat in ipairs(patterns) do
                    if oName:find(pat:lower(), 1, true) then
                        table.insert(found, obj)
                        break
                    end
                end
            end
        end
    end)
    return found
end

-- Egg Rarity Ranking
local EggRarityRank = {
    ["blackhole egg"] = 100,
    ["ethereal egg"]  = 90,
    ["diamond egg"]   = 80,
    ["divine egg"]    = 75,
    ["golden egg"]    = 70,
    ["mythic egg"]    = 68,
    ["flaming egg"]   = 65,
    ["legendary egg"] = 62,
    ["skull egg"]     = 60,
    ["slime egg"]     = 55,
    ["crystal egg"]   = 50,
    ["glass egg"]     = 45,
    ["flower egg"]    = 40,
    ["slimy egg"]     = 38,
    ["easter egg"]    = 35,
    ["mushroom egg"]  = 30,
    ["stone egg"]     = 25,
    ["leaf egg"]      = 20,
    ["cracked egg"]   = 15,
    ["brown egg"]     = 10,
    ["white egg"]     = 5
}

-- Zone Options for Stealing Eggs
local StealZoneOptions = {
    "Best Egg (Auto Rarest)",
    "Ethereal Zone",
    "Divine / Diamond",
    "Mythic / Golden",
    "Legendary / Flaming",
    "Epic / Skull / Slime",
    "Rare / Crystal / Flower",
    "Any Egg Spawned"
}

-- Teleport Locations
local TeleportLocations = {
    ["Food Stall (Tim)"]      = "stall_food",
    ["Gears Stall (Rick)"]    = "stall_gears",
    ["Sell Stall (Richie)"]   = "stall_sell",
    ["Egg Tracker (Eggo)"]    = "stall_eggtracker",
    ["Ethereal Spawns"]       = "spawn_ethereal",
    ["Divine Spawns"]         = "spawn_divine",
    ["Mythic Spawns"]         = "spawn_mythic",
    ["Legendary Spawns"]      = "spawn_legendary",
    ["Epic Spawns"]           = "spawn_epic",
    ["Rare Spawns"]           = "spawn_rare",
    ["Common Meadow"]         = "spawn_common",
    ["Desert Maze"]           = Vector3.new(-380, 15, 210),
    ["Giant Tree"]            = Vector3.new(290, 45, -260),
    ["Waterfall Cave"]        = Vector3.new(-180, 20, -320),
    ["My Base / Plot"]        = "my_base"
}

local TeleportZoneNames = {
    "Food Stall (Tim)",
    "Gears Stall (Rick)",
    "Sell Stall (Richie)",
    "Egg Tracker (Eggo)",
    "Ethereal Spawns",
    "Divine Spawns",
    "Mythic Spawns",
    "Legendary Spawns",
    "Epic Spawns",
    "Rare Spawns",
    "Common Meadow",
    "Desert Maze",
    "Giant Tree",
    "Waterfall Cave",
    "My Base / Plot"
}

-- Character & Base Helpers
local function getChar()
    return LocalPlayer.Character
end

local function getRoot(char)
    char = char or getChar()
    return char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
end

local function getHum(char)
    char = char or getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function isAlive(char)
    char = char or getChar()
    local hum = getHum(char)
    return hum and hum.Health > 0
end

local cachedMyPlot = nil
local SavedBaseCFrame = nil

local function GetMyPlot()
    if cachedMyPlot and cachedMyPlot.Parent then return cachedMyPlot end

    pcall(function()
        local myName = LocalPlayer.Name:lower()
        local myUserId = tostring(LocalPlayer.UserId)
        local myDisplay = LocalPlayer.DisplayName:lower()
        local plotsFolder = Workspace:FindFirstChild("Plots") 
                         or Workspace:FindFirstChild("Bases") 
                         or Workspace:FindFirstChild("Farms")
                         or Workspace:FindFirstChild("Tycoons")
                         or Workspace:FindFirstChild("PlayerPlots")
                         or Workspace:FindFirstChild("PlayerBases")
                         or Workspace:FindFirstChild("Islands")

        if plotsFolder then
            for _, plot in ipairs(plotsFolder:GetChildren()) do
                local data = plot:FindFirstChild("Data")
                if data then
                    local ownerVal = data:FindFirstChild("Owner") or data:FindFirstChild("Player") or data:FindFirstChild("UserId")
                    if ownerVal then
                        local ov = ownerVal.Value
                        if ov == LocalPlayer or (typeof(ov) == "Instance" and ov.Name:lower() == myName) or tostring(ov):lower() == myName or tostring(ov) == myUserId then
                            cachedMyPlot = plot
                            return
                        end
                    end
                end

                for _, attr in ipairs({"Owner", "Player", "UserId", "OwnerId"}) do
                    local val = plot:GetAttribute(attr)
                    if val and (tostring(val):lower() == myName or tostring(val) == myUserId) then
                        cachedMyPlot = plot
                        return
                    end
                end

                local directOwner = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player")
                if directOwner and directOwner:IsA("ValueObject") then
                    local ov = directOwner.Value
                    if ov == LocalPlayer or (typeof(ov) == "Instance" and ov.Name:lower() == myName) or tostring(ov):lower() == myName or tostring(ov) == myUserId then
                        cachedMyPlot = plot
                        return
                    end
                end

                local pn = plot.Name:lower()
                if pn == myName or pn:find(myName, 1, true) or pn:find(myDisplay, 1, true) then
                    cachedMyPlot = plot
                    return
                end
            end

            for _, plot in ipairs(plotsFolder:GetChildren()) do
                for _, lbl in ipairs(plot:GetDescendants()) do
                    if lbl:IsA("TextLabel") and lbl.Visible and (lbl.Text:lower():find(myName, 1, true) or lbl.Text:lower():find(myDisplay, 1, true)) then
                        cachedMyPlot = plot
                        return
                    end
                end
            end
        end
    end)

    return cachedMyPlot
end

local function GetPlayerBaseCFrame()
    local myPlot = GetMyPlot()
    if myPlot then
        local bp = myPlot:FindFirstChild("Baseplate") or myPlot:FindFirstChild("Spawn") or myPlot.PrimaryPart or myPlot:FindFirstChildWhichIsA("BasePart", true)
        if bp then
            SavedBaseCFrame = bp.CFrame + Vector3.new(0, 3.5, 0)
            return SavedBaseCFrame
        else
            SavedBaseCFrame = myPlot:GetPivot() + Vector3.new(0, 3.5, 0)
            return SavedBaseCFrame
        end
    end
    if SavedBaseCFrame then
        return SavedBaseCFrame
    end
    local char = getChar()
    local hrp = getRoot(char)
    if hrp then
        SavedBaseCFrame = hrp.CFrame
        return SavedBaseCFrame
    end
    return CFrame.new(0, 5, 0)
end

local function GetPlayerNests()
    local nests = {}
    local seen = {}
    local myPlot = GetMyPlot()

    if myPlot then
        local nestsFolder = myPlot:FindFirstChild("Nests") or myPlot:FindFirstChild("NestFolder") or myPlot:FindFirstChild("Incubators")
        if nestsFolder then
            for _, n in ipairs(nestsFolder:GetChildren()) do
                if not seen[n] then seen[n] = true table.insert(nests, n) end
            end
        end
        for _, child in ipairs(myPlot:GetChildren()) do
            if not seen[child] and (child.Name:lower():find("nest") or child.Name:lower():find("incubator")) then
                seen[child] = true
                table.insert(nests, child)
            end
        end
    end

    if #nests == 0 then
        local char = getChar()
        local hrp = getRoot(char)
        local basePos = (hrp and hrp.Position) or (SavedBaseCFrame and SavedBaseCFrame.Position)
        if basePos then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and not seen[obj] and (obj.Name:lower():find("nest") or obj.Name:lower():find("incubator")) then
                    local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                    if p and (p.Position - basePos).Magnitude < 70 then
                        seen[obj] = true
                        table.insert(nests, obj)
                    end
                end
            end
        end
    end

    return nests
end

local function IsEggInsideMyBase(egg)
    if not egg or not egg.Parent then return true end
    local myPlot = GetMyPlot()
    if myPlot and egg:IsDescendantOf(myPlot) then
        return true
    end
    local basePos = (SavedBaseCFrame and SavedBaseCFrame.Position)
    if basePos then
        local eggPart = (egg:IsA("BasePart") and egg) or egg:FindFirstChildWhichIsA("BasePart", true)
        if eggPart and (eggPart.Position - basePos).Magnitude < 30 then
            return true
        end
    end
    return false
end

local function IsEggInsideAnyBase(egg)
    return IsEggInsideMyBase(egg)
end

-- Safe Mount-Aware & Streaming-Proof Teleportation
local function SafeTeleport(targetCFrame)
    pcall(function()
        local char = getChar()
        if not char then return end
        local hum = getHum(char)
        local hrp = getRoot(char)
        if not hrp then return end

        local targetPos = (typeof(targetCFrame) == "CFrame" and targetCFrame.Position) or (typeof(targetCFrame) == "Vector3" and targetCFrame) or hrp.Position
        local targetCF = (typeof(targetCFrame) == "CFrame" and targetCFrame) or CFrame.new(targetPos)

        pcall(function()
            if Workspace.StreamingEnabled and LocalPlayer.RequestStreamAroundAsync then
                LocalPlayer:RequestStreamAroundAsync(targetPos, 1.5)
            end
        end)

        if hum and hum.SeatPart then
            local seat = hum.SeatPart
            local mount = seat.Parent
            if seat:IsA("BasePart") then
                seat.AssemblyLinearVelocity = Vector3.zero
                seat.AssemblyAngularVelocity = Vector3.zero
                seat.CFrame = targetCF
            end
            if mount and mount:IsA("Model") then
                pcall(function() mount:PivotTo(targetCF) end)
                local mountRoot = mount.PrimaryPart or mount:FindFirstChild("RootPart") or mount:FindFirstChild("HumanoidRootPart") or seat
                if mountRoot and mountRoot:IsA("BasePart") then
                    mountRoot.AssemblyLinearVelocity = Vector3.zero
                    mountRoot.AssemblyAngularVelocity = Vector3.zero
                    mountRoot.CFrame = targetCF
                end
            end
        end

        hrp.Anchored = true
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        char:PivotTo(targetCF)
        hrp.CFrame = targetCF
        task.wait(0.04)
        hrp.Anchored = false

        if LocalPlayer.GameplayPaused then
            local pauseStart = tick()
            while LocalPlayer.GameplayPaused and (tick() - pauseStart < 2.5) do
                task.wait(0.05)
            end
        end
    end)
end

-- Teleport directly to named game location / stall / spawn
local function TeleportToLocation(destName)
    local char = getChar()
    if not char then return end

    if destName == "My Base / Plot" then
        local myPlot = GetMyPlot()
        if myPlot then
            local bp = myPlot:FindFirstChild("Baseplate") or myPlot.PrimaryPart or myPlot:FindFirstChildWhichIsA("BasePart", true)
            if bp then
                SafeTeleport(bp.CFrame + Vector3.new(0, 5, 0))
            else
                SafeTeleport(myPlot:GetPivot() + Vector3.new(0, 5, 0))
            end
        elseif Remote_TeleportToPlot then
            Remote_TeleportToPlot:FireServer()
        end
        return
    end

    local stalls = Workspace:FindFirstChild("Stalls")
    if stalls then
        local stall = nil
        if destName:find("Food") then stall = stalls:FindFirstChild("Food")
        elseif destName:find("Gears") then stall = stalls:FindFirstChild("Gears")
        elseif destName:find("Sell") then stall = stalls:FindFirstChild("Sell")
        elseif destName:find("Tracker") then stall = stalls:FindFirstChild("EggTracker")
        end

        if stall then
            local part = stall:FindFirstChild("HumanoidRootPart", true) 
                      or stall:FindFirstChild("RoofCenter", true) 
                      or stall:FindFirstChildWhichIsA("BasePart", true)
            if part then
                SafeTeleport(part.CFrame + Vector3.new(0, 3, 6))
                return
            end
        end
    end

    local eggSpawns = Workspace:FindFirstChild("EggSpawns")
    if eggSpawns then
        local keyword = nil
        if destName:find("Ethereal") then keyword = "ethereal"
        elseif destName:find("Divine") then keyword = "divine"
        elseif destName:find("Mythic") then keyword = "mythic"
        elseif destName:find("Legendary") then keyword = "legendary"
        elseif destName:find("Epic") then keyword = "epic"
        elseif destName:find("Rare") then keyword = "rare"
        elseif destName:find("Common") then keyword = "common"
        end

        if keyword then
            for _, spawnPart in ipairs(eggSpawns:GetChildren()) do
                if spawnPart:IsA("BasePart") and spawnPart.Name:lower():find(keyword) then
                    SafeTeleport(spawnPart.CFrame + Vector3.new(0, 4, 0))
                    return
                end
            end
        end
    end

    local landmarkCoords = {
        ["Desert Maze"]    = Vector3.new(-380, 15, 210),
        ["Giant Tree"]     = Vector3.new(290, 45, -260),
        ["Waterfall Cave"] = Vector3.new(-180, 20, -320)
    }
    if landmarkCoords[destName] then
        SafeTeleport(CFrame.new(landmarkCoords[destName]))
        return
    end

    local fallbackPos = TeleportLocations[destName]
    if typeof(fallbackPos) == "Vector3" then
        SafeTeleport(CFrame.new(fallbackPos))
    end
end

-- =================================================================
-- CORE AUTOMATION LOGIC
-- =================================================================
local function isCollectibleEgg(obj)
    if not obj or not obj.Parent then return false end
    if IsEggInsideMyBase(obj) then return false end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and obj:IsDescendantOf(p.Character) then return false end
    end

    local oName = obj.Name:lower()
    local pName = obj.Parent.Name:lower()

    if oName:find("gate") or oName:find("door") or oName:find("wall") or oName:find("floor") or oName:find("stall") or oName:find("shop") or oName:find("tracker") then
        return false
    end

    local eggSpawnsFolder = Workspace:FindFirstChild("EggSpawns")
    if (eggSpawnsFolder and obj:IsDescendantOf(eggSpawnsFolder)) or pName == "eggspawns" or pName:find("eggspawn") then
        return true
    end

    for _, desc in ipairs(obj:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local at = (desc.ActionText or ""):lower()
            local ot = (desc.ObjectText or ""):lower()
            local pn = desc.Name:lower()
            if at:find("steal") or at:find("egg") or at:find("grab") or at:find("take") or at:find("collect") or at:find("pick")
            or ot:find("egg") or ot:find("steal") or pn:find("steal") or pn:find("egg") then
                return true
            end
        end
    end

    local part = (obj:IsA("BasePart") and obj) or obj:FindFirstChildWhichIsA("BasePart", true)
    if part and (part.Size.X > 25 or part.Size.Z > 25) then
        return false
    end

    if oName:find("egg") then
        return true
    end

    for k, _ in pairs(EggRarityRank) do
        local baseK = k:gsub(" egg", "")
        if oName:find(baseK, 1, true) then
            return true
        end
    end

    if obj.Parent.Name:lower():find("nest") and (obj:IsA("Model") or (part and part.Size.Y < 8)) then
        return true
    end

    return false
end

local function GetAllEggs()
    local candidates = {}
    local seen = {}

    local function checkAdd(obj)
        if not obj or not obj.Parent or seen[obj] then return end
        if not isCollectibleEgg(obj) then return end

        seen[obj] = true
        table.insert(candidates, obj)
    end

    local eggSpawns = Workspace:FindFirstChild("EggSpawns")
    if eggSpawns then
        for _, child in ipairs(eggSpawns:GetChildren()) do
            local innerEgg = child:FindFirstChild("Egg") 
                          or child:FindFirstChild("EggBase")
                          or child:FindFirstChildWhichIsA("Model")
            if innerEgg then
                checkAdd(innerEgg)
            else
                checkAdd(child)
            end
            for _, sub in ipairs(child:GetChildren()) do
                if sub:IsA("Model") or sub:IsA("BasePart") then
                    checkAdd(sub)
                end
            end
        end
    end

    pcall(function()
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent:IsA("BasePart") then
                local at = (desc.ActionText or ""):lower()
                local ot = (desc.ObjectText or ""):lower()
                local pn = desc.Name:lower()
                if at:find("steal") or at:find("egg") or at:find("grab") or at:find("take")
                or ot:find("egg") or ot:find("steal") or pn:find("steal") or pn:find("egg") then
                    local target = (desc.Parent.Parent and desc.Parent.Parent:IsA("Model") and desc.Parent.Parent ~= Workspace and desc.Parent.Parent)
                                or (desc.Parent:IsA("Model") and desc.Parent)
                                or desc.Parent
                    checkAdd(target)
                end
            end
        end
    end)

    for _, fName in ipairs({"RenderedEggs", "Eggs", "SpawnedEggs", "WorldEggs", "WildEggs", "Items", "Drops", "Map"}) do
        local f = Workspace:FindFirstChild(fName)
        if f then
            for _, child in ipairs(f:GetChildren()) do
                checkAdd(child)
                for _, sub in ipairs(child:GetChildren()) do
                    checkAdd(sub)
                end
            end
        end
    end

    local myPlot = GetMyPlot()
    local plots = Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("Bases") or Workspace:FindFirstChild("Farms")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            if not myPlot or plot ~= myPlot then
                local nests = plot:FindFirstChild("Nests") or plot:FindFirstChild("Incubators")
                if nests then
                    for _, nest in ipairs(nests:GetChildren()) do
                        for _, child in ipairs(nest:GetChildren()) do
                            checkAdd(child)
                        end
                    end
                end
            end
        end
    end

    if #candidates == 0 then
        for _, child in ipairs(Workspace:GetChildren()) do
            checkAdd(child)
        end
    end

    if #candidates == 0 then
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("Model") and isCollectibleEgg(desc) then
                checkAdd(desc)
                if #candidates >= 30 then break end
            end
        end
    end

    return candidates
end

local function GetBestStealEgg()
    local eggs = GetAllEggs()
    if #eggs == 0 then return nil end

    local bestEgg = nil
    local bestScore = -1
    local overallBestEgg = nil
    local overallBestScore = -1
    local zone = State.SelectedStealZone or "Best Egg"

    for _, egg in ipairs(eggs) do
        local eggName = egg.Name:lower()
        local score = 1

        for k, v in pairs(EggRarityRank) do
            local baseK = k:gsub(" egg", "")
            if eggName:find(baseK, 1, true) then
                score = math.max(score, v)
            end
        end

        local attrRarity = egg:GetAttribute("Rarity") or egg:GetAttribute("Tier")
        if attrRarity then
            local astr = tostring(attrRarity):lower()
            for k, v in pairs(EggRarityRank) do
                local baseK = k:gsub(" egg", "")
                if astr:find(baseK, 1, true) then
                    score = math.max(score, v + 50)
                end
            end
        end

        if score > overallBestScore then
            overallBestScore = score
            overallBestEgg = egg
        end

        local matchesFilter = false
        if zone:find("Best Egg") or zone:find("Any Egg") then
            matchesFilter = true
        elseif zone:find("Ethereal") and (eggName:find("ethereal") or eggName:find("blackhole")) then
            matchesFilter = true
        elseif (zone:find("Divine") or zone:find("Diamond")) and (eggName:find("divine") or eggName:find("diamond")) then
            matchesFilter = true
        elseif (zone:find("Mythic") or zone:find("Golden")) and (eggName:find("mythic") or eggName:find("golden")) then
            matchesFilter = true
        elseif (zone:find("Legendary") or zone:find("Flaming")) and (eggName:find("legend") or eggName:find("flaming")) then
            matchesFilter = true
        elseif (zone:find("Epic") or zone:find("Skull") or zone:find("Slime")) and (eggName:find("epic") or eggName:find("skull") or eggName:find("slime")) then
            matchesFilter = true
        elseif (zone:find("Rare") or zone:find("Crystal") or zone:find("Flower")) and (eggName:find("rare") or eggName:find("crystal") or eggName:find("flower")) then
            matchesFilter = true
        end

        if matchesFilter and score > bestScore then
            bestScore = score
            bestEgg = egg
        end
    end

    if bestEgg then
        return bestEgg
    end

    if overallBestEgg then
        return overallBestEgg
    end

    return eggs[1]
end

local function isEggHeld(targetEgg, initialBasketCount, initialCharCount, initialCharItems)
    if not targetEgg or not targetEgg.Parent or not targetEgg:IsDescendantOf(Workspace) then
        return true
    end

    local char = getChar()
    if not char then return false end

    if targetEgg:IsDescendantOf(char) then
        return true
    end

    for _, item in ipairs(char:GetChildren()) do
        if not initialCharItems or not initialCharItems[item] then
            local iname = item.Name:lower()
            if iname:find("egg") or iname:find("held") or iname:find("stolen") or iname:find("carry") then
                return true
            end
        end
    end

    for _, item in ipairs(char:GetChildren()) do
        local iname = item.Name:lower()
        if iname:find("basket") or iname:find("backpack") then
            if initialBasketCount and #item:GetChildren() > initialBasketCount then
                return true
            end
            for _, child in ipairs(item:GetChildren()) do
                local cname = child.Name:lower()
                if cname:find("egg") or cname:find("held") or cname:find("stolen") then
                    return true
                end
            end
        end
    end

    for attr, val in pairs(char:GetAttributes()) do
        local an = tostring(attr):lower()
        if (an:find("egg") or an:find("carry") or an:find("hold") or an:find("stolen")) and val ~= false and val ~= 0 and val ~= "" and val ~= nil then
            return true
        end
    end

    local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
    if pgui then
        for _, g in ipairs(pgui:GetDescendants()) do
            if (g:IsA("TextButton") or g:IsA("TextLabel")) and g.Visible then
                local txt = g.Text:lower()
                if txt:find("drop egg") or txt:find("run to base") or txt:find("carrying egg") or txt:find("stolen egg") then
                    return true
                end
            end
        end
    end

    return false
end

-- Forward declaration for auto steal toggle controller
local autoStealController = nil

local isStealing = false
local function ExecuteStealEgg()
    if isStealing then return end
    isStealing = true

    pcall(function()
        local char = getChar()
        local hrp = getRoot(char)
        local hum = getHum(char)
        if not hrp or not hum or not isAlive(char) then
            isStealing = false
            return
        end

        if not SavedBaseCFrame then
            SavedBaseCFrame = hrp.CFrame
        end

        local targetEgg = GetBestStealEgg()
        if not targetEgg or not targetEgg.Parent or IsEggInsideMyBase(targetEgg) then
            State.AutoSteal = false
            if autoStealController then autoStealController.SetState(false) end
            isStealing = false
            return
        end

        local eggPart = targetEgg:FindFirstChild("Handle") 
                     or targetEgg:FindFirstChild("Egg") 
                     or targetEgg:FindFirstChild("EggBase") 
                     or targetEgg:FindFirstChild("Sphere.007") 
                     or (targetEgg:IsA("Model") and targetEgg.PrimaryPart) 
                     or targetEgg:FindFirstChildWhichIsA("MeshPart", true)
                     or (targetEgg:IsA("BasePart") and targetEgg)
                     or targetEgg:FindFirstChildOfClass("BasePart")
                     or targetEgg:FindFirstChildWhichIsA("BasePart", true)
        if not eggPart then
            isStealing = false
            return
        end

        local initialCharItems = {}
        for _, item in ipairs(char:GetChildren()) do
            initialCharItems[item] = true
        end

        local basket = nil
        for _, item in ipairs(char:GetChildren()) do
            local iname = item.Name:lower()
            if iname:find("basket") or iname:find("backpack") then
                basket = item
                break
            end
        end
        local initialBasketCount = basket and #basket:GetChildren() or 0
        local initialCharCount = #char:GetChildren()

        local pickupRemotes = FindAllRemotes("pickup", "steal", "grab", "collect", "take", "egg")
        if Remote_EggPickup and not table.find(pickupRemotes, Remote_EggPickup) then
            table.insert(pickupRemotes, Remote_EggPickup)
        end

        SafeTeleport(eggPart.CFrame + Vector3.new(0, 1.2, 0))
        
        if LocalPlayer.GameplayPaused then
            local pStart = tick()
            while LocalPlayer.GameplayPaused and (tick() - pStart < 2.5) do
                task.wait(0.05)
            end
        end
        task.wait(0.1)

        if hum.Sit or hum.SeatPart then
            hum.Sit = false
            if Remote_PetDismount then
                SafeFireRemote(Remote_PetDismount)
            end
            task.wait(0.08)
            if eggPart and eggPart.Parent and hrp then
                SafeTeleport(eggPart.CFrame + Vector3.new(0, 0.8, 0))
            end
        end

        local nearbyPrompts = {}
        local function collectPrompts(container)
            if not container then return end
            for _, p in ipairs(container:GetDescendants()) do
                if p:IsA("ProximityPrompt") and not table.find(nearbyPrompts, p) then
                    table.insert(nearbyPrompts, p)
                end
            end
        end
        collectPrompts(targetEgg)
        collectPrompts(targetEgg.Parent)
        pcall(function()
            for _, p in ipairs(Workspace:GetDescendants()) do
                if p:IsA("ProximityPrompt") and p.Parent and p.Parent:IsA("BasePart") then
                    if (p.Parent.Position - eggPart.Position).Magnitude <= 25 then
                        if not table.find(nearbyPrompts, p) then
                            table.insert(nearbyPrompts, p)
                        end
                    end
                end
            end
        end)

        local startTime = tick()
        local grabbed = false
        local VIM = nil
        pcall(function() VIM = game:GetService("VirtualInputManager") end)

        local function triggerProximityPrompt(prompt)
            if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return end
            pcall(function()
                prompt.RequiresLineOfSight = false
                prompt.MaxActivationDistance = 99999
            end)
            local origHold = prompt.HoldDuration or 0
            if fireproximityprompt then
                pcall(function() fireproximityprompt(prompt, 0) end)
                pcall(function() fireproximityprompt(prompt, origHold) end)
                pcall(function() fireproximityprompt(prompt) end)
            end
            if typeof(prompt.InputHoldBegin) == "function" then
                pcall(function()
                    prompt.HoldDuration = 0
                    prompt:InputHoldBegin()
                    task.wait(0.03)
                    prompt:InputHoldEnd()
                    prompt.HoldDuration = origHold
                end)
            end
        end

        while (tick() - startTime < 4.0) do
            if not isAlive(char) then break end

            if isEggHeld(targetEgg, initialBasketCount, initialCharCount, initialCharItems) then
                grabbed = true
                break
            end

            if hum.Sit or hum.SeatPart then
                hum.Sit = false
                if Remote_PetDismount then SafeFireRemote(Remote_PetDismount) end
            end

            if eggPart and eggPart.Parent and hrp and (hrp.Position - eggPart.Position).Magnitude > 3 then
                SafeTeleport(eggPart.CFrame + Vector3.new(0, 0.5, 0))
            end

            for _, prompt in ipairs(nearbyPrompts) do
                triggerProximityPrompt(prompt)
            end

            if VIM then
                pcall(function()
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.03)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end)
            end

            for _, cd in ipairs(targetEgg:GetDescendants()) do
                if cd:IsA("ClickDetector") and fireclickdetector then
                    pcall(function() fireclickdetector(cd) end)
                end
            end

            if firetouchinterest and hrp then
                local contactParts = {hrp, char:FindFirstChild("Torso"), char:FindFirstChild("UpperTorso"), char:FindFirstChild("RightLeg"), char:FindFirstChild("RightFoot")}
                for _, cp in ipairs(contactParts) do
                    if cp and cp:IsA("BasePart") then
                        for _, ep in ipairs(targetEgg:GetDescendants()) do
                            if ep:IsA("BasePart") then
                                pcall(function()
                                    firetouchinterest(cp, ep, 0)
                                    firetouchinterest(cp, ep, 1)
                                end)
                            end
                        end
                        if eggPart and eggPart:IsA("BasePart") then
                            pcall(function()
                                firetouchinterest(cp, eggPart, 0)
                                firetouchinterest(cp, eggPart, 1)
                            end)
                        end
                    end
                end
            end

            for _, rem in ipairs(pickupRemotes) do
                SafeFireRemote(rem, targetEgg)
                SafeFireRemote(rem, eggPart)
                SafeFireRemote(rem, targetEgg.Name)
                SafeFireRemote(rem, targetEgg.Parent)
                if targetEgg.Parent then SafeFireRemote(rem, targetEgg.Parent.Name) end
                SafeFireRemote(rem, targetEgg, true)
                SafeFireRemote(rem, eggPart, true)
                SafeFireRemote(rem, 1)
                SafeFireRemote(rem)
            end

            pcall(function()
                if eggPart and VirtualUser then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(eggPart.Position)
                    if onScreen then
                        VirtualUser:Button1Down(Vector2.new(screenPos.X, screenPos.Y), Camera.CFrame)
                        task.wait(0.02)
                        VirtualUser:Button1Up(Vector2.new(screenPos.X, screenPos.Y), Camera.CFrame)
                    end
                end
            end)

            if hum and hrp and eggPart then
                hum:MoveTo(eggPart.Position)
            end

            task.wait(0.12)
        end

        if not grabbed and isEggHeld(targetEgg, initialBasketCount, initialCharCount, initialCharItems) then
            grabbed = true
        end

        task.wait(0.15)

        local basePos = GetPlayerBaseCFrame()
        SafeTeleport(basePos)
        
        if LocalPlayer.GameplayPaused then
            local pStart = tick()
            while LocalPlayer.GameplayPaused and (tick() - pStart < 2.5) do
                task.wait(0.05)
            end
        end
        task.wait(0.25)

        local placeRemotes = FindAllRemotes("place", "deposit", "nest", "put")
        if Remote_EggPlaced and not table.find(placeRemotes, Remote_EggPlaced) then
            table.insert(placeRemotes, Remote_EggPlaced)
        end

        local hatchRemotes = FindAllRemotes("hatch", "openegg", "incubate", "claim", "crack")
        if Remote_Hatch and not table.find(hatchRemotes, Remote_Hatch) then
            table.insert(hatchRemotes, Remote_Hatch)
        end

        local nests = GetPlayerNests()
        if #nests > 0 then
            local firstNest = nests[1]
            local fPart = firstNest:FindFirstChild("Handle") or firstNest.PrimaryPart or firstNest:FindFirstChildWhichIsA("BasePart", true)
            if fPart and hrp and (hrp.Position - fPart.Position).Magnitude > 15 then
                SafeTeleport(fPart.CFrame + Vector3.new(0, 1.5, 0))
                task.wait(0.15)
            end
        end

        for i, nest in ipairs(nests) do
            local nestPart = nest:FindFirstChild("Handle") or nest.PrimaryPart or nest:FindFirstChildWhichIsA("BasePart", true)

            for _, rem in ipairs(placeRemotes) do
                SafeFireRemote(rem, nest)
                SafeFireRemote(rem, nest.Name)
                SafeFireRemote(rem, i)
                SafeFireRemote(rem, targetEgg)
                SafeFireRemote(rem)
            end

            if firetouchinterest and hrp and nestPart then
                pcall(function()
                    firetouchinterest(hrp, nestPart, 0)
                    task.wait(0.02)
                    firetouchinterest(hrp, nestPart, 1)
                end)
            end

            for _, prompt in ipairs(nest:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    pcall(function()
                        prompt.HoldDuration = 0
                        prompt.RequiresLineOfSight = false
                        prompt.MaxActivationDistance = 99999
                    end)
                    if fireproximityprompt then
                        pcall(function() fireproximityprompt(prompt, 0) end)
                        pcall(function() fireproximityprompt(prompt) end)
                    end
                end
            end

            if State.AutoHatch then
                for _, hRem in ipairs(hatchRemotes) do
                    SafeFireRemote(hRem, nest)
                    SafeFireRemote(hRem, nest.Name)
                    SafeFireRemote(hRem, i)
                    SafeFireRemote(hRem)
                end
            end
        end

        if State.AutoEquipBest then
            task.spawn(function()
                task.wait(0.3)
                EquipBestPet()
            end)
        end

        State.AutoSteal = false
        if autoStealController then
            autoStealController.SetState(false)
        end
    end)

    isStealing = false
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoSteal and not isStealing and isAlive() then
            ExecuteStealEgg()
        end
    end
end)

local function ExecuteHatchNests()
    local char = getChar()
    local hrp = getRoot(char)
    local hatchRemotes = FindAllRemotes("hatch", "openegg", "incubate", "claim", "crack")
    if Remote_Hatch and not table.find(hatchRemotes, Remote_Hatch) then
        table.insert(hatchRemotes, Remote_Hatch)
    end

    pcall(function()
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Visible then
                local txt = desc.Text:lower()
                if txt:find("ready") or (txt:find("hatch") and not txt:find("auto")) then
                    local bg = desc:FindFirstAncestorWhichIsA("BillboardGui") or desc:FindFirstAncestorWhichIsA("SurfaceGui")
                    local eggModel = (bg and bg.Adornee and (bg.Adornee:IsA("Model") and bg.Adornee or bg.Adornee.Parent))
                                  or desc:FindFirstAncestorWhichIsA("Model") 
                                  or desc.Parent
                    local eggPart = (bg and bg.Adornee and bg.Adornee:IsA("BasePart") and bg.Adornee)
                                 or (eggModel and (eggModel.PrimaryPart or eggModel:FindFirstChildWhichIsA("BasePart", true)))
                                 or (desc.Parent and desc.Parent:IsA("BasePart") and desc.Parent)

                    if eggModel and eggPart then
                        for _, prompt in ipairs(eggModel:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") then
                                pcall(function()
                                    prompt.HoldDuration = 0
                                    prompt.RequiresLineOfSight = false
                                    prompt.MaxActivationDistance = 99999
                                end)
                                if fireproximityprompt then
                                    pcall(function() fireproximityprompt(prompt, 0) end)
                                    pcall(function() fireproximityprompt(prompt) end)
                                end
                            end
                        end

                        if firetouchinterest and hrp then
                            pcall(function()
                                firetouchinterest(hrp, eggPart, 0)
                                task.wait(0.01)
                                firetouchinterest(hrp, eggPart, 1)
                            end)
                        end

                        for _, rem in ipairs(hatchRemotes) do
                            SafeFireRemote(rem, eggModel)
                            SafeFireRemote(rem, eggModel.Name)
                            SafeFireRemote(rem, eggPart)
                            SafeFireRemote(rem, 1)
                            SafeFireRemote(rem, true)
                            SafeFireRemote(rem)
                        end
                    end
                end
            end
        end
    end)

    local nests = GetPlayerNests()
    for i, nest in ipairs(nests) do
        local nestPart = nest:FindFirstChild("Handle") or nest.PrimaryPart or nest:FindFirstChildWhichIsA("BasePart", true)

        for _, rem in ipairs(hatchRemotes) do
            SafeFireRemote(rem, nest)
            SafeFireRemote(rem, nest.Name)
            SafeFireRemote(rem, i)
            SafeFireRemote(rem, true)
            SafeFireRemote(rem)

            for _, child in ipairs(nest:GetChildren()) do
                if child:IsA("Model") or child.Name:lower():find("egg") then
                    SafeFireRemote(rem, child)
                    SafeFireRemote(rem, child.Name)
                end
            end
        end

        for _, prompt in ipairs(nest:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                pcall(function()
                    prompt.HoldDuration = 0
                    prompt.RequiresLineOfSight = false
                    prompt.MaxActivationDistance = 99999
                end)
                if fireproximityprompt then
                    pcall(function() fireproximityprompt(prompt, 0) end)
                    pcall(function() fireproximityprompt(prompt) end)
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoHatch and isAlive() then
            pcall(ExecuteHatchNests)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoPlace and isAlive() then
            pcall(function()
                local placeRemote = Remote_EggPlaced or GetRemote("EggPlaced", "PlaceEgg", "DepositEgg")
                local nests = GetPlayerNests()
                if #nests > 0 and placeRemote then
                    for _, nest in ipairs(nests) do
                        pcall(function() placeRemote:FireServer(nest) end)
                        pcall(function() placeRemote:FireServer(nest.Name) end)
                        pcall(function() placeRemote:FireServer() end)
                    end
                end
            end)
        end
    end
end)

local function GetBestPet()
    local myPlot = GetMyPlot()
    local petsFolder = myPlot and myPlot:FindFirstChild("Pets")
    local candidates = {}

    if petsFolder then
        for _, p in ipairs(petsFolder:GetChildren()) do
            if p:IsA("Model") then
                table.insert(candidates, p)
            end
        end
    end

    if #candidates == 0 then
        local pPets = LocalPlayer:FindFirstChild("Pets")
        if pPets then
            for _, p in ipairs(pPets:GetChildren()) do
                if p:IsA("Model") or p:IsA("Configuration") or p:IsA("Folder") then
                    table.insert(candidates, p)
                end
            end
        end
    end

    if #candidates == 0 then return nil end

    local bestPet = nil
    local bestScore = -1

    for _, pet in ipairs(candidates) do
        local score = 1
        local pName = pet.Name:lower()

        for eggKey, rank in pairs(EggRarityRank) do
            local baseKey = eggKey:gsub(" egg", "")
            if pName:find(baseKey, 1, true) then
                score = math.max(score, rank * 10)
            end
        end

        if pName:find("ethereal") or pName:find("blackhole") then score = math.max(score, 1000)
        elseif pName:find("divine") or pName:find("diamond") then score = math.max(score, 800)
        elseif pName:find("mythic") or pName:find("golden") then score = math.max(score, 650)
        elseif pName:find("legend") or pName:find("flaming") then score = math.max(score, 500)
        elseif pName:find("epic") or pName:find("skull") or pName:find("slime") then score = math.max(score, 350)
        elseif pName:find("rare") or pName:find("crystal") then score = math.max(score, 200)
        end

        for _, attr in ipairs({"Multiplier", "Speed", "Level", "Tier", "Power", "Rarity"}) do
            local val = pet:GetAttribute(attr)
            if typeof(val) == "number" then
                score = score + val * 5
            elseif typeof(val) == "string" then
                local sval = val:lower()
                if sval:find("ethereal") then score = score + 900
                elseif sval:find("divine") then score = score + 700
                elseif sval:find("mythic") then score = score + 500
                elseif sval:find("legend") then score = score + 400
                elseif sval:find("epic") then score = score + 200
                end
            end
        end

        for _, childName in ipairs({"Multiplier", "Speed", "Level", "Tier", "Rarity"}) do
            local cv = pet:FindFirstChild(childName)
            if cv and cv:IsA("ValueObject") and typeof(cv.Value) == "number" then
                score = score + cv.Value * 5
            end
        end

        if score > bestScore then
            bestScore = score
            bestPet = pet
        end
    end

    return bestPet or candidates[#candidates]
end

function EquipBestPet()
    local char = getChar()
    if not isAlive(char) then return end
    local hum = getHum(char)
    if not hum then return end

    local bestPet = GetBestPet()
    if not bestPet then return end

    if hum.SeatPart and hum.SeatPart:IsDescendantOf(bestPet) then
        return
    end

    if hum.SeatPart then
        local dRemote = Remote_PetDismount or GetRemote("PetDismount", "Dismount", "Unmount")
        if dRemote then
            pcall(function() dRemote:FireServer() end)
            task.wait(0.1)
        end
    end

    local mRemote = Remote_Mounting or GetRemote("Mounting", "Mount", "Ride", "RidePet", "EquipPet")
    if mRemote then
        pcall(function() mRemote:FireServer(bestPet) end)
        pcall(function() mRemote:FireServer(bestPet.Name) end)
        local idVal = bestPet:GetAttribute("Id") or bestPet:FindFirstChild("Id")
        if idVal then
            pcall(function() mRemote:FireServer(idVal) end)
        end
    end

    for _, prompt in ipairs(bestPet:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                prompt.HoldDuration = 0
                prompt.RequiresLineOfSight = false
                prompt.MaxActivationDistance = 99999
            end)
            if fireproximityprompt then
                pcall(function() fireproximityprompt(prompt, 0) end)
                pcall(function() fireproximityprompt(prompt) end)
            end
        end
    end

    local seat = bestPet:FindFirstChildWhichIsA("Seat", true) or bestPet:FindFirstChildWhichIsA("VehicleSeat", true)
    if seat and not hum.SeatPart then
        pcall(function() seat:Sit(hum) end)
    end
end

task.spawn(function()
    while true do
        task.wait(1.5)
        if State.AutoEquipBest and isAlive() then
            pcall(EquipBestPet)
        end
    end
end)

-- Rare Egg ESP Engine
local espHighlights = {}
local espBillboards = {}

local function ClearEggESP()
    for _, h in pairs(espHighlights) do
        if h and h.Parent then h:Destroy() end
    end
    for _, b in pairs(espBillboards) do
        if b and b.Parent then b:Destroy() end
    end
    espHighlights = {}
    espBillboards = {}
end

task.spawn(function()
    while true do
        task.wait(1.0)
        if State.RareEggESP then
            pcall(function()
                local renderedEggs = Workspace:FindFirstChild("RenderedEggs")
                local char = getChar()
                local hrp = getRoot(char)

                if renderedEggs and hrp then
                    for _, egg in ipairs(renderedEggs:GetChildren()) do
                        if egg:IsA("Model") then
                            if IsEggInsideAnyBase(egg) then
                                if espHighlights[egg] then espHighlights[egg]:Destroy() espHighlights[egg] = nil end
                                if espBillboards[egg] then espBillboards[egg]:Destroy() espBillboards[egg] = nil end
                            else
                                local eggName = egg.Name:lower()
                                local score = EggRarityRank[eggName] or 0

                                if score >= 25 or eggName:find("egg") then
                                    local targetPart = egg:FindFirstChild("Handle") or egg:FindFirstChild("EggBase") or egg.PrimaryPart or egg:FindFirstChildOfClass("BasePart")
                                    if targetPart and not espHighlights[egg] then
                                        local hl = Instance.new("Highlight")
                                        hl.Name = "JunejoEggESP"
                                        hl.Adornee = egg
                                        hl.FillColor = (score >= 80 and Color3.fromRGB(239, 68, 68)) or (score >= 50 and Color3.fromRGB(168, 85, 247)) or Color3.fromRGB(255, 215, 0)
                                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                        hl.FillTransparency = 0.35
                                        hl.OutlineTransparency = 0
                                        hl.Parent = egg
                                        espHighlights[egg] = hl

                                        local bb = Instance.new("BillboardGui")
                                        bb.Name = "JunejoEggTag"
                                        bb.Adornee = targetPart
                                        bb.Size = UDim2.new(0, 130, 0, 32)
                                        bb.StudsOffset = Vector3.new(0, 2.5, 0)
                                        bb.AlwaysOnTop = true

                                        local lbl = Instance.new("TextLabel")
                                        lbl.Size = UDim2.new(1, 0, 1, 0)
                                        lbl.BackgroundTransparency = 1
                                        lbl.Font = Enum.Font.GothamBold
                                        lbl.TextSize = 10
                                        lbl.TextColor3 = hl.FillColor
                                        lbl.TextStrokeTransparency = 0
                                        lbl.TextStrokeColor3 = Color3.fromRGB(15, 14, 22)
                                        lbl.Text = egg.Name .. "\n[" .. math.floor((hrp.Position - targetPart.Position).Magnitude) .. "m]"
                                        lbl.Parent = bb
                                        bb.Parent = targetPart
                                        espBillboards[egg] = bb
                                    end

                                    if espBillboards[egg] and targetPart then
                                        local lbl = espBillboards[egg]:FindFirstChildOfClass("TextLabel")
                                        if lbl then
                                            lbl.Text = egg.Name .. "\n[" .. math.floor((hrp.Position - targetPart.Position).Magnitude) .. "m]"
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            ClearEggESP()
        end
    end
end)

-- Player Chams ESP & Billboard Tags
local playerHighlights = {}
local playerBillboards = {}

local function ClearPlayerESP()
    for _, h in pairs(playerHighlights) do
        if h and h.Parent then h:Destroy() end
    end
    for _, b in pairs(playerBillboards) do
        if b and b.Parent then b:Destroy() end
    end
    playerHighlights = {}
    playerBillboards = {}
end

task.spawn(function()
    while true do
        task.wait(1.0)
        if State.PlayerESP or State.PlayerTags then
            pcall(function()
                local myChar = getChar()
                local myRoot = getRoot(myChar)

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local pChar = p.Character
                        local pHum = pChar:FindFirstChildOfClass("Humanoid")
                        local pRoot = pChar:FindFirstChild("HumanoidRootPart") or pChar.PrimaryPart

                        if pHum and pRoot and pHum.Health > 0 then
                            if State.PlayerESP and not playerHighlights[p] then
                                local hl = Instance.new("Highlight")
                                hl.Name = "JunejoPlayerChams"
                                hl.Adornee = pChar
                                hl.FillColor = Color3.fromRGB(168, 85, 247)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.4
                                hl.OutlineTransparency = 0
                                hl.Parent = pChar
                                playerHighlights[p] = hl
                            elseif not State.PlayerESP and playerHighlights[p] then
                                playerHighlights[p]:Destroy()
                                playerHighlights[p] = nil
                            end

                            if State.PlayerTags and not playerBillboards[p] then
                                local bb = Instance.new("BillboardGui")
                                bb.Name = "JunejoPlayerTag"
                                bb.Adornee = pRoot
                                bb.Size = UDim2.new(0, 140, 0, 36)
                                bb.StudsOffset = Vector3.new(0, 3.2, 0)
                                bb.AlwaysOnTop = true

                                local nameLbl = Instance.new("TextLabel", bb)
                                nameLbl.Size = UDim2.new(1, 0, 0, 18)
                                nameLbl.BackgroundTransparency = 1
                                nameLbl.Font = Enum.Font.GothamBold
                                nameLbl.TextSize = 11
                                nameLbl.TextColor3 = Color3.fromRGB(192, 132, 252)
                                nameLbl.TextStrokeTransparency = 0
                                nameLbl.TextStrokeColor3 = Color3.fromRGB(15, 14, 22)
                                nameLbl.Text = p.DisplayName

                                local distLbl = Instance.new("TextLabel", bb)
                                distLbl.Name = "DistLabel"
                                distLbl.Size = UDim2.new(1, 0, 0, 14)
                                distLbl.Position = UDim2.new(0, 0, 0, 18)
                                distLbl.BackgroundTransparency = 1
                                distLbl.Font = Enum.Font.Gotham
                                distLbl.TextSize = 9.5
                                distLbl.TextColor3 = Color3.fromRGB(157, 148, 190)
                                distLbl.TextStrokeTransparency = 0
                                distLbl.TextStrokeColor3 = Color3.fromRGB(15, 14, 22)

                                local dist = myRoot and math.floor((myRoot.Position - pRoot.Position).Magnitude) or 0
                                distLbl.Text = dist .. " Studs | HP: " .. math.floor(pHum.Health)
                                bb.Parent = pRoot
                                playerBillboards[p] = bb
                            elseif State.PlayerTags and playerBillboards[p] then
                                local distLbl = playerBillboards[p]:FindFirstChild("DistLabel")
                                if distLbl then
                                    local dist = myRoot and math.floor((myRoot.Position - pRoot.Position).Magnitude) or 0
                                    distLbl.Text = dist .. " Studs | HP: " .. math.floor(pHum.Health)
                                end
                            elseif not State.PlayerTags and playerBillboards[p] then
                                playerBillboards[p]:Destroy()
                                playerBillboards[p] = nil
                            end
                        end
                    end
                end
            end)
        else
            ClearPlayerESP()
        end
    end
end)

-- Physics Systems
local function ApplyWalkSpeed()
    pcall(function()
        local hum = getHum()
        if hum then
            hum.WalkSpeed = State.WalkSpeedActive and State.WalkSpeedValue or 16
        end
    end)
end

RunService.Stepped:Connect(function()
    if State.WalkSpeedActive and not State.FlyActive then
        local hum = getHum()
        if hum and hum.WalkSpeed ~= State.WalkSpeedValue then
            hum.WalkSpeed = State.WalkSpeedValue
        end
    end
end)

local function ApplyJumpPower()
    pcall(function()
        local hum = getHum()
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = State.JumpPowerActive and State.JumpPowerValue or 50
        end
    end)
end

RunService.Stepped:Connect(function()
    if State.JumpPowerActive then
        local hum = getHum()
        if hum and hum.JumpPower ~= State.JumpPowerValue then
            hum.UseJumpPower = true
            hum.JumpPower = State.JumpPowerValue
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfJumpActive and isAlive() then
        pcall(function()
            local hrp = getRoot()
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 55, hrp.AssemblyLinearVelocity.Z)
            end
        end)
    end
end)

RunService.Stepped:Connect(function()
    if State.NoClipActive and isAlive() then
        pcall(function()
            local char = getChar()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

local flyBodyGyro, flyBodyVelocity, flyConnection
local function StopFly()
    pcall(function()
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
        if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
        local hum = getHum()
        if hum then hum.PlatformStand = false end
    end)
end

local function StartFly()
    StopFly()
    pcall(function()
        local char = getChar()
        local hrp = getRoot(char)
        local hum = getHum(char)
        if not hrp or not hum then return end

        hum.PlatformStand = true

        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.P = 9e4
        flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBodyGyro.CFrame = hrp.CFrame
        flyBodyGyro.Parent = hrp

        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.Velocity = Vector3.zero
        flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBodyVelocity.Parent = hrp

        flyConnection = RunService.RenderStepped:Connect(function()
            if not State.FlyActive or not hrp.Parent then
                StopFly()
                return
            end

            local cam = Workspace.CurrentCamera
            local moveDir = hum.MoveDirection
            local speed = State.FlySpeed

            flyBodyGyro.CFrame = cam.CFrame
            if moveDir.Magnitude > 0 then
                flyBodyVelocity.Velocity = (cam.CFrame.LookVector * (moveDir.Z * -1) + cam.CFrame.RightVector * moveDir.X).Unit * speed
            else
                flyBodyVelocity.Velocity = Vector3.zero
            end
        end)
    end)
end

local origAmbient = Lighting.Ambient
local origBrightness = Lighting.Brightness
local origFogEnd = Lighting.FogEnd

local function ApplyFullBright()
    pcall(function()
        if State.FullBrightActive then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.FogEnd = 1e6
            Lighting.GlobalShadows = false
        else
            Lighting.Ambient = origAmbient
            Lighting.Brightness = origBrightness
            Lighting.FogEnd = origFogEnd
            Lighting.GlobalShadows = true
        end
    end)
end

pcall(function()
    local ProximityPromptService = game:GetService("ProximityPromptService")
    ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
        if State.InstantPrompts then
            pcall(function()
                prompt.HoldDuration = 0
                if typeof(fireproximityprompt) == "function" then
                    fireproximityprompt(prompt)
                end
            end)
        end
    end)
end)

LocalPlayer.Idled:Connect(function()
    if State.AntiAFKActive then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    ApplyWalkSpeed()
    ApplyJumpPower()
    if State.FlyActive then StartFly() end
end)

-- =================================================================
-- UI CREATION (UI 1: OFFICIAL ULTRA SCRIPT HUB CLASSIC MATTE DARK)
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoUltraScriptHub_RideAPet"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = guiParent
    else
        ScreenGui.Parent = guiParent
    end
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Window (Width: 280px, Height: 335px, Background: #0F0F11, Corner: 10px, Border: #23232A)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 335)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundTransparency = 1
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "RIDE A PET"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 34, 0, 34)
CloseButton.Position = UDim2.new(1, -34, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 170)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Header Divider Line
local HeaderDivider = Instance.new("Frame")
HeaderDivider.Name = "HeaderDivider"
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position = UDim2.new(0, 0, 0, 34)
HeaderDivider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderDivider.BorderSizePixel = 0
HeaderDivider.Parent = MainFrame

-- Header Draggable Logic
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

-- Scrollable Content Container
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"
ContentScroll.Size = UDim2.new(1, -24, 1, -80)
ContentScroll.Position = UDim2.new(0, 12, 0, 38)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 2
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 62)
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentScroll

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 4)
ContentPadding.PaddingBottom = UDim.new(0, 6)
ContentPadding.Parent = ContentScroll

-- =================================================================
-- UI 1 COMPONENT BUILDERS (Checkboxes, Steppers, Action Buttons, Dropdowns)
-- =================================================================
local currentLayoutOrder = 0

local function AddToggleRow(text, defaultState, callback)
    currentLayoutOrder = currentLayoutOrder + 1
    local Row = Instance.new("Frame")
    Row.Name = text .. "_Row"
    Row.Size = UDim2.new(1, 0, 0, 26)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = currentLayoutOrder
    Row.Parent = ContentScroll

    local RowBtn = Instance.new("TextButton")
    RowBtn.Size = UDim2.new(1, 0, 1, 0)
    RowBtn.BackgroundTransparency = 1
    RowBtn.Text = ""
    RowBtn.ZIndex = 5
    RowBtn.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local CheckBox = Instance.new("Frame")
    CheckBox.Size = UDim2.new(0, 18, 0, 18)
    CheckBox.Position = UDim2.new(1, -20, 0.5, -9)
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
    CheckMark.BackgroundTransparency = defaultState and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox

    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark

    local isEnabled = defaultState

    local function updateState(newState)
        isEnabled = newState
        CheckMark.BackgroundTransparency = isEnabled and 0 or 1
        if callback then
            callback(isEnabled)
        end
    end

    RowBtn.MouseButton1Click:Connect(function()
        updateState(not isEnabled)
    end)

    return {
        SetState = updateState,
        GetState = function() return isEnabled end
    }
end

local function AddActionButton(text, callback)
    currentLayoutOrder = currentLayoutOrder + 1
    local Btn = Instance.new("TextButton")
    Btn.Name = text .. "_Btn"
    Btn.Size = UDim2.new(1, 0, 0, 28)
    Btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Text = text:upper()
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.LayoutOrder = currentLayoutOrder
    Btn.Parent = ContentScroll

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(45, 45, 58) }):Play()
        task.wait(0.09)
        TweenService:Create(Btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(27, 27, 32) }):Play()
        if callback then
            callback()
        end
    end)

    return Btn
end

local function AddStepperRow(title, min, max, defaultVal, step, callback)
    currentLayoutOrder = currentLayoutOrder + 1
    local Row = Instance.new("Frame")
    Row.Name = title .. "_StepperRow"
    Row.Size = UDim2.new(1, 0, 0, 26)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = currentLayoutOrder
    Row.Parent = ContentScroll

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -115, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ControlFrame = Instance.new("Frame")
    ControlFrame.Size = UDim2.new(0, 105, 0, 24)
    ControlFrame.Position = UDim2.new(1, -105, 0.5, -12)
    ControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ControlFrame.BorderSizePixel = 0
    ControlFrame.Parent = Row

    local CtrlCorner = Instance.new("UICorner")
    CtrlCorner.CornerRadius = UDim.new(0, 6)
    CtrlCorner.Parent = ControlFrame

    local CtrlStroke = Instance.new("UIStroke")
    CtrlStroke.Color = Color3.fromRGB(45, 45, 55)
    CtrlStroke.Thickness = 1
    CtrlStroke.Parent = ControlFrame

    local MinusBtn = Instance.new("TextButton")
    MinusBtn.Size = UDim2.new(0, 26, 1, 0)
    MinusBtn.Position = UDim2.new(0, 0, 0, 0)
    MinusBtn.BackgroundTransparency = 1
    MinusBtn.Text = "-"
    MinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    MinusBtn.TextSize = 14
    MinusBtn.Font = Enum.Font.GothamBold
    MinusBtn.Parent = ControlFrame

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(1, -52, 1, 0)
    ValLabel.Position = UDim2.new(0, 26, 0, 0)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = tostring(defaultVal)
    ValLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValLabel.TextSize = 11
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.Parent = ControlFrame

    local PlusBtn = Instance.new("TextButton")
    PlusBtn.Size = UDim2.new(0, 26, 1, 0)
    PlusBtn.Position = UDim2.new(1, -26, 0, 0)
    PlusBtn.BackgroundTransparency = 1
    PlusBtn.Text = "+"
    PlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    PlusBtn.TextSize = 14
    PlusBtn.Font = Enum.Font.GothamBold
    PlusBtn.Parent = ControlFrame

    local currentVal = defaultVal
    step = step or 10

    MinusBtn.MouseButton1Click:Connect(function()
        currentVal = math.clamp(currentVal - step, min, max)
        ValLabel.Text = tostring(currentVal)
        if callback then
            callback(currentVal)
        end
    end)

    PlusBtn.MouseButton1Click:Connect(function()
        currentVal = math.clamp(currentVal + step, min, max)
        ValLabel.Text = tostring(currentVal)
        if callback then
            callback(currentVal)
        end
    end)

    return Row
end

local function AddDropdownRow(title, optionsList, defaultIndex, callback)
    currentLayoutOrder = currentLayoutOrder + 1
    local DropBtn = Instance.new("TextButton")
    DropBtn.Name = title .. "_DropdownBtn"
    DropBtn.Size = UDim2.new(1, 0, 0, 28)
    DropBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    DropBtn.BorderSizePixel = 0
    DropBtn.AutoButtonColor = false
    DropBtn.Text = ""
    DropBtn.LayoutOrder = currentLayoutOrder
    DropBtn.Parent = ContentScroll

    local DropCorner = Instance.new("UICorner")
    DropCorner.CornerRadius = UDim.new(0, 6)
    DropCorner.Parent = DropBtn

    local DropStroke = Instance.new("UIStroke")
    DropStroke.Color = Color3.fromRGB(45, 45, 55)
    DropStroke.Thickness = 1
    DropStroke.Parent = DropBtn

    local DropLabel = Instance.new("TextLabel")
    DropLabel.Size = UDim2.new(1, -34, 1, 0)
    DropLabel.Position = UDim2.new(0, 10, 0, 0)
    DropLabel.BackgroundTransparency = 1
    DropLabel.Text = title .. ": " .. tostring(optionsList[defaultIndex])
    DropLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
    DropLabel.Font = Enum.Font.GothamMedium
    DropLabel.TextSize = 11
    DropLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropLabel.Parent = DropBtn

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 24, 1, 0)
    Arrow.Position = UDim2.new(1, -26, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▾"
    Arrow.TextColor3 = Color3.fromRGB(160, 160, 175)
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 12
    Arrow.Parent = DropBtn

    currentLayoutOrder = currentLayoutOrder + 1
    local ListFrame = Instance.new("Frame")
    ListFrame.Name = title .. "_List"
    ListFrame.Size = UDim2.new(1, 0, 0, 0)
    ListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    ListFrame.BorderSizePixel = 0
    ListFrame.Visible = false
    ListFrame.ClipsDescendants = true
    ListFrame.LayoutOrder = currentLayoutOrder
    ListFrame.Parent = ContentScroll

    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 6)
    ListCorner.Parent = ListFrame

    local ListStroke = Instance.new("UIStroke")
    ListStroke.Color = Color3.fromRGB(45, 45, 55)
    ListStroke.Thickness = 1
    ListStroke.Parent = ListFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 3)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListFrame

    local ListPadding = Instance.new("UIPadding")
    ListPadding.PaddingTop = UDim.new(0, 4)
    ListPadding.PaddingBottom = UDim.new(0, 4)
    ListPadding.PaddingLeft = UDim.new(0, 4)
    ListPadding.PaddingRight = UDim.new(0, 4)
    ListPadding.Parent = ListFrame

    local isOpen = false
    local totalH = #optionsList * 25 + 8

    for idx, item in ipairs(optionsList) do
        local ItemBtn = Instance.new("TextButton")
        ItemBtn.Size = UDim2.new(1, 0, 0, 22)
        ItemBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
        ItemBtn.BorderSizePixel = 0
        ItemBtn.AutoButtonColor = false
        ItemBtn.Text = string.format("  %d. %s", idx, tostring(item))
        ItemBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
        ItemBtn.Font = Enum.Font.GothamMedium
        ItemBtn.TextSize = 10
        ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
        ItemBtn.LayoutOrder = idx
        ItemBtn.Parent = ListFrame

        local ItemCorner = Instance.new("UICorner")
        ItemCorner.CornerRadius = UDim.new(0, 4)
        ItemCorner.Parent = ItemBtn

        ItemBtn.MouseButton1Click:Connect(function()
            DropLabel.Text = title .. ": " .. tostring(item)
            isOpen = false
            Arrow.Text = "▾"
            TweenService:Create(ListFrame, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 0) }):Play()
            task.wait(0.16)
            ListFrame.Visible = false
            if callback then
                callback(item)
            end
        end)
    end

    DropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        Arrow.Text = isOpen and "▴" or "▾"
        if isOpen then
            ListFrame.Visible = true
            TweenService:Create(ListFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, totalH)
            }):Play()
        else
            local tw = TweenService:Create(ListFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(1, 0, 0, 0)
            })
            tw:Play()
            tw.Completed:Connect(function()
                if not isOpen then ListFrame.Visible = false end
            end)
        end
    end)

    return DropBtn
end

-- =================================================================
-- REGISTER ALL FEATURES
-- =================================================================

-- 1. Auto Steal (Rarest Egg) Toggle
autoStealController = AddToggleRow("Auto Steal (Rarest Egg)", false, function(s)
    State.AutoSteal = s
    if s then
        task.spawn(ExecuteStealEgg)
    end
end)

-- 2. Steal Target Rarity Dropdown
AddDropdownRow("Steal Target Rarity", StealZoneOptions, 1, function(opt)
    State.SelectedStealZone = opt
    if State.AutoSteal then
        task.spawn(ExecuteStealEgg)
    end
end)

-- 3. Auto Hatch Eggs Toggle
AddToggleRow("Auto Hatch Eggs", false, function(s)
    State.AutoHatch = s
    if s then
        task.spawn(function()
            pcall(ExecuteHatchNests)
        end)
    end
end)

-- 4. Auto Place Eggs Toggle
AddToggleRow("Auto Place Eggs", false, function(s)
    State.AutoPlace = s
end)

-- 5. Auto Equip Best Pet Toggle
AddToggleRow("Auto Equip Best Pet", false, function(s)
    State.AutoEquipBest = s
    if s then
        task.spawn(function()
            EquipBestPet()
        end)
    end
end)

-- 6. Teleport Destination Dropdown
AddDropdownRow("Teleport Destination", TeleportZoneNames, 1, function(opt)
    State.SelectedTeleportZone = opt
    TeleportToLocation(opt)
end)

-- 7. Teleport to Destination Action Button
AddActionButton("Teleport to Destination", function()
    TeleportToLocation(State.SelectedTeleportZone)
end)

-- 8. Teleport to My Base Action Button
AddActionButton("Teleport to My Base", function()
    TeleportToLocation("My Base / Plot")
end)

-- 9. WalkSpeed Boost & Stepper
AddToggleRow("WalkSpeed Boost", false, function(s)
    State.WalkSpeedActive = s
    ApplyWalkSpeed()
end)

AddStepperRow("WalkSpeed", 16, 250, 45, 10, function(v)
    State.WalkSpeedValue = v
    ApplyWalkSpeed()
end)

-- 10. JumpPower Boost & Stepper
AddToggleRow("JumpPower Boost", false, function(s)
    State.JumpPowerActive = s
    ApplyJumpPower()
end)

AddStepperRow("JumpPower", 50, 300, 50, 10, function(v)
    State.JumpPowerValue = v
    ApplyJumpPower()
end)

-- 11. Infinite Jump Toggle
AddToggleRow("Infinite Jump", false, function(s)
    State.InfJumpActive = s
end)

-- 12. Player NoClip Toggle
AddToggleRow("Player NoClip", false, function(s)
    State.NoClipActive = s
end)

-- 13. Universal 3D Fly & Stepper
AddToggleRow("Universal 3D Fly", false, function(s)
    State.FlyActive = s
    if s then StartFly() else StopFly() end
end)

AddStepperRow("Fly Speed", 10, 200, 50, 10, function(v)
    State.FlySpeed = v
end)

-- 14. Rare Egg ESP Toggle
AddToggleRow("Rare Egg ESP", false, function(s)
    State.RareEggESP = s
    if not s then ClearEggESP() end
end)

-- 15. Player Chams ESP Toggle
AddToggleRow("Player Chams ESP", false, function(s)
    State.PlayerESP = s
    if not s then ClearPlayerESP() end
end)

-- 16. Player Info Tags Toggle
AddToggleRow("Player Info Tags", false, function(s)
    State.PlayerTags = s
    if not s then ClearPlayerESP() end
end)

-- 17. FullBright & Clear Fog Toggle
AddToggleRow("FullBright & Clear Fog", false, function(s)
    State.FullBrightActive = s
    ApplyFullBright()
end)

-- 18. Instant Prompts Toggle
AddToggleRow("Instant Prompts", false, function(s)
    State.InstantPrompts = s
end)

-- 19. Anti-AFK System Toggle
AddToggleRow("Anti-AFK System", true, function(s)
    State.AntiAFKActive = s
end)

-- 20. Server Actions
AddActionButton("Rejoin Server", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

AddActionButton("Server Hop", function()
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local res = game:HttpGet(url)
        local data = HttpService:JSONDecode(res)
        for _, s in ipairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                return
            end
        end
    end)
end)

-- =================================================================
-- MANDATORY CENTERED FOOTER (ULTRA SCRIPT HUB | Made by Junejo)
-- =================================================================
local FooterDivider = Instance.new("Frame")
FooterDivider.Name = "FooterDivider"
FooterDivider.Size = UDim2.new(1, 0, 0, 1)
FooterDivider.Position = UDim2.new(0, 0, 1, -40)
FooterDivider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
FooterDivider.BorderSizePixel = 0
FooterDivider.Parent = MainFrame

local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 39)
Footer.Position = UDim2.new(0, 0, 1, -39)
Footer.BackgroundTransparency = 1
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Name = "FooterTitle"
FooterTitle.Size = UDim2.new(1, 0, 0, 16)
FooterTitle.Position = UDim2.new(0, 0, 0, 4)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 12
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Name = "FooterSub"
FooterSub.Size = UDim2.new(1, 0, 0, 14)
FooterSub.Position = UDim2.new(0, 0, 0, 20)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 10
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.Parent = Footer

print("[ULTRA SCRIPT HUB] Ride A Pet loaded successfully!")
