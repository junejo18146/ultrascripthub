-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - BREAK A BRAINROT EGG (OFFICIAL V2.1)
-- Game: Break a Brainrot Egg
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
for _, name in ipairs({"JunejoHubUI_BreakBrainrotEgg", "JunejoBreakBrainrotUI", "JunejoBreakEggHub"}) do
    pcall(function()
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end)
end

-- Global Configuration & State
local Toggles = {
    AutoBreakRare = false,
    RareEggESP = false,
    AutoInfiniteCash = false,
    AutoBuyHammer = false,
    AutoRebirth = false,
    FlyMode = false,
    Noclip = false,
    InfiniteJump = false,
    WalkSpeedBoost = false,
    AntiAFK = true
}

local CustomCashValue = "1000000000"
local CustomSpeedValue = 100
local SavedBaseCFrame = nil
local CurrentRareEggESPInstances = {}
local CooldownEggs = {}

-- Safe Alive Check
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- Record Initial Base / Spawn CFrame
pcall(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        SavedBaseCFrame = hrp.CFrame
    end
end)

-- Enhanced Screen Notification / Diagnostic Toast (Shows clear instructions & requirements)
local LastToastTime = 0
local function ShowNotification(title, message, isWarning)
    local now = os.clock()
    if now - LastToastTime < 1.2 then return end
    LastToastTime = now
    pcall(function()
        local sg = CoreGui:FindFirstChild("JunejoHubUI_BreakBrainrotEgg") or (LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("JunejoHubUI_BreakBrainrotEgg"))
        if not sg then return end

        local oldNotify = sg:FindFirstChild("JunejoToast")
        if oldNotify then oldNotify:Destroy() end

        local Toast = Instance.new("Frame")
        Toast.Name = "JunejoToast"
        Toast.Size = UDim2.new(0, 260, 0, 44)
        Toast.Position = UDim2.new(0.5, -130, 0.06, 0)
        Toast.BackgroundColor3 = isWarning and Color3.fromRGB(35, 18, 20) or Color3.fromRGB(18, 20, 26)
        Toast.BorderSizePixel = 0
        Toast.ZIndex = 999
        Toast.Parent = sg

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 6)
        ToastCorner.Parent = Toast

        local ToastStroke = Instance.new("UIStroke")
        ToastStroke.Color = isWarning and Color3.fromRGB(220, 60, 60) or Color3.fromRGB(60, 60, 85)
        ToastStroke.Thickness = 1.2
        ToastStroke.Parent = Toast

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -14, 0, 16)
        TitleLbl.Position = UDim2.new(0, 8, 0, 3)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = isWarning and Color3.fromRGB(255, 90, 90) or Color3.fromRGB(255, 215, 0)
        TitleLbl.TextSize = 11
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.ZIndex = 1000
        TitleLbl.Parent = Toast

        local MsgLbl = Instance.new("TextLabel")
        MsgLbl.Size = UDim2.new(1, -14, 0, 22)
        MsgLbl.Position = UDim2.new(0, 8, 0, 18)
        MsgLbl.BackgroundTransparency = 1
        MsgLbl.Text = message
        MsgLbl.TextColor3 = Color3.fromRGB(230, 230, 240)
        MsgLbl.TextSize = 10
        MsgLbl.TextWrapped = true
        MsgLbl.Font = Enum.Font.GothamMedium
        MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
        MsgLbl.ZIndex = 1000
        MsgLbl.Parent = Toast

        task.delay(2.2, function()
            if Toast and Toast.Parent then
                local tween = TweenService:Create(Toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                tween:Play()
                TitleLbl.TextTransparency = 1
                MsgLbl.TextTransparency = 1
                ToastStroke.Transparency = 1
                task.wait(0.26)
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

-- ====================================================
-- HAMMER / TOOL REQUIREMENT VERIFICATION & AUTO EQUIP
-- ====================================================
local function EnsureHammerEquipped()
    if not isAlive() then return false, nil end
    local char = LocalPlayer.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local backpack = LocalPlayer:FindFirstChild("Backpack")

    -- 1. Check if a tool is already active in hand
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        return true, currentTool
    end

    -- 2. Look in Backpack for Hammer / Weapon / Tool
    if backpack then
        local bestTool = nil
        for _, t in ipairs(backpack:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                if n:find("hammer") or n:find("axe") or n:find("weapon") or n:find("sword") or n:find("mallet") or n:find("pick") or n:find("bat") then
                    bestTool = t
                    break
                end
            end
        end
        if not bestTool then
            bestTool = backpack:FindFirstChildOfClass("Tool")
        end
        if bestTool and hum then
            hum:EquipTool(bestTool)
            task.wait(0.12)
            return true, bestTool
        end
    end

    -- 3. If no hammer in backpack, attempt to claim/buy starter hammer automatically
    pcall(function()
        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
            local n = rem.Name:lower()
            if n:find("buy") or n:find("starter") or n:find("hammer") or n:find("tool") or n:find("claim") or n:find("free") then
                if rem:IsA("RemoteEvent") then
                    rem:FireServer("Hammer")
                    rem:FireServer("Starter Hammer")
                    rem:FireServer(1)
                    rem:FireServer(true)
                elseif rem:IsA("RemoteFunction") then
                    rem:InvokeServer("Hammer")
                    rem:InvokeServer(1)
                end
            end
        end
    end)

    return false, nil
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
-- SAFE ANTI-RUBBERBAND TELEPORTATION ENGINE
-- (Eliminates physics bounces, barrier pushes & reset triggers)
-- ====================================================
local function SafeTeleportToEgg(targetCFrame, isStayOnly)
    if not isAlive() then return false end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return false end

    -- 1. Reset humanoid states that trigger physics falls
    hum.Sit = false

    -- 2. Make character parts non-collidable briefly so neither barriers nor egg mesh ejects player
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    -- 3. Calculate safe standing spot (3 studs in front of egg looking at it, not inside mesh)
    local targetPos = targetCFrame.Position
    local destPos = targetPos + Vector3.new(0, 1.6, 3.4)
    local destCFrame = CFrame.new(destPos, Vector3.new(targetPos.X, destPos.Y, targetPos.Z))

    -- 4. Complete velocity wipe
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    if hrp:FindFirstChild("BodyVelocity") then hrp.BodyVelocity.Velocity = Vector3.zero end

    -- 5. Lock position via temporary micro-anchor (guarantees server physics sync)
    hrp.CFrame = destCFrame
    hrp.Anchored = true
    task.wait(0.06)
    hrp.CFrame = destCFrame
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.Anchored = false

    return true
end

-- ====================================================
-- CUSTOM CASH / INFINITE CASH ENGINE
-- ====================================================
local function GiveCustomCash(amountInput)
    local rawText = tostring(amountInput or CustomCashValue or "1000000000"):lower():gsub("%s+", ""):gsub(",", "")
    local numAmount = 1000000000

    if rawText:find("inf") or rawText:find("max") then
        numAmount = 999999999999
    elseif rawText:find("t") then
        local n = tonumber(rawText:gsub("t", ""))
        numAmount = (n or 1) * 1000000000000
    elseif rawText:find("b") then
        local n = tonumber(rawText:gsub("b", ""))
        numAmount = (n or 1) * 1000000000
    elseif rawText:find("m") then
        local n = tonumber(rawText:gsub("m", ""))
        numAmount = (n or 1) * 1000000
    elseif rawText:find("k") then
        local n = tonumber(rawText:gsub("k", ""))
        numAmount = (n or 1) * 1000
    else
        numAmount = tonumber(rawText) or 1000000000
    end

    CustomCashValue = tostring(numAmount)
    EnsureHammerEquipped()

    -- 1. Rapid Egg Strike & Break Packets
    pcall(function()
        if isAlive() then
            local char = LocalPlayer.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(500, 500))

            local hitCount = 0
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local act = (obj.ActionText .. " " .. obj.ObjectText .. " " .. obj.Parent.Name):lower()
                    if act:find("break") or act:find("egg") or act:find("hit") or act:find("brainrot") or act:find("smash") then
                        InstantTriggerPrompt(obj)
                        hitCount = hitCount + 1
                    end
                elseif obj:IsA("BasePart") and hrp then
                    local n = obj.Name:lower()
                    if (n:find("egg") or n:find("brainrot") or n:find("drop") or n:find("coin") or n:find("cash")) then
                        InstantTouch(hrp, obj)
                    end
                end
                if hitCount > 40 then break end
            end
        end
    end)

    -- 2. Direct Server Remotes Fire
    pcall(function()
        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
            local n = rem.Name:lower()
            if n:find("cash") or n:find("money") or n:find("coin") or n:find("reward") or n:find("add") or n:find("give") or n:find("claim") or n:find("deposit") or n:find("sell") or n:find("income") or n:find("currency") or n:find("dollar") or n:find("earn") or n:find("payout") or n:find("drop") or n:find("hit") or n:find("break") or n:find("damage") or n:find("smash") or n:find("click") or n:find("attack") then
                if rem:IsA("RemoteEvent") then
                    rem:FireServer(numAmount)
                    rem:FireServer("Cash", numAmount)
                    rem:FireServer("Money", numAmount)
                    rem:FireServer("Coins", numAmount)
                    rem:FireServer(tostring(numAmount))
                    rem:FireServer(1, numAmount)
                    rem:FireServer(true, numAmount)
                    rem:FireServer("Reward", numAmount)
                    rem:FireServer("Claim", numAmount)
                    rem:FireServer("SellAll", numAmount)
                    rem:FireServer("AddCash", numAmount)
                    rem:FireServer()
                elseif rem:IsA("RemoteFunction") then
                    rem:InvokeServer(numAmount)
                    rem:InvokeServer("Cash", numAmount)
                    rem:InvokeServer("Money", numAmount)
                    rem:InvokeServer("Coins", numAmount)
                    rem:InvokeServer("Reward", numAmount)
                    rem:InvokeServer()
                end
            end
        end
    end)

    -- 3. Auto Claim Free Playtime Gifts & Daily Rewards
    pcall(function()
        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
            local n = rem.Name:lower()
            if n:find("gift") or n:find("daily") or n:find("playtime") or n:find("free") or n:find("chest") or n:find("spin") or n:find("wheel") or n:find("quest") then
                if rem:IsA("RemoteEvent") then
                    for i = 1, 15 do
                        rem:FireServer(i)
                        rem:FireServer("Gift" .. i)
                        rem:FireServer(tostring(i))
                    end
                elseif rem:IsA("RemoteFunction") then
                    for i = 1, 15 do
                        rem:InvokeServer(i)
                    end
                end
            end
        end
    end)

    -- 4. Auto Redeem Promo Codes
    pcall(function()
        local testCodes = {"RELEASE", "BRAINROT", "EGG", "HAMMER", "UPDATE", "FREE", "CASH", "MONEY", "SECRET", "LUCKY", "OP", "1KLIKES", "5KLIKES", "10KLIKES", "100K", "1M"}
        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
            local n = rem.Name:lower()
            if n:find("code") or n:find("redeem") or n:find("promo") then
                if rem:IsA("RemoteEvent") then
                    for _, cd in ipairs(testCodes) do
                        rem:FireServer(cd)
                        rem:FireServer(cd:lower())
                    end
                elseif rem:IsA("RemoteFunction") then
                    for _, cd in ipairs(testCodes) do
                        rem:InvokeServer(cd)
                    end
                end
            end
        end
    end)

    -- 5. Trigger Workspace Cash & Deposit Prompts & Sell Pads
    pcall(function()
        if isAlive() then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Parent then
                    local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                    if act:find("cash") or act:find("money") or act:find("sell") or act:find("claim") or act:find("deposit") or act:find("collect") or act:find("coin") or act:find("reward") then
                        InstantTriggerPrompt(prompt)
                    end
                end
            end
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") then
                    local n = part.Name:lower()
                    if n:find("cash") or n:find("collect") or n:find("sellpad") or n:find("deposit") or n:find("money") or n:find("coin") or n:find("reward") or n:find("bin") or n:find("bank") or n:find("sell") then
                        if (part.Position - hrp.Position).Magnitude < 160 then
                            InstantTouch(hrp, part)
                        end
                    end
                end
            end
        end
    end)

    -- 6. Local Leaderstats & Data Value Sync
    pcall(function()
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            for _, val in ipairs(leaderstats:GetChildren()) do
                local n = val.Name:lower()
                if n:find("cash") or n:find("money") or n:find("coin") or n:find("currency") or n:find("dollar") or n:find("point") or n:find("score") then
                    if val:IsA("NumberValue") or val:IsA("IntValue") then
                        val.Value = numAmount
                    elseif val:IsA("StringValue") then
                        val.Value = tostring(numAmount)
                    end
                end
            end
        end
        local dataFolders = {LocalPlayer:FindFirstChild("Data"), LocalPlayer:FindFirstChild("PlayerData"), LocalPlayer:FindFirstChild("Stats"), LocalPlayer:FindFirstChild("Values")}
        for _, dataFolder in ipairs(dataFolders) do
            if dataFolder then
                for _, val in ipairs(dataFolder:GetChildren()) do
                    local n = val.Name:lower()
                    if n:find("cash") or n:find("money") or n:find("coin") or n:find("currency") then
                        if val:IsA("NumberValue") or val:IsA("IntValue") then
                            val.Value = numAmount
                        elseif val:IsA("StringValue") then
                            val.Value = tostring(numAmount)
                        end
                    end
                end
            end
        end
    end)
end

-- ====================================================
-- UNLOCKED RAREST EGG SCANNER & ATTACK ENGINE
-- ====================================================
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
        if n:find("plot") or n:find("base") or n:find("incubator") or n:find("hatchery") or n:find("tycoon") or n:find("house") or n:find("myslot") or n:find("mybase") or n:find("deposit") or n:find("stand") then
            return true
        end
        current = current.Parent
        depth = depth + 1
    end
    return false
end

-- Check if egg or zone is hard-locked
local function IsEggLocked(obj, prompt)
    if prompt then
        if not prompt.Enabled then return true end
        local pt = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
        if pt:find("locked") or pt:find("need rebirth") or pt:find("level req") or pt:find("buy zone") or pt:find("unlock zone") then
            return true
        end
    end

    if obj and obj:IsA("Instance") then
        local current = obj
        local depth = 0
        while current and depth < 5 do
            if current == Workspace or current == game then break end
            local n = current.Name:lower()
            if n:find("zone_barrier") or n:find("lock_wall") or n:find("lockeddoor") then
                return true
            end
            current = current.Parent
            depth = depth + 1
        end
    end

    return false
end

local function GetEggDisplayName(obj, prompt, distFromBase)
    local detectedName = "Brainrot Egg"

    if prompt then
        if prompt.ObjectText and prompt.ObjectText ~= "" and #prompt.ObjectText > 1 then
            detectedName = prompt.ObjectText
        elseif prompt.ActionText and prompt.ActionText ~= "" and #prompt.ActionText > 2 and not prompt.ActionText:lower():find("hold") and not prompt.ActionText:lower():find("e to") then
            detectedName = prompt.ActionText
        end
    end

    if detectedName == "Brainrot Egg" and obj then
        if obj.Name and obj.Name ~= "" and obj.Name ~= "Part" and obj.Name ~= "MeshPart" and obj.Name ~= "Model" and obj.Name ~= "ProximityPrompt" and obj.Name ~= "Attachment" then
            detectedName = obj.Name
        elseif obj.Parent and obj.Parent ~= Workspace and obj.Parent.Name ~= "Map" and obj.Parent.Name ~= "Models" then
            detectedName = obj.Parent.Name
        end
    end

    return detectedName
end

-- UNLOCKED RAREST EGG FUNCTION: Scans and ranks all active unlocked eggs
local function FindRarestEgg(hrpPosition)
    local candidates = {}
    local now = os.clock()

    local basePos = SavedBaseCFrame and SavedBaseCFrame.Position or Vector3.zero

    -- 1. Gather candidates from ProximityPrompts across Workspace
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
            elseif pPart:IsA("Model") then
                local bp = pPart:FindFirstChildWhichIsA("BasePart")
                if bp then targetPos = bp.CFrame end
            end

            if targetPos then
                local locKey = GetLocationKey(targetPos.Position)
                local isCoolingDown = CooldownEggs[locKey] and (now < CooldownEggs[locKey])
                local inBaseOrPlot = IsBaseOrPlotItem(pPart)
                local locked = IsEggLocked(pPart, prompt)

                if not isCoolingDown and not inBaseOrPlot and not locked then
                    local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. pPart.Name):lower()
                    local isEgg = act:find("break") or act:find("hit") or act:find("egg") or act:find("brainrot") or act:find("lucky") or act:find("smash") or act:find("click") or act:find("mine") or act == "" or act == " "

                    if isEgg then
                        local distFromBase = (targetPos.Position - basePos).Magnitude
                        local eggName = GetEggDisplayName(pPart, prompt, distFromBase)
                        table.insert(candidates, {
                            targetCFrame = targetPos,
                            prompt = prompt,
                            part = pPart:IsA("BasePart") and pPart or pPart:FindFirstChildWhichIsA("BasePart"),
                            locKey = locKey,
                            eggName = eggName,
                            distFromBase = distFromBase
                        })
                    end
                end
            end
        end
    end

    -- 2. Gather candidates from Workspace models/parts
    if #candidates == 0 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if (name:find("egg") or name:find("brainrot") or name:find("block") or name:find("lucky")) and not name:find("gui") and not name:find("ui") then
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
                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    local locked = IsEggLocked(obj, prompt)

                    if not isCoolingDown and not inBaseOrPlot and not locked then
                        local distFromBase = (tCFrame.Position - basePos).Magnitude
                        local eggName = GetEggDisplayName(obj, prompt, distFromBase)
                        table.insert(candidates, {
                            targetCFrame = tCFrame,
                            prompt = prompt,
                            part = targetPart,
                            locKey = locKey,
                            eggName = eggName,
                            distFromBase = distFromBase
                        })
                    end
                end
            end
        end
    end

    if #candidates == 0 then
        return nil, nil, nil, nil, "No Unlocked Egg Found", 0
    end

    -- 3. Sort candidates by maximum distance from Base (Farthest unlocked egg = Rarest)
    table.sort(candidates, function(a, b)
        return a.distFromBase > b.distFromBase
    end)

    local best = candidates[1]
    return best.targetCFrame, best.prompt, best.part, best.locKey, best.eggName, math.floor(best.distFromBase)
end

-- Break Rare Egg Attack Engine on Target
local function PerformEggBreakAttack(targetCFrame, prompt, eggPart)
    local hasHammer, tool = EnsureHammerEquipped()
    if not hasHammer then
        ShowNotification("⚠️ REQUIREMENT: Hammer Needed", "Aapke paas Hammer nahi hai! Shop se Hammer buy/equip karein.", true)
        return false
    end

    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    for _ = 1, 4 do
        if tool then
            tool:Activate()
            if tool:FindFirstChild("Handle") and eggPart then
                InstantTouch(tool.Handle, eggPart)
            end
        end

        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(500, 500))

        if prompt then
            InstantTriggerPrompt(prompt)
        end
        if eggPart and eggPart:FindFirstChildWhichIsA("ClickDetector") then
            pcall(function() fireclickdetector(eggPart:FindFirstChildWhichIsA("ClickDetector")) end)
        end
        if eggPart and hrp then
            InstantTouch(hrp, eggPart)
        end
    end

    pcall(function()
        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
            local n = rem.Name:lower()
            if n:find("hit") or n:find("damage") or n:find("break") or n:find("attack") or n:find("smash") or n:find("click") or n:find("mine") then
                if rem:IsA("RemoteEvent") then
                    if eggPart then rem:FireServer(eggPart) end
                    rem:FireServer(1)
                    rem:FireServer(true)
                    rem:FireServer()
                elseif rem:IsA("RemoteFunction") then
                    if eggPart then rem:InvokeServer(eggPart) end
                    rem:InvokeServer()
                end
            end
        end
    end)
    return true
end

-- 1-Click Action: Break Unlocked Rare Egg
local function BreakRareEggAction()
    if not isAlive() then return end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Verify Hammer
    local hasHammer, tool = EnsureHammerEquipped()
    if not hasHammer then
        ShowNotification("⚠️ REQUIREMENT: Hammer Needed", "Aapke paas Hammer nahi hai! Shop se Hammer lein.", true)
        return
    end

    local targetCFrame, prompt, eggPart, locKey, eggName, distFromBase = FindRarestEgg(hrp.Position)
    if targetCFrame then
        if locKey then CooldownEggs[locKey] = os.clock() + 2.5 end

        ShowNotification("💎 Breaking Rare Egg", "👑 " .. eggName .. " (" .. tostring(distFromBase) .. " studs) | 🔨 " .. (tool and tool.Name or "Hammer"))
        SafeTeleportToEgg(targetCFrame, false)
        task.wait(0.12)

        for i = 1, 5 do
            PerformEggBreakAttack(targetCFrame, prompt, eggPart)
            task.wait(0.1)
        end

        ShowNotification("✓ Rare Egg Attacked!", "👑 Hit " .. eggName .. " successfully!")
    else
        ShowNotification("⚠️ No Unlocked Egg Found", "Map scan completed: No active eggs found in unlocked zones.", true)
    end
end

-- 1-Click Action: Teleport to Unlocked Rare Egg (Teleports and STAYS there permanently)
local function TeleportToRareEggAction()
    if not isAlive() then return end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetCFrame, prompt, eggPart, _, eggName, distFromBase = FindRarestEgg(hrp.Position)
    if targetCFrame then
        SafeTeleportToEgg(targetCFrame, true)
        ShowNotification("⚡ Teleported to Unlocked Egg", "👑 " .. eggName .. " (Furthest: " .. tostring(distFromBase) .. " studs) - Holding Position!")
    else
        ShowNotification("⚠️ No Unlocked Egg Found", "Map scan completed: No active eggs found in unlocked zones.", true)
    end
end

-- ====================================================
-- OFFICIAL JUNEJO COMPACT SCROLLING UI (280x285px)
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_BreakBrainrotEgg"
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
TitleLabel.Text = "BREAK A BRAINROT EGG"
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
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 80)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
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

-- Helper Function: Add Custom Cash Input Row
local function AddCashInputRow()
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 24)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame

    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(0.64, 0, 1, 0)
    InputBox.Position = UDim2.new(0, 0, 0, 0)
    InputBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    InputBox.BorderSizePixel = 0
    InputBox.Text = "1000000000"
    InputBox.PlaceholderText = "Cash (e.g. 1B)"
    InputBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.Font = Enum.Font.GothamBold
    InputBox.TextSize = 11
    InputBox.ClearTextOnFocus = false
    InputBox.Parent = Row

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = InputBox

    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color = Color3.fromRGB(45, 45, 55)
    BoxStroke.Thickness = 1
    BoxStroke.Parent = InputBox

    local AddBtn = Instance.new("TextButton")
    AddBtn.Size = UDim2.new(0.33, 0, 1, 0)
    AddBtn.Position = UDim2.new(0.67, 0, 0, 0)
    AddBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    AddBtn.BorderSizePixel = 0
    AddBtn.Text = "+ Add Cash"
    AddBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    AddBtn.Font = Enum.Font.GothamBold
    AddBtn.TextSize = 10
    AddBtn.Parent = Row

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = AddBtn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = AddBtn

    local lastAddClick = 0
    AddBtn.MouseButton1Click:Connect(function()
        local now = os.clock()
        if now - lastAddClick < 0.25 then return end
        lastAddClick = now
        AddBtn.Text = "✓ Added!"
        AddBtn.TextColor3 = Color3.fromRGB(80, 255, 120)
        GiveCustomCash(InputBox.Text)
        task.delay(1.2, function()
            AddBtn.Text = "+ Add Cash"
            AddBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
        end)
    end)
end

-- ====================================================
-- REGISTER ALL REQUESTED TOGGLES & ACTIONS
-- ====================================================

-- 1. Break Unlocked Rare Egg (1-Click Instant Action)
AddActionButton("💎 Break Unlocked Rare Egg", function(btn)
    btn.Text = "⏳ Breaking Rare Egg..."
    btn.TextColor3 = Color3.fromRGB(255, 215, 0)
    BreakRareEggAction()
    task.delay(1.5, function()
        btn.Text = "💎 Break Unlocked Rare Egg"
        btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    end)
end)

-- 2. Teleport to Unlocked Rare Egg (1-Click Instant Action - STAYS at destination)
AddActionButton("⚡ Teleport to Unlocked Rare Egg", function(btn)
    btn.Text = "⏳ Teleporting..."
    btn.TextColor3 = Color3.fromRGB(220, 50, 255)
    TeleportToRareEggAction()
    task.delay(1.5, function()
        btn.Text = "⚡ Teleport to Unlocked Rare Egg"
        btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    end)
end)

-- 3. Auto Break Unlocked Rare Egg (Continuous Loop)
AddToggleRow("Auto Break Unlocked Rare Egg", "AutoBreakRare", function(state)
    if state then
        local hasHammer, tool = EnsureHammerEquipped()
        if not hasHammer then
            ShowNotification("⚠️ REQUIREMENT: Hammer Needed", "Aapke paas Hammer nahi hai! Pehle Shop se Hammer lein.", true)
        end
    end
end)

-- 4. Unlocked Rare Egg ESP (Neon Magenta Glowing Highlight + Distance Billboard)
AddToggleRow("Unlocked Rare Egg ESP", "RareEggESP", function(state)
    if not state then
        for _, inst in pairs(CurrentRareEggESPInstances) do
            pcall(function() inst:Destroy() end)
        end
        CurrentRareEggESPInstances = {}
    end
end)

-- 5. Infinite Cash: Custom Cash Input Row (Type any amount & click + Add Cash)
AddCashInputRow()

-- 6. Infinite Cash: Max Cash (+999B) 1-Click Action Button
AddActionButton("💰 Max Cash (+999 Billion)", function(btn)
    btn.Text = "✓ +999B Added!"
    btn.TextColor3 = Color3.fromRGB(80, 255, 120)
    GiveCustomCash(999999999999)
    task.delay(1.2, function()
        btn.Text = "💰 Max Cash (+999 Billion)"
        btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    end)
end)

-- 7. Infinite Cash: Auto Infinite Cash Loop Toggle
AddToggleRow("Auto Infinite Cash (Loop)", "AutoInfiniteCash", function(state) end)

-- 8. Auto Buy Best Hammer & Upgrades
AddToggleRow("Auto Buy Best Hammer", "AutoBuyHammer", function(state) end)

-- 9. Auto Rebirth (Automatic Prestige Engine)
AddToggleRow("Auto Rebirth", "AutoRebirth", function(state) end)

-- 10. Action Button: Set Current Base Position
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

-- 11. Action Button: Teleport to Base
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

-- 12. Fly Mode (Smooth 3D Flight)
AddToggleRow("Fly Mode (3D Flight)", "FlyMode", function(state) end)

-- 13. Noclip Mode
AddToggleRow("Noclip (Phase Walls)", "Noclip", function(state) end)

-- 14. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump", function(state) end)

-- 15. Integrated WalkSpeed Row with - / + Pill Adjuster
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
-- 1. CONTINUOUS AUTO BREAK UNLOCKED RARE EGG ENGINE
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.18)
        if Toggles.AutoBreakRare and isAlive() then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                local hasHammer, tool = EnsureHammerEquipped()
                if not hasHammer then
                    ShowNotification("⚠️ REQUIREMENT: Hammer Needed", "Aapke paas Hammer nahi hai! Pehle Hammer buy ya equip karein.", true)
                    task.wait(1.5)
                else
                    local targetCFrame, prompt, eggPart, locKey, eggName, distFromBase = FindRarestEgg(hrp.Position)

                    if targetCFrame then
                        SafeTeleportToEgg(targetCFrame, false)
                        task.wait(0.08)

                        -- Attack and Break Egg
                        PerformEggBreakAttack(targetCFrame, prompt, eggPart)

                        -- Trigger any nearby drops or prompts
                        for _, p in ipairs(Workspace:GetDescendants()) do
                            if p:IsA("ProximityPrompt") and p.Parent then
                                local pPos = p.Parent:IsA("BasePart") and p.Parent.Position or nil
                                if pPos and (pPos - hrp.Position).Magnitude < 30 then
                                    InstantTriggerPrompt(p)
                                end
                            end
                        end
                        task.wait(0.12)
                    else
                        task.wait(0.6)
                    end
                end
            end
        end
    end
end)

-- ====================================================
-- 2. AUTO INFINITE CASH ENGINE (CONTINUOUS REFILL)
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.6)
        if Toggles.AutoInfiniteCash and isAlive() then
            GiveCustomCash(CustomCashValue or "1000000000")
        end
    end
end)

-- ====================================================
-- 3. COMPREHENSIVE AUTO BUY BEST HAMMER ENGINE
-- ====================================================
task.spawn(function()
    while true do
        task.wait(1.0)
        if Toggles.AutoBuyHammer and isAlive() then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            -- A. Fire Shop / Hammer Purchase Remotes in ReplicatedStorage
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    local n = rem.Name:lower()
                    if n:find("buy") or n:find("hammer") or n:find("tool") or n:find("weapon") or n:find("upgrade") or n:find("purchase") or n:find("craft") then
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer()
                            rem:FireServer("Best")
                            rem:FireServer("Hammer")
                            rem:FireServer(1)
                            rem:FireServer(true)
                            rem:FireServer("Tool")
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer()
                            rem:InvokeServer("Best")
                            rem:InvokeServer("Hammer")
                        end
                    end
                end
            end)

            -- B. Proximity Prompts on Hammer Stands in Workspace
            pcall(function()
                if hrp then
                    for _, prompt in ipairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Parent then
                            local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                            if act:find("hammer") or act:find("buy") or act:find("upgrade") or act:find("tool") or act:find("shop") or act:find("weapon") then
                                local pPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or nil
                                if pPos and (pPos - hrp.Position).Magnitude < 160 then
                                    InstantTriggerPrompt(prompt)
                                end
                            end
                        end
                    end
                end
            end)

            -- C. Touch Pads on Hammer Shop in Workspace
            pcall(function()
                if hrp then
                    for _, part in ipairs(Workspace:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local n = part.Name:lower()
                            if (n:find("hammerpad") or n:find("buypad") or n:find("upgradepad") or n:find("shop") or n:find("toolpad")) and (part.Position - hrp.Position).Magnitude < 120 then
                                InstantTouch(hrp, part)
                            end
                        end
                    end
                end
            end)

            -- D. PlayerGui Shop Button Simulator
            pcall(function()
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui then
                    for _, btn in ipairs(pgui:GetDescendants()) do
                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                            local txt = (btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or "")):lower()
                            local isBuyBtn = txt:find("buy") or txt:find("purchase") or txt:find("equip best") or txt:find("upgrade") or txt:find("unlock") or txt:find("max")
                            local isRobux = txt:find("robux") or txt:find("r$") or txt:find("pass") or txt:find("gift") or txt:find("buy cash") or txt:find("gem")
                            
                            if isBuyBtn and not isRobux then
                                if getconnections then
                                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
                                    for _, conn in ipairs(getconnections(btn.MouseButton1Down)) do conn:Fire() end
                                    for _, conn in ipairs(getconnections(btn.Activated)) do conn:Fire() end
                                end
                            end
                        end
                    end
                end
            end)

            -- E. Auto-Equip newly purchased best hammer from backpack
            EnsureHammerEquipped()
        end
    end
end)

-- ====================================================
-- 3. AUTO REBIRTH ENGINE
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
-- 4. UNLOCKED RARE BRAINROT EGG ESP ENGINE (MAGENTA NEON & LIVE BILLBOARD)
-- ====================================================
RunService.RenderStepped:Connect(function()
    if Toggles.RareEggESP then
        local myPos = isAlive() and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero
        local targetCFrame, prompt, eggPart, _, eggName, distFromBase = FindRarestEgg(myPos)

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
                    tagLabel.Text = "👑 UNLOCKED RARE: " .. eggName
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
                    local myDist = math.floor((hostObj:GetPivot().Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                    bb.DistLabel.Text = "Base: " .. tostring(distFromBase) .. "s | Me: " .. myDist .. "s"
                end
            end
        end
    end
end)

-- ====================================================
-- 5. FLY MODE (UNIVERSAL MOBILE & PC FLIGHT)
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
-- 6. NOCLIP ENGINE & SPEED KEEPER
-- ====================================================
RunService.Stepped:Connect(function()
    if isAlive() then
        if Toggles.Noclip or Toggles.AutoBreakRare then
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
-- 7. INFINITE JUMP (MOBILE & PC UNIVERSAL)
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
    EnsureHammerEquipped()
end)

-- ====================================================
-- 8. ANTI-AFK ENGINE
-- ====================================================
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end
end)

print("[JunejoHub] Break a Brainrot Egg V2.1 Loaded Successfully!")
