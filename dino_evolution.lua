--[[
    JUNEJO ULTRA SCRIPT HUB - +1 DINO EVOLUTION
    Target Game: +1 Dino Evolution (Roblox)
    Game Link: https://www.roblox.com/games/103138601755519/1-Dino-Evolution
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
    AutoRebirth = false,
    AutoClick = false,
    AutoFight = false,
    InfiniteWins = false,
    AutoHatchEggs = false,
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
    local names = {"JunejoDinoEvolutionUI", "JunejoDinoUI", "JunejoHubUI"}
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
ScreenGui.Name = "JunejoDinoEvolutionUI"
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
TitleLabel.Text = "+1 DINO EVOLUTION"
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

-- Generate 8 User-Specified Toggle Rows
AddToggleRow("Auto Rebirth", "AutoRebirth")
AddToggleRow("Auto Click (+1 Power)", "AutoClick")
AddToggleRow("Auto Fight Dinos", "AutoFight")
AddToggleRow("Infinite Wins", "InfiniteWins")
AddToggleRow("Auto Hatch Eggs", "AutoHatchEggs")
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
        Text = "+1 Dino Evolution Loaded!",
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
-- 4. AUTO CLICK / TRAIN ENGINE (+1 Strength / Power Fast Pulse)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.04)
        if Toggles.AutoClick then
            pcall(function()
                local char = LocalPlayer.Character
                local backpack = LocalPlayer:FindFirstChild("Backpack")

                -- Auto equip training / power items
                if backpack then
                    for _, item in ipairs(backpack:GetChildren()) do
                        if item:IsA("Tool") then
                            item.Parent = char
                        end
                    end
                end

                -- Auto activate equipped tools
                if char then
                    for _, item in ipairs(char:GetChildren()) do
                        if item:IsA("Tool") then
                            item:Activate()
                        end
                    end
                end

                -- Virtual tap / mouse clicker
                if VirtualUser then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(500, 500))
                end

                if VirtualInputManager then
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 0)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 0)
                end

                -- Click / Train / Power Remote Sweeper
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoClick then break end
                    local nameLower = obj.Name:lower()
                    if nameLower:find("click") or nameLower:find("train") or nameLower:find("strength") or 
                       nameLower:find("power") or nameLower:find("tap") or nameLower:find("punch") or 
                       nameLower:find("addstrength") or nameLower:find("gainpower") or nameLower:find("dino") then
                        if obj:IsA("RemoteEvent") then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer(1)
                                obj:FireServer(true)
                                obj:FireServer("+1")
                                obj:FireServer("Train")
                            end)
                        elseif obj:IsA("RemoteFunction") then
                            pcall(function()
                                obj:InvokeServer()
                                obj:InvokeServer(1)
                            end)
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 5. AUTO FIGHT DINOS & BOSSES ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.08)
        if Toggles.AutoFight then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                -- Direct Combat Remotes Sweeper
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoFight then break end
                    local nameLower = obj.Name:lower()
                    if nameLower:find("attack") or nameLower:find("fight") or nameLower:find("damage") or 
                       nameLower:find("hit") or nameLower:find("dinoattack") or nameLower:find("bosshit") or 
                       nameLower:find("battledamage") or nameLower:find("requestmeleehitbox") or nameLower:find("bite") then
                        if obj:IsA("RemoteEvent") then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer(1)
                                obj:FireServer(true)
                                obj:FireServer("Attack")
                                obj:FireServer("Boss")
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

                -- Scan for Enemy Dino & Boss Models
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
-- 6. INFINITE WINS ENGINE (Runway, Gate Touch & Remotes)
--------------------------------------------------------------------
local cachedWinParts = {}
local lastWinScan = 0

local function GetDinoWinTargets()
    if os.time() - lastWinScan > 4 or #cachedWinParts == 0 then
        cachedWinParts = {}
        pcall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character or Workspace) then
                    local n = obj.Name:lower()
                    local pName = obj.Parent and obj.Parent.Name:lower() or ""
                    local isWinPart = false

                    -- Check BillboardGui / SurfaceGui text
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
                            for _, txt in ipairs(child:GetDescendants()) do
                                if txt:IsA("TextLabel") then
                                    local t = txt.Text:lower()
                                    if t:find("win") or t:find("trophy") or t:find("finish") or t:find("goal") or t:find("gate") or t:find("stage") then
                                        isWinPart = true
                                        break
                                    end
                                end
                            end
                        end
                    end

                    -- Check Part or Folder name
                    if not isWinPart then
                        if n:find("win") or n:find("finish") or n:find("goal") or n:find("gate") or 
                           n:find("trophy") or n:find("stage") or n:find("checkpoint") or n:find("endzone") or 
                           pName:find("win") or pName:find("finish") or pName:find("gates") or pName:find("stages") or 
                           pName:find("runway") or pName:find("track") or pName:find("evolution") then
                            isWinPart = true
                        end
                    end

                    if isWinPart and obj.Size.Magnitude > 0.5 then
                        table.insert(cachedWinParts, obj)
                    end
                end
            end
        end)
        lastWinScan = os.time()
    end
    return cachedWinParts
end

task.spawn(function()
    while true do
        task.wait(0.12)
        if Toggles.InfiniteWins then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- Layer 1: Virtual Touch on Win Gates / Runway Endpoints
                local winTargets = GetDinoWinTargets()
                if firetouchinterest and #winTargets > 0 then
                    for _, targetPart in ipairs(winTargets) do
                        if not Toggles.InfiniteWins then break end
                        pcall(function()
                            if targetPart and targetPart.Parent then
                                firetouchinterest(hrp, targetPart, 0)
                                task.wait(0.01)
                                firetouchinterest(hrp, targetPart, 1)
                            end
                        end)
                    end
                end

                -- Layer 2: All Win / Stage / Reward Remotes
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.InfiniteWins then break end
                    local nameLower = obj.Name:lower()
                    if nameLower:find("win") or nameLower:find("claimwin") or nameLower:find("givewin") or 
                       nameLower:find("addwin") or nameLower:find("passgate") or nameLower:find("wingate") or 
                       nameLower:find("stagewin") or nameLower:find("finish") or nameLower:find("reward") or 
                       nameLower:find("claimreward") or nameLower:find("reachgoal") or nameLower:find("endrun") then
                        if obj:IsA("RemoteEvent") then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer(1)
                                obj:FireServer(true)
                                obj:FireServer("Win")
                                obj:FireServer("Claim")
                                obj:FireServer("Stage1")
                                obj:FireServer(1, true)
                                obj:FireServer(100)
                            end)
                        elseif obj:IsA("RemoteFunction") then
                            pcall(function()
                                obj:InvokeServer()
                                obj:InvokeServer(1)
                                obj:InvokeServer(true)
                                obj:InvokeServer("Win")
                            end)
                        end
                    end
                end

                -- Layer 3: Victory / Next Stage GUI Clicker
                if LocalPlayer:FindFirstChild("PlayerGui") then
                    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.Name ~= "JunejoDinoEvolutionUI" then
                            for _, btn in ipairs(gui:GetDescendants()) do
                                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                                    local bName = btn.Name:lower()
                                    local bText = (btn:IsA("TextButton") and btn.Text or ""):lower()
                                    
                                    if bName:find("claimwin") or bName:find("winclaim") or bName:find("collectwin") or 
                                       bName:find("nextstage") or bText:find("claim win") or bText:find("collect win") or 
                                       bText:find("claim") or bText:find("victory") then
                                        ClickGuiButton(btn)
                                    end
                                end
                            end
                        end
                    end
                end

                -- Layer 4: Win Chests Proximity Prompts
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local promptName = prompt.Name:lower() .. (prompt.ObjectText or ""):lower() .. (prompt.ActionText or ""):lower()
                        if promptName:find("win") or promptName:find("trophy") or promptName:find("claim") or promptName:find("finish") then
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
-- 7. AUTO HATCH EGGS ENGINE (Instant Open)
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
                       nameLower:find("purchaseegg") or nameLower:find("egghatch") or nameLower:find("eggopen") or 
                       nameLower:find("dinoegg") then
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
-- 8. SMART AUTO REBIRTH WITH REQUIREMENTS CHECKER & NOTIFIER
--------------------------------------------------------------------
local lastRebirthNotify = 0

local function GetRebirthRequirementsInfo()
    local info = "Checking Rebirth Status..."
    pcall(function()
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        local strengthVal = leaderstats and (leaderstats:FindFirstChild("Strength") or leaderstats:FindFirstChild("Power"))
        local winsVal = leaderstats and (leaderstats:FindFirstChild("Wins") or leaderstats:FindFirstChild("Win"))
        local rebirthVal = leaderstats and (leaderstats:FindFirstChild("Rebirth") or leaderstats:FindFirstChild("Rebirths"))
        
        local curStrength = strengthVal and strengthVal.Value or 0
        local curWins = winsVal and winsVal.Value or 0
        local curRebirth = rebirthVal and rebirthVal.Value or 0

        info = "Rebirth: " .. tostring(curRebirth) .. " | Power: " .. tostring(curStrength) .. " | Wins: " .. tostring(curWins)
    end)
    return info
end

task.spawn(function()
    while true do
        task.wait(0.4)
        if Toggles.AutoRebirth then
            pcall(function()
                local didRebirth = false

                -- Layer 1: In-Game Rebirth GUI Auto-Clicker
                if LocalPlayer:FindFirstChild("PlayerGui") then
                    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.Name ~= "JunejoDinoEvolutionUI" then
                            for _, btn in ipairs(gui:GetDescendants()) do
                                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                                    local bName = btn.Name:lower()
                                    local bText = (btn:IsA("TextButton") and btn.Text or ""):lower()
                                    local parentName = btn.Parent and btn.Parent.Name:lower() or ""

                                    if bName:find("rebirth") or bName:find("evolve") or bName:find("prestige") or 
                                       bText:find("rebirth") or bText:find("evolve") or bText:find("yes") or 
                                       bText:find("confirm") or parentName:find("rebirth") then
                                        ClickGuiButton(btn)
                                        didRebirth = true
                                    end
                                end
                            end
                        end
                    end
                end

                -- Layer 2: All ReplicatedStorage Rebirth Remotes
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoRebirth then break end
                    local nameLower = obj.Name:lower()
                    if nameLower:find("rebirth") or nameLower:find("prestige") or nameLower:find("evolve") or 
                       nameLower:find("dorebirth") or nameLower:find("buyrebirth") or nameLower:find("dinorebirth") then
                        if obj:IsA("RemoteEvent") then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer(1)
                                obj:FireServer(true)
                                obj:FireServer("Rebirth")
                                obj:FireServer(1, true)
                                didRebirth = true
                            end)
                        elseif obj:IsA("RemoteFunction") then
                            pcall(function()
                                obj:InvokeServer()
                                obj:InvokeServer(1)
                                obj:InvokeServer(true)
                                didRebirth = true
                            end)
                        end
                    end
                end

                -- Layer 3: Physical Rebirth Altars & ProximityPrompts
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local promptName = prompt.Name:lower() .. (prompt.ObjectText or ""):lower() .. (prompt.ActionText or ""):lower()
                        if promptName:find("rebirth") or promptName:find("evolve") or promptName:find("prestige") then
                            if fireproximityprompt then
                                fireproximityprompt(prompt, 0)
                                didRebirth = true
                            end
                        end
                    end
                end

                -- Periodic Status Notification
                if os.time() - lastRebirthNotify > 12 then
                    lastRebirthNotify = os.time()
                    local reqInfo = GetRebirthRequirementsInfo()
                    pcall(function()
                        StarterGui:SetCore("SendNotification", {
                            Title = "Auto Rebirth Active",
                            Text = reqInfo,
                            Duration = 3
                        })
                    end)
                end
            end)
        end
    end
end)
