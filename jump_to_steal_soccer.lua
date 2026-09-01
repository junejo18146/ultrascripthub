--[[
    JUNEJO ULTRA SCRIPT HUB - JUMP TO STEAL SOCCER PLAYERS (REVISED)
    Target Game: Jump To Steal Soccer Players (Roblox)
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
local StarterGui = game:GetService("StarterGui")
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
    local names = {"JunejoJumpToStealSoccerUI", "JunejoHubUI_Soccer", "JunejoHubUI"}
    for _, name in ipairs(names) do
        if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
        if gethui and gethui():FindFirstChild(name) then gethui()[name]:Destroy() end
    end
end)

--------------------------------------------------------------------
-- CONFIGURATION & STATE (EXACT 5 REQUESTED FEATURES)
--------------------------------------------------------------------
local Toggles = {
    SoccerESP = false,
    AutoRebirth = false,
    FlyMode = false,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

local CustomSpeedValue = 50
local FlySpeed = 50

--------------------------------------------------------------------
-- NOTIFICATION HELPER
--------------------------------------------------------------------
local function ShowNotification(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3.5
        })
    end)
end

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
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 55, hrp.Velocity.Z)
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

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.4)
    if Toggles.WalkSpeedBoost then
        UpdateCharacterSpeed()
    end
end)

--------------------------------------------------------------------
-- 3. FLY MODE ENGINE (WASD & MOBILE TOUCH CONTROLS)
--------------------------------------------------------------------
local Flying = false
local BodyGyro, BodyVelocity

local function StartFlying()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        Flying = true
        hum.PlatformStand = true

        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.P = 9e4
        BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        BodyGyro.cframe = hrp.CFrame
        BodyGyro.Parent = hrp

        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.velocity = Vector3.zero
        BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
        BodyVelocity.Parent = hrp

        task.spawn(function()
            while Flying and Toggles.FlyMode and hrp.Parent and hum.Health > 0 do
                local cam = Workspace.CurrentCamera
                local moveDir = hum.MoveDirection
                
                BodyGyro.cframe = cam.CFrame

                if moveDir.Magnitude > 0 then
                    local flyVector = (cam.CFrame.LookVector * (moveDir.Z * -1)) + (cam.CFrame.RightVector * moveDir.X)
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        flyVector = flyVector + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        flyVector = flyVector - Vector3.new(0, 1, 0)
                    end
                    BodyVelocity.velocity = flyVector.Unit * FlySpeed
                else
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        BodyVelocity.velocity = Vector3.new(0, FlySpeed, 0)
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        BodyVelocity.velocity = Vector3.new(0, -FlySpeed, 0)
                    else
                        BodyVelocity.velocity = Vector3.zero
                    end
                end
                RunService.RenderStepped:Wait()
            end

            if BodyGyro then BodyGyro:Destroy() end
            if BodyVelocity then BodyVelocity:Destroy() end
            if hum then hum.PlatformStand = false end
            Flying = false
        end)
    end)
end

local function StopFlying()
    Flying = false
    pcall(function()
        if BodyGyro then BodyGyro:Destroy() end
        if BodyVelocity then BodyVelocity:Destroy() end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end)
end

--------------------------------------------------------------------
-- 4. SUPERCHARGED AUTO REBIRTH (MULTI-METHOD + LIVE SCREEN FEEDBACK)
--------------------------------------------------------------------
local RebirthStatusLabel = nil

local function TriggerMultiRebirth()
    -- Method 1: Remote Events & Functions
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = string.lower(obj.Name)
            if string.find(n, "rebirth") or string.find(n, "prestige") or string.find(n, "ascend") then
                pcall(function()
                    if obj:IsA("RemoteEvent") then
                        obj:FireServer()
                        obj:FireServer(1)
                        obj:FireServer(true)
                        obj:FireServer("Rebirth")
                    else
                        obj:InvokeServer()
                        obj:InvokeServer(1)
                        obj:InvokeServer(true)
                    end
                end)
            end
        end
    end

    -- Method 2: Physical Rebirth Pads & Proximity Prompts in Workspace
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local n = string.lower(obj.Name)
        if string.find(n, "rebirth") then
            if obj:IsA("BasePart") and hrp and firetouchinterest then
                pcall(function()
                    firetouchinterest(hrp, obj, 0)
                    task.wait(0.02)
                    firetouchinterest(hrp, obj, 1)
                end)
            end
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                pcall(function()
                    if fireproximityprompt then
                        fireproximityprompt(obj, 0)
                        fireproximityprompt(obj)
                    end
                    if obj.InputHoldBegin then
                        obj:InputHoldBegin()
                        task.wait(0.04)
                        obj:InputHoldEnd()
                    end
                end)
            end
        end
    end

    -- Method 3: PlayerGui Rebirth Buttons (firesignal, activate, and screen click)
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, btn in ipairs(pGui:GetDescendants()) do
            if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                local bText = btn:IsA("TextButton") and string.lower(btn.Text) or ""
                local bName = string.lower(btn.Name)
                if string.find(bName, "rebirth") or string.find(bText, "rebirth") or string.find(bName, "prestige") then
                    pcall(function()
                        if firesignal then
                            firesignal(btn.MouseButton1Click)
                            firesignal(btn.Activated)
                        end
                        if btn.Activate then btn:Activate() end
                        if VirtualInputManager and btn.AbsoluteSize.X > 0 then
                            local center = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
                            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
                            task.wait(0.02)
                            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
                        end
                    end)
                end
            end
        end
    end
end

-- Dedicated Rebirth Monitor Loop
task.spawn(function()
    local lastNotificationTick = 0

    while true do
        task.wait(1.5)
        if Toggles.AutoRebirth then
            pcall(function()
                -- 1. Scan PlayerGui for requirement texts
                local foundRequirementText = nil
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then
                    for _, lbl in ipairs(pGui:GetDescendants()) do
                        if lbl:IsA("TextLabel") and lbl.Visible then
                            local txt = string.lower(lbl.Text)
                            if (string.find(txt, "rebirth") or string.find(txt, "need") or string.find(txt, "cost") or string.find(txt, "require") or string.find(txt, "/")) and string.len(lbl.Text) < 60 then
                                foundRequirementText = lbl.Text
                                break
                            end
                        end
                    end
                end

                -- 2. Read leaderstats values
                local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                local cashStat = leaderstats and (leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Coins") or leaderstats:FindFirstChild("Jumps"))
                local currentStatValue = cashStat and tostring(cashStat.Value) or "N/A"

                -- 3. Trigger Rebirth Execution
                TriggerMultiRebirth()

                -- 4. Update Screen Status
                local statusMsg = ""
                if foundRequirementText then
                    statusMsg = foundRequirementText
                else
                    statusMsg = "Checking Rebirth... (Cash: " .. currentStatValue .. ")"
                end

                if RebirthStatusLabel then
                    RebirthStatusLabel.Text = "Status: " .. statusMsg
                end

                -- Also show StarterGui Notification every 6 seconds so user clearly sees it
                local now = tick()
                if now - lastNotificationTick >= 6 then
                    lastNotificationTick = now
                    ShowNotification("Auto Rebirth", statusMsg)
                end
            end)
        else
            if RebirthStatusLabel then
                RebirthStatusLabel.Text = "Status: Disabled"
            end
        end
    end
end)

--------------------------------------------------------------------
-- 5. SOCCER PLAYERS & LUCKY BLOCKS ESP (WALLHACK)
--------------------------------------------------------------------
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "Junejo_SoccerESP"
ESPFolder.Parent = UIContainer

local function ClearSoccerESP()
    for _, obj in ipairs(ESPFolder:GetChildren()) do
        obj:Destroy()
    end
end

local function CreateSoccerESP(item)
    if not item or not item.Parent then return end
    local adorneePart = item:IsA("BasePart") and item or (item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")))
    if not adorneePart then return end

    local id = "ESP_" .. tostring(item:GetDebugId())
    if ESPFolder:FindFirstChild(id) then return end

    local espHolder = Instance.new("Folder")
    espHolder.Name = id
    espHolder.Parent = ESPFolder

    local hl = Instance.new("Highlight")
    hl.Adornee = item
    hl.FillColor = Color3.fromRGB(0, 230, 118)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.45
    hl.OutlineTransparency = 0
    hl.Parent = espHolder

    local bb = Instance.new("BillboardGui")
    bb.Adornee = adorneePart
    bb.Size = UDim2.new(0, 160, 0, 32)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.Parent = espHolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 255, 150)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.2
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.Text = item.Name
    label.Parent = bb

    task.spawn(function()
        while espHolder.Parent and item.Parent and adorneePart.Parent do
            task.wait(0.3)
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = math.floor((hrp.Position - adorneePart.Position).Magnitude)
                    label.Text = "⚽ " .. item.Name .. "\n[" .. tostring(dist) .. " Studs]"
                end
            end)
        end
        espHolder:Destroy()
    end)
end

local function IsSoccerTarget(obj)
    if not (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool")) then return false end
    local name = string.lower(obj.Name)
    local keywords = {
        "soccer", "player", "lucky", "block", "ronaldo", "messi", 
        "mbappe", "neymar", "haaland", "legend", "golden", "diamond", 
        "rainbow", "void", "pedestal", "stand", "goal", "trophy"
    }
    for _, kw in ipairs(keywords) do
        if string.find(name, kw) then
            return true
        end
    end
    if obj:FindFirstChildWhichIsA("ProximityPrompt", true) then
        return true
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.SoccerESP then
            pcall(function()
                for _, child in ipairs(Workspace:GetChildren()) do
                    if child.Name ~= "Terrain" and child ~= LocalPlayer.Character then
                        if IsSoccerTarget(child) then
                            CreateSoccerESP(child)
                        else
                            for _, sub in ipairs(child:GetChildren()) do
                                if IsSoccerTarget(sub) then
                                    CreateSoccerESP(sub)
                                end
                            end
                        end
                    end
                end
            end)
        else
            ClearSoccerESP()
        end
    end
end)

--------------------------------------------------------------------
-- 6. JUNEJO ULTRA SCRIPT HUB - MASTER UI (5 ROWS + STATUS BAR)
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoJumpToStealSoccerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = UIContainer

local TotalFrameHeight = 230

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
TitleLabel.Text = "JUMP TO STEAL SOCCER"
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
    ClearSoccerESP()
    StopFlying()
    Toggles.SoccerESP = false
    Toggles.AutoRebirth = false
    Toggles.FlyMode = false
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

-- Content Frame (5 Rows)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 0, 150)
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
-- POPULATE EXACT 5 ROWS
--------------------------------------------------------------------

-- 1. Soccer Players ESP
AddToggleRow("Soccer Players ESP", "SoccerESP", function(enabled)
    if not enabled then ClearSoccerESP() end
end)

-- 2. Auto Rebirth
AddToggleRow("Auto Rebirth", "AutoRebirth", function(enabled)
    if enabled then
        ShowNotification("Auto Rebirth", "Scanning Rebirth requirements & remotes...")
    end
end)

-- Rebirth Status Sub-Label (Live feedback right inside the GUI)
local RebirthStatusRow = Instance.new("Frame")
RebirthStatusRow.Name = "RebirthStatus_Row"
RebirthStatusRow.Size = UDim2.new(1, 0, 0, 16)
RebirthStatusRow.BackgroundTransparency = 1
RebirthStatusRow.Parent = ContentFrame

RebirthStatusLabel = Instance.new("TextLabel")
RebirthStatusLabel.Size = UDim2.new(1, 0, 1, 0)
RebirthStatusLabel.BackgroundTransparency = 1
RebirthStatusLabel.Text = "Status: Disabled"
RebirthStatusLabel.TextColor3 = Color3.fromRGB(0, 230, 118)
RebirthStatusLabel.TextSize = 10
RebirthStatusLabel.Font = Enum.Font.GothamMedium
RebirthStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
RebirthStatusLabel.Parent = RebirthStatusRow

-- 3. Fly Mode
AddToggleRow("Fly Mode", "FlyMode", function(enabled)
    if enabled then
        StartFlying()
    else
        StopFlying()
    end
end)

-- 4. WalkSpeed Boost with Integrated Adjuster Pill (- / +)
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

-- 5. Infinite Jump
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

print("[JUNEJO SCRIPT HUB] Jump To Steal Soccer Players Loaded Successfully!")
