--[[
    JUNEJO ULTRA SCRIPT HUB - WASH THE HOUSE (V2)
    Target Game: Wash the House (Roblox)
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11) - Solid Matte Black Standard
    Status: Standalone Dedicated Executable - Instant Auto Clean & Placement Engine
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local VirtualInputManager
pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Safe UI Parent getter (Delta, Arceus X, Fluxus, PC/Mobile compatible)
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

-- Cleanup previous UI instances of this script
for _, name in ipairs({"JunejoWashTheHouseV2UI", "JunejoWashHouseV2", "JunejoWashTheHouse_V2"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

-- Feature States
local Toggles = {
    AutoClean = false,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

local CustomSpeedValue = 50

--------------------------------------------------------------------
-- ANTI-AFK SYSTEM (Prevents 20-minute idle disconnect)
--------------------------------------------------------------------
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

--------------------------------------------------------------------
-- 1. BULLETPROOF INFINITE JUMP (PC & MOBILE COMPATIBLE)
--------------------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and LocalPlayer.Character then
        pcall(function()
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                if hrp then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, math.max(hum.JumpPower > 0 and hum.JumpPower or 50, 50), hrp.Velocity.Z)
                end
            end
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
-- 2. BULLETPROOF WALKSPEED BOOST ENGINE (DUAL ENGINE)
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

local function BindHumanoidSpeedListener(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Toggles.WalkSpeedBoost and hum.WalkSpeed ~= CustomSpeedValue then
                hum.WalkSpeed = CustomSpeedValue
            end
        end)
    end
end

if LocalPlayer.Character then
    BindHumanoidSpeedListener(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    BindHumanoidSpeedListener(char)
    UpdateCharacterSpeed()
end)

RunService.Stepped:Connect(function()
    if Toggles.WalkSpeedBoost and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= CustomSpeedValue then
            hum.WalkSpeed = CustomSpeedValue
        end
    end
end)

--------------------------------------------------------------------
-- 3. MASTER AUTO CLEAN & AUTO-PLACE HOUSE ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.12)
        if Toggles.AutoClean then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local bp = LocalPlayer:FindFirstChild("Backpack")

                -- 1. Auto-Equip Tools from Backpack
                if bp and hum then
                    for _, tool in ipairs(bp:GetChildren()) do
                        if tool:IsA("Tool") then
                            hum:EquipTool(tool)
                        end
                    end
                end

                -- 2. Activate any equipped tool
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            pcall(function() tool:Activate() end)
                        end
                    end
                end

                -- 3. Clean all Dirt / Stain / Grime Decals, Textures & Parts
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoClean then break end
                    if obj:IsA("Texture") or obj:IsA("Decal") then
                        local n = obj.Name:lower()
                        local parentN = obj.Parent and obj.Parent.Name:lower() or ""
                        if n:find("dirt") or n:find("stain") or n:find("clean") or n:find("grime") or n:find("mess") or n:find("spot") or n:find("dust") or n:find("mud") or parentN:find("dirt") or parentN:find("stain") then
                            obj.Transparency = 1
                        end
                    elseif obj:IsA("BasePart") then
                        local n = obj.Name:lower()
                        if n:find("dirt") or n:find("stain") or n:find("clean") or n:find("grime") or n:find("mess") or n:find("spot") or n:find("dust") or n:find("rubbish") or n:find("trash") then
                            obj.Transparency = 1
                            if firetouchinterest and hrp then
                                firetouchinterest(hrp, obj, 0)
                                task.wait()
                                firetouchinterest(hrp, obj, 1)
                            end
                        end
                    end
                end

                -- 4. Bypass & Fire ALL ProximityPrompts across the entire house (Pickup / Place / Clean)
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoClean then break end
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        pcall(function()
                            prompt.RequiresLineOfSight = false
                            prompt.MaxActivationDistance = 999999
                            prompt.HoldDuration = 0
                            if fireproximityprompt then
                                fireproximityprompt(prompt, 0)
                            else
                                prompt:InputHoldBegin()
                                task.wait(0.01)
                                prompt:InputHoldEnd()
                            end
                        end)
                    elseif prompt:IsA("ClickDetector") then
                        pcall(function()
                            prompt.MaxActivationDistance = 999999
                            if fireclickdetector then
                                fireclickdetector(prompt)
                            end
                        end)
                    end
                end

                -- 5. Send Universal E-Key & Mouse Click Inputs
                pcall(function()
                    if VirtualInputManager then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.015)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end
                    if VirtualUser then
                        VirtualUser:Button1Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                        task.wait(0.015)
                        VirtualUser:Button1Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                    end
                end)

                -- 6. Remote Event Sweeper (Clean, Place, Pickup, Task)
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local rn = remote.Name:lower()
                        if rn:find("clean") or rn:find("wash") or rn:find("place") or rn:find("pickup") or rn:find("interact") or rn:find("item") or rn:find("task") or rn:find("stain") or rn:find("dirt") then
                            pcall(function()
                                remote:FireServer()
                                remote:FireServer(true)
                                remote:FireServer(1)
                                if hrp then
                                    remote:FireServer(hrp.Position)
                                end
                            end)
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 4. GUI CREATION (JUNEJO EXECUTIVE MATTE BLACK THEME)
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoWashTheHouseV2UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 290, 0, 230)
MainFrame.Position = UDim2.new(0.5, -145, 0.4, -115)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17) -- Pure Junejo Matte Black
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42) -- Subtle 1px border stroke
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- HEADER
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -45, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "WASH THE HOUSE"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 26, 0, 26)
CloseButton.Position = UDim2.new(1, -32, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
CloseButton.BorderSizePixel = 0
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 160)
CloseButton.TextSize = 12
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- CONTENT LIST
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -20, 0, 150)
ContentContainer.Position = UDim2.new(0, 10, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.Parent = ContentContainer

-- HELPER: TOGGLE ROW BUILDER
local function CreateToggleRow(order, titleText, initialVal, onToggleCallback)
    local Row = Instance.new("Frame")
    Row.Name = "Row_" .. titleText:gsub("%s+", "")
    Row.Size = UDim2.new(1, 0, 0, 36)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Row.BorderSizePixel = 0
    Row.LayoutOrder = order
    Row.Parent = ContentContainer

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 7)
    RowCorner.Parent = Row

    local RowStroke = Instance.new("UIStroke")
    RowStroke.Color = Color3.fromRGB(35, 35, 42)
    RowStroke.Thickness = 1
    RowStroke.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -55, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = titleText
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local CheckBox = Instance.new("TextButton")
    CheckBox.Size = UDim2.new(0, 26, 0, 26)
    CheckBox.Position = UDim2.new(1, -32, 0.5, -13)
    CheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    CheckBox.BorderSizePixel = 0
    CheckBox.AutoButtonColor = false
    CheckBox.Text = ""
    CheckBox.Parent = Row

    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 6)
    CheckCorner.Parent = CheckBox

    local CheckStroke = Instance.new("UIStroke")
    CheckStroke.Color = Color3.fromRGB(45, 45, 55)
    CheckStroke.Thickness = 1
    CheckStroke.Parent = CheckBox

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 14, 0, 14)
    Indicator.Position = UDim2.new(0.5, -7, 0.5, -7)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.BorderSizePixel = 0
    Indicator.BackgroundTransparency = initialVal and 0 or 1
    Indicator.Parent = CheckBox

    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(0, 4)
    IndCorner.Parent = Indicator

    local isEnabled = initialVal

    local function ToggleState()
        isEnabled = not isEnabled
        TweenService:Create(Indicator, TweenInfo.new(0.15), {
            BackgroundTransparency = isEnabled and 0 or 1
        }):Play()
        if isEnabled then
            CheckStroke.Color = Color3.fromRGB(255, 255, 255)
        else
            CheckStroke.Color = Color3.fromRGB(45, 45, 55)
        end
        onToggleCallback(isEnabled)
    end

    CheckBox.MouseButton1Click:Connect(ToggleState)

    local ClickCover = Instance.new("TextButton")
    ClickCover.Size = UDim2.new(1, -40, 1, 0)
    ClickCover.BackgroundTransparency = 1
    ClickCover.Text = ""
    ClickCover.Parent = Row
    ClickCover.MouseButton1Click:Connect(ToggleState)

    return {
        Set = function(v)
            isEnabled = v
            Indicator.BackgroundTransparency = isEnabled and 0 or 1
            CheckStroke.Color = isEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(45, 45, 55)
            onToggleCallback(isEnabled)
        end
    }
end

-- HELPER: WALKSPEED ADJUSTABLE ROW BUILDER
local function CreateSpeedControlRow(order, titleText, initialVal, onToggleCallback)
    local Row = Instance.new("Frame")
    Row.Name = "Row_Speed"
    Row.Size = UDim2.new(1, 0, 0, 36)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Row.BorderSizePixel = 0
    Row.LayoutOrder = order
    Row.Parent = ContentContainer

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 7)
    RowCorner.Parent = Row

    local RowStroke = Instance.new("UIStroke")
    RowStroke.Color = Color3.fromRGB(35, 35, 42)
    RowStroke.Thickness = 1
    RowStroke.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 110, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = titleText
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    -- Speed Adjuster Controls [-] [Value] [+]
    local ControlsFrame = Instance.new("Frame")
    ControlsFrame.Size = UDim2.new(0, 95, 0, 26)
    ControlsFrame.Position = UDim2.new(1, -135, 0.5, -13)
    ControlsFrame.BackgroundTransparency = 1
    ControlsFrame.Parent = Row

    local MinusBtn = Instance.new("TextButton")
    MinusBtn.Size = UDim2.new(0, 24, 0, 24)
    MinusBtn.Position = UDim2.new(0, 0, 0.5, -12)
    MinusBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    MinusBtn.BorderSizePixel = 0
    MinusBtn.Font = Enum.Font.GothamBold
    MinusBtn.Text = "-"
    MinusBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinusBtn.TextSize = 13
    MinusBtn.Parent = ControlsFrame

    local MinusCorner = Instance.new("UICorner")
    MinusCorner.CornerRadius = UDim.new(0, 5)
    MinusCorner.Parent = MinusBtn

    local SpeedDisplay = Instance.new("TextLabel")
    SpeedDisplay.Size = UDim2.new(0, 42, 0, 24)
    SpeedDisplay.Position = UDim2.new(0, 27, 0.5, -12)
    SpeedDisplay.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    SpeedDisplay.BorderSizePixel = 0
    SpeedDisplay.Font = Enum.Font.GothamBold
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    SpeedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedDisplay.TextSize = 11
    SpeedDisplay.Parent = ControlsFrame

    local DisplayCorner = Instance.new("UICorner")
    DisplayCorner.CornerRadius = UDim.new(0, 5)
    DisplayCorner.Parent = SpeedDisplay

    local PlusBtn = Instance.new("TextButton")
    PlusBtn.Size = UDim2.new(0, 24, 0, 24)
    PlusBtn.Position = UDim2.new(0, 72, 0.5, -12)
    PlusBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    PlusBtn.BorderSizePixel = 0
    PlusBtn.Font = Enum.Font.GothamBold
    PlusBtn.Text = "+"
    PlusBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    PlusBtn.TextSize = 13
    PlusBtn.Parent = ControlsFrame

    local PlusCorner = Instance.new("UICorner")
    PlusCorner.CornerRadius = UDim.new(0, 5)
    PlusCorner.Parent = PlusBtn

    MinusBtn.MouseButton1Click:Connect(function()
        CustomSpeedValue = math.max(16, CustomSpeedValue - 10)
        SpeedDisplay.Text = tostring(CustomSpeedValue)
        if Toggles.WalkSpeedBoost then
            UpdateCharacterSpeed()
        end
    end)

    PlusBtn.MouseButton1Click:Connect(function()
        CustomSpeedValue = math.min(250, CustomSpeedValue + 10)
        SpeedDisplay.Text = tostring(CustomSpeedValue)
        if Toggles.WalkSpeedBoost then
            UpdateCharacterSpeed()
        end
    end)

    -- Toggle Checkbox
    local CheckBox = Instance.new("TextButton")
    CheckBox.Size = UDim2.new(0, 26, 0, 26)
    CheckBox.Position = UDim2.new(1, -32, 0.5, -13)
    CheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    CheckBox.BorderSizePixel = 0
    CheckBox.AutoButtonColor = false
    CheckBox.Text = ""
    CheckBox.Parent = Row

    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 6)
    CheckCorner.Parent = CheckBox

    local CheckStroke = Instance.new("UIStroke")
    CheckStroke.Color = Color3.fromRGB(45, 45, 55)
    CheckStroke.Thickness = 1
    CheckStroke.Parent = CheckBox

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 14, 0, 14)
    Indicator.Position = UDim2.new(0.5, -7, 0.5, -7)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.BorderSizePixel = 0
    Indicator.BackgroundTransparency = initialVal and 0 or 1
    Indicator.Parent = CheckBox

    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(0, 4)
    IndCorner.Parent = Indicator

    local isEnabled = initialVal

    local function ToggleState()
        isEnabled = not isEnabled
        TweenService:Create(Indicator, TweenInfo.new(0.15), {
            BackgroundTransparency = isEnabled and 0 or 1
        }):Play()
        if isEnabled then
            CheckStroke.Color = Color3.fromRGB(255, 255, 255)
        else
            CheckStroke.Color = Color3.fromRGB(45, 45, 55)
        end
        onToggleCallback(isEnabled)
    end

    CheckBox.MouseButton1Click:Connect(ToggleState)

    return {
        Set = function(v)
            isEnabled = v
            Indicator.BackgroundTransparency = isEnabled and 0 or 1
            CheckStroke.Color = isEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(45, 45, 55)
            onToggleCallback(isEnabled)
        end
    }
end

-- ATTACH FEATURE ROWS
CreateToggleRow(1, "Auto Clean", false, function(v)
    Toggles.AutoClean = v
end)

CreateSpeedControlRow(2, "WalkSpeed Boost", false, function(v)
    Toggles.WalkSpeedBoost = v
    UpdateCharacterSpeed()
end)

CreateToggleRow(3, "Infinite Jump", false, function(v)
    Toggles.InfiniteJump = v
end)

-- FOOTER
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 32)
Footer.Position = UDim2.new(0, 0, 1, -32)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 14)
FooterTitle.Position = UDim2.new(0, 0, 0, 2)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 10
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 12)
FooterSub.Position = UDim2.new(0, 0, 0, 16)
FooterSub.BackgroundTransparency = 1
FooterSub.Font = Enum.Font.Gotham
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 9
FooterSub.Parent = Footer

-- DRAGGABLE ENGINE (Touch & Mouse Universal Drag)
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

-- PARENT TO SCREEN
ScreenGui.Parent = UIContainer
