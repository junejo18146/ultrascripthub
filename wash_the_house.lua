--[[
    Junejo Ultra Script Hub - Wash the House (Compact 2-Feature Edition)
    Target Game: Wash the House (Roblox)
    Created for junejo18146
--]]

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Safe UI Parent getter (compatible with all Roblox executors)
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

-- Cleanup previous GUI instances
for _, name in ipairs({"JunejoHubUI_WashTheHouse"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

----------------------------------------------------
-- COMPACT MAIN HUB UI (300x260)
----------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_WashTheHouse"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = UIContainer
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 260)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -130)
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

-- Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -45, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "WASH THE HOUSE"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 170)
CloseButton.TextSize = 15
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Make Draggable
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

-- Content Container
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -28, 1, -80)
Content.Position = UDim2.new(0, 14, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)
UIList.Parent = Content

-- Footer Frame
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 36)
Footer.Position = UDim2.new(0, 0, 1, -36)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 16)
FooterTitle.Position = UDim2.new(0, 0, 0, 2)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 14
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 14)
FooterSub.Position = UDim2.new(0, 0, 0, 18)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 11
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.Parent = Footer

----------------------------------------------------
-- 2 SPECIFIC FEATURES LOGIC
----------------------------------------------------
local FeatureStates = {
    Speed = false,
    AutoClean = false
}

local CustomSpeedValue = 100

local function CreateToggleRow(text, key)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 34)
    Row.BackgroundTransparency = 1
    Row.Parent = Content
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local CheckBox = Instance.new("TextButton")
    CheckBox.Size = UDim2.new(0, 28, 0, 28)
    CheckBox.Position = UDim2.new(1, -28, 0.5, -14)
    CheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    CheckBox.BorderSizePixel = 0
    CheckBox.Text = ""
    CheckBox.Parent = Row
    
    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 6)
    CheckCorner.Parent = CheckBox
    
    local CheckStroke = Instance.new("UIStroke")
    CheckStroke.Color = Color3.fromRGB(45, 45, 55)
    CheckStroke.Thickness = 1.5
    CheckStroke.Parent = CheckBox
    
    local CheckMark = Instance.new("Frame")
    CheckMark.Size = UDim2.new(0.6, 0, 0.6, 0)
    CheckMark.Position = UDim2.new(0.2, 0, 0.2, 0)
    CheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CheckMark.BackgroundTransparency = 1
    CheckMark.Parent = CheckBox
    
    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 4)
    MarkCorner.Parent = CheckMark
    
    CheckBox.MouseButton1Click:Connect(function()
        FeatureStates[key] = not FeatureStates[key]
        CheckMark.BackgroundTransparency = FeatureStates[key] and 0 or 1
    end)
end

-- 1. FEATURE: AUTO CLEAN DIRT
CreateToggleRow("Auto Clean Dirt", "AutoClean")

-- 2. FEATURE: SPEED MANAGEMENT INPUT LINE & TOGGLE
local SpeedControlRow = Instance.new("Frame")
SpeedControlRow.Name = "SpeedControlRow"
SpeedControlRow.Size = UDim2.new(1, 0, 0, 36)
SpeedControlRow.BackgroundTransparency = 1
SpeedControlRow.Parent = Content

local SpeedTextBox = Instance.new("TextBox")
SpeedTextBox.Name = "SpeedTextBox"
SpeedTextBox.Size = UDim2.new(0.64, 0, 1, 0)
SpeedTextBox.Position = UDim2.new(0, 0, 0, 0)
SpeedTextBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
SpeedTextBox.BorderSizePixel = 0
SpeedTextBox.PlaceholderText = "Enter Speed..."
SpeedTextBox.Text = "100"
SpeedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedTextBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 140)
SpeedTextBox.TextSize = 12
SpeedTextBox.Font = Enum.Font.GothamMedium
SpeedTextBox.ClearTextOnFocus = false
SpeedTextBox.Parent = SpeedControlRow

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedTextBox

local SpeedStroke = Instance.new("UIStroke")
SpeedStroke.Color = Color3.fromRGB(45, 45, 55)
SpeedStroke.Thickness = 1.5
SpeedStroke.Parent = SpeedTextBox

local SetSpeedButton = Instance.new("TextButton")
SetSpeedButton.Name = "SetSpeedButton"
SetSpeedButton.Size = UDim2.new(0.32, 0, 1, 0)
SetSpeedButton.Position = UDim2.new(0.68, 0, 0, 0)
SetSpeedButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SetSpeedButton.BorderSizePixel = 0
SetSpeedButton.Text = "SET SPEED"
SetSpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SetSpeedButton.TextSize = 11
SetSpeedButton.Font = Enum.Font.GothamBold
SetSpeedButton.Parent = SpeedControlRow

local SetBtnCorner = Instance.new("UICorner")
SetBtnCorner.CornerRadius = UDim.new(0, 6)
SetBtnCorner.Parent = SetSpeedButton

SetSpeedButton.MouseButton1Click:Connect(function()
    local num = tonumber(SpeedTextBox.Text)
    if num then CustomSpeedValue = num end
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = CustomSpeedValue end
    end)
    FeatureStates.Speed = true
end)

CreateToggleRow("Enable Speed Boost", "Speed")

-- Speed Boost Stepped Loop
RunService.Stepped:Connect(function()
    if FeatureStates.Speed then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = CustomSpeedValue end
        end)
    end
end)

-- Auto Clean Dirt Background Loop
task.spawn(function()
    while true do
        task.wait(0.3)
        if FeatureStates.AutoClean then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Texture") or obj:IsA("Decal") then
                        local n = obj.Name:lower()
                        if n:find("dirt") or n:find("stain") or n:find("clean") or n:find("grime") or n:find("mess") or n:find("spot") then
                            if obj:IsA("Texture") or obj:IsA("Decal") then
                                obj.Transparency = 1
                            elseif obj:IsA("BasePart") then
                                obj.Transparency = 1
                                if firetouchinterest and hrp then
                                    firetouchinterest(hrp, obj, 0)
                                    firetouchinterest(hrp, obj, 1)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)
