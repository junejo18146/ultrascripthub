--[[
    JUNEJO ULTRA SCRIPT HUB - SLAYERS 2
    Target Game: Slayers 2 (Roblox)
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11)
    Status: Unlocked Direct Standalone Execution
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Safe UI Parent getter (compatible with Delta, Codex, Fluxus, and PC Executors)
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

-- Clean up any previous UI instances safely
for _, name in ipairs({"JunejoHubUI_Slayers2", "JunejoSlayers2UI", "JunejoUltraScriptHub_Slayers2"}) do
    pcall(function()
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end)
end

-- Global Configuration & State
local Toggles = {
    AutoFarmMobs = false,
    AutoAcceptQuests = false,
    FastAutoAttack = false,
    KillAura = false,
    MobESP = false,
    PlayerESP = false,
    TrainerESP = false,
    WalkSpeed = false,
    AntiAFK = true
}

local CustomSpeedValue = 50
local CurrentMobESP = {}
local CurrentPlayerESP = {}
local CurrentTrainerESP = {}
local SafePlatform = nil

-- Safe Alive Check
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- Anti-AFK Handler
pcall(function()
    LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end
    end)
end)

-- Screen Toast Notification Helper
local function ShowToast(title, message)
    pcall(function()
        local sg = CoreGui:FindFirstChild("JunejoHubUI_Slayers2") or (LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("JunejoHubUI_Slayers2"))
        if not sg then return end

        local oldToast = sg:FindFirstChild("JunejoToast")
        if oldToast then oldToast:Destroy() end

        local Toast = Instance.new("Frame")
        Toast.Name = "JunejoToast"
        Toast.Size = UDim2.new(0, 240, 0, 40)
        Toast.Position = UDim2.new(0.5, -120, 0.08, 0)
        Toast.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        Toast.BorderSizePixel = 0
        Toast.ZIndex = 9999
        Toast.Parent = sg

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 8)
        ToastCorner.Parent = Toast

        local ToastStroke = Instance.new("UIStroke")
        ToastStroke.Color = Color3.fromRGB(50, 50, 65)
        ToastStroke.Thickness = 1
        ToastStroke.Parent = Toast

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -12, 0, 16)
        TitleLbl.Position = UDim2.new(0, 8, 0, 4)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
        TitleLbl.TextSize = 11
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.ZIndex = 10000
        TitleLbl.Parent = Toast

        local MsgLbl = Instance.new("TextLabel")
        MsgLbl.Size = UDim2.new(1, -12, 0, 16)
        MsgLbl.Position = UDim2.new(0, 8, 0, 19)
        MsgLbl.BackgroundTransparency = 1
        MsgLbl.Text = message
        MsgLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
        MsgLbl.TextSize = 10
        MsgLbl.Font = Enum.Font.GothamMedium
        MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
        MsgLbl.ZIndex = 10000
        MsgLbl.Parent = Toast

        task.delay(2.5, function()
            if Toast and Toast.Parent then
                local tween = TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                tween:Play()
                TitleLbl.TextTransparency = 1
                MsgLbl.TextTransparency = 1
                ToastStroke.Transparency = 1
                task.wait(0.35)
                if Toast then Toast:Destroy() end
            end
        end)
    end)
end

-- ====================================================
-- CORE FUNCTIONALITIES & ENGINES
-- ====================================================

-- 1. Safe Zone Teleport Action
local function TeleportToSafeZone()
    pcall(function()
        if not isAlive() then
            ShowToast("Error", "Character not spawned!")
            return
        end

        local hrp = LocalPlayer.Character.HumanoidRootPart
        local safePos = Vector3.new(hrp.Position.X, hrp.Position.Y + 600, hrp.Position.Z)

        if not SafePlatform or not SafePlatform.Parent then
            SafePlatform = Instance.new("Part")
            SafePlatform.Name = "JunejoSafeZonePlatform"
            SafePlatform.Size = Vector3.new(40, 2, 40)
            SafePlatform.Anchored = true
            SafePlatform.CanCollide = true
            SafePlatform.Material = Enum.Material.SmoothPlastic
            SafePlatform.Color = Color3.fromRGB(25, 25, 30)
            SafePlatform.CFrame = CFrame.new(safePos - Vector3.new(0, 3, 0))
            SafePlatform.Parent = Workspace
        else
            SafePlatform.CFrame = CFrame.new(safePos - Vector3.new(0, 3, 0))
        end

        hrp.CFrame = CFrame.new(safePos)
        ShowToast("Safe Zone", "Teleported to Sky Safe Platform!")
    end)
end

-- Weapon Auto-Equip Helper
local function AutoEquipWeapon()
    pcall(function()
        if not isAlive() then return end
        local char = LocalPlayer.Character
        local hasToolEquipped = char:FindFirstChildOfClass("Tool")
        if not hasToolEquipped then
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp then
                local tool = bp:FindFirstChildOfClass("Tool")
                if tool then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:EquipTool(tool) end
                end
            end
        end
    end)
end

-- Universal Attack Trigger
local function TriggerAttack()
    pcall(function()
        if not isAlive() then return end
        AutoEquipWeapon()
        
        -- Tool Activate
        local char = LocalPlayer.Character
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Activate()
            end
        end

        -- Virtual Click
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))

        -- ReplicatedStorage Combat Remotes Broadcaster
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local rn = remote.Name:lower()
                if rn:find("attack") or rn:find("combat") or rn:find("m1") or rn:find("slash") or rn:find("hit") or rn:find("punch") or rn:find("swing") or rn:find("damage") then
                    pcall(function() remote:FireServer() end)
                    pcall(function() remote:FireServer(1) end)
                    pcall(function() remote:FireServer("Light") end)
                end
            end
        end
    end)
end

-- Enemy Scanner Helper
local function GetEnemies()
    local enemies = {}
    pcall(function()
        local function checkModel(model)
            if model:IsA("Model") and model ~= LocalPlayer.Character then
                local hum = model:FindFirstChildOfClass("Humanoid")
                local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
                local isPlayer = Players:GetPlayerFromCharacter(model) ~= nil
                
                if hum and hum.Health > 0 and root and not isPlayer then
                    table.insert(enemies, {
                        Model = model,
                        Humanoid = hum,
                        RootPart = root,
                        Name = model.Name
                    })
                end
            end
        end

        for _, obj in ipairs(Workspace:GetChildren()) do
            checkModel(obj)
            if obj:IsA("Folder") or obj:IsA("Model") then
                for _, sub in ipairs(obj:GetChildren()) do
                    checkModel(sub)
                end
            end
        end
    end)
    return enemies
end

-- 2. Fast Auto Attack Loop
task.spawn(function()
    while true do
        task.wait(0.08)
        if Toggles.FastAutoAttack and isAlive() then
            TriggerAttack()
        end
    end
end)

-- 3. Kill Aura Loop
task.spawn(function()
    while true do
        task.wait(0.12)
        if Toggles.KillAura and isAlive() then
            pcall(function()
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                local enemies = GetEnemies()
                for _, enemy in ipairs(enemies) do
                    if not Toggles.KillAura then break end
                    local dist = (enemy.RootPart.Position - myPos).Magnitude
                    if dist <= 35 then
                        TriggerAttack()
                    end
                end
            end)
        end
    end
end)

-- 4. Auto Farm Mobs Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if Toggles.AutoFarmMobs and isAlive() then
            pcall(function()
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local enemies = GetEnemies()
                
                local closest = nil
                local shortestDist = math.huge
                for _, enemy in ipairs(enemies) do
                    local d = (enemy.RootPart.Position - hrp.Position).Magnitude
                    if d < shortestDist then
                        shortestDist = d
                        closest = enemy
                    end
                end

                if closest and closest.Humanoid.Health > 0 then
                    hrp.CFrame = closest.RootPart.CFrame * CFrame.new(0, 6, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    TriggerAttack()
                end
            end)
        end
    end
end)

-- 5. Auto Accept Quests Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoAcceptQuests and isAlive() then
            pcall(function()
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoAcceptQuests then break end
                    if prompt:IsA("ProximityPrompt") then
                        local text = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                        if text:find("quest") or text:find("talk") or text:find("accept") or text:find("mission") or text:find("task") then
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                prompt:InputHoldBegin()
                                task.wait(0.05)
                                prompt:InputHoldEnd()
                            end
                        end
                    end
                end

                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local rn = remote.Name:lower()
                        if rn:find("quest") or rn:find("mission") or rn:find("accept") then
                            if remote:IsA("RemoteEvent") then
                                pcall(function() remote:FireServer("Accept") end)
                                pcall(function() remote:FireServer(1) end)
                            elseif remote:IsA("RemoteFunction") then
                                pcall(function() remote:InvokeServer("Accept") end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 6. Mob / Demon ESP Engine
local function UpdateMobESP()
    pcall(function()
        if not Toggles.MobESP then
            for _, esp in pairs(CurrentMobESP) do
                if esp and esp.Parent then esp:Destroy() end
            end
            CurrentMobESP = {}
            return
        end

        local enemies = GetEnemies()
        for _, enemy in ipairs(enemies) do
            local part = enemy.RootPart
            if part and not CurrentMobESP[part] then
                local bg = Instance.new("BillboardGui")
                bg.Name = "JunejoMobESP"
                bg.Adornee = part
                bg.Size = UDim2.new(0, 140, 0, 32)
                bg.StudsOffset = Vector3.new(0, 3.5, 0)
                bg.AlwaysOnTop = true
                bg.Parent = part

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.fromRGB(255, 60, 80)
                lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                lbl.TextStrokeTransparency = 0
                lbl.TextSize = 11
                lbl.Font = Enum.Font.GothamBold
                lbl.Text = enemy.Name .. " [HP: " .. math.floor(enemy.Humanoid.Health) .. "]"
                lbl.Parent = bg

                CurrentMobESP[part] = bg
            elseif part and CurrentMobESP[part] then
                local lbl = CurrentMobESP[part]:FindFirstChildOfClass("TextLabel")
                if lbl and isAlive() then
                    local dist = math.floor((part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                    lbl.Text = enemy.Name .. " [" .. dist .. "m] [HP: " .. math.floor(enemy.Humanoid.Health) .. "]"
                end
            end
        end
    end)
end

-- 7. Player ESP Engine
local function UpdatePlayerESP()
    pcall(function()
        if not Toggles.PlayerESP then
            for _, esp in pairs(CurrentPlayerESP) do
                if esp and esp.Parent then esp:Destroy() end
            end
            CurrentPlayerESP = {}
            return
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local char = plr.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    if not CurrentPlayerESP[plr] then
                        local bg = Instance.new("BillboardGui")
                        bg.Name = "JunejoPlayerESP"
                        bg.Adornee = hrp
                        bg.Size = UDim2.new(0, 140, 0, 32)
                        bg.StudsOffset = Vector3.new(0, 3.5, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = hrp

                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(0, 220, 255)
                        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        lbl.TextStrokeTransparency = 0
                        lbl.TextSize = 11
                        lbl.Font = Enum.Font.GothamBold
                        lbl.Text = plr.DisplayName
                        lbl.Parent = bg

                        CurrentPlayerESP[plr] = bg
                    else
                        local lbl = CurrentPlayerESP[plr]:FindFirstChildOfClass("TextLabel")
                        if lbl and isAlive() then
                            local dist = math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                            lbl.Text = plr.DisplayName .. " [" .. dist .. "m]"
                        end
                    end
                end
            end
        end
    end)
end

-- 8. Trainers & NPC ESP Engine
local function UpdateTrainerESP()
    pcall(function()
        if not Toggles.TrainerESP then
            for _, esp in pairs(CurrentTrainerESP) do
                if esp and esp.Parent then esp:Destroy() end
            end
            CurrentTrainerESP = {}
            return
        end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
                local name = obj.Name:lower()
                local isTrainer = name:find("trainer") or name:find("breathing") or name:find("master") or name:find("sensei") or name:find("water") or name:find("flame") or name:find("thunder") or name:find("wind") or name:find("sun") or name:find("gourd")
                
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildWhichIsA("BasePart")
                if isTrainer and root then
                    if not CurrentTrainerESP[root] then
                        local bg = Instance.new("BillboardGui")
                        bg.Name = "JunejoTrainerESP"
                        bg.Adornee = root
                        bg.Size = UDim2.new(0, 150, 0, 32)
                        bg.StudsOffset = Vector3.new(0, 4, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = root

                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
                        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        lbl.TextStrokeTransparency = 0
                        lbl.TextSize = 11
                        lbl.Font = Enum.Font.GothamBold
                        lbl.Text = "[TRAINER] " .. obj.Name
                        lbl.Parent = bg

                        CurrentTrainerESP[root] = bg
                    else
                        local lbl = CurrentTrainerESP[root]:FindFirstChildOfClass("TextLabel")
                        if lbl and isAlive() then
                            local dist = math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                            lbl.Text = "[TRAINER] " .. obj.Name .. " [" .. dist .. "m]"
                        end
                    end
                end
            end
        end
    end)
end

-- ESP Master Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        UpdateMobESP()
        UpdatePlayerESP()
        UpdateTrainerESP()
    end
end)

-- 9. WalkSpeed Controller Loop
RunService.Heartbeat:Connect(function()
    pcall(function()
        if isAlive() then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if Toggles.WalkSpeed then
                    hum.WalkSpeed = CustomSpeedValue
                end
            end
        end
    end)
end)

-- ====================================================
-- OFFICIAL UI 1: ULTRA SCRIPT HUB CLASSIC MATTE DARK
-- ====================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_Slayers2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif CoreGui then
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = UIContainer end
else
    ScreenGui.Parent = UIContainer
end

-- Main Container (280px width, 360px height to accommodate action button + 7 rows + speed stepper + footer)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.5, -140, 0.45, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -44, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "SLAYERS 2"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 36, 0, 36)
CloseButton.Position = UDim2.new(1, -36, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "x"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 170)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Header Divider Line
local HeaderDivider = Instance.new("Frame")
HeaderDivider.Name = "HeaderDivider"
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position = UDim2.new(0, 0, 0, 36)
HeaderDivider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderDivider.BorderSizePixel = 0
HeaderDivider.Parent = MainFrame

-- Draggable Functionality (Mouse & Touch Mobile)
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

-- Content Container Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -28, 0, 265)
ContentFrame.Position = UDim2.new(0, 14, 0, 44)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local ContentList = Instance.new("UIListLayout")
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.Padding = UDim.new(0, 5)
ContentList.Parent = ContentFrame

-- Top Action Button: Teleport to Safe Zone
local ActionBtnFrame = Instance.new("Frame")
ActionBtnFrame.Size = UDim2.new(1, 0, 0, 28)
ActionBtnFrame.BackgroundTransparency = 1
ActionBtnFrame.LayoutOrder = 1
ActionBtnFrame.Parent = ContentFrame

local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(1, 0, 1, 0)
ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
ActionBtn.BorderSizePixel = 0
ActionBtn.Text = "Teleport to Safe Zone"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.TextSize = 12
ActionBtn.Font = Enum.Font.GothamBold
ActionBtn.AutoButtonColor = false
ActionBtn.Parent = ActionBtnFrame

local ActionCorner = Instance.new("UICorner")
ActionCorner.CornerRadius = UDim.new(0, 6)
ActionCorner.Parent = ActionBtn

local ActionStroke = Instance.new("UIStroke")
ActionStroke.Color = Color3.fromRGB(45, 45, 55)
ActionStroke.Thickness = 1
ActionStroke.Parent = ActionBtn

ActionBtn.MouseButton1Click:Connect(function()
    TeleportToSafeZone()
end)

-- Helper: Add Standard Toggle Row
local function AddToggleRow(text, configKey, order)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 22)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.Parent = ContentFrame
    
    local RowBtn = Instance.new("TextButton")
    RowBtn.Size = UDim2.new(1, 0, 1, 0)
    RowBtn.BackgroundTransparency = 1
    RowBtn.Text = ""
    RowBtn.ZIndex = 5
    RowBtn.Parent = Row
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -26, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local CheckBox = Instance.new("Frame")
    CheckBox.Size = UDim2.new(0, 20, 0, 20)
    CheckBox.Position = UDim2.new(1, -20, 0.5, -10)
    CheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    CheckBox.BorderSizePixel = 0
    CheckBox.Parent = Row
    
    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 5)
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
        
        if configKey == "MobESP" and not Toggles.MobESP then UpdateMobESP() end
        if configKey == "PlayerESP" and not Toggles.PlayerESP then UpdatePlayerESP() end
        if configKey == "TrainerESP" and not Toggles.TrainerESP then UpdateTrainerESP() end
    end)
end

-- Add Standard Features
AddToggleRow("Auto Farm Mobs / Demons", "AutoFarmMobs", 2)
AddToggleRow("Auto Accept Quests", "AutoAcceptQuests", 3)
AddToggleRow("Fast Auto Attack", "FastAutoAttack", 4)
AddToggleRow("Kill Aura", "KillAura", 5)
AddToggleRow("Mob / Demon ESP", "MobESP", 6)
AddToggleRow("Player ESP", "PlayerESP", 7)
AddToggleRow("Trainers / NPC ESP", "TrainerESP", 8)

-- Speed / Stepper Row (WalkSpeed + Pill Stepper)
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, 0, 0, 24)
SpeedRow.BackgroundTransparency = 1
SpeedRow.LayoutOrder = 9
SpeedRow.Parent = ContentFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 100, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed"
SpeedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedRow

-- Right Controls Container (Checkbox + Stepper Pill)
local SpeedControls = Instance.new("Frame")
SpeedControls.Size = UDim2.new(0, 134, 1, 0)
SpeedControls.Position = UDim2.new(1, -134, 0, 0)
SpeedControls.BackgroundTransparency = 1
SpeedControls.Parent = SpeedRow

-- Checkbox for Speed
local SpeedCheckBox = Instance.new("Frame")
SpeedCheckBox.Size = UDim2.new(0, 20, 0, 20)
SpeedCheckBox.Position = UDim2.new(0, 0, 0.5, -10)
SpeedCheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
SpeedCheckBox.BorderSizePixel = 0
SpeedCheckBox.Parent = SpeedControls

local SpeedCheckCorner = Instance.new("UICorner")
SpeedCheckCorner.CornerRadius = UDim.new(0, 5)
SpeedCheckCorner.Parent = SpeedCheckBox

local SpeedCheckStroke = Instance.new("UIStroke")
SpeedCheckStroke.Color = Color3.fromRGB(45, 45, 55)
SpeedCheckStroke.Thickness = 1.2
SpeedCheckStroke.Parent = SpeedCheckBox

local SpeedCheckMark = Instance.new("Frame")
SpeedCheckMark.Size = UDim2.new(0, 10, 0, 10)
SpeedCheckMark.Position = UDim2.new(0.5, -5, 0.5, -5)
SpeedCheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeed and 0 or 1
SpeedCheckMark.BorderSizePixel = 0
SpeedCheckMark.Parent = SpeedCheckBox

local SpeedMarkCorner = Instance.new("UICorner")
SpeedMarkCorner.CornerRadius = UDim.new(0, 2)
SpeedMarkCorner.Parent = SpeedCheckMark

local SpeedCheckBtn = Instance.new("TextButton")
SpeedCheckBtn.Size = UDim2.new(1, 0, 1, 0)
SpeedCheckBtn.BackgroundTransparency = 1
SpeedCheckBtn.Text = ""
SpeedCheckBtn.ZIndex = 5
SpeedCheckBtn.Parent = SpeedCheckBox

SpeedCheckBtn.MouseButton1Click:Connect(function()
    Toggles.WalkSpeed = not Toggles.WalkSpeed
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeed and 0 or 1
    if not Toggles.WalkSpeed and isAlive() then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    end
end)

-- Stepper Pill [ - 50 + ]
local StepperPill = Instance.new("Frame")
StepperPill.Size = UDim2.new(0, 105, 0, 24)
StepperPill.Position = UDim2.new(1, -105, 0.5, -12)
StepperPill.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
StepperPill.BorderSizePixel = 0
StepperPill.Parent = SpeedControls

local StepperCorner = Instance.new("UICorner")
StepperCorner.CornerRadius = UDim.new(0, 6)
StepperCorner.Parent = StepperPill

local StepperStroke = Instance.new("UIStroke")
StepperStroke.Color = Color3.fromRGB(45, 45, 55)
StepperStroke.Thickness = 1
StepperStroke.Parent = StepperPill

local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 28, 1, 0)
MinusBtn.Position = UDim2.new(0, 0, 0, 0)
MinusBtn.BackgroundTransparency = 1
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
MinusBtn.TextSize = 14
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Parent = StepperPill

local ValueLbl = Instance.new("TextLabel")
ValueLbl.Size = UDim2.new(1, -56, 1, 0)
ValueLbl.Position = UDim2.new(0, 28, 0, 0)
ValueLbl.BackgroundTransparency = 1
ValueLbl.Text = tostring(CustomSpeedValue)
ValueLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueLbl.TextSize = 12
ValueLbl.Font = Enum.Font.GothamBold
ValueLbl.Parent = StepperPill

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 28, 1, 0)
PlusBtn.Position = UDim2.new(1, -28, 0, 0)
PlusBtn.BackgroundTransparency = 1
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
PlusBtn.TextSize = 14
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Parent = StepperPill

MinusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.max(16, CustomSpeedValue - 10)
    ValueLbl.Text = tostring(CustomSpeedValue)
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(250, CustomSpeedValue + 10)
    ValueLbl.Text = tostring(CustomSpeedValue)
end)

-- Mandatory Centered Footer
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 42)
Footer.Position = UDim2.new(0, 0, 1, -42)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 16)
FooterTitle.Position = UDim2.new(0, 0, 0, 4)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 12
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 14)
FooterSub.Position = UDim2.new(0, 0, 0, 20)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 11
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.Parent = Footer

ShowToast("Ultra Script Hub", "Slayers 2 Script Loaded Successfully!")
