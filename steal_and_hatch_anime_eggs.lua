-- =================================================================
-- ULTRA SCRIPT HUB - OFFICIAL UI 1 (CLASSIC MATTE DARK)
-- GAME: Steal and Hatch Anime Eggs
-- PLACE ID: 76377501906469
-- AUTHOR: Made by Junejo
-- REPOSITORY: junejo18146/ultrascripthub
-- =================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
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

-- Base Anchor & Steal Controller (STRICTLY PRESERVED)
_G.SavedBaseCFrame = nil
local isStealingActive = false
local CooldownEggs = {}

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
Scroll.CanvasSize = UDim2.new(0, 0, 0, 580)
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
            if onClick then onClick(btn) end
            task.wait(0.25)
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

local function isAlive()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0
end

local function setCharacterPosition(targetCFrame)
    pcall(function()
        if not isAlive() then return end
        local rootPart = LocalPlayer.Character.HumanoidRootPart

        local bv = rootPart:FindFirstChild("USH_AnchorVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "USH_AnchorVelocity"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.zero
            bv.Parent = rootPart
        end

        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
        rootPart.Velocity = Vector3.zero
        rootPart.RotVelocity = Vector3.zero
        rootPart.CFrame = targetCFrame
    end)
end

local function removeCharacterAnchor()
    pcall(function()
        if isAlive() then
            local rootPart = LocalPlayer.Character.HumanoidRootPart
            if rootPart:FindFirstChild("USH_AnchorVelocity") then
                rootPart.USH_AnchorVelocity:Destroy()
            end
        end
    end)
end

local function getBaseCFrame()
    if _G.SavedBaseCFrame then
        return _G.SavedBaseCFrame
    end

    local basePos = nil
    pcall(function()
        local myName = LocalPlayer.Name
        local myDisplayName = LocalPlayer.DisplayName

        for _, containerName in ipairs({"Bases", "Plots", "Houses", "Islands", "SpawnLocations", "Spawns"}) do
            local container = Workspace:FindFirstChild(containerName)
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
    end)

    if not basePos and isAlive() then
        basePos = LocalPlayer.Character.HumanoidRootPart.CFrame
        _G.SavedBaseCFrame = basePos
    end
    return basePos
end

local function TriggerEggPrompt(prompt)
    if not prompt or not prompt.Parent then return end
    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 9999
        prompt.HoldDuration = 0
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt, 1)
            fireproximityprompt(prompt)
        end
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
        end
    end)
end

local function InstantTouch(part, targetPart)
    if not part or not targetPart then return end
    pcall(function()
        if firetouchinterest then
            firetouchinterest(part, targetPart, 0)
            firetouchinterest(part, targetPart, 1)
            firetouchinterest(targetPart, part, 0)
            firetouchinterest(targetPart, part, 1)
        end
    end)
end

local function GetLocationKey(pos)
    return math.floor(pos.X / 4) .. "_" .. math.floor(pos.Y / 4) .. "_" .. math.floor(pos.Z / 4)
end

-- =================================================================
-- ULTRA HIGH-PRECISION EGG SCANNERS (STRICTLY PRESERVED)
-- =================================================================

local function FindRarestEggTarget()
    local candidates = {}
    local now = os.clock()
    local baseCFrame = getBaseCFrame()
    local basePos = baseCFrame and baseCFrame.Position or Vector3.zero
    local char = LocalPlayer.Character

    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local pPart = prompt.Parent
            local targetPos = nil
            local actualPart = nil

            if pPart:IsA("BasePart") then
                targetPos = pPart.CFrame
                actualPart = pPart
            elseif pPart:IsA("Attachment") then
                targetPos = pPart.WorldCFrame
                actualPart = pPart.Parent:IsA("BasePart") and pPart.Parent or nil
            elseif pPart:IsA("Model") and pPart.PrimaryPart then
                targetPos = pPart.PrimaryPart.CFrame
                actualPart = pPart.PrimaryPart
            elseif pPart:IsA("Model") then
                local bp = pPart:FindFirstChildWhichIsA("BasePart")
                if bp then 
                    targetPos = bp.CFrame
                    actualPart = bp
                end
            end

            if targetPos and actualPart and actualPart ~= char and (not actualPart.Parent or actualPart.Parent ~= char) then
                local locKey = GetLocationKey(targetPos.Position)
                local isCoolingDown = CooldownEggs[locKey] and (now < CooldownEggs[locKey])

                if not isCoolingDown then
                    local distFromBase = (targetPos.Position - basePos).Magnitude
                    if distFromBase > 15 then
                        local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. pPart.Name):lower()
                        local isEgg = act:find("steal") or act:find("take") or act:find("grab") or act:find("egg") or act:find("pick") or act:find("collect") or act == ""

                        if isEgg then
                            local score = distFromBase
                            if act:find("eternal") then score = score + 50000 end
                            if act:find("divine") then score = score + 25000 end
                            if act:find("secret") then score = score + 15000 end
                            if act:find("mythic") then score = score + 8000 end
                            if act:find("legendary") then score = score + 4000 end
                            if act:find("rare") then score = score + 1000 end

                            table.insert(candidates, {
                                targetCFrame = targetPos,
                                prompt = prompt,
                                part = actualPart,
                                locKey = locKey,
                                score = score,
                                distFromBase = distFromBase
                            })
                        end
                    end
                end
            end
        end
    end

    if #candidates == 0 then return nil end

    table.sort(candidates, function(a, b)
        return a.score > b.score
    end)

    return candidates[1]
end

local function FindNearestEggTarget()
    if not isAlive() then return nil end
    local hrpPos = LocalPlayer.Character.HumanoidRootPart.Position
    local baseCFrame = getBaseCFrame()
    local basePos = baseCFrame and baseCFrame.Position or Vector3.zero
    local best = nil
    local shortestDist = math.huge
    local now = os.clock()
    local char = LocalPlayer.Character

    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local pPart = prompt.Parent
            local targetPos = nil
            local actualPart = nil

            if pPart:IsA("BasePart") then
                targetPos = pPart.CFrame
                actualPart = pPart
            elseif pPart:IsA("Attachment") then
                targetPos = pPart.WorldCFrame
                actualPart = pPart.Parent:IsA("BasePart") and pPart.Parent or nil
            elseif pPart:IsA("Model") and pPart.PrimaryPart then
                targetPos = pPart.PrimaryPart.CFrame
                actualPart = pPart.PrimaryPart
            elseif pPart:IsA("Model") then
                local bp = pPart:FindFirstChildWhichIsA("BasePart")
                if bp then 
                    targetPos = bp.CFrame
                    actualPart = bp
                end
            end

            if targetPos and actualPart and actualPart ~= char and (not actualPart.Parent or actualPart.Parent ~= char) then
                local locKey = GetLocationKey(targetPos.Position)
                local isCoolingDown = CooldownEggs[locKey] and (now < CooldownEggs[locKey])

                if not isCoolingDown then
                    local distFromBase = (targetPos.Position - basePos).Magnitude
                    if distFromBase > 15 then
                        local dist = (targetPos.Position - hrpPos).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            best = {
                                targetCFrame = targetPos,
                                prompt = prompt,
                                part = actualPart,
                                locKey = locKey
                            }
                        end
                    end
                end
            end
        end
    end

    return best
end

-- =================================================================
-- MASTER ZERO-DISTANCE HEIST PIPELINE (STRICTLY PRESERVED)
-- =================================================================

local function ExecuteHeistPipeline(targetInfo)
    if not targetInfo or isStealingActive or not isAlive() then return end
    isStealingActive = true

    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char.HumanoidRootPart
        local baseCFrame = getBaseCFrame()

        if not baseCFrame then
            isStealingActive = false
            return
        end

        local targetCFrame = targetInfo.targetCFrame
        local prompt = targetInfo.prompt
        local part = targetInfo.part
        local locKey = targetInfo.locKey

        -- 1. TELEPORT DIRECTLY INSIDE / ON TOP OF EGG PART (Zero Distance)
        setCharacterPosition(targetCFrame)
        task.wait(0.2)

        -- 2. STAY IN DIRECT CONTACT & EXECUTE GRAB (0.8s)
        local grabTime = tick()
        while tick() - grabTime < 0.8 and isAlive() do
            setCharacterPosition(targetCFrame)

            if part then
                InstantTouch(hrp, part)
            end
            if prompt then
                TriggerEggPrompt(prompt)
            end

            task.wait(0.08)
        end

        -- Mark egg cooldown so subsequent calls target next egg
        if locKey then
            CooldownEggs[locKey] = os.clock() + 3.5
        end

        -- 3. DIRECT RETURN TO SAVED BASE
        if baseCFrame and isAlive() then
            task.wait(0.1)
            setCharacterPosition(baseCFrame * CFrame.new(0, 2.5, 0))
            task.wait(0.2)

            -- 4. DEPOSIT & NEST CONFIRMATION (0.6s)
            local depTime = tick()
            while tick() - depTime < 0.6 and isAlive() do
                setCharacterPosition(baseCFrame * CFrame.new(0, 2.0, 0))

                -- Trigger base deposit & nest prompts
                for _, p in ipairs(Workspace:GetDescendants()) do
                    if p:IsA("ProximityPrompt") and p.Parent then
                        local pPos = p.Parent:IsA("BasePart") and p.Parent.Position or nil
                        if pPos and (pPos - baseCFrame.Position).Magnitude < 45 then
                            TriggerEggPrompt(p)
                        end
                    end
                end

                -- Touch base deposit / nest / plot parts
                for _, bp in ipairs(Workspace:GetDescendants()) do
                    if bp:IsA("BasePart") and (bp.Position - baseCFrame.Position).Magnitude < 40 then
                        local n = string.lower(bp.Name)
                        if string.find(n, "deposit") or string.find(n, "nest") or string.find(n, "hatch") or string.find(n, "slot") or string.find(n, "base") or string.find(n, "place") then
                            InstantTouch(hrp, bp)
                        end
                    end
                end

                -- Fire deposit remotes
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") then
                        local rName = string.lower(rem.Name)
                        if string.find(rName, "deposit") or string.find(rName, "place") or string.find(rName, "store") or string.find(rName, "claim") or string.find(rName, "dropegg") then
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
-- REGISTER ALL 18 ACTIVE FEATURE ROWS
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
createActionButtonRow("StealRareBtnRow", "Steal Rare Egg (1-Click)", "⚡ STEAL", 3, function(btn)
    task.spawn(function()
        btn.Text = "STEALING..."
        local target = FindRarestEggTarget()
        if target then
            ExecuteHeistPipeline(target)
            btn.Text = "✅ SUCCESS"
        else
            btn.Text = "❌ NO EGG"
        end
        task.wait(0.8)
        btn.Text = "⚡ STEAL"
    end)
end)

-- 4. Save Base Position
createActionButtonRow("SaveBaseRow", "Save Base Position", "💾 SAVE", 4, function(btn)
    if isAlive() then
        _G.SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        btn.Text = "✅ SAVED"
        task.wait(0.8)
        btn.Text = "💾 SAVE"
    end
end)

-- 5. Teleport to Base
createActionButtonRow("TpBaseRow", "Teleport to Base", "🏠 TP BASE", 5, function(btn)
    local base = getBaseCFrame()
    if base and isAlive() then
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

-- 9. Remove Bosses (Godmode)
createToggleRow("RemoveBossRow", "Remove Bosses (Godmode)", _G.RemoveBosses, 9, function(state)
    _G.RemoveBosses = state
end)

-- 10. Anti-Egg Drop
createToggleRow("AntiDropRow", "Anti-Egg Drop", _G.AntiEggDrop, 10, function(state)
    _G.AntiEggDrop = state
end)

-- 11. Rare Egg ESP
createToggleRow("RareESPRow", "Rare Egg ESP", _G.RareEggESP, 11, function(state)
    _G.RareEggESP = state
end)

-- 12. All Egg ESP
createToggleRow("AllEggESPRow", "All Egg ESP", _G.AllEggESP, 12, function(state)
    _G.AllEggESP = state
end)

-- 13. Boss ESP
createToggleRow("BossESPRow", "Boss ESP", _G.BossESP, 13, function(state)
    _G.BossESP = state
end)

-- 14. Player ESP
createToggleRow("PlayerESPRow", "Player ESP", _G.PlayerESP, 14, function(state)
    _G.PlayerESP = state
end)

-- 15. WalkSpeed Boost
createStepperRow("WalkSpeedRow", "WalkSpeed", "WalkSpeedActive", "WalkSpeedValue", 16, 300, 10, 60, 15, function(active, val)
    if not active then
        pcall(function()
            if isAlive() then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            end
        end)
    end
end)

-- 16. Fly Mode
createStepperRow("FlyModeRow", "Fly Mode", "FlyActive", "FlySpeedValue", 20, 250, 10, 70, 16, function(active, val)
    if not active then
        pcall(function()
            if isAlive() then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                if hrp:FindFirstChild("USH_FlyVelocity") then hrp.USH_FlyVelocity:Destroy() end
                if hrp:FindFirstChild("USH_FlyGyro") then hrp.USH_FlyGyro:Destroy() end
            end
        end)
    end
end)

-- 17. Noclip Mode
createToggleRow("NoclipRow", "Noclip Mode", _G.NoclipActive, 17, function(state)
    _G.NoclipActive = state
end)

-- 18. Infinite Jump
createToggleRow("InfJumpRow", "Infinite Jump", _G.InfJumpActive, 18, function(state)
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

-- 1. Auto Steal Rare Egg Loop (STRICTLY PRESERVED)
task.spawn(function()
    while true do
        task.wait(0.4)
        if _G.AutoStealRareEgg and not isStealingActive and isAlive() then
            local target = FindRarestEggTarget()
            if target then
                ExecuteHeistPipeline(target)
            end
        end
    end
end)

-- 2. Auto Steal Nearest Egg Loop (STRICTLY PRESERVED)
task.spawn(function()
    while true do
        task.wait(0.4)
        if _G.AutoStealNearestEgg and not isStealingActive and isAlive() then
            local target = FindNearestEggTarget()
            if target then
                ExecuteHeistPipeline(target)
            end
        end
    end
end)

-- 3. Auto Hatch Eggs Engine
task.spawn(function()
    while true do
        task.wait(0.6)
        if _G.AutoHatchEggs then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local nameLower = string.lower(obj.Name)
                    if string.find(nameLower, "hatch") or string.find(nameLower, "nest") or string.find(nameLower, "egg") or string.find(nameLower, "pod") then
                        for _, prompt in ipairs(obj:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") then
                                TriggerEggPrompt(prompt)
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

-- 4. SUPERCHARGED 5-LAYER AUTO TRAIN SPEED ENGINE (FIXED & HIGH-SPEED)
task.spawn(function()
    while true do
        task.wait(0.15)
        if _G.AutoTrainSpeed and isAlive() and not isStealingActive then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local backpack = LocalPlayer:FindFirstChild("Backpack")

                -- Layer 1: Auto Equip Any Training Tools (Weights, Dumbbells, Energy, Swords)
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            char:FindFirstChildOfClass("Humanoid"):EquipTool(tool)
                            break
                        end
                    end
                end

                -- Layer 2: Tool Activate
                local currentTool = char:FindFirstChildOfClass("Tool")
                if currentTool then
                    currentTool:Activate()
                end

                -- Layer 3: Virtual Click Tap Emulation
                if VirtualInputManager then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                else
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(500, 500), Workspace.CurrentCamera.CFrame)
                    VirtualUser:Button1Up(Vector2.new(500, 500), Workspace.CurrentCamera.CFrame)
                end

                -- Layer 4: Touch Treadmills / Training Pads
                if hrp then
                    for _, pad in ipairs(Workspace:GetDescendants()) do
                        if pad:IsA("BasePart") then
                            local n = string.lower(pad.Name)
                            if string.find(n, "treadmill") or string.find(n, "speedpad") or string.find(n, "train") or string.find(n, "track") or string.find(n, "run") then
                                if (pad.Position - hrp.Position).Magnitude < 60 and firetouchinterest then
                                    InstantTouch(hrp, pad)
                                end
                            end
                        end
                    end
                end

                -- Layer 5: Deep Remote Sweeper for Speed/Training
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") then
                        local rName = string.lower(rem.Name)
                        if string.find(rName, "train") or string.find(rName, "speed") or string.find(rName, "workout") or string.find(rName, "click") or string.find(rName, "tap") or string.find(rName, "addspeed") or string.find(rName, "step") then
                            pcall(function() rem:FireServer() end)
                            pcall(function() rem:FireServer(1) end)
                            pcall(function() rem:FireServer("Speed") end)
                        end
                    end
                end
            end)
        end
    end
end)

-- 5. SUPERCHARGED 4-LAYER AUTO REBIRTH ENGINE (FIXED & FULL-AUTO)
task.spawn(function()
    while true do
        task.wait(1.0)
        if _G.AutoRebirth and isAlive() then
            pcall(function()
                -- Layer 1: ReplicatedStorage Remotes
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local rName = string.lower(rem.Name)
                        if string.find(rName, "rebirth") or string.find(rName, "prestige") or string.find(rName, "ascend") or string.find(rName, "evolve") or string.find(rName, "dorebirth") or string.find(rName, "buyrebirth") then
                            if rem:IsA("RemoteEvent") then
                                pcall(function() rem:FireServer() end)
                                pcall(function() rem:FireServer(1) end)
                                pcall(function() rem:FireServer("Rebirth") end)
                            else
                                pcall(function() rem:InvokeServer() end)
                                pcall(function() rem:InvokeServer(1) end)
                            end
                        end
                    end
                end

                -- Layer 2: PlayerGui Rebirth Buttons & Modals
                if LocalPlayer:FindFirstChild("PlayerGui") then
                    for _, btn in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                        if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                            local bText = string.lower(btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or ""))
                            if string.find(bText, "rebirth") or string.find(bText, "prestige") or string.find(bText, "ascend") or string.find(bText, "yes") or string.find(bText, "confirm") then
                                pcall(function()
                                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                                        conn:Fire()
                                    end
                                end)
                            end
                        end
                    end
                end

                -- Layer 3: Physical Rebirth Pads & ProximityPrompts
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        local nameLower = string.lower(obj.Name)
                        if string.find(nameLower, "rebirth") or string.find(nameLower, "prestige") then
                            if obj:IsA("BasePart") and (obj.Position - hrp.Position).Magnitude < 30 then
                                InstantTouch(hrp, obj)
                            end
                            if obj:IsA("ProximityPrompt") then
                                TriggerEggPrompt(obj)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 6. Remove Bosses (Godmode) Engine
RunService.Stepped:Connect(function()
    if _G.RemoveBosses then
        pcall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
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

-- 7. Anti-Egg Drop Protection
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

-- 8. Movement Engines (WalkSpeed, Fly, Noclip, Infinite Jump)
RunService.RenderStepped:Connect(function(deltaTime)
    pcall(function()
        if not isAlive() then return end
        local char = LocalPlayer.Character
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

            local cam = Workspace.CurrentCamera
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
    if _G.NoclipActive and isAlive() then
        pcall(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- Infinite Jump Handler
UserInputService.JumpRequest:Connect(function()
    if _G.InfJumpActive and isAlive() then
        pcall(function()
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

-- =================================================================
-- ULTRA-STABLE ESP ENGINES (NO FLICKER, CONTINUOUS TRACKING)
-- =================================================================

local espHolder = Instance.new("Folder")
espHolder.Name = "USH_ESP_Holder"
espHolder.Parent = ScreenGui

task.spawn(function()
    while true do
        task.wait(0.4)
        pcall(function()
            local char = LocalPlayer.Character
            local rootPart = isAlive() and char.HumanoidRootPart or nil

            if not _G.RareEggESP and not _G.AllEggESP and not _G.BossESP and not _G.PlayerESP then
                espHolder:ClearAllChildren()
            else
                -- 1. Rare Egg ESP & All Egg ESP (Universal Model & Prompt Scanner)
                if _G.RareEggESP or _G.AllEggESP then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj ~= char and (not obj.Parent or obj.Parent ~= char) then
                            local nameLower = string.lower(obj.Name)
                            local isEgg = false
                            local targetPart = nil
                            local displayName = obj.Name

                            if obj:IsA("Model") and (string.find(nameLower, "egg") or obj:FindFirstChildWhichIsA("ProximityPrompt")) and not string.find(nameLower, "spawner") and not string.find(nameLower, "hatch") and not string.find(nameLower, "nest") then
                                isEgg = true
                                targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            elseif obj:IsA("BasePart") and string.find(nameLower, "egg") and not string.find(nameLower, "spawner") and not string.find(nameLower, "hatch") and not string.find(nameLower, "nest") then
                                isEgg = true
                                targetPart = obj
                            end

                            if isEgg and targetPart and targetPart.Transparency < 1 then
                                local isRare = string.find(nameLower, "eternal") or string.find(nameLower, "divine") or string.find(nameLower, "secret") or string.find(nameLower, "mythic") or string.find(nameLower, "legendary") or string.find(nameLower, "rare")

                                if (_G.RareEggESP and isRare) or _G.AllEggESP then
                                    local espTag = espHolder:FindFirstChild("ESP_Egg_" .. tostring(targetPart:GetDebugId(0)))
                                    local dist = rootPart and math.floor((rootPart.Position - targetPart.Position).Magnitude) or 0

                                    if not espTag then
                                        espTag = Instance.new("BillboardGui")
                                        espTag.Name = "ESP_Egg_" .. tostring(targetPart:GetDebugId(0))
                                        espTag.AlwaysOnTop = true
                                        espTag.Size = UDim2.new(0, 150, 0, 28)
                                        espTag.StudsOffset = Vector3.new(0, 2.5, 0)
                                        espTag.Adornee = targetPart
                                        espTag.Parent = espHolder

                                        local label = Instance.new("TextLabel")
                                        label.Name = "Tag"
                                        label.Size = UDim2.new(1, 0, 1, 0)
                                        label.BackgroundTransparency = 1
                                        label.TextColor3 = isRare and Color3.fromRGB(255, 50, 220) or Color3.fromRGB(255, 215, 0)
                                        label.Font = Enum.Font.GothamBold
                                        label.TextSize = 11
                                        label.TextStrokeTransparency = 0.2
                                        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                        label.Parent = espTag

                                        local hl = Instance.new("Highlight")
                                        hl.Name = "Glow"
                                        hl.FillColor = isRare and Color3.fromRGB(255, 50, 220) or Color3.fromRGB(255, 215, 0)
                                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                        hl.FillTransparency = 0.45
                                        hl.Adornee = obj
                                        hl.Parent = espTag
                                    end

                                    if espTag:FindFirstChild("Tag") then
                                        espTag.Tag.Text = (isRare and "👑 [RARE] " or "🥚 ") .. displayName .. " [" .. tostring(dist) .. "m]"
                                    end
                                end
                            end
                        end
                    end
                end

                -- 2. Boss ESP (Guardian & Boss Wallhack)
                if _G.BossESP then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj ~= char and not Players:GetPlayerFromCharacter(obj) then
                            local nameLower = string.lower(obj.Name)
                            if string.find(nameLower, "boss") or string.find(nameLower, "guardian") or string.find(nameLower, "guard") or string.find(nameLower, "monster") then
                                local targetPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                                if targetPart then
                                    local espTag = espHolder:FindFirstChild("ESP_Boss_" .. tostring(obj:GetDebugId(0)))
                                    local dist = rootPart and math.floor((rootPart.Position - targetPart.Position).Magnitude) or 0

                                    if not espTag then
                                        espTag = Instance.new("BillboardGui")
                                        espTag.Name = "ESP_Boss_" .. tostring(obj:GetDebugId(0))
                                        espTag.AlwaysOnTop = true
                                        espTag.Size = UDim2.new(0, 140, 0, 28)
                                        espTag.StudsOffset = Vector3.new(0, 3.5, 0)
                                        espTag.Adornee = targetPart
                                        espTag.Parent = espHolder

                                        local label = Instance.new("TextLabel")
                                        label.Name = "Tag"
                                        label.Size = UDim2.new(1, 0, 1, 0)
                                        label.BackgroundTransparency = 1
                                        label.TextColor3 = Color3.fromRGB(255, 50, 50)
                                        label.Font = Enum.Font.GothamBold
                                        label.TextSize = 11
                                        label.TextStrokeTransparency = 0.2
                                        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                        label.Parent = espTag

                                        local hl = Instance.new("Highlight")
                                        hl.Name = "Glow"
                                        hl.FillColor = Color3.fromRGB(255, 30, 30)
                                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                        hl.FillTransparency = 0.4
                                        hl.Adornee = obj
                                        hl.Parent = espTag
                                    end

                                    if espTag:FindFirstChild("Tag") then
                                        espTag.Tag.Text = "👹 " .. obj.Name .. " [" .. tostring(dist) .. "m]"
                                    end
                                end
                            end
                        end
                    end
                end

                -- 3. Player ESP (Live Player Tracker)
                if _G.PlayerESP then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local pRoot = p.Character.HumanoidRootPart
                            local espTag = espHolder:FindFirstChild("ESP_Player_" .. tostring(p.UserId))
                            local dist = rootPart and math.floor((rootPart.Position - pRoot.Position).Magnitude) or 0

                            if not espTag then
                                espTag = Instance.new("BillboardGui")
                                espTag.Name = "ESP_Player_" .. tostring(p.UserId)
                                espTag.AlwaysOnTop = true
                                espTag.Size = UDim2.new(0, 130, 0, 28)
                                espTag.StudsOffset = Vector3.new(0, 3.2, 0)
                                espTag.Adornee = pRoot
                                espTag.Parent = espHolder

                                local label = Instance.new("TextLabel")
                                label.Name = "Tag"
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1
                                label.TextColor3 = Color3.fromRGB(0, 230, 255)
                                label.Font = Enum.Font.GothamBold
                                label.TextSize = 11
                                label.TextStrokeTransparency = 0.2
                                label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                label.Parent = espTag

                                local hl = Instance.new("Highlight")
                                hl.Name = "Glow"
                                hl.FillColor = Color3.fromRGB(0, 230, 255)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.5
                                hl.Adornee = p.Character
                                hl.Parent = espTag
                            end

                            if espTag:FindFirstChild("Tag") then
                                espTag.Tag.Text = "👤 " .. p.DisplayName .. " [" .. tostring(dist) .. "m]"
                            end
                        end
                    end
                end
            end
        end)
    end
end)

print("[ULTRA SCRIPT HUB] Steal & Hatch Anime Eggs Master Hub Active!")
