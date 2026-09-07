--[[
    ========================================================================
    JUNEJO ULTRA SCRIPT HUB - +1 LONG ARM TOY ESCAPE!
    ========================================================================
    Author: Made by Junejo (junejo18146)
    Target Game: +1 Long Arm Toy Escape! (Roblox)
    Repository: junejo18146/ultrascripthub
    File: long_arm_toy_escape.lua
    UI Standard: Junejo Classic Dark UI (#0F0F11) - Flat & Borderless Standard
    
    Features Included (All Core Game Logic 100% Intact & Preserved):
        1. Auto Train Arms (Touch Overhead Bars, Fire Growth Remotes & Tools)
        2. Auto Wins (Touch Win/Victory Pads & Fire Win Remotes)
        3. Auto Rebirth (Automatic Prestige Loop)
        4. Noclip Mode (Walk & Phase Through Walls & Doors)
        5. Infinite Jump (Continuous Multi-Jump Engine)
        6. WalkSpeed Boost + Integrated Pill Controller (- / +: 16 to 300)
        7. Fly Mode (Smooth 3D Flight with WASD/Space/Shift controls)
        8. Anti-AFK Engine (Auto 20-minute idle disconnect protection)
    ========================================================================
--]]

local GameTitle = "+1 LONG ARM ESCAPE"

-- Core Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
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
        local old = parent:FindFirstChild("JunejoHub_LongArmEscape") or parent:FindFirstChild("RobloxScriptUI_LongArmEscape") or parent:FindFirstChild("RobloxScriptUI_LongArmEscapeHub")
        if old then old:Destroy() end
    end)
    pcall(function()
        if CoreGui:FindFirstChild("JunejoHub_LongArmEscape") then
            CoreGui.JunejoHub_LongArmEscape:Destroy()
        end
    end)
    pcall(function()
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("JunejoHub_LongArmEscape") then
            LocalPlayer.PlayerGui.JunejoHub_LongArmEscape:Destroy()
        end
    end)
end
CleanupOldGui()

-- Global Feature Toggles & State
local Toggles = {
    AutoTrain = false,
    AutoWins = false,
    AutoRebirth = false,
    Noclip = false,
    InfiniteJump = false,
    WalkSpeedBoost = false,
    FlyMode = false,
    AntiAFK = true
}

local CustomSpeedValue = 24

-- =================================================================
-- 1. HELPER FUNCTIONS & CACHED SEARCH
-- =================================================================
local function getCharParts()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local rHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
    local lHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
    return root, hum, rHand, lHand
end

-- Cached training bars & win pads to prevent lag
local cachedBars = {}
local cachedWinPads = {}
local lastCacheUpdate = 0

local function refreshWorkspaceCache()
    cachedBars = {}
    cachedWinPads = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            local pName = obj.Parent and obj.Parent.Name:lower() or ""
            
            -- Check for Training Bars
            if n:find("bar") or n:find("pullup") or n:find("train") or n:find("hang") or pName:find("bar") or pName:find("train") then
                table.insert(cachedBars, obj)
            end
            
            -- Check for Win Pads
            if n:find("win") or n:find("finish") or n:find("victory") or n:find("end") or n:find("trophy") or n:find("checkpoint") then
                table.insert(cachedWinPads, obj)
            end
        elseif obj:IsA("TouchTransmitter") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                local n = parent.Name:lower()
                if n:find("win") or n:find("finish") or n:find("victory") or n:find("end") or n:find("trophy") or n:find("checkpoint") then
                    table.insert(cachedWinPads, parent)
                end
            end
        end
    end
    lastCacheUpdate = tick()
end

refreshWorkspaceCache()

-- Fire matching ReplicatedStorage remotes safely
local function fireRemotesMatching(keywords)
    pcall(function()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local n = obj.Name:lower()
                local isShop = n:find("shop") or n:find("buy") or n:find("purchase") or n:find("menu") or n:find("pass")
                if not isShop then
                    for _, kw in ipairs(keywords) do
                        if n:find(kw) then
                            pcall(function() obj:FireServer() end)
                            pcall(function() obj:FireServer(1) end)
                            pcall(function() obj:FireServer(true) end)
                            break
                        end
                    end
                end
            elseif obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                local isShop = n:find("shop") or n:find("buy") or n:find("purchase") or n:find("menu")
                if not isShop then
                    for _, kw in ipairs(keywords) do
                        if n:find(kw) then
                            task.spawn(function()
                                pcall(function() obj:InvokeServer() end)
                                pcall(function() obj:InvokeServer(1) end)
                                pcall(function() obj:InvokeServer(true) end)
                            end)
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- =================================================================
-- 2. AUTOMATION ENGINES & UTILITIES
-- =================================================================

-- Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- Infinite Jump Engine
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        local _, hum = getCharParts()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Noclip Engine
RunService.Stepped:Connect(function()
    if Toggles.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- WalkSpeed Enforcer (Smooth & Anti-Rubberband)
local function UpdateCharacterSpeed()
    local _, hum = getCharParts()
    if hum then
        if Toggles.WalkSpeedBoost then
            hum.WalkSpeed = CustomSpeedValue
        else
            hum.WalkSpeed = 16
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(function()
            if Toggles.WalkSpeedBoost then
                local _, hum = getCharParts()
                if hum and hum.WalkSpeed ~= CustomSpeedValue then
                    hum.WalkSpeed = CustomSpeedValue
                end
            end
        end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.spawn(function()
        local hum = char:WaitForChild("Humanoid", 4)
        if hum then
            task.wait(0.5)
            UpdateCharacterSpeed()
        end
    end)
end)

-- =================================================================
-- FLY SYSTEM
-- =================================================================
local FlyBodyGyro, FlyBodyVelocity
local FlyConnection

local function EnableFly()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if FlyBodyGyro then FlyBodyGyro:Destroy() end
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() end

    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.CFrame = root.CFrame
    FlyBodyGyro.Parent = root

    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity = Vector3.zero
    FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVelocity.Parent = root

    hum.PlatformStand = true

    local Camera = Workspace.CurrentCamera
    if FlyConnection then FlyConnection:Disconnect() end
    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Toggles.FlyMode or not root or not hum or not FlyBodyVelocity or not FlyBodyGyro then
            if FlyConnection then FlyConnection:Disconnect() end
            return
        end
        FlyBodyGyro.CFrame = Camera.CFrame

        local flyDirection = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            flyDirection = flyDirection + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            flyDirection = flyDirection - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            flyDirection = flyDirection - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            flyDirection = flyDirection + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            flyDirection = flyDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            flyDirection = flyDirection - Vector3.new(0, 1, 0)
        end

        local flySpeed = math.clamp(CustomSpeedValue * 2, 40, 180)
        FlyBodyVelocity.Velocity = flyDirection * flySpeed
    end)
end

local function DisableFly()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

-- =================================================================
-- 3. WORKABLE GAME LOOPS
-- =================================================================

local trainKeywords = {"train", "stretch", "arm", "length", "grow", "pullup", "click", "tap", "add"}
local winKeywords = {"win", "finish", "victory", "checkpoint", "door", "reward"}
local rebirthKeywords = {"rebirth", "prestige", "ascend", "reset"}

-- Continuous Auto Train Arms Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if Toggles.AutoTrain then
            pcall(function()
                -- 1. Refresh cache every 15s
                if tick() - lastCacheUpdate > 15 then
                    refreshWorkspaceCache()
                end
                
                local root, hum, rHand, lHand = getCharParts()
                if root then
                    -- 2. Touch Overhead Bars directly with hands (Pull-Up reps)
                    if #cachedBars > 0 and firetouchinterest then
                        for _, bar in ipairs(cachedBars) do
                            if not Toggles.AutoTrain then break end
                            if bar and bar.Parent then
                                local dist = (Vector2.new(root.Position.X, root.Position.Z) - Vector2.new(bar.Position.X, bar.Position.Z)).Magnitude
                                if dist <= 120 then
                                    if rHand then
                                        firetouchinterest(rHand, bar, 0)
                                        task.wait(0.005)
                                        firetouchinterest(rHand, bar, 1)
                                    end
                                    if lHand then
                                        firetouchinterest(lHand, bar, 0)
                                        task.wait(0.005)
                                        firetouchinterest(lHand, bar, 1)
                                    end
                                    firetouchinterest(root, bar, 0)
                                    task.wait(0.005)
                                    firetouchinterest(root, bar, 1)
                                end
                            end
                        end
                    end
                    
                    -- 3. Fire Game Remotes for arm growth
                    fireRemotesMatching(trainKeywords)
                    
                    -- 4. Equip & activate tool if available
                    local char = LocalPlayer.Character
                    if char then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                        else
                            local bpTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if bpTool and hum then
                                hum:EquipTool(bpTool)
                                task.wait(0.04)
                                bpTool:Activate()
                            end
                        end
                    end
                    
                    -- 5. Trigger PlayerGui Train button if available via firesignal
                    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                    if pgui and firesignal then
                        for _, btn in ipairs(pgui:GetDescendants()) do
                            if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                                local bName = btn.Name:lower()
                                local bText = btn:IsA("TextButton") and btn.Text:lower() or ""
                                if (bName:find("train") or bText:find("train")) and not bName:find("shop") and not bText:find("shop") then
                                    firesignal(btn.MouseButton1Click)
                                    firesignal(btn.Activated)
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Continuous Auto Wins Loop
task.spawn(function()
    while true do
        task.wait(0.3)
        if Toggles.AutoWins then
            pcall(function()
                if tick() - lastCacheUpdate > 15 then
                    refreshWorkspaceCache()
                end
                
                local root, _ = getCharParts()
                if root then
                    -- 1. Trigger Win Pads via firetouchinterest
                    if #cachedWinPads > 0 and firetouchinterest then
                        for _, pad in ipairs(cachedWinPads) do
                            if not Toggles.AutoWins then break end
                            if pad and pad.Parent then
                                firetouchinterest(root, pad, 0)
                                task.wait(0.01)
                                firetouchinterest(root, pad, 1)
                            end
                        end
                    end
                    
                    -- 2. Fire Win Remotes in ReplicatedStorage
                    fireRemotesMatching(winKeywords)
                end
            end)
        end
    end
end)

-- Continuous Auto Rebirth Loop
task.spawn(function()
    while true do
        task.wait(1.0)
        if Toggles.AutoRebirth then
            pcall(function()
                fireRemotesMatching(rebirthKeywords)
            end)
        end
    end
end)

-- =================================================================
-- OFFICIAL JUNEJO STANDARD UI GENERATOR (FLAT & BORDERLESS)
-- =================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHub_LongArmEscape"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

-- Calculate Dynamic Window Height
-- Header (32) + Gap/Padding (10) + (7 items * 27px) + Footer (38) = ~270px
local MainWindowHeight = 275

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
    Toggles.AutoTrain = false
    Toggles.AutoWins = false
    Toggles.AutoRebirth = false
    Toggles.Noclip = false
    Toggles.InfiniteJump = false
    Toggles.WalkSpeedBoost = false
    Toggles.FlyMode = false
    DisableFly()
    UpdateCharacterSpeed()
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
ContentFrame.Size = UDim2.new(1, -24, 0, 195)
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

-- =================================================================
-- BUILD FEATURE ROWS
-- =================================================================

-- 1. Auto Train Arms
AddToggleRow("Auto Train Arms", "AutoTrain")

-- 2. Auto Wins
AddToggleRow("Auto Wins", "AutoWins")

-- 3. Auto Rebirth
AddToggleRow("Auto Rebirth", "AutoRebirth")

-- 4. WalkSpeed with Integrated - / + Pill Controller
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
    CustomSpeedValue = math.max(16, CustomSpeedValue - 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

-- 5. Noclip (Walk Thru Walls)
AddToggleRow("Noclip (Walk Thru Walls)", "Noclip")

-- 6. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump")

-- 7. Fly Mode
AddToggleRow("Fly Mode", "FlyMode", function(enabled)
    if enabled then EnableFly() else DisableFly() end
end)

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

print("[Junejo Script Hub]: +1 Long Arm Toy Escape Script Loaded Successfully!")
