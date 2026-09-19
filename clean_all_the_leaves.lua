--[[
    ========================================================================
    JUNEJO ULTRA SCRIPT HUB - CLEAN ALL THE LEAVES!
    ========================================================================
    Author: Made by Junejo (junejo18146)
    Target Game: Clean all the leaves! 🍃 [Roblox]
    Place ID: 92637789841354
    Repository: junejo18146/ultrascripthub
    File: clean_all_the_leaves.lua
    Universal Mobile (Delta / Codex / Fluxus / Arceus X) & PC Compatible
    UI Standard: Official Ultra Script Hub Classic Matte Dark (1:1 Exact Screenshot Standard)
    
    Features Included:
        1. Auto Collect Leaves (Targeted Auto-Nav & Collect, Auto-stops when bag is full)
        2. Clean All Leaves Loop (Brings & stacks all leaves on map into a neat pile)
        3. Leaf Magnet Aura (Pulls nearby leaves directly to character)
        4. Auto Click Tool (Continuously activates rake, blower, vacuum or mower)
        5. Expand Bag Capacity (Boosts bag capacity to 99,999)
        6. Dump All Leaves (1-Click Action: Instantly empties bag into nearest dumpster)
        7. Teleport to Dump Can (1-Click Action: Warps in front of dumpster)
        8. Clean 100% Zone / 1% Finisher (1-Click Action: Sweeps hidden stray leaves)
        9. Collect Duck Bot Parts (1-Click Action: Sweeps all 3 secret vacuum pieces)
        10. Teleport: House Yard / Spawn (1-Click Action Button)
        11. Teleport: Rooftop / Vents (1-Click Action Button)
        12. Teleport: Basement Chamber (1-Click Action Button)
        13. Leaves ESP (Bright Cyan Highlights & Distance Tags)
        14. FullBright & Clear Vision (Permanent night vision & fog removal)
        15. WalkSpeed Boost (Integrated Checkbox + [ - 50 + ] Stepper Pill)
        16. Fly Mode (Smooth 3D WASD & Mobile Touch Flight Engine)
        17. Infinite Jump (Airborne continuous multi-jump bypass)
        18. Player NoClip (Phase through walls, fences & doors)
        19. Fast Proximity Prompts (0s hold auto-sweeper)
        20. 24/7 Anti-AFK Disconnect Engine
    ========================================================================
--]]

local GameName = "CLEAN ALL THE LEAVES!"
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera

-- Safe UI Container resolver
local function getSafeUIParent(gui)
    local parent = nil
    if typeof(gethui) == "function" then
        parent = gethui()
    elseif syn and typeof(syn.protect_gui) == "function" then
        syn.protect_gui(gui)
        parent = CoreGui
    else
        pcall(function() parent = CoreGui end)
        if not parent then
            parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end
    return parent
end

local UIContainer = getSafeUIParent()

-- Cleanup previous UI instances cleanly
pcall(function()
    local names = {"SufyanScripterHub", "JunejoCleanLeavesUI", "RobloxScriptUI_CleanLeaves", "JunejoHubUI"}
    for _, name in ipairs(names) do
        pcall(function()
            if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        end)
        pcall(function()
            if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
                LocalPlayer.PlayerGui[name]:Destroy()
            end
        end)
        pcall(function()
            if gethui and gethui():FindFirstChild(name) then gethui()[name]:Destroy() end
        end)
    end
end)

-- Engine State Store
local State = {
    AutoCollectLeaves   = false,
    CleanAllLeavesLoop  = false,
    AutoCleanLeaves     = false,
    LeafMagnetAura      = false,
    AuraRange           = 35,
    ExpandBagCapacity   = false,
    AutoClickTool       = false,

    WalkSpeedActive     = false,
    WalkSpeedValue      = 50,
    JumpPowerActive     = false,
    JumpPowerValue      = 50,
    InfJumpActive       = false,
    NoClipActive        = false,
    FlyActive           = false,
    FlySpeed            = 55,

    LeafESP             = false,
    PlayerESP           = false,
    FullBrightActive    = false,

    InstantPrompts      = false,
    AntiAFKActive       = true
}

-- Notification Helper
local function ShowToast(title, desc)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Ultra Script Hub",
            Text = desc or "",
            Duration = 2.5
        })
    end)
end

-- Character Helpers
local function getChar()
    return LocalPlayer.Character
end

local function isAlive(targetChar)
    local char = targetChar or getChar()
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    return (hum ~= nil and hum.Health > 0 and root ~= nil)
end

local function getRoot()
    local char = getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local char = getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Teleport helper with multi-frame velocity zeroing & anti-rebound
local function teleportPlayer(targetCF)
    if not targetCF then return false end
    local char = getChar()
    local root = getRoot()
    if not char or not root then return false end

    local destCF = targetCF
    if typeof(destCF) == "Vector3" then
        destCF = CFrame.new(destCF)
    end

    pcall(function()
        if root.Anchored then root.Anchored = false end
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        if typeof(char.PivotTo) == "function" then
            char:PivotTo(destCF)
        else
            root.CFrame = destCF
        end
    end)

    task.spawn(function()
        for _ = 1, 2 do
            task.wait(0.03)
            pcall(function()
                if isAlive() then
                    local r = getRoot()
                    local c = getChar()
                    if r and c then
                        r.AssemblyLinearVelocity = Vector3.zero
                        r.AssemblyAngularVelocity = Vector3.zero
                        if typeof(c.PivotTo) == "function" then
                            c:PivotTo(destCF)
                        else
                            r.CFrame = destCF
                        end
                    end
                end
            end)
        end
    end)
    return true
end

-- Trigger Proximity Prompt Safely
local function triggerPrompt(prompt)
    if not prompt or not prompt.Parent or not prompt.Enabled then return end
    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, 30)
        if typeof(fireproximityprompt) == "function" then
            fireproximityprompt(prompt)
        elseif typeof(prompt.InputHoldBegin) == "function" then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration > 0 and math.min(prompt.HoldDuration + 0.05, 1.0) or 0.05)
            prompt:InputHoldEnd()
        end
    end)
end

-- Forward declarations to toggle the UI switch programmatically
local setCollectToggle = nil

-- Accurate Current Leaves & Bag Capacity Detector
local function getBagInfo()
    if State.ExpandBagCapacity then
        return 0, 999999, false
    end

    local currentLeaves = nil
    local maxCapacity = nil
    local isFullFlag = false

    pcall(function()
        local cam = Workspace.CurrentCamera
        local vpSize = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        local pg = LocalPlayer:FindFirstChild("PlayerGui")

        if pg then
            local bottomLeftNumbers = {}

            for _, lbl in ipairs(pg:GetDescendants()) do
                if lbl:IsA("TextLabel") and lbl.Visible and lbl.Text and #lbl.Text > 0 then
                    local isOurGui = false
                    local anc = lbl.Parent
                    while anc do
                        local an = anc.Name
                        if an:find("Junejo") or an:find("Hub") or anc == CoreGui then
                            isOurGui = true
                            break
                        end
                        anc = anc.Parent
                    end

                    if not isOurGui then
                        local rawText = lbl.Text
                        local txt = rawText:lower()
                        local lName = lbl.Name:lower()
                        local pName = lbl.Parent and lbl.Parent.Name:lower() or ""

                        local isUnrelated = lName:find("health") or lName:find("hp") or lName:find("stamina")
                                         or lName:find("coin") or lName:find("gold") or lName:find("fps")
                                         or lName:find("ping") or pName:find("coin") or pName:find("gold")

                        if not isUnrelated then
                            local cMatch, mMatch = rawText:match("(%d+)%s*/%s*(%d+)")
                            if cMatch and mMatch then
                                local cN = tonumber(cMatch)
                                local mN = tonumber(mMatch)
                                if cN and mN and mN >= 5 then
                                    currentLeaves = cN
                                    maxCapacity = math.max(maxCapacity or 0, mN)
                                end
                            end

                            local absPos = lbl.AbsolutePosition
                            if absPos.X <= (vpSize.X * 0.40) and absPos.Y >= (vpSize.Y * 0.55) then
                                local pureNum = rawText:match("^%s*(%d+)%s*$")
                                if pureNum then
                                    local val = tonumber(pureNum)
                                    if val then
                                        table.insert(bottomLeftNumbers, {
                                            val = val,
                                            x = absPos.X,
                                            y = absPos.Y,
                                            name = lName,
                                            parentName = pName
                                        })
                                    end
                                end
                            end

                            local isBagNamed = lName:find("leaf") or lName:find("leaves") or lName:find("bag") or lName:find("capacity")
                                            or pName:find("bag") or pName:find("leaf") or pName:find("leaves")
                            if isBagNamed then
                                if txt == "full" or txt:find("bag full") then
                                    isFullFlag = true
                                end
                                local num = rawText:match("(%d+)")
                                if num then
                                    local nVal = tonumber(num)
                                    if lName:find("cap") or lName:find("max") or pName:find("cap") or pName:find("max") then
                                        if nVal and nVal >= 5 then
                                            maxCapacity = math.max(maxCapacity or 0, nVal)
                                        end
                                    elseif lName:find("leaf") or lName:find("cur") or lName:find("count") then
                                        if nVal then
                                            currentLeaves = nVal
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if #bottomLeftNumbers >= 2 then
                local nums = {}
                for _, item in ipairs(bottomLeftNumbers) do table.insert(nums, item.val) end
                table.sort(nums)
                local highest = nums[#nums]
                local lowest = nums[1]
                if highest >= 5 and highest <= 1000000 then
                    maxCapacity = math.max(maxCapacity or 0, highest)
                    if currentLeaves == nil then
                        currentLeaves = lowest
                    end
                end
            elseif #bottomLeftNumbers == 1 then
                local onlyVal = bottomLeftNumbers[1].val
                if onlyVal >= 5 and not maxCapacity then
                    maxCapacity = onlyVal
                end
            end
        end

        for _, folderName in ipairs({"Data", "PlayerData", "Stats", "Inventory", "Upgrades", "PlayerStats"}) do
            local folder = LocalPlayer:FindFirstChild(folderName)
            if folder then
                for _, obj in ipairs(folder:GetDescendants()) do
                    if obj:IsA("ValueBase") and typeof(obj.Value) == "number" then
                        local on = obj.Name:lower()
                        if (on:find("cap") or on:find("max") or on:find("storage")) and obj.Value >= 5 then
                            maxCapacity = math.max(maxCapacity or 0, obj.Value)
                        elseif (on:find("leaf") or on:find("leaves") or on:find("count")) and not on:find("total") and not on:find("all") and not on:find("lifetime") then
                            if currentLeaves == nil then currentLeaves = obj.Value end
                        end
                    end
                end
            end
        end

        local aLeaves = LocalPlayer:GetAttribute("Leaves") or LocalPlayer:GetAttribute("LeafCount") or LocalPlayer:GetAttribute("CurrentLeaves")
        if aLeaves and typeof(aLeaves) == "number" then
            if currentLeaves == nil then currentLeaves = aLeaves end
        end

        local aCap = LocalPlayer:GetAttribute("MaxLeaves") or LocalPlayer:GetAttribute("Capacity") or LocalPlayer:GetAttribute("MaxCapacity") or LocalPlayer:GetAttribute("BagCapacity")
        if aCap and typeof(aCap) == "number" and aCap >= 5 then
            maxCapacity = math.max(maxCapacity or 0, aCap)
        end

        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            local lCur = ls:FindFirstChild("Leaves") or ls:FindFirstChild("Leaf") or ls:FindFirstChild("LeafCount")
            if lCur and lCur:IsA("ValueBase") and typeof(lCur.Value) == "number" then
                if currentLeaves == nil then currentLeaves = lCur.Value end
            end
            local lMax = ls:FindFirstChild("Capacity") or ls:FindFirstChild("MaxLeaves") or ls:FindFirstChild("MaxBag")
            if lMax and lMax:IsA("ValueBase") and typeof(lMax.Value) == "number" and lMax.Value >= 5 then
                maxCapacity = math.max(maxCapacity or 0, lMax.Value)
            end
        end

        local char = getChar()
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                local tCap = tool:GetAttribute("Capacity") or tool:GetAttribute("MaxLeaves") or tool:GetAttribute("MaxCapacity")
                if tCap and typeof(tCap) == "number" and tCap >= 5 then
                    maxCapacity = math.max(maxCapacity or 0, tCap)
                end
            end
        end
    end)

    maxCapacity = maxCapacity or 25
    currentLeaves = currentLeaves or 0

    local full = false
    if currentLeaves > 0 and currentLeaves >= maxCapacity and maxCapacity >= 5 then
        full = true
    elseif isFullFlag and currentLeaves > 0 and currentLeaves >= maxCapacity then
        full = true
    end

    return currentLeaves, maxCapacity, full
end

local function isBagFull()
    local _, _, full = getBagInfo()
    return full
end

local function applyBagExpansion()
    pcall(function()
        LocalPlayer:SetAttribute("Capacity", 999999)
        LocalPlayer:SetAttribute("MaxCapacity", 999999)
        LocalPlayer:SetAttribute("MaxLeaves", 999999)
        LocalPlayer:SetAttribute("MaxBag", 999999)
        LocalPlayer:SetAttribute("BagCapacity", 999999)

        local char = getChar()
        if char then
            char:SetAttribute("Capacity", 999999)
            char:SetAttribute("MaxCapacity", 999999)
            char:SetAttribute("MaxLeaves", 999999)
            char:SetAttribute("MaxBag", 999999)
            char:SetAttribute("BagCapacity", 999999)

            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                tool:SetAttribute("Capacity", 999999)
                tool:SetAttribute("MaxCapacity", 999999)
            end
        end

        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            for _, v in ipairs(ls:GetChildren()) do
                local n = v.Name:lower()
                if (n:find("cap") or n:find("max")) and v:IsA("ValueBase") then
                    v.Value = 999999
                end
            end
        end

        for _, rem in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                local rn = rem.Name:lower()
                if rn:find("upgrade") or rn:find("buybag") or rn:find("buycap") then
                    pcall(function()
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer("Bag", 1)
                            rem:FireServer("Capacity", 1)
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer("Bag", 1)
                        end
                    end)
                end
            end
        end
    end)
end

-- Cache for ground leaves
local lastLeafScan = 0
local cachedLeaves = {}

local function getAllLeaves()
    local root = getRoot()
    if not root then return {} end

    local now = tick()
    if #cachedLeaves > 0 and (now - lastLeafScan < 0.6) then
        local valid = {}
        for _, l in ipairs(cachedLeaves) do
            if l and l.Parent and l:IsA("BasePart") and l.Transparency < 0.9 and l.Size.Magnitude > 0.05 then
                table.insert(valid, l)
            end
        end
        if #valid > 0 then
            table.sort(valid, function(a, b)
                return (root.Position - a.Position).Magnitude < (root.Position - b.Position).Magnitude
            end)
            cachedLeaves = valid
            return cachedLeaves
        end
    end
    lastLeafScan = now

    local leaves = {}
    local seen = {}

    local function isValidLeafPart(obj)
        if not obj or not obj.Parent or not obj:IsA("BasePart") then return false end
        if seen[obj] then return false end
        if obj.Transparency >= 0.9 or obj.Size.Magnitude < 0.05 then return false end

        local myChar = LocalPlayer.Character
        if myChar and obj:IsDescendantOf(myChar) then return false end
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p.Character and obj:IsDescendantOf(p.Character) then return false end
        end

        local pModel = obj:FindFirstAncestorOfClass("Model")
        if pModel then
            local mn = pModel.Name:lower()
            if mn:find("tree") or mn:find("bush") or mn:find("hedge") or mn:find("pine") or mn:find("plant") or mn:find("house") or mn:find("dump") or mn:find("trash") or mn:find("bin") or mn:find("can") then
                return false
            end
        end

        local on = obj.Name:lower()
        if on:find("tree") or on:find("branch") or on:find("bush") or on:find("trunk") or on:find("wood") or on:find("can") or on:find("bin") or on:find("dump") or on:find("rake") or on:find("blower") or on:find("mower") or on:find("vacuum") then
            return false
        end

        return true
    end

    pcall(function()
        local CollectionService = game:GetService("CollectionService")
        for _, tag in ipairs({"Leaf", "Leaves", "Cleanable", "LeafPile", "Debris"}) do
            for _, obj in ipairs(CollectionService:GetTagged(tag)) do
                local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if isValidLeafPart(part) then
                    seen[part] = true
                    table.insert(leaves, part)
                end
            end
        end
    end)

    local candidateFolders = {}
    for _, fName in ipairs({"Leaves", "LeafPiles", "LeafFolder", "Debris", "Cleanables", "Piles", "GroundLeaves", "Drops", "YardLeaves"}) do
        local f = Workspace:FindFirstChild(fName)
        if f then table.insert(candidateFolders, f) end
        local mapF = Workspace:FindFirstChild("Map")
        if mapF and mapF:FindFirstChild(fName) then table.insert(candidateFolders, mapF:FindFirstChild(fName)) end
    end

    for _, child in ipairs(Workspace:GetChildren()) do
        local cn = child.Name:lower()
        if (cn:find("leaf") or cn:find("leaves") or cn:find("pile") or cn:find("debris") or cn:find("cleanable")) and (child:IsA("Folder") or child:IsA("Model")) then
            table.insert(candidateFolders, child)
        end
    end

    for _, folder in ipairs(candidateFolders) do
        for _, obj in ipairs(folder:GetDescendants()) do
            if isValidLeafPart(obj) then
                seen[obj] = true
                table.insert(leaves, obj)
            end
        end
    end

    local maxLimit = State.CleanAllLeavesLoop and 1000 or 50
    local maxDist = State.CleanAllLeavesLoop and 2500 or 250
    if #leaves < (State.CleanAllLeavesLoop and 500 or 15) then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if isValidLeafPart(obj) then
                local n = obj.Name:lower()
                local parentName = obj.Parent and obj.Parent.Name:lower() or ""
                if n:find("leaf") or n:find("leaves") or n:find("pile") or n:find("debris") or parentName:find("leaf") or parentName:find("leaves") or parentName:find("pile") then
                    local dist = (root.Position - obj.Position).Magnitude
                    if dist <= maxDist then
                        seen[obj] = true
                        table.insert(leaves, obj)
                        if #leaves >= maxLimit then break end
                    end
                end
            end
        end
    end

    if #leaves > 1 then
        pcall(function()
            table.sort(leaves, function(a, b)
                return (root.Position - a.Position).Magnitude < (root.Position - b.Position).Magnitude
            end)
        end)
    end

    cachedLeaves = leaves
    return leaves
end

local function getNearestTrashCan()
    local root = getRoot()
    if not root then return nil end
    local nearest = nil
    local minDist = 99999

    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local pText = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
            if pText:find("dump") or pText:find("trash") or pText:find("empty") or pText:find("dispose") or pText:find("can") or pText:find("bin") then
                local pPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                if pPart then
                    local d = (root.Position - pPart.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        nearest = pPart
                    end
                end
            end
        end
    end

    if nearest then return nearest end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if (n:find("trash") or n:find("garbage") or n:find("dumpster") or n:find("bin") or n:find("disposal") or n:find("recycle"))
           and not n:find("gui") and not n:find("item") and not n:find("particle") then
            local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            if part then
                local d = (root.Position - part.Position).Magnitude
                if d < minDist then
                    minDist = d
                    nearest = part
                end
            end
        end
    end

    return nearest
end

local function teleportToDumpCan()
    local root = getRoot()
    local trash = getNearestTrashCan()
    if not root then
        ShowToast("Teleport Alert", "Character not ready!")
        return
    end
    if not trash then
        ShowToast("Trash Alert", "Garbage Dump Can not found nearby!")
        return
    end

    teleportPlayer(trash.CFrame + Vector3.new(0, 2, 4))
    ShowToast("Dumpster 🗑️", "Warped directly next to Garbage Dump Can!")
end

local function dumpAllLeaves()
    local root = getRoot()
    local trash = getNearestTrashCan()
    if not root then
        ShowToast("Dump Alert", "Character not ready!")
        return
    end
    if not trash then
        ShowToast("Dump Alert", "Garbage Dump Can not found nearby!")
        return
    end

    teleportPlayer(trash.CFrame + Vector3.new(0, 2.5, 0))
    task.wait(0.15)

    for _, p in ipairs(trash.Parent:GetDescendants()) do
        if p:IsA("ProximityPrompt") then
            triggerPrompt(p)
        end
    end

    if typeof(firetouchinterest) == "function" then
        firetouchinterest(root, trash, 0)
        task.wait(0.04)
        firetouchinterest(root, trash, 1)
    end

    for _, rem in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if rem:IsA("RemoteEvent") then
            local rn = rem.Name:lower()
            if rn:find("dump") or rn:find("empty") or rn:find("deposit") or rn:find("sell") or rn:find("trash") then
                pcall(function() rem:FireServer() end)
                pcall(function() rem:FireServer(trash) end)
            end
        end
    end

    task.wait(0.3)
    ShowToast("Dump All Leaves 📥", "All leaves dumped into garbage dumpster!")
end

local function isPartCleanableLeaf(part)
    if not part or not part:IsA("BasePart") then return false end

    local myChar = LocalPlayer.Character
    if myChar and part:IsDescendantOf(myChar) then return false end
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p.Character and part:IsDescendantOf(p.Character) then return false end
    end

    local objName = part.Name:lower()
    local pModel = part:FindFirstAncestorOfClass("Model")
    local parentName = pModel and pModel.Name:lower() or (part.Parent and part.Parent.Name:lower() or "")

    if parentName:find("tree") or parentName:find("bush") or parentName:find("hedge") or parentName:find("house")
       or parentName:find("dump") or parentName:find("trash") or parentName:find("bin") or parentName:find("can")
       or parentName:find("fence") or parentName:find("wall") or parentName:find("floor") or parentName:find("roof") then
        return false
    end

    if objName:find("tree") or objName:find("trunk") or objName:find("branch") or objName:find("bush")
       or objName:find("baseplate") or objName:find("terrain") or objName:find("ground")
       or objName:find("can") or objName:find("bin") or objName:find("dump") or objName:find("trash") then
        return false
    end

    if objName:find("leaf") or objName:find("leaves") or objName:find("pile") or objName:find("debris") or objName:find("cleanable")
       or parentName:find("leaf") or parentName:find("leaves") or parentName:find("pile") or parentName:find("debris") then
        return true
    end

    local cs = game:GetService("CollectionService")
    for _, tag in ipairs({"Leaf", "Leaves", "Cleanable", "LeafPile", "Debris"}) do
        if cs:HasTag(part, tag) or (pModel and cs:HasTag(pModel, tag)) then
            return true
        end
    end

    if part:FindFirstChildOfClass("ClickDetector") or part:FindFirstChildOfClass("SelectionBox") or part:FindFirstChildOfClass("Highlight") then
        return true
    end
    if part.Parent and (part.Parent:FindFirstChildOfClass("ClickDetector") or part.Parent:FindFirstChildOfClass("SelectionBox") or part.Parent:FindFirstChildOfClass("Highlight")) then
        return true
    end

    return false
end

local lastLeafClickTime = 0
local function clickOnTargetLeaf(targetLeaf)
    if not targetLeaf or not isPartCleanableLeaf(targetLeaf) then return end

    local cur, max, full = getBagInfo()
    if full then
        State.AutoCollectLeaves = false
        State.AutoCleanLeaves = false
        if setCollectToggle then setCollectToggle(false) end
        ShowToast("Bag Full! 🎒", string.format("Bag full (%d/%d)! Dump leaves at Dumpster.", cur, max))
        return
    end

    local now = tick()
    if now - lastLeafClickTime < 2.8 then
        return
    end
    lastLeafClickTime = now

    pcall(function()
        local cam = Workspace.CurrentCamera
        if not cam then return end

        local sPos, onScreen = cam:WorldToViewportPoint(targetLeaf.Position)
        if not onScreen then return end

        local clickPos = Vector2.new(sPos.X, sPos.Y)

        if typeof(fireclickdetector) == "function" then
            local cd = targetLeaf:FindFirstChildOfClass("ClickDetector")
                    or (targetLeaf.Parent and targetLeaf.Parent:FindFirstChildOfClass("ClickDetector"))
                    or (targetLeaf.Parent and targetLeaf.Parent:FindFirstChildWhichIsA("ClickDetector", true))
            if cd then fireclickdetector(cd) end
        end

        if VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, true, game, 0)
            task.wait(0.04)
            VirtualInputManager:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, false, game, 0)
        end

        if VirtualUser then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(clickPos)
        end

        local char = getChar()
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end

        for _, pr in ipairs(targetLeaf.Parent:GetDescendants()) do
            if pr:IsA("ProximityPrompt") then
                triggerPrompt(pr)
            end
        end

        for _, rem in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if rem:IsA("RemoteEvent") then
                local rn = rem.Name:lower()
                if rn:find("collect") or rn:find("clean") or rn:find("suck") or rn:find("vacuum") or rn:find("rake") or rn:find("pickup") then
                    pcall(function() rem:FireServer(targetLeaf) end)
                    pcall(function() rem:FireServer(targetLeaf.Name) end)
                end
            end
        end
    end)
end

-- Targeted Auto Collect Leaves Engine
task.spawn(function()
    while true do
        task.wait(0.12)
        local isFarming = (State.AutoCollectLeaves or State.AutoCleanLeaves)
        if isFarming and isAlive() then
            local cur, max, full = getBagInfo()
            if full then
                State.AutoCollectLeaves = false
                State.AutoCleanLeaves = false
                if setCollectToggle then setCollectToggle(false) end
                ShowToast("Bag Full! 🎒", string.format("Bag full (%d/%d)! Teleport to Dump Can.", cur, max))
            else
                pcall(function()
                    local root = getRoot()
                    local char = getChar()
                    local hum = getHum()
                    if not root or not char or not hum then return end

                    local tool = char:FindFirstChildOfClass("Tool")
                    if not tool and LocalPlayer:FindFirstChild("Backpack") then
                        local bTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                        if bTool then
                            hum:EquipTool(bTool)
                            tool = bTool
                        end
                    end

                    local mouse = LocalPlayer:GetMouse()
                    local lookedAtPart = mouse and mouse.Target

                    local cam = Workspace.CurrentCamera
                    if (not lookedAtPart or not isPartCleanableLeaf(lookedAtPart)) and cam then
                        local ray = cam:ViewportPointToRay(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                        local rParams = RaycastParams.new()
                        rParams.FilterDescendantsInstances = {char}
                        rParams.FilterType = Enum.RaycastFilterType.Exclude
                        local hit = Workspace:Raycast(ray.Origin, ray.Direction * 35, rParams)
                        if hit and hit.Instance then
                            lookedAtPart = hit.Instance
                        end
                    end

                    if lookedAtPart and isPartCleanableLeaf(lookedAtPart) then
                        clickOnTargetLeaf(lookedAtPart)
                    end

                    local leaves = getAllLeaves()
                    if #leaves > 0 then
                        local closest = leaves[1]
                        if closest and closest.Parent and closest:IsA("BasePart") then
                            local dist = (root.Position - closest.Position).Magnitude
                            if dist < 12 and not isBagFull() then
                                hum:MoveTo(closest.Position)
                                local _, onScreen = cam:WorldToViewportPoint(closest.Position)
                                if onScreen and (not lookedAtPart or not isPartCleanableLeaf(lookedAtPart)) then
                                    clickOnTargetLeaf(closest)
                                end
                            end
                        end
                    end
                end)
            end
        elseif State.LeafMagnetAura and isAlive() then
            pcall(function()
                local root = getRoot()
                if not root then return end
                local leaves = getAllLeaves()
                local collected = 0
                for _, lf in ipairs(leaves) do
                    if lf and lf.Parent and lf:IsA("BasePart") then
                        local dist = (root.Position - lf.Position).Magnitude
                        if dist <= State.AuraRange then
                            if typeof(firetouchinterest) == "function" then
                                firetouchinterest(root, lf, 0)
                                task.wait(0.01)
                                firetouchinterest(root, lf, 1)
                            end
                            pcall(function()
                                lf.CFrame = root.CFrame
                                lf.AssemblyLinearVelocity = Vector3.zero
                            end)
                            collected = collected + 1
                            if collected >= 12 then break end
                        end
                    end
                end
            end)
        end

        if State.ExpandBagCapacity then
            applyBagExpansion()
        end
    end
end)

-- Clean All Leaves Loop Engine (Brings & stacks all leaves in front of player)
task.spawn(function()
    while true do
        task.wait(0.2)
        if State.CleanAllLeavesLoop and isAlive() then
            pcall(function()
                local root = getRoot()
                local char = getChar()
                if not root or not char then return end

                local pileBase = root.CFrame * CFrame.new(0, -1.8, -4.5)
                local leaves = getAllLeaves()

                for index, leaf in ipairs(leaves) do
                    local stackHeight = math.min((index - 1) * 0.04, 2.2)
                    local targetCFrame = pileBase * CFrame.new(0, stackHeight, 0)

                    if leaf and leaf.Parent and leaf:IsA("BasePart") then
                        pcall(function()
                            leaf.CFrame = targetCFrame
                            leaf.AssemblyLinearVelocity = Vector3.zero
                            leaf.Velocity = Vector3.zero
                            leaf.RotVelocity = Vector3.zero
                            leaf.CanCollide = false
                        end)

                        if typeof(firetouchinterest) == "function" then
                            pcall(function()
                                firetouchinterest(root, leaf, 0)
                                task.wait(0.001)
                                firetouchinterest(root, leaf, 1)
                            end)
                        end
                    elseif leaf and leaf.Parent and leaf:IsA("Model") then
                        pcall(function() leaf:PivotTo(targetCFrame) end)
                    end
                end
            end)
        end
    end
end)

-- Dedicated Auto Tool Clicker
task.spawn(function()
    while true do
        task.wait(0.15)
        if State.AutoClickTool and isAlive() then
            pcall(function()
                local char = getChar()
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end)
        end
    end
end)

-- Clean 100% Remaining Missing Leaves (The 1% Finisher)
local function huntRemainingLeaves()
    task.spawn(function()
        local root = getRoot()
        if not root then return end
        ShowToast("1% Finisher 🔍", "Searching for hidden leaves...")

        local leaves = getAllLeaves()
        if #leaves == 0 then
            ShowToast("All Clear! 🏆", "No stray leaves remaining in this zone!")
            return
        end

        local count = 0
        for _, leaf in ipairs(leaves) do
            if leaf and leaf.Parent and leaf:IsA("BasePart") then
                teleportPlayer(leaf.CFrame + Vector3.new(0, 1.5, 0))
                task.wait(0.18)

                local char = getChar()
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end

                if typeof(firetouchinterest) == "function" then
                    firetouchinterest(root, leaf, 0)
                    task.wait(0.02)
                    firetouchinterest(root, leaf, 1)
                end

                count = count + 1
                if count >= 15 then break end
            end
        end

        ShowToast("Area Swept ✨", "Collected hidden stray leaves!")
    end)
end

-- Collect Secret Duck Bot Parts
local function collectDuckBotParts()
    task.spawn(function()
        local root = getRoot()
        if not root then return end
        ShowToast("Duck Bot 🤖", "Locating secret duck bot pieces...")

        local duckParts = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local n = obj.Name:lower()
            if (n:find("duck") or n:find("bot") or n:find("secretpiece") or n:find("part")) and
               not n:find("base") and not n:find("map") and not n:find("tree") then
                local p = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if p then table.insert(duckParts, p) end
            end
        end

        if #duckParts == 0 then
            ShowToast("Duck Bot", "Parts already claimed or not spawned.")
            return
        end

        for _, dp in ipairs(duckParts) do
            teleportPlayer(dp.CFrame + Vector3.new(0, 2, 0))
            task.wait(0.3)
            for _, prompt in ipairs(dp.Parent:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    triggerPrompt(prompt)
                end
            end
            if typeof(firetouchinterest) == "function" then
                firetouchinterest(root, dp, 0)
                task.wait(0.02)
                firetouchinterest(root, dp, 1)
            end
        end

        ShowToast("Duck Bot 🤖", "All accessible duck bot pieces swept!")
    end)
end

-- =========================================================================
-- VISUALS (LEAF ESP & LIGHTING)
-- =========================================================================
local EspContainer = Instance.new("Folder")
EspContainer.Name = "Junejo_Leaves_ESP"
pcall(function()
    EspContainer.Parent = CoreGui
end)

local leafHighlights = {}
local leafBillboards = {}

local function updateLeafEsp()
    if not State.LeafESP then
        for _, h in pairs(leafHighlights) do if h then h:Destroy() end end
        for _, b in pairs(leafBillboards) do if b then b:Destroy() end end
        leafHighlights = {}
        leafBillboards = {}
        return
    end

    local root = getRoot()
    local leaves = getAllLeaves()

    for _, leaf in ipairs(leaves) do
        if leaf and leaf.Parent and leaf:IsA("BasePart") then
            if not leafHighlights[leaf] then
                local hl = Instance.new("Highlight")
                hl.Name = "LeafHL"
                hl.Adornee = leaf
                hl.FillColor = Color3.fromRGB(0, 210, 210)
                hl.OutlineColor = Color3.fromRGB(56, 189, 248)
                hl.FillTransparency = 0.45
                hl.OutlineTransparency = 0
                hl.Parent = EspContainer
                leafHighlights[leaf] = hl
            end

            if not leafBillboards[leaf] then
                local bb = Instance.new("BillboardGui")
                bb.Name = "LeafBB"
                bb.Adornee = leaf
                bb.Size = UDim2.new(0, 100, 0, 20)
                bb.AlwaysOnTop = true
                bb.StudsOffset = Vector3.new(0, 1.8, 0)
                bb.Parent = EspContainer

                local lbl = Instance.new("TextLabel", bb)
                lbl.Name = "Txt"
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.fromRGB(56, 189, 248)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 9
                leafBillboards[leaf] = bb
            end

            if leafBillboards[leaf] and leafBillboards[leaf]:FindFirstChild("Txt") and root then
                local d = math.floor((root.Position - leaf.Position).Magnitude)
                leafBillboards[leaf].Txt.Text = "🍃 Leaf [" .. tostring(d) .. "m]"
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(2.0)
        if State.LeafESP then
            pcall(updateLeafEsp)
        end
    end
end)

local origLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local function setFullBright(enabled)
    State.FullBrightActive = enabled
    if enabled then
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 195, 205)
    else
        Lighting.Brightness = origLighting.Brightness
        Lighting.ClockTime = origLighting.ClockTime
        Lighting.FogEnd = origLighting.FogEnd
        Lighting.GlobalShadows = origLighting.GlobalShadows
        Lighting.OutdoorAmbient = origLighting.OutdoorAmbient
    end
end

-- =========================================================================
-- MOVEMENT & FLY ENGINE
-- =========================================================================
local function UpdateCharacterSpeed()
    pcall(function()
        local hum = getHum()
        if hum then
            if State.WalkSpeedActive then
                hum.WalkSpeed = State.WalkSpeedValue
            else
                hum.WalkSpeed = 16
            end
        end
    end)
end

RunService.Heartbeat:Connect(function()
    pcall(function()
        if State.WalkSpeedActive and isAlive() and not State.FlyActive then
            local hum = getHum()
            if hum and hum.WalkSpeed ~= State.WalkSpeedValue then
                hum.WalkSpeed = State.WalkSpeedValue
            end
        end
    end)
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfJumpActive and isAlive() then
        pcall(function()
            local hum = getHum()
            local root = getRoot()
            if hum and root then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 52, root.AssemblyLinearVelocity.Z)
            end
        end)
    end
end)

local myCachedParts = {}
local function updateMyParts()
    local char = getChar()
    local parts = {}
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then table.insert(parts, p) end
        end
    end
    myCachedParts = parts
end

RunService.Stepped:Connect(function()
    if State.NoClipActive and isAlive() then
        for _, part in ipairs(myCachedParts) do
            if part and part.Parent and part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local flyBodyVel, flyBodyGyro
local function startFly()
    local root = getRoot()
    if not root then return end

    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.Name = "JunejoFlyVel"
    flyBodyVel.MaxForce = Vector3.new(9e5, 9e5, 9e5)
    flyBodyVel.Velocity = Vector3.zero
    flyBodyVel.Parent = root

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.Name = "JunejoFlyGyro"
    flyBodyGyro.MaxTorque = Vector3.new(9e5, 9e5, 9e5)
    flyBodyGyro.CFrame = root.CFrame
    flyBodyGyro.Parent = root

    task.spawn(function()
        while State.FlyActive and isAlive() do
            RunService.RenderStepped:Wait()
            local cam = Workspace.CurrentCamera
            local hum = getHum()
            local r = getRoot()
            if not cam or not hum or not r or not flyBodyVel or not flyBodyGyro then break end

            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            if moveDir.Magnitude > 0 then
                flyBodyVel.Velocity = moveDir.Unit * State.FlySpeed
            else
                flyBodyVel.Velocity = Vector3.zero
            end
            flyBodyGyro.CFrame = cam.CFrame
        end
    end)
end

local function stopFly()
    if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
    if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
end

-- Fast Proximity Prompts
pcall(function()
    ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
        if State.InstantPrompts then
            triggerPrompt(prompt)
        end
    end)
end)

-- 24/7 Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    if State.AntiAFKActive then
        pcall(function()
            if VirtualUser then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero)
            end
        end)
    end
end)

-- =========================================================================
-- EXACT SCREENSHOT 1:1 UI ARCHITECTURE (UI 1 MATTE DARK STANDARD)
-- =========================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoCleanLeavesUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = UIContainer

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 260)
MainFrame.Position = UDim2.new(0.5, -140, 0.4, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Smooth Dragging Engine
local isDragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then isDragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and isDragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Top Header Bar
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
CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Content Scroll Frame
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"
ContentScroll.Size = UDim2.new(1, -24, 1, -74)
ContentScroll.Position = UDim2.new(0, 12, 0, 36)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 2
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentScroll

-- Helper: Full-Width 1-Click Action Button Factory
local function AddActionButton(text, callback)
    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Name = "ActionBtn_" .. text:gsub("%s+", "")
    ActionBtn.Size = UDim2.new(1, 0, 0, 26)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
    ActionBtn.BorderSizePixel = 0
    ActionBtn.Text = text
    ActionBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    ActionBtn.TextSize = 11
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.Parent = ContentScroll
    
    local ActionCorner = Instance.new("UICorner")
    ActionCorner.CornerRadius = UDim.new(0, 6)
    ActionCorner.Parent = ActionBtn
    
    local ActionStroke = Instance.new("UIStroke")
    ActionStroke.Color = Color3.fromRGB(35, 35, 44)
    ActionStroke.Thickness = 1
    ActionStroke.Parent = ActionBtn
    
    ActionBtn.MouseButton1Click:Connect(function()
        ActionBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        task.delay(0.15, function() ActionBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 27) end)
        if callback then callback() end
    end)
end

-- Helper: Classic Checkbox Toggle Row Factory
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentScroll
    
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
    
    local function setVisualState(val)
        State[configKey] = val
        CheckMark.BackgroundTransparency = val and 0 or 1
        if callback then callback(val) end
    end
    
    RowBtn.MouseButton1Click:Connect(function()
        setVisualState(not State[configKey])
    end)
    
    return setVisualState
end

-- =========================================================================
-- POPULATING ROWS (EXACT ORDER & SCREENSHOT STYLE)
-- =========================================================================

-- 1. Full-Width Action Button: DUMP ALL LEAVES
AddActionButton("DUMP ALL LEAVES", function()
    dumpAllLeaves()
end)

-- 2. Full-Width Action Button: TELEPORT TO DUMP CAN
AddActionButton("TELEPORT TO DUMP CAN", function()
    teleportToDumpCan()
end)

-- 3. Full-Width Action Button: CLEAN 100% ZONE (1% FINISHER)
AddActionButton("CLEAN 100% ZONE (1% FINISHER)", function()
    huntRemainingLeaves()
end)

-- 4. Full-Width Action Button: COLLECT DUCK BOT PARTS
AddActionButton("COLLECT DUCK BOT PARTS", function()
    collectDuckBotParts()
end)

-- 5. Auto Collect Leaves
setCollectToggle = AddToggleRow("Auto Collect Leaves", "AutoCollectLeaves", function(s)
    State.AutoCleanLeaves = s
    if s then
        local cur, max, full = getBagInfo()
        if full then
            State.AutoCollectLeaves = false
            State.AutoCleanLeaves = false
            if setCollectToggle then setCollectToggle(false) end
            ShowToast("Bag Status 🎒", string.format("Bag is full (%d/%d)! Dump leaves first.", cur, max))
            return
        end
        ShowToast("Auto Collect Leaves", string.format("Armed: Collecting leaves (%d/%d)!", cur, max))
    else
        ShowToast("Auto Collect Leaves", "Disabled")
    end
end)

-- 6. Clean All Leaves Loop
AddToggleRow("Clean All Leaves Loop", "CleanAllLeavesLoop", function(s)
    ShowToast("Clean All Leaves 🧹", s and "Loop Active: Stacking all leaves in front of you!" or "Disabled")
end)

-- 7. Leaf Magnet Aura
AddToggleRow("Leaf Magnet Aura", "LeafMagnetAura", function(s)
    ShowToast("Magnet Aura", s and "Active: Sucking leaves in radius" or "Disabled")
end)

-- 8. Expand Bag Capacity (Infinite)
AddToggleRow("Expand Bag Capacity", "ExpandBagCapacity", function(s)
    if s then
        applyBagExpansion()
        ShowToast("Bag Capacity", "Infinite Bag Capacity (99,999) Activated!")
    else
        ShowToast("Bag Capacity", "Capacity boost disabled")
    end
end)

-- 9. Auto Click Tool
AddToggleRow("Auto Click Tool", "AutoClickTool", function(s)
    ShowToast("Auto Tool", s and "Auto tool activation enabled" or "Disabled")
end)

-- 10. Leaves ESP
AddToggleRow("Leaves ESP", "LeafESP", function(s)
    updateLeafEsp()
    ShowToast("Leaves ESP", s and "Tracking leaves through walls" or "Disabled")
end)

-- 11. FullBright & Clear Vision
AddToggleRow("FullBright & Clear Vision", "FullBrightActive", function(s)
    setFullBright(s)
    ShowToast("FullBright", s and "Night vision active" or "Disabled")
end)

-- 12. Fast Proximity Prompts
AddToggleRow("Fast Proximity Prompts", "InstantPrompts", function(s)
    ShowToast("Fast Prompts", s and "Instant interaction enabled" or "Disabled")
end)

-- 13. WalkSpeed Integrated Row (with Checkbox + Stepper Pill as shown in screenshot)
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, 0, 0, 24)
SpeedRow.BackgroundTransparency = 1
SpeedRow.Parent = ContentScroll

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.42, 0, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed"
SpeedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedRow

local SpeedCheckBox = Instance.new("Frame")
SpeedCheckBox.Size = UDim2.new(0, 18, 0, 18)
SpeedCheckBox.Position = UDim2.new(0.46, 0, 0.5, -9)
SpeedCheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
SpeedCheckBox.BorderSizePixel = 0
SpeedCheckBox.Parent = SpeedRow

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
SpeedCheckMark.BackgroundTransparency = State.WalkSpeedActive and 0 or 1
SpeedCheckMark.BorderSizePixel = 0
SpeedCheckMark.Parent = SpeedCheckBox

local SpeedMarkCorner = Instance.new("UICorner")
SpeedMarkCorner.CornerRadius = UDim.new(0, 2)
SpeedMarkCorner.Parent = SpeedCheckMark

local SpeedToggleBtn = Instance.new("TextButton")
SpeedToggleBtn.Size = UDim2.new(1, 0, 1, 0)
SpeedToggleBtn.BackgroundTransparency = 1
SpeedToggleBtn.Text = ""
SpeedToggleBtn.ZIndex = 5
SpeedToggleBtn.Parent = SpeedCheckBox

SpeedToggleBtn.MouseButton1Click:Connect(function()
    State.WalkSpeedActive = not State.WalkSpeedActive
    SpeedCheckMark.BackgroundTransparency = State.WalkSpeedActive and 0 or 1
    UpdateCharacterSpeed()
end)

local SpeedControlFrame = Instance.new("Frame")
SpeedControlFrame.Size = UDim2.new(0.44, 0, 1, 0)
SpeedControlFrame.Position = UDim2.new(0.56, 0, 0, 0)
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
SpeedDisplay.Text = tostring(State.WalkSpeedValue)
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
    State.WalkSpeedValue = math.max(16, State.WalkSpeedValue - 10)
    SpeedDisplay.Text = tostring(State.WalkSpeedValue)
    UpdateCharacterSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    State.WalkSpeedValue = math.min(300, State.WalkSpeedValue + 10)
    SpeedDisplay.Text = tostring(State.WalkSpeedValue)
    UpdateCharacterSpeed()
end)

-- 14. Fly Mode
AddToggleRow("Fly Mode", "FlyActive", function(s)
    if s then startFly() else stopFly() end
    ShowToast("Fly Mode", s and "3D Flying Enabled (WASD/Touch)" or "Fly Disabled")
end)

-- 15. Infinite Jump
AddToggleRow("Infinite Jump", "InfJumpActive", function(s)
    ShowToast("Infinite Jump", s and "Air Jump Enabled!" or "Infinite Jump Disabled")
end)

-- 16. Player NoClip
AddToggleRow("Player NoClip", "NoClipActive", function(s)
    if s then
        updateMyParts()
    elseif isAlive() then
        for _, part in ipairs(myCachedParts) do
            if part and part.Parent and part:IsA("BasePart") then part.CanCollide = true end
        end
    end
    ShowToast("NoClip", s and "Walk through walls active!" or "NoClip Disabled")
end)

-- 17. Teleport: House Yard / Front (Action Button)
AddActionButton("TP: HOUSE YARD / SPAWN", function()
    for _, sp in ipairs(Workspace:GetDescendants()) do
        if sp:IsA("SpawnLocation") and sp.Enabled then
            teleportPlayer(sp.CFrame + Vector3.new(0, 3, 0))
            ShowToast("Teleport", "Warped to House Spawn!")
            return
        end
    end
    ShowToast("Teleport", "Spawn location resolved.")
end)

-- 18. Teleport: Rooftop / Vents (Action Button)
AddActionButton("TP: ROOFTOP / VENTS", function()
    local root = getRoot()
    if root then
        teleportPlayer(root.CFrame + Vector3.new(0, 45, 0))
        ShowToast("Teleport", "Elevated to rooftop level!")
    end
end)

-- 19. Teleport: Basement / Ending (Action Button)
AddActionButton("TP: BASEMENT CHAMBER", function()
    local basement = Workspace:FindFirstChild("Basement", true) or Workspace:FindFirstChild("Ending", true)
    if basement then
        local p = basement:IsA("BasePart") and basement or basement:FindFirstChildWhichIsA("BasePart")
        if p then
            teleportPlayer(p.CFrame + Vector3.new(0, 3, 0))
            ShowToast("Basement", "Warped into basement!")
            return
        end
    end
    ShowToast("Basement", "Basement chamber not unlocked yet.")
end)

-- =========================================================================
-- MANDATORY CENTERED FOOTER (ULTRA SCRIPT HUB | Made by Junejo)
-- =========================================================================
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
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

ShowToast("Ultra Script Hub", "Clean all the leaves! loaded successfully!")
