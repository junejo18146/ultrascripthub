--[[
    ========================================================================
    JUNEJO ULTRA SCRIPT HUB - STEAL AN EGG (V3.0 ULTIMATE)
    ========================================================================
    Author: Made by Junejo (junejo18146)
    Target Game: Steal an Egg (Roblox)
    Repository: junejo18146/ultrascripthub
    File: steal_an_egg.lua
    UI Standard: Junejo Classic Dark UI (#0F0F11) - Flat & Borderless Standard
    
    Verified Features Included (17 Features):
        1. Auto Steal Rare Egg (Furthest Rare Farm)
        2. Auto Steal Nearest Egg (Fast Chain Loop)
        3. Steal Rare Egg (1-Click Action)
        4. Set Base Position (1-Click Action)
        5. Teleport to Base (1-Click Action)
        6. Auto Hatch Base Eggs
        7. Auto Treadmill Trainer (Speed Boost)
        8. Auto Claim XP & Rewards
        9. Rare Egg ESP (Neon Magenta + Distance Tag)
        10. All Egg ESP (Golden Glow + Tag)
        11. Player ESP & Base Defense Radar
        12. WalkSpeed Boost (+ / - Pill Controller: 16 to 300)
        13. Fly Mode (Smooth 3D Flight)
        14. Noclip Mode (Phase Through Walls & Doors)
        15. Infinite Jump (Multi-Jump Bypass)
        16. Instant Proximity Prompts (0s Hold Sweeper)
        17. Anti-AFK Engine (20-min Disconnect Protection)
    ========================================================================
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

-- State & Settings
local Toggles = {
    AutoStealRare = false,
    AutoStealNearest = false,
    AutoHatch = false,
    AutoTreadmill = false,
    AutoClaimXP = false,
    RareEggESP = false,
    AllEggESP = false,
    PlayerESP = false,
    WalkSpeedBoost = false,
    FlyMode = false,
    Noclip = false,
    InfiniteJump = false,
    InstantPrompts = true,
    AntiAFK = true
}

local CustomSpeedValue = 60
local SavedBaseCFrame = nil
local ESPObjects = {}

-- Safe Base CFrame Initialization
pcall(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        SavedBaseCFrame = hrp.CFrame
    end
end)

-- Safe UI Container Resolver
local function GetSafeUIContainer()
    local container = nil
    pcall(function()
        if gethui then
            container = gethui()
        end
    end)
    if not container then
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
            if playerGui then container = playerGui end
        end)
    end
    if not container then
        pcall(function()
            if syn and syn.protect_gui then container = CoreGui end
        end)
    end
    if not container then
        pcall(function() container = CoreGui end)
    end
    return container or LocalPlayer:WaitForChild("PlayerGui")
end

local UIContainer = GetSafeUIContainer()

-- Cleanup Previous UI Instances
pcall(function()
    local names = {"JunejoStealAnEggUI", "StealAnEggUI", "JunejoHubUI"}
    for _, name in ipairs(names) do
        pcall(function()
            if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        end)
        pcall(function()
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
                LocalPlayer.PlayerGui[name]:Destroy()
            end
        end)
        pcall(function()
            if gethui and gethui():FindFirstChild(name) then gethui()[name]:Destroy() end
        end)
    end
end)

------------------------------------------------------------------------
-- SMOOTH ZERO-VIBRATION CORE ENGINE FUNCTIONS
------------------------------------------------------------------------

-- Safe Teleport without physics jitter or camera shake
local function SafeTeleport(targetCFrame)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if hrp:IsA("BasePart") then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end

        hrp.CFrame = targetCFrame + Vector3.new(0, 1.2, 0)

        if hrp:IsA("BasePart") then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

-- Instant ProximityPrompt trigger
local function SafeTriggerPrompt(prompt)
    if not prompt or not prompt.Parent then return false end
    pcall(function()
        prompt.HoldDuration = 0
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
        elseif prompt.InputHoldBegin then
            prompt:InputHoldBegin()
            task.wait(0.01)
            prompt:InputHoldEnd()
        end
    end)
    return true
end

-- Find all egg instances across Workspace
local function GetAllEggs()
    local eggs = {}
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local parent = obj.Parent
                local pName = string.lower(parent.Name)
                local grandParent = parent.Parent and string.lower(parent.Parent.Name) or ""
                if string.find(pName, "egg") or string.find(grandParent, "egg") or string.find(pName, "carry") or string.find(pName, "rare") then
                    local primaryPart = parent:IsA("BasePart") and parent or (parent:IsA("Model") and (parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")))
                    if primaryPart then
                        table.insert(eggs, {
                            Model = parent,
                            Part = primaryPart,
                            Prompt = obj,
                            IsRare = (string.find(pName, "rare") or string.find(grandParent, "rare") or parent:FindFirstChild("RareAreaEggHighlight") or parent:FindFirstChild("Highlight")) and true or false
                        })
                    end
                end
            elseif obj:IsA("Model") and (string.find(string.lower(obj.Name), "egg") or obj:FindFirstChild("RareAreaEggHighlight")) then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    table.insert(eggs, {
                        Model = obj,
                        Part = primaryPart,
                        Prompt = prompt,
                        IsRare = (string.find(string.lower(obj.Name), "rare") or obj:FindFirstChild("RareAreaEggHighlight")) and true or false
                    })
                end
            end
        end
    end)
    return eggs
end

-- Find Furthest / Rare Egg
local function GetTargetRareEgg()
    local all = GetAllEggs()
    local rareEggs = {}
    for _, e in ipairs(all) do
        if e.IsRare then
            table.insert(rareEggs, e)
        end
    end

    local basePos = SavedBaseCFrame and SavedBaseCFrame.Position or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position) or Vector3.zero

    if #rareEggs > 0 then
        table.sort(rareEggs, function(a, b)
            return (a.Part.Position - basePos).Magnitude > (b.Part.Position - basePos).Magnitude
        end)
        return rareEggs[1]
    end

    if #all > 0 then
        table.sort(all, function(a, b)
            return (a.Part.Position - basePos).Magnitude > (b.Part.Position - basePos).Magnitude
        end)
        return all[1]
    end

    return nil
end

-- Find Nearest Egg
local function GetTargetNearestEgg()
    local all = GetAllEggs()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or #all == 0 then return nil end

    local myPos = hrp.Position
    table.sort(all, function(a, b)
        return (a.Part.Position - myPos).Magnitude < (b.Part.Position - myPos).Magnitude
    end)
    return all[1]
end

-- 1-Click Steal Rare Egg Action
local function StealRareEggOnce()
    task.spawn(function()
        local egg = GetTargetRareEgg()
        if not egg or not egg.Part then return end
        
        SafeTeleport(egg.Part.CFrame)
        task.wait(0.08)
        if egg.Prompt then
            SafeTriggerPrompt(egg.Prompt)
        end
        task.wait(0.08)
        if SavedBaseCFrame then
            SafeTeleport(SavedBaseCFrame)
        end
    end)
end

-- 1-Click Set Base Position Action
local function SetBasePosition()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            SavedBaseCFrame = hrp.CFrame
        end
    end)
end

-- 1-Click Teleport to Base Action
local function TeleportToBase()
    if SavedBaseCFrame then
        SafeTeleport(SavedBaseCFrame)
    end
end

------------------------------------------------------------------------
-- BACKGROUND AUTOMATION WORKERS (NON-BLOCKING)
------------------------------------------------------------------------

-- 1. Auto Steal Rare Egg Loop
task.spawn(function()
    while true do
        if Toggles.AutoStealRare then
            pcall(function()
                local egg = GetTargetRareEgg()
                if egg and egg.Part then
                    SafeTeleport(egg.Part.CFrame)
                    task.wait(0.1)
                    if egg.Prompt then
                        SafeTriggerPrompt(egg.Prompt)
                    end
                    task.wait(0.1)
                    if SavedBaseCFrame then
                        SafeTeleport(SavedBaseCFrame)
                    end
                end
            end)
            task.wait(0.4)
        else
            task.wait(0.5)
        end
    end
end)

-- 2. Auto Steal Nearest Egg Loop
task.spawn(function()
    while true do
        if Toggles.AutoStealNearest and not Toggles.AutoStealRare then
            pcall(function()
                local egg = GetTargetNearestEgg()
                if egg and egg.Part then
                    SafeTeleport(egg.Part.CFrame)
                    task.wait(0.08)
                    if egg.Prompt then
                        SafeTriggerPrompt(egg.Prompt)
                    end
                    task.wait(0.08)
                    if SavedBaseCFrame then
                        SafeTeleport(SavedBaseCFrame)
                    end
                end
            end)
            task.wait(0.3)
        else
            task.wait(0.5)
        end
    end
end)

-- 3. Auto Hatch Base Eggs Loop
task.spawn(function()
    while true do
        if Toggles.AutoHatch then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        local pName = string.lower(obj.Parent and obj.Parent.Name or "")
                        local actionText = string.lower(obj.ActionText or "")
                        if string.find(pName, "hatch") or string.find(actionText, "hatch") or string.find(pName, "open") or string.find(actionText, "open") then
                            SafeTriggerPrompt(obj)
                        end
                    end
                end
                
                -- Remote Sweep for Hatching
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "hatch") or string.find(rName, "openegg") then
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer(1)
                            elseif remote:IsA("RemoteFunction") then
                                remote:InvokeServer(1)
                            end
                        end
                    end
                end
            end)
            task.wait(0.35)
        else
            task.wait(0.5)
        end
    end
end)

-- 4. Auto Treadmill Trainer Loop
task.spawn(function()
    while true do
        if Toggles.AutoTreadmill then
            pcall(function()
                local treadmillPart = nil
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local name = string.lower(obj.Name)
                        if string.find(name, "treadmill") or string.find(name, "mobonlystreadmill") or string.find(name, "train") then
                            treadmillPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if treadmillPart then break end
                        end
                    end
                end

                if treadmillPart then
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - treadmillPart.Position).Magnitude > 6 then
                        SafeTeleport(treadmillPart.CFrame + Vector3.new(0, 2, 0))
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(0.5)
        end
    end
end)

-- 5. Auto Claim XP & Rewards Loop
task.spawn(function()
    while true do
        if Toggles.AutoClaimXP then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "xpclaim") or string.find(string.lower(obj.Name), "claim") or string.find(string.lower(obj.Name), "reward")) then
                        if firetouchinterest and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0)
                            task.wait(0.01)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 1)
                        end
                    elseif obj:IsA("ProximityPrompt") and (string.find(string.lower(obj.ActionText or ""), "claim") or string.find(string.lower(obj.ActionText or ""), "reward")) then
                        SafeTriggerPrompt(obj)
                    end
                end

                -- Remote Claim Sweep
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "claim") or string.find(rName, "reward") or string.find(rName, "gift") or string.find(rName, "xp") then
                            remote:FireServer()
                        end
                    end
                end
            end)
            task.wait(1.5)
        else
            task.wait(1)
        end
    end
end)

-- 6. Instant Proximity Prompts Sweeper (0s Hold)
task.spawn(function()
    while true do
        if Toggles.InstantPrompts then
            pcall(function()
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        prompt.HoldDuration = 0
                        prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, 20)
                        prompt.RequiresLineOfSight = false
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

------------------------------------------------------------------------
-- VISUALS & ESP ENGINES (WALLHACKS)
------------------------------------------------------------------------

local function CleanESPGroup(groupKey)
    if ESPObjects[groupKey] then
        for _, item in ipairs(ESPObjects[groupKey]) do
            pcall(function()
                if item and item.Destroy then item:Destroy() end
            end)
        end
    end
    ESPObjects[groupKey] = {}
end

local function CreateESPBox(part, color, text, groupKey)
    if not part or not part.Parent then return end
    pcall(function()
        local highlight = Instance.new("Highlight")
        highlight.Name = "JunejoESP"
        highlight.Adornee = part.Parent:IsA("Model") and part.Parent or part
        highlight.FillColor = color
        highlight.FillTransparency = 0.45
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = part

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "JunejoESPText"
        billboard.Adornee = part
        billboard.Size = UDim2.new(0, 100, 0, 24)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = part

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = color
        label.TextStrokeTransparency = 0.2
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextSize = 11
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard

        table.insert(ESPObjects[groupKey], highlight)
        table.insert(ESPObjects[groupKey], billboard)
    end)
end

-- Master ESP Worker Loop
task.spawn(function()
    while true do
        -- 1. Rare Egg ESP (Neon Magenta)
        if Toggles.RareEggESP then
            CleanESPGroup("RareEgg")
            pcall(function()
                local eggs = GetAllEggs()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                for _, egg in ipairs(eggs) do
                    if egg.IsRare and egg.Part then
                        local dist = hrp and math.floor((egg.Part.Position - hrp.Position).Magnitude) or 0
                        CreateESPBox(egg.Part, Color3.fromRGB(255, 0, 180), "💎 RARE EGG [" .. dist .. "m]", "RareEgg")
                    end
                end
            end)
        else
            CleanESPGroup("RareEgg")
        end

        -- 2. All Egg ESP (Gold)
        if Toggles.AllEggESP then
            CleanESPGroup("AllEgg")
            pcall(function()
                local eggs = GetAllEggs()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                for _, egg in ipairs(eggs) do
                    if egg.Part and not egg.IsRare then
                        local dist = hrp and math.floor((egg.Part.Position - hrp.Position).Magnitude) or 0
                        CreateESPBox(egg.Part, Color3.fromRGB(255, 215, 0), "🥚 EGG [" .. dist .. "m]", "AllEgg")
                    end
                end
            end)
        else
            CleanESPGroup("AllEgg")
        end

        -- 3. Player ESP & Radar (Neon Red)
        if Toggles.PlayerESP then
            CleanESPGroup("Player")
            pcall(function()
                local myChar = LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local pHrp = player.Character.HumanoidRootPart
                        local dist = myHrp and math.floor((pHrp.Position - myHrp.Position).Magnitude) or 0
                        CreateESPBox(pHrp, Color3.fromRGB(255, 50, 50), "👤 " .. player.DisplayName .. " [" .. dist .. "m]", "Player")
                    end
                end
            end)
        else
            CleanESPGroup("Player")
        end

        task.wait(1.5)
    end
end)

------------------------------------------------------------------------
-- MOVEMENT & QUALITY OF LIFE ENGINES
------------------------------------------------------------------------

-- WalkSpeed Engine
local function UpdateSpeed()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            if Toggles.WalkSpeedBoost then
                hum.WalkSpeed = CustomSpeedValue
            else
                hum.WalkSpeed = 16
            end
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if Toggles.WalkSpeedBoost then
        UpdateSpeed()
    end
end)

-- Infinite Jump Engine
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- Noclip Engine
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

-- Smooth 3D Fly Engine
local FlyBV = nil
local FlyBG = nil

local function EnableFly()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if FlyBV then FlyBV:Destroy() end
        if FlyBG then FlyBG:Destroy() end

        FlyBV = Instance.new("BodyVelocity")
        FlyBV.Velocity = Vector3.zero
        FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBV.Parent = hrp

        FlyBG = Instance.new("BodyGyro")
        FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBG.CFrame = hrp.CFrame
        FlyBG.Parent = hrp
    end)
end

local function DisableFly()
    pcall(function()
        if FlyBV then FlyBV:Destroy() FlyBV = nil end
        if FlyBG then FlyBG:Destroy() FlyBG = nil end
    end)
end

RunService.RenderStepped:Connect(function()
    if Toggles.FlyMode and FlyBV and FlyBG then
        pcall(function()
            local cam = Workspace.CurrentCamera
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            FlyBG.CFrame = cam.CFrame
            FlyBV.Velocity = moveDir.Magnitude > 0 and (moveDir.Unit * CustomSpeedValue) or Vector3.zero
        end)
    end
end)

-- Anti-AFK Engine (20-min Disconnect Shield)
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end
end)

------------------------------------------------------------------------
-- OFFICIAL JUNEJO CLASSIC DARK UI GENERATOR (#0F0F11 - 280x285px)
------------------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoStealAnEggUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true

-- Main Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 285)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -142)
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

-- Dragging Engine
local isDragging, dragStart, startPos = false, nil, nil
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

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Header Frame (Height: 32px)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "STEAL AN EGG"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
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
    ScreenGui:Destroy()
end)

-- Header Separation Line (1px)
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Scrolling Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 0, 210)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 480)
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper: Add Flat Borderless Toggle Row
local function AddToggleRow(text, configKey, callback)
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

-- Helper: Add 1-Click Action Button Row
local function AddActionRow(text, buttonText, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -65, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(0, 58, 0, 20)
    ActionBtn.Position = UDim2.new(1, -58, 0.5, -10)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ActionBtn.BorderSizePixel = 0
    ActionBtn.Text = buttonText
    ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionBtn.TextSize = 10
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.Parent = Row
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ActionBtn
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1.2
    BtnStroke.Parent = ActionBtn
    
    ActionBtn.MouseButton1Click:Connect(function()
        ActionBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
        task.delay(0.15, function()
            ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
        end)
        if callback then callback() end
    end)
end

------------------------------------------------------------------------
-- REGISTERING ALL 17 FEATURES (NUMBER-WISE STANDARD)
------------------------------------------------------------------------

-- 1. Auto Steal Rare Egg
AddToggleRow("Auto Steal Rare Egg", "AutoStealRare")

-- 2. Auto Steal Nearest Egg
AddToggleRow("Auto Steal Nearest Egg", "AutoStealNearest")

-- 3. Steal Rare Egg (1-Click)
AddActionRow("Steal Rare Egg", "STEAL", StealRareEggOnce)

-- 4. Set Base Position (1-Click)
AddActionRow("Set Base Position", "SET", function()
    SetBasePosition()
end)

-- 5. Teleport to Base (1-Click)
AddActionRow("Teleport to Base", "TP", function()
    TeleportToBase()
end)

-- 6. Auto Hatch Base Eggs
AddToggleRow("Auto Hatch Base Eggs", "AutoHatch")

-- 7. Auto Treadmill Trainer
AddToggleRow("Auto Treadmill Trainer", "AutoTreadmill")

-- 8. Auto Claim XP & Rewards
AddToggleRow("Auto Claim XP & Rewards", "AutoClaimXP")

-- 9. Rare Egg ESP
AddToggleRow("Rare Egg ESP", "RareEggESP")

-- 10. All Egg ESP
AddToggleRow("All Egg ESP", "AllEggESP")

-- 11. Player ESP & Base Defense Radar
AddToggleRow("Player ESP & Radar", "PlayerESP")

-- 12. WalkSpeed Boost + Integrated Pill Controller (- / +)
local SpeedRow = Instance.new("Frame")
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

local MarkCorner2 = Instance.new("UICorner")
MarkCorner2.CornerRadius = UDim.new(0, 2)
MarkCorner2.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
    UpdateSpeed()
end)

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
    CustomSpeedValue = math.max(16, CustomSpeedValue - 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateSpeed()
end)

-- 13. Fly Mode
AddToggleRow("Fly Mode", "FlyMode", function(enabled)
    if enabled then EnableFly() else DisableFly() end
end)

-- 14. Noclip Mode
AddToggleRow("Noclip Mode", "Noclip")

-- 15. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump")

-- 16. Instant Proximity Prompts
AddToggleRow("Instant Prompts (0s)", "InstantPrompts")

-- 17. Anti-AFK Engine
AddToggleRow("Anti-AFK Engine", "AntiAFK")

-- Pinned Footer
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

-- Mount UI
ScreenGui.Parent = UIContainer
