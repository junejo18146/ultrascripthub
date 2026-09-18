-- =================================================================
-- ULTRA SCRIPT HUB - OFFICIAL UI 1 (CLASSIC MATTE DARK)
-- GAME: Steal and Hatch Anime Eggs
-- PLACE ID: 76377501906469
-- AUTHOR: Made by Junejo
-- REPOSITORY: junejo18146/ultrascripthub
-- =================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Feature Global States
_G.AutoStealRareEgg = false
_G.AutoStealNearestEgg = false
_G.AutoHatchEggs = false
_G.AutoTrainSpeed = false
_G.AutoRebirth = false
_G.AutoCollectCash = false
_G.RemoveBosses = false
_G.AntiEggDrop = false
_G.RareEggESP = false
_G.AllEggESP = false
_G.BossESP = false
_G.PlayerESP = false
_G.WalkSpeedActive = false
_G.WalkSpeedValue = 60
_G.FlyActive = false
_G.FlySpeedValue = 70
_G.NoclipActive = false
_G.InfJumpActive = false

-- Base Anchor
_G.SavedBaseCFrame = nil
local isStealingActive = false

-- Cleanup Old UI Instances
pcall(function()
    for _, name in ipairs({"UltraScriptHub_StealAnimeEggs", "JunejoHub_StealAnimeEggs", "StealAndHatchAnimeEggsUI"}) do
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end
end)

-- Safe GUI Resolver
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
ScreenGui.Name = "UltraScriptHub_StealAnimeEggs"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getSafeGui()

-- =================================================================
-- UI 1 MASTER FRAME (280x260px - Standard Matte Dark)
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
GameTitle.Text = "STEAL & HATCH ANIME EGGS"
GameTitle.Font = Enum.Font.GothamBold
GameTitle.TextSize = 12
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
    _G.AutoStealRareEgg = false
    _G.AutoStealNearestEgg = false
    _G.AutoHatchEggs = false
    _G.AutoTrainSpeed = false
    _G.AutoRebirth = false
    _G.AutoCollectCash = false
    _G.RemoveBosses = false
    _G.AntiEggDrop = false
    _G.RareEggESP = false
    _G.AllEggESP = false
    _G.BossESP = false
    _G.PlayerESP = false
    _G.WalkSpeedActive = false
    _G.FlyActive = false
    _G.NoclipActive = false
    _G.InfJumpActive = false
    ScreenGui:Destroy()
end)

local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.Size = UDim2.new(1, -28, 0, 1)
Divider.Position = UDim2.new(0, 14, 1, -1)
Divider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Divider.BorderSizePixel = 0
Divider.Parent = Header

-- Content Scrolling Container
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Scroll"
Scroll.Size = UDim2.new(1, -16, 0, 172)
Scroll.Position = UDim2.new(0, 10, 0, 44)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
Scroll.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.Parent = Scroll

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 12)
end)

-- =================================================================
-- UI COMPONENTS (Official Junejo UI 1 System)
-- =================================================================

-- 1. Standard Toggle Row
local function createToggleRow(name, text, defaultState, layoutOrder, onToggle)
    local state = defaultState or false

    local row = Instance.new("Frame")
    row.Name = name
    row.Size = UDim2.new(1, -8, 0, 26)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder
    row.Parent = Scroll

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
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

-- 2. Action Button Row (1-Click Action)
local function createActionButtonRow(name, text, btnText, layoutOrder, onClick)
    local row = Instance.new("Frame")
    row.Name = name
    row.Size = UDim2.new(1, -8, 0, 26)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder
    row.Parent = Scroll

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(240, 240, 245)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Size = UDim2.new(1, -95, 1, 0)
    label.BackgroundTransparency = 1
    label.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 85, 0, 22)
    btn.Position = UDim2.new(1, -85, 0.5, -11)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    btn.BorderSizePixel = 0
    btn.Text = btnText
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = row

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(45, 45, 55)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        task.spawn(function()
            if onClick then onClick() end
            task.wait(0.15)
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        end)
    end)

    return row
end

-- 3. Stepper Controller Row (WalkSpeed / Fly)
local function createStepperRow(name, titleText, toggleVar, valVar, minVal, maxVal, step, defaultVal, layoutOrder, onChange)
    local state = _G[toggleVar] or false
    local current = _G[valVar] or defaultVal

    local row = Instance.new("Frame")
    row.Name = name
    row.Size = UDim2.new(1, -8, 0, 26)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder
    row.Parent = Scroll

    local label = Instance.new("TextLabel")
    label.Text = titleText
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(240, 240, 245)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Size = UDim2.new(0, 80, 1, 0)
    label.BackgroundTransparency = 1
    label.Parent = row

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(0, 85, 0.5, -10)
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
        _G[toggleVar] = state
        if onChange then onChange(state, current) end
    end)

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
    valLabel.TextSize = 11
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
        current = math.max(minVal, current - step)
        _G[valVar] = current
        valLabel.Text = tostring(current)
        if onChange then onChange(state, current) end
    end)

    plus.MouseButton1Click:Connect(function()
        current = math.min(maxVal, current + step)
        _G[valVar] = current
        valLabel.Text = tostring(current)
        if onChange then onChange(state, current) end
    end)

    return row
end

-- =================================================================
-- CORE ENGINE HELPERS & POSITION CONTROL
-- =================================================================

-- Safe Position Anchor & Velocity Stabilizer
local function setCharacterPosition(targetCFrame)
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local bv = rootPart:FindFirstChild("USH_AnchorVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "USH_AnchorVelocity"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.zero
            bv.Parent = rootPart
        end

        rootPart.Velocity = Vector3.zero
        rootPart.RotVelocity = Vector3.zero
        rootPart.CFrame = targetCFrame
    end)
end

local function removeCharacterAnchor()
    pcall(function()
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart and rootPart:FindFirstChild("USH_AnchorVelocity") then
            rootPart.USH_AnchorVelocity:Destroy()
        end
    end)
end

-- Auto Detect or Return Saved Base CFrame
local function getMyBaseCFrame()
    if _G.SavedBaseCFrame then
        return _G.SavedBaseCFrame
    end

    local basePos = nil
    pcall(function()
        local myName = LocalPlayer.Name
        local myDisplayName = LocalPlayer.DisplayName

        -- 1. Check workspace folders for bases/plots
        for _, containerName in ipairs({"Bases", "Plots", "Houses", "Islands", "SpawnLocations", "Spawns"}) do
            local container = workspace:FindFirstChild(containerName)
            if container then
                for _, base in ipairs(container:GetChildren()) do
                    local bName = string.lower(base.Name)
                    if string.find(bName, string.lower(myName)) or string.find(bName, string.lower(myDisplayName)) or (base:FindFirstChild("Owner") and (tostring(base.Owner.Value) == myName or tostring(base.Owner.Value) == myDisplayName)) then
                        local spawnPad = base:FindFirstChild("Spawn") or base:FindFirstChild("Nest") or base:FindFirstChild("Collector") or base:FindFirstChild("Deposit") or base:FindFirstChildWhichIsA("BasePart")
                        if spawnPad then
                            basePos = spawnPad.CFrame + Vector3.new(0, 3.5, 0)
                            break
                        end
                    end
                end
            end
            if basePos then break end
        end

        -- 2. Check workspace descendants for player assigned spawn or nest
        if not basePos then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj:IsA("SpawnLocation") or string.find(string.lower(obj.Name), "spawn")) and obj:IsA("BasePart") then
                    basePos = obj.CFrame + Vector3.new(0, 3.5, 0)
                    break
                end
            end
        end
    end)

    if not basePos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        basePos = LocalPlayer.Character.HumanoidRootPart.CFrame
        _G.SavedBaseCFrame = basePos
    end
    return basePos
end

-- Robust Supercharged ProximityPrompt & Touch Trigger
local function interactObject(obj)
    if not obj then return end
    pcall(function()
        local char = LocalPlayer.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")

        -- 1. ProximityPrompts (Instant trigger & hold bypass)
        for _, prompt in ipairs(obj:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                prompt.RequiresLineOfSight = false
                prompt.MaxActivationDistance = 999
                prompt.HoldDuration = 0
                fireproximityprompt(prompt, 0)
                task.spawn(function()
                    pcall(function() fireproximityprompt(prompt) end)
                end)
            end
        end

        if obj:IsA("ProximityPrompt") then
            obj.RequiresLineOfSight = false
            obj.MaxActivationDistance = 999
            obj.HoldDuration = 0
            fireproximityprompt(obj, 0)
            task.spawn(function()
                pcall(function() fireproximityprompt(obj) end)
            end)
        end

        -- 2. Touch Interest Emulation
        if rootPart and firetouchinterest then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                firetouchinterest(rootPart, part, 0)
                task.wait(0.01)
                firetouchinterest(rootPart, part, 1)
            end
        end

        -- 3. ClickDetectors
        for _, cd in ipairs(obj:GetDescendants()) do
            if cd:IsA("ClickDetector") and fireclickdetector then
                fireclickdetector(cd)
            end
        end
    end)
end

-- Scan and Return Rarest Egg Object
local function getRarestEgg()
    local rarestEgg = nil
    local maxScore = -1
    local basePos = getMyBaseCFrame()
    local char = LocalPlayer.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")

    pcall(function()
        for _, item in ipairs(workspace:GetDescendants()) do
            if (item:IsA("Model") or item:IsA("BasePart") or item:IsA("Tool")) and item ~= char and item.Parent ~= char then
                local nameLower = string.lower(item.Name)
                if (string.find(nameLower, "egg") or item:FindFirstChild("Egg") or item:FindFirstChildWhichIsA("ProximityPrompt")) and not string.find(nameLower, "spawner") and not string.find(nameLower, "hatch") and not string.find(nameLower, "nest") then
                    local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
                    if part and part.Transparency < 1 then
                        local score = 10
                        if string.find(nameLower, "eternal") then score = score + 100000 end
                        if string.find(nameLower, "divine") then score = score + 50000 end
                        if string.find(nameLower, "secret") then score = score + 25000 end
                        if string.find(nameLower, "mythic") then score = score + 10000 end
                        if string.find(nameLower, "legendary") then score = score + 5000 end
                        if string.find(nameLower, "rare") then score = score + 1000 end

                        if basePos then
                            local distFromBase = (part.Position - basePos.Position).Magnitude
                            score = score + distFromBase
                        end

                        if score > maxScore then
                            maxScore = score
                            rarestEgg = item
                        end
                    end
                end
            end
        end
    end)
    return rarestEgg
end

-- Scan and Return Nearest Egg Object
local function getNearestEgg()
    local nearestEgg = nil
    local minDist = math.huge
    local char = LocalPlayer.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    pcall(function()
        for _, item in ipairs(workspace:GetDescendants()) do
            if (item:IsA("Model") or item:IsA("BasePart") or item:IsA("Tool")) and item ~= char and item.Parent ~= char then
                local nameLower = string.lower(item.Name)
                if (string.find(nameLower, "egg") or item:FindFirstChildWhichIsA("ProximityPrompt")) and not string.find(nameLower, "spawner") and not string.find(nameLower, "hatch") and not string.find(nameLower, "nest") then
                    local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
                    if part and part.Transparency < 1 then
                        local dist = (rootPart.Position - part.Position).Magnitude
                        if dist < minDist and dist > 4 then
                            minDist = dist
                            nearestEgg = item
                        end
                    end
                end
            end
        end
    end)
    return nearestEgg
end

-- Universal Deep Steal & Deposit Pipeline
local function performStealCycle(targetEgg)
    if not targetEgg or isStealingActive then return end
    isStealingActive = true

    pcall(function()
        local char = LocalPlayer.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            isStealingActive = false
            return
        end

        local targetPart = targetEgg:IsA("BasePart") and targetEgg or targetEgg:FindFirstChildWhichIsA("BasePart")
        if not targetPart then
            isStealingActive = false
            return
        end

        local myBase = getMyBaseCFrame()

        -- 1. Teleport to Egg Position (Direct Contact)
        setCharacterPosition(targetPart.CFrame * CFrame.new(0, 1.5, 0))
        
        -- 2. Stay and Grab Lock (Continuous 0.75s interaction so server acknowledges grab)
        local startTime = tick()
        while tick() - startTime < 0.75 do
            setCharacterPosition(targetPart.CFrame * CFrame.new(0, 1.2, 0))
            interactObject(targetEgg)
            
            -- Also scan and trigger any nearby prompt around the egg
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Parent then
                    local pPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                    if pPart and (pPart.Position - targetPart.Position).Magnitude < 15 then
                        prompt.HoldDuration = 0
                        prompt.RequiresLineOfSight = false
                        prompt.MaxActivationDistance = 999
                        fireproximityprompt(prompt, 0)
                    end
                end
            end
            
            -- Fire ReplicatedStorage remotes related to Steal / Grab
            for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                if rem:IsA("RemoteEvent") then
                    local rName = string.lower(rem.Name)
                    if string.find(rName, "steal") or string.find(rName, "grab") or string.find(rName, "take") or string.find(rName, "pick") then
                        pcall(function() rem:FireServer(targetEgg) end)
                    end
                end
            end
            task.wait(0.1)
        end

        -- 3. Teleport to Base Nest
        if myBase then
            setCharacterPosition(myBase)
            
            -- 4. Stay at Base Nest and Deposit (Continuous 0.6s deposit lock)
            local depStart = tick()
            while tick() - depStart < 0.6 do
                setCharacterPosition(myBase)
                
                -- Deposit Prompts & Pads at Base
                for _, obj in ipairs(workspace:GetDescendants()) do
                    local nameLower = string.lower(obj.Name)
                    if string.find(nameLower, "nest") or string.find(nameLower, "deposit") or string.find(nameLower, "plot") or string.find(nameLower, "base") or string.find(nameLower, "hatch") then
                        local p = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                        if p and (p.Position - myBase.Position).Magnitude < 35 then
                            interactObject(obj)
                        end
                    end
                end

                -- Fire Deposit Remotes
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") then
                        local rName = string.lower(rem.Name)
                        if string.find(rName, "deposit") or string.find(rName, "place") or string.find(rName, "store") or string.find(rName, "claim") then
                            pcall(function() rem:FireServer() end)
                        end
                    end
                end
                task.wait(0.1)
            end
        end

        removeCharacterAnchor()
    end)

    isStealingActive = false
end

-- =================================================================
-- REGISTER ALL 19 REQUESTED FEATURE ROWS
-- =================================================================

-- 1. Auto Steal Rare Egg
createToggleRow("AutoStealRareRow", "Auto Steal Rare Egg", _G.AutoStealRareEgg, 1, function(state)
    _G.AutoStealRareEgg = state
end)

-- 2. Auto Steal Nearest Egg
createToggleRow("AutoStealNearRow", "Auto Steal Nearest Egg", _G.AutoStealNearestEgg, 2, function(state)
    _G.AutoStealNearestEgg = state
end)

-- 3. Steal Rare Egg (1-Click)
createActionButtonRow("StealRareBtnRow", "Steal Rare Egg (1-Click)", "⚡ STEAL", 3, function()
    task.spawn(function()
        local rare = getRarestEgg()
        if rare then
            performStealCycle(rare)
        end
    end)
end)

-- 4. Save Base Position
createActionButtonRow("SaveBaseRow", "Save Base Position", "💾 SAVE", 4, function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        _G.SavedBaseCFrame = char.HumanoidRootPart.CFrame
    end
end)

-- 5. Teleport to Base
createActionButtonRow("TpBaseRow", "Teleport to Base", "🏠 TP BASE", 5, function()
    local base = getMyBaseCFrame()
    if base then
        setCharacterPosition(base)
        task.wait(0.2)
        removeCharacterAnchor()
    end
end)

-- 6. Auto Hatch Eggs
createToggleRow("AutoHatchRow", "Auto Hatch Eggs", _G.AutoHatchEggs, 6, function(state)
    _G.AutoHatchEggs = state
end)

-- 7. Auto Train Speed
createToggleRow("AutoTrainRow", "Auto Train Speed", _G.AutoTrainSpeed, 7, function(state)
    _G.AutoTrainSpeed = state
end)

-- 8. Auto Rebirth
createToggleRow("AutoRebirthRow", "Auto Rebirth", _G.AutoRebirth, 8, function(state)
    _G.AutoRebirth = state
end)

-- 9. Auto Collect Cash
createToggleRow("AutoCashRow", "Auto Collect Cash", _G.AutoCollectCash, 9, function(state)
    _G.AutoCollectCash = state
end)

-- 10. Remove Bosses (Godmode)
createToggleRow("RemoveBossRow", "Remove Bosses (Godmode)", _G.RemoveBosses, 10, function(state)
    _G.RemoveBosses = state
end)

-- 11. Anti-Egg Drop
createToggleRow("AntiDropRow", "Anti-Egg Drop", _G.AntiEggDrop, 11, function(state)
    _G.AntiEggDrop = state
end)

-- 12. Rare Egg ESP
createToggleRow("RareESPRow", "Rare Egg ESP", _G.RareEggESP, 12, function(state)
    _G.RareEggESP = state
end)

-- 13. All Egg ESP
createToggleRow("AllEggESPRow", "All Egg ESP", _G.AllEggESP, 13, function(state)
    _G.AllEggESP = state
end)

-- 14. Boss ESP
createToggleRow("BossESPRow", "Boss ESP", _G.BossESP, 14, function(state)
    _G.BossESP = state
end)

-- 15. Player ESP
createToggleRow("PlayerESPRow", "Player ESP", _G.PlayerESP, 15, function(state)
    _G.PlayerESP = state
end)

-- 16. WalkSpeed Boost
createStepperRow("WalkSpeedRow", "WalkSpeed", "WalkSpeedActive", "WalkSpeedValue", 16, 300, 10, 60, 16, function(active, val)
    if not active then
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            end
        end)
    end
end)

-- 17. Fly Mode
createStepperRow("FlyModeRow", "Fly Mode", "FlyActive", "FlySpeedValue", 20, 250, 10, 70, 17, function(active, val)
    if not active then
        pcall(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:FindFirstChild("USH_FlyVelocity") then
                hrp.USH_FlyVelocity:Destroy()
            end
            if hrp and hrp:FindFirstChild("USH_FlyGyro") then
                hrp.USH_FlyGyro:Destroy()
            end
        end)
    end
end)

-- 18. Noclip Mode
createToggleRow("NoclipRow", "Noclip Mode", _G.NoclipActive, 18, function(state)
    _G.NoclipActive = state
end)

-- 19. Infinite Jump
createToggleRow("InfJumpRow", "Infinite Jump", _G.InfJumpActive, 19, function(state)
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
-- BACKGROUND AUTOMATION ENGINES
-- =================================================================

-- 1. Auto Steal Rare Egg Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoStealRareEgg and not isStealingActive then
            local rare = getRarestEgg()
            if rare then
                performStealCycle(rare)
            end
        end
    end
end)

-- 2. Auto Steal Nearest Egg Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoStealNearestEgg and not isStealingActive then
            local near = getNearestEgg()
            if near then
                performStealCycle(near)
            end
        end
    end
end)

-- 3. Supercharged Multi-Layer Auto Collect Cash Engine
task.spawn(function()
    while true do
        task.wait(0.35)
        if _G.AutoCollectCash then
            pcall(function()
                local char = LocalPlayer.Character
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end

                -- Layer 1: Touch Interest on all Cash, Coin, Yen, Income, Collector Parts
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local nameLower = string.lower(obj.Name)
                        if string.find(nameLower, "cash") or string.find(nameLower, "coin") or string.find(nameLower, "yen") or string.find(nameLower, "money") or string.find(nameLower, "income") or string.find(nameLower, "collector") or string.find(nameLower, "atm") or string.find(nameLower, "bank") or string.find(nameLower, "safe") or string.find(nameLower, "drop") then
                            if (obj.Position - rootPart.Position).Magnitude < 300 and firetouchinterest then
                                firetouchinterest(rootPart, obj, 0)
                                task.wait(0.005)
                                firetouchinterest(rootPart, obj, 1)
                            end
                        end
                    end
                end

                -- Layer 2: Trigger ProximityPrompts on Collectors / Cash Stations
                for _, prompt in ipairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local pName = string.lower(prompt.ActionText .. " " .. prompt.ObjectText .. " " .. (prompt.Parent and prompt.Parent.Name or ""))
                        if string.find(pName, "collect") or string.find(pName, "claim") or string.find(pName, "cash") or string.find(pName, "coin") or string.find(pName, "money") or string.find(pName, "income") then
                            prompt.HoldDuration = 0
                            prompt.RequiresLineOfSight = false
                            prompt.MaxActivationDistance = 999
                            fireproximityprompt(prompt, 0)
                        end
                    end
                end

                -- Layer 3: Remote Sweeper for Currency Invocations
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local rName = string.lower(rem.Name)
                        if string.find(rName, "collectcash") or string.find(rName, "claimcash") or string.find(rName, "collectincome") or string.find(rName, "claimincome") or string.find(rName, "collectmoney") or string.find(rName, "claimmoney") or string.find(rName, "collectall") or string.find(rName, "cash") or string.find(rName, "income") then
                            if rem:IsA("RemoteEvent") then pcall(function() rem:FireServer() end) else pcall(function() rem:InvokeServer() end) end
                        end
                    end
                end

                -- Layer 4: PlayerGui Claim Buttons
                if LocalPlayer:FindFirstChild("PlayerGui") then
                    for _, btn in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                        if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                            local bText = string.lower(btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or ""))
                            if string.find(bText, "claim") or string.find(bText, "collect") then
                                pcall(function()
                                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                                        conn:Fire()
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. Auto Hatch Eggs Engine
task.spawn(function()
    while true do
        task.wait(0.6)
        if _G.AutoHatchEggs then
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    local nameLower = string.lower(obj.Name)
                    if string.find(nameLower, "hatch") or string.find(nameLower, "nest") or string.find(nameLower, "egg") or string.find(nameLower, "pod") then
                        for _, prompt in ipairs(obj:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") then
                                prompt.HoldDuration = 0
                                prompt.RequiresLineOfSight = false
                                prompt.MaxActivationDistance = 999
                                fireproximityprompt(prompt, 0)
                            end
                        end
                    end
                end

                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local rName = string.lower(rem.Name)
                        if string.find(rName, "hatch") or string.find(rName, "openegg") or string.find(rName, "claimhatch") or string.find(rName, "buyegg") then
                            if rem:IsA("RemoteEvent") then pcall(function() rem:FireServer() end) else pcall(function() rem:InvokeServer() end) end
                        end
                    end
                end
            end)
        end
    end
end)

-- 5. Auto Train Speed Engine
task.spawn(function()
    while true do
        task.wait(0.4)
        if _G.AutoTrainSpeed then
            pcall(function()
                local char = LocalPlayer.Character
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    for _, pad in ipairs(workspace:GetDescendants()) do
                        local nameLower = string.lower(pad.Name)
                        if string.find(nameLower, "treadmill") or string.find(nameLower, "train") or string.find(nameLower, "speedpad") or string.find(nameLower, "track") then
                            local part = pad:IsA("BasePart") and pad or pad:FindFirstChildWhichIsA("BasePart")
                            if part and firetouchinterest then
                                firetouchinterest(rootPart, part, 0)
                                task.wait(0.005)
                                firetouchinterest(rootPart, part, 1)
                            end
                        end
                    end

                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end

                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") then
                        local rName = string.lower(rem.Name)
                        if string.find(rName, "train") or string.find(rName, "speed") or string.find(rName, "workout") or string.find(rName, "click") then
                            pcall(function() rem:FireServer() end)
                        end
                    end
                end
            end)
        end
    end
end)

-- 6. Auto Rebirth Engine
task.spawn(function()
    while true do
        task.wait(1.5)
        if _G.AutoRebirth then
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local rName = string.lower(rem.Name)
                        if string.find(rName, "rebirth") or string.find(rName, "prestige") or string.find(rName, "ascend") then
                            if rem:IsA("RemoteEvent") then pcall(function() rem:FireServer(1) end) else pcall(function() rem:InvokeServer(1) end) end
                        end
                    end
                end
            end)
        end
    end
end)

-- 7. Remove Bosses (Godmode) Engine
RunService.Stepped:Connect(function()
    if _G.RemoveBosses then
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                    local nameLower = string.lower(obj.Name)
                    if string.find(nameLower, "boss") or string.find(nameLower, "guardian") or string.find(nameLower, "guard") or string.find(nameLower, "monster") then
                        for _, part in ipairs(obj:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                                part.CanTouch = false
                            end
                            if part:IsA("TouchTransmitter") then
                                part:Destroy()
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- 8. Anti-Egg Drop Protection
task.spawn(function()
    local function applyAntiDrop(char)
        if not char then return end
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.StateChanged:Connect(function(oldState, newState)
                if _G.AntiEggDrop then
                    if newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.PlatformStanding then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
            end)
        end
    end

    if LocalPlayer.Character then applyAntiDrop(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(applyAntiDrop)
end)

-- 9. Movement Engines (WalkSpeed, Fly, Noclip, Infinite Jump)
RunService.RenderStepped:Connect(function(deltaTime)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        -- WalkSpeed Boost
        if _G.WalkSpeedActive and _G.WalkSpeedValue and hum and hrp then
            hum.WalkSpeed = _G.WalkSpeedValue
            if hum.MoveDirection.Magnitude > 0 then
                local boost = (_G.WalkSpeedValue - 16)
                hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (boost * deltaTime))
            end
        end

        -- Fly Mode (3D Smooth WASD & Mobile Touch)
        if _G.FlyActive and hrp and hum then
            local bv = hrp:FindFirstChild("USH_FlyVelocity")
            local bg = hrp:FindFirstChild("USH_FlyGyro")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "USH_FlyVelocity"
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bv.Parent = hrp
            end
            if not bg then
                bg = Instance.new("BodyGyro")
                bg.Name = "USH_FlyGyro"
                bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                bg.CFrame = hrp.CFrame
                bg.Parent = hrp
            end

            local cam = workspace.CurrentCamera
            local moveVec = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec = moveVec - Vector3.new(0, 1, 0) end

            if moveVec.Magnitude > 0 then
                bv.Velocity = moveVec.Unit * _G.FlySpeedValue
            else
                bv.Velocity = hum.MoveDirection * _G.FlySpeedValue
            end
            bg.CFrame = cam.CFrame
        end
    end)
end)

-- Noclip Handler
RunService.Stepped:Connect(function()
    if _G.NoclipActive then
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

-- Infinite Jump Handler
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
-- VISUALS & ESP ENGINES (Rare Egg, All Eggs, Boss, Player)
-- =================================================================

local espHolder = Instance.new("Folder")
espHolder.Name = "USH_ESP_Holder"
espHolder.Parent = ScreenGui

task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            espHolder:ClearAllChildren()
            local char = LocalPlayer.Character
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")

            -- 1. Rare Egg ESP & All Egg ESP
            if _G.RareEggESP or _G.AllEggESP then
                local rarest = _G.RareEggESP and getRarestEgg() or nil

                for _, item in ipairs(workspace:GetDescendants()) do
                    if (item:IsA("Model") or item:IsA("BasePart") or item:IsA("Tool")) and item ~= char and item.Parent ~= char then
                        local nameLower = string.lower(item.Name)
                        if (string.find(nameLower, "egg") or item:FindFirstChildWhichIsA("ProximityPrompt")) and not string.find(nameLower, "spawner") and not string.find(nameLower, "hatch") and not string.find(nameLower, "nest") then
                            local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
                            if part and part.Transparency < 1 then
                                local isRare = (item == rarest) or string.find(nameLower, "eternal") or string.find(nameLower, "divine") or string.find(nameLower, "mythic")

                                if (_G.RareEggESP and isRare) or _G.AllEggESP then
                                    local dist = rootPart and math.floor((rootPart.Position - part.Position).Magnitude) or 0

                                    local bill = Instance.new("BillboardGui")
                                    bill.Name = "EggESP"
                                    bill.AlwaysOnTop = true
                                    bill.Size = UDim2.new(0, 140, 0, 28)
                                    bill.StudsOffset = Vector3.new(0, 2.5, 0)
                                    bill.Adornee = part
                                    bill.Parent = espHolder

                                    local label = Instance.new("TextLabel")
                                    label.Size = UDim2.new(1, 0, 1, 0)
                                    label.BackgroundTransparency = 1
                                    label.Text = (isRare and "👑 [RARE] " or "🥚 ") .. item.Name .. " [" .. tostring(dist) .. "m]"
                                    label.TextColor3 = isRare and Color3.fromRGB(255, 50, 220) or Color3.fromRGB(255, 215, 0)
                                    label.Font = Enum.Font.GothamBold
                                    label.TextSize = 11
                                    label.TextStrokeTransparency = 0.2
                                    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                    label.Parent = bill

                                    local hl = Instance.new("Highlight")
                                    hl.FillColor = isRare and Color3.fromRGB(255, 50, 220) or Color3.fromRGB(255, 215, 0)
                                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    hl.FillTransparency = 0.4
                                    hl.Adornee = item
                                    hl.Parent = espHolder
                                end
                            end
                        end
                    end
                end
            end

            -- 2. Boss ESP
            if _G.BossESP then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj ~= char then
                        local nameLower = string.lower(obj.Name)
                        if string.find(nameLower, "boss") or string.find(nameLower, "guardian") or string.find(nameLower, "guard") then
                            local part = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                            if part then
                                local dist = rootPart and math.floor((rootPart.Position - part.Position).Magnitude) or 0

                                local bill = Instance.new("BillboardGui")
                                bill.Name = "BossESP"
                                bill.AlwaysOnTop = true
                                bill.Size = UDim2.new(0, 140, 0, 28)
                                bill.StudsOffset = Vector3.new(0, 3, 0)
                                bill.Adornee = part
                                bill.Parent = espHolder

                                local label = Instance.new("TextLabel")
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1
                                label.Text = "👹 " .. obj.Name .. " [" .. tostring(dist) .. "m]"
                                label.TextColor3 = Color3.fromRGB(255, 50, 50)
                                label.Font = Enum.Font.GothamBold
                                label.TextSize = 11
                                label.TextStrokeTransparency = 0.2
                                label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                label.Parent = bill

                                local hl = Instance.new("Highlight")
                                hl.FillColor = Color3.fromRGB(255, 30, 30)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.4
                                hl.Adornee = obj
                                hl.Parent = espHolder
                            end
                        end
                    end
                end
            end

            -- 3. Player ESP
            if _G.PlayerESP then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local pRoot = p.Character.HumanoidRootPart
                        local dist = rootPart and math.floor((rootPart.Position - pRoot.Position).Magnitude) or 0

                        local bill = Instance.new("BillboardGui")
                        bill.Name = "PlayerESP"
                        bill.AlwaysOnTop = true
                        bill.Size = UDim2.new(0, 120, 0, 28)
                        bill.StudsOffset = Vector3.new(0, 3, 0)
                        bill.Adornee = pRoot
                        bill.Parent = espHolder

                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = "👤 " .. p.DisplayName .. " [" .. tostring(dist) .. "m]"
                        label.TextColor3 = Color3.fromRGB(0, 230, 255)
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 11
                        label.TextStrokeTransparency = 0.2
                        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        label.Parent = bill

                        local hl = Instance.new("Highlight")
                        hl.FillColor = Color3.fromRGB(0, 230, 255)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.Adornee = p.Character
                        hl.Parent = espHolder
                    end
                end
            end
        end)
    end
end)

print("[ULTRA SCRIPT HUB] Steal and Hatch Anime Eggs Upgraded Successfully!")
