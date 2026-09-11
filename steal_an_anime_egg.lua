-- ====================================================================
-- ULTRA SCRIPT HUB - STEAL AN ANIME EGG (V2.0 COMPACT SCROLLING EDITION)
-- Creator: Junejo (junejo18146)
-- Target Game: Steal An Anime Egg (Place ID: 76377501906469)
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
    task.wait(1)
    if HumanoidRootPart then
        SavedBaseCFrame = HumanoidRootPart.CFrame
    end
end)

-- Feature Toggles
local Toggles = {
    AutoSteal = false,
    InstantPrompt = false,
    AutoDeposit = false,
    AutoCollectCash = false,
    AutoHatch = false,
    AutoRebirth = false,
    AutoAttackBoss = false,
    EggESP = false,
    PlayerESP = false,
    BaseESP = false,
    BossESP = false,
    WalkSpeedBoost = false,
    InfiniteJump = false,
    AntiRagdoll = false
}

local CustomSpeedValue = 32
local ESPStorage = {
    Eggs = {},
    Players = {},
    Bases = {},
    Boss = {}
}

-- Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Speed Enforcer Loop (Bypasses Game Anti-Cheat Overrides)
local function UpdateCharacterSpeed()
    if Humanoid then
        Humanoid.WalkSpeed = Toggles.WalkSpeedBoost and CustomSpeedValue or 16
    end
end

RunService.Heartbeat:Connect(function()
    if Toggles.WalkSpeedBoost and Humanoid and Humanoid.WalkSpeed ~= CustomSpeedValue then
        Humanoid.WalkSpeed = CustomSpeedValue
    end
    if Toggles.AntiRagdoll and Humanoid then
        Humanoid.PlatformStand = false
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Instant Steal / Prompt Bypass (0s Hold)
local function PatchPrompt(prompt)
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 40
        prompt.RequiresLineOfSight = false
    end
end

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
    if Toggles.InstantPrompt and player == LocalPlayer then
        fireproximityprompt(prompt, 0)
    end
end)

task.spawn(function()
    while true do
        if Toggles.InstantPrompt then
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    PatchPrompt(prompt)
                end
            end
        end
        task.wait(0.8)
    end
end)

-- Robust Multi-Method Base Detector
local function FindMyBase()
    -- 1. Check Plots/Bases Folders
    local potentialFolders = {
        Workspace:FindFirstChild("Bases"),
        Workspace:FindFirstChild("Plots"),
        Workspace:FindFirstChild("PlayerBases"),
        Workspace:FindFirstChild("Islands"),
        Workspace:FindFirstChild("Houses")
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

    -- 2. Deep scan across Workspace
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
        local nest = base:FindFirstChild("Nest", true) or base:FindFirstChild("Deposit", true) or base:FindFirstChild("EggStand", true) or base:FindFirstChild("Spawn", true) or base:FindFirstChild("Collector", true)
        if nest and nest:IsA("BasePart") then
            return nest.CFrame * CFrame.new(0, 3, 0)
        elseif base:IsA("Model") and (base.PrimaryPart or base:FindFirstChildWhichIsA("BasePart")) then
            local part = base.PrimaryPart or base:FindFirstChildWhichIsA("BasePart")
            return part.CFrame * CFrame.new(0, 3, 0)
        end
    end
    return SavedBaseCFrame or (HumanoidRootPart and HumanoidRootPart.CFrame)
end

-- ====================================================================
-- AUTO FARM ENGINES
-- ====================================================================

-- 1. Auto Steal Eggs Loop
task.spawn(function()
    while true do
        if Toggles.AutoSteal and HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
            pcall(function()
                local eggTargets = {}
                
                -- Collect all available stealable eggs in arena
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local text = string.lower(prompt.ActionText .. " " .. prompt.ObjectText)
                        local parentName = string.lower(prompt.Parent and prompt.Parent.Name or "")
                        if string.find(text, "steal") or string.find(text, "grab") or string.find(text, "take") or string.find(text, "egg") or string.find(parentName, "egg") or string.find(parentName, "nest") then
                            local part = prompt.Parent
                            if part:IsA("BasePart") then
                                table.insert(eggTargets, { part = part, prompt = prompt })
                            elseif part:IsA("Model") and (part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart")) then
                                table.insert(eggTargets, { part = part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart"), prompt = prompt })
                            end
                        end
                    end
                end

                if #eggTargets > 0 then
                    for _, target in ipairs(eggTargets) do
                        if not Toggles.AutoSteal then break end
                        if target.part and target.part.Parent then
                            -- Teleport directly to egg
                            HumanoidRootPart.CFrame = target.part.CFrame * CFrame.new(0, 2, 0)
                            task.wait(0.15)
                            
                            -- Multi-Method Prompt Trigger
                            PatchPrompt(target.prompt)
                            fireproximityprompt(target.prompt, 0)
                            fireproximityprompt(target.prompt, 1)
                            task.wait(0.2)

                            -- Auto Teleport back to Base & secure
                            local depositCFrame = GetBaseDepositPosition()
                            if depositCFrame then
                                HumanoidRootPart.CFrame = depositCFrame
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.8)
    end
end)

-- 2. Auto Deposit Eggs Loop
task.spawn(function()
    while true do
        if Toggles.AutoDeposit and HumanoidRootPart then
            pcall(function()
                local base = FindMyBase()
                if base then
                    for _, prompt in ipairs(base:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            PatchPrompt(prompt)
                            fireproximityprompt(prompt, 0)
                        end
                    end
                    -- Touch deposit pads
                    for _, part in ipairs(base:GetDescendants()) do
                        if part:IsA("BasePart") and (string.find(string.lower(part.Name), "deposit") or string.find(string.lower(part.Name), "nest") or string.find(string.lower(part.Name), "collector")) then
                            firetouchinterest(HumanoidRootPart, part, 0)
                            firetouchinterest(HumanoidRootPart, part, 1)
                        end
                    end
                end

                -- Sweep Deposit Remotes
                local depositRemotes = {"Deposit", "DepositEgg", "StoreEgg", "PlaceEgg", "CollectEgg", "SellEgg"}
                for _, rName in ipairs(depositRemotes) do
                    local rem = ReplicatedStorage:FindFirstChild(rName, true)
                    if rem and rem:IsA("RemoteEvent") then
                        rem:FireServer()
                    elseif rem and rem:IsA("RemoteFunction") then
                        rem:InvokeServer()
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

-- 3. Auto Collect Cash Engine
task.spawn(function()
    while true do
        if Toggles.AutoCollectCash and HumanoidRootPart then
            pcall(function()
                -- Magnet pull dropped coins/cash in Workspace
                for _, item in ipairs(Workspace:GetChildren()) do
                    local iName = string.lower(item.Name)
                    if string.find(iName, "coin") or string.find(iName, "cash") or string.find(iName, "money") or string.find(iName, "drop") or string.find(iName, "gem") or string.find(iName, "yen") then
                        if item:IsA("BasePart") then
                            item.CFrame = HumanoidRootPart.CFrame
                            firetouchinterest(HumanoidRootPart, item, 0)
                            firetouchinterest(HumanoidRootPart, item, 1)
                        elseif item:IsA("Model") then
                            local prim = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                            if prim then
                                prim.CFrame = HumanoidRootPart.CFrame
                                firetouchinterest(HumanoidRootPart, prim, 0)
                                firetouchinterest(HumanoidRootPart, prim, 1)
                            end
                        end
                    end
                end

                -- Base ATM / Collector Pad Magnet
                local base = FindMyBase()
                if base then
                    for _, p in ipairs(base:GetDescendants()) do
                        if p:IsA("BasePart") and (string.find(string.lower(p.Name), "cash") or string.find(string.lower(p.Name), "atm") or string.find(string.lower(p.Name), "collect")) then
                            firetouchinterest(HumanoidRootPart, p, 0)
                            firetouchinterest(HumanoidRootPart, p, 1)
                        end
                    end
                end
            end)
        end
        task.wait(0.4)
    end
end)

-- 4. Auto Hatch Eggs Engine
task.spawn(function()
    while true do
        if Toggles.AutoHatch then
            pcall(function()
                local hatchRemotes = {"Hatch", "HatchEgg", "OpenEgg", "BuyEgg", "EggHatch", "Roll", "Summon", "Draw"}
                for _, name in ipairs(hatchRemotes) do
                    local rem = ReplicatedStorage:FindFirstChild(name, true)
                    if rem and rem:IsA("RemoteEvent") then
                        rem:FireServer(1)
                        rem:FireServer("Egg", 1)
                        rem:FireServer("AnimeEgg", 1)
                    elseif rem and rem:IsA("RemoteFunction") then
                        rem:InvokeServer(1)
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- 5. Auto Rebirth Engine
task.spawn(function()
    while true do
        if Toggles.AutoRebirth then
            pcall(function()
                local rebirthRemotes = {"Rebirth", "AutoRebirth", "BuyRebirth", "RebirthEvent", "Prestige", "Ascend"}
                for _, name in ipairs(rebirthRemotes) do
                    local rem = ReplicatedStorage:FindFirstChild(name, true)
                    if rem and rem:IsA("RemoteEvent") then
                        rem:FireServer(1)
                        rem:FireServer()
                    elseif rem and rem:IsA("RemoteFunction") then
                        rem:InvokeServer(1)
                        rem:InvokeServer()
                    end
                end
            end)
        end
        task.wait(1.5)
    end
end)

-- 6. Auto Attack Boss Engine
task.spawn(function()
    while true do
        if Toggles.AutoAttackBoss and HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
            pcall(function()
                local bossModel = nil
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Humanoid") and obj.Parent ~= Character and (obj.MaxHealth >= 1000 or string.find(string.lower(obj.Parent.Name), "boss") or obj.Parent:FindFirstChild("bosshealth") or obj.Parent:FindFirstChild("bosshealthmax")) then
                        bossModel = obj.Parent
                        break
                    end
                end

                if bossModel then
                    local bossPart = bossModel:FindFirstChild("HumanoidRootPart") or bossModel:FindFirstChild("Head") or bossModel:FindFirstChildWhichIsA("BasePart")
                    if bossPart then
                        -- Hover safely above boss
                        HumanoidRootPart.CFrame = bossPart.CFrame * CFrame.new(0, 10, 0)
                        
                        -- Equip tool and attack
                        local tool = Character:FindFirstChildWhichIsA("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                        if tool then
                            if tool.Parent ~= Character then
                                Humanoid:EquipTool(tool)
                            end
                            tool:Activate()
                        end

                        local attackRemotes = {"Attack", "Hit", "DamageBoss", "BossHit", "Punch", "Slash", "Damage"}
                        for _, rName in ipairs(attackRemotes) do
                            local rem = ReplicatedStorage:FindFirstChild(rName, true)
                            if rem and rem:IsA("RemoteEvent") then
                                rem:FireServer(bossModel)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.2)
    end
end)

-- ====================================================================
-- ESP SYSTEMS (EGGS, PLAYERS, BASES, BOSS)
-- ====================================================================

local function ClearESPFolder(list)
    for _, item in ipairs(list) do
        if item then item:Destroy() end
    end
    return {}
end

-- 1. Anime Egg ESP
task.spawn(function()
    while true do
        if Toggles.EggESP then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if (string.find(string.lower(obj.Name), "egg") or string.find(string.lower(obj.Name), "nest")) and (obj:IsA("BasePart") or obj:IsA("Model")) and not obj:FindFirstChild("JunejoEggHighlight") then
                    local targetPart = obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"))
                    if targetPart then
                        local hl = Instance.new("Highlight")
                        hl.Name = "JunejoEggHighlight"
                        hl.FillColor = Color3.fromRGB(255, 180, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.4
                        hl.Adornee = obj
                        hl.Parent = obj
                        table.insert(ESPStorage.Eggs, hl)

                        local bb = Instance.new("BillboardGui")
                        bb.Name = "JunejoEggBillboard"
                        bb.Adornee = targetPart
                        bb.Size = UDim2.new(0, 120, 0, 24)
                        bb.StudsOffset = Vector3.new(0, 2.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = targetPart

                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.Text = "🥚 " .. obj.Name
                        txt.TextColor3 = Color3.fromRGB(255, 220, 50)
                        txt.TextSize = 11
                        txt.Font = Enum.Font.GothamBold
                        txt.Parent = bb

                        table.insert(ESPStorage.Eggs, bb)
                    end
                end
            end
        else
            ESPStorage.Eggs = ClearESPFolder(ESPStorage.Eggs)
        end
        task.wait(2.5)
    end
end)

-- 2. Player ESP
task.spawn(function()
    while true do
        if Toggles.PlayerESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and not plr.Character:FindFirstChild("JunejoPlrHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "JunejoPlrHighlight"
                    hl.FillColor = Color3.fromRGB(255, 60, 60)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.Adornee = plr.Character
                    hl.Parent = plr.Character
                    table.insert(ESPStorage.Players, hl)

                    local bb = Instance.new("BillboardGui")
                    bb.Name = "JunejoPlrBillboard"
                    bb.Adornee = plr.Character.HumanoidRootPart
                    bb.Size = UDim2.new(0, 120, 0, 24)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = plr.Character.HumanoidRootPart

                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = "👤 " .. plr.DisplayName
                    txt.TextColor3 = Color3.fromRGB(255, 100, 100)
                    txt.TextSize = 11
                    txt.Font = Enum.Font.GothamBold
                    txt.Parent = bb

                    table.insert(ESPStorage.Players, bb)
                end
            end
        else
            ESPStorage.Players = ClearESPFolder(ESPStorage.Players)
        end
        task.wait(2.5)
    end
end)

-- 3. Player Base ESP
task.spawn(function()
    while true do
        if Toggles.BaseESP then
            local basesFolder = Workspace:FindFirstChild("Bases") or Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("PlayerBases")
            if basesFolder then
                for _, base in ipairs(basesFolder:GetChildren()) do
                    if not base:FindFirstChild("JunejoBaseHighlight") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "JunejoBaseHighlight"
                        hl.FillColor = Color3.fromRGB(0, 180, 255)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.6
                        hl.Adornee = base
                        hl.Parent = base
                        table.insert(ESPStorage.Bases, hl)
                    end
                end
            end
        else
            ESPStorage.Bases = ClearESPFolder(ESPStorage.Bases)
        end
        task.wait(3)
    end
end)

-- 4. Boss ESP
task.spawn(function()
    while true do
        if Toggles.BossESP then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Humanoid") and obj.Parent ~= Character and (obj.MaxHealth >= 1000 or string.find(string.lower(obj.Parent.Name), "boss") or obj.Parent:FindFirstChild("bosshealth")) and not obj.Parent:FindFirstChild("JunejoBossHighlight") then
                    local bossModel = obj.Parent
                    local hl = Instance.new("Highlight")
                    hl.Name = "JunejoBossHighlight"
                    hl.FillColor = Color3.fromRGB(200, 50, 255)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.4
                    hl.Adornee = bossModel
                    hl.Parent = bossModel
                    table.insert(ESPStorage.Boss, hl)
                end
            end
        else
            ESPStorage.Boss = ClearESPFolder(ESPStorage.Boss)
        end
        task.wait(3)
    end
end)

-- ====================================================================
-- JUNEJO OFFICIAL COMPACT SCROLLING UI (5 FEATURES VISIBLE AT A TIME)
-- ====================================================================

local CoreGui = game:GetService("CoreGui")
local ExistingUI = CoreGui:FindFirstChild("JunejoHubUI")
if ExistingUI then ExistingUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = CoreGui

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
TitleLabel.Text = "STEAL AN ANIME EGG"
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
    ClearESPFolder(ESPStorage.Eggs)
    ClearESPFolder(ESPStorage.Players)
    ClearESPFolder(ESPStorage.Bases)
    ClearESPFolder(ESPStorage.Boss)
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

-- Add All Features to the Compact Scrolling List
AddToggleRow("Auto Steal Eggs", "AutoSteal")
AddToggleRow("Instant Steal (0s Prompt)", "InstantPrompt")
AddToggleRow("Auto Deposit Eggs", "AutoDeposit")
AddToggleRow("Auto Collect Cash", "AutoCollectCash")
AddToggleRow("Auto Hatch Eggs", "AutoHatch")
AddToggleRow("Auto Rebirth", "AutoRebirth")
AddToggleRow("Auto Attack Boss", "AutoAttackBoss")
AddToggleRow("Anime Egg ESP", "EggESP")
AddToggleRow("Player ESP", "PlayerESP")
AddToggleRow("Player Base ESP", "BaseESP")
AddToggleRow("Boss ESP", "BossESP")
AddToggleRow("Anti-Egg Drop (No Ragdoll)", "AntiRagdoll")
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
