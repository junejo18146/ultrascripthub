--[[
    ========================================================================
    JUNEJO ULTRA SCRIPT HUB - 99 NIGHTS IN THE FOREST (OFFICIAL V2.0)
    ========================================================================
    Author: Made by Junejo (junejo18146)
    Target Game: 99 Nights in the Forest (Roblox)
    Repository: junejo18146/ultrascripthub
    File: nights_in_the_forest.lua
    UI Standard: Junejo Classic Dark UI (#0F0F11) - Flat & Borderless Standard
    
    Features Included:
        1. Kill Aura (Multi-Method 60 Studs Auto Combat & Remote Sweep)
        2. Auto Fill Campfire (Pulls all fuel, wood & coal across workspace directly into campfire)
        3. Bring Fuel (Instant 1-Click Action)
        4. Bring Food (Instant 1-Click Action)
        5. Bring Medicine (Instant 1-Click Action)
        6. Bring Scrap (Instant 1-Click Action)
        7. Bring Bandages (Instant 1-Click Action)
        8. Teleport Campfire (Instant 1-Click Action)
        9. FullBright (Permanent Night Vision & Max Visibility)
        10. WalkSpeed Boost + Integrated Pill Controller (- / +: 16 to 250)
        11. Infinite Jump (Continuous Multi-Jump Engine)
        12. Fly Mode + Integrated Pill Controller (- / +: 20 to 250 with WASD & Mobile Joystick)
        13. Anti-AFK Engine (Auto 20-minute idle disconnect protection)
    ========================================================================
--]]

local GameTitle = "99 NIGHTS IN THE FOREST"

-- Core Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- =================================================================
-- SAFE GUI PARENT RESOLVER & DUPLICATE CLEANER
-- =================================================================
local function GetSafeGuiParent()
    local targetParent = nil
    if gethui then
        local s, r = pcall(gethui)
        if s and r then targetParent = r end
    end
    if not targetParent then
        local s, _ = pcall(function()
            local test = Instance.new("Folder")
            test.Parent = CoreGui
            test:Destroy()
        end)
        if s then targetParent = CoreGui end
    end
    if not targetParent then
        targetParent = LocalPlayer:WaitForChild("PlayerGui", 5) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end
    return targetParent or CoreGui or LocalPlayer:FindFirstChild("PlayerGui")
end

local function CleanupOldGui()
    pcall(function()
        local parent = GetSafeGuiParent()
        local names = {"JunejoHubUI_99Nights", "Forest99UI_Badshah", "NightsInForestUI"}
        for _, name in ipairs(names) do
            local old = parent:FindFirstChild(name)
            if old then old:Destroy() end
        end
    end)
    pcall(function()
        for _, name in ipairs({"JunejoHubUI_99Nights", "Forest99UI_Badshah", "NightsInForestUI"}) do
            if CoreGui:FindFirstChild(name) then
                CoreGui[name]:Destroy()
            end
            if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
                LocalPlayer.PlayerGui[name]:Destroy()
            end
        end
    end)
end
CleanupOldGui()

-- Global Feature States & Configuration
local Toggles = {
    KillAura = false,
    AutoFillCampfire = false,
    FullBright = false,
    WalkSpeedBoost = false,
    InfiniteJump = false,
    FlyMode = false,
    AntiAFK = true
}

local CustomSpeedValue = 45
local CustomFlySpeed = 60

-- =================================================================
-- HELPER FUNCTIONS & CHARACTER ACCESS
-- =================================================================
local function getPlayerChar()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return char, root, hum
end

local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.MaxActivationDistance = 999999
        prompt.RequiresLineOfSight = false
        prompt.HoldDuration = 0
    end)
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
        else
            prompt:InputHoldBegin()
            task.wait(0.01)
            prompt:InputHoldEnd()
        end
    end)
end

-- Universal Event Dispatcher
local function fireSignalDirect(sig, ...)
    if not sig then return end
    local args = {...}
    pcall(function()
        if firesignal then
            firesignal(sig, table.unpack(args))
        end
    end)
end

-- Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

-- =================================================================
-- CAMPFIRE FINDER ENGINE
-- =================================================================
local cachedCampfire = nil
local lastFireSearch = 0

local function getCampfire()
    local now = tick()
    if cachedCampfire and cachedCampfire.Parent and (now - lastFireSearch < 5) then
        return cachedCampfire
    end
    lastFireSearch = now

    -- Search for Campfire object in workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "campfire") or string.find(nameLower, "fire_pit") or string.find(nameLower, "camp_fire") or string.find(nameLower, "firepit") then
                local part = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Fire") or obj:FindFirstChildWhichIsA("BasePart")) or obj
                if part and part:IsA("BasePart") then
                    cachedCampfire = part
                    return part
                end
            end
        end
    end

    -- Fallback: check for Fire emitter or PointLight
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Fire") or obj:IsA("PointLight") then
            if obj.Parent and obj.Parent:IsA("BasePart") and (string.find(string.lower(obj.Parent.Name), "fire") or string.find(string.lower(obj.Parent.Parent.Name), "camp")) then
                cachedCampfire = obj.Parent
                return obj.Parent
            end
        end
    end

    return nil
end

-- =================================================================
-- BRING SPECIFIC ITEMS TO PLAYER ENGINE
-- =================================================================
local function bringItemCategory(keywords)
    task.spawn(function()
        pcall(function()
            local _, hrp = getPlayerChar()
            if not hrp then return end

            local broughtCount = 0
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    local nameLower = string.lower(obj.Name)
                    local matches = false
                    
                    for _, kw in ipairs(keywords) do
                        if string.find(nameLower, kw) then
                            matches = true
                            break
                        end
                    end

                    if matches then
                        local part = obj:IsA("Model") and (obj:FindFirstChild("Handle") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")) or obj
                        if part and part:IsA("BasePart") and not part:IsA("Terrain") and not part:IsDescendantOf(LocalPlayer.Character) and (part.Position - hrp.Position).Magnitude > 4 then
                            part.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 4) + Vector3.new(0, 1.5, 0)
                            
                            pcall(function()
                                firetouchinterest(hrp, part, 0)
                                task.wait(0.01)
                                firetouchinterest(hrp, part, 1)
                            end)
                            
                            for _, prompt in ipairs(obj:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") then
                                    triggerPrompt(prompt)
                                end
                            end

                            broughtCount = broughtCount + 1
                            if broughtCount >= 25 then
                                task.wait(0.08)
                                broughtCount = 0
                            end
                        end
                    end
                end
            end
        end)
    end)
end

-- Auto-Equip Best Weapon Helper
local function equipBestWeapon()
    pcall(function()
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not char or not backpack then return end
        
        local currentTool = char:FindFirstChildOfClass("Tool")
        if not currentTool then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local tName = string.lower(tool.Name)
                    if string.find(tName, "axe") or string.find(tName, "sword") or string.find(tName, "spear") or string.find(tName, "knife") or string.find(tName, "torch") or string.find(tName, "gun") or string.find(tName, "bow") or string.find(tName, "weapon") then
                        char.Humanoid:EquipTool(tool)
                        break
                    end
                end
            end
            if not char:FindFirstChildOfClass("Tool") then
                local firstTool = backpack:FindFirstChildOfClass("Tool")
                if firstTool then char.Humanoid:EquipTool(firstTool) end
            end
        end
    end)
end

-- =================================================================
-- 1. POWERFUL KILL AURA ENGINE (60 STUDS COMBAT & REMOTE ATTACK)
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.1)
        if Toggles.KillAura then
            pcall(function()
                local char, hrp, hum = getPlayerChar()
                if not hrp or not hum or hum.Health <= 0 then return end
                
                equipBestWeapon()
                local tool = char:FindFirstChildOfClass("Tool")

                -- Find all nearby animals and hostiles across workspace
                for _, model in ipairs(Workspace:GetDescendants()) do
                    if model:IsA("Model") and model ~= char and not Players:GetPlayerFromCharacter(model) then
                        local enemyHum = model:FindFirstChildOfClass("Humanoid")
                        local enemyPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model:FindFirstChild("Torso") or model:FindFirstChildWhichIsA("BasePart")
                        
                        if enemyHum and enemyHum.Health > 0 and enemyPart then
                            local dist = (enemyPart.Position - hrp.Position).Magnitude
                            if dist <= 60 then
                                local targetAimCFrame = CFrame.lookAt(hrp.Position, enemyPart.Position)

                                -- 1. Tool Activation & Remote Invocations
                                if tool then
                                    tool:Activate()
                                    for _, sub in ipairs(tool:GetDescendants()) do
                                        if sub:IsA("RemoteEvent") then
                                            pcall(function() sub:FireServer(enemyPart, enemyPart.Position) end)
                                            pcall(function() sub:FireServer(model, enemyPart) end)
                                            pcall(function() sub:FireServer() end)
                                        elseif sub:IsA("RemoteFunction") then
                                            pcall(function() sub:InvokeServer(enemyPart, enemyPart.Position) end)
                                            pcall(function() sub:InvokeServer(model, enemyPart) end)
                                            pcall(function() sub:InvokeServer() end)
                                        end
                                    end
                                end

                                -- 2. Virtual User Click towards target
                                pcall(function()
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(500, 500), targetAimCFrame)
                                    task.wait(0.01)
                                    VirtualUser:Button1Up(Vector2.new(500, 500), targetAimCFrame)
                                end)

                                -- 3. Trigger ProximityPrompts on enemy model
                                for _, prompt in ipairs(model:GetDescendants()) do
                                    if prompt:IsA("ProximityPrompt") then
                                        triggerPrompt(prompt)
                                    end
                                end

                                -- 4. Remote attack hooks in ReplicatedStorage
                                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                                    if rem:IsA("RemoteEvent") then
                                        local rName = string.lower(rem.Name)
                                        if string.find(rName, "hurt") or string.find(rName, "attack") or string.find(rName, "damage") or string.find(rName, "hit") or string.find(rName, "combat") then
                                            pcall(function() rem:FireServer(model, enemyPart) end)
                                            pcall(function() rem:FireServer(enemyPart, enemyPart.Position) end)
                                            pcall(function() rem:FireServer() end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 2. AUTO FILL CAMPFIRE ENGINE
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoFillCampfire then
            pcall(function()
                local fire = getCampfire()
                if not fire then return end

                local firePos = fire.CFrame + Vector3.new(0, 1.5, 0)
                local fuelCount = 0

                -- Scan all workspace descendants for Coal, Fuel, Wood, Gas, Sticks, Logs
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local nameLower = string.lower(obj.Name)
                        if string.find(nameLower, "coal") or string.find(nameLower, "fuel") or string.find(nameLower, "gas") or string.find(nameLower, "wood") or string.find(nameLower, "log") or string.find(nameLower, "stick") or string.find(nameLower, "igniter") then
                            local part = obj:IsA("Model") and (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")) or obj
                            if part and part:IsA("BasePart") and not part:IsA("Terrain") and part ~= fire and not part:IsDescendantOf(LocalPlayer.Character) then
                                local dist = (part.Position - fire.Position).Magnitude
                                if dist > 2 then
                                    part.CFrame = firePos
                                    part.Velocity = Vector3.new(0, -5, 0)
                                    
                                    pcall(function()
                                        firetouchinterest(part, fire, 0)
                                        task.wait(0.01)
                                        firetouchinterest(part, fire, 1)
                                    end)

                                    for _, prompt in ipairs(obj:GetDescendants()) do
                                        if prompt:IsA("ProximityPrompt") then
                                            triggerPrompt(prompt)
                                        end
                                    end

                                    fuelCount = fuelCount + 1
                                    if fuelCount >= 20 then
                                        task.wait(0.05)
                                        fuelCount = 0
                                    end
                                end
                            end
                        end
                    end
                end

                -- Trigger campfire prompts
                if fire.Parent then
                    for _, prompt in ipairs(fire.Parent:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            triggerPrompt(prompt)
                        end
                    end
                end
                for _, prompt in ipairs(fire:GetChildren()) do
                    if prompt:IsA("ProximityPrompt") then
                        triggerPrompt(prompt)
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 3. FULLBRIGHT ENGINE
-- =================================================================
local defaultLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local function UpdateFullBright(state)
    pcall(function()
        if state then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        else
            Lighting.Brightness = defaultLighting.Brightness
            Lighting.ClockTime = defaultLighting.ClockTime
            Lighting.FogEnd = defaultLighting.FogEnd
            Lighting.GlobalShadows = defaultLighting.GlobalShadows
            Lighting.OutdoorAmbient = defaultLighting.OutdoorAmbient
        end
    end)
end

-- =================================================================
-- 4. PLAYER ENHANCEMENTS (WalkSpeed, Infinite Jump, Fly)
-- =================================================================

-- WalkSpeed Enforcer
RunService.RenderStepped:Connect(function(deltaTime)
    pcall(function()
        if Toggles.WalkSpeedBoost and CustomSpeedValue and CustomSpeedValue > 16 then
            local char, hrp, hum = getPlayerChar()
            if char and hum and hrp and hum.MoveDirection.Magnitude > 0 then
                local speedBoost = (CustomSpeedValue - 16)
                hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (speedBoost * deltaTime))
            end
        end
    end)
end)

-- Infinite Jump Engine
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        local _, root, hum = getPlayerChar()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            if root then
                root.Velocity = Vector3.new(root.Velocity.X, 52, root.Velocity.Z)
            end
        end
    end
end)

-- Fly Engine (Full 3D Smooth WASD & Mobile Touch Joystick)
local FlyBodyGyro = nil
local FlyBodyVelocity = nil
local FlyConnection = nil
local Flying = false

local function DisableFly()
    Flying = false
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    if FlyBodyVelocity then
        pcall(function() FlyBodyVelocity:Destroy() end)
        FlyBodyVelocity = nil
    end
    if FlyBodyGyro then
        pcall(function() FlyBodyGyro:Destroy() end)
        FlyBodyGyro = nil
    end
    pcall(function()
        local _, hrp, hum = getPlayerChar()
        if hum then hum.PlatformStand = false end
        if hrp then
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
            if hrp:FindFirstChild("ForestFlyBV") then hrp.ForestFlyBV:Destroy() end
            if hrp:FindFirstChild("ForestFlyBG") then hrp.ForestFlyBG:Destroy() end
        end
    end)
end

local function EnableFly()
    DisableFly()
    local char, hrp, hum = getPlayerChar()
    if not hrp or not hum then return end

    Flying = true
    
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.Name = "ForestFlyBG"
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.CFrame = hrp.CFrame
    FlyBodyGyro.Parent = hrp

    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Name = "ForestFlyBV"
    FlyBodyVelocity.Velocity = Vector3.zero
    FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVelocity.Parent = hrp

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Toggles.FlyMode or not Flying or not hrp or not hrp.Parent or not hum or hum.Health <= 0 then
            DisableFly()
            return
        end

        local cam = Workspace.CurrentCamera
        if not cam then return end

        FlyBodyGyro.CFrame = cam.CFrame

        local flySpeed = math.clamp(CustomFlySpeed, 20, 250)
        local moveDirection = Vector3.zero

        -- PC Keyboard WASD Controls
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end

        -- Mobile Touch / Dynamic Thumbstick Support
        if hum.MoveDirection.Magnitude > 0 then
            local rawMove = hum.MoveDirection
            local forwardDot = rawMove:Dot(cam.CFrame.LookVector)
            local rightDot = rawMove:Dot(cam.CFrame.RightVector)
            
            local mobileDir = (cam.CFrame.LookVector * forwardDot) + (cam.CFrame.RightVector * rightDot)
            if mobileDir.Magnitude > 0.1 then
                moveDirection = moveDirection + mobileDir.Unit
            else
                moveDirection = moveDirection + (cam.CFrame.LookVector * rawMove.Magnitude)
            end
        end

        if moveDirection.Magnitude > 0 then
            FlyBodyVelocity.Velocity = moveDirection.Unit * flySpeed
        else
            FlyBodyVelocity.Velocity = Vector3.zero
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.6)
    if Toggles.FlyMode then
        EnableFly()
    end
end)

-- =================================================================
-- OFFICIAL JUNEJO STANDARD UI GENERATOR (FLAT & BORDERLESS)
-- =================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_99Nights"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Enabled = true
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = GetSafeGuiParent()

local MainWindowHeight = 330

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 280, 0, MainWindowHeight)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = true
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

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = GameTitle
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
    Toggles.KillAura = false
    Toggles.AutoFillCampfire = false
    Toggles.FullBright = false
    Toggles.WalkSpeedBoost = false
    Toggles.InfiniteJump = false
    Toggles.FlyMode = false
    UpdateFullBright(false)
    DisableFly()
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
ContentFrame.Size = UDim2.new(1, -24, 0, 250)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper function for Toggle Rows (Strictly Flat & Borderless Standard)
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

-- Helper function for Action Button Rows
local function AddActionButton(text, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 24)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame

    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(1, 0, 1, 0)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ActionBtn.BorderSizePixel = 0
    ActionBtn.Text = text
    ActionBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    ActionBtn.TextSize = 11
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.AutoButtonColor = false
    ActionBtn.Parent = Row

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = ActionBtn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = ActionBtn

    ActionBtn.MouseButton1Click:Connect(function()
        ActionBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        task.delay(0.12, function()
            ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
        end)
        if callback then callback() end
    end)
end

-- =================================================================
-- BUILD FEATURE ROWS
-- =================================================================

-- 1. Kill Aura
AddToggleRow("Kill Aura", "KillAura")

-- 2. Auto Fill Campfire
AddToggleRow("Auto Fill Campfire", "AutoFillCampfire")

-- 3. FullBright
AddToggleRow("FullBright", "FullBright", function(state)
    UpdateFullBright(state)
end)

-- 4. 1-Click Action Buttons
AddActionButton("⚡ Teleport Campfire", function()
    local char, hrp = getPlayerChar()
    if not hrp then return end
    local fire = getCampfire()
    if fire then
        hrp.CFrame = fire.CFrame + Vector3.new(0, 3.5, 0)
    else
        hrp.CFrame = CFrame.new(0, 10, 0)
    end
end)

AddActionButton("🪵 Bring Fuel", function()
    bringItemCategory({"fuel", "gas", "oil", "igniter", "coal"})
end)

AddActionButton("🍎 Bring Food", function()
    bringItemCategory({"food", "carrot", "apple", "berry", "corn", "mushroom", "meat", "cooked"})
end)

AddActionButton("💊 Bring Medicine", function()
    bringItemCategory({"medicine", "medkit", "med", "pill", "heal", "aid"})
end)

AddActionButton("⚙️ Bring Scrap", function()
    bringItemCategory({"scrap", "metal", "gear", "iron", "wire", "pipe"})
end)

AddActionButton("🩹 Bring Bandages", function()
    bringItemCategory({"bandage", "bandages", "gauze"})
end)

-- 5. WalkSpeed with Integrated - / + Pill Controller
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

local MarkCorner = Instance.new("UICorner")
MarkCorner.CornerRadius = UDim.new(0, 2)
MarkCorner.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
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
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(250, CustomSpeedValue + 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
end)

-- 6. Fly Mode with Integrated - / + Fly Speed Pill Controller
local FlyRow = Instance.new("Frame")
FlyRow.Size = UDim2.new(1, 0, 0, 23)
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
FlyLabel.Text = "Fly Mode"
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
FlyCheckMark.BackgroundTransparency = Toggles.FlyMode and 0 or 1
FlyCheckMark.BorderSizePixel = 0
FlyCheckMark.Parent = FlyCheckBox

local MarkCornerFly = Instance.new("UICorner")
MarkCornerFly.CornerRadius = UDim.new(0, 2)
MarkCornerFly.Parent = FlyCheckMark

FlyToggleBtn.MouseButton1Click:Connect(function()
    Toggles.FlyMode = not Toggles.FlyMode
    FlyCheckMark.BackgroundTransparency = Toggles.FlyMode and 0 or 1
    if Toggles.FlyMode then
        EnableFly()
    else
        DisableFly()
    end
end)

local FlyControlFrame = Instance.new("Frame")
FlyControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
FlyControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
FlyControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
FlyControlFrame.BorderSizePixel = 0
FlyControlFrame.Parent = FlyRow

local FlyCtrlCorner = Instance.new("UICorner")
FlyCtrlCorner.CornerRadius = UDim.new(0, 4)
FlyCtrlCorner.Parent = FlyControlFrame

local FlyCtrlStroke = Instance.new("UIStroke")
FlyCtrlStroke.Color = Color3.fromRGB(45, 45, 55)
FlyCtrlStroke.Thickness = 1
FlyCtrlStroke.Parent = FlyControlFrame

local FlyMinusBtn = Instance.new("TextButton")
FlyMinusBtn.Size = UDim2.new(0, 22, 1, 0)
FlyMinusBtn.Position = UDim2.new(0, 0, 0, 0)
FlyMinusBtn.BackgroundTransparency = 1
FlyMinusBtn.Text = "-"
FlyMinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
FlyMinusBtn.TextSize = 14
FlyMinusBtn.Font = Enum.Font.GothamBold
FlyMinusBtn.Parent = FlyControlFrame

local FlyDisplay = Instance.new("TextLabel")
FlyDisplay.Size = UDim2.new(1, -44, 1, 0)
FlyDisplay.Position = UDim2.new(0, 22, 0, 0)
FlyDisplay.BackgroundTransparency = 1
FlyDisplay.Text = tostring(CustomFlySpeed)
FlyDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyDisplay.TextSize = 11
FlyDisplay.Font = Enum.Font.GothamBold
FlyDisplay.Parent = FlyControlFrame

local FlyPlusBtn = Instance.new("TextButton")
FlyPlusBtn.Size = UDim2.new(0, 22, 1, 0)
FlyPlusBtn.Position = UDim2.new(1, -22, 0, 0)
FlyPlusBtn.BackgroundTransparency = 1
FlyPlusBtn.Text = "+"
FlyPlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
FlyPlusBtn.TextSize = 14
FlyPlusBtn.Font = Enum.Font.GothamBold
FlyPlusBtn.Parent = FlyControlFrame

FlyMinusBtn.MouseButton1Click:Connect(function()
    CustomFlySpeed = math.max(20, CustomFlySpeed - 10)
    FlyDisplay.Text = tostring(CustomFlySpeed)
end)

FlyPlusBtn.MouseButton1Click:Connect(function()
    CustomFlySpeed = math.min(250, CustomFlySpeed + 10)
    FlyDisplay.Text = tostring(CustomFlySpeed)
end)

-- 7. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump")

-- 8. Anti-AFK Engine
AddToggleRow("Anti-AFK Engine", "AntiAFK")

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

-- Window Dragging (Mouse & Touch)
local dragging = false
local dragInput, dragStart, startPos

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
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Mount GUI
ScreenGui.Parent = GetSafeGuiParent()

print("[Junejo Script Hub]: 99 Nights in the Forest Script Loaded Successfully!")
