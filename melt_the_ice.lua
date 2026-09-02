--==============================================================--
--  JUNEJO ULTRA SCRIPT HUB - OFFICIAL STANDALONE SCRIPT
--  Game: Melt The Ice
--  Version: 2.0 (Auto Melt Ice, Auto Fuel, Auto Upgrade, Auto Collect & Mobile Fly)
--  Branding: ULTRA SCRIPT HUB | Made by Junejo (junejo18146)
--==============================================================--

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

-- Feature Toggles & States
local Toggles = {
    AutoMeltIce = false,
    AutoFuel = false,
    AutoUpgrade = false,
    AutoCollect = false,
    FlyMode = false,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

local CustomSpeedValue = 50
local NormalWalkSpeed = 16
local FlySpeed = 60
local Flying = false
local FlyBodyGyro, FlyBodyVel

-- Clean Old UI Instances
pcall(function()
    if CoreGui and CoreGui:FindFirstChild("JunejoHub_MeltTheIce") then
        CoreGui:FindFirstChild("JunejoHub_MeltTheIce"):Destroy()
    end
    if CoreGui and CoreGui:FindFirstChild("SakiScriptsMeltTheIceUI") then
        CoreGui:FindFirstChild("SakiScriptsMeltTheIceUI"):Destroy()
    end
    local lpGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if lpGui then
        if lpGui:FindFirstChild("JunejoHub_MeltTheIce") then
            lpGui:FindFirstChild("JunejoHub_MeltTheIce"):Destroy()
        end
        if lpGui:FindFirstChild("SakiScriptsMeltTheIceUI") then
            lpGui:FindFirstChild("SakiScriptsMeltTheIceUI"):Destroy()
        end
    end
end)

-- Anti-AFK Protection
LocalPlayer.Idled:Connect(function()
    if VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

-- Character Helper Functions
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char.PrimaryPart
end

local function getHum()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- Remote Search & Dispatcher
local function fireGameRemotes(keywords, argsList)
    local searchContainers = {ReplicatedStorage, Workspace}
    local lpGui = LocalPlayer:FindFirstChild("PlayerGui")
    if lpGui then table.insert(searchContainers, lpGui) end
    local char = LocalPlayer.Character
    if char then table.insert(searchContainers, char) end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then table.insert(searchContainers, backpack) end

    for _, container in ipairs(searchContainers) do
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = string.lower(obj.Name)
                for _, kw in ipairs(keywords) do
                    if string.find(n, kw) then
                        for _, argSet in ipairs(argsList) do
                            pcall(function()
                                if obj:IsA("RemoteEvent") then
                                    if type(argSet) == "table" then
                                        obj:FireServer(unpack(argSet))
                                    elseif argSet ~= nil then
                                        obj:FireServer(argSet)
                                    else
                                        obj:FireServer()
                                    end
                                elseif obj:IsA("RemoteFunction") then
                                    if type(argSet) == "table" then
                                        obj:InvokeServer(unpack(argSet))
                                    elseif argSet ~= nil then
                                        obj:InvokeServer(argSet)
                                    else
                                        obj:InvokeServer()
                                    end
                                end
                            end)
                        end
                        break
                    end
                end
            end
        end
    end
end

-- WalkSpeed Multi-Layer Engine
local function UpdateCharacterSpeed()
    local hum = getHum()
    if hum then
        if Toggles.WalkSpeedBoost then
            hum.WalkSpeed = CustomSpeedValue
        else
            hum.WalkSpeed = NormalWalkSpeed
        end
    end
end

RunService.RenderStepped:Connect(function()
    if Toggles.WalkSpeedBoost and CustomSpeedValue > 16 then
        pcall(function()
            local hum = getHum()
            if hum then
                hum.WalkSpeed = CustomSpeedValue
            end
        end)
    end
end)

RunService.Heartbeat:Connect(function()
    if Toggles.WalkSpeedBoost and CustomSpeedValue > 16 then
        pcall(function()
            local hum = getHum()
            local root = getRoot()
            if hum and root then
                if hum.WalkSpeed ~= CustomSpeedValue then
                    hum.WalkSpeed = CustomSpeedValue
                end
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    root.AssemblyLinearVelocity = Vector3.new(
                        moveDir.X * CustomSpeedValue,
                        root.AssemblyLinearVelocity.Y,
                        moveDir.Z * CustomSpeedValue
                    )
                end
            end
        end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    UpdateCharacterSpeed()
end)

-- Infinite Jump Engine
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        pcall(function()
            local hum = getHum()
            local root = getRoot()
            if hum and root then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                root.AssemblyLinearVelocity = Vector3.new(
                    root.AssemblyLinearVelocity.X,
                    50,
                    root.AssemblyLinearVelocity.Z
                )
            end
        end)
    end
end)

-- Smooth 3D Flight Engine
local function startFlying()
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return end

    Flying = true
    hum.PlatformStand = true

    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.CFrame = root.CFrame
    FlyBodyGyro.Parent = root

    FlyBodyVel = Instance.new("BodyVelocity")
    FlyBodyVel.Velocity = Vector3.new(0, 0, 0)
    FlyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVel.Parent = root

    task.spawn(function()
        while Flying and Toggles.FlyMode do
            RunService.RenderStepped:Wait()
            if not root or not FlyBodyGyro or not FlyBodyVel then break end
            
            FlyBodyGyro.CFrame = Camera.CFrame
            local direction = Vector3.new()

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + (Camera.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - (Camera.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - (Camera.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + (Camera.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            -- Mobile Touch / Thumbstick support
            if hum.MoveDirection.Magnitude > 0 and direction.Magnitude == 0 then
                direction = (Camera.CFrame.LookVector * hum.MoveDirection.Z * -1) + (Camera.CFrame.RightVector * hum.MoveDirection.X)
            end

            FlyBodyVel.Velocity = direction * FlySpeed
        end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if FlyBodyVel then FlyBodyVel:Destroy() end
        if hum then hum.PlatformStand = false end
        Flying = false
    end)
end

local function stopFlying()
    Flying = false
    if FlyBodyGyro then FlyBodyGyro:Destroy() end
    if FlyBodyVel then FlyBodyVel:Destroy() end
    local hum = getHum()
    if hum then hum.PlatformStand = false end
end

--==============================================================--
--  GUI CREATION (Official Junejo Ultra Script Hub Standard)
--==============================================================--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHub_MeltTheIce"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local parentGui = nil
if gethui then 
    pcall(function() parentGui = gethui() end) 
end
if not parentGui then 
    pcall(function() parentGui = CoreGui end) 
end
if not parentGui then 
    pcall(function()
        parentGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    end) 
end

pcall(function()
    ScreenGui.Parent = parentGui or CoreGui
end)
if not ScreenGui.Parent then
    pcall(function()
        ScreenGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end)
end

-- Main Frame (280 x 265)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 265)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -132)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
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
TitleLabel.Text = "MELT THE ICE"
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
CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 0, 188)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper function for Toggle Rows
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

-- 1. Auto Melt Ice Toggle
AddToggleRow("Auto Melt Ice", "AutoMeltIce")

-- 2. Auto Fuel Toggle
AddToggleRow("Auto Fuel", "AutoFuel")

-- 3. Auto Upgrade Toggle
AddToggleRow("Auto Upgrade", "AutoUpgrade")

-- 4. Auto Collect Toggle
AddToggleRow("Auto Collect", "AutoCollect")

-- 5. Fly Mode Toggle
AddToggleRow("Fly Mode", "FlyMode", function(enabled)
    if enabled then
        startFlying()
    else
        stopFlying()
    end
end)

-- 6. Integrated WalkSpeed Row with Pill Adjuster
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
    UpdateCharacterSpeed()
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
    CustomSpeedValue = math.max(16, CustomSpeedValue - 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(250, CustomSpeedValue + 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

-- 7. Infinite Jump Toggle
AddToggleRow("Infinite Jump", "InfiniteJump")

-- Footer
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
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

--==============================================================--
-- 1. AUTO MELT ICE (Hyper Weapon Fire + Target Scanner + Remotes)
--==============================================================--
task.spawn(function()
    while true do
        if Toggles.AutoMeltIce then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local root = getRoot()

                -- Auto Equip & Activate Weapon / Tool
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then
                    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                    if backpack then
                        local bTool = backpack:FindFirstChildOfClass("Tool")
                        if bTool then
                            bTool.Parent = char
                            tool = bTool
                        end
                    end
                end

                if tool then
                    pcall(function() tool:Activate() end)
                end

                -- Virtual Click Simulation
                if VirtualUser then
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(500, 500))
                    end)
                end
                if VirtualInputManager then
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 0)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 0)
                    end)
                end

                -- Target & Touch Nearest Ice Blocks / Melting Targets
                if root then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not Toggles.AutoMeltIce then break end
                        if obj:IsA("BasePart") then
                            local n = obj.Name:lower()
                            local p = obj.Parent and obj.Parent.Name:lower() or ""
                            if n:find("ice") or n:find("melt") or n:find("glacier") or n:find("block") or n:find("frost") or
                               p:find("ice") or p:find("melt") or p:find("glacier") or p:find("frozen") then
                                if (obj.Position - root.Position).Magnitude < 45 then
                                    if firetouchinterest then
                                        firetouchinterest(obj, root, 0)
                                        task.wait()
                                        firetouchinterest(obj, root, 1)
                                    end
                                end
                            end
                        elseif obj:IsA("ProximityPrompt") then
                            local act = (obj.ActionText .. " " .. obj.ObjectText):lower()
                            if act:find("melt") or act:find("burn") or act:find("heat") or act:find("hit") or act:find("ice") then
                                pcall(function()
                                    obj.HoldDuration = 0
                                    if fireproximityprompt then fireproximityprompt(obj, 0) else obj:InputHoldBegin() task.wait(0.01) obj:InputHoldEnd() end
                                end)
                            end
                        elseif obj:IsA("ClickDetector") then
                            if fireclickdetector then
                                fireclickdetector(obj)
                            end
                        end
                    end
                end

                -- Fire All Melting & Attack Remotes
                fireGameRemotes(
                    {
                        "melt", "meltice", "hitice", "damageice", "burn", "heat", "damage",
                        "click", "mine", "attack", "melter", "meltblock", "hit", "flame", "laser", "fire"
                    },
                    {{}, {1}, {999999}, {true}, {"Ice"}, {"Melt"}, {"All"}, {1, 1}, {1, true}}
                )
            end)
            task.wait(0.04)
        else
            task.wait(0.3)
        end
    end
end)

--==============================================================--
-- 2. AUTO FUEL LOOP (Background Value Lock + Remotes)
--==============================================================--
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoFuel then
            pcall(function()
                local char = LocalPlayer.Character

                -- Scan and refill fuel ValueObjects & Attributes
                local searchContainers = {LocalPlayer, char, LocalPlayer:FindFirstChild("PlayerGui"), LocalPlayer:FindFirstChild("Backpack")}
                for _, cont in ipairs(searchContainers) do
                    if cont then
                        for _, obj in ipairs(cont:GetDescendants()) do
                            local nameLower = string.lower(obj.Name)
                            if string.find(nameLower, "fuel") or string.find(nameLower, "gas") or string.find(nameLower, "tank") or string.find(nameLower, "energy") or string.find(nameLower, "ammo") then
                                if obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("DoubleConstrainedValue") then
                                    local parent = obj.Parent
                                    local maxObj = parent and (parent:FindFirstChild("MaxFuel") or parent:FindFirstChild("MaxGas") or parent:FindFirstChild("Max") or parent:FindFirstChild("Capacity"))
                                    if maxObj and (maxObj:IsA("NumberValue") or maxObj:IsA("IntValue")) then
                                        obj.Value = maxObj.Value
                                    else
                                        if obj.Value < 999999 then
                                            obj.Value = 999999
                                        end
                                    end
                                end
                            end
                            if obj:IsA("Instance") then
                                local attrs = obj:GetAttributes()
                                for attrName, attrVal in pairs(attrs) do
                                    local attrLower = string.lower(attrName)
                                    if string.find(attrLower, "fuel") or string.find(attrLower, "gas") or string.find(attrLower, "tank") or string.find(attrLower, "energy") or string.find(attrLower, "ammo") then
                                        if type(attrVal) == "number" then
                                            obj:SetAttribute(attrName, 999999)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                -- Fire Refill Remotes in Background
                fireGameRemotes(
                    {"fuel", "refill", "gas", "tank", "fill", "reload", "energy", "charge", "addfuel", "buyfuel", "getfuel", "refillfuel", "freefuel"},
                    {{}, {true}, {1}, {999999}, {math.huge}, {"Refill"}, {"Max"}, {"Fuel"}, {"All"}, {"Gas"}}
                )
            end)
        end
    end
end)

--==============================================================--
-- 3. AUTO UPGRADE LOOP (Background Remote Dispatcher)
--==============================================================--
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoUpgrade then
            pcall(function()
                fireGameRemotes(
                    {
                        "upgrade", "buyupgrade", "purchaseupgrade", "upgradestat", "upgradeskill",
                        "upgradetank", "upgradefuel", "upgradeheat", "upgradepower", "upgradespeed",
                        "upgrademelt", "upgradetool", "upgradeweapon", "buyitem", "buyall", "levelup",
                        "statupgrade", "shopupgrade", "buystat", "addstat"
                    },
                    {
                        {},
                        {1}, {2}, {3}, {4}, {5},
                        {true},
                        {"All"}, {"Heat"}, {"Power"}, {"Fuel"}, {"Tank"}, {"Speed"},
                        {"Capacity"}, {"Damage"}, {"Range"}, {"MeltSpeed"}, {"Multiplier"},
                        {"Flamethrower"}, {"Weapon"}, {"Torch"}, {"Laser"},
                        {"Max"},
                        {1, 1}, {1, true}, {"All", true},
                        {"Heat", 1}, {"Fuel", 1}, {"Tank", 1}, {"Speed", 1}, {"Power", 1},
                        {"Heat", true}, {"Fuel", true}, {"Tank", true}, {"Speed", true}
                    }
                )
            end)
        end
    end
end)

--==============================================================--
-- 4. AUTO COLLECT LOOP (Medals, Coins, Shards, Gold Bars)
--==============================================================--
task.spawn(function()
    while true do
        task.wait(0.3)
        if Toggles.AutoCollect then
            pcall(function()
                local root = getRoot()
                if not root then return end

                -- Universal TouchTransmitter Collection
                for _, descendant in ipairs(Workspace:GetDescendants()) do
                    if descendant:IsA("TouchTransmitter") then
                        local part = descendant.Parent
                        if part and part:IsA("BasePart") then
                            local isPlayerPart = false
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p.Character and part:IsDescendantOf(p.Character) then
                                    isPlayerPart = true
                                    break
                                end
                            end

                            if not isPlayerPart then
                                if firetouchinterest then
                                    firetouchinterest(part, root, 0)
                                    task.wait()
                                    firetouchinterest(part, root, 1)
                                else
                                    part.CFrame = root.CFrame
                                end
                            end
                        end
                    end
                end

                -- Collect Drops / Gold Bars / Medals / Shards by Name & Color
                for _, item in ipairs(Workspace:GetDescendants()) do
                    if item:IsA("BasePart") then
                        local n = string.lower(item.Name)
                        local isGoldColor = (item.Color.R > 0.7 and item.Color.G > 0.6 and item.Color.B < 0.3)
                        if string.find(n, "coin") or string.find(n, "medal") or string.find(n, "shard") or string.find(n, "drop") or string.find(n, "reward") or string.find(n, "cash") or string.find(n, "gold") or string.find(n, "ingot") or string.find(n, "bar") or isGoldColor then
                            if firetouchinterest then
                                firetouchinterest(item, root, 0)
                                task.wait()
                                firetouchinterest(item, root, 1)
                            else
                                item.CFrame = root.CFrame
                            end
                        end
                    end
                end

                -- Remotes for Collection
                fireGameRemotes(
                    {"collect", "pickup", "claim", "claimreward", "grab", "getall", "collectall"},
                    {{}, {1}, {true}, {"All"}}
                )
            end)
        end
    end
end)

print("[ULTRA SCRIPT HUB] Melt The Ice v2.0 Loaded Successfully!")

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "ULTRA SCRIPT HUB",
        Text = "Melt The Ice v2.0 Ready! Made by Junejo",
        Duration = 5
    })
end)
