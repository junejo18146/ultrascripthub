-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - MUSCLE LEGENDS (OFFICIAL)
-- Game: Muscle Legends
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Safe GUI Parent Resolver (Guarantees Instant Rendering on Mobile & PC)
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
    for _, name in ipairs({"JunejoHubUI_MuscleLegends", "JunejoMuscleLegendsUI", "AjizMuscleHub"}) do
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
-- GLOBAL STATE & DATA STORAGE
-- ====================================================
local State = {
    Running = true,
    FarmMode = "Off",
    RepDelay = 0.06,
    AutoBenchmark = false,
    BenchmarkSeconds = 12,
    BenchmarkEvery = 600,
    SourcePreference = "Auto (fastest)",
    StrengthSource = "Tools (Best for Rebirth)",
    RotateSeconds = 120,
    
    AutoRebirth = false,
    SmartRebirthFulfillment = true,
    AutoRebirthPetSwap = true,
    AutoRebirthBoostPush = true,
    
    AutoBoosts = false,
    SaveBigBoosts = false,
    AutoUltimates = true,
    UltimatePlan = "Rebirth",
    KeepRebirths = 0,
    AutoChests = false,
    AutoGroup = false,
    AutoGifts = false,
    AutoWheel = false,
    AutoQuests = false,
    AutoHatch = false,
    HatchCrystal = "Blue Crystal",
    KeepCurrency = 0,
    HatchDelay = 0.4,
    AutoEquipPets = false,
    PetPriority = "Farm speed",
    AutoSellPets = false,
    SellRarities = {},
    AutoDeletePets = false,
    DeletePetNames = {},
    AutoEvolvePets = false,
    AlwaysKingsGym = true,
    AntiAFK = true,
    Notify = true,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

local CustomSpeedValue = 50
local Runtime = {
    Status = "Idle",
    Target = "none",
    Bench = "not run",
    FarmToken = 0,
    Reps = 0,
    Hatched = 0,
    Claimed = 0,
    Boosts = 0,
    Upgrades = 0,
    Evolved = 0,
    RebirthCount = 0,
    RebirthBusy = false,
    KingLockedUntil = 0,
    Heartbeat = 0,
    Rates = {},
    RatesStamp = 0,
    RatesRebirth = -1,
    StartClock = os.clock(),
    StartStats = {Strength = 0, Agility = 0, Durability = 0},
    Blacklist = {},
}

-- ====================================================
-- SAFE LAZY-BINDING GAME ENGINE & REMOTES
-- ====================================================
local rEvents = ReplicatedStorage:FindFirstChild("rEvents") or ReplicatedStorage:WaitForChild("rEvents", 5)
local sharedFolder = ReplicatedStorage:FindFirstChild("shared") or ReplicatedStorage:WaitForChild("shared", 5)

local GF = nil
pcall(function()
    if sharedFolder and sharedFolder:FindFirstChild("modules") and sharedFolder.modules:FindFirstChild("GlobalFunctions") then
        GF = require(sharedFolder.modules.GlobalFunctions)
    end
end)

local Data = nil
pcall(function()
    if ReplicatedStorage:FindFirstChild("packages") and ReplicatedStorage.packages:FindFirstChild("ReplicatorClient") then
        Data = require(ReplicatedStorage.packages.ReplicatorClient).get("Data")
    end
end)

local function getLocalStat(name)
    local val = LocalPlayer:FindFirstChild(name)
    if val then return val end
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then return ls:FindFirstChild(name) end
    return nil
end

local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent") or LocalPlayer:WaitForChild("muscleEvent", 5)
local machineInUse = LocalPlayer:FindFirstChild("machineInUse") or LocalPlayer:WaitForChild("machineInUse", 5)
local leaderstats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:WaitForChild("leaderstats", 5)

local Strength = (leaderstats and leaderstats:FindFirstChild("Strength")) or LocalPlayer:WaitForChild("Strength", 5)
local Rebirths = (leaderstats and leaderstats:FindFirstChild("Rebirths")) or LocalPlayer:WaitForChild("Rebirths", 5)
local Agility = LocalPlayer:FindFirstChild("Agility") or LocalPlayer:WaitForChild("Agility", 5)
local Durability = LocalPlayer:FindFirstChild("Durability") or LocalPlayer:WaitForChild("Durability", 5)
local Gems = LocalPlayer:FindFirstChild("Gems") or LocalPlayer:WaitForChild("Gems", 5)
local Tokens = LocalPlayer:FindFirstChild("Tokens") or LocalPlayer:WaitForChild("Tokens", 5)

if Strength then Runtime.StartStats.Strength = Strength.Value end
if Agility then Runtime.StartStats.Agility = Agility.Value end
if Durability then Runtime.StartStats.Durability = Durability.Value end

local Remotes = {}
if rEvents then
    Remotes.Machine   = rEvents:FindFirstChild("machineInteractRemote")
    Remotes.Rebirth   = rEvents:FindFirstChild("rebirthRemote")
    Remotes.Crystal   = rEvents:FindFirstChild("openCrystalRemote")
    Remotes.Chest     = rEvents:FindFirstChild("checkChestRemote")
    Remotes.Group     = rEvents:FindFirstChild("groupRemote")
    Remotes.Gift      = rEvents:FindFirstChild("freeGiftClaimRemote")
    Remotes.Wheel     = rEvents:FindFirstChild("openFortuneWheelRemote")
    Remotes.Quests    = rEvents:FindFirstChild("questsEvent")
    Remotes.EquipPet  = rEvents:FindFirstChild("equipPetEvent")
    Remotes.SellPet   = rEvents:FindFirstChild("sellPetEvent")
    Remotes.PetEvolve = rEvents:FindFirstChild("petEvolveEvent")
    Remotes.Area      = rEvents:FindFirstChild("areaTravelRemote")
    Remotes.Rejoin    = rEvents:FindFirstChild("rejoinServerEvent")
    Remotes.Ultimates = rEvents:FindFirstChild("ultimatesRemote")
end

local machinesFolder = Workspace:FindFirstChild("machinesFolder") or Workspace:WaitForChild("machinesFolder", 5)
local treadmillsFolder = Workspace:FindFirstChild("Treadmills") or Workspace:WaitForChild("Treadmills", 5)
local areaTeleportParts = Workspace:FindFirstChild("areaTeleportParts") or Workspace:WaitForChild("areaTeleportParts", 5)
local kingsGymPart = areaTeleportParts and areaTeleportParts:FindFirstChild("beachToMuscleKing")

local crystalPrices = sharedFolder and sharedFolder:FindFirstChild("catalogs") and sharedFolder.catalogs:FindFirstChild("crystalPrices")
local gameUltimates = sharedFolder and sharedFolder:FindFirstChild("catalogs") and sharedFolder.catalogs:FindFirstChild("gameUltimatesFolder")
local fortuneWheel = sharedFolder and sharedFolder:FindFirstChild("catalogs") and sharedFolder.catalogs:FindFirstChild("fortuneWheelChances") and sharedFolder.catalogs.fortuneWheelChances:FindFirstChild("Fortune Wheel")
local questCatalog = sharedFolder and sharedFolder:FindFirstChild("catalogs") and sharedFolder.catalogs:FindFirstChild("Quests")
local questsNpcs = Workspace:FindFirstChild("questsNpcs")

local CHEST_NAMES = {"Golden Chest", "Enchanted Chest", "Magma Chest", "Mythical Chest", "Legends Chest", "Jungle Chest"}

local TOOL_STATS = {
    Weight     = {strengthGain = true},
    Situps     = {strengthGain = true, agilityGain = true},
    Pushups    = {strengthGain = true, agilityGain = true, durabilityGain = true},
    Handstands = {strengthGain = true, durabilityGain = true},
}

local TIMED_BOOSTS = {["Protein Egg"] = "Protein Egg", ["Tropical Shake"] = "Tropical Shake"}
local BOOST_ACTIONS = {
    ["Protein Bar"]    = "proteinBar",
    ["Protein Shake"]  = "proteinShake",
    ["Protein Egg"]    = "proteinEgg",
    ["Energy Bar"]     = "energyBar",
    ["Energy Shake"]   = "energyShake",
    ["TOUGH Bar"]      = "toughBar",
    ["ULTRA Shake"]    = "ultraShake",
    ["Tropical Shake"] = "tropicalShake",
}
local INSTANT_BOOSTS = {
    ["Protein Bar"] = true, ["Protein Shake"] = true, ["TOUGH Bar"] = true,
    ["ULTRA Shake"] = true, ["Energy Bar"] = true, ["Energy Shake"] = true,
}
local SAVED_FOR_PUSH = {["ULTRA Shake"] = true, ["TOUGH Bar"] = true}

local PERK_PETS = {
    ["Swift Samurai"]   = 6000,
    ["Powercore Hound"] = 5000,
    ["Tribal Overlord"] = 4000,
    ["Titanium Hydra"]  = 3000,
    ["Speedy Sally"]    = 2000,
}

local PET_PRIORITY = {
    ["Farm speed"] = {["Swift Samurai"] = 6, ["Powercore Hound"] = 5, ["Tribal Overlord"] = 4, ["Titanium Hydra"] = 3, ["Speedy Sally"] = 2},
    ["Rebirths"]   = {["Tribal Overlord"] = 6, ["Speedy Sally"] = 5, ["Titanium Hydra"] = 4, ["Swift Samurai"] = 3, ["Powercore Hound"] = 2},
    ["Raw stats"]  = {},
}
local RARITY_ORDER = {Basic = 1, Rare = 2, Epic = 3, Unique = 4, Advanced = 5}

local ULTIMATE_PRIORITY = {
    Speed      = {"Galaxy Gains", "+5% Rep Speed", "Golden Rebirth"},
    Balanced   = {"Galaxy Gains", "+5% Rep Speed", "Jungle Swift", "Muscle Mind", "Golden Rebirth"},
    Rebirth    = {"Golden Rebirth", "Galaxy Gains", "+5% Rep Speed"},
    Everything = {"Galaxy Gains", "+5% Rep Speed", "Golden Rebirth", "+1 Pet Slot", "x2 Quest Rewards", "x2 Chest Rewards", "+1 Daily Spin", "Jungle Swift", "Muscle Mind", "+10 Item Capacity", "Infernal Health", "Demon Damage"},
}

local char, hum, hrp
local restartFarm

local function bindCharacter(c)
    char = c
    hum = c:WaitForChild("Humanoid", 10)
    hrp = c:WaitForChild("HumanoidRootPart", 10)
end

if LocalPlayer.Character then bindCharacter(LocalPlayer.Character) end

LocalPlayer.CharacterAdded:Connect(function(c)
    bindCharacter(c)
    Runtime.Blacklist = {}
    Runtime.Heartbeat = os.clock()
    if State.FarmMode ~= "Off" and not Runtime.RebirthBusy and restartFarm then restartFarm() end
end)

local function alive()
    return char and char.Parent and hum and hrp and hrp.Parent and hum.Health > 0
end

local function gf(name, ...)
    if not GF or not GF[name] then return nil end
    local packed = table.pack(pcall(GF[name], ...))
    elevate()
    if packed[1] then return table.unpack(packed, 2, packed.n) end
    return nil
end

local function invoke(remote, ...)
    if not remote then return nil end
    local packed = table.pack(pcall(remote.InvokeServer, remote, ...))
    elevate()
    if packed[1] then return table.unpack(packed, 2, packed.n) end
    return nil
end

local function fire(remote, ...)
    if not remote then return end
    pcall(remote.FireServer, remote, ...)
    elevate()
end

local function dataIndex(...)
    if not Data then return nil end
    local ok, v = pcall(function(...) return Data:TryIndex({...}) end, ...)
    elevate()
    if ok then return v end
    return nil
end

local function running()
    return State.Running
end

local function farming(token)
    return running() and State.FarmMode ~= "Off" and token == Runtime.FarmToken
end

local function short(n)
    if type(n) ~= "number" then return tostring(n or 0) end
    local s = gf("shortenNumber", n)
    if s then return s end
    if n >= 1e12 then return string.format("%.2fT", n / 1e12)
    elseif n >= 1e9 then return string.format("%.2fB", n / 1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n / 1e6)
    elseif n >= 1e3 then return string.format("%.2fK", n / 1e3)
    end
    return tostring(math.floor(n))
end

local function statValue(gainKey)
    if gainKey == "strengthGain" and Strength then return Strength.Value end
    if gainKey == "agilityGain" and Agility then return Agility.Value end
    if Durability then return Durability.Value end
    return 0
end

local function repsCounter()
    local quests = LocalPlayer:FindFirstChild("Quests")
    if not quests then return nil end
    for _, group in ipairs(quests:GetChildren()) do
        for _, quest in ipairs(group:GetChildren()) do
            local req = quest:FindFirstChild("requirements")
            local reps = req and req:FindFirstChild("Reps")
            local progress = reps and reps:FindFirstChild("progress")
            if progress then return progress end
        end
    end
    return nil
end

local function beat()
    Runtime.Heartbeat = os.clock()
end

local function beatWait(seconds)
    local t0 = os.clock()
    while os.clock() - t0 < seconds do
        beat()
        task.wait(0.2)
    end
end

local function anchorAt(cf)
    if not alive() then return end
    hrp.CFrame = cf
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
end

local function isMounted()
    return char and (char:GetAttribute("MachineStandingMount") == true
        or char:GetAttribute("MachineScaleFrozen") == true
        or (hum and hum.SeatPart ~= nil))
end

local function unseat()
    if not hum then return end
    pcall(function() hum.Sit = false end)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    if hum.SeatPart then
        for _, w in ipairs(hum.SeatPart:GetChildren()) do
            if w:IsA("Weld") and w.Name == "SeatWeld" then pcall(function() w:Destroy() end) end
        end
    end
end

local function leaveMachine()
    if Remotes.Machine then invoke(Remotes.Machine, "leaveMachine") end
    unseat()
    local t = os.clock()
    while isMounted() and os.clock() - t < 4 do
        beat()
        unseat()
        task.wait(0.15)
    end
    task.wait(0.15)
    beat()
    return not isMounted()
end

local function blacklisted(inst)
    local until_ = Runtime.Blacklist[inst]
    return until_ ~= nil and until_ > os.clock()
end

local function meetsRequirements(inst)
    local req = inst:FindFirstChild("requirements")
    if not req then return true end
    local can = gf("checkIfPlayerCanUseMachine", LocalPlayer, req)
    return can == nil or can == true
end

local function findTool(name)
    local bp = LocalPlayer:FindFirstChild("Backpack")
    return (bp and bp:FindFirstChild(name)) or (char and char:FindFirstChild(name))
end

local function toolUsable(name)
    local tool = findTool(name)
    if not tool then return false end
    local amount = tool:FindFirstChild("requiredAmount")
    local kind = tool:FindFirstChild("requiredType")
    if not amount or not kind then return true end
    local have = Strength and Strength.Value or 0
    if kind.Value == "Agility" and Agility then have = Agility.Value
    elseif kind.Value == "Durability" and Durability then have = Durability.Value end
    return have >= amount.Value
end

local function equipTool(name)
    local tool = findTool(name)
    if not tool or not hum then return false end
    pcall(function() hum:EquipTool(tool) end)
    return true
end

local function heldTool()
    local t = char and char:FindFirstChildOfClass("Tool")
    return t and t.Name or nil
end

local function machineSources(gainKey)
    local list = {}
    if not machinesFolder then return list end
    for _, m in ipairs(machinesFolder:GetChildren()) do
        local gain = m:FindFirstChild(gainKey)
        local seat = m.PrimaryPart
        local repTime = m:FindFirstChild("repTime")
        local kingLocked = m:GetAttribute("IsKingMachine") == true
            and (Runtime.KingLockedUntil or 0) > os.clock()
        if gain and seat and seat:IsA("Seat") and not kingLocked and not blacklisted(m) and meetsRequirements(m) then
            local rt = repTime and repTime.Value or 1
            if rt <= 0 then rt = 1 end
            table.insert(list, {
                kind = "machine", key = "M:" .. m.Name, model = m, seat = seat,
                gain = gain.Value, repTime = rt, estimate = gain.Value / rt,
                label = m.Name .. " (+" .. gain.Value .. "/" .. rt .. "s)",
            })
        end
    end
    table.sort(list, function(a, b) return a.estimate > b.estimate end)
    return list
end

local function toolSources(gainKey)
    local list = {}
    for name, stats in pairs(TOOL_STATS) do
        if stats[gainKey] and toolUsable(name) then
            local tool = findTool(name)
            local gain = tool and tool:FindFirstChild(gainKey)
            local repTime = tool and tool:FindFirstChild("repTime")
            local rt = repTime and repTime.Value or 1
            if rt <= 0 then rt = 1 end
            table.insert(list, {
                kind = "tool", key = "T:" .. name, toolName = name,
                gain = gain and gain.Value or 0, repTime = rt,
                estimate = (gain and gain.Value or 0) / rt,
                label = name .. " tool",
            })
        end
    end
    table.sort(list, function(a, b) return a.estimate > b.estimate end)
    return list
end

local function candidateSources(gainKey)
    local machines = machineSources(gainKey)
    local tools = toolSources(gainKey)
    if #machines == 0 and #tools == 0 and next(Runtime.Blacklist) then
        Runtime.Blacklist = {}
        machines = machineSources(gainKey)
        tools = toolSources(gainKey)
    end
    local out = {}
    local preference = gainKey == "strengthGain" and State.StrengthSource or State.SourcePreference
    local toolsOnly = preference == "Tools only" or preference == "Tools (Hotbar)" or preference == "Tools (Best for Rebirth)"
    local machinesOnly = preference == "Machines only" or preference == "Machines"
    if not toolsOnly then
        for i = 1, math.min(2, #machines) do table.insert(out, machines[i]) end
    end
    if not machinesOnly then
        for i = 1, math.min(2, #tools) do table.insert(out, tools[i]) end
    end
    if #out == 0 then
        for i = 1, math.min(1, #machines) do table.insert(out, machines[i]) end
        for i = 1, math.min(1, #tools) do table.insert(out, tools[i]) end
    end
    return out
end

local function engageMachine(source)
    if not alive() then return false end
    if isMounted() and not leaveMachine() then
        Runtime.Status = "Stuck on a machine, retrying"
        task.wait(0.1)
        return false
    end
    for _ = 1, 3 do
        if not alive() then return false end
        beat()
        anchorAt(source.seat.CFrame * CFrame.new(0, 5, 0))
        task.wait(0.05)
    end
    if not Remotes.Machine then return false end
    local res, reason = invoke(Remotes.Machine, "useMachine", source.seat)
    if res ~= true then
        if reason == "isKingMachine" or source.model:GetAttribute("IsKingMachine") == true then
            Runtime.KingLockedUntil = os.clock() + 120
        else
            Runtime.Blacklist[source.model] = os.clock() + 180
        end
        return false
    end
    local deadline = os.clock() + 0.6
    while machineInUse and machineInUse.Value ~= source.seat and os.clock() < deadline do
        beat()
        task.wait(0.03)
    end
    return machineInUse and machineInUse.Value == source.seat
end

local function engageTool(source)
    if isMounted() and not leaveMachine() then
        Runtime.Status = "Stuck on a machine, retrying"
        task.wait(0.5)
        return false
    end
    beat()
    equipTool(source.toolName)
    beatWait(0.5)
    return heldTool() == source.toolName
end

local function engage(source)
    if source.kind == "machine" then return engageMachine(source) end
    return engageTool(source)
end

local function repOnce(source)
    if not muscleEvent then return end
    if source.kind == "machine" then
        muscleEvent:FireServer("rep", source.seat)
    else
        muscleEvent:FireServer("rep")
    end
    Runtime.Reps = Runtime.Reps + 1
end

local function sourceHealthy(source)
    if source.kind == "machine" then return machineInUse and machineInUse.Value == source.seat end
    return heldTool() == source.toolName and not isMounted()
end

local function pickSource(gainKey, token)
    local list = candidateSources(gainKey)
    if #list == 0 then return nil end
    local best, bestScore
    for _, source in ipairs(list) do
        local score = Runtime.Rates[source.key] or source.estimate
        if not bestScore or score > bestScore then best, bestScore = source, score end
    end
    return best
end

local function rebirthTarget()
    if not Rebirths then return math.huge end
    local need = gf("calculateRequiredRebirthStrength", Rebirths.Value, LocalPlayer)
    if type(need) == "number" then return need end
    return (Rebirths.Value + 1) * 10000
end

local function canRebirth()
    if not Strength then return false end
    if char and char:GetAttribute("IsRebirthing") == true then return false end
    if LocalPlayer:GetAttribute("LastMapCFrame") ~= nil then return false end
    return Strength.Value >= rebirthTarget()
end

local function boostActive(name)
    local folder = LocalPlayer:FindFirstChild("boostTimersFolder")
    local entry = folder and folder:FindFirstChild(name)
    return entry ~= nil and entry.Value > 0
end

local function boostAction(name)
    local known = BOOST_ACTIONS[name]
    if known then return known end
    local parts = {}
    for word in tostring(name):gmatch("%S+") do
        if #parts == 0 then parts[1] = word:lower()
        else parts[#parts + 1] = word:sub(1, 1):upper() .. word:sub(2):lower() end
    end
    return table.concat(parts)
end

local function useConsumable(tool)
    if not hum or not char or not tool or not tool.Parent or not muscleEvent then return false end
    beat()
    local consumables = LocalPlayer:FindFirstChild("consumablesFolder")
    local before = consumables and #consumables:GetChildren() or 0
    pcall(function() hum:EquipTool(tool) end)
    local t = os.clock()
    while char:FindFirstChildOfClass("Tool") ~= tool and os.clock() - t < 1.5 do
        beat()
        task.wait(0.1)
    end
    if char:FindFirstChildOfClass("Tool") ~= tool then return false end
    fire(muscleEvent, boostAction(tool.Name), tool)
    Runtime.Boosts = Runtime.Boosts + 1
    return true
end

local function useBoosts(forPush)
    if isMounted() then leaveMachine() end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return 0, 0 end
    local used, failed = 0, 0
    for _, tool in ipairs(bp:GetChildren()) do
        if not running() then break end
        if tool.Parent and TIMED_BOOSTS[tool.Name] and not boostActive(tool.Name) then
            if useConsumable(tool) then used = used + 1 else failed = failed + 1 end
        end
    end
    for _, tool in ipairs(bp:GetChildren()) do
        if not running() then break end
        if tool.Parent and INSTANT_BOOSTS[tool.Name] then
            local hold = State.SaveBigBoosts and SAVED_FOR_PUSH[tool.Name] and not forPush
            if not hold then
                if useConsumable(tool) then used = used + 1 else failed = failed + 1 end
            end
        end
    end
    if hum then pcall(function() hum:UnequipTools() end) end
    if used > 0 then notify("Boosts", used .. " consumable(s) used", 2.5) end
    return used, failed
end

local function upgradeUltimates()
    if not gameUltimates or not Remotes.Ultimates or not Rebirths then return 0 end
    local plan = ULTIMATE_PRIORITY[State.UltimatePlan] or ULTIMATE_PRIORITY.Rebirth
    local done = 0
    for _, name in ipairs(plan) do
        if not running() then break end
        local entry = gameUltimates:FindFirstChild(name)
        if entry then
            local maxUp = entry:FindFirstChild("maxUpgrades")
            local level = dataIndex("ultimatesFolder", name) or 0
            if type(level) ~= "number" then level = 0 end
            if not maxUp or level < maxUp.Value then
                local cost = gf("calculateUltimateRebirthCost", entry, level)
                if type(cost) == "number" and Rebirths.Value - cost >= State.KeepRebirths then
                    if invoke(Remotes.Ultimates, "upgradeUltimate", name) == true then
                        done = done + 1
                        Runtime.Upgrades = Runtime.Upgrades + 1
                        notify("Ultimate", name .. " -> level " .. (level + 1), 2.5)
                        task.wait(0.4)
                    end
                end
            end
        end
    end
    return done
end

local function petPerkStat(pet, name)
    local perks = pet:FindFirstChild("perksFolder")
    local v = perks and perks:FindFirstChild(name)
    if v then return v.Value end
    local direct = pet:FindFirstChild(name)
    return direct and direct.Value or 0
end

local function allPetsCustom(priorityKey)
    local list = {}
    local folder = LocalPlayer:FindFirstChild("petsFolder")
    if not folder then return list end
    local weights = PET_PRIORITY[priorityKey or State.PetPriority] or PET_PRIORITY["Farm speed"]
    local statKey = "strength"
    if State.FarmMode == "Agility" then statKey = "agility"
    elseif State.FarmMode == "Durability" then statKey = "durability" end
    for _, rarityFolder in ipairs(folder:GetChildren()) do
        for _, pet in ipairs(rarityFolder:GetChildren()) do
            local levelValue = pet:FindFirstChild("level")
            table.insert(list, {
                pet = pet,
                rarity = rarityFolder.Name,
                perk = weights[pet.Name] or 0,
                keep = PERK_PETS[pet.Name] ~= nil,
                rank = RARITY_ORDER[rarityFolder.Name] or 0,
                power = petPerkStat(pet, statKey),
                level = levelValue and levelValue.Value or 1,
            })
        end
    end
    table.sort(list, function(a, b)
        if a.perk ~= b.perk then return a.perk > b.perk end
        if a.power ~= b.power then return a.power > b.power end
        if a.rank ~= b.rank then return a.rank > b.rank end
        return a.level > b.level
    end)
    return list
end

local function equippedSet()
    local set, slots = {}, 0
    local folder = LocalPlayer:FindFirstChild("equippedPets")
    if not folder then return set, 0 end
    for _, slot in ipairs(folder:GetChildren()) do
        slots = slots + 1
        local ref = slot:FindFirstChild("petReference")
        if ref and ref.Value then set[ref.Value] = true end
    end
    return set, slots
end

local function equipBestPetsCustom(priorityKey)
    if not Remotes.EquipPet then return end
    local list = allPetsCustom(priorityKey)
    if #list == 0 then return end

    local allowed = {}
    for _, entry in ipairs(list) do
        if gf("checkIfPlayerHasEnoughStatsForPet", LocalPlayer, entry.pet) ~= false then
            allowed[#allowed + 1] = entry.pet
        end
    end
    if #allowed == 0 then return end

    local equipped, slots = equippedSet()
    if slots == 0 then return end

    for _, pet in ipairs(allowed) do
        equipped = equippedSet()
        local filled = 0
        for _ in pairs(equipped) do filled = filled + 1 end
        if filled >= slots then break end
        if not equipped[pet] then
            fire(Remotes.EquipPet, "equipPet", pet)
            task.wait(0.2)
        end
    end
end

local function doRebirth()
    if not Remotes.Rebirth or not Strength then return false end
    if State.AutoRebirthPetSwap then pcall(function() equipBestPetsCustom("Rebirths") end) end
    if isMounted() then leaveMachine() end
    local beforeStrength = Strength.Value
    local res = invoke(Remotes.Rebirth, "rebirthRequest")
    if res == true then
        Runtime.RebirthCount = Runtime.RebirthCount + 1
        notify("Rebirth", "Rebirth " .. tostring(Rebirths and Rebirths.Value or "+1") .. " Complete!", 3)
    end
    local t = os.clock()
    while res == true and os.clock() - t < 8 do
        beat()
        if Strength.Value < beforeStrength and alive() and char:GetAttribute("IsRebirthing") ~= true then break end
        task.wait(0.03)
    end
    Runtime.Blacklist = {}
    if State.AutoUltimates then pcall(upgradeUltimates) end
    if State.AutoRebirthPetSwap then pcall(function() equipBestPetsCustom("Farm speed") end) end
    return res == true
end

local function rebirthChain(maxCount, spendBoosts)
    maxCount = maxCount or 50
    local gained = 0
    for _ = 1, maxCount do
        if not running() then break end
        if not canRebirth() and spendBoosts then
            local before = Strength and Strength.Value or 0
            Runtime.Status = "Auto pushing boost for rebirth"
            useBoosts(true)
            if Strength and Strength.Value <= before then break end
        end
        if not canRebirth() then break end
        Runtime.Status = "Rebirthing (" .. (gained + 1) .. ")"
        if not doRebirth() then break end
        gained = gained + 1
        task.wait()
    end
    if gained > 1 then notify("Rebirth Chain", gained .. " rebirths chained!", 4) end
    return gained
end

local function requestAutoRebirth()
    if not running() or not State.AutoRebirth or Runtime.RebirthBusy or not Strength then return false end
    local target = rebirthTarget()
    if State.AutoRebirthBoostPush and Strength.Value < target and Strength.Value >= target * 0.85 then
        useBoosts(true)
    end
    if not canRebirth() then return false end
    
    Runtime.RebirthBusy = true
    Runtime.FarmToken = Runtime.FarmToken + 1
    spawnTask(function()
        local gained = rebirthChain(50, false)
        Runtime.RebirthBusy = false
        if State.FarmMode ~= "Off" and restartFarm then restartFarm() end
    end)
    return true
end

local function resolveMode()
    if State.AutoRebirth and State.SmartRebirthFulfillment and Strength and Strength.Value < rebirthTarget() then
        return "Strength"
    end
    if State.FarmMode ~= "Rotate" then return State.FarmMode end
    local order = {"Strength", "Agility", "Durability"}
    local span = math.max(State.RotateSeconds, 15)
    return order[(math.floor(os.clock() / span) % #order) + 1]
end

local GAIN_KEY = {Strength = "strengthGain", Agility = "agilityGain", Durability = "durabilityGain"}

local function bestTreadmill()
    local best
    if not treadmillsFolder then return nil end
    for _, t in ipairs(treadmillsFolder:GetChildren()) do
        local gain = t:FindFirstChild("agilityAmount")
        local part = t:FindFirstChild("treadmillPart")
        if gain and part and not blacklisted(t) and meetsRequirements(t) then
            if not best or gain.Value > best.gain then
                best = {model = t, part = part, gain = gain.Value}
            end
        end
    end
    return best
end

local function bestRock()
    local best
    if not machinesFolder or not Durability then return nil end
    for _, m in ipairs(machinesFolder:GetChildren()) do
        local rock = m:FindFirstChild("Rock")
        local gain = m:FindFirstChild("durabilityGain")
        local need = m:FindFirstChild("neededDurability")
        if rock and gain and not blacklisted(m) and Durability.Value >= (need and need.Value or 0) then
            if not best or gain.Value > best.gain then
                best = {model = m, rock = rock, gain = gain.Value, estimate = gain.Value / 1.4}
            end
        end
    end
    return best
end

local function farmTreadmill(token, mode)
    local entry = bestTreadmill()
    if not entry then return false end
    leaveMachine()
    local part = entry.part
    Runtime.Target = entry.model.Name .. " treadmill (+" .. entry.gain .. ")"
    Runtime.Status = "Running on treadmill"
    local nextScan = os.clock() + 15
    while farming(token) and resolveMode() == mode do
        if not alive() then return true end
        Runtime.Heartbeat = os.clock()
        anchorAt(part.CFrame * CFrame.new(0, part.Size.Y / 2 + hum.HipHeight + hrp.Size.Y / 2 + 0.4, 0))
        if os.clock() > nextScan then
            nextScan = os.clock() + 15
            local better = bestTreadmill()
            if better and better.model ~= entry.model and better.gain > entry.gain then return true end
        end
        task.wait(0.1)
    end
    return true
end

local function farmRock(token, mode)
    local entry = bestRock()
    if not entry then return false end
    leaveMachine()
    local rock = entry.rock
    local reach = math.max(rock.Size.X, rock.Size.Z) / 2 - 4
    local stand = CFrame.new(rock.Position - Vector3.new(0, 0, reach), rock.Position)
    equipTool("Punch")
    Runtime.Target = entry.model.Name .. " (+" .. entry.gain .. " per punch)"
    Runtime.Status = "Punching"
    local flip = false
    while farming(token) and resolveMode() == mode do
        if not alive() then return true end
        Runtime.Heartbeat = os.clock()
        anchorAt(stand)
        flip = not flip
        if muscleEvent then muscleEvent:FireServer("punch", flip and "rightHand" or "leftHand") end
        Runtime.Reps = Runtime.Reps + 1
        task.wait(0.12)
    end
    return true
end

local function farmStat(token, mode)
    if not farming(token) then return true end
    local gainKey = GAIN_KEY[mode]
    local source = pickSource(gainKey, token)
    if not farming(token) then return true end

    if mode == "Agility" then
        local treadmill = bestTreadmill()
        local treadRate = treadmill and (treadmill.gain / 3.3) or 0
        local sourceRate = source and (Runtime.Rates[source.key] or source.estimate) or 0
        if treadmill and treadRate > sourceRate and State.SourcePreference ~= "Tools only" then
            return farmTreadmill(token, mode)
        end
    end

    if mode == "Durability" and State.SourcePreference == "Rocks only" then
        return farmRock(token, mode)
    end

    if not source then
        if mode == "Durability" and farmRock(token, mode) then return true end
        Runtime.Status = "No usable source for " .. mode
        Runtime.Target = "none"
        task.wait(2)
        return true
    end

    if not farming(token) then return true end
    if not engage(source) then
        Runtime.Status = "Locked, trying next: " .. source.label
        Runtime.Target = "switching"
        task.wait(0.2)
        return true
    end

    local rate = Runtime.Rates[source.key]
    Runtime.Target = source.label .. (rate and (" ~ " .. string.format("%.0f", rate) .. "/s") or "")
    Runtime.Status = (source.kind == "machine") and "Lifting" or "Exercising"

    local chore = os.clock() + 90
    while farming(token) and resolveMode() == mode do
        if not alive() then return true end
        if not sourceHealthy(source) then return true end
        Runtime.Heartbeat = os.clock()
        repOnce(source)
        if requestAutoRebirth() then return true end
        if os.clock() > chore then return true end
        task.wait(State.RepDelay)
    end
    return true
end

local function teleportToKingsGym()
    if not alive() or not kingsGymPart then return false end
    if (hrp.Position - kingsGymPart.Position).Magnitude < 500 then return true end
    if isMounted() then leaveMachine() end
    for _ = 1, 3 do
        if not alive() then return false end
        anchorAt(kingsGymPart.CFrame * CFrame.new(0, 6, 0))
        task.wait(0.05)
    end
    return (hrp.Position - kingsGymPart.Position).Magnitude < 500
end

local function startFarm()
    Runtime.FarmToken = Runtime.FarmToken + 1
    local token = Runtime.FarmToken
    Runtime.Heartbeat = os.clock()
    spawnTask(function()
        local nextBoost, nextUlt = 0, 0
        while farming(token) do
            elevate()
            Runtime.Heartbeat = os.clock()
            if State.AutoBoosts and os.clock() > nextBoost then
                nextBoost = os.clock() + 45
                pcall(useBoosts, false)
            end
            if State.AutoUltimates and os.clock() > nextUlt then
                nextUlt = os.clock() + 60
                pcall(upgradeUltimates)
            end
            local mode = resolveMode()
            if not alive() then
                Runtime.Status = "Waiting for character"
                task.wait(1)
            elseif GAIN_KEY[mode] then
                farmStat(token, mode)
            else
                task.wait(0.5)
            end
            task.wait(0.05)
        end
        Runtime.Exited = token
        if token == Runtime.FarmToken then
            Runtime.Status = "Idle"
            Runtime.Target = "none"
            pcall(leaveMachine)
        end
    end)
end

restartFarm = startFarm

local function stopFarm(reason)
    local old = Runtime.FarmToken
    State.FarmMode = "Off"
    Runtime.FarmToken = old + 1
    Runtime.Target = "none"
    Runtime.Status = "Stopping"
    spawnTask(function()
        local t = os.clock()
        while Runtime.Exited ~= old and os.clock() - t < 6 do task.wait(0.1) end
        leaveMachine()
        local t2 = os.clock()
        while isMounted() and os.clock() - t2 < 3 do
            leaveMachine()
            task.wait(0.2)
        end
        if State.FarmMode == "Off" then
            Runtime.Status = reason or "Idle"
            Runtime.Target = "none"
        end
    end)
end

local function claimChests()
    if not Remotes.Chest then return end
    for _, name in ipairs(CHEST_NAMES) do
        if invoke(Remotes.Chest, name) == true then
            Runtime.Claimed = Runtime.Claimed + 1
            notify("Chest", name .. " claimed", 2)
        end
        task.wait(0.25)
    end
end

local function claimGroup()
    if not Remotes.Group then return end
    if invoke(Remotes.Group, "groupRewards") == true then
        Runtime.Claimed = Runtime.Claimed + 1
        notify("Group Reward", "Group reward claimed", 2.5)
    end
end

local function claimGifts()
    if not Remotes.Gift then return end
    for n = 1, 8 do
        if invoke(Remotes.Gift, "claimGift", n) == true then
            Runtime.Claimed = Runtime.Claimed + 1
            notify("Free Gift", "Gift " .. n .. " claimed", 2)
        end
        task.wait(0.25)
    end
end

local function spinWheel()
    if not Remotes.Wheel or not fortuneWheel then return end
    local spins = dataIndex("freeWheelSpins")
    if type(spins) ~= "number" then return end
    while spins > 0 do
        local res = invoke(Remotes.Wheel, "openFortuneWheel", fortuneWheel)
        if type(res) ~= "table" then break end
        Runtime.Claimed = Runtime.Claimed + 1
        notify("Fortune Wheel", tostring(res.name) .. " (" .. tostring(res.rarity) .. ")", 2.5)
        spins = spins - 1
        task.wait(1)
    end
end

local function collectQuests()
    if not Remotes.Quests then return end
    local root = LocalPlayer:FindFirstChild("Quests")
    if not root then return end

    for _, quest in ipairs(root:GetDescendants()) do
        if quest:IsA("Folder") and quest:FindFirstChild("requirements") then
            if gf("checkForCompleteQuest", quest) == true then
                fire(Remotes.Quests, "collectQuest", quest)
                Runtime.Claimed = Runtime.Claimed + 1
                notify("Quest", quest.Name .. " collected", 2)
                task.wait(0.4)
            end
        end
    end
end

local questAcceptCooldown = {}

local function nextNpcQuest(questLine)
    local root = LocalPlayer:FindFirstChild("Quests")
    local story = root and root:FindFirstChild("Story Quests")
    local completed = root and root:FindFirstChild("completedQuests")
    local catalogQuests = questLine and questLine:FindFirstChild("Quests")
    if not root or not story or not completed or not catalogQuests then return nil end

    if story:FindFirstChild(questLine.Name) then return nil end

    local finished = completed:FindFirstChild(questLine.Name)
    local numbers = {}
    for _, quest in ipairs(catalogQuests:GetChildren()) do
        local number = tonumber(quest.Name)
        if number then table.insert(numbers, number) end
    end
    table.sort(numbers)

    if not finished then return catalogQuests:FindFirstChild("1") end
    for _, number in ipairs(numbers) do
        local name = tostring(number)
        if not finished:FindFirstChild(name) then
            return catalogQuests:FindFirstChild(name)
        end
    end
    return nil
end

local function acceptNpcQuests()
    if not questsNpcs or not Remotes.Quests then return end
    for _, npc in ipairs(questsNpcs:GetChildren()) do
        local link = npc:FindFirstChild("questLink")
        local questLine = link and link:IsA("ObjectValue") and link.Value or nil
        local required = questLine and questLine:FindFirstChild("Rebirths")
        if questLine and (not required or (Rebirths and required.Value <= Rebirths.Value)) then
            local quest = nextNpcQuest(questLine)
            local lastRequest = quest and questAcceptCooldown[quest] or 0
            if quest and os.clock() - lastRequest >= 8 then
                questAcceptCooldown[quest] = os.clock()
                local action = quest.Parent and quest.Parent.Parent and quest.Parent.Parent.Name == "Industrial Daily"
                    and "createNewIndustrialDaily" or "createNewStoryQuest"
                fire(Remotes.Quests, action, quest)
                notify("Quest", npc.Name .. " quest accepted", 2)
                task.wait(0.4)
            end
        end
    end
end

local function updateNpcQuests()
    collectQuests()
    task.wait(0.6)
    acceptNpcQuests()
end

local function crystalCost(name)
    if not crystalPrices then return nil end
    local entry = crystalPrices:FindFirstChild(name)
    if not entry then return nil end
    local price = entry:FindFirstChild("price")
    local kind = entry:FindFirstChild("priceType")
    return price and price.Value or 0, kind and kind.Value or "Gems"
end

local function currencyValue(kind)
    if kind == "Tokens" and Tokens then return Tokens.Value end
    if Gems then return Gems.Value end
    return 0
end

local function hatchOnce(name)
    if not Remotes.Crystal then return false, "no remote" end
    local price, kind = crystalCost(name)
    if not price then return false, "unknown crystal" end
    if currencyValue(kind) - price < State.KeepCurrency then return false, "saving " .. kind end
    local pet, rarity = invoke(Remotes.Crystal, "openCrystal", name)
    if type(pet) == "string" then
        Runtime.Hatched = Runtime.Hatched + 1
        return true, pet .. " (" .. tostring(rarity) .. ")"
    end
    return false, "denied"
end

local function unevolvedPetCounts()
    local counts = {}
    local folder = LocalPlayer:FindFirstChild("petsFolder")
    if not folder then return counts end
    for _, rarityFolder in ipairs(folder:GetChildren()) do
        for _, pet in ipairs(rarityFolder:GetChildren()) do
            if pet:IsA("StringValue") and pet:FindFirstChild("evolved") == nil then
                counts[pet.Name] = (counts[pet.Name] or 0) + 1
            end
        end
    end
    return counts
end

local function evolveReadyPets()
    if not Remotes.PetEvolve then return 0 end
    local evolved = 0
    local counts = unevolvedPetCounts()
    local names = {}
    for name, count in pairs(counts) do
        if count >= 5 then names[#names + 1] = name end
    end
    table.sort(names)

    for _, name in ipairs(names) do
        local count = counts[name] or 0
        while count >= 5 and running() do
            fire(Remotes.PetEvolve, "evolvePet", name)
            task.wait(0.8)
            local after = unevolvedPetCounts()[name] or 0
            if after >= count then break end
            evolved = evolved + 1
            Runtime.Evolved = Runtime.Evolved + 1
            count = after
        end
    end
    return evolved
end

-- Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    if not State.AntiAFK then return end
    pcall(function()
        if VirtualUser then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end)

-- Speed Override Listener
local function UpdateCharacterSpeed()
    pcall(function()
        if alive() then
            if State.WalkSpeedBoost then
                hum.WalkSpeed = CustomSpeedValue
            else
                hum.WalkSpeed = 16
            end
        end
    end)
end

-- Infinite Jump Listener
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and alive() then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

-- ====================================================
-- OFFICIAL JUNEJO BORDERLESS UI (280x285px)
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_MuscleLegends"
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
TitleLabel.Text = "MUSCLE LEGENDS"
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
    State.Running = false
    State.FarmMode = "Off"
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

-- Helper Function: Add Dynamic Status Banner
local function AddStatusRow(initialText)
    local StatusRow = Instance.new("Frame")
    StatusRow.Size = UDim2.new(1, -6, 0, 20)
    StatusRow.BackgroundTransparency = 1
    StatusRow.Parent = ContentFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 1, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = initialText
    StatusLabel.TextColor3 = Color3.fromRGB(136, 136, 153)
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd
    StatusLabel.Parent = StatusRow

    return {
        SetText = function(txt) StatusLabel.Text = tostring(txt) end
    }
end

-- Helper Function: Add Strictly Flat & Borderless Toggle Row
local function AddToggleRow(text, configKey, callback, defaultVal)
    if defaultVal ~= nil then State[configKey] = defaultVal end
    
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
    CheckMark.BackgroundTransparency = State[configKey] and 0 or 1
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
        State[configKey] = not State[configKey]
        CheckMark.BackgroundTransparency = State[configKey] and 0 or 1
        if callback then callback(State[configKey]) end
    end)

    return {
        Set = function(val)
            State[configKey] = val
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
        if callback then spawnTask(callback) end
    end)
end

-- Helper Function: Add Selector Row (Pill Cycler)
local function AddSelectorRow(text, options, defaultVal, callback)
    local items = options or {}
    if #items == 0 then items = {"None"} end
    local currentIdx = 1
    for i, opt in ipairs(items) do
        if opt == defaultVal then currentIdx = i break end
    end

    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.48, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local SelectorBtn = Instance.new("TextButton")
    SelectorBtn.Size = UDim2.new(0.50, 0, 0, 20)
    SelectorBtn.Position = UDim2.new(0.50, 0, 0.5, -10)
    SelectorBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    SelectorBtn.BorderSizePixel = 0
    SelectorBtn.Text = tostring(items[currentIdx])
    SelectorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelectorBtn.TextSize = 10
    SelectorBtn.Font = Enum.Font.GothamBold
    SelectorBtn.TextTruncate = Enum.TextTruncate.AtEnd
    SelectorBtn.Parent = Row

    local SelCorner = Instance.new("UICorner")
    SelCorner.CornerRadius = UDim.new(0, 4)
    SelCorner.Parent = SelectorBtn

    local SelStroke = Instance.new("UIStroke")
    SelStroke.Color = Color3.fromRGB(45, 45, 55)
    SelStroke.Thickness = 1.2
    SelStroke.Parent = SelectorBtn

    local function selectIdx(idx)
        currentIdx = idx
        local selected = items[currentIdx]
        SelectorBtn.Text = tostring(selected)
        if callback then spawnTask(function() callback(selected) end) end
    end

    SelectorBtn.MouseButton1Click:Connect(function()
        currentIdx = currentIdx + 1
        if currentIdx > #items then currentIdx = 1 end
        selectIdx(currentIdx)
    end)

    return {
        SetValue = function(val)
            for i, opt in ipairs(items) do
                if opt == val then
                    selectIdx(i)
                    break
                end
            end
        end
    }
end

-- ====================================================
-- UI CONTROLS REGISTRATION
-- ====================================================

-- Live Status Row
local statusBanner = AddStatusRow("Next Rebirth: Calculating...")
local liveGainsBanner = AddStatusRow("Str: - | Rebirths: -")

-- 1. SMART AUTO REBIRTH
AddSectionHeader("Smart Auto Rebirth")

AddToggleRow("Smart Auto Rebirth", "AutoRebirth", function(state)
    if state then
        notify("Auto Rebirth", "Smart Requirement Fulfillment Active!", 3)
        requestAutoRebirth()
    else
        notify("Auto Rebirth", "Auto Rebirth Paused.", 2)
    end
end)

AddToggleRow("Auto Boost Push for Rebirth", "AutoRebirthBoostPush", function(state) end, true)
AddToggleRow("Auto Swap Rebirth Perk Pets", "AutoRebirthPetSwap", function(state) end, true)
AddToggleRow("Auto Upgrade Ultimates", "AutoUltimates", function(state) end, true)

AddActionRow("Rebirth Now (Instant Chain)", "Chain", function()
    local wasFarming = State.FarmMode
    Runtime.FarmToken = Runtime.FarmToken + 1
    local gained = rebirthChain(50, true)
    notify("Rebirth Chain", gained > 0 and (gained .. " rebirth(s) completed!") or "Not enough strength yet", 3)
    if wasFarming ~= "Off" then startFarm() end
end)

-- 2. FAST AUTO FARM
AddSectionHeader("Fast Auto Farm")

local farmModeSelector = AddSelectorRow("Stat Farm", {"Off", "Strength", "Agility", "Durability", "Rotate"}, "Off", function(mode)
    if mode == "Off" then
        stopFarm("Stopped by user")
        notify("Auto Farm", "Farm Stopped.", 2)
    else
        State.FarmMode = mode
        startFarm()
        notify("Auto Farm", "Farming " .. mode .. " Started!", 2.5)
    end
end)

AddSelectorRow("Strength Source", {"Tools (Best for Rebirth)", "Auto (fastest)", "Machines"}, "Tools (Best for Rebirth)", function(source)
    State.StrengthSource = source
    Runtime.Rates = {}
    Runtime.Blacklist = {}
    if State.FarmMode == "Strength" then startFarm() end
end)

AddToggleRow("King's Gym Tool Farm", "AlwaysKingsGym", function(state)
    if state then spawnTask(teleportToKingsGym) end
end, true)

AddActionRow("Stop Farm / Free Character", "Stop", function()
    farmModeSelector.SetValue("Off")
    stopFarm("Freed character")
end)

-- 3. BOOSTS & CONSUMABLES
AddSectionHeader("Boosts & Consumables")

AddToggleRow("Auto Use Timed Boosts", "AutoBoosts", function(state) end)
AddActionRow("Consume All Shakes/Bars", "Use", function()
    useBoosts(true)
end)

-- 4. REWARDS & CHESTS
AddSectionHeader("Rewards & Chests")

AddToggleRow("Auto Chests (6h Timers)", "AutoChests", function(state) end)
AddToggleRow("Auto Group Rewards", "AutoGroup", function(state) end)
AddToggleRow("Auto Free Gifts", "AutoGifts", function(state) end)
AddToggleRow("Auto Fortune Wheel", "AutoWheel", function(state) end)
AddToggleRow("Auto Story/Daily Quests", "AutoQuests", function(state)
    if state then spawnTask(updateNpcQuests) end
end)

AddActionRow("Claim All Rewards Now", "Claim", function()
    pcall(claimChests)
    pcall(claimGroup)
    pcall(claimGifts)
    pcall(spinWheel)
    pcall(updateNpcQuests)
    notify("Rewards", "All reward claims executed!", 2.5)
end)

-- 5. CRYSTALS & PETS
AddSectionHeader("Crystals & Pets")

local crystalNames = {}
if crystalPrices then
    for _, c in ipairs(crystalPrices:GetChildren()) do table.insert(crystalNames, c.Name) end
    table.sort(crystalNames)
end
if #crystalNames == 0 then crystalNames = {"Blue Crystal"} end

AddSelectorRow("Select Crystal", crystalNames, "Blue Crystal", function(cName)
    State.HatchCrystal = cName
end)

AddToggleRow("Auto Hatch Crystal", "AutoHatch", function(state) end)

AddActionRow("Hatch Crystal x10", "Hatch", function()
    local got = 0
    for _ = 1, 10 do
        if hatchOnce(State.HatchCrystal) then got = got + 1 else break end
        task.wait(0.3)
    end
    notify("Hatch", got .. " pets hatched!", 2.5)
end)

AddToggleRow("Auto Equip Best Pets", "AutoEquipPets", function(state) end)
AddActionRow("Equip Best Pets Now", "Equip", function()
    equipBestPetsCustom()
end)

AddToggleRow("Auto Evolve Ready (x5)", "AutoEvolvePets", function(state) end)
AddActionRow("Evolve All Ready Pets", "Evolve", function()
    local n = evolveReadyPets()
    notify("Evolution", n .. " pet(s) evolved!", 2.5)
end)

-- 6. MOVEMENT & UTILITIES
AddSectionHeader("Movement & Utilities")

-- Integrated Speed Row
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
SpeedCheckMark.BackgroundTransparency = State.WalkSpeedBoost and 0 or 1
SpeedCheckMark.BorderSizePixel = 0
SpeedCheckMark.Parent = SpeedCheckBox

local MarkCorner = Instance.new("UICorner")
MarkCorner.CornerRadius = UDim.new(0, 2)
MarkCorner.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    State.WalkSpeedBoost = not State.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = State.WalkSpeedBoost and 0 or 1
    UpdateCharacterSpeed()
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
    UpdateCharacterSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

AddToggleRow("Infinite Jump", "InfiniteJump", function(state) end)

local areaParts = areaTeleportParts
local areaNames = {}
if areaParts then
    for _, p in ipairs(areaParts:GetChildren()) do table.insert(areaNames, p.Name) end
    table.sort(areaNames)
end
if #areaNames == 0 then areaNames = {"none"} end
local selectedArea = areaNames[1]

AddSelectorRow("Area Teleport", areaNames, selectedArea, function(pad) selectedArea = pad end)
AddActionRow("Teleport To Area", "TP", function()
    if not areaParts then return end
    local part = areaParts:FindFirstChild(selectedArea)
    if not part or not alive() then return end
    Runtime.FarmToken = Runtime.FarmToken + 1
    leaveMachine()
    for _ = 1, 10 do anchorAt(part.CFrame * CFrame.new(0, 6, 0)) task.wait(0.1) end
    if State.FarmMode ~= "Off" then startFarm() end
end)

AddActionRow("Rejoin Server", "Rejoin", function()
    if Remotes.Rejoin then pcall(function() Remotes.Rejoin:FireServer() end) end
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
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

-- ====================================================
-- BACKGROUND ASYNC LOOPS (NON-BLOCKING)
-- ====================================================

-- Live Stats Loop
spawnTask(function()
    while running() do
        elevate()
        local targetReq = rebirthTarget()
        local curStr = Strength and Strength.Value or 0
        local pct = math.clamp(curStr / (targetReq > 0 and targetReq or 1) * 100, 0, 100)
        
        statusBanner.SetText(("Next Rebirth: %s / %s (%.0f%%) | %s"):format(
            short(curStr),
            short(targetReq),
            pct,
            Runtime.Status
        ))

        liveGainsBanner.SetText(("Str: %s | Gems: %s | Rebirths: %s"):format(
            short(curStr),
            short(Gems and Gems.Value or 0),
            short(Rebirths and Rebirths.Value or 0)
        ))

        task.wait(0.5)
    end
end)

-- Auto Rebirth Listener & Poller
if Strength then
    Strength.Changed:Connect(function()
        if running() and State.AutoRebirth then requestAutoRebirth() end
    end)
end

spawnTask(function()
    while running() do
        if State.AutoRebirth then requestAutoRebirth() end
        task.wait(0.25)
    end
end)

-- Automatic Chests, Gifts, Wheel, Quests Loop
spawnTask(function()
    local nextChest, nextGroup, nextGift, nextWheel, nextQuest = 0, 0, 0, 0, 0
    while running() do
        elevate()
        local now = os.clock()
        if State.AutoChests and now > nextChest then nextChest = now + 90 pcall(claimChests) end
        if State.AutoGroup and now > nextGroup then nextGroup = now + 120 pcall(claimGroup) end
        if State.AutoGifts and now > nextGift then nextGift = now + 60 pcall(claimGifts) end
        if State.AutoWheel and now > nextWheel then nextWheel = now + 60 pcall(spinWheel) end
        if State.AutoQuests and now > nextQuest then nextQuest = now + 10 pcall(updateNpcQuests) end
        task.wait(2)
    end
end)

-- Automatic Crystals & Pets Loop
spawnTask(function()
    local nextPets = 0
    while running() do
        elevate()
        if State.AutoHatch then
            local ok = hatchOnce(State.HatchCrystal)
            task.wait(ok and State.HatchDelay or 3)
        else
            task.wait(1)
        end
        if (State.AutoEquipPets or State.AutoEvolvePets) and os.clock() > nextPets then
            nextPets = os.clock() + 15
            if State.AutoEvolvePets then pcall(evolveReadyPets) end
            if State.AutoEquipPets then pcall(function() equipBestPetsCustom() end) end
        end
    end
end)

-- Watchdog Farm Loop
spawnTask(function()
    while running() do
        elevate()
        if State.FarmMode ~= "Off" and os.clock() - (Runtime.Heartbeat or 0) > 25 then
            Runtime.Status = "Watchdog restart"
            startFarm()
        end
        task.wait(5)
    end
end)

-- King's Gym Tool Teleport Loop
spawnTask(function()
    while running() do
        elevate()
        if State.AlwaysKingsGym
            and State.FarmMode == "Strength"
            and (State.StrengthSource == "Tools (Hotbar)" or State.StrengthSource == "Tools (Best for Rebirth)")
        then
            pcall(teleportToKingsGym)
        end
        task.wait(1)
    end
end)

notify("Muscle Legends", "Junejo Ultra Script Hub Loaded!", 3)
