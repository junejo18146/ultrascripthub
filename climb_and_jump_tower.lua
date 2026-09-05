--[[
    JUNEJO ULTRA SCRIPT HUB - CLIMB AND JUMP TOWER
    Target Game: Climb and Jump Tower (Roblox)
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11) - Flat & Borderless Standard
    Status: Direct Standalone Executable
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- Safe Parent GUI Selection
local function getGuiParent()
    if gethui then
        local success, res = pcall(gethui)
        if success and res then return res end
    end
    local success, result = pcall(function() return CoreGui end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Cleanup Old UI Instances
pcall(function()
    for _, name in ipairs({"GetFatBreakTapeGui", "JunejoHubUI_ClimbTower", "JunejoHubUI"}) do
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end
end)

--------------------------------------------------------------------------------
-- GLOBAL STATE FLAGS (STRICTLY PRESERVED)
--------------------------------------------------------------------------------
local State = {
    InfJumpActive = false,
    AutoCollectActive = false,
    WalkSpeedValue = 16,
    JumpPowerValue = 50
}

--------------------------------------------------------------------------------
-- HELPER FUNCTIONS & CLIENT-SIDE ENGINES (EXACT LOGIC PRESERVED)
--------------------------------------------------------------------------------

local function getPlayerChar()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return char, root, hum
end

-- 1. WALKSPEED BOOST ENGINE
RunService.RenderStepped:Connect(function(deltaTime)
    pcall(function()
        if State.WalkSpeedValue and State.WalkSpeedValue > 16 then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                local hum = char.Humanoid
                local hrp = char.HumanoidRootPart
                if hum.MoveDirection.Magnitude > 0 then
                    local speedBoost = (State.WalkSpeedValue - 16)
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (speedBoost * deltaTime))
                end
            end
        end
    end)
end)

-- 2. JUMP POWER BOOST ENGINE
RunService.RenderStepped:Connect(function()
    pcall(function()
        local _, _, hum = getPlayerChar()
        if hum and State.JumpPowerValue > 50 then
            hum.UseJumpPower = true
            hum.JumpPower = State.JumpPowerValue
        end
    end)
end)

-- 3. INFINITE JUMP ENGINE
UserInputService.JumpRequest:Connect(function()
    if State.InfJumpActive then
        local _, root, hum = getPlayerChar()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            if root then
                root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z)
            end
        end
    end
end)

-- 4. AUTO COLLECT REWARDS & COINS
task.spawn(function()
    while true do
        task.wait(0.3)
        if State.AutoCollectActive then
            pcall(function()
                local _, root = getPlayerChar()
                if not root then return end

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not State.AutoCollectActive then break end
                    if obj:IsA("BasePart") then
                        local nameLower = string.lower(obj.Name)
                        if string.find(nameLower, "coin") or string.find(nameLower, "gem") or string.find(nameLower, "reward") or string.find(nameLower, "gift") or string.find(nameLower, "drop") then
                            if (obj.Position - root.Position).Magnitude <= 60 then
                                if firetouchinterest then
                                    firetouchinterest(root, obj, 0)
                                    task.wait(0.01)
                                    firetouchinterest(root, obj, 1)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ================================================================================
-- OFFICIAL JUNEJO FLAT & BORDERLESS USER INTERFACE
-- ================================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_ClimbTower"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = getGuiParent()

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 205)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -102)
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
TitleLabel.Text = "CLIMB AND JUMP TOWER"
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
    State.InfJumpActive = false
    State.AutoCollectActive = false
    State.WalkSpeedValue = 16
    State.JumpPowerValue = 50
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
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 0, 128)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper function for Flat & Borderless Toggle Rows
local function AddToggleRow(text, getStatus, setStatus)
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
    CheckMark.BackgroundTransparency = getStatus() and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox
    
    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark
    
    RowBtn.MouseButton1Click:Connect(function()
        local newState = not getStatus()
        setStatus(newState)
        CheckMark.BackgroundTransparency = newState and 0 or 1
    end)
end

-- =================================================================
-- FEATURE ROWS CONFIGURATION
-- =================================================================

-- 1. Infinite Jump Toggle
AddToggleRow("Infinite Jump", function() return State.InfJumpActive end, function(val)
    State.InfJumpActive = val
end)

-- 2. Auto Collect Rewards Toggle
AddToggleRow("Auto Collect Rewards", function() return State.AutoCollectActive end, function(val)
    State.AutoCollectActive = val
end)

-- 3. Integrated WalkSpeed Row (- / + Pill Controller)
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, 0, 0, 23)
SpeedRow.BackgroundTransparency = 1
SpeedRow.Parent = ContentFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.55, 0, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed"
SpeedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedRow

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
SpeedDisplay.Text = tostring(State.WalkSpeedValue)
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
    State.WalkSpeedValue = math.max(16, State.WalkSpeedValue - 15)
    SpeedDisplay.Text = tostring(State.WalkSpeedValue)
end)

PlusBtn.MouseButton1Click:Connect(function()
    State.WalkSpeedValue = math.min(200, State.WalkSpeedValue + 15)
    SpeedDisplay.Text = tostring(State.WalkSpeedValue)
end)

-- 4. Integrated Jump Power Row (- / + Pill Controller)
local JumpRow = Instance.new("Frame")
JumpRow.Size = UDim2.new(1, 0, 0, 23)
JumpRow.BackgroundTransparency = 1
JumpRow.Parent = ContentFrame

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Size = UDim2.new(0.55, 0, 1, 0)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "Jump Power"
JumpLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
JumpLabel.TextSize = 12
JumpLabel.Font = Enum.Font.GothamBold
JumpLabel.TextXAlignment = Enum.TextXAlignment.Left
JumpLabel.Parent = JumpRow

local JumpControlFrame = Instance.new("Frame")
JumpControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
JumpControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
JumpControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
JumpControlFrame.BorderSizePixel = 0
JumpControlFrame.Parent = JumpRow

local JumpCorner = Instance.new("UICorner")
JumpCorner.CornerRadius = UDim.new(0, 4)
JumpCorner.Parent = JumpControlFrame

local JumpStroke = Instance.new("UIStroke")
JumpStroke.Color = Color3.fromRGB(45, 45, 55)
JumpStroke.Thickness = 1
JumpStroke.Parent = JumpControlFrame

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
JumpDisplay.Text = tostring(State.JumpPowerValue)
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
    State.JumpPowerValue = math.max(50, State.JumpPowerValue - 25)
    JumpDisplay.Text = tostring(State.JumpPowerValue)
end)

JumpPlusBtn.MouseButton1Click:Connect(function()
    State.JumpPowerValue = math.min(250, State.JumpPowerValue + 25)
    JumpDisplay.Text = tostring(State.JumpPowerValue)
end)

-- Footer (Pinned at bottom)
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

-- Smooth Dragging Mechanism
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
