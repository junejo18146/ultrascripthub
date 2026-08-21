--[[
    JUNEJO ULTRA SCRIPT HUB - +1 HIGH JUMP POWER ESCAPE
    Target Game: +1 High Jump Power Escape (Roblox)
    Game Link: https://www.roblox.com/games/83388257263676/1-High-Jump-Power-Escape
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11) - Exact Classic Standard
    Status: Standalone Dedicated Executable
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

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

-- Cleanup previous UI instances
for _, name in ipairs({"JunejoHighJumpPowerEscapeUI", "JunejoJumpPowerEscapeUI", "JunejoHubUI"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

-- Feature States
local Toggles = {
    AutoWin = false,
    AutoRebirth = false,
    Fly = false,
    Speed = false,
    InfiniteJump = false
}

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
-- 2. WALKSPEED BOOST ENGINE (50 Speed)
--------------------------------------------------------------------
local function UpdateCharacterSpeed()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Toggles.Speed then
                hum.WalkSpeed = 50
            else
                hum.WalkSpeed = 16
            end
        end
    end)
end

local function BindSpeedListener(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Toggles.Speed and hum.WalkSpeed ~= 50 then
                hum.WalkSpeed = 50
            end
        end)
    end
end

if LocalPlayer.Character then
    BindSpeedListener(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    BindSpeedListener(char)
    UpdateCharacterSpeed()
end)

RunService.Stepped:Connect(function()
    if Toggles.Speed and not Toggles.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        pcall(function()
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 50
        end)
    end
end)

--------------------------------------------------------------------
-- 3. 3D FLY SYSTEM (PC & Mobile Touch Compatible)
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

            -- PC Keyboard Controls
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
            if hum.MoveDirection.Magnitude > 0 then
                local forward = camera.CFrame.LookVector
                local right = camera.CFrame.RightVector
                local rawDir = hum.MoveDirection
                moveDirection = moveDirection + (forward * rawDir.Z * -1) + (right * rawDir.X)
            end

            local flySpeed = 60
            if moveDirection.Magnitude > 0 then
                flyBodyVelocity.Velocity = moveDirection.Unit * flySpeed
            else
                flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    end)
end

--------------------------------------------------------------------
-- 4. ULTRA SMOOTH ZERO-VIBRATION AUTO WIN & TROPHY ENGINE
--------------------------------------------------------------------
-- Helper to collect all win, finish, stage, wall, gate and trophy parts
local function CollectAllWinTargets()
    local targets = {}
    local char = LocalPlayer.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (not char or not obj:IsDescendantOf(char)) and not obj.Parent:IsA("Tool") then
            local n = obj.Name:lower()
            local parentN = obj.Parent and obj.Parent.Name:lower() or ""

            local isWinPart = (
                n:find("win") or n:find("finish") or n:find("trophy") or n:find("escape") or 
                n:find("stage") or n:find("gate") or n:find("goal") or n:find("endpad") or 
                n:find("finishline") or n:find("checkpoint") or parentN:find("win") or 
                parentN:find("finish") or parentN:find("trophy") or parentN:find("stage") or
                parentN:find("escape") or parentN:find("wall") or parentN:find("level")
            )

            -- Exclude UI / Shop / Door / decorative signs
            local isExcluded = (
                n:find("sign") or n:find("gui") or n:find("ui") or n:find("shop") or 
                n:find("light") or n:find("display") or n:find("text") or n:find("icon")
            )

            if isWinPart and not isExcluded then
                table.insert(targets, obj)
            end
        end
    end
    return targets
end

-- Helper to find the furthest finish pad in the track (End of Escape)
local function GetFurthestFinishPad()
    local allTargets = CollectAllWinTargets()
    if #allTargets == 0 then return nil end

    local bestPad = nil
    local maxDist = -math.huge

    for _, part in ipairs(allTargets) do
        local dist = part.Position.Magnitude
        local n = part.Name:lower()
        local pn = part.Parent and part.Parent.Name:lower() or ""

        if n:find("win") or n:find("finish") or n:find("trophy") or pn:find("win") or pn:find("finish") or pn:find("trophy") then
            dist = dist + 1000
        end

        if dist > maxDist then
            maxDist = dist
            bestPad = part
        end
    end

    return bestPad
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoWin then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum or hum.Health <= 0 then return end

                local furthestPad = GetFurthestFinishPad()
                local allTargets = CollectAllWinTargets()

                -- 1. Silent Touch Interest Simulation on Furthest Finish Pad (NO CAMERA SHAKE)
                if furthestPad and firetouchinterest then
                    pcall(function()
                        firetouchinterest(hrp, furthestPad, 0)
                        task.wait(0.02)
                        firetouchinterest(hrp, furthestPad, 1)
                    end)

                    local prompt = furthestPad:FindFirstChildOfClass("ProximityPrompt") or (furthestPad.Parent and furthestPad.Parent:FindFirstChildOfClass("ProximityPrompt"))
                    if prompt and prompt.Enabled then
                        pcall(function()
                            prompt.HoldDuration = 0
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                                fireproximityprompt(prompt, 0)
                            else
                                prompt:InputHoldBegin()
                                prompt:InputHoldEnd()
                            end
                        end)
                    end
                end

                -- 2. Smooth One-Way Positioning (Only if far away, with cooldown to avoid respawn flicker)
                if furthestPad and not Toggles.Fly then
                    local currentDist = (hrp.Position - furthestPad.Position).Magnitude
                    if currentDist > 25 then
                        pcall(function()
                            hrp.CFrame = furthestPad.CFrame + Vector3.new(0, 3.5, 0)
                            hrp.Velocity = Vector3.new(0, 0, 0)
                        end)
                        task.wait(0.3)
                    end
                end

                -- 3. Multi-Touch Simulation across all detected Stage & Win Triggers (Silent Background Touch)
                if firetouchinterest and #allTargets > 0 then
                    for _, pad in ipairs(allTargets) do
                        if not Toggles.AutoWin then break end
                        pcall(function()
                            firetouchinterest(hrp, pad, 0)
                            firetouchinterest(hrp, pad, 1)
                        end)
                    end
                end

                -- 4. TouchTransmitter Sweeper (Triggers any Touched event on the character)
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoWin then break end
                    if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
                        local part = obj.Parent
                        if not char or not part:IsDescendantOf(char) then
                            pcall(function()
                                if firetouchinterest then
                                    firetouchinterest(hrp, part, 0)
                                    firetouchinterest(hrp, part, 1)
                                end
                            end)
                        end
                    end
                end

                -- 5. ReplicatedStorage Deep Remote Sweeper (Win, Trophy, Finish, Escape, Stage, Reward)
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoWin then break end
                    if remote:IsA("RemoteEvent") then
                        local rn = remote.Name:lower()
                        if rn:find("win") or rn:find("trophy") or rn:find("finish") or rn:find("escape") or rn:find("goal") or rn:find("stage") or rn:find("claim") or rn:find("give") or rn:find("add") or rn:find("reward") or rn:find("level") or rn:find("complete") then
                            pcall(function()
                                remote:FireServer()
                                remote:FireServer(true)
                                remote:FireServer(1)
                                remote:FireServer("Win")
                                remote:FireServer("Trophy")
                                remote:FireServer("Finish")
                                remote:FireServer("Escape")
                                remote:FireServer(100)
                                if hrp then
                                    remote:FireServer(hrp.Position)
                                end
                                if furthestPad then
                                    remote:FireServer(furthestPad)
                                end
                            end)
                        end
                    elseif remote:IsA("RemoteFunction") then
                        local rn = remote.Name:lower()
                        if rn:find("win") or rn:find("trophy") or rn:find("finish") or rn:find("escape") or rn:find("claim") or rn:find("reward") then
                            pcall(function()
                                remote:InvokeServer()
                                remote:InvokeServer(1)
                                remote:InvokeServer("Win")
                            end)
                        end
                    end
                end

                -- 6. Auto Jump simulation (Triggers in-game Jump/Pass verification)
                pcall(function()
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                    if VirtualUser then
                        VirtualUser:Button1Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                        VirtualUser:Button1Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                    end
                end)
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 5. BULLETPROOF 4-LAYER AUTO REBIRTH ENGINE
--------------------------------------------------------------------
local function ClickGuiButton(btn)
    pcall(function()
        if firesignal then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.MouseButton1Down)
            firesignal(btn.MouseButton1Up)
            firesignal(btn.Activated)
        end
    end)
    pcall(function()
        if getconnections then
            for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                conn:Fire()
            end
            for _, conn in pairs(getconnections(btn.Activated)) do
                conn:Fire()
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.35)
        if Toggles.AutoRebirth then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                -- Layer 1: Global Remote Event Sweeper with all argument combinations
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoRebirth then break end
                    if remote:IsA("RemoteEvent") then
                        local rn = remote.Name:lower()
                        if rn:find("rebirth") or rn:find("prestige") or rn:find("buyrebirth") or rn:find("dorebirth") or rn:find("rankup") or rn:find("ascend") or rn:find("reset") or rn:find("evolution") or rn:find("tierup") then
                            pcall(function()
                                remote:FireServer()
                                remote:FireServer(1)
                                remote:FireServer(true)
                                remote:FireServer("Rebirth")
                                remote:FireServer("Buy")
                                remote:FireServer("All")
                                remote:FireServer(LocalPlayer)
                                remote:FireServer({})
                            end)
                        end
                    elseif remote:IsA("RemoteFunction") then
                        local rn = remote.Name:lower()
                        if rn:find("rebirth") or rn:find("prestige") or rn:find("buyrebirth") or rn:find("dorebirth") then
                            pcall(function()
                                remote:InvokeServer()
                                remote:InvokeServer(1)
                                remote:InvokeServer("Rebirth")
                                remote:InvokeServer(true)
                            end)
                        end
                    end
                end

                -- Layer 2: PlayerGui UI Rebirth / Buy / Confirm Auto-Clicker
                if LocalPlayer:FindFirstChild("PlayerGui") then
                    for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                        if not Toggles.AutoRebirth then break end
                        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                            local tn = gui.Text and gui.Text:lower() or ""
                            local gn = gui.Name:lower()
                            local parentN = gui.Parent and gui.Parent.Name:lower() or ""

                            local isRebirthBtn = (
                                tn:find("rebirth") or tn:find("prestige") or tn:find("re-birth") or 
                                gn:find("rebirth") or gn:find("prestige") or gn:find("buyrebirth") or 
                                parentN:find("rebirth") or parentN:find("prestige")
                            )

                            local isConfirmBtn = (
                                (tn == "yes" or tn == "confirm" or tn == "buy" or tn == "ok" or tn:find("accept")) and 
                                (parentN:find("rebirth") or parentN:find("prompt") or parentN:find("confirm") or parentN:find("popup"))
                            )

                            if (isRebirthBtn or isConfirmBtn) and not (tn:find("robux") or gn:find("robux") or tn:find("pass") or gn:find("pass") or tn:find("close")) then
                                ClickGuiButton(gui)
                            end
                        end
                    end
                end

                -- Layer 3: Workspace Rebirth Pads & NPC ProximityPrompts
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoRebirth then break end
                    local n = obj.Name:lower()
                    local parentN = obj.Parent and obj.Parent.Name:lower() or ""

                    if n:find("rebirth") or parentN:find("rebirth") then
                        if obj:IsA("BasePart") and hrp and firetouchinterest then
                            pcall(function()
                                firetouchinterest(hrp, obj, 0)
                                task.wait(0.01)
                                firetouchinterest(hrp, obj, 1)
                            end)
                        elseif obj:IsA("ProximityPrompt") and obj.Enabled then
                            pcall(function()
                                obj.HoldDuration = 0
                                if fireproximityprompt then
                                    fireproximityprompt(obj)
                                    fireproximityprompt(obj, 0)
                                else
                                    obj:InputHoldBegin()
                                    obj:InputHoldEnd()
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
-- 6. EXACT JUNEJO ULTRA SCRIPT HUB CLASSIC UI
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHighJumpPowerEscapeUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = UIContainer
end

-- Main Container Frame (280px width, 222px height for 5 features)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 222)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -111)
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
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.BorderSizePixel = 0
TitleLabel.Text = "+1 HIGH JUMP POWER ESCAPE"
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
CloseButton.BorderSizePixel = 0
CloseButton.AutoButtonColor = false
CloseButton.Selectable = false
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

-- Content Frame (Height 136px for 5 items)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -28, 0, 136)
ContentFrame.Position = UDim2.new(0, 14, 0, 36)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper function to add classic Junejo toggle rows (Full row clickable, transparent row, square checkbox)
local function AddToggleRow(text, configKey)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 24)
    Row.BackgroundTransparency = 1
    Row.BorderSizePixel = 0
    Row.Parent = ContentFrame
    
    local RowBtn = Instance.new("TextButton")
    RowBtn.Size = UDim2.new(1, 0, 1, 0)
    RowBtn.BackgroundTransparency = 1
    RowBtn.BorderSizePixel = 0
    RowBtn.AutoButtonColor = false
    RowBtn.Selectable = false
    RowBtn.Text = ""
    RowBtn.ZIndex = 5
    RowBtn.Parent = Row
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -28, 1, 0)
    Label.BackgroundTransparency = 1
    Label.BorderSizePixel = 0
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
        
        -- Feature specific triggers
        if configKey == "Fly" then
            if Toggles.Fly then
                StartFly()
            else
                StopFly()
            end
        elseif configKey == "Speed" then
            UpdateCharacterSpeed()
        end
    end)
end

-- Add the 5 requested toggle rows
AddToggleRow("Auto Win", "AutoWin")
AddToggleRow("Auto Rebirth", "AutoRebirth")
AddToggleRow("Fly Mode", "Fly")
AddToggleRow("WalkSpeed Boost (50)", "Speed")
AddToggleRow("Infinite Jump", "InfiniteJump")

-- Footer Frame
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 44)
Footer.Position = UDim2.new(0, 0, 1, -44)
Footer.BackgroundTransparency = 1
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 16)
FooterTitle.Position = UDim2.new(0, 0, 0, 5)
FooterTitle.BackgroundTransparency = 1
FooterTitle.BorderSizePixel = 0
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 13
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 14)
FooterSub.Position = UDim2.new(0, 0, 0, 21)
FooterSub.BackgroundTransparency = 1
FooterSub.BorderSizePixel = 0
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 11
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.Parent = Footer
