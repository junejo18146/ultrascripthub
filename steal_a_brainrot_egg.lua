-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - STEAL A BRAINROT EGG (V4 CONTINUOUS CYCLE FIX)
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- ====================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Clean previous instances safely
for _, uiName in ipairs({"JunejoHubUI_StealBrainrotEgg", "JunejoStealBrainrotEggUI"}) do
    pcall(function()
        if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(uiName) then
            LocalPlayer.PlayerGui[uiName]:Destroy()
        end
    end)
end

-- Global Configuration & State
local Toggles = {
    AutoSteal = false,
    EggESP = false,
    Noclip = false,
    InfiniteJump = false,
    WalkSpeedBoost = false,
    AntiAFK = true
}

local CustomSpeedValue = 100
local SavedBaseCFrame = nil
local CurrentEggESPInstances = {}
local CooldownEggs = {} -- Prevents targeting empty/cooling down egg spawns

-- Safe Alive Check
local function isAlive()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end

-- Universal Instant ProximityPrompt Trigger
local function InstantTriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 100
        prompt.RequiresLineOfSight = false
        prompt.Enabled = true

        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt)
        end
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            task.wait(0.02)
            prompt:InputHoldEnd()
        end
    end)
end

-- Speed Update Helper
local function UpdateCharacterSpeed()
    pcall(function()
        if isAlive() then
            if Toggles.WalkSpeedBoost then
                LocalPlayer.Character.Humanoid.WalkSpeed = CustomSpeedValue
            else
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end
    end)
end

-- ====================================================
-- UI GENERATION (JUNEJO CLASSIC STANDARD)
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_StealBrainrotEgg"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 280)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -140)
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

-- Dragging Engine (PC & Mobile Touch Support)
local function enableDrag(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
enableDrag(MainFrame)

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
TitleLabel.Text = "STEAL A BRAINROT EGG"
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
ContentFrame.Size = UDim2.new(1, -24, 0, 195)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper Function: Add Toggle Row (Junejo Borderless Row Standard)
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

-- Helper Function: Add Action Button Row
local function AddActionButton(text, callback)
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
    
    Btn.MouseButton1Click:Connect(function()
        if callback then callback(Btn) end
    end)
end

-- 1. Auto Steal Nearest Egg & Return to Base
AddToggleRow("Auto Steal Nearest Egg", "AutoSteal", function(state)
    if state and isAlive() then
        if not SavedBaseCFrame then
            SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end
end)

-- 2. Set Current Base Position Button
AddActionButton("📍 Set Current Base Position", function(btn)
    if isAlive() then
        SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        btn.Text = "✓ Base Location Saved!"
        btn.TextColor3 = Color3.fromRGB(80, 255, 120)
        task.delay(1.5, function()
            btn.Text = "📍 Set Current Base Position"
            btn.TextColor3 = Color3.fromRGB(240, 240, 240)
        end)
    end
end)

-- 3. Teleport to Base Button
AddActionButton("⚡ Teleport to Base", function(btn)
    if isAlive() then
        if not SavedBaseCFrame then
            SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = SavedBaseCFrame * CFrame.new(0, 1.5, 0)
        btn.Text = "✓ Teleported to Base!"
        task.delay(1.2, function()
            btn.Text = "⚡ Teleport to Base"
        end)
    end
end)

-- 4. Best Egg ESP
AddToggleRow("Best Egg ESP", "EggESP", function(state)
    if not state then
        for _, highlight in pairs(CurrentEggESPInstances) do
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
        end
        CurrentEggESPInstances = {}
    end
end)

-- 5. Noclip Mode
AddToggleRow("Noclip (Phase Walls)", "Noclip", function(state) end)

-- 6. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump", function(state) end)

-- 7. Integrated WalkSpeed Row with - / + Pill Adjuster
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
    CustomSpeedValue = math.min(300, CustomSpeedValue + 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

-- Footer (Junejo Brand Standards)
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

-- ====================================================
-- CONTINUOUS MULTI-EGG STEAL & BASE RETURN ENGINE
-- ====================================================

-- Generate a unique spatial key for each egg spawn location
local function GetLocationKey(pos)
    return math.floor(pos.X / 4) .. "_" .. math.floor(pos.Y / 4) .. "_" .. math.floor(pos.Z / 4)
end

-- Function: Find the Nearest AVAILABLE Egg (cycles across all eggs without getting stuck on empty respawning ones)
local function FindNearestAvailableEgg(hrpPosition)
    local bestTargetCFrame = nil
    local bestPrompt = nil
    local bestPart = nil
    local bestLocKey = nil
    local shortestDist = math.huge
    local now = os.clock()

    -- 1. Scan ProximityPrompts for Steal / Egg prompts
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local pPart = prompt.Parent
            local targetPos = nil

            if pPart:IsA("BasePart") then
                targetPos = pPart.CFrame
            elseif pPart:IsA("Attachment") then
                targetPos = pPart.WorldCFrame
            elseif pPart:IsA("Model") and pPart.PrimaryPart then
                targetPos = pPart.PrimaryPart.CFrame
            end

            if targetPos then
                local locKey = GetLocationKey(targetPos.Position)
                local isCoolingDown = CooldownEggs[locKey] and (now < CooldownEggs[locKey])

                if not isCoolingDown then
                    local distFromBase = SavedBaseCFrame and (targetPos.Position - SavedBaseCFrame.Position).Magnitude or 100
                    if distFromBase > 14 then
                        local act = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
                        local pName = pPart.Name:lower()
                        
                        local isEggOrSteal = act:find("steal") or act:find("take") or act:find("grab") or act:find("egg") or act:find("brainrot") or act:find("pick") or act:find("collect") or pName:find("egg") or pName:find("brainrot") or act == "" or act == " "
                        
                        if isEggOrSteal then
                            local dist = (targetPos.Position - hrpPosition).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                bestTargetCFrame = targetPos
                                bestPrompt = prompt
                                bestPart = pPart:IsA("BasePart") and pPart or nil
                                bestLocKey = locKey
                            end
                        end
                    end
                end
            end
        end
    end

    -- 2. Fallback: Scan Workspace Models / BaseParts named Egg or Brainrot
    if not bestTargetCFrame then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if (name:find("egg") or name:find("brainrot")) and not name:find("gui") and not name:find("ui") then
                local tCFrame = nil
                local targetPart = nil
                
                if obj:IsA("BasePart") then
                    tCFrame = obj.CFrame
                    targetPart = obj
                elseif obj:IsA("Model") and obj.PrimaryPart then
                    tCFrame = obj.PrimaryPart.CFrame
                    targetPart = obj.PrimaryPart
                elseif obj:IsA("Model") then
                    local p = obj:FindFirstChildWhichIsA("BasePart")
                    if p then
                        tCFrame = p.CFrame
                        targetPart = p
                    end
                end

                if tCFrame then
                    local locKey = GetLocationKey(tCFrame.Position)
                    local isCoolingDown = CooldownEggs[locKey] and (now < CooldownEggs[locKey])

                    if not isCoolingDown then
                        local distFromBase = SavedBaseCFrame and (tCFrame.Position - SavedBaseCFrame.Position).Magnitude or 100
                        if distFromBase > 16 then
                            local dist = (tCFrame.Position - hrpPosition).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                bestTargetCFrame = tCFrame
                                bestPart = targetPart
                                bestLocKey = locKey
                                local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if p then bestPrompt = p end
                            end
                        end
                    end
                end
            end
        end
    end

    return bestTargetCFrame, bestPrompt, bestPart, bestLocKey
end

-- Teleport and Deposit at Base Helper
local function ReturnToBaseAndDeposit(hrp)
    if SavedBaseCFrame and isAlive() then
        -- Teleport directly to Base
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = SavedBaseCFrame * CFrame.new(0, 1.5, 0)
        task.wait(0.2)

        -- Deposit / Hatch trigger at Base (scans all prompts within 35 studs of Base)
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Parent then
                local pos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or (prompt.Parent:IsA("Attachment") and prompt.Parent.WorldPosition or nil)
                if pos and (pos - hrp.Position).Magnitude < 35 then
                    InstantTriggerPrompt(prompt)
                end
            end
        end

        -- Base Touchpads trigger
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude < 30 then
                local n = part.Name:lower()
                if n:find("deposit") or n:find("hatch") or n:find("nest") or n:find("slot") or n:find("place") or n:find("base") or n:find("incub") then
                    if firetouchinterest then
                        firetouchinterest(hrp, part, 0)
                        task.wait()
                        firetouchinterest(hrp, part, 1)
                    end
                end
            end
        end
    end
end

-- Master Auto Steal Loop (Continuous Cycling Across Map)
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoSteal and isAlive() then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                -- Automatically capture current position as Base if not yet saved
                if not SavedBaseCFrame then
                    SavedBaseCFrame = hrp.CFrame
                end

                -- Step 1: Find the nearest AVAILABLE egg in the map
                local targetCFrame, prompt, eggPart, locKey = FindNearestAvailableEgg(hrp.Position)

                if targetCFrame then
                    -- Mark this egg location on cooldown (6 seconds) so it cycles to other eggs while this one respawns
                    if locKey then
                        CooldownEggs[locKey] = os.clock() + 6
                    end

                    -- Step 2: Instant Teleport to the Nearest Egg
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.CFrame = targetCFrame * CFrame.new(0, 2, 0)
                    task.wait(0.15)

                    -- Step 3: Trigger Steal
                    if prompt then
                        InstantTriggerPrompt(prompt)
                    end

                    -- Trigger touch if part exists
                    if eggPart and firetouchinterest then
                        firetouchinterest(hrp, eggPart, 0)
                        task.wait()
                        firetouchinterest(hrp, eggPart, 1)
                    end

                    -- Also scan any prompt within 16 studs of current teleport spot
                    for _, p in ipairs(Workspace:GetDescendants()) do
                        if p:IsA("ProximityPrompt") and p.Parent then
                            local pPos = p.Parent:IsA("BasePart") and p.Parent.Position or nil
                            if pPos and (pPos - hrp.Position).Magnitude < 16 then
                                InstantTriggerPrompt(p)
                            end
                        end
                    end

                    -- Small delay for server sync
                    task.wait(0.18)

                    -- Step 4: Instantly Return to Base with the Stolen Egg!
                    ReturnToBaseAndDeposit(hrp)
                    task.wait(0.3)
                else
                    -- If all nearby eggs were recently stolen and are on cooldown, clear expired ones and brief wait
                    task.wait(0.4)
                end
            end
        end
    end
end)

-- Instant Proximity & Distance Boost Hook
RunService.Stepped:Connect(function()
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
            prompt.MaxActivationDistance = 45
            prompt.RequiresLineOfSight = false
        end
    end
end)

-- Best Egg ESP Engine (Neon Gold Visual Glow on all Brainrot Eggs)
RunService.RenderStepped:Connect(function()
    if Toggles.EggESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if (obj:IsA("Model") or obj:IsA("BasePart")) and (name:find("egg") or name:find("brainrot")) and not name:find("gui") then
                if not obj:FindFirstChild("JunejoEggESP") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "JunejoEggESP"
                    highlight.FillColor = Color3.fromRGB(255, 215, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.25
                    highlight.OutlineTransparency = 0
                    highlight.Parent = obj
                    table.insert(CurrentEggESPInstances, highlight)
                end
            end
        end
    end
end)

-- Noclip Engine & Speed Boost Keeper
RunService.Stepped:Connect(function()
    if isAlive() then
        if Toggles.Noclip or Toggles.AutoSteal then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        if Toggles.WalkSpeedBoost then
            LocalPlayer.Character.Humanoid.WalkSpeed = CustomSpeedValue
        end
    end
end)

-- Infinite Jump Engine
UIS.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and isAlive() then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Character Added Re-hook
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateCharacterSpeed()
end)

-- Anti-AFK Engine (Idle Disconnect Protection)
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end
end)
