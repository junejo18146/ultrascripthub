--[[
    JUNEJO SCRIPT HUB
    Game: Grow Beanstalk to Steal An Egg
    PlaceId: 87695656520229
    Creator: Made by Junejo (junejo18146)
    Repository: ultrascripthub
    UI Design: Junejo Classic Executive Dark UI (Flat Borderless Rows & Interactive Line Bars)
]]

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuration & State
local Toggles = {
    AutoStealEgg = false,
    AutoStealRareEgg = false,
    AutoStealNearestEgg = false,
    FastClimbBeanstalk = false,
    AutoUnlockTreadmill = false,
    AutoUpgradeBase = false,
    AutoHatchEgg = false,
    AutoRebirth = false,
    AutoClaimRewards = false,
    WalkSpeedBoost = false,
    InfiniteJump = false,
    FlyMode = false,
}

local Sliders = {
    WalkSpeed = 75,
    JumpPower = 120,
    FlySpeed = 70,
}

local SavedBasePosition = nil
local Flying = false
local FlyBodyVel = nil
local FlyBodyGyro = nil

-- Anti-AFK Disconnect Protection
if getconnections then
    for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
        if conn.Disable then conn:Disable() elseif conn.Disconnect then conn:Disconnect() end
    end
else
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end

-- Fast ProximityPrompt 0s Hold Bypass
task.spawn(function()
    local function OptimizePrompt(prompt)
        if prompt and prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
        end
    end
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        OptimizePrompt(prompt)
    end
    Workspace.DescendantAdded:Connect(OptimizePrompt)
end)

-- Character & Base Helpers
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRootPart()
    local char = GetCharacter()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"))
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Auto-Locate Player's Base/Plot
local function FindMyPlot()
    local potentialPlots = Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("Bases") or Workspace:FindFirstChild("Tycoons") or Workspace:FindFirstChild("Islands")
    if potentialPlots then
        for _, plot in ipairs(potentialPlots:GetChildren()) do
            local ownerVal = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player") or plot:FindFirstChild("UserId")
            if ownerVal and (ownerVal.Value == LocalPlayer or ownerVal.Value == LocalPlayer.Name or ownerVal.Value == LocalPlayer.UserId) then
                return plot
            end
            if string.find(string.lower(plot.Name), string.lower(LocalPlayer.Name)) then
                return plot
            end
        end
    end
    return nil
end

local function GetBasePosition()
    if SavedBasePosition then
        return SavedBasePosition
    end
    local myPlot = FindMyPlot()
    if myPlot then
        local baseSpawn = myPlot:FindFirstChild("Spawn") or myPlot:FindFirstChild("BaseSpawn") or myPlot:FindFirstChild("Floor") or myPlot:FindFirstChild("PrimaryPart") or myPlot:FindFirstChildWhichIsA("BasePart")
        if baseSpawn then
            return baseSpawn.Position + Vector3.new(0, 4, 0)
        end
    end
    local root = GetRootPart()
    if root then
        return root.Position
    end
    return Vector3.new(0, 5, 0)
end

-- Fire Prompt / Remote Utility
local function TriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt.HoldDuration = 0
            prompt:InputHoldBegin()
            task.wait(0.05)
            prompt:InputHoldEnd()
        end
    end)
end

local function SafeTouch(targetPart)
    local root = GetRootPart()
    if not root or not targetPart or not targetPart:IsA("BasePart") then return end
    pcall(function()
        if firetouchinterest then
            firetouchinterest(root, targetPart, 0)
            task.wait(0.03)
            firetouchinterest(root, targetPart, 1)
        else
            local oldPos = root.CFrame
            root.CFrame = targetPart.CFrame + Vector3.new(0, 1.5, 0)
            task.wait(0.1)
            root.CFrame = oldPos
        end
    end)
end

-- Egg Finder & Rarity Evaluator
local function GetEggRarityScore(eggInstance)
    local name = string.lower(eggInstance.Name)
    local score = 1
    if string.find(name, "secret") or string.find(name, "celestial") then
        score = 100
    elseif string.find(name, "rainbow") or string.find(name, "diamond") then
        score = 80
    elseif string.find(name, "legendary") or string.find(name, "mythic") then
        score = 60
    elseif string.find(name, "golden") or string.find(name, "gold") then
        score = 40
    elseif string.find(name, "rare") or string.find(name, "epic") then
        score = 25
    end
    -- Higher elevation on beanstalk usually means rarer egg
    local part = eggInstance:IsA("BasePart") and eggInstance or eggInstance:FindFirstChildWhichIsA("BasePart")
    if part then
        score = score + math.floor(part.Position.Y / 20)
    end
    return score
end

local function GetAllEggs()
    local eggs = {}
    local function Scan(parent)
        if not parent then return end
        for _, obj in ipairs(parent:GetChildren()) do
            local lowName = string.lower(obj.Name)
            if string.find(lowName, "egg") or string.find(lowName, "nest") or string.find(lowName, "steal") then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if part or prompt then
                    table.insert(eggs, {
                        Instance = obj,
                        Part = part or (prompt and prompt.Parent:IsA("BasePart") and prompt.Parent),
                        Prompt = prompt,
                        RarityScore = GetEggRarityScore(obj),
                    })
                end
            end
            Scan(obj)
        end
    end

    local eggsFolder = Workspace:FindFirstChild("Eggs") or Workspace:FindFirstChild("EggSpawns") or Workspace:FindFirstChild("Nests") or Workspace:FindFirstChild("Map")
    if eggsFolder then
        Scan(eggsFolder)
    else
        Scan(Workspace)
    end
    return eggs
end

-- Egg Stealing Routine
local function ExecuteSteal(eggData, returnToBase)
    local root = GetRootPart()
    if not root or not eggData then return end
    local targetPart = eggData.Part or (eggData.Prompt and eggData.Prompt.Parent)
    if not targetPart then return end

    local originalCFrame = root.CFrame
    local targetPos = targetPart.Position + Vector3.new(0, 3, 0)
    
    -- Teleport to egg
    root.CFrame = CFrame.new(targetPos)
    task.wait(0.12)
    
    -- Trigger ProximityPrompt or Touch
    if eggData.Prompt then
        TriggerPrompt(eggData.Prompt)
    end
    SafeTouch(targetPart)

    -- Also check for Steal Remotes
    pcall(function()
        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                local remName = string.lower(rem.Name)
                if string.find(remName, "steal") or string.find(remName, "grabegg") or string.find(remName, "takeegg") then
                    if rem:IsA("RemoteEvent") then
                        rem:FireServer(eggData.Instance)
                    else
                        rem:InvokeServer(eggData.Instance)
                    end
                end
            end
        end
    end)

    task.wait(0.15)
    
    -- Return to base if requested
    if returnToBase then
        local basePos = GetBasePosition()
        root.CFrame = CFrame.new(basePos)
        task.wait(0.2)
        
        -- Trigger deposit / place prompt on plot
        local myPlot = FindMyPlot()
        if myPlot then
            for _, prompt in ipairs(myPlot:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    local pName = string.lower(prompt.ObjectText .. prompt.ActionText .. prompt.Name)
                    if string.find(pName, "place") or string.find(pName, "deposit") or string.find(pName, "drop") or string.find(pName, "hatch") then
                        TriggerPrompt(prompt)
                    end
                end
            end
        end
    end
end

-- 1. Auto Steal Egg (Cycle all eggs)
task.spawn(function()
    while true do
        task.wait(0.3)
        if Toggles.AutoStealEgg then
            local eggs = GetAllEggs()
            if #eggs > 0 then
                for _, egg in ipairs(eggs) do
                    if not Toggles.AutoStealEgg then break end
                    ExecuteSteal(egg, true)
                    task.wait(0.5)
                end
            end
        end
    end
end)

-- 2. Auto Steal Rare Egg (Highest rarity score)
task.spawn(function()
    while true do
        task.wait(0.35)
        if Toggles.AutoStealRareEgg then
            local eggs = GetAllEggs()
            if #eggs > 0 then
                table.sort(eggs, function(a, b)
                    return a.RarityScore > b.RarityScore
                end)
                local bestEgg = eggs[1]
                if bestEgg then
                    ExecuteSteal(bestEgg, true)
                    task.wait(0.6)
                end
            end
        end
    end
end)

-- 3. Auto Steal Nearest Egg
task.spawn(function()
    while true do
        task.wait(0.3)
        if Toggles.AutoStealNearestEgg then
            local root = GetRootPart()
            if root then
                local eggs = GetAllEggs()
                local nearestEgg = nil
                local shortestDist = math.huge
                for _, egg in ipairs(eggs) do
                    local part = egg.Part or (egg.Prompt and egg.Prompt.Parent)
                    if part then
                        local dist = (root.Position - part.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            nearestEgg = egg
                        end
                    end
                end
                if nearestEgg then
                    ExecuteSteal(nearestEgg, true)
                    task.wait(0.5)
                end
            end
        end
    end
end)

-- 4. Fast Climb on Beanstalk
task.spawn(function()
    while true do
        task.wait(0.08)
        if Toggles.FastClimbBeanstalk then
            local root = GetRootPart()
            local hum = GetHumanoid()
            if root and hum then
                -- Detect beanstalk or vertical climb vines
                local climbParts = {}
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local name = string.lower(obj.Name)
                        if string.find(name, "beanstalk") or string.find(name, "vine") or string.find(name, "stem") or string.find(name, "ladder") or string.find(name, "cloud") then
                            if (root.Position - obj.Position).Magnitude < 40 then
                                table.insert(climbParts, obj)
                            end
                        end
                    end
                end
                
                -- Upward velocity boost when on or near beanstalk
                if #climbParts > 0 or hum:GetState() == Enum.HumanoidStateType.Climbing then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 90, root.AssemblyLinearVelocity.Z)
                else
                    -- Smooth step upward if moving
                    if hum.MoveDirection.Magnitude > 0 then
                        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 55, root.AssemblyLinearVelocity.Z)
                    end
                end
            end
        end
    end
end)

-- 5. Auto Unlock Treadmill
task.spawn(function()
    while true do
        task.wait(0.4)
        if Toggles.AutoUnlockTreadmill then
            local myPlot = FindMyPlot()
            if myPlot then
                -- Search for unlock buttons / pads on plot
                for _, obj in ipairs(myPlot:GetDescendants()) do
                    local name = string.lower(obj.Name)
                    if string.find(name, "treadmill") or string.find(name, "speed") or string.find(name, "unlock") or string.find(name, "tier") then
                        if obj:IsA("ProximityPrompt") then
                            TriggerPrompt(obj)
                        elseif obj:IsA("BasePart") then
                            SafeTouch(obj)
                        end
                    end
                end
            end
            
            -- Remotes scan
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local remName = string.lower(rem.Name)
                        if string.find(remName, "treadmill") or string.find(remName, "unlockspeed") or string.find(remName, "buytreadmill") then
                            if rem:IsA("RemoteEvent") then
                                rem:FireServer()
                            else
                                rem:InvokeServer()
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 6. Auto Upgrade Base & Grow Beanstalk
task.spawn(function()
    while true do
        task.wait(0.4)
        if Toggles.AutoUpgradeBase then
            local myPlot = FindMyPlot()
            if myPlot then
                for _, obj in ipairs(myPlot:GetDescendants()) do
                    local name = string.lower(obj.Name)
                    if string.find(name, "upgrade") or string.find(name, "buy") or string.find(name, "grow") or string.find(name, "expand") or string.find(name, "capacity") or string.find(name, "button") then
                        if obj:IsA("ProximityPrompt") then
                            TriggerPrompt(obj)
                        elseif obj:IsA("BasePart") then
                            SafeTouch(obj)
                        end
                    end
                end
            end
            
            -- Base upgrade & Beanstalk Grow remotes
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local remName = string.lower(rem.Name)
                        if string.find(remName, "upgrade") or string.find(remName, "growbeanstalk") or string.find(remName, "buybase") or string.find(remName, "purchase") then
                            if rem:IsA("RemoteEvent") then
                                rem:FireServer()
                            else
                                rem:InvokeServer()
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 7. Auto Hatch Egg
task.spawn(function()
    while true do
        task.wait(0.4)
        if Toggles.AutoHatchEgg then
            local myPlot = FindMyPlot()
            if myPlot then
                for _, prompt in ipairs(myPlot:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local text = string.lower(prompt.ObjectText .. prompt.ActionText .. prompt.Name)
                        if string.find(text, "hatch") or string.find(text, "open") or string.find(text, "claim") or string.find(text, "crack") then
                            TriggerPrompt(prompt)
                        end
                    end
                end
            end
            
            -- Hatch Remotes
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local remName = string.lower(rem.Name)
                        if string.find(remName, "hatch") or string.find(remName, "openegg") or string.find(remName, "crackegg") then
                            if rem:IsA("RemoteEvent") then
                                rem:FireServer()
                                rem:FireServer("1")
                                rem:FireServer(true)
                            else
                                rem:InvokeServer()
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 8. Auto Rebirth
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoRebirth then
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local remName = string.lower(rem.Name)
                        if string.find(remName, "rebirth") or string.find(remName, "prestige") or string.find(remName, "ascend") then
                            if rem:IsA("RemoteEvent") then
                                rem:FireServer()
                            else
                                rem:InvokeServer()
                            end
                        end
                    end
                end
            end)
            
            local myPlot = FindMyPlot()
            if myPlot then
                for _, obj in ipairs(myPlot:GetDescendants()) do
                    local name = string.lower(obj.Name)
                    if string.find(name, "rebirth") then
                        if obj:IsA("ProximityPrompt") then
                            TriggerPrompt(obj)
                        elseif obj:IsA("BasePart") then
                            SafeTouch(obj)
                        end
                    end
                end
            end
        end
    end
end)

-- 9. Auto Claim All Rewards
task.spawn(function()
    while true do
        task.wait(1)
        if Toggles.AutoClaimRewards then
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local remName = string.lower(rem.Name)
                        if string.find(remName, "claim") or string.find(remName, "reward") or string.find(remName, "gift") or string.find(remName, "daily") or string.find(remName, "spin") or string.find(remName, "chest") then
                            if rem:IsA("RemoteEvent") then
                                rem:FireServer()
                                rem:FireServer(1)
                                rem:FireServer("Daily")
                                rem:FireServer("Playtime")
                            else
                                rem:InvokeServer()
                            end
                        end
                    end
                end
            end)
            
            -- Search for claim chests in workspace
            for _, obj in ipairs(Workspace:GetDescendants()) do
                local name = string.lower(obj.Name)
                if string.find(name, "reward") or string.find(name, "chest") or string.find(name, "gift") then
                    if obj:IsA("ProximityPrompt") then
                        TriggerPrompt(obj)
                    elseif obj:IsA("BasePart") then
                        SafeTouch(obj)
                    end
                end
            end
        end
    end
end)

-- 10. WalkSpeed Boost Engine
local function UpdateWalkSpeed()
    local hum = GetHumanoid()
    if hum then
        if Toggles.WalkSpeedBoost then
            hum.WalkSpeed = Sliders.WalkSpeed
        else
            hum.WalkSpeed = 16
        end
    end
end

RunService.RenderStepped:Connect(function()
    if Toggles.WalkSpeedBoost then
        local hum = GetHumanoid()
        if hum and hum.WalkSpeed ~= Sliders.WalkSpeed then
            hum.WalkSpeed = Sliders.WalkSpeed
        end
    end
end)

-- 11. Infinite Jump Engine with Jump Height
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        local hum = GetHumanoid()
        local root = GetRootPart()
        if hum and root then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, Sliders.JumpPower, root.AssemblyLinearVelocity.Z)
        end
    end
end)

-- 12. 3D Fly Mode Engine
local function StartFlying()
    local char = GetCharacter()
    local root = GetRootPart()
    if not root then return end
    
    Flying = true
    FlyBodyVel = Instance.new("BodyVelocity")
    FlyBodyVel.Velocity = Vector3.new(0, 0, 0)
    FlyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVel.Parent = root
    
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.CFrame = root.CFrame
    FlyBodyGyro.Parent = root

    task.spawn(function()
        while Flying and Toggles.FlyMode do
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end

            -- Mobile Touch Joystick Support
            local hum = GetHumanoid()
            if hum and hum.MoveDirection.Magnitude > 0 then
                moveDir = moveDir + (Camera.CFrame:VectorToWorldSpace(hum.MoveDirection))
            end

            if moveDir.Magnitude > 0 then
                FlyBodyVel.Velocity = moveDir.Unit * Sliders.FlySpeed
            else
                FlyBodyVel.Velocity = Vector3.new(0, 0, 0)
            end

            FlyBodyGyro.CFrame = Camera.CFrame
            RunService.RenderStepped:Wait()
        end
        if FlyBodyVel then FlyBodyVel:Destroy() FlyBodyVel = nil end
        if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
        Flying = false
    end)
end

local function StopFlying()
    Flying = false
    if FlyBodyVel then FlyBodyVel:Destroy() FlyBodyVel = nil end
    if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
end

-- ==========================================
-- JUNEJO CLASSIC EXECUTIVE UI DESIGN
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_GrowBeanstalk"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

-- Parent safely
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 285, 0, 310)
MainFrame.Position = UDim2.new(0.5, -142, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Draggable MainFrame
local isDragging = false
local dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and isDragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

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

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "GROW BEANSTALK TO STEAL AN EGG"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 11
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

-- Scrolling Content Frame
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"
ContentScroll.Size = UDim2.new(1, -24, 1, -74)
ContentScroll.Position = UDim2.new(0, 12, 0, 36)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 2
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentScroll

-- Helper: Add Borderless Toggle Row
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentScroll
    
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

-- Helper: Add Interactive Line Bar Slider Row (Toggle + Smooth Line Bar)
local function AddSliderRow(title, configKey, sliderKey, minVal, maxVal, defaultVal, onChangeCallback, onToggleCallback)
    Sliders[sliderKey] = defaultVal
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 38)
    Container.BackgroundTransparency = 1
    Container.Parent = ContentScroll
    
    -- Top Row: Label + Value + Toggle Checkbox
    local TopRow = Instance.new("Frame")
    TopRow.Size = UDim2.new(1, 0, 0, 20)
    TopRow.BackgroundTransparency = 1
    TopRow.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TopRow
    
    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0.2, 0, 1, 0)
    ValLabel.Position = UDim2.new(0.6, 0, 0, 0)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = tostring(defaultVal)
    ValLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
    ValLabel.TextSize = 11
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.Parent = TopRow
    
    local CheckBox = Instance.new("Frame")
    CheckBox.Size = UDim2.new(0, 18, 0, 18)
    CheckBox.Position = UDim2.new(1, -18, 0.5, -9)
    CheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    CheckBox.BorderSizePixel = 0
    CheckBox.Parent = TopRow
    
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
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = ""
    ToggleBtn.ZIndex = 5
    ToggleBtn.Parent = TopRow
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Toggles[configKey] = not Toggles[configKey]
        CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
        if onToggleCallback then onToggleCallback(Toggles[configKey]) end
    end)
    
    -- Bottom Line Bar Slider Track
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, 0, 0, 6)
    SliderTrack.Position = UDim2.new(0, 0, 0, 24)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = Container
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = SliderTrack
    
    local TrackStroke = Instance.new("UIStroke")
    TrackStroke.Color = Color3.fromRGB(40, 40, 50)
    TrackStroke.Thickness = 1
    TrackStroke.Parent = SliderTrack
    
    local initialPercent = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill
    
    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(1, 0, 1, 8)
    SliderBtn.Position = UDim2.new(0, 0, 0, -4)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text = ""
    SliderBtn.ZIndex = 6
    SliderBtn.Parent = SliderTrack
    
    local isSliding = false
    local function UpdateSlider(input)
        local posX = input.Position.X - SliderTrack.AbsolutePosition.X
        local percent = math.clamp(posX / SliderTrack.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * percent)
        Sliders[sliderKey] = val
        ValLabel.Text = tostring(val)
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        if onChangeCallback then onChangeCallback(val) end
    end
    
    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            UpdateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
end

-- ==========================================
-- POPULATE FEATURES
-- ==========================================

-- 1. Auto Steal Egg
AddToggleRow("Auto Steal Egg", "AutoStealEgg")

-- 2. Auto Steal Rare Egg
AddToggleRow("Auto Steal Rare Egg", "AutoStealRareEgg")

-- 3. Auto Steal Nearest Egg
AddToggleRow("Auto Steal Nearest Egg", "AutoStealNearestEgg")

-- 4. Fast Climb on Beanstalk
AddToggleRow("Fast Climb Beanstalk", "FastClimbBeanstalk")

-- 5. Auto Unlock Treadmill
AddToggleRow("Auto Unlock Treadmill", "AutoUnlockTreadmill")

-- 6. Auto Upgrade Base
AddToggleRow("Auto Upgrade Base", "AutoUpgradeBase")

-- 7. Auto Hatch Egg
AddToggleRow("Auto Hatch Egg", "AutoHatchEgg")

-- 8. Auto Rebirth
AddToggleRow("Auto Rebirth", "AutoRebirth")

-- 9. Auto Claim All Rewards
AddToggleRow("Auto Claim All Rewards", "AutoClaimRewards")

-- 10. WalkSpeed with Line Bar Slider
AddSliderRow("WalkSpeed", "WalkSpeedBoost", "WalkSpeed", 16, 300, 75, function(val)
    UpdateWalkSpeed()
end, function(enabled)
    UpdateWalkSpeed()
end)

-- 11. Infinite Jump with Line Bar Slider
AddSliderRow("Infinite Jump", "InfiniteJump", "JumpPower", 50, 300, 120, nil, nil)

-- 12. Fly Mode with Line Bar Slider
AddSliderRow("Fly Mode", "FlyMode", "FlySpeed", 20, 250, 70, nil, function(enabled)
    if enabled then
        StartFlying()
    else
        StopFlying()
    end
end)

-- Footer (Pinned at bottom)
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 34)
Footer.Position = UDim2.new(0, 0, 1, -36)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 14)
FooterTitle.Position = UDim2.new(0, 0, 0, 2)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 11
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 12)
FooterSub.Position = UDim2.new(0, 0, 0, 16)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 9
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.Parent = Footer

print("Junejo Ultra Script Hub loaded successfully for Grow Beanstalk to Steal An Egg!")
