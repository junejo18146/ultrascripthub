--[[
    ========================================================================
    JUNEJO ULTRA SCRIPT HUB - THROW A COIN (V3.0 AUTO BAR CLICKER)
    ========================================================================
    Author: Made by Junejo (junejo18146)
    Target Game: Throw a Coin (Roblox)
    Repository: junejo18146/ultrascripthub
    File: throw_a_coin.lua
    UI Standard: Junejo Classic Dark UI (#0F0F11) - Flat & Borderless Standard
    
    Features Included (All Original Core Mechanics 100% Preserved):
        1. Auto Throw Coin (Auto-Clicks Fountain Side Bar & Throws Every 0.5s Without Tapping)
        2. Auto Sell Items (Continuous Sell Hitbox Touch, PlayerGui & Remotes Sweep)
        3. Auto Upgrade Luck (Continuous Upgrade Pads, PlayerGui & Remotes Sweep)
        4. Teleport to Fountain (Instant 1-Click Action to Wishing Fountain / Well)
        5. Teleport to Sell Area (Instant 1-Click Action to Sell Shop / Merchant)
        6. WalkSpeed Boost + Integrated Pill Controller (- / +: 16 to 300)
        7. Jump Power Boost + Integrated Pill Controller (- / +: 50 to 300)
        8. Infinite Jump (Continuous Multi-Jump Engine)
        9. Fly Mode (Smooth 3D Flight with WASD/Space/Shift controls)
        10. Anti-AFK Engine (Auto 20-minute idle disconnect protection)
    ========================================================================
--]]

local GameTitle = "THROW A COIN"

-- Core Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local VirtualInputManager = nil
pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- =================================================================
-- SAFE GUI PARENT RESOLVER & DUPLICATE CLEANER
-- =================================================================
local function GetSafeGuiParent()
    if gethui then
        local s, r = pcall(gethui)
        if s and r then return r end
    end
    local s, _ = pcall(function() local _ = CoreGui.Name end)
    if s then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function CleanupOldGui()
    pcall(function()
        local parent = GetSafeGuiParent()
        local names = {"JunejoHub_ThrowACoin", "SakiScriptsThrowACoinUI", "ThrowACoinUI", "SakiScriptsUI", "JunejoHubUI_ThrowACoin"}
        for _, name in ipairs(names) do
            local old = parent:FindFirstChild(name)
            if old then old:Destroy() end
        end
    end)
    pcall(function()
        for _, name in ipairs({"JunejoHub_ThrowACoin", "SakiScriptsThrowACoinUI", "ThrowACoinUI", "SakiScriptsUI"}) do
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
    AutoThrow = false,
    AutoSell = false,
    AutoUpgradeLuck = false,
    WalkSpeedBoost = false,
    JumpPowerBoost = false,
    InfiniteJump = false,
    FlyMode = false,
    AntiAFK = true
}

local CustomSpeedValue = 35
local CustomJumpValue = 100
local FlySpeedValue = 60

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

-- Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end)
    end
end)

-- Universal Click Trigger for GUI Buttons
local function triggerGuiButton(btn)
    if not btn then return end
    pcall(function()
        if firesignal then
            if btn.MouseButton1Click then firesignal(btn.MouseButton1Click) end
            if btn.Activated then firesignal(btn.Activated) end
            if btn.MouseButton1Down then firesignal(btn.MouseButton1Down) end
            if btn.MouseButton1Up then firesignal(btn.MouseButton1Up) end
        end
        if VirtualInputManager and btn.AbsoluteSize and btn.AbsoluteSize.X > 0 then
            local center = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
        end
    end)
end

-- =================================================================
-- 1. AUTO THROW COIN & SIDE BAR AUTO-CLICKER ENGINE (Every 0.5s)
-- =================================================================
local function executeThrowCoin()
    pcall(function()
        local char, root, hum = getPlayerChar()

        -- 1. Auto Equip & Fast Activate Coin Tool
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            else
                local bpTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if bpTool and hum then
                    hum:EquipTool(bpTool)
                    task.wait(0.02)
                    bpTool:Activate()
                end
            end
        end

        -- 2. Scan & Click the Side Bar / Power Bar / Throw Button in PlayerGui
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in ipairs(playerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name ~= "JunejoHub_ThrowACoin" then
                    for _, obj in ipairs(gui:GetDescendants()) do
                        if (obj:IsA("TextButton") or obj:IsA("ImageButton") or obj:IsA("Frame") or obj:IsA("ImageLabel")) and obj.Visible then
                            local n = obj.Name:lower()
                            local pName = obj.Parent and obj.Parent.Name:lower() or ""
                            local full = n .. " " .. pName
                            
                            -- Detect any Side Bar, Power Meter, Charging Bar, or Throw Button
                            if full:find("bar") or full:find("throw") or full:find("power") or full:find("charge") or full:find("meter") or full:find("coin") or full:find("side") or full:find("click") or full:find("tap") or full:find("target") or full:find("fountain") or full:find("gauge") then
                                if not full:find("shop") and not full:find("sell") and not full:find("upgrade") and not full:find("rebirth") and not full:find("setting") then
                                    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                                        triggerGuiButton(obj)
                                    elseif obj:IsA("Frame") or obj:IsA("ImageLabel") then
                                        -- Click center of frame/bar directly via VirtualInputManager
                                        pcall(function()
                                            local absPos = obj.AbsolutePosition
                                            local absSize = obj.AbsoluteSize
                                            if absSize.X > 0 and absSize.Y > 0 and VirtualInputManager then
                                                local center = absPos + (absSize / 2)
                                                VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
                                                VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- 3. Side & Center Screen Tap Simulation (Clicks exact screen spots where Side Bar appears)
        local camera = Workspace.CurrentCamera
        if camera and camera.ViewportSize then
            local vp = camera.ViewportSize
            local tapSpots = {
                Vector2.new(vp.X * 0.82, vp.Y * 0.50), -- Right Side Bar (Primary)
                Vector2.new(vp.X * 0.85, vp.Y * 0.60), -- Right Side Lower Bar
                Vector2.new(vp.X * 0.75, vp.Y * 0.50), -- Right-Mid Bar
                Vector2.new(vp.X * 0.50, vp.Y * 0.50), -- Center Screen
                Vector2.new(vp.X * 0.50, vp.Y * 0.70)  -- Bottom Center Bar
            }

            for _, spot in ipairs(tapSpots) do
                if VirtualInputManager then
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(spot.X, spot.Y, 0, true, game, 0)
                        VirtualInputManager:SendMouseButtonEvent(spot.X, spot.Y, 0, false, game, 0)
                    end)
                end
                pcall(function()
                    VirtualUser:ClickButton1(spot)
                end)
            end
        end

        -- 4. Fire Throw / Toss / Coin Remotes in ReplicatedStorage with power args
        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
            if rem:IsA("RemoteEvent") then
                local rName = string.lower(rem.Name)
                if string.find(rName, "throw") or string.find(rName, "toss") or string.find(rName, "flip") or string.find(rName, "coin") or string.find(rName, "fountain") or string.find(rName, "drop") or string.find(rName, "power") then
                    if not string.find(rName, "sell") and not string.find(rName, "upgrade") and not string.find(rName, "shop") and not string.find(rName, "buy") then
                        pcall(function() rem:FireServer() end)
                        pcall(function() rem:FireServer(100) end)
                        pcall(function() rem:FireServer(1) end)
                        pcall(function() rem:FireServer(true) end)
                        pcall(function() rem:FireServer("Throw", 100) end)
                        pcall(function() rem:FireServer("Throw") end)
                    end
                end
            elseif rem:IsA("RemoteFunction") then
                local rName = string.lower(rem.Name)
                if string.find(rName, "throw") or string.find(rName, "toss") or string.find(rName, "flip") or string.find(rName, "coin") or string.find(rName, "fountain") then
                    if not string.find(rName, "sell") and not string.find(rName, "upgrade") and not string.find(rName, "shop") and not string.find(rName, "buy") then
                        task.spawn(function()
                            pcall(function() rem:InvokeServer() end)
                            pcall(function() rem:InvokeServer(100) end)
                            pcall(function() rem:InvokeServer(1) end)
                            pcall(function() rem:InvokeServer(true) end)
                        end)
                    end
                end
            end
        end

        -- 5. Trigger Fountain ProximityPrompts & ClickDetectors
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local pName = string.lower(obj.Parent.Name)
                if string.find(pName, "fountain") or string.find(pName, "well") or string.find(pName, "coin") or string.find(pName, "wishing") or string.find(pName, "pit") or string.find(pName, "target") then
                    pcall(function()
                        obj.HoldDuration = 0
                        obj.MaxActivationDistance = 99999
                    end)
                    if fireproximityprompt then fireproximityprompt(obj) end
                end
            elseif obj:IsA("ClickDetector") then
                local pName = string.lower(obj.Parent.Name)
                if string.find(pName, "fountain") or string.find(pName, "well") or string.find(pName, "coin") or string.find(pName, "wishing") then
                    if fireclickdetector then fireclickdetector(obj) end
                end
            end
        end
    end)
end

-- Continuous Auto Throw Loop (Every 0.5s Fast Throw - No Manual Tapping Needed)
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoThrow then
            executeThrowCoin()
        end
    end
end)

-- =================================================================
-- 2. AUTO SELL ENGINE (Workspace Hitboxes, PlayerGui & Remotes)
-- =================================================================
local function executeSellCycle()
    pcall(function()
        local _, root = getPlayerChar()
        if not root then return end

        -- 1. Search & Touch All Sell Hitboxes
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsA("Terrain") then
                local nameL = string.lower(obj.Name)
                if string.find(nameL, "sell") or string.find(nameL, "shop") or string.find(nameL, "merchant") or string.find(nameL, "cashier") or string.find(nameL, "exchange") then
                    if firetouchinterest then
                        firetouchinterest(root, obj, 0)
                        task.wait(0.005)
                        firetouchinterest(root, obj, 1)
                    end
                end
            elseif obj:IsA("ProximityPrompt") then
                local pName = string.lower(obj.Parent.Name)
                if string.find(pName, "sell") or string.find(pName, "merchant") or string.find(pName, "shop") then
                    pcall(function()
                        obj.HoldDuration = 0
                        obj.MaxActivationDistance = 99999
                    end)
                    if fireproximityprompt then fireproximityprompt(obj) end
                end
            elseif obj:IsA("ClickDetector") then
                local pName = string.lower(obj.Parent.Name)
                if string.find(pName, "sell") or string.find(pName, "merchant") then
                    if fireclickdetector then fireclickdetector(obj) end
                end
            end
        end

        -- 2. Click Any In-Game Sell GUI Button
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, btn in ipairs(playerGui:GetDescendants()) do
                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                    local nameL = string.lower(btn.Name)
                    local textL = btn:IsA("TextButton") and string.lower(btn.Text) or ""
                    if string.find(nameL, "sell") or string.find(textL, "sell") or string.find(nameL, "cashout") then
                        triggerGuiButton(btn)
                    end
                end
            end
        end

        -- 3. Fire All Sell Remotes in ReplicatedStorage
        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
            local rName = string.lower(rem.Name)
            if string.find(rName, "sell") or string.find(rName, "cashout") or string.find(rName, "deposit") or string.find(rName, "exchange") or string.find(rName, "convert") then
                if rem:IsA("RemoteEvent") then
                    pcall(function() rem:FireServer() end)
                    pcall(function() rem:FireServer(true) end)
                    pcall(function() rem:FireServer("All") end)
                    pcall(function() rem:FireServer(1) end)
                elseif rem:IsA("RemoteFunction") then
                    pcall(function() rem:InvokeServer() end)
                    pcall(function() rem:InvokeServer(true) end)
                    pcall(function() rem:InvokeServer("All") end)
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.4)
        if Toggles.AutoSell then
            executeSellCycle()
        end
    end
end)

-- =================================================================
-- 3. AUTO UPGRADE LUCK & STATS ENGINE
-- =================================================================
local function executeUpgradeCycle()
    pcall(function()
        local _, root = getPlayerChar()

        -- 1. Touch Upgrade Pads
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsA("Terrain") then
                local nameL = string.lower(obj.Name)
                if string.find(nameL, "upgrade") or string.find(nameL, "luck") or string.find(nameL, "boost") then
                    if root and firetouchinterest then
                        firetouchinterest(root, obj, 0)
                        task.wait(0.005)
                        firetouchinterest(root, obj, 1)
                    end
                end
            elseif obj:IsA("ProximityPrompt") then
                local pName = string.lower(obj.Parent.Name)
                if string.find(pName, "upgrade") or string.find(pName, "luck") or string.find(pName, "buy") then
                    pcall(function()
                        obj.HoldDuration = 0
                        obj.MaxActivationDistance = 99999
                    end)
                    if fireproximityprompt then fireproximityprompt(obj) end
                end
            end
        end

        -- 2. Click In-Game Upgrade Buttons in PlayerGui
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, btn in ipairs(playerGui:GetDescendants()) do
                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                    local nameL = string.lower(btn.Name)
                    local textL = btn:IsA("TextButton") and string.lower(btn.Text) or ""
                    if string.find(nameL, "luck") or string.find(textL, "luck") or string.find(nameL, "upgrade") or string.find(textL, "upgrade") or string.find(nameL, "buy") then
                        triggerGuiButton(btn)
                    end
                end
            end
        end

        -- 3. Fire All Upgrade Remotes in ReplicatedStorage
        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
            local rName = string.lower(rem.Name)
            if string.find(rName, "luck") or string.find(rName, "upgrade") or string.find(rName, "buyupgrade") or string.find(rName, "stat") or string.find(rName, "multiplier") then
                if rem:IsA("RemoteEvent") then
                    pcall(function() rem:FireServer("Luck") end)
                    pcall(function() rem:FireServer("LuckUpgrade") end)
                    pcall(function() rem:FireServer("LuckMultiplier") end)
                    pcall(function() rem:FireServer("All") end)
                    pcall(function() rem:FireServer(1) end)
                    pcall(function() rem:FireServer() end)
                elseif rem:IsA("RemoteFunction") then
                    pcall(function() rem:InvokeServer("Luck") end)
                    pcall(function() rem:InvokeServer("LuckUpgrade") end)
                    pcall(function() rem:InvokeServer(1) end)
                    pcall(function() rem:InvokeServer() end)
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.8)
        if Toggles.AutoUpgradeLuck then
            executeUpgradeCycle()
        end
    end
end)

-- =================================================================
-- 4. PLAYER ENHANCEMENTS (WalkSpeed, JumpPower, InfJump, Fly)
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

-- Jump Power Enforcer
RunService.RenderStepped:Connect(function()
    pcall(function()
        local _, _, hum = getPlayerChar()
        if hum then
            if Toggles.JumpPowerBoost then
                hum.UseJumpPower = true
                hum.JumpPower = CustomJumpValue
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

-- Fly Engine
task.spawn(function()
    while true do
        task.wait(0.03)
        if Toggles.FlyMode then
            pcall(function()
                local _, hrp, hum = getPlayerChar()
                local camera = Workspace.CurrentCamera
                
                if hrp and hum and camera then
                    local bv = hrp:FindFirstChild("CoinFlyBV") or Instance.new("BodyVelocity")
                    bv.Name = "CoinFlyBV"
                    bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                    bv.Parent = hrp
                    
                    local bg = hrp:FindFirstChild("CoinFlyBG") or Instance.new("BodyGyro")
                    bg.Name = "CoinFlyBG"
                    bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
                    bg.P = 10000
                    bg.Parent = hrp
                    
                    hum.PlatformStand = true
                    bg.CFrame = camera.CFrame
                    
                    local speed = FlySpeedValue or 60
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        local flyVel = camera.CFrame.LookVector * speed
                        if math.abs(moveDir.Z) < 0.2 and math.abs(moveDir.X) > 0.5 then
                            flyVel = camera.CFrame.RightVector * speed * (moveDir.X > 0 and 1 or -1)
                        end
                        bv.Velocity = flyVel
                    else
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        else
            pcall(function()
                local _, hrp, hum = getPlayerChar()
                if hum and hum.PlatformStand then
                    hum.PlatformStand = false
                end
                if hrp then
                    if hrp:FindFirstChild("CoinFlyBV") then hrp.CoinFlyBV:Destroy() end
                    if hrp:FindFirstChild("CoinFlyBG") then hrp.CoinFlyBG:Destroy() end
                end
            end)
        end
    end
end)

-- Teleport Helpers
local function teleportToKeyword(keywords, yOffset)
    pcall(function()
        local _, root = getPlayerChar()
        if not root then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local nameL = string.lower(obj.Name)
                local matches = false
                for _, kw in ipairs(keywords) do
                    if string.find(nameL, kw) then
                        matches = true
                        break
                    end
                end
                if matches then
                    local part = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")) or obj
                    if part and part:IsA("BasePart") and not part:IsA("Terrain") then
                        root.CFrame = part.CFrame + Vector3.new(0, yOffset or 5, 0)
                        return
                    end
                end
            end
        end
    end)
end

-- =================================================================
-- OFFICIAL JUNEJO STANDARD UI GENERATOR (FLAT & BORDERLESS)
-- =================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHub_ThrowACoin"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

-- Dynamic Compact Window Height
local MainWindowHeight = 300

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, MainWindowHeight)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -math.floor(MainWindowHeight / 2))
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
    Toggles.AutoThrow = false
    Toggles.AutoSell = false
    Toggles.AutoUpgradeLuck = false
    Toggles.WalkSpeedBoost = false
    Toggles.JumpPowerBoost = false
    Toggles.InfiniteJump = false
    Toggles.FlyMode = false
    pcall(function()
        local _, hrp, hum = getPlayerChar()
        if hum then hum.PlatformStand = false end
        if hrp then
            if hrp:FindFirstChild("CoinFlyBV") then hrp.CoinFlyBV:Destroy() end
            if hrp:FindFirstChild("CoinFlyBG") then hrp.CoinFlyBG:Destroy() end
        end
    end)
    ScreenGui:Destroy()
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 0, 220)
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
local function AddActionRow(text, buttonText, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -75, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(0, 70, 1, -2)
    ActionBtn.Position = UDim2.new(1, -70, 0, 1)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ActionBtn.Text = buttonText
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
        TweenService:Create(ActionBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
        task.delay(0.12, function()
            TweenService:Create(ActionBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(27, 27, 32)}):Play()
        end)
        if callback then callback() end
    end)
end

-- =================================================================
-- BUILD FEATURE ROWS
-- =================================================================

-- 1. Auto Throw Coin (Auto Side Bar Clicker & 0.5s Fast Throw)
AddToggleRow("Auto Throw Coin", "AutoThrow")

-- 2. Auto Sell Items
AddToggleRow("Auto Sell Items", "AutoSell")

-- 3. Auto Upgrade Luck
AddToggleRow("Auto Upgrade Luck", "AutoUpgradeLuck")

-- 4. Teleport to Fountain
AddActionRow("Teleport Fountain", "Teleport", function()
    teleportToKeyword({"fountain", "well", "wishing", "pit", "pool", "target"}, 5)
end)

-- 5. Teleport to Sell Area
AddActionRow("Teleport Sell Area", "Teleport", function()
    teleportToKeyword({"sell", "shop", "merchant", "cashier", "exchange"}, 5)
end)

-- 6. WalkSpeed with Integrated - / + Pill Controller
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
    CustomSpeedValue = math.min(300, CustomSpeedValue + 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
end)

-- 7. Jump Power Boost with Integrated - / + Pill Controller
local JumpRow = Instance.new("Frame")
JumpRow.Size = UDim2.new(1, 0, 0, 23)
JumpRow.BackgroundTransparency = 1
JumpRow.Parent = ContentFrame

local JumpToggleBtn = Instance.new("TextButton")
JumpToggleBtn.Size = UDim2.new(0.55, 0, 1, 0)
JumpToggleBtn.BackgroundTransparency = 1
JumpToggleBtn.Text = ""
JumpToggleBtn.ZIndex = 5
JumpToggleBtn.Parent = JumpRow

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Size = UDim2.new(1, -26, 1, 0)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "Jump Power"
JumpLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
JumpLabel.TextSize = 12
JumpLabel.Font = Enum.Font.GothamBold
JumpLabel.TextXAlignment = Enum.TextXAlignment.Left
JumpLabel.Parent = JumpToggleBtn

local JumpCheckBox = Instance.new("Frame")
JumpCheckBox.Size = UDim2.new(0, 18, 0, 18)
JumpCheckBox.Position = UDim2.new(1, -18, 0.5, -9)
JumpCheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
JumpCheckBox.BorderSizePixel = 0
JumpCheckBox.Parent = JumpToggleBtn

local JumpCheckCorner = Instance.new("UICorner")
JumpCheckCorner.CornerRadius = UDim.new(0, 4)
JumpCheckCorner.Parent = JumpCheckBox

local JumpCheckStroke = Instance.new("UIStroke")
JumpCheckStroke.Color = Color3.fromRGB(45, 45, 55)
JumpCheckStroke.Thickness = 1.2
JumpCheckStroke.Parent = JumpCheckBox

local JumpCheckMark = Instance.new("Frame")
JumpCheckMark.Size = UDim2.new(0, 10, 0, 10)
JumpCheckMark.Position = UDim2.new(0.5, -5, 0.5, -5)
JumpCheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
JumpCheckMark.BackgroundTransparency = Toggles.JumpPowerBoost and 0 or 1
JumpCheckMark.BorderSizePixel = 0
JumpCheckMark.Parent = JumpCheckBox

local MarkCornerJump = Instance.new("UICorner")
MarkCornerJump.CornerRadius = UDim.new(0, 2)
MarkCornerJump.Parent = JumpCheckMark

JumpToggleBtn.MouseButton1Click:Connect(function()
    Toggles.JumpPowerBoost = not Toggles.JumpPowerBoost
    JumpCheckMark.BackgroundTransparency = Toggles.JumpPowerBoost and 0 or 1
    if not Toggles.JumpPowerBoost then
        local _, _, hum = getPlayerChar()
        if hum then hum.JumpPower = 50 end
    end
end)

local JumpControlFrame = Instance.new("Frame")
JumpControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
JumpControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
JumpControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
JumpControlFrame.BorderSizePixel = 0
JumpControlFrame.Parent = JumpRow

local JumpCtrlCorner = Instance.new("UICorner")
JumpCtrlCorner.CornerRadius = UDim.new(0, 4)
JumpCtrlCorner.Parent = JumpControlFrame

local JumpCtrlStroke = Instance.new("UIStroke")
JumpCtrlStroke.Color = Color3.fromRGB(45, 45, 55)
JumpCtrlStroke.Thickness = 1
JumpCtrlStroke.Parent = JumpControlFrame

local JumpMinusBtn = Instance.new("TextButton")
JumpMinusBtn.Size = UDim2.new(0, 22, 1, 0)
JumpMinusBtn.Position = UDim2.new(0, 0, 0, 0)
JumpMinusBtn.BackgroundTransparency = 1
JumpMinusBtn.Text = "-"
JumpMinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
JumpMinusBtn.TextSize = 14
JumpMinusBtn.Font = Enum.Font.GothamBold
JumpMinusBtn.Parent = JumpControlFrame

local JumpDisplay = Instance.new("TextLabel")
JumpDisplay.Size = UDim2.new(1, -44, 1, 0)
JumpDisplay.Position = UDim2.new(0, 22, 0, 0)
JumpDisplay.BackgroundTransparency = 1
JumpDisplay.Text = tostring(CustomJumpValue)
JumpDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpDisplay.TextSize = 11
JumpDisplay.Font = Enum.Font.GothamBold
JumpDisplay.Parent = JumpControlFrame

local JumpPlusBtn = Instance.new("TextButton")
JumpPlusBtn.Size = UDim2.new(0, 22, 1, 0)
JumpPlusBtn.Position = UDim2.new(1, -22, 0, 0)
JumpPlusBtn.BackgroundTransparency = 1
JumpPlusBtn.Text = "+"
JumpPlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
JumpPlusBtn.TextSize = 14
JumpPlusBtn.Font = Enum.Font.GothamBold
JumpPlusBtn.Parent = JumpControlFrame

JumpMinusBtn.MouseButton1Click:Connect(function()
    CustomJumpValue = math.max(50, CustomJumpValue - 25)
    JumpDisplay.Text = tostring(CustomJumpValue)
end)

JumpPlusBtn.MouseButton1Click:Connect(function()
    CustomJumpValue = math.min(300, CustomJumpValue + 25)
    JumpDisplay.Text = tostring(CustomJumpValue)
end)

-- 8. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump")

-- 9. Fly Mode
AddToggleRow("Fly Mode", "FlyMode")

-- 10. Anti-AFK Engine
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

print("[Junejo Script Hub]: Throw a Coin Script (V3.0 Auto Bar Clicker) Loaded Successfully!")
