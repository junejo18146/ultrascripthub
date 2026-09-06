-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - CLIMB AND JUMP TOWER (OFFICIAL)
-- Game: Climb and Jump Tower (Roblox)
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera", 5)

-- Safe GUI Parent Resolver (Instant 0s Rendering on Mobile & PC)
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
    for _, name in ipairs({"JunejoHubUI_ClimbAndJump", "JunejoHub_ClimbJumpTower", "ClimbAndJumpHubUI"}) do
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
    -- Auto Farm
    AutoWin = false,
    AutoJumpCoins = false,
    FastClimb = false,
    ClimbSpeed = 60,
    AutoHatch = false,
    AutoClaimRewards = true,

    -- Movement
    WalkSpeedBoost = false,
    WalkSpeed = 50,
    InfJump = false,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,

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
-- TOWER TOP & WIN RESOLVER
-- ====================================================
local function getTowerTopCFrame()
    local basePos = Vector3.new(0, 0, 0)
    local char, root = getPlayerChar()
    if root then basePos = root.Position end

    -- 1. Scan for dedicated Win / Finish / Trophy / Top pads
    local bestPad = nil
    local highestY = -math.huge

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not (char and obj:IsDescendantOf(char)) then
            local n = obj.Name:lower()
            if n:find("win") or n:find("finish") or n:find("trophy") or n:find("top") or n:find("summit") or n:find("goal") or n:find("endpad") then
                if obj.Position.Y > highestY then
                    highestY = obj.Position.Y
                    bestPad = obj
                end
            end
        end
    end

    if bestPad then
        return bestPad.CFrame + Vector3.new(0, 3, 0), bestPad
    end

    -- 2. Scan towers / stages for highest platform
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local n = obj.Name:lower()
            if n:find("tower") or n:find("stage") or n:find("landmark") then
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") and part.Position.Y > highestY then
                        highestY = part.Position.Y
                        bestPad = part
                    end
                end
            end
        end
    end

    if bestPad and highestY > 50 then
        return bestPad.CFrame + Vector3.new(0, 3, 0), bestPad
    end

    -- 3. Fallback high altitude CFrame
    return CFrame.new(basePos.X, 350, basePos.Z), nil
end

local function getSpawnCFrame()
    local spawnLoc = Workspace:FindFirstChildOfClass("SpawnLocation")
    if spawnLoc then
        return spawnLoc.CFrame + Vector3.new(0, 4, 0)
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("spawn") or n:find("lobby") or n:find("start") then
                return obj.CFrame + Vector3.new(0, 4, 0)
            end
        end
    end
    return CFrame.new(0, 15, 0)
end

-- ====================================================
-- AUTO FARM ENGINES
-- ====================================================

-- 1. Auto Win / Top Teleport Loop
spawnTask(function()
    while true do
        task.wait(0.5)
        if Settings.AutoWin and isAlive() then
            local _, root, hum = getPlayerChar()
            if root and hum then
                local topCF, winPad = getTowerTopCFrame()
                if topCF then
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    root.CFrame = topCF

                    -- Trigger Win Pad Touch
                    if winPad and firetouchinterest then
                        pcall(function()
                            firetouchinterest(root, winPad, 0)
                            task.wait(0.05)
                            firetouchinterest(root, winPad, 1)
                        end)
                    end

                    -- Trigger Win / Claim Remotes
                    pcall(function()
                        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                                local rn = rem.Name:lower()
                                if rn:find("win") or rn:find("trophy") or rn:find("finish") or rn:find("reach") or rn:find("complete") then
                                    if rem:IsA("RemoteEvent") then rem:FireServer()
                                    elseif rem:IsA("RemoteFunction") then rem:InvokeServer() end
                                end
                            end
                        end
                    end)

                    task.wait(0.6)
                end
            end
        end
    end
end)

-- 2. Auto Jump & Coin Farm Loop
spawnTask(function()
    while true do
        task.wait(0.8)
        if Settings.AutoJumpCoins and isAlive() then
            local _, root, hum = getPlayerChar()
            if root and hum then
                -- Step 1: Go to Top
                local topCF = getTowerTopCFrame()
                root.AssemblyLinearVelocity = Vector3.zero
                root.CFrame = topCF
                task.wait(0.3)

                -- Step 2: Trigger Jump / Dive down for coins
                hum.Jump = true
                root.AssemblyLinearVelocity = Vector3.new(0, -250, 0)

                -- Trigger Distance / Coin Remotes
                pcall(function()
                    for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                        if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                            local rn = rem.Name:lower()
                            if rn:find("jump") or rn:find("fall") or rn:find("coin") or rn:find("distance") or rn:find("score") then
                                if rem:IsA("RemoteEvent") then rem:FireServer()
                                elseif rem:IsA("RemoteFunction") then rem:InvokeServer() end
                            end
                        end
                    end
                end)

                task.wait(1.5)
            end
        end
    end
end)

-- 3. Fast Climb Engine
RunService.Heartbeat:Connect(function()
    if Settings.FastClimb and isAlive() then
        local _, root, hum = getPlayerChar()
        if root and hum then
            -- If climbing ladder / wall or moving upward
            if hum:GetState() == Enum.HumanoidStateType.Climbing or UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, Settings.ClimbSpeed, root.AssemblyLinearVelocity.Z)
            end
        end
    end
end)

-- 4. Auto Hatch Eggs Loop
spawnTask(function()
    while true do
        task.wait(0.5)
        if Settings.AutoHatch and isAlive() then
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local rn = rem.Name:lower()
                        if rn:find("hatch") or rn:find("buyegg") or rn:find("openegg") or rn:find("pethatch") then
                            if rem:IsA("RemoteEvent") then rem:FireServer(1, true)
                            elseif rem:IsA("RemoteFunction") then rem:InvokeServer(1, true) end
                        end
                    end
                end
            end)
        end
    end
end)

-- 5. Auto Claim Playtime Rewards, Spins & Daily Chests
spawnTask(function()
    while true do
        task.wait(2.5)
        if Settings.AutoClaimRewards and isAlive() then
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local rn = rem.Name:lower()
                        if rn:find("gift") or rn:find("reward") or rn:find("spin") or rn:find("chest") or rn:find("daily") or rn:find("free") or rn:find("claim") then
                            for i = 1, 12 do
                                if rem:IsA("RemoteEvent") then rem:FireServer(i)
                                elseif rem:IsA("RemoteFunction") then rem:InvokeServer(i) end
                            end
                        end
                    end
                end
            end)
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
ScreenGui.Name = "JunejoHubUI_ClimbAndJump"
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
TitleLabel.Text = "CLIMB & JUMP TOWER"
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

-- Helper Function: Add Action / Click Button Row
local function AddActionRow(text, btnLabel, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 23)
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
    ActionBtn.Text = btnLabel or "▶"
    ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionBtn.TextSize = 11
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
        if callback then spawnTask(function() callback(ActionBtn) end) end
    end)
end

-- ====================================================
-- REGISTER FEATURES & CONTROLS
-- ====================================================

-- 1. AUTO FARM & PROGRESSION
AddSectionHeader("Auto Farm & Progression")

AddToggleRow("Auto Win / Top Trophy", "AutoWin", function(state)
    if state then
        notify("Auto Win", "Auto Win / Top Trophy Farm Active!", 2)
    end
end)

AddToggleRow("Auto Jump Coin Farm", "AutoJumpCoins", function(state)
    if state then
        notify("Coin Farm", "Auto Jump & Max Fall Coin Farm Active!", 2)
    end
end)

AddToggleRow("Fast Speed Climb", "FastClimb", function(state)
    if state then
        notify("Fast Climb", "Climb Speed Boost Active!", 2)
    end
end)

-- Climb Speed Adjuster Pill
local ClimbRow = Instance.new("Frame")
ClimbRow.Size = UDim2.new(1, -6, 0, 23)
ClimbRow.BackgroundTransparency = 1
ClimbRow.Parent = ContentFrame

local ClimbLabel = Instance.new("TextLabel")
ClimbLabel.Size = UDim2.new(0.55, 0, 1, 0)
ClimbLabel.BackgroundTransparency = 1
ClimbLabel.Text = "Climb Boost Speed"
ClimbLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
ClimbLabel.TextSize = 12
ClimbLabel.Font = Enum.Font.GothamBold
ClimbLabel.TextXAlignment = Enum.TextXAlignment.Left
ClimbLabel.Parent = ClimbRow

local ClimbControlFrame = Instance.new("Frame")
ClimbControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
ClimbControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
ClimbControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
ClimbControlFrame.BorderSizePixel = 0
ClimbControlFrame.Parent = ClimbRow

local CCtrlCorner = Instance.new("UICorner")
CCtrlCorner.CornerRadius = UDim.new(0, 4)
CCtrlCorner.Parent = ClimbControlFrame

local CCtrlStroke = Instance.new("UIStroke")
CCtrlStroke.Color = Color3.fromRGB(45, 45, 55)
CCtrlStroke.Thickness = 1
CCtrlStroke.Parent = ClimbControlFrame

local CMinusBtn = Instance.new("TextButton")
CMinusBtn.Size = UDim2.new(0, 22, 1, 0)
CMinusBtn.Position = UDim2.new(0, 0, 0, 0)
CMinusBtn.BackgroundTransparency = 1
CMinusBtn.Text = "-"
CMinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
CMinusBtn.TextSize = 14
CMinusBtn.Font = Enum.Font.GothamBold
CMinusBtn.Parent = ClimbControlFrame

local ClimbDisplay = Instance.new("TextLabel")
ClimbDisplay.Size = UDim2.new(1, -44, 1, 0)
ClimbDisplay.Position = UDim2.new(0, 22, 0, 0)
ClimbDisplay.BackgroundTransparency = 1
ClimbDisplay.Text = tostring(Settings.ClimbSpeed)
ClimbDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
ClimbDisplay.TextSize = 11
ClimbDisplay.Font = Enum.Font.GothamBold
ClimbDisplay.Parent = ClimbControlFrame

local CPlusBtn = Instance.new("TextButton")
CPlusBtn.Size = UDim2.new(0, 22, 1, 0)
CPlusBtn.Position = UDim2.new(1, -22, 0, 0)
CPlusBtn.BackgroundTransparency = 1
CPlusBtn.Text = "+"
CPlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
CPlusBtn.TextSize = 14
CPlusBtn.Font = Enum.Font.GothamBold
CPlusBtn.Parent = ClimbControlFrame

CMinusBtn.MouseButton1Click:Connect(function()
    Settings.ClimbSpeed = math.max(20, Settings.ClimbSpeed - 10)
    ClimbDisplay.Text = tostring(Settings.ClimbSpeed)
end)

CPlusBtn.MouseButton1Click:Connect(function()
    Settings.ClimbSpeed = math.min(200, Settings.ClimbSpeed + 10)
    ClimbDisplay.Text = tostring(Settings.ClimbSpeed)
end)

AddToggleRow("Auto Hatch Eggs", "AutoHatch", function(state) end)
AddToggleRow("Auto Claim Gifts & Spins", "AutoClaimRewards", function(state) end, true)

-- 2. MOVEMENT & MOBILITY
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
    Settings.WalkSpeed = math.max(16, Settings.WalkSpeed - 5)
    SpeedDisplay.Text = tostring(Settings.WalkSpeed)
end)

PlusBtn.MouseButton1Click:Connect(function()
    Settings.WalkSpeed = math.min(200, Settings.WalkSpeed + 5)
    SpeedDisplay.Text = tostring(Settings.WalkSpeed)
end)

AddToggleRow("Infinite Jump", "InfJump", function(state) end)

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
FlyLabel.Text = "Tower Fly Mode"
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
    Settings.FlySpeed = math.min(150, Settings.FlySpeed + 5)
    FlyDisplay.Text = tostring(Settings.FlySpeed)
end)

AddToggleRow("Auto NoClip", "NoClip", function(state) end)

-- 3. TELEPORTS
AddSectionHeader("Teleports & Waypoints")

AddActionRow("Teleport to Top", "TP", function()
    if isAlive() then
        local topCF = getTowerTopCFrame()
        LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        LocalPlayer.Character.HumanoidRootPart.CFrame = topCF
        notify("Teleport", "Teleported to Tower Top!", 2)
    end
end)

AddActionRow("Teleport to Base/Spawn", "TP", function()
    if isAlive() then
        local spawnCF = getSpawnCFrame()
        LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        LocalPlayer.Character.HumanoidRootPart.CFrame = spawnCF
        notify("Teleport", "Teleported to Spawn Area!", 2)
    end
end)

AddActionRow("Click-to-TP Tool", "Get", function()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "Click Teleport"
        tool.Activated:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            if isAlive() and mouse.Hit then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
        tool.Parent = bp
        notify("Tool Given", "Click Teleport tool added to Backpack!", 2)
    end
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

notify("Climb & Jump Tower", "Junejo Ultra Script Hub Loaded!", 3)
