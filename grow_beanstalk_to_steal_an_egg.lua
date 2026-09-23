-- ==============================================================================
-- JUNEJO ULTRA SCRIPT HUB - GROW BEANSTALK TO STEAL AN EGG
-- Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- UI Framework: UI 1 (Official Ultra Script Hub Classic Matte Dark)
-- Universal Mobile & PC Delta / Codex / Fluxus / PC Optimized
-- ==============================================================================

local GameName = "GROW BEANSTALK TO STEAL AN EGG"

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
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera

-- Destroy existing UI if re-executed
for _, guiName in ipairs({"JunejoHubUI_GrowBeanstalk", "JunejoHubUI"}) do
    pcall(function()
        if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(guiName) then
            LocalPlayer.PlayerGui[guiName]:Destroy()
        end
    end)
end

-- Configuration & State
local Toggles = {
    InfiniteCash = false,
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
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
end

-- Fast ProximityPrompt 0s Hold Bypass
task.spawn(function()
    local function OptimizePrompt(prompt)
        if prompt and prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 99999
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
    local possibleContainers = {
        Workspace:FindFirstChild("Plots"),
        Workspace:FindFirstChild("Bases"),
        Workspace:FindFirstChild("Tycoons"),
        Workspace:FindFirstChild("Islands"),
        Workspace:FindFirstChild("Players"),
        Workspace:FindFirstChild("Map"),
        Workspace
    }
    
    for _, container in ipairs(possibleContainers) do
        if container then
            for _, plot in ipairs(container:GetChildren()) do
                if plot:IsA("Model") or plot:IsA("Folder") then
                    local ownerVal = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player") or plot:FindFirstChild("UserId") or plot:FindFirstChild("OwnerName")
                    if ownerVal and (ownerVal.Value == LocalPlayer or ownerVal.Value == LocalPlayer.Name or ownerVal.Value == LocalPlayer.UserId or tostring(ownerVal.Value) == tostring(LocalPlayer.UserId)) then
                        return plot
                    end
                    local lowName = string.lower(plot.Name)
                    if string.find(lowName, string.lower(LocalPlayer.Name)) or string.find(lowName, tostring(LocalPlayer.UserId)) then
                        return plot
                    end
                    local sign = plot:FindFirstChild("Sign", true) or plot:FindFirstChild("OwnerSign", true)
                    if sign then
                        for _, txt in ipairs(sign:GetDescendants()) do
                            if txt:IsA("TextLabel") and (string.find(string.lower(txt.Text), string.lower(LocalPlayer.Name)) or string.find(string.lower(txt.Text), string.lower(LocalPlayer.DisplayName))) then
                                return plot
                            end
                        end
                    end
                end
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

-- Universal Interaction Handlers
local function TriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt)
        else
            prompt.HoldDuration = 0
            prompt:InputHoldBegin()
            task.wait(0.04)
            prompt:InputHoldEnd()
        end
    end)
end

local function TriggerClickDetector(cd)
    if not cd or not cd:IsA("ClickDetector") then return end
    pcall(function()
        if fireclickdetector then
            fireclickdetector(cd)
        end
    end)
end

local function SafeTouch(targetPart)
    local root = GetRootPart()
    if not root or not targetPart or not targetPart:IsA("BasePart") then return end
    pcall(function()
        if firetouchinterest then
            firetouchinterest(root, targetPart, 0)
            task.wait(0.02)
            firetouchinterest(root, targetPart, 1)
        end
    end)
end

local function ClickGuiButton(btn)
    if not btn then return end
    pcall(function()
        for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
            conn:Fire()
        end
        for _, conn in pairs(getconnections(btn.Activated)) do
            conn:Fire()
        end
    end)
end

-- Universal Remote Fire Helper
local function FireRemotesByKeywords(keywords, argsList)
    pcall(function()
        for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
            if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
                local lname = string.lower(descendant.Name)
                for _, kw in ipairs(keywords) do
                    if string.find(lname, kw) then
                        if descendant:IsA("RemoteEvent") then
                            descendant:FireServer()
                            if argsList then
                                for _, arg in ipairs(argsList) do
                                    descendant:FireServer(arg)
                                    descendant:FireServer(unpack(type(arg) == "table" and arg or {arg}))
                                end
                            end
                        elseif descendant:IsA("RemoteFunction") then
                            descendant:InvokeServer()
                            if argsList then
                                for _, arg in ipairs(argsList) do
                                    descendant:InvokeServer(arg)
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

-- Instant Cash Add Function
local function AddCashInstant()
    local myPlot = FindMyPlot()
    if myPlot then
        for _, obj in ipairs(myPlot:GetDescendants()) do
            local name = string.lower(obj.Name)
            if string.find(name, "collector") or string.find(name, "cash") or string.find(name, "money") or string.find(name, "bank") or string.find(name, "drop") or string.find(name, "earnings") or string.find(name, "atm") or string.find(name, "safe") then
                if obj:IsA("ProximityPrompt") then TriggerPrompt(obj)
                elseif obj:IsA("ClickDetector") then TriggerClickDetector(obj)
                elseif obj:IsA("BasePart") then SafeTouch(obj) end
            end
        end
    end
    FireRemotesByKeywords(
        {"collect", "claimcash", "withdraw", "collectcash", "getmoney", "bank", "addcash", "givecash", "claimincome", "petrevenue", "claimall", "cashreward"},
        {999999999, 1000000, 50000, true, "Max", "Cash", "All"}
    )
    pcall(function()
        local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Data") or LocalPlayer:FindFirstChild("Values") or LocalPlayer
        if stats then
            for _, val in ipairs(stats:GetChildren()) do
                local vName = string.lower(val.Name)
                if string.find(vName, "cash") or string.find(vName, "money") or string.find(vName, "coin") or string.find(vName, "gold") then
                    if val:IsA("NumberValue") or val:IsA("IntValue") then
                        val.Value = 999999999999
                    elseif val:IsA("StringValue") then
                        val.Value = "$999.9B"
                    end
                end
            end
        end
    end)
end

-- 1. INFINITE CASH (+999B) CONTINUOUS ENGINE
task.spawn(function()
    while true do
        task.wait(0.12)
        if Toggles.InfiniteCash then
            AddCashInstant()
        end
    end
end)

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

    local targetPos = targetPart.Position + Vector3.new(0, 3, 0)
    root.AssemblyLinearVelocity = Vector3.zero
    root.CFrame = CFrame.new(targetPos)
    task.wait(0.12)
    
    if eggData.Prompt then
        TriggerPrompt(eggData.Prompt)
    end
    SafeTouch(targetPart)

    FireRemotesByKeywords({"steal", "grabegg", "takeegg"}, {eggData.Instance, eggData.Instance.Name})

    task.wait(0.15)
    
    if returnToBase then
        local basePos = GetBasePosition()
        root.AssemblyLinearVelocity = Vector3.zero
        root.CFrame = CFrame.new(basePos)
        task.wait(0.2)
        
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

-- 2. Auto Steal Egg
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

-- 3. Auto Steal Rare Egg
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

-- 4. Auto Steal Nearest Egg
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

-- 5. Fast Climb on Beanstalk
task.spawn(function()
    while true do
        task.wait(0.04)
        if Toggles.FastClimbBeanstalk then
            local root = GetRootPart()
            local hum = GetHumanoid()
            if root and hum then
                root.AssemblyLinearVelocity = Vector3.new(0, 160, 0)
                root.CFrame = root.CFrame + Vector3.new(0, 5, 0)
                hum:ChangeState(Enum.HumanoidStateType.Freefall)
            end
        end
    end
end)

-- 6. SUPER BEANSTALK GROW ENGINE
task.spawn(function()
    while true do
        task.wait(0.15)
        if Toggles.InfiniteBeanstalk then
            local myPlot = FindMyPlot()
            
            FireRemotesByKeywords(
                {"grow", "beanstalk", "water", "fertilize", "feed", "upgradebeanstalk", "growth", "plantgrow", "buygrowth"},
                {1, 10, 100, 1000, true, "Beanstalk", "Grow", "Max"}
            )
            
            if myPlot then
                for _, obj in ipairs(myPlot:GetDescendants()) do
                    local name = string.lower(obj.Name)
                    local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
                    local isGrowTarget = string.find(name, "grow") or string.find(name, "beanstalk") or string.find(name, "water") or string.find(name, "feed") or string.find(name, "stalk") or string.find(name, "plant") or string.find(parentName, "grow") or string.find(parentName, "beanstalk")
                    
                    if isGrowTarget then
                        if obj:IsA("ProximityPrompt") then TriggerPrompt(obj)
                        elseif obj:IsA("ClickDetector") then TriggerClickDetector(obj)
                        elseif obj:IsA("BasePart") then SafeTouch(obj) end
                    end
                end
                
                for _, obj in ipairs(myPlot:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local name = string.lower(obj.Name)
                        if string.find(name, "beanstalk") or string.find(name, "stem") or string.find(name, "stalk") or string.find(name, "vine") or string.find(name, "trunk") then
                            pcall(function()
                                obj.Size = Vector3.new(math.max(obj.Size.X, 12), math.max(obj.Size.Y, 2000), math.max(obj.Size.Z, 12))
                                obj.CanCollide = true
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- 7. SUPER TREADMILL UNLOCK & TRAIN ENGINE
task.spawn(function()
    while true do
        task.wait(0.25)
        if Toggles.AutoUnlockTreadmill then
            local myPlot = FindMyPlot()
            
            FireRemotesByKeywords(
                {"treadmill", "unlocktreadmill", "buytreadmill", "upgradespeed", "speedupgrade", "unlockspeed", "buyspeed", "treadmilltier", "train"},
                {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, true, "Max", "Treadmill"}
            )
            
            local searchAreas = {myPlot, Workspace:FindFirstChild("Tycoons"), Workspace:FindFirstChild("Plots")}
            for _, area in ipairs(searchAreas) do
                if area then
                    for _, obj in ipairs(area:GetDescendants()) do
                        local name = string.lower(obj.Name)
                        local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
                        local isTreadmillTarget = string.find(name, "treadmill") or string.find(name, "speed") or string.find(name, "runner") or string.find(name, "track") or string.find(name, "unlock") or string.find(parentName, "treadmill") or string.find(parentName, "speed")
                        
                        if isTreadmillTarget then
                            if obj:IsA("ProximityPrompt") then TriggerPrompt(obj)
                            elseif obj:IsA("ClickDetector") then TriggerClickDetector(obj)
                            elseif obj:IsA("BasePart") then SafeTouch(obj) end
                        end
                    end
                end
            end
            
            pcall(function()
                for _, btn in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                        local text = string.lower(btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or ""))
                        if string.find(text, "treadmill") or string.find(text, "unlock speed") or string.find(text, "buy speed") or string.find(text, "upgrade speed") then
                            ClickGuiButton(btn)
                        end
                    end
                end
            end)
        end
    end
end)

-- 8. Auto Upgrade Base
task.spawn(function()
    while true do
        task.wait(0.3)
        if Toggles.AutoUpgradeBase then
            local myPlot = FindMyPlot()
            if myPlot then
                for _, obj in ipairs(myPlot:GetDescendants()) do
                    local name = string.lower(obj.Name)
                    local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
                    if string.find(name, "upgrade") or string.find(name, "buy") or string.find(name, "button") or string.find(name, "pad") or string.find(parentName, "buttons") or string.find(parentName, "upgrades") then
                        if obj:IsA("ProximityPrompt") then TriggerPrompt(obj)
                        elseif obj:IsA("ClickDetector") then TriggerClickDetector(obj)
                        elseif obj:IsA("BasePart") then SafeTouch(obj) end
                    end
                end
            end
            
            FireRemotesByKeywords({"upgrade", "buybase", "purchase", "tycoonbuy", "buybutton", "plotupgrade"}, {true, 1, "Max"})
        end
    end
end)

-- 9. Auto Hatch Egg
task.spawn(function()
    while true do
        task.wait(0.25)
        if Toggles.AutoHatchEgg then
            local myPlot = FindMyPlot()
            local searchAreas = {myPlot, Workspace}
            for _, area in ipairs(searchAreas) do
                if area then
                    for _, prompt in ipairs(area:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            local text = string.lower(prompt.ObjectText .. " " .. prompt.ActionText .. " " .. prompt.Name)
                            if string.find(text, "hatch") or string.find(text, "open") or string.find(text, "claim") or string.find(text, "crack") or string.find(text, "egg") or string.find(text, "incubator") or string.find(text, "pet") then
                                TriggerPrompt(prompt)
                            end
                        end
                    end
                end
            end
            
            FireRemotesByKeywords(
                {"hatch", "openegg", "crackegg", "claimpet", "placeegg", "egghatch", "open"},
                {1, "1", true, "Common", "Egg", "Basic", "Golden"}
            )
            
            if myPlot then
                for _, obj in ipairs(myPlot:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local name = string.lower(obj.Name)
                        if string.find(name, "hatch") or string.find(name, "incubator") or string.find(name, "nest") or string.find(name, "eggslot") then
                            SafeTouch(obj)
                        end
                    end
                end
            end
            
            pcall(function()
                for _, btn in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                        local text = string.lower(btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or ""))
                        if string.find(text, "hatch") or string.find(text, "claim") or string.find(text, "open") or string.find(text, "skip") then
                            ClickGuiButton(btn)
                        end
                    end
                end
            end)
        end
    end
end)

-- 10. Auto Rebirth
task.spawn(function()
    while true do
        task.wait(0.35)
        if Toggles.AutoRebirth then
            FireRemotesByKeywords(
                {"rebirth", "prestige", "ascend", "dorebirth", "requestrebirth", "rebirthsystem"},
                {1, true, "1"}
            )
            
            local myPlot = FindMyPlot()
            local searchAreas = {myPlot, Workspace}
            for _, area in ipairs(searchAreas) do
                if area then
                    for _, obj in ipairs(area:GetDescendants()) do
                        local name = string.lower(obj.Name)
                        if string.find(name, "rebirth") or string.find(name, "prestige") then
                            if obj:IsA("ProximityPrompt") then TriggerPrompt(obj)
                            elseif obj:IsA("ClickDetector") then TriggerClickDetector(obj)
                            elseif obj:IsA("BasePart") then SafeTouch(obj) end
                        end
                    end
                end
            end
            
            pcall(function()
                for _, btn in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                        local text = string.lower(btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or ""))
                        if string.find(text, "rebirth") or string.find(text, "prestige") or string.find(text, "confirm") then
                            ClickGuiButton(btn)
                        end
                    end
                end
            end)
        end
    end
end)

-- 11. Auto Claim All Rewards
task.spawn(function()
    while true do
        task.wait(1)
        if Toggles.AutoClaimRewards then
            FireRemotesByKeywords(
                {"claim", "reward", "gift", "daily", "spin", "chest", "playtime"},
                {1, "Daily", "Playtime", "Gift1", "Gift2", "Gift3", "Free", true}
            )
            
            for _, obj in ipairs(Workspace:GetDescendants()) do
                local name = string.lower(obj.Name)
                if string.find(name, "reward") or string.find(name, "chest") or string.find(name, "gift") then
                    if obj:IsA("ProximityPrompt") then TriggerPrompt(obj)
                    elseif obj:IsA("ClickDetector") then TriggerClickDetector(obj)
                    elseif obj:IsA("BasePart") then SafeTouch(obj) end
                end
            end
        end
    end
end)

-- Movement Helpers
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

local function StartFlying()
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

-- ==============================================================================
-- JUNEJO OFFICIAL UI 1 - CLASSIC MATTE DARK INTERFACE
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_GrowBeanstalk"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local guiParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = guiParent

-- Main Window Frame (Matte Black Compact Container)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 310)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -155)
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

-- 1. Header Frame
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = GameName
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
    StopFlying()
    ScreenGui:Destroy()
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- 2. Scrollable Content Container
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

-- Helper Function: Action Button (Official Junejo Standard)
local function AddActionButton(text, callback)
    local BtnFrame = Instance.new("Frame")
    BtnFrame.Size = UDim2.new(1, 0, 0, 26)
    BtnFrame.BackgroundTransparency = 1
    BtnFrame.Parent = ContentFrame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = BtnFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(40, 40, 50) }):Play()
        task.delay(0.12, function()
            TweenService:Create(Btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(27, 27, 32) }):Play()
        end)
        if callback then callback() end
    end)
end

-- Helper Function: Flat Toggle Row
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
    Label.Position = UDim2.new(0, 4, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

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

-- Helper Function: Dual Control Stepper Pill Row
local function AddStepperRow(text, toggleKey, valKey, minVal, maxVal, step, onToggleCallback, onChangeCallback)
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

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -28, 1, 0)
    Label.Position = UDim2.new(0, 4, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleBtn

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
    CheckMark.BackgroundTransparency = Toggles[toggleKey] and 0 or 1
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

    local ValDisplay = Instance.new("TextLabel")
    ValDisplay.Size = UDim2.new(1, -44, 1, 0)
    ValDisplay.Position = UDim2.new(0, 22, 0, 0)
    ValDisplay.BackgroundTransparency = 1
    ValDisplay.Text = tostring(Sliders[valKey])
    ValDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValDisplay.TextSize = 11
    ValDisplay.Font = Enum.Font.GothamBold
    ValDisplay.Parent = ControlFrame

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
        Toggles[toggleKey] = not Toggles[toggleKey]
        CheckMark.BackgroundTransparency = Toggles[toggleKey] and 0 or 1
        if onToggleCallback then onToggleCallback(Toggles[toggleKey]) end
    end)

    MinusBtn.MouseButton1Click:Connect(function()
        Sliders[valKey] = math.max(minVal, Sliders[valKey] - step)
        ValDisplay.Text = tostring(Sliders[valKey])
        if onChangeCallback then onChangeCallback(Sliders[valKey]) end
    end)

    PlusBtn.MouseButton1Click:Connect(function()
        Sliders[valKey] = math.min(maxVal, Sliders[valKey] + step)
        ValDisplay.Text = tostring(Sliders[valKey])
        if onChangeCallback then onChangeCallback(Sliders[valKey]) end
    end)
end

-- ==============================================================================
-- POPULATE FEATURES
-- ==============================================================================

-- 1. Action Button: Instant Cash Boost
AddActionButton("⚡ Add +1B Cash Now", function()
    AddCashInstant()
end)

-- 2. Toggles List
AddToggleRow("Infinite Cash (+999B)", "InfiniteCash")
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

-- 3. Stepper Rows (Speed, Jump, Fly)
AddStepperRow("WalkSpeed", "WalkSpeedBoost", "WalkSpeed", 16, 300, 15, function(enabled)
    UpdateWalkSpeed()
end, function(val)
    UpdateWalkSpeed()
end)

AddStepperRow("Infinite Jump", "InfiniteJump", "JumpPower", 50, 300, 20, nil, nil)

AddStepperRow("Fly Mode", "FlyMode", "FlySpeed", 20, 250, 10, function(enabled)
    if enabled then
        StartFlying()
    else
        StopFlying()
    end
end, nil)

-- ==============================================================================
-- 4. FOOTER FRAME (MANDATORY ULTRA SCRIPT HUB FOOTER)
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
