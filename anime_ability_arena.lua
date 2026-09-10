-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - ANIME ABILITY ARENA (V2 EDITION)
-- Game: Anime Ability Arena (Roblox)
-- Link: https://www.roblox.com/games/108567435288296/Anime-Ability-Arena
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- Universal Mobile (Delta / Codex / Fluxus) & PC Compatible
-- Official Classic Executive Dark UI (New 7 Core Hybrid Features)
-- ====================================================

local function elevate()
    if setthreadidentity then pcall(setthreadidentity, 8) end
end
elevate()

local rawSpawn = task.spawn
local function spawnTask(fn)
    return rawSpawn(function()
        elevate()
        pcall(fn)
    end)
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera", 5)

-- Safe GUI Parent Resolver
local function getSafeGui()
    if gethui then
        local success, res = pcall(gethui)
        if success and res then return res end
    end
    local core = nil
    pcall(function() core = game:GetService("CoreGui") end)
    if core then
        local ok = pcall(function()
            local test = Instance.new("Folder")
            test.Parent = core
            test:Destroy()
        end)
        if ok then return core end
    end
    return LocalPlayer:WaitForChild("PlayerGui", 10) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

local guiParent = getSafeGui()

-- Clean all previous UI instances safely
pcall(function()
    for _, name in ipairs({"JunejoHubUI_AnimeAbilityArena", "JunejoHub_AnimeAbilityArena", "JunejoAnimeAbilityUI"}) do
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        local lpGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if lpGui and lpGui:FindFirstChild(name) then lpGui[name]:Destroy() end
        if guiParent and guiParent:FindFirstChild(name) then guiParent[name]:Destroy() end
    end
end)

-- Screen Notification Helper
local function notify(title, message, dur)
    elevate()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "[JUNEJO] " .. tostring(title),
            Text = tostring(message),
            Duration = dur or 3
        })
    end)
end

-- ====================================================
-- GLOBAL STATE & SETTINGS (NEW 7 CORE FEATURES)
-- ====================================================
local Settings = {
    -- 5 Top Features from previous 7
    KillAura = false,
    AuraRadius = 25,
    AutoFarmKills = false,
    HitboxExpander = false,
    HitboxSize = 18,
    InstantGetUp = true,
    WalkSpeedBoost = false,
    WalkSpeed = 55,

    -- 2 Selected Features from remaining 13
    AutoAwakening = false,
    PlayerESP = false,

    -- Built-in Protection
    AntiAFK = true,
}

local function getPlayerChar()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return char, root, hum
end

local function isAlive()
    local _, root, hum = getPlayerChar()
    return root ~= nil and hum ~= nil and hum.Health > 0
end

-- ====================================================
-- 1. ZERO-DELAY KILL AURA
-- ====================================================
local function executeM1Attack()
    elevate()
    if VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(960, 540))
        end)
    end

    if VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end

    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
        end
    end

    pcall(function()
        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
            if rem:IsA("RemoteEvent") then
                local n = rem.Name:lower()
                if n:find("attack") or n:find("m1") or n:find("punch") or n:find("combat") or n:find("hit") or n:find("slash") then
                    rem:FireServer()
                    rem:FireServer(1)
                    rem:FireServer(true)
                end
            end
        end
    end)
end

spawnTask(function()
    while true do
        task.wait(0.05)
        if Settings.KillAura and isAlive() then
            local _, myRoot = getPlayerChar()
            if myRoot then
                local hasEnemyNearby = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local eHum = p.Character:FindFirstChildOfClass("Humanoid")
                        if eHum and eHum.Health > 0 then
                            local dist = (p.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                            if dist <= Settings.AuraRadius then
                                hasEnemyNearby = true
                                break
                            end
                        end
                    end
                end
                if hasEnemyNearby then
                    executeM1Attack()
                end
            end
        end
    end
end)

-- ====================================================
-- 2. AUTO FARM KILLS (YEN FARM)
-- ====================================================
spawnTask(function()
    while true do
        task.wait(0.12)
        if Settings.AutoFarmKills and isAlive() then
            local _, myRoot = getPlayerChar()
            if myRoot then
                local bestTarget = nil
                local lowestHP = math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local eHum = p.Character:FindFirstChildOfClass("Humanoid")
                        if eHum and eHum.Health > 0 then
                            if eHum.Health < lowestHP then
                                lowestHP = eHum.Health
                                bestTarget = p
                            end
                        end
                    end
                end

                if bestTarget and bestTarget.Character and bestTarget.Character:FindFirstChild("HumanoidRootPart") then
                    local tRoot = bestTarget.Character.HumanoidRootPart
                    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                    executeM1Attack()
                end
            end
        end
    end
end)

-- ====================================================
-- 3. HITBOX EXPANDER (18x18 Red Neon)
-- ====================================================
local originalSizes = {}

local function applyHitbox(targetChar)
    if not targetChar or targetChar == LocalPlayer.Character then return end
    local root = targetChar:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then
        if not originalSizes[root] then
            originalSizes[root] = {
                Size = root.Size,
                Transparency = root.Transparency,
                CanCollide = root.CanCollide,
                Material = root.Material,
                Color = root.Color
            }
        end
        if Settings.HitboxExpander then
            root.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
            root.Transparency = 0.65
            root.Color = Color3.fromRGB(255, 35, 35)
            root.Material = Enum.Material.Neon
            root.CanCollide = false
        else
            local orig = originalSizes[root]
            if orig then
                root.Size = orig.Size
                root.Transparency = orig.Transparency
                root.Color = orig.Color
                root.Material = orig.Material
                root.CanCollide = orig.CanCollide
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if Settings.HitboxExpander then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                applyHitbox(p.Character)
            end
        end
    end
end)

-- ====================================================
-- 4. AUTO ULTIMATE / AWAKENING (G Key Spammer)
-- ====================================================
local function castKey(keyCode)
    if VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
        end)
    end
end

spawnTask(function()
    while true do
        task.wait(1.5)
        if Settings.AutoAwakening and isAlive() then
            castKey(Enum.KeyCode.G)
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") then
                        local n = rem.Name:lower()
                        if n:find("awake") or n:find("ultimate") or n:find("mode") then
                            rem:FireServer()
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================================================
-- 5. INSTANT AUTO GET UP / ANTI-RAGDOLL (< 0.1s)
-- ====================================================
local function handleInstantGetUp()
    if not Settings.InstantGetUp or not isAlive() then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if hum and root then
        local state = hum:GetState()
        if hum.Sit or hum.PlatformStand or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Physics then
            hum.Sit = false
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            hum:ChangeState(Enum.HumanoidStateType.Running)
            root.AssemblyAngularVelocity = Vector3.zero
        end

        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BallSocketConstraint") or obj.Name:lower():find("ragdoll") or obj.Name:lower():find("knockdown") then
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("Motor6D") and not obj.Enabled then
                obj.Enabled = true
            end
        end
    end
end

RunService.Heartbeat:Connect(handleInstantGetUp)
RunService.Stepped:Connect(handleInstantGetUp)

-- ====================================================
-- 6. PLAYER ESP HIGHLIGHTS (Wallhacks)
-- ====================================================
local espHighlights = {}

local function createESP(player)
    if player == LocalPlayer then return end

    local function setupChar(char)
        if not char then return end
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if not root then return end

        local hl = Instance.new("Highlight")
        hl.Name = "JunejoESP"
        hl.FillColor = Color3.fromRGB(255, 45, 45)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0.1
        hl.Adornee = char
        hl.Enabled = Settings.PlayerESP
        hl.Parent = char
        espHighlights[player] = hl
    end

    player.CharacterAdded:Connect(setupChar)
    if player.Character then setupChar(player.Character) end
end

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

RunService.RenderStepped:Connect(function()
    for _, hl in pairs(espHighlights) do
        if hl then hl.Enabled = Settings.PlayerESP end
    end
end)

-- ====================================================
-- 7. WALKSPEED BOOST ENGINE (Persistent)
-- ====================================================
local function applyWalkSpeed()
    local _, _, hum = getPlayerChar()
    if hum then
        if Settings.WalkSpeedBoost then
            hum.WalkSpeed = Settings.WalkSpeed
        else
            hum.WalkSpeed = 16
        end
    end
end

RunService.RenderStepped:Connect(function()
    if Settings.WalkSpeedBoost then
        local _, _, hum = getPlayerChar()
        if hum and hum.WalkSpeed ~= Settings.WalkSpeed then
            hum.WalkSpeed = Settings.WalkSpeed
        end
    end
end)

-- Anti-AFK Disconnect Engine
if getconnections then
    for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
        if conn.Disable then conn:Disable() elseif conn.Disconnect then conn:Disconnect() end
    end
else
    LocalPlayer.Idled:Connect(function()
        if VirtualUser then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero)
            end)
        end
    end)
end

-- ====================================================
-- JUNEJO CLASSIC EXECUTIVE UI (100% FLAT & BORDERLESS)
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_AnimeAbilityArena"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 285, 0, 275)
MainFrame.Position = UDim2.new(0.5, -142, 0.5, -137)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Draggable MainFrame
local isDragging = false
local dragInput, dragStart, startPos
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

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ANIME ABILITY ARENA"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 11
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

-- Content Frame
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

-- Helper: Add Borderless Toggle Row
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
    CheckMark.BackgroundTransparency = Settings[configKey] and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox
    
    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark
    
    RowBtn.MouseButton1Click:Connect(function()
        Settings[configKey] = not Settings[configKey]
        CheckMark.BackgroundTransparency = Settings[configKey] and 0 or 1
        if callback then callback(Settings[configKey]) end
    end)
end

-- Helper: Add Interactive Line Bar Slider Row
local function AddSliderRow(title, configKey, sliderKey, minVal, maxVal, defaultVal, onChangeCallback, onToggleCallback)
    Settings[sliderKey] = defaultVal
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 38)
    Container.BackgroundTransparency = 1
    Container.Parent = ContentScroll
    
    local TopRow = Instance.new("Frame")
    TopRow.Size = UDim2.new(1, 0, 0, 20)
    TopRow.BackgroundTransparency = 1
    TopRow.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TopRow
    
    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0.2, 0, 1, 0)
    ValLabel.Position = UDim2.new(0.6, 0, 0, 0)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = tostring(defaultVal)
    ValLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
    ValLabel.TextSize = 11
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.Parent = TopRow
    
    local CheckBox = Instance.new("Frame")
    CheckBox.Size = UDim2.new(0, 18, 0, 18)
    CheckBox.Position = UDim2.new(1, -18, 0.5, -9)
    CheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    CheckBox.BorderSizePixel = 0
    CheckBox.Parent = TopRow
    
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
    CheckMark.BackgroundTransparency = Settings[configKey] and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox
    
    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = ""
    ToggleBtn.ZIndex = 5
    ToggleBtn.Parent = TopRow
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Settings[configKey] = not Settings[configKey]
        CheckMark.BackgroundTransparency = Settings[configKey] and 0 or 1
        if onToggleCallback then onToggleCallback(Settings[configKey]) end
    end)
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, 0, 0, 6)
    SliderTrack.Position = UDim2.new(0, 0, 0, 24)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = Container
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = SliderTrack
    
    local TrackStroke = Instance.new("UIStroke")
    TrackStroke.Color = Color3.fromRGB(40, 40, 50)
    TrackStroke.Thickness = 1
    TrackStroke.Parent = SliderTrack
    
    local initialPercent = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill
    
    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(1, 0, 1, 8)
    SliderBtn.Position = UDim2.new(0, 0, 0, -4)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text = ""
    SliderBtn.ZIndex = 6
    SliderBtn.Parent = SliderTrack
    
    local isSliding = false
    local function UpdateSlider(input)
        local posX = input.Position.X - SliderTrack.AbsolutePosition.X
        local percent = math.clamp(posX / SliderTrack.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * percent)
        Settings[sliderKey] = val
        ValLabel.Text = tostring(val)
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        if onChangeCallback then onChangeCallback(val) end
    end
    
    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            UpdateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
end

-- ==========================================
-- POPULATE NEW 7 HYBRID FEATURES
-- ==========================================

-- 1. Zero-Delay Kill Aura
AddToggleRow("Zero-Delay Kill Aura", "KillAura")

-- 2. Auto Farm Kills (Yen Farm)
AddToggleRow("Auto Farm Kills", "AutoFarmKills")

-- 3. Hitbox Expander (18x18 Red Neon)
AddToggleRow("Hitbox Expander", "HitboxExpander")

-- 4. Auto Ultimate / Awakening (G Key)
AddToggleRow("Auto Ultimate (Awakening)", "AutoAwakening")

-- 5. Instant Auto Get Up (Anti-Ragdoll)
AddToggleRow("Instant Auto Get Up", "InstantGetUp")

-- 6. Player ESP Highlights (Wallhacks)
AddToggleRow("Player ESP Highlights", "PlayerESP")

-- 7. WalkSpeed Boost (Interactive Line Bar)
AddSliderRow("WalkSpeed Boost", "WalkSpeedBoost", "WalkSpeed", 16, 150, 55, function(val)
    applyWalkSpeed()
end, function(enabled)
    applyWalkSpeed()
end)

-- Footer (Pinned at bottom)
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 34)
Footer.Position = UDim2.new(0, 0, 1, -36)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 14)
FooterTitle.Position = UDim2.new(0, 0, 0, 2)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 11
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 12)
FooterSub.Position = UDim2.new(0, 0, 0, 16)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 9
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.Parent = Footer

print("Junejo Ultra Script Hub V2 loaded successfully for Anime Ability Arena (New 7 Hybrid Features)!")
