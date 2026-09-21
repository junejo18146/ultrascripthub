-- =================================================================
-- JUNEJO ULTRA SCRIPT HUB - JUMP FOR ANIMALS (OFFICIAL SCRIPT)
-- Target Game: Jump for Animals (Roblox ID: 126870639873289)
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- UI Standard: UI 1 (Official Ultra Script Hub Classic Matte Dark)
-- Universal Mobile (Delta / Codex / Fluxus) & PC Compatible
-- =================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

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
    for _, name in ipairs({"JumpForAnimalsUI", "RobloxScriptUI_Badshah", "JunejoJumpForAnimalsUI", "JunejoUltraScriptHub_JumpForAnimals"}) do
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

-- =================================================================
-- GAME ASSETS & CONSTANTS (Extracted from Place Data)
-- =================================================================
local MapFolder = workspace:WaitForChild("Map", 15)
local StagesFolder = MapFolder and MapFolder:WaitForChild("Stages", 15)
local PlotsFolder = MapFolder and MapFolder:WaitForChild("Plots", 15)
local ClientGuardsFolder = MapFolder and MapFolder:WaitForChild("ClientGuards", 15)

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
local PlaceEggRemote = Remotes and Remotes:FindFirstChild("PlaceEggRequest")
local ReturnToBaseRemote = Remotes and Remotes:FindFirstChild("ReturnToBaseRequest")
local SquatTrainingRemote = Remotes and Remotes:FindFirstChild("SquatTrainingRequest")
local SquatBonusRemote = Remotes and Remotes:FindFirstChild("SquatBonusRequest")
local StopSquattingRemote = Remotes and Remotes:FindFirstChild("StopSquattingRequest")
local DropEggRemote = Remotes and Remotes:FindFirstChild("DropEggRequest")
local IncubatorRemote = Remotes and Remotes:FindFirstChild("Incubator")

-- Available Zones in Order of Progression
local AvailableZones = {
    "Meadow",
    "Jungle",
    "Coral Reef",
    "Savannah",
    "Desert",
    "Winter",
    "Crystal Mines",
    "Mystic Isles",
    "Celestial Heights",
    "Prehistoric",
    "The Underworld"
}

-- Guard Names for Complete Neutralization
local GuardNames = {
    "Owl", "Lionfish", "Polar Bear", "Lion", "Bear", "Gorilla",
    "Whale", "T-Rex", "FIRE PHOENIX", "Hyena", "Demon Troll"
}

-- Rarity Weights for Accurate Egg Selection
local RarityWeights = {
    ["Common"] = 1,
    ["Uncommon"] = 2,
    ["Rare"] = 3,
    ["Epic"] = 4,
    ["Legendary"] = 5,
    ["Mythic"] = 6,
    ["Ascended"] = 7,
    ["Celestial"] = 8,
    ["Divine"] = 9,
    ["Eternal"] = 10,
    ["Exclusive"] = 11
}

-- Animal-to-Rarity Mapping Extracted from Game Stages
local AnimalRarityMap = {
    -- The Underworld
    ["Wraith Knight"] = 9, ["Demon Troll"] = 8, ["Scorpion King"] = 8, ["Volcanic Cerebus"] = 6, ["Fire Imp"] = 5, ["Fire Snail"] = 4,
    -- Savannah
    ["HoneyBadger"] = 9, ["Shoebill"] = 8, ["Serval"] = 5, ["Jackal"] = 4, ["Aardvark"] = 3,
    -- Celestial Heights
    ["GARUDA"] = 5, ["Unicorn"] = 4, ["STYMPHALIANBIRD"] = 3, ["ARCHAEOPTERYX"] = 2, ["MICRORAPTOR"] = 1,
    -- Prehistoric
    ["Brachiosaurus"] = 5, ["Ankylosaurus"] = 4, ["Triceratops"] = 3, ["Velociraptor"] = 2, ["Gallimimus"] = 1,
    -- Meadow
    ["Owl"] = 5, ["Llama"] = 4, ["Pony"] = 3, ["Golden Retriver"] = 2, ["Bunny"] = 1, ["Chicken"] = 1, ["Guienna Pig"] = 1,
    -- Jungle
    ["Crocodile"] = 4, ["Parrot"] = 3, ["Archerfish"] = 3, ["Capybara"] = 2, ["Turtle"] = 1, ["Frog"] = 1,
    -- Coral Reef
    ["Butterflyfish"] = 4, ["Pufferfish"] = 4, ["Boxfish"] = 3, ["Seahorse"] = 2, ["Coral Goby"] = 1, ["Goldfish"] = 1,
    -- Desert
    ["Giraffe"] = 4, ["Ostrich"] = 3, ["Horse"] = 2, ["Goat"] = 1, ["Lizard"] = 1,
    -- Crystal Mines
    ["Jellyfish"] = 4, ["Bat"] = 3, ["Cat"] = 2, ["Hamster"] = 1, ["Snail"] = 1,
    -- Winter
    ["Stingray"] = 4, ["Barracuda"] = 3, ["Sailfish"] = 3, ["Tuna"] = 2, ["Pigeon"] = 1,
    -- Mystic Isles
    ["Swordfish"] = 4, ["Trumpetfish"] = 3, ["Moorish Idol"] = 3, ["Seal"] = 2, ["Prehistoric Dragonfly"] = 1, ["Koala"] = 1
}

-- Global Settings
_G.Settings = {
    AutoStealBest = false,
    SelectedStealZone = "Meadow",
    AutoTrain = false,
    RemoveGuards = false,
    AutoHatchEgg = false,
    AutoPlaceEgg = false,
    SelectedTPZone = "Meadow",
    Fly = false,
    FlySpeed = 50,
    WalkSpeedBoost = false,
    WalkSpeed = 50,
    InfJump = false,
    PlayerESP = false,
    NoClip = false,
    CustomBaseCFrame = nil
}

-- =================================================================
-- CORE HELPER FUNCTIONS
-- =================================================================
local function isAlive()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end

-- Robust Plot & Base Detection
local function getMyPlot()
    if not PlotsFolder then return nil end
    local myName = LocalPlayer.Name:lower()
    local myDisplay = LocalPlayer.DisplayName:lower()
    local myId = tostring(LocalPlayer.UserId)

    -- 1. Check Owner StringValue
    for _, plot in pairs(PlotsFolder:GetChildren()) do
        local owner = plot:FindFirstChild("Owner")
        if owner and owner:IsA("StringValue") then
            local val = tostring(owner.Value):lower()
            if val == myName or val == myDisplay or val == myId or val:find(myName) then
                return plot
            end
        end
    end

    -- 2. Check TextLabels inside Plots
    for _, plot in pairs(PlotsFolder:GetChildren()) do
        for _, desc in pairs(plot:GetDescendants()) do
            if desc:IsA("TextLabel") then
                local txt = desc.Text:lower()
                if txt:find(myName) or txt:find(myDisplay) then
                    return plot
                end
            end
        end
    end

    -- 3. Fallback: First Plot with Detector
    for _, plot in pairs(PlotsFolder:GetChildren()) do
        if plot:FindFirstChild("Detector") then
            return plot
        end
    end

    return PlotsFolder:GetChildren()[1]
end

local function getMyBaseCFrame()
    if _G.Settings.CustomBaseCFrame then
        return _G.Settings.CustomBaseCFrame
    end
    local plot = getMyPlot()
    if plot then
        local det = plot:FindFirstChild("Detector") or plot:FindFirstChild("DefaultSize")
        if det and det:IsA("BasePart") then
            return det.CFrame + Vector3.new(0, 3, 0)
        end
        local squat = plot:FindFirstChild("SquatZone")
        if squat then
            local floor = squat:FindFirstChild("Floor")
            local fDet = floor and (floor:FindFirstChild("Detector") or floor:FindFirstChild("Main"))
            if fDet and fDet:IsA("BasePart") then
                return fDet.CFrame + Vector3.new(0, 3, 0)
            end
        end
        if plot:IsA("Model") then
            return plot:GetPivot() + Vector3.new(0, 4, 0)
        end
    end
    return nil
end

local function getMySquatCFrame()
    local plot = getMyPlot()
    if plot then
        local squat = plot:FindFirstChild("SquatZone")
        if squat then
            local floor = squat:FindFirstChild("Floor")
            local fDet = floor and (floor:FindFirstChild("Detector") or floor:FindFirstChild("Main"))
            if fDet and fDet:IsA("BasePart") then
                return fDet.CFrame + Vector3.new(0, 2.5, 0), fDet
            end
        end
    end
    return getMyBaseCFrame(), nil
end

-- Multi-touch with Character
local function TouchWithCharacter(targetPart)
    if not targetPart or not isAlive() then return end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and firetouchinterest then
        pcall(function()
            firetouchinterest(hrp, targetPart, 0)
            task.wait()
            firetouchinterest(hrp, targetPart, 1)
        end)
    end
end

-- =================================================================
-- ACCURATE EGG DETECTION & VALIDATION
-- =================================================================

-- Checks if a specific egg is currently carried by LocalPlayer
local function isEggCarriedByMe(egg)
    if not egg or not egg.Parent then return false end

    -- A placed egg in any plot is NEVER considered "carried"
    if PlotsFolder and egg:IsDescendantOf(PlotsFolder) then
        return false
    end

    -- 1. Check CarriedByUserId Attribute (Primary game mechanic)
    local carrier = egg:GetAttribute("CarriedByUserId")
    if carrier and carrier == LocalPlayer.UserId then
        return true
    end

    -- 2. Check if egg was reparented directly into Character
    if LocalPlayer.Character and egg:IsDescendantOf(LocalPlayer.Character) then
        return true
    end

    -- 3. Check if egg is welded to Character
    if isAlive() then
        for _, joint in pairs(LocalPlayer.Character:GetDescendants()) do
            if joint:IsA("Weld") or joint:IsA("WeldConstraint") or joint:IsA("Motor6D") then
                if (joint.Part0 and joint.Part0:IsDescendantOf(egg)) or (joint.Part1 and joint.Part1:IsDescendantOf(egg)) then
                    return true
                end
            end
        end
    end

    return false
end

-- Returns any currently carried egg from stages or character
local function getAnyCarriedEgg()
    if not isAlive() then return nil end

    -- Check all stages for an egg flagged with our UserId
    if StagesFolder then
        for _, stage in pairs(StagesFolder:GetChildren()) do
            local spawned = stage:FindFirstChild("SpawnedEggs")
            if spawned then
                for _, egg in pairs(spawned:GetChildren()) do
                    if egg:IsA("Model") and isEggCarriedByMe(egg) then
                        return egg
                    end
                end
            end
        end
    end

    -- Check character for any attached egg model with EggRoot
    local char = LocalPlayer.Character
    if char then
        for _, child in pairs(char:GetChildren()) do
            if child:IsA("Model") and (child:FindFirstChild("EggRoot") or child:GetAttribute("EggId")) then
                return child
            end
        end
    end

    return nil
end

local function hasEggCarried()
    return getAnyCarriedEgg() ~= nil
end

-- Find Best Egg In Chosen Zone
local function getBestEggInZone(zoneName)
    if not StagesFolder then return nil end
    local stage = StagesFolder:FindFirstChild(zoneName)
    if not stage then return nil end
    local spawnedFolder = stage:FindFirstChild("SpawnedEggs")
    if not spawnedFolder then return nil end

    local bestEgg = nil
    local highestRank = -1

    local eggs = spawnedFolder:GetChildren()
    if #eggs == 0 then return nil end

    for _, eggModel in pairs(eggs) do
        if eggModel:IsA("Model") then
            local carrier = eggModel:GetAttribute("CarriedByUserId")
            -- Only consider eggs that are either not carried by anyone, or already carried by us
            if not carrier or carrier == 0 or carrier == LocalPlayer.UserId then
                local eggRank = 1

                -- Check Rarity Attribute directly
                local attrRarity = eggModel:GetAttribute("Rarity")
                if attrRarity and RarityWeights[attrRarity] then
                    eggRank = math.max(eggRank, RarityWeights[attrRarity])
                end

                -- Check RarityLabel BillboardGui
                local rarityLabel = eggModel:FindFirstChild("RarityLabel")
                if rarityLabel then
                    local frame = rarityLabel:FindFirstChild("Frame")
                    if frame then
                        for _, child in pairs(frame:GetChildren()) do
                            if child:IsA("TextLabel") and child.Text and child.Text ~= "" then
                                local weight = RarityWeights[child.Text]
                                if weight then
                                    eggRank = math.max(eggRank, weight)
                                end
                            end
                        end
                    end
                end

                -- Check Animal Name fallback
                local animalWeight = AnimalRarityMap[eggModel.Name]
                if animalWeight then
                    eggRank = math.max(eggRank, animalWeight)
                end

                if eggRank > highestRank then
                    highestRank = eggRank
                    bestEgg = eggModel
                end
            end
        end
    end

    -- Fallback to first available egg in the zone
    if not bestEgg and #eggs > 0 then
        for _, e in pairs(eggs) do
            local carrier = e:GetAttribute("CarriedByUserId")
            if not carrier or carrier == 0 or carrier == LocalPlayer.UserId then
                bestEgg = e
                break
            end
        end
    end

    return bestEgg
end

-- Complete Guard Remover
local function removeAllGuards()
    if ClientGuardsFolder then
        for _, guard in pairs(ClientGuardsFolder:GetChildren()) do
            pcall(function()
                for _, part in pairs(guard:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.CanTouch = false
                        part.CanQuery = false
                        part.Transparency = 1
                    end
                end
                guard:PivotTo(CFrame.new(0, -99999, 0))
                guard:Destroy()
            end)
        end
    end

    if MapFolder then
        for _, g in pairs(MapFolder:GetChildren()) do
            if g:IsA("Model") and table.find(GuardNames, g.Name) then
                pcall(function()
                    g:PivotTo(CFrame.new(0, -99999, 0))
                    g:Destroy()
                end)
            end
        end
    end
end

-- =================================================================
-- STEAL & DELIVERY MECHANICS
-- =================================================================

-- 1. Steals egg from nest (Guarantees hold completion before returning)
local function stealEgg(targetEgg)
    if not targetEgg or not targetEgg.Parent or not isAlive() then return false end
    local eggRoot = targetEgg:FindFirstChild("EggRoot") or targetEgg:FindFirstChildWhichIsA("BasePart", true)
    if not eggRoot then return false end

    local char = LocalPlayer.Character
    local hrp = char.HumanoidRootPart

    -- Teleport directly onto the egg nest
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = eggRoot.CFrame + Vector3.new(0, 1.5, 0)
    task.wait(0.12)

    local prompt = targetEgg:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return false end

    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = 50
    prompt.Enabled = true

    -- Method 1: Executor Proximity Hook
    if fireproximityprompt then
        pcall(function() fireproximityprompt(prompt) end)
        pcall(function() fireproximityprompt(prompt, 0) end)
        pcall(function() fireproximityprompt(prompt, 1) end)
    end

    -- Method 2: Luau Native InputHoldBegin
    pcall(function()
        if prompt.InputHoldBegin then
            prompt:InputHoldBegin()
        end
    end)

    -- Method 3: VirtualInputManager Key Simulation
    local VIM = pcall(function() return game:GetService("VirtualInputManager") end) and game:GetService("VirtualInputManager")
    if VIM then
        pcall(function()
            VIM:SendKeyEvent(true, prompt.KeyboardKeyCode or Enum.KeyCode.E, false, game)
        end)
    end

    -- Wait with character anchored at egg until server grants ownership
    local holdStart = tick()
    local holdDuration = (prompt.HoldDuration and prompt.HoldDuration > 0) and prompt.HoldDuration or 0.8
    local maxWait = math.clamp(holdDuration + 0.8, 1.2, 2.5)

    while (tick() - holdStart) < maxWait do
        task.wait(0.1)

        -- Keep character glued to egg
        if isAlive() and eggRoot and eggRoot.Parent then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = eggRoot.CFrame + Vector3.new(0, 1.5, 0)
        end

        -- Re-ping executor prompt hook
        if fireproximityprompt and prompt.Parent then
            pcall(function() fireproximityprompt(prompt) end)
        end

        -- Check if egg was awarded to local player
        if isEggCarriedByMe(targetEgg) or hasEggCarried() then
            break
        end
    end

    -- Release input hold
    pcall(function()
        if prompt.InputHoldEnd then
            prompt:InputHoldEnd()
        end
    end)
    if VIM then
        pcall(function()
            VIM:SendKeyEvent(false, prompt.KeyboardKeyCode or Enum.KeyCode.E, false, game)
        end)
    end

    task.wait(0.15)
    return isEggCarriedByMe(targetEgg) or hasEggCarried()
end

-- 2. Delivers egg to Base and deposits it into the plot
local function deliverEggToBase(carriedEgg)
    if not isAlive() then return end
    local char = LocalPlayer.Character
    local hrp = char.HumanoidRootPart
    local baseCF = getMyBaseCFrame()

    -- 1. Teleport to base plot
    if baseCF then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = baseCF
        task.wait(0.2)
    elseif ReturnToBaseRemote then
        ReturnToBaseRemote:FireServer()
        task.wait(0.3)
    end

    -- 2. Trigger plot detector touch
    local plot = getMyPlot()
    local det = plot and (plot:FindFirstChild("Detector") or plot:FindFirstChild("DefaultSize"))
    if det then
        TouchWithCharacter(det)
    end

    -- 3. Fire PlaceEggRequest remote
    if PlaceEggRemote then
        if carriedEgg then
            PlaceEggRemote:FireServer(carriedEgg)
        end
        PlaceEggRemote:FireServer()
    end

    -- 4. Wait until the egg is placed (no longer carried)
    local placeStart = tick()
    while (tick() - placeStart) < 1.2 and isAlive() do
        if not hasEggCarried() and (not carriedEgg or not isEggCarriedByMe(carriedEgg)) then
            break
        end
        if PlaceEggRemote then
            PlaceEggRemote:FireServer(carriedEgg)
            PlaceEggRemote:FireServer()
        end
        if det then
            TouchWithCharacter(det)
        end
        task.wait(0.15)
    end

    task.wait(0.15)
end

-- =================================================================
-- BACKGROUND LOGIC & AUTOMATION LOOPS
-- =================================================================

-- 1. AUTO STEAL BEST EGG LOOP (ZONE-FOCUSED & NEVER VISITS BASE WITHOUT EGG)
task.spawn(function()
    while task.wait(0.2) do
        if _G.Settings.AutoStealBest and isAlive() then
            local zoneName = _G.Settings.SelectedStealZone or "Meadow"

            -- Step 1: If player somehow already has an egg, deliver it first
            local alreadyCarried = getAnyCarriedEgg()
            if alreadyCarried then
                deliverEggToBase(alreadyCarried)
            else
                -- Step 2: Find the best egg in the chosen zone
                local bestEgg = getBestEggInZone(zoneName)
                if bestEgg and bestEgg.Parent then
                    -- Attempt steal
                    local success = stealEgg(bestEgg)

                    -- CRITICAL: ONLY DELIVER TO BASE IF EGG WAS ACTUALLY STOLEN!
                    if success or isEggCarriedByMe(bestEgg) or hasEggCarried() then
                        deliverEggToBase(bestEgg)
                    end
                else
                    -- No egg currently spawned in this zone:
                    -- Stay right inside the chosen zone waiting for an egg!
                    local stage = StagesFolder and StagesFolder:FindFirstChild(zoneName)
                    if stage then
                        local anchorPart = stage:FindFirstChild("SignPart") or stage:FindFirstChildWhichIsA("BasePart", true)
                        if anchorPart and isAlive() then
                            local hrp = LocalPlayer.Character.HumanoidRootPart
                            if (hrp.Position - anchorPart.Position).Magnitude > 30 then
                                hrp.AssemblyLinearVelocity = Vector3.zero
                                hrp.CFrame = anchorPart.CFrame + Vector3.new(0, 4, 0)
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end
        end
    end
end)

-- 2. AUTO TRAIN (SQUATS) LOOP
task.spawn(function()
    while task.wait(0.2) do
        if _G.Settings.AutoTrain and isAlive() then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local squatCF, detPart = getMySquatCFrame()

            -- Position player inside SquatZone Detector
            if squatCF then
                if (hrp.Position - squatCF.Position).Magnitude > 5 then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.CFrame = squatCF
                    task.wait(0.15)
                end
                if detPart then
                    TouchWithCharacter(detPart)
                end
            end

            -- Fire Squat Remotes
            if SquatTrainingRemote then
                SquatTrainingRemote:FireServer()
            end
            if SquatBonusRemote then
                SquatBonusRemote:FireServer()
            end

            -- Equip training barbell tool
            local char = LocalPlayer.Character
            local hum = char:FindFirstChild("Humanoid")
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool and hum then
                for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and not t.Name:lower():find("egg") then
                        hum:EquipTool(t)
                        tool = t
                        break
                    end
                end
            end
            if tool then
                tool:Activate()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(500, 500))
                task.wait(0.04)
                VirtualUser:Button1Up(Vector2.new(500, 500))
            end
        end
    end
end)

-- 3. REMOVE GUARDS CONTINUOUS LOOP
task.spawn(function()
    while task.wait(0.3) do
        if _G.Settings.RemoveGuards then
            removeAllGuards()
        end
    end
end)

if ClientGuardsFolder then
    ClientGuardsFolder.ChildAdded:Connect(function(child)
        if _G.Settings.RemoveGuards then
            task.wait(0.05)
            pcall(function()
                for _, part in pairs(child:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.CanTouch = false
                        part.Transparency = 1
                    end
                end
                child:PivotTo(CFrame.new(0, -99999, 0))
                child:Destroy()
            end)
        end
    end)
end

-- 4. AUTO PLACE EGG LOOP
task.spawn(function()
    while task.wait(0.35) do
        if _G.Settings.AutoPlaceEgg and isAlive() and hasEggCarried() then
            local baseCF = getMyBaseCFrame()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            if PlaceEggRemote then
                PlaceEggRemote:FireServer()
            end
            local plot = getMyPlot()
            if plot then
                local det = plot:FindFirstChild("Detector") or plot:FindFirstChild("DefaultSize")
                if det then
                    TouchWithCharacter(det)
                end
            end
        end
    end
end)

-- 5. AUTO HATCH EGG LOOP
task.spawn(function()
    while task.wait(0.4) do
        if _G.Settings.AutoHatchEgg and isAlive() then
            local plot = getMyPlot()
            if plot then
                local placedEggs = plot:FindFirstChild("PlacedEggs")
                if placedEggs then
                    for _, prompt in pairs(placedEggs:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            if fireproximityprompt then
                                pcall(function() fireproximityprompt(prompt) end)
                            end
                        end
                    end
                end
            end
            if IncubatorRemote then
                IncubatorRemote:FireServer()
            end
        end
    end
end)

-- 6. NOCLIP OVERRIDE
RunService.Stepped:Connect(function()
    if _G.Settings.NoClip and isAlive() then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 7. INFINITE JUMP
UIS.JumpRequest:Connect(function()
    if _G.Settings.InfJump and isAlive() then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 8. FLIGHT MECHANICS
local bv, bg
RunService.RenderStepped:Connect(function()
    if _G.Settings.Fly and isAlive() then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local cam = workspace.CurrentCamera

        if not bv or not bv.Parent then
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Parent = hrp
        end
        if not bg or not bg.Parent then
            bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            bg.P = 10000
            bg.Parent = hrp
        end

        local moveDir = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + (cam.CFrame.LookVector) end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - (cam.CFrame.LookVector) end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - (cam.CFrame.RightVector) end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + (cam.CFrame.RightVector) end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        local speed = _G.Settings.FlySpeed or 50
        bv.Velocity = moveDir * speed
        bg.CFrame = cam.CFrame
    else
        if bv then bv:Destroy(); bv = nil end
        if bg then bg:Destroy(); bg = nil end
    end
end)

-- 9. WALKSPEED BOOST
RunService.Heartbeat:Connect(function()
    if _G.Settings.WalkSpeedBoost and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = _G.Settings.WalkSpeed or 50
        end
    end
end)

-- 10. PLAYER ESP
local espBoxes = {}
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local hrp = char.HumanoidRootPart
            if not espBoxes[player] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillColor = Color3.fromRGB(168, 85, 247)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = char
                highlight.Parent = char

                local bill = Instance.new("BillboardGui")
                bill.Name = "ESP_Name"
                bill.Size = UDim2.new(0, 100, 0, 20)
                bill.AlwaysOnTop = true
                bill.Adornee = hrp

                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = player.DisplayName
                txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 10
                txt.Parent = bill
                bill.Parent = hrp

                espBoxes[player] = { Highlight = highlight, Bill = bill, Text = txt }
            else
                local data = espBoxes[player]
                if data.Highlight and data.Highlight.Parent ~= char then
                    data.Highlight.Adornee = char
                    data.Highlight.Parent = char
                end
                if data.Bill and data.Bill.Parent ~= hrp then
                    data.Bill.Adornee = hrp
                    data.Bill.Parent = hrp
                end
                if data.Text and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                    data.Text.Text = string.format("%s [%dm]", player.DisplayName, dist)
                end
            end
        else
            if espBoxes[player] then
                pcall(function()
                    if espBoxes[player].Highlight then espBoxes[player].Highlight:Destroy() end
                    if espBoxes[player].Bill then espBoxes[player].Bill:Destroy() end
                end)
                espBoxes[player] = nil
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if _G.Settings.PlayerESP then
        updateESP()
    else
        for p, data in pairs(espBoxes) do
            pcall(function()
                if data.Highlight then data.Highlight:Destroy() end
                if data.Bill then data.Bill:Destroy() end
            end)
        end
        table.clear(espBoxes)
    end
end)

-- =================================================================
-- UI CREATION (UI 1: OFFICIAL ULTRA SCRIPT HUB CLASSIC MATTE DARK)
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoUltraScriptHub_JumpForAnimals"
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
TitleLabel.Text = "JUMP FOR ANIMALS"
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

UIS.InputChanged:Connect(function(input)
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
-- UI 1 COMPONENT GENERATORS (Checkboxes, Steppers, Action Buttons, Dropdowns)
-- =================================================================
local currentLayoutOrder = 0

-- 1. Compact Toggle Row with Rounded-Square Checkbox
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

-- 2. Full-Width Dark Rounded Action Button
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

-- 3. Stepper Pill Control Row (e.g., [  -   50   +  ])
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

-- 4. Clean Inline Dropdown Row
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

-- 1. Auto Steal Best Egg Toggle
local autoStealToggleController
autoStealToggleController = AddToggleRow("Auto Steal Best Egg", false, function(state)
    _G.Settings.AutoStealBest = state
    -- If turned ON and no egg in hands, immediately teleport to chosen zone
    if state and isAlive() and not hasEggCarried() and StagesFolder then
        local stage = StagesFolder:FindFirstChild(_G.Settings.SelectedStealZone or "Meadow")
        if stage then
            local part = stage:FindFirstChild("SignPart") or stage:FindFirstChildWhichIsA("BasePart", true)
            if part then
                LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 4, 0)
            end
        end
    end
end)

-- 2. Steal Zone Dropdown
AddDropdownRow("Steal Zone", AvailableZones, 1, function(selectedZone)
    _G.Settings.SelectedStealZone = selectedZone

    -- Automatically activate Auto Steal if not already running
    if not _G.Settings.AutoStealBest and autoStealToggleController then
        autoStealToggleController.SetState(true)
    end

    -- Instantly teleport to that chosen zone to initiate egg stealing
    if isAlive() and StagesFolder then
        local stage = StagesFolder:FindFirstChild(selectedZone)
        if stage then
            local part = stage:FindFirstChild("SignPart") or stage:FindFirstChildWhichIsA("BasePart", true)
            if part then
                LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 4, 0)
            end
        end
    end
end)

-- 3. Auto Train (Squats) Toggle
AddToggleRow("Auto Train (Squats)", false, function(state)
    _G.Settings.AutoTrain = state
end)

-- 4. Remove Guards Toggle
AddToggleRow("Remove Guards", false, function(state)
    _G.Settings.RemoveGuards = state
    if state then
        removeAllGuards()
    end
end)

-- 5. Auto Place Egg Toggle
AddToggleRow("Auto Place Egg", false, function(state)
    _G.Settings.AutoPlaceEgg = state
end)

-- 6. Auto Hatch Egg Toggle
AddToggleRow("Auto Hatch Egg", false, function(state)
    _G.Settings.AutoHatchEgg = state
end)

-- 7. TP to Base Action Button
AddActionButton("TP to Base", function()
    local baseCF = getMyBaseCFrame()
    if baseCF and isAlive() then
        LocalPlayer.Character.HumanoidRootPart.CFrame = baseCF
    elseif ReturnToBaseRemote then
        ReturnToBaseRemote:FireServer()
    end
end)

-- 8. Set Base Spot (Here) Action Button
AddActionButton("Set Base Spot (Here)", function()
    if isAlive() then
        _G.Settings.CustomBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

-- 9. Teleport to Zone Dropdown
AddDropdownRow("Teleport to Zone", AvailableZones, 1, function(targetZone)
    _G.Settings.SelectedTPZone = targetZone
    if isAlive() and StagesFolder then
        local stage = StagesFolder:FindFirstChild(targetZone)
        if stage then
            local part = stage:FindFirstChild("SignPart") or stage:FindFirstChildWhichIsA("BasePart", true)
            if part then
                LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end
end)

-- 10. Fly Mode Toggle & Stepper
AddToggleRow("Fly Mode", false, function(state)
    _G.Settings.Fly = state
end)

AddStepperRow("Fly Speed", 10, 250, 50, 10, function(val)
    _G.Settings.FlySpeed = val
end)

-- 11. WalkSpeed Boost Toggle & Stepper
AddToggleRow("WalkSpeed Boost", false, function(state)
    _G.Settings.WalkSpeedBoost = state
    if not state and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)

AddStepperRow("WalkSpeed", 16, 250, 50, 10, function(val)
    _G.Settings.WalkSpeed = val
    if _G.Settings.WalkSpeedBoost and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
end)

-- 12. Infinite Jump Toggle
AddToggleRow("Infinite Jump", false, function(state)
    _G.Settings.InfJump = state
end)

-- 13. Player ESP Toggle
AddToggleRow("Player ESP", false, function(state)
    _G.Settings.PlayerESP = state
end)

-- 14. NoClip Toggle
AddToggleRow("NoClip", false, function(state)
    _G.Settings.NoClip = state
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

print("[ULTRA SCRIPT HUB] Jump for Animals loaded successfully!")
