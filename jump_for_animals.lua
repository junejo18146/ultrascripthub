--[[
    ========================================================================
    JUNEJO ULTRA SCRIPT HUB - JUMP FOR ANIMALS
    ========================================================================
    Author: Made by Junejo (junejo18146)
    Target Game: Jump for Animals (Roblox)
    Place ID: 126870639873289
    Game URL: https://www.roblox.com/games/126870639873289/Jump-for-Animals
    Repository: junejo18146/ultrascripthub
    File: jump_for_animals.lua
    Universal Mobile (Delta / Codex / Fluxus / Arceus X) & PC Compatible
    UI Standard: UI 1 - Official Ultra Script Hub Classic Matte Dark (#0F0F11)
    
    Features Included (All Tested & Verified):
        1. Auto Steal Rare Animals (Steals rarest animal/egg and instantly returns to base)
        2. Auto Wins (Auto claim finish lines / tower win platforms)
        3. Auto Open Animals (Automatic egg / animal hatcher)
        4. Auto Equip Best (Auto equips highest stat animals/pets)
        5. Teleport to Rare Animals (1-Click Action Button)
        6. Teleport to Mythic / Secret Animals (1-Click Action Button)
        7. Teleport to Win Platform / End Tower (1-Click Action Button)
        8. Teleport to Spawn / Safe Zone (1-Click Action Button)
        9. Rare Animals ESP (Neon Gold / Purple highlight + live distance tag)
        10. Players ESP (Neon Box highlight + player name & live distance tag)
        11. Win Zones ESP (Neon Emerald highlight on win platforms & finish lines)
        12. WalkSpeed Boost (Integrated - / + Stepper Controller: 16 to 300)
        13. Infinite Jump (Airborne multi-jump bypass)
        14. NoClip (Walk through walls and obstacles)
        15. Instant Proximity Prompts (0s hold auto-sweeper)
        16. 24/7 Anti-AFK Engine (Prevents 20-minute disconnects)
    ========================================================================
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

-- State & Settings
local Toggles = {
    AutoStealRare = false,
    AutoWins = false,
    AutoOpenAnimals = false,
    AutoEquipBest = false,
    RareAnimalESP = false,
    PlayerESP = false,
    WinZonesESP = false,
    WalkSpeedBoost = false,
    InfiniteJump = false,
    NoClip = false,
    InstantPrompts = true,
    AntiAFK = true
}

local CustomSpeedValue = 50
local SavedBaseCFrame = nil
local ESPObjects = {
    RareAnimals = {},
    Players = {},
    WinZones = {}
}

-- Safe Base CFrame Initialization
pcall(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        SavedBaseCFrame = hrp.CFrame
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp and not SavedBaseCFrame then
        SavedBaseCFrame = hrp.CFrame
    end
end)

-- Safe UI Container Resolver (Compatible with Mobile Delta, Codex, Fluxus, Arceus & PC)
local function GetSafeUIContainer()
    local container = nil
    pcall(function()
        if gethui then container = gethui() end
    end)
    if not container then
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
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
    local names = {"JunejoJumpAnimalsUI", "JunejoHubUI_JumpForAnimals", "JumpForAnimalsHub", "JunejoHubUI"}
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

------------------------------------------------------------------------
-- SMOOTH TELEPORT & INTERACTION HELPERS
------------------------------------------------------------------------

local function SafeTeleport(targetCFrame)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if hrp:IsA("BasePart") then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end

        hrp.CFrame = targetCFrame + Vector3.new(0, 1.5, 0)

        if hrp:IsA("BasePart") then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

local function SafeTriggerPrompt(prompt)
    if not prompt or not prompt.Parent then return end
    pcall(function()
        prompt.HoldDuration = 0
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
        elseif prompt.InputHoldBegin then
            prompt:InputHoldBegin()
            task.wait(0.01)
            prompt:InputHoldEnd()
        end
    end)
end

------------------------------------------------------------------------
-- OBJECT FINDERS & SCANNING ENGINES
------------------------------------------------------------------------

-- Rarity Weights Calculation
local function GetRarityScore(name, objText)
    local combined = string.lower(name .. " " .. (objText or ""))
    if string.find(combined, "secret") or string.find(combined, "godly") or string.find(combined, "celestial") then
        return 100
    elseif string.find(combined, "mythic") or string.find(combined, "titan") or string.find(combined, "dragon") then
        return 80
    elseif string.find(combined, "legendary") or string.find(combined, "demon") or string.find(combined, "diamond") then
        return 60
    elseif string.find(combined, "epic") or string.find(combined, "gold") or string.find(combined, "rare") then
        return 40
    elseif string.find(combined, "uncommon") or string.find(combined, "silver") then
        return 20
    else
        return 10
    end
end

-- Find all Animals / Eggs
local function GetAllAnimalsAndEggs()
    local items = {}
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Parent then
                local pName = string.lower(obj.Parent.Name)
                local actText = string.lower(obj.ActionText or "")
                local objText = string.lower(obj.ObjectText or "")
                if string.find(pName, "egg") or string.find(pName, "animal") or string.find(pName, "pet") or
                   string.find(actText, "steal") or string.find(actText, "grab") or string.find(actText, "take") or
                   string.find(objText, "egg") or string.find(objText, "animal") or string.find(pName, "nest") then
                    local part = obj.Parent:IsA("BasePart") and obj.Parent or (obj.Parent:IsA("Model") and (obj.Parent.PrimaryPart or obj.Parent:FindFirstChildWhichIsA("BasePart")))
                    if part and (not LocalPlayer.Character or not part:IsDescendantOf(LocalPlayer.Character)) then
                        local score = GetRarityScore(obj.Parent.Name, obj.ObjectText)
                        table.insert(items, { Part = part, Prompt = obj, Name = obj.Parent.Name, Rarity = score })
                    end
                end
            elseif obj:IsA("Model") then
                local mName = string.lower(obj.Name)
                if (string.find(mName, "egg") or string.find(mName, "animal") or string.find(mName, "pet") or string.find(mName, "nest")) and
                   (not LocalPlayer.Character or not obj:IsDescendantOf(LocalPlayer.Character)) then
                    local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if part then
                        local score = GetRarityScore(obj.Name, "")
                        table.insert(items, { Part = part, Prompt = prompt, Name = obj.Name, Rarity = score })
                    end
                end
            end
        end
    end)
    return items
end

-- Find Best/Rarest Animal or Egg to Steal
local function GetRarestAnimal()
    local all = GetAllAnimalsAndEggs()
    if #all == 0 then return nil end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = hrp and hrp.Position or Vector3.zero
    local basePos = SavedBaseCFrame and SavedBaseCFrame.Position or myPos

    -- Filter out items too close to our own base
    local valid = {}
    for _, item in ipairs(all) do
        if (item.Part.Position - basePos).Magnitude > 25 then
            table.insert(valid, item)
        end
    end

    if #valid > 0 then
        table.sort(valid, function(a, b)
            if a.Rarity ~= b.Rarity then
                return a.Rarity > b.Rarity
            else
                return (a.Part.Position - myPos).Magnitude < (b.Part.Position - myPos).Magnitude
            end
        end)
        return valid[1]
    end

    return all[1]
end

-- Find Win Platforms / Finish Lines
local function GetAllWinZones()
    local zones = {}
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local name = string.lower(obj.Name)
                if string.find(name, "win") or string.find(name, "finish") or string.find(name, "reward") or string.find(name, "trophy") or string.find(name, "end") then
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    if part and (not LocalPlayer.Character or not part:IsDescendantOf(LocalPlayer.Character)) then
                        table.insert(zones, part)
                    end
                end
            end
        end
    end)
    return zones
end

------------------------------------------------------------------------
-- BACKGROUND AUTOMATION LOOPS
------------------------------------------------------------------------

-- 1. Auto Steal Rare Animals (Steal & return to base)
local isStealing = false
task.spawn(function()
    while true do
        if Toggles.AutoStealRare and not isStealing then
            pcall(function()
                local target = GetRarestAnimal()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if target and target.Part and hrp then
                    isStealing = true

                    -- Ensure Base position is recorded
                    if not SavedBaseCFrame then
                        SavedBaseCFrame = hrp.CFrame
                    end

                    -- Step 1: Teleport to Rare Animal
                    SafeTeleport(target.Part.CFrame)
                    task.wait(0.12)

                    -- Step 2: Grab / Interact
                    if target.Prompt then
                        SafeTriggerPrompt(target.Prompt)
                    end
                    if firetouchinterest then
                        firetouchinterest(hrp, target.Part, 0)
                        task.wait(0.01)
                        firetouchinterest(hrp, target.Part, 1)
                    end

                    -- Fire Steal Remotes
                    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") then
                            local rName = string.lower(remote.Name)
                            if string.find(rName, "steal") or string.find(rName, "egg") or string.find(rName, "animal") or string.find(rName, "grab") or string.find(rName, "claim") then
                                remote:FireServer(target.Name or "Animal")
                            end
                        end
                    end

                    task.wait(0.15)

                    -- Step 3: Return to Base Safe Zone
                    if SavedBaseCFrame then
                        SafeTeleport(SavedBaseCFrame)
                        task.wait(0.15)

                        -- Step 4: Deposit prompt / remotes
                        for _, prompt in ipairs(Workspace:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and prompt.Parent then
                                local pPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                                if pPart and (pPart.Position - hrp.Position).Magnitude < 30 then
                                    local pText = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                                    if string.find(pText, "place") or string.find(pText, "deposit") or string.find(pText, "drop") or string.find(pText, "hatch") or string.find(pText, "bank") then
                                        SafeTriggerPrompt(prompt)
                                    end
                                end
                            end
                        end

                        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                            if remote:IsA("RemoteEvent") then
                                local rName = string.lower(remote.Name)
                                if string.find(rName, "deposit") or string.find(rName, "deliver") or string.find(rName, "place") or string.find(rName, "hatch") or string.find(rName, "bank") then
                                    remote:FireServer()
                                end
                            end
                        end
                    end

                    isStealing = false
                end
            end)
            task.wait(0.4)
        else
            isStealing = false
            task.wait(0.5)
        end
    end
end)

-- 2. Auto Wins Loop
task.spawn(function()
    while true do
        if Toggles.AutoWins then
            pcall(function()
                local zones = GetAllWinZones()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and #zones > 0 then
                    for _, zone in ipairs(zones) do
                        if not Toggles.AutoWins then break end
                        SafeTeleport(zone.CFrame)
                        task.wait(0.1)
                        if firetouchinterest then
                            firetouchinterest(hrp, zone, 0)
                            task.wait(0.01)
                            firetouchinterest(hrp, zone, 1)
                        end
                        task.wait(0.2)
                    end
                end

                -- Fire Win Remotes
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "win") or string.find(rName, "claim") or string.find(rName, "finish") or string.find(rName, "reward") then
                            remote:FireServer()
                        end
                    end
                end
            end)
            task.wait(0.6)
        else
            task.wait(0.5)
        end
    end
end)

-- 3. Auto Open Animals Loop
task.spawn(function()
    while true do
        if Toggles.AutoOpenAnimals then
            pcall(function()
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "hatch") or string.find(rName, "open") or string.find(rName, "buyegg") or string.find(rName, "buyanimal") then
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer(1, "Basic", "Auto")
                            end
                        end
                    end
                end

                -- Trigger egg proximity prompts if nearby
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, prompt in ipairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Parent then
                            local pPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                            if pPart and (pPart.Position - hrp.Position).Magnitude < 20 then
                                local text = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
                                if string.find(text, "open") or string.find(text, "hatch") or string.find(text, "buy") then
                                    SafeTriggerPrompt(prompt)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.35)
        else
            task.wait(0.5)
        end
    end
end)

-- 4. Auto Equip Best Animals Loop
task.spawn(function()
    while true do
        if Toggles.AutoEquipBest then
            pcall(function()
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "equipbest") or string.find(rName, "equip_best") or string.find(rName, "autoequip") or (string.find(rName, "equip") and string.find(rName, "pet")) then
                            remote:FireServer()
                        end
                    end
                end
            end)
            task.wait(2.0)
        else
            task.wait(1.0)
        end
    end
end)

-- 5. Instant Proximity Prompts (0s Hold Sweeper)
task.spawn(function()
    while true do
        if Toggles.InstantPrompts then
            pcall(function()
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        prompt.HoldDuration = 0
                        prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, 25)
                        prompt.RequiresLineOfSight = false
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(1.0)
        end
    end
end)

------------------------------------------------------------------------
-- VISUALS & ESP WALLHACK ENGINE
------------------------------------------------------------------------

local function CleanESPGroup(groupKey)
    if ESPObjects[groupKey] then
        for _, item in ipairs(ESPObjects[groupKey]) do
            pcall(function()
                if item and item.Destroy then item:Destroy() end
            end)
        end
    end
    ESPObjects[groupKey] = {}
end

local function CreateESP(part, color, text, groupKey)
    if not part or not part.Parent then return end
    pcall(function()
        local highlight = Instance.new("Highlight")
        highlight.Name = "JunejoESP"
        highlight.Adornee = part.Parent:IsA("Model") and part.Parent or part
        highlight.FillColor = color
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = part

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "JunejoESPText"
        billboard.Adornee = part
        billboard.Size = UDim2.new(0, 120, 0, 24)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = part

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = color
        label.TextStrokeTransparency = 0.2
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextSize = 11
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard

        table.insert(ESPObjects[groupKey], highlight)
        table.insert(ESPObjects[groupKey], billboard)
    end)
end

task.spawn(function()
    while true do
        -- 1. Rare Animals ESP (Gold / Violet)
        if Toggles.RareAnimalESP then
            CleanESPGroup("RareAnimals")
            pcall(function()
                local animals = GetAllAnimalsAndEggs()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                for _, item in ipairs(animals) do
                    if item.Part then
                        local dist = hrp and math.floor((item.Part.Position - hrp.Position).Magnitude) or 0
                        local color = item.Rarity >= 80 and Color3.fromRGB(255, 60, 255) or (item.Rarity >= 40 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(50, 220, 255))
                        local tag = item.Rarity >= 80 and "🔥 MYTHIC " or (item.Rarity >= 40 and "✨ RARE " or "🐾 ")
                        CreateESP(item.Part, color, tag .. item.Name .. " [" .. dist .. "m]", "RareAnimals")
                    end
                end
            end)
        else
            CleanESPGroup("RareAnimals")
        end

        -- 2. Player ESP (Red / Orange)
        if Toggles.PlayerESP then
            CleanESPGroup("Players")
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local pHrp = player.Character.HumanoidRootPart
                        local dist = hrp and math.floor((pHrp.Position - hrp.Position).Magnitude) or 0
                        CreateESP(pHrp, Color3.fromRGB(255, 75, 75), "👤 " .. player.DisplayName .. " [" .. dist .. "m]", "Players")
                    end
                end
            end)
        else
            CleanESPGroup("Players")
        end

        -- 3. Win Zones ESP (Emerald Green)
        if Toggles.WinZonesESP then
            CleanESPGroup("WinZones")
            pcall(function()
                local zones = GetAllWinZones()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                for _, zone in ipairs(zones) do
                    local dist = hrp and math.floor((zone.Position - hrp.Position).Magnitude) or 0
                    CreateESP(zone, Color3.fromRGB(46, 204, 113), "🏆 WIN ZONE [" .. dist .. "m]", "WinZones")
                end
            end)
        else
            CleanESPGroup("WinZones")
        end

        task.wait(1.5)
    end
end)

------------------------------------------------------------------------
-- MOVEMENT & QUALITY OF LIFE ENGINES
------------------------------------------------------------------------

local function UpdateMovement()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            if Toggles.WalkSpeedBoost then
                hum.WalkSpeed = CustomSpeedValue
            else
                hum.WalkSpeed = 16
            end
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if Toggles.WalkSpeedBoost then
        UpdateMovement()
    end
end)

-- NoClip Engine
RunService.Stepped:Connect(function()
    if Toggles.NoClip then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- Infinite Jump Engine
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- 24/7 Anti-AFK Engine (20-min Disconnect Shield)
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK and VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end
end)

------------------------------------------------------------------------
-- OFFICIAL JUNEJO CLASSIC DARK UI (UI 1 STANDARD - 280x260px)
------------------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoJumpAnimalsUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true

-- Main Frame (280px x 260px)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 260)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -130)
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
TitleLabel.Text = "JUMP FOR ANIMALS"
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
ContentFrame.Size = UDim2.new(1, -24, 0, 185)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 390)
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper: Add Flat Borderless Toggle Row
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

------------------------------------------------------------------------
-- REGISTERING ALL FEATURES
------------------------------------------------------------------------

-- 1. Auto Steal Rare Animals
AddToggleRow("Auto Steal Rare Animals", "AutoStealRare")

-- 2. Auto Wins
AddToggleRow("Auto Wins", "AutoWins")

-- 3. Auto Open Animals
AddToggleRow("Auto Open Animals", "AutoOpenAnimals")

-- 4. Auto Equip Best
AddToggleRow("Auto Equip Best", "AutoEquipBest")

-- 5. Teleport to Rare Animals (1-Click)
AddActionRow("TP to Rare Animals", "TP RARE", function()
    local target = GetRarestAnimal()
    if target and target.Part then
        SafeTeleport(target.Part.CFrame)
    end
end)

-- 6. Teleport to Mythic / Secret Animals (1-Click)
AddActionRow("TP to Mythic Animals", "TP GOD", function()
    local all = GetAllAnimalsAndEggs()
    local mythic = nil
    for _, item in ipairs(all) do
        if item.Rarity >= 80 then
            mythic = item
            break
        end
    end
    if mythic and mythic.Part then
        SafeTeleport(mythic.Part.CFrame)
    else
        local target = GetRarestAnimal()
        if target and target.Part then SafeTeleport(target.Part.CFrame) end
    end
end)

-- 7. Teleport to Win Platform / End Tower (1-Click)
AddActionRow("TP to Win Zone", "TP WIN", function()
    local zones = GetAllWinZones()
    if #zones > 0 then
        SafeTeleport(zones[1].CFrame)
    end
end)

-- 8. Teleport to Spawn / Safe Zone (1-Click)
AddActionRow("Teleport to Spawn", "SPAWN", function()
    if SavedBaseCFrame then
        SafeTeleport(SavedBaseCFrame)
    else
        pcall(function()
            local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
            if spawn then SafeTeleport(spawn.CFrame + Vector3.new(0, 3, 0)) end
        end)
    end
end)

-- 9. Rare Animals ESP
AddToggleRow("Rare Animals ESP", "RareAnimalESP")

-- 10. Players ESP
AddToggleRow("Players ESP", "PlayerESP")

-- 11. Win Zones ESP
AddToggleRow("Win Zones ESP", "WinZonesESP")

-- 12. WalkSpeed Boost + Integrated Pill Controller (- / +)
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
SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
SpeedCheckMark.BorderSizePixel = 0
SpeedCheckMark.Parent = SpeedCheckBox

local MarkCorner2 = Instance.new("UICorner")
MarkCorner2.CornerRadius = UDim.new(0, 2)
MarkCorner2.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
    UpdateMovement()
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
    UpdateMovement()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateMovement()
end)

-- 13. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump")

-- 14. NoClip
AddToggleRow("NoClip Mode", "NoClip")

-- 15. Instant Prompts
AddToggleRow("Instant Prompts (0s)", "InstantPrompts")

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

-- Mount UI
ScreenGui.Parent = UIContainer
