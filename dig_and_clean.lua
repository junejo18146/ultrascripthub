--[[
    JUNEJO ULTRA SCRIPT HUB - DIG & CLEAN (REBUILT & ENHANCED ENGINE)
    Target Game: Dig & Clean (Roblox)
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11) - Flat & Borderless Standard
    Status: Direct Standalone Executable
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Safe UI Parent getter (Delta, Arceus X, Fluxus, PC/Mobile compatible)
local function GetSafeUIContainer()
    local container = nil
    if gethui then
        pcall(function() container = gethui() end)
    end
    if not container then
        pcall(function()
            if syn and syn.protect_gui then
                container = CoreGui
            end
        end)
    end
    if not container then
        pcall(function() container = CoreGui end)
    end
    return container or LocalPlayer:WaitForChild("PlayerGui")
end

local UIContainer = GetSafeUIContainer()

-- Cleanup previous UI instances
pcall(function()
    local names = {"JunejoDigAndCleanUI", "GetFatBreakTapeGui", "JunejoHubUI_DigClean", "JunejoHubUI"}
    for _, name in ipairs(names) do
        if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
        if gethui and gethui():FindFirstChild(name) then gethui()[name]:Destroy() end
    end
end)

--------------------------------------------------------------------
-- CONFIGURATION & STATE
--------------------------------------------------------------------
local Toggles = {
    AutoDig = false,
    AutoClean = false,
    AutoPlace = false,
    AutoDetector = false,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

local CustomSpeedValue = 50

--------------------------------------------------------------------
-- ANTI-AFK SYSTEM (PREVENTS 20-MINUTE IDLE DISCONNECT)
--------------------------------------------------------------------
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

--------------------------------------------------------------------
-- UNIVERSAL CLICK & INTERACTION SIMULATOR (DELTA / MOBILE / PC)
--------------------------------------------------------------------
local function SimulateScreenClick()
    pcall(function()
        local cam = Workspace.CurrentCamera
        local center = cam and Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2) or Vector2.new(200, 200)

        -- 1. VirtualInputManager Click
        if VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
            task.wait(0.03)
            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
            return
        end

        -- 2. Mouse1 Click
        if mouse1click then
            mouse1click()
            return
        end

        -- 3. VirtualUser Center Click
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(center, cam.CFrame)
        task.wait(0.03)
        VirtualUser:Button1Up(center, cam.CFrame)
    end)
end

-- Universal ProximityPrompt Trigger
local function TriggerPrompt(prompt)
    if not prompt or not prompt.Enabled then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt)
        end
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            task.wait(0.05)
            prompt:InputHoldEnd()
        end
    end)
end

-- Comprehensive Tool Equipper
local function EquipToolByKeywords(keywords)
    local char = LocalPlayer.Character
    if not char then return nil end

    -- Check currently equipped tool
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then
        local name = string.lower(equipped.Name)
        for _, kw in ipairs(keywords) do
            if string.find(name, kw) then return equipped end
        end
    end

    -- Search Backpack
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local name = string.lower(tool.Name)
                for _, kw in ipairs(keywords) do
                    if string.find(name, kw) then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum:EquipTool(tool)
                            task.wait(0.1)
                            return tool
                        end
                    end
                end
            end
        end
    end
    return nil
end

--------------------------------------------------------------------
-- CACHED NETWORK & REMOTES RESOLVER
--------------------------------------------------------------------
local CachedRemotes = {
    Dig = {},
    Clean = {},
    Place = {},
    Detector = {}
}

local function RefreshRemotes()
    pcall(function()
        CachedRemotes = { Dig = {}, Clean = {}, Place = {}, Detector = {} }
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = string.lower(obj.Name)
                if string.find(name, "dig") or string.find(name, "mine") or string.find(name, "shovel") then
                    table.insert(CachedRemotes.Dig, obj)
                end
                if string.find(name, "clean") or string.find(name, "wash") or string.find(name, "spray") or string.find(name, "dirt") then
                    table.insert(CachedRemotes.Clean, obj)
                end
                if string.find(name, "place") or string.find(name, "museum") or string.find(name, "stand") or string.find(name, "display") then
                    table.insert(CachedRemotes.Place, obj)
                end
                if string.find(name, "detector") or string.find(name, "scan") or string.find(name, "search") then
                    table.insert(CachedRemotes.Detector, obj)
                end
            end
        end
    end)
end

RefreshRemotes()

local function SafeFireRemote(remote, ...)
    pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(...)
        end
    end)
end

--------------------------------------------------------------------
-- 1. INFINITE JUMP ENGINE
--------------------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        pcall(function()
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and Toggles.InfiniteJump and input.KeyCode == Enum.KeyCode.Space then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
            end
        end)
    end
end)

--------------------------------------------------------------------
-- 2. WALKSPEED BOOST ENGINE (DUAL ENGINE)
--------------------------------------------------------------------
local function UpdateCharacterSpeed()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Toggles.WalkSpeedBoost then
                hum.WalkSpeed = CustomSpeedValue
            else
                hum.WalkSpeed = 16
            end
        end
    end)
end

RunService.RenderStepped:Connect(function(deltaTime)
    pcall(function()
        if Toggles.WalkSpeedBoost and CustomSpeedValue > 16 then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                local hum = char.Humanoid
                local hrp = char.HumanoidRootPart
                if hum.MoveDirection.Magnitude > 0 then
                    local speedBoost = (CustomSpeedValue - 16)
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (speedBoost * deltaTime))
                end
            end
        end
    end)
end)

--------------------------------------------------------------------
-- 3. AUTO DETECTOR ENGINE (MULTI-LAYERED)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoDetector then
            pcall(function()
                local tool = EquipToolByKeywords({"detector", "metal", "scan", "finder", "sensor"})
                if tool then
                    tool:Activate()
                    SimulateScreenClick()

                    -- Fire any remote inside the tool
                    for _, child in ipairs(tool:GetDescendants()) do
                        if child:IsA("RemoteEvent") then
                            SafeFireRemote(child)
                            SafeFireRemote(child, true)
                        end
                    end
                end

                -- Fire cached detector remotes
                for _, remote in ipairs(CachedRemotes.Detector) do
                    SafeFireRemote(remote)
                    SafeFireRemote(remote, true)
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 4. AUTO DIG ENGINE (MULTI-LAYERED)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoDig then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- Equip shovel/spade
                local tool = EquipToolByKeywords({"shovel", "spade", "dig", "trowel", "pick", "scoop"})
                if tool then
                    tool:Activate()
                end

                -- Click center of screen to dig
                SimulateScreenClick()

                -- Trigger nearby digging proximity prompts
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoDig then break end
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local pPart = prompt.Parent
                        if pPart and pPart:IsA("BasePart") then
                            local dist = (pPart.Position - hrp.Position).Magnitude
                            if dist <= prompt.MaxActivationDistance + 8 then
                                local act = string.lower(prompt.ActionText .. " " .. prompt.ObjectText)
                                if string.find(act, "dig") or string.find(act, "mine") or string.find(act, "search") or string.find(act, "unearth") or act == " " or act == "" then
                                    TriggerPrompt(prompt)
                                end
                            end
                        end
                    end
                end

                -- Fire cached dig remotes
                for _, remote in ipairs(CachedRemotes.Dig) do
                    SafeFireRemote(remote)
                    SafeFireRemote(remote, true)
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 5. AUTO CLEAN ENGINE (MULTI-LAYERED)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoClean then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                -- Equip cleaner/spray
                local tool = EquipToolByKeywords({"spray", "water", "clean", "sponge", "wash", "brush", "bottle"})
                if tool then
                    tool:Activate()
                end

                -- Click center of screen to clean/spray
                SimulateScreenClick()

                -- Trigger nearby cleaning prompts
                if hrp then
                    for _, prompt in ipairs(Workspace:GetDescendants()) do
                        if not Toggles.AutoClean then break end
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            local pPart = prompt.Parent
                            if pPart and pPart:IsA("BasePart") then
                                local dist = (pPart.Position - hrp.Position).Magnitude
                                if dist <= prompt.MaxActivationDistance + 8 then
                                    local act = string.lower(prompt.ActionText .. " " .. prompt.ObjectText)
                                    if string.find(act, "clean") or string.find(act, "wash") or string.find(act, "rinse") or string.find(act, "sponge") then
                                        TriggerPrompt(prompt)
                                    end
                                end
                            end
                        end
                    end
                end

                -- Fire cached clean remotes
                for _, remote in ipairs(CachedRemotes.Clean) do
                    SafeFireRemote(remote)
                    SafeFireRemote(remote, true)
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 6. AUTO PLACE ENGINE (MULTI-LAYERED)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.4)
        if Toggles.AutoPlace then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                -- 1. Trigger nearby museum / stand placement prompts
                if hrp then
                    for _, prompt in ipairs(Workspace:GetDescendants()) do
                        if not Toggles.AutoPlace then break end
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            local pPart = prompt.Parent
                            if pPart and pPart:IsA("BasePart") then
                                local dist = (pPart.Position - hrp.Position).Magnitude
                                if dist <= prompt.MaxActivationDistance + 8 then
                                    local act = string.lower(prompt.ActionText .. " " .. prompt.ObjectText)
                                    if string.find(act, "place") or string.find(act, "display") or string.find(act, "stand") or string.find(act, "put") or string.find(act, "museum") then
                                        TriggerPrompt(prompt)
                                    end
                                end
                            end
                        end
                    end
                end

                -- 2. Trigger place / display UI buttons
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then
                    for _, btn in ipairs(pGui:GetDescendants()) do
                        if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                            local txt = btn:IsA("TextButton") and string.lower(btn.Text) or ""
                            local name = string.lower(btn.Name)
                            if string.find(name, "place") or string.find(txt, "place") or string.find(name, "display") or string.find(txt, "display") or string.find(txt, "deposit") then
                                if firesignal then
                                    firesignal(btn.MouseButton1Click)
                                    firesignal(btn.Activated)
                                end
                            end
                        end
                    end
                end

                -- 3. Fire cached place remotes
                for _, remote in ipairs(CachedRemotes.Place) do
                    SafeFireRemote(remote)
                    SafeFireRemote(remote, "All")
                    SafeFireRemote(remote, true)
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 7. JUNEJO ULTRA SCRIPT HUB - OFFICIAL MASTER UI
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoDigAndCleanUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = UIContainer

local TotalFrameHeight = 240

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, TotalFrameHeight)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -math.floor(TotalFrameHeight / 2))
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
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "DIG & CLEAN"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseButton"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 4)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    Toggles.AutoDig = false
    Toggles.AutoClean = false
    Toggles.AutoPlace = false
    Toggles.AutoDetector = false
    Toggles.WalkSpeedBoost = false
    Toggles.InfiniteJump = false
    UpdateCharacterSpeed()
    ScreenGui:Destroy()
end)

-- Header Separation Line (Official Junejo Standard)
local HeaderLine = Instance.new("Frame")
HeaderLine.Name = "HeaderLine"
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Draggable Functionality
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

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 0, 164)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper function for Toggle Rows (Flat & Borderless)
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Name = text .. "_Row"
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

--------------------------------------------------------------------
-- POPULATE ROWS (6 CORE FEATURES)
--------------------------------------------------------------------
-- 1. Auto Dig
AddToggleRow("Auto Dig", "AutoDig")

-- 2. Auto Clean
AddToggleRow("Auto Clean", "AutoClean")

-- 3. Auto Place
AddToggleRow("Auto Place", "AutoPlace")

-- 4. Auto Detector
AddToggleRow("Auto Detector", "AutoDetector")

-- 5. WalkSpeed Boost with Integrated Adjuster Pill (- / +)
local SpeedRow = Instance.new("Frame")
SpeedRow.Name = "WalkSpeed_Row"
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

-- Pill Controller Frame
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
    CustomSpeedValue = math.min(250, CustomSpeedValue + 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

-- 6. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump")

--------------------------------------------------------------------
-- FOOTER (PERMANENT OFFICIAL BRANDING)
--------------------------------------------------------------------
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
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

print("[JUNEJO SCRIPT HUB] Dig & Clean Loaded Successfully!")
