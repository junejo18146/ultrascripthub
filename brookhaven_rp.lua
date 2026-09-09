-- =================================================================
-- JUNEJO ULTRA SCRIPT HUB - BROOKHAVEN RP
-- Target Game: Brookhaven 🏡 RP (Place ID: 4924922222)
-- Creator: Made by Junejo (junejo18146)
-- UI Framework: Official Junejo Matte Black Standard UI (280px)
-- Universal Mobile (Delta / Codex / Fluxus) & PC Compatible
-- =================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera or Workspace:FindFirstChildWhichIsA("Camera")

-- State & Global Feature Flags
local Toggles = {
    FlyMode = false,
    WalkSpeedBoost = false,
    JumpPowerBoost = false,
    InfiniteJump = false,
    NoClip = false,
    AntiSit = false,
    AntiRagdoll = false,
    Invisible = false
}

local CustomFlySpeed = 50
local CustomSpeedValue = 16
local CustomJumpPowerValue = 50

-- Forward Declarations
local startFlying
local stopFlying
local applyPlayerPhysics
local UpdateCharacterSpeed
local UpdateCharacterJump

-- =================================================================
-- BULLETPROOF GUI PARENT RESOLVER (Instant 0s Rendering Mobile & PC)
-- =================================================================
local function getGuiParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then return pg end
    local okCore, core = pcall(function() return game:GetService("CoreGui") end)
    if okCore and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui", 5)
end

local guiParent = getGuiParent()

-- Clean all previous UI instances safely
pcall(function()
    for _, name in ipairs({"JunejoHubUI_Brookhaven", "RobloxScriptUI_Badshah_Brookhaven", "BrookhavenMasterUI"}) do
        if guiParent and guiParent:FindFirstChild(name) then pcall(function() guiParent[name]:Destroy() end) end
        pcall(function()
            if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        end)
        pcall(function()
            local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if pg and pg:FindFirstChild(name) then pg[name]:Destroy() end
        end)
    end
end)

-- =================================================================
-- OFFICIAL JUNEJO STANDARD UI (MATTE BLACK 280PX)
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_Brookhaven"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
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
TitleLabel.Text = "BROOKHAVEN RP"
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
    if stopFlying then stopFlying() end
    ScreenGui:Destroy()
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Content Scrolling Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 1, -74)
ContentFrame.Position = UDim2.new(0, 12, 0, 36)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
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

    return function(val)
        Toggles[configKey] = val
        CheckMark.BackgroundTransparency = val and 0 or 1
    end
end

-- Helper function for Action Buttons
local function AddActionRow(text, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = Row
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Btn
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(45, 45, 55)
    Stroke.Thickness = 1
    Stroke.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

-- =================================================================
-- POPULATE UI FEATURES
-- =================================================================

-- 1. Smooth Fly Toggle with Integrated Speed Pill (- / +)
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
FlyLabel.Text = "Smooth Fly"
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

local MarkCorner1 = Instance.new("UICorner")
MarkCorner1.CornerRadius = UDim.new(0, 2)
MarkCorner1.Parent = FlyCheckMark

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

local FlySpeedDisplay = Instance.new("TextLabel")
FlySpeedDisplay.Size = UDim2.new(1, -44, 1, 0)
FlySpeedDisplay.Position = UDim2.new(0, 22, 0, 0)
FlySpeedDisplay.BackgroundTransparency = 1
FlySpeedDisplay.Text = tostring(CustomFlySpeed)
FlySpeedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
FlySpeedDisplay.TextSize = 11
FlySpeedDisplay.Font = Enum.Font.GothamBold
FlySpeedDisplay.Parent = FlyControlFrame

local FlyPlusBtn = Instance.new("TextButton")
FlyPlusBtn.Size = UDim2.new(0, 22, 1, 0)
FlyPlusBtn.Position = UDim2.new(1, -22, 0, 0)
FlyPlusBtn.BackgroundTransparency = 1
FlyPlusBtn.Text = "+"
FlyPlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
FlyPlusBtn.TextSize = 14
FlyPlusBtn.Font = Enum.Font.GothamBold
FlyPlusBtn.Parent = FlyControlFrame

FlyToggleBtn.MouseButton1Click:Connect(function()
    Toggles.FlyMode = not Toggles.FlyMode
    FlyCheckMark.BackgroundTransparency = Toggles.FlyMode and 0 or 1
    if Toggles.FlyMode then
        if startFlying then startFlying() end
    else
        if stopFlying then stopFlying() end
    end
end)

FlyMinusBtn.MouseButton1Click:Connect(function()
    CustomFlySpeed = math.max(10, CustomFlySpeed - 10)
    FlySpeedDisplay.Text = tostring(CustomFlySpeed)
end)

FlyPlusBtn.MouseButton1Click:Connect(function()
    CustomFlySpeed = math.min(250, CustomFlySpeed + 10)
    FlySpeedDisplay.Text = tostring(CustomFlySpeed)
end)

-- 2. Integrated WalkSpeed Row with Pill Adjuster (- / +)
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

local MarkCorner2 = Instance.new("UICorner")
MarkCorner2.CornerRadius = UDim.new(0, 2)
MarkCorner2.Parent = SpeedCheckMark

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

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
    if UpdateCharacterSpeed then UpdateCharacterSpeed() end
end)

MinusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.max(16, CustomSpeedValue - 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    if UpdateCharacterSpeed then UpdateCharacterSpeed() end
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(250, CustomSpeedValue + 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    if UpdateCharacterSpeed then UpdateCharacterSpeed() end
end)

-- 3. Integrated JumpPower Row with Pill Adjuster (- / +)
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
JumpLabel.Text = "JumpPower"
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

local MarkCorner3 = Instance.new("UICorner")
MarkCorner3.CornerRadius = UDim.new(0, 2)
MarkCorner3.Parent = JumpCheckMark

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
JumpDisplay.Text = tostring(CustomJumpPowerValue)
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

JumpToggleBtn.MouseButton1Click:Connect(function()
    Toggles.JumpPowerBoost = not Toggles.JumpPowerBoost
    JumpCheckMark.BackgroundTransparency = Toggles.JumpPowerBoost and 0 or 1
    if UpdateCharacterJump then UpdateCharacterJump() end
end)

JumpMinusBtn.MouseButton1Click:Connect(function()
    CustomJumpPowerValue = math.max(50, CustomJumpPowerValue - 15)
    JumpDisplay.Text = tostring(CustomJumpPowerValue)
    if UpdateCharacterJump then UpdateCharacterJump() end
end)

JumpPlusBtn.MouseButton1Click:Connect(function()
    CustomJumpPowerValue = math.min(300, CustomJumpPowerValue + 15)
    JumpDisplay.Text = tostring(CustomJumpPowerValue)
    if UpdateCharacterJump then UpdateCharacterJump() end
end)

-- 4. Infinite Jump Toggle
AddToggleRow("Infinite Jump", "InfiniteJump")

-- 5. Noclip (Pass Walls) Toggle
AddToggleRow("Noclip (Pass Walls)", "NoClip")

-- 6. Anti-Sit Mode Toggle
AddToggleRow("Anti-Sit Mode", "AntiSit", function(state)
    if applyPlayerPhysics then applyPlayerPhysics() end
end)

-- 7. Anti-Ragdoll / Stabilizer Toggle
AddToggleRow("Anti-Ragdoll / Stabilizer", "AntiRagdoll")

-- 8. Ghost / Invisible Mode Toggle
AddToggleRow("Ghost / Invisible Mode", "Invisible", function(state)
    local char = LocalPlayer.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then
                p.Transparency = state and 0.8 or 0
            end
        end
    end
end)

-- 9. Reset Character Action Button
AddActionRow("💀 Reset Character", function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end)

-- Footer
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 36)
Footer.Position = UDim2.new(0, 0, 1, -36)
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

-- Header Draggable Logic
local dragging, dragInput, dragStart, startPos
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

-- =================================================================
-- GAME HELPER ENGINES & PHYSICS
-- =================================================================

-- Anti-AFK Engine
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)
LocalPlayer.Idled:Connect(function()
    if VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

local function getChar()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        return hrp, hum, char
    end
    return nil, nil, nil
end

applyPlayerPhysics = function()
    local _, hum, _ = getChar()
    if hum then
        if Toggles.WalkSpeedBoost then
            hum.WalkSpeed = CustomSpeedValue
        else
            hum.WalkSpeed = 16
        end
        if Toggles.JumpPowerBoost then
            hum.UseJumpPower = true
            hum.JumpPower = CustomJumpPowerValue
        else
            hum.JumpPower = 50
        end
        if Toggles.AntiSit then
            hum.Sit = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        else
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        end
    end
end

UpdateCharacterSpeed = function()
    local _, hum, _ = getChar()
    if hum then
        if Toggles.WalkSpeedBoost then
            hum.WalkSpeed = CustomSpeedValue
        else
            hum.WalkSpeed = 16
        end
    end
end

UpdateCharacterJump = function()
    local _, hum, _ = getChar()
    if hum then
        if Toggles.JumpPowerBoost then
            hum.UseJumpPower = true
            hum.JumpPower = CustomJumpPowerValue
        else
            hum.JumpPower = 50
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.6)
    applyPlayerPhysics()
    if Toggles.Invisible then
        local _, _, char = getChar()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") or p:IsA("Decal") then
                    p.Transparency = 0.8
                end
            end
        end
    end
end)

-- Stepped Loop for Movement / Noclip / Anti-Sit / Anti-Ragdoll
RunService.Stepped:Connect(function()
    local hrp, hum, char = getChar()
    if not char then return end

    -- Noclip logic
    if Toggles.NoClip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- Anti-Sit
    if Toggles.AntiSit and hum and hum.Sit then
        hum.Sit = false
    end

    -- Anti-Ragdoll & Fling Stabilizer
    if Toggles.AntiRagdoll and hrp then
        if hrp.AssemblyLinearVelocity.Magnitude > 350 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end

    -- Continuous Speed & Jump Enforcement
    if hum then
        if Toggles.WalkSpeedBoost and hum.WalkSpeed ~= CustomSpeedValue then
            hum.WalkSpeed = CustomSpeedValue
        end
        if Toggles.JumpPowerBoost and hum.JumpPower ~= CustomJumpPowerValue then
            hum.UseJumpPower = true
            hum.JumpPower = CustomJumpPowerValue
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        local _, hum, _ = getChar()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Fly System
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyConnection = nil

startFlying = function()
    local hrp, hum, _ = getChar()
    if not hrp or not hum then return end
    hum.PlatformStand = true

    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.Parent = hrp

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.P = 9e4
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp

    if flyConnection then flyConnection:Disconnect() end

    flyConnection = RunService.RenderStepped:Connect(function()
        if not Toggles.FlyMode or not hrp or not hum then
            if stopFlying then stopFlying() end
            return
        end

        local speed = CustomFlySpeed
        local moveDir = hum.MoveDirection
        local camCFrame = Camera and Camera.CFrame or Workspace.CurrentCamera.CFrame

        flyBodyGyro.CFrame = camCFrame

        local velocity = Vector3.new(0, 0, 0)
        if moveDir.Magnitude > 0 then
            velocity = (camCFrame.LookVector * (moveDir.Z * -1) + camCFrame.RightVector * moveDir.X).Unit * speed
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity = velocity + Vector3.new(0, speed, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            velocity = velocity - Vector3.new(0, speed, 0)
        end

        flyBodyVelocity.Velocity = velocity
    end)
end

stopFlying = function()
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    local _, hum, _ = getChar()
    if hum then hum.PlatformStand = false end
end
