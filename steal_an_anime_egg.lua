-- ====================================================================
-- ULTRA SCRIPT HUB - STEAL AN ANIME EGG
-- Creator: Junejo (junejo18146)
-- Target Game: Steal An Anime Egg (Place ID: 76377501906469)
-- ====================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- Feature States
local Toggles = {
    AutoSteal = false,
    InstantPrompt = false,
    AutoDeposit = false,
    AutoCollectCash = false,
    AutoHatch = false,
    AutoRebirth = false,
    AutoAttackBoss = false,
    EggESP = false,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

local CustomSpeedValue = 32
local ESPObjects = {}

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Speed updater
local function UpdateCharacterSpeed()
    if Humanoid then
        if Toggles.WalkSpeedBoost then
            Humanoid.WalkSpeed = CustomSpeedValue
        else
            Humanoid.WalkSpeed = 16
        end
    end
end

RunService.Heartbeat:Connect(function()
    if Toggles.WalkSpeedBoost and Humanoid and Humanoid.WalkSpeed ~= CustomSpeedValue then
        Humanoid.WalkSpeed = CustomSpeedValue
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Instant Steal Prompts
task.spawn(function()
    while true do
        if Toggles.InstantPrompt then
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 0
                    prompt.MaxActivationDistance = 35
                end
            end
        end
        task.wait(1)
    end
end)

-- Helper: Get Player Base / Plot
local function GetPlayerBase()
    local basesFolder = Workspace:FindFirstChild("Bases") or Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("PlayerBases")
    if basesFolder then
        for _, base in ipairs(basesFolder:GetChildren()) do
            local owner = base:FindFirstChild("Owner") or base:FindFirstChild("Player")
            if (owner and owner.Value == LocalPlayer) or base.Name == LocalPlayer.Name then
                return base
            end
        end
    end
    -- Fallback search by descendants
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj.Name == "Base" or obj.Name == "Nest" or obj.Name == "Plot") and obj:FindFirstChild("Owner") and obj.Owner.Value == LocalPlayer then
            return obj
        end
    end
    return nil
end

-- Auto Steal Loop
task.spawn(function()
    while true do
        if Toggles.AutoSteal and HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
            pcall(function()
                -- Find eggs in arena
                local eggFound = nil
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and (string.find(string.lower(obj.ActionText), "steal") or string.find(string.lower(obj.ActionText), "grab") or string.find(string.lower(obj.ObjectText), "egg")) then
                        local promptPart = obj.Parent
                        if promptPart and promptPart:IsA("BasePart") then
                            eggFound = { part = promptPart, prompt = obj }
                            break
                        end
                    end
                end

                if eggFound then
                    local originalCFrame = HumanoidRootPart.CFrame
                    HumanoidRootPart.CFrame = eggFound.part.CFrame * CFrame.new(0, 2, 0)
                    task.wait(0.2)
                    fireproximityprompt(eggFound.prompt, 0)
                    task.wait(0.3)

                    -- Teleport back to base if deposit enabled or return
                    local base = GetPlayerBase()
                    if base then
                        local nest = base:FindFirstChild("Nest") or base:FindFirstChild("Deposit") or base:FindFirstChild("Spawn") or base:FindFirstChildWhichIsA("BasePart")
                        if nest then
                            HumanoidRootPart.CFrame = nest.CFrame * CFrame.new(0, 3, 0)
                            task.wait(0.4)
                        end
                    else
                        HumanoidRootPart.CFrame = originalCFrame
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

-- Auto Deposit Eggs
task.spawn(function()
    while true do
        if Toggles.AutoDeposit and HumanoidRootPart then
            pcall(function()
                local base = GetPlayerBase()
                if base then
                    local dropPrompt = base:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if dropPrompt then
                        fireproximityprompt(dropPrompt, 0)
                    end
                end
            end)
        end
        task.wait(1.5)
    end
end)

-- Auto Collect Cash / Drops
task.spawn(function()
    while true do
        if Toggles.AutoCollectCash and HumanoidRootPart then
            pcall(function()
                for _, item in ipairs(Workspace:GetChildren()) do
                    if item:IsA("BasePart") and (string.find(string.lower(item.Name), "coin") or string.find(string.lower(item.Name), "cash") or string.find(string.lower(item.Name), "money") or string.find(string.lower(item.Name), "drop")) then
                        item.CFrame = HumanoidRootPart.CFrame
                    elseif item:IsA("Model") and (string.find(string.lower(item.Name), "coin") or string.find(string.lower(item.Name), "cash") or string.find(string.lower(item.Name), "money")) then
                        local primary = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                        if primary then
                            primary.CFrame = HumanoidRootPart.CFrame
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- Auto Hatch Eggs
task.spawn(function()
    while true do
        if Toggles.AutoHatch then
            pcall(function()
                local hatchRemotes = {"Hatch", "HatchEgg", "OpenEgg", "BuyEgg", "EggHatch"}
                for _, name in ipairs(hatchRemotes) do
                    local remote = ReplicatedStorage:FindFirstChild(name, true)
                    if remote and remote:IsA("RemoteEvent") then
                        remote:FireServer(1)
                    elseif remote and remote:IsA("RemoteFunction") then
                        remote:InvokeServer(1)
                    end
                end
            end)
        end
        task.wait(0.6)
    end
end)

-- Auto Rebirth
task.spawn(function()
    while true do
        if Toggles.AutoRebirth then
            pcall(function()
                local rebirthRemotes = {"Rebirth", "AutoRebirth", "BuyRebirth", "RebirthEvent"}
                for _, name in ipairs(rebirthRemotes) do
                    local remote = ReplicatedStorage:FindFirstChild(name, true)
                    if remote and remote:IsA("RemoteEvent") then
                        remote:FireServer(1)
                    elseif remote and remote:IsA("RemoteFunction") then
                        remote:InvokeServer(1)
                    end
                end
            end)
        end
        task.wait(2)
    end
end)

-- Auto Attack Boss
task.spawn(function()
    while true do
        if Toggles.AutoAttackBoss and HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
            pcall(function()
                local bossModel = nil
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if (obj.Name == "bosshealth" or obj.Name == "bosshealthmax" or string.find(string.lower(obj.Name), "boss")) and obj.Parent and obj.Parent:IsA("Model") then
                        bossModel = obj.Parent
                        break
                    end
                end

                if bossModel then
                    local bossPart = bossModel:FindFirstChild("HumanoidRootPart") or bossModel:FindFirstChild("Head") or bossModel:FindFirstChildWhichIsA("BasePart")
                    if bossPart then
                        -- Safe float above boss
                        HumanoidRootPart.CFrame = bossPart.CFrame * CFrame.new(0, 10, 0)
                        
                        -- Fire attack remotes or tool activated
                        local tool = Character:FindFirstChildWhichIsA("Tool")
                        if tool then
                            tool:Activate()
                        end

                        local attackRemotes = {"Attack", "Hit", "DamageBoss", "BossHit", "Punch", "Slash"}
                        for _, rName in ipairs(attackRemotes) do
                            local rem = ReplicatedStorage:FindFirstChild(rName, true)
                            if rem and rem:IsA("RemoteEvent") then
                                rem:FireServer(bossModel)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.2)
    end
end)

-- Egg ESP
local function ClearESP()
    for _, item in ipairs(ESPObjects) do
        if item then item:Destroy() end
    end
    ESPObjects = {}
end

task.spawn(function()
    while true do
        if Toggles.EggESP then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if (string.find(string.lower(obj.Name), "egg") or string.find(string.lower(obj.Name), "nest")) and obj:IsA("BasePart") and not obj:FindFirstChild("JunejoEggHighlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "JunejoEggHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 170, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Adornee = obj
                    highlight.Parent = obj
                    table.insert(ESPObjects, highlight)

                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "JunejoEggBillboard"
                    billboard.Adornee = obj
                    billboard.Size = UDim2.new(0, 100, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = obj

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = "[EGG] " .. obj.Name
                    textLabel.TextColor3 = Color3.fromRGB(255, 220, 50)
                    textLabel.TextSize = 11
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.Parent = billboard

                    table.insert(ESPObjects, billboard)
                end
            end
        else
            ClearESP()
        end
        task.wait(3)
    end
end)

-- ====================================================================
-- JUNEJO OFFICIAL STANDARD UI CREATION
-- ====================================================================

local CoreGui = game:GetService("CoreGui")
local ExistingUI = CoreGui:FindFirstChild("JunejoHubUI")
if ExistingUI then ExistingUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -180)
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
TitleLabel.Text = "STEAL AN ANIME EGG"
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
    ClearESP()
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
ContentFrame.Size = UDim2.new(1, -24, 0, 280)
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

-- Add Main Toggle Rows
AddToggleRow("Auto Steal Eggs", "AutoSteal")
AddToggleRow("Instant Steal (0s Prompt)", "InstantPrompt")
AddToggleRow("Auto Deposit Eggs", "AutoDeposit")
AddToggleRow("Auto Collect Cash", "AutoCollectCash")
AddToggleRow("Auto Hatch Eggs", "AutoHatch")
AddToggleRow("Auto Rebirth", "AutoRebirth")
AddToggleRow("Auto Attack Boss", "AutoAttackBoss")
AddToggleRow("Anime Egg ESP", "EggESP")
AddToggleRow("Infinite Jump", "InfiniteJump")

-- Integrated WalkSpeed Row with Pill Adjuster
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

-- Footer
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
