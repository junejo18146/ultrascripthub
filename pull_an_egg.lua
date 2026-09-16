-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - PULL AN EGG (OFFICIAL SCRIPT)
-- Game: Pull an Egg
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- Universal Mobile (Delta / Codex / Fluxus) & PC Compatible
-- UI: Official UI 1 (Ultra Script Hub Classic Matte Dark)
-- ====================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Clean up any previous UI instances safely
for _, name in ipairs({"JunejoHubUI_PullAnEgg", "JunejoPullAnEggUI", "UltraScriptHub_PullAnEgg"}) do
    pcall(function()
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end)
end

-- Global Configuration & State
local Toggles = {
    RemoveGuard = false,
    AutoPullEgg = false,
    AutoTrain = false,
    AutoRebirth = false,
    AutoHatch = false,
    AutoClaimGifts = false,
    WalkSpeedBoost = false,
    InfiniteJump = false,
    Noclip = false,
    AntiAFK = true
}

local CustomSpeedValue = 50
local SavedBaseCFrame = nil

-- Record initial position on spawn as fallback base
pcall(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        SavedBaseCFrame = hrp.CFrame
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    pcall(function()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not SavedBaseCFrame and hrp then
            SavedBaseCFrame = hrp.CFrame
        end
    end)
end)

-- Safe Alive & Character Helper
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- Speed Update Helper
local function UpdateCharacterSpeed()
    pcall(function()
        if isAlive() then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if Toggles.WalkSpeedBoost then
                    hum.WalkSpeed = CustomSpeedValue
                else
                    hum.WalkSpeed = 16
                end
            end
        end
    end)
end

-- Anti-AFK Engine (Always active in background)
if getconnections then
    for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
        if conn.Disable then conn:Disable() elseif conn.Disconnect then conn:Disconnect() end
    end
else
    LocalPlayer.Idled:Connect(function()
        if VirtualUser then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero)
            end)
        end
    end)
end

-- Safe Button Clicker Utility
local function TriggerGuiButton(btn)
    if not btn or not btn:IsA("GuiButton") then return end
    pcall(function()
        if getconnections then
            for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
            for _, c in ipairs(getconnections(btn.MouseButton1Down)) do c:Fire() end
            for _, c in ipairs(getconnections(btn.Activated)) do c:Fire() end
        end
        if firesignal then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.MouseButton1Down)
            firesignal(btn.Activated)
        end
    end)
end

-- Safe ProximityPrompt Trigger
local function TriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = math.huge
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt, 1)
            fireproximityprompt(prompt)
        end
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            task.wait(0.01)
            prompt:InputHoldEnd()
        end
    end)
end

-- Safe Touch Interest Trigger
local function TriggerTouch(part, targetPart)
    if not part or not targetPart then return end
    pcall(function()
        if firetouchinterest then
            firetouchinterest(part, targetPart, 0)
            firetouchinterest(part, targetPart, 1)
            firetouchinterest(targetPart, part, 0)
            firetouchinterest(targetPart, part, 1)
        end
    end)
end

-- Screen Notification Helper
local function ShowNotification(title, message)
    pcall(function()
        local sg = CoreGui:FindFirstChild("JunejoHubUI_PullAnEgg") or (LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("JunejoHubUI_PullAnEgg"))
        if not sg then return end

        local oldNotify = sg:FindFirstChild("JunejoToast")
        if oldNotify then oldNotify:Destroy() end

        local Toast = Instance.new("Frame")
        Toast.Name = "JunejoToast"
        Toast.Size = UDim2.new(0, 240, 0, 38)
        Toast.Position = UDim2.new(0.5, -120, 0.1, 0)
        Toast.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        Toast.BorderSizePixel = 0
        Toast.ZIndex = 999
        Toast.Parent = sg

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 8)
        ToastCorner.Parent = Toast

        local ToastStroke = Instance.new("UIStroke")
        ToastStroke.Color = Color3.fromRGB(50, 50, 65)
        ToastStroke.Thickness = 1
        ToastStroke.Parent = Toast

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -12, 0, 15)
        TitleLbl.Position = UDim2.new(0, 8, 0, 3)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
        TitleLbl.TextSize = 10
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.ZIndex = 1000
        TitleLbl.Parent = Toast

        local MsgLbl = Instance.new("TextLabel")
        MsgLbl.Size = UDim2.new(1, -12, 0, 15)
        MsgLbl.Position = UDim2.new(0, 8, 0, 18)
        MsgLbl.BackgroundTransparency = 1
        MsgLbl.Text = message
        MsgLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
        MsgLbl.TextSize = 9
        MsgLbl.Font = Enum.Font.GothamMedium
        MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
        MsgLbl.ZIndex = 1000
        MsgLbl.Parent = Toast

        task.delay(2.5, function()
            if Toast and Toast.Parent then
                local tween = TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                tween:Play()
                TitleLbl.TextTransparency = 1
                MsgLbl.TextTransparency = 1
                ToastStroke.Transparency = 1
                task.wait(0.3)
                if Toast and Toast.Parent then Toast:Destroy() end
            end
        end)
    end)
end

-- ====================================================
-- BASE / GOAL / DROP ZONE LOCATOR
-- ====================================================
local function GetPlayerBaseCFrame()
    local baseCFrame = nil
    pcall(function()
        local myName = LocalPlayer.Name
        local myUserId = LocalPlayer.UserId
        
        -- 1. Search for owned Plots/Bases/Nests in Workspace
        for _, containerName in ipairs({"Plots", "Bases", "Houses", "Islands", "Nests", "Zones", "Spawns", "DropZones", "Delivery", "SafeZones"}) do
            local container = Workspace:FindFirstChild(containerName)
            if container then
                for _, plot in ipairs(container:GetChildren()) do
                    local isMine = false
                    if string.find(string.lower(plot.Name), string.lower(myName)) then
                        isMine = true
                    end
                    local ownerVal = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player") or plot:FindFirstChild("UserId")
                    if ownerVal then
                        if ownerVal.Value == LocalPlayer or ownerVal.Value == myName or ownerVal.Value == myUserId then
                            isMine = true
                        end
                    end
                    if isMine then
                        local dropPart = plot:FindFirstChild("Deposit") or plot:FindFirstChild("Drop") or plot:FindFirstChild("Pad") or plot:FindFirstChild("Nest") or plot:FindFirstChild("Collector") or plot:FindFirstChild("Spawn") or plot:FindFirstChild("SpawnLocation") or plot.PrimaryPart or plot:FindFirstChildOfClass("BasePart")
                        if dropPart and dropPart:IsA("BasePart") then
                            baseCFrame = dropPart.CFrame + Vector3.new(0, 3, 0)
                            return
                        elseif plot:IsA("Model") and plot.PrimaryPart then
                            baseCFrame = plot.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                            return
                        end
                    end
                end
            end
        end

        -- 2. Search anywhere in Workspace for a base named after player
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Folder") then
                local oName = string.lower(obj.Name)
                if string.find(oName, "base") or string.find(oName, "plot") or string.find(oName, "island") or string.find(oName, "nest") then
                    local owner = obj:FindFirstChild("Owner") or obj:FindFirstChild("Player")
                    if (owner and (owner.Value == LocalPlayer or owner.Value == myName)) or string.find(oName, string.lower(myName)) then
                        local part = obj:FindFirstChild("Drop") or obj:FindFirstChild("Deposit") or obj:FindFirstChild("Pad") or obj:FindFirstChild("Nest") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                        if part and part:IsA("BasePart") then
                            baseCFrame = part.CFrame + Vector3.new(0, 3, 0)
                            return
                        end
                    end
                end
            end
        end

        -- 3. Check for SpawnLocations
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("SpawnLocation") and obj.Enabled then
                baseCFrame = obj.CFrame + Vector3.new(0, 3, 0)
                return
            end
        end

        -- 4. Check for Safe Zone / Finish / Delivery parts
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = string.lower(obj.Name)
                if string.find(n, "deposit") or string.find(n, "dropzone") or string.find(n, "delivery") or string.find(n, "finish") or string.find(n, "goal") or string.find(n, "safezone") then
                    baseCFrame = obj.CFrame + Vector3.new(0, 3, 0)
                    return
                end
            end
        end
    end)

    return baseCFrame or SavedBaseCFrame or (isAlive() and LocalPlayer.Character.HumanoidRootPart.CFrame)
end

-- ====================================================
-- EGG TARGET LOCATOR
-- ====================================================
local function GetTargetEggs()
    local eggs = {}
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj ~= char and not obj:IsDescendantOf(char) then
                local isEgg = false
                local targetPart = nil
                local targetPrompt = nil
                local targetCD = nil

                local oName = string.lower(obj.Name)
                local pName = obj.Parent and string.lower(obj.Parent.Name) or ""

                -- Avoid player characters and NPCs
                if not Players:GetPlayerFromCharacter(obj) and not string.find(pName, "character") and not string.find(pName, "player") then
                    if obj:IsA("Model") then
                        if (string.find(oName, "egg") or string.find(oName, "pull") or string.find(oName, "tether") or string.find(oName, "lucky") or string.find(oName, "brainrot")) and not string.find(oName, "hatch") and not string.find(oName, "shop") and not string.find(oName, "gui") then
                            targetPart = obj.PrimaryPart or obj:FindFirstChild("Handle") or obj:FindFirstChild("Egg") or obj:FindFirstChild("Main") or obj:FindFirstChildOfClass("BasePart")
                            if targetPart then
                                targetPrompt = obj:FindFirstChildOfClass("ProximityPrompt", true)
                                targetCD = obj:FindFirstChildOfClass("ClickDetector", true)
                                isEgg = true
                            end
                        end
                    elseif obj:IsA("BasePart") and obj.Parent and not obj.Parent:IsA("Model") then
                        if (string.find(oName, "egg") or string.find(oName, "pullegg") or string.find(oName, "tether")) and not string.find(oName, "hatch") and not string.find(oName, "shop") then
                            targetPart = obj
                            targetPrompt = obj:FindFirstChildOfClass("ProximityPrompt")
                            targetCD = obj:FindFirstChildOfClass("ClickDetector")
                            isEgg = true
                        end
                    elseif obj:IsA("ProximityPrompt") and obj.Enabled then
                        local act = string.lower(obj.ActionText or "")
                        local objT = string.lower(obj.ObjectText or "")
                        if (string.find(act, "pull") or string.find(act, "steal") or string.find(act, "grab") or string.find(act, "take") or string.find(act, "carry") or string.find(objT, "egg") or string.find(act, "egg")) and not string.find(act, "hatch") and not string.find(act, "buy") and not string.find(act, "open") then
                            targetPrompt = obj
                            targetPart = obj.Parent:IsA("BasePart") and obj.Parent or (obj.Parent:IsA("Model") and (obj.Parent.PrimaryPart or obj.Parent:FindFirstChildOfClass("BasePart")))
                            isEgg = true
                        end
                    end

                    if isEgg and targetPart then
                        local dist = (targetPart.Position - hrp.Position).Magnitude
                        table.insert(eggs, {
                            Model = obj:IsA("Model") and obj or obj.Parent,
                            Part = targetPart,
                            Prompt = targetPrompt,
                            ClickDetector = targetCD,
                            Distance = dist
                        })
                    end
                end
            end
        end

        table.sort(eggs, function(a, b) return a.Distance < b.Distance end)
    end)
    return eggs
end

-- ====================================================
-- AUTO-CLOSE UNWANTED SPIN WHEEL / INTRUSIVE POPUPS
-- ====================================================
task.spawn(function()
    while true do
        pcall(function()
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            if pgui then
                for _, gui in ipairs(pgui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "JunejoHubUI_PullAnEgg" then
                        local gName = string.lower(gui.Name)
                        if string.find(gName, "wheel") or string.find(gName, "spin") or string.find(gName, "roulette") then
                            for _, btn in ipairs(gui:GetDescendants()) do
                                if btn:IsA("GuiButton") then
                                    local bName = string.lower(btn.Name)
                                    local bText = string.lower(btn.Text or "")
                                    if string.find(bName, "close") or string.find(bName, "exit") or string.find(bName, "x") or bText == "x" or string.find(bText, "close") then
                                        TriggerGuiButton(btn)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

-- ====================================================
-- FEATURE 1: REMOVE GUARD
-- ====================================================
local function applyRemoveGuard()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local name = string.lower(obj.Name)
                if string.find(name, "guard") or string.find(name, "security") or string.find(name, "police") or string.find(name, "boss") or string.find(name, "enemy") or string.find(name, "npc") then
                    if obj ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(obj) then
                        obj:Destroy()
                    end
                end
            elseif obj:IsA("BasePart") then
                local name = string.lower(obj.Name)
                if string.find(name, "guard") or string.find(name, "laser") or string.find(name, "barrier") or string.find(name, "kill") or string.find(name, "damage") then
                    obj.CanCollide = false
                    obj.CanTouch = false
                    obj.Transparency = 0.8
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        if Toggles.RemoveGuard then
            applyRemoveGuard()
        end
        task.wait(1.5)
    end
end)

-- ====================================================
-- FEATURE 2: AUTO PULL EGG & BRING TO BASE ENGINE
-- ====================================================
task.spawn(function()
    while true do
        if Toggles.AutoPullEgg and isAlive() then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then return end

                local baseCFrame = GetPlayerBaseCFrame()
                local eggList = GetTargetEggs()

                if #eggList > 0 then
                    local target = eggList[1]
                    local eggPart = target.Part
                    local eggPrompt = target.Prompt
                    local eggCD = target.ClickDetector
                    local eggModel = target.Model

                    -- 1. Move/Teleport to Egg
                    if (hrp.Position - eggPart.Position).Magnitude > 6 then
                        hrp.CFrame = eggPart.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.12)
                    end

                    -- 2. Equip Pull / Rope Tool
                    local tool = char:FindFirstChildOfClass("Tool")
                    if not tool and LocalPlayer:FindFirstChild("Backpack") then
                        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                            if item:IsA("Tool") then
                                item.Parent = char
                                tool = item
                                break
                            end
                        end
                    end
                    if tool then tool:Activate() end

                    -- 3. Grab / Interact with the Egg
                    if eggPrompt and eggPrompt.Parent and eggPrompt.Enabled then
                        TriggerPrompt(eggPrompt)
                    end
                    if eggCD and eggCD.Parent and fireclickdetector then
                        fireclickdetector(eggCD)
                    end
                    TriggerTouch(hrp, eggPart)

                    -- 4. Fire Egg Pull specific Remotes (Safe - no spin wheel remotes)
                    for _, rootService in ipairs({ReplicatedStorage, Workspace}) do
                        for _, remote in ipairs(rootService:GetDescendants()) do
                            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                local rName = string.lower(remote.Name)
                                if (string.find(rName, "pull") or string.find(rName, "grab") or string.find(rName, "steal") or string.find(rName, "take")) and not string.find(rName, "spin") and not string.find(rName, "wheel") and not string.find(rName, "gift") and not string.find(rName, "shop") then
                                    if remote:IsA("RemoteEvent") then
                                        remote:FireServer(eggModel or eggPart)
                                        remote:FireServer("Pull", eggModel or eggPart)
                                        remote:FireServer(1)
                                        remote:FireServer()
                                    elseif remote:IsA("RemoteFunction") then
                                        task.spawn(function()
                                            pcall(function() remote:InvokeServer(eggModel or eggPart) end)
                                            pcall(function() remote:InvokeServer("Pull") end)
                                        end)
                                    end
                                end
                            end
                        end
                    end

                    task.wait(0.15)

                    -- 5. Pull & Transport Egg to Base
                    if baseCFrame then
                        hrp.CFrame = baseCFrame
                        task.wait(0.2)
                        
                        -- Trigger deposit touch & prompt at base
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and (obj.Position - hrp.Position).Magnitude <= 15 then
                                local n = string.lower(obj.Name)
                                if string.find(n, "deposit") or string.find(n, "drop") or string.find(n, "pad") or string.find(n, "nest") or string.find(n, "collector") or string.find(n, "base") or string.find(n, "claim") then
                                    TriggerTouch(hrp, obj)
                                    local p = obj:FindFirstChildOfClass("ProximityPrompt")
                                    if p then TriggerPrompt(p) end
                                end
                            end
                        end

                        if tool then tool:Activate() end
                    end
                else
                    -- Stand at base and pull / activate tool
                    if baseCFrame and (hrp.Position - baseCFrame.Position).Magnitude > 10 then
                        hrp.CFrame = baseCFrame
                    end
                    
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end)
        end
        task.wait(0.25)
    end
end)

-- ====================================================
-- FEATURE 3: AUTO TRAIN / AUTO CLICK
-- ====================================================
task.spawn(function()
    while true do
        if Toggles.AutoTrain and isAlive() then
            pcall(function()
                local char = LocalPlayer.Character
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool and LocalPlayer:FindFirstChild("Backpack") then
                    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if item:IsA("Tool") then
                            item.Parent = char
                            tool = item
                            break
                        end
                    end
                end

                if tool then
                    tool:Activate()
                end

                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local rName = string.lower(remote.Name)
                        if (string.find(rName, "train") or string.find(rName, "strength") or string.find(rName, "power") or string.find(rName, "workout") or string.find(rName, "lift")) and not string.find(rName, "wheel") and not string.find(rName, "spin") then
                            remote:FireServer()
                            remote:FireServer(1)
                        end
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- ====================================================
-- FEATURE 4: AUTO REBIRTH (SUPERCHARGED 4-LAYER ENGINE)
-- ====================================================
task.spawn(function()
    while true do
        if Toggles.AutoRebirth and isAlive() then
            pcall(function()
                -- Layer 1: PlayerGui Button Sweeper
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui then
                    for _, desc in ipairs(pgui:GetDescendants()) do
                        if desc:IsA("GuiButton") then
                            local bText = string.lower(desc.Text or "")
                            local bName = string.lower(desc.Name or "")
                            local pName = desc.Parent and string.lower(desc.Parent.Name or "") or ""
                            
                            if (string.find(bText, "rebirth") or string.find(bName, "rebirth") or string.find(pName, "rebirth") or 
                                string.find(bText, "prestige") or string.find(bName, "prestige") or string.find(pName, "prestige") or
                                string.find(bText, "ascend") or string.find(bName, "ascend") or string.find(pName, "ascend")) and not string.find(bName, "spin") and not string.find(bName, "wheel") then
                                TriggerGuiButton(desc)
                            end

                            if (string.find(pName, "rebirth") or string.find(pName, "confirm") or string.find(pName, "dialog") or string.find(pName, "popup")) and not string.find(pName, "wheel") then
                                if string.find(bText, "yes") or string.find(bText, "confirm") or string.find(bText, "buy") or string.find(bText, "ok") or string.find(bText, "accept") or
                                   string.find(bName, "yes") or string.find(bName, "confirm") or string.find(bName, "buy") or string.find(bName, "ok") then
                                    TriggerGuiButton(desc)
                                end
                            end
                        end
                    end
                end

                -- Layer 2: Workspace Rebirth Touch Pads & Prompts
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local oName = string.lower(obj.Name)
                    if string.find(oName, "rebirth") or string.find(oName, "prestige") or string.find(oName, "ascend") then
                        if obj:IsA("ProximityPrompt") then
                            TriggerPrompt(obj)
                        elseif obj:IsA("ClickDetector") then
                            fireclickdetector(obj)
                        elseif obj:IsA("BasePart") and hrp then
                            TriggerTouch(hrp, obj)
                        end
                    end
                end

                -- Layer 3: RemoteEvents in ReplicatedStorage
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local rName = string.lower(remote.Name)
                        if (string.find(rName, "rebirth") or string.find(rName, "prestige") or string.find(rName, "ascend") or string.find(rName, "rank") or string.find(rName, "reset")) and not string.find(rName, "wheel") and not string.find(rName, "spin") then
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer()
                                remote:FireServer(1)
                                remote:FireServer("1")
                                remote:FireServer(true)
                                remote:FireServer({})
                                remote:FireServer("Rebirth")
                            elseif remote:IsA("RemoteFunction") then
                                task.spawn(function()
                                    pcall(function() remote:InvokeServer() end)
                                    pcall(function() remote:InvokeServer(1) end)
                                    pcall(function() remote:InvokeServer("1") end)
                                    pcall(function() remote:InvokeServer(true) end)
                                end)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.8)
    end
end)

-- ====================================================
-- FEATURE 5: AUTO HATCH / OPEN EGG (DYNAMIC PROXIMITY & REMOTE ENGINE)
-- ====================================================
task.spawn(function()
    while true do
        if Toggles.AutoHatch and isAlive() then
            pcall(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                -- Layer 1: Trigger all nearby Egg ProximityPrompts / ClickDetectors / Touch
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local n = string.lower(obj.Name)
                    if (string.find(n, "hatch") or string.find(n, "eggstand") or string.find(n, "shop")) and not string.find(n, "wheel") and not string.find(n, "spin") then
                        if obj:IsA("ProximityPrompt") then
                            TriggerPrompt(obj)
                        elseif obj:IsA("ClickDetector") then
                            fireclickdetector(obj)
                        elseif obj:IsA("BasePart") and hrp and (obj.Position - hrp.Position).Magnitude <= 35 then
                            TriggerTouch(hrp, obj)
                        end
                    end
                end

                -- Layer 2: PlayerGui Hatch Buttons
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui then
                    for _, desc in ipairs(pgui:GetDescendants()) do
                        if desc:IsA("GuiButton") then
                            local bText = string.lower(desc.Text or "")
                            local bName = string.lower(desc.Name or "")
                            local pName = desc.Parent and string.lower(desc.Parent.Name or "") or ""
                            if (string.find(pName, "egg") or string.find(pName, "hatch") or string.find(pName, "shop")) and not string.find(pName, "wheel") and not string.find(pName, "spin") then
                                if string.find(bText, "open") or string.find(bText, "hatch") or string.find(bText, "buy") or string.find(bText, "1") or string.find(bName, "open") or string.find(bName, "hatch") or string.find(bName, "buy") or string.find(bName, "single") then
                                    TriggerGuiButton(desc)
                                end
                            end
                        end
                    end
                end

                -- Layer 3: RemoteEvents in ReplicatedStorage
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local rName = string.lower(remote.Name)
                        if (string.find(rName, "openegg") or string.find(rName, "hatchegg") or string.find(rName, "buyegg") or string.find(rName, "eggopen") or string.find(rName, "hatch")) and not string.find(rName, "wheel") and not string.find(rName, "spin") then
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer("Egg1", 1)
                                remote:FireServer("Egg1", "Single")
                                remote:FireServer("Egg", 1)
                                remote:FireServer(1)
                                remote:FireServer("1")
                                remote:FireServer(true)
                                remote:FireServer()
                            elseif remote:IsA("RemoteFunction") then
                                task.spawn(function()
                                    pcall(function() remote:InvokeServer("Egg1", 1) end)
                                    pcall(function() remote:InvokeServer(1) end)
                                end)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.3)
    end
end)

-- ====================================================
-- FEATURE 6: AUTO CLAIM FREE GIFTS
-- ====================================================
task.spawn(function()
    while true do
        if Toggles.AutoClaimGifts and isAlive() then
            pcall(function()
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "gift") or string.find(rName, "daily") or string.find(rName, "reward") or string.find(rName, "free") then
                            for i = 1, 12 do
                                if remote:IsA("RemoteEvent") then
                                    remote:FireServer(i)
                                    remote:FireServer(tostring(i))
                                else
                                    task.spawn(function()
                                        pcall(function() remote:InvokeServer(i) end)
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(5)
    end
end)

-- ====================================================
-- FEATURE 7: TELEPORT TO ZONES / SAFE ZONES
-- ====================================================
local function teleportToZone()
    pcall(function()
        if not isAlive() then return end
        local hrp = LocalPlayer.Character.HumanoidRootPart

        local targetCFrame = nil
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local oName = string.lower(obj.Name)
                if string.find(oName, "zone") or string.find(oName, "world") or string.find(oName, "eggarea") or string.find(oName, "stage") or string.find(oName, "safe") then
                    if obj:IsA("BasePart") then
                        targetCFrame = obj.CFrame + Vector3.new(0, 4, 0)
                    elseif obj:IsA("Model") and obj.PrimaryPart then
                        targetCFrame = obj.PrimaryPart.CFrame + Vector3.new(0, 4, 0)
                    end
                    if targetCFrame then break end
                end
            end
        end

        if targetCFrame then
            hrp.CFrame = targetCFrame
            ShowNotification("Teleport", "Teleported to Safe Zone!")
        else
            hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 50
            ShowNotification("Teleport", "Teleported forward!")
        end
    end)
end

-- ====================================================
-- FEATURE 8: WALKSPEED BOOST (+ / - CONTROLLER)
-- ====================================================
RunService.RenderStepped:Connect(function()
    if Toggles.WalkSpeedBoost and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= CustomSpeedValue then
            hum.WalkSpeed = CustomSpeedValue
        end
    end
end)

-- ====================================================
-- FEATURE 9: INFINITE JUMP
-- ====================================================
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and isAlive() then
        pcall(function()
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- ====================================================
-- FEATURE 10: NOCLIP
-- ====================================================
RunService.Stepped:Connect(function()
    if Toggles.Noclip and isAlive() then
        pcall(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- ====================================================
-- OFFICIAL JUNEJO UI 1 (ULTRA SCRIPT HUB CLASSIC MATTE DARK)
-- Form Factor: 280px × 260px | CornerRadius: 10px | Matte Black #0F0F11
-- Mandatory Footer: ULTRA SCRIPT HUB | Made by Junejo
-- ====================================================

local guiParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_PullAnEgg"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 260)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -130)
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
            if input.UserInputState == Enum.UserInputState.End then isDragging = false end
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
TitleLabel.Text = "PULL AN EGG"
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

-- Content Scroll Frame
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

-- Top Action Button (TELEPORT TO SAFE ZONE)
local ActionBtn = Instance.new("TextButton")
ActionBtn.Name = "ActionBtn_Teleport"
ActionBtn.Size = UDim2.new(1, 0, 0, 26)
ActionBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
ActionBtn.BorderSizePixel = 0
ActionBtn.Text = "TELEPORT TO SAFE ZONE"
ActionBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
ActionBtn.TextSize = 11
ActionBtn.Font = Enum.Font.GothamBold
ActionBtn.Parent = ContentScroll

local ActionCorner = Instance.new("UICorner")
ActionCorner.CornerRadius = UDim.new(0, 6)
ActionCorner.Parent = ActionBtn

local ActionStroke = Instance.new("UIStroke")
ActionStroke.Color = Color3.fromRGB(35, 35, 44)
ActionStroke.Thickness = 1
ActionStroke.Parent = ActionBtn

ActionBtn.MouseButton1Click:Connect(function()
    teleportToZone()
end)

-- Helper: Add Classic Checkbox Toggle Row
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

-- ====================================================
-- ADDING ALL REQUESTED FEATURES (EXACT ORDER & STYLE)
-- ====================================================

-- 1. Remove Guard
AddToggleRow("Remove Guard", "RemoveGuard", function(state)
    if state then
        applyRemoveGuard()
        ShowNotification("Guard", "Security Guards Removed!")
    end
end)

-- 2. Auto Pull Egg
AddToggleRow("Auto Pull Egg", "AutoPullEgg", function(state)
    ShowNotification("Auto Pull", state and "Auto Pull to Base Started!" or "Auto Pull Stopped")
end)

-- 3. Auto Train / Click
AddToggleRow("Auto Train / Click", "AutoTrain", function(state)
    ShowNotification("Auto Train", state and "Training Farm Started!" or "Training Stopped")
end)

-- 4. Auto Rebirth
AddToggleRow("Auto Rebirth", "AutoRebirth", function(state)
    ShowNotification("Auto Rebirth", state and "Auto Rebirth Active!" or "Auto Rebirth Stopped")
end)

-- 5. Auto Hatch / Open Egg
AddToggleRow("Auto Hatch / Open Egg", "AutoHatch", function(state)
    ShowNotification("Auto Hatch", state and "Egg Hatching Active!" or "Hatching Stopped")
end)

-- 6. Auto Claim Free Gifts
AddToggleRow("Auto Claim Free Gifts", "AutoClaimGifts", function(state)
    ShowNotification("Gifts", state and "Auto Claim Gifts Active!" or "Gifts Stopped")
end)

-- 7. WalkSpeed Integrated Row (with Checkbox + Stepper Pill as shown in screenshot)
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, 0, 0, 24)
SpeedRow.BackgroundTransparency = 1
SpeedRow.Parent = ContentScroll

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.42, 0, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed"
SpeedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedRow

-- Checkbox for WalkSpeed
local SpeedCheckBox = Instance.new("Frame")
SpeedCheckBox.Size = UDim2.new(0, 18, 0, 18)
SpeedCheckBox.Position = UDim2.new(0.46, 0, 0.5, -9)
SpeedCheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
SpeedCheckBox.BorderSizePixel = 0
SpeedCheckBox.Parent = SpeedRow

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

local SpeedMarkCorner = Instance.new("UICorner")
SpeedMarkCorner.CornerRadius = UDim.new(0, 2)
SpeedMarkCorner.Parent = SpeedCheckMark

local SpeedToggleBtn = Instance.new("TextButton")
SpeedToggleBtn.Size = UDim2.new(1, 0, 1, 0)
SpeedToggleBtn.BackgroundTransparency = 1
SpeedToggleBtn.Text = ""
SpeedToggleBtn.ZIndex = 5
SpeedToggleBtn.Parent = SpeedCheckBox

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
    UpdateCharacterSpeed()
end)

-- Stepper Pill Frame (-  50  +)
local SpeedControlFrame = Instance.new("Frame")
SpeedControlFrame.Size = UDim2.new(0.44, 0, 1, 0)
SpeedControlFrame.Position = UDim2.new(0.56, 0, 0, 0)
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
    UpdateCharacterSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 10)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

-- 8. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump")

-- 9. Noclip
AddToggleRow("Noclip", "Noclip", function(state)
    if not state and isAlive() then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end)

-- Mandatory Footer (ULTRA SCRIPT HUB | Made by Junejo)
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
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

ShowNotification("Ultra Script Hub", "Pull an Egg Script Loaded!")
