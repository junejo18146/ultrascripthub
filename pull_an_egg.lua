-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - PULL AN EGG (OFFICIAL SCRIPT)
-- Game: Pull an Egg
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- Universal Mobile (Delta / Codex / Fluxus) & PC Compatible
-- UI Style: UI 1 (Classic Matte Dark)
-- ====================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
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
    AutoEquipBest = false,
    AutoClaimGifts = false,
    TeleportZones = false,
    WalkSpeedBoost = false,
    InfiniteJump = false,
    Noclip = false,
    AntiAFK = true
}

local CustomSpeedValue = 35
local RemovedGuardsCache = {}

-- Safe Alive & Character Helper
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- Anti-AFK System (Always active in background)
task.spawn(function()
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAFK then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end
        end)
    end)
end)

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
-- FEATURE 1: REMOVE GUARD
-- ====================================================
local function applyRemoveGuard()
    pcall(function()
        -- Search and disable/remove Guard NPCs, Security models, and Kill bricks guarding eggs
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
-- FEATURE 2: AUTO PULL EGG
-- ====================================================
task.spawn(function()
    while true do
        if Toggles.AutoPullEgg and isAlive() then
            pcall(function()
                -- Interacting with proximity prompts / click detectors on Eggs
                local foundPrompt = false
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local pName = string.lower(prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Name .. " " .. (prompt.Parent and prompt.Parent.Name or ""))
                        if string.find(pName, "pull") or string.find(pName, "egg") or string.find(pName, "grab") or string.find(pName, "steal") or string.find(pName, "claim") or string.find(pName, "interact") then
                            prompt.HoldDuration = 0
                            fireproximityprompt(prompt)
                            foundPrompt = true
                        end
                    elseif prompt:IsA("ClickDetector") then
                        fireclickdetector(prompt)
                    end
                end

                -- Also search for pull / egg remotes in ReplicatedStorage
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "pull") or string.find(rName, "eggpall") or string.find(rName, "pulrevent") or string.find(rName, "clickegg") then
                            remote:FireServer()
                        end
                    end
                end
            end)
        end
        task.wait(0.15)
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
                -- Auto equip and activate training weight / dumbbell tools
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

                -- Fire training remotes
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "train") or string.find(rName, "click") or string.find(rName, "strength") or string.find(rName, "power") or string.find(rName, "workout") then
                            remote:FireServer()
                        end
                    end
                end
            end)
        end
        task.wait(0.08)
    end
end)

-- ====================================================
-- FEATURE 4: AUTO REBIRTH
-- ====================================================
task.spawn(function()
    while true do
        if Toggles.AutoRebirth and isAlive() then
            pcall(function()
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "rebirth") or string.find(rName, "prestige") or string.find(rName, "ascend") then
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer(1)
                            else
                                remote:InvokeServer(1)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(2)
    end
end)

-- ====================================================
-- FEATURE 5: AUTO HATCH / OPEN EGG
-- ====================================================
task.spawn(function()
    while true do
        if Toggles.AutoHatch and isAlive() then
            pcall(function()
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "openegg") or string.find(rName, "hatchegg") or string.find(rName, "buyegg") or string.find(rName, "eggopen") then
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer("Egg1", 1)
                                remote:FireServer(1)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ====================================================
-- FEATURE 6: AUTO EQUIP BEST PETS
-- ====================================================
task.spawn(function()
    while true do
        if Toggles.AutoEquipBest and isAlive() then
            pcall(function()
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "equipbest") or string.find(rName, "bestpet") or string.find(rName, "autoequip") or string.find(rName, "equippet") then
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer()
                            else
                                remote:InvokeServer()
                            end
                        end
                    end
                end
            end)
        end
        task.wait(3)
    end
end)

-- ====================================================
-- FEATURE 7: AUTO CLAIM FREE GIFTS
-- ====================================================
task.spawn(function()
    while true do
        if Toggles.AutoClaimGifts and isAlive() then
            pcall(function()
                -- Claim timed gifts 1-12 & daily rewards & spin wheel
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "gift") or string.find(rName, "daily") or string.find(rName, "reward") or string.find(rName, "spin") or string.find(rName, "wheel") or string.find(rName, "free") then
                            for i = 1, 12 do
                                if remote:IsA("RemoteEvent") then
                                    remote:FireServer(i)
                                    remote:FireServer(tostring(i))
                                else
                                    remote:InvokeServer(i)
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
-- FEATURE 8: TELEPORT TO ZONES / WORLDS
-- ====================================================
local function teleportToZone()
    pcall(function()
        if not isAlive() then return end
        local hrp = LocalPlayer.Character.HumanoidRootPart

        -- Scan Workspace for zones, egg pedestals, world spawns
        local targetCFrame = nil
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local oName = string.lower(obj.Name)
                if string.find(oName, "zone") or string.find(oName, "world") or string.find(oName, "eggarea") or string.find(oName, "stage") then
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
            ShowNotification("Teleport", "Teleported to Zone!")
        else
            -- Default forward boost
            hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 50
            ShowNotification("Teleport", "Teleported forward!")
        end
    end)
end

-- ====================================================
-- FEATURE 9: WALKSPEED BOOST (+ / - CONTROLLER)
-- ====================================================
task.spawn(function()
    while true do
        if Toggles.WalkSpeedBoost and isAlive() then
            pcall(function()
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= CustomSpeedValue then
                    hum.WalkSpeed = CustomSpeedValue
                end
            end)
        end
        task.wait(0.2)
    end
end)

-- ====================================================
-- FEATURE 10: INFINITE JUMP
-- ====================================================
pcall(function()
    UIS.JumpRequest:Connect(function()
        if Toggles.InfiniteJump and isAlive() then
            pcall(function()
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)
end)

-- ====================================================
-- FEATURE 11: NOCLIP
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
-- ====================================================
local function BuildJunejoUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "JunejoHubUI_PullAnEgg"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Secure Parent Helper
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Main Container Frame (UI 1 Standard: 280px width, Matte Dark)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 280, 0, 440)
    MainFrame.Position = UDim2.new(0.5, -140, 0.5, -220)
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

    -- Smooth Dragging System (PC Mouse & Mobile Touch)
    local dragging, dragInput, dragStart, startPos
    local function updateDrag(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

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

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)

    -- Header Frame
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Name = "Title"
    HeaderTitle.Size = UDim2.new(1, -70, 0, 20)
    HeaderTitle.Position = UDim2.new(0, 12, 0, 4)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = "ULTRA SCRIPT HUB"
    HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeaderTitle.TextSize = 13
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(1, -70, 0, 14)
    Subtitle.Position = UDim2.new(0, 12, 0, 23)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Pull an Egg  •  Made by Junejo"
    Subtitle.TextColor3 = Color3.fromRGB(136, 136, 153)
    Subtitle.TextSize = 10
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = Header

    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Name = "MinBtn"
    MinBtn.Size = UDim2.new(0, 22, 0, 22)
    MinBtn.Position = UDim2.new(1, -50, 0, 10)
    MinBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    MinBtn.TextSize = 13
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = Header

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 5)
    MinCorner.Parent = MinBtn

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 22, 0, 22)
    CloseBtn.Position = UDim2.new(1, -26, 0, 10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = Header

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 5)
    CloseCorner.Parent = CloseBtn

    local HeaderDivider = Instance.new("Frame")
    HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
    HeaderDivider.Position = UDim2.new(0, 0, 1, -1)
    HeaderDivider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    HeaderDivider.BorderSizePixel = 0
    HeaderDivider.Parent = Header

    -- Scrollable Content Container for Toggles
    local ScrollContainer = Instance.new("ScrollingFrame")
    ScrollContainer.Name = "ScrollContainer"
    ScrollContainer.Size = UDim2.new(1, 0, 1, -66)
    ScrollContainer.Position = UDim2.new(0, 0, 0, 42)
    ScrollContainer.BackgroundTransparency = 1
    ScrollContainer.BorderSizePixel = 0
    ScrollContainer.ScrollBarThickness = 2
    ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 440)
    ScrollContainer.Parent = MainFrame

    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 2)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = ScrollContainer

    local UIPad = Instance.new("UIPadding")
    UIPad.PaddingTop = UDim.new(0, 4)
    UIPad.PaddingBottom = UDim.new(0, 4)
    UIPad.PaddingLeft = UDim.new(0, 8)
    UIPad.PaddingRight = UDim.new(0, 8)
    UIPad.Parent = ScrollContainer

    -- Mandatory Footer (Junejo UI 1 Standard)
    local Footer = Instance.new("Frame")
    Footer.Name = "Footer"
    Footer.Size = UDim2.new(1, 0, 0, 24)
    Footer.Position = UDim2.new(0, 0, 1, -24)
    Footer.BackgroundColor3 = Color3.fromRGB(13, 13, 15)
    Footer.BorderSizePixel = 0
    Footer.Parent = MainFrame

    local FooterDivider = Instance.new("Frame")
    FooterDivider.Size = UDim2.new(1, 0, 0, 1)
    FooterDivider.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    FooterDivider.BorderSizePixel = 0
    FooterDivider.Parent = Footer

    local FooterText = Instance.new("TextLabel")
    FooterText.Size = UDim2.new(1, 0, 1, 0)
    FooterText.BackgroundTransparency = 1
    FooterText.Text = "ULTRA SCRIPT HUB  |  Made by Junejo"
    FooterText.TextColor3 = Color3.fromRGB(110, 110, 125)
    FooterText.TextSize = 9
    FooterText.Font = Enum.Font.GothamMedium
    FooterText.Parent = Footer

    -- Toggle Creator Function (Classic Square Checkbox UI 1 Standard)
    local function CreateToggleRow(order, labelText, toggleKey, onToggle)
        local Row = Instance.new("Frame")
        Row.Name = "Row_" .. toggleKey
        Row.Size = UDim2.new(1, 0, 0, 30)
        Row.BackgroundTransparency = 1
        Row.LayoutOrder = order
        Row.Parent = ScrollContainer

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -34, 1, 0)
        Label.Position = UDim2.new(0, 4, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = labelText
        Label.TextColor3 = Color3.fromRGB(220, 220, 230)
        Label.TextSize = 11
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Row

        local Box = Instance.new("TextButton")
        Box.Name = "Box"
        Box.Size = UDim2.new(0, 18, 0, 18)
        Box.Position = UDim2.new(1, -22, 0.5, -9)
        Box.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
        Box.BorderSizePixel = 0
        Box.Text = ""
        Box.AutoButtonColor = false
        Box.Parent = Row

        local BoxCorner = Instance.new("UICorner")
        BoxCorner.CornerRadius = UDim.new(0, 4)
        BoxCorner.Parent = Box

        local BoxStroke = Instance.new("UIStroke")
        BoxStroke.Color = Color3.fromRGB(45, 45, 55)
        BoxStroke.Thickness = 1
        BoxStroke.Parent = Box

        local Checkmark = Instance.new("Frame")
        Checkmark.Name = "Checkmark"
        Checkmark.Size = UDim2.new(0, 10, 0, 10)
        Checkmark.Position = UDim2.new(0.5, -5, 0.5, -5)
        Checkmark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Checkmark.BorderSizePixel = 0
        Checkmark.Visible = Toggles[toggleKey] or false
        Checkmark.Parent = Box

        local CheckCorner = Instance.new("UICorner")
        CheckCorner.CornerRadius = UDim.new(0, 2)
        CheckCorner.Parent = Checkmark

        local function setChecked(val)
            Toggles[toggleKey] = val
            Checkmark.Visible = val
            if val then
                Box.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                BoxStroke.Color = Color3.fromRGB(100, 100, 120)
                Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                Box.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
                BoxStroke.Color = Color3.fromRGB(45, 45, 55)
                Label.TextColor3 = Color3.fromRGB(220, 220, 230)
            end
            if onToggle then onToggle(val) end
        end

        Box.MouseButton1Click:Connect(function()
            setChecked(not Toggles[toggleKey])
        end)

        return Row
    end

    -- Action Button Creator (for Instant Action like Teleport)
    local function CreateActionButtonRow(order, labelText, btnText, onClick)
        local Row = Instance.new("Frame")
        Row.Name = "ActionRow_" .. order
        Row.Size = UDim2.new(1, 0, 0, 30)
        Row.BackgroundTransparency = 1
        Row.LayoutOrder = order
        Row.Parent = ScrollContainer

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -74, 1, 0)
        Label.Position = UDim2.new(0, 4, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = labelText
        Label.TextColor3 = Color3.fromRGB(220, 220, 230)
        Label.TextSize = 11
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Row

        local ActionBtn = Instance.new("TextButton")
        ActionBtn.Size = UDim2.new(0, 60, 0, 20)
        ActionBtn.Position = UDim2.new(1, -64, 0.5, -10)
        ActionBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        ActionBtn.Text = btnText
        ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ActionBtn.TextSize = 10
        ActionBtn.Font = Enum.Font.GothamBold
        ActionBtn.BorderSizePixel = 0
        ActionBtn.Parent = Row

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 4)
        BtnCorner.Parent = ActionBtn

        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = Color3.fromRGB(55, 55, 68)
        BtnStroke.Thickness = 1
        BtnStroke.Parent = ActionBtn

        ActionBtn.MouseButton1Click:Connect(function()
            if onClick then onClick() end
        end)

        return Row
    end

    -- Speed Controller Creator (Integrated - / + Pill Stepper UI 1 Standard)
    local function CreateSpeedControllerRow(order)
        local Row = Instance.new("Frame")
        Row.Name = "Row_SpeedController"
        Row.Size = UDim2.new(1, 0, 0, 32)
        Row.BackgroundTransparency = 1
        Row.LayoutOrder = order
        Row.Parent = ScrollContainer

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0, 110, 1, 0)
        Label.Position = UDim2.new(0, 4, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = "WalkSpeed Boost"
        Label.TextColor3 = Color3.fromRGB(220, 220, 230)
        Label.TextSize = 11
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Row

        -- Pill Container (105px x 22px, #1B1B20)
        local Pill = Instance.new("Frame")
        Pill.Name = "SpeedPill"
        Pill.Size = UDim2.new(0, 105, 0, 22)
        Pill.Position = UDim2.new(1, -109, 0.5, -11)
        Pill.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
        Pill.BorderSizePixel = 0
        Pill.Parent = Row

        local PillCorner = Instance.new("UICorner")
        PillCorner.CornerRadius = UDim.new(0, 6)
        PillCorner.Parent = Pill

        local PillStroke = Instance.new("UIStroke")
        PillStroke.Color = Color3.fromRGB(45, 45, 55)
        PillStroke.Thickness = 1
        PillStroke.Parent = Pill

        -- Minus Button
        local MinusBtn = Instance.new("TextButton")
        MinusBtn.Size = UDim2.new(0, 22, 1, 0)
        MinusBtn.Position = UDim2.new(0, 0, 0, 0)
        MinusBtn.BackgroundTransparency = 1
        MinusBtn.Text = "-"
        MinusBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
        MinusBtn.TextSize = 13
        MinusBtn.Font = Enum.Font.GothamBold
        MinusBtn.Parent = Pill

        -- Value Display
        local ValLabel = Instance.new("TextLabel")
        ValLabel.Size = UDim2.new(1, -44, 1, 0)
        ValLabel.Position = UDim2.new(0, 22, 0, 0)
        ValLabel.BackgroundTransparency = 1
        ValLabel.Text = tostring(CustomSpeedValue)
        ValLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ValLabel.TextSize = 11
        ValLabel.Font = Enum.Font.GothamBold
        ValLabel.Parent = Pill

        -- Plus Button
        local PlusBtn = Instance.new("TextButton")
        PlusBtn.Size = UDim2.new(0, 22, 1, 0)
        PlusBtn.Position = UDim2.new(1, -22, 0, 0)
        PlusBtn.BackgroundTransparency = 1
        PlusBtn.Text = "+"
        PlusBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
        PlusBtn.TextSize = 13
        PlusBtn.Font = Enum.Font.GothamBold
        PlusBtn.Parent = Pill

        MinusBtn.MouseButton1Click:Connect(function()
            CustomSpeedValue = math.max(16, CustomSpeedValue - 5)
            ValLabel.Text = tostring(CustomSpeedValue)
            if Toggles.WalkSpeedBoost and isAlive() then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = CustomSpeedValue
            end
        end)

        PlusBtn.MouseButton1Click:Connect(function()
            CustomSpeedValue = math.min(250, CustomSpeedValue + 5)
            ValLabel.Text = tostring(CustomSpeedValue)
            if Toggles.WalkSpeedBoost and isAlive() then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = CustomSpeedValue
            end
        end)

        -- Quick Toggle on Pill click
        ValLabel.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
                if Toggles.WalkSpeedBoost then
                    PillStroke.Color = Color3.fromRGB(100, 100, 120)
                    Pill.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                    ShowNotification("Speed", "WalkSpeed Boost ON (" .. CustomSpeedValue .. ")")
                else
                    PillStroke.Color = Color3.fromRGB(45, 45, 55)
                    Pill.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
                    if isAlive() then LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end
                    ShowNotification("Speed", "WalkSpeed Reset to Normal")
                end
            end
        end)

        return Row
    end

    -- ====================================================
    -- POPULATING THE 11 FEATURES IN UI
    -- ====================================================
    CreateToggleRow(1, "Remove Guard", "RemoveGuard", function(v)
        if v then
            applyRemoveGuard()
            ShowNotification("Guard", "Security Guards Removed!")
        end
    end)

    CreateToggleRow(2, "Auto Pull Egg", "AutoPullEgg", function(v)
        ShowNotification("Auto Pull", v and "Auto Pull Enabled!" or "Auto Pull Disabled")
    end)

    CreateToggleRow(3, "Auto Train / Click", "AutoTrain", function(v)
        ShowNotification("Auto Train", v and "Training Farm Started!" or "Training Stopped")
    end)

    CreateToggleRow(4, "Auto Rebirth", "AutoRebirth", function(v)
        ShowNotification("Auto Rebirth", v and "Auto Rebirth ON" or "Auto Rebirth OFF")
    end)

    CreateToggleRow(5, "Auto Hatch / Open Egg", "AutoHatch", function(v)
        ShowNotification("Auto Hatch", v and "Hatching Started!" or "Hatching Stopped")
    end)

    CreateToggleRow(6, "Auto Equip Best Pets", "AutoEquipBest", function(v)
        ShowNotification("Pets", v and "Auto Equip Best ON" or "Auto Equip Best OFF")
    end)

    CreateToggleRow(7, "Auto Claim Free Gifts", "AutoClaimGifts", function(v)
        ShowNotification("Gifts", v and "Auto Claim Gifts ON" or "Auto Claim Gifts OFF")
    end)

    CreateActionButtonRow(8, "Teleport to Zones", "TP Zone", function()
        teleportToZone()
    end)

    CreateSpeedControllerRow(9)

    CreateToggleRow(10, "Infinite Jump", "InfiniteJump", function(v)
        ShowNotification("Inf Jump", v and "Infinite Jump Enabled!" or "Infinite Jump Disabled")
    end)

    CreateToggleRow(11, "Noclip", "Noclip", function(v)
        ShowNotification("Noclip", v and "Noclip Enabled!" or "Noclip Disabled")
        if not v and isAlive() then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end)

    -- Window Minimize / Toggle Logic
    local isMinimized = false
    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            ScrollContainer.Visible = false
            Footer.Visible = false
            MainFrame.Size = UDim2.new(0, 280, 0, 42)
            MinBtn.Text = "+"
        else
            ScrollContainer.Visible = true
            Footer.Visible = true
            MainFrame.Size = UDim2.new(0, 280, 0, 440)
            MinBtn.Text = "-"
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    ShowNotification("Ultra Script Hub", "Pull an Egg Script Loaded!")
end

-- Initialize UI
BuildJunejoUI()
