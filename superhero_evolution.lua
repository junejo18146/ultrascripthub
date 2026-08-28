--[[
    JUNEJO ULTRA SCRIPT HUB - +1 SUPERHERO EVOLUTION
    Target Game: +1 Superhero Evolution (Roblox)
    Game Link: https://www.roblox.com/games/97824450589417/1-Superhero-Evolution
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11) - Flat Borderless Rows Standard
    Status: Complete Standalone Executable
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local VirtualInputManager
pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Safe UI Parent getter (Delta, Arceus X, Fluxus, PC/Mobile compatible)
local function GetUIContainer()
    local success, res = pcall(function()
        if gethui then return gethui() end
        if syn and syn.protect_gui then return CoreGui end
        return CoreGui
    end)
    if success and res then return res end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local UIContainer = GetUIContainer()

-- Cleanup previous UI instances
for _, name in ipairs({"JunejoSuperheroEvolutionUI", "JunejoHeroEvolutionUI", "JunejoHubUI"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

-- 8 Core Feature Toggles
local Toggles = {
    AutoTrain = false,
    PowerFarm = false,
    AutoRebirth = false,
    AutoWins = false,
    AutoFightBoss = false,
    Fly = false,
    WalkSpeed = false,
    InfiniteJump = false
}

--------------------------------------------------------------------
-- ANTI-AFK SYSTEM (Prevents 20-minute idle disconnect)
--------------------------------------------------------------------
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

--------------------------------------------------------------------
-- 1. INFINITE JUMP ENGINE
--------------------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        pcall(function()
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and Toggles.InfiniteJump and input.KeyCode == Enum.KeyCode.Space then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
            end
        end)
    end
end)

--------------------------------------------------------------------
-- 2. WALKSPEED BOOST ENGINE (50 Speed)
--------------------------------------------------------------------
local function UpdateCharacterSpeed()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Toggles.WalkSpeed then
                hum.WalkSpeed = 50
            else
                hum.WalkSpeed = 16
            end
        end
    end)
end

local function BindSpeedListener(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Toggles.WalkSpeed and hum.WalkSpeed ~= 50 then
                hum.WalkSpeed = 50
            end
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    BindSpeedListener(newChar)
    if Toggles.WalkSpeed then
        UpdateCharacterSpeed()
    end
end)

if LocalPlayer.Character then
    BindSpeedListener(LocalPlayer.Character)
end

--------------------------------------------------------------------
-- 3. SMOOTH 3D FLY MODE (WASD + Mobile Controls)
--------------------------------------------------------------------
local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local FlyConnection = nil
local FlySpeed = 60

local function StartFlying()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end

        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.Name = "JunejoFlyVelocity"
        FlyBodyVelocity.Velocity = Vector3.zero
        FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyVelocity.Parent = hrp

        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.Name = "JunejoFlyGyro"
        FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyGyro.P = 10000
        FlyBodyGyro.D = 100
        FlyBodyGyro.CFrame = hrp.CFrame
        FlyBodyGyro.Parent = hrp

        hum.PlatformStand = true

        FlyConnection = RunService.RenderStepped:Connect(function()
            if not Toggles.Fly or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                return
            end

            local cam = Workspace.CurrentCamera
            local root = LocalPlayer.Character.HumanoidRootPart
            local moveDir = Vector3.zero

            -- Keyboard input
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end

            -- Mobile touch / thumbstick support
            if moveDir.Magnitude == 0 and hum.MoveDirection.Magnitude > 0 then
                local camLook = cam.CFrame.LookVector
                local camRight = cam.CFrame.RightVector
                local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
                local flatRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
                
                moveDir = (flatLook * hum.MoveDirection.Z * -1) + (flatRight * hum.MoveDirection.X)
            end

            if moveDir.Magnitude > 0 then
                FlyBodyVelocity.Velocity = moveDir.Unit * FlySpeed
            else
                FlyBodyVelocity.Velocity = Vector3.zero
            end

            FlyBodyGyro.CFrame = cam.CFrame
        end)
    end)
end

local function StopFlying()
    pcall(function()
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
        if FlyBodyVelocity then
            FlyBodyVelocity:Destroy()
            FlyBodyVelocity = nil
        end
        if FlyBodyGyro then
            FlyBodyGyro:Destroy()
            FlyBodyGyro = nil
        end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end)
end

--------------------------------------------------------------------
-- 4. AUTO TRAIN ENGINE (Hyper Power Gain / Tool Auto-Equip / Remotes)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        if Toggles.AutoTrain then
            pcall(function()
                local char = LocalPlayer.Character
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                
                -- Auto-Equip training tools/punches/weights
                if backpack then
                    for _, item in ipairs(backpack:GetChildren()) do
                        if item:IsA("Tool") then
                            item.Parent = char
                        end
                    end
                end

                -- Auto-Activate all equipped tools
                if char then
                    for _, item in ipairs(char:GetChildren()) do
                        if item:IsA("Tool") then
                            item:Activate()
                        end
                    end
                end

                -- Virtual Tap / Click emulation
                if VirtualUser then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(500, 500))
                end

                if VirtualInputManager then
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 0)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 0)
                end

                -- Remote scanner & firer for Training / Power events
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") then
                        local nameLower = obj.Name:lower()
                        if nameLower:find("train") or nameLower:find("punch") or nameLower:find("workout") or 
                           nameLower:find("power") or nameLower:find("click") or nameLower:find("tap") or 
                           nameLower:find("swing") or nameLower:find("gain") then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer("Train")
                                obj:FireServer(1)
                                obj:FireServer(true)
                            end)
                        end
                    elseif obj:IsA("RemoteFunction") then
                        local nameLower = obj.Name:lower()
                        if nameLower:find("train") or nameLower:find("punch") or nameLower:find("power") then
                            pcall(function()
                                obj:InvokeServer()
                            end)
                        end
                    end
                end
            end)
        end
        task.wait(0.05)
    end
end)

--------------------------------------------------------------------
-- 5. +1 POWER FARM ENGINE (ProximityPrompts & Station Sweeper)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        if Toggles.PowerFarm then
            pcall(function()
                -- Sweep proximity prompts for workout equipment / dumbbells
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local promptName = prompt.Name:lower() .. (prompt.ObjectText or ""):lower() .. (prompt.ActionText or ""):lower()
                        if promptName:find("train") or promptName:find("power") or promptName:find("punch") or 
                           promptName:find("lift") or promptName:find("workout") or promptName:find("dumbbell") or 
                           promptName:find("click") or promptName:find("collect") then
                            if fireproximityprompt then
                                fireproximityprompt(prompt, 0)
                            end
                        end
                    end
                end

                -- Direct Power Events Pulse
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") then
                        local nameLower = obj.Name:lower()
                        if nameLower:find("addpower") or nameLower:find("givepower") or nameLower:find("gainpower") or 
                           nameLower:find("heropower") or nameLower:find("stat") or nameLower:find("multiplier") then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer("+1")
                                obj:FireServer(1)
                            end)
                        end
                    end
                end
            end)
        end
        task.wait(0.04)
    end
end)

--------------------------------------------------------------------
-- 6. AUTO REBIRTH / EVOLUTION ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        if Toggles.AutoRebirth then
            pcall(function()
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") then
                        local nameLower = obj.Name:lower()
                        if nameLower:find("rebirth") or nameLower:find("prestige") or nameLower:find("evolve") or 
                           nameLower:find("evolution") or nameLower:find("ascend") or nameLower:find("dorebirth") or 
                           nameLower:find("buyrebirth") or nameLower:find("herorebirth") then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer(1)
                                obj:FireServer(true)
                            end)
                        end
                    elseif obj:IsA("RemoteFunction") then
                        local nameLower = obj.Name:lower()
                        if nameLower:find("rebirth") or nameLower:find("evolve") or nameLower:find("evolution") then
                            pcall(function()
                                obj:InvokeServer()
                            end)
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

--------------------------------------------------------------------
-- 7. AUTO WINS ENGINE (Runway, Win Gates & Remote Sweeper)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        if Toggles.AutoWins then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                -- Win Remote Events Sweeper
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") then
                        local nameLower = obj.Name:lower()
                        if nameLower:find("win") or nameLower:find("claimwin") or nameLower:find("givewin") or 
                           nameLower:find("passgate") or nameLower:find("wingate") or nameLower:find("stagewin") or 
                           nameLower:find("finish") or nameLower:find("reward") then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer(1)
                                obj:FireServer(true)
                            end)
                        end
                    end
                end

                -- Scan for Win Pads, Gates, Finish Lines & Touch Interest
                if hrp then
                    for _, part in ipairs(Workspace:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local partName = part.Name:lower()
                            if (partName:find("win") or partName:find("finish") or partName:find("gate") or 
                                partName:find("portal") or partName:find("trophy") or partName:find("checkpoint")) and 
                               not part:IsDescendantOf(char) then
                                pcall(function()
                                    if firetouchinterest then
                                        firetouchinterest(hrp, part, 0)
                                        task.wait(0.01)
                                        firetouchinterest(hrp, part, 1)
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.2)
    end
end)

--------------------------------------------------------------------
-- 8. AUTO FIGHT BOSS / ENEMIES ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        if Toggles.AutoFightBoss then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                -- Auto equip weapons for boss fight
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            tool.Parent = char
                        end
                    end
                end

                -- Hitbox Expansion & Damage Remote trigger
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") then
                        local nameLower = obj.Name:lower()
                        if nameLower:find("attack") or nameLower:find("damage") or nameLower:find("hit") or 
                           nameLower:find("fight") or nameLower:find("slash") or nameLower:find("punchboss") or 
                           nameLower:find("attackboss") or nameLower:find("damageboss") then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer("Boss")
                                obj:FireServer(1)
                                obj:FireServer(true)
                            end)
                        end
                    end
                end

                -- Scan for Enemy / Boss Models
                if hrp then
                    local targetEnemy = nil
                    local shortestDistance = 150

                    for _, enemy in ipairs(Workspace:GetDescendants()) do
                        if enemy:IsA("Model") and enemy ~= char and enemy:FindFirstChildOfClass("Humanoid") then
                            local enemyHum = enemy:FindFirstChildOfClass("Humanoid")
                            local enemyHrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
                            
                            if enemyHum and enemyHum.Health > 0 and enemyHrp and not Players:GetPlayerFromCharacter(enemy) then
                                local dist = (enemyHrp.Position - hrp.Position).Magnitude
                                if dist < shortestDistance then
                                    shortestDistance = dist
                                    targetEnemy = enemy
                                end
                            end
                        end
                    end

                    if targetEnemy then
                        local enemyHrp = targetEnemy:FindFirstChild("HumanoidRootPart") or targetEnemy:FindFirstChild("Torso")
                        if enemyHrp and char then
                            -- Swing tools
                            for _, tool in ipairs(char:GetChildren()) do
                                if tool:IsA("Tool") then
                                    tool:Activate()
                                    local handle = tool:FindFirstChild("Handle")
                                    if handle and handle:IsA("BasePart") then
                                        handle.Size = Vector3.new(20, 20, 20)
                                        handle.CanCollide = false
                                        if firetouchinterest then
                                            firetouchinterest(handle, enemyHrp, 0)
                                            task.wait(0.01)
                                            firetouchinterest(handle, enemyHrp, 1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.08)
    end
end)

--------------------------------------------------------------------
-- GUI CREATION (JUNEJO ULTRA SCRIPT HUB - EXACT CLASSIC DARK SPEC)
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoSuperheroEvolutionUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = UIContainer

-- Main Container Frame (Fixed Compact Standard 280px, Height: 300px for 8 rows)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 300)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Draggable implementation
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

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
        updateInput(input)
    end
end)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Header Frame (Height: 34px)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "SUPERHERO EVOLUTION"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 34, 0, 34)
CloseButton.Position = UDim2.new(1, -34, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 170)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Content Frame (Height: 220px for 8 rows with 4px gap)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -28, 0, 220)
ContentFrame.Position = UDim2.new(0, 14, 0, 36)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper function to generate clean, borderless toggle rows
local function AddToggleRow(text, configKey, onToggleCallback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 24)
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
        if onToggleCallback then
            onToggleCallback(Toggles[configKey])
        end
    end)
end

-- Generate 8 Toggle Rows
AddToggleRow("Auto Train", "AutoTrain")
AddToggleRow("+1 Power Farm", "PowerFarm")
AddToggleRow("Auto Rebirth", "AutoRebirth")
AddToggleRow("Auto Wins", "AutoWins")
AddToggleRow("Auto Fight Boss", "AutoFightBoss")
AddToggleRow("Fly Mode", "Fly", function(enabled)
    if enabled then
        StartFlying()
    else
        StopFlying()
    end
end)
AddToggleRow("WalkSpeed Boost (50)", "WalkSpeed", function(enabled)
    UpdateCharacterSpeed()
end)
AddToggleRow("Infinite Jump", "InfiniteJump")

-- Footer Frame (Pinned at bottom, Height: 44px)
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 44)
Footer.Position = UDim2.new(0, 0, 1, -44)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 16)
FooterTitle.Position = UDim2.new(0, 0, 0, 5)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 13
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 14)
FooterSub.Position = UDim2.new(0, 0, 0, 21)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 11
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.Parent = Footer
