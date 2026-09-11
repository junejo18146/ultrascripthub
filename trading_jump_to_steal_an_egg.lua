-- ====================================================================
-- ULTRA SCRIPT HUB - TRADING JUMP TO STEAL AN EGG
-- Creator: Junejo (junejo18146)
-- Target Game: Trading Jump To Steal An Egg (Place ID: 106383201135975)
-- GitHub: https://raw.githubusercontent.com/junejo18146/ultrascripthub/main/trading_jump_to_steal_an_egg.lua
-- Style: Junejo Official Borderless UI (5-Row Visible Compact Frame)
-- ====================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- Saved Base CFrame anchor
local SavedBaseCFrame = nil
task.spawn(function()
    task.wait(0.5)
    if HumanoidRootPart then
        SavedBaseCFrame = HumanoidRootPart.CFrame
    end
end)

-- Feature Toggles
local Toggles = {
    AutoStealRare = false,
    InstantPrompt = false,
    AutoRebirth = false,
    AutoTrainJump = false,
    RareEggESP = false,
    PlayerESP = false,
    BaseESP = false,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

local CustomSpeedValue = 32
local CooldownEggs = {}
local ESPStorage = {
    SingleRareEgg = nil,
    SingleRareEggBillboard = nil,
    Players = {},
    Bases = {}
}

-- Safe Alive Check
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Speed Enforcer Loop
local function UpdateCharacterSpeed()
    if Humanoid then
        Humanoid.WalkSpeed = Toggles.WalkSpeedBoost and CustomSpeedValue or 16
    end
end

RunService.Heartbeat:Connect(function()
    if Toggles.WalkSpeedBoost and Humanoid and Humanoid.WalkSpeed ~= CustomSpeedValue then
        Humanoid.WalkSpeed = CustomSpeedValue
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Universal Instant ProximityPrompt Trigger
local function InstantTriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 999999
        prompt.RequiresLineOfSight = false
        prompt.Enabled = true

        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt, 1)
            fireproximityprompt(prompt)
        end
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            task.wait(0.04)
            prompt:InputHoldEnd()
        end
    end)
end

-- Universal Touch Interest Trigger
local function InstantTouch(part1, part2)
    if not part1 or not part2 then return end
    pcall(function()
        if firetouchinterest then
            firetouchinterest(part1, part2, 0)
            firetouchinterest(part1, part2, 1)
            firetouchinterest(part2, part1, 0)
            firetouchinterest(part2, part1, 1)
        end
    end)
end

-- Global Proximity Prompt Fast Hook
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
    if (Toggles.InstantPrompt or Toggles.AutoStealRare) and player == LocalPlayer then
        InstantTriggerPrompt(prompt)
    end
end)

task.spawn(function()
    while true do
        if Toggles.InstantPrompt or Toggles.AutoStealRare then
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    pcall(function()
                        prompt.HoldDuration = 0
                        prompt.MaxActivationDistance = 999999
                        prompt.RequiresLineOfSight = false
                    end)
                end
            end
        end
        task.wait(0.5)
    end
end)

-- Multi-Method Base Finder
local function FindMyBase()
    local potentialFolders = {
        Workspace:FindFirstChild("Bases"),
        Workspace:FindFirstChild("Plots"),
        Workspace:FindFirstChild("PlayerBases"),
        Workspace:FindFirstChild("Islands"),
        Workspace:FindFirstChild("Stands"),
        Workspace:FindFirstChild("Tycoons")
    }
    for _, folder in ipairs(potentialFolders) do
        if folder then
            for _, base in ipairs(folder:GetChildren()) do
                local ownerVal = base:FindFirstChild("Owner") or base:FindFirstChild("Player") or base:FindFirstChild("OwnerName")
                if ownerVal and (ownerVal.Value == LocalPlayer or ownerVal.Value == LocalPlayer.Name or tostring(ownerVal.Value) == tostring(LocalPlayer.UserId)) then
                    return base
                end
                if base.Name == LocalPlayer.Name or base:GetAttribute("Owner") == LocalPlayer.UserId or base:GetAttribute("OwnerName") == LocalPlayer.Name then
                    return base
                end
            end
        end
    end

    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("Folder") then
            local owner = obj:FindFirstChild("Owner")
            if owner and (owner.Value == LocalPlayer or owner.Value == LocalPlayer.Name) then
                return obj
            end
        end
    end

    return nil
end

local function GetBaseDepositPosition()
    local base = FindMyBase()
    if base then
        local nest = base:FindFirstChild("Nest", true) or base:FindFirstChild("Deposit", true) or base:FindFirstChild("EggStand", true) or base:FindFirstChild("Spawn", true) or base:FindFirstChild("Collector", true) or base:FindFirstChild("Drop", true)
        if nest and nest:IsA("BasePart") then
            return nest.CFrame * CFrame.new(0, 3.2, 0)
        elseif base:IsA("Model") and (base.PrimaryPart or base:FindFirstChildWhichIsA("BasePart")) then
            local part = base.PrimaryPart or base:FindFirstChildWhichIsA("BasePart")
            return part.CFrame * CFrame.new(0, 3.2, 0)
        end
    end
    return SavedBaseCFrame or (HumanoidRootPart and HumanoidRootPart.CFrame)
end

-- Check if Character is currently holding / carrying an egg
local function HasCarriedEgg()
    if not Character then return false end
    for _, obj in ipairs(Character:GetChildren()) do
        if obj:IsA("Tool") or obj:IsA("Model") then
            local n = string.lower(obj.Name)
            if n:find("egg") or n:find("carry") or n:find("held") or n:find("item") or n:find("stolen") then
                return true
            end
        end
    end
    if LocalPlayer:FindFirstChild("Backpack") then
        for _, obj in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if obj:IsA("Tool") then
                local n = string.lower(obj.Name)
                if n:find("egg") or n:find("carry") or n:find("held") or n:find("stolen") then
                    return true
                end
            end
        end
    end
    return false
end

local function GetLocationKey(pos)
    return math.floor(pos.X / 4) .. "_" .. math.floor(pos.Y / 4) .. "_" .. math.floor(pos.Z / 4)
end

-- Helper to extract World Position & BasePart from any object
local function GetWorldPosition(obj)
    if not obj then return nil, nil end
    if obj:IsA("BasePart") then
        return obj.Position, obj
    elseif obj:IsA("Model") then
        local pivot = obj:GetPivot()
        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        return pivot.Position, part
    elseif obj:IsA("Attachment") then
        local p = obj.Parent:IsA("BasePart") and obj.Parent or nil
        return obj.WorldPosition, p
    elseif obj:IsA("ProximityPrompt") and obj.Parent then
        return GetWorldPosition(obj.Parent)
    end
    return nil, nil
end

-- ====================================================================
-- MASTER TOP FLOOR RARE EGG FINDER
-- (RULE: RARE EGG = THE ABSOLUTE HIGHEST ELEVATION 'Y' EGG ON TOP FLOOR)
-- ====================================================================

local function FindTopFloorRareEgg(ignoreCooldown)
    local now = os.clock()
    local candidates = {}
    local myBase = FindMyBase()
    local baseDeposit = GetBaseDepositPosition()
    local basePos = baseDeposit and baseDeposit.Position or Vector3.new(0, 0, 0)

    -- 1. Scan ALL ProximityPrompts across Workspace outside player base
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local pObj = prompt.Parent
            if pObj and not (myBase and pObj:IsDescendantOf(myBase)) and not pObj:FindFirstAncestorOfClass("Player") then
                local pos, part = GetWorldPosition(pObj)
                if pos and part then
                    local locKey = GetLocationKey(pos)
                    local isCoolingDown = not ignoreCooldown and (CooldownEggs[locKey] and (now < CooldownEggs[locKey]))
                    
                    if not isCoolingDown then
                        local dist = math.floor((pos - basePos).Magnitude)
                        table.insert(candidates, {
                            pos = pos,
                            y = pos.Y,
                            part = part,
                            model = pObj:IsA("Model") and pObj or part,
                            prompt = prompt,
                            locKey = locKey,
                            name = pObj.Name,
                            dist = dist
                        })
                    end
                end
            end
        end
    end

    -- 2. Scan egg models across Workspace as fallback
    if #candidates == 0 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart")) and not (myBase and obj:IsDescendantOf(myBase)) and not obj:FindFirstAncestorOfClass("Player") then
                local n = string.lower(obj.Name)
                if (n:find("egg") or n:find("rare") or n:find("secret") or n:find("floor") or n:find("top") or n:find("sky") or n:find("tier") or n:find("lucky")) and not n:find("gui") and not n:find("ui") then
                    local pos, part = GetWorldPosition(obj)
                    if pos and part then
                        local locKey = GetLocationKey(pos)
                        local isCoolingDown = not ignoreCooldown and (CooldownEggs[locKey] and (now < CooldownEggs[locKey]))
                        
                        if not isCoolingDown then
                            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            local dist = math.floor((pos - basePos).Magnitude)
                            table.insert(candidates, {
                                pos = pos,
                                y = pos.Y,
                                part = part,
                                model = obj:IsA("Model") and obj or part,
                                prompt = prompt,
                                locKey = locKey,
                                name = obj.Name,
                                dist = dist
                            })
                        end
                    end
                end
            end
        end
    end

    -- STRICT RULE: SORT BY MAXIMUM 'Y' ELEVATION (HIGHEST SKY FLOOR / TOP STEP FIRST!)
    table.sort(candidates, function(a, b)
        return a.y > b.y
    end)

    if #candidates > 0 then
        return candidates[1]
    end
    return nil
end

-- ====================================================================
-- 1. AUTO STEAL TOP FLOOR RARE EGG ENGINE
-- ====================================================================

task.spawn(function()
    while true do
        if Toggles.AutoStealRare and isAlive() then
            pcall(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum or hum.Health <= 0 then return end

                local best = FindTopFloorRareEgg(false)

                if best and best.part and best.part.Parent then
                    local eggTarget = best.part
                    local eggPrompt = best.prompt
                    local locKey = best.locKey
                    local baseReturnCFrame = GetBaseDepositPosition()
                    
                    if locKey then
                        CooldownEggs[locKey] = os.clock() + 4.5
                    end

                    -- Phase 1: Teleport Directly to Top Floor Rare Egg & Zero Velocity
                    hrp.Velocity = Vector3.zero
                    if hrp:FindFirstChild("AssemblyLinearVelocity") then
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end
                    hrp.CFrame = eggTarget.CFrame * CFrame.new(0, 2.5, 0)

                    -- Phase 2: Stay-and-Grab Execution Window (0.65s lock for full server replication)
                    local grabStart = os.clock()
                    while (os.clock() - grabStart < 0.65) and Toggles.AutoStealRare and isAlive() do
                        if eggTarget and eggTarget.Parent then
                            hrp.CFrame = eggTarget.CFrame * CFrame.new(0, 2.5, 0)
                            hrp.Velocity = Vector3.zero
                            if hrp:FindFirstChild("AssemblyLinearVelocity") then
                                hrp.AssemblyLinearVelocity = Vector3.zero
                            end
                        end

                        if eggPrompt and eggPrompt.Parent then
                            InstantTriggerPrompt(eggPrompt)
                        end

                        for _, p in ipairs(Workspace:GetDescendants()) do
                            if p:IsA("ProximityPrompt") and p.Parent then
                                local pPos = p.Parent:IsA("BasePart") and p.Parent.Position or nil
                                if pPos and (pPos - hrp.Position).Magnitude < 25 then
                                    InstantTriggerPrompt(p)
                                end
                            end
                        end

                        if eggTarget and eggTarget.Parent then
                            InstantTouch(hrp, eggTarget)
                        end

                        if HasCarriedEgg() or (eggPrompt and not eggPrompt.Enabled) then
                            break
                        end

                        task.wait(0.08)
                    end

                    task.wait(0.1)

                    -- Phase 3: Teleport Back to Base & Multi-Method Deposit
                    if baseReturnCFrame and isAlive() then
                        hrp.Velocity = Vector3.zero
                        if hrp:FindFirstChild("AssemblyLinearVelocity") then
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                        end
                        hrp.CFrame = baseReturnCFrame
                        task.wait(0.25)

                        local myBaseAfter = FindMyBase()
                        if myBaseAfter then
                            for _, bPrompt in ipairs(myBaseAfter:GetDescendants()) do
                                if bPrompt:IsA("ProximityPrompt") then
                                    InstantTriggerPrompt(bPrompt)
                                end
                            end
                            for _, part in ipairs(myBaseAfter:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    local n = string.lower(part.Name)
                                    if n:find("deposit") or n:find("nest") or n:find("collector") or n:find("stand") or n:find("egg") or n:find("drop") then
                                        InstantTouch(hrp, part)
                                    end
                                end
                            end
                        end

                        local depositRemotes = {"Deposit", "DepositEgg", "StoreEgg", "PlaceEgg", "CollectEgg", "SellEgg", "DropEgg", "SecureEgg", "ClaimEgg"}
                        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                                local rName = string.lower(rem.Name)
                                for _, dName in ipairs(depositRemotes) do
                                    if string.find(rName, string.lower(dName)) then
                                        pcall(function()
                                            if rem:IsA("RemoteEvent") then
                                                rem:FireServer()
                                                rem:FireServer(1)
                                                rem:FireServer(true)
                                            else
                                                rem:InvokeServer()
                                            end
                                        end)
                                    end
                                end
                            end
                        end

                        for _, p in ipairs(Workspace:GetDescendants()) do
                            if p:IsA("ProximityPrompt") and p.Parent then
                                local pPos = p.Parent:IsA("BasePart") and p.Parent.Position or nil
                                if pPos and (pPos - HumanoidRootPart.Position).Magnitude < 40 then
                                    local aText = string.lower(p.ActionText .. " " .. p.ObjectText .. " " .. p.Parent.Name)
                                    if aText:find("deposit") or aText:find("place") or aText:find("drop") or aText:find("store") or aText:find("nest") then
                                        InstantTriggerPrompt(p)
                                    end
                                end
                            end
                        end

                        task.wait(0.3)
                    end
                end
            end)
        end
        task.wait(0.35)
    end
end)

-- ====================================================================
-- 2. AUTO REBIRTH ENGINE (MULTI-METHOD REBIRTH SWEEPER)
-- ====================================================================

task.spawn(function()
    while true do
        if Toggles.AutoRebirth and isAlive() then
            pcall(function()
                local hrp = LocalPlayer.Character.HumanoidRootPart

                -- 1. Rebirth Remotes Trigger
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    local n = string.lower(rem.Name)
                    if n:find("rebirth") or n:find("prestige") or n:find("ascend") or n:find("rankup") or n:find("dorebirth") or n:find("buyrebirth") then
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

                -- 2. Rebirth Proximity Prompts in Workspace
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Parent then
                        local act = string.lower(prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name)
                        if act:find("rebirth") or act:find("prestige") or act:find("ascend") then
                            local pPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or nil
                            if pPos and (pPos - hrp.Position).Magnitude < 80 then
                                InstantTriggerPrompt(prompt)
                            end
                        end
                    end
                end

                -- 3. Rebirth Touch Pads
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local n = string.lower(part.Name)
                        if (n:find("rebirth") or n:find("prestige") or n:find("ascend")) and (part.Position - hrp.Position).Magnitude < 60 then
                            InstantTouch(hrp, part)
                        end
                    end
                end

                -- 4. GUI Rebirth Buttons (PlayerGui Click Simulation)
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui then
                    for _, btn in ipairs(pgui:GetDescendants()) do
                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                            local txt = string.lower(btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or ""))
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
        task.wait(0.8)
    end
end)

-- ====================================================================
-- 3. AUTO TRAIN JUMP
-- ====================================================================

task.spawn(function()
    while true do
        if Toggles.AutoTrainJump and isAlive() then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")

                -- Equip jump tool if available
                local tool = char:FindFirstChildWhichIsA("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                if tool and hum then
                    if tool.Parent ~= char then
                        hum:EquipTool(tool)
                    end
                    tool:Activate()
                end

                -- Sweep Training & Jump Remotes
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") then
                        local rName = string.lower(rem.Name)
                        if string.find(rName, "jump") or string.find(rName, "train") or string.find(rName, "click") or string.find(rName, "power") then
                            rem:FireServer()
                            rem:FireServer(1)
                            rem:FireServer(true)
                        end
                    end
                end

                -- Touch training pads in workspace/base
                if hrp then
                    for _, pad in ipairs(Workspace:GetDescendants()) do
                        if pad:IsA("BasePart") and (string.find(string.lower(pad.Name), "train") or string.find(string.lower(pad.Name), "trampoline") or string.find(string.lower(pad.Name), "jumppad")) then
                            InstantTouch(hrp, pad)
                        end
                    end
                end
            end)
        end
        task.wait(0.25)
    end
end)

-- ====================================================================
-- 4. RARE EGG ESP (EXCLUSIVELY HIGHLIGHTS ONLY THE TOP FLOOR RARE EGG)
-- ====================================================================

local function ClearSingleRareEggESP()
    if ESPStorage.SingleRareEgg then
        pcall(function() ESPStorage.SingleRareEgg:Destroy() end)
        ESPStorage.SingleRareEgg = nil
    end
    if ESPStorage.SingleRareEggBillboard then
        pcall(function() ESPStorage.SingleRareEggBillboard:Destroy() end)
        ESPStorage.SingleRareEggBillboard = nil
    end
end

task.spawn(function()
    while true do
        if Toggles.RareEggESP and isAlive() then
            pcall(function()
                local best = FindTopFloorRareEgg(true)
                if best and best.part and best.part.Parent then
                    local targetObj = best.model or best.part
                    local targetPart = best.part
                    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local distToMe = myHrp and math.floor((targetPart.Position - myHrp.Position).Magnitude) or best.dist
                    local floorY = math.floor(best.y)

                    if not ESPStorage.SingleRareEgg or ESPStorage.SingleRareEgg.Adornee ~= targetObj then
                        ClearSingleRareEggESP()

                        local hl = Instance.new("Highlight")
                        hl.Name = "JunejoSingleRareEggHighlight"
                        hl.FillColor = Color3.fromRGB(255, 215, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.25
                        hl.OutlineTransparency = 0
                        hl.Adornee = targetObj
                        hl.Parent = targetObj
                        ESPStorage.SingleRareEgg = hl

                        local bb = Instance.new("BillboardGui")
                        bb.Name = "JunejoSingleRareEggBillboard"
                        bb.Adornee = targetPart
                        bb.Size = UDim2.new(0, 165, 0, 28)
                        bb.StudsOffset = Vector3.new(0, 3.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = targetPart

                        local txt = Instance.new("TextLabel")
                        txt.Name = "RareTag"
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.Text = "👑 TOP FLOOR: " .. best.name .. " [Y: " .. floorY .. "]"
                        txt.TextColor3 = Color3.fromRGB(255, 220, 50)
                        txt.TextStrokeTransparency = 0
                        txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        txt.TextSize = 11
                        txt.Font = Enum.Font.GothamBold
                        txt.Parent = bb

                        ESPStorage.SingleRareEggBillboard = bb
                    else
                        if ESPStorage.SingleRareEggBillboard and ESPStorage.SingleRareEggBillboard:FindFirstChild("RareTag") then
                            ESPStorage.SingleRareEggBillboard.RareTag.Text = "👑 TOP FLOOR: " .. best.name .. " [Y: " .. floorY .. " | " .. distToMe .. "s]"
                        end
                    end
                else
                    ClearSingleRareEggESP()
                end
            end)
        else
            ClearSingleRareEggESP()
        end
        task.wait(1.5)
    end
end)

-- ====================================================================
-- 5. PLAYER ESP & BASE DEFENSE RADAR (RED HIGHLIGHT + DISTANCE)
-- ====================================================================

local function ClearPlayerESP()
    for _, item in ipairs(ESPStorage.Players) do
        if item then pcall(function() item:Destroy() end) end
    end
    ESPStorage.Players = {}
end

task.spawn(function()
    while true do
        if Toggles.PlayerESP and isAlive() then
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local char = plr.Character
                    local hrp = char.HumanoidRootPart

                    if not char:FindFirstChild("JunejoPlrHighlight") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "JunejoPlrHighlight"
                        hl.FillColor = Color3.fromRGB(255, 60, 60)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.35
                        hl.Adornee = char
                        hl.Parent = char
                        table.insert(ESPStorage.Players, hl)
                    end

                    if not hrp:FindFirstChild("JunejoPlrBillboard") then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "JunejoPlrBillboard"
                        bb.Adornee = hrp
                        bb.Size = UDim2.new(0, 150, 0, 26)
                        bb.StudsOffset = Vector3.new(0, 3, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = hrp

                        local txt = Instance.new("TextLabel")
                        txt.Name = "PlrLabel"
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextColor3 = Color3.fromRGB(255, 90, 90)
                        txt.TextSize = 11
                        txt.Font = Enum.Font.GothamBold
                        txt.Parent = bb
                        table.insert(ESPStorage.Players, bb)
                    end

                    local bb = hrp:FindFirstChild("JunejoPlrBillboard")
                    if bb and bb:FindFirstChild("PlrLabel") and myHrp then
                        local dist = math.floor((hrp.Position - myHrp.Position).Magnitude)
                        bb.PlrLabel.Text = "👤 " .. plr.DisplayName .. " [" .. dist .. "s]"
                    end
                end
            end
        else
            ClearPlayerESP()
        end
        task.wait(2)
    end
end)

-- ====================================================================
-- 6. PLAYER BASE ESP (CYAN HIGHLIGHT ON ALL ENEMY & OWN BASES)
-- ====================================================================

local function ClearBaseESP()
    for _, item in ipairs(ESPStorage.Bases) do
        if item then pcall(function() item:Destroy() end) end
    end
    ESPStorage.Bases = {}
end

task.spawn(function()
    while true do
        if Toggles.BaseESP then
            local potentialFolders = {
                Workspace:FindFirstChild("Bases"),
                Workspace:FindFirstChild("Plots"),
                Workspace:FindFirstChild("PlayerBases"),
                Workspace:FindFirstChild("Islands"),
                Workspace:FindFirstChild("Stands"),
                Workspace:FindFirstChild("Tycoons")
            }
            for _, folder in ipairs(potentialFolders) do
                if folder then
                    for _, base in ipairs(folder:GetChildren()) do
                        if (base:IsA("Model") or base:IsA("BasePart")) and not base:FindFirstChild("JunejoBaseHighlight") then
                            local part = base:IsA("BasePart") and base or (base.PrimaryPart or base:FindFirstChildWhichIsA("BasePart"))
                            if part then
                                local hl = Instance.new("Highlight")
                                hl.Name = "JunejoBaseHighlight"
                                hl.FillColor = Color3.fromRGB(0, 200, 255)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.45
                                hl.Adornee = base
                                hl.Parent = base
                                table.insert(ESPStorage.Bases, hl)

                                local bb = Instance.new("BillboardGui")
                                bb.Name = "JunejoBaseBillboard"
                                bb.Adornee = part
                                bb.Size = UDim2.new(0, 140, 0, 24)
                                bb.StudsOffset = Vector3.new(0, 3, 0)
                                bb.AlwaysOnTop = true
                                bb.Parent = part

                                local txt = Instance.new("TextLabel")
                                txt.Size = UDim2.new(1, 0, 1, 0)
                                txt.BackgroundTransparency = 1
                                txt.Text = "🏰 " .. base.Name .. " Base"
                                txt.TextColor3 = Color3.fromRGB(80, 220, 255)
                                txt.TextSize = 11
                                txt.Font = Enum.Font.GothamBold
                                txt.Parent = bb
                                table.insert(ESPStorage.Bases, bb)
                            end
                        end
                    end
                end
            end
        else
            ClearBaseESP()
        end
        task.wait(3)
    end
end)

-- ====================================================================
-- JUNEJO OFFICIAL COMPACT SCROLLING UI (5 FEATURES VISIBLE STANDARD)
-- ====================================================================

local CoreGui = game:GetService("CoreGui")
local ExistingUI = CoreGui:FindFirstChild("JunejoHubUI") or LocalPlayer.PlayerGui:FindFirstChild("JunejoHubUI")
if ExistingUI then ExistingUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Compact Standard MainFrame (280x225px)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 225)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -112)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Header (32px)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "TRADING JUMP TO STEAL EGG"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 11
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
    ClearSingleRareEggESP()
    ClearPlayerESP()
    ClearBaseESP()
    ScreenGui:Destroy() 
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Scrollable Content Frame (Shows Exactly 5 Items at a time, Scroll for rest!)
local ScrollingContent = Instance.new("ScrollingFrame")
ScrollingContent.Name = "ScrollingContent"
ScrollingContent.Size = UDim2.new(1, -24, 0, 145)
ScrollingContent.Position = UDim2.new(0, 12, 0, 38)
ScrollingContent.BackgroundTransparency = 1
ScrollingContent.BorderSizePixel = 0
ScrollingContent.ScrollBarThickness = 3
ScrollingContent.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 85)
ScrollingContent.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingContent.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollingContent.ClipsDescendants = true
ScrollingContent.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ScrollingContent

-- Helper function for Toggle Rows
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ScrollingContent
    
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
    
    RowBtn.MouseButton1Click:Connect(function()
        Toggles[configKey] = not Toggles[configKey]
        CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
        if callback then callback(Toggles[configKey]) end
    end)
end

-- 1-Click Action Row Helper
local function AddActionRow(text, btnText, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ScrollingContent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.58, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(0.40, 0, 1, 0)
    ActionBtn.Position = UDim2.new(0.60, 0, 0, 0)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ActionBtn.Text = btnText
    ActionBtn.TextColor3 = Color3.fromRGB(255, 220, 50)
    ActionBtn.TextSize = 11
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.Parent = Row

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ActionBtn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = ActionBtn

    ActionBtn.MouseButton1Click:Connect(function()
        if callback then callback(ActionBtn) end
    end)
end

-- Add Top Features List
AddToggleRow("Auto Steal Rare Egg", "AutoStealRare")
AddActionRow("Teleport to Rare Egg", "Teleport", function(btn)
    if isAlive() then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local best = FindTopFloorRareEgg(true)
            if best and best.part then
                hrp.Velocity = Vector3.zero
                if hrp:FindFirstChild("AssemblyLinearVelocity") then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
                hrp.CFrame = best.part.CFrame * CFrame.new(0, 3.5, 0)
                if best.prompt then
                    InstantTriggerPrompt(best.prompt)
                end
                if btn then
                    btn.Text = "✓ Teleported!"
                    btn.TextColor3 = Color3.fromRGB(80, 255, 120)
                    task.delay(1.2, function()
                        btn.Text = "Teleport"
                        btn.TextColor3 = Color3.fromRGB(255, 220, 50)
                    end)
                end
            else
                if btn then
                    btn.Text = "No Egg Found"
                    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
                    task.delay(1.2, function()
                        btn.Text = "Teleport"
                        btn.TextColor3 = Color3.fromRGB(255, 220, 50)
                    end)
                end
            end
        end
    end
end)
AddToggleRow("Instant Steal (0s Prompt)", "InstantPrompt")
AddActionRow("Save Base Position", "Set Base", function(btn)
    if isAlive() then
        SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        if btn then
            btn.Text = "Saved!"
            btn.TextColor3 = Color3.fromRGB(80, 255, 120)
            task.delay(1.2, function()
                btn.Text = "Set Base"
                btn.TextColor3 = Color3.fromRGB(255, 220, 50)
            end)
        end
    end
end)
AddToggleRow("Auto Rebirth", "AutoRebirth")
AddToggleRow("Auto Train Jump", "AutoTrainJump")
AddToggleRow("Rare Egg ESP (Gold)", "RareEggESP", function(state)
    if not state then ClearSingleRareEggESP() end
end)
AddToggleRow("Player ESP & Radar", "PlayerESP", function(state)
    if not state then ClearPlayerESP() end
end)
AddToggleRow("Player Base ESP", "BaseESP", function(state)
    if not state then ClearBaseESP() end
end)
AddToggleRow("Infinite Jump", "InfiniteJump")

-- Integrated WalkSpeed Row with Pill Adjuster
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, -6, 0, 23)
SpeedRow.BackgroundTransparency = 1
SpeedRow.Parent = ScrollingContent

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

local MarkCorner = Instance.new("UICorner")
MarkCorner.CornerRadius = UDim.new(0, 2)
MarkCorner.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
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
    CustomSpeedValue = math.max(16, CustomSpeedValue - 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

-- Footer (Pinned at bottom, 36px)
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
