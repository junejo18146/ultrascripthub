--[[
    JUNEJO ULTRA SCRIPT HUB - STEAL AN EGG
    Game: Steal An Egg (Roblox)
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Official UI 1 - Classic Matte Dark (#0F0F11)
    Status: Direct Standalone Executable (Key System Disabled)
--]]

-- =================================================================
-- 1. SERVICES & VARIABLES
-- =================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local State = {
    AutoSteal = false,
    AutoTreadmill = false,
    AutoHatch = false,
    InfiniteJump = false,
    WalkSpeedEnabled = false,
    WalkSpeed = 50,
    AntiAFK = true
}

local SavedBaseCFrame = nil

-- Safe UI Parent getter (compatible with Delta, Codex, Fluxus, and PC Executors)
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

-- Clean up any previous instances safely
for _, name in ipairs({"JunejoHubUI_StealAnEgg", "RobloxScriptUI_Badshah", "JunejoStealAnEggUI"}) do
    pcall(function()
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end)
end

-- Helper: Safe Alive Check
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and root ~= nil
end

-- Helper: Trigger Proximity Prompts
local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.1)
            prompt:InputHoldEnd()
        end
    end)
end

-- Anti-AFK Engine (Prevents 20-minute idle kicks)
pcall(function()
    LocalPlayer.Idled:Connect(function()
        if State.AntiAFK then
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end
    end)
end)

-- Screen Toast Notification Helper
local function ShowToast(title, message)
    pcall(function()
        local sg = UIContainer:FindFirstChild("JunejoHubUI_StealAnEgg")
        if not sg then return end

        local oldToast = sg:FindFirstChild("JunejoToast")
        if oldToast then oldToast:Destroy() end

        local Toast = Instance.new("Frame")
        Toast.Name = "JunejoToast"
        Toast.Size = UDim2.new(0, 230, 0, 36)
        Toast.Position = UDim2.new(0.5, -115, 0.08, 0)
        Toast.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        Toast.BorderSizePixel = 0
        Toast.ZIndex = 9999
        Toast.Parent = sg

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 8)
        ToastCorner.Parent = Toast

        local ToastStroke = Instance.new("UIStroke")
        ToastStroke.Color = Color3.fromRGB(50, 50, 65)
        ToastStroke.Thickness = 1
        ToastStroke.Parent = Toast

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -12, 0, 15)
        TitleLbl.Position = UDim2.new(0, 8, 0, 3)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
        TitleLbl.TextSize = 11
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.ZIndex = 10000
        TitleLbl.Parent = Toast

        local MsgLbl = Instance.new("TextLabel")
        MsgLbl.Size = UDim2.new(1, -12, 0, 15)
        MsgLbl.Position = UDim2.new(0, 8, 0, 17)
        MsgLbl.BackgroundTransparency = 1
        MsgLbl.Text = message
        MsgLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
        MsgLbl.TextSize = 10
        MsgLbl.Font = Enum.Font.GothamMedium
        MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
        MsgLbl.ZIndex = 10000
        MsgLbl.Parent = Toast

        task.delay(2.0, function()
            if Toast and Toast.Parent then
                local tween = TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                tween:Play()
                TitleLbl.TextTransparency = 1
                MsgLbl.TextTransparency = 1
                ToastStroke.Transparency = 1
                task.wait(0.35)
                if Toast then Toast:Destroy() end
            end
        end)
    end)
end

-- =================================================================
-- 2. BACKGROUND FEATURE LOOPS
-- =================================================================

-- 1. Auto Steal & Safe Teleport Engine
task.spawn(function()
    while true do
        task.wait(0.3)
        if State.AutoSteal and isAlive() then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    if not SavedBaseCFrame then
                        SavedBaseCFrame = root.CFrame
                    end

                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not State.AutoSteal then break end
                        if obj:IsA("ProximityPrompt") then
                            local parentName = string.lower(obj.Parent and obj.Parent.Name or "")
                            local actionText = string.lower(obj.ActionText or "")
                            local objText = string.lower(obj.ObjectText or "")

                            if string.find(parentName, "egg") or string.find(actionText, "steal") or string.find(actionText, "take") or string.find(objText, "egg") then
                                local eggPart = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                                if eggPart then
                                    root.CFrame = eggPart.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.1)
                                    triggerPrompt(obj)
                                    task.wait(0.1)
                                    if SavedBaseCFrame then
                                        root.CFrame = SavedBaseCFrame
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

-- 2. Auto Treadmill Train Engine
task.spawn(function()
    while true do
        task.wait(0.1)
        if State.AutoTreadmill and isAlive() then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not State.AutoTreadmill then break end
                        local oName = string.lower(obj.Name)
                        if string.find(oName, "treadmill") or string.find(oName, "train") or string.find(oName, "speedpad") then
                            if obj:IsA("TouchTransmitter") and obj.Parent then
                                if firetouchinterest then
                                    firetouchinterest(obj.Parent, root, 0)
                                    task.wait()
                                    firetouchinterest(obj.Parent, root, 1)
                                end
                            elseif obj:IsA("ProximityPrompt") then
                                triggerPrompt(obj)
                            end
                        end
                    end

                    for _, container in ipairs({ReplicatedStorage, LocalPlayer:FindFirstChild("PlayerGui")}) do
                        if container then
                            for _, remote in ipairs(container:GetDescendants()) do
                                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                    local rName = string.lower(remote.Name)
                                    if string.find(rName, "train") or string.find(rName, "treadmill") or string.find(rName, "addspeed") or string.find(rName, "speed") then
                                        pcall(function()
                                            if remote:IsA("RemoteEvent") then
                                                remote:FireServer()
                                                remote:FireServer(true)
                                            else
                                                remote:InvokeServer()
                                            end
                                        end)
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

-- 3. Auto Hatch & Place Engine
task.spawn(function()
    while true do
        task.wait(0.4)
        if State.AutoHatch then
            pcall(function()
                for _, container in ipairs({ReplicatedStorage, LocalPlayer:FindFirstChild("PlayerGui"), Workspace}) do
                    if container then
                        for _, remote in ipairs(container:GetDescendants()) do
                            if not State.AutoHatch then break end
                            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                local rName = string.lower(remote.Name)
                                if string.find(rName, "hatch") or string.find(rName, "place") or string.find(rName, "openegg") or string.find(rName, "egghatch") then
                                    pcall(function()
                                        if remote:IsA("RemoteEvent") then
                                            remote:FireServer()
                                            remote:FireServer(true)
                                            remote:FireServer(1)
                                        else
                                            remote:InvokeServer()
                                            remote:InvokeServer(true)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not State.AutoHatch then break end
                    if obj:IsA("ProximityPrompt") then
                        local aText = string.lower(obj.ActionText or "")
                        local oText = string.lower(obj.ObjectText or "")
                        if string.find(aText, "hatch") or string.find(aText, "place") or string.find(oText, "hatch") then
                            triggerPrompt(obj)
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. WalkSpeed Modifier Loop
RunService.RenderStepped:Connect(function()
    pcall(function()
        if State.WalkSpeedEnabled and isAlive() then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and State.WalkSpeed and hum.WalkSpeed ~= State.WalkSpeed then
                hum.WalkSpeed = State.WalkSpeed
            end
        end
    end)
end)

-- 5. Infinite Air Jump System
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and isAlive() then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- =================================================================
-- 3. UI GENERATOR ENGINE (JUNEJO UI 1 - CLASSIC MATTE DARK #0F0F11)
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_StealAnEgg"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = UIContainer

-- Main Container (280px width, 240px height)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 240)
MainFrame.Position = UDim2.new(0.5, -140, 0.45, -120)
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

-- Header Bar (32px)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -44, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "STEAL AN EGG"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -32, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "x"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 175)
CloseButton.TextSize = 15
CloseButton.Font = Enum.Font.GothamMedium
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local HeaderDivider = Instance.new("Frame")
HeaderDivider.Name = "HeaderDivider"
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position = UDim2.new(0, 0, 0, 32)
HeaderDivider.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
HeaderDivider.BorderSizePixel = 0
HeaderDivider.Parent = MainFrame

-- Smooth Dragging System (Desktop & Mobile Touch)
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
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Content Scroll Frame
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"
ContentScroll.Size = UDim2.new(1, 0, 0, 172)
ContentScroll.Position = UDim2.new(0, 0, 0, 34)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 80)
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.ScrollingDirection = Enum.ScrollingDirection.Y
ContentScroll.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.Parent = ContentScroll

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 6)
ContentPadding.PaddingBottom = UDim.new(0, 6)
ContentPadding.PaddingLeft = UDim.new(0, 14)
ContentPadding.PaddingRight = UDim.new(0, 14)
ContentPadding.Parent = ContentScroll

-- Helper: Create Feature Toggle Row (26px height, flat borderless row with rounded-square checkbox)
local function CreateToggleRow(order, name, key, onToggle)
    local Row = Instance.new("Frame")
    Row.Name = name .. "Row"
    Row.Size = UDim2.new(1, 0, 0, 26)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.Parent = ContentScroll

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, -28, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Checkbox = Instance.new("TextButton")
    Checkbox.Name = "Checkbox"
    Checkbox.Size = UDim2.new(0, 18, 0, 18)
    Checkbox.Position = UDim2.new(1, -18, 0.5, -9)
    Checkbox.BackgroundColor3 = State[key] and Color3.fromRGB(35, 35, 45) or Color3.fromRGB(27, 27, 32)
    Checkbox.BorderSizePixel = 0
    Checkbox.Text = ""
    Checkbox.Parent = Row

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = Checkbox

    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color = State[key] and Color3.fromRGB(80, 80, 100) or Color3.fromRGB(45, 45, 55)
    BoxStroke.Thickness = 1
    BoxStroke.Parent = Checkbox

    local CheckMark = Instance.new("Frame")
    CheckMark.Name = "CheckMark"
    CheckMark.Size = UDim2.new(0, 8, 0, 8)
    CheckMark.Position = UDim2.new(0.5, -4, 0.5, -4)
    CheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CheckMark.BorderSizePixel = 0
    CheckMark.Visible = State[key]
    CheckMark.Parent = Checkbox

    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark

    local function ToggleState()
        State[key] = not State[key]
        CheckMark.Visible = State[key]
        if State[key] then
            Checkbox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            BoxStroke.Color = Color3.fromRGB(80, 80, 100)
        else
            Checkbox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
            BoxStroke.Color = Color3.fromRGB(45, 45, 55)
        end
        if onToggle then onToggle(State[key]) end
        ShowToast(name, State[key] and "Enabled" or "Disabled")
    end

    Checkbox.MouseButton1Click:Connect(ToggleState)
    return Row
end

-- =================================================================
-- ROWS DEFINITION (OFFICIAL JUNEJO UI 1 STANDARD)
-- =================================================================

-- 1. Auto Steal & Return
CreateToggleRow(1, "Auto Steal & Return", "AutoSteal", function(state)
    if state and isAlive() then
        SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

-- 2. Auto Treadmill Train
CreateToggleRow(2, "Auto Treadmill Train", "AutoTreadmill")

-- 3. Auto Hatch & Place
CreateToggleRow(3, "Auto Hatch & Place", "AutoHatch")

-- 4. Infinite Jump
CreateToggleRow(4, "Infinite Jump", "InfiniteJump")

-- 5. WalkSpeed Row (Checkbox + Pill Stepper: [ - 50 + ])
local SpeedRow = Instance.new("Frame")
SpeedRow.Name = "SpeedRow"
SpeedRow.Size = UDim2.new(1, 0, 0, 26)
SpeedRow.BackgroundTransparency = 1
SpeedRow.LayoutOrder = 5
SpeedRow.Parent = ContentScroll

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(1, -125, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed"
SpeedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamMedium
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedRow

local SpeedCheckbox = Instance.new("TextButton")
SpeedCheckbox.Name = "SpeedCheckbox"
SpeedCheckbox.Size = UDim2.new(0, 18, 0, 18)
SpeedCheckbox.Position = UDim2.new(1, -120, 0.5, -9)
SpeedCheckbox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
SpeedCheckbox.BorderSizePixel = 0
SpeedCheckbox.Text = ""
SpeedCheckbox.Parent = SpeedRow

local SpeedBoxCorner = Instance.new("UICorner")
SpeedBoxCorner.CornerRadius = UDim.new(0, 4)
SpeedBoxCorner.Parent = SpeedCheckbox

local SpeedBoxStroke = Instance.new("UIStroke")
SpeedBoxStroke.Color = Color3.fromRGB(45, 45, 55)
SpeedBoxStroke.Thickness = 1
SpeedBoxStroke.Parent = SpeedCheckbox

local SpeedMark = Instance.new("Frame")
SpeedMark.Name = "SpeedMark"
SpeedMark.Size = UDim2.new(0, 8, 0, 8)
SpeedMark.Position = UDim2.new(0.5, -4, 0.5, -4)
SpeedMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedMark.BorderSizePixel = 0
SpeedMark.Visible = State.WalkSpeedEnabled
SpeedMark.Parent = SpeedCheckbox

local SpeedMarkCorner = Instance.new("UICorner")
SpeedMarkCorner.CornerRadius = UDim.new(0, 2)
SpeedMarkCorner.Parent = SpeedMark

SpeedCheckbox.MouseButton1Click:Connect(function()
    State.WalkSpeedEnabled = not State.WalkSpeedEnabled
    SpeedMark.Visible = State.WalkSpeedEnabled
    if State.WalkSpeedEnabled then
        SpeedCheckbox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        SpeedBoxStroke.Color = Color3.fromRGB(80, 80, 100)
    else
        SpeedCheckbox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
        SpeedBoxStroke.Color = Color3.fromRGB(45, 45, 55)
        if isAlive() then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
    ShowToast("WalkSpeed", State.WalkSpeedEnabled and ("Enabled (" .. State.WalkSpeed .. ")") or "Disabled")
end)

local StepperPill = Instance.new("Frame")
StepperPill.Name = "StepperPill"
StepperPill.Size = UDim2.new(0, 95, 0, 22)
StepperPill.Position = UDim2.new(1, -95, 0.5, -11)
StepperPill.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
StepperPill.BorderSizePixel = 0
StepperPill.Parent = SpeedRow

local PillCorner = Instance.new("UICorner")
PillCorner.CornerRadius = UDim.new(0, 5)
PillCorner.Parent = StepperPill

local PillStroke = Instance.new("UIStroke")
PillStroke.Color = Color3.fromRGB(45, 45, 55)
PillStroke.Thickness = 1
PillStroke.Parent = StepperPill

local MinusBtn = Instance.new("TextButton")
MinusBtn.Name = "MinusBtn"
MinusBtn.Size = UDim2.new(0, 26, 1, 0)
MinusBtn.BackgroundTransparency = 1
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
MinusBtn.TextSize = 13
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Parent = StepperPill

local SpeedValLbl = Instance.new("TextLabel")
SpeedValLbl.Name = "SpeedValLbl"
SpeedValLbl.Size = UDim2.new(1, -52, 1, 0)
SpeedValLbl.Position = UDim2.new(0, 26, 0, 0)
SpeedValLbl.BackgroundTransparency = 1
SpeedValLbl.Text = tostring(State.WalkSpeed)
SpeedValLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedValLbl.TextSize = 11
SpeedValLbl.Font = Enum.Font.GothamBold
SpeedValLbl.Parent = StepperPill

local PlusBtn = Instance.new("TextButton")
PlusBtn.Name = "PlusBtn"
PlusBtn.Size = UDim2.new(0, 26, 1, 0)
PlusBtn.Position = UDim2.new(1, -26, 0, 0)
PlusBtn.BackgroundTransparency = 1
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
PlusBtn.TextSize = 13
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Parent = StepperPill

MinusBtn.MouseButton1Click:Connect(function()
    State.WalkSpeed = math.max(16, State.WalkSpeed - 10)
    SpeedValLbl.Text = tostring(State.WalkSpeed)
    if State.WalkSpeedEnabled and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = State.WalkSpeed end
    end
end)

PlusBtn.MouseButton1Click:Connect(function()
    State.WalkSpeed = math.min(250, State.WalkSpeed + 10)
    SpeedValLbl.Text = tostring(State.WalkSpeed)
    if State.WalkSpeedEnabled and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = State.WalkSpeed end
    end
end)

-- Mandatory Centered Branding Footer (UI 1 Standard)
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 34)
Footer.Position = UDim2.new(0, 0, 1, -34)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterDivider = Instance.new("Frame")
FooterDivider.Name = "FooterDivider"
FooterDivider.Size = UDim2.new(1, 0, 0, 1)
FooterDivider.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
FooterDivider.BorderSizePixel = 0
FooterDivider.Parent = Footer

local HubTitle = Instance.new("TextLabel")
HubTitle.Name = "HubTitle"
HubTitle.Size = UDim2.new(1, 0, 0, 15)
HubTitle.Position = UDim2.new(0, 0, 0, 2)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "ULTRA SCRIPT HUB"
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 11
HubTitle.Font = Enum.Font.GothamBold
HubTitle.Parent = Footer

local CreatorSubtitle = Instance.new("TextLabel")
CreatorSubtitle.Name = "CreatorSubtitle"
CreatorSubtitle.Size = UDim2.new(1, 0, 0, 14)
CreatorSubtitle.Position = UDim2.new(0, 0, 0, 17)
CreatorSubtitle.BackgroundTransparency = 1
CreatorSubtitle.Text = "Made by Junejo"
CreatorSubtitle.TextColor3 = Color3.fromRGB(136, 136, 153)
CreatorSubtitle.TextSize = 9
CreatorSubtitle.Font = Enum.Font.GothamMedium
CreatorSubtitle.Parent = Footer

ShowToast("ULTRA SCRIPT HUB", "Steal An Egg Loaded!")
print("[Junejo Hub] Steal An Egg initialized with UI 1 Classic Matte Dark!")
