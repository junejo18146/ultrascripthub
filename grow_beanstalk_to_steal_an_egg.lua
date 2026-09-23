-- ==============================================================================
-- JUNEJO ULTRA SCRIPT HUB - GROW BEANSTALK TO STEAL AN EGG
-- Game: Grow Beanstalk to Steal An Egg (Place ID: 87695656520229)
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- UI Framework: UI 1 (Official Ultra Script Hub Classic Matte Dark)
-- Universal Mobile (Delta / Codex / Fluxus) & PC Compatible
-- ==============================================================================

local GameTitle = "GROW BEANSTALK TO STEAL AN EGG"

-- Core Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera

-- Cleanup previous interface if running
for _, name in ipairs({"JunejoHubUI_GrowBeanstalk", "JunejoHubUI", "UltraHub_Beanstalk"}) do
    pcall(function()
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui and pGui:FindFirstChild(name) then pGui[name]:Destroy() end
    end)
end

-- ==============================================================================
-- 1. STATE CONFIGURATION (CASH & NOCLIP COMPLETELY EXCLUDED)
-- ==============================================================================
local HubState = {
    AutoStealEgg = false,
    AutoStealRareEgg = false,
    AutoStealNearestEgg = false,
    FastClimbBeanstalk = false,
    InfiniteBeanstalk = false,
    AutoUnlockTreadmill = false,
    AutoUpgradeBase = false,
    AutoHatchEgg = false,
    AutoRebirth = false,
    AutoClaimRewards = false,
    WalkSpeedBoost = false,
    InfiniteJump = false,
    FlyMode = false,
}

local Settings = {
    WalkSpeed = 75,
    JumpPower = 120,
    FlySpeed = 70,
}

local CachedPlot = nil
local SavedBaseCFrame = nil
local FlyingActive = false
local FlyVelocity = nil
local FlyGyro = nil

-- ==============================================================================
-- 2. ESSENTIAL ENGINE HELPERS
-- ==============================================================================

-- 24/7 Anti-AFK Idle Bypass
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)
LocalPlayer.Idled:Connect(function()
    if VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end
end)

local function GetPlayerCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRootPart()
    local char = GetPlayerCharacter()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function GetHumanoid()
    local char = GetPlayerCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Instant 0-second Proximity Prompt Resolver
local function FastTriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 99999
        local origHold = prompt.HoldDuration or 0
        prompt.HoldDuration = 0

        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait(0.04)
            prompt:InputHoldEnd()
        end
        prompt.HoldDuration = origHold
    end)
end

-- Touch Transmitter / Pad Interactor
local function DirectTouch(part)
    local root = GetRootPart()
    if not root or not part or not part:IsA("BasePart") then return end
    pcall(function()
        if firetouchinterest then
            firetouchinterest(root, part, 0)
            task.wait()
            firetouchinterest(root, part, 1)
        end
    end)
end

-- Proximity prompt global optimizer
task.spawn(function()
    local function Optimize(p)
        if p:IsA("ProximityPrompt") then
            p.HoldDuration = 0
            p.RequiresLineOfSight = false
            p.MaxActivationDistance = 99999
        end
    end
    for _, desc in ipairs(Workspace:GetDescendants()) do Optimize(desc) end
    Workspace.DescendantAdded:Connect(Optimize)
end)

-- Dynamic Plot Locator
local function LocatePlot()
    if CachedPlot and CachedPlot.Parent then return CachedPlot end

    local candidates = {
        Workspace:FindFirstChild("Plots"),
        Workspace:FindFirstChild("Bases"),
        Workspace:FindFirstChild("Tycoons"),
        Workspace:FindFirstChild("Islands"),
        Workspace:FindFirstChild("Map"),
        Workspace
    }

    local pName = LocalPlayer.Name:lower()
    local pUserId = tostring(LocalPlayer.UserId)

    for _, container in ipairs(candidates) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Model") or item:IsA("Folder") then
                    local owner = item:FindFirstChild("Owner") or item:FindFirstChild("Player") or item:FindFirstChild("UserId")
                    if owner then
                        local ov = tostring(typeof(owner) == "Instance" and owner.Value or owner):lower()
                        if ov:find(pName, 1, true) or ov:find(pUserId, 1, true) then
                            CachedPlot = item
                            return item
                        end
                    end
                    local n = item.Name:lower()
                    if n:find(pName, 1, true) or n:find(pUserId, 1, true) then
                        CachedPlot = item
                        return item
                    end
                end
            end
        end
    end
    return nil
end

local function GetBaseCFrame()
    if SavedBaseCFrame then return SavedBaseCFrame end
    local plot = LocatePlot()
    if plot then
        local sp = plot:FindFirstChild("Spawn") or plot:FindFirstChild("BaseSpawn") or plot:FindFirstChildWhichIsA("BasePart")
        if sp then
            SavedBaseCFrame = sp.CFrame + Vector3.new(0, 3, 0)
            return SavedBaseCFrame
        end
    end
    local root = GetRootPart()
    if root then
        SavedBaseCFrame = root.CFrame
        return SavedBaseCFrame
    end
    return CFrame.new(0, 5, 0)
end

-- Smart Remote Dispatcher
local function DispatchRemotes(tags, args)
    pcall(function()
        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                local rName = rem.Name:lower()
                for _, tag in ipairs(tags) do
                    if rName:find(tag, 1, true) then
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer()
                            if args then
                                for _, a in ipairs(args) do
                                    rem:FireServer(a)
                                    rem:FireServer(unpack(type(a) == "table" and a or {a}))
                                end
                            end
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer()
                            if args then
                                for _, a in ipairs(args) do
                                    rem:InvokeServer(a)
                                end
                            end
                        end
                        break
                    end
                end
            end
        end
    end)
end

-- ==============================================================================
-- 3. GAMEPLAY AUTOMATION SYSTEMS
-- ==============================================================================

-- Egg Scoring Evaluator
local function CalculateEggValue(egg)
    local n = egg.Name:lower()
    local val = 1
    if n:find("secret") or n:find("celestial") then val = 100
    elseif n:find("rainbow") or n:find("diamond") then val = 80
    elseif n:find("legendary") or n:find("mythic") then val = 60
    elseif n:find("golden") or n:find("gold") then val = 40
    elseif n:find("rare") or n:find("epic") then val = 25
    end
    local part = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
    if part then
        val = val + math.floor(part.Position.Y / 15)
    end
    return val
end

-- Discover All Active Eggs
local function ScanWorldEggs()
    local list = {}
    local function Collect(folder)
        if not folder then return end
        for _, obj in ipairs(folder:GetChildren()) do
            local ln = obj.Name:lower()
            if ln:find("egg") or ln:find("nest") or ln:find("steal") then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                local bp = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if bp or prompt then
                    table.insert(list, {
                        Object = obj,
                        Part = bp or (prompt and prompt.Parent:IsA("BasePart") and prompt.Parent),
                        Prompt = prompt,
                        Score = CalculateEggValue(obj)
                    })
                end
            end
            Collect(obj)
        end
    end

    local searchRoots = {
        Workspace:FindFirstChild("Eggs"),
        Workspace:FindFirstChild("EggSpawns"),
        Workspace:FindFirstChild("Nests"),
        Workspace:FindFirstChild("Map"),
        Workspace
    }
    for _, root in ipairs(searchRoots) do
        if root then
            Collect(root)
            if #list > 0 then break end
        end
    end
    return list
end

-- Steal Action Runner
local function ExecuteStealCycle(eggInfo)
    local root = GetRootPart()
    if not root or not eggInfo then return end
    local target = eggInfo.Part or (eggInfo.Prompt and eggInfo.Prompt.Parent)
    if not target then return end

    root.AssemblyLinearVelocity = Vector3.zero
    root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
    task.wait(0.12)

    if eggInfo.Prompt then
        FastTriggerPrompt(eggInfo.Prompt)
    end
    DirectTouch(target)

    DispatchRemotes({"steal", "grabegg", "takeegg"}, {eggInfo.Object, eggInfo.Object.Name})
    task.wait(0.14)

    -- Deliver egg back to base plot
    local baseCF = GetBaseCFrame()
    root.AssemblyLinearVelocity = Vector3.zero
    root.CFrame = baseCF
    task.wait(0.18)

    local plot = LocatePlot()
    if plot then
        for _, p in ipairs(plot:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                local pText = (p.ObjectText .. " " .. p.ActionText .. " " .. p.Name):lower()
                if pText:find("place") or pText:find("deposit") or pText:find("drop") or pText:find("hatch") then
                    FastTriggerPrompt(p)
                end
            end
        end
    end
end

-- 1. Auto Steal Egg Routine
task.spawn(function()
    while true do
        task.wait(0.3)
        if HubState.AutoStealEgg then
            local eggs = ScanWorldEggs()
            for _, egg in ipairs(eggs) do
                if not HubState.AutoStealEgg then break end
                ExecuteStealCycle(egg)
                task.wait(0.4)
            end
        end
    end
end)

-- 2. Auto Steal Rare Egg Routine
task.spawn(function()
    while true do
        task.wait(0.35)
        if HubState.AutoStealRareEgg then
            local eggs = ScanWorldEggs()
            if #eggs > 0 then
                table.sort(eggs, function(a, b) return a.Score > b.Score end)
                local rarest = eggs[1]
                if rarest then
                    ExecuteStealCycle(rarest)
                    task.wait(0.5)
                end
            end
        end
    end
end)

-- 3. Auto Steal Nearest Egg Routine
task.spawn(function()
    while true do
        task.wait(0.3)
        if HubState.AutoStealNearestEgg then
            local root = GetRootPart()
            if root then
                local eggs = ScanWorldEggs()
                local closest = nil
                local minDistance = math.huge
                for _, egg in ipairs(eggs) do
                    local p = egg.Part or (egg.Prompt and egg.Prompt.Parent)
                    if p then
                        local d = (root.Position - p.Position).Magnitude
                        if d < minDistance then
                            minDistance = d
                            closest = egg
                        end
                    end
                end
                if closest then
                    ExecuteStealCycle(closest)
                    task.wait(0.45)
                end
            end
        end
    end
end)

-- 4. Fast Climb on Beanstalk (Smooth Summit Lift)
task.spawn(function()
    while true do
        task.wait(0.04)
        if HubState.FastClimbBeanstalk then
            local root = GetRootPart()
            local hum = GetHumanoid()
            if root and hum then
                root.AssemblyLinearVelocity = Vector3.new(0, 160, 0)
                root.CFrame = root.CFrame + Vector3.new(0, 4.5, 0)
                hum:ChangeState(Enum.HumanoidStateType.Freefall)
            end
        end
    end
end)

-- 5. Infinite Long Beanstalk (Skyward Growth Engine)
task.spawn(function()
    while true do
        task.wait(0.2)
        if HubState.InfiniteBeanstalk then
            DispatchRemotes(
                {"grow", "beanstalk", "water", "fertilize", "feed", "upgradebeanstalk", "growth", "plantgrow", "buygrowth"},
                {1, 10, 100, 1000, true, "Beanstalk", "Grow", "Max"}
            )
            local plot = LocatePlot()
            if plot then
                for _, obj in ipairs(plot:GetDescendants()) do
                    local n = obj.Name:lower()
                    local pn = obj.Parent and obj.Parent.Name:lower() or ""
                    if n:find("grow") or n:find("beanstalk") or n:find("water") or n:find("feed") or pn:find("grow") then
                        if obj:IsA("ProximityPrompt") then FastTriggerPrompt(obj)
                        elseif obj:IsA("ClickDetector") and fireclickdetector then fireclickdetector(obj)
                        elseif obj:IsA("BasePart") then DirectTouch(obj) end
                    end
                end
                for _, obj in ipairs(plot:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local n = obj.Name:lower()
                        if n:find("beanstalk") or n:find("stem") or n:find("stalk") or n:find("trunk") or n:find("vine") then
                            pcall(function()
                                obj.Size = Vector3.new(math.max(obj.Size.X, 14), math.max(obj.Size.Y, 2500), math.max(obj.Size.Z, 14))
                                obj.CanCollide = true
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- 6. Auto Unlock & Train Treadmill Engine
task.spawn(function()
    while true do
        task.wait(0.25)
        if HubState.AutoUnlockTreadmill then
            DispatchRemotes(
                {"treadmill", "unlocktreadmill", "buytreadmill", "upgradespeed", "speedupgrade", "unlockspeed", "buyspeed", "treadmilltier", "train"},
                {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, true, "Max", "Treadmill"}
            )
            local plot = LocatePlot()
            local zones = {plot, Workspace:FindFirstChild("Tycoons"), Workspace:FindFirstChild("Plots")}
            for _, z in ipairs(zones) do
                if z then
                    for _, obj in ipairs(z:GetDescendants()) do
                        local n = obj.Name:lower()
                        if n:find("treadmill") or n:find("speed") or n:find("runner") or n:find("track") then
                            if obj:IsA("ProximityPrompt") then FastTriggerPrompt(obj)
                            elseif obj:IsA("ClickDetector") and fireclickdetector then fireclickdetector(obj)
                            elseif obj:IsA("BasePart") then DirectTouch(obj) end
                        end
                    end
                end
            end
        end
    end
end)

-- 7. Auto Upgrade Base (Tycoon Plot Upgrades)
task.spawn(function()
    while true do
        task.wait(0.3)
        if HubState.AutoUpgradeBase then
            local plot = LocatePlot()
            if plot then
                for _, obj in ipairs(plot:GetDescendants()) do
                    local n = obj.Name:lower()
                    if n:find("upgrade") or n:find("buy") or n:find("button") or n:find("pad") then
                        if obj:IsA("ProximityPrompt") then FastTriggerPrompt(obj)
                        elseif obj:IsA("ClickDetector") and fireclickdetector then fireclickdetector(obj)
                        elseif obj:IsA("BasePart") then DirectTouch(obj) end
                    end
                end
            end
            DispatchRemotes({"upgrade", "buybase", "purchase", "tycoonbuy", "buybutton", "plotupgrade"}, {true, 1, "Max"})
        end
    end
end)

-- 8. Auto Hatch Egg
task.spawn(function()
    while true do
        task.wait(0.3)
        if HubState.AutoHatchEgg then
            local plot = LocatePlot()
            if plot then
                for _, p in ipairs(plot:GetDescendants()) do
                    if p:IsA("ProximityPrompt") then
                        local t = (p.ObjectText .. " " .. p.ActionText .. " " .. p.Name):lower()
                        if t:find("hatch") or t:find("open") or t:find("crack") or t:find("egg") or t:find("incubator") then
                            FastTriggerPrompt(p)
                        end
                    end
                end
            end
            DispatchRemotes(
                {"hatch", "openegg", "crackegg", "claimpet", "placeegg", "egghatch", "open"},
                {1, "1", true, "Common", "Basic", "Golden"}
            )
        end
    end
end)

-- 9. Auto Rebirth
task.spawn(function()
    while true do
        task.wait(0.4)
        if HubState.AutoRebirth then
            DispatchRemotes(
                {"rebirth", "prestige", "ascend", "dorebirth", "requestrebirth", "rebirthsystem"},
                {1, true, "1"}
            )
            local plot = LocatePlot()
            if plot then
                for _, obj in ipairs(plot:GetDescendants()) do
                    local n = obj.Name:lower()
                    if n:find("rebirth") or n:find("prestige") then
                        if obj:IsA("ProximityPrompt") then FastTriggerPrompt(obj)
                        elseif obj:IsA("ClickDetector") and fireclickdetector then fireclickdetector(obj)
                        elseif obj:IsA("BasePart") then DirectTouch(obj) end
                    end
                end
            end
        end
    end
end)

-- 10. Auto Claim All Rewards
task.spawn(function()
    while true do
        task.wait(1.2)
        if HubState.AutoClaimRewards then
            DispatchRemotes(
                {"claim", "reward", "gift", "daily", "spin", "chest", "playtime"},
                {1, "Daily", "Playtime", "Gift1", "Gift2", "Free", true}
            )
            for _, obj in ipairs(Workspace:GetDescendants()) do
                local n = obj.Name:lower()
                if n:find("reward") or n:find("chest") or n:find("gift") then
                    if obj:IsA("ProximityPrompt") then FastTriggerPrompt(obj)
                    elseif obj:IsA("ClickDetector") and fireclickdetector then fireclickdetector(obj)
                    elseif obj:IsA("BasePart") then DirectTouch(obj) end
                end
            end
        end
    end
end)

-- ==============================================================================
-- 4. MOVEMENT ENGINES
-- ==============================================================================

local function ApplyWalkSpeed()
    local hum = GetHumanoid()
    if hum then
        if HubState.WalkSpeedBoost then
            hum.WalkSpeed = Settings.WalkSpeed
        else
            hum.WalkSpeed = 16
        end
    end
end

RunService.RenderStepped:Connect(function()
    if HubState.WalkSpeedBoost then
        local hum = GetHumanoid()
        if hum and hum.WalkSpeed ~= Settings.WalkSpeed then
            hum.WalkSpeed = Settings.WalkSpeed
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if HubState.InfiniteJump then
        local hum = GetHumanoid()
        local root = GetRootPart()
        if hum and root then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, Settings.JumpPower, root.AssemblyLinearVelocity.Z)
        end
    end
end)

local function EnableFlight()
    local root = GetRootPart()
    if not root then return end

    FlyingActive = true
    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.Velocity = Vector3.zero
    FlyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyVelocity.Parent = root

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyGyro.P = 9e4
    FlyGyro.CFrame = root.CFrame
    FlyGyro.Parent = root

    task.spawn(function()
        while FlyingActive and HubState.FlyMode do
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end

            local hum = GetHumanoid()
            if hum and hum.MoveDirection.Magnitude > 0 then
                move = move + (Camera.CFrame:VectorToWorldSpace(hum.MoveDirection))
            end

            if move.Magnitude > 0 then
                FlyVelocity.Velocity = move.Unit * Settings.FlySpeed
            else
                FlyVelocity.Velocity = Vector3.zero
            end

            FlyGyro.CFrame = Camera.CFrame
            RunService.RenderStepped:Wait()
        end
        if FlyVelocity then FlyVelocity:Destroy() FlyVelocity = nil end
        if FlyGyro then FlyGyro:Destroy() FlyGyro = nil end
        FlyingActive = false
    end)
end

local function DisableFlight()
    FlyingActive = false
    if FlyVelocity then FlyVelocity:Destroy() FlyVelocity = nil end
    if FlyGyro then FlyGyro:Destroy() FlyGyro = nil end
end

-- ==============================================================================
-- 5. OFFICIAL JUNEJO UI 1 - CLASSIC MATTE DARK INTERFACE
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_GrowBeanstalk"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local guiParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = guiParent

-- Main Container (Classic Matte Dark 280x305px)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 305)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -152)
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

-- Draggable Logic (Mobile Touch & PC Mouse)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
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

MainFrame.InputChanged:Connect(function(input)
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

-- Header Frame
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = GameTitle
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

CloseButton.MouseButton1Click:Connect(function()
    DisableFlight()
    ScreenGui:Destroy()
end)

-- Header Divider Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Scrollable Features Container
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -74)
ContentFrame.Position = UDim2.new(0, 10, 0, 36)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Row Builder: Standard Checkbox Toggle Row
local function AddToggleRow(label, stateKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame

    local RowBtn = Instance.new("TextButton")
    RowBtn.Size = UDim2.new(1, 0, 1, 0)
    RowBtn.BackgroundTransparency = 1
    RowBtn.Text = ""
    RowBtn.ZIndex = 5
    RowBtn.Parent = Row

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -28, 1, 0)
    Text.Position = UDim2.new(0, 4, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Text = label
    Text.TextColor3 = Color3.fromRGB(240, 240, 240)
    Text.TextSize = 12
    Text.Font = Enum.Font.GothamBold
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Row

    local CheckBox = Instance.new("Frame")
    CheckBox.Size = UDim2.new(0, 18, 0, 18)
    CheckBox.Position = UDim2.new(1, -20, 0.5, -9)
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
    CheckMark.BackgroundTransparency = HubState[stateKey] and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox

    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark

    RowBtn.MouseButton1Click:Connect(function()
        HubState[stateKey] = not HubState[stateKey]
        CheckMark.BackgroundTransparency = HubState[stateKey] and 0 or 1
        if callback then callback(HubState[stateKey]) end
    end)
end

-- Row Builder: Dual Control Stepper Pill Row
local function AddStepperRow(label, toggleKey, valKey, minVal, maxVal, step, onToggleCallback, onChangeCallback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0.55, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = ""
    ToggleBtn.ZIndex = 5
    ToggleBtn.Parent = Row

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -28, 1, 0)
    Text.Position = UDim2.new(0, 4, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Text = label
    Text.TextColor3 = Color3.fromRGB(240, 240, 240)
    Text.TextSize = 12
    Text.Font = Enum.Font.GothamBold
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = ToggleBtn

    local CheckBox = Instance.new("Frame")
    CheckBox.Size = UDim2.new(0, 18, 0, 18)
    CheckBox.Position = UDim2.new(1, -20, 0.5, -9)
    CheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    CheckBox.BorderSizePixel = 0
    CheckBox.Parent = ToggleBtn

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
    CheckMark.BackgroundTransparency = HubState[toggleKey] and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox

    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark

    local ControlFrame = Instance.new("Frame")
    ControlFrame.Size = UDim2.new(0, 95, 0, 22)
    ControlFrame.Position = UDim2.new(1, -97, 0.5, -11)
    ControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ControlFrame.BorderSizePixel = 0
    ControlFrame.Parent = Row

    local CtrlCorner = Instance.new("UICorner")
    CtrlCorner.CornerRadius = UDim.new(0, 4)
    CtrlCorner.Parent = ControlFrame

    local CtrlStroke = Instance.new("UIStroke")
    CtrlStroke.Color = Color3.fromRGB(45, 45, 55)
    CtrlStroke.Thickness = 1
    CtrlStroke.Parent = ControlFrame

    local MinusBtn = Instance.new("TextButton")
    MinusBtn.Size = UDim2.new(0, 22, 1, 0)
    MinusBtn.BackgroundTransparency = 1
    MinusBtn.Text = "-"
    MinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    MinusBtn.TextSize = 14
    MinusBtn.Font = Enum.Font.GothamBold
    MinusBtn.Parent = ControlFrame

    local Display = Instance.new("TextLabel")
    Display.Size = UDim2.new(1, -44, 1, 0)
    Display.Position = UDim2.new(0, 22, 0, 0)
    Display.BackgroundTransparency = 1
    Display.Text = tostring(Settings[valKey])
    Display.TextColor3 = Color3.fromRGB(255, 255, 255)
    Display.TextSize = 11
    Display.Font = Enum.Font.GothamBold
    Display.Parent = ControlFrame

    local PlusBtn = Instance.new("TextButton")
    PlusBtn.Size = UDim2.new(0, 22, 1, 0)
    PlusBtn.Position = UDim2.new(1, -22, 0, 0)
    PlusBtn.BackgroundTransparency = 1
    PlusBtn.Text = "+"
    PlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    PlusBtn.TextSize = 14
    PlusBtn.Font = Enum.Font.GothamBold
    PlusBtn.Parent = ControlFrame

    ToggleBtn.MouseButton1Click:Connect(function()
        HubState[toggleKey] = not HubState[toggleKey]
        CheckMark.BackgroundTransparency = HubState[toggleKey] and 0 or 1
        if onToggleCallback then onToggleCallback(HubState[toggleKey]) end
    end)

    MinusBtn.MouseButton1Click:Connect(function()
        Settings[valKey] = math.max(minVal, Settings[valKey] - step)
        Display.Text = tostring(Settings[valKey])
        if onChangeCallback then onChangeCallback(Settings[valKey]) end
    end)

    PlusBtn.MouseButton1Click:Connect(function()
        Settings[valKey] = math.min(maxVal, Settings[valKey] + step)
        Display.Text = tostring(Settings[valKey])
        if onChangeCallback then onChangeCallback(Settings[valKey]) end
    end)
end

-- ==============================================================================
-- POPULATE FEATURES
-- ==============================================================================

-- 1. Automation Toggles
AddToggleRow("Auto Steal Egg", "AutoStealEgg")
AddToggleRow("Auto Steal Rare Egg", "AutoStealRareEgg")
AddToggleRow("Auto Steal Nearest Egg", "AutoStealNearestEgg")
AddToggleRow("Fast Climb Beanstalk", "FastClimbBeanstalk")
AddToggleRow("Infinite Long Beanstalk", "InfiniteBeanstalk")
AddToggleRow("Auto Unlock Treadmill", "AutoUnlockTreadmill")
AddToggleRow("Auto Upgrade Base", "AutoUpgradeBase")
AddToggleRow("Auto Hatch Egg", "AutoHatchEgg")
AddToggleRow("Auto Rebirth", "AutoRebirth")
AddToggleRow("Auto Claim All Rewards", "AutoClaimRewards")

-- 2. Movement Stepper Pills
AddStepperRow("WalkSpeed", "WalkSpeedBoost", "WalkSpeed", 16, 300, 15, function()
    ApplyWalkSpeed()
end, function()
    ApplyWalkSpeed()
end)

AddStepperRow("Infinite Jump", "InfiniteJump", "JumpPower", 50, 300, 20, nil, nil)

AddStepperRow("Fly Mode", "FlyMode", "FlySpeed", 20, 250, 10, function(active)
    if active then
        EnableFlight()
    else
        DisableFlight()
    end
end, nil)

-- ==============================================================================
-- 6. MANDATORY JUNEJO FOOTER
-- ==============================================================================
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

print("[ULTRA SCRIPT HUB] Grow Beanstalk to Steal An Egg loaded successfully!")
