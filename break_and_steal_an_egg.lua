--[[
    ========================================================================
    ULTRA SCRIPT HUB - OFFICIAL PRODUCTION SCRIPT
    ========================================================================
    Game: Break and Steal an Egg
    Place ID: 114326934417838
    Creator: Made by Junejo (junejo18146)
    UI Style: UI 1 (Official Ultra Script Hub Classic Matte Dark - 280px)
    GitHub: https://github.com/junejo18146/ultrascripthub
    ========================================================================
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Safe Parent Selection
local function GetSafeGuiParent()
    local success, parent = pcall(function()
        if gethui then return gethui() end
        if CoreGui and pcall(function() return CoreGui.Name end) then
            return CoreGui
        end
        return PlayerGui
    end)
    return (success and parent) or PlayerGui
end

local GuiParent = GetSafeGuiParent()

-- Clean up existing instances
local ExistingUI = GuiParent:FindFirstChild("Junejo_BreakAndStealAnEgg_UI")
if ExistingUI then ExistingUI:Destroy() end

-- Game Remotes Reference
local EggHitRequest = ReplicatedStorage:FindFirstChild("EggHitRequest")
local BatHitRequest = ReplicatedStorage:FindFirstChild("BatHitRequest")
local PlaceAnimalRemote = ReplicatedStorage:FindFirstChild("PlaceAnimalRemote")
local UpgradePlotRequest = ReplicatedStorage:FindFirstChild("UpgradePlotRequest")
local PickaxeShopRequest = ReplicatedStorage:FindFirstChild("PickaxeShopRequest")
local TreadmillSessionRemote = ReplicatedStorage:FindFirstChild("TreadmillSessionRemote")
local SpeedGainRemote = ReplicatedStorage:FindFirstChild("SpeedGainRemote")
local OfflineRewardRemote = ReplicatedStorage:FindFirstChild("OfflineRewardRemote")
local GroupRewardRemote = ReplicatedStorage:FindFirstChild("GroupRewardRemote")

-- Pickaxe Tiers (Highest to Lowest)
local PickaxeTiers = {
    "18: Celestial Pickaxe", "17: Galaxy Pickaxe", "16: Cool Pickaxe",
    "15: Secret Pickaxe", "14: Ufo Pickaxe", "13: Hacker Pickaxe",
    "12: Demon Pickaxe", "11: Crystal Pickaxe", "10: Rainbow Pickaxe",
    "9: Candy Pickaxe", "8: Lightning Pickaxe", "7: Cactus Pickaxe",
    "6: Strawberry Pickaxe", "5: Diamond Pickaxe", "4: Golden Pickaxe",
    "3: Iron Pickaxe", "2: Stone Pickaxe", "1: Wooden Pickaxe"
}

-- Feature Toggles & State
local Toggles = {
    InfiniteHammer = false,
    AutoBreakRare = false,
    AutoStealRare = false,
    AutoDeposit = false,
    AutoUpgradeBase = false,
    AutoBuyPickaxe = false,
    AutoTrainSpeed = false,
    RareEggESP = false,
    AnimalESP = false,
    PlayerESP = false,
    WalkSpeed = false,
    FlyMode = false,
    Noclip = false,
    InfiniteJump = false
}

local CustomWalkSpeed = 50
local FlySpeed = 60
local SavedBaseCFrame = nil

-- Character Helper Functions
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRootPart()
    local char = GetCharacter()
    return char:WaitForChild("HumanoidRootPart", 5)
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:WaitForChild("Humanoid", 5)
end

local function EquipBestPickaxe()
    local char = GetCharacter()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    
    -- Check character first
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:find("Pickaxe") or tool.Name:find("Bat")) then
            return tool
        end
    end
    
    -- Check backpack for highest pickaxe
    if backpack then
        for _, pName in ipairs(PickaxeTiers) do
            local found = backpack:FindFirstChild(pName)
            if found then
                local hum = GetHumanoid()
                if hum then
                    hum:EquipTool(found)
                    task.wait(0.1)
                    return found
                end
            end
        end
        -- Fallback to any tool in backpack
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:find("Pickaxe") or tool.Name:find("Bat")) then
                local hum = GetHumanoid()
                if hum then
                    hum:EquipTool(tool)
                    task.wait(0.1)
                    return tool
                end
            end
        end
    end
    return nil
end

-- Base / Plot Detection
local function FindMyBase()
    if SavedBaseCFrame then
        return SavedBaseCFrame
    end
    
    local plots = workspace:FindFirstChild("Plots")
    if plots then
        for _, base in ipairs(plots:GetChildren()) do
            local hitbox = base:FindFirstChild("Hitbox")
            if hitbox then
                local playerUi = hitbox:FindFirstChild("PlayerInfoUi")
                if playerUi then
                    for _, desc in ipairs(playerUi:GetDescendants()) do
                        if desc:IsA("TextLabel") and (desc.Text:find(LocalPlayer.Name) or desc.Text:find(LocalPlayer.DisplayName)) then
                            local spawnPoint = base:FindFirstChild("SpawnPoint") or base:FindFirstChild("Dirt") or hitbox
                            SavedBaseCFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0)
                            return SavedBaseCFrame
                        end
                    end
                end
            end
        end
        -- Fallback: first base or plot
        local firstBase = plots:FindFirstChild("Base_1")
        if firstBase then
            local sp = firstBase:FindFirstChild("SpawnPoint") or firstBase:FindFirstChild("Dirt") or firstBase:FindFirstChild("Hitbox")
            if sp then
                return sp.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
    return nil
end

-- Egg Scanner: Finds the best/rarest egg (Diamond > Gold > Highest Zone)
local function FindBestEgg()
    local bestEgg = nil
    local bestScore = -1
    
    local function EvaluateEgg(eggModel)
        if not eggModel or not eggModel:IsA("Model") then return end
        local eggPart = eggModel:FindFirstChild("Egg") or eggModel:FindFirstChildWhichIsA("BasePart")
        if not eggPart then return end
        
        local overhead = eggPart:FindFirstChild("EggOverhead") or eggPart:FindFirstChildWhichIsA("Attachment")
        local eggUi = overhead and (overhead:FindFirstChild("EggInfoUi") or overhead:FindFirstChildWhichIsA("BillboardGui"))
        
        local score = 10 -- Base normal egg score
        
        if eggUi then
            -- Mutation check
            local mutLabel = eggUi:FindFirstChild("Mutation")
            if mutLabel and mutLabel:IsA("TextLabel") then
                if mutLabel.Text:find("Diamond") then
                    score = score + 50000
                elseif mutLabel.Text:find("Gold") then
                    score = score + 20000
                end
            end
            
            -- Luck Multiplier check
            local luckFrame = eggUi:FindFirstChild("LuckMultiList")
            if luckFrame then
                local luckLabel = luckFrame:FindFirstChild("LuckMulti")
                if luckLabel and luckLabel:IsA("TextLabel") then
                    local num = tonumber(luckLabel.Text:match("%d+[%.,]?%d*")) or 1
                    score = score + (num * 10)
                end
            end
            
            -- Rarity check
            local rarityLabel = eggUi:FindFirstChild("Rarity")
            if rarityLabel and rarityLabel:IsA("TextLabel") then
                local r = rarityLabel.Text
                if r:find("Celestial") then score = score + 10000
                elseif r:find("Cosmic") then score = score + 8000
                elseif r:find("Divine") then score = score + 6000
                elseif r:find("Secret") then score = score + 5000
                elseif r:find("Mythic") then score = score + 3000
                elseif r:find("Legendary") then score = score + 1500
                elseif r:find("Epic") then score = score + 500
                end
            end
        end
        
        -- Zone priority based on name
        local modelName = eggModel.Name
        if modelName:find("3:") then score = score + 300
        elseif modelName:find("2:") then score = score + 200
        elseif modelName:find("1:") then score = score + 100
        end
        
        if score > bestScore then
            bestScore = score
            bestEgg = eggModel
        end
    end
    
    -- Check Workspace Build ZoneBuilds
    local build = workspace:FindFirstChild("Build")
    local zoneBuilds = build and build:FindFirstChild("ZoneBuilds")
    if zoneBuilds then
        for _, zone in ipairs(zoneBuilds:GetChildren()) do
            local eggsFolder = zone:FindFirstChild("Eggs")
            if eggsFolder then
                for _, egg in ipairs(eggsFolder:GetChildren()) do
                    if egg:IsA("Model") and not egg.Name:find("Nest") then
                        EvaluateEgg(egg)
                    end
                end
            end
        end
    end
    
    -- Check Zone 9 and Special Egg Spawn
    local zone9 = workspace:FindFirstChild("Zone 9")
    if zone9 then
        for _, child in ipairs(zone9:GetDescendants()) do
            if child:IsA("Model") and child.Name:find("Egg") and not child.Name:find("Nest") then
                EvaluateEgg(child)
            end
        end
    end
    
    local specialEgg = workspace:FindFirstChild("Special Egg Spawn")
    if specialEgg then
        for _, child in ipairs(specialEgg:GetDescendants()) do
            if child:IsA("Model") and child.Name:find("Egg") and not child.Name:find("Nest") then
                EvaluateEgg(child)
            end
        end
    end
    
    return bestEgg
end

-- Animal Scanner: Finds the heaviest / rarest dropped animal on map
local function FindBestAnimalPrompt()
    local bestPrompt = nil
    local maxWeight = -1
    
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Name == "StealPrompt" then
            local objText = desc.ObjectText or ""
            local weightStr = objText:match("%[([%d%.,]+)%s*Kg%]") or objText:match("([%d%.,]+)%s*Kg")
            local weight = 1
            if weightStr then
                weightStr = weightStr:gsub(",", "")
                weight = tonumber(weightStr) or 1
            end
            
            -- Bonus for high tier colors/names
            if objText:find("Celestial") or objText:find("Cosmic") or objText:find("Swordfish") then
                weight = weight + 2000
            end
            
            if weight > maxWeight then
                maxWeight = weight
                bestPrompt = desc
            end
        end
    end
    return bestPrompt, maxWeight
end

-- Check if player is currently carrying an animal
local function IsCarryingAnimal()
    local char = GetCharacter()
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Model") or (child:IsA("Tool") and child.Name:find("Carried")) or child.Name:find("Animal") then
            return true
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, child in ipairs(bp:GetChildren()) do
            if child.Name:find("Carried") or child.Name:find("Animal") then
                return true
            end
        end
    end
    return false
end

-- ========================================================================
-- BACKGROUND AUTOMATION WORKERS
-- ========================================================================

-- 1. Auto Break Rare Egg & Infinite Hammer Power Engine
task.spawn(function()
    while true do
        task.wait(0.05)
        if Toggles.AutoBreakRare then
            local targetEgg = FindBestEgg()
            if targetEgg and targetEgg.Parent then
                local eggPart = targetEgg:FindFirstChild("Egg") or targetEgg:FindFirstChildWhichIsA("BasePart")
                if eggPart then
                    local root = GetRootPart()
                    if root then
                        -- Safe float above egg
                        root.CFrame = eggPart.CFrame + Vector3.new(0, 4, 0)
                        root.AssemblyLinearVelocity = Vector3.zero
                        
                        local tool = EquipBestPickaxe()
                        if tool then
                            tool:Activate()
                        end
                        
                        -- Infinite Hammer Power Burst
                        local hits = Toggles.InfiniteHammer and 25 or 3
                        for _ = 1, hits do
                            if EggHitRequest then
                                EggHitRequest:FireServer(targetEgg)
                                EggHitRequest:FireServer(eggPart)
                            end
                            if BatHitRequest then
                                BatHitRequest:FireServer(targetEgg)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- 2. Auto Steal Rare Animal Engine
task.spawn(function()
    while true do
        task.wait(0.15)
        if Toggles.AutoStealRare then
            local prompt, weight = FindBestAnimalPrompt()
            if prompt and prompt.Parent then
                local promptPart = prompt.Parent
                if promptPart:IsA("Attachment") then
                    promptPart = promptPart.Parent
                end
                
                local root = GetRootPart()
                if root and promptPart and promptPart:IsA("BasePart") then
                    root.CFrame = promptPart.CFrame + Vector3.new(0, 2, 0)
                    root.AssemblyLinearVelocity = Vector3.zero
                    task.wait(0.05)
                    fireproximityprompt(prompt, 0)
                    task.wait(0.1)
                end
            end
        end
    end
end)

-- 3. Auto Deposit to Base Engine
task.spawn(function()
    while true do
        task.wait(0.25)
        if Toggles.AutoDeposit and IsCarryingAnimal() then
            local baseCFrame = FindMyBase()
            local root = GetRootPart()
            if baseCFrame and root then
                root.CFrame = baseCFrame
                root.AssemblyLinearVelocity = Vector3.zero
                task.wait(0.1)
                if PlaceAnimalRemote then
                    PlaceAnimalRemote:FireServer()
                end
            end
        end
    end
end)

-- 4. Auto Upgrade Base Engine
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.AutoUpgradeBase then
            if UpgradePlotRequest then
                for i = 1, 8 do
                    UpgradePlotRequest:FireServer(i)
                    task.wait(0.05)
                end
            end
        end
    end
end)

-- 5. Auto Buy Best Pickaxe Engine
task.spawn(function()
    while true do
        task.wait(2.0)
        if Toggles.AutoBuyPickaxe then
            if PickaxeShopRequest then
                for _, pName in ipairs(PickaxeTiers) do
                    PickaxeShopRequest:FireServer(pName)
                    task.wait(0.05)
                end
            end
        end
    end
end)

-- 6. Auto Train Speed Engine
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoTrainSpeed then
            local plots = workspace:FindFirstChild("Plots")
            if plots then
                for _, base in ipairs(plots:GetChildren()) do
                    local tm = base:FindFirstChild("Basic Treadmill") or base:FindFirstChild("Futuristic Treadmill")
                    if tm then
                        local hb = tm:FindFirstChild("Hitbox")
                        if hb and hb:IsA("BasePart") then
                            local root = GetRootPart()
                            if root then
                                root.CFrame = hb.CFrame + Vector3.new(0, 3, 0)
                                root.AssemblyLinearVelocity = Vector3.new(0, 0, 5)
                            end
                            if TreadmillSessionRemote then
                                TreadmillSessionRemote:FireServer(true)
                            end
                            if SpeedGainRemote then
                                SpeedGainRemote:FireServer()
                            end
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- WalkSpeed Enforcer Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        local hum = GetHumanoid()
        if hum then
            if Toggles.WalkSpeed then
                hum.WalkSpeed = CustomWalkSpeed
            else
                if hum.WalkSpeed > 16 and hum.WalkSpeed == CustomWalkSpeed then
                    hum.WalkSpeed = 16
                end
            end
        end
    end
end)

-- Noclip Enforcer
RunService.Stepped:Connect(function()
    if Toggles.Noclip then
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

-- Infinite Jump Enforcer
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        local hum = GetHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Fly Mode Engine
local FlyBodyGyro, FlyBodyVelocity
local function StartFlying()
    local root = GetRootPart()
    if not root then return end
    
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.CFrame = root.CFrame
    FlyBodyGyro.Parent = root
    
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity = Vector3.zero
    FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVelocity.Parent = root
    
    task.spawn(function()
        while Toggles.FlyMode and FlyBodyGyro and FlyBodyVelocity do
            local camera = workspace.CurrentCamera
            local moveDir = Vector3.zero
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end
            
            FlyBodyGyro.CFrame = camera.CFrame
            FlyBodyVelocity.Velocity = moveDir.Unit == moveDir.Unit and moveDir.Unit * FlySpeed or Vector3.zero
            RunService.RenderStepped:Wait()
        end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
    end)
end

local function StopFlying()
    if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
end

-- ESP System Storage
local ESPHolders = {
    Eggs = {},
    Animals = {},
    Players = {}
}

local function ClearESP(category)
    for _, obj in pairs(ESPHolders[category]) do
        if obj and obj.Parent then obj:Destroy() end
    end
    ESPHolders[category] = {}
end

-- Rare Egg ESP Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.RareEggESP then
            ClearESP("Eggs")
            local function AddEggESP(eggModel)
                if not eggModel or not eggModel:IsA("Model") then return end
                local eggPart = eggModel:FindFirstChild("Egg") or eggModel:FindFirstChildWhichIsA("BasePart")
                if not eggPart then return end
                
                local isRare = false
                local overhead = eggPart:FindFirstChild("EggOverhead") or eggPart:FindFirstChildWhichIsA("Attachment")
                local eggUi = overhead and (overhead:FindFirstChild("EggInfoUi") or overhead:FindFirstChildWhichIsA("BillboardGui"))
                local mutationText = ""
                local hpText = ""
                
                if eggUi then
                    local mut = eggUi:FindFirstChild("Mutation")
                    if mut and mut:IsA("TextLabel") and mut.Text ~= "" then
                        mutationText = "[" .. mut.Text .. "] "
                        isRare = true
                    end
                    local hpList = eggUi:FindFirstChild("HpBarList")
                    local hpBar = hpList and hpList:FindFirstChild("HpBar")
                    local hpLabel = hpBar and hpBar:FindFirstChild("HpAmount")
                    if hpLabel and hpLabel:IsA("TextLabel") then
                        hpText = " • " .. hpLabel.Text
                    end
                end
                
                if isRare or eggModel.Name:find("3:") or eggModel.Name:find("2:") or eggModel.Name:find("Diamond") or eggModel.Name:find("Gold") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "Junejo_EggHighlight"
                    highlight.FillColor = mutationText:find("Diamond") and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(255, 215, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Adornee = eggModel
                    highlight.Parent = eggModel
                    table.insert(ESPHolders.Eggs, highlight)
                    
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "Junejo_EggTag"
                    bb.Adornee = eggPart
                    bb.Size = UDim2.new(0, 160, 0, 30)
                    bb.StudsOffset = Vector3.new(0, 3.5, 0)
                    bb.AlwaysOnTop = true
                    
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = mutationText .. eggModel.Name .. hpText
                    lbl.TextColor3 = highlight.FillColor
                    lbl.TextStrokeTransparency = 0.2
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 11
                    lbl.Parent = bb
                    bb.Parent = eggPart
                    table.insert(ESPHolders.Eggs, bb)
                end
            end
            
            local build = workspace:FindFirstChild("Build")
            local zoneBuilds = build and build:FindFirstChild("ZoneBuilds")
            if zoneBuilds then
                for _, zone in ipairs(zoneBuilds:GetChildren()) do
                    local eggsFolder = zone:FindFirstChild("Eggs")
                    if eggsFolder then
                        for _, egg in ipairs(eggsFolder:GetChildren()) do
                            AddEggESP(egg)
                        end
                    end
                end
            end
        else
            ClearESP("Eggs")
        end
    end
end)

-- Animal ESP Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.AnimalESP then
            ClearESP("Animals")
            for _, desc in ipairs(workspace:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Name == "StealPrompt" then
                    local parentPart = desc.Parent
                    if parentPart:IsA("Attachment") then parentPart = parentPart.Parent end
                    if parentPart and parentPart:IsA("BasePart") then
                        local objText = desc.ObjectText or "Animal"
                        local cleanText = objText:gsub("<[^>]+>", "")
                        
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "Junejo_AnimalHighlight"
                        highlight.FillColor = Color3.fromRGB(80, 255, 120)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.4
                        highlight.Adornee = parentPart.Parent or parentPart
                        highlight.Parent = parentPart
                        table.insert(ESPHolders.Animals, highlight)
                        
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "Junejo_AnimalTag"
                        bb.Adornee = parentPart
                        bb.Size = UDim2.new(0, 150, 0, 25)
                        bb.StudsOffset = Vector3.new(0, 2.5, 0)
                        bb.AlwaysOnTop = true
                        
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = "🐾 " .. cleanText
                        lbl.TextColor3 = Color3.fromRGB(80, 255, 120)
                        lbl.TextStrokeTransparency = 0.2
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 11
                        lbl.Parent = bb
                        bb.Parent = parentPart
                        table.insert(ESPHolders.Animals, bb)
                    end
                end
            end
        else
            ClearESP("Animals")
        end
    end
end)

-- Player ESP Loop
task.spawn(function()
    while true do
        task.wait(2.0)
        if Toggles.PlayerESP then
            ClearESP("Players")
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local char = player.Character
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local hl = Instance.new("Highlight")
                        hl.Name = "Junejo_PlayerHL"
                        hl.FillColor = Color3.fromRGB(255, 50, 75)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.Adornee = char
                        hl.Parent = char
                        table.insert(ESPHolders.Players, hl)
                        
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "Junejo_PlayerTag"
                        bb.Adornee = root
                        bb.Size = UDim2.new(0, 140, 0, 25)
                        bb.StudsOffset = Vector3.new(0, 3, 0)
                        bb.AlwaysOnTop = true
                        
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        local dist = (GetRootPart().Position - root.Position).Magnitude
                        lbl.Text = player.DisplayName .. " [" .. math.floor(dist) .. "m]"
                        lbl.TextColor3 = Color3.fromRGB(255, 80, 100)
                        lbl.TextStrokeTransparency = 0.2
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 11
                        lbl.Parent = bb
                        bb.Parent = root
                        table.insert(ESPHolders.Players, bb)
                    end
                end
            end
        else
            ClearESP("Players")
        end
    end
end)

-- Fast 0s Proximity Prompts Bypass
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    fireproximityprompt(prompt, 0)
end)

-- 24/7 Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.zero)
end)

-- ========================================================================
-- OFFICIAL UI 1 DESIGN: JUNEJO CLASSIC MATTE DARK (280px)
-- ========================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Junejo_BreakAndStealAnEgg_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

-- Mobile Floating Toggle Button
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatToggle"
FloatBtn.Size = UDim2.new(0, 38, 0, 38)
FloatBtn.Position = UDim2.new(0, 15, 0.45, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
FloatBtn.Text = "🥚"
FloatBtn.TextSize = 18
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.AutoButtonColor = false
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 10)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(35, 35, 42)
FloatStroke.Thickness = 1.2
FloatStroke.Parent = FloatBtn

-- Main Frame (UI 1 Standard: 280px width, 260px height)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 265)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -132)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "BREAK AND STEAL AN EGG"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(140, 140, 155)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = Header

local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 1, -1)
Divider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Divider.BorderSizePixel = 0
Divider.Parent = Header

-- Content Scroll Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "Content"
ScrollFrame.Size = UDim2.new(1, 0, 1, -78)
ScrollFrame.Position = UDim2.new(0, 0, 0, 38)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 2
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 4)
ContentLayout.Parent = ScrollFrame

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingLeft = UDim.new(0, 10)
ContentPadding.PaddingRight = UDim.new(0, 10)
ContentPadding.PaddingTop = UDim.new(0, 4)
ContentPadding.PaddingBottom = UDim.new(0, 4)
ContentPadding.Parent = ScrollFrame

-- Action Button Builder (UI 1 Standard: Full Width #1B1B20)
local function CreateActionButton(text, layoutOrder, onClick)
    local btn = Instance.new("TextButton")
    btn.Name = "Action_" .. text
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.LayoutOrder = layoutOrder
    btn.AutoButtonColor = false
    btn.Parent = ScrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 55)
    stroke.Thickness = 1
    stroke.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(27, 27, 32)}):Play()
        onClick()
    end)
    return btn
end

-- Toggle Row Builder (UI 1 Standard: Left Label, Right 20x20 Checkbox)
local function CreateToggleRow(name, key, layoutOrder, onToggle)
    local row = Instance.new("Frame")
    row.Name = "Row_" .. key
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder
    row.Parent = ScrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 4, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    
    local box = Instance.new("TextButton")
    box.Name = "Box"
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(1, -22, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    box.Text = ""
    box.AutoButtonColor = false
    box.Parent = row
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 5)
    boxCorner.Parent = box
    
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(45, 45, 55)
    boxStroke.Thickness = 1
    boxStroke.Parent = box
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(1, -6, 1, -6)
    fill.Position = UDim2.new(0, 3, 0, 3)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BackgroundTransparency = 1
    fill.BorderSizePixel = 0
    fill.Parent = box
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    local function UpdateUI()
        local enabled = Toggles[key]
        TweenService:Create(fill, TweenInfo.new(0.18), {
            BackgroundTransparency = enabled and 0 or 1
        }):Play()
        TweenService:Create(boxStroke, TweenInfo.new(0.18), {
            Color = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(45, 45, 55)
        }):Play()
    end
    
    box.MouseButton1Click:Connect(function()
        Toggles[key] = not Toggles[key]
        UpdateUI()
        if onToggle then onToggle(Toggles[key]) end
    end)
    
    return row
end

-- Speed Stepper Row Builder (UI 1 Standard: Dual Checkbox + Integrated Stepper Pill [ - 50 + ])
local function CreateSpeedRow(layoutOrder)
    local row = Instance.new("Frame")
    row.Name = "Row_WalkSpeed"
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder
    row.Parent = ScrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 110, 1, 0)
    label.Position = UDim2.new(0, 4, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "WalkSpeed"
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    
    -- Checkbox
    local box = Instance.new("TextButton")
    box.Name = "Box"
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(1, -125, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    box.Text = ""
    box.AutoButtonColor = false
    box.Parent = row
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 5)
    boxCorner.Parent = box
    
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(45, 45, 55)
    boxStroke.Thickness = 1
    boxStroke.Parent = box
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(1, -6, 1, -6)
    fill.Position = UDim2.new(0, 3, 0, 3)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BackgroundTransparency = 1
    fill.BorderSizePixel = 0
    fill.Parent = box
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    box.MouseButton1Click:Connect(function()
        Toggles.WalkSpeed = not Toggles.WalkSpeed
        TweenService:Create(fill, TweenInfo.new(0.18), {BackgroundTransparency = Toggles.WalkSpeed and 0 or 1}):Play()
        TweenService:Create(boxStroke, TweenInfo.new(0.18), {Color = Toggles.WalkSpeed and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(45, 45, 55)}):Play()
    end)
    
    -- Stepper Pill [ - 50 + ]
    local pill = Instance.new("Frame")
    pill.Name = "Pill"
    pill.Size = UDim2.new(0, 95, 0, 24)
    pill.Position = UDim2.new(1, -98, 0.5, -12)
    pill.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    pill.Parent = row
    
    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(0, 6)
    pillCorner.Parent = pill
    
    local pillStroke = Instance.new("UIStroke")
    pillStroke.Color = Color3.fromRGB(45, 45, 55)
    pillStroke.Thickness = 1
    pillStroke.Parent = pill
    
    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 26, 1, 0)
    minusBtn.BackgroundTransparency = 1
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 14
    minusBtn.Parent = pill
    
    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(1, -52, 1, 0)
    valLabel.Position = UDim2.new(0, 26, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(CustomWalkSpeed)
    valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 12
    valLabel.Parent = pill
    
    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 26, 1, 0)
    plusBtn.Position = UDim2.new(1, -26, 0, 0)
    plusBtn.BackgroundTransparency = 1
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 14
    plusBtn.Parent = pill
    
    minusBtn.MouseButton1Click:Connect(function()
        CustomWalkSpeed = math.max(16, CustomWalkSpeed - 10)
        valLabel.Text = tostring(CustomWalkSpeed)
    end)
    
    plusBtn.MouseButton1Click:Connect(function()
        CustomWalkSpeed = math.min(300, CustomWalkSpeed + 10)
        valLabel.Text = tostring(CustomWalkSpeed)
    end)
end

-- ========================================================================
-- POPULATE FEATURES (EXACT REQUESTED LIST)
-- ========================================================================

-- Action Button 1: Teleport to Base
CreateActionButton("Teleport to Base", 1, function()
    local baseCFrame = FindMyBase()
    local root = GetRootPart()
    if baseCFrame and root then
        root.CFrame = baseCFrame
        root.AssemblyLinearVelocity = Vector3.zero
    end
end)

-- Action Button 2: Set Base Position (Custom Anchor)
CreateActionButton("Set Base Position", 2, function()
    local root = GetRootPart()
    if root then
        SavedBaseCFrame = root.CFrame
    end
end)

-- Feature Toggles
CreateToggleRow("Instant Break (Infinite Hammer)", "InfiniteHammer", 3)
CreateToggleRow("Auto Break Rare Egg", "AutoBreakRare", 4)
CreateToggleRow("Auto Steal Rare Animal", "AutoStealRare", 5)
CreateToggleRow("Auto Deposit to Base", "AutoDeposit", 6)
CreateToggleRow("Auto Upgrade Base", "AutoUpgradeBase", 7)
CreateToggleRow("Auto Buy Best Pickaxe", "AutoBuyPickaxe", 8)
CreateToggleRow("Auto Train Speed", "AutoTrainSpeed", 9)
CreateToggleRow("Rare Egg ESP", "RareEggESP", 10)
CreateToggleRow("Animal ESP (Weight & Rarity)", "AnimalESP", 11)
CreateToggleRow("Player ESP", "PlayerESP", 12)
CreateSpeedRow(13)
CreateToggleRow("Fly Mode", "FlyMode", 14, function(state)
    if state then StartFlying() else StopFlying() end
end)
CreateToggleRow("Noclip", "Noclip", 15)
CreateToggleRow("Infinite Jump", "InfiniteJump", 16)

-- Zone Teleport Action Buttons (Zone 1 to 9 + Safe Zone)
local function TeleportToZone(zoneName)
    local root = GetRootPart()
    if not root then return end
    
    local hitboxes = workspace:FindFirstChild("Build") and workspace.Build:FindFirstChild("ZoneHitboxes")
    if hitboxes then
        local hb = hitboxes:FindFirstChild(zoneName)
        if hb and hb:IsA("BasePart") then
            root.CFrame = hb.CFrame + Vector3.new(0, 4, 0)
            root.AssemblyLinearVelocity = Vector3.zero
            return
        end
    end
    
    -- Special Zone 9 / Special Egg fallbacks
    if zoneName == "9" then
        local z9 = workspace:FindFirstChild("Zone 9")
        if z9 then
            local part = z9:FindFirstChildWhichIsA("BasePart", true)
            if part then
                root.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                root.AssemblyLinearVelocity = Vector3.zero
            end
        end
    elseif zoneName == "SafeZone" then
        if hitboxes and hitboxes:FindFirstChild("SafeZone") then
            root.CFrame = hitboxes.SafeZone.CFrame + Vector3.new(0, 4, 0)
        end
    end
end

CreateActionButton("Teleport: Safe Zone", 17, function() TeleportToZone("SafeZone") end)
CreateActionButton("Teleport: Zone 9 (Galaxy / Sun)", 18, function() TeleportToZone("9") end)
CreateActionButton("Teleport: Zone 8 (Fortune)", 19, function() TeleportToZone("8") end)
CreateActionButton("Teleport: Zone 7 (Angel / Volcano)", 20, function() TeleportToZone("7") end)

-- Mandatory Centered Footer (UI 1 Standard)
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 38)
Footer.Position = UDim2.new(0, 0, 1, -38)
Footer.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterDivider = Instance.new("Frame")
FooterDivider.Name = "FooterDivider"
FooterDivider.Size = UDim2.new(1, 0, 0, 1)
FooterDivider.Position = UDim2.new(0, 0, 0, 0)
FooterDivider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
FooterDivider.BorderSizePixel = 0
FooterDivider.Parent = Footer

local HubLabel = Instance.new("TextLabel")
HubLabel.Name = "HubLabel"
HubLabel.Size = UDim2.new(1, 0, 0, 14)
HubLabel.Position = UDim2.new(0, 0, 0, 6)
HubLabel.BackgroundTransparency = 1
HubLabel.Text = "ULTRA SCRIPT HUB"
HubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HubLabel.Font = Enum.Font.GothamBold
HubLabel.TextSize = 11
HubLabel.Parent = Footer

local CreatorLabel = Instance.new("TextLabel")
CreatorLabel.Name = "CreatorLabel"
CreatorLabel.Size = UDim2.new(1, 0, 0, 12)
CreatorLabel.Position = UDim2.new(0, 0, 0, 20)
CreatorLabel.BackgroundTransparency = 1
CreatorLabel.Text = "Made by Junejo"
CreatorLabel.TextColor3 = Color3.fromRGB(136, 136, 153)
CreatorLabel.Font = Enum.Font.Gotham
CreatorLabel.TextSize = 10
CreatorLabel.Parent = Footer

-- UI Toggle / Dragging Systems
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatBtn.Visible = true
end)

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Draggable MainFrame
local dragging, dragInput, dragStart, startPos
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

-- Draggable FloatBtn
local fDragging, fDragInput, fDragStart, fStartPos
FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fDragging = true
        fDragStart = input.Position
        fStartPos = FloatBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                fDragging = false
            end
        end)
    end
end)

FloatBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        fDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == fDragInput and fDragging then
        local delta = input.Position - fDragStart
        FloatBtn.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
    end
end)
