-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - STEAL A LUCKY EGG (OFFICIAL SCRIPT)
-- Game: Steal A Lucky Egg (PlaceId: 123698673940079)
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- Universal Mobile (Delta / Codex / Fluxus) & PC Compatible
-- ====================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Clean all previous UI instances safely
for _, name in ipairs({"JunejoHubUI_StealLuckyEgg", "JunejoStealLuckyEggUI", "JunejoLuckyEggHub"}) do
    pcall(function()
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end)
end

-- Global Configuration & State
local Toggles = {
    AutoStealRare = false,
    AutoSteal = false,
    AutoRebirth = false,
    AutoTreadmill = false,
    AutoUpgradeBrainrot = false,
    AutoSell = false,
    AutoHatch = false,
    AutoUpgradeBase = false,
    RareEggESP = false,
    EggESP = false,
    PlayerESP = false,
    FlyMode = false,
    Noclip = false,
    InfiniteJump = false,
    WalkSpeedBoost = false,
    AntiAFK = true
}

local CustomSpeedValue = 100
local SavedBaseCFrame = nil
local CurrentEggESPInstances = {}
local CurrentRareEggESPInstances = {}
local CurrentPlayerESPInstances = {}
local CooldownEggs = {}

-- Safe Alive Check
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- Screen Notification Helper
local function ShowNotification(title, message)
    pcall(function()
        local sg = CoreGui:FindFirstChild("JunejoHubUI_StealLuckyEgg") or LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("JunejoHubUI_StealLuckyEgg")
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

        task.delay(3.5, function()
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

-- Universal Instant ProximityPrompt Trigger
local function InstantTriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = math.huge
        prompt.RequiresLineOfSight = false
        prompt.Enabled = true

        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt, 1)
            fireproximityprompt(prompt)
        end
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
        end
    end)
end

-- Universal Touch Interest Trigger
local function InstantTouch(part, targetPart)
    if not part or not targetPart then return end
    pcall(function()
        if firetouchinterest then
            firetouchinterest(part, targetPart, 0)
            firetouchinterest(part, targetPart, 1)
            firetouchinterest(targetPart, part, 0)
            firetouchinterest(targetPart, part, 1)
        end
    end)
end

-- Speed Update Helper
local function UpdateCharacterSpeed()
    pcall(function()
        if isAlive() then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
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

-- ====================================================
-- ADVANCED RARITY EVALUATION & INTELLIGENT SCANNER
-- ====================================================
local RarityWeights = {
    -- Ultra Tiers
    ["secret"] = 1000000,
    ["godly"] = 800000,
    ["celestial"] = 700000,
    ["cosmic"] = 600000,
    ["divine"] = 500000,
    ["infinity"] = 450000,
    ["omega"] = 400000,
    ["galactic"] = 350000,
    ["void"] = 300000,
    ["ancient"] = 250000,
    ["abyssal"] = 220000,
    ["titan"] = 200000,
    ["solar"] = 180000,
    ["demon"] = 170000,
    ["angelic"] = 160000,

    -- High Tiers
    ["mythic"] = 150000,
    ["mythical"] = 150000,
    ["legendary"] = 100000,
    ["diamond"] = 80000,
    ["emerald"] = 70000,
    ["ruby"] = 60000,
    ["sapphire"] = 50000,
    ["rainbow"] = 45000,
    ["plasma"] = 40000,
    ["radioactive"] = 38000,
    ["neon"] = 35000,
    ["magma"] = 32000,
    ["volcanic"] = 30000,
    ["volcano"] = 30000,

    -- Mid-High Tiers
    ["epic"] = 25000,
    ["golden"] = 20000,
    ["gold"] = 18000,
    ["crystal"] = 15000,
    ["frost"] = 14000,
    ["ice"] = 12000,
    ["shadow"] = 10000,
    ["darkness"] = 10000,
    ["dark"] = 8000,
    ["rare"] = 5000,
    ["uncommon"] = 500,
    ["common"] = 100,

    -- Famous High Tier Characters
    ["skibidi titan"] = 900000,
    ["gigachad"] = 750000,
    ["mewing"] = 650000,
    ["sigma"] = 600000,
    ["kai cenat"] = 400000,
    ["baby gronk"] = 350000,
    ["grimace"] = 300000,
    ["caseoh"] = 250000,
    ["tungsten"] = 200000,
    ["fanum"] = 150000,
    ["rizz"] = 100000,
    ["skibidi"] = 80000,
}

local function GetLocationKey(pos)
    return math.floor(pos.X / 4) .. "_" .. math.floor(pos.Y / 4) .. "_" .. math.floor(pos.Z / 4)
end

local function IsBaseOrPlotItem(obj)
    if not obj then return false end
    local charModel = obj:FindFirstAncestorOfClass("Model")
    if charModel and Players:GetPlayerFromCharacter(charModel) then
        return true
    end
    local current = obj
    local depth = 0
    while current and depth < 7 do
        if current == Workspace or current == game then break end
        local n = current.Name:lower()
        if n:find("plot") or n:find("base") or n:find("incubator") or n:find("hatchery") or n:find("tycoon") or n:find("house") or n:find("myslot") or n:find("mybase") or n:find("deposit") or n:find("treadmill") or n:find("stand") then
            return true
        end
        current = current.Parent
        depth = depth + 1
    end
    return false
end

local function GetEggRarityScore(obj, prompt, distFromBase)
    local score = 100
    local detectedName = "Lucky Egg"
    local combinedText = ""

    -- 1. Scan Object Name
    if obj then
        detectedName = obj.Name
        combinedText = combinedText .. " " .. obj.Name:lower()
    end

    -- 2. Scan Proximity Prompt Texts
    if prompt then
        if prompt.ObjectText and prompt.ObjectText ~= "" then
            detectedName = prompt.ObjectText
            combinedText = combinedText .. " " .. prompt.ObjectText:lower()
        end
        if prompt.ActionText and prompt.ActionText ~= "" then
            combinedText = combinedText .. " " .. prompt.ActionText:lower()
        end
    end

    -- 3. Scan Ancestor Names (Parents up to 5 levels for Zone, Biome, Area names)
    if obj and obj:IsA("Instance") then
        local currentParent = obj.Parent
        local depth = 0
        while currentParent and depth < 5 do
            if currentParent == Workspace or currentParent == game then break end
            combinedText = combinedText .. " " .. currentParent.Name:lower()
            currentParent = currentParent.Parent
            depth = depth + 1
        end
    end

    -- 4. Scan Attributes & Value Objects
    if obj and obj:IsA("Instance") then
        pcall(function()
            for attrName, attrVal in pairs(obj:GetAttributes()) do
                combinedText = combinedText .. " " .. tostring(attrName):lower() .. " " .. tostring(attrVal):lower()
                if type(attrVal) == "number" then
                    local an = attrName:lower()
                    if an:find("rarity") or an:find("tier") or an:find("luck") or an:find("multiplier") or an:find("price") or an:find("cost") or an:find("value") or an:find("level") then
                        score = math.max(score, attrVal * 100)
                    end
                end
            end
            if obj.Parent then
                for attrName, attrVal in pairs(obj.Parent:GetAttributes()) do
                    combinedText = combinedText .. " " .. tostring(attrName):lower() .. " " .. tostring(attrVal):lower()
                    if type(attrVal) == "number" then
                        local an = attrName:lower()
                        if an:find("rarity") or an:find("tier") or an:find("luck") or an:find("multiplier") then
                            score = math.max(score, attrVal * 100)
                        end
                    end
                end
            end
        end)

        pcall(function()
            for _, valObj in ipairs(obj:GetDescendants()) do
                if valObj:IsA("ValueBase") then
                    combinedText = combinedText .. " " .. valObj.Name:lower() .. " " .. tostring(valObj.Value):lower()
                    if valObj:IsA("NumberValue") or valObj:IsA("IntValue") then
                        score = math.max(score, valObj.Value * 10)
                    end
                elseif valObj:IsA("TextLabel") or valObj:IsA("TextBox") then
                    combinedText = combinedText .. " " .. valObj.Text:lower()
                    if valObj.Text and valObj.Text ~= "" and #valObj.Text > 2 and not valObj.Text:lower():find("e to") and not valObj.Text:lower():find("hold") then
                        detectedName = valObj.Text
                    end
                end
            end
        end)
    end

    -- 5. Match High Tier Keywords
    for keyword, weight in pairs(RarityWeights) do
        if combinedText:find(keyword) then
            if weight > score then
                score = weight
            end
        end
    end

    -- 6. Match Multipliers, Tiers, Zones, Biomes, Numbers
    local tierNum = combinedText:match("tier%s*(%d+)") or combinedText:match("tier%-(%d+)") or combinedText:match("t(%d+)")
    if tierNum then
        score = score + (tonumber(tierNum) * 30000)
    end

    local zoneNum = combinedText:match("zone%s*(%d+)") or combinedText:match("biome%s*(%d+)") or combinedText:match("area%s*(%d+)") or combinedText:match("island%s*(%d+)")
    if zoneNum then
        score = score + (tonumber(zoneNum) * 25000)
    end

    local multNum = combinedText:match("(%d+)%s*x") or combinedText:match("x%s*(%d+)")
    if multNum then
        score = score + (tonumber(multNum) * 1000)
    end

    local kNum = combinedText:match("(%d+)%s*k")
    if kNum then
        score = score + (tonumber(kNum) * 500)
    end

    local mNum = combinedText:match("(%d+)%s*m")
    if mNum then
        score = score + (tonumber(mNum) * 50000)
    end

    local bNum = combinedText:match("(%d+)%s*b")
    if bNum then
        score = score + (tonumber(bNum) * 500000)
    end

    -- 7. Biome Depth Distance Weighting (Higher zone eggs are placed further away)
    if distFromBase and distFromBase > 0 then
        score = score + math.floor(distFromBase / 4)
    end

    return score, detectedName
end

local function FindRarestEgg(hrpPosition)
    local candidates = {}
    local now = os.clock()
    local basePos = SavedBaseCFrame and SavedBaseCFrame.Position or hrpPosition

    -- 1. Gather all candidates from ProximityPrompts (outside Base / Plots)
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local pPart = prompt.Parent
            local targetPos = nil

            if pPart:IsA("BasePart") then
                targetPos = pPart.CFrame
            elseif pPart:IsA("Attachment") then
                targetPos = pPart.WorldCFrame
            elseif pPart:IsA("Model") and pPart.PrimaryPart then
                targetPos = pPart.PrimaryPart.CFrame
            end

            if targetPos then
                local locKey = GetLocationKey(targetPos.Position)
                local isCoolingDown = CooldownEggs[locKey] and (now < CooldownEggs[locKey])
                local inBaseOrPlot = IsBaseOrPlotItem(pPart)

                if not isCoolingDown and not inBaseOrPlot then
                    local distFromBase = (targetPos.Position - basePos).Magnitude
                    if distFromBase > 18 then
                        local act = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
                        local pName = pPart.Name:lower()
                        local isEgg = act:find("steal") or act:find("take") or act:find("grab") or act:find("egg") or act:find("lucky") or act:find("brainrot") or act:find("pick") or act:find("collect") or pName:find("egg") or pName:find("lucky") or pName:find("brainrot") or act == "" or act == " "

                        if isEgg then
                            local score, eggName = GetEggRarityScore(pPart, prompt, distFromBase)
                            table.insert(candidates, {
                                targetCFrame = targetPos,
                                prompt = prompt,
                                part = pPart:IsA("BasePart") and pPart or nil,
                                locKey = locKey,
                                eggName = eggName,
                                score = score,
                                distFromBase = distFromBase
                            })
                        end
                    end
                end
            end
        end
    end

    -- 2. Gather candidates from Workspace models/parts as fallback
    if #candidates == 0 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if (name:find("egg") or name:find("lucky") or name:find("brainrot")) and not name:find("gui") and not name:find("ui") then
                local tCFrame = nil
                local targetPart = nil

                if obj:IsA("BasePart") then
                    tCFrame = obj.CFrame
                    targetPart = obj
                elseif obj:IsA("Model") and obj.PrimaryPart then
                    tCFrame = obj.PrimaryPart.CFrame
                    targetPart = obj.PrimaryPart
                elseif obj:IsA("Model") then
                    local p = obj:FindFirstChildWhichIsA("BasePart")
                    if p then
                        tCFrame = p.CFrame
                        targetPart = p
                    end
                end

                if tCFrame then
                    local locKey = GetLocationKey(tCFrame.Position)
                    local isCoolingDown = CooldownEggs[locKey] and (now < CooldownEggs[locKey])
                    local inBaseOrPlot = IsBaseOrPlotItem(obj)

                    if not isCoolingDown and not inBaseOrPlot then
                        local distFromBase = (tCFrame.Position - basePos).Magnitude
                        if distFromBase > 18 then
                            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            local score, eggName = GetEggRarityScore(obj, prompt, distFromBase)
                            table.insert(candidates, {
                                targetCFrame = tCFrame,
                                prompt = prompt,
                                part = targetPart,
                                locKey = locKey,
                                eggName = eggName,
                                score = score,
                                distFromBase = distFromBase
                            })
                        end
                    end
                end
            end
        end
    end

    if #candidates == 0 then
        return nil, nil, nil, nil, "No Rare Egg Found", 0
    end

    -- 3. Sort candidates in descending order by score
    table.sort(candidates, function(a, b)
        return a.score > b.score
    end)

    local best = candidates[1]
    return best.targetCFrame, best.prompt, best.part, best.locKey, best.eggName, best.score
end

local function FindNearestAvailableEgg(hrpPosition)
    local candidates = {}
    local now = os.clock()
    local basePos = SavedBaseCFrame and SavedBaseCFrame.Position or hrpPosition

    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local pPart = prompt.Parent
            local targetPos = nil

            if pPart:IsA("BasePart") then
                targetPos = pPart.CFrame
            elseif pPart:IsA("Attachment") then
                targetPos = pPart.WorldCFrame
            elseif pPart:IsA("Model") and pPart.PrimaryPart then
                targetPos = pPart.PrimaryPart.CFrame
            end

            if targetPos then
                local locKey = GetLocationKey(targetPos.Position)
                local isCoolingDown = CooldownEggs[locKey] and (now < CooldownEggs[locKey])
                local inBaseOrPlot = IsBaseOrPlotItem(pPart)

                if not isCoolingDown and not inBaseOrPlot then
                    local distFromBase = (targetPos.Position - basePos).Magnitude
                    if distFromBase > 16 then
                        local act = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
                        local pName = pPart.Name:lower()
                        local isEgg = act:find("steal") or act:find("take") or act:find("grab") or act:find("egg") or act:find("lucky") or act:find("brainrot") or act:find("pick") or act:find("collect") or pName:find("egg") or pName:find("lucky") or pName:find("brainrot") or act == "" or act == " "

                        if isEgg then
                            local dist = (targetPos.Position - hrpPosition).Magnitude
                            table.insert(candidates, {
                                targetCFrame = targetPos,
                                prompt = prompt,
                                part = pPart:IsA("BasePart") and pPart or nil,
                                locKey = locKey,
                                dist = dist
                            })
                        end
                    end
                end
            end
        end
    end

    if #candidates == 0 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if (name:find("egg") or name:find("lucky") or name:find("brainrot")) and not name:find("gui") and not name:find("ui") then
                local tCFrame = nil
                local targetPart = nil

                if obj:IsA("BasePart") then
                    tCFrame = obj.CFrame
                    targetPart = obj
                elseif obj:IsA("Model") and obj.PrimaryPart then
                    tCFrame = obj.PrimaryPart.CFrame
                    targetPart = obj.PrimaryPart
                elseif obj:IsA("Model") then
                    local p = obj:FindFirstChildWhichIsA("BasePart")
                    if p then
                        tCFrame = p.CFrame
                        targetPart = p
                    end
                end

                if tCFrame then
                    local locKey = GetLocationKey(tCFrame.Position)
                    local isCoolingDown = CooldownEggs[locKey] and (now < CooldownEggs[locKey])
                    local inBaseOrPlot = IsBaseOrPlotItem(obj)

                    if not isCoolingDown and not inBaseOrPlot then
                        local distFromBase = (tCFrame.Position - basePos).Magnitude
                        if distFromBase > 16 then
                            local dist = (tCFrame.Position - hrpPosition).Magnitude
                            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            table.insert(candidates, {
                                targetCFrame = tCFrame,
                                prompt = prompt,
                                part = targetPart,
                                locKey = locKey,
                                dist = dist
                            })
                        end
                    end
                end
            end
        end
    end

    if #candidates == 0 then
        return nil, nil, nil, nil
    end

    table.sort(candidates, function(a, b)
        return a.dist < b.dist
    end)

    local best = candidates[1]
    return best.targetCFrame, best.prompt, best.part, best.locKey
end

local function ReturnToBaseAndDeposit(hrp)
    if SavedBaseCFrame and isAlive() then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = SavedBaseCFrame * CFrame.new(0, 2, 0)
        task.wait(0.18)

        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Parent then
                local pos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or (prompt.Parent:IsA("Attachment") and prompt.Parent.WorldPosition or nil)
                if pos and (pos - hrp.Position).Magnitude < 50 then
                    InstantTriggerPrompt(prompt)
                end
            end
        end

        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude < 45 then
                local n = part.Name:lower()
                if n:find("deposit") or n:find("hatch") or n:find("nest") or n:find("slot") or n:find("place") or n:find("base") or n:find("incub") or n:find("stand") then
                    InstantTouch(hrp, part)
                end
            end
        end
    end
end

-- Teleport to Rare Lucky Egg Action (TELEPORTS AND STAYS AT RARE EGG)
local function TeleportToRareEggAction()
    if not isAlive() then return end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Disable any auto loops that pull player away
    Toggles.AutoTreadmill = false
    Toggles.AutoSteal = false
    Toggles.AutoStealRare = false

    local targetCFrame, prompt, eggPart, _, eggName, rarity = FindRarestEgg(hrp.Position)
    if targetCFrame then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = targetCFrame * CFrame.new(0, 3.2, 0)
        task.wait(0.15)
        if prompt then InstantTriggerPrompt(prompt) end
        if eggPart then InstantTouch(hrp, eggPart) end
        ShowNotification("⚡ Teleported to Rarest Egg", "👑 " .. eggName .. " (Score: " .. rarity .. ")")
    else
        ShowNotification("No Rare Egg Found", "Scanning biomes... No active rare eggs found.")
    end
end

-- Steal Rare Lucky Egg Action Pipeline (TELEPORTS AND CLAIMS RARE EGG ON THE SPOT)
local function StealRareEggAction()
    if not isAlive() then return end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    Toggles.AutoTreadmill = false
    Toggles.AutoSteal = false

    local targetCFrame, prompt, eggPart, locKey, eggName, rarity = FindRarestEgg(hrp.Position)

    if targetCFrame then
        if locKey then
            CooldownEggs[locKey] = os.clock() + 4
        end

        ShowNotification("💎 Stealing Rarest Egg", "👑 " .. eggName .. " (Score: " .. rarity .. ")")

        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = targetCFrame * CFrame.new(0, 2.5, 0)
        task.wait(0.15)

        if prompt then
            InstantTriggerPrompt(prompt)
        end

        if eggPart then
            InstantTouch(hrp, eggPart)
        end

        for _, p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Parent then
                local pPos = p.Parent:IsA("BasePart") and p.Parent.Position or nil
                if pPos and (pPos - hrp.Position).Magnitude < 30 then
                    InstantTriggerPrompt(p)
                end
            end
        end

        ShowNotification("✓ Rarest Egg Claimed!", "👑 Secured " .. eggName .. " at spawn location!")
    else
        ShowNotification("No Rare Egg Found", "Scanning biomes... No active rare eggs found.")
    end
end

-- ====================================================
-- OFFICIAL JUNEJO COMPACT SCROLLING UI (280x285px)
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_StealLuckyEgg"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local guiParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
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
TitleLabel.Text = "STEAL A LUCKY EGG"
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

-- Scrollable Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -16, 0, 205)
ContentFrame.Position = UDim2.new(0, 10, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 80)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 540)
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper Function: Add Debounced Toggle Row
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 24)
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

-- Helper Function: Add Action Button Row
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
-- REGISTER ALL REQUESTED TOGGLES & ACTIONS
-- ====================================================

-- 1. Steal Rare Lucky Egg (1-Click Instant Action)
AddActionButton("💎 Steal Rare Egg (1-Click)", function(btn)
    btn.Text = "⏳ Stealing Rare Egg..."
    btn.TextColor3 = Color3.fromRGB(255, 215, 0)
    StealRareEggAction()
    task.delay(1.5, function()
        btn.Text = "💎 Steal Rare Egg (1-Click)"
        btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    end)
end)

-- 2. Teleport to Rare Egg (1-Click Instant Action)
AddActionButton("⚡ Teleport to Rare Egg", function(btn)
    btn.Text = "⏳ Teleporting..."
    btn.TextColor3 = Color3.fromRGB(220, 50, 255)
    TeleportToRareEggAction()
    task.delay(1.5, function()
        btn.Text = "⚡ Teleport to Rare Egg"
        btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    end)
end)

-- 3. Auto Steal Rare Egg (Continuous Loop)
AddToggleRow("Auto Steal Rare Egg", "AutoStealRare", function(state)
    if state and isAlive() then
        Toggles.AutoTreadmill = false
        Toggles.AutoSteal = false
        ShowNotification("Auto Steal Rare Egg", "Active: Seeking and securing rarest lucky eggs at spawn zones!")
    end
end)

-- 4. Auto Steal Nearest Egg (Continuous Loop)
AddToggleRow("Auto Steal Nearest Egg", "AutoSteal", function(state)
    if state and isAlive() then
        if not SavedBaseCFrame then
            SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end
end)

-- 5. Action Button: Set Current Base Position
AddActionButton("📍 Set Current Base Position", function(btn)
    if isAlive() then
        SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        btn.Text = "✓ Base Location Saved!"
        btn.TextColor3 = Color3.fromRGB(80, 255, 120)
        task.delay(1.5, function()
            btn.Text = "📍 Set Current Base Position"
            btn.TextColor3 = Color3.fromRGB(240, 240, 240)
        end)
    end
end)

-- 6. Action Button: Teleport to Base
AddActionButton("⚡ Teleport to Base", function(btn)
    if isAlive() then
        if not SavedBaseCFrame then
            SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = SavedBaseCFrame * CFrame.new(0, 2, 0)
        btn.Text = "✓ Teleported to Base!"
        task.delay(1.2, function()
            btn.Text = "⚡ Teleport to Base"
        end)
    end
end)

-- 7. Auto Rebirth (Automatic Prestige & Luck Multipliers)
AddToggleRow("Auto Rebirth", "AutoRebirth", function(state)
    if state then
        ShowNotification("Auto Rebirth", "Active: Automatically rebirthing for Luck & Cash multiplier!")
    end
end)

-- 8. Auto Treadmill (Train Speed on Treadmill)
AddToggleRow("Auto Treadmill", "AutoTreadmill", function(state)
    if state then
        ShowNotification("Auto Treadmill", "Active: Training on Base Treadmill when at Base!")
    end
end)

-- 9. Auto Upgrade Brainrot (Upgrade/Evolve Pets & Brainrots)
AddToggleRow("Auto Upgrade Brainrot", "AutoUpgradeBrainrot", function(state)
    if state then
        ShowNotification("Auto Upgrade Brainrot", "Active: Automatically upgrading Brainrots & Pets stats!")
    end
end)

-- 10. Auto Sell (Pets / Unwanted Eggs / Items)
AddToggleRow("Auto Sell", "AutoSell", function(state) end)

-- 11. Auto Hatch Eggs (Hatch incubated eggs placed in Base)
AddToggleRow("Auto Hatch Eggs", "AutoHatch", function(state) end)

-- 12. Auto Upgrade Base & Treadmills
AddToggleRow("Auto Upgrade Base", "AutoUpgradeBase", function(state)
    if state then
        ShowNotification("Auto Upgrade Base", "Active: Auto-buying Treadmills & Base Upgrades!")
    end
end)

-- 13. Rare Lucky Egg ESP (Neon Magenta Glowing Highlight + Billboard)
AddToggleRow("Rare Egg ESP", "RareEggESP", function(state)
    if not state then
        for _, inst in pairs(CurrentRareEggESPInstances) do
            pcall(function() inst:Destroy() end)
        end
        CurrentRareEggESPInstances = {}
    end
end)

-- 14. Lucky Egg ESP (Gold Highlight on All Eggs)
AddToggleRow("Lucky Egg ESP", "EggESP", function(state)
    if not state then
        for _, highlight in pairs(CurrentEggESPInstances) do
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
        end
        CurrentEggESPInstances = {}
    end
end)

-- 15. Player ESP & Base Defense Radar
AddToggleRow("Player ESP & Radar", "PlayerESP", function(state)
    if not state then
        for _, inst in pairs(CurrentPlayerESPInstances) do
            pcall(function() inst:Destroy() end)
        end
        CurrentPlayerESPInstances = {}
    end
end)

-- 16. Fly Mode (Smooth 3D Flight)
AddToggleRow("Fly Mode (3D Flight)", "FlyMode", function(state) end)

-- 17. Noclip Mode
AddToggleRow("Noclip (Phase Walls)", "Noclip", function(state) end)

-- 18. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump", function(state) end)

-- 19. Integrated WalkSpeed Row with - / + Pill Adjuster
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, -6, 0, 24)
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

local lastSpeedClick = 0
SpeedToggleBtn.MouseButton1Click:Connect(function()
    local now = os.clock()
    if now - lastSpeedClick < 0.15 then return end
    lastSpeedClick = now
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
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

-- Footer Frame
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
-- 1. CONTINUOUS AUTO STEAL ENGINES
-- ====================================================

-- Master Auto Steal Rare Egg Engine (TELEPORTS & STAYS AT RARE EGGS, NEVER RETURNS TO BASE)
task.spawn(function()
    while true do
        task.wait(0.3)
        if Toggles.AutoStealRare and isAlive() then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                local targetCFrame, prompt, eggPart, locKey, eggName, rarity = FindRarestEgg(hrp.Position)

                if targetCFrame then
                    if locKey then
                        CooldownEggs[locKey] = os.clock() + 3
                    end

                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.CFrame = targetCFrame * CFrame.new(0, 2.2, 0)
                    task.wait(0.15)

                    if prompt then
                        InstantTriggerPrompt(prompt)
                    end

                    if eggPart then
                        InstantTouch(hrp, eggPart)
                    end

                    for _, p in ipairs(Workspace:GetDescendants()) do
                        if p:IsA("ProximityPrompt") and p.Parent then
                            local pPos = p.Parent:IsA("BasePart") and p.Parent.Position or nil
                            if pPos and (pPos - hrp.Position).Magnitude < 30 then
                                InstantTriggerPrompt(p)
                            end
                        end
                    end
                    -- STAYS AT RARE EGG LOCATION - NEVER RETURNS TO BASE!
                    task.wait(0.3)
                else
                    task.wait(0.5)
                end
            end
        end
    end
end)

-- Master Auto Steal Nearest Egg Engine (Cycles between nearest eggs and Base)
task.spawn(function()
    while true do
        task.wait(0.25)
        if Toggles.AutoSteal and not Toggles.AutoStealRare and isAlive() then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                if not SavedBaseCFrame then
                    SavedBaseCFrame = hrp.CFrame
                end

                local targetCFrame, prompt, eggPart, locKey = FindNearestAvailableEgg(hrp.Position)

                if targetCFrame then
                    if locKey then
                        CooldownEggs[locKey] = os.clock() + 4
                    end

                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.CFrame = targetCFrame * CFrame.new(0, 2.2, 0)
                    task.wait(0.25)

                    if prompt then
                        InstantTriggerPrompt(prompt)
                    end

                    if eggPart then
                        InstantTouch(hrp, eggPart)
                    end

                    for _, p in ipairs(Workspace:GetDescendants()) do
                        if p:IsA("ProximityPrompt") and p.Parent then
                            local pPos = p.Parent:IsA("BasePart") and p.Parent.Position or nil
                            if pPos and (pPos - hrp.Position).Magnitude < 22 then
                                InstantTriggerPrompt(p)
                            end
                        end
                    end

                    task.wait(0.5)
                    ReturnToBaseAndDeposit(hrp)
                    task.wait(0.3)
                else
                    task.wait(0.5)
                end
            end
        end
    end
end)

-- ====================================================
-- 2. AUTO REBIRTH ENGINE (MULTI-METHOD SWEEPER)
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.8)
        if Toggles.AutoRebirth and isAlive() then
            local hrp = LocalPlayer.Character.HumanoidRootPart

            -- 1. Rebirth Remotes Trigger
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    local n = rem.Name:lower()
                    if n:find("rebirth") or n:find("prestige") or n:find("ascend") or n:find("evolve") then
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer()
                            rem:FireServer(1)
                            rem:FireServer(true)
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer()
                            rem:InvokeServer(1)
                        end
                    end
                end
            end)

            -- 2. Rebirth Proximity Prompts
            pcall(function()
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Parent then
                        local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                        if act:find("rebirth") or act:find("prestige") or act:find("ascend") then
                            local pPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or nil
                            if pPos and (pPos - hrp.Position).Magnitude < 120 then
                                InstantTriggerPrompt(prompt)
                            end
                        end
                    end
                end
            end)

            -- 3. Rebirth Touch Pads
            pcall(function()
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local n = part.Name:lower()
                        if (n:find("rebirth") or n:find("prestige") or n:find("ascend")) and (part.Position - hrp.Position).Magnitude < 90 then
                            InstantTouch(hrp, part)
                        end
                    end
                end
            end)

            -- 4. GUI Rebirth Buttons
            pcall(function()
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui then
                    for _, btn in ipairs(pgui:GetDescendants()) do
                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                            local txt = (btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or "")):lower()
                            if (txt:find("rebirth") or txt:find("prestige")) and not txt:find("robux") and not txt:find("pass") and not txt:find("shop") then
                                if getconnections then
                                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
                                    for _, conn in ipairs(getconnections(btn.Activated)) do conn:Fire() end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================================================
-- 3. AUTO TREADMILL ENGINE (SAFE BASE SPEED TRAINER)
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.3)
        if Toggles.AutoTreadmill and isAlive() then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                local basePos = SavedBaseCFrame and SavedBaseCFrame.Position or hrp.Position
                local distFromBase = (hrp.Position - basePos).Magnitude

                -- Only train on treadmill when player is AT BASE (never pull away from distant zones)
                if distFromBase < 40 and not (Toggles.AutoSteal or Toggles.AutoStealRare) then
                    local bestTreadmillPart = nil
                    local shortestTreadmillDist = math.huge

                    for _, part in ipairs(Workspace:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local n = part.Name:lower()
                            if n:find("treadmill") or n:find("speedpad") or n:find("track") or n:find("runpad") or n:find("train") then
                                local dist = (part.Position - basePos).Magnitude
                                if dist < shortestTreadmillDist then
                                    shortestTreadmillDist = dist
                                    bestTreadmillPart = part
                                end
                            end
                        end
                    end

                    if bestTreadmillPart then
                        InstantTouch(hrp, bestTreadmillPart)
                    end
                end

                pcall(function()
                    for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                        local n = rem.Name:lower()
                        if n:find("treadmill") or n:find("speed") or n:find("train") or n:find("step") or n:find("addspeed") or n:find("gainspeed") then
                            if rem:IsA("RemoteEvent") then
                                rem:FireServer()
                                rem:FireServer(1)
                                rem:FireServer(true)
                            elseif rem:IsA("RemoteFunction") then
                                rem:InvokeServer()
                                rem:InvokeServer(1)
                            end
                        end
                    end
                end)
            end
        end
    end
end)

-- ====================================================
-- 4. AUTO UPGRADE BRAINROT ENGINE
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.6)
        if Toggles.AutoUpgradeBrainrot and isAlive() then
            local hrp = LocalPlayer.Character.HumanoidRootPart

            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    local n = rem.Name:lower()
                    if n:find("upgradebrainrot") or n:find("upgradepet") or n:find("evolve") or n:find("levelup") or n:find("boostpet") or n:find("upgradepets") or n:find("mutate") then
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer()
                            rem:FireServer("All")
                            rem:FireServer(1)
                            rem:FireServer(true)
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer()
                            rem:InvokeServer("All")
                        end
                    end
                end
            end)

            pcall(function()
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Parent then
                        local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                        if (act:find("upgrade") or act:find("evolve") or act:find("level") or act:find("mutate") or act:find("boost")) and (act:find("brainrot") or act:find("pet") or act:find("lucky") or act:find("slot") or act:find("stand")) then
                            local pPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or nil
                            if pPos and (pPos - hrp.Position).Magnitude < 150 then
                                InstantTriggerPrompt(prompt)
                            end
                        end
                    end
                end
            end)

            pcall(function()
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local n = part.Name:lower()
                        if (n:find("upgradepet") or n:find("upgradebrainrot") or n:find("evolvepad") or n:find("petpad")) and (part.Position - hrp.Position).Magnitude < 100 then
                            InstantTouch(hrp, part)
                        end
                    end
                end
            end)

            pcall(function()
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui then
                    for _, btn in ipairs(pgui:GetDescendants()) do
                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                            local txt = (btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or "")):lower()
                            if (txt:find("upgrade brainrot") or txt:find("upgrade pet") or txt:find("upgrade all") or txt:find("evolve all") or txt:find("level up")) and not txt:find("robux") and not txt:find("pass") then
                                if getconnections then
                                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
                                    for _, conn in ipairs(getconnections(btn.Activated)) do conn:Fire() end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================================================
-- 5. AUTO SELL ENGINE (SELLS PETS / UNWANTED EGGS)
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoSell and isAlive() then
            local hrp = LocalPlayer.Character.HumanoidRootPart

            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    local n = rem.Name:lower()
                    if n:find("sell") or n:find("sellall") or n:find("sellpet") or n:find("sellegg") or n:find("cashout") or n:find("exchange") then
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer()
                            rem:FireServer("All")
                            rem:FireServer(true)
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer()
                            rem:InvokeServer("All")
                        end
                    end
                end
            end)

            pcall(function()
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Parent then
                        local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                        if act:find("sell") or act:find("cash in") or act:find("exchange") or act:find("trade in") or act:find("deposit cash") then
                            local pPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or nil
                            if pPos and (pPos - hrp.Position).Magnitude < 180 then
                                InstantTriggerPrompt(prompt)
                            end
                        end
                    end
                end
            end)

            pcall(function()
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local n = part.Name:lower()
                        if (n:find("sell") or n:find("sellpad") or n:find("sellzone") or n:find("dropzone") or n:find("merchant") or n:find("cashin")) and (part.Position - hrp.Position).Magnitude < 120 then
                            InstantTouch(hrp, part)
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================================================
-- 6. AUTO HATCH EGGS (HATCHES EGGS IN BASE SLOTS/NESTS)
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.3)
        if Toggles.AutoHatch and isAlive() then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local basePos = SavedBaseCFrame and SavedBaseCFrame.Position or hrp.Position

            pcall(function()
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Parent then
                        local pPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or (prompt.Parent:IsA("Attachment") and prompt.Parent.WorldPosition or nil)
                        if pPos then
                            local distToBase = (pPos - basePos).Magnitude
                            local distToMe = (pPos - hrp.Position).Magnitude
                            if distToBase < 90 or distToMe < 120 then
                                local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                                if act:find("hatch") or act:find("open") or act:find("egg") or act:find("claim") or act:find("slot") or act:find("nest") or act:find("incub") then
                                    InstantTriggerPrompt(prompt)
                                end
                            end
                        end
                    end
                end
            end)

            pcall(function()
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local n = part.Name:lower()
                        if n:find("hatch") or n:find("nest") or n:find("slot") or n:find("eggstand") or n:find("incub") then
                            if (part.Position - hrp.Position).Magnitude < 100 then
                                InstantTouch(hrp, part)
                            end
                        end
                    end
                end
            end)

            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    local n = rem.Name:lower()
                    if n:find("hatch") or n:find("openegg") or n:find("buyegg") or n:find("claimpet") or n:find("claimlucky") then
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer()
                            rem:FireServer(1)
                            rem:FireServer("Egg")
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer()
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================================================
-- 7. AUTO UPGRADE BASE & TREADMILLS ENGINE
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.8)
        if Toggles.AutoUpgradeBase and isAlive() then
            local hrp = LocalPlayer.Character.HumanoidRootPart

            pcall(function()
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Parent then
                        local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                        if act:find("upgrade") or act:find("buy") or act:find("capacity") or act:find("base") or act:find("slot") or act:find("speed") or act:find("treadmill") or act:find("luck") then
                            local pPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or nil
                            if pPos and (pPos - hrp.Position).Magnitude < 150 then
                                InstantTriggerPrompt(prompt)
                            end
                        end
                    end
                end
            end)

            pcall(function()
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local n = part.Name:lower()
                        if (n:find("upgrade") or n:find("buyslot") or n:find("treadmill") or n:find("speedpad") or n:find("luckpad")) and (part.Position - hrp.Position).Magnitude < 100 then
                            InstantTouch(hrp, part)
                        end
                    end
                end
            end)

            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    local n = rem.Name:lower()
                    if n:find("upgrade") or n:find("buyspeed") or n:find("buyslot") or n:find("treadmill") or n:find("upgradebase") or n:find("buyluck") then
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer()
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer()
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================================================
-- 8. RARE LUCKY EGG ESP ENGINE (MAGENTA NEON HIGHLIGHT & LIVE TAG)
-- ====================================================
RunService.RenderStepped:Connect(function()
    if Toggles.RareEggESP then
        local myPos = isAlive() and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero
        local targetCFrame, prompt, eggPart, _, eggName, rarity = FindRarestEgg(myPos)

        if eggPart or (targetCFrame and targetCFrame.Position) then
            local hostObj = eggPart or (prompt and prompt.Parent)
            if hostObj and (hostObj:IsA("BasePart") or hostObj:IsA("Model")) then
                if not hostObj:FindFirstChild("JunejoRareEggHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "JunejoRareEggHighlight"
                    hl.FillColor = Color3.fromRGB(220, 30, 255)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.2
                    hl.OutlineTransparency = 0
                    hl.Parent = hostObj
                    table.insert(CurrentRareEggESPInstances, hl)
                end

                if not hostObj:FindFirstChild("JunejoRareEggBillboard") then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "JunejoRareEggBillboard"
                    bb.Size = UDim2.new(0, 220, 0, 42)
                    bb.StudsOffset = Vector3.new(0, 3.5, 0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = hostObj:IsA("BasePart") and hostObj or hostObj:FindFirstChildWhichIsA("BasePart")
                    bb.Parent = hostObj

                    local tagLabel = Instance.new("TextLabel")
                    tagLabel.Name = "TagLabel"
                    tagLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    tagLabel.Position = UDim2.new(0, 0, 0, 0)
                    tagLabel.BackgroundTransparency = 1
                    tagLabel.Text = "👑 RAREST: " .. eggName
                    tagLabel.TextColor3 = Color3.fromRGB(255, 60, 255)
                    tagLabel.TextStrokeTransparency = 0
                    tagLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    tagLabel.TextSize = 11
                    tagLabel.Font = Enum.Font.GothamBold
                    tagLabel.Parent = bb

                    local distLabel = Instance.new("TextLabel")
                    distLabel.Name = "DistLabel"
                    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
                    distLabel.BackgroundTransparency = 1
                    distLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
                    distLabel.TextStrokeTransparency = 0
                    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    distLabel.TextSize = 10
                    distLabel.Font = Enum.Font.GothamMedium
                    distLabel.Parent = bb
                    table.insert(CurrentRareEggESPInstances, bb)
                end

                local bb = hostObj:FindFirstChild("JunejoRareEggBillboard")
                if bb and bb:FindFirstChild("DistLabel") and isAlive() then
                    local dist = math.floor((hostObj:GetPivot().Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                    bb.DistLabel.Text = "Distance: " .. dist .. "s | Tier Score: " .. rarity
                end
            end
        end
    end
end)

-- ====================================================
-- 9. LUCKY EGG ESP ENGINE (GOLD HIGHLIGHT)
-- ====================================================
RunService.RenderStepped:Connect(function()
    if Toggles.EggESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if (obj:IsA("Model") or obj:IsA("BasePart")) and (name:find("egg") or name:find("lucky") or name:find("brainrot")) and not name:find("gui") then
                if not obj:FindFirstChild("JunejoEggESP") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "JunejoEggESP"
                    highlight.FillColor = Color3.fromRGB(255, 215, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.25
                    highlight.OutlineTransparency = 0
                    highlight.Parent = obj
                    table.insert(CurrentEggESPInstances, highlight)
                end
            end
        end
    end
end)

-- ====================================================
-- 10. PLAYER ESP & BASE DEFENSE RADAR
-- ====================================================
RunService.RenderStepped:Connect(function()
    if Toggles.PlayerESP and isAlive() then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local char = plr.Character
                local hrp = char.HumanoidRootPart
                
                if not char:FindFirstChild("JunejoPlrHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "JunejoPlrHighlight"
                    hl.FillColor = Color3.fromRGB(255, 60, 60)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.3
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                    table.insert(CurrentPlayerESPInstances, hl)
                end
                
                if not hrp:FindFirstChild("JunejoRadarBillboard") then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "JunejoRadarBillboard"
                    bb.Size = UDim2.new(0, 180, 0, 32)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = hrp
                    bb.Parent = hrp
                    
                    local label = Instance.new("TextLabel")
                    label.Name = "InfoLabel"
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(255, 80, 80)
                    label.TextStrokeTransparency = 0
                    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    label.TextSize = 11
                    label.Font = Enum.Font.GothamBold
                    label.Parent = bb
                    table.insert(CurrentPlayerESPInstances, bb)
                end
                
                local bb = hrp:FindFirstChild("JunejoRadarBillboard")
                if bb and bb:FindFirstChild("InfoLabel") and isAlive() then
                    local myHrp = LocalPlayer.Character.HumanoidRootPart
                    local distToMe = math.floor((hrp.Position - myHrp.Position).Magnitude)
                    local baseDistText = ""
                    if SavedBaseCFrame then
                        local distToBase = math.floor((hrp.Position - SavedBaseCFrame.Position).Magnitude)
                        baseDistText = " | Base: " .. distToBase .. "s"
                    end
                    bb.InfoLabel.Text = plr.DisplayName .. " [" .. distToMe .. "s" .. baseDistText .. "]"
                end
            end
        end
    end
end)

-- ====================================================
-- 11. FLY MODE (UNIVERSAL MOBILE & PC FLIGHT)
-- ====================================================
local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local FlySpeed = 65

local function EnableFly()
    if not isAlive() then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Name = "JunejoFlyVelocity"
    FlyBodyVelocity.MaxForce = Vector3.new(9e5, 9e5, 9e5)
    FlyBodyVelocity.Velocity = Vector3.zero
    FlyBodyVelocity.Parent = hrp
    
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.Name = "JunejoFlyGyro"
    FlyBodyGyro.MaxTorque = Vector3.new(9e5, 9e5, 9e5)
    FlyBodyGyro.CFrame = hrp.CFrame
    FlyBodyGyro.Parent = hrp
end

local function DisableFly()
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
    if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
end

RunService.RenderStepped:Connect(function()
    if Toggles.FlyMode and isAlive() then
        if not FlyBodyVelocity or not FlyBodyVelocity.Parent then
            EnableFly()
        end
        local cam = Workspace.CurrentCamera
        local moveDir = Vector3.zero
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        if hum and hum.MoveDirection.Magnitude > 0 and moveDir.Magnitude == 0 then
            moveDir = (cam.CFrame.LookVector * hum.MoveDirection.Z * -1) + (cam.CFrame.RightVector * hum.MoveDirection.X)
            if hum.Jump then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
        end
        
        if FlyBodyGyro then FlyBodyGyro.CFrame = cam.CFrame end
        if FlyBodyVelocity then
            if moveDir.Magnitude > 0 then
                FlyBodyVelocity.Velocity = moveDir.Unit * (Toggles.WalkSpeedBoost and CustomSpeedValue or FlySpeed)
            else
                FlyBodyVelocity.Velocity = Vector3.zero
            end
        end
    else
        if FlyBodyVelocity or FlyBodyGyro then
            DisableFly()
        end
    end
end)

-- ====================================================
-- 12. NOCLIP ENGINE & SPEED KEEPER
-- ====================================================
RunService.Stepped:Connect(function()
    if isAlive() then
        if Toggles.Noclip or Toggles.AutoSteal or Toggles.AutoStealRare then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        if Toggles.WalkSpeedBoost then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = CustomSpeedValue end
        end
    end
end)

-- ====================================================
-- 13. INFINITE JUMP (MOBILE & PC UNIVERSAL)
-- ====================================================
UIS.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function()
    if Toggles.InfiniteJump and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Jump then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Character Added Re-hook
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateCharacterSpeed()
end)

-- ====================================================
-- 14. ANTI-AFK ENGINE
-- ====================================================
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end
end)
