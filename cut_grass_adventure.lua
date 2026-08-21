--[[
    JUNEJO ULTRA SCRIPT HUB - +1 CUT GRASS ADVENTURE
    Target Game: +1 Cut Grass Adventure (Roblox)
    Game Link: https://www.roblox.com/games/90086669327265/1-Cut-Grass-Adventur
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
for _, name in ipairs({"JunejoCutGrassAdventureUI", "JunejoCutGrassUI", "JunejoHubUI"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

-- Feature States
local Toggles = {
    RemoveGrass = false,
    AutoCollect = false,
    AutoSell = false,
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
-- 4. MASTER REMOVE GRASS ENGINE (Instant Clear & Auto Harvest)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.08)
        if Toggles.RemoveGrass then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local bp = LocalPlayer:FindFirstChild("Backpack")

                -- 1. Auto-Equip Cutter / Tool to register server harvest
                if bp and hum then
                    for _, tool in ipairs(bp:GetChildren()) do
                        if tool:IsA("Tool") then
                            hum:EquipTool(tool)
                        end
                    end
                end

                -- 2. Fast Tool Activation
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            pcall(function() tool:Activate() end)
                        end
                    end
                end

                -- 3. Virtual Swing / Click Emulation
                pcall(function()
                    if VirtualUser then
                        VirtualUser:Button1Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                        task.wait(0.01)
                        VirtualUser:Button1Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                    end
                end)

                -- 4. Instant Grass Removal, Transparency, Collision Disabling & Touch Sweep
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.RemoveGrass then break end
                    local n = obj.Name:lower()
                    local parentN = obj.Parent and obj.Parent.Name:lower() or ""

                    if n:find("grass") or n:find("plant") or n:find("crop") or n:find("leaf") or n:find("blade") or n:find("bush") or n:find("weed") or parentN:find("grass") then
                        if obj:IsA("BasePart") then
                            obj.Transparency = 1
                            obj.CanCollide = false
                            if hrp and firetouchinterest then
                                firetouchinterest(hrp, obj, 0)
                                task.wait()
                                firetouchinterest(hrp, obj, 1)
                            end
                        elseif obj:IsA("Texture") or obj:IsA("Decal") then
                            obj.Transparency = 1
                        end
                    end
                end

                -- 5. Remote Event Sweeper for Grass Removal / Cut / Harvest
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.RemoveGrass then break end
                    if remote:IsA("RemoteEvent") then
                        local rn = remote.Name:lower()
                        if rn:find("cut") or rn:find("remove") or rn:find("clear") or rn:find("swing") or rn:find("harvest") or rn:find("slash") or rn:find("mow") or rn:find("grass") or rn:find("farm") or rn:find("gain") or rn:find("click") or rn:find("hit") or rn:find("train") then
                            pcall(function()
                                remote:FireServer()
                                remote:FireServer(true)
                                remote:FireServer(1)
                                if hrp then
                                    remote:FireServer(hrp.Position)
                                end
                            end)
                        end
                    elseif remote:IsA("RemoteFunction") then
                        local rn = remote.Name:lower()
                        if rn:find("cut") or rn:find("remove") or rn:find("clear") or rn:find("swing") or rn:find("harvest") or rn:find("grass") then
                            pcall(function()
                                remote:InvokeServer()
                            end)
                        end
                    end
                end

                -- 6. ProximityPrompt Auto-Trigger on Grass Plots
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.RemoveGrass then break end
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local pn = prompt.Parent and prompt.Parent.Name:lower() or ""
                        local actText = prompt.ActionText:lower()
                        local objText = prompt.ObjectText:lower()
                        if pn:find("grass") or pn:find("cut") or pn:find("remove") or pn:find("farm") or actText:find("cut") or actText:find("remove") or actText:find("harvest") or objText:find("grass") then
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
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 5. MASTER AUTO COLLECT ENGINE (Magnetic Instant Coins & Drops)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.1)
        if Toggles.AutoCollect then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- 1. Scan Workspace for Coins, Gems, Drops, Orbs, Loot & Collectibles
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoCollect then break end
                    local n = obj.Name:lower()
                    local parentN = obj.Parent and obj.Parent.Name:lower() or ""

                    if n:find("coin") or n:find("gem") or n:find("drop") or n:find("loot") or n:find("reward") or n:find("orb") or n:find("star") or n:find("chest") or n:find("shard") or n:find("pickup") or parentN:find("coin") or parentN:find("drop") or parentN:find("loot") or parentN:find("reward") then
                        if obj:IsA("BasePart") then
                            if firetouchinterest then
                                firetouchinterest(hrp, obj, 0)
                                task.wait()
                                firetouchinterest(hrp, obj, 1)
                            else
                                obj.CFrame = hrp.CFrame
                            end
                        end
                    end
                end

                -- 2. Trigger ProximityPrompts on all collectable drops
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoCollect then break end
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local pn = prompt.Parent and prompt.Parent.Name:lower() or ""
                        local actText = prompt.ActionText:lower()
                        local objText = prompt.ObjectText:lower()
                        if pn:find("coin") or pn:find("drop") or pn:find("collect") or pn:find("pickup") or pn:find("loot") or actText:find("collect") or actText:find("pickup") or objText:find("coin") or objText:find("gem") or objText:find("loot") then
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
                        end
                    end
                end

                -- 3. Remote Sweeper for Collect / Pickup
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoCollect then break end
                    if remote:IsA("RemoteEvent") then
                        local rn = remote.Name:lower()
                        if rn:find("collect") or rn:find("pickup") or rn:find("coin") or rn:find("drop") or rn:find("loot") or rn:find("claim") or rn:find("reward") or rn:find("grab") then
                            pcall(function()
                                remote:FireServer()
                                remote:FireServer(true)
                                remote:FireServer(1)
                                remote:FireServer("Coin")
                                remote:FireServer("Drop")
                                remote:FireServer("All")
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
-- 6. MASTER AUTO SELL ENGINE (Automatic Coin/Grass Sell Loop)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.25)
        if Toggles.AutoSell then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                -- 1. Remote Event Sweeper for Selling
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoSell then break end
                    if remote:IsA("RemoteEvent") then
                        local rn = remote.Name:lower()
                        if rn:find("sell") or rn:find("convert") or rn:find("deposit") or rn:find("exchange") or rn:find("cashin") then
                            pcall(function()
                                remote:FireServer()
                                remote:FireServer(true)
                                remote:FireServer("Sell")
                                remote:FireServer("All")
                                remote:FireServer(1)
                            end)
                        end
                    elseif remote:IsA("RemoteFunction") then
                        local rn = remote.Name:lower()
                        if rn:find("sell") or rn:find("convert") or rn:find("exchange") then
                            pcall(function()
                                remote:InvokeServer()
                            end)
                        end
                    end
                end

                -- 2. Sell Zone Touch Interest Detection
                if hrp then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not Toggles.AutoSell then break end
                        if obj:IsA("BasePart") then
                            local n = obj.Name:lower()
                            if n:find("sell") or n:find("sellpad") or n:find("sellzone") or n:find("sellarea") or n:find("sellring") or n:find("sellcircle") then
                                if firetouchinterest then
                                    firetouchinterest(hrp, obj, 0)
                                    task.wait()
                                    firetouchinterest(hrp, obj, 1)
                                end
                            end
                        end
                    end
                end

                -- 3. Sell ProximityPrompt Trigger
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoSell then break end
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local pn = prompt.Parent and prompt.Parent.Name:lower() or ""
                        local actText = prompt.ActionText:lower()
                        if pn:find("sell") or actText:find("sell") then
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
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 7. MASTER AUTO REBIRTH ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoRebirth then
            pcall(function()
                -- Remote Event Sweeper for Rebirth & Prestige
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoRebirth then break end
                    if remote:IsA("RemoteEvent") then
                        local rn = remote.Name:lower()
                        if rn:find("rebirth") or rn:find("prestige") or rn:find("buyrebirth") or rn:find("dorebirth") or rn:find("rankup") or rn:find("ascend") then
                            pcall(function()
                                remote:FireServer()
                                remote:FireServer(1)
                                remote:FireServer(true)
                            end)
                        end
                    elseif remote:IsA("RemoteFunction") then
                        local rn = remote.Name:lower()
                        if rn:find("rebirth") or rn:find("prestige") or rn:find("buyrebirth") then
                            pcall(function()
                                remote:InvokeServer()
                                remote:InvokeServer(1)
                            end)
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 8. EXACT JUNEJO ULTRA SCRIPT HUB CLASSIC UI
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoCutGrassAdventureUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = UIContainer
end

-- Main Container Frame (280px width, 278px height for 7 features)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 278)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -139)
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
TitleLabel.Text = "+1 CUT GRASS ADVENTURE"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
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
ContentFrame.Size = UDim2.new(1, -28, 0, 192)
ContentFrame.Position = UDim2.new(0, 14, 0, 36)
ContentFrame.BackgroundTransparency = 1
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

-- Add the 7 official requested toggle rows (Explicit "Auto Collect")
AddToggleRow("Remove Grass", "RemoveGrass")
AddToggleRow("Auto Collect", "AutoCollect")
AddToggleRow("Auto Sell", "AutoSell")
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
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 16)
FooterTitle.Position = UDim2.new(0, 0, 0, 5)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 13
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 14)
FooterSub.Position = UDim2.new(0, 0, 0, 21)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 11
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.Parent = Footer
