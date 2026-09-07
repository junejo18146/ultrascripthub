--[[
    ========================================================================
    JUNEJO ULTRA SCRIPT HUB - +1 LONG ARM ESCAPE! (OFFICIAL V4.0 - ULTRA OPTIMIZED)
    ========================================================================
    Author: Made by Junejo (junejo18146)
    Target Game: +1 Long Arm Escape! / +1 Long Arm Toy Escape (Roblox)
    Repository: junejo18146/ultrascripthub
    File: long_arm_toy_escape.lua
    UI Standard: Junejo Classic Dark UI (#0F0F11) - Flat & Borderless Standard
    
    Changelog V4.0:
        - 100% Zero-Lag & Anti-Freeze Architecture (Cached references, no heavy GetDescendants spam)
        - Fixed Auto Wins: Strictly INCREASES wins without deducting or spending on unwanted skips/rebirths
        - 100% Vibration-Free & Screen-Stable Auto Wins
        - High-Speed Auto Train Arms (+1 Length per click + Tool Auto-Equip & Spammer + Pull-Up Bars)
        - Dedicated Auto Rebirth Engine (Executes safely only when enabled)
        - WalkSpeed Boost + Fly Mode with integrated - / + Pill Controllers
        - Infinite Jump + NoClip + Anti-AFK
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

-- Character Parts Helper
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
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return end
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

-- =================================================================
-- LIGHTWEIGHT CACHED ASSETS DISCOVERY (RUNS ONCE, NO SPAM)
-- =================================================================
local cachedTrophies = {}
local cachedTrainingBars = {}
local cachedTrainRemotes = {}
local cachedWinRemotes = {}
local cachedRebirthRemotes = {}
local cachedPrompts = {Train = {}, Win = {}, Rebirth = {}}

local function IsBlacklisted(n, pName)
    local badWords = {
        "shop", "buy", "purchase", "gamepass", "pass", "robux", 
        "skip", "cost", "price", "spend", "donate", "product", 
        "egg", "pet", "spin", "wheel", "lucky", "trade", "delete"
    }
    for _, bad in ipairs(badWords) do
        if n:find(bad) or pName:find(bad) then
            return true
        end
    end
    return false
end

local function ScanAndCacheEverything()
    local trophies = {}
    local bars = {}
    local trainRem = {}
    local winRem = {}
    local rebRem = {}
    local promptsTrain = {}
    local promptsWin = {}
    local promptsReb = {}
    local seen = {}

    -- 1. Scan ReplicatedStorage for Remotes
    pcall(function()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            local n = string.lower(obj.Name)
            local pName = obj.Parent and string.lower(obj.Parent.Name) or ""
            
            if not IsBlacklisted(n, pName) then
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    -- Training remotes
                    if n:find("train") or n:find("stretch") or n:find("arm") or n:find("length") or n:find("grow") or n:find("click") or n:find("tap") or n:find("power") or n:find("workout") or n:find("rep") or n:find("gain") or n:find("strength") or n:find("punch") then
                        table.insert(trainRem, obj)
                    -- Win remotes (STRICT: only win addition remotes, no shops/skips)
                    elseif n:find("win") or n:find("givewin") or n:find("addwin") or n:find("claimwin") or n:find("finish") or n:find("trophy") or n:find("stagecomplete") or n:find("reachgoal") or n:find("touchwin") then
                        table.insert(winRem, obj)
                    -- Rebirth remotes
                    elseif n:find("rebirth") or n:find("prestige") or n:find("ascend") then
                        table.insert(rebRem, obj)
                    end
                end
            end
        end
    end)

    -- 2. Scan Workspace for Trophies, Win Pads, Pull-Up Bars, and Prompts
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
                local n = string.lower(obj.Name)
                local pName = obj.Parent and string.lower(obj.Parent.Name) or ""
                
                if not IsBlacklisted(n, pName) then
                    -- Trophies / Win Pads / Finish parts
                    local isIgnored = n:find("spawn") or n:find("track") or n:find("floor") or n:find("baseplate") or n:find("wall") or pName:find("lobby")
                    if not isIgnored then
                        if n:find("trophy") or n:find("goldentrophy") or n:find("cup") or n:find("winpad") or n:find("finishpad") or n:find("endpad") or n:find("trophypad") or pName:find("troph") or pName:find("win") then
                            if not seen[obj] then
                                seen[obj] = true
                                table.insert(trophies, obj)
                            end
                        end
                    end
                    
                    -- Pull-up Bars & Gym Equipment
                    if n:find("bar") or n:find("pullup") or n:find("train") or n:find("hang") or n:find("stretch") or n:find("workout") or pName:find("bar") or pName:find("train") then
                        if not seen[obj] then
                            seen[obj] = true
                            table.insert(bars, obj)
                        end
                    end
                end
            elseif obj:IsA("TouchTransmitter") then
                local parent = obj.Parent
                if parent and parent:IsA("BasePart") and not parent:IsDescendantOf(LocalPlayer.Character) then
                    local n = string.lower(parent.Name)
                    local pn = parent.Parent and string.lower(parent.Parent.Name) or ""
                    if not IsBlacklisted(n, pn) then
                        if n:find("trophy") or n:find("win") or n:find("finish") or pn:find("troph") or pn:find("win") then
                            if not seen[parent] then
                                seen[parent] = true
                                table.insert(trophies, parent)
                            end
                        elseif n:find("bar") or n:find("train") or n:find("pullup") or pn:find("bar") then
                            if not seen[parent] then
                                seen[parent] = true
                                table.insert(bars, parent)
                            end
                        end
                    end
                end
            elseif obj:IsA("ProximityPrompt") then
                local act = string.lower(obj.ActionText or "")
                local objT = string.lower(obj.ObjectText or "")
                local pName = string.lower(obj.Parent and obj.Parent.Name or "")
                
                if not IsBlacklisted(act, pName) and not IsBlacklisted(objT, pName) then
                    if act:find("train") or act:find("pull") or act:find("stretch") or act:find("hang") or pName:find("train") or pName:find("bar") then
                        table.insert(promptsTrain, obj)
                    elseif act:find("win") or act:find("trophy") or act:find("finish") or act:find("claim") or pName:find("trophy") or pName:find("win") then
                        table.insert(promptsWin, obj)
                    elseif act:find("rebirth") or act:find("prestige") or pName:find("rebirth") then
                        table.insert(promptsReb, obj)
                    end
                end
            end
        end
    end)

    cachedTrophies = trophies
    cachedTrainingBars = bars
    cachedTrainRemotes = trainRem
    cachedWinRemotes = winRem
    cachedRebirthRemotes = rebRem
    cachedPrompts.Train = promptsTrain
    cachedPrompts.Win = promptsWin
    cachedPrompts.Rebirth = promptsReb
end

-- Initialize scan asynchronously
task.spawn(ScanAndCacheEverything)

-- Refresh scan very gently every 30 seconds
task.spawn(function()
    while true do
        task.wait(30)
        ScanAndCacheEverything()
    end
end)

-- =================================================================
-- 1. AUTO TRAIN ARMS ENGINE (HIGH SPEED, 0% LAG)
-- =================================================================

-- Thread A: High-Speed Screen Clicks (Gives +1 Arm Length / Arm Stat)
task.spawn(function()
    while true do
        task.wait(0.06)
        if Toggles.AutoTrain then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(500, 500))
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

-- Thread B: Tool Auto-Equipper & Activator (Dumbbells / Arm Clickers)
task.spawn(function()
    while true do
        task.wait(0.1)
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
                            tool = bpTool
                        end
                    end
                    
                    if tool then
                        pcall(function() tool:Activate() end)
                    end
                end
            end)
        end
    end
end)

-- Thread C: Training Prompts, Pull-Up Bars & Cached Training Remotes
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoTrain then
            pcall(function()
                local root, hum, rHand, lHand, _ = getCharParts()
                
                -- Touch Overhead Bars in Gym / Lobby
                if root and #cachedTrainingBars > 0 and firetouchinterest then
                    for _, bar in ipairs(cachedTrainingBars) do
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
                
                -- Trigger Training Proximity Prompts
                for _, prompt in ipairs(cachedPrompts.Train) do
                    if not Toggles.AutoTrain then break end
                    if prompt and prompt.Parent and prompt.Enabled then
                        triggerPrompt(prompt)
                    end
                end
                
                -- Fire Cached Training Remotes
                for _, rem in ipairs(cachedTrainRemotes) do
                    if not Toggles.AutoTrain then break end
                    if rem and rem.Parent then
                        if rem:IsA("RemoteEvent") then
                            pcall(function() rem:FireServer() end)
                            pcall(function() rem:FireServer(1) end)
                            pcall(function() rem:FireServer(true) end)
                            pcall(function() rem:FireServer("Train") end)
                            pcall(function() rem:FireServer("Arm") end)
                        elseif rem:IsA("RemoteFunction") then
                            task.spawn(function()
                                pcall(function() rem:InvokeServer() end)
                                pcall(function() rem:InvokeServer(1) end)
                                pcall(function() rem:InvokeServer("Train") end)
                            end)
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 2. AUTO WINS ENGINE (100% INCREASE ONLY, NO DEDUCTIONS, VIBRATION-FREE)
-- =================================================================

-- Thread A: Virtual Touch Interest on Trophies & Win Pads
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoWins then
            pcall(function()
                local root, hum = getCharParts()
                if not root or not hum or hum.Health <= 0 then return end
                
                -- Virtual Touch on all Golden Trophies / Win Pads
                if #cachedTrophies > 0 and firetouchinterest then
                    for _, trophy in ipairs(cachedTrophies) do
                        if not Toggles.AutoWins then break end
                        if trophy and trophy.Parent then
                            firetouchinterest(root, trophy, 0)
                            firetouchinterest(root, trophy, 1)
                        end
                    end
                end
                
                -- Trigger Win Proximity Prompts
                for _, prompt in ipairs(cachedPrompts.Win) do
                    if not Toggles.AutoWins then break end
                    if prompt and prompt.Parent and prompt.Enabled then
                        triggerPrompt(prompt)
                    end
                end
            end)
        end
    end
end)

-- Thread B: Pure Win Addition Remotes (Strictly Checked, No Deductions)
task.spawn(function()
    while true do
        task.wait(0.25)
        if Toggles.AutoWins then
            pcall(function()
                for _, rem in ipairs(cachedWinRemotes) do
                    if not Toggles.AutoWins then break end
                    if rem and rem.Parent then
                        local n = string.lower(rem.Name)
                        -- STRICT SAFETY CHECK: Ensure it's not a spend/buy/skip remote
                        if not n:find("skip") and not n:find("buy") and not n:find("cost") and not n:find("rebirth") and not n:find("upgrade") then
                            if rem:IsA("RemoteEvent") then
                                pcall(function() rem:FireServer() end)
                                pcall(function() rem:FireServer(1) end)
                                pcall(function() rem:FireServer(true) end)
                                pcall(function() rem:FireServer("Win") end)
                                pcall(function() rem:FireServer("Trophy") end)
                            elseif rem:IsA("RemoteFunction") then
                                task.spawn(function()
                                    pcall(function() rem:InvokeServer() end)
                                    pcall(function() rem:InvokeServer(1) end)
                                    pcall(function() rem:InvokeServer("Win") end)
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 3. AUTO REBIRTH ENGINE (STRICTLY ISOLATED & DEDICATED)
-- =================================================================
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.AutoRebirth then
            pcall(function()
                -- 1. Fire cached rebirth remotes
                for _, rem in ipairs(cachedRebirthRemotes) do
                    if not Toggles.AutoRebirth then break end
                    if rem and rem.Parent then
                        if rem:IsA("RemoteEvent") then
                            pcall(function() rem:FireServer() end)
                            pcall(function() rem:FireServer(1) end)
                            pcall(function() rem:FireServer(true) end)
                        elseif rem:IsA("RemoteFunction") then
                            task.spawn(function()
                                pcall(function() rem:InvokeServer() end)
                                pcall(function() rem:InvokeServer(1) end)
                            end)
                        end
                    end
                end
                
                -- 2. Trigger Rebirth Prompts
                for _, prompt in ipairs(cachedPrompts.Rebirth) do
                    if not Toggles.AutoRebirth then break end
                    if prompt and prompt.Parent and prompt.Enabled then
                        triggerPrompt(prompt)
                    end
                end
                
                -- 3. Trigger Rebirth Confirmation button in PlayerGui if open
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui and firesignal then
                    for _, btn in ipairs(pgui:GetDescendants()) do
                        if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                            local bName = string.lower(btn.Name)
                            local bText = btn:IsA("TextButton") and string.lower(btn.Text) or ""
                            if (bName:find("rebirth") or bText:find("rebirth") or bName:find("prestige") or bText:find("prestige")) and not bName:find("shop") and not bName:find("pass") and not bText:find("robux") then
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
-- 4. PLAYER ENHANCEMENTS (WalkSpeed, InfJump, Noclip, Fly)
-- =================================================================

-- WalkSpeed Enforcer (Direct CFrame Offset + Humanoid Speed)
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

-- 2. Auto Wins (100% Increase Only, Vibration-Free)
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

print("[Junejo Script Hub]: +1 Long Arm Escape V4.0 Loaded Successfully!")
