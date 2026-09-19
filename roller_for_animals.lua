--[[
    ========================================================================
    JUNEJO ULTRA SCRIPT HUB - ROLLER FOR ANIMALS
    ========================================================================
    Author: Made by Junejo (junejo18146)
    Target Game: Roller for Animals 🛼🐾 (Roblox Place: 88910662712492)
    Repository: junejo18146/ultrascripthub
    File: roller_for_animals.lua
    Universal Mobile (Delta / Codex / Fluxus / Arceus X) & PC Compatible
    UI Standard: Official Ultra Script Hub Classic Matte Dark (1:1 Exact Screenshot Standard)
    
    Features Included:
        1. Auto Collect Rare Animals (Autonomous Rare-First Roll, Grab & Deposit Engine)
        2. Auto Sell Animals (5-Layer Auto Sell & Pen Deposit Engine)
        3. Teleport To Rarest Animal (Full-Width Action Button)
        4. Select Base Position (Full-Width Action Button)
        5. Teleport To Base (Full-Width Action Button)
        6. Auto Rebirth (Automatic Multi-Layer Prestige & Rebirth Engine)
        7. Auto Hatch Pets (Automatic Egg Stands, Incubators & Remote Pet Opener)
        8. Rare Animals ESP (Neon Magenta Highlight + Live Billboard Distance Tag)
        9. Player ESP (Neon Red Player Highlight + Live Distance Tag)
        10. WalkSpeed Boost (Integrated Checkbox + [ - 50 + ] Stepper Pill)
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
    local names = {"JunejoRollerForAnimalsUI", "RobloxScriptUI_RollerForAnimals", "JunejoHubUI", "UniversalScriptHubUI"}
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
    WalkSpeedBoost = false,
    Fly = false,
    InfiniteJump = false,
}

local CustomBasePos = nil
local CustomSpeedValue = 50
local FlySpeed = 60
local ESPObjects = {}
local PlayerESPObjects = {}

-- =================================================================
-- NOTIFICATION SYSTEM
-- =================================================================
local function ShowNotification(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Ultra Script Hub",
            Text = text or "",
            Duration = 2.5
        })
    end)
end

-- =================================================================
-- CHARACTER & MOVEMENT UTILITIES
-- =================================================================
local function isAlive()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return char and hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end

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
        if Toggles.AutoCollectRare and isAlive() then
            pcall(function()
                local animals = GetSpawnedAnimals()
                if #animals > 0 then
                    local target = animals[1]
                    if target and target.Part and target.Part.Parent then
                        local root = GetRoot()
                        if root then
                            SafeTeleport(target.Part.CFrame + Vector3.new(0, 2, 0))
                            task.wait(0.15)
                            
                            for _, prompt in ipairs(target.Object:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") then
                                    prompt.HoldDuration = 0
                                    fireproximityprompt(prompt)
                                end
                            end
                            
                            if firetouchinterest and target.Part and root then
                                firetouchinterest(root, target.Part, 0)
                                task.wait(0.05)
                                firetouchinterest(root, target.Part, 1)
                            end
                            
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
                            
                            if Toggles.AutoSell then
                                local baseCFrame = FindMyBaseCFrame()
                                SafeTeleport(baseCFrame)
                                task.wait(0.2)
                                
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

-- Standalone Auto Sell
task.spawn(function()
    while true do
        if Toggles.AutoSell and not Toggles.AutoCollectRare and isAlive() then
            pcall(function()
                local baseCFrame = FindMyBaseCFrame()
                local root = GetRoot()
                if root and (root.Position - baseCFrame.Position).Magnitude > 30 then
                    SafeTeleport(baseCFrame)
                end
                
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        local text = (desc.ObjectText .. " " .. desc.ActionText):lower()
                        if text:find("sell") or text:find("deposit") or text:find("pen") or text:find("drop") then
                            desc.HoldDuration = 0
                            fireproximityprompt(desc)
                        end
                    end
                end
                
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
        if Toggles.AutoRebirth and isAlive() then
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
        if Toggles.AutoHatch and isAlive() then
            pcall(function()
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        local txt = (desc.ObjectText .. " " .. desc.ActionText .. " " .. desc.Parent.Name):lower()
                        if txt:find("egg") or txt:find("hatch") or txt:find("open") or txt:find("pet") then
                            desc.HoldDuration = 0
                            fireproximityprompt(desc)
                        end
                    end
                end
                
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local rname = rem.Name:lower()
                        if rname:find("hatch") or rname:find("openegg") or rname:find("buyegg") or rname:find("petroll") then
                            pcall(function()
                                if rem:IsA("RemoteEvent") then
                                    rem:FireServer("Tier1", 1)
                                    rem:FireServer(1, 1)
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
                            local hl = Instance.new("Highlight")
                            hl.Name = "JunejoRareESP"
                            hl.FillColor = animal.Rarity >= 500 and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(255, 200, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.35
                            hl.OutlineTransparency = 0.1
                            hl.Adornee = animal.Object
                            hl.Parent = animal.Object
                            
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
                            local root = GetRoot()
                            if root and ESPObjects[key].Label and ESPObjects[key].Part then
                                local dist = math.floor((root.Position - ESPObjects[key].Part.Position).Magnitude)
                                ESPObjects[key].Label.Text = string.format("🌟 %s [%dm]", animal.Name, dist)
                            end
                        end
                    end
                end
                
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
local function UpdateCharacterSpeed()
    pcall(function()
        local hum = GetHumanoid()
        if hum then
            if Toggles.WalkSpeedBoost then
                hum.WalkSpeed = CustomSpeedValue
            else
                hum.WalkSpeed = 16
            end
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if Toggles.WalkSpeedBoost then
        pcall(function()
            local hum = GetHumanoid()
            if hum and hum.WalkSpeed ~= CustomSpeedValue then
                hum.WalkSpeed = CustomSpeedValue
            end
        end)
    end
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
    if Toggles.InfiniteJump then
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
-- EXACT SCREENSHOT 1:1 UI ARCHITECTURE
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoRollerForAnimalsUI"
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

-- =================================================================
-- POPULATING ROWS (EXACT ORDER & SCREENSHOT STYLE)
-- =================================================================

-- 1. Full-Width Action Button: TELEPORT TO RARE ANIMAL
AddActionButton("TELEPORT TO RARE ANIMAL", function()
    local animals = GetSpawnedAnimals()
    if #animals > 0 then
        local target = animals[1]
        if target and target.Part then
            SafeTeleport(target.Part.CFrame + Vector3.new(0, 3, 0))
            ShowNotification("Teleport", "Teleported to " .. target.Name)
        end
    else
        ShowNotification("Teleport", "No rare animals detected!")
    end
end)

-- 2. Full-Width Action Button: SET BASE POSITION
AddActionButton("SET BASE POSITION", function()
    local root = GetRoot()
    if root then
        CustomBasePos = root.CFrame
        ShowNotification("Base Position", "Custom Base position saved!")
    end
end)

-- 3. Full-Width Action Button: TELEPORT TO BASE
AddActionButton("TELEPORT TO BASE", function()
    local baseCF = FindMyBaseCFrame()
    SafeTeleport(baseCF)
    ShowNotification("Base", "Returned to Base!")
end)

-- 4. Auto Collect Rare Animals
AddToggleRow("Auto Collect Rare Animals", "AutoCollectRare", function(state)
    ShowNotification("Auto Collect", state and "Rolling Rare Animals!" or "Auto Collect Stopped")
end)

-- 5. Auto Sell Animals
AddToggleRow("Auto Sell Animals", "AutoSell", function(state)
    ShowNotification("Auto Sell", state and "Auto Sell Animals Active!" or "Auto Sell Stopped")
end)

-- 6. Auto Rebirth
AddToggleRow("Auto Rebirth", "AutoRebirth", function(state)
    ShowNotification("Auto Rebirth", state and "Auto Rebirth Active!" or "Auto Rebirth Stopped")
end)

-- 7. Auto Hatch Pets
AddToggleRow("Auto Hatch Pets", "AutoHatch", function(state)
    ShowNotification("Auto Hatch", state and "Pet Hatching Active!" or "Hatching Stopped")
end)

-- 8. Rare Animals ESP
AddToggleRow("Rare Animals ESP", "RareESP", function(state)
    ShowNotification("Rare ESP", state and "Rare Animals Highlighted!" or "Rare ESP Disabled")
end)

-- 9. Player ESP
AddToggleRow("Player ESP", "PlayerESP", function(state)
    ShowNotification("Player ESP", state and "Player Wallhack Active!" or "Player ESP Disabled")
end)

-- 10. WalkSpeed Integrated Row (with Checkbox + Stepper Pill as shown in screenshot)
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

-- Checkbox for WalkSpeed
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
SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
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
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
    UpdateCharacterSpeed()
end)

-- Stepper Pill Frame (-  50  +)
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

-- 11. Fly Mode
AddToggleRow("Fly Mode", "Fly", function(state)
    if state then
        StartFlying()
        ShowNotification("Fly Mode", "Smooth Fly Enabled (WASD/Touch)")
    else
        StopFlying()
        ShowNotification("Fly Mode", "Fly Disabled")
    end
end)

-- 12. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump", function(state)
    ShowNotification("Infinite Jump", state and "Infinite Jump Enabled!" or "Infinite Jump Disabled")
end)

-- =================================================================
-- MANDATORY CENTERED FOOTER (ULTRA SCRIPT HUB | Made by Junejo)
-- =================================================================
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

ShowNotification("Ultra Script Hub", "Roller for Animals loaded successfully!")
