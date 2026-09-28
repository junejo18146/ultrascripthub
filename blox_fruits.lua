--[[
    ========================================================================
    ULTRA SCRIPT HUB - OFFICIAL PRODUCTION SCRIPT
    ========================================================================
    Game: Blox Fruits 🍎⚔️
    Creator: Made by Junejo (junejo18146)
    UI Style: UI 1 (Official Ultra Script Hub Classic Matte Dark - 280px)
    GitHub: https://github.com/junejo18146/ultrascripthub
    Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/junejo18146/ultrascripthub/main/blox_fruits.lua"))()
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
    for _, name in ipairs({"UltraScriptHub_BloxFruits", "JunejoHubUI_BloxFruits", "Junejo_BloxFruits_UI1"}) do
        if GuiParent:FindFirstChild(name) then GuiParent[name]:Destroy() end
        if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end
end)

-- Feature State Table
local Toggles = {
    FastAttack = false,
    AutoCollectFruits = false,
    AutoStoreFruits = false,
    AutoStats = false,
    FruitESP = false,
    PlayerESP = false,
    ChestESP = false,
    FlowerESP = false,
    BossESP = false,
    MirageESP = false,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

local CustomSpeedValue = 50

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

-- =================================================================
-- FEATURE ENGINES
-- =================================================================

-- Helper: Trigger Proximity Prompt
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

-- 1. Fast Attack Engine
task.spawn(function()
    while true do
        task.wait(0.08)
        if Toggles.FastAttack then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword" or tool:FindFirstChild("Damage") or tool:FindFirstChild("Handle")) then
                        tool:Activate()
                        pcall(function()
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(0, 0))
                            task.wait(0.01)
                            VirtualUser:Button1Up(Vector2.new(0, 0))
                        end)

                        -- Combat Remote Firing if present
                        local netModule = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
                        if netModule then
                            for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                                if remote:IsA("RemoteEvent") and (remote.Name == "RegisterAttack" or remote.Name == "RegisterHit") then
                                    remote:FireServer(0.05)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. Auto Collect Fruits Engine
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoCollectFruits then
            pcall(function()
                local root = getRoot()
                if root then
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if not Toggles.AutoCollectFruits then break end
                        local oName = string.lower(obj.Name)
                        if (string.find(oName, "fruit") or obj:GetAttribute("OriginalName")) and obj ~= LocalPlayer.Character then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if part then
                                root.CFrame = part.CFrame + Vector3.new(0, 2, 0)
                                task.wait(0.15)
                                if firetouchinterest then
                                    firetouchinterest(part, root, 0)
                                    task.wait()
                                    firetouchinterest(part, root, 1)
                                end
                                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then triggerPrompt(prompt) end
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. Auto Store Fruits Engine
task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.AutoStoreFruits then
            pcall(function()
                local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                if commF then
                    local char = LocalPlayer.Character
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    local containers = {char, bp}

                    for _, container in ipairs(containers) do
                        if container then
                            for _, tool in ipairs(container:GetChildren()) do
                                if tool:IsA("Tool") and string.find(string.lower(tool.Name), "fruit") then
                                    local fruitName = tool:GetAttribute("OriginalName") or tool.Name
                                    commF:InvokeServer("StoreFruit", fruitName, tool)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. Auto Stats Upgrade Engine
task.spawn(function()
    while true do
        task.wait(1)
        if Toggles.AutoStats then
            pcall(function()
                local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                if commF then
                    local points = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Points")
                    if points and points.Value > 0 then
                        local spend = math.min(points.Value, 5)
                        commF:InvokeServer("AddPoint", "Melee", spend)
                        commF:InvokeServer("AddPoint", "Defense", spend)
                    end
                end
            end)
        end
    end
end)

-- 5. ESP System (Fruits, Players, Chests, Flowers, Bosses, Mirage)
local ActiveESP = {
    Fruits = {},
    Players = {},
    Chests = {},
    Flowers = {},
    Bosses = {},
    Mirage = {}
}

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
        billboard.Size = UDim2.new(0, 110, 0, 20)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
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
        local root = getRoot()

        -- Fruit ESP
        if Toggles.FruitESP then
            pcall(function()
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if not Toggles.FruitESP then break end
                    local oName = string.lower(obj.Name)
                    if (string.find(oName, "fruit") or obj:GetAttribute("OriginalName")) and obj ~= LocalPlayer.Character then
                        if not ActiveESP.Fruits[obj] then
                            ActiveESP.Fruits[obj] = CreateHighlightESP(obj, Color3.fromRGB(255, 215, 0), "🍎 " .. obj.Name)
                        end
                    end
                end
            end)
        else
            if next(ActiveESP.Fruits) ~= nil then ClearESPTable(ActiveESP.Fruits) end
        end

        -- Player ESP
        if Toggles.PlayerESP then
            pcall(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if not Toggles.PlayerESP then break end
                    if p ~= LocalPlayer and p.Character then
                        if not ActiveESP.Players[p.Character] then
                            ActiveESP.Players[p.Character] = CreateHighlightESP(p.Character, Color3.fromRGB(0, 240, 255), "👤 " .. p.DisplayName)
                        end
                    end
                end
            end)
        else
            if next(ActiveESP.Players) ~= nil then ClearESPTable(ActiveESP.Players) end
        end

        -- Chest ESP
        if Toggles.ChestESP then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.ChestESP then break end
                    local oName = string.lower(obj.Name)
                    if string.find(oName, "chest") and (obj:IsA("Model") or obj:IsA("BasePart")) then
                        if not ActiveESP.Chests[obj] then
                            ActiveESP.Chests[obj] = CreateHighlightESP(obj, Color3.fromRGB(50, 255, 100), "📦 " .. obj.Name)
                        end
                    end
                end
            end)
        else
            if next(ActiveESP.Chests) ~= nil then ClearESPTable(ActiveESP.Chests) end
        end

        -- Flower ESP
        if Toggles.FlowerESP then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.FlowerESP then break end
                    local oName = string.lower(obj.Name)
                    if (string.find(oName, "flower1") or string.find(oName, "flower2") or string.find(oName, "flower3") or string.find(oName, "flower")) and (obj:IsA("Model") or obj:IsA("BasePart")) then
                        if not ActiveESP.Flowers[obj] then
                            ActiveESP.Flowers[obj] = CreateHighlightESP(obj, Color3.fromRGB(255, 105, 180), "🌸 " .. obj.Name)
                        end
                    end
                end
            end)
        else
            if next(ActiveESP.Flowers) ~= nil then ClearESPTable(ActiveESP.Flowers) end
        end

        -- Boss ESP
        if Toggles.BossESP then
            pcall(function()
                local enemies = Workspace:FindFirstChild("Enemies") or Workspace
                for _, obj in ipairs(enemies:GetChildren()) do
                    if not Toggles.BossESP then break end
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum and hum.MaxHealth > 15000 and obj ~= LocalPlayer.Character then
                        if not ActiveESP.Bosses[obj] then
                            ActiveESP.Bosses[obj] = CreateHighlightESP(obj, Color3.fromRGB(255, 50, 50), "👑 " .. obj.Name)
                        end
                    end
                end
            end)
        else
            if next(ActiveESP.Bosses) ~= nil then ClearESPTable(ActiveESP.Bosses) end
        end

        -- Mirage Island ESP
        if Toggles.MirageESP then
            pcall(function()
                for _, obj in ipairs(Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations") and Workspace._WorldOrigin.Locations:GetChildren() or Workspace:GetChildren()) do
                    if not Toggles.MirageESP then break end
                    local oName = string.lower(obj.Name)
                    if string.find(oName, "mirage") or string.find(oName, "kitsune") then
                        if not ActiveESP.Mirage[obj] then
                            ActiveESP.Mirage[obj] = CreateHighlightESP(obj, Color3.fromRGB(157, 78, 221), "🏝️ " .. obj.Name)
                        end
                    end
                end
            end)
        else
            if next(ActiveESP.Mirage) ~= nil then ClearESPTable(ActiveESP.Mirage) end
        end
    end
end)

-- 6. WalkSpeed Controller
RunService.RenderStepped:Connect(function()
    pcall(function()
        local hum = getHum()
        if hum then
            if Toggles.WalkSpeedBoost then
                hum.WalkSpeed = CustomSpeedValue
            else
                if hum.WalkSpeed == CustomSpeedValue then
                    hum.WalkSpeed = 16
                end
            end
        end
    end)
end)

-- 7. Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        pcall(function()
            local hum = getHum()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- =================================================================
-- TELEPORT HELPERS
-- =================================================================
local function TeleportToSafeZone()
    local root = getRoot()
    if not root then return false end

    -- Check PlaceId / Sea
    local placeId = game.PlaceId
    if placeId == 4442272183 then
        -- Second Sea: Cafe
        root.CFrame = CFrame.new(-380.47, 77.22, 255.82)
        return true
    elseif placeId == 7449423635 then
        -- Third Sea: Mansion
        root.CFrame = CFrame.new(-12463.87, 374.91, -7551.98)
        return true
    else
        -- First Sea: Middle Town Safe Zone
        root.CFrame = CFrame.new(-656.32, 7.85, 1437.14)
        return true
    end
end

local function TeleportToSpawnedFruit()
    local root = getRoot()
    if not root then return false end

    for _, obj in ipairs(Workspace:GetChildren()) do
        local oName = string.lower(obj.Name)
        if (string.find(oName, "fruit") or obj:GetAttribute("OriginalName")) and obj ~= LocalPlayer.Character then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                return true
            end
        end
    end
    return false
end

local function TeleportToNearestChest()
    local root = getRoot()
    if not root then return false end

    local nearestChest = nil
    local nearestDist = math.huge

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if string.find(string.lower(obj.Name), "chest") and (obj:IsA("Model") or obj:IsA("BasePart")) then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = (part.Position - root.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestChest = part
                end
            end
        end
    end

    if nearestChest then
        root.CFrame = nearestChest.CFrame + Vector3.new(0, 3, 0)
        return true
    end
    return false
end

-- =================================================================
-- UI NUMBER 1 (UI 1) — OFFICIAL ULTRA SCRIPT HUB CLASSIC MATTE DARK
-- Standards:
-- - Main Container: 280px width, 290px height
-- - Background: #0F0F11, Border: 1px #23232A, Corner: 12px
-- - Full-width dark rounded action buttons (Height 26px, Corner 6px, #1B1B20)
-- - Standard Feature Rows (Height 23px, White text, 18x18px Checkbox)
-- - WalkSpeed Stepper Pill ([ - 50 + ], Corner 6px, #1B1B20)
-- - Mandatory Centered Footer (ULTRA SCRIPT HUB / Made by Junejo)
-- =================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Junejo_BloxFruits_UI1"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = GuiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 290)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -145)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

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
        updateInput(input)
    end
end)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- 1. Header Frame
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "BLOX FRUITS"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
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

CloseButton.MouseEnter:Connect(function()
    CloseButton.TextColor3 = Color3.fromRGB(255, 75, 75)
end)

CloseButton.MouseLeave:Connect(function()
    CloseButton.TextColor3 = Color3.fromRGB(160, 160, 160)
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Name = "HeaderLine"
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- 2. Scrollable Content Frame
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"
ContentScroll.Size = UDim2.new(1, -24, 1, -74)
ContentScroll.Position = UDim2.new(0, 12, 0, 36)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 2
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 430)
ContentScroll.Parent = MainFrame

local ContentList = Instance.new("UIListLayout")
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.Padding = UDim.new(0, 4)
ContentList.Parent = ContentScroll

ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 6)
end)

-- Helper: Action Button Row
local function AddActionButton(text, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 26)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentScroll

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.BorderSizePixel = 0
    Btn.Parent = Row

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(45, 45, 55)
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        pcall(callback, Btn)
    end)

    Btn.MouseEnter:Connect(function()
        Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    end)

    Btn.MouseLeave:Connect(function()
        Btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    end)

    return Btn
end

-- Helper: Standard Borderless Toggle Row
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
    CheckCorner.CornerRadius = UDim.new(0, 5)
    CheckCorner.Parent = CheckBox

    local CheckStroke = Instance.new("UIStroke")
    CheckStroke.Color = Color3.fromRGB(45, 45, 55)
    CheckStroke.Thickness = 1
    CheckStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    CheckStroke.Parent = CheckBox

    local CheckMark = Instance.new("Frame")
    CheckMark.Size = UDim2.new(0, 10, 0, 10)
    CheckMark.Position = UDim2.new(0.5, -5, 0.5, -5)
    CheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox

    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 3)
    MarkCorner.Parent = CheckMark

    RowBtn.MouseButton1Click:Connect(function()
        Toggles[configKey] = not Toggles[configKey]
        CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
        if callback then callback(Toggles[configKey]) end
    end)
end

-- =================================================================
-- POPULATE FEATURES
-- =================================================================

-- 1. Action Teleport Buttons
AddActionButton("TELEPORT TO SAFE ZONE", function(btn)
    local ok = TeleportToSafeZone()
    if ok then
        btn.Text = "TELEPORTED!"
        task.wait(1)
        btn.Text = "TELEPORT TO SAFE ZONE"
    end
end)

AddActionButton("TELEPORT TO SPAWNED FRUIT", function(btn)
    local ok = TeleportToSpawnedFruit()
    if ok then
        btn.Text = "WARPED TO FRUIT!"
    else
        btn.Text = "NO FRUIT SPAWNED!"
    end
    task.wait(1)
    btn.Text = "TELEPORT TO SPAWNED FRUIT"
end)

AddActionButton("TELEPORT TO NEAREST CHEST", function(btn)
    local ok = TeleportToNearestChest()
    if ok then
        btn.Text = "WARPED TO CHEST!"
    else
        btn.Text = "NO CHEST FOUND!"
    end
    task.wait(1)
    btn.Text = "TELEPORT TO NEAREST CHEST"
end)

-- 2. Combat & Automation Toggles
AddToggleRow("Fast Attack", "FastAttack", function(v)
    Toggles.FastAttack = v
end)

AddToggleRow("Auto Collect Fruits", "AutoCollectFruits", function(v)
    Toggles.AutoCollectFruits = v
end)

AddToggleRow("Auto Store Fruits", "AutoStoreFruits", function(v)
    Toggles.AutoStoreFruits = v
end)

AddToggleRow("Auto Stats Upgrade", "AutoStats", function(v)
    Toggles.AutoStats = v
end)

-- 3. Visuals & ESP
AddToggleRow("Fruit ESP", "FruitESP", function(v)
    Toggles.FruitESP = v
end)

AddToggleRow("Player ESP", "PlayerESP", function(v)
    Toggles.PlayerESP = v
end)

AddToggleRow("Chest ESP", "ChestESP", function(v)
    Toggles.ChestESP = v
end)

AddToggleRow("Flower ESP", "FlowerESP", function(v)
    Toggles.FlowerESP = v
end)

AddToggleRow("Boss ESP", "BossESP", function(v)
    Toggles.BossESP = v
end)

AddToggleRow("Mirage Island ESP", "MirageESP", function(v)
    Toggles.MirageESP = v
end)

AddToggleRow("Infinite Jump", "InfiniteJump", function(v)
    Toggles.InfiniteJump = v
end)

-- 4. WalkSpeed Row with Integrated Stepper Pill
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, 0, 0, 24)
SpeedRow.BackgroundTransparency = 1
SpeedRow.Parent = ContentScroll

local SpeedToggleBtn = Instance.new("TextButton")
SpeedToggleBtn.Size = UDim2.new(0.5, 0, 1, 0)
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
SpeedCheckCorner.CornerRadius = UDim.new(0, 5)
SpeedCheckCorner.Parent = SpeedCheckBox

local SpeedCheckStroke = Instance.new("UIStroke")
SpeedCheckStroke.Color = Color3.fromRGB(45, 45, 55)
SpeedCheckStroke.Thickness = 1
SpeedCheckStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
SpeedCheckStroke.Parent = SpeedCheckBox

local SpeedCheckMark = Instance.new("Frame")
SpeedCheckMark.Size = UDim2.new(0, 10, 0, 10)
SpeedCheckMark.Position = UDim2.new(0.5, -5, 0.5, -5)
SpeedCheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
SpeedCheckMark.BorderSizePixel = 0
SpeedCheckMark.Parent = SpeedCheckBox

local SpeedMarkCorner = Instance.new("UICorner")
SpeedMarkCorner.CornerRadius = UDim.new(0, 3)
SpeedMarkCorner.Parent = SpeedCheckMark

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
end)

-- Stepper Pill [ - 50 + ]
local StepperPill = Instance.new("Frame")
StepperPill.Name = "StepperPill"
StepperPill.Size = UDim2.new(0, 95, 0, 22)
StepperPill.Position = UDim2.new(1, -95, 0.5, -11)
StepperPill.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
StepperPill.BorderSizePixel = 0
StepperPill.Parent = SpeedRow

local StepperCorner = Instance.new("UICorner")
StepperCorner.CornerRadius = UDim.new(0, 6)
StepperCorner.Parent = StepperPill

local StepperStroke = Instance.new("UIStroke")
StepperStroke.Color = Color3.fromRGB(45, 45, 55)
StepperStroke.Thickness = 1
StepperStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
StepperStroke.Parent = StepperPill

local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 26, 1, 0)
MinusBtn.Position = UDim2.new(0, 0, 0, 0)
MinusBtn.BackgroundTransparency = 1
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.TextSize = 13
MinusBtn.Parent = StepperPill

local SpeedValueLabel = Instance.new("TextLabel")
SpeedValueLabel.Size = UDim2.new(1, -52, 1, 0)
SpeedValueLabel.Position = UDim2.new(0, 26, 0, 0)
SpeedValueLabel.BackgroundTransparency = 1
SpeedValueLabel.Text = tostring(CustomSpeedValue)
SpeedValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedValueLabel.Font = Enum.Font.GothamBold
SpeedValueLabel.TextSize = 11
SpeedValueLabel.Parent = StepperPill

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 26, 1, 0)
PlusBtn.Position = UDim2.new(1, -26, 0, 0)
PlusBtn.BackgroundTransparency = 1
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.TextSize = 13
PlusBtn.Parent = StepperPill

MinusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.max(16, CustomSpeedValue - 10)
    SpeedValueLabel.Text = tostring(CustomSpeedValue)
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 10)
    SpeedValueLabel.Text = tostring(CustomSpeedValue)
end)

-- 3. Mandatory Centered Footer
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 36)
Footer.Position = UDim2.new(0, 0, 1, -38)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Name = "FooterTitle"
FooterTitle.Size = UDim2.new(1, 0, 0, 14)
FooterTitle.Position = UDim2.new(0, 0, 0, 4)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 11
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Name = "FooterSub"
FooterSub.Size = UDim2.new(1, 0, 0, 12)
FooterSub.Position = UDim2.new(0, 0, 0, 18)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 9
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.Parent = Footer

print("[ULTRA SCRIPT HUB] Blox Fruits loaded successfully with UI 1 (Classic Matte Dark).")
