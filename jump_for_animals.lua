-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - JUMP FOR ANIMALS (OFFICIAL)
-- Game: Jump for Animals
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- Universal Mobile (Delta / Codex / Fluxus) & PC Compatible
-- 100% Flat & Borderless Junejo Standard UI
-- ====================================================

local function elevate()
    if setthreadidentity then pcall(setthreadidentity, 8) end
end
elevate()

local rawSpawn = task.spawn
local function spawnTask(fn)
    return rawSpawn(function()
        elevate()
        pcall(fn)
    end)
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Safe GUI Parent Resolver (Instant Rendering on Mobile & PC)
local function getSafeGui()
    if gethui then
        local success, res = pcall(gethui)
        if success and res then return res end
    end
    local core = nil
    pcall(function() core = game:GetService("CoreGui") end)
    if core then
        local ok = pcall(function()
            local test = Instance.new("Folder")
            test.Parent = core
            test:Destroy()
        end)
        if ok then return core end
    end
    return LocalPlayer:WaitForChild("PlayerGui", 10) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

local guiParent = getSafeGui()

-- Clean all previous UI instances safely
pcall(function()
    for _, name in ipairs({"JunejoHubUI_JumpForAnimals", "JumpForAnimalsHub", "JunejoJumpAnimalsUI"}) do
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        local lpGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if lpGui and lpGui:FindFirstChild(name) then lpGui[name]:Destroy() end
        if guiParent and guiParent:FindFirstChild(name) then guiParent[name]:Destroy() end
    end
end)

-- Screen Notification Helper
local function notify(title, message, dur)
    elevate()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "[JUNEJO] " .. tostring(title),
            Text = tostring(message),
            Duration = dur or 3
        })
    end)
end

-- ====================================================
-- GLOBAL STATE & DATA STORAGE
-- ====================================================
local Settings = {
    AutoFarmEggs = false,
    AutoTrain = false,
    EggESP = false,
    PlayerESP = false,
    InstantPrompt = true,
    AntiAFK = true,
    NoClip = false,
    InfJump = false,
    Fly = false,
    WalkSpeedBoost = false,
    WalkSpeed = 50,
    JumpPowerBoost = false,
    JumpPower = 100,
    FlySpeed = 60,
    PlotCFrame = nil,
    EggNestCFrame = nil,
    TrainCFrame = nil
}

_G.Settings = Settings

local SavedBaseCFrame = nil
pcall(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        SavedBaseCFrame = hrp.CFrame
        Settings.PlotCFrame = hrp.CFrame
    end
end)

local function isAlive()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end

-- Inventory snapshot & possession detection
local function takeSnapshot()
    local snap = {}
    if isAlive() then
        local char = LocalPlayer.Character
        for _, o in ipairs(char:GetChildren()) do snap[o] = true end
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            for _, o in ipairs(bp:GetChildren()) do snap[o] = true end
        end
    end
    return snap
end

local function hasEggCarried()
    if not isAlive() then return false end
    local char = LocalPlayer.Character
    for _, obj in pairs(char:GetChildren()) do
        local n = obj.Name:lower()
        if (obj:IsA("Tool") or obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Accessory")) and (n:find("egg") or n:find("animal") or n:find("carry") or n:find("pet") or n:find("hold")) then
            return true
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, tool in pairs(bp:GetChildren()) do
            local n = tool.Name:lower()
            if n:find("egg") or n:find("animal") or n:find("carry") or n:find("pet") or n:find("hold") then
                return true
            end
        end
    end
    return false
end

local function isEggInPossession(initialSnap)
    if not isAlive() then return false end
    if hasEggCarried() then return true end

    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")

    -- Delta snapshot check (new item added)
    if initialSnap then
        for _, obj in ipairs(char:GetChildren()) do
            if not initialSnap[obj] and not obj:IsA("Highlight") and not obj:IsA("UIStroke") and not obj:IsA("BodyVelocity") and not obj:IsA("BodyGyro") and not obj:IsA("Humanoid") and not obj:IsA("BasePart") then
                return true
            end
        end
        if bp then
            for _, obj in ipairs(bp:GetChildren()) do
                if not initialSnap[obj] then
                    return true
                end
            end
        end
    end

    -- Attribute checks
    for k, v in pairs(char:GetAttributes()) do
        local kl = tostring(k):lower()
        if (kl:find("egg") or kl:find("carry") or kl:find("hold") or kl:find("stolen")) and v ~= false and v ~= nil and v ~= 0 and v ~= "" then
            return true
        end
    end
    for k, v in pairs(LocalPlayer:GetAttributes()) do
        local kl = tostring(k):lower()
        if (kl:find("egg") or kl:find("carry") or kl:find("hold") or kl:find("stolen")) and v ~= false and v ~= nil and v ~= 0 and v ~= "" then
            return true
        end
    end

    return false
end

-- Clean Proximity Prompt Trigger
local function triggerPromptClean(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 9999
        prompt.Enabled = true

        if fireproximityprompt then
            pcall(fireproximityprompt, prompt)
        end
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            task.wait(0.06)
            prompt:InputHoldEnd()
        end
    end)
end

-- Universal Touch Interest Trigger
local function InstantTouch(part, targetPart)
    if not part or not targetPart then return end
    pcall(function()
        if firetouchinterest then
            firetouchinterest(part, targetPart, 0)
            firetouchinterest(part, targetPart, 1)
            firetouchinterest(targetPart, part, 0)
            firetouchinterest(targetPart, part, 1)
        end
    end)
end

-- Dynamic Egg Nest Resolver
local function getEggNestLocation()
    if Settings.EggNestCFrame then
        return Settings.EggNestCFrame
    end

    local basePos = (Settings.PlotCFrame or SavedBaseCFrame) and (Settings.PlotCFrame or SavedBaseCFrame).Position or nil

    -- 1. Scan ProximityPrompts for eggs/nests
    local bestPromptCF = nil
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt.Parent then
            local part = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
            if part then
                local txt = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                local distFromBase = basePos and (part.Position - basePos).Magnitude or 100
                if txt:find("egg") or txt:find("steal") or txt:find("nest") or txt:find("take") or txt:find("grab") or txt:find("pick") then
                    return part.CFrame * CFrame.new(0, 2, 0)
                end
                if distFromBase > 30 and not bestPromptCF then
                    bestPromptCF = part.CFrame * CFrame.new(0, 2, 0)
                end
            end
        end
    end
    if bestPromptCF then return bestPromptCF end

    -- 2. Scan Workspace models/parts for Egg / Nest
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if (n:find("egg") or n:find("nest")) and not n:find("highlight") and not n:find("gui") and not n:find("player") then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if part and (not LocalPlayer.Character or not part:IsDescendantOf(LocalPlayer.Character)) then
                    local distFromBase = basePos and (part.Position - basePos).Magnitude or 100
                    if distFromBase > 30 then
                        return part.CFrame * CFrame.new(0, 2, 0)
                    end
                end
            end
        end
    end

    return nil
end

local isStealingActive = false
local autoStealToggleController = nil

local function performStealAndReturn()
    if isStealingActive or not isAlive() then return false end
    isStealingActive = true

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then
        isStealingActive = false
        if autoStealToggleController then autoStealToggleController.Set(false) end
        return false
    end

    -- 1. Ensure Base CFrame is locked
    local baseCF = Settings.PlotCFrame or SavedBaseCFrame or hrp.CFrame
    Settings.PlotCFrame = baseCF
    SavedBaseCFrame = baseCF

    -- 2. Resolve Egg Nest Target
    local nestCF = getEggNestLocation()
    if not nestCF then
        notify("Setup Needed", "Egg Nest ke paas ja kar 'Record Egg Nest' click karein!", 3)
        isStealingActive = false
        Settings.AutoFarmEggs = false
        if autoStealToggleController then autoStealToggleController.Set(false) end
        return false
    end

    notify("Stealing Egg", "Egg Nest par teleport ho rahe hain...", 2)

    -- Disable collisions temporarily
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
    hum.Sit = false

    local initialSnap = takeSnapshot()

    -- Step 1: Teleport to Egg Nest
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = nestCF
    task.wait(0.2)
    hrp.CFrame = nestCF
    hrp.AssemblyLinearVelocity = Vector3.zero

    -- Step 2: Hold position at Egg Nest and trigger steal
    local startTime = os.clock()
    local stolen = false

    while (os.clock() - startTime < 4.5) do
        if not isAlive() then break end

        -- Keep character locked at nest
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = nestCF

        -- Trigger all prompts within 28 studs
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Parent then
                local part = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                if part and (part.Position - hrp.Position).Magnitude < 28 then
                    triggerPromptClean(prompt)
                    InstantTouch(hrp, part)
                    if part:FindFirstChildWhichIsA("ClickDetector") then
                        pcall(function() fireclickdetector(part:FindFirstChildWhichIsA("ClickDetector")) end)
                    end
                end
            end
        end

        -- Fire touch on any nearby egg models
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("egg") and not obj:IsDescendantOf(char) then
                if (obj.Position - hrp.Position).Magnitude < 25 then
                    InstantTouch(hrp, obj)
                    if obj:FindFirstChildWhichIsA("ClickDetector") then
                        pcall(function() fireclickdetector(obj:FindFirstChildWhichIsA("ClickDetector")) end)
                    end
                end
            end
        end

        -- Fire steal remotes
        pcall(function()
            for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                if rem:IsA("RemoteEvent") then
                    local rn = rem.Name:lower()
                    if rn:find("steal") or rn:find("egg") or rn:find("take") or rn:find("grab") or rn:find("claim") or rn:find("pick") or rn:find("interact") then
                        rem:FireServer()
                    end
                end
            end
        end)

        if VirtualUser then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(500, 500))
        end

        -- Check if egg was picked up
        if isEggInPossession(initialSnap) then
            stolen = true
            break
        end

        task.wait(0.2)
    end

    task.wait(0.15)
    notify("Returning to Base", "Egg le kar Base par wapis teleport ho rahe hain...", 2)

    -- Step 3: Teleport directly back to Base Plot
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = baseCF
    task.wait(0.2)
    hrp.CFrame = baseCF
    hrp.AssemblyLinearVelocity = Vector3.zero

    -- Step 4: Deposit egg at Base
    for _ = 1, 8 do
        if not isAlive() then break end

        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Parent then
                local part = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                if part and (part.Position - hrp.Position).Magnitude < 30 then
                    local txt = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                    if txt:find("place") or txt:find("drop") or txt:find("deliver") or txt:find("deposit") or txt:find("hatch") or txt:find("claim") or txt:find("egg") or txt:find("nest") then
                        triggerPromptClean(prompt)
                        InstantTouch(hrp, part)
                    end
                end
            end
        end

        pcall(function()
            for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                if rem:IsA("RemoteEvent") then
                    local rn = rem.Name:lower()
                    if rn:find("deposit") or rn:find("deliver") or rn:find("hatch") or rn:find("place") or rn:find("drop") or rn:find("claim") then
                        rem:FireServer()
                    end
                end
            end
        end)

        task.wait(0.15)
    end

    -- Step 5: Automatically turn OFF toggle and STOP at Base!
    Settings.AutoFarmEggs = false
    if autoStealToggleController then
        autoStealToggleController.Set(false)
    end

    notify("Egg Delivered!", "Egg base par safely pohnch gaya aur auto steal stop ho gaya!", 3)
    isStealingActive = false
    return true
end

-- ====================================================
-- OFFICIAL JUNEJO BORDERLESS UI (280x285px)
-- STRICT FLAT BORDERLESS ROWS ONLY
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_JumpForAnimals"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 285)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -142)
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
TitleLabel.Text = "JUMP FOR ANIMALS"
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
    ScreenGui:Destroy()
end)

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
ContentFrame.Size = UDim2.new(1, -16, 0, 205)
ContentFrame.Position = UDim2.new(0, 10, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 80)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper Function: Add Section Title
local function AddSectionHeader(title)
    local SecRow = Instance.new("Frame")
    SecRow.Size = UDim2.new(1, -6, 0, 18)
    SecRow.BackgroundTransparency = 1
    SecRow.Parent = ContentFrame

    local SecLabel = Instance.new("TextLabel")
    SecLabel.Size = UDim2.new(1, 0, 1, 0)
    SecLabel.BackgroundTransparency = 1
    SecLabel.Text = "• " .. string.upper(title) .. " •"
    SecLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    SecLabel.TextSize = 10
    SecLabel.Font = Enum.Font.GothamBold
    SecLabel.TextXAlignment = Enum.TextXAlignment.Center
    SecLabel.Parent = SecRow
end

-- Helper Function: Add Strictly Flat & Borderless Toggle Row
local function AddToggleRow(text, configKey, callback, defaultVal)
    if defaultVal ~= nil then Settings[configKey] = defaultVal end
    
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
    CheckMark.BackgroundTransparency = Settings[configKey] and 0 or 1
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
        Settings[configKey] = not Settings[configKey]
        CheckMark.BackgroundTransparency = Settings[configKey] and 0 or 1
        if callback then callback(Settings[configKey]) end
    end)

    return {
        Set = function(val)
            Settings[configKey] = val
            CheckMark.BackgroundTransparency = val and 0 or 1
            if callback then callback(val) end
        end
    }
end

-- Helper Function: Add Action / Click Button Row
local function AddActionRow(text, btnLabel, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -65, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(0, 58, 0, 20)
    ActionBtn.Position = UDim2.new(1, -58, 0.5, -10)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ActionBtn.BorderSizePixel = 0
    ActionBtn.Text = btnLabel or "▶"
    ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionBtn.TextSize = 11
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.Parent = Row

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ActionBtn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1.2
    BtnStroke.Parent = ActionBtn

    ActionBtn.MouseButton1Click:Connect(function()
        if callback then spawnTask(function() callback(ActionBtn) end) end
    end)
end

-- ====================================================
-- REGISTER FEATURES & CONTROLS
-- ====================================================

-- 1. MAIN AUTOMATION
AddSectionHeader("Main Automation")

autoStealToggleController = AddToggleRow("Auto Steal Egg", "AutoFarmEggs", function(state)
    if state then
        if isAlive() and not Settings.PlotCFrame then
            Settings.PlotCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            SavedBaseCFrame = Settings.PlotCFrame
        end
        notify("Auto Steal", "Egg Nest par ja kar egg steal ho raha hai...", 2)
        spawnTask(performStealAndReturn)
    end
end)

AddActionRow("Steal Egg (1-Click)", "Steal", function()
    spawnTask(performStealAndReturn)
end)

AddToggleRow("Auto Train Spot", "AutoTrain", function(state)
    if state then
        if not Settings.TrainCFrame then
            notify("Setup Needed", "Pehle 'Record Train Spot' click karein!", 3)
        else
            notify("Auto Train", "Safe Auto Train Active!", 2)
        end
    end
end)

AddActionRow("Record Base / Plot", "Set", function(btn)
    if isAlive() then
        Settings.PlotCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        SavedBaseCFrame = Settings.PlotCFrame
        btn.Text = "Saved!"
        notify("Waypoint", "Base Plot Position Saved!", 2)
        task.delay(1.5, function() btn.Text = "Set" end)
    end
end)

AddActionRow("Record Egg Nest", "Set", function(btn)
    if isAlive() then
        Settings.EggNestCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        btn.Text = "Saved!"
        notify("Waypoint", "Egg Nest Position Saved!", 2)
        task.delay(1.5, function() btn.Text = "Set" end)
    end
end)

AddActionRow("Record Train Spot", "Set", function(btn)
    if isAlive() then
        Settings.TrainCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        btn.Text = "Saved!"
        notify("Waypoint", "Train Spot Position Saved!", 2)
        task.delay(1.5, function() btn.Text = "Set" end)
    end
end)

-- 2. TELEPORTS
AddSectionHeader("Teleport Waypoints")

AddActionRow("Teleport to Base", "TP", function()
    if isAlive() and (Settings.PlotCFrame or SavedBaseCFrame) then
        LocalPlayer.Character.HumanoidRootPart.CFrame = Settings.PlotCFrame or SavedBaseCFrame
        notify("Teleport", "Teleported to Base!", 2)
    else
        notify("Error", "Base position not recorded yet!", 2)
    end
end)

AddActionRow("Teleport to Nest", "TP", function()
    if isAlive() and Settings.EggNestCFrame then
        LocalPlayer.Character.HumanoidRootPart.CFrame = Settings.EggNestCFrame
        notify("Teleport", "Teleported to Egg Nest!", 2)
    else
        notify("Error", "Nest position not recorded yet!", 2)
    end
end)

AddActionRow("Teleport to Train Spot", "TP", function()
    if isAlive() and Settings.TrainCFrame then
        LocalPlayer.Character.HumanoidRootPart.CFrame = Settings.TrainCFrame
        notify("Teleport", "Teleported to Training Spot!", 2)
    else
        notify("Error", "Train Spot not recorded yet!", 2)
    end
end)

AddActionRow("Click-to-TP Tool", "Get", function()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "Click Teleport"
        tool.Activated:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            if isAlive() and mouse.Hit then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
        tool.Parent = bp
        notify("Tool Given", "Click Teleport tool added to Backpack!", 2)
    end
end)

-- 3. VISUALS (ESP)
AddSectionHeader("Visuals & ESP")

AddToggleRow("Egg Highlights ESP", "EggESP", function(state)
    if not state then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == "EggHighlight" then v:Destroy() end
        end
    end
end)

AddToggleRow("Player Highlights ESP", "PlayerESP", function(state)
    if not state then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("PlayerHighlight") then
                p.Character.PlayerHighlight:Destroy()
            end
        end
    end
end)

-- 4. MOVEMENT & OVERRIDES
AddSectionHeader("Movement & Utilities")

-- Integrated WalkSpeed Row with Pill Adjuster
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
SpeedCheckMark.BackgroundTransparency = Settings.WalkSpeedBoost and 0 or 1
SpeedCheckMark.BorderSizePixel = 0
SpeedCheckMark.Parent = SpeedCheckBox

local MarkCorner = Instance.new("UICorner")
MarkCorner.CornerRadius = UDim.new(0, 2)
MarkCorner.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Settings.WalkSpeedBoost = not Settings.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Settings.WalkSpeedBoost and 0 or 1
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
SpeedDisplay.Text = tostring(Settings.WalkSpeed)
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
    Settings.WalkSpeed = math.max(16, Settings.WalkSpeed - 15)
    SpeedDisplay.Text = tostring(Settings.WalkSpeed)
end)

PlusBtn.MouseButton1Click:Connect(function()
    Settings.WalkSpeed = math.min(300, Settings.WalkSpeed + 15)
    SpeedDisplay.Text = tostring(Settings.WalkSpeed)
end)

-- Integrated JumpPower Row with Pill Adjuster
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
JumpCheckMark.BackgroundTransparency = Settings.JumpPowerBoost and 0 or 1
JumpCheckMark.BorderSizePixel = 0
JumpCheckMark.Parent = JumpCheckBox

local JMarkCorner = Instance.new("UICorner")
JMarkCorner.CornerRadius = UDim.new(0, 2)
JMarkCorner.Parent = JumpCheckMark

JumpToggleBtn.MouseButton1Click:Connect(function()
    Settings.JumpPowerBoost = not Settings.JumpPowerBoost
    JumpCheckMark.BackgroundTransparency = Settings.JumpPowerBoost and 0 or 1
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
JumpDisplay.Text = tostring(Settings.JumpPower)
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
    Settings.JumpPower = math.max(50, Settings.JumpPower - 25)
    JumpDisplay.Text = tostring(Settings.JumpPower)
end)

JPlusBtn.MouseButton1Click:Connect(function()
    Settings.JumpPower = math.min(400, Settings.JumpPower + 25)
    JumpDisplay.Text = tostring(Settings.JumpPower)
end)

AddToggleRow("Infinite Jump", "InfJump", function(state) end)
AddToggleRow("Fly Mode", "Fly", function(state) end)
AddToggleRow("NoClip & De-Aggro", "NoClip", function(state) end)
AddToggleRow("Instant Proximity Prompts", "InstantPrompt", function(state) end, true)

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

-- ====================================================
-- ORIGINAL VERIFIED GAME LOOPS & BACKGROUND ENGINES
-- ====================================================

-- Safe, Death-Proof Auto Train Loop
local isTeleportedToTrain = false

spawnTask(function()
    while true do
        task.wait(0.2)
        if Settings.AutoTrain and isAlive() then
            local char = LocalPlayer.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")

            if Settings.TrainCFrame and not isTeleportedToTrain then
                if hrp and (hrp.Position - Settings.TrainCFrame.Position).Magnitude > 5 then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.CFrame = Settings.TrainCFrame * CFrame.new(0, 3, 0)
                    task.wait(0.4)
                end
                isTeleportedToTrain = true
            end

            local tool = char:FindFirstChildOfClass("Tool")
            if not tool and hum then
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp then
                    for _, t in pairs(bp:GetChildren()) do
                        if t:IsA("Tool") and not t.Name:lower():find("egg") then
                            hum:EquipTool(t)
                            tool = t
                            task.wait(0.2)
                            break
                        end
                    end
                end
            end

            if tool then
                tool:Activate()
                if VirtualUser then
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(500, 500))
                    task.wait(0.05)
                    VirtualUser:Button1Up(Vector2.new(500, 500))
                end
            end
        else
            isTeleportedToTrain = false
        end
    end
end)

-- Instant Proximity & Distance Hook
RunService.Stepped:Connect(function()
    if Settings.InstantPrompt then
        for _, prompt in pairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0
                prompt.MaxActivationDistance = 25
            end
        end
    end
end)

-- ESP Rendering
RunService.RenderStepped:Connect(function()
    if Settings.EggESP then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("egg") and not obj:FindFirstChild("EggHighlight") then
                local h = Instance.new("Highlight")
                h.Name = "EggHighlight"
                h.FillColor = Color3.fromRGB(30, 237, 93)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.Parent = obj
            end
        end
    end

    if Settings.PlayerESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("PlayerHighlight") then
                local h = Instance.new("Highlight")
                h.Name = "PlayerHighlight"
                h.FillColor = Color3.fromRGB(255, 50, 50)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.Parent = p.Character
            end
        end
    end
end)

-- Movement & NoClip Overrides
RunService.Stepped:Connect(function()
    if isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if Settings.WalkSpeedBoost then
                hum.WalkSpeed = Settings.WalkSpeed
            else
                hum.WalkSpeed = 16
            end
            if Settings.JumpPowerBoost then
                hum.JumpPower = Settings.JumpPower
            else
                hum.JumpPower = 50
            end
        end
        if Settings.NoClip then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.CanTouch = false
                end
            end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if Settings.InfJump and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Flight Mechanics
local bv, bg
RunService.RenderStepped:Connect(function()
    if Settings.Fly and isAlive() then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local cam = Workspace.CurrentCamera

        if not bv or not bv.Parent then
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Parent = hrp
        end
        if not bg or not bg.Parent then
            bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            bg.P = 10000
            bg.Parent = hrp
        end

        local moveDir = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + (cam.CFrame.LookVector) end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - (cam.CFrame.LookVector) end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - (cam.CFrame.RightVector) end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + (cam.CFrame.RightVector) end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        bv.Velocity = moveDir.Unit * Settings.FlySpeed
        bg.CFrame = cam.CFrame
        if moveDir.Magnitude == 0 then bv.Velocity = Vector3.new(0, 0, 0) end
    else
        if bv then bv:Destroy(); bv = nil end
        if bg then bg:Destroy(); bg = nil end
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK and VirtualUser then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

notify("Jump for Animals", "Junejo Ultra Script Hub Loaded!", 3)
