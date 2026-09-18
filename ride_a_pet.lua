--[[
    ========================================================================
    JUNEJO ULTRA SCRIPT HUB - RIDE A PET
    ========================================================================
    Author: Made by Junejo (junejo18146)
    Target Game: Ride A Pet (Roblox Place: 124216119978534)
    Repository: junejo18146/ultrascripthub
    File: ride_a_pet.lua
    Universal Mobile (Delta / Codex / Fluxus / Arceus X) & PC Compatible
    UI Standard: UI 1 - Official Ultra Script Hub Classic Matte Dark (#0F0F11)
    
    Features Included:
        1. Auto Steal Egg (Automatic teleport, grab rare egg & base nest deposit)
        2. Steal Zone Selector (< Zone > Interactive Selector Pill)
        3. Auto Hatch Eggs (Automatic incubator & nest hatcher)
        4. Auto Place Egg (Automatic egg placing into nests)
        5. Auto Equip Best Pet (Mounts highest tier pet)
        6. Rare Egg ESP (Highlights rarest map eggs with distance & excludes base eggs)
        7. Teleport Zone Selector (< Destination > Interactive Selector Pill)
        8. Teleport To Zone (1-Click Action Button)
        9. Teleport To My Base (1-Click Action Button)
        10. WalkSpeed Boost (Integrated - / + Stepper Controller: 16 to 250)
        11. Fly Mode (Integrated - / + Stepper Controller: 20 to 200)
        12. NoClip Mode (Walk through fences, walls & barriers)
        13. 24/7 Anti-AFK Engine (Prevents 20-minute disconnects)
    ========================================================================
--]]

local GameName = "RIDE A PET"
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

-- =================================================================
-- SAFE UI CONTAINER RESOLVER & INSTANT CLEANUP
-- =================================================================
local function GetSafeUIContainer()
    local container = nil
    pcall(function()
        if gethui then container = gethui() end
    end)
    if not container then
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 2)
            if playerGui then container = playerGui end
        end)
    end
    if not container then
        pcall(function()
            if syn and syn.protect_gui then container = CoreGui end
        end)
    end
    if not container then
        pcall(function() container = CoreGui end)
    end
    return container or LocalPlayer:WaitForChild("PlayerGui")
end

local UIContainer = GetSafeUIContainer()

-- Cleanup Previous UI Instances
pcall(function()
    local names = {"JunejoRideAPetUI", "RobloxScriptUI_RideAPet", "JunejoHubUI"}
    for _, name in ipairs(names) do
        pcall(function()
            if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        end)
        pcall(function()
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
                LocalPlayer.PlayerGui[name]:Destroy()
            end
        end)
        pcall(function()
            if gethui and gethui():FindFirstChild(name) then gethui()[name]:Destroy() end
        end)
    end
end)

-- =================================================================
-- STATE & SETTINGS
-- =================================================================
local Toggles = {
    AutoSteal = false,
    AutoHatch = false,
    AutoPlace = false,
    AutoEquipBest = false,
    NoClip = false,
    WalkSpeed = false,
    Fly = false,
    BestEggESP = false,
    AntiAFK = true
}

local CustomSpeedValue = 45
local CustomFlySpeed = 50
local StealZoneIndex = 1
local TeleportZoneIndex = 1

-- Egg Rarity Ranking (Higher score = Rarer Egg)
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
    "Best Egg (Auto)",
    "Ethereal Zone",
    "Divine / Diamond",
    "Mythic / Golden",
    "Legend / Flaming",
    "Epic / Skull",
    "Rare / Crystal",
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

-- Non-blocking Remote Resolver
local function GetGameRemote(remoteName)
    local targetRemote = nil
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local gameRemotes = remotes and remotes:FindFirstChild("Game")
        if gameRemotes then
            targetRemote = gameRemotes:FindFirstChild(remoteName)
        end
        if not targetRemote and remotes then
            targetRemote = remotes:FindFirstChild(remoteName, true)
        end
        if not targetRemote then
            targetRemote = ReplicatedStorage:FindFirstChild(remoteName, true)
        end
    end)
    return targetRemote
end

-- =================================================================
-- HELPER FUNCTIONS & MOUNT-AWARE TELEPORTATION
-- =================================================================

-- Find player's assigned plot in Workspace.Plots
local function GetMyPlot()
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if plotsFolder then
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            local data = plot:FindFirstChild("Data")
            if data then
                local ownerVal = data:FindFirstChild("Owner")
                if ownerVal and (ownerVal.Value == LocalPlayer or (ownerVal.Value and ownerVal.Value.Name == LocalPlayer.Name)) then
                    return plot
                end
            end
        end
    end
    return nil
end

-- Check if an egg is inside ANY player's base/nests
local function IsEggInsideAnyBase(egg)
    if not egg or not egg.Parent then return true end

    local plotsFolder = Workspace:FindFirstChild("Plots")
    if plotsFolder then
        if egg:IsDescendantOf(plotsFolder) then
            return true
        end

        local eggPart = egg:FindFirstChild("Handle") or egg:FindFirstChild("EggBase") or egg.PrimaryPart or egg:FindFirstChildOfClass("BasePart")
        if eggPart then
            for _, plot in ipairs(plotsFolder:GetChildren()) do
                local baseplate = plot:FindFirstChild("Baseplate")
                if baseplate and baseplate:IsA("BasePart") then
                    local dist = (eggPart.Position - baseplate.Position).Magnitude
                    local radius = math.max(baseplate.Size.X, baseplate.Size.Z) * 0.65
                    if dist <= radius then
                        return true
                    end
                end
            end
        end
    end

    return false
end

-- Teleport player character and mount safely
local function SafeTeleport(targetCFrame)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if hum and hum.SeatPart then
            local mount = hum.SeatPart.Parent
            if mount and mount:IsA("Model") then
                local mountRoot = mount.PrimaryPart or mount:FindFirstChild("RootPart") or mount:FindFirstChild("HumanoidRootPart") or hum.SeatPart
                if mountRoot and mountRoot:IsA("BasePart") then
                    mountRoot.AssemblyLinearVelocity = Vector3.zero
                    mountRoot.AssemblyAngularVelocity = Vector3.zero
                    mount:PivotTo(targetCFrame)
                    mountRoot.CFrame = targetCFrame
                end
            end
        end

        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        char:PivotTo(targetCFrame)
        hrp.CFrame = targetCFrame

        task.spawn(function()
            for _ = 1, 3 do
                task.wait(0.04)
                if hrp and hrp.Parent then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    char:PivotTo(targetCFrame)
                    hrp.CFrame = targetCFrame
                end
            end
        end)
    end)
end

-- Teleport directly to named game location / stall / spawn
local function TeleportToLocation(destName)
    local char = LocalPlayer.Character
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
        else
            local tpRemote = GetGameRemote("TeleportToPlot")
            if tpRemote then tpRemote:FireServer() end
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

-- Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK and VirtualUser then
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end)
    end
end)

-- NoClip System
RunService.Stepped:Connect(function()
    if Toggles.NoClip and LocalPlayer.Character then
        pcall(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- WalkSpeed System
local function ApplyWalkSpeed()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Toggles.WalkSpeed and CustomSpeedValue or 16
        end
    end)
end

RunService.Stepped:Connect(function()
    if Toggles.WalkSpeed and not Toggles.Fly and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= CustomSpeedValue then
            hum.WalkSpeed = CustomSpeedValue
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    ApplyWalkSpeed()
end)

-- Fly System (Mobile Touch & PC WASD Compatible)
local flyBodyGyro, flyBodyVelocity, flyConnection

local function StopFly()
    pcall(function()
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
        if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end)
end

local function StartFly()
    StopFly()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
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
            if not Toggles.Fly or not hrp.Parent then
                StopFly()
                return
            end

            local cam = Workspace.CurrentCamera
            local moveDir = hum.MoveDirection
            local speed = CustomFlySpeed

            flyBodyGyro.CFrame = cam.CFrame
            if moveDir.Magnitude > 0 then
                flyBodyVelocity.Velocity = (cam.CFrame.LookVector * (moveDir.Z * -1) + cam.CFrame.RightVector * moveDir.X).Unit * speed
            else
                flyBodyVelocity.Velocity = Vector3.zero
            end
        end)
    end)
end

-- =================================================================
-- CORE AUTOMATION SYSTEMS
-- =================================================================

local function GetBestStealEgg()
    local renderedEggs = Workspace:FindFirstChild("RenderedEggs")
    if not renderedEggs then return nil end

    local eggs = renderedEggs:GetChildren()
    if #eggs == 0 then return nil end

    local selectedZone = StealZoneOptions[StealZoneIndex] or "Best Egg (Auto)"
    local bestEgg = nil
    local bestScore = -1

    for _, egg in ipairs(eggs) do
        if egg:IsA("Model") and not IsEggInsideAnyBase(egg) then
            local eggName = egg.Name:lower()
            local score = EggRarityRank[eggName] or 1

            if selectedZone:find("Best Egg") then
                if score > bestScore then
                    bestScore = score
                    bestEgg = egg
                end
            elseif selectedZone:find("Ethereal") then
                if eggName:find("ethereal") or eggName:find("blackhole") then
                    return egg
                end
            elseif selectedZone:find("Divine") or selectedZone:find("Diamond") then
                if eggName:find("divine") or eggName:find("diamond") then
                    return egg
                end
            elseif selectedZone:find("Mythic") or selectedZone:find("Golden") then
                if eggName:find("mythic") or eggName:find("golden") then
                    return egg
                end
            elseif selectedZone:find("Legend") or selectedZone:find("Flaming") then
                if eggName:find("legend") or eggName:find("flaming") then
                    return egg
                end
            elseif selectedZone:find("Epic") or selectedZone:find("Skull") or selectedZone:find("Slime") then
                if eggName:find("epic") or eggName:find("skull") or eggName:find("slime") then
                    return egg
                end
            elseif selectedZone:find("Rare") or selectedZone:find("Crystal") or selectedZone:find("Flower") then
                if eggName:find("rare") or eggName:find("crystal") or eggName:find("flower") then
                    return egg
                end
            else
                return egg
            end
        end
    end

    return bestEgg or eggs[1]
end

-- Robust Egg Steal Routine
local isStealing = false
local function ExecuteStealEgg()
    if isStealing then return end
    isStealing = true

    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local targetEgg = GetBestStealEgg()
        if not targetEgg or not targetEgg.Parent or IsEggInsideAnyBase(targetEgg) then
            isStealing = false
            return
        end

        local eggPart = targetEgg:FindFirstChild("Handle") 
                     or targetEgg:FindFirstChild("EggBase") 
                     or targetEgg:FindFirstChild("Sphere.007") 
                     or targetEgg.PrimaryPart 
                     or targetEgg:FindFirstChildOfClass("BasePart")
        if not eggPart then
            isStealing = false
            return
        end

        -- Step 1: Teleport onto the egg
        SafeTeleport(eggPart.CFrame + Vector3.new(0, 1.5, 0))
        task.wait(0.25)

        -- Step 2: Trigger ProximityPrompt ("Pickup")
        for _, prompt in ipairs(targetEgg:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                pcall(function()
                    prompt.HoldDuration = 0
                    prompt.RequiresLineOfSight = false
                    prompt.MaxActivationDistance = 99999
                end)
                if fireproximityprompt then
                    fireproximityprompt(prompt, 0)
                    task.wait(0.04)
                    fireproximityprompt(prompt, 1)
                    fireproximityprompt(prompt)
                end
            end
        end

        local pickupRemote = GetGameRemote("EggPickup")
        if pickupRemote then
            pickupRemote:FireServer(targetEgg)
            pickupRemote:FireServer(targetEgg.Name)
            pickupRemote:FireServer(eggPart)
        end

        if firetouchinterest and hrp and eggPart then
            firetouchinterest(hrp, eggPart, 0)
            task.wait(0.04)
            firetouchinterest(hrp, eggPart, 1)
        end

        task.wait(0.35)

        -- Step 3: Bring Egg to Player Base
        local myPlot = GetMyPlot()
        if myPlot then
            local bp = myPlot:FindFirstChild("Baseplate") or myPlot.PrimaryPart or myPlot:FindFirstChildWhichIsA("BasePart", true)
            if bp then
                SafeTeleport(bp.CFrame + Vector3.new(0, 4, 0))
            else
                SafeTeleport(myPlot:GetPivot() + Vector3.new(0, 4, 0))
            end
        else
            local tpRemote = GetGameRemote("TeleportToPlot")
            if tpRemote then tpRemote:FireServer() end
        end

        task.wait(0.35)

        -- Step 4: Deposit Egg onto Open Nest
        if myPlot and myPlot:FindFirstChild("Nests") then
            for _, nest in ipairs(myPlot.Nests:GetChildren()) do
                local nestPart = nest:FindFirstChild("Handle") or nest:FindFirstChildWhichIsA("BasePart", true)
                if nestPart then
                    SafeTeleport(nestPart.CFrame + Vector3.new(0, 2.5, 0))
                    task.wait(0.1)

                    local placeRemote = GetGameRemote("EggPlaced")
                    if placeRemote then
                        placeRemote:FireServer(nest)
                        placeRemote:FireServer(nest.Name)
                        placeRemote:FireServer()
                    end

                    if firetouchinterest and hrp then
                        firetouchinterest(hrp, nestPart, 0)
                        task.wait(0.03)
                        firetouchinterest(hrp, nestPart, 1)
                    end

                    if Toggles.AutoHatch then
                        local hatchRemote = GetGameRemote("Hatch")
                        if hatchRemote then hatchRemote:FireServer(nest) end
                    end
                end
            end
        end
    end)

    isStealing = false
end

-- Auto Steal Loop
task.spawn(function()
    while true do
        task.wait(0.6)
        if Toggles.AutoSteal then
            ExecuteStealEgg()
        end
    end
end)

-- Auto Hatch Eggs Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoHatch then
            pcall(function()
                local myPlot = GetMyPlot()
                if myPlot and myPlot:FindFirstChild("Nests") then
                    local hatchRemote = GetGameRemote("Hatch")
                    for _, nest in ipairs(myPlot.Nests:GetChildren()) do
                        if hatchRemote then
                            hatchRemote:FireServer(nest)
                        end
                        for _, prompt in ipairs(nest:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and fireproximityprompt then
                                fireproximityprompt(prompt, 0)
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Place Egg Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoPlace then
            pcall(function()
                local myPlot = GetMyPlot()
                if myPlot and myPlot:FindFirstChild("Nests") then
                    local placeRemote = GetGameRemote("EggPlaced")
                    for _, nest in ipairs(myPlot.Nests:GetChildren()) do
                        if placeRemote then
                            placeRemote:FireServer(nest)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Equip Best Pet Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.AutoEquipBest then
            pcall(function()
                local myPlot = GetMyPlot()
                local petsFolder = myPlot and myPlot:FindFirstChild("Pets")
                if petsFolder then
                    local pets = petsFolder:GetChildren()
                    if #pets > 0 then
                        local targetPet = pets[#pets]
                        local mountRemote = GetGameRemote("Mounting")
                        if mountRemote and targetPet then
                            mountRemote:FireServer(targetPet)
                        end
                    end
                end
            end)
        end
    end
end)

-- Rare Egg ESP (Excludes Base Eggs)
local espHighlights = {}
local espBillboards = {}

local function ClearESP()
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
        if Toggles.BestEggESP then
            pcall(function()
                local renderedEggs = Workspace:FindFirstChild("RenderedEggs")
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

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
                                        hl.FillColor = (score >= 80 and Color3.fromRGB(255, 60, 255)) or (score >= 50 and Color3.fromRGB(255, 215, 0)) or Color3.fromRGB(50, 220, 255)
                                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                        hl.FillTransparency = 0.35
                                        hl.OutlineTransparency = 0
                                        hl.Parent = egg
                                        espHighlights[egg] = hl

                                        local bb = Instance.new("BillboardGui")
                                        bb.Name = "JunejoTag"
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
                                        lbl.TextStrokeTransparency = 0.2
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
            ClearESP()
        end
    end
end)

-- =================================================================
-- OFFICIAL JUNEJO CLASSIC DARK UI (UI 1 STANDARD - 280x265px)
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoRideAPetUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true

-- Main Frame (280px x 265px)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 265)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -132)
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

-- Dragging Engine
local isDragging, dragStart, startPos = false, nil, nil
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Header Frame (Height: 32px)
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
    ScreenGui:Destroy()
end)

-- Header Separation Line (1px)
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Scrolling Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 0, 190)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 320)
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper: Add Flat Borderless Toggle Row (Classic Square Checkbox)
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

-- Helper: Add 1-Click Action Button Row
local function AddActionRow(text, buttonText, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
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
    ActionBtn.Text = buttonText
    ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionBtn.TextSize = 10
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
        ActionBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
        task.delay(0.15, function()
            ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
        end)
        if callback then callback() end
    end)
end

-- Helper: Add Interactive Option Stepper Pill (< Choice >)
local function AddSelectorRow(text, options, getIndex, setIndex, onSelect)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.42, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local StepperFrame = Instance.new("Frame")
    StepperFrame.Size = UDim2.new(0.56, 0, 1, 0)
    StepperFrame.Position = UDim2.new(0.44, 0, 0, 0)
    StepperFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    StepperFrame.BorderSizePixel = 0
    StepperFrame.Parent = Row

    local StepCorner = Instance.new("UICorner")
    StepCorner.CornerRadius = UDim.new(0, 4)
    StepCorner.Parent = StepperFrame

    local StepStroke = Instance.new("UIStroke")
    StepStroke.Color = Color3.fromRGB(45, 45, 55)
    StepStroke.Thickness = 1
    StepStroke.Parent = StepperFrame

    local LeftBtn = Instance.new("TextButton")
    LeftBtn.Size = UDim2.new(0, 18, 1, 0)
    LeftBtn.Position = UDim2.new(0, 0, 0, 0)
    LeftBtn.BackgroundTransparency = 1
    LeftBtn.Text = "<"
    LeftBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    LeftBtn.TextSize = 12
    LeftBtn.Font = Enum.Font.GothamBold
    LeftBtn.Parent = StepperFrame

    local DisplayLabel = Instance.new("TextLabel")
    DisplayLabel.Size = UDim2.new(1, -36, 1, 0)
    DisplayLabel.Position = UDim2.new(0, 18, 0, 0)
    DisplayLabel.BackgroundTransparency = 1
    DisplayLabel.Text = options[getIndex()] or options[1]
    DisplayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DisplayLabel.TextSize = 9
    DisplayLabel.TextTruncate = Enum.TextTruncate.AtEnd
    DisplayLabel.Font = Enum.Font.GothamBold
    DisplayLabel.Parent = StepperFrame

    local RightBtn = Instance.new("TextButton")
    RightBtn.Size = UDim2.new(0, 18, 1, 0)
    RightBtn.Position = UDim2.new(1, -18, 0, 0)
    RightBtn.BackgroundTransparency = 1
    RightBtn.Text = ">"
    RightBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    RightBtn.TextSize = 12
    RightBtn.Font = Enum.Font.GothamBold
    RightBtn.Parent = StepperFrame

    LeftBtn.MouseButton1Click:Connect(function()
        local idx = getIndex() - 1
        if idx < 1 then idx = #options end
        setIndex(idx)
        DisplayLabel.Text = options[idx]
        if onSelect then onSelect(options[idx]) end
    end)

    RightBtn.MouseButton1Click:Connect(function()
        local idx = getIndex() + 1
        if idx > #options then idx = 1 end
        setIndex(idx)
        DisplayLabel.Text = options[idx]
        if onSelect then onSelect(options[idx]) end
    end)
end

-- =================================================================
-- REGISTERING ALL FEATURES
-- =================================================================

-- 1. Auto Steal Egg Toggle
AddToggleRow("Auto Steal (Best)", "AutoSteal", function(state)
    if state then
        task.spawn(ExecuteStealEgg)
    end
end)

-- 2. Steal Zone Selector Pill
AddSelectorRow("Steal Zone", StealZoneOptions, function() return StealZoneIndex end, function(val) StealZoneIndex = val end, function(sel)
    if Toggles.AutoSteal then task.spawn(ExecuteStealEgg) end
end)

-- 3. Auto Hatch Eggs
AddToggleRow("Auto Hatch Eggs", "AutoHatch")

-- 4. Auto Place Egg
AddToggleRow("Auto Place Egg", "AutoPlace")

-- 5. Auto Equip Best Pet
AddToggleRow("Auto Equip Best Pet", "AutoEquipBest")

-- 6. Rare Egg ESP (Excludes Base Eggs)
AddToggleRow("Rare Egg ESP", "BestEggESP", function(state)
    if not state then ClearESP() end
end)

-- 7. Teleport Zone Selector Pill
AddSelectorRow("Teleport Zone", TeleportZoneNames, function() return TeleportZoneIndex end, function(val) TeleportZoneIndex = val end, function(sel)
    TeleportToLocation(sel)
end)

-- 8. Teleport To Zone (Action Button)
AddActionRow("Teleport To Zone", "TP ZONE", function()
    local dest = TeleportZoneNames[TeleportZoneIndex] or "Food Stall (Tim)"
    TeleportToLocation(dest)
end)

-- 9. Teleport To My Base (Action Button)
AddActionRow("Teleport To My Base", "MY BASE", function()
    TeleportToLocation("My Base / Plot")
end)

-- 10. WalkSpeed Boost + Integrated Pill Controller (- / +)
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
SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeed and 0 or 1
SpeedCheckMark.BorderSizePixel = 0
SpeedCheckMark.Parent = SpeedCheckBox

local SpeedMarkCorner = Instance.new("UICorner")
SpeedMarkCorner.CornerRadius = UDim.new(0, 2)
SpeedMarkCorner.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Toggles.WalkSpeed = not Toggles.WalkSpeed
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeed and 0 or 1
    ApplyWalkSpeed()
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
    ApplyWalkSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(250, CustomSpeedValue + 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    ApplyWalkSpeed()
end)

-- 11. Fly Mode + Integrated Pill Controller (- / +)
local FlyRow = Instance.new("Frame")
FlyRow.Size = UDim2.new(1, 0, 0, 23)
FlyRow.BackgroundTransparency = 1
FlyRow.Parent = ContentFrame

local FlyToggleBtn = Instance.new("TextButton")
FlyToggleBtn.Size = UDim2.new(0.55, 0, 1, 0)
FlyToggleBtn.BackgroundTransparency = 1
FlyToggleBtn.Text = ""
FlyToggleBtn.ZIndex = 5
FlyToggleBtn.Parent = FlyRow

local FlyLabel = Instance.new("TextLabel")
FlyLabel.Size = UDim2.new(1, -26, 1, 0)
FlyLabel.BackgroundTransparency = 1
FlyLabel.Text = "Fly Mode"
FlyLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
FlyLabel.TextSize = 12
FlyLabel.Font = Enum.Font.GothamBold
FlyLabel.TextXAlignment = Enum.TextXAlignment.Left
FlyLabel.Parent = FlyToggleBtn

local FlyCheckBox = Instance.new("Frame")
FlyCheckBox.Size = UDim2.new(0, 18, 0, 18)
FlyCheckBox.Position = UDim2.new(1, -18, 0.5, -9)
FlyCheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
FlyCheckBox.BorderSizePixel = 0
FlyCheckBox.Parent = FlyToggleBtn

local FlyCheckCorner = Instance.new("UICorner")
FlyCheckCorner.CornerRadius = UDim.new(0, 4)
FlyCheckCorner.Parent = FlyCheckBox

local FlyCheckStroke = Instance.new("UIStroke")
FlyCheckStroke.Color = Color3.fromRGB(45, 45, 55)
FlyCheckStroke.Thickness = 1.2
FlyCheckStroke.Parent = FlyCheckBox

local FlyCheckMark = Instance.new("Frame")
FlyCheckMark.Size = UDim2.new(0, 10, 0, 10)
FlyCheckMark.Position = UDim2.new(0.5, -5, 0.5, -5)
FlyCheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FlyCheckMark.BackgroundTransparency = Toggles.Fly and 0 or 1
FlyCheckMark.BorderSizePixel = 0
FlyCheckMark.Parent = FlyCheckBox

local FlyMarkCorner = Instance.new("UICorner")
FlyMarkCorner.CornerRadius = UDim.new(0, 2)
FlyMarkCorner.Parent = FlyCheckMark

FlyToggleBtn.MouseButton1Click:Connect(function()
    Toggles.Fly = not Toggles.Fly
    FlyCheckMark.BackgroundTransparency = Toggles.Fly and 0 or 1
    if Toggles.Fly then StartFly() else StopFly() end
end)

local FlyControlFrame = Instance.new("Frame")
FlyControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
FlyControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
FlyControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
FlyControlFrame.BorderSizePixel = 0
FlyControlFrame.Parent = FlyRow

local FlyCtrlCorner = Instance.new("UICorner")
FlyCtrlCorner.CornerRadius = UDim.new(0, 4)
FlyCtrlCorner.Parent = FlyControlFrame

local FlyCtrlStroke = Instance.new("UIStroke")
FlyCtrlStroke.Color = Color3.fromRGB(45, 45, 55)
FlyCtrlStroke.Thickness = 1
FlyCtrlStroke.Parent = FlyControlFrame

local FlyMinusBtn = Instance.new("TextButton")
FlyMinusBtn.Size = UDim2.new(0, 22, 1, 0)
FlyMinusBtn.Position = UDim2.new(0, 0, 0, 0)
FlyMinusBtn.BackgroundTransparency = 1
FlyMinusBtn.Text = "-"
FlyMinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
FlyMinusBtn.TextSize = 14
FlyMinusBtn.Font = Enum.Font.GothamBold
FlyMinusBtn.Parent = FlyControlFrame

local FlyDisplay = Instance.new("TextLabel")
FlyDisplay.Size = UDim2.new(1, -44, 1, 0)
FlyDisplay.Position = UDim2.new(0, 22, 0, 0)
FlyDisplay.BackgroundTransparency = 1
FlyDisplay.Text = tostring(CustomFlySpeed)
FlyDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyDisplay.TextSize = 11
FlyDisplay.Font = Enum.Font.GothamBold
FlyDisplay.Parent = FlyControlFrame

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
    FlyDisplay.Text = tostring(CustomFlySpeed)
end)

FlyPlusBtn.MouseButton1Click:Connect(function()
    CustomFlySpeed = math.min(200, CustomFlySpeed + 10)
    FlyDisplay.Text = tostring(CustomFlySpeed)
end)

-- 12. NoClip Mode
AddToggleRow("NoClip Mode", "NoClip")

-- Pinned Footer (Mandatory Junejo Footer)
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

-- Mount UI Directly to Container
ScreenGui.Parent = UIContainer

-- Startup Toast Notification
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "ULTRA SCRIPT HUB",
        Text = GameName .. " Loaded Successfully!",
        Duration = 4
    })
end)
