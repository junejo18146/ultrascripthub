-- =================================================================
-- ULTRA SCRIPT HUB - OFFICIAL UI STANDARD (UI 1 - CLASSIC MATTE DARK)
-- GAME: Blox Fruits
-- AUTHOR: Made by Junejo
-- REPO: junejo18146/ultrascripthub
-- =================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Feature States
_G.AutoFarmLevel = false
_G.InfJumpActive = false
_G.ChestESPActive = false
_G.FruitESPActive = false
_G.WalkSpeedActive = false
_G.WalkSpeedValue = 50

-- Cleanup Old UI Instances
pcall(function()
    for _, name in ipairs({"UltraScriptHub_BloxFruits", "BloxFruitsUI_Badshah", "JunejoHubUI_BloxFruits"}) do
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end
end)

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

-- =================================================================
-- UI 1 MASTER FRAME (280x260px Standard)
-- =================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 260)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Draggable Logic (PC Mouse & Mobile Touch)
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

-- Header Container
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local GameTitle = Instance.new("TextLabel")
GameTitle.Name = "GameTitle"
GameTitle.Text = "BLOX FRUITS"
GameTitle.Font = Enum.Font.GothamBold
GameTitle.TextSize = 13
GameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
GameTitle.TextXAlignment = Enum.TextXAlignment.Left
GameTitle.Position = UDim2.new(0, 14, 0, 11)
GameTitle.Size = UDim2.new(1, -50, 0, 16)
GameTitle.BackgroundTransparency = 1
GameTitle.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 165)
CloseBtn.Position = UDim2.new(1, -30, 0, 11)
CloseBtn.Size = UDim2.new(0, 16, 0, 16)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    _G.AutoFarmLevel = false
    _G.InfJumpActive = false
    _G.ChestESPActive = false
    _G.FruitESPActive = false
    _G.WalkSpeedActive = false
    ScreenGui:Destroy()
end)

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
Content.Size = UDim2.new(1, -28, 0, 165)
Content.Position = UDim2.new(0, 14, 0, 46)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.Parent = Content

-- =================================================================
-- UI COMPONENTS
-- =================================================================

-- Standard Feature Toggle Row
local function createToggleRow(name, text, defaultState, layoutOrder, onToggle)
    local state = defaultState or false

    local row = Instance.new("Frame")
    row.Name = name
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder
    row.Parent = Content

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(240, 240, 245)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Size = UDim2.new(1, -30, 1, 0)
    label.BackgroundTransparency = 1
    label.Parent = row

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(1, -20, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    box.BorderSizePixel = 0
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

    local check = Instance.new("Frame")
    check.Size = UDim2.new(0, 12, 0, 12)
    check.Position = UDim2.new(0.5, -6, 0.5, -6)
    check.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    check.BorderSizePixel = 0
    check.Visible = state
    check.Parent = box

    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 3)
    checkCorner.Parent = check

    local function updateState()
        state = not state
        check.Visible = state
        if onToggle then
            task.spawn(onToggle, state)
        end
    end

    box.MouseButton1Click:Connect(updateState)

    local rowBtn = Instance.new("TextButton")
    rowBtn.Size = UDim2.new(1, -25, 1, 0)
    rowBtn.BackgroundTransparency = 1
    rowBtn.Text = ""
    rowBtn.Parent = row
    rowBtn.MouseButton1Click:Connect(updateState)

    return row
end

-- WalkSpeed Row with Checkbox AND Stepper Pill
local function createWalkSpeedRow(layoutOrder)
    local state = _G.WalkSpeedActive or false
    local current = _G.WalkSpeedValue or 50

    local row = Instance.new("Frame")
    row.Name = "WalkSpeedRow"
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder
    row.Parent = Content

    local label = Instance.new("TextLabel")
    label.Text = "WalkSpeed"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(240, 240, 245)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Size = UDim2.new(0, 85, 1, 0)
    label.BackgroundTransparency = 1
    label.Parent = row

    -- WalkSpeed Toggle Checkbox
    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(0, 100, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    box.BorderSizePixel = 0
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

    local check = Instance.new("Frame")
    check.Size = UDim2.new(0, 12, 0, 12)
    check.Position = UDim2.new(0.5, -6, 0.5, -6)
    check.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    check.BorderSizePixel = 0
    check.Visible = state
    check.Parent = box

    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 3)
    checkCorner.Parent = check

    box.MouseButton1Click:Connect(function()
        state = not state
        check.Visible = state
        _G.WalkSpeedActive = state
        if not state then
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
                end
            end)
        end
    end)

    -- Stepper Pill Frame
    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 105, 0, 22)
    pill.Position = UDim2.new(1, -105, 0.5, -11)
    pill.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    pill.BorderSizePixel = 0
    pill.Parent = row

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(0, 6)
    pillCorner.Parent = pill

    local pillStroke = Instance.new("UIStroke")
    pillStroke.Color = Color3.fromRGB(45, 45, 55)
    pillStroke.Thickness = 1
    pillStroke.Parent = pill

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 28, 1, 0)
    minus.Position = UDim2.new(0, 0, 0, 0)
    minus.BackgroundTransparency = 1
    minus.Text = "-"
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 14
    minus.TextColor3 = Color3.fromRGB(200, 200, 210)
    minus.Parent = pill

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(1, -56, 1, 0)
    valLabel.Position = UDim2.new(0, 28, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(current)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 12
    valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valLabel.Parent = pill

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 28, 1, 0)
    plus.Position = UDim2.new(1, -28, 0, 0)
    plus.BackgroundTransparency = 1
    plus.Text = "+"
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 14
    plus.TextColor3 = Color3.fromRGB(200, 200, 210)
    plus.Parent = pill

    minus.MouseButton1Click:Connect(function()
        current = math.max(16, current - 5)
        _G.WalkSpeedValue = current
        valLabel.Text = tostring(current)
    end)

    plus.MouseButton1Click:Connect(function()
        current = math.min(250, current + 5)
        _G.WalkSpeedValue = current
        valLabel.Text = tostring(current)
    end)
end

-- =================================================================
-- REGISTER ROWS
-- =================================================================

-- 1. Auto Farm Level
createToggleRow("AutoFarmRow", "Auto Farm Level", _G.AutoFarmLevel, 1, function(state)
    _G.AutoFarmLevel = state
end)

-- 2. Chest ESP
createToggleRow("ChestESPRow", "Chest ESP", _G.ChestESPActive, 2, function(state)
    _G.ChestESPActive = state
end)

-- 3. Fruit ESP
createToggleRow("FruitESPRow", "Fruit ESP", _G.FruitESPActive, 3, function(state)
    _G.FruitESPActive = state
end)

-- 4. WalkSpeed (With Middle Checkbox & Right Stepper Pill)
createWalkSpeedRow(4)

-- 5. Infinite Jump
createToggleRow("InfJumpRow", "Infinite Jump", _G.InfJumpActive, 5, function(state)
    _G.InfJumpActive = state
end)

-- =================================================================
-- MANDATORY FOOTER
-- =================================================================
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 32)
Footer.Position = UDim2.new(0, 0, 1, -34)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local HubTitle = Instance.new("TextLabel")
HubTitle.Name = "HubTitle"
HubTitle.Text = "ULTRA SCRIPT HUB"
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextSize = 11
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextXAlignment = Enum.TextXAlignment.Center
HubTitle.Position = UDim2.new(0, 0, 0, 0)
HubTitle.Size = UDim2.new(1, 0, 0, 14)
HubTitle.BackgroundTransparency = 1
HubTitle.Parent = Footer

local CreatorTitle = Instance.new("TextLabel")
CreatorTitle.Name = "CreatorTitle"
CreatorTitle.Text = "Made by Junejo"
CreatorTitle.Font = Enum.Font.GothamMedium
CreatorTitle.TextSize = 10
CreatorTitle.TextColor3 = Color3.fromRGB(136, 136, 153)
CreatorTitle.TextXAlignment = Enum.TextXAlignment.Center
CreatorTitle.Position = UDim2.new(0, 0, 0, 14)
CreatorTitle.Size = UDim2.new(1, 0, 0, 14)
CreatorTitle.BackgroundTransparency = 1
CreatorTitle.Parent = Footer

-- =================================================================
-- CORE HELPERS & BLOX FRUITS NET/REMOTE ENGINE
-- =================================================================

local function getCommF()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes and remotes:FindFirstChild("CommF_") then
        return remotes.CommF_
    end
    if ReplicatedStorage:FindFirstChild("CommF_") then
        return ReplicatedStorage.CommF_
    end
    if remotes and remotes:FindFirstChild("CommE") then
        return remotes.CommE
    end
    return nil
end

-- Fast Tool Equipper (Sword / Melee / Fruit / Combat)
local function equipBestWeapon()
    pcall(function()
        local character = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not character or not backpack then return end
        
        local currentTool = character:FindFirstChildOfClass("Tool")
        if not currentTool then
            -- Prefer Melee or Sword, otherwise any tool
            local targetTool = nil
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local tType = tool:FindFirstChild("ToolTip") and tool.ToolTip.Value or ""
                    if tType == "Melee" or tType == "Sword" or tType == "Blox Fruit" then
                        targetTool = tool
                        break
                    elseif not targetTool then
                        targetTool = tool
                    end
                end
            end
            if targetTool and character:FindFirstChildOfClass("Humanoid") then
                character:FindFirstChildOfClass("Humanoid"):EquipTool(targetTool)
            end
        end
    end)
end

-- Auto Enable Buso Haki
local function checkAndEnableBuso()
    pcall(function()
        local character = LocalPlayer.Character
        if character and not character:FindFirstChild("HasBuso") then
            local commF = getCommF()
            if commF then
                commF:InvokeServer("Buso")
            end
        end
    end)
end

-- BodyVelocity Hover & Flight Anchor
local function setSafePosition(targetCFrame)
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local bv = rootPart:FindFirstChild("BF_AnchorVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "BF_AnchorVelocity"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.zero
            bv.Parent = rootPart
        end
        
        rootPart.CFrame = targetCFrame
    end)
end

local function removeSafePosition()
    pcall(function()
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart and rootPart:FindFirstChild("BF_AnchorVelocity") then
            rootPart.BF_AnchorVelocity:Destroy()
        end
    end)
end

-- Bypass Character Physics Collision (Noclip)
RunService.Stepped:Connect(function()
    if _G.AutoFarmLevel then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- WalkSpeed Engine
RunService.RenderStepped:Connect(function(deltaTime)
    pcall(function()
        if _G.WalkSpeedActive and _G.WalkSpeedValue and _G.WalkSpeedValue > 16 then
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")

            if hum and hrp then
                hum.WalkSpeed = _G.WalkSpeedValue
                if hum.MoveDirection.Magnitude > 0 then
                    local boost = (_G.WalkSpeedValue - 16)
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (boost * deltaTime))
                end
            end
        end
    end)
end)

-- Infinite Jump
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

-- =================================================================
-- QUEST & LEVEL DATABASE (SEA 1 COMPLETE PROGRESSION)
-- =================================================================

local QuestList = {
    { Min = 1, Max = 9, Quest = "BanditQuest1", ID = 1, Mob = "Bandit", NPCPos = CFrame.new(1060, 16, 1548) },
    { Min = 10, Max = 14, Quest = "JungleQuest", ID = 1, Mob = "Monkey", NPCPos = CFrame.new(-1598, 36, 153) },
    { Min = 15, Max = 29, Quest = "JungleQuest", ID = 2, Mob = "Gorilla", NPCPos = CFrame.new(-1598, 36, 153) },
    { Min = 30, Max = 39, Quest = "BuggyQuest1", ID = 1, Mob = "Pirate", NPCPos = CFrame.new(-1141, 4, 3831) },
    { Min = 40, Max = 59, Quest = "BuggyQuest1", ID = 2, Mob = "Brute", NPCPos = CFrame.new(-1141, 4, 3831) },
    { Min = 60, Max = 74, Quest = "DesertQuest", ID = 1, Mob = "Desert Bandit", NPCPos = CFrame.new(894, 6, 4392) },
    { Min = 75, Max = 89, Quest = "DesertQuest", ID = 2, Mob = "Desert Officer", NPCPos = CFrame.new(894, 6, 4392) },
    { Min = 90, Max = 99, Quest = "SnowQuest", ID = 1, Mob = "Snow Bandit", NPCPos = CFrame.new(1385, 87, -1298) },
    { Min = 100, Max = 119, Quest = "SnowQuest", ID = 2, Mob = "Snowman", NPCPos = CFrame.new(1385, 87, -1298) },
    { Min = 120, Max = 149, Quest = "MarineQuest2", ID = 1, Mob = "Chief Petty Officer", NPCPos = CFrame.new(-5039, 28, 4324) },
    { Min = 150, Max = 174, Quest = "SkyQuest", ID = 1, Mob = "Sky Bandit", NPCPos = CFrame.new(-4839, 717, -2619) },
    { Min = 175, Max = 189, Quest = "SkyQuest", ID = 2, Mob = "Dark Master", NPCPos = CFrame.new(-4839, 717, -2619) },
    { Min = 190, Max = 209, Quest = "PrisonerQuest", ID = 1, Mob = "Prisoner", NPCPos = CFrame.new(4854, 5, 744) },
    { Min = 210, Max = 249, Quest = "PrisonerQuest", ID = 2, Mob = "Dangerous Prisoner", NPCPos = CFrame.new(4854, 5, 744) },
    { Min = 250, Max = 274, Quest = "ColosseumQuest", ID = 1, Mob = "Toga Warrior", NPCPos = CFrame.new(-1427, 7, -2792) },
    { Min = 275, Max = 299, Quest = "ColosseumQuest", ID = 2, Mob = "Gladiator", NPCPos = CFrame.new(-1427, 7, -2792) },
    { Min = 300, Max = 324, Quest = "MagmaQuest", ID = 1, Mob = "Military Soldier", NPCPos = CFrame.new(-5247, 8, 8504) },
    { Min = 325, Max = 374, Quest = "MagmaQuest", ID = 2, Mob = "Military Spy", NPCPos = CFrame.new(-5247, 8, 8504) },
    { Min = 375, Max = 399, Quest = "FishmanQuest", ID = 1, Mob = "Fishman Warrior", NPCPos = CFrame.new(61163, 18, 1569) },
    { Min = 400, Max = 449, Quest = "FishmanQuest", ID = 2, Mob = "Fishman Commando", NPCPos = CFrame.new(61163, 18, 1569) },
    { Min = 450, Max = 474, Quest = "SkyQuest", ID = 1, Mob = "God's Guard", NPCPos = CFrame.new(-7894, 5545, -380) },
    { Min = 475, Max = 524, Quest = "SkyQuest", ID = 2, Mob = "Shanda", NPCPos = CFrame.new(-7894, 5545, -380) },
    { Min = 525, Max = 624, Quest = "SkyQuest", ID = 1, Mob = "Royal Squad", NPCPos = CFrame.new(-7894, 5545, -380) },
    { Min = 625, Max = 649, Quest = "FountainQuest", ID = 1, Mob = "Galley Pirate", NPCPos = CFrame.new(5259, 38, 4050) },
    { Min = 650, Max = 700, Quest = "FountainQuest", ID = 2, Mob = "Galley Captain", NPCPos = CFrame.new(5259, 38, 4050) },
}

local function getPlayerLevel()
    local level = 1
    pcall(function()
        if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") then
            level = tonumber(LocalPlayer.Data.Level.Value) or 1
        elseif LocalPlayer:FindFirstChild("PlayerGui") then
            local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
            if mainGui and mainGui:FindFirstChild("Level") then
                local txt = mainGui.Level.Text
                local num = tonumber(string.match(txt, "%d+"))
                if num then level = num end
            end
        end
    end)
    return level
end

local function hasActiveQuest()
    local hasQuest = false
    pcall(function()
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main") then
            local questFrame = LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
            if questFrame and questFrame.Visible then
                hasQuest = true
            end
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

-- =================================================================
-- AUTO FARM LEVEL ENGINE (MULTI-ATTACK + SMART TARGETING)
-- =================================================================

-- Attack Action Trigger (Virtual User + Tool Click + Modules Net)
local function performAttack()
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
        
        -- Virtual Input Manager & VirtualUser
        if VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        else
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(500, 500), workspace.CurrentCamera.CFrame)
            VirtualUser:Button1Up(Vector2.new(500, 500), workspace.CurrentCamera.CFrame)
        end
        
        -- Module RegisterAttack bypass
        pcall(function()
            local modules = ReplicatedStorage:FindFirstChild("Modules")
            local net = modules and modules:FindFirstChild("Net")
            if net and net:FindFirstChild("RegisterAttack") then
                net.RegisterAttack:FireServer(0)
            end
        end)
    end)
end

-- Main Auto Farm Level Thread
task.spawn(function()
    while true do
        task.wait(0.08)
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
                local commF = getCommF()

                -- 1. Check and Start Quest
                if not hasActiveQuest() then
                    if questInfo and commF then
                        -- Teleport close to NPC if far to ensure server accepts
                        local hrp = character.HumanoidRootPart
                        if questInfo.NPCPos and (hrp.Position - questInfo.NPCPos.Position).Magnitude > 150 then
                            setSafePosition(questInfo.NPCPos * CFrame.new(0, 5, 0))
                            task.wait(0.4)
                        end
                        commF:InvokeServer("StartQuest", questInfo.Quest, questInfo.ID)
                        task.wait(0.3)
                    end
                end

                -- 2. Equip Weapon & Enable Haki
                equipBestWeapon()
                checkAndEnableBuso()

                -- 3. Search for Target Mob
                local targetMob = nil
                local targetHRP = nil
                local minDistance = math.huge
                local playerPos = character.HumanoidRootPart.Position

                -- Search in workspace.Enemies
                local enemiesFolder = workspace:FindFirstChild("Enemies")
                if enemiesFolder then
                    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                            if enemy.Humanoid.Health > 0 then
                                local enemyName = string.lower(enemy.Name)
                                local targetName = string.lower(questInfo.Mob)
                                if string.find(enemyName, targetName) then
                                    local dist = (playerPos - enemy.HumanoidRootPart.Position).Magnitude
                                    if dist < minDistance then
                                        minDistance = dist
                                        targetMob = enemy
                                        targetHRP = enemy.HumanoidRootPart
                                    end
                                elseif not targetMob and string.find(enemyName, "bandit") or string.find(enemyName, "pirate") or string.find(enemyName, "monkey") then
                                    targetMob = enemy
                                    targetHRP = enemy.HumanoidRootPart
                                end
                            end
                        end
                    end
                end

                -- Fallback Search in entire workspace
                if not targetMob then
                    for _, enemy in ipairs(workspace:GetChildren()) do
                        if enemy:IsA("Model") and enemy ~= character and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                            if enemy.Humanoid.Health > 0 then
                                local enemyName = string.lower(enemy.Name)
                                local targetName = string.lower(questInfo.Mob)
                                if string.find(enemyName, targetName) then
                                    targetMob = enemy
                                    targetHRP = enemy.HumanoidRootPart
                                    break
                                end
                            end
                        end
                    end
                end

                -- 4. Attack or Move to Spawn Area
                if targetMob and targetHRP then
                    -- Disable enemy collision
                    pcall(function()
                        for _, part in ipairs(targetMob:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end)

                    -- Position above enemy (Farm Spot)
                    local attackCFrame = targetHRP.CFrame * CFrame.new(0, 7.5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    setSafePosition(attackCFrame)

                    -- Trigger combat combo
                    performAttack()
                else
                    -- No mob spawned yet -> Teleport near Quest NPC / Enemy Spawn Zone
                    if questInfo and questInfo.NPCPos then
                        setSafePosition(questInfo.NPCPos * CFrame.new(0, 15, 0))
                    else
                        removeSafePosition()
                    end
                end
            end)
        else
            removeSafePosition()
        end
    end
end)

-- =================================================================
-- FRUIT ESP ENGINE (DEEP SCANNER + DYNAMIC HIGHLIGHT + BILLBOARD)
-- =================================================================

local fruitESPFolder = Instance.new("Folder")
fruitESPFolder.Name = "FruitESP_Holder"
fruitESPFolder.Parent = ScreenGui

local knownFruits = {
    "fruit", "bomb", "blade", "chop", "spring", "rocket", "smoke", "spin",
    "flame", "falcon", "ice", "sand", "dark", "diamond", "light", "rubber",
    "barrier", "ghost", "magma", "quake", "buddha", "love", "spider", "sound",
    "phoenix", "portal", "rumble", "pain", "blizzard", "gravity", "mammoth",
    "t-rex", "dough", "shadow", "venom", "control", "gas", "spirit", "dragon",
    "leopard", "kitsune", "yeti"
}

local function isFruitObject(obj)
    if not obj then return false end
    local name = string.lower(obj.Name)
    
    if string.find(name, "fruit") then
        return true
    end
    
    for _, fName in ipairs(knownFruits) do
        if string.find(name, fName) and (obj:IsA("Tool") or obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")) then
            return true
        end
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(1.2)
        pcall(function()
            fruitESPFolder:ClearAllChildren()
            
            if _G.FruitESPActive then
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                local foundFruits = {}

                -- Scan Workspace Children & Descendants
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if (obj:IsA("Tool") or obj:IsA("Model")) and isFruitObject(obj) then
                        -- Make sure it's not held by a player
                        local isPlayerTool = false
                        local parent = obj.Parent
                        while parent and parent ~= workspace do
                            if Players:GetPlayerFromCharacter(parent) then
                                isPlayerTool = true
                                break
                            end
                            parent = parent.Parent
                        end

                        if not isPlayerTool and not foundFruits[obj] then
                            foundFruits[obj] = true
                            local targetPart = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if targetPart then
                                local dist = rootPart and math.floor((rootPart.Position - targetPart.Position).Magnitude) or 0

                                -- Billboard Tag
                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "FruitESP_Bill"
                                billboard.AlwaysOnTop = true
                                billboard.Size = UDim2.new(0, 160, 0, 32)
                                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                                billboard.Adornee = targetPart
                                billboard.Parent = fruitESPFolder

                                local label = Instance.new("TextLabel")
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1
                                label.Text = "🍎 " .. obj.Name .. " [" .. tostring(dist) .. "m]"
                                label.TextColor3 = Color3.fromRGB(255, 80, 240)
                                label.Font = Enum.Font.GothamBold
                                label.TextSize = 12
                                label.TextStrokeTransparency = 0.2
                                label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                label.Parent = billboard

                                -- Highlight Glow
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "FruitESP_Glow"
                                highlight.FillColor = Color3.fromRGB(255, 50, 220)
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                highlight.FillTransparency = 0.4
                                highlight.OutlineTransparency = 0
                                highlight.Adornee = obj
                                highlight.Parent = fruitESPFolder
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- =================================================================
-- CHEST ESP ENGINE (BILLBOARD + GOLD HIGHLIGHT)
-- =================================================================

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
                                billboard.Name = "ChestESP_Bill"
                                billboard.AlwaysOnTop = true
                                billboard.Size = UDim2.new(0, 110, 0, 28)
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

                                local highlight = Instance.new("Highlight")
                                highlight.Name = "ChestESP_Glow"
                                highlight.FillColor = Color3.fromRGB(255, 215, 0)
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                highlight.FillTransparency = 0.5
                                highlight.Adornee = obj
                                highlight.Parent = chestESPFolder
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- =================================================================
-- 24/7 ANTI-AFK DISCONNECT PROTECTION
-- =================================================================
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

print("[ULTRA SCRIPT HUB] Blox Fruits Script Loaded Successfully!")
