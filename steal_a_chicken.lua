-- =================================================================
-- JUNEJO ULTRA SCRIPT HUB - STEAL A CHICKEN (OFFICIAL SCRIPT)
-- Target Game: Steal a Chicken (Place ID: 76503495566299)
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- UI Standard: UI 1 (Official Ultra Script Hub Classic Matte Dark)
-- Universal Mobile (Delta / Codex / Fluxus) & PC Compatible
-- =================================================================

local GameName = "Steal a Chicken"

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera

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
    for _, name in ipairs({"StealAChickenMobileUI", "JunejoStealAChickenUI", "JunejoUltraScriptHub_StealAChicken"}) do
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

-- Anti-AFK Engine
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)
LocalPlayer.Idled:Connect(function()
    if VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- Character Helper Functions
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function getHum()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- =================================================================
-- REMOTE RESOLVER (Auto-discovers exact Remotes)
-- =================================================================
local Remotes = {}

local function safeCallRemote(rem, ...)
    if not rem then return nil end
    local res = nil
    pcall(function(...)
        if rem:IsA("RemoteEvent") or rem:IsA("UnreliableRemoteEvent") then
            rem:FireServer(...)
        elseif rem:IsA("RemoteFunction") then
            res = rem:InvokeServer(...)
        end
    end, ...)
    return res
end

local function scanRemotes()
    for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
        if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") or desc:IsA("UnreliableRemoteEvent") then
            local n = desc.Name
            if n == "claimAllEggs" then
                Remotes.ClaimAllEggs = desc
            elseif n == "claimEgg" then
                Remotes.ClaimEgg = desc
            elseif n == "sellAllItems" then
                Remotes.SellAllItems = desc
            elseif n == "sellItem" then
                Remotes.SellItem = desc
            elseif n == "dropChicken" then
                Remotes.DropChicken = desc
            elseif n == "teleportToBase" then
                Remotes.TeleportToBase = desc
            elseif n == "stealEgg" then
                Remotes.StealEgg = desc
            end
        end
    end
end
scanRemotes()
ReplicatedStorage.DescendantAdded:Connect(scanRemotes)

-- =================================================================
-- BASE DETECTOR & TELEPORT HELPERS (BULLETPROOF)
-- =================================================================
local cachedMyBase = nil
local SavedBaseCFrame = nil

local function getBasesFolder()
    local direct = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Map") and Workspace.Game.Map:FindFirstChild("Lobby") and Workspace.Game.Map.Lobby:FindFirstChild("Bases")
    if direct then return direct end

    for _, desc in ipairs(Workspace:GetChildren()) do
        if desc.Name == "Game" or desc.Name == "Map" or desc.Name == "Lobby" or desc.Name == "Bases" then
            local b = desc:FindFirstChild("Bases", true)
            if b then return b end
        end
    end
    return Workspace:FindFirstChild("Bases", true)
end

local function getMyBase()
    if cachedMyBase and cachedMyBase.Parent then
        return cachedMyBase
    end
    local basesFolder = getBasesFolder()
    if not basesFolder then return nil end

    local myName = LocalPlayer.Name:lower()
    local myDisplay = LocalPlayer.DisplayName:lower()

    -- 1. Check Billboard Title
    for _, base in ipairs(basesFolder:GetChildren()) do
        local billb = base:FindFirstChild("BaseBillb") or base:FindFirstChildWhichIsA("BillboardGui", true)
        if billb then
            for _, desc in ipairs(billb:GetDescendants()) do
                if desc:IsA("TextLabel") then
                    local txt = desc.Text:lower()
                    if txt:find(myName, 1, true) or txt:find(myDisplay, 1, true) then
                        cachedMyBase = base
                        return base
                    end
                end
            end
        end

        local ownerVal = base:FindFirstChild("Owner") or base:FindFirstChild("Player") or base:GetAttribute("Owner") or base:GetAttribute("Player")
        if ownerVal then
            local valStr = tostring(typeof(ownerVal) == "Instance" and ownerVal.Value or ownerVal):lower()
            if valStr:find(myName, 1, true) or valStr:find(myDisplay, 1, true) then
                cachedMyBase = base
                return base
            end
        end
    end

    -- 2. Detect closest base if in Lobby
    local root = getRoot()
    if root then
        local closestBase = nil
        local minDist = 9999
        for _, base in ipairs(basesFolder:GetChildren()) do
            local sp = base:FindFirstChild("Spawn") or base:GetPivot()
            local pos = sp:IsA("BasePart") and sp.Position or sp.Position
            local d = (root.Position - pos).Magnitude
            if d < minDist then
                minDist = d
                closestBase = base
            end
        end
        if minDist < 90 then
            cachedMyBase = closestBase
            return closestBase
        end
    end

    return nil
end

-- Strictly targets player's chicken pen / coop while 100% avoiding the treadmill
local function getBasePenCFrame(base)
    if not base then return nil end

    local stuff = base:FindFirstChild("stuff") or base:FindFirstChild("Stuff")

    -- 1. Identify Treadmill position so we NEVER touch or go near it
    local treadmill = (stuff and (stuff:FindFirstChild("Treadmill") or stuff:FindFirstChild("treadmill"))) or base:FindFirstChild("Treadmill", true)
    local treadmillPos = nil
    if treadmill then
        treadmillPos = treadmill:IsA("BasePart") and treadmill.Position or (treadmill:IsA("Model") and (treadmill.PrimaryPart and treadmill.PrimaryPart.Position or treadmill:GetPivot().Position))
    end

    local function isNearTreadmill(pos)
        if not treadmillPos or not pos then return false end
        return (pos - treadmillPos).Magnitude < 11
    end

    local penNames = {
        "chickenpen", "pen", "coop", "chickencoop", "yard", "chickenyard",
        "barn", "chickenbarn", "chickens", "roost", "enclosure", "chickenzone",
        "dropzone", "depositpen", "deposit"
    }

    -- 2. Search inside stuff for explicit Pen / Coop / Barn models or parts
    if stuff then
        for _, child in ipairs(stuff:GetChildren()) do
            local n = child.Name:lower()
            if not n:find("treadmill") and not n:find("speed") and not n:find("train") and not n:find("open") then
                for _, nameKey in ipairs(penNames) do
                    if n == nameKey or n:find(nameKey, 1, true) then
                        local pos = child:IsA("BasePart") and child.Position or child:GetPivot().Position
                        if not isNearTreadmill(pos) then
                            if child:IsA("BasePart") then return child.CFrame + Vector3.new(0, 2.5, 0) end
                            if child:IsA("Model") and child.PrimaryPart then return child.PrimaryPart.CFrame + Vector3.new(0, 2.5, 0) end
                            local bp = child:FindFirstChildWhichIsA("BasePart")
                            if bp then return bp.CFrame + Vector3.new(0, 2.5, 0) end
                        end
                    end
                end
            end
        end
    end

    -- 3. Search directly in base children
    for _, child in ipairs(base:GetChildren()) do
        local n = child.Name:lower()
        if not n:find("treadmill") and not n:find("speed") and not n:find("train") and not n:find("spawn") and not n:find("billb") and not n:find("open") then
            for _, nameKey in ipairs(penNames) do
                if n == nameKey or n:find(nameKey, 1, true) then
                    local pos = child:IsA("BasePart") and child.Position or child:GetPivot().Position
                    if not isNearTreadmill(pos) then
                        if child:IsA("BasePart") then return child.CFrame + Vector3.new(0, 2.5, 0) end
                        if child:IsA("Model") and child.PrimaryPart then return child.PrimaryPart.CFrame + Vector3.new(0, 2.5, 0) end
                        local bp = child:FindFirstChildWhichIsA("BasePart")
                        if bp then return bp.CFrame + Vector3.new(0, 2.5, 0) end
                    end
                end
            end
        end
    end

    -- 4. Check for any ProximityPrompt inside base for dropping chickens
    for _, prompt in ipairs(base:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
            if (act:find("drop") or act:find("deposit") or act:find("place") or act:find("chicken") or act:find("pen") or act:find("store")) and not act:find("treadmill") and not act:find("speed") and not act:find("train") then
                local pPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or prompt.Parent:GetPivot().Position
                if not isNearTreadmill(pPos) then
                    return prompt.Parent:IsA("BasePart") and (prompt.Parent.CFrame + Vector3.new(0, 2.5, 0)) or (prompt.Parent:GetPivot() + Vector3.new(0, 2.5, 0))
                end
            end
        end
    end

    -- 5. Search descendants for parts matching pen keywords (excluding treadmill)
    for _, desc in ipairs(base:GetDescendants()) do
        if desc:IsA("BasePart") then
            local n = desc.Name:lower()
            if n ~= "open" and not n:find("treadmill") and not n:find("train") and not n:find("speed") and not n:find("spawn") and not n:find("billb") then
                if n:find("pen") or n:find("coop") or n:find("yard") or n:find("barn") or n:find("chicken") or n:find("drop") then
                    if not isNearTreadmill(desc.Position) then
                        return desc.CFrame + Vector3.new(0, 2.5, 0)
                    end
                end
            end
        end
    end

    -- 6. Offset into base pen away from the Treadmill
    local sp = base:FindFirstChild("Spawn") or base:FindFirstChildWhichIsA("SpawnLocation")
    if sp and sp:IsA("BasePart") then
        if treadmillPos then
            local toTreadmill = (treadmillPos - sp.Position)
            local awayFromTreadmill = Vector3.new(-toTreadmill.X, 0, -toTreadmill.Z)
            if awayFromTreadmill.Magnitude > 1 then
                local targetPos = sp.Position + awayFromTreadmill.Unit * 14 + Vector3.new(0, 2.5, 0)
                if not isNearTreadmill(targetPos) then
                    return CFrame.new(targetPos, sp.Position)
                end
            end
        end

        local cand1 = sp.CFrame * CFrame.new(-12, 2.5, 4)
        if not isNearTreadmill(cand1.Position) then
            return cand1
        end
        local cand2 = sp.CFrame * CFrame.new(12, 2.5, 4)
        if not isNearTreadmill(cand2.Position) then
            return cand2
        end
    end

    -- 7. Fallback to base pivot if not near treadmill
    local piv = base:GetPivot() + Vector3.new(0, 2.5, 0)
    if not isNearTreadmill(piv.Position) then
        return piv
    end

    return nil
end

-- Teleport directly to Base Pen without invoking game reset button or treadmill
local function teleportToMyBase()
    local root = getRoot()
    if not root then return end

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    local base = getMyBase()
    if base then
        local penCF = getBasePenCFrame(base)
        if penCF then
            root.CFrame = penCF
            return
        end
        local sp = base:FindFirstChild("Spawn") or base:FindFirstChildWhichIsA("SpawnLocation")
        if sp and sp:IsA("BasePart") then
            root.CFrame = sp.CFrame + Vector3.new(0, 2.5, 0)
            return
        end
    end

    if SavedBaseCFrame then
        root.CFrame = SavedBaseCFrame + Vector3.new(0, 2, 0)
        return
    end
end

task.spawn(function()
    task.wait(0.6)
    local base = getMyBase()
    if base then
        local penCF = getBasePenCFrame(base)
        if penCF then
            SavedBaseCFrame = penCF
            return
        end
        local sp = base:FindFirstChild("Spawn") or base:FindFirstChildWhichIsA("SpawnLocation")
        if sp and sp:IsA("BasePart") then
            SavedBaseCFrame = sp.CFrame + Vector3.new(0, 2.5, 0)
            return
        end
    end
    local root = getRoot()
    if root and not SavedBaseCFrame then
        SavedBaseCFrame = root.CFrame
    end
end)

-- =================================================================
-- FEATURE STATES & SETTINGS
-- =================================================================
local AvailableZones = {
    "All Zones",
    "Crystal",
    "Cosmic",
    "Abyss",
    "Beach",
    "Volcano",
    "Snow",
    "Desert",
    "Jungle",
    "Lake",
    "Forest"
}
local CurrentZoneIndex = 1

local ZoneTierScores = {
    ["Crystal"] = 1000,
    ["Cosmic"] = 900,
    ["Abyss"] = 800,
    ["Beach"] = 700,
    ["Volcano"] = 600,
    ["Snow"] = 500,
    ["Desert"] = 400,
    ["Jungle"] = 300,
    ["Lake"] = 200,
    ["Forest"] = 100
}

local Toggles = {
    AutoSteal = false,
    AutoCollectEggs = false,
    AutoSellEggs = false,
    AutoTrainSpeed = false,
    RemoveGuards = false,
    FlyMode = false,
    NoClip = false,
    InfiniteJump = false,
    WalkSpeedBoost = false
}

local CustomWalkSpeed = 45
local CustomFlySpeed = 60

local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 99999
        prompt.Enabled = true

        local origHold = prompt.HoldDuration or 0
        prompt.HoldDuration = 0

        if fireproximityprompt then
            pcall(function() fireproximityprompt(prompt) end)
            pcall(function() fireproximityprompt(prompt, 0) end)
        end

        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            task.wait(0.04)
            prompt:InputHoldEnd()
        end

        prompt.HoldDuration = origHold
    end)
end

local function isCarryingChicken()
    local char = LocalPlayer.Character
    if not char then return false, nil end

    for _, child in ipairs(char:GetChildren()) do
        local n = child.Name:lower()
        if not n:find("root") and not n:find("head") and not n:find("torso") and not n:find("arm") and not n:find("leg") and not n:find("animate") and not n:find("humanoid") and not n:find("treadmill") and not n:find("bat") and not n:find("egg") and not n:find("weapon") and not n:find("sword") then
            if n:find("chicken") or n:find("poultry") or n:find("rooster") or n:find("hen") or n:find("bird") then
                return true, child
            end
            if child:IsA("Tool") and not n:find("bat") and not n:find("sword") and not n:find("weapon") and not n:find("egg") then
                return true, child
            end
        end
    end

    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            local n = item.Name:lower()
            if not n:find("bat") and not n:find("weapon") and not n:find("sword") and not n:find("egg") then
                if n:find("chicken") or n:find("poultry") or n:find("rooster") or n:find("hen") or n:find("bird") then
                    return true, item
                end
            end
        end
    end

    for _, attrName in ipairs({"HoldingChicken", "CarryingChicken", "Carrying", "HasChicken", "Holding", "HeldChicken"}) do
        local v = char:GetAttribute(attrName) or LocalPlayer:GetAttribute(attrName)
        if v == true or (type(v) == "string" and (v:lower():find("chicken") or v ~= "")) then
            return true, nil
        end
    end

    for _, vName in ipairs({"HoldingChicken", "CarryingChicken", "Carrying", "HeldChicken", "Holding"}) do
        local valObj = char:FindFirstChild(vName) or LocalPlayer:FindFirstChild(vName)
        if valObj then
            local v = valObj.Value
            if v == true or (type(v) == "string" and v ~= "") or (typeof(v) == "Instance" and v ~= nil) then
                return true, nil
            end
        end
    end

    return false, nil
end

local function dropChickenIntoBase()
    local char = LocalPlayer.Character
    local root = getRoot()
    if not char or not root then return end

    if Remotes.DropChicken then
        safeCallRemote(Remotes.DropChicken)
        safeCallRemote(Remotes.DropChicken, true)
        safeCallRemote(Remotes.DropChicken, 1)
    end

    pcall(function()
        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                local n = rem.Name:lower()
                if n == "dropchicken" or n == "placechicken" or n == "depositchicken" or n == "storechicken" or n == "deliverchicken" then
                    safeCallRemote(rem)
                    safeCallRemote(rem, true)
                end
            end
        end
    end)

    pcall(function()
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local tn = tool.Name:lower()
            if not tn:find("bat") and not tn:find("sword") and not tn:find("weapon") then
                tool:Activate()
            end
        end
    end)

    local myBase = getMyBase()
    if myBase then
        for _, p in ipairs(myBase:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                local act = (p.ActionText .. " " .. p.ObjectText .. " " .. p.Parent.Name):lower()
                if not act:find("treadmill") and not act:find("train") and not act:find("speed") then
                    if act:find("drop") or act:find("place") or act:find("deposit") or act:find("put") or act:find("chicken") or act:find("pen") or act == "" then
                        triggerPrompt(p)
                    end
                end
            end
        end

        for _, part in ipairs(myBase:GetDescendants()) do
            if part:IsA("BasePart") then
                local n = part.Name:lower()
                if (n:find("pen") or n:find("coop") or n:find("fence") or n:find("drop") or n:find("nest") or n:find("yard")) and not n:find("treadmill") and not n:find("train") and not n:find("speed") then
                    if firetouchinterest then
                        pcall(function()
                            firetouchinterest(root, part, 0)
                            task.wait()
                            firetouchinterest(root, part, 1)
                        end)
                    end
                end
            end
        end
    end

    pcall(function()
        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
        if pgui then
            for _, btn in ipairs(pgui:GetDescendants()) do
                if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                    local n = btn.Name:lower()
                    local txt = btn:IsA("TextButton") and btn.Text:lower() or ""
                    if n:find("drop") or txt:find("drop") then
                        if firesignal then firesignal(btn.MouseButton1Click) end
                        if getconnections then
                            for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
                            for _, c in ipairs(getconnections(btn.Activated)) do c:Fire() end
                        end
                    end
                end
            end
        end
    end)
end

-- 1. Auto Steal Logic
local isStealing = false
local NestCooldowns = {}

local function getNestRarityScore(nest, zoneName)
    local score = ZoneTierScores[zoneName] or 50
    local nName = nest.Name:lower()
    if nName:find("insane") then
        score = score + 300
    elseif nName:find("huge") then
        score = score + 120
    elseif nName:find("large") then
        score = score + 70
    elseif nName:find("medium") then
        score = score + 40
    else
        score = score + 10
    end
    return score
end

local function getBestAvailableNests()
    local playZones = (Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Map") and Workspace.Game.Map:FindFirstChild("PlayZones")) or Workspace:FindFirstChild("PlayZones", true)
    if not playZones then return {} end

    local selectedZone = AvailableZones[CurrentZoneIndex]
    local zonesToScan = {}

    if selectedZone == "All Zones" then
        for _, z in ipairs(playZones:GetChildren()) do
            if z:IsA("Folder") or z:IsA("Model") then
                table.insert(zonesToScan, z)
            end
        end
    else
        local targetFolder = playZones:FindFirstChild(selectedZone)
        if targetFolder then
            table.insert(zonesToScan, targetFolder)
        end
    end

    local now = os.clock()
    local nests = {}
    for _, z in ipairs(zonesToScan) do
        local nestsFolder = z:FindFirstChild("Nests") or z
        if nestsFolder then
            for _, nest in ipairs(nestsFolder:GetChildren()) do
                local rootPart = nest:FindFirstChild("Root") or nest:FindFirstChildWhichIsA("BasePart")
                local prompt = (rootPart and rootPart:FindFirstChildOfClass("ProximityPrompt")) or nest:FindFirstChildWhichIsA("ProximityPrompt", true)
                local hasChicken = nest:FindFirstChild("Chicken") ~= nil or (prompt and prompt.Enabled)

                local onCooldown = rootPart and NestCooldowns[rootPart] and (now < NestCooldowns[rootPart])

                if prompt and hasChicken and not onCooldown then
                    table.insert(nests, {
                        Nest = nest,
                        Root = rootPart,
                        Prompt = prompt,
                        Zone = z.Name,
                        Score = getNestRarityScore(nest, z.Name)
                    })
                end
            end
        end

        local insane = z:FindFirstChild("InsaneEgg")
        if insane then
            local rootPart = insane:FindFirstChild("Root") or insane:FindFirstChildWhichIsA("BasePart")
            local prompt = (rootPart and rootPart:FindFirstChildOfClass("ProximityPrompt")) or insane:FindFirstChildWhichIsA("ProximityPrompt", true)
            local onCooldown = rootPart and NestCooldowns[rootPart] and (now < NestCooldowns[rootPart])
            if prompt and prompt.Enabled and not onCooldown then
                table.insert(nests, {
                    Nest = insane,
                    Root = rootPart,
                    Prompt = prompt,
                    Zone = z.Name,
                    Score = (ZoneTierScores[z.Name] or 50) + 350
                })
            end
        end
    end

    table.sort(nests, function(a, b)
        return a.Score > b.Score
    end)

    return nests
end

task.spawn(function()
    while true do
        task.wait(0.12)
        if Toggles.AutoSteal and not isStealing then
            local char = LocalPlayer.Character
            local root = getRoot()
            local hum = getHum()

            if char and root and root.Parent and hum and hum.Health > 0 then
                if isCarryingChicken() then
                    teleportToMyBase()
                    task.wait(0.3)
                    dropChickenIntoBase()
                    task.wait(0.25)
                else
                    local bestNests = getBestAvailableNests()
                    if #bestNests > 0 then
                        isStealing = true
                        for _, data in ipairs(bestNests) do
                            if not Toggles.AutoSteal then break end
                            if data.Root and data.Prompt and data.Prompt.Enabled then
                                root.AssemblyLinearVelocity = Vector3.zero
                                root.AssemblyAngularVelocity = Vector3.zero
                                root.CFrame = data.Root.CFrame + Vector3.new(0, 1.5, 0)
                                task.wait(0.12)

                                pcall(function()
                                    data.Prompt.RequiresLineOfSight = false
                                    data.Prompt.MaxActivationDistance = 99999
                                    data.Prompt.HoldDuration = 0
                                end)

                                local stealStart = os.clock()
                                local gotChicken = false
                                local initialChickenObj = data.Nest:FindFirstChild("Chicken")

                                while os.clock() - stealStart < 0.85 do
                                    if not Toggles.AutoSteal then break end

                                    root.AssemblyLinearVelocity = Vector3.zero
                                    root.CFrame = data.Root.CFrame + Vector3.new(0, 1.5, 0)

                                    triggerPrompt(data.Prompt)

                                    if firetouchinterest and data.Root:IsA("BasePart") then
                                        pcall(function()
                                            firetouchinterest(root, data.Root, 0)
                                            task.wait()
                                            firetouchinterest(root, data.Root, 1)
                                        end)
                                    end

                                    if Remotes.StealEgg then
                                        safeCallRemote(Remotes.StealEgg, data.Zone:lower(), data.Root.Position)
                                    end

                                    if isCarryingChicken() then
                                        gotChicken = true
                                        break
                                    end

                                    if not data.Prompt.Enabled or not data.Prompt.Parent or (initialChickenObj and not initialChickenObj.Parent) then
                                        gotChicken = true
                                        break
                                    end

                                    task.wait(0.06)
                                end

                                task.wait(0.08)

                                if gotChicken or isCarryingChicken() then
                                    teleportToMyBase()
                                    task.wait(0.35)

                                    dropChickenIntoBase()
                                    task.wait(0.25)

                                    if isCarryingChicken() then
                                        dropChickenIntoBase()
                                        task.wait(0.2)
                                    end

                                    NestCooldowns[data.Root] = os.clock() + 5
                                    break
                                else
                                    NestCooldowns[data.Root] = os.clock() + 3
                                end
                            end
                        end
                        isStealing = false
                    else
                        task.wait(0.3)
                    end
                end
            end
        else
            task.wait(0.3)
        end
    end
end)

-- 2. Auto Collect Eggs
local function collectEggs()
    if Remotes.ClaimAllEggs then
        pcall(function() Remotes.ClaimAllEggs:FireServer() end)
    end

    pcall(function()
        local bp = LocalPlayer.PlayerGui:FindFirstChild("BackpackGui")
        local growFrame = bp and bp:FindFirstChild("GrowEggFrame")
        local colAll = growFrame and growFrame:FindFirstChild("CollectAll")
        if colAll and colAll:IsA("GuiButton") and colAll.Visible then
            if firesignal then
                firesignal(colAll.MouseButton1Click)
            end
        end
        local scroll = growFrame and growFrame:FindFirstChild("ScrollingFrame")
        if scroll then
            for _, slot in ipairs(scroll:GetChildren()) do
                local sf = slot:FindFirstChild("SlotFrame")
                local btn = sf and sf:FindFirstChild("CollectButton")
                if btn and btn:IsA("GuiButton") and btn.Visible then
                    if firesignal then firesignal(btn.MouseButton1Click) end
                end
            end
        end
    end)

    local penEggs = Workspace:FindFirstChild("PenEggs")
    if penEggs then
        for _, eggModel in ipairs(penEggs:GetChildren()) do
            for _, prompt in ipairs(eggModel:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.ActionText == "Collect" then
                    triggerPrompt(prompt)
                end
            end
            local eggId = eggModel:GetAttribute("eggId")
            if eggId and Remotes.ClaimEgg then
                pcall(function() Remotes.ClaimEgg:InvokeServer(eggId) end)
            end
        end
    end

    local myBase = getMyBase()
    if myBase then
        for _, desc in ipairs(myBase:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and (desc.ActionText:lower():find("egg") or desc.ActionText:lower():find("collect")) then
                triggerPrompt(desc)
            end
        end
    end
end

task.spawn(function()
    while true do
        if Toggles.AutoCollectEggs then
            collectEggs()
            task.wait(1.2)
        else
            task.wait(0.5)
        end
    end
end)

-- 3. Auto Sell Eggs
local function sellAllEggsDirectly()
    if Remotes.SellAllItems then
        pcall(function() Remotes.SellAllItems:FireServer("egg") end)
        pcall(function() Remotes.SellAllItems:FireServer() end)
    end

    pcall(function()
        local dg = LocalPlayer.PlayerGui:FindFirstChild("DialogueGui")
        if dg then
            local confirmDia = dg:FindFirstChild("SellConfirmDialogue")
            if confirmDia and confirmDia.Visible then
                local confBtn = confirmDia:FindFirstChild("Confirm")
                if confBtn and firesignal then
                    firesignal(confBtn.MouseButton1Click)
                end
            end
            local sellDia = dg:FindFirstChild("SellDialogue")
            if sellDia and sellDia.Visible then
                local sellInv = sellDia:FindFirstChild("SellInventory")
                if sellInv and firesignal then
                    firesignal(sellInv.MouseButton1Click)
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        if Toggles.AutoSellEggs then
            sellAllEggsDirectly()
            task.wait(1.5)
        else
            task.wait(0.5)
        end
    end
end)

-- 4. Auto Train Speed
task.spawn(function()
    while true do
        if Toggles.AutoTrainSpeed and not Toggles.AutoSteal then
            local root = getRoot()
            local myBase = getMyBase()
            if root and myBase then
                local treadmill = myBase:FindFirstChild("stuff") and myBase.stuff:FindFirstChild("Treadmill")
                if treadmill and treadmill:IsA("BasePart") then
                    local targetCFrame = treadmill.CFrame + Vector3.new(0, 2.5, 0)
                    if (root.Position - treadmill.Position).Magnitude > 4 then
                        root.CFrame = targetCFrame
                    end
                end
            end
            task.wait(0.2)
        else
            task.wait(0.5)
        end
    end
end)

-- 5. Remove Guards
local function isGuardModel(m)
    if not m or not m:IsA("Model") or m == LocalPlayer.Character then return false end
    if m.Parent == Workspace and m.Name == "model" and m:FindFirstChildOfClass("Humanoid") then
        return true
    end
    for _, p in ipairs(m:GetDescendants()) do
        if p:IsA("BasePart") and p.CollisionGroup == "Guard" then
            return true
        end
    end
    return false
end

task.spawn(function()
    while true do
        if Toggles.RemoveGuards then
            for _, m in ipairs(Workspace:GetChildren()) do
                if isGuardModel(m) then
                    pcall(function()
                        m:PivotTo(CFrame.new(0, -9999, 0))
                        m:Destroy()
                    end)
                end
            end
            task.wait(0.5)
        else
            task.wait(0.8)
        end
    end
end)

Workspace.ChildAdded:Connect(function(child)
    if Toggles.RemoveGuards and child:IsA("Model") then
        task.wait(0.08)
        if isGuardModel(child) then
            pcall(function()
                child:PivotTo(CFrame.new(0, -9999, 0))
                child:Destroy()
            end)
        end
    end
end)

-- 6. Fly System
local flyBodyVel = nil
local flyBodyGyro = nil

local function startFlying()
    local root = getRoot()
    if not root then return end

    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVel.Velocity = Vector3.new(0, 0, 0)
    flyBodyVel.Parent = root

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.P = 10000
    flyBodyGyro.CFrame = root.CFrame
    flyBodyGyro.Parent = root

    task.spawn(function()
        while Toggles.FlyMode and flyBodyVel and flyBodyGyro do
            local currentRoot = getRoot()
            local hum = getHum()
            if not currentRoot or not hum then break end

            local moveDir = hum.MoveDirection
            local camCF = Camera.CFrame
            flyBodyGyro.CFrame = camCF

            if moveDir.Magnitude > 0 then
                flyBodyVel.Velocity = camCF.LookVector * CustomFlySpeed
            else
                flyBodyVel.Velocity = Vector3.new(0, 0, 0)
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                flyBodyVel.Velocity = flyBodyVel.Velocity + Vector3.new(0, CustomFlySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                flyBodyVel.Velocity = flyBodyVel.Velocity - Vector3.new(0, CustomFlySpeed, 0)
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

-- 7. Movement & Collision Overrides
RunService.Stepped:Connect(function()
    if Toggles.NoClip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        local hum = getHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Toggles.WalkSpeedBoost then
        local hum = getHum()
        if hum and hum.WalkSpeed ~= CustomWalkSpeed then
            hum.WalkSpeed = CustomWalkSpeed
        end
    end
end)

-- =================================================================
-- UI CREATION (UI 1: OFFICIAL ULTRA SCRIPT HUB CLASSIC MATTE DARK)
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoUltraScriptHub_StealAChicken"
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
TitleLabel.Text = "STEAL A CHICKEN"
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
    stopFlying()
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
                callback(item, idx)
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

-- Forward controllers for mutual exclusivity
local autoStealCtrl, trainSpeedCtrl

-- 1. Auto Steal Chickens (Best)
autoStealCtrl = AddToggleRow("Auto Steal Chickens (Best)", false, function(enabled)
    Toggles.AutoSteal = enabled
    if enabled and Toggles.AutoTrainSpeed and trainSpeedCtrl then
        trainSpeedCtrl.SetState(false)
    end
end)

-- 2. Target Zone Selector Dropdown
AddDropdownRow("Target Zone", AvailableZones, 1, function(zoneName, idx)
    CurrentZoneIndex = idx
end)

-- 3. Auto Collect Eggs
AddToggleRow("Auto Collect Eggs", false, function(enabled)
    Toggles.AutoCollectEggs = enabled
end)

-- 4. Auto Sell Eggs (Instant Direct Sell)
AddToggleRow("Auto Sell Eggs", false, function(enabled)
    Toggles.AutoSellEggs = enabled
end)

-- 5. Auto Train Speed (Treadmill)
trainSpeedCtrl = AddToggleRow("Auto Train Speed", false, function(enabled)
    Toggles.AutoTrainSpeed = enabled
    if enabled and Toggles.AutoSteal and autoStealCtrl then
        autoStealCtrl.SetState(false)
    end
end)

-- 6. Remove Guards
AddToggleRow("Remove Guards", false, function(enabled)
    Toggles.RemoveGuards = enabled
end)

-- 7. Teleport to My Base Action Button
AddActionButton("Teleport to My Base", function()
    teleportToMyBase()
end)

-- 8. WalkSpeed Boost & Stepper Pill
AddToggleRow("WalkSpeed Boost", false, function(enabled)
    Toggles.WalkSpeedBoost = enabled
    if not enabled then
        local hum = getHum()
        if hum then hum.WalkSpeed = 16 end
    else
        local hum = getHum()
        if hum then hum.WalkSpeed = CustomWalkSpeed end
    end
end)

AddStepperRow("WalkSpeed", 16, 250, CustomWalkSpeed, 10, function(val)
    CustomWalkSpeed = val
    if Toggles.WalkSpeedBoost then
        local hum = getHum()
        if hum then hum.WalkSpeed = val end
    end
end)

-- 9. Fly Mode & Stepper Pill
AddToggleRow("Fly Mode", false, function(enabled)
    Toggles.FlyMode = enabled
    if enabled then
        startFlying()
    else
        stopFlying()
    end
end)

AddStepperRow("Fly Speed", 20, 200, CustomFlySpeed, 10, function(val)
    CustomFlySpeed = val
end)

-- 10. No Clip Toggle
AddToggleRow("No Clip", false, function(enabled)
    Toggles.NoClip = enabled
end)

-- 11. Infinite Jump Toggle
AddToggleRow("Infinite Jump", false, function(enabled)
    Toggles.InfiniteJump = enabled
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

print("[ULTRA SCRIPT HUB] Steal a Chicken loaded successfully!")
