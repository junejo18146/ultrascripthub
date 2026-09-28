--[[
    ========================================================================
    ULTRA SCRIPT HUB - OFFICIAL PRODUCTION SCRIPT
    ========================================================================
    Game: Steal An Egg 🥚
    Creator: Made by Junejo (junejo18146)
    UI Style: UI 3 (Wide Tabbed Category Hub - 340px x 220px)
    GitHub: https://github.com/junejo18146/ultrascripthub
    Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/junejo18146/ultrascripthub/main/steal_an_egg.lua"))()
    ========================================================================
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Safe Parent Selection
local function GetSafeGuiParent()
    local target = nil
    pcall(function()
        if gethui then
            target = gethui()
        elseif CoreGui and pcall(function() return CoreGui.Name end) then
            local test = Instance.new("Folder")
            test.Parent = CoreGui
            test:Destroy()
            target = CoreGui
        end
    end)
    if not target then
        target = LocalPlayer:WaitForChild("PlayerGui")
    end
    return target
end

local GuiParent = GetSafeGuiParent()

-- Cleanup Existing Instances
pcall(function()
    for _, name in ipairs({"UltraScriptHub_StealAnEgg", "JunejoHubUI_StealAnEgg", "Junejo_StealAnEgg_UI3"}) do
        if GuiParent:FindFirstChild(name) then GuiParent[name]:Destroy() end
        if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end
end)

-- Global Feature State
local State = {
    AutoSteal = false,
    AutoDeliver = false,
    AutoHatch = false,
    AutoTrain = false,
    EggESP = false,
    GuardianESP = false,
    WalkSpeed = false,
    WalkSpeedValue = 50,
    InfiniteJump = false
}

local SavedBaseCFrame = nil

local function getRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function getHum()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- Save initial spawn / base CFrame
task.spawn(function()
    task.wait(1)
    local root = getRoot()
    if root and not SavedBaseCFrame then
        SavedBaseCFrame = root.CFrame
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.2)
    local root = getRoot()
    if root and not SavedBaseCFrame then
        SavedBaseCFrame = root.CFrame
    end
end)

-- Helper: Trigger Proximity Prompts
local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.1)
            prompt:InputHoldEnd()
        end
    end)
end

-- =================================================================
-- RAREST EGG DETECTION ENGINE
-- =================================================================
local RarityKeywords = {
    { word = "secret", score = 100000 },
    { word = "divine", score = 80000 },
    { word = "angel", score = 70000 },
    { word = "demon", score = 65000 },
    { word = "godly", score = 60000 },
    { word = "void", score = 50000 },
    { word = "celestial", score = 40000 },
    { word = "mythic", score = 30000 },
    { word = "legendary", score = 20000 },
    { word = "epic", score = 10000 },
    { word = "rare", score = 5000 },
    { word = "uncommon", score = 2000 },
    { word = "common", score = 500 },
}

local function CalculateRarityScore(instance)
    local score = 0
    local textBlob = string.lower(instance.Name)

    if instance.Parent then
        textBlob = textBlob .. " " .. string.lower(instance.Parent.Name)
        if instance.Parent.Parent then
            textBlob = textBlob .. " " .. string.lower(instance.Parent.Parent.Name)
        end
    end

    for _, desc in ipairs(instance:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
            textBlob = textBlob .. " " .. string.lower(desc.Text)
        elseif desc:IsA("ProximityPrompt") then
            textBlob = textBlob .. " " .. string.lower(desc.ActionText or "") .. " " .. string.lower(desc.ObjectText or "")
        end
    end

    pcall(function()
        for attrName, attrVal in pairs(instance:GetAttributes()) do
            textBlob = textBlob .. " " .. string.lower(tostring(attrName)) .. " " .. string.lower(tostring(attrVal))
            if type(attrVal) == "number" and attrVal > score then
                score = math.max(score, attrVal)
            end
        end
    end)

    for _, kw in ipairs(RarityKeywords) do
        if string.find(textBlob, kw.word) then
            score = math.max(score, kw.score)
        end
    end

    local primary = instance:IsA("BasePart") and instance or instance:FindFirstChildWhichIsA("BasePart")
    if primary then
        local dist = (primary.Position - Vector3.new(0, primary.Position.Y, 0)).Magnitude
        score = score + math.floor(dist * 2)
    end

    return score
end

local function FindRarestEgg()
    local bestEggPart = nil
    local bestPrompt = nil
    local highestScore = -1

    -- Pass 1: ProximityPrompts for stealing eggs
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local pName = string.lower(obj.Parent and obj.Parent.Name or "")
            local aText = string.lower(obj.ActionText or "")
            local oText = string.lower(obj.ObjectText or "")

            if string.find(pName, "egg") or string.find(aText, "steal") or string.find(aText, "take") or string.find(oText, "egg") then
                local parent = obj.Parent
                local part = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart")
                if part then
                    local score = CalculateRarityScore(parent)
                    if score > highestScore then
                        highestScore = score
                        bestEggPart = part
                        bestPrompt = obj
                    end
                end
            end
        end
    end

    -- Pass 2: BaseParts / Models named Egg if no prompt found
    if not bestEggPart then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart")) and string.find(string.lower(obj.Name), "egg") and obj ~= LocalPlayer.Character then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local score = CalculateRarityScore(obj)
                    if score > highestScore then
                        highestScore = score
                        bestEggPart = part
                        bestPrompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    end
                end
            end
        end
    end

    return bestEggPart, bestPrompt
end

-- =================================================================
-- FEATURE ENGINES
-- =================================================================

-- 1. Auto Steal Eggs Engine (Prioritizes Rarest Egg)
task.spawn(function()
    while true do
        task.wait(0.35)
        if State.AutoSteal then
            pcall(function()
                local root = getRoot()
                if root then
                    local rarestPart, rarestPrompt = FindRarestEgg()
                    if rarestPart then
                        root.CFrame = rarestPart.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.12)
                        if rarestPrompt then
                            triggerPrompt(rarestPrompt)
                        else
                            local prompt = rarestPart.Parent:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt then triggerPrompt(prompt) end
                        end
                        task.wait(0.12)

                        if State.AutoDeliver and SavedBaseCFrame then
                            root.CFrame = SavedBaseCFrame
                            task.wait(0.25)
                        end
                    else
                        -- Fallback to any egg prompt
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if not State.AutoSteal then break end
                            if obj:IsA("ProximityPrompt") then
                                local parentName = string.lower(obj.Parent and obj.Parent.Name or "")
                                local actionText = string.lower(obj.ActionText or "")
                                local objText = string.lower(obj.ObjectText or "")

                                if string.find(parentName, "egg") or string.find(actionText, "steal") or string.find(actionText, "take") or string.find(objText, "egg") then
                                    local targetPart = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                                    if targetPart then
                                        root.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                                        task.wait(0.12)
                                        triggerPrompt(obj)
                                        task.wait(0.12)
                                        if State.AutoDeliver and SavedBaseCFrame then
                                            root.CFrame = SavedBaseCFrame
                                            task.wait(0.2)
                                        end
                                        break
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

-- 2. Auto Deliver to Base Engine
task.spawn(function()
    while true do
        task.wait(0.4)
        if State.AutoDeliver and not State.AutoSteal then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hasEgg = false
                    for _, child in ipairs(char:GetChildren()) do
                        local cName = string.lower(child.Name)
                        if child:IsA("Tool") or string.find(cName, "egg") then
                            hasEgg = true
                            break
                        end
                    end
                    if hasEgg and SavedBaseCFrame then
                        local root = getRoot()
                        if root then
                            root.CFrame = SavedBaseCFrame
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. Auto Hatch Eggs Engine
task.spawn(function()
    while true do
        task.wait(0.4)
        if State.AutoHatch then
            pcall(function()
                for _, container in ipairs({ReplicatedStorage, LocalPlayer:FindFirstChild("PlayerGui"), Workspace}) do
                    if container then
                        for _, remote in ipairs(container:GetDescendants()) do
                            if not State.AutoHatch then break end
                            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                local rName = string.lower(remote.Name)
                                if string.find(rName, "hatch") or string.find(rName, "openegg") or string.find(rName, "egghatch") or string.find(rName, "place") then
                                    pcall(function()
                                        if remote:IsA("RemoteEvent") then
                                            remote:FireServer()
                                            remote:FireServer(true)
                                            remote:FireServer(1)
                                        else
                                            remote:InvokeServer()
                                            remote:InvokeServer(true)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not State.AutoHatch then break end
                    if obj:IsA("ProximityPrompt") then
                        local aText = string.lower(obj.ActionText or "")
                        local oText = string.lower(obj.ObjectText or "")
                        if string.find(aText, "hatch") or string.find(aText, "place") or string.find(oText, "hatch") then
                            triggerPrompt(obj)
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. Auto Train Speed Engine (Robust Multi-Method Implementation)
task.spawn(function()
    while true do
        task.wait(0.1)
        if State.AutoTrain then
            pcall(function()
                local char = LocalPlayer.Character
                local root = getRoot()
                if not char or not root then return end

                local feet = {
                    root,
                    char:FindFirstChild("LeftFoot"),
                    char:FindFirstChild("RightFoot"),
                    char:FindFirstChild("Left Leg"),
                    char:FindFirstChild("Right Leg")
                }

                -- Method A: Touch & ProximityPrompts on Treadmills
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not State.AutoTrain then break end
                    local oName = string.lower(obj.Name)
                    local pName = string.lower(obj.Parent and obj.Parent.Name or "")

                    if string.find(oName, "treadmill") or string.find(oName, "train") or string.find(oName, "speed") or string.find(oName, "pad")
                    or string.find(pName, "treadmill") or string.find(pName, "train") then
                        if obj:IsA("BasePart") then
                            if firetouchinterest then
                                for _, part in ipairs(feet) do
                                    if part then
                                        firetouchinterest(obj, part, 0)
                                        task.wait()
                                        firetouchinterest(obj, part, 1)
                                    end
                                end
                            end
                        elseif obj:IsA("ProximityPrompt") then
                            local aText = string.lower(obj.ActionText or "")
                            local oText = string.lower(obj.ObjectText or "")
                            if string.find(aText, "train") or string.find(aText, "run") or string.find(aText, "speed")
                            or string.find(oText, "treadmill") or string.find(oText, "speed") then
                                triggerPrompt(obj)
                            end
                        end
                    end
                end

                -- Method B: Fire All Training / Speed Remotes
                for _, container in ipairs({ReplicatedStorage, LocalPlayer:FindFirstChild("PlayerGui"), Workspace}) do
                    if container then
                        for _, remote in ipairs(container:GetDescendants()) do
                            if not State.AutoTrain then break end
                            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                local rName = string.lower(remote.Name)
                                if string.find(rName, "train") or string.find(rName, "treadmill") or string.find(rName, "addspeed")
                                or string.find(rName, "speed") or string.find(rName, "step") or string.find(rName, "click")
                                or string.find(rName, "workout") or string.find(rName, "exercise") or string.find(rName, "run") then
                                    pcall(function()
                                        if remote:IsA("RemoteEvent") then
                                            remote:FireServer()
                                            remote:FireServer(true)
                                            remote:FireServer(1)
                                            remote:FireServer("Treadmill")
                                            remote:FireServer("Train")
                                        else
                                            remote:InvokeServer()
                                            remote:InvokeServer(true)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end

                -- Method C: Virtual Click Simulation (For click-based treadmill training)
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(0, 0))
                    task.wait(0.02)
                    VirtualUser:Button1Up(Vector2.new(0, 0))
                end)
            end)
        end
    end
end)

-- 5. ESP System (Eggs & Guardians)
local ActiveEggESP = {}
local ActiveGuardianESP = {}

local function ClearESPTable(t)
    for obj, esp in pairs(t) do
        pcall(function()
            if esp.Highlight then esp.Highlight:Destroy() end
            if esp.Billboard then esp.Billboard:Destroy() end
        end)
    end
    table.clear(t)
end

local function CreateHighlightESP(modelOrPart, color, labelText)
    local highlight = Instance.new("Highlight")
    highlight.Name = "Junejo_ESP"
    highlight.Adornee = modelOrPart
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = modelOrPart

    local primary = modelOrPart:IsA("BasePart") and modelOrPart or modelOrPart:FindFirstChildWhichIsA("BasePart")
    local billboard = nil
    if primary then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "Junejo_Billboard"
        billboard.Adornee = primary
        billboard.Size = UDim2.new(0, 100, 0, 20)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = labelText
        textLabel.TextColor3 = color
        textLabel.TextStrokeTransparency = 0.2
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 11
        textLabel.Parent = billboard

        billboard.Parent = primary
    end

    return { Highlight = highlight, Billboard = billboard }
end

task.spawn(function()
    while true do
        task.wait(1.5)
        if State.EggESP then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not State.EggESP then break end
                    local oName = string.lower(obj.Name)
                    if (string.find(oName, "egg") or string.find(oName, "nest")) and (obj:IsA("Model") or obj:IsA("BasePart")) then
                        if not ActiveEggESP[obj] and obj ~= LocalPlayer.Character then
                            ActiveEggESP[obj] = CreateHighlightESP(obj, Color3.fromRGB(255, 215, 0), "🥚 " .. obj.Name)
                        end
                    end
                end
            end)
        else
            if next(ActiveEggESP) ~= nil then
                ClearESPTable(ActiveEggESP)
            end
        end

        if State.GuardianESP then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not State.GuardianESP then break end
                    local oName = string.lower(obj.Name)
                    if (string.find(oName, "guard") or string.find(oName, "boss") or string.find(oName, "monster") or string.find(oName, "enemy")) and (obj:IsA("Model") or obj:IsA("BasePart")) then
                        if not ActiveGuardianESP[obj] and obj ~= LocalPlayer.Character then
                            ActiveGuardianESP[obj] = CreateHighlightESP(obj, Color3.fromRGB(255, 50, 75), "⚠️ " .. obj.Name)
                        end
                    end
                end
            end)
        else
            if next(ActiveGuardianESP) ~= nil then
                ClearESPTable(ActiveGuardianESP)
            end
        end
    end
end)

-- 6. WalkSpeed Loop
RunService.RenderStepped:Connect(function()
    pcall(function()
        local hum = getHum()
        if hum then
            if State.WalkSpeed then
                hum.WalkSpeed = State.WalkSpeedValue
            else
                if hum.WalkSpeed == State.WalkSpeedValue then
                    hum.WalkSpeed = 16
                end
            end
        end
    end)
end)

-- 7. Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        pcall(function()
            local hum = getHum()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- =================================================================
-- UI 3: WIDE TABBED CATEGORY HUB (340px x 220px)
-- Theme: Technical Dark #0F1016, Border #242738, Accent #9D4EDD
-- Button Style: Purple Status Chip Button (Pill chip + dot + dynamic ON/OFF)
-- Stepper: Embedded Stepper Pill (95x22px)
-- Corner Geometry: 4px Micro Curve
-- No Hub Footer
-- =================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Junejo_StealAnEgg_UI3"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 220)
MainFrame.Position = UDim2.new(0.5, -170, 0.45, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 4)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(36, 39, 56)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- Draggable Logic
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

-- Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 28)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

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
        updateInput(input)
    end
end)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "STEAL AN EGG"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -26, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 155, 175)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

CloseBtn.MouseEnter:Connect(function()
    CloseBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
end)

CloseBtn.MouseLeave:Connect(function()
    CloseBtn.TextColor3 = Color3.fromRGB(150, 155, 175)
end)

local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.Size = UDim2.new(1, -24, 0, 1)
Divider.Position = UDim2.new(0, 12, 0, 28)
Divider.BackgroundColor3 = Color3.fromRGB(36, 39, 56)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- Tabs Navigation Bar
local TabsBar = Instance.new("Frame")
TabsBar.Name = "TabsBar"
TabsBar.Size = UDim2.new(1, -24, 0, 24)
TabsBar.Position = UDim2.new(0, 12, 0, 34)
TabsBar.BackgroundTransparency = 1
TabsBar.Parent = MainFrame

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.FillDirection = Enum.FillDirection.Horizontal
TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 4)
TabsLayout.Parent = TabsBar

-- Content Pages Container
local PagesContainer = Instance.new("Frame")
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -24, 1, -66)
PagesContainer.Position = UDim2.new(0, 12, 0, 62)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

local TabButtons = {}
local TabPages = {}

local function SwitchTab(tabName)
    for name, btn in pairs(TabButtons) do
        local page = TabPages[name]
        if name == tabName then
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(43, 48, 71)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            local stroke = btn:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = Color3.fromRGB(157, 78, 221) end
        else
            page.Visible = false
            btn.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
            btn.TextColor3 = Color3.fromRGB(131, 138, 164)
            local stroke = btn:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = Color3.fromRGB(38, 42, 60) end
        end
    end
end

local function CreateTab(tabName, layoutOrder)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabName .. "Tab"
    tabBtn.Size = UDim2.new(0.24, -3, 1, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Color3.fromRGB(131, 138, 164)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 10
    tabBtn.LayoutOrder = layoutOrder
    tabBtn.BorderSizePixel = 0
    tabBtn.Parent = TabsBar

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 3)
    tabCorner.Parent = tabBtn

    local tabStroke = Instance.new("UIStroke")
    tabStroke.Thickness = 1
    tabStroke.Color = Color3.fromRGB(38, 42, 60)
    tabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    tabStroke.Parent = tabBtn

    local page = Instance.new("Frame")
    page.Name = tabName .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = PagesContainer

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.FillDirection = Enum.FillDirection.Vertical
    pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pageLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.Parent = page

    TabButtons[tabName] = tabBtn
    TabPages[tabName] = page

    tabBtn.MouseButton1Click:Connect(function()
        SwitchTab(tabName)
    end)

    return page
end

local FarmPage = CreateTab("FARM", 1)
local MovePage = CreateTab("MOVE", 2)
local VisualsPage = CreateTab("VISUALS", 3)
local TeleportPage = CreateTab("TELEPORT", 4)

-- Helper: UI 3 Purple Status Chip Toggle Row
local function CreateChipToggle(parentPage, text, defaultState, callback)
    local row = Instance.new("Frame")
    row.Name = text .. "_Row"
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.Parent = parentPage

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -75, 1, 0)
    label.Position = UDim2.new(0, 2, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(226, 228, 238)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local chipBtn = Instance.new("TextButton")
    chipBtn.Name = "ChipBtn"
    chipBtn.Size = UDim2.new(0, 60, 0, 22)
    chipBtn.Position = UDim2.new(1, -62, 0, 2)
    chipBtn.BackgroundColor3 = Color3.fromRGB(23, 24, 34)
    chipBtn.Text = ""
    chipBtn.BorderSizePixel = 0
    chipBtn.Parent = row

    local chipCorner = Instance.new("UICorner")
    chipCorner.CornerRadius = UDim.new(0, 4)
    chipCorner.Parent = chipBtn

    local chipStroke = Instance.new("UIStroke")
    chipStroke.Thickness = 1
    chipStroke.Color = Color3.fromRGB(39, 42, 59)
    chipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    chipStroke.Parent = chipBtn

    local dot = Instance.new("Frame")
    dot.Name = "Dot"
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 8, 0.5, -3)
    dot.BackgroundColor3 = Color3.fromRGB(80, 85, 108)
    dot.BorderSizePixel = 0
    dot.Parent = chipBtn

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local statusText = Instance.new("TextLabel")
    statusText.Name = "Status"
    statusText.Size = UDim2.new(1, -20, 1, 0)
    statusText.Position = UDim2.new(0, 18, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "OFF"
    statusText.TextColor3 = Color3.fromRGB(109, 115, 141)
    statusText.Font = Enum.Font.Code
    statusText.TextSize = 10
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = chipBtn

    local isEnabled = defaultState

    local function updateVisuals()
        if isEnabled then
            chipBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 48)
            chipStroke.Color = Color3.fromRGB(157, 78, 221)
            dot.BackgroundColor3 = Color3.fromRGB(199, 125, 255)
            statusText.Text = "ON"
            statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            chipBtn.BackgroundColor3 = Color3.fromRGB(23, 24, 34)
            chipStroke.Color = Color3.fromRGB(39, 42, 59)
            dot.BackgroundColor3 = Color3.fromRGB(80, 85, 108)
            statusText.Text = "OFF"
            statusText.TextColor3 = Color3.fromRGB(109, 115, 141)
        end
    end

    chipBtn.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        updateVisuals()
        pcall(callback, isEnabled)
    end)

    updateVisuals()
    return row
end

-- Helper: UI 3 Stepper WalkSpeed Row
local function CreateWalkSpeedRow(parentPage)
    local row = Instance.new("Frame")
    row.Name = "WalkSpeed_Row"
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.Parent = parentPage

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 85, 1, 0)
    label.Position = UDim2.new(0, 2, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "WalkSpeed"
    label.TextColor3 = Color3.fromRGB(226, 228, 238)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    -- Stepper Pill (95x22)
    local stepper = Instance.new("Frame")
    stepper.Name = "Stepper"
    stepper.Size = UDim2.new(0, 95, 0, 22)
    stepper.Position = UDim2.new(1, -162, 0, 2)
    stepper.BackgroundColor3 = Color3.fromRGB(23, 24, 34)
    stepper.BorderSizePixel = 0
    stepper.Parent = row

    local stepCorner = Instance.new("UICorner")
    stepCorner.CornerRadius = UDim.new(0, 4)
    stepCorner.Parent = stepper

    local stepStroke = Instance.new("UIStroke")
    stepStroke.Thickness = 1
    stepStroke.Color = Color3.fromRGB(39, 42, 59)
    stepStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stepStroke.Parent = stepper

    local minusBtn = Instance.new("TextButton")
    minusBtn.Name = "Minus"
    minusBtn.Size = UDim2.new(0, 24, 1, 0)
    minusBtn.Position = UDim2.new(0, 0, 0, 0)
    minusBtn.BackgroundTransparency = 1
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.fromRGB(150, 155, 175)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 13
    minusBtn.Parent = stepper

    local valLabel = Instance.new("TextLabel")
    valLabel.Name = "Value"
    valLabel.Size = UDim2.new(1, -48, 1, 0)
    valLabel.Position = UDim2.new(0, 24, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(State.WalkSpeedValue)
    valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 11
    valLabel.Parent = stepper

    local plusBtn = Instance.new("TextButton")
    plusBtn.Name = "Plus"
    plusBtn.Size = UDim2.new(0, 24, 1, 0)
    plusBtn.Position = UDim2.new(1, -24, 0, 0)
    plusBtn.BackgroundTransparency = 1
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.fromRGB(150, 155, 175)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 13
    plusBtn.Parent = stepper

    -- Chip Toggle for Speed
    local chipBtn = Instance.new("TextButton")
    chipBtn.Name = "ChipBtn"
    chipBtn.Size = UDim2.new(0, 60, 0, 22)
    chipBtn.Position = UDim2.new(1, -62, 0, 2)
    chipBtn.BackgroundColor3 = Color3.fromRGB(23, 24, 34)
    chipBtn.Text = ""
    chipBtn.BorderSizePixel = 0
    chipBtn.Parent = row

    local chipCorner = Instance.new("UICorner")
    chipCorner.CornerRadius = UDim.new(0, 4)
    chipCorner.Parent = chipBtn

    local chipStroke = Instance.new("UIStroke")
    chipStroke.Thickness = 1
    chipStroke.Color = Color3.fromRGB(39, 42, 59)
    chipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    chipStroke.Parent = chipBtn

    local dot = Instance.new("Frame")
    dot.Name = "Dot"
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 8, 0.5, -3)
    dot.BackgroundColor3 = Color3.fromRGB(80, 85, 108)
    dot.BorderSizePixel = 0
    dot.Parent = chipBtn

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local statusText = Instance.new("TextLabel")
    statusText.Name = "Status"
    statusText.Size = UDim2.new(1, -20, 1, 0)
    statusText.Position = UDim2.new(0, 18, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "OFF"
    statusText.TextColor3 = Color3.fromRGB(109, 115, 141)
    statusText.Font = Enum.Font.Code
    statusText.TextSize = 10
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = chipBtn

    local function updateVisuals()
        if State.WalkSpeed then
            chipBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 48)
            chipStroke.Color = Color3.fromRGB(157, 78, 221)
            dot.BackgroundColor3 = Color3.fromRGB(199, 125, 255)
            statusText.Text = "ON"
            statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            chipBtn.BackgroundColor3 = Color3.fromRGB(23, 24, 34)
            chipStroke.Color = Color3.fromRGB(39, 42, 59)
            dot.BackgroundColor3 = Color3.fromRGB(80, 85, 108)
            statusText.Text = "OFF"
            statusText.TextColor3 = Color3.fromRGB(109, 115, 141)
        end
    end

    chipBtn.MouseButton1Click:Connect(function()
        State.WalkSpeed = not State.WalkSpeed
        updateVisuals()
    end)

    minusBtn.MouseButton1Click:Connect(function()
        State.WalkSpeedValue = math.max(16, State.WalkSpeedValue - 10)
        valLabel.Text = tostring(State.WalkSpeedValue)
    end)

    plusBtn.MouseButton1Click:Connect(function()
        State.WalkSpeedValue = math.min(300, State.WalkSpeedValue + 10)
        valLabel.Text = tostring(State.WalkSpeedValue)
    end)

    updateVisuals()
    return row
end

-- =================================================================
-- POPULATE PAGES
-- =================================================================

-- 1. Farm Page
CreateChipToggle(FarmPage, "Auto Steal Eggs", State.AutoSteal, function(v)
    State.AutoSteal = v
end)

CreateChipToggle(FarmPage, "Auto Deliver to Base", State.AutoDeliver, function(v)
    State.AutoDeliver = v
end)

CreateChipToggle(FarmPage, "Auto Hatch Eggs", State.AutoHatch, function(v)
    State.AutoHatch = v
end)

CreateChipToggle(FarmPage, "Auto Train Speed", State.AutoTrain, function(v)
    State.AutoTrain = v
end)

-- 2. Move Page
CreateWalkSpeedRow(MovePage)

CreateChipToggle(MovePage, "Infinite Jump", State.InfiniteJump, function(v)
    State.InfiniteJump = v
end)

-- 3. Visuals Page
CreateChipToggle(VisualsPage, "Egg ESP", State.EggESP, function(v)
    State.EggESP = v
end)

CreateChipToggle(VisualsPage, "Guardian ESP", State.GuardianESP, function(v)
    State.GuardianESP = v
end)

-- 4. Teleport Page (Action Buttons)
local function CreateActionButton(parentPage, text, callback)
    local btnRow = Instance.new("Frame")
    btnRow.Name = text .. "_Row"
    btnRow.Size = UDim2.new(1, 0, 0, 32)
    btnRow.BackgroundTransparency = 1
    btnRow.Parent = parentPage

    local actionBtn = Instance.new("TextButton")
    actionBtn.Name = "ActionBtn"
    actionBtn.Size = UDim2.new(1, 0, 0, 28)
    actionBtn.Position = UDim2.new(0, 0, 0, 2)
    actionBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
    actionBtn.Text = text
    actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextSize = 11
    actionBtn.BorderSizePixel = 0
    actionBtn.Parent = btnRow

    local actionCorner = Instance.new("UICorner")
    actionCorner.CornerRadius = UDim.new(0, 4)
    actionCorner.Parent = actionBtn

    local actionStroke = Instance.new("UIStroke")
    actionStroke.Thickness = 1
    actionStroke.Color = Color3.fromRGB(157, 78, 221)
    actionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    actionStroke.Parent = actionBtn

    actionBtn.MouseEnter:Connect(function()
        actionBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 48)
    end)

    actionBtn.MouseLeave:Connect(function()
        actionBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
    end)

    actionBtn.MouseButton1Click:Connect(function()
        pcall(callback, actionBtn)
    end)

    return actionBtn
end

-- Teleport to Safe Base Button
CreateActionButton(TeleportPage, "TELEPORT TO SAFE BASE", function(btn)
    local root = getRoot()
    if root then
        if SavedBaseCFrame then
            root.CFrame = SavedBaseCFrame
        else
            SavedBaseCFrame = root.CFrame
        end
        btn.Text = "TELEPORTED TO BASE!"
        task.wait(1)
        btn.Text = "TELEPORT TO SAFE BASE"
    end
end)

-- Teleport to Rare Egg Button
CreateActionButton(TeleportPage, "TELEPORT TO RARE EGG", function(btn)
    local root = getRoot()
    if root then
        local rarestPart = FindRarestEgg()
        if rarestPart then
            root.CFrame = rarestPart.CFrame + Vector3.new(0, 4, 0)
            btn.Text = "WARPED TO RARE EGG!"
            task.wait(1)
            btn.Text = "TELEPORT TO RARE EGG"
        else
            btn.Text = "NO EGG FOUND!"
            task.wait(1)
            btn.Text = "TELEPORT TO RARE EGG"
        end
    end
end)

-- Set Default Active Tab
SwitchTab("FARM")

print("[ULTRA SCRIPT HUB] Steal An Egg loaded successfully with UI 3 (Wide Tabbed Category Hub).")
