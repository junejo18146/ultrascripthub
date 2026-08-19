--[[
    JUNEJO ULTRA SCRIPT HUB - +1 SPINJITSU ESCAPE
    Target Game: +1 Spinjitsu Escape (Roblox)
    Game Link: https://www.roblox.com/games/131910189515331/1-Spinjitsu-Escape
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11) - Solid Matte Black
    Status: Unlocked Direct Standalone Execution
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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
for _, name in ipairs({"JunejoSpinjitsuEscapeUI", "JunejoHubUI_Spinjitsu", "JunejoSpinjitsuMain"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

-- Feature States
local Toggles = {
    AutoSpinjitsu = false,
    AutoBreakWalls = false,
    AutoStageWins = false,
    AutoCollectRewards = false,
    AutoUpgrade = false,
    AutoHatch = false,
    AutoEquipBest = false,
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
-- 1. INFINITE JUMP (PC & MOBILE COMPATIBLE)
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
-- 3. 3D FLY SYSTEM (WASD & TOUCH JOYSTICK)
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

            -- Mobile Touch Joystick Support
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
-- 4. AUTO SPINJITSU ENGINE (AUTOMATIC JITSU / SPIN TRAINING)
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.08)
        if Toggles.AutoSpinjitsu then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local backpack = LocalPlayer:FindFirstChild("Backpack")

                -- Equip Spin / Jitsu tool if any
                if backpack and char and hum then
                    local currentTool = char:FindFirstChildOfClass("Tool")
                    if not currentTool then
                        for _, tool in ipairs(backpack:GetChildren()) do
                            if tool:IsA("Tool") then
                                hum:EquipTool(tool)
                                break
                            end
                        end
                    end
                end

                -- Activate tool
                if char then
                    local activeTool = char:FindFirstChildOfClass("Tool")
                    if activeTool then
                        activeTool:Activate()
                    end
                end

                -- Tap / Click Emulation
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(500, 500))
                    task.wait(0.01)
                    VirtualUser:Button1Up(Vector2.new(500, 500))
                end)

                -- Remote Sweeper for Spin / Jitsu Training
                local spinKeywords = {"spin", "jitsu", "train", "click", "power", "addpower", "spinjitsu", "swing", "use"}
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoSpinjitsu then break end
                    if remote:IsA("RemoteEvent") then
                        local rName = remote.Name:lower()
                        for _, kw in ipairs(spinKeywords) do
                            if rName:find(kw) then
                                remote:FireServer()
                                remote:FireServer(1)
                                remote:FireServer(true)
                                break
                            end
                        end
                    elseif remote:IsA("RemoteFunction") then
                        local rfName = remote.Name:lower()
                        for _, kw in ipairs(spinKeywords) do
                            if rfName:find(kw) then
                                pcall(function() remote:InvokeServer() end)
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
-- 5. AUTO BREAK WALLS ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.15)
        if Toggles.AutoBreakWalls then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local wallKeywords = {"wall", "obstacle", "door", "barrier", "gate", "break", "smash"}

                -- Method 1: Remote Events for breaking walls / damaging barriers
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoBreakWalls then break end
                    if remote:IsA("RemoteEvent") then
                        local rName = remote.Name:lower()
                        if rName:find("break") or rName:find("wall") or rName:find("hit") or rName:find("smash") or rName:find("damage") then
                            remote:FireServer()
                            remote:FireServer(1)
                        end
                    end
                end

                -- Method 2: Touch & Proximity interactions on nearby walls
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoBreakWalls then break end
                    if obj:IsA("BasePart") and obj.CanTouch and (obj.Position - hrp.Position).Magnitude <= 35 then
                        local objName = obj.Name:lower()
                        for _, kw in ipairs(wallKeywords) do
                            if objName:find(kw) then
                                if firetouchinterest then
                                    firetouchinterest(hrp, obj, 0)
                                    task.wait()
                                    firetouchinterest(hrp, obj, 1)
                                end
                                break
                            end
                        end
                    elseif obj:IsA("ProximityPrompt") then
                        local pText = (obj.ActionText .. " " .. obj.ObjectText .. " " .. (obj.Parent and obj.Parent.Name or "")):lower()
                        for _, kw in ipairs(wallKeywords) do
                            if pText:find(kw) then
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
-- 6. AUTO STAGE & AUTO WINS ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoStageWins then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local winKeywords = {"win", "finish", "stage", "door", "end", "portal", "checkpoint", "goal", "zone"}

                -- Method 1: Scan Remotes for Stage Complete / Win claims
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoStageWins then break end
                    if remote:IsA("RemoteEvent") then
                        local rName = remote.Name:lower()
                        for _, kw in ipairs(winKeywords) do
                            if rName:find(kw) then
                                remote:FireServer()
                                remote:FireServer(1)
                                remote:FireServer(true)
                                break
                            end
                        end
                    elseif remote:IsA("RemoteFunction") then
                        local rfName = remote.Name:lower()
                        for _, kw in ipairs(winKeywords) do
                            if rfName:find(kw) then
                                pcall(function() remote:InvokeServer() end)
                                break
                            end
                        end
                    end
                end

                -- Method 2: Scan Workspace Finish Lines & Stage Pads
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoStageWins then break end
                    if part:IsA("BasePart") and part.CanTouch then
                        local pName = part.Name:lower()
                        if pName:find("finish") or pName:find("win") or pName:find("endpad") or pName:find("goal") or pName:find("nextstage") then
                            if firetouchinterest then
                                firetouchinterest(hrp, part, 0)
                                task.wait()
                                firetouchinterest(hrp, part, 1)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 7. AUTO COLLECT REWARDS & GIFTS ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.AutoCollectRewards then
            pcall(function()
                local rewardKeywords = {"reward", "gift", "daily", "claim", "free", "chest", "bonus", "time", "spinwheel"}

                -- Layer 1: Remotes for Claiming Free Gifts / Daily Rewards
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoCollectRewards then break end
                    if remote:IsA("RemoteEvent") then
                        local rName = remote.Name:lower()
                        for _, kw in ipairs(rewardKeywords) do
                            if rName:find(kw) then
                                for i = 1, 12 do
                                    remote:FireServer(i)
                                end
                                remote:FireServer()
                                break
                            end
                        end
                    elseif remote:IsA("RemoteFunction") then
                        local rfName = remote.Name:lower()
                        for _, kw in ipairs(rewardKeywords) do
                            if rfName:find(kw) then
                                pcall(function() remote:InvokeServer() end)
                                for i = 1, 12 do
                                    pcall(function() remote:InvokeServer(i) end)
                                end
                                break
                            end
                        end
                    end
                end

                -- Layer 2: Workspace Reward Chests / Prompts
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoCollectRewards then break end
                    if prompt:IsA("ProximityPrompt") then
                        local pText = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. (prompt.Parent and prompt.Parent.Name or "")):lower()
                        for _, kw in ipairs(rewardKeywords) do
                            if pText:find(kw) then
                                if fireproximityprompt then
                                    fireproximityprompt(prompt)
                                end
                                break
                            end
                        end
                    elseif prompt:IsA("BasePart") and hrp and firetouchinterest then
                        local pName = prompt.Name:lower()
                        if pName:find("chest") or pName:find("reward") or pName:find("drop") or pName:find("coin") then
                            firetouchinterest(hrp, prompt, 0)
                            task.wait()
                            firetouchinterest(hrp, prompt, 1)
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 8. AUTO UPGRADE SPINJITSU ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(1.0)
        if Toggles.AutoUpgrade then
            pcall(function()
                local upgradeKeywords = {"upgrade", "buyupgrade", "spinup", "jitsuupgrade", "powerupgrade", "speedupgrade"}
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoUpgrade then break end
                    if remote:IsA("RemoteEvent") then
                        local rName = remote.Name:lower()
                        for _, kw in ipairs(upgradeKeywords) do
                            if rName:find(kw) then
                                for tier = 1, 10 do
                                    remote:FireServer(tier)
                                end
                                remote:FireServer("All")
                                remote:FireServer()
                                break
                            end
                        end
                    elseif remote:IsA("RemoteFunction") then
                        local rfName = remote.Name:lower()
                        for _, kw in ipairs(upgradeKeywords) do
                            if rfName:find(kw) then
                                pcall(function() remote:InvokeServer() end)
                                for tier = 1, 10 do
                                    pcall(function() remote:InvokeServer(tier) end)
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
-- 9. AUTO HATCH / PETS ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.8)
        if Toggles.AutoHatch then
            pcall(function()
                local eggKeywords = {"egg", "hatch", "buyegg", "openegg", "pet", "summon"}

                -- Layer 1: Remotes for Opening Egg
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoHatch then break end
                    if remote:IsA("RemoteEvent") then
                        local rName = remote.Name:lower()
                        for _, kw in ipairs(eggKeywords) do
                            if rName:find(kw) then
                                remote:FireServer(1, "Single")
                                remote:FireServer(1)
                                remote:FireServer("Basic")
                                remote:FireServer("Egg1")
                                break
                            end
                        end
                    elseif remote:IsA("RemoteFunction") then
                        local rfName = remote.Name:lower()
                        for _, kw in ipairs(eggKeywords) do
                            if rfName:find(kw) then
                                pcall(function() remote:InvokeServer(1) end)
                                pcall(function() remote:InvokeServer("Egg1") end)
                                break
                            end
                        end
                    end
                end

                -- Layer 2: Workspace Egg Proximity Prompts
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoHatch then break end
                    if prompt:IsA("ProximityPrompt") then
                        local pText = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. (prompt.Parent and prompt.Parent.Name or "")):lower()
                        for _, kw in ipairs(eggKeywords) do
                            if pText:find(kw) then
                                if fireproximityprompt then
                                    fireproximityprompt(prompt)
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
-- 10. AUTO EQUIP BEST PET ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(2.0)
        if Toggles.AutoEquipBest then
            pcall(function()
                local equipKeywords = {"equipbest", "equipall", "bestpet", "autoequip", "equipthebest"}
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoEquipBest then break end
                    if remote:IsA("RemoteEvent") then
                        local rName = remote.Name:lower()
                        for _, kw in ipairs(equipKeywords) do
                            if rName:find(kw) then
                                remote:FireServer()
                                remote:FireServer(true)
                                break
                            end
                        end
                    elseif remote:IsA("RemoteFunction") then
                        local rfName = remote.Name:lower()
                        for _, kw in ipairs(equipKeywords) do
                            if rfName:find(kw) then
                                pcall(function() remote:InvokeServer() end)
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
-- 11. AUTO REBIRTH ENGINE
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
-- UNIFIED JUNEJO EXECUTIVE UI (100% SOLID MATTE BLACK THEME #0F0F11)
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoSpinjitsuEscapeUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = UIContainer
end

-- Main Container Frame (Solid 100% Opaque Matte Black #0F0F11)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 260)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BackgroundTransparency = 0
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
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

-- Dragging System (Desktop & Mobile Touch)
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

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
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        updateDrag(input)
    end
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "+1 SPINJITSU ESCAPE"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -30, 0, 6)
CloseButton.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 160)
CloseButton.TextSize = 12
CloseButton.AutoButtonColor = false
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    Toggles.AutoSpinjitsu = false
    Toggles.AutoBreakWalls = false
    Toggles.AutoStageWins = false
    Toggles.AutoCollectRewards = false
    Toggles.AutoUpgrade = false
    Toggles.AutoHatch = false
    Toggles.AutoEquipBest = false
    Toggles.AutoRebirth = false
    Toggles.WalkSpeedBoost = false
    Toggles.InfiniteJump = false
    Toggles.Fly = false
    StopFly()
    UpdateCharacterSpeed()
    ScreenGui:Destroy()
end)

-- Scrollable Content Area
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"
ContentScroll.Size = UDim2.new(1, -16, 1, -80)
ContentScroll.Position = UDim2.new(0, 8, 0, 42)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 430)
ContentScroll.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.Parent = ContentScroll

-- Helper: Create Toggle Row
local function CreateToggleRow(name, initialValue, callback, order)
    local Row = Instance.new("Frame")
    Row.Name = name .. "Row"
    Row.Size = UDim2.new(1, -4, 0, 32)
    Row.BackgroundColor3 = Color3.fromRGB(21, 21, 25)
    Row.BorderSizePixel = 0
    Row.LayoutOrder = order or 1
    Row.Parent = ContentScroll

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 6)
    RowCorner.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -45, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Checkbox = Instance.new("TextButton")
    Checkbox.Size = UDim2.new(0, 20, 0, 20)
    Checkbox.Position = UDim2.new(1, -26, 0.5, -10)
    Checkbox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Checkbox.Text = ""
    Checkbox.AutoButtonColor = false
    Checkbox.BorderSizePixel = 0
    Checkbox.Parent = Row

    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 5)
    CheckCorner.Parent = Checkbox

    local CheckStroke = Instance.new("UIStroke")
    CheckStroke.Color = Color3.fromRGB(45, 45, 55)
    CheckStroke.Thickness = 1
    CheckStroke.Parent = Checkbox

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 10, 0, 10)
    Indicator.Position = UDim2.new(0.5, -5, 0.5, -5)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.BorderSizePixel = 0
    Indicator.Visible = initialValue
    Indicator.Parent = Checkbox

    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(0, 3)
    IndCorner.Parent = Indicator

    local isEnabled = initialValue
    local function ToggleState()
        isEnabled = not isEnabled
        Indicator.Visible = isEnabled
        if isEnabled then
            Checkbox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            CheckStroke.Color = Color3.fromRGB(80, 80, 100)
        else
            Checkbox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
            CheckStroke.Color = Color3.fromRGB(45, 45, 55)
        end
        callback(isEnabled)
    end

    Checkbox.MouseButton1Click:Connect(ToggleState)
    
    local ClickDetector = Instance.new("TextButton")
    ClickDetector.Size = UDim2.new(1, -35, 1, 0)
    ClickDetector.Position = UDim2.new(0, 0, 0, 0)
    ClickDetector.BackgroundTransparency = 1
    ClickDetector.Text = ""
    ClickDetector.Parent = Row
    ClickDetector.MouseButton1Click:Connect(ToggleState)

    return Row
end

-- Helper: Create Speed Controller Row
local function CreateSpeedController(order)
    local Row = Instance.new("Frame")
    Row.Name = "SpeedControllerRow"
    Row.Size = UDim2.new(1, -4, 0, 32)
    Row.BackgroundColor3 = Color3.fromRGB(21, 21, 25)
    Row.BorderSizePixel = 0
    Row.LayoutOrder = order or 99
    Row.Parent = ContentScroll

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 6)
    RowCorner.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 85, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = "WalkSpeed"
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local MinusBtn = Instance.new("TextButton")
    MinusBtn.Size = UDim2.new(0, 22, 0, 20)
    MinusBtn.Position = UDim2.new(0, 100, 0.5, -10)
    MinusBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    MinusBtn.Font = Enum.Font.GothamBold
    MinusBtn.Text = "-"
    MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinusBtn.TextSize = 12
    MinusBtn.AutoButtonColor = false
    MinusBtn.BorderSizePixel = 0
    MinusBtn.Parent = Row
    local MinusCorner = Instance.new("UICorner")
    MinusCorner.CornerRadius = UDim.new(0, 4)
    MinusCorner.Parent = MinusBtn

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 36, 0, 20)
    ValueLabel.Position = UDim2.new(0, 126, 0.5, -10)
    ValueLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Text = tostring(CustomSpeedValue)
    ValueLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    ValueLabel.TextSize = 11
    ValueLabel.Parent = Row
    local ValueCorner = Instance.new("UICorner")
    ValueCorner.CornerRadius = UDim.new(0, 4)
    ValueCorner.Parent = ValueLabel

    local PlusBtn = Instance.new("TextButton")
    PlusBtn.Size = UDim2.new(0, 22, 0, 20)
    PlusBtn.Position = UDim2.new(0, 166, 0.5, -10)
    PlusBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    PlusBtn.Font = Enum.Font.GothamBold
    PlusBtn.Text = "+"
    PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlusBtn.TextSize = 12
    PlusBtn.AutoButtonColor = false
    PlusBtn.BorderSizePixel = 0
    PlusBtn.Parent = Row
    local PlusCorner = Instance.new("UICorner")
    PlusCorner.CornerRadius = UDim.new(0, 4)
    PlusCorner.Parent = PlusBtn

    local BoostCheck = Instance.new("TextButton")
    BoostCheck.Size = UDim2.new(0, 20, 0, 20)
    BoostCheck.Position = UDim2.new(1, -26, 0.5, -10)
    BoostCheck.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    BoostCheck.Text = ""
    BoostCheck.AutoButtonColor = false
    BoostCheck.BorderSizePixel = 0
    BoostCheck.Parent = Row
    local BoostCheckCorner = Instance.new("UICorner")
    BoostCheckCorner.CornerRadius = UDim.new(0, 5)
    BoostCheckCorner.Parent = BoostCheck
    local BoostCheckStroke = Instance.new("UIStroke")
    BoostCheckStroke.Color = Color3.fromRGB(45, 45, 55)
    BoostCheckStroke.Thickness = 1
    BoostCheckStroke.Parent = BoostCheck

    local BoostIndicator = Instance.new("Frame")
    BoostIndicator.Size = UDim2.new(0, 10, 0, 10)
    BoostIndicator.Position = UDim2.new(0.5, -5, 0.5, -5)
    BoostIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BoostIndicator.BorderSizePixel = 0
    BoostIndicator.Visible = false
    BoostIndicator.Parent = BoostCheck
    local BoostIndCorner = Instance.new("UICorner")
    BoostIndCorner.CornerRadius = UDim.new(0, 3)
    BoostIndCorner.Parent = BoostIndicator

    MinusBtn.MouseButton1Click:Connect(function()
        CustomSpeedValue = math.max(16, CustomSpeedValue - 10)
        ValueLabel.Text = tostring(CustomSpeedValue)
        UpdateCharacterSpeed()
    end)

    PlusBtn.MouseButton1Click:Connect(function()
        CustomSpeedValue = math.min(300, CustomSpeedValue + 10)
        ValueLabel.Text = tostring(CustomSpeedValue)
        UpdateCharacterSpeed()
    end)

    BoostCheck.MouseButton1Click:Connect(function()
        Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
        BoostIndicator.Visible = Toggles.WalkSpeedBoost
        if Toggles.WalkSpeedBoost then
            BoostCheck.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            BoostCheckStroke.Color = Color3.fromRGB(80, 80, 100)
        else
            BoostCheck.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
            BoostCheckStroke.Color = Color3.fromRGB(45, 45, 55)
        end
        UpdateCharacterSpeed()
    end)
end

-- Assemble All Feature Rows
CreateToggleRow("Auto Spinjitsu (Train)", false, function(v) Toggles.AutoSpinjitsu = v end, 1)
CreateToggleRow("Auto Break Walls", false, function(v) Toggles.AutoBreakWalls = v end, 2)
CreateToggleRow("Auto Stage & Wins", false, function(v) Toggles.AutoStageWins = v end, 3)
CreateToggleRow("Auto Collect Rewards", false, function(v) Toggles.AutoCollectRewards = v end, 4)
CreateToggleRow("Auto Upgrade Spinjitsu", false, function(v) Toggles.AutoUpgrade = v end, 5)
CreateToggleRow("Auto Hatch Eggs", false, function(v) Toggles.AutoHatch = v end, 6)
CreateToggleRow("Auto Equip Best Pet", false, function(v) Toggles.AutoEquipBest = v end, 7)
CreateToggleRow("Auto Rebirth", false, function(v) Toggles.AutoRebirth = v end, 8)
CreateSpeedController(9)
CreateToggleRow("Fly Mode (WASD / Touch)", false, function(v)
    Toggles.Fly = v
    if v then StartFly() else StopFly() end
end, 10)
CreateToggleRow("Infinite Jump", false, function(v) Toggles.InfiniteJump = v end, 11)

-- Footer Branding
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 32)
Footer.Position = UDim2.new(0, 0, 1, -32)
Footer.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Name = "FooterTitle"
FooterTitle.Size = UDim2.new(1, 0, 0, 14)
FooterTitle.Position = UDim2.new(0, 0, 0, 2)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 10
FooterTitle.TextAlignment = Enum.TextXAlignment.Center
FooterTitle.Parent = Footer

local FooterSubtitle = Instance.new("TextLabel")
FooterSubtitle.Name = "FooterSubtitle"
FooterSubtitle.Size = UDim2.new(1, 0, 0, 12)
FooterSubtitle.Position = UDim2.new(0, 0, 0, 16)
FooterSubtitle.BackgroundTransparency = 1
FooterSubtitle.Font = Enum.Font.Gotham
FooterSubtitle.Text = "Made by Junejo"
FooterSubtitle.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSubtitle.TextSize = 9
FooterSubtitle.TextAlignment = Enum.TextXAlignment.Center
FooterSubtitle.Parent = Footer

print("[JUNEJO SCRIPT HUB] +1 Spinjitsu Escape Loaded Successfully!")
