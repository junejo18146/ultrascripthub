--[[
    ========================================================================
    JUNEJO ULTRA SCRIPT HUB - +1 LONG ARM ESCAPE! (OFFICIAL V3.0)
    ========================================================================
    Author: Made by Junejo (junejo18146)
    Target Game: +1 Long Arm Escape! / +1 Long Arm Toy Escape (Roblox)
    Repository: junejo18146/ultrascripthub
    File: long_arm_toy_escape.lua
    UI Standard: Junejo Classic Dark UI (#0F0F11) - Flat & Borderless Standard
    
    Features Included:
        1. Auto Train Arms (Multi-Threaded Click/Tap Engine + Tool Auto-Equip & Spammer + Training Remotes + Equipment Prompts)
        2. Auto Wins (100% Vibration-Free & Screen-Stable: Virtual Touch Interest + Trophy Sweeper + Remote Harvester)
        3. Auto Rebirth (Automatic Prestige Engine & Remote Invocations)
        4. WalkSpeed Boost + Integrated Pill Controller (- / +: 16 to 300)
        5. Infinite Jump (Airborne Continuous Multi-Jump Engine with Mobile Hook)
        6. NoClip Mode (Walk & Phase Through Walls & Barriers)
        7. Fly Mode + Integrated Pill Controller (- / +: 20 to 250 with WASD & Mobile Joystick)
        8. Anti-AFK Engine (Auto 20-minute idle disconnect protection)
    ========================================================================
--]]

local GameTitle = "+1 LONG ARM ESCAPE"

-- Core Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- =================================================================
-- SAFE GUI PARENT RESOLVER & DUPLICATE CLEANER
-- =================================================================
local function GetSafeGuiParent()
    local targetParent = nil
    if gethui then
        local s, r = pcall(gethui)
        if s and r then targetParent = r end
    end
    if not targetParent then
        local s, _ = pcall(function()
            local test = Instance.new("Folder")
            test.Parent = CoreGui
            test:Destroy()
        end)
        if s then targetParent = CoreGui end
    end
    if not targetParent then
        targetParent = LocalPlayer:WaitForChild("PlayerGui", 5) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end
    return targetParent or CoreGui or LocalPlayer:FindFirstChild("PlayerGui")
end

local function CleanupOldGui()
    pcall(function()
        local parent = GetSafeGuiParent()
        local names = {"JunejoHubUI_LongArmEscape", "SakiScriptsLongArmUI", "RobloxScriptUI_LongArmEscape", "RobloxScriptUI_LongArmEscapeHub", "SakiScriptsUI"}
        for _, name in ipairs(names) do
            local old = parent:FindFirstChild(name)
            if old then old:Destroy() end
        end
    end)
    pcall(function()
        for _, name in ipairs({"JunejoHubUI_LongArmEscape", "SakiScriptsLongArmUI", "RobloxScriptUI_LongArmEscape", "RobloxScriptUI_LongArmEscapeHub", "SakiScriptsUI"}) do
            if CoreGui:FindFirstChild(name) then
                CoreGui[name]:Destroy()
            end
            if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
                LocalPlayer.PlayerGui[name]:Destroy()
            end
        end
    end)
end
CleanupOldGui()

-- Global Feature States & Configuration
local Toggles = {
    AutoTrain = false,
    AutoWins = false,
    AutoRebirth = false,
    WalkSpeedBoost = false,
    InfiniteJump = false,
    Noclip = false,
    FlyMode = false,
    AntiAFK = true
}

local CustomSpeedValue = 45
local CustomFlySpeed = 60

-- =================================================================
-- HELPER FUNCTIONS & CHARACTER ACCESS
-- =================================================================
local function getCharParts()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil, nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local rHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
    local lHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
    local head = char:FindFirstChild("Head")
    return root, hum, rHand, lHand, head
end

local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.MaxActivationDistance = 999999
        prompt.RequiresLineOfSight = false
        prompt.HoldDuration = 0
    end)
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt, 1)
        else
            prompt:InputHoldBegin()
            task.wait(0.01)
            prompt:InputHoldEnd()
        end
    end)
end

-- Anti-AFK Engine
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

-- Cached training bars & win pads
local cachedBars = {}
local cachedWinPads = {}
local lastCacheUpdate = 0

local function refreshWorkspaceCache()
    local bars = {}
    local winPads = {}
    local seen = {}
    
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
                local n = string.lower(obj.Name)
                local pName = obj.Parent and string.lower(obj.Parent.Name) or ""
                local isYellow = (obj.BrickColor.Name:lower():find("yellow") or (obj.Color.R > 0.65 and obj.Color.G > 0.65 and obj.Color.B < 0.45))
                
                -- Check for Training Bars / Equipment / Pullup / Dumbbell / Workout zones
                if n:find("bar") or n:find("pullup") or n:find("train") or n:find("hang") or n:find("stretch") or n:find("weight") or n:find("dumbbell") or n:find("gym") or n:find("workout") or pName:find("bar") or pName:find("train") or pName:find("workout") or pName:find("equipment") then
                    if not seen[obj] then
                        seen[obj] = true
                        table.insert(bars, obj)
                    end
                end
                
                -- Check for Win Pads / Yellow Stage Pads / Trophies / Finish lines
                local isIgnoredWin = n:find("spawn") or n:find("track") or n:find("floor") or n:find("baseplate") or n:find("wall") or pName:find("lobby") or pName:find("gui")
                if not isIgnoredWin then
                    if n:find("win") or n:find("finish") or n:find("victory") or n:find("trophy") or n:find("goldentrophy") or n:find("cup") or n:find("checkpoint") or n:find("goal") or n:find("endpad") or n:find("winpad") or n:find("trophypad") or pName:find("win") or pName:find("troph") or (isYellow and (n:find("pad") or pName:find("stage"))) then
                        if not seen[obj] then
                            seen[obj] = true
                            table.insert(winPads, obj)
                        end
                    end
                end
            elseif obj:IsA("TouchTransmitter") then
                local parent = obj.Parent
                if parent and parent:IsA("BasePart") and not parent:IsDescendantOf(LocalPlayer.Character) then
                    local n = string.lower(parent.Name)
                    local pn = parent.Parent and string.lower(parent.Parent.Name) or ""
                    if n:find("win") or n:find("finish") or n:find("victory") or n:find("trophy") or n:find("checkpoint") or n:find("pad") or pn:find("win") or pn:find("stage") or pn:find("troph") then
                        if not seen[parent] then
                            seen[parent] = true
                            table.insert(winPads, parent)
                        end
                    elseif n:find("bar") or n:find("train") or n:find("stretch") or n:find("hang") or pn:find("bar") or pn:find("train") then
                        if not seen[parent] then
                            seen[parent] = true
                            table.insert(bars, parent)
                        end
                    end
                end
            end
        end
    end)
    
    cachedBars = bars
    cachedWinPads = winPads
    lastCacheUpdate = tick()
end

refreshWorkspaceCache()

-- =================================================================
-- 1. AUTO TRAIN ARMS (HIGH-FREQUENCY MULTI-THREADED TRAIN ENGINE)
-- =================================================================
local trainKeywords = {
    "train", "stretch", "arm", "length", "grow", "pullup", "click", "tap", 
    "add", "gain", "power", "workout", "exercise", "rep", "give", "increase", 
    "stat", "farm", "punch", "lift", "strength", "long", "swing", "hit", "growth"
}

local function fireAllTrainingRemotes()
    pcall(function()
        local containers = {ReplicatedStorage, Workspace, LocalPlayer:FindFirstChild("PlayerScripts"), LocalPlayer:FindFirstChild("PlayerGui")}
        for _, container in ipairs(containers) do
            if container then
                for _, obj in ipairs(container:GetDescendants()) do
                    if obj:IsA("RemoteEvent") then
                        local n = string.lower(obj.Name)
                        local isShop = n:find("shop") or n:find("buy") or n:find("purchase") or n:find("pass") or n:find("gamepass") or n:find("egg") or n:find("pet")
                        if not isShop then
                            for _, kw in ipairs(trainKeywords) do
                                if n:find(kw) then
                                    pcall(function() obj:FireServer() end)
                                    pcall(function() obj:FireServer(1) end)
                                    pcall(function() obj:FireServer(true) end)
                                    pcall(function() obj:FireServer("Train") end)
                                    pcall(function() obj:FireServer("Arm") end)
                                    pcall(function() obj:FireServer("Length") end)
                                    pcall(function() obj:FireServer("Click") end)
                                    pcall(function() obj:FireServer(LocalPlayer) end)
                                    break
                                end
                            end
                        end
                    elseif obj:IsA("RemoteFunction") then
                        local n = string.lower(obj.Name)
                        local isShop = n:find("shop") or n:find("buy") or n:find("purchase") or n:find("egg") or n:find("pet")
                        if not isShop then
                            for _, kw in ipairs(trainKeywords) do
                                if n:find(kw) then
                                    task.spawn(function()
                                        pcall(function() obj:InvokeServer() end)
                                        pcall(function() obj:InvokeServer(1) end)
                                        pcall(function() obj:InvokeServer(true) end)
                                        pcall(function() obj:InvokeServer("Train") end)
                                        pcall(function() obj:InvokeServer("Arm") end)
                                    end)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Thread A: High-speed Screen Clicker & Input Simulation (Gives +1 Stat on Click/Tap)
task.spawn(function()
    while true do
        task.wait(0.04)
        if Toggles.AutoTrain then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(500, 500))
                VirtualUser:Button1Down(Vector2.new(0, 0))
                VirtualUser:Button1Up(Vector2.new(0, 0))
            end)
            if VirtualInputManager then
                pcall(function()
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 1)
                end)
            end
        end
    end
end)

-- Thread B: Tool Auto-Equip, Rapid Activator & Tool Remotes Spammer
task.spawn(function()
    while true do
        task.wait(0.05)
        if Toggles.AutoTrain then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                
                if char and hum then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if not tool and backpack then
                        local bpTool = backpack:FindFirstChildOfClass("Tool")
                        if bpTool then
                            hum:EquipTool(bpTool)
                            task.wait(0.02)
                            tool = bpTool
                        end
                    end
                    
                    if tool then
                        pcall(function() tool:Activate() end)
                        for _, rem in ipairs(tool:GetDescendants()) do
                            if rem:IsA("RemoteEvent") then
                                pcall(function() rem:FireServer() end)
                                pcall(function() rem:FireServer(1) end)
                                pcall(function() rem:FireServer(true) end)
                            elseif rem:IsA("RemoteFunction") then
                                pcall(function() rem:InvokeServer() end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Thread C: Workout Equipment, Pull-up Bars & Training Remotes Dispatcher
task.spawn(function()
    while true do
        task.wait(0.12)
        if Toggles.AutoTrain then
            pcall(function()
                if tick() - lastCacheUpdate > 8 then
                    refreshWorkspaceCache()
                end
                
                local root, hum, rHand, lHand, _ = getCharParts()
                
                -- 1. Touch Workout Bars & Stations across Workspace
                if root and #cachedBars > 0 and firetouchinterest then
                    for _, bar in ipairs(cachedBars) do
                        if not Toggles.AutoTrain then break end
                        if bar and bar.Parent then
                            if rHand then
                                firetouchinterest(rHand, bar, 0)
                                firetouchinterest(rHand, bar, 1)
                            end
                            if lHand then
                                firetouchinterest(lHand, bar, 0)
                                firetouchinterest(lHand, bar, 1)
                            end
                            firetouchinterest(root, bar, 0)
                            firetouchinterest(root, bar, 1)
                        end
                    end
                end
                
                -- 2. Trigger ProximityPrompts & ClickDetectors on Bars
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoTrain then break end
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local pName = string.lower(prompt.Parent and prompt.Parent.Name or "")
                        local act = string.lower(prompt.ActionText or "")
                        local objT = string.lower(prompt.ObjectText or "")
                        if pName:find("train") or pName:find("bar") or pName:find("stretch") or pName:find("arm") or pName:find("pullup") or act:find("train") or act:find("pull") or act:find("exercise") or act:find("stretch") or act:find("hang") or act:find("workout") or objT:find("train") or objT:find("bar") then
                            triggerPrompt(prompt)
                        end
                    elseif prompt:IsA("ClickDetector") then
                        local pName = string.lower(prompt.Parent and prompt.Parent.Name or "")
                        if pName:find("train") or pName:find("bar") or pName:find("arm") or pName:find("stretch") or pName:find("pullup") then
                            pcall(function() fireclickdetector(prompt) end)
                        end
                    end
                end
                
                -- 3. Fire all Training Remotes
                fireAllTrainingRemotes()
                
                -- 4. PlayerGui Train Button Clicker
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui and firesignal then
                    for _, btn in ipairs(pgui:GetDescendants()) do
                        if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                            local bName = string.lower(btn.Name)
                            local bText = btn:IsA("TextButton") and string.lower(btn.Text) or ""
                            if (bName:find("train") or bText:find("train") or bName:find("stretch") or bText:find("stretch") or bName:find("click") or bText:find("tap") or bName:find("workout") or bName:find("punch")) and not bName:find("shop") and not bText:find("shop") and not bName:find("egg") and not bName:find("pass") then
                                firesignal(btn.MouseButton1Click)
                                firesignal(btn.Activated)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 2. AUTO WINS ENGINE (100% VIBRATION-FREE & SCREEN-STABLE)
-- =================================================================
local winKeywords = {
    "win", "givewin", "addwin", "claimwin", "finish", "trophy", "stage", 
    "reachgoal", "checkpoint", "victory", "collect", "claim", "reward", 
    "addwins", "end", "beat", "escaped", "escape", "touchwin", "collecttrophy"
}

local function IsBlacklistedForWins(name)
    local n = string.lower(name)
    local badKeywords = {
        "buy", "shop", "gamepass", "pass", "robux", "purchase", 
        "product", "donate", "2x", "3x", "boost", "prompt", 
        "price", "store", "pay", "order", "item", "devproduct", "spend",
        "egg", "pet", "spin", "wheel", "lucky"
    }
    for _, bad in ipairs(badKeywords) do
        if string.find(n, bad) then
            return true
        end
    end
    return false
end

-- Thread A: Pure Game Remotes Invocations (0% Camera Movement, 100% Stable)
task.spawn(function()
    while true do
        task.wait(0.15)
        if Toggles.AutoWins then
            pcall(function()
                local containers = {ReplicatedStorage, Workspace, LocalPlayer:FindFirstChild("PlayerScripts"), LocalPlayer:FindFirstChild("PlayerGui")}
                for _, container in ipairs(containers) do
                    if container then
                        for _, obj in ipairs(container:GetDescendants()) do
                            if not Toggles.AutoWins then break end
                            if obj:IsA("RemoteEvent") then
                                local n = string.lower(obj.Name)
                                local pName = obj.Parent and string.lower(obj.Parent.Name) or ""
                                if not IsBlacklistedForWins(n) and not IsBlacklistedForWins(pName) then
                                    for _, kw in ipairs(winKeywords) do
                                        if string.find(n, kw) then
                                            pcall(function() obj:FireServer() end)
                                            pcall(function() obj:FireServer(1) end)
                                            pcall(function() obj:FireServer(true) end)
                                            pcall(function() obj:FireServer("Win") end)
                                            pcall(function() obj:FireServer("Trophy") end)
                                            pcall(function() obj:FireServer(LocalPlayer) end)
                                            pcall(function() obj:FireServer(1, true) end)
                                            break
                                        end
                                    end
                                end
                            elseif obj:IsA("RemoteFunction") then
                                local n = string.lower(obj.Name)
                                local pName = obj.Parent and string.lower(obj.Parent.Name) or ""
                                if not IsBlacklistedForWins(n) and not IsBlacklistedForWins(pName) then
                                    for _, kw in ipairs(winKeywords) do
                                        if string.find(n, kw) then
                                            task.spawn(function()
                                                pcall(function() obj:InvokeServer() end)
                                                pcall(function() obj:InvokeServer(1) end)
                                                pcall(function() obj:InvokeServer(true) end)
                                                pcall(function() obj:InvokeServer("Win") end)
                                                pcall(function() obj:InvokeServer("Trophy") end)
                                            end)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- PlayerGui Win & Claim Buttons
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui and firesignal then
                    for _, btn in ipairs(pgui:GetDescendants()) do
                        if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                            local bName = string.lower(btn.Name)
                            local bText = btn:IsA("TextButton") and string.lower(btn.Text) or ""
                            if not IsBlacklistedForWins(bName) and not IsBlacklistedForWins(bText) then
                                if (string.find(bName, "win") or string.find(bText, "win") or string.find(bName, "claim") or string.find(bText, "claim") or string.find(bName, "trophy") or string.find(bText, "trophy") or string.find(bName, "reward")) then
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

-- Thread B: Virtual Touch on Win Pads & Trophies (Zero Screen Shaking)
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoWins then
            pcall(function()
                local root, hum = getCharParts()
                if not root or not hum or hum.Health <= 0 then return end
                
                if tick() - lastCacheUpdate > 8 then
                    refreshWorkspaceCache()
                end
                
                -- Virtual Touch Interest on all detected Win Pads & Trophies from current location
                if #cachedWinPads > 0 and firetouchinterest then
                    for _, pad in ipairs(cachedWinPads) do
                        if not Toggles.AutoWins then break end
                        if pad and pad.Parent then
                            firetouchinterest(root, pad, 0)
                            firetouchinterest(root, pad, 1)
                            
                            -- Trigger any ProximityPrompts or ClickDetectors in the pad's model
                            if pad.Parent then
                                for _, sub in ipairs(pad.Parent:GetDescendants()) do
                                    if sub:IsA("ProximityPrompt") and sub.Enabled then
                                        triggerPrompt(sub)
                                    elseif sub:IsA("ClickDetector") then
                                        pcall(function() fireclickdetector(sub) end)
                                    elseif sub:IsA("BasePart") and sub ~= pad and firetouchinterest then
                                        local subName = string.lower(sub.Name)
                                        if string.find(subName, "win") or string.find(subName, "trophy") or string.find(subName, "finish") or string.find(subName, "cup") then
                                            firetouchinterest(root, sub, 0)
                                            firetouchinterest(root, sub, 1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 3. AUTO REBIRTH ENGINE
-- =================================================================
local cachedRebirthRemote = nil
local lastRebirthSearch = 0

local function getRebirthRemote()
    if cachedRebirthRemote and cachedRebirthRemote.Parent then
        return cachedRebirthRemote
    end
    if tick() - lastRebirthSearch < 10 then return nil end
    lastRebirthSearch = tick()
    
    pcall(function()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local n = obj.Name:lower()
                if (n:find("rebirth") or n:find("prestige") or n:find("ascend")) and not n:find("shop") and not n:find("buy") and not n:find("pass") then
                    cachedRebirthRemote = obj
                    return
                end
            end
        end
    end)
    return cachedRebirthRemote
end

task.spawn(function()
    while true do
        task.wait(2)
        if Toggles.AutoRebirth then
            pcall(function()
                local rem = getRebirthRemote()
                if rem then
                    rem:FireServer()
                    rem:FireServer(1)
                    rem:FireServer(true)
                end
            end)
        end
    end
end)

-- =================================================================
-- 4. PLAYER ENHANCEMENTS (WalkSpeed, InfJump, Noclip, Fly)
-- =================================================================

-- WalkSpeed Enforcer
RunService.RenderStepped:Connect(function(deltaTime)
    pcall(function()
        if Toggles.WalkSpeedBoost and CustomSpeedValue and CustomSpeedValue > 16 then
            local char, hum = LocalPlayer.Character, nil
            if char then hum = char:FindFirstChildOfClass("Humanoid") end
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if char and hum and hrp and hum.MoveDirection.Magnitude > 0 then
                local speedBoost = (CustomSpeedValue - 16)
                hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (speedBoost * deltaTime))
            end
        end
    end)
end)

-- Infinite Jump Engine
local function performJump()
    if not Toggles.InfiniteJump then return end
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 52, hrp.AssemblyLinearVelocity.Z)
        end
    end)
end

UserInputService.JumpRequest:Connect(performJump)

-- Mobile Jump Button Hook
local function hookMobileJump()
    pcall(function()
        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
        local touchGui = pgui and pgui:FindFirstChild("TouchGui")
        local touchControl = touchGui and touchGui:FindFirstChild("TouchControlFrame")
        local jumpBtn = touchControl and touchControl:FindFirstChild("JumpButton")
        if jumpBtn then
            jumpBtn.InputBegan:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and Toggles.InfiniteJump then
                    performJump()
                end
            end)
        end
    end)
end

task.spawn(function()
    task.wait(1)
    hookMobileJump()
end)

-- NoClip Engine
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

-- Fly Engine (Full 3D Smooth WASD & Mobile Touch Joystick)
local FlyBodyGyro = nil
local FlyBodyVelocity = nil
local FlyConnection = nil
local Flying = false

local function DisableFly()
    Flying = false
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    if FlyBodyVelocity then
        pcall(function() FlyBodyVelocity:Destroy() end)
        FlyBodyVelocity = nil
    end
    if FlyBodyGyro then
        pcall(function() FlyBodyGyro:Destroy() end)
        FlyBodyGyro = nil
    end
    pcall(function()
        local _, hrp, hum = getCharParts()
        if hum then hum.PlatformStand = false end
        if hrp then
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
            if hrp:FindFirstChild("LongArmFlyBV") then hrp.LongArmFlyBV:Destroy() end
            if hrp:FindFirstChild("LongArmFlyBG") then hrp.LongArmFlyBG:Destroy() end
        end
    end)
end

local function EnableFly()
    DisableFly()
    local char, hrp, hum = getCharParts()
    if not hrp or not hum then return end

    Flying = true
    
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.Name = "LongArmFlyBG"
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.CFrame = hrp.CFrame
    FlyBodyGyro.Parent = hrp

    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Name = "LongArmFlyBV"
    FlyBodyVelocity.Velocity = Vector3.zero
    FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVelocity.Parent = hrp

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Toggles.FlyMode or not Flying or not hrp or not hrp.Parent or not hum or hum.Health <= 0 then
            DisableFly()
            return
        end

        local cam = Workspace.CurrentCamera
        if not cam then return end

        FlyBodyGyro.CFrame = cam.CFrame

        local flySpeed = math.clamp(CustomFlySpeed, 20, 250)
        local moveDirection = Vector3.zero

        -- PC Keyboard WASD Controls
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end

        -- Mobile Touch / Dynamic Thumbstick Support
        if hum.MoveDirection.Magnitude > 0 then
            local rawMove = hum.MoveDirection
            local forwardDot = rawMove:Dot(cam.CFrame.LookVector)
            local rightDot = rawMove:Dot(cam.CFrame.RightVector)
            
            local mobileDir = (cam.CFrame.LookVector * forwardDot) + (cam.CFrame.RightVector * rightDot)
            if mobileDir.Magnitude > 0.1 then
                moveDirection = moveDirection + mobileDir.Unit
            else
                moveDirection = moveDirection + (cam.CFrame.LookVector * rawMove.Magnitude)
            end
        end

        if moveDirection.Magnitude > 0 then
            FlyBodyVelocity.Velocity = moveDirection.Unit * flySpeed
        else
            FlyBodyVelocity.Velocity = Vector3.zero
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.6)
    hookMobileJump()
    if Toggles.FlyMode then
        EnableFly()
    end
end)

-- =================================================================
-- OFFICIAL JUNEJO STANDARD UI GENERATOR (FLAT & BORDERLESS)
-- =================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_LongArmEscape"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Enabled = true
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = GetSafeGuiParent()

local MainWindowHeight = 265

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 280, 0, MainWindowHeight)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

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
TitleLabel.Text = GameTitle
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
    Toggles.AutoTrain = false
    Toggles.AutoWins = false
    Toggles.AutoRebirth = false
    Toggles.WalkSpeedBoost = false
    Toggles.InfiniteJump = false
    Toggles.Noclip = false
    Toggles.FlyMode = false
    DisableFly()
    ScreenGui:Destroy()
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Scrollable Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 0, 185)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper function for Toggle Rows (Strictly Flat & Borderless Standard)
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

-- =================================================================
-- BUILD FEATURE ROWS
-- =================================================================

-- 1. Auto Train Arms
AddToggleRow("Auto Train Arms", "AutoTrain")

-- 2. Auto Wins (Vibration-Free & Screen-Stable)
AddToggleRow("Auto Wins (Vibration-Free)", "AutoWins")

-- 3. Auto Rebirth
AddToggleRow("Auto Rebirth", "AutoRebirth")

-- 4. WalkSpeed with Integrated - / + Pill Controller
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

local MarkCorner = Instance.new("UICorner")
MarkCorner.CornerRadius = UDim.new(0, 2)
MarkCorner.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
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
    CustomSpeedValue = math.max(16, CustomSpeedValue - 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
end)

-- 5. Fly Mode with Integrated - / + Pill Controller
local FlyRow = Instance.new("Frame")
FlyRow.Size = UDim2.new(1, 0, 0, 23)
FlyRow.BackgroundTransparency = 1
FlyRow.Parent = ContentFrame

local FlyToggleBtn = Instance.new("TextButton")
FlyToggleBtn.Size = UDim2.new(0.55, 0, 1, 0)
FlyToggleBtn.BackgroundTransparency = 1
FlyToggleBtn.Text = ""
FlyToggleBtn.ZIndex = 5
FlyToggleBtn.Parent = FlyRow

local FlyLabel = Instance.new("TextLabel")
FlyLabel.Size = UDim2.new(1, -26, 1, 0)
FlyLabel.BackgroundTransparency = 1
FlyLabel.Text = "Fly Mode"
FlyLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
FlyLabel.TextSize = 12
FlyLabel.Font = Enum.Font.GothamBold
FlyLabel.TextXAlignment = Enum.TextXAlignment.Left
FlyLabel.Parent = FlyToggleBtn

local FlyCheckBox = Instance.new("Frame")
FlyCheckBox.Size = UDim2.new(0, 18, 0, 18)
FlyCheckBox.Position = UDim2.new(1, -18, 0.5, -9)
FlyCheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
FlyCheckBox.BorderSizePixel = 0
FlyCheckBox.Parent = FlyToggleBtn

local FlyCheckCorner = Instance.new("UICorner")
FlyCheckCorner.CornerRadius = UDim.new(0, 4)
FlyCheckCorner.Parent = FlyCheckBox

local FlyCheckStroke = Instance.new("UIStroke")
FlyCheckStroke.Color = Color3.fromRGB(45, 45, 55)
FlyCheckStroke.Thickness = 1.2
FlyCheckStroke.Parent = FlyCheckBox

local FlyCheckMark = Instance.new("Frame")
FlyCheckMark.Size = UDim2.new(0, 10, 0, 10)
FlyCheckMark.Position = UDim2.new(0.5, -5, 0.5, -5)
FlyCheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FlyCheckMark.BackgroundTransparency = Toggles.FlyMode and 0 or 1
FlyCheckMark.BorderSizePixel = 0
FlyCheckMark.Parent = FlyCheckBox

local MarkCornerFly = Instance.new("UICorner")
MarkCornerFly.CornerRadius = UDim.new(0, 2)
MarkCornerFly.Parent = FlyCheckMark

FlyToggleBtn.MouseButton1Click:Connect(function()
    Toggles.FlyMode = not Toggles.FlyMode
    FlyCheckMark.BackgroundTransparency = Toggles.FlyMode and 0 or 1
    if Toggles.FlyMode then
        EnableFly()
    else
        DisableFly()
    end
end)

local FlyControlFrame = Instance.new("Frame")
FlyControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
FlyControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
FlyControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
FlyControlFrame.BorderSizePixel = 0
FlyControlFrame.Parent = FlyRow

local FlyCtrlCorner = Instance.new("UICorner")
FlyCtrlCorner.CornerRadius = UDim.new(0, 4)
FlyCtrlCorner.Parent = FlyControlFrame

local FlyCtrlStroke = Instance.new("UIStroke")
FlyCtrlStroke.Color = Color3.fromRGB(45, 45, 55)
FlyCtrlStroke.Thickness = 1
FlyCtrlStroke.Parent = FlyControlFrame

local FlyMinusBtn = Instance.new("TextButton")
FlyMinusBtn.Size = UDim2.new(0, 22, 1, 0)
FlyMinusBtn.Position = UDim2.new(0, 0, 0, 0)
FlyMinusBtn.BackgroundTransparency = 1
FlyMinusBtn.Text = "-"
FlyMinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
FlyMinusBtn.TextSize = 14
FlyMinusBtn.Font = Enum.Font.GothamBold
FlyMinusBtn.Parent = FlyControlFrame

local FlyDisplay = Instance.new("TextLabel")
FlyDisplay.Size = UDim2.new(1, -44, 1, 0)
FlyDisplay.Position = UDim2.new(0, 22, 0, 0)
FlyDisplay.BackgroundTransparency = 1
FlyDisplay.Text = tostring(CustomFlySpeed)
FlyDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyDisplay.TextSize = 11
FlyDisplay.Font = Enum.Font.GothamBold
FlyDisplay.Parent = FlyControlFrame

local FlyPlusBtn = Instance.new("TextButton")
FlyPlusBtn.Size = UDim2.new(0, 22, 1, 0)
FlyPlusBtn.Position = UDim2.new(1, -22, 0, 0)
FlyPlusBtn.BackgroundTransparency = 1
FlyPlusBtn.Text = "+"
FlyPlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
FlyPlusBtn.TextSize = 14
FlyPlusBtn.Font = Enum.Font.GothamBold
FlyPlusBtn.Parent = FlyControlFrame

FlyMinusBtn.MouseButton1Click:Connect(function()
    CustomFlySpeed = math.max(20, CustomFlySpeed - 10)
    FlyDisplay.Text = tostring(CustomFlySpeed)
end)

FlyPlusBtn.MouseButton1Click:Connect(function()
    CustomFlySpeed = math.min(250, CustomFlySpeed + 10)
    FlyDisplay.Text = tostring(CustomFlySpeed)
end)

-- 6. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump")

-- 7. NoClip
AddToggleRow("NoClip (Walk Thru Walls)", "Noclip")

-- 8. Anti-AFK Engine
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

-- Window Dragging (Mouse & Touch)
local dragging = false
local dragInput, dragStart, startPos

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

-- Mount GUI
ScreenGui.Parent = GetSafeGuiParent()

print("[Junejo Script Hub]: +1 Long Arm Escape Script Loaded Successfully!")
