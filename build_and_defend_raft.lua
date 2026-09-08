-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - BUILD & DEFEND RAFT ⛵
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- Universal Compatibility (Mobile Delta / Fluxus / Codex & PC)
-- ====================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    while not LocalPlayer do
        LocalPlayer = Players.LocalPlayer
        task.wait(0.05)
    end
end

-- Clean old UI instances safely across CoreGui, gethui and PlayerGui
pcall(function()
    for _, name in ipairs({"JunejoHubUI_BuildDefendRaft", "RaftScriptUI", "JunejoRaftHub"}) do
        pcall(function()
            if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        end)
        pcall(function()
            if gethui and gethui():FindFirstChild(name) then gethui()[name]:Destroy() end
        end)
        pcall(function()
            local pg = LocalPlayer and (LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:FindFirstChildOfClass("PlayerGui"))
            if pg and pg:FindFirstChild(name) then pg[name]:Destroy() end
        end)
    end
end)

-- Global Configuration & State
local Toggles = {
    AutoEnemyDetector = false,
    WalkSpeedBoost = false,
    JumpPowerBoost = false
}

local CustomSpeedValue = 100
local CustomJumpPower = 120
local ActiveHighlights = {}

-- Safe Character Check
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- Speed & Jump Update Helpers
local function UpdateCharacterSpeed()
    pcall(function()
        if isAlive() then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = Toggles.WalkSpeedBoost and CustomSpeedValue or 16
            end
        end
    end)
end

local function UpdateCharacterJump()
    pcall(function()
        if isAlive() then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if Toggles.JumpPowerBoost then
                    hum.UseJumpPower = true
                    hum.JumpPower = CustomJumpPower
                else
                    hum.UseJumpPower = true
                    hum.JumpPower = 50
                end
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateCharacterSpeed()
    UpdateCharacterJump()
end)

-- Screen Notification Helper
local function ShowNotification(title, message)
    pcall(function()
        local sg = CoreGui:FindFirstChild("JunejoHubUI_BuildDefendRaft") or (LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("JunejoHubUI_BuildDefendRaft"))
        if not sg then return end

        local oldNotify = sg:FindFirstChild("JunejoToast")
        if oldNotify then oldNotify:Destroy() end

        local Toast = Instance.new("Frame")
        Toast.Name = "JunejoToast"
        Toast.Size = UDim2.new(0, 260, 0, 42)
        Toast.Position = UDim2.new(0.5, -130, 0.12, 0)
        Toast.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        Toast.BorderSizePixel = 0
        Toast.ZIndex = 999
        Toast.Parent = sg

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 8)
        ToastCorner.Parent = Toast

        local ToastStroke = Instance.new("UIStroke")
        ToastStroke.Color = Color3.fromRGB(60, 60, 80)
        ToastStroke.Thickness = 1.2
        ToastStroke.Parent = Toast

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -12, 0, 16)
        TitleLbl.Position = UDim2.new(0, 8, 0, 4)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
        TitleLbl.TextSize = 11
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.ZIndex = 1000
        TitleLbl.Parent = Toast

        local MsgLbl = Instance.new("TextLabel")
        MsgLbl.Size = UDim2.new(1, -12, 0, 16)
        MsgLbl.Position = UDim2.new(0, 8, 0, 20)
        MsgLbl.BackgroundTransparency = 1
        MsgLbl.Text = message
        MsgLbl.TextColor3 = Color3.fromRGB(230, 230, 240)
        MsgLbl.TextSize = 10
        MsgLbl.Font = Enum.Font.GothamMedium
        MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
        MsgLbl.ZIndex = 1000
        MsgLbl.Parent = Toast

        task.delay(3, function()
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

-- ====================================================
-- BACKEND ACTIONS
-- ====================================================

-- 1. Teleport To Raft
local function TeleportToRaftAction()
    pcall(function()
        if not isAlive() then return end
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local foundTarget = nil

        -- Search Method 1: Check Player Rafts / Islands in Workspace
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") or v:IsA("Folder") then
                local name = v.Name:lower()
                if (name:find(LocalPlayer.Name:lower()) or name:find(tostring(LocalPlayer.UserId))) and (name:find("raft") or name:find("island") or name:find("plot") or name:find("base")) then
                    foundTarget = v:GetPivot()
                    break
                end
            end
        end

        -- Search Method 2: Spawn Location / Team Spawn
        if not foundTarget then
            if LocalPlayer.RespawnLocation then
                foundTarget = LocalPlayer.RespawnLocation.CFrame
            else
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("SpawnLocation") and (obj.Name:lower():find("raft") or obj.Name:lower():find("player")) then
                        foundTarget = obj.CFrame
                        break
                    end
                end
            end
        end

        -- Execute Teleport
        if foundTarget then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = foundTarget + Vector3.new(0, 6, 0)
            ShowNotification("Teleport Raft", "Successfully teleported to your raft!")
        else
            ShowNotification("Teleport Raft", "Could not locate your raft/base position.")
        end
    end)
end

-- 2. Redeem Codes & Daily Rewards
local function RedeemCodesAndGiftsAction()
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
        local redeemRemote = remotes:FindFirstChild("RedeemCode") or remotes:FindFirstChild("ClaimDaily") or remotes:FindFirstChild("ClaimReward")
        if redeemRemote then
            local codes = {"RELEASE", "RAFT", "BUILD", "DEFEND", "500LIKES", "1KLIKES"}
            for _, c in ipairs(codes) do
                pcall(function() redeemRemote:FireServer(c) end)
                task.wait(0.08)
            end
            pcall(function() redeemRemote:FireServer() end)
            ShowNotification("Gift & Codes", "Attempted to redeem codes & claim rewards!")
        else
            ShowNotification("Redeem", "No redeem remote found.")
        end
    end)
end

-- 3. Enemy Detector ESP Loop
RunService.RenderStepped:Connect(function()
    if Toggles.AutoEnemyDetector then
        for _, obj in ipairs(Workspace:GetChildren()) do
            local isEnemy = (obj:FindFirstChild("Humanoid") or obj.Name:lower():find("enemy")) and obj ~= LocalPlayer.Character
            if isEnemy then
                if not obj:FindFirstChild("JunejoRaftHighlight") then
                    pcall(function()
                        local hl = Instance.new("Highlight")
                        hl.Name = "JunejoRaftHighlight"
                        hl.FillColor = Color3.fromRGB(255, 50, 50)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.4
                        hl.OutlineTransparency = 0
                        hl.Parent = obj
                        table.insert(ActiveHighlights, hl)
                    end)
                end
            end
        end
    else
        if #ActiveHighlights > 0 then
            for _, hl in ipairs(ActiveHighlights) do
                pcall(function()
                    if hl and hl.Parent then hl:Destroy() end
                end)
            end
            ActiveHighlights = {}
        end
    end
end)

-- ====================================================
-- OFFICIAL JUNEJO COMPACT UI (280px Standard)
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_BuildDefendRaft"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local isParented = false
pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
        if ScreenGui.Parent then isParented = true end
    end
end)
if not isParented then
    pcall(function()
        ScreenGui.Parent = CoreGui
        if ScreenGui.Parent then isParented = true end
    end)
end
if not isParented then
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
        if pg then
            ScreenGui.Parent = pg
            isParented = true
        end
    end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 235)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -117)
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

-- Header Draggable Logic
local function enableHeaderDrag(dragHandle, targetFrame)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
enableHeaderDrag(Header, MainFrame)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "BUILD & DEFEND RAFT ⛵"
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

-- Scrollable Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -16, 0, 155)
ContentFrame.Position = UDim2.new(0, 10, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 80)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper Function: Add Flat Toggle Row
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 23)
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
    
    local lastClick = 0
    RowBtn.MouseButton1Click:Connect(function()
        local now = os.clock()
        if now - lastClick < 0.12 then return end
        lastClick = now
        Toggles[configKey] = not Toggles[configKey]
        CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
        if callback then callback(Toggles[configKey]) end
    end)
end

-- Helper Function: Add Action Button
local function AddActionButton(text, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 24)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.Parent = Row
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Btn
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn
    
    local lastClick = 0
    Btn.MouseButton1Click:Connect(function()
        local now = os.clock()
        if now - lastClick < 0.25 then return end
        lastClick = now
        if callback then callback(Btn) end
    end)
end

-- ====================================================
-- ROWS CONFIGURATION
-- ====================================================

-- 1. Teleport to Raft Action Button
AddActionButton("🛥️ Teleport to Raft", function(btn)
    btn.Text = "⏳ Teleporting..."
    TeleportToRaftAction()
    task.delay(1.2, function()
        btn.Text = "🛥️ Teleport to Raft"
    end)
end)

-- 2. Redeem Codes & Gifts Action Button
AddActionButton("🎁 Redeem Codes & Gifts", function(btn)
    btn.Text = "⏳ Redeeming..."
    RedeemCodesAndGiftsAction()
    task.delay(1.2, function()
        btn.Text = "🎁 Redeem Codes & Gifts"
    end)
end)

-- 3. Auto Enemy Detector Toggle
AddToggleRow("Auto Enemy Detector", "AutoEnemyDetector", function(state) end)

-- 4. Integrated WalkSpeed Row with - / + Pill Controller
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, -6, 0, 23)
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

local SpeedMarkCorner = Instance.new("UICorner")
SpeedMarkCorner.CornerRadius = UDim.new(0, 2)
SpeedMarkCorner.Parent = SpeedCheckMark

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
    CustomSpeedValue = math.min(300, CustomSpeedValue + 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

-- 5. Integrated JumpPower Row with - / + Pill Controller
local JumpRow = Instance.new("Frame")
JumpRow.Size = UDim2.new(1, -6, 0, 23)
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

local JumpMarkCorner = Instance.new("UICorner")
JumpMarkCorner.CornerRadius = UDim.new(0, 2)
JumpMarkCorner.Parent = JumpCheckMark

JumpToggleBtn.MouseButton1Click:Connect(function()
    Toggles.JumpPowerBoost = not Toggles.JumpPowerBoost
    JumpCheckMark.BackgroundTransparency = Toggles.JumpPowerBoost and 0 or 1
    UpdateCharacterJump()
end)

local JumpControlFrame = Instance.new("Frame")
JumpControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
JumpControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
JumpControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
JumpControlFrame.BorderSizePixel = 0
JumpControlFrame.Parent = JumpRow

local JCtrlCorner = Instance.new("UICorner")
JCtrlCorner.CornerRadius = UDim.new(0, 4)
JCtrlCorner.Parent = JumpControlFrame

local JCtrlStroke = Instance.new("UIStroke")
JCtrlStroke.Color = Color3.fromRGB(45, 45, 55)
JCtrlStroke.Thickness = 1
JCtrlStroke.Parent = JumpControlFrame

local JMinusBtn = Instance.new("TextButton")
JMinusBtn.Size = UDim2.new(0, 22, 1, 0)
JMinusBtn.Position = UDim2.new(0, 0, 0, 0)
JMinusBtn.BackgroundTransparency = 1
JMinusBtn.Text = "-"
JMinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
JMinusBtn.TextSize = 14
JMinusBtn.Font = Enum.Font.GothamBold
JMinusBtn.Parent = JumpControlFrame

local JumpDisplay = Instance.new("TextLabel")
JumpDisplay.Size = UDim2.new(1, -44, 1, 0)
JumpDisplay.Position = UDim2.new(0, 22, 0, 0)
JumpDisplay.BackgroundTransparency = 1
JumpDisplay.Text = tostring(CustomJumpPower)
JumpDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpDisplay.TextSize = 11
JumpDisplay.Font = Enum.Font.GothamBold
JumpDisplay.Parent = JumpControlFrame

local JPlusBtn = Instance.new("TextButton")
JPlusBtn.Size = UDim2.new(0, 22, 1, 0)
JPlusBtn.Position = UDim2.new(1, -22, 0, 0)
JPlusBtn.BackgroundTransparency = 1
JPlusBtn.Text = "+"
JPlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
JPlusBtn.TextSize = 14
JPlusBtn.Font = Enum.Font.GothamBold
JPlusBtn.Parent = JumpControlFrame

JMinusBtn.MouseButton1Click:Connect(function()
    CustomJumpPower = math.max(50, CustomJumpPower - 15)
    JumpDisplay.Text = tostring(CustomJumpPower)
    UpdateCharacterJump()
end)

JPlusBtn.MouseButton1Click:Connect(function()
    CustomJumpPower = math.min(350, CustomJumpPower + 15)
    JumpDisplay.Text = tostring(CustomJumpPower)
    UpdateCharacterJump()
end)

-- ====================================================
-- FOOTER
-- ====================================================
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
