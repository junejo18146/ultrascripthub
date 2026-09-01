--[[
    JUNEJO ULTRA SCRIPT HUB - STEAL A BRAINROT
    Target Game: Steal a Brainrot (Roblox)
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
    local names = {"JunejoStealABrainrotUI", "JunejoHubUI_Brainrot", "JunejoHubUI"}
    for _, name in ipairs(names) do
        if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
        if gethui and gethui():FindFirstChild(name) then gethui()[name]:Destroy() end
    end
end)

--------------------------------------------------------------------
-- CONFIGURATION & STATE (8 REQUESTED FEATURES)
--------------------------------------------------------------------
local Toggles = {
    AutoSteal = false,
    AutoTeleportToBase = false,
    BrainrotESP = false,
    Noclip = false,
    WalkSpeedBoost = false,
    InfiniteJump = false,
    AutoRebirth = false
}

local CustomSpeedValue = 50
local SavedBaseCFrame = nil

-- Default fallback base coordinate
task.spawn(function()
    task.wait(1)
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end)
end)

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
-- PROXIMITY PROMPT HELPER
--------------------------------------------------------------------
local function InstantTriggerPrompt(prompt)
    if not prompt or not prompt.Enabled then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt)
        end
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            task.wait(0.04)
            prompt:InputHoldEnd()
        end
    end)
end

--------------------------------------------------------------------
-- 1. NOCLIP ENGINE
--------------------------------------------------------------------
RunService.Stepped:Connect(function()
    if Toggles.Noclip then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

--------------------------------------------------------------------
-- 2. INFINITE JUMP ENGINE
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
-- 3. WALKSPEED BOOST ENGINE (DUAL ENGINE)
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
-- 4. AUTO STEAL & AUTO TELEPORT TO BASE ENGINE
--------------------------------------------------------------------
local function TeleportHome()
    pcall(function()
        if SavedBaseCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = SavedBaseCFrame + Vector3.new(0, 3, 0)
        end
    end)
end

-- Monitor when player picks up / steals an item to trigger Auto Teleport
local function BindCharacterCarryingListener(char)
    if not char then return end
    char.ChildAdded:Connect(function(child)
        if Toggles.AutoTeleportToBase and (child:IsA("Tool") or child:IsA("Model")) then
            task.wait(0.1)
            TeleportHome()
        end
    end)
end

if LocalPlayer.Character then
    BindCharacterCarryingListener(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.4)
    BindCharacterCarryingListener(char)
    if Toggles.WalkSpeedBoost then
        UpdateCharacterSpeed()
    end
end)

-- Auto Steal Loop
task.spawn(function()
    while true do
        task.wait(0.15)
        if Toggles.AutoSteal then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local stolen = false

                -- Scan for ProximityPrompts across Workspace
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoSteal then break end
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local pPart = prompt.Parent
                        if pPart and pPart:IsA("BasePart") then
                            local dist = (pPart.Position - hrp.Position).Magnitude
                            -- Range: Within prompt distance + 10 studs
                            if dist <= prompt.MaxActivationDistance + 10 then
                                local act = string.lower(prompt.ActionText .. " " .. prompt.ObjectText)
                                if string.find(act, "steal") or string.find(act, "take") or string.find(act, "grab") or string.find(act, "loot") or string.find(act, "brainrot") or act == " " or act == "" then
                                    InstantTriggerPrompt(prompt)
                                    stolen = true
                                    
                                    if Toggles.AutoTeleportToBase then
                                        task.wait(0.15)
                                        TeleportHome()
                                    end
                                    break
                                end
                            end
                        end
                    end
                end

                -- Fallback: Scan for Remotes named Steal or Take in ReplicatedStorage
                if not stolen then
                    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") then
                            local name = string.lower(remote.Name)
                            if string.find(name, "steal") or string.find(name, "take") or string.find(name, "loot") then
                                remote:FireServer()
                                remote:FireServer(true)
                                if Toggles.AutoTeleportToBase then
                                    task.wait(0.15)
                                    TeleportHome()
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 5. BRAINROT ESP (WALLHACK)
--------------------------------------------------------------------
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "Junejo_BrainrotESP"
ESPFolder.Parent = UIContainer

local function ClearBrainrotESP()
    for _, obj in ipairs(ESPFolder:GetChildren()) do
        obj:Destroy()
    end
end

local function CreateBrainrotESP(item)
    if not item or not item.Parent then return end
    local adorneePart = item:IsA("BasePart") and item or (item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")))
    if not adorneePart then return end

    local id = "ESP_" .. tostring(item:GetDebugId())
    if ESPFolder:FindFirstChild(id) then return end

    local espHolder = Instance.new("Folder")
    espHolder.Name = id
    espHolder.Parent = ESPFolder

    -- Gold Highlight Box
    local hl = Instance.new("Highlight")
    hl.Adornee = item
    hl.FillColor = Color3.fromRGB(255, 215, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.45
    hl.OutlineTransparency = 0
    hl.Parent = espHolder

    -- Billboard Gui
    local bb = Instance.new("BillboardGui")
    bb.Adornee = adorneePart
    bb.Size = UDim2.new(0, 160, 0, 32)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.Parent = espHolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 220, 50)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.2
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.Text = item.Name
    label.Parent = bb

    -- Live Distance Updater
    task.spawn(function()
        while espHolder.Parent and item.Parent and adorneePart.Parent do
            task.wait(0.3)
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = math.floor((hrp.Position - adorneePart.Position).Magnitude)
                    label.Text = "🧠 " .. item.Name .. "\n[" .. tostring(dist) .. " Studs]"
                end
            end)
        end
        espHolder:Destroy()
    end)
end

-- Brainrot Identifier
local function IsBrainrotObject(obj)
    if not (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool")) then return false end
    local name = string.lower(obj.Name)
    local keywords = {
        "brainrot", "skibidi", "sigma", "toilet", "mewing", "gigachad", 
        "caseoh", "kai", "cenat", "grimace", "pedestal", "display", 
        "stand", "podium", "trophy", "character", "item"
    }
    for _, kw in ipairs(keywords) do
        if string.find(name, kw) then
            return true
        end
    end
    -- Check if object contains a Steal prompt
    if obj:FindFirstChildWhichIsA("ProximityPrompt", true) then
        return true
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.BrainrotESP then
            pcall(function()
                for _, child in ipairs(Workspace:GetChildren()) do
                    if child.Name ~= "Terrain" and child ~= LocalPlayer.Character then
                        if IsBrainrotObject(child) then
                            CreateBrainrotESP(child)
                        else
                            for _, sub in ipairs(child:GetChildren()) do
                                if IsBrainrotObject(sub) then
                                    CreateBrainrotESP(sub)
                                end
                            end
                        end
                    end
                end
            end)
        else
            ClearBrainrotESP()
        end
    end
end)

--------------------------------------------------------------------
-- 6. AUTO REBIRTH ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(1)
        if Toggles.AutoRebirth then
            pcall(function()
                -- 1. Fire Rebirth Remotes in ReplicatedStorage
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoRebirth then break end
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local name = string.lower(remote.Name)
                        if string.find(name, "rebirth") or string.find(name, "prestige") or string.find(name, "ascend") then
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer()
                                remote:FireServer(1)
                                remote:FireServer(true)
                            elseif remote:IsA("RemoteFunction") then
                                remote:InvokeServer()
                            end
                        end
                    end
                end

                -- 2. Click Rebirth GUI Buttons if visible
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then
                    for _, btn in ipairs(pGui:GetDescendants()) do
                        if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                            local txt = btn:IsA("TextButton") and string.lower(btn.Text) or ""
                            local name = string.lower(btn.Name)
                            if string.find(name, "rebirth") or string.find(txt, "rebirth") or string.find(name, "prestige") or string.find(txt, "prestige") then
                                if firesignal then
                                    firesignal(btn.MouseButton1Click)
                                    firesignal(btn.Activated)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 7. JUNEJO ULTRA SCRIPT HUB - MASTER UI
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoStealABrainrotUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = UIContainer

-- Total Height calculation:
-- Header (32) + Line (1) + Spacing (5) + (8 rows * 27) + Footer (36) = ~290px
local TotalFrameHeight = 290

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
TitleLabel.Text = "STEAL A BRAINROT"
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
    ClearBrainrotESP()
    Toggles.AutoSteal = false
    Toggles.AutoTeleportToBase = false
    Toggles.BrainrotESP = false
    Toggles.Noclip = false
    Toggles.WalkSpeedBoost = false
    Toggles.InfiniteJump = false
    Toggles.AutoRebirth = false
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
ContentFrame.Size = UDim2.new(1, -24, 0, 216)
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
-- POPULATE ROWS (EXACT 8 FEATURES)
--------------------------------------------------------------------

-- 1. Auto Steal
AddToggleRow("Auto Steal", "AutoSteal")

-- 2. Auto Teleport to Base
AddToggleRow("Auto Teleport to Base", "AutoTeleportToBase")

-- 3. Set Base Position (1-Click Action Button Row)
local SetBaseRow = Instance.new("Frame")
SetBaseRow.Name = "SetBase_Row"
SetBaseRow.Size = UDim2.new(1, 0, 0, 23)
SetBaseRow.BackgroundTransparency = 1
SetBaseRow.Parent = ContentFrame

local SetBaseLabel = Instance.new("TextLabel")
SetBaseLabel.Size = UDim2.new(1, -75, 1, 0)
SetBaseLabel.BackgroundTransparency = 1
SetBaseLabel.Text = "Set Base Position"
SetBaseLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SetBaseLabel.TextSize = 12
SetBaseLabel.Font = Enum.Font.GothamBold
SetBaseLabel.TextXAlignment = Enum.TextXAlignment.Left
SetBaseLabel.Parent = SetBaseRow

local SetBaseBtn = Instance.new("TextButton")
SetBaseBtn.Size = UDim2.new(0, 70, 0, 20)
SetBaseBtn.Position = UDim2.new(1, -70, 0.5, -10)
SetBaseBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
SetBaseBtn.Text = "Set Base"
SetBaseBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
SetBaseBtn.TextSize = 11
SetBaseBtn.Font = Enum.Font.GothamBold
SetBaseBtn.Parent = SetBaseRow

local SetCorner = Instance.new("UICorner")
SetCorner.CornerRadius = UDim.new(0, 4)
SetCorner.Parent = SetBaseBtn

local SetStroke = Instance.new("UIStroke")
SetStroke.Color = Color3.fromRGB(45, 45, 55)
SetStroke.Thickness = 1
SetStroke.Parent = SetBaseBtn

SetBaseBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            SavedBaseCFrame = hrp.CFrame
            SetBaseBtn.Text = "Saved!"
            SetBaseBtn.TextColor3 = Color3.fromRGB(50, 215, 75)
            SetStroke.Color = Color3.fromRGB(50, 215, 75)
            task.wait(1.5)
            SetBaseBtn.Text = "Set Base"
            SetBaseBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
            SetStroke.Color = Color3.fromRGB(45, 45, 55)
        end
    end)
end)

-- 4. Brainrot ESP
AddToggleRow("Brainrot ESP", "BrainrotESP", function(enabled)
    if not enabled then ClearBrainrotESP() end
end)

-- 5. Noclip
AddToggleRow("Noclip", "Noclip")

-- 6. WalkSpeed Boost with Integrated Adjuster Pill (- / +)
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

-- 7. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump")

-- 8. Auto Rebirth
AddToggleRow("Auto Rebirth", "AutoRebirth")

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

print("[JUNEJO SCRIPT HUB] Steal A Brainrot Loaded Successfully!")
