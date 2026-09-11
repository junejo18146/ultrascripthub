-- ====================================================================
-- ULTRA SCRIPT HUB - LAST STOP
-- Creator: Junejo (junejo18146)
-- Target Game: Last Stop
-- ====================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- Mouse Unlocker
RunService.RenderStepped:Connect(function()
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true
end)

-- Feature States
local State = {
    Running = true,
    AutoLootActive = false,
    LootRange = 60,
    KillAuraActive = false,
    AuraRange = 25,
    SpeedBoostActive = false,
    SpeedValue = 35,
    FullBrightActive = false,
    InfiniteJump = false,
    AntiAFK = true
}

-- Character Resolvers
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and root ~= nil
end

local function getPlayerChar()
    local char = LocalPlayer.Character
    if not char or not char.Parent then return nil, nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return char, root, hum
end

-- Universal Interaction Helpers
local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = math.huge
        prompt.RequiresLineOfSight = false
        prompt.Enabled = true

        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt, 1)
            fireproximityprompt(prompt)
        end
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
        end
    end)
end

-- Bus Resolver
local function getBusPart()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("bus") or n:find("vehicle") then
                if obj:IsA("Model") then
                    return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                elseif obj:IsA("BasePart") then
                    return obj
                end
            end
        end
    end
    return nil
end

-- ====================================================================
-- AUTOMATION ENGINES
-- ====================================================================

-- Feature 1: Teleport To Bus Action
local function teleportToBus()
    if not isAlive() then return end
    local busPart = getBusPart()
    local _, root = getPlayerChar()
    if busPart and root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.CFrame = busPart.CFrame * CFrame.new(0, 5, 0)
    end
end

-- Feature 2: Auto Loot [TP + Grab] Engine
task.spawn(function()
    while State.Running do
        task.wait(0.25)
        if State.AutoLootActive and isAlive() then
            pcall(function()
                local _, root = getPlayerChar()
                if not root then return end
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and obj.Parent then
                        local parentPart = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                        if parentPart then
                            local dist = (parentPart.Position - root.Position).Magnitude
                            if dist <= State.LootRange then
                                local originalCFrame = root.CFrame
                                root.CFrame = parentPart.CFrame * CFrame.new(0, 2, 0)
                                task.wait(0.08)
                                triggerPrompt(obj)
                                task.wait(0.08)
                                root.CFrame = originalCFrame
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Feature 3: Kill Aura Engine
task.spawn(function()
    while State.Running do
        task.wait(0.15)
        if State.KillAuraActive and isAlive() then
            pcall(function()
                local char, root, hum = getPlayerChar()
                if not root then return end
                
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then
                    local bpTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                    if bpTool and hum then 
                        hum:EquipTool(bpTool) 
                        tool = bpTool 
                    end
                end

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj ~= char then
                        local eHum = obj:FindFirstChildOfClass("Humanoid")
                        local eRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                        if eHum and eRoot and eHum.Health > 0 then
                            local name = obj.Name:lower()
                            if name:find("zombie") or name:find("enemy") or name:find("entity") or name:find("monster") then
                                if (eRoot.Position - root.Position).Magnitude <= State.AuraRange then
                                    if tool then tool:Activate() end
                                    if firetouchinterest and tool and tool:FindFirstChild("Handle") then
                                        firetouchinterest(tool.Handle, eRoot, 0)
                                        task.wait(0.01)
                                        firetouchinterest(tool.Handle, eRoot, 1)
                                    end
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

-- Feature 4: WalkSpeed Boost Enforcer
RunService.Stepped:Connect(function()
    if isAlive() and State.SpeedBoostActive then
        pcall(function()
            local _, _, hum = getPlayerChar()
            if hum then
                hum.WalkSpeed = State.SpeedValue
            end
        end)
    end
end)

local function UpdateCharacterSpeed()
    if isAlive() then
        local _, _, hum = getPlayerChar()
        if hum then
            hum.WalkSpeed = State.SpeedBoostActive and State.SpeedValue or 16
        end
    end
end

-- Feature 5: Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and isAlive() then
        local _, _, hum = getPlayerChar()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Feature 6: Fullbright / Remove Fog Engine
local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows
}

local function UpdateFullBright(enable)
    if enable then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.FogEnd = 1e10
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    end
end

task.spawn(function()
    while State.Running do
        task.wait(0.5)
        if State.FullBrightActive then
            pcall(function()
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                Lighting.Brightness = 2
                Lighting.FogEnd = 1e10
                Lighting.GlobalShadows = false
            end)
        end
    end
end)

-- Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end
end)

-- ====================================================================
-- JUNEJO OFFICIAL COMPACT SCROLLING UI (5 FEATURES VISIBLE STANDARD)
-- ====================================================================

local ExistingUI = CoreGui:FindFirstChild("JunejoHubUI") or LocalPlayer.PlayerGui:FindFirstChild("JunejoHubUI")
if ExistingUI then ExistingUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Compact Standard MainFrame (280x225px)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 225)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -112)
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

-- Header (32px)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LAST STOP 🚌"
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
    State.Running = false
    UpdateFullBright(false)
    ScreenGui:Destroy() 
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Scrollable Content Frame (Shows Exactly 5 Items at a time, Scroll for rest!)
local ScrollingContent = Instance.new("ScrollingFrame")
ScrollingContent.Name = "ScrollingContent"
ScrollingContent.Size = UDim2.new(1, -24, 0, 145)
ScrollingContent.Position = UDim2.new(0, 12, 0, 38)
ScrollingContent.BackgroundTransparency = 1
ScrollingContent.BorderSizePixel = 0
ScrollingContent.ScrollBarThickness = 3
ScrollingContent.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 85)
ScrollingContent.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingContent.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollingContent.ClipsDescendants = true
ScrollingContent.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ScrollingContent

-- Helper function for Toggle Rows
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ScrollingContent
    
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
    CheckMark.BackgroundTransparency = State[configKey] and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox
    
    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark
    
    RowBtn.MouseButton1Click:Connect(function()
        State[configKey] = not State[configKey]
        CheckMark.BackgroundTransparency = State[configKey] and 0 or 1
        if callback then callback(State[configKey]) end
    end)
end

-- 1-Click Action Row Helper
local function AddActionRow(text, btnText, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ScrollingContent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(0.38, 0, 1, 0)
    ActionBtn.Position = UDim2.new(0.62, 0, 0, 0)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ActionBtn.Text = btnText
    ActionBtn.TextColor3 = Color3.fromRGB(255, 220, 50)
    ActionBtn.TextSize = 11
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.Parent = Row

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ActionBtn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = ActionBtn

    ActionBtn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

-- Add Features to the Scrolling Frame
AddActionRow("Teleport To Bus", "Teleport", teleportToBus)
AddToggleRow("Auto Loot [TP + Grab]", "AutoLootActive")
AddToggleRow("Kill Aura (Auto Attack)", "KillAuraActive")
AddToggleRow("Fullbright / Remove Fog", "FullBrightActive", UpdateFullBright)
AddToggleRow("Infinite Jump", "InfiniteJump")

-- Integrated WalkSpeed Row with Pill Adjuster
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, -6, 0, 23)
SpeedRow.BackgroundTransparency = 1
SpeedRow.Parent = ScrollingContent

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
SpeedCheckMark.BackgroundTransparency = State.SpeedBoostActive and 0 or 1
SpeedCheckMark.BorderSizePixel = 0
SpeedCheckMark.Parent = SpeedCheckBox

local MarkCorner = Instance.new("UICorner")
MarkCorner.CornerRadius = UDim.new(0, 2)
MarkCorner.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    State.SpeedBoostActive = not State.SpeedBoostActive
    SpeedCheckMark.BackgroundTransparency = State.SpeedBoostActive and 0 or 1
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
SpeedDisplay.Text = tostring(State.SpeedValue)
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
    State.SpeedValue = math.max(16, State.SpeedValue - 10)
    SpeedDisplay.Text = tostring(State.SpeedValue)
    UpdateCharacterSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    State.SpeedValue = math.min(250, State.SpeedValue + 10)
    SpeedDisplay.Text = tostring(State.SpeedValue)
    UpdateCharacterSpeed()
end)

-- Footer (Pinned at bottom, 36px)
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
