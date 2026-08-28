--[[
    JUNEJO ULTRA SCRIPT HUB - GROW A CHICKEN FIGHTER
    Target Game: Grow a Chicken Fighter (Roblox)
    Game Link: https://www.roblox.com/games/94640181989498/Grow-a-Chicken-Fighter
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
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local VirtualInputManager
pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

-- 8 Core Feature Toggles
local Toggles = {
    AutoPitFarm = false,
    AutoCollectCash = false,
    AutoRebirth = false,
    AutoHatchEggs = false,
    AutoTowerFight = false,
    Fly = false,
    WalkSpeed = false,
    InfiniteJump = false
}

-- Safe UI Parent resolver (Delta Mobile, Arceus X, Fluxus, Codex, PC)
local function GetSafeUIContainer()
    local container = nil
    
    pcall(function()
        if gethui then
            container = gethui()
        end
    end)
    
    if not container then
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
            if playerGui then
                container = playerGui
            end
        end)
    end
    
    if not container then
        pcall(function()
            if syn and syn.protect_gui then
                container = CoreGui
            end
        end)
    end
    
    if not container then
        pcall(function()
            container = CoreGui
        end)
    end
    
    return container or LocalPlayer:WaitForChild("PlayerGui")
end

local UIContainer = GetSafeUIContainer()

-- Cleanup previous UI instances safely
pcall(function()
    local names = {"JunejoGrowChickenFighterUI", "JunejoChickenFighterUI", "JunejoHubUI"}
    for _, name in ipairs(names) do
        pcall(function()
            if CoreGui and CoreGui:FindFirstChild(name) then
                CoreGui[name]:Destroy()
            end
        end)
        pcall(function()
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
                LocalPlayer.PlayerGui[name]:Destroy()
            end
        end)
        pcall(function()
            if gethui and gethui():FindFirstChild(name) then
                gethui()[name]:Destroy()
            end
        end)
    end
end)

--------------------------------------------------------------------
-- HELPER: UNIVERSAL GUI CLICK SIMULATOR
--------------------------------------------------------------------
local function ClickGuiButton(btn)
    if not btn then return end
    pcall(function()
        if firesignal then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.MouseButton1Down)
            firesignal(btn.MouseButton1Up)
            firesignal(btn.Activated)
        end
    end)
    pcall(function()
        if getconnections then
            for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                conn:Fire()
            end
            for _, conn in pairs(getconnections(btn.MouseButton1Down)) do
                conn:Fire()
            end
            for _, conn in pairs(getconnections(btn.Activated)) do
                conn:Fire()
            end
        end
    end)
    pcall(function()
        if VirtualInputManager and btn.AbsolutePosition and btn.AbsoluteSize then
            local center = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
        end
    end)
end

--------------------------------------------------------------------
-- GUI CREATION (IMMEDIATE CREATION - JUNEJO CLASSIC DARK SPEC)
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoGrowChickenFighterUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true

-- Main Container Frame (Fixed Compact Standard 280px, Height: 305px for 8 rows)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 305)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -152)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Corner & Border Stroke
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
Header.Active = true
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "GROW A CHICKEN FIGHTER"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
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

-- Draggable implementation attached to Header (Prevents click-swallowing on Mobile)
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
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Content Frame (Height: 224px for 8 rows)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -28, 0, 224)
ContentFrame.Position = UDim2.new(0, 14, 0, 36)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Forward function declarations
local StartFlying, StopFlying, UpdateCharacterSpeed

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
            pcall(function()
                onToggleCallback(Toggles[configKey])
            end)
        end
    end)
end

-- Generate 8 Requested Toggle Rows
AddToggleRow("Auto Attack / Pit Farm", "AutoPitFarm")
AddToggleRow("Auto Collect Cash & Drops", "AutoCollectCash")
AddToggleRow("Auto Rebirth / Ascend", "AutoRebirth")
AddToggleRow("Auto Hatch Eggs", "AutoHatchEggs")
AddToggleRow("Auto Tower Fight", "AutoTowerFight")
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

-- Safely Mount ScreenGui
local mounted = false
pcall(function()
    ScreenGui.Parent = UIContainer
    mounted = true
end)

if not mounted or not ScreenGui.Parent then
    pcall(function()
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        mounted = true
    end)
end

-- Success Notification Pop-up
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "ULTRA SCRIPT HUB",
        Text = "Grow a Chicken Fighter Loaded!",
        Duration = 4
    })
end)

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
UpdateCharacterSpeed = function()
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
    task.spawn(function()
        local hum = char:WaitForChild("Humanoid", 3)
        if hum then
            hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if Toggles.WalkSpeed and hum.WalkSpeed ~= 50 then
                    hum.WalkSpeed = 50
                end
            end)
        end
    end)
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

StartFlying = function()
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

StopFlying = function()
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
-- 4. AUTO ATTACK / PIT FARM ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.06)
        if Toggles.AutoPitFarm then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local backpack = LocalPlayer:FindFirstChild("Backpack")

                -- Auto-Equip swords, gloves, or chicken combat tools
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

                -- Direct Attack & Pit Combat Remote Events Sweeper
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoPitFarm then break end
                    local nameLower = obj.Name:lower()
                    if nameLower:find("attack") or nameLower:find("hit") or nameLower:find("punch") or 
                       nameLower:find("damage") or nameLower:find("pit") or nameLower:find("combat") or 
                       nameLower:find("fight") or nameLower:find("requestmeleehitbox") or nameLower:find("swing") or 
                       nameLower:find("tap") or nameLower:find("click") or nameLower:find("target") then
                        if obj:IsA("RemoteEvent") then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer(1)
                                obj:FireServer(true)
                                obj:FireServer("Attack")
                                obj:FireServer("Pit")
                                obj:FireServer(hrp and hrp.Position or Vector3.zero)
                            end)
                        elseif obj:IsA("RemoteFunction") then
                            pcall(function()
                                obj:InvokeServer()
                                obj:InvokeServer(1)
                                obj:InvokeServer("Attack")
                            end)
                        end
                    end
                end

                -- Expanded Pit Target / Enemy Hitbox
                if hrp then
                    for _, enemy in ipairs(Workspace:GetDescendants()) do
                        if enemy:IsA("Model") and enemy ~= char and enemy:FindFirstChildOfClass("Humanoid") then
                            local eHum = enemy:FindFirstChildOfClass("Humanoid")
                            local eHrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso") or enemy:FindFirstChild("Head")
                            if eHum and eHum.Health > 0 and eHrp and not Players:GetPlayerFromCharacter(enemy) then
                                local dist = (eHrp.Position - hrp.Position).Magnitude
                                if dist < 120 then
                                    if char then
                                        for _, tool in ipairs(char:GetChildren()) do
                                            if tool:IsA("Tool") then
                                                tool:Activate()
                                                local handle = tool:FindFirstChild("Handle")
                                                if handle and handle:IsA("BasePart") then
                                                    handle.Size = Vector3.new(20, 20, 20)
                                                    handle.CanCollide = false
                                                    if firetouchinterest then
                                                        firetouchinterest(handle, eHrp, 0)
                                                        task.wait(0.01)
                                                        firetouchinterest(handle, eHrp, 1)
                                                    end
                                                end
                                            end
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

--------------------------------------------------------------------
-- 5. AUTO COLLECT CASH & DROPS ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.15)
        if Toggles.AutoCollectCash then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                -- Layer 1: Touch & Sweep Physical Cash, Drops, Scrap, Corn & Coins
                if hrp and firetouchinterest then
                    for _, drop in ipairs(Workspace:GetDescendants()) do
                        if not Toggles.AutoCollectCash then break end
                        if drop:IsA("BasePart") and not drop:IsDescendantOf(char) then
                            local dName = drop.Name:lower()
                            local pName = drop.Parent and drop.Parent.Name:lower() or ""
                            if dName:find("coin") or dName:find("cash") or dName:find("drop") or 
                               dName:find("money") or dName:find("scrap") or dName:find("corn") or 
                               dName:find("gem") or dName:find("token") or dName:find("reward") or 
                               pName:find("drop") or pName:find("coin") or pName:find("scrap") or pName:find("cash") then
                                pcall(function()
                                    firetouchinterest(hrp, drop, 0)
                                    task.wait(0.01)
                                    firetouchinterest(hrp, drop, 1)
                                end)
                            end
                        end
                    end
                end

                -- Layer 2: All Cash & Scrap Collect Remotes
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoCollectCash then break end
                    local nameLower = obj.Name:lower()
                    if nameLower:find("collect") or nameLower:find("claimcash") or nameLower:find("collectcash") or 
                       nameLower:find("getcash") or nameLower:find("claimdrop") or nameLower:find("collectdrop") or 
                       nameLower:find("pickup") or nameLower:find("claimreward") or nameLower:find("collectscrap") then
                        if obj:IsA("RemoteEvent") then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer(1)
                                obj:FireServer(true)
                                obj:FireServer("All")
                            end)
                        elseif obj:IsA("RemoteFunction") then
                            pcall(function()
                                obj:InvokeServer()
                                obj:InvokeServer(1)
                            end)
                        end
                    end
                end

                -- Layer 3: ProximityPrompts for Feeders, Recyclers & Cash Desks
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local promptName = prompt.Name:lower() .. (prompt.ObjectText or ""):lower() .. (prompt.ActionText or ""):lower()
                        if promptName:find("collect") or promptName:find("cash") or promptName:find("claim") or 
                           promptName:find("scrap") or promptName:find("corn") or promptName:find("take") then
                            if fireproximityprompt then
                                fireproximityprompt(prompt, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 6. AUTO REBIRTH / ASCEND ENGINE (Multi-Layer)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.4)
        if Toggles.AutoRebirth then
            pcall(function()
                -- Layer 1: In-Game Rebirth / Ascend GUI Auto-Clicker
                if LocalPlayer:FindFirstChild("PlayerGui") then
                    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.Name ~= "JunejoGrowChickenFighterUI" then
                            for _, btn in ipairs(gui:GetDescendants()) do
                                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                                    local bName = btn.Name:lower()
                                    local bText = (btn:IsA("TextButton") and btn.Text or ""):lower()
                                    local parentName = btn.Parent and btn.Parent.Name:lower() or ""

                                    if bName:find("rebirth") or bName:find("ascend") or bName:find("ascension") or 
                                       bName:find("prestige") or bName:find("evolve") or bText:find("rebirth") or 
                                       bText:find("ascend") or bText:find("confirm") or bText:find("yes") or 
                                       parentName:find("rebirth") or parentName:find("ascend") then
                                        ClickGuiButton(btn)
                                    end
                                end
                            end
                        end
                    end
                end

                -- Layer 2: All ReplicatedStorage Rebirth & Ascend Remotes
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoRebirth then break end
                    local nameLower = obj.Name:lower()
                    if nameLower:find("rebirth") or nameLower:find("ascend") or nameLower:find("ascension") or 
                       nameLower:find("prestige") or nameLower:find("evolve") or nameLower:find("dorebirth") or 
                       nameLower:find("buyrebirth") or nameLower:find("buyascend") then
                        if obj:IsA("RemoteEvent") then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer(1)
                                obj:FireServer(true)
                                obj:FireServer("Rebirth")
                                obj:FireServer("Ascend")
                                obj:FireServer(1, true)
                            end)
                        elseif obj:IsA("RemoteFunction") then
                            pcall(function()
                                obj:InvokeServer()
                                obj:InvokeServer(1)
                                obj:InvokeServer(true)
                                obj:InvokeServer("Rebirth")
                            end)
                        end
                    end
                end

                -- Layer 3: Physical Rebirth / Ascend Altars & ProximityPrompts
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local promptName = prompt.Name:lower() .. (prompt.ObjectText or ""):lower() .. (prompt.ActionText or ""):lower()
                        if promptName:find("rebirth") or promptName:find("ascend") or promptName:find("prestige") then
                            if fireproximityprompt then
                                fireproximityprompt(prompt, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 7. AUTO HATCH EGGS ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoHatchEggs then
            pcall(function()
                -- Layer 1: Egg Hatch Remote Sweeper
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoHatchEggs then break end
                    local nameLower = obj.Name:lower()
                    if nameLower:find("hatch") or nameLower:find("buyegg") or nameLower:find("openegg") or 
                       nameLower:find("purchaseegg") or nameLower:find("egghatch") or nameLower:find("eggopen") then
                        if obj:IsA("RemoteEvent") then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer("Basic Egg")
                                obj:FireServer("Egg")
                                obj:FireServer(1)
                                obj:FireServer(1, false)
                                obj:FireServer(true)
                            end)
                        elseif obj:IsA("RemoteFunction") then
                            pcall(function()
                                obj:InvokeServer()
                                obj:InvokeServer("Basic Egg")
                                obj:InvokeServer(1)
                            end)
                        end
                    end
                end

                -- Layer 2: Workspace Egg Stands / ProximityPrompts
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local promptName = prompt.Name:lower() .. (prompt.ObjectText or ""):lower() .. (prompt.ActionText or ""):lower()
                        if promptName:find("hatch") or promptName:find("egg") or promptName:find("open") or promptName:find("buy") then
                            if fireproximityprompt then
                                fireproximityprompt(prompt, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 8. AUTO TOWER FIGHT ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.25)
        if Toggles.AutoTowerFight then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                -- Layer 1: Tower Combat & Stage Remotes
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoTowerFight then break end
                    local nameLower = obj.Name:lower()
                    if nameLower:find("tower") or nameLower:find("starttower") or nameLower:find("entertower") or 
                       nameLower:find("towerfight") or nameLower:find("towerstage") or nameLower:find("nextfloor") or 
                       nameLower:find("claimtower") or nameLower:find("towerreward") then
                        if obj:IsA("RemoteEvent") then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer(1)
                                obj:FireServer(true)
                                obj:FireServer("Start")
                                obj:FireServer("Next")
                            end)
                        elseif obj:IsA("RemoteFunction") then
                            pcall(function()
                                obj:InvokeServer()
                                obj:InvokeServer(1)
                                obj:InvokeServer("Start")
                            end)
                        end
                    end
                end

                -- Layer 2: Tower Portals, Gates & Enemies
                if hrp and firetouchinterest then
                    for _, part in ipairs(Workspace:GetDescendants()) do
                        if part:IsA("BasePart") and not part:IsDescendantOf(char) then
                            local pName = part.Name:lower()
                            local parentName = part.Parent and part.Parent.Name:lower() or ""
                            if pName:find("tower") or pName:find("elevator") or pName:find("floor") or 
                               parentName:find("tower") or parentName:find("floor") then
                                pcall(function()
                                    firetouchinterest(hrp, part, 0)
                                    task.wait(0.01)
                                    firetouchinterest(hrp, part, 1)
                                end)
                            end
                        end
                    end
                end

                -- Layer 3: Tower ProximityPrompts
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local promptName = prompt.Name:lower() .. (prompt.ObjectText or ""):lower() .. (prompt.ActionText or ""):lower()
                        if promptName:find("tower") or promptName:find("floor") or promptName:find("enter") or promptName:find("start") then
                            if fireproximityprompt then
                                fireproximityprompt(prompt, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
end)
