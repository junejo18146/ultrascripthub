--[[
    JUNEJO ULTRA SCRIPT HUB - +1 DRAIN WATER PER CLICK
    Target Game: +1 Drain Water Per Click (Roblox)
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11)
    Status: Unlocked Direct Standalone Execution
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

-- Cleanup previous UI instances
for _, name in ipairs({"JunejoDrainWaterUI", "JunejoHubUI_DrainWater", "JunejoDrainWaterMain"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

-- Feature States
local Toggles = {
    AutoDrain = false,
    AutoRebirth = false,
    Fly = false,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

local CustomSpeedValue = 50
local FlySpeed = 60

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

RunService.RenderStepped:Connect(function(dt)
    if Toggles.WalkSpeedBoost and not Toggles.Fly then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                if hum.WalkSpeed ~= CustomSpeedValue then
                    hum.WalkSpeed = CustomSpeedValue
                end
                if hum.MoveDirection.Magnitude > 0.05 then
                    local targetSpeed = tonumber(CustomSpeedValue) or 50
                    if targetSpeed > 16 then
                        local extraSpeed = (targetSpeed - 16)
                        local stepMultiplier = math.clamp(dt or (1/60), 0.001, 0.05)
                        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (extraSpeed * stepMultiplier))
                    end
                end
            end
        end)
    end
end)

--------------------------------------------------------------------
-- 3. BULLETPROOF 3D FLY SYSTEM (PC & MOBILE TOUCH COMPATIBLE)
--------------------------------------------------------------------
local flyBodyGyro, flyBodyVelocity, flyConnection

local function StopFly()
    pcall(function()
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if flyBodyGyro then
            flyBodyGyro:Destroy()
            flyBodyGyro = nil
        end
        if flyBodyVelocity then
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
        end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end)
end

local function StartFly()
    StopFly()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        hum.PlatformStand = true

        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.P = 9e4
        flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBodyGyro.CFrame = hrp.CFrame
        flyBodyGyro.Parent = hrp

        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBodyVelocity.Parent = hrp

        flyConnection = RunService.RenderStepped:Connect(function()
            if not Toggles.Fly or not hrp or not hrp.Parent or not hum or not hum.Parent then
                StopFly()
                return
            end

            hum.PlatformStand = true
            local camera = Workspace.CurrentCamera
            if not camera then return end

            flyBodyGyro.CFrame = camera.CFrame

            local moveDirection = Vector3.new(0, 0, 0)

            -- PC Controls
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end

            -- Mobile Touch / Thumbstick Integration
            if hum.MoveDirection.Magnitude > 0.05 then
                local camLook = camera.CFrame.LookVector
                local camRight = camera.CFrame.RightVector
                local localMove = hum.MoveDirection
                moveDirection = moveDirection + (camLook * (-localMove.Z)) + (camRight * localMove.X)
            end

            if moveDirection.Magnitude > 0 then
                flyBodyVelocity.Velocity = moveDirection.Unit * FlySpeed
            else
                flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Toggles.Fly then
        StartFly()
    end
end)

--------------------------------------------------------------------
-- 4. 5-LAYER AUTO DRAIN ENGINE (HYPER-SPEED WATER FARMER)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.05)
        if Toggles.AutoDrain then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local backpack = LocalPlayer:FindFirstChild("Backpack")

                -- Layer 1: Auto-Equip Pump / Drain Tool if unequipped
                if backpack and char and hum then
                    local currentTool = char:FindFirstChildOfClass("Tool")
                    if not currentTool then
                        for _, tool in ipairs(backpack:GetChildren()) do
                            if tool:IsA("Tool") then
                                hum:EquipTool(tool)
                                task.wait(0.05)
                                break
                            end
                        end
                    end
                end

                -- Layer 2: Tool Activation & Swing
                if char then
                    local activeTool = char:FindFirstChildOfClass("Tool")
                    if activeTool then
                        activeTool:Activate()
                    end
                end

                -- Layer 3: Virtual Input Tap / Click Emulation
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(500, 500))
                    task.wait(0.01)
                    VirtualUser:Button1Up(Vector2.new(500, 500))
                end)

                -- Layer 4: ReplicatedStorage Remote Sweeper for Drain & Click Events
                local drainKeywords = {"drain", "click", "tap", "water", "pump", "addwater", "drainthewater", "minewater", "collectwater", "drainevent", "drainwater", "hit", "swing", "use"}
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoDrain then break end
                    if remote:IsA("RemoteEvent") then
                        local rName = remote.Name:lower()
                        for _, kw in ipairs(drainKeywords) do
                            if rName:find(kw) then
                                remote:FireServer()
                                remote:FireServer(1)
                                remote:FireServer(true)
                                break
                            end
                        end
                    elseif remote:IsA("RemoteFunction") then
                        local rfName = remote.Name:lower()
                        for _, kw in ipairs(drainKeywords) do
                            if rfName:find(kw) then
                                pcall(function() remote:InvokeServer() end)
                                break
                            end
                        end
                    end
                end

                -- Layer 5: Workspace ClickDetectors & ProximityPrompts on Water / Draining spots
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoDrain then break end
                    if obj:IsA("ClickDetector") then
                        local objName = obj.Parent and obj.Parent.Name:lower() or ""
                        for _, kw in ipairs(drainKeywords) do
                            if objName:find(kw) then
                                if fireclickdetector then
                                    fireclickdetector(obj)
                                end
                                break
                            end
                        end
                    elseif obj:IsA("ProximityPrompt") then
                        local objText = (obj.ActionText .. " " .. obj.ObjectText .. " " .. (obj.Parent and obj.Parent.Name or "")):lower()
                        for _, kw in ipairs(drainKeywords) do
                            if objText:find(kw) then
                                if fireproximityprompt then
                                    fireproximityprompt(obj)
                                end
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 5. AUTO REBIRTH ENGINE (PERMANENT MULTIPLIER GROWTH)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.AutoRebirth then
            pcall(function()
                local rebirthKeywords = {"rebirth", "prestige", "dorebirth", "buyrebirth", "claimrebirth", "performrebirth"}
                
                -- Layer 1: ReplicatedStorage Remotes
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoRebirth then break end
                    if remote:IsA("RemoteEvent") then
                        local rName = remote.Name:lower()
                        for _, kw in ipairs(rebirthKeywords) do
                            if rName:find(kw) then
                                remote:FireServer()
                                remote:FireServer(1)
                                remote:FireServer(true)
                                break
                            end
                        end
                    elseif remote:IsA("RemoteFunction") then
                        local rfName = remote.Name:lower()
                        for _, kw in ipairs(rebirthKeywords) do
                            if rfName:find(kw) then
                                pcall(function() remote:InvokeServer() end)
                                pcall(function() remote:InvokeServer(1) end)
                                break
                            end
                        end
                    end
                end

                -- Layer 2: Workspace Rebirth Pads & Prompts
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoRebirth then break end
                    if prompt:IsA("ProximityPrompt") then
                        local pText = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. (prompt.Parent and prompt.Parent.Name or "")):lower()
                        for _, kw in ipairs(rebirthKeywords) do
                            if pText:find(kw) then
                                if fireproximityprompt then
                                    fireproximityprompt(prompt)
                                end
                                break
                            end
                        end
                    elseif prompt:IsA("BasePart") and hrp and firetouchinterest then
                        local partName = prompt.Name:lower()
                        for _, kw in ipairs(rebirthKeywords) do
                            if partName:find(kw) then
                                firetouchinterest(hrp, prompt, 0)
                                task.wait()
                                firetouchinterest(hrp, prompt, 1)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- UNIFIED JUNEJO EXECUTIVE UI (290x228px Compact Dark UI)
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoDrainWaterUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = UIContainer
end

-- Main Container Frame (Width: 290px, Height: 228px)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 290, 0, 228)
MainFrame.Position = UDim2.new(0.5, -145, 0.5, -114)
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
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "+1 DRAIN WATER PER CLICK"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 34, 0, 34)
CloseButton.Position = UDim2.new(1, -34, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 170)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
    StopFly()
    ScreenGui:Destroy()
end)

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
ContentFrame.Size = UDim2.new(1, -28, 0, 136)
ContentFrame.Position = UDim2.new(0, 14, 0, 36)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 3)
UIList.Parent = ContentFrame

-- Helper function to add compact toggle rows (Full row clickable)
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 22)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -26, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local CheckboxBg = Instance.new("Frame")
    CheckboxBg.Size = UDim2.new(0, 20, 0, 20)
    CheckboxBg.Position = UDim2.new(1, -20, 0.5, -10)
    CheckboxBg.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    CheckboxBg.BorderSizePixel = 0
    CheckboxBg.Parent = Row

    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 4)
    CheckCorner.Parent = CheckboxBg

    local CheckStroke = Instance.new("UIStroke")
    CheckStroke.Color = Color3.fromRGB(45, 45, 55)
    CheckStroke.Thickness = 1
    CheckStroke.Parent = CheckboxBg

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 10, 0, 10)
    Indicator.Position = UDim2.new(0.5, -5, 0.5, -5)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = CheckboxBg

    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(0, 2)
    IndCorner.Parent = Indicator

    local ClickHitbox = Instance.new("TextButton")
    ClickHitbox.Size = UDim2.new(1, 0, 1, 0)
    ClickHitbox.BackgroundTransparency = 1
    ClickHitbox.Text = ""
    ClickHitbox.Parent = Row

    local function ToggleState()
        Toggles[configKey] = not Toggles[configKey]
        Indicator.Visible = Toggles[configKey]
        if callback then
            callback(Toggles[configKey])
        end
    end

    ClickHitbox.MouseButton1Click:Connect(ToggleState)
    return Row
end

-- 1. Auto Drain
AddToggleRow("Auto Drain", "AutoDrain", nil)

-- 2. Auto Rebirth
AddToggleRow("Auto Rebirth", "AutoRebirth", nil)

-- 3. Fly Mode (3D Smooth Fly)
AddToggleRow("Fly Mode", "Fly", function(state)
    if state then
        StartFly()
    else
        StopFly()
    end
end)

-- 4. WalkSpeed Boost
AddToggleRow("WalkSpeed Boost", "WalkSpeedBoost", function(state)
    UpdateCharacterSpeed()
end)

-- WalkSpeed Adjuster Row (- / + Controls)
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, 0, 0, 20)
SpeedRow.BackgroundTransparency = 1
SpeedRow.Parent = ContentFrame

local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Size = UDim2.new(0, 90, 1, 0)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Text = "Adjust Speed:"
SpeedTitle.TextColor3 = Color3.fromRGB(160, 160, 175)
SpeedTitle.TextSize = 10
SpeedTitle.Font = Enum.Font.GothamMedium
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left
SpeedTitle.Parent = SpeedRow

local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 22, 0, 18)
MinusBtn.Position = UDim2.new(0, 95, 0.5, -9)
MinusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
MinusBtn.BorderSizePixel = 0
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.TextSize = 11
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Parent = SpeedRow

local MinusCorner = Instance.new("UICorner")
MinusCorner.CornerRadius = UDim.new(0, 4)
MinusCorner.Parent = MinusBtn

local SpeedValueLabel = Instance.new("TextLabel")
SpeedValueLabel.Size = UDim2.new(0, 40, 1, 0)
SpeedValueLabel.Position = UDim2.new(0, 120, 0, 0)
SpeedValueLabel.BackgroundTransparency = 1
SpeedValueLabel.Text = tostring(CustomSpeedValue)
SpeedValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedValueLabel.TextSize = 10
SpeedValueLabel.Font = Enum.Font.GothamBold
SpeedValueLabel.Parent = SpeedRow

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 22, 0, 18)
PlusBtn.Position = UDim2.new(0, 165, 0.5, -9)
PlusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
PlusBtn.BorderSizePixel = 0
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.TextSize = 11
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Parent = SpeedRow

local PlusCorner = Instance.new("UICorner")
PlusCorner.CornerRadius = UDim.new(0, 4)
PlusCorner.Parent = PlusBtn

MinusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.max(20, CustomSpeedValue - 10)
    SpeedValueLabel.Text = tostring(CustomSpeedValue)
    if Toggles.WalkSpeedBoost then
        UpdateCharacterSpeed()
    end
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 10)
    SpeedValueLabel.Text = tostring(CustomSpeedValue)
    if Toggles.WalkSpeedBoost then
        UpdateCharacterSpeed()
    end
end)

-- 5. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump", nil)

-- Footer Branding
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, -28, 0, 30)
Footer.Position = UDim2.new(0, 14, 1, -34)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 14)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 10
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.TextXAlignment = Enum.TextXAlignment.Center
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 12)
FooterSub.Position = UDim2.new(0, 0, 0, 14)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 9
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.TextXAlignment = Enum.TextXAlignment.Center
FooterSub.Parent = Footer
