-- ==============================================================================
-- JUNEJO ULTRA SCRIPT HUB - STEAL A CHICKEN
-- Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- UI Framework: UI 1 (Official Ultra Script Hub Classic Matte Dark)
-- Universal Mobile & PC Delta / Codex / Fluxus Optimized
-- ==============================================================================

local GameName = "STEAL A CHICKEN"

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera

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

-- ==============================================================================
-- REMOTE RESOLVER (Auto-discovers exact game remotes)
-- ==============================================================================
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

-- ==============================================================================
-- BASE DETECTOR & TELEPORT HELPERS
-- ==============================================================================
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

local function getBasePenCFrame(base)
    if not base then return nil end

    local stuff = base:FindFirstChild("stuff") or base:FindFirstChild("Stuff")

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

    local piv = base:GetPivot() + Vector3.new(0, 2.5, 0)
    if not isNearTreadmill(piv.Position) then
        return piv
    end

    return nil
end

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

-- ==============================================================================
-- FEATURE STATES & SETTINGS
-- ==============================================================================
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

local CustomWalkSpeed = 50
local CustomFlySpeed = 60

-- ==============================================================================
-- PROMPT TRIGGER HELPER
-- ==============================================================================
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

-- ==============================================================================
-- 1. AUTO STEAL BEST CHICKENS
-- ==============================================================================
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

-- ==============================================================================
-- 2. AUTO COLLECT EGGS
-- ==============================================================================
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

-- ==============================================================================
-- 3. AUTO SELL EGGS
-- ==============================================================================
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

-- ==============================================================================
-- 4. AUTO TRAIN SPEED
-- ==============================================================================
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

-- ==============================================================================
-- 5. REMOVE GUARDS
-- ==============================================================================
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

-- ==============================================================================
-- 6. FLY SYSTEM
-- ==============================================================================
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

-- ==============================================================================
-- 7. MOVEMENT HACKS (NOCLIP, INFINITE JUMP, WALKSPEED)
-- ==============================================================================
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

local function UpdateWalkSpeed()
    pcall(function()
        local hum = getHum()
        if hum then
            if Toggles.WalkSpeedBoost then
                hum.WalkSpeed = CustomWalkSpeed
            else
                hum.WalkSpeed = 16
            end
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if Toggles.WalkSpeedBoost then
        local hum = getHum()
        if hum and hum.WalkSpeed ~= CustomWalkSpeed then
            hum.WalkSpeed = CustomWalkSpeed
        end
    end
end)

-- ==============================================================================
-- JUNEJO OFFICIAL UI 1 - CLASSIC MATTE DARK INTERFACE
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_StealAChicken"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local guiParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = guiParent

-- Main Window Frame
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

-- Draggable Logic (Mobile & PC)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
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

MainFrame.InputChanged:Connect(function(input)
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

-- 1. Header Frame
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = GameName
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
    stopFlying()
    ScreenGui:Destroy()
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- 2. Scrollable Content Container
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -74)
ContentFrame.Position = UDim2.new(0, 10, 0, 36)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- UI Helper: Action Button
local function AddActionButton(text, callback)
    local BtnFrame = Instance.new("Frame")
    BtnFrame.Size = UDim2.new(1, 0, 0, 26)
    BtnFrame.BackgroundTransparency = 1
    BtnFrame.Parent = ContentFrame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = BtnFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(40, 40, 50) }):Play()
        task.delay(0.12, function()
            TweenService:Create(Btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(27, 27, 32) }):Play()
        end)
        if callback then callback() end
    end)
end

-- UI Helper: Toggle Row
local ToggleUpdaters = {}
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
    Label.Position = UDim2.new(0, 4, 0, 0)
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
    CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox

    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark

    local function updateVisual()
        CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
    end
    ToggleUpdaters[configKey] = updateVisual

    RowBtn.MouseButton1Click:Connect(function()
        Toggles[configKey] = not Toggles[configKey]
        updateVisual()
        if callback then callback(Toggles[configKey]) end
    end)
end

-- ==============================================================================
-- BUILD UI CONTROLS
-- ==============================================================================

-- 1. Action Button: Teleport to Base
AddActionButton("Teleport to My Base", function()
    teleportToMyBase()
end)

-- 2. Zone Dropdown Selector
local ZoneContainer = Instance.new("Frame")
ZoneContainer.Size = UDim2.new(1, 0, 0, 26)
ZoneContainer.BackgroundTransparency = 1
ZoneContainer.ClipsDescendants = true
ZoneContainer.Parent = ContentFrame

local ZoneBtn = Instance.new("TextButton")
ZoneBtn.Size = UDim2.new(1, 0, 0, 26)
ZoneBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
ZoneBtn.BorderSizePixel = 0
ZoneBtn.AutoButtonColor = false
ZoneBtn.Text = ""
ZoneBtn.Parent = ZoneContainer

local ZoneBtnCorner = Instance.new("UICorner")
ZoneBtnCorner.CornerRadius = UDim.new(0, 5)
ZoneBtnCorner.Parent = ZoneBtn

local ZoneBtnStroke = Instance.new("UIStroke")
ZoneBtnStroke.Color = Color3.fromRGB(45, 45, 55)
ZoneBtnStroke.Thickness = 1
ZoneBtnStroke.Parent = ZoneBtn

local ZoneBtnLabel = Instance.new("TextLabel")
ZoneBtnLabel.Size = UDim2.new(1, -12, 1, 0)
ZoneBtnLabel.Position = UDim2.new(0, 8, 0, 0)
ZoneBtnLabel.BackgroundTransparency = 1
ZoneBtnLabel.Text = "Zone: " .. AvailableZones[CurrentZoneIndex] .. " ▾"
ZoneBtnLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
ZoneBtnLabel.TextSize = 11
ZoneBtnLabel.Font = Enum.Font.GothamBold
ZoneBtnLabel.TextXAlignment = Enum.TextXAlignment.Left
ZoneBtnLabel.Parent = ZoneBtn

local ZoneListFrame = Instance.new("Frame")
ZoneListFrame.Size = UDim2.new(1, 0, 0, #AvailableZones * 22 + 4)
ZoneListFrame.Position = UDim2.new(0, 0, 0, 30)
ZoneListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
ZoneListFrame.BorderSizePixel = 0
ZoneListFrame.Visible = false
ZoneListFrame.Parent = ZoneContainer

local ZoneListCorner = Instance.new("UICorner")
ZoneListCorner.CornerRadius = UDim.new(0, 5)
ZoneListCorner.Parent = ZoneListFrame

local ZoneListStroke = Instance.new("UIStroke")
ZoneListStroke.Color = Color3.fromRGB(45, 45, 55)
ZoneListStroke.Thickness = 1
ZoneListStroke.Parent = ZoneListFrame

local ZoneLayout = Instance.new("UIListLayout")
ZoneLayout.Padding = UDim.new(0, 2)
ZoneLayout.Parent = ZoneListFrame

local isDropdownOpen = false
local function toggleDropdown()
    isDropdownOpen = not isDropdownOpen
    if isDropdownOpen then
        ZoneListFrame.Visible = true
        ZoneContainer.Size = UDim2.new(1, 0, 0, 32 + #AvailableZones * 22)
    else
        ZoneListFrame.Visible = false
        ZoneContainer.Size = UDim2.new(1, 0, 0, 26)
    end
end
ZoneBtn.MouseButton1Click:Connect(toggleDropdown)

for idx, zName in ipairs(AvailableZones) do
    local Item = Instance.new("TextButton")
    Item.Size = UDim2.new(1, -6, 0, 20)
    Item.Position = UDim2.new(0, 3, 0, 0)
    Item.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Item.BorderSizePixel = 0
    Item.AutoButtonColor = false
    Item.Text = (zName == "All Zones" and "⭐ " or "• ") .. zName
    Item.TextColor3 = Color3.fromRGB(220, 220, 220)
    Item.TextSize = 10
    Item.Font = Enum.Font.GothamMedium
    Item.Parent = ZoneListFrame

    local ItemCorner = Instance.new("UICorner")
    ItemCorner.CornerRadius = UDim.new(0, 4)
    ItemCorner.Parent = Item

    Item.MouseButton1Click:Connect(function()
        CurrentZoneIndex = idx
        ZoneBtnLabel.Text = "Zone: " .. AvailableZones[CurrentZoneIndex] .. " ▾"
        toggleDropdown()
    end)
end

-- 3. Feature Toggles
AddToggleRow("Auto Steal Chickens (Best)", "AutoSteal", function(enabled)
    if enabled and Toggles.AutoTrainSpeed then
        Toggles.AutoTrainSpeed = false
        if ToggleUpdaters["AutoTrainSpeed"] then ToggleUpdaters["AutoTrainSpeed"]() end
    end
end)

AddToggleRow("Auto Collect Eggs", "AutoCollectEggs")
AddToggleRow("Auto Sell Eggs", "AutoSellEggs")

AddToggleRow("Auto Train Speed", "AutoTrainSpeed", function(enabled)
    if enabled and Toggles.AutoSteal then
        Toggles.AutoSteal = false
        if ToggleUpdaters["AutoSteal"] then ToggleUpdaters["AutoSteal"]() end
    end
end)

AddToggleRow("Remove Guards", "RemoveGuards")

AddToggleRow("Fly Mode", "FlyMode", function(enabled)
    if enabled then
        startFlying()
    else
        stopFlying()
    end
end)

-- 4. Fly Speed Stepper Row
local FlySpeedRow = Instance.new("Frame")
FlySpeedRow.Size = UDim2.new(1, 0, 0, 23)
FlySpeedRow.BackgroundTransparency = 1
FlySpeedRow.Parent = ContentFrame

local FlySpeedLabel = Instance.new("TextLabel")
FlySpeedLabel.Size = UDim2.new(0.55, 0, 1, 0)
FlySpeedLabel.Position = UDim2.new(0, 4, 0, 0)
FlySpeedLabel.BackgroundTransparency = 1
FlySpeedLabel.Text = "Fly Speed"
FlySpeedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
FlySpeedLabel.TextSize = 12
FlySpeedLabel.Font = Enum.Font.GothamBold
FlySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
FlySpeedLabel.Parent = FlySpeedRow

local FlyControlFrame = Instance.new("Frame")
FlyControlFrame.Size = UDim2.new(0, 95, 0, 22)
FlyControlFrame.Position = UDim2.new(1, -97, 0.5, -11)
FlyControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
FlyControlFrame.BorderSizePixel = 0
FlyControlFrame.Parent = FlySpeedRow

local FlyCtrlCorner = Instance.new("UICorner")
FlyCtrlCorner.CornerRadius = UDim.new(0, 4)
FlyCtrlCorner.Parent = FlyControlFrame

local FlyCtrlStroke = Instance.new("UIStroke")
FlyCtrlStroke.Color = Color3.fromRGB(45, 45, 55)
FlyCtrlStroke.Thickness = 1
FlyCtrlStroke.Parent = FlyControlFrame

local FlyMinusBtn = Instance.new("TextButton")
FlyMinusBtn.Size = UDim2.new(0, 22, 1, 0)
FlyMinusBtn.BackgroundTransparency = 1
FlyMinusBtn.Text = "-"
FlyMinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
FlyMinusBtn.TextSize = 14
FlyMinusBtn.Font = Enum.Font.GothamBold
FlyMinusBtn.Parent = FlyControlFrame

local FlySpeedDisplay = Instance.new("TextLabel")
FlySpeedDisplay.Size = UDim2.new(1, -44, 1, 0)
FlySpeedDisplay.Position = UDim2.new(0, 22, 0, 0)
FlySpeedDisplay.BackgroundTransparency = 1
FlySpeedDisplay.Text = tostring(CustomFlySpeed)
FlySpeedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
FlySpeedDisplay.TextSize = 11
FlySpeedDisplay.Font = Enum.Font.GothamBold
FlySpeedDisplay.Parent = FlyControlFrame

local FlyPlusBtn = Instance.new("TextButton")
FlyPlusBtn.Size = UDim2.new(0, 22, 1, 0)
FlyPlusBtn.Position = UDim2.new(1, -22, 0, 0)
FlyPlusBtn.BackgroundTransparency = 1
FlyPlusBtn.Text = "+"
FlyPlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
FlyPlusBtn.TextSize = 14
FlyPlusBtn.Font = Enum.Font.GothamBold
FlyPlusBtn.Parent = FlyControlFrame

FlyMinusBtn.MouseButton1Click:Connect(function()
    CustomFlySpeed = math.max(20, CustomFlySpeed - 10)
    FlySpeedDisplay.Text = tostring(CustomFlySpeed)
end)

FlyPlusBtn.MouseButton1Click:Connect(function()
    CustomFlySpeed = math.min(250, CustomFlySpeed + 10)
    FlySpeedDisplay.Text = tostring(CustomFlySpeed)
end)

-- 5. WalkSpeed Row (Checkbox Toggle + Stepper Pill)
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
SpeedLabel.Size = UDim2.new(1, -28, 1, 0)
SpeedLabel.Position = UDim2.new(0, 4, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed"
SpeedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedToggleBtn

local SpeedCheckBox = Instance.new("Frame")
SpeedCheckBox.Size = UDim2.new(0, 18, 0, 18)
SpeedCheckBox.Position = UDim2.new(1, -20, 0.5, -9)
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
    UpdateWalkSpeed()
end)

local SpeedControlFrame = Instance.new("Frame")
SpeedControlFrame.Size = UDim2.new(0, 95, 0, 22)
SpeedControlFrame.Position = UDim2.new(1, -97, 0.5, -11)
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
SpeedDisplay.Text = tostring(CustomWalkSpeed)
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
    CustomWalkSpeed = math.max(16, CustomWalkSpeed - 10)
    SpeedDisplay.Text = tostring(CustomWalkSpeed)
    UpdateWalkSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomWalkSpeed = math.min(250, CustomWalkSpeed + 10)
    SpeedDisplay.Text = tostring(CustomWalkSpeed)
    UpdateWalkSpeed()
end)

-- 6. Movement Toggles
AddToggleRow("No Clip", "NoClip")
AddToggleRow("Infinite Jump", "InfiniteJump")

-- ==============================================================================
-- 3. FOOTER FRAME (MANDATORY ULTRA SCRIPT HUB FOOTER)
-- ==============================================================================
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

print("[ULTRA SCRIPT HUB] Steal a Chicken loaded successfully!")
