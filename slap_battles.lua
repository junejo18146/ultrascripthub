-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - SLAP BATTLES 🥊
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- Universal Compatibility (Mobile Delta / Fluxus / Codex & PC)
-- ====================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    while not LocalPlayer do
        LocalPlayer = Players.LocalPlayer
        task.wait(0.05)
    end
end

-- Clean old UI instances safely across CoreGui, gethui and PlayerGui
pcall(function()
    for _, name in ipairs({"JunejoHubUI_SlapBattles", "SufyanSlapBattlesHub", "JunejoSlapBattlesHub"}) do
        pcall(function()
            if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        end)
        pcall(function()
            if gethui and gethui():FindFirstChild(name) then gethui()[name]:Destroy() end
        end)
        pcall(function()
            local pg = LocalPlayer and (LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:FindFirstChildOfClass("PlayerGui"))
            if pg and pg:FindFirstChild(name) then pg[name]:Destroy() end
        end)
    end
end)

-- Global Configuration & State
local Toggles = {
    SlapAura = false,
    HitboxExtend = false,
    AutoAbility = false,
    AntiReverse = true,
    AntiVoid = false,
    AntiRagdoll = false,
    AntiFling = false,
    AutoSlapple = false,
    TycoonClick = false,
    MegarockAFK = false,
    PlayerGloveESP = false,
    WalkSpeedBoost = false,
    JumpPowerBoost = false,
    InfiniteJump = false,
    AntiAFK = true
}

local CustomSpeedValue = 100
local CustomJumpPower = 120
local AuraRadius = 18
local HitboxSize = 14
local ESPInstances = {}
local AntiVoidPart = nil

-- Safe Character & Tool Helpers
local function getChar()
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        return root, hum, char
    end
    return nil, nil, nil
end

local function isAlive()
    local root, hum = getChar()
    return root ~= nil and hum ~= nil and hum.Health > 0
end

local function getEquippedGlove()
    local _, _, char = getChar()
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then return tool end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        local tool = bp:FindFirstChildOfClass("Tool")
        if tool then return tool end
    end
    return nil
end

local function getGloveName(player)
    if not player or not player.Character then return "None" end
    local char = player.Character
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool.Name end
    local ls = player:FindFirstChild("leaderstats")
    if ls and ls:FindFirstChild("Glove") then
        return tostring(ls.Glove.Value)
    end
    return "Default"
end

local function isReverseActive(player)
    if not player or not player.Character then return false end
    local char = player.Character
    if char:FindFirstChild("Reverse") or char:FindFirstChild("Defense") or (char:FindFirstChild("Part") and char.Part.Name == "Reverse") then
        return true
    end
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("Highlight") and child.FillColor == Color3.fromRGB(255, 0, 0) then
            return true
        end
        if child:IsA("ParticleEmitter") and string.find(string.lower(child.Name), "reverse") then
            return true
        end
    end
    return false
end

-- Speed & Jump Update Helpers
local function UpdateCharacterSpeed()
    pcall(function()
        if isAlive() then
            local _, hum = getChar()
            if hum then
                hum.WalkSpeed = Toggles.WalkSpeedBoost and CustomSpeedValue or 16
            end
        end
    end)
end

local function UpdateCharacterJump()
    pcall(function()
        if isAlive() then
            local _, hum = getChar()
            if hum then
                if Toggles.JumpPowerBoost then
                    hum.UseJumpPower = true
                    hum.JumpPower = CustomJumpPower
                else
                    hum.UseJumpPower = true
                    hum.JumpPower = 50
                end
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateCharacterSpeed()
    UpdateCharacterJump()
end)

-- Screen Notification Toast Helper
local function ShowNotification(title, message)
    pcall(function()
        local sg = CoreGui:FindFirstChild("JunejoHubUI_SlapBattles") or (LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("JunejoHubUI_SlapBattles"))
        if not sg then return end

        local oldNotify = sg:FindFirstChild("JunejoToast")
        if oldNotify then oldNotify:Destroy() end

        local Toast = Instance.new("Frame")
        Toast.Name = "JunejoToast"
        Toast.Size = UDim2.new(0, 260, 0, 42)
        Toast.Position = UDim2.new(0.5, -130, 0.12, 0)
        Toast.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        Toast.BorderSizePixel = 0
        Toast.ZIndex = 999
        Toast.Parent = sg

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 8)
        ToastCorner.Parent = Toast

        local ToastStroke = Instance.new("UIStroke")
        ToastStroke.Color = Color3.fromRGB(60, 60, 80)
        ToastStroke.Thickness = 1.2
        ToastStroke.Parent = Toast

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -12, 0, 16)
        TitleLbl.Position = UDim2.new(0, 8, 0, 4)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
        TitleLbl.TextSize = 11
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.ZIndex = 1000
        TitleLbl.Parent = Toast

        local MsgLbl = Instance.new("TextLabel")
        MsgLbl.Size = UDim2.new(1, -12, 0, 16)
        MsgLbl.Position = UDim2.new(0, 8, 0, 20)
        MsgLbl.BackgroundTransparency = 1
        MsgLbl.Text = message
        MsgLbl.TextColor3 = Color3.fromRGB(230, 230, 240)
        MsgLbl.TextSize = 10
        MsgLbl.Font = Enum.Font.GothamMedium
        MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
        MsgLbl.ZIndex = 1000
        MsgLbl.Parent = Toast

        task.delay(3, function()
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
-- BACKEND ENGINES & WORKERS
-- ====================================================

-- 1. Anti-Void Platform (Y = -5)
local function UpdateAntiVoid(enabled)
    pcall(function()
        if enabled then
            if not AntiVoidPart or not AntiVoidPart.Parent then
                AntiVoidPart = Instance.new("Part")
                AntiVoidPart.Name = "Junejo_AntiVoid_Platform"
                AntiVoidPart.Size = Vector3.new(3500, 4, 3500)
                AntiVoidPart.Position = Vector3.new(0, -5, 0)
                AntiVoidPart.Anchored = true
                AntiVoidPart.CanCollide = true
                AntiVoidPart.Transparency = 0.5
                AntiVoidPart.Material = Enum.Material.ForceField
                AntiVoidPart.Color = Color3.fromRGB(0, 220, 220)
                AntiVoidPart.Parent = Workspace
            end
        else
            if AntiVoidPart and AntiVoidPart.Parent then
                AntiVoidPart:Destroy()
                AntiVoidPart = nil
            end
        end
    end)
end

-- 2. Slap Aura Engine (Anti-Kick & Reach check)
task.spawn(function()
    while true do
        task.wait(0.28)
        if Toggles.SlapAura then
            pcall(function()
                local root, hum, char = getChar()
                local tool = getEquippedGlove()
                if root and hum and hum.Health > 0 and tool then
                    local myPos = root.Position
                    local targetChar = nil
                    local targetRoot = nil
                    local closestDist = AuraRadius

                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local pChar = player.Character
                            local pHum = pChar:FindFirstChildOfClass("Humanoid")
                            local pRoot = pChar:FindFirstChild("HumanoidRootPart")
                            if pHum and pHum.Health > 0 and pRoot then
                                local reverseProtected = Toggles.AntiReverse and isReverseActive(player)
                                if not reverseProtected then
                                    local dist = (pRoot.Position - myPos).Magnitude
                                    if dist <= closestDist then
                                        closestDist = dist
                                        targetChar = pChar
                                        targetRoot = pRoot
                                    end
                                end
                            end
                        end
                    end

                    if targetChar and targetRoot then
                        pcall(function()
                            root.CFrame = CFrame.new(root.Position, Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
                        end)

                        local gloveHitbox = tool:FindFirstChild("Hitbox") or tool:FindFirstChild("Glove") or tool:FindFirstChild("Handle")
                        if gloveHitbox and gloveHitbox:IsA("BasePart") then
                            local originalSize = gloveHitbox.Size
                            local neededReach = math.clamp(closestDist + 3, 6, 25)
                            gloveHitbox.Size = Vector3.new(neededReach, neededReach, neededReach)
                            gloveHitbox.CanCollide = false
                            tool:Activate()
                            task.delay(0.15, function()
                                if not Toggles.HitboxExtend and gloveHitbox and gloveHitbox.Parent then
                                    gloveHitbox.Size = originalSize
                                end
                            end)
                        else
                            tool:Activate()
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. Hitbox Extender Engine
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.HitboxExtend then
            pcall(function()
                local tool = getEquippedGlove()
                if tool then
                    local hitbox = tool:FindFirstChild("Hitbox") or tool:FindFirstChild("Glove") or tool:FindFirstChild("Handle")
                    if hitbox and hitbox:IsA("BasePart") then
                        hitbox.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                        hitbox.Transparency = 0.65
                        hitbox.CanCollide = false
                    end
                end
            end)
        end
    end
end)

-- 4. Auto Glove Ability [E]
task.spawn(function()
    while true do
        task.wait(0.8)
        if Toggles.AutoAbility then
            pcall(function()
                local genAbility = ReplicatedStorage:FindFirstChild("GeneralAbility")
                if genAbility and genAbility:IsA("RemoteEvent") then
                    genAbility:FireServer()
                end
            end)
        end
    end
end)

-- 5. Anti-Ragdoll, Anti-Fling & Stepped Movement
RunService.Stepped:Connect(function()
    pcall(function()
        local root, hum, char = getChar()
        if hum and root and hum.Health > 0 then
            if Toggles.AntiRagdoll then
                if hum.PlatformStand then
                    hum.PlatformStand = false
                end
                if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
                if char:FindFirstChild("Ragdolled") then
                    local rVal = char.Ragdolled
                    if rVal:IsA("BoolValue") and rVal.Value == true then
                        rVal.Value = false
                    end
                end
            end

            if Toggles.AntiFling then
                local vel = root.Velocity
                if vel.Magnitude > 110 then
                    root.Velocity = Vector3.new(
                        math.clamp(vel.X, -50, 50),
                        math.clamp(vel.Y, -40, 60),
                        math.clamp(vel.Z, -50, 50)
                    )
                end
            end

            if Toggles.WalkSpeedBoost and hum.WalkSpeed ~= CustomSpeedValue then
                hum.WalkSpeed = CustomSpeedValue
            end
            if Toggles.JumpPowerBoost then
                hum.UseJumpPower = true
                if hum.JumpPower ~= CustomJumpPower then
                    hum.JumpPower = CustomJumpPower
                end
            end
        end
    end)
end)

-- 6. Auto Slapple Collector
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.AutoSlapple then
            pcall(function()
                local root = select(1, getChar())
                if root then
                    local slappleFolder = Workspace:FindFirstChild("Arena") and Workspace.Arena:FindFirstChild("island5") and Workspace.Arena.island5:FindFirstChild("Slapples") or Workspace:FindFirstChild("Slapple")
                    local targetSlapple = nil

                    if slappleFolder then
                        for _, obj in pairs(slappleFolder:GetChildren()) do
                            if obj:IsA("BasePart") or obj:IsA("Model") then
                                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
                                if part and part.Transparency < 0.9 then
                                    targetSlapple = part
                                    break
                                end
                            end
                        end
                    end

                    if not targetSlapple then
                        for _, child in pairs(Workspace:GetChildren()) do
                            if string.find(string.lower(child.Name), "slapple") then
                                local p = child:IsA("BasePart") and child or child:FindFirstChildOfClass("BasePart")
                                if p then targetSlapple = p; break end
                            end
                        end
                    end

                    if targetSlapple then
                        local origPos = root.CFrame
                        root.CFrame = targetSlapple.CFrame
                        task.wait(0.1)
                        root.CFrame = origPos
                        ShowNotification("Slapple", "Collected Slapple from Island!")
                    end
                end
            end)
        end
    end
end)

-- 7. Tycoon Auto Clicker
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.TycoonClick then
            pcall(function()
                local tycoon = Workspace:FindFirstChild(LocalPlayer.Name .. "'s Tycoon") or Workspace:FindFirstChild("Tycoon")
                if tycoon then
                    local clickPart = tycoon:FindFirstChild("Click") or tycoon:FindFirstChild("Button")
                    if clickPart and clickPart:FindFirstChild("ClickDetector") then
                        fireclickdetector(clickPart.ClickDetector)
                    end
                end
            end)
        end
    end
end)

-- 8. Megarock AFK Helper
task.spawn(function()
    while true do
        task.wait(2)
        if Toggles.MegarockAFK then
            pcall(function()
                local _, _, char = getChar()
                if char and not char:FindFirstChild("rock") and not char:FindFirstChild("Rock") then
                    local genAbility = ReplicatedStorage:FindFirstChild("GeneralAbility")
                    if genAbility and genAbility:IsA("RemoteEvent") then
                        genAbility:FireServer()
                    end
                end
            end)
        end
    end
end)

-- 9. Infinite Jump
UIS.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        local _, hum = getChar()
        if hum and hum.Health > 0 then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- 10. Player & Glove ESP
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "Junejo_SlapBattles_ESP"
pcall(function() ESPFolder.Parent = CoreGui end)
if not ESPFolder.Parent then ESPFolder.Parent = Workspace end

local function UpdateESP()
    for _, child in pairs(ESPFolder:GetChildren()) do
        child:Destroy()
    end

    if not Toggles.PlayerGloveESP then return end

    local myRoot = select(1, getChar())
    if not myRoot then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local pChar = player.Character
            local pHead = pChar:FindFirstChild("Head")
            local pHum = pChar:FindFirstChildOfClass("Humanoid")
            local pRoot = pChar:FindFirstChild("HumanoidRootPart")

            if pHead and pHum and pHum.Health > 0 and pRoot then
                local dist = math.floor((pRoot.Position - myRoot.Position).Magnitude)
                local gName = getGloveName(player)
                local isRev = isReverseActive(player)

                local bb = Instance.new("BillboardGui", ESPFolder)
                bb.Adornee = pHead
                bb.Size = UDim2.new(0, 140, 0, 42)
                bb.StudsOffset = Vector3.new(0, 2.5, 0)
                bb.AlwaysOnTop = true

                local nameLbl = Instance.new("TextLabel", bb)
                nameLbl.Size = UDim2.new(1, 0, 0, 14)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Font = Enum.Font.GothamBold
                nameLbl.TextSize = 10
                nameLbl.TextColor3 = isRev and Color3.fromRGB(255, 60, 80) or Color3.fromRGB(255, 255, 255)
                nameLbl.Text = player.DisplayName .. (isRev and " ⚠️ [REVERSE]" or "")

                local gloveLbl = Instance.new("TextLabel", bb)
                gloveLbl.Size = UDim2.new(1, 0, 0, 14)
                gloveLbl.Position = UDim2.new(0, 0, 0, 14)
                gloveLbl.BackgroundTransparency = 1
                gloveLbl.Font = Enum.Font.GothamBold
                gloveLbl.TextSize = 9.5
                gloveLbl.TextColor3 = Color3.fromRGB(0, 220, 220)
                gloveLbl.Text = "🥊 Glove: " .. gName

                local distLbl = Instance.new("TextLabel", bb)
                distLbl.Size = UDim2.new(1, 0, 0, 12)
                distLbl.Position = UDim2.new(0, 0, 0, 28)
                distLbl.BackgroundTransparency = 1
                distLbl.Font = Enum.Font.Gotham
                distLbl.TextSize = 8.5
                distLbl.TextColor3 = Color3.fromRGB(180, 180, 190)
                distLbl.Text = tostring(dist) .. " studs"
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if Toggles.PlayerGloveESP then
            pcall(UpdateESP)
        end
    end
end)

-- 11. Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Teleport Helper
local function TeleportToPos(pos, name)
    pcall(function()
        local root = select(1, getChar())
        if root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.CFrame = CFrame.new(pos)
            ShowNotification("Teleport", "Teleported to " .. name .. "!")
        end
    end)
end

-- ====================================================
-- OFFICIAL JUNEJO COMPACT UI (280px Standard)
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_SlapBattles"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local isParented = false
pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
        if ScreenGui.Parent then isParented = true end
    end
end)
if not isParented then
    pcall(function()
        ScreenGui.Parent = CoreGui
        if ScreenGui.Parent then isParented = true end
    end)
end
if not isParented then
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
        if pg then
            ScreenGui.Parent = pg
            isParented = true
        end
    end)
end

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

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local function enableHeaderDrag(dragHandle, targetFrame)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
enableHeaderDrag(Header, MainFrame)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "SLAP BATTLES 🥊"
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
CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

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
ContentFrame.Size = UDim2.new(1, -16, 0, 230)
ContentFrame.Position = UDim2.new(0, 10, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 80)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper Function: Add Flat Toggle Row
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 23)
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
    
    local lastClick = 0
    RowBtn.MouseButton1Click:Connect(function()
        local now = os.clock()
        if now - lastClick < 0.12 then return end
        lastClick = now
        Toggles[configKey] = not Toggles[configKey]
        CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
        if callback then callback(Toggles[configKey]) end
    end)
end

-- Helper Function: Add Action Button
local function AddActionButton(text, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 24)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.Parent = Row
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Btn
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn
    
    local lastClick = 0
    Btn.MouseButton1Click:Connect(function()
        local now = os.clock()
        if now - lastClick < 0.25 then return end
        lastClick = now
        if callback then callback(Btn) end
    end)
end

-- ====================================================
-- ROWS REGISTRATION (COMBAT, DEFENSE, FARM, TELEPORTS)
-- ====================================================

-- 1. Slap Aura Toggle
AddToggleRow("Slap Aura (Auto-Slap)", "SlapAura", function(state) end)

-- 2. Smart Anti-Reverse Toggle
AddToggleRow("Smart Anti-Reverse", "AntiReverse", function(state) end)

-- 3. Hitbox Extender / Reach Toggle
AddToggleRow("Hitbox Extender (Reach)", "HitboxExtend", function(state) end)

-- 4. Auto Ability [E] Toggle
AddToggleRow("Auto Glove Ability [E]", "AutoAbility", function(state) end)

-- 5. Physical Anti-Void Toggle
AddToggleRow("Physical Anti-Void", "AntiVoid", function(state)
    UpdateAntiVoid(state)
end)

-- 6. Anti-Ragdoll & Fast Recovery Toggle
AddToggleRow("Anti-Ragdoll / Recovery", "AntiRagdoll", function(state) end)

-- 7. Anti-Fling Dampener Toggle
AddToggleRow("Anti-Fling Dampener", "AntiFling", function(state) end)

-- 8. Auto Slapple Collector Toggle
AddToggleRow("Auto Slapple Collector", "AutoSlapple", function(state) end)

-- 9. Tycoon Auto-Click Toggle
AddToggleRow("Tycoon Auto-Click", "TycoonClick", function(state) end)

-- 10. Megarock AFK Helper Toggle
AddToggleRow("Megarock AFK Helper", "MegarockAFK", function(state) end)

-- 11. Player & Glove ESP Toggle
AddToggleRow("Player & Glove ESP", "PlayerGloveESP", function(state)
    if not state then
        for _, c in pairs(ESPFolder:GetChildren()) do c:Destroy() end
    end
end)

-- 12. Infinite Jump Toggle
AddToggleRow("Infinite Jump", "InfiniteJump", function(state) end)

-- 13. Integrated WalkSpeed Row with - / + Pill Controller
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, -6, 0, 23)
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

local SpeedMarkCorner = Instance.new("UICorner")
SpeedMarkCorner.CornerRadius = UDim.new(0, 2)
SpeedMarkCorner.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
    UpdateCharacterSpeed()
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
    UpdateCharacterSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

-- 14. Integrated JumpPower Row with - / + Pill Controller
local JumpRow = Instance.new("Frame")
JumpRow.Size = UDim2.new(1, -6, 0, 23)
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
JumpLabel.Text = "JumpPower"
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

local JumpMarkCorner = Instance.new("UICorner")
JumpMarkCorner.CornerRadius = UDim.new(0, 2)
JumpMarkCorner.Parent = JumpCheckMark

JumpToggleBtn.MouseButton1Click:Connect(function()
    Toggles.JumpPowerBoost = not Toggles.JumpPowerBoost
    JumpCheckMark.BackgroundTransparency = Toggles.JumpPowerBoost and 0 or 1
    UpdateCharacterJump()
end)

local JumpControlFrame = Instance.new("Frame")
JumpControlFrame.Size = UDim2.new(0.42, 0, 1, 0)
JumpControlFrame.Position = UDim2.new(0.58, 0, 0, 0)
JumpControlFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
JumpControlFrame.BorderSizePixel = 0
JumpControlFrame.Parent = JumpRow

local JCtrlCorner = Instance.new("UICorner")
JCtrlCorner.CornerRadius = UDim.new(0, 4)
JCtrlCorner.Parent = JumpControlFrame

local JCtrlStroke = Instance.new("UIStroke")
JCtrlStroke.Color = Color3.fromRGB(45, 45, 55)
JCtrlStroke.Thickness = 1
JCtrlStroke.Parent = JumpControlFrame

local JMinusBtn = Instance.new("TextButton")
JMinusBtn.Size = UDim2.new(0, 22, 1, 0)
JMinusBtn.Position = UDim2.new(0, 0, 0, 0)
JMinusBtn.BackgroundTransparency = 1
JMinusBtn.Text = "-"
JMinusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
JMinusBtn.TextSize = 14
JMinusBtn.Font = Enum.Font.GothamBold
JMinusBtn.Parent = JumpControlFrame

local JumpDisplay = Instance.new("TextLabel")
JumpDisplay.Size = UDim2.new(1, -44, 1, 0)
JumpDisplay.Position = UDim2.new(0, 22, 0, 0)
JumpDisplay.BackgroundTransparency = 1
JumpDisplay.Text = tostring(CustomJumpPower)
JumpDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpDisplay.TextSize = 11
JumpDisplay.Font = Enum.Font.GothamBold
JumpDisplay.Parent = JumpControlFrame

local JPlusBtn = Instance.new("TextButton")
JPlusBtn.Size = UDim2.new(0, 22, 1, 0)
JPlusBtn.Position = UDim2.new(1, -22, 0, 0)
JPlusBtn.BackgroundTransparency = 1
JPlusBtn.Text = "+"
JPlusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
JPlusBtn.TextSize = 14
JPlusBtn.Font = Enum.Font.GothamBold
JPlusBtn.Parent = JumpControlFrame

JMinusBtn.MouseButton1Click:Connect(function()
    CustomJumpPower = math.max(50, CustomJumpPower - 15)
    JumpDisplay.Text = tostring(CustomJumpPower)
    UpdateCharacterJump()
end)

JPlusBtn.MouseButton1Click:Connect(function()
    CustomJumpPower = math.min(350, CustomJumpPower + 15)
    JumpDisplay.Text = tostring(CustomJumpPower)
    UpdateCharacterJump()
end)

-- 15. Action Buttons: Teleports
AddActionButton("📍 TP: Safe Lobby", function()
    TeleportToPos(Vector3.new(-390, 328, -5), "Lobby")
end)

AddActionButton("📍 TP: Main Arena", function()
    TeleportToPos(Vector3.new(0, 100, 0), "Main Arena")
end)

AddActionButton("📍 TP: Slapple Island", function()
    TeleportToPos(Vector3.new(-400, 50, -15), "Slapple Island")
end)

AddActionButton("📍 TP: Moai Island", function()
    TeleportToPos(Vector3.new(215, -15, 0), "Moai Island")
end)

AddActionButton("📍 TP: Floating Plate", function()
    TeleportToPos(Vector3.new(-35, 75, -230), "Floating Plate")
end)

AddActionButton("📍 TP: Arena Cannon", function()
    TeleportToPos(Vector3.new(245, 34, 160), "Arena Cannon")
end)

-- 16. Action Button: Rejoin Server
AddActionButton("🔄 Rejoin Server", function()
    ShowNotification("Rejoining", "Reconnecting to server...")
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

-- ====================================================
-- FOOTER
-- ====================================================
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
