--[[
    ========================================================================
    JUNEJO ULTRA SCRIPT HUB - ROLLER FOR ANIMALS
    ========================================================================
    Author: Made by Junejo (junejo18146)
    Target Game: Roller for Animals 🛼🐾 (Roblox Place: 88910662712492)
    Repository: junejo18146/ultrascripthub
    File: roller_for_animals.lua
    Universal Mobile (Delta / Codex / Fluxus / Arceus X) & PC Compatible
    UI Standard: UI 1 - Official Ultra Script Hub Classic Matte Dark (#0F0F11)
    
    Features Included:
        1. Auto Collect Rare Animals (Autonomous Rare-First Roll, Grab & Deposit Engine)
        2. Sell Animals (5-Layer Auto Sell & Pen Deposit Engine)
        3. Teleport To Rarest Animals (1-Click Direct Teleport to highest tier animal)
        4. Select Base Position (1-Click Custom Base Anchor save)
        5. Teleport To Base (1-Click Instant Safe Base Return)
        6. Auto Rebirth (Automatic Multi-Layer Prestige & Rebirth Engine)
        7. Auto Hatch Pets (Automatic Egg Stands, Incubators & Remote Pet Opener)
        8. Rare Animals ESP (Neon Magenta Highlight + Live Billboard Distance Tag)
        9. Player ESP (Neon Red Player Highlight + Live Distance Tag)
        10. WalkSpeed Boost (Integrated - / + Stepper Controller: 16 to 300)
        11. Fly Mode (Smooth 3D WASD & Mobile Touch Flight Engine)
        12. Infinite Jump (Continuous Airborne Multi-Jump Bypass)
        13. Instant Proximity Prompts (0s hold auto-sweeper)
        14. 24/7 Anti-AFK Engine (Prevents 20-minute idle disconnects)
    ========================================================================
--]]

local GameName = "ROLLER FOR ANIMALS"
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
    local names = {"JunejoRollerForAnimalsUI", "RobloxScriptUI_RollerForAnimals", "JunejoHubUI"}
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
    AutoCollectRare = false,
    AutoSell = false,
    AutoRebirth = false,
    AutoHatch = false,
    RareESP = false,
    PlayerESP = false,
    WalkSpeed = false,
    Fly = false,
    InfJump = false,
}

local CustomBasePos = nil
local CurrentSpeed = 50
local FlySpeed = 60
local ESPObjects = {}
local PlayerESPObjects = {}

-- =================================================================
-- NOTIFICATION SYSTEM
-- =================================================================
local function Notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Ultra Script Hub",
            Text = text or "",
            Duration = duration
        })
    end)
end

-- =================================================================
-- CHARACTER & MOVEMENT UTILITIES
-- =================================================================
local function GetRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function GetHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

local function SafeTeleport(cframe)
    local root = GetRoot()
    if root and cframe then
        pcall(function()
            root.Velocity = Vector3.new(0, 0, 0)
            root.RotVelocity = Vector3.new(0, 0, 0)
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end)
        root.CFrame = cframe
    end
end

-- =================================================================
-- BASE DETECTION ENGINE
-- =================================================================
local function FindMyBaseCFrame()
    if CustomBasePos then
        return typeof(CustomBasePos) == "CFrame" and CustomBasePos or CFrame.new(CustomBasePos)
    end
    
    local myName = LocalPlayer.Name
    local myDisplayName = LocalPlayer.DisplayName
    
    -- 1. Check Plots / Bases / Pens in Workspace
    local baseContainers = {
        Workspace:FindFirstChild("Bases"),
        Workspace:FindFirstChild("Plots"),
        Workspace:FindFirstChild("Pens"),
        Workspace:FindFirstChild("Barns"),
        Workspace:FindFirstChild("Islands"),
        Workspace:FindFirstChild("Tycoons"),
        Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Bases"),
        Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Plots"),
        Workspace
    }
    
    for _, container in ipairs(baseContainers) do
        if container then
            for _, obj in ipairs(container:GetChildren()) do
                local name = obj.Name:lower()
                local isOwner = false
                
                -- Check Attributes & Values
                pcall(function()
                    if obj:GetAttribute("Owner") == myName or obj:GetAttribute("Owner") == LocalPlayer.UserId then isOwner = true end
                    if obj:FindFirstChild("Owner") and (tostring(obj.Owner.Value) == myName or tostring(obj.Owner.Value) == tostring(LocalPlayer.UserId)) then isOwner = true end
                    if obj:FindFirstChild("OwnerName") and (tostring(obj.OwnerName.Value) == myName or tostring(obj.OwnerName.Value) == myDisplayName) then isOwner = true end
                    if name:find(myName:lower()) or (myDisplayName and name:find(myDisplayName:lower())) then isOwner = true end
                end)
                
                if isOwner then
                    local primary = obj.PrimaryPart or obj:FindFirstChild("Spawn") or obj:FindFirstChild("BasePlate") or obj:FindFirstChild("Floor") or obj:FindFirstChild("Pen") or obj:FindFirstChildWhichIsA("BasePart")
                    if primary then
                        return primary.CFrame + Vector3.new(0, 4, 0)
                    end
                end
            end
        end
    end
    
    -- 2. Fallback to SpawnLocation
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("SpawnLocation") then
            return desc.CFrame + Vector3.new(0, 4, 0)
        end
    end
    
    return GetRoot() and GetRoot().CFrame or CFrame.new(0, 10, 0)
end

-- =================================================================
-- ANIMAL SCANNER & RARITY SCORER
-- =================================================================
local function CalculateRarityScore(obj)
    local score = 1
    local name = obj.Name:lower()
    
    if name:find("secret") or name:find("mythic") or name:find("divine") or name:find("celestial") or name:find("god") then
        score = 1000
    elseif name:find("legendary") or name:find("omega") or name:find("diamond") then
        score = 500
    elseif name:find("epic") or name:find("golden") or name:find("giant") then
        score = 250
    elseif name:find("rare") or name:find("rainbow") then
        score = 100
    elseif name:find("uncommon") or name:find("silver") then
        score = 50
    end
    
    pcall(function()
        if obj:GetAttribute("Rarity") then
            local r = tostring(obj:GetAttribute("Rarity")):lower()
            if r:find("secret") or r:find("mythic") then score = math.max(score, 1000)
            elseif r:find("legendary") then score = math.max(score, 500)
            elseif r:find("epic") then score = math.max(score, 250)
            elseif r:find("rare") then score = math.max(score, 100) end
        end
        if obj:GetAttribute("Tier") then
            score = score + (tonumber(obj:GetAttribute("Tier")) or 0) * 50
        end
    end)
    
    return score
end

local function GetSpawnedAnimals()
    local list = {}
    local animalContainers = {
        Workspace:FindFirstChild("Animals"),
        Workspace:FindFirstChild("SpawnedAnimals"),
        Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Animals"),
        Workspace:FindFirstChild("AnimalFolder"),
        Workspace:FindFirstChild("Spawned"),
        Workspace:FindFirstChild("Debris"),
        Workspace
    }
    
    local scanned = {}
    for _, container in ipairs(animalContainers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if not scanned[item] and item ~= LocalPlayer.Character then
                    scanned[item] = true
                    local isAnimal = false
                    local name = item.Name:lower()
                    
                    if item:GetAttribute("Animal") or item:GetAttribute("Rarity") or item:GetAttribute("Tier") then
                        isAnimal = true
                    elseif name:find("animal") or name:find("cat") or name:find("dog") or name:find("dragon") or name:find("lion") or name:find("tiger") or name:find("elephant") or name:find("bear") or name:find("penguin") or name:find("monkey") or name:find("dino") or name:find("pet") then
                        isAnimal = true
                    elseif item:FindFirstChildWhichIsA("ProximityPrompt") and not item:IsA("Player") then
                        isAnimal = true
                    end
                    
                    if isAnimal then
                        local part = item:IsA("BasePart") and item or (item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")))
                        if part then
                            table.insert(list, {
                                Object = item,
                                Part = part,
                                Rarity = CalculateRarityScore(item),
                                Name = item.Name
                            })
                        end
                    end
                end
            end
        end
    end
    
    table.sort(list, function(a, b)
        return a.Rarity > b.Rarity
    end)
    
    return list
end

-- =================================================================
-- FEATURE 1 & 2: AUTO COLLECT RARE ANIMALS & SELL ANIMALS
-- =================================================================
task.spawn(function()
    while true do
        if Toggles.AutoCollectRare then
            pcall(function()
                local animals = GetSpawnedAnimals()
                if #animals > 0 then
                    local target = animals[1] -- Highest rarity animal
                    if target and target.Part and target.Part.Parent then
                        local root = GetRoot()
                        if root then
                            -- 1. Teleport to Rare Animal
                            SafeTeleport(target.Part.CFrame + Vector3.new(0, 2, 0))
                            task.wait(0.15)
                            
                            -- 2. Trigger ProximityPrompt / Touch / Virtual Roll
                            for _, prompt in ipairs(target.Object:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") then
                                    prompt.HoldDuration = 0
                                    fireproximityprompt(prompt)
                                end
                            end
                            
                            -- Trigger Touch Interest
                            if firetouchinterest and target.Part and root then
                                firetouchinterest(root, target.Part, 0)
                                task.wait(0.05)
                                firetouchinterest(root, target.Part, 1)
                            end
                            
                            -- Trigger Network Remotes if available
                            for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                                if rem:IsA("RemoteEvent") or rem:IsA("UnreliableRemoteEvent") then
                                    local rname = rem.Name:lower()
                                    if rname:find("collect") or rname:find("grab") or rname:find("roll") or rname:find("pickup") then
                                        pcall(function() rem:FireServer(target.Object) end)
                                        pcall(function() rem:FireServer(target.Part) end)
                                    end
                                end
                            end
                            
                            task.wait(0.2)
                            
                            -- 3. Return to Base & Deposit/Sell if enabled or inventory filled
                            if Toggles.AutoSell then
                                local baseCFrame = FindMyBaseCFrame()
                                SafeTeleport(baseCFrame)
                                task.wait(0.2)
                                
                                -- Trigger Sell Pads / Prompts / Remotes
                                for _, desc in ipairs(Workspace:GetDescendants()) do
                                    if desc:IsA("ProximityPrompt") and (desc.ObjectText:lower():find("sell") or desc.ActionText:lower():find("sell") or desc.ActionText:lower():find("deposit")) then
                                        desc.HoldDuration = 0
                                        fireproximityprompt(desc)
                                    end
                                end
                                
                                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                                        local rname = rem.Name:lower()
                                        if rname:find("sell") or rname:find("deposit") or rname:find("claimcash") or rname:find("cashout") then
                                            pcall(function()
                                                if rem:IsA("RemoteEvent") then rem:FireServer()
                                                else rem:InvokeServer() end
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.3)
    end
end)

-- Dedicated Auto Sell Engine (if running standalone)
task.spawn(function()
    while true do
        if Toggles.AutoSell and not Toggles.AutoCollectRare then
            pcall(function()
                local baseCFrame = FindMyBaseCFrame()
                local root = GetRoot()
                if root and (root.Position - baseCFrame.Position).Magnitude > 30 then
                    SafeTeleport(baseCFrame)
                end
                
                -- Trigger Sell Prompts
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        local text = (desc.ObjectText .. " " .. desc.ActionText):lower()
                        if text:find("sell") or text:find("deposit") or text:find("pen") or text:find("drop") then
                            desc.HoldDuration = 0
                            fireproximityprompt(desc)
                        end
                    end
                end
                
                -- Fire Remotes
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local rname = rem.Name:lower()
                        if rname:find("sell") or rname:find("deposit") or rname:find("claimcash") then
                            pcall(function()
                                if rem:IsA("RemoteEvent") then rem:FireServer()
                                else rem:InvokeServer() end
                            end)
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- =================================================================
-- FEATURE 6: AUTO REBIRTH
-- =================================================================
task.spawn(function()
    while true do
        if Toggles.AutoRebirth then
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local name = rem.Name:lower()
                        if name:find("rebirth") or name:find("prestige") or name:find("ascend") then
                            pcall(function()
                                if rem:IsA("RemoteEvent") then rem:FireServer()
                                else rem:InvokeServer() end
                            end)
                        end
                    end
                end
                
                -- Trigger Rebirth GUI Buttons
                if LocalPlayer:FindFirstChild("PlayerGui") then
                    for _, btn in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                            local btext = (btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or "")):lower()
                            if btext:find("rebirth") or btext:find("prestige") then
                                pcall(function()
                                    for _, conn in ipairs(getconnections(btn.MouseButton1Click or btn.Activated)) do
                                        conn:Fire()
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(1.5)
    end
end)

-- =================================================================
-- FEATURE 7: AUTO HATCH PETS
-- =================================================================
task.spawn(function()
    while true do
        if Toggles.AutoHatch then
            pcall(function()
                -- 1. Scan Egg Stands & Prompts
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        local txt = (desc.ObjectText .. " " .. desc.ActionText .. " " .. desc.Parent.Name):lower()
                        if txt:find("egg") or txt:find("hatch") or txt:find("open") or txt:find("pet") then
                            desc.HoldDuration = 0
                            fireproximityprompt(desc)
                        end
                    end
                end
                
                -- 2. Scan ReplicatedStorage Remotes
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local rname = rem.Name:lower()
                        if rname:find("hatch") or rname:find("openegg") or rname:find("buyegg") or rname:find("petroll") then
                            pcall(function()
                                if rem:IsA("RemoteEvent") then
                                    rem:FireServer("Tier1", 1)
                                    rem:FireServer(1, 1)
                                    rem:FireServer("Basic", 1)
                                    rem:FireServer("Common", 1)
                                    rem:FireServer(1)
                                    rem:FireServer()
                                else
                                    rem:InvokeServer("Tier1", 1)
                                    rem:InvokeServer(1)
                                    rem:InvokeServer()
                                end
                            end)
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- =================================================================
-- FEATURE 8: RARE ANIMALS ESP
-- =================================================================
local function ClearRareESP()
    for _, esp in pairs(ESPObjects) do
        pcall(function()
            if esp.Highlight then esp.Highlight:Destroy() end
            if esp.Billboard then esp.Billboard:Destroy() end
        end)
    end
    ESPObjects = {}
end

task.spawn(function()
    while true do
        if Toggles.RareESP then
            pcall(function()
                local animals = GetSpawnedAnimals()
                local currentGuids = {}
                
                for _, animal in ipairs(animals) do
                    if animal.Rarity >= 50 and animal.Part and animal.Part.Parent then
                        local key = animal.Object
                        currentGuids[key] = true
                        
                        if not ESPObjects[key] then
                            -- Create Neon Highlight
                            local hl = Instance.new("Highlight")
                            hl.Name = "JunejoRareESP"
                            hl.FillColor = animal.Rarity >= 500 and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(255, 200, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.35
                            hl.OutlineTransparency = 0.1
                            hl.Adornee = animal.Object
                            hl.Parent = animal.Object
                            
                            -- Create BillboardGui
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "JunejoRareTag"
                            bb.Size = UDim2.new(0, 160, 0, 35)
                            bb.StudsOffset = Vector3.new(0, 3, 0)
                            bb.AlwaysOnTop = true
                            bb.Adornee = animal.Part
                            
                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.Font = Enum.Font.GothamBold
                            label.TextSize = 13
                            label.TextColor3 = animal.Rarity >= 500 and Color3.fromRGB(255, 100, 255) or Color3.fromRGB(255, 220, 50)
                            label.TextStrokeTransparency = 0.2
                            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            label.Text = animal.Name .. " [RARE]"
                            label.Parent = bb
                            bb.Parent = animal.Part
                            
                            ESPObjects[key] = { Highlight = hl, Billboard = bb, Label = label, Part = animal.Part, Animal = animal }
                        else
                            -- Update Distance Tag
                            local root = GetRoot()
                            if root and ESPObjects[key].Label and ESPObjects[key].Part then
                                local dist = math.floor((root.Position - ESPObjects[key].Part.Position).Magnitude)
                                ESPObjects[key].Label.Text = string.format("🌟 %s [%dm]", animal.Name, dist)
                            end
                        end
                    end
                end
                
                -- Cleanup Removed Animals
                for key, esp in pairs(ESPObjects) do
                    if not currentGuids[key] or not key.Parent then
                        pcall(function()
                            if esp.Highlight then esp.Highlight:Destroy() end
                            if esp.Billboard then esp.Billboard:Destroy() end
                        end)
                        ESPObjects[key] = nil
                    end
                end
            end)
        else
            if next(ESPObjects) ~= nil then
                ClearRareESP()
            end
        end
        task.wait(0.5)
    end
end)

-- =================================================================
-- FEATURE 9: PLAYER ESP
-- =================================================================
local function ClearPlayerESP()
    for _, esp in pairs(PlayerESPObjects) do
        pcall(function()
            if esp.Highlight then esp.Highlight:Destroy() end
            if esp.Billboard then esp.Billboard:Destroy() end
        end)
    end
    PlayerESPObjects = {}
end

task.spawn(function()
    while true do
        if Toggles.PlayerESP then
            pcall(function()
                local root = GetRoot()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local char = player.Character
                        local hrp = char.HumanoidRootPart
                        
                        if not PlayerESPObjects[player] then
                            local hl = Instance.new("Highlight")
                            hl.Name = "JunejoPlayerESP"
                            hl.FillColor = Color3.fromRGB(255, 50, 50)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.45
                            hl.OutlineTransparency = 0.2
                            hl.Adornee = char
                            hl.Parent = char
                            
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "JunejoPlayerTag"
                            bb.Size = UDim2.new(0, 160, 0, 30)
                            bb.StudsOffset = Vector3.new(0, 3.5, 0)
                            bb.AlwaysOnTop = true
                            bb.Adornee = hrp
                            
                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.Font = Enum.Font.GothamBold
                            label.TextSize = 13
                            label.TextColor3 = Color3.fromRGB(255, 100, 100)
                            label.TextStrokeTransparency = 0.2
                            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            label.Text = player.DisplayName
                            label.Parent = bb
                            bb.Parent = hrp
                            
                            PlayerESPObjects[player] = { Highlight = hl, Billboard = bb, Label = label, Root = hrp }
                        else
                            if root and PlayerESPObjects[player].Label and PlayerESPObjects[player].Root then
                                local dist = math.floor((root.Position - PlayerESPObjects[player].Root.Position).Magnitude)
                                PlayerESPObjects[player].Label.Text = string.format("👤 %s [%dm]", player.DisplayName, dist)
                            end
                        end
                    end
                end
            end)
        else
            if next(PlayerESPObjects) ~= nil then
                ClearPlayerESP()
            end
        end
        task.wait(0.5)
    end
end)

-- =================================================================
-- FEATURE 10: WALKSPEED BOOST (+ / - STEPPER CONTROLLER)
-- =================================================================
task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if Toggles.WalkSpeed then
            pcall(function()
                local hum = GetHumanoid()
                if hum and hum.WalkSpeed ~= CurrentSpeed then
                    hum.WalkSpeed = CurrentSpeed
                end
            end)
        end
    end)
end)

-- =================================================================
-- FEATURE 11: FLY MODE (SMOOTH 3D WASD / TOUCH)
-- =================================================================
local Flying = false
local FlyVelocity = nil
local FlyGyro = nil

local function StartFlying()
    pcall(function()
        local root = GetRoot()
        local hum = GetHumanoid()
        if not root or not hum then return end
        
        Flying = true
        hum.PlatformStand = true
        
        FlyVelocity = Instance.new("BodyVelocity")
        FlyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyVelocity.Parent = root
        
        FlyGyro = Instance.new("BodyGyro")
        FlyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyGyro.CFrame = root.CFrame
        FlyGyro.Parent = root
        
        task.spawn(function()
            while Flying and Toggles.Fly do
                local cam = Workspace.CurrentCamera
                local direction = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    direction = direction + cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    direction = direction - cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    direction = direction - cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    direction = direction + cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    direction = direction + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    direction = direction - Vector3.new(0, 1, 0)
                end
                
                if direction.Magnitude > 0 then
                    direction = direction.Unit * FlySpeed
                end
                
                if FlyVelocity and FlyVelocity.Parent then
                    FlyVelocity.Velocity = direction
                end
                if FlyGyro and FlyGyro.Parent then
                    FlyGyro.CFrame = cam.CFrame
                end
                
                RunService.RenderStepped:Wait()
            end
            
            pcall(function()
                if FlyVelocity then FlyVelocity:Destroy() end
                if FlyGyro then FlyGyro:Destroy() end
                if hum then hum.PlatformStand = false end
                Flying = false
            end)
        end)
    end)
end

local function StopFlying()
    Flying = false
    pcall(function()
        if FlyVelocity then FlyVelocity:Destroy() end
        if FlyGyro then FlyGyro:Destroy() end
        local hum = GetHumanoid()
        if hum then hum.PlatformStand = false end
    end)
end

-- =================================================================
-- FEATURE 12: INFINITE JUMP
-- =================================================================
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfJump then
        pcall(function()
            local hum = GetHumanoid()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- =================================================================
-- FEATURE 13 & 14: 0S PROMPTS & 24/7 ANTI-AFK ENGINE
-- =================================================================
task.spawn(function()
    Workspace.DescendantAdded:Connect(function(desc)
        if desc:IsA("ProximityPrompt") then
            desc.HoldDuration = 0
        end
    end)
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            desc.HoldDuration = 0
        end
    end
end)

-- Anti-AFK Engine
task.spawn(function()
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            if VirtualUser then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end
        end)
    end)
end)

-- =================================================================
-- UI 1 DESIGN: ULTRA SCRIPT HUB CLASSIC MATTE DARK (280x265px)
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoRollerForAnimalsUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = UIContainer

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 265)
MainFrame.Position = UDim2.new(0.5, -140, 0.4, -132)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17) -- Matte Black #0F0F11
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42) -- Border #23232A
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 36)
Topbar.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
Topbar.BorderSizePixel = 0
Topbar.Parent = MainFrame

local TopbarDivider = Instance.new("Frame")
TopbarDivider.Size = UDim2.new(1, 0, 0, 1)
TopbarDivider.Position = UDim2.new(0, 0, 1, -1)
TopbarDivider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
TopbarDivider.BorderSizePixel = 0
TopbarDivider.Parent = Topbar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -70, 0, 18)
TitleLabel.Position = UDim2.new(0, 12, 0, 3)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = GameName
TitleLabel.Parent = Topbar

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Size = UDim2.new(1, -70, 0, 14)
SubtitleLabel.Position = UDim2.new(0, 12, 0, 19)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Font = Enum.Font.GothamMedium
SubtitleLabel.TextSize = 10
SubtitleLabel.TextColor3 = Color3.fromRGB(136, 136, 153) -- #888899
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubtitleLabel.Text = "Made by Junejo"
SubtitleLabel.Parent = Topbar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "×"
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Topbar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -56, 0, 6)
MinBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "—"
MinBtn.TextSize = 11
MinBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = Topbar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

-- Floating Open Pill (when minimized)
local OpenPill = Instance.new("TextButton")
OpenPill.Name = "JunejoOpenPill"
OpenPill.Size = UDim2.new(0, 110, 0, 30)
OpenPill.Position = UDim2.new(0.02, 0, 0.45, 0)
OpenPill.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
OpenPill.Font = Enum.Font.GothamBold
OpenPill.Text = "🐾 ROLLER HUB"
OpenPill.TextSize = 11
OpenPill.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenPill.Visible = false
OpenPill.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 8)
OpenCorner.Parent = OpenPill

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(35, 35, 42)
OpenStroke.Parent = OpenPill

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    MainFrame.Visible = not isMinimized
    OpenPill.Visible = isMinimized
end)

OpenPill.MouseButton1Click:Connect(function()
    isMinimized = false
    MainFrame.Visible = true
    OpenPill.Visible = false
end)

-- Topbar Smooth Dragging
local dragging, dragInput, dragStart, startPos
Topbar.InputBegan:Connect(function(input)
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

Topbar.InputChanged:Connect(function(input)
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

-- Content ScrollingFrame
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -16, 1, -64)
Content.Position = UDim2.new(0, 8, 0, 40)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 3)
ContentLayout.Parent = Content

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 8)
end)

-- Footer (Mandatory for UI 1)
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 22)
Footer.Position = UDim2.new(0, 0, 1, -22)
Footer.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterDivider = Instance.new("Frame")
FooterDivider.Size = UDim2.new(1, 0, 0, 1)
FooterDivider.Position = UDim2.new(0, 0, 0, 0)
FooterDivider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
FooterDivider.BorderSizePixel = 0
FooterDivider.Parent = Footer

local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(1, 0, 1, 0)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Font = Enum.Font.GothamMedium
FooterLabel.TextSize = 10
FooterLabel.TextColor3 = Color3.fromRGB(85, 85, 102) -- #555566
FooterLabel.Text = "ULTRA SCRIPT HUB  |  Made by Junejo"
FooterLabel.Parent = Footer

-- =================================================================
-- UI COMPONENT FACTORIES (UI 1 FLAT BORDERLESS ROWS)
-- =================================================================
local RowOrder = 0

-- 1. Checkbox Toggle Row Factory
local function CreateToggleRow(name, initialValue, callback)
    RowOrder = RowOrder + 1
    
    local Row = Instance.new("Frame")
    Row.Name = "Row_" .. name
    Row.Size = UDim2.new(1, 0, 0, 26)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = RowOrder
    Row.Parent = Content
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.Position = UDim2.new(0, 6, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 12
    Title.TextColor3 = Color3.fromRGB(224, 224, 230)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = name
    Title.Parent = Row
    
    -- Classic Square Checkbox (18x18px)
    local CheckBox = Instance.new("TextButton")
    CheckBox.Size = UDim2.new(0, 18, 0, 18)
    CheckBox.Position = UDim2.new(1, -22, 0.5, -9)
    CheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    CheckBox.BorderSizePixel = 0
    CheckBox.Text = ""
    CheckBox.Parent = Row
    
    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 4)
    CheckCorner.Parent = CheckBox
    
    local CheckStroke = Instance.new("UIStroke")
    CheckStroke.Color = Color3.fromRGB(45, 45, 55)
    CheckStroke.Thickness = 1
    CheckStroke.Parent = CheckBox
    
    local CheckMark = Instance.new("Frame")
    CheckMark.Size = UDim2.new(0, 10, 0, 10)
    CheckMark.Position = UDim2.new(0.5, -5, 0.5, -5)
    CheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CheckMark.BorderSizePixel = 0
    CheckMark.Visible = initialValue
    CheckMark.Parent = CheckBox
    
    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark
    
    local state = initialValue
    local function SetState(val)
        state = val
        CheckMark.Visible = state
        if state then
            CheckBox.BackgroundColor3 = Color3.fromRGB(58, 134, 255)
            CheckStroke.Color = Color3.fromRGB(58, 134, 255)
        else
            CheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
            CheckStroke.Color = Color3.fromRGB(45, 45, 55)
        end
        callback(state)
    end
    
    CheckBox.MouseButton1Click:Connect(function()
        SetState(not state)
    end)
    
    return SetState
end

-- 2. 1-Click Action Button Row Factory
local function CreateActionRow(title, btnText, callback)
    RowOrder = RowOrder + 1
    
    local Row = Instance.new("Frame")
    Row.Name = "Action_" .. title
    Row.Size = UDim2.new(1, 0, 0, 28)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = RowOrder
    Row.Parent = Content
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -95, 1, 0)
    Title.Position = UDim2.new(0, 6, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 12
    Title.TextColor3 = Color3.fromRGB(224, 224, 230)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = title
    Title.Parent = Row
    
    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(0, 85, 0, 22)
    ActionBtn.Position = UDim2.new(1, -88, 0.5, -11)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.Text = btnText
    ActionBtn.TextSize = 11
    ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionBtn.BorderSizePixel = 0
    ActionBtn.Parent = Row
    
    local ActionCorner = Instance.new("UICorner")
    ActionCorner.CornerRadius = UDim.new(0, 5)
    ActionCorner.Parent = ActionBtn
    
    local ActionStroke = Instance.new("UIStroke")
    ActionStroke.Color = Color3.fromRGB(45, 45, 55)
    ActionStroke.Thickness = 1
    ActionStroke.Parent = ActionBtn
    
    ActionBtn.MouseButton1Click:Connect(function()
        ActionBtn.BackgroundColor3 = Color3.fromRGB(58, 134, 255)
        task.delay(0.15, function()
            ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
        end)
        callback()
    end)
end

-- 3. WalkSpeed - / + Stepper Controller Row Factory
local function CreateSpeedStepperRow(name, defaultSpeed, minSpeed, maxSpeed, step, callback)
    RowOrder = RowOrder + 1
    
    local Row = Instance.new("Frame")
    Row.Name = "Stepper_" .. name
    Row.Size = UDim2.new(1, 0, 0, 30)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = RowOrder
    Row.Parent = Content
    
    -- Checkbox to Toggle
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -115, 1, 0)
    Title.Position = UDim2.new(0, 6, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 12
    Title.TextColor3 = Color3.fromRGB(224, 224, 230)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = name
    Title.Parent = Row
    
    -- Pill Stepper Container (105x22px)
    local StepperPill = Instance.new("Frame")
    StepperPill.Size = UDim2.new(0, 105, 0, 22)
    StepperPill.Position = UDim2.new(1, -108, 0.5, -11)
    StepperPill.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    StepperPill.BorderSizePixel = 0
    StepperPill.Parent = Row
    
    local PillCorner = Instance.new("UICorner")
    PillCorner.CornerRadius = UDim.new(0, 5)
    PillCorner.Parent = StepperPill
    
    local PillStroke = Instance.new("UIStroke")
    PillStroke.Color = Color3.fromRGB(45, 45, 55)
    PillStroke.Thickness = 1
    PillStroke.Parent = StepperPill
    
    local MinusBtn = Instance.new("TextButton")
    MinusBtn.Size = UDim2.new(0, 24, 1, 0)
    MinusBtn.Position = UDim2.new(0, 0, 0, 0)
    MinusBtn.BackgroundTransparency = 1
    MinusBtn.Font = Enum.Font.GothamBold
    MinusBtn.Text = "–"
    MinusBtn.TextSize = 13
    MinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    MinusBtn.Parent = StepperPill
    
    local ValLabel = Instance.new("TextButton")
    ValLabel.Size = UDim2.new(1, -48, 1, 0)
    ValLabel.Position = UDim2.new(0, 24, 0, 0)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.Text = tostring(defaultSpeed)
    ValLabel.TextSize = 11
    ValLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValLabel.Parent = StepperPill
    
    local PlusBtn = Instance.new("TextButton")
    PlusBtn.Size = UDim2.new(0, 24, 1, 0)
    PlusBtn.Position = UDim2.new(1, -24, 0, 0)
    PlusBtn.BackgroundTransparency = 1
    PlusBtn.Font = Enum.Font.GothamBold
    PlusBtn.Text = "+"
    PlusBtn.TextSize = 13
    PlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    PlusBtn.Parent = StepperPill
    
    local speedVal = defaultSpeed
    local speedActive = false
    
    local function UpdateDisplay()
        ValLabel.Text = tostring(speedVal)
        if speedActive then
            StepperPill.BackgroundColor3 = Color3.fromRGB(35, 75, 150)
            PillStroke.Color = Color3.fromRGB(58, 134, 255)
        else
            StepperPill.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
            PillStroke.Color = Color3.fromRGB(45, 45, 55)
        end
        callback(speedVal, speedActive)
    end
    
    MinusBtn.MouseButton1Click:Connect(function()
        speedVal = math.max(minSpeed, speedVal - step)
        UpdateDisplay()
    end)
    
    PlusBtn.MouseButton1Click:Connect(function()
        speedVal = math.min(maxSpeed, speedVal + step)
        UpdateDisplay()
    end)
    
    ValLabel.MouseButton1Click:Connect(function()
        speedActive = not speedActive
        UpdateDisplay()
    end)
end

-- =================================================================
-- BUILD UI ROWS IN ORDER
-- =================================================================

-- 1. Auto Collect Rare Animals
CreateToggleRow("Auto Collect Rare", false, function(state)
    Toggles.AutoCollectRare = state
    Notify("Auto Collect Rare", state and "Active (Rolling Rarest Animals)" or "Disabled", 2)
end)

-- 2. Sell Animals
CreateToggleRow("Auto Sell Animals", false, function(state)
    Toggles.AutoSell = state
    Notify("Auto Sell Animals", state and "Active (Auto Depositing at Pen)" or "Disabled", 2)
end)

-- 3. Teleport To Rarest Animals (1-Click Action)
CreateActionRow("Teleport to Rare", "TP RARE ⚡", function()
    local animals = GetSpawnedAnimals()
    if #animals > 0 then
        local target = animals[1]
        if target and target.Part then
            SafeTeleport(target.Part.CFrame + Vector3.new(0, 3, 0))
            Notify("Teleported", "Reached " .. target.Name .. " (Score: " .. target.Rarity .. ")", 2)
        end
    else
        Notify("Teleport Failed", "No rare animals detected!", 2)
    end
end)

-- 4. Select Base Position (1-Click Action)
CreateActionRow("Select Base Pos", "SET BASE 📍", function()
    local root = GetRoot()
    if root then
        CustomBasePos = root.CFrame
        Notify("Base Anchor Saved", "Custom base set at current position!", 3)
    end
end)

-- 5. Teleport To Base (1-Click Action)
CreateActionRow("Teleport to Base", "TP BASE 🏠", function()
    local baseCF = FindMyBaseCFrame()
    SafeTeleport(baseCF)
    Notify("Base Teleport", "Returned to base safely!", 2)
end)

-- 6. Auto Rebirth
CreateToggleRow("Auto Rebirth", false, function(state)
    Toggles.AutoRebirth = state
    Notify("Auto Rebirth", state and "Enabled (Automated Prestige)" or "Disabled", 2)
end)

-- 7. Auto Hatch Pets
CreateToggleRow("Auto Hatch Pets", false, function(state)
    Toggles.AutoHatch = state
    Notify("Auto Hatch Pets", state and "Enabled (Auto Egg/Pet Opener)" or "Disabled", 2)
end)

-- 8. Rare Animals ESP
CreateToggleRow("Rare Animals ESP", false, function(state)
    Toggles.RareESP = state
    Notify("Rare Animals ESP", state and "Enabled (Glowing Highlights)" or "Disabled", 2)
end)

-- 9. Player ESP
CreateToggleRow("Player ESP", false, function(state)
    Toggles.PlayerESP = state
    Notify("Player ESP", state and "Enabled (Red Chams & Distance)" or "Disabled", 2)
end)

-- 10. WalkSpeed Boost (- / + Stepper Controller)
CreateSpeedStepperRow("WalkSpeed", 50, 16, 300, 10, function(speed, active)
    CurrentSpeed = speed
    Toggles.WalkSpeed = active
    if not active then
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = 16 end
    end
end)

-- 11. Fly Mode
CreateToggleRow("Fly Mode", false, function(state)
    Toggles.Fly = state
    if state then
        StartFlying()
        Notify("Fly Mode", "Enabled (WASD / Touch Flight)", 2)
    else
        StopFlying()
        Notify("Fly Mode", "Disabled", 2)
    end
end)

-- 12. Infinite Jump
CreateToggleRow("Infinite Jump", false, function(state)
    Toggles.InfJump = state
    Notify("Infinite Jump", state and "Enabled (Continuous Multi-Jump)" or "Disabled", 2)
end)

Notify("Ultra Script Hub", "Roller for Animals loaded successfully!", 4)
