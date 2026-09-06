-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - DUNGEON QUEST REBORN (OFFICIAL)
-- Game: Dungeon Quest Reborn (ID: 77649408247578)
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- Universal Mobile (Delta / Codex / Fluxus) & PC Compatible
-- 100% Flat & Borderless Junejo Standard UI
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

local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera", 5)

-- Safe GUI Parent Resolver (Instant Rendering on Mobile & PC)
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
    for _, name in ipairs({"JunejoHubUI_DungeonQuest", "NomiiScripts_DQ", "JunejoDQHubUI"}) do
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
-- GLOBAL STATE & SETTINGS
-- ====================================================
local Settings = {
    -- Combat
    KillAura = false,
    AuraRadius = 25,
    AutoSkills = false,
    BossPriority = false,

    -- Movement
    WalkSpeedBoost = false,
    WalkSpeed = 28,
    NoClip = false,
    InfJump = false,
    Fly = false,
    FlySpeed = 30,

    -- Visuals & ESP
    MobESP = false,
    Tracers = false,
    LootESP = false,
    PlayerESP = false,

    -- System
    AntiAFK = true,
}

_G.Settings = Settings

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
-- DUNGEON MOB DETECTION & COMBAT LOGIC
-- ====================================================
local function getDungeonMobs()
    local mobs = {}
    local playerChars = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then playerChars[p.Character] = true end
    end

    local function scanFolder(container)
        if not container then return end
        for _, obj in ipairs(container:GetChildren()) do
            if obj:IsA("Model") and not playerChars[obj] then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildWhichIsA("BasePart")
                if hum and root and hum.Health > 0 then
                    local isBoss = string.find(string.lower(obj.Name), "boss") ~= nil
                    table.insert(mobs, {
                        Model = obj,
                        Humanoid = hum,
                        Root = root,
                        IsBoss = isBoss
                    })
                end
            end
            if obj:IsA("Folder") or (obj:IsA("Model") and not obj:FindFirstChildOfClass("Humanoid")) then
                scanFolder(obj)
            end
        end
    end

    local dungeonFolder = Workspace:FindFirstChild("dungeon") or Workspace:FindFirstChild("mobs") or Workspace:FindFirstChild("Live") or Workspace
    scanFolder(dungeonFolder)

    return mobs
end

-- Attack Trigger (Left Click / Tool Activate / Touch)
local lastAttackTime = 0
local function triggerAttack()
    local now = os.clock()
    if now - lastAttackTime < 0.12 then return end
    lastAttackTime = now

    spawnTask(function()
        if VirtualInputManager then
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end)
        end
        if VirtualUser then
            pcall(function()
                VirtualUser:ClickButton1(Vector2.new(0, 0))
            end)
        end
        pcall(function()
            if mouse1click then mouse1click() end
        end)
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end)
    end)
end

-- Auto Skills Trigger (Q, E, R Keys)
local lastSkillTime = 0
local function triggerSkills()
    local now = os.clock()
    if now - lastSkillTime < 0.45 then return end
    lastSkillTime = now

    spawnTask(function()
        if VirtualInputManager then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                task.wait(0.03)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
            end)
            task.wait(0.08)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.03)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end)
            task.wait(0.08)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                task.wait(0.03)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
            end)
        end
    end)
end

-- Combat Loop
RunService.RenderStepped:Connect(function()
    local char, root, hum = getPlayerChar()
    if not root or not hum or hum.Health <= 0 then return end

    if Settings.KillAura or Settings.AutoSkills then
        local mobs = getDungeonMobs()
        local targetMob = nil
        local closestDist = Settings.AuraRadius

        -- Check for Boss first if BossPriority is enabled
        if Settings.BossPriority then
            for _, mobData in ipairs(mobs) do
                if mobData.IsBoss and mobData.Root then
                    local dist = (root.Position - mobData.Root.Position).Magnitude
                    if dist <= Settings.AuraRadius then
                        targetMob = mobData
                        break
                    end
                end
            end
        end

        -- If no boss in range, target closest mob
        if not targetMob then
            for _, mobData in ipairs(mobs) do
                if mobData.Root then
                    local dist = (root.Position - mobData.Root.Position).Magnitude
                    if dist <= closestDist then
                        closestDist = dist
                        targetMob = mobData
                    end
                end
            end
        end

        if targetMob then
            if Settings.KillAura then
                triggerAttack()
                pcall(function()
                    local rArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
                    if rArm and targetMob.Root then
                        if firetouchinterest then
                            firetouchinterest(rArm, targetMob.Root, 0)
                            firetouchinterest(rArm, targetMob.Root, 1)
                        end
                    end
                end)
            end
            if Settings.AutoSkills then
                triggerSkills()
            end
        end
    end
end)

-- ====================================================
-- MOVEMENT ENGINE (WalkSpeed, NoClip, Fly, InfJump)
-- ====================================================
RunService.RenderStepped:Connect(function()
    local char, root, hum = getPlayerChar()
    if hum and root and Settings.WalkSpeedBoost and not Settings.Fly then
        hum.WalkSpeed = Settings.WalkSpeed
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local speedMultiplier = (Settings.WalkSpeed / 16)
            if speedMultiplier > 1 then
                root.CFrame = root.CFrame + (moveDir * (speedMultiplier - 1) * 0.35)
            end
        end
    elseif hum and not Settings.WalkSpeedBoost then
        hum.WalkSpeed = 16
    end
end)

RunService.Stepped:Connect(function()
    if Settings.NoClip then
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

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and isAlive() then
        local _, _, hum = getPlayerChar()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Flight Mechanics
local flyBodyVelocity, flyBodyGyro
local function startFly()
    local char, root, hum = getPlayerChar()
    if not root or not hum then return end
    
    hum.PlatformStand = true
    
    if not flyBodyVelocity or not flyBodyVelocity.Parent then
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.Name = "FlyVelocity"
        flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = root
    end
    
    if not flyBodyGyro or not flyBodyGyro.Parent then
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.Name = "FlyGyro"
        flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        flyBodyGyro.CFrame = root.CFrame
        flyBodyGyro.P = 10000
        flyBodyGyro.D = 500
        flyBodyGyro.Parent = root
    end
end

local function stopFly()
    local _, _, hum = getPlayerChar()
    if hum then hum.PlatformStand = false end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

RunService.RenderStepped:Connect(function()
    if Settings.Fly and isAlive() then
        local _, root, hum = getPlayerChar()
        if root and hum then
            if not flyBodyVelocity or not flyBodyGyro then
                startFly()
            else
                hum.PlatformStand = true
                local camCF = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame or CFrame.new()
                local moveDir = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit
                end
                
                flyBodyVelocity.Velocity = moveDir * (Settings.FlySpeed * 1.5)
                flyBodyGyro.CFrame = camCF
            end
        end
    else
        stopFly()
    end
end)

-- ====================================================
-- VISUALS & DUNGEON ESP ENGINE
-- ====================================================
local MobESPCache = {}
local LootESPCache = {}
local PlayerESPCache = {}

local function createHighlightESP(instance, name, color, cache)
    if cache[instance] then return cache[instance] end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "JunejoESP_" .. name
    highlight.Adornee = instance
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = guiParent
    
    local rootPart = instance:IsA("BasePart") and instance or (instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChildWhichIsA("BasePart") or instance.PrimaryPart)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "JunejoESP_Tag"
    billboard.Adornee = rootPart
    billboard.Size = UDim2.new(0, 130, 0, 30)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Parent = guiParent
    
    local tag = Instance.new("TextLabel")
    tag.Size = UDim2.new(1, 0, 1, 0)
    tag.BackgroundTransparency = 1
    tag.Text = name
    tag.TextColor3 = color
    tag.Font = Enum.Font.GothamBold
    tag.TextSize = 12
    tag.TextStrokeTransparency = 0.3
    tag.Parent = billboard

    local tracer = nil
    if Drawing and Drawing.new then
        pcall(function()
            tracer = Drawing.new("Line")
            tracer.Visible = false
            tracer.Color = color
            tracer.Thickness = 1.5
            tracer.Transparency = 0.85
        end)
    end

    local record = {Highlight = highlight, Billboard = billboard, Tag = tag, Tracer = tracer}
    cache[instance] = record
    return record
end

local function cleanCache(cache)
    for inst, record in pairs(cache) do
        pcall(function()
            if record.Highlight then record.Highlight:Destroy() end
            if record.Billboard then record.Billboard:Destroy() end
            if record.Tracer then record.Tracer:Remove() end
        end)
        cache[inst] = nil
    end
end

RunService.RenderStepped:Connect(function()
    local _, root = getPlayerChar()
    if not root then return end
    local cam = Workspace.CurrentCamera

    -- 1. Mob & Boss ESP
    if Settings.MobESP or Settings.Tracers then
        local mobs = getDungeonMobs()
        for _, mobData in ipairs(mobs) do
            local color = mobData.IsBoss and Color3.fromRGB(250, 204, 21) or Color3.fromRGB(239, 68, 68)
            local label = string.format("%s [%d HP]", mobData.Model.Name, math.floor(mobData.Humanoid.Health))
            local record = MobESPCache[mobData.Model] or createHighlightESP(mobData.Model, label, color, MobESPCache)
            
            if record then
                record.Tag.Text = label
                record.Tag.TextColor3 = color
                record.Highlight.FillColor = color
                record.Highlight.Enabled = Settings.MobESP
                record.Billboard.Enabled = Settings.MobESP
                
                if Settings.Tracers and record.Tracer and cam and mobData.Root then
                    local pos, onScreen = cam:WorldToViewportPoint(mobData.Root.Position)
                    if onScreen then
                        record.Tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                        record.Tracer.To = Vector2.new(pos.X, pos.Y)
                        record.Tracer.Color = color
                        record.Tracer.Visible = true
                    else
                        record.Tracer.Visible = false
                    end
                elseif record.Tracer then
                    record.Tracer.Visible = false
                end
            end
        end
    else
        cleanCache(MobESPCache)
    end

    -- 2. Chest & Loot ESP
    if Settings.LootESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local name = string.lower(obj.Name)
                if string.find(name, "chest") or string.find(name, "gold") or string.find(name, "loot") or string.find(name, "drop") then
                    createHighlightESP(obj, "💰 " .. obj.Name, Color3.fromRGB(34, 197, 94), LootESPCache)
                end
            end
        end
    else
        cleanCache(LootESPCache)
    end

    -- 3. Party Player ESP
    if Settings.PlayerESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local pRoot = player.Character:FindFirstChild("HumanoidRootPart")
                local pHum = player.Character:FindFirstChild("Humanoid")
                if pRoot and pHum and pHum.Health > 0 then
                    local label = string.format("👤 %s [%d HP]", player.DisplayName, math.floor(pHum.Health))
                    createHighlightESP(player.Character, label, Color3.fromRGB(56, 189, 248), PlayerESPCache)
                end
            end
        end
    else
        cleanCache(PlayerESPCache)
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK and VirtualUser then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ====================================================
-- OFFICIAL JUNEJO BORDERLESS UI (280x285px)
-- STRICT FLAT BORDERLESS ROWS ONLY
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_DungeonQuest"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 285)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -142)
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

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local function enableHeaderDrag(dragHandle, targetFrame)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
enableHeaderDrag(Header, MainFrame)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "DUNGEON QUEST REBORN"
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
    cleanCache(MobESPCache)
    cleanCache(LootESPCache)
    cleanCache(PlayerESPCache)
    ScreenGui:Destroy()
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Scrollable Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -16, 0, 205)
ContentFrame.Position = UDim2.new(0, 10, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 80)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper Function: Add Section Title
local function AddSectionHeader(title)
    local SecRow = Instance.new("Frame")
    SecRow.Size = UDim2.new(1, -6, 0, 18)
    SecRow.BackgroundTransparency = 1
    SecRow.Parent = ContentFrame

    local SecLabel = Instance.new("TextLabel")
    SecLabel.Size = UDim2.new(1, 0, 1, 0)
    SecLabel.BackgroundTransparency = 1
    SecLabel.Text = "• " .. string.upper(title) .. " •"
    SecLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    SecLabel.TextSize = 10
    SecLabel.Font = Enum.Font.GothamBold
    SecLabel.TextXAlignment = Enum.TextXAlignment.Center
    SecLabel.Parent = SecRow
end

-- Helper Function: Add Strictly Flat & Borderless Toggle Row
local function AddToggleRow(text, configKey, callback, defaultVal)
    if defaultVal ~= nil then Settings[configKey] = defaultVal end
    
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 23)
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
    CheckMark.BackgroundTransparency = Settings[configKey] and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox
    
    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark
    
    local lastClick = 0
    RowBtn.MouseButton1Click:Connect(function()
        local now = os.clock()
        if now - lastClick < 0.12 then return end
        lastClick = now
        Settings[configKey] = not Settings[configKey]
        CheckMark.BackgroundTransparency = Settings[configKey] and 0 or 1
        if callback then callback(Settings[configKey]) end
    end)

    return {
        Set = function(val)
            Settings[configKey] = val
            CheckMark.BackgroundTransparency = val and 0 or 1
            if callback then callback(val) end
        end
    }
end

-- ====================================================
-- REGISTER FEATURES & CONTROLS
-- ====================================================

-- 1. AUTO FARM & COMBAT
AddSectionHeader("Combat & Auto Farm")

AddToggleRow("Auto Attack / Kill Aura", "KillAura", function(state)
    if state then
        notify("Kill Aura", "Dungeon Mob Kill Aura Active!", 2)
    end
end)

-- Aura Radius Pill Adjuster
local AuraRow = Instance.new("Frame")
AuraRow.Size = UDim2.new(1, -6, 0, 23)
AuraRow.BackgroundTransparency = 1
AuraRow.Parent = ContentFrame

local AuraLabel = Instance.new("TextLabel")
AuraLabel.Size = UDim2.new(0.55, 0, 1, 0)
AuraLabel.BackgroundTransparency = 1
AuraLabel.Text = "Aura Radius (Studs)"
AuraLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
AuraLabel.TextSize = 12
AuraLabel.Font = Enum.Font.GothamBold
AuraLabel.TextXAlignment = Enum.TextXAlignment.Left
AuraLabel.Parent = AuraRow

local AuraControlFrame = Instance.new("Frame")
AuraControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
AuraControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
AuraControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
AuraControlFrame.BorderSizePixel = 0
AuraControlFrame.Parent = AuraRow

local ACtrlCorner = Instance.new("UICorner")
ACtrlCorner.CornerRadius = UDim.new(0, 4)
ACtrlCorner.Parent = AuraControlFrame

local ACtrlStroke = Instance.new("UIStroke")
ACtrlStroke.Color = Color3.fromRGB(45, 45, 55)
ACtrlStroke.Thickness = 1
ACtrlStroke.Parent = AuraControlFrame

local AMinusBtn = Instance.new("TextButton")
AMinusBtn.Size = UDim2.new(0, 22, 1, 0)
AMinusBtn.Position = UDim2.new(0, 0, 0, 0)
AMinusBtn.BackgroundTransparency = 1
AMinusBtn.Text = "-"
AMinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
AMinusBtn.TextSize = 14
AMinusBtn.Font = Enum.Font.GothamBold
AMinusBtn.Parent = AuraControlFrame

local AuraDisplay = Instance.new("TextLabel")
AuraDisplay.Size = UDim2.new(1, -44, 1, 0)
AuraDisplay.Position = UDim2.new(0, 22, 0, 0)
AuraDisplay.BackgroundTransparency = 1
AuraDisplay.Text = tostring(Settings.AuraRadius)
AuraDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
AuraDisplay.TextSize = 11
AuraDisplay.Font = Enum.Font.GothamBold
AuraDisplay.Parent = AuraControlFrame

local APlusBtn = Instance.new("TextButton")
APlusBtn.Size = UDim2.new(0, 22, 1, 0)
APlusBtn.Position = UDim2.new(1, -22, 0, 0)
APlusBtn.BackgroundTransparency = 1
APlusBtn.Text = "+"
APlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
APlusBtn.TextSize = 14
APlusBtn.Font = Enum.Font.GothamBold
APlusBtn.Parent = AuraControlFrame

AMinusBtn.MouseButton1Click:Connect(function()
    Settings.AuraRadius = math.max(10, Settings.AuraRadius - 5)
    AuraDisplay.Text = tostring(Settings.AuraRadius)
end)

APlusBtn.MouseButton1Click:Connect(function()
    Settings.AuraRadius = math.min(80, Settings.AuraRadius + 5)
    AuraDisplay.Text = tostring(Settings.AuraRadius)
end)

AddToggleRow("Auto Cast Skills (Q, E, R)", "AutoSkills", function(state)
    if state then
        notify("Auto Skills", "Auto Spell & Ability Casting Active!", 2)
    end
end)

AddToggleRow("Boss Focus Priority", "BossPriority", function(state) end)

-- 2. MOVEMENT MODS
AddSectionHeader("Movement & Mobility")

-- Integrated WalkSpeed Row with Pill Adjuster
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, -6, 0, 23)
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
SpeedCheckMark.BackgroundTransparency = Settings.WalkSpeedBoost and 0 or 1
SpeedCheckMark.BorderSizePixel = 0
SpeedCheckMark.Parent = SpeedCheckBox

local MarkCorner = Instance.new("UICorner")
MarkCorner.CornerRadius = UDim.new(0, 2)
MarkCorner.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Settings.WalkSpeedBoost = not Settings.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Settings.WalkSpeedBoost and 0 or 1
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
SpeedDisplay.Text = tostring(Settings.WalkSpeed)
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
    Settings.WalkSpeed = math.max(16, Settings.WalkSpeed - 4)
    SpeedDisplay.Text = tostring(Settings.WalkSpeed)
end)

PlusBtn.MouseButton1Click:Connect(function()
    Settings.WalkSpeed = math.min(100, Settings.WalkSpeed + 4)
    SpeedDisplay.Text = tostring(Settings.WalkSpeed)
end)

AddToggleRow("Auto NoClip (Gates Bypass)", "NoClip", function(state) end)
AddToggleRow("Infinite Jump (Dodge AOE)", "InfJump", function(state) end)

-- Integrated Fly Mode Row with Pill Adjuster
local FlyRow = Instance.new("Frame")
FlyRow.Size = UDim2.new(1, -6, 0, 23)
FlyRow.BackgroundTransparency = 1
FlyRow.Parent = ContentFrame

local FlyToggleBtn = Instance.new("TextButton")
FlyToggleBtn.Size = UDim2.new(0.55, 0, 1, 0)
FlyToggleBtn.BackgroundTransparency = 1
FlyToggleBtn.Text = ""
FlyToggleBtn.ZIndex = 5
FlyToggleBtn.Parent = FlyRow

local FlyLabel = Instance.new("TextLabel")
FlyLabel.Size = UDim2.new(1, -26, 1, 0)
FlyLabel.BackgroundTransparency = 1
FlyLabel.Text = "Dungeon Fly Mode"
FlyLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
FlyLabel.TextSize = 12
FlyLabel.Font = Enum.Font.GothamBold
FlyLabel.TextXAlignment = Enum.TextXAlignment.Left
FlyLabel.Parent = FlyToggleBtn

local FlyCheckBox = Instance.new("Frame")
FlyCheckBox.Size = UDim2.new(0, 18, 0, 18)
FlyCheckBox.Position = UDim2.new(1, -18, 0.5, -9)
FlyCheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
FlyCheckBox.BorderSizePixel = 0
FlyCheckBox.Parent = FlyToggleBtn

local FlyCheckCorner = Instance.new("UICorner")
FlyCheckCorner.CornerRadius = UDim.new(0, 4)
FlyCheckCorner.Parent = FlyCheckBox

local FlyCheckStroke = Instance.new("UIStroke")
FlyCheckStroke.Color = Color3.fromRGB(45, 45, 55)
FlyCheckStroke.Thickness = 1.2
FlyCheckStroke.Parent = FlyCheckBox

local FlyCheckMark = Instance.new("Frame")
FlyCheckMark.Size = UDim2.new(0, 10, 0, 10)
FlyCheckMark.Position = UDim2.new(0.5, -5, 0.5, -5)
FlyCheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FlyCheckMark.BackgroundTransparency = Settings.Fly and 0 or 1
FlyCheckMark.BorderSizePixel = 0
FlyCheckMark.Parent = FlyCheckBox

local FMarkCorner = Instance.new("UICorner")
FMarkCorner.CornerRadius = UDim.new(0, 2)
FMarkCorner.Parent = FlyCheckMark

FlyToggleBtn.MouseButton1Click:Connect(function()
    Settings.Fly = not Settings.Fly
    FlyCheckMark.BackgroundTransparency = Settings.Fly and 0 or 1
end)

local FlyControlFrame = Instance.new("Frame")
FlyControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
FlyControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
FlyControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
FlyControlFrame.BorderSizePixel = 0
FlyControlFrame.Parent = FlyRow

local FCtrlCorner = Instance.new("UICorner")
FCtrlCorner.CornerRadius = UDim.new(0, 4)
FCtrlCorner.Parent = FlyControlFrame

local FCtrlStroke = Instance.new("UIStroke")
FCtrlStroke.Color = Color3.fromRGB(45, 45, 55)
FCtrlStroke.Thickness = 1
FCtrlStroke.Parent = FlyControlFrame

local FMinusBtn = Instance.new("TextButton")
FMinusBtn.Size = UDim2.new(0, 22, 1, 0)
FMinusBtn.Position = UDim2.new(0, 0, 0, 0)
FMinusBtn.BackgroundTransparency = 1
FMinusBtn.Text = "-"
FMinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
FMinusBtn.TextSize = 14
FMinusBtn.Font = Enum.Font.GothamBold
FMinusBtn.Parent = FlyControlFrame

local FlyDisplay = Instance.new("TextLabel")
FlyDisplay.Size = UDim2.new(1, -44, 1, 0)
FlyDisplay.Position = UDim2.new(0, 22, 0, 0)
FlyDisplay.BackgroundTransparency = 1
FlyDisplay.Text = tostring(Settings.FlySpeed)
FlyDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyDisplay.TextSize = 11
FlyDisplay.Font = Enum.Font.GothamBold
FlyDisplay.Parent = FlyControlFrame

local FPlusBtn = Instance.new("TextButton")
FPlusBtn.Size = UDim2.new(0, 22, 1, 0)
FPlusBtn.Position = UDim2.new(1, -22, 0, 0)
FPlusBtn.BackgroundTransparency = 1
FPlusBtn.Text = "+"
FPlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
FPlusBtn.TextSize = 14
FPlusBtn.Font = Enum.Font.GothamBold
FPlusBtn.Parent = FlyControlFrame

FMinusBtn.MouseButton1Click:Connect(function()
    Settings.FlySpeed = math.max(10, Settings.FlySpeed - 5)
    FlyDisplay.Text = tostring(Settings.FlySpeed)
end)

FPlusBtn.MouseButton1Click:Connect(function()
    Settings.FlySpeed = math.min(100, Settings.FlySpeed + 5)
    FlyDisplay.Text = tostring(Settings.FlySpeed)
end)

-- 3. VISUALS & ESP
AddSectionHeader("Visuals & Dungeon ESP")

AddToggleRow("Mob & Boss ESP", "MobESP", function(state)
    if not state then cleanCache(MobESPCache) end
end)

AddToggleRow("ESP Tracers", "Tracers", function(state)
    if not state then
        for _, rec in pairs(MobESPCache) do
            if rec.Tracer then rec.Tracer.Visible = false end
        end
    end
end)

AddToggleRow("Chest & Loot ESP", "LootESP", function(state)
    if not state then cleanCache(LootESPCache) end
end)

AddToggleRow("Party Player ESP", "PlayerESP", function(state)
    if not state then cleanCache(PlayerESPCache) end
end)

-- Pinned Footer
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

notify("Dungeon Quest Reborn", "Junejo Ultra Script Hub Loaded!", 3)
