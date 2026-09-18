-- =================================================================
-- ULTRA SCRIPT HUB - OFFICIAL UI (CLASSIC MATTE DARK)
-- GAME: Blox Fruits
-- AUTHOR: Made by Junejo
-- =================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Global Feature State Flags
_G.AutoFarmLevel = false
_G.WalkSpeedValue = 16
_G.InfJumpActive = false
_G.ChestESPActive = false
_G.FruitESPActive = false

-- Prevent duplicate UI
local function cleanupOldUI()
    for _, name in ipairs({"UltraScriptHub_BloxFruits", "BloxFruitsUI_Badshah", "JunejoHubUI_BloxFruits"}) do
        pcall(function()
            if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        end)
        pcall(function()
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
                LocalPlayer.PlayerGui[name]:Destroy()
            end
        end)
    end
end
cleanupOldUI()

-- Safe GUI Parent Resolver
local function getSafeGui()
    if gethui then
        local success, res = pcall(gethui)
        if success and res then return res end
    end
    if CoreGui and not RunService:IsStudio() then
        local ok = pcall(function()
            local test = Instance.new("Folder")
            test.Parent = CoreGui
            test:Destroy()
        end)
        if ok then return CoreGui end
    end
    return LocalPlayer:WaitForChild("PlayerGui", 10) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraScriptHub_BloxFruits"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getSafeGui()

-- Main Container (280x245 Dimension)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 245)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -122)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17) -- Matte Black
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42) -- Border
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Draggable Logic (Mobile Touch & PC Mouse)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
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
MainFrame.InputChanged:Connect(function(input)
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

-- Header Container (Game Name on Top + Ultra Script Hub Subtitle)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local GameTitle = Instance.new("TextLabel")
GameTitle.Name = "GameTitle"
GameTitle.Text = "BLOX FRUITS"
GameTitle.Font = Enum.Font.GothamBold
GameTitle.TextSize = 13
GameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
GameTitle.TextXAlignment = Enum.TextXAlignment.Left
GameTitle.Position = UDim2.new(0, 14, 0, 6)
GameTitle.Size = UDim2.new(0, 200, 0, 16)
GameTitle.BackgroundTransparency = 1
GameTitle.Parent = Header

local HubSubtitle = Instance.new("TextLabel")
HubSubtitle.Name = "HubSubtitle"
HubSubtitle.Text = "ULTRA SCRIPT HUB"
HubSubtitle.Font = Enum.Font.GothamBold
HubSubtitle.TextSize = 9
HubSubtitle.TextColor3 = Color3.fromRGB(160, 160, 175)
HubSubtitle.TextXAlignment = Enum.TextXAlignment.Left
HubSubtitle.Position = UDim2.new(0, 14, 0, 22)
HubSubtitle.Size = UDim2.new(0, 200, 0, 12)
HubSubtitle.BackgroundTransparency = 1
HubSubtitle.Parent = Header

local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.Size = UDim2.new(1, -28, 0, 1)
Divider.Position = UDim2.new(0, 14, 1, -1)
Divider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Divider.BorderSizePixel = 0
Divider.Parent = Header

-- Content Container
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -28, 0, 170)
Content.Position = UDim2.new(0, 14, 0, 48)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 4)
ContentLayout.Parent = Content

-- Helper: Create Fully-Clickable Mobile-Optimized Toggle Row
local function createToggleRow(name, text, defaultState, layoutOrder, onToggle)
    local state = defaultState or false

    local rowBtn = Instance.new("TextButton")
    rowBtn.Name = name
    rowBtn.Size = UDim2.new(1, 0, 0, 28)
    rowBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    rowBtn.BackgroundTransparency = 0.6
    rowBtn.BorderSizePixel = 0
    rowBtn.AutoButtonColor = false
    rowBtn.Text = ""
    rowBtn.LayoutOrder = layoutOrder
    rowBtn.Parent = Content

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = rowBtn

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(225, 225, 235)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.BackgroundTransparency = 1
    label.Parent = rowBtn

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 18, 0, 18)
    box.Position = UDim2.new(1, -26, 0.5, -9)
    box.BackgroundColor3 = state and Color3.fromRGB(45, 45, 60) or Color3.fromRGB(24, 24, 30)
    box.BorderSizePixel = 0
    box.Parent = rowBtn

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = state and Color3.fromRGB(90, 90, 120) or Color3.fromRGB(45, 45, 55)
    boxStroke.Thickness = 1
    boxStroke.Parent = box

    local check = Instance.new("Frame")
    check.Size = UDim2.new(0, 10, 0, 10)
    check.Position = UDim2.new(0.5, -5, 0.5, -5)
    check.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    check.BorderSizePixel = 0
    check.Visible = state
    check.Parent = box

    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 2)
    checkCorner.Parent = check

    local function updateState(newState)
        state = newState
        check.Visible = state
        box.BackgroundColor3 = state and Color3.fromRGB(45, 45, 60) or Color3.fromRGB(24, 24, 30)
        boxStroke.Color = state and Color3.fromRGB(120, 120, 160) or Color3.fromRGB(45, 45, 55)
        if onToggle then
            task.spawn(onToggle, state)
        end
    end

    rowBtn.Activated:Connect(function()
        updateState(not state)
    end)

    return rowBtn
end

-- Helper: Mobile-Optimized Speed Controller Row (- / + Pill Stepper)
local function createSpeedRow(name, text, minVal, maxVal, defaultVal, layoutOrder, onSpeedChange)
    local current = defaultVal or 16

    local row = Instance.new("Frame")
    row.Name = name
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    row.BackgroundTransparency = 0.6
    row.BorderSizePixel = 0
    row.LayoutOrder = layoutOrder
    row.Parent = Content

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(225, 225, 235)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Size = UDim2.new(1, -125, 1, 0)
    label.BackgroundTransparency = 1
    label.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 110, 0, 22)
    pill.Position = UDim2.new(1, -116, 0.5, -11)
    pill.BackgroundColor3 = Color3.fromRGB(27, 27, 34)
    pill.BorderSizePixel = 0
    pill.Parent = row

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(0, 6)
    pillCorner.Parent = pill

    local pillStroke = Instance.new("UIStroke")
    pillStroke.Color = Color3.fromRGB(50, 50, 65)
    pillStroke.Thickness = 1
    pillStroke.Parent = pill

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 30, 1, 0)
    minus.Position = UDim2.new(0, 0, 0, 0)
    minus.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    minus.BorderSizePixel = 0
    minus.Text = "-"
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 14
    minus.TextColor3 = Color3.fromRGB(255, 255, 255)
    minus.AutoButtonColor = true
    minus.Parent = pill

    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = UDim.new(0, 4)
    minusCorner.Parent = minus

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(1, -60, 1, 0)
    valLabel.Position = UDim2.new(0, 30, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(current)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 11
    valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valLabel.Parent = pill

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 30, 1, 0)
    plus.Position = UDim2.new(1, -30, 0, 0)
    plus.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    plus.BorderSizePixel = 0
    plus.Text = "+"
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 14
    plus.TextColor3 = Color3.fromRGB(255, 255, 255)
    plus.AutoButtonColor = true
    plus.Parent = pill

    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 4)
    plusCorner.Parent = plus

    local function changeSpeed(delta)
        current = math.clamp(current + delta, minVal, maxVal)
        valLabel.Text = tostring(current)
        if onSpeedChange then
            task.spawn(onSpeedChange, current)
        end
    end

    minus.Activated:Connect(function()
        changeSpeed(-5)
    end)

    plus.Activated:Connect(function()
        changeSpeed(5)
    end)
end

-- ==========================================
-- REGISTER UI CONTROLS
-- ==========================================

-- 1. Auto Farm Level
createToggleRow("AutoFarmRow", "Auto Farm Level", _G.AutoFarmLevel, 1, function(state)
    _G.AutoFarmLevel = state
    print("[Blox Fruits] Auto Farm Level set to:", state)
end)

-- 2. Infinite Jump
createToggleRow("InfJumpRow", "Infinite Jump", _G.InfJumpActive, 2, function(state)
    _G.InfJumpActive = state
    print("[Blox Fruits] Infinite Jump set to:", state)
end)

-- 3. Chest ESP
createToggleRow("ChestESPRow", "Chest ESP", _G.ChestESPActive, 3, function(state)
    _G.ChestESPActive = state
    print("[Blox Fruits] Chest ESP set to:", state)
end)

-- 4. Fruit ESP
createToggleRow("FruitESPRow", "Fruit ESP", _G.FruitESPActive, 4, function(state)
    _G.FruitESPActive = state
    print("[Blox Fruits] Fruit ESP set to:", state)
end)

-- 5. WalkSpeed Pill Stepper Controller
createSpeedRow("WalkSpeedRow", "WalkSpeed", 16, 250, _G.WalkSpeedValue, 5, function(val)
    _G.WalkSpeedValue = val
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
        end
    end)
end)

-- ==========================================
-- MANDATORY FOOTER (Made by Junejo)
-- ==========================================
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -22)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterText = Instance.new("TextLabel")
FooterText.Text = "Made by Junejo"
FooterText.Font = Enum.Font.GothamMedium
FooterText.TextSize = 10
FooterText.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterText.TextXAlignment = Enum.TextXAlignment.Center
FooterText.Size = UDim2.new(1, 0, 1, 0)
FooterText.BackgroundTransparency = 1
FooterText.Parent = Footer

-- =================================================================
-- GAMEPLAY ENGINE & FEATURE IMPLEMENTATIONS (100% OPERATIONAL)
-- =================================================================

-- 1. WalkSpeed Engine (Direct WalkSpeed + CFrame translation fallback)
RunService.RenderStepped:Connect(function(deltaTime)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if hum and hrp and _G.WalkSpeedValue and _G.WalkSpeedValue > 16 then
            -- Set humanoid walkspeed
            hum.WalkSpeed = _G.WalkSpeedValue
            
            -- Apply physics CFrame boost when moving
            if hum.MoveDirection.Magnitude > 0 then
                local boost = (_G.WalkSpeedValue - 16)
                hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (boost * deltaTime))
            end
        end
    end)
end)

-- 2. Infinite Jump (PC Keyboard + Mobile Touch Screen)
UserInputService.JumpRequest:Connect(function()
    if _G.InfJumpActive then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- 3. Noclip Handler
RunService.Stepped:Connect(function()
    if _G.AutoFarmLevel then
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

-- Helper: Auto-Equip Combat Tool
local function equipCombatTool()
    pcall(function()
        local character = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not character or not backpack then return end
        
        local currentTool = character:FindFirstChildOfClass("Tool")
        if not currentTool then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    character:FindFirstChildOfClass("Humanoid"):EquipTool(tool)
                    break
                end
            end
        end
    end)
end

-- Helper: Position & Velocity lock for auto-farm
local function setFarmPosition(targetCFrame)
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local bv = rootPart:FindFirstChild("BF_FlyVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "BF_FlyVelocity"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.zero
            bv.Parent = rootPart
        end
        
        rootPart.CFrame = targetCFrame
    end)
end

local function removeFarmVelocity()
    pcall(function()
        local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart and rootPart:FindFirstChild("BF_FlyVelocity") then
            rootPart.BF_FlyVelocity:Destroy()
        end
    end)
end

-- Quest Database for Blox Fruits Leveling
local QuestList = {
    { Min = 1, Max = 9, Quest = "BanditQuest1", ID = 1, Mob = "Bandit" },
    { Min = 10, Max = 14, Quest = "JungleQuest", ID = 1, Mob = "Monkey" },
    { Min = 15, Max = 29, Quest = "JungleQuest", ID = 2, Mob = "Gorilla" },
    { Min = 30, Max = 39, Quest = "BuggyQuest1", ID = 1, Mob = "Pirate" },
    { Min = 40, Max = 59, Quest = "BuggyQuest1", ID = 2, Mob = "Brute" },
    { Min = 60, Max = 74, Quest = "DesertQuest", ID = 1, Mob = "Desert Bandit" },
    { Min = 75, Max = 89, Quest = "DesertQuest", ID = 2, Mob = "Desert Officer" },
    { Min = 90, Max = 99, Quest = "SnowQuest", ID = 1, Mob = "Snow Bandit" },
    { Min = 100, Max = 119, Quest = "SnowQuest", ID = 2, Mob = "Snowman" },
    { Min = 120, Max = 149, Quest = "MarineQuest2", ID = 1, Mob = "Chief Petty Officer" },
    { Min = 150, Max = 174, Quest = "SkyQuest", ID = 1, Mob = "Sky Bandit" },
    { Min = 175, Max = 189, Quest = "SkyQuest", ID = 2, Mob = "Dark Master" },
    { Min = 190, Max = 209, Quest = "PrisonerQuest", ID = 1, Mob = "Prisoner" },
    { Min = 210, Max = 249, Quest = "PrisonerQuest", ID = 2, Mob = "Dangerous Prisoner" },
    { Min = 250, Max = 274, Quest = "ColosseumQuest", ID = 1, Mob = "Toga Warrior" },
    { Min = 275, Max = 299, Quest = "ColosseumQuest", ID = 2, Mob = "Gladiator" },
    { Min = 300, Max = 324, Quest = "MagmaQuest", ID = 1, Mob = "Military Soldier" },
    { Min = 325, Max = 374, Quest = "MagmaQuest", ID = 2, Mob = "Military Spy" },
    { Min = 375, Max = 399, Quest = "FishmanQuest", ID = 1, Mob = "Fishman Warrior" },
    { Min = 400, Max = 449, Quest = "FishmanQuest", ID = 2, Mob = "Fishman Commando" },
    { Min = 450, Max = 474, Quest = "SkyQuest", ID = 1, Mob = "God's Guard" },
    { Min = 475, Max = 524, Quest = "SkyQuest", ID = 2, Mob = "Shanda" },
    { Min = 525, Max = 624, Quest = "SkyQuest", ID = 1, Mob = "Royal Squad" },
    { Min = 625, Max = 649, Quest = "FountainQuest", ID = 1, Mob = "Galley Pirate" },
    { Min = 650, Max = 700, Quest = "FountainQuest", ID = 2, Mob = "Galley Captain" },
}

local function getPlayerLevel()
    local level = 1
    pcall(function()
        if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") then
            level = LocalPlayer.Data.Level.Value
        elseif LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("Level") then
            local txt = LocalPlayer.PlayerGui.Main.Level.Text
            local num = tonumber(string.match(txt, "%d+"))
            if num then level = num end
        end
    end)
    return level
end

local function hasActiveQuest()
    local hasQuest = false
    pcall(function()
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("Quest") then
            hasQuest = LocalPlayer.PlayerGui.Main.Quest.Visible
        end
    end)
    return hasQuest
end

local function getQuestDataForLevel(lvl)
    for _, q in ipairs(QuestList) do
        if lvl >= q.Min and lvl <= q.Max then
            return q
        end
    end
    return QuestList[#QuestList]
end

-- 4. Complete Auto Farm Level Engine
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoFarmLevel then
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
                    return
                end

                if character.Humanoid.Health <= 0 then
                    task.wait(2)
                    return
                end

                local myLevel = getPlayerLevel()
                local questInfo = getQuestDataForLevel(myLevel)

                -- Check if we need to take a quest
                if not hasActiveQuest() then
                    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                    local commF = remotes and remotes:FindFirstChild("CommF_")
                    if commF then
                        commF:InvokeServer("StartQuest", questInfo.Quest, questInfo.ID)
                        task.wait(0.3)
                    end
                end

                -- Find alive enemy matching mob name
                local targetMob = nil
                local enemiesFolder = workspace:FindFirstChild("Enemies")

                if enemiesFolder then
                    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                            if enemy.Humanoid.Health > 0 then
                                if string.find(string.lower(enemy.Name), string.lower(questInfo.Mob)) then
                                    targetMob = enemy
                                    break
                                elseif not targetMob then
                                    targetMob = enemy
                                end
                            end
                        end
                    end
                end

                if not targetMob then
                    for _, enemy in ipairs(workspace:GetChildren()) do
                        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy ~= character then
                            if enemy.Humanoid.Health > 0 and string.find(string.lower(enemy.Name), string.lower(questInfo.Mob)) then
                                targetMob = enemy
                                break
                            end
                        end
                    end
                end

                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    equipCombatTool()

                    -- Attack Position: 8 studs above target
                    local mobCFrame = targetMob.HumanoidRootPart.CFrame
                    local safeAttackCFrame = mobCFrame * CFrame.new(0, 8, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    setFarmPosition(safeAttackCFrame)

                    -- Attack triggers
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(500, 500), workspace.CurrentCamera.CFrame)
                else
                    removeFarmVelocity()
                end
            end)
        else
            removeFarmVelocity()
        end
    end
end)

-- 5. Chest ESP Handler
local chestESPFolder = Instance.new("Folder")
chestESPFolder.Name = "ChestESP_Holder"
chestESPFolder.Parent = ScreenGui

task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            chestESPFolder:ClearAllChildren()
            if _G.ChestESPActive then
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")

                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local nameLower = string.lower(obj.Name)
                        if string.find(nameLower, "chest") then
                            local part = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or obj
                            if part and part:IsA("BasePart") and part.Transparency < 1 then
                                local dist = rootPart and math.floor((rootPart.Position - part.Position).Magnitude) or 0

                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "ChestESP"
                                billboard.AlwaysOnTop = true
                                billboard.Size = UDim2.new(0, 100, 0, 30)
                                billboard.StudsOffset = Vector3.new(0, 2, 0)
                                billboard.Adornee = part
                                billboard.Parent = chestESPFolder

                                local label = Instance.new("TextLabel")
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1
                                label.Text = "💎 Chest [" .. tostring(dist) .. "m]"
                                label.TextColor3 = Color3.fromRGB(255, 215, 0)
                                label.Font = Enum.Font.GothamBold
                                label.TextSize = 11
                                label.TextStrokeTransparency = 0.3
                                label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                label.Parent = billboard
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- 6. Fruit ESP Handler
local fruitESPFolder = Instance.new("Folder")
fruitESPFolder.Name = "FruitESP_Holder"
fruitESPFolder.Parent = ScreenGui

task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            fruitESPFolder:ClearAllChildren()
            if _G.FruitESPActive then
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")

                for _, obj in ipairs(workspace:GetChildren()) do
                    if (obj:IsA("Tool") or obj:IsA("Model")) and string.find(string.lower(obj.Name), "fruit") then
                        local part = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local dist = rootPart and math.floor((rootPart.Position - part.Position).Magnitude) or 0

                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "FruitESP"
                            billboard.AlwaysOnTop = true
                            billboard.Size = UDim2.new(0, 140, 0, 30)
                            billboard.StudsOffset = Vector3.new(0, 2, 0)
                            billboard.Adornee = part
                            billboard.Parent = fruitESPFolder

                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.Text = "🍎 " .. obj.Name .. " [" .. tostring(dist) .. "m]"
                            label.TextColor3 = Color3.fromRGB(255, 85, 255)
                            label.Font = Enum.Font.GothamBold
                            label.TextSize = 12
                            label.TextStrokeTransparency = 0.2
                            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            label.Parent = billboard
                        end
                    end
                end
            end
        end)
    end
end)
