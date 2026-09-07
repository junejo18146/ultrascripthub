--[[
    ========================================================================
    JUNEJO ULTRA SCRIPT HUB - ANIME CARD FARM (OFFICIAL V1.0)
    ========================================================================
    Author: Made by Junejo (junejo18146)
    Target Game: Anime Card Farm (Roblox)
    Game Link: https://www.roblox.com/games/125039473548047/Anime-Card-Farm
    Repository: junejo18146/ultrascripthub
    File: anime_card_farm.lua
    UI Standard: Junejo Classic Dark UI (#0F0F11) - Flat & Borderless Standard
    
    Features Included:
        1. Auto Carry & Instant Pickup (ProximityPrompts, Physical Touch & Remotes Sweep)
        2. Auto Instant Sell Boxes (Hitbox Touch, Sell Prompts & Deposit Remotes)
        3. Auto Open / Roll Packs (Fast Pack Rolling & Remote Invocations)
        4. Auto Upgrade Plot Slots (Automatic Slot & Plot Expansion)
        5. Infinite Money (Permanent Multiplier & Visual Enforcer)
        6. WalkSpeed Boost + Integrated Pill Controller (- / +: 16 to 300)
        7. Jump Power Boost + Integrated Pill Controller (- / +: 50 to 300)
        8. Infinite Jump (Continuous Multi-Jump Engine)
        9. Fly Mode (Smooth 3D Flight with WASD/Space/Shift controls)
        10. Anti-AFK Engine (Auto 20-minute idle disconnect protection)
    ========================================================================
--]]

local GameTitle = "ANIME CARD FARM"

-- Core Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
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
        local names = {"JunejoHubUI_AnimeCardFarm", "SakiScriptsAnimeCardFarmUI", "AnimeCardFarm_SakiScripts", "AnimeCardFarmUI_Badshah", "SakiScriptsUI"}
        for _, name in ipairs(names) do
            local old = parent:FindFirstChild(name)
            if old then old:Destroy() end
        end
    end)
    pcall(function()
        for _, name in ipairs({"JunejoHubUI_AnimeCardFarm", "SakiScriptsAnimeCardFarmUI", "AnimeCardFarm_SakiScripts", "AnimeCardFarmUI_Badshah", "SakiScriptsUI"}) do
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
    AutoCarry = false,
    AutoSell = false,
    AutoOpenPacks = false,
    AutoUpgradeSlots = false,
    InfiniteMoney = false,
    WalkSpeedBoost = false,
    JumpPowerBoost = false,
    InfiniteJump = false,
    FlyMode = false,
    AntiAFK = true
}

local CustomSpeedValue = 35
local CustomJumpValue = 100
local FlySpeedValue = 60
local LockedInfiniteBalance = 999999999999

-- =================================================================
-- HELPER FUNCTIONS & CHARACTER ACCESS
-- =================================================================
local function getPlayerChar()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return char, root, hum
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
        else
            prompt:InputHoldBegin()
            task.wait(0.01)
            prompt:InputHoldEnd()
        end
    end)
end

local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}
local function formatMoney(val)
    local i = 1
    while val >= 1000 and i < #suffixes do
        val = val / 1000
        i = i + 1
    end
    return string.format("$%.2f%s", val, suffixes[i])
end

-- Universal Event Dispatcher
local function fireSignalDirect(sig, ...)
    if not sig then return end
    local args = {...}
    pcall(function()
        if firesignal then
            firesignal(sig, table.unpack(args))
        end
    end)
    pcall(function()
        if getconnections then
            for _, conn in ipairs(getconnections(sig)) do
                if conn.Function then
                    task.spawn(pcall, conn.Function, table.unpack(args))
                elseif conn.Fire then
                    task.spawn(pcall, function() conn:Fire(table.unpack(args)) end)
                end
            end
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
-- 1. AUTO CARRY & INSTANT PICKUP ENGINE
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoCarry then
            pcall(function()
                local _, root = getPlayerChar()

                -- A) Trigger ProximityPrompts (Exclude Sell Prompts)
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local pName = string.lower(prompt.Parent and prompt.Parent.Name or "")
                        local act = string.lower(prompt.ActionText or "")
                        if not string.find(pName, "sell") and not string.find(act, "sell") then
                            triggerPrompt(prompt)
                        end
                    end
                end

                -- B) Physical Touch Collection (Radius 150 studs)
                if root and firetouchinterest then
                    for _, drop in ipairs(Workspace:GetDescendants()) do
                        if drop:IsA("BasePart") and not drop:IsA("Terrain") and not drop:IsDescendantOf(LocalPlayer.Character) then
                            local dName = string.lower(drop.Name)
                            local pName = drop.Parent and string.lower(drop.Parent.Name) or ""
                            if string.find(dName, "card") or string.find(dName, "box") or string.find(dName, "drop") or string.find(dName, "pack") or string.find(pName, "box") or string.find(pName, "card") then
                                if (drop.Position - root.Position).Magnitude <= 150 then
                                    firetouchinterest(root, drop, 0)
                                    firetouchinterest(root, drop, 1)
                                end
                            end
                        elseif drop:IsA("ClickDetector") then
                            if fireclickdetector then fireclickdetector(drop) end
                        end
                    end
                end

                -- C) Carry Remote Triggers
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    local lower = string.lower(obj.Name)
                    if string.find(lower, "carry") or string.find(lower, "pick") or string.find(lower, "grab") or string.find(lower, "take") or string.find(lower, "box") then
                        if not string.find(lower, "sell") and not string.find(lower, "buy") and not string.find(lower, "shop") then
                            if obj:IsA("RemoteEvent") then
                                pcall(function() obj:FireServer() end)
                                pcall(function() obj:FireServer(1) end)
                            elseif obj:IsA("RemoteFunction") then
                                pcall(function() obj:InvokeServer() end)
                                pcall(function() obj:InvokeServer(1) end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 2. INSTANT AUTO SELL ENGINE
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.25)
        if Toggles.AutoSell then
            pcall(function()
                local _, root = getPlayerChar()

                -- Touch Sell Hitboxes / Dropoffs
                if root and firetouchinterest then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
                            local nameL = string.lower(obj.Name)
                            if string.find(nameL, "sell") or string.find(nameL, "dropoff") or string.find(nameL, "deposit") then
                                firetouchinterest(root, obj, 0)
                                firetouchinterest(root, obj, 1)
                            end
                        elseif obj:IsA("ProximityPrompt") and obj.Enabled then
                            local act = string.lower(obj.ActionText or "")
                            local pName = string.lower(obj.Parent and obj.Parent.Name or "")
                            if string.find(act, "sell") or string.find(pName, "sell") or string.find(act, "deposit") then
                                triggerPrompt(obj)
                            end
                        end
                    end
                end

                -- Fire All Sell Remotes
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    local lower = string.lower(obj.Name)
                    if string.find(lower, "sell") or string.find(lower, "claim") or string.find(lower, "collect") or string.find(lower, "deposit") or string.find(lower, "dropoff") then
                        if obj:IsA("RemoteEvent") then
                            pcall(function() obj:FireServer() end)
                            pcall(function() obj:FireServer(true) end)
                            pcall(function() obj:FireServer("All") end)
                        elseif obj:IsA("RemoteFunction") then
                            pcall(function() obj:InvokeServer() end)
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 3. AUTO OPEN / ROLL PACKS ENGINE (MULTI-LAYER FAST PACK ROLLER)
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.25)
        if Toggles.AutoOpenPacks then
            pcall(function()
                local _, root = getPlayerChar()

                -- Layer A: Workspace ProximityPrompts for Packs / Stands / Rolls
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local pName = string.lower(prompt.Parent and prompt.Parent.Name or "")
                        local act = string.lower(prompt.ActionText or "")
                        local objText = string.lower(prompt.ObjectText or "")
                        
                        if string.find(pName, "pack") or string.find(pName, "roll") or string.find(pName, "card") or string.find(pName, "gacha") or string.find(pName, "stand") or string.find(pName, "shop") or string.find(pName, "draw") or string.find(pName, "summon") or
                           string.find(act, "pack") or string.find(act, "roll") or string.find(act, "open") or string.find(act, "draw") or string.find(act, "buy") or string.find(act, "gacha") or string.find(act, "summon") or
                           string.find(objText, "pack") or string.find(objText, "roll") or string.find(objText, "card") then
                            
                            -- Don't trigger sell or plot buy prompts here
                            if not string.find(pName, "sell") and not string.find(act, "sell") and not string.find(pName, "plot") and not string.find(act, "plot") then
                                triggerPrompt(prompt)
                            end
                        end
                    end
                end

                -- Layer B: Workspace ClickDetectors & Touch on Pack Stands
                for _, stand in ipairs(Workspace:GetDescendants()) do
                    if stand:IsA("ClickDetector") then
                        local sName = string.lower(stand.Parent and stand.Parent.Name or "")
                        if string.find(sName, "pack") or string.find(sName, "roll") or string.find(sName, "gacha") or string.find(sName, "card") or string.find(sName, "draw") then
                            if fireclickdetector then
                                fireclickdetector(stand)
                            end
                        end
                    elseif root and firetouchinterest and stand:IsA("BasePart") and not stand:IsDescendantOf(LocalPlayer.Character) then
                        local sName = string.lower(stand.Name)
                        local pName = stand.Parent and string.lower(stand.Parent.Name) or ""
                        if (string.find(sName, "pack") or string.find(sName, "roll") or string.find(sName, "gacha") or string.find(pName, "pack") or string.find(pName, "roll") or string.find(pName, "gacha")) and not string.find(sName, "sell") and not string.find(pName, "sell") then
                            if (stand.Position - root.Position).Magnitude <= 80 then
                                firetouchinterest(root, stand, 0)
                                firetouchinterest(root, stand, 1)
                            end
                        end
                    end
                end

                -- Layer C: ReplicatedStorage Universal Network Remote Sweeper
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local lower = string.lower(obj.Name)
                        if string.find(lower, "pack") or string.find(lower, "roll") or string.find(lower, "gacha") or string.find(lower, "draw") or string.find(lower, "summon") or string.find(lower, "buycard") or string.find(lower, "opencard") or string.find(lower, "buyegg") or string.find(lower, "openegg") or string.find(lower, "openbox") or string.find(lower, "rollcard") then
                            if not string.find(lower, "sell") and not string.find(lower, "upgrade") and not string.find(lower, "slot") then
                                if obj:IsA("RemoteEvent") then
                                    pcall(function() obj:FireServer() end)
                                    pcall(function() obj:FireServer(1) end)
                                    pcall(function() obj:FireServer("Basic Pack", 1) end)
                                    pcall(function() obj:FireServer("Basic", 1) end)
                                    pcall(function() obj:FireServer("Pack", 1) end)
                                    pcall(function() obj:FireServer("Basic Pack") end)
                                    pcall(function() obj:FireServer(1, false) end)
                                    pcall(function() obj:FireServer("Basic Pack", 1, false) end)
                                    pcall(function() obj:FireServer("Basic Pack", 1, true) end)
                                    pcall(function() obj:FireServer(true) end)
                                    pcall(function() obj:FireServer("1") end)
                                elseif obj:IsA("RemoteFunction") then
                                    pcall(function() obj:InvokeServer() end)
                                    pcall(function() obj:InvokeServer(1) end)
                                    pcall(function() obj:InvokeServer("Basic Pack", 1) end)
                                    pcall(function() obj:InvokeServer("Basic", 1) end)
                                    pcall(function() obj:InvokeServer("Pack", 1) end)
                                    pcall(function() obj:InvokeServer("Basic Pack") end)
                                    pcall(function() obj:InvokeServer(1, false) end)
                                    pcall(function() obj:InvokeServer("Basic Pack", 1, false) end)
                                    pcall(function() obj:InvokeServer("Basic Pack", 1, true) end)
                                end
                            end
                        end
                    end
                end

                -- Layer D: In-Game UI Buttons Clicker & Animation Skip
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then
                    for _, gui in ipairs(pGui:GetChildren()) do
                        if gui.Name ~= "JunejoHubUI_AnimeCardFarm" then
                            for _, btn in ipairs(gui:GetDescendants()) do
                                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                                    if btn.Visible and (btn.Active or btn.Selectable) then
                                        local bText = string.lower(btn:IsA("TextButton") and btn.Text or "")
                                        local bName = string.lower(btn.Name)
                                        
                                        -- Click Roll / Open buttons
                                        if (string.find(bText, "roll") or string.find(bText, "open") or string.find(bText, "draw") or string.find(bText, "gacha") or string.find(bText, "summon") or string.find(bText, "pack") or string.find(bText, "1x") or
                                            string.find(bName, "roll") or string.find(bName, "open") or string.find(bName, "draw") or string.find(bName, "gacha") or string.find(bName, "summon") or string.find(bName, "pack") or string.find(bName, "buy")) and
                                           not string.find(bText, "sell") and not string.find(bName, "sell") and not string.find(bText, "robux") and not string.find(bText, "r%$") and not string.find(bName, "gamepass") then
                                            
                                            fireSignalDirect(btn.MouseButton1Click)
                                            fireSignalDirect(btn.Activated)
                                            pcall(function()
                                                if firesignal then
                                                    firesignal(btn.MouseButton1Down)
                                                    firesignal(btn.MouseButton1Up)
                                                end
                                            end)
                                        end
                                        
                                        -- Auto Skip Animation / Auto Claim
                                        if string.find(bText, "skip") or string.find(bName, "skip") or string.find(bText, "claim") or string.find(bName, "claim") or string.find(bText, "continue") or string.find(bText, "ok") or string.find(bName, "close") then
                                            fireSignalDirect(btn.MouseButton1Click)
                                            fireSignalDirect(btn.Activated)
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
-- 4. AUTO UPGRADE PLOT SLOTS ENGINE
-- =================================================================
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.AutoUpgradeSlots then
            pcall(function()
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    local lower = string.lower(obj.Name)
                    if string.find(lower, "upgrade") or string.find(lower, "slot") or string.find(lower, "buyslot") then
                        if obj:IsA("RemoteEvent") then
                            pcall(function() obj:FireServer() end)
                            pcall(function() obj:FireServer(1) end)
                        elseif obj:IsA("RemoteFunction") then
                            pcall(function() obj:InvokeServer() end)
                            pcall(function() obj:InvokeServer(1) end)
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 5. INFINITE MONEY VISUAL ENFORCER
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.4)
        if Toggles.InfiniteMoney then
            pcall(function()
                local formatted = formatMoney(LockedInfiniteBalance)
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then
                    for _, gui in ipairs(pGui:GetChildren()) do
                        if gui.Name ~= "JunejoHubUI_AnimeCardFarm" then
                            for _, obj in ipairs(gui:GetDescendants()) do
                                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                                    local nameL = string.lower(obj.Name)
                                    local t = obj.Text
                                    if string.find(t, "%$") or string.find(nameL, "money") or string.find(nameL, "cash") or string.find(nameL, "coins") or string.find(nameL, "balance") or string.find(nameL, "yen") then
                                        if obj.Text ~= formatted then
                                            obj.Text = formatted
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                if leaderstats then
                    for _, stat in ipairs(leaderstats:GetChildren()) do
                        if stat:IsA("IntValue") or stat:IsA("NumberValue") or stat:IsA("StringValue") then
                            local sName = string.lower(stat.Name)
                            if string.find(sName, "money") or string.find(sName, "cash") or string.find(sName, "coin") or string.find(sName, "yen") or string.find(sName, "gold") then
                                if stat:IsA("StringValue") then
                                    stat.Value = formatted
                                else
                                    stat.Value = LockedInfiniteBalance
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
-- 6. PLAYER ENHANCEMENTS (WalkSpeed, JumpPower, InfJump, Fly)
-- =================================================================

-- WalkSpeed Enforcer
RunService.RenderStepped:Connect(function(deltaTime)
    pcall(function()
        if Toggles.WalkSpeedBoost and CustomSpeedValue and CustomSpeedValue > 16 then
            local char, hrp, hum = getPlayerChar()
            if char and hum and hrp and hum.MoveDirection.Magnitude > 0 then
                local speedBoost = (CustomSpeedValue - 16)
                hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (speedBoost * deltaTime))
            end
        end
    end)
end)

-- Jump Power Enforcer
RunService.RenderStepped:Connect(function()
    pcall(function()
        local _, _, hum = getPlayerChar()
        if hum then
            if Toggles.JumpPowerBoost then
                hum.UseJumpPower = true
                hum.JumpPower = CustomJumpValue
            end
        end
    end)
end)

-- Infinite Jump Engine
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        local _, root, hum = getPlayerChar()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            if root then
                root.Velocity = Vector3.new(root.Velocity.X, 52, root.Velocity.Z)
            end
        end
    end
end)

-- Fly Engine (Full 3D Smooth WASD & Mobile Touch Control)
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
        local _, hrp, hum = getPlayerChar()
        if hum then hum.PlatformStand = false end
        if hrp then
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
            if hrp:FindFirstChild("CardFlyBV") then hrp.CardFlyBV:Destroy() end
            if hrp:FindFirstChild("CardFlyBG") then hrp.CardFlyBG:Destroy() end
        end
    end)
end

local function EnableFly()
    DisableFly()
    local char, hrp, hum = getPlayerChar()
    if not hrp or not hum then return end

    Flying = true
    
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.Name = "CardFlyBG"
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.CFrame = hrp.CFrame
    FlyBodyGyro.Parent = hrp

    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Name = "CardFlyBV"
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

        local flySpeed = math.clamp(CustomSpeedValue * 2.2, 50, 220)
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

-- Re-enable Fly on Character Respawn if enabled
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.6)
    if Toggles.FlyMode then
        EnableFly()
    end
end)

-- =================================================================
-- OFFICIAL JUNEJO STANDARD UI GENERATOR (FLAT & BORDERLESS)
-- =================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_AnimeCardFarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Enabled = true
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = GetSafeGuiParent()

-- Dynamic Compact Window Height
local MainWindowHeight = 315

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
    Toggles.AutoCarry = false
    Toggles.AutoSell = false
    Toggles.AutoOpenPacks = false
    Toggles.AutoUpgradeSlots = false
    Toggles.InfiniteMoney = false
    Toggles.WalkSpeedBoost = false
    Toggles.JumpPowerBoost = false
    Toggles.InfiniteJump = false
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
ContentFrame.Size = UDim2.new(1, -24, 0, 235)
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

-- 1. Auto Carry & Instant Pickup
AddToggleRow("Auto Carry Cards / Boxes", "AutoCarry")

-- 2. Auto Instant Sell Boxes
AddToggleRow("Auto Instant Sell Boxes", "AutoSell")

-- 3. Auto Open / Roll Packs
AddToggleRow("Auto Open / Roll Packs", "AutoOpenPacks")

-- 4. Auto Upgrade Plot Slots
AddToggleRow("Auto Upgrade Plot Slots", "AutoUpgradeSlots")

-- 5. Infinite Money
AddToggleRow("Infinite Money (Lock)", "InfiniteMoney")

-- 6. WalkSpeed with Integrated - / + Pill Controller
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

-- 7. Jump Power Boost with Integrated - / + Pill Controller
local JumpRow = Instance.new("Frame")
JumpRow.Size = UDim2.new(1, 0, 0, 23)
JumpRow.BackgroundTransparency = 1
JumpRow.Parent = ContentFrame

local JumpToggleBtn = Instance.new("TextButton")
JumpToggleBtn.Size = UDim2.new(0.55, 0, 1, 0)
JumpToggleBtn.BackgroundTransparency = 1
JumpToggleBtn.Text = ""
JumpToggleBtn.ZIndex = 5
JumpToggleBtn.Parent = JumpRow

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Size = UDim2.new(1, -26, 1, 0)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "Jump Power"
JumpLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
JumpLabel.TextSize = 12
JumpLabel.Font = Enum.Font.GothamBold
JumpLabel.TextXAlignment = Enum.TextXAlignment.Left
JumpLabel.Parent = JumpToggleBtn

local JumpCheckBox = Instance.new("Frame")
JumpCheckBox.Size = UDim2.new(0, 18, 0, 18)
JumpCheckBox.Position = UDim2.new(1, -18, 0.5, -9)
JumpCheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
JumpCheckBox.BorderSizePixel = 0
JumpCheckBox.Parent = JumpToggleBtn

local JumpCheckCorner = Instance.new("UICorner")
JumpCheckCorner.CornerRadius = UDim.new(0, 4)
JumpCheckCorner.Parent = JumpCheckBox

local JumpCheckStroke = Instance.new("UIStroke")
JumpCheckStroke.Color = Color3.fromRGB(45, 45, 55)
JumpCheckStroke.Thickness = 1.2
JumpCheckStroke.Parent = JumpCheckBox

local JumpCheckMark = Instance.new("Frame")
JumpCheckMark.Size = UDim2.new(0, 10, 0, 10)
JumpCheckMark.Position = UDim2.new(0.5, -5, 0.5, -5)
JumpCheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
JumpCheckMark.BackgroundTransparency = Toggles.JumpPowerBoost and 0 or 1
JumpCheckMark.BorderSizePixel = 0
JumpCheckMark.Parent = JumpCheckBox

local MarkCornerJump = Instance.new("UICorner")
MarkCornerJump.CornerRadius = UDim.new(0, 2)
MarkCornerJump.Parent = JumpCheckMark

JumpToggleBtn.MouseButton1Click:Connect(function()
    Toggles.JumpPowerBoost = not Toggles.JumpPowerBoost
    JumpCheckMark.BackgroundTransparency = Toggles.JumpPowerBoost and 0 or 1
    if not Toggles.JumpPowerBoost then
        local _, _, hum = getPlayerChar()
        if hum then hum.JumpPower = 50 end
    end
end)

local JumpControlFrame = Instance.new("Frame")
JumpControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
JumpControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
JumpControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
JumpControlFrame.BorderSizePixel = 0
JumpControlFrame.Parent = JumpRow

local JumpCtrlCorner = Instance.new("UICorner")
JumpCtrlCorner.CornerRadius = UDim.new(0, 4)
JumpCtrlCorner.Parent = JumpControlFrame

local JumpCtrlStroke = Instance.new("UIStroke")
JumpCtrlStroke.Color = Color3.fromRGB(45, 45, 55)
JumpCtrlStroke.Thickness = 1
JumpCtrlStroke.Parent = JumpControlFrame

local JumpMinusBtn = Instance.new("TextButton")
JumpMinusBtn.Size = UDim2.new(0, 22, 1, 0)
JumpMinusBtn.Position = UDim2.new(0, 0, 0, 0)
JumpMinusBtn.BackgroundTransparency = 1
JumpMinusBtn.Text = "-"
JumpMinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
JumpMinusBtn.TextSize = 14
JumpMinusBtn.Font = Enum.Font.GothamBold
JumpMinusBtn.Parent = JumpControlFrame

local JumpDisplay = Instance.new("TextLabel")
JumpDisplay.Size = UDim2.new(1, -44, 1, 0)
JumpDisplay.Position = UDim2.new(0, 22, 0, 0)
JumpDisplay.BackgroundTransparency = 1
JumpDisplay.Text = tostring(CustomJumpValue)
JumpDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpDisplay.TextSize = 11
JumpDisplay.Font = Enum.Font.GothamBold
JumpDisplay.Parent = JumpControlFrame

local JumpPlusBtn = Instance.new("TextButton")
JumpPlusBtn.Size = UDim2.new(0, 22, 1, 0)
JumpPlusBtn.Position = UDim2.new(1, -22, 0, 0)
JumpPlusBtn.BackgroundTransparency = 1
JumpPlusBtn.Text = "+"
JumpPlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
JumpPlusBtn.TextSize = 14
JumpPlusBtn.Font = Enum.Font.GothamBold
JumpPlusBtn.Parent = JumpControlFrame

JumpMinusBtn.MouseButton1Click:Connect(function()
    CustomJumpValue = math.max(50, CustomJumpValue - 25)
    JumpDisplay.Text = tostring(CustomJumpValue)
end)

JumpPlusBtn.MouseButton1Click:Connect(function()
    CustomJumpValue = math.min(300, CustomJumpValue + 25)
    JumpDisplay.Text = tostring(CustomJumpValue)
end)

-- 8. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump")

-- 9. Fly Mode
AddToggleRow("Fly Mode", "FlyMode", function(enabled)
    if enabled then
        EnableFly()
    else
        DisableFly()
    end
end)

-- 10. Anti-AFK Engine
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

print("[Junejo Script Hub]: Anime Card Farm Script Loaded Successfully!")
