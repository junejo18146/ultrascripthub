--[[
    JUNEJO ULTRA SCRIPT HUB - 99 NIGHTS IN THE FOREST
    Target Game: 99 Nights in the Forest (Roblox)
    Developer: Grandma's Favourite Games
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11) - Flat & Borderless Standard
    Status: Direct Standalone Executable
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Safe UI Parent getter (Delta, Arceus X, Fluxus, PC/Mobile compatible)
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

-- Cleanup previous UI instances
for _, name in ipairs({"JunejoHubUI_NightsForest", "JunejoNightsInTheForestUI", "JunejoHubUI"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

--------------------------------------------------------------------
-- CONFIGURATION & STATE (5 SELECTED FEATURES)
--------------------------------------------------------------------
local Toggles = {
    ChildrenESP = false,
    ItemsESP = false,
    Fly = false,
    InfiniteJump = false
}

local FlySpeed = 50
local CampfirePosition = nil
local SavedSpawnPosition = nil

-- Record initial spawn position as safe campfire backup
pcall(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        SavedSpawnPosition = hrp.Position
    end
end)

--------------------------------------------------------------------
-- ANTI-AFK SYSTEM (20 MINUTE DISCONNECT PROTECTION)
--------------------------------------------------------------------
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

--------------------------------------------------------------------
-- 1. INFINITE JUMP ENGINE
--------------------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        pcall(function()
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and Toggles.InfiniteJump and input.KeyCode == Enum.KeyCode.Space then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
            end
        end)
    end
end)

--------------------------------------------------------------------
-- 2. CAMPFIRE LOCATOR & TELEPORT ENGINE
--------------------------------------------------------------------
local function FindCampfire()
    -- Priority 1: Check known workspace paths
    local candidates = {
        Workspace:FindFirstChild("Campground"),
        Workspace:FindFirstChild("Campfire"),
        Workspace:FindFirstChild("Camp"),
        Workspace:FindFirstChild("Fire"),
        Workspace:FindFirstChild("MainCamp")
    }
    for _, obj in ipairs(candidates) do
        if obj then
            if obj:IsA("BasePart") then
                return obj
            elseif obj:IsA("Model") then
                return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            end
        end
    end
    
    -- Priority 2: Recursive search for campfire keyword
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("BasePart") or desc:IsA("Model") then
            local lowerName = string.lower(desc.Name)
            if string.find(lowerName, "campfire") or string.find(lowerName, "firepit") or string.find(lowerName, "camp_fire") then
                if desc:IsA("BasePart") then
                    return desc
                elseif desc:IsA("Model") and (desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart")) then
                    return desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart")
                end
            end
        end
    end
    
    -- Priority 3: Search for Fire particle emitters
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("Fire") and desc.Parent and desc.Parent:IsA("BasePart") then
            return desc.Parent
        end
    end

    return nil
end

local function TeleportToCampfire()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local campPart = FindCampfire()
        if campPart then
            hrp.CFrame = CFrame.new(campPart.Position + Vector3.new(0, 4, 0))
        elseif CampfirePosition then
            hrp.CFrame = CFrame.new(CampfirePosition + Vector3.new(0, 4, 0))
        elseif SavedSpawnPosition then
            hrp.CFrame = CFrame.new(SavedSpawnPosition + Vector3.new(0, 4, 0))
        end
    end)
end

--------------------------------------------------------------------
-- 3. MISSING CHILDREN ESP
--------------------------------------------------------------------
local ChildrenESPFolder = Instance.new("Folder")
ChildrenESPFolder.Name = "Junejo_ChildrenESP"
ChildrenESPFolder.Parent = UIContainer

local function ClearChildrenESP()
    for _, obj in ipairs(ChildrenESPFolder:GetChildren()) do
        obj:Destroy()
    end
end

local function IsChildModel(model)
    if not model or not model:IsA("Model") then return false end
    if model == LocalPlayer.Character then return false end
    local name = string.lower(model.Name)
    
    if string.find(name, "child") or string.find(name, "kid") or string.find(name, "missing") or string.find(name, "lost") or string.find(name, "orphan") then
        return true
    end
    
    if model:GetAttribute("IsChild") or model:GetAttribute("MissingChild") then
        return true
    end
    
    return false
end

local function CreateChildESP(model)
    local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not root then return end
    
    local id = "ChildESP_" .. tostring(model:GetDebugId(0))
    if ChildrenESPFolder:FindFirstChild(id) then return end
    
    local espHolder = Instance.new("Folder")
    espHolder.Name = id
    espHolder.Parent = ChildrenESPFolder
    
    -- Cyan Highlight
    local hl = Instance.new("Highlight")
    hl.Adornee = model
    hl.FillColor = Color3.fromRGB(0, 230, 255)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.45
    hl.OutlineTransparency = 0
    hl.Parent = espHolder
    
    -- Billboard Text
    local bb = Instance.new("BillboardGui")
    bb.Adornee = root
    bb.Size = UDim2.new(0, 160, 0, 36)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = espHolder
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 240, 255)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.2
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.Text = "👦 MISSING CHILD"
    label.Parent = bb
    
    -- Distance Updater
    task.spawn(function()
        while espHolder.Parent and model.Parent do
            task.wait(0.25)
            pcall(function()
                local char = LocalPlayer.Character
                local myHrp = char and char:FindFirstChild("HumanoidRootPart")
                if myHrp and root.Parent then
                    local dist = math.floor((myHrp.Position - root.Position).Magnitude)
                    label.Text = "👦 MISSING CHILD\n[" .. tostring(dist) .. "m]"
                end
            end)
        end
        espHolder:Destroy()
    end)
end

task.spawn(function()
    while true do
        task.wait(1.5)
        if Toggles.ChildrenESP then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and IsChildModel(obj) then
                        CreateChildESP(obj)
                    end
                end
            end)
        else
            ClearChildrenESP()
        end
    end
end)

--------------------------------------------------------------------
-- 4. ITEMS & CHESTS ESP
--------------------------------------------------------------------
local ItemsESPFolder = Instance.new("Folder")
ItemsESPFolder.Name = "Junejo_ItemsESP"
ItemsESPFolder.Parent = UIContainer

local function ClearItemsESP()
    for _, obj in ipairs(ItemsESPFolder:GetChildren()) do
        obj:Destroy()
    end
end

local function IsLootItem(item)
    if not item then return false, "" end
    local name = string.lower(item.Name)
    
    if string.find(name, "chest") or string.find(name, "crate") or string.find(name, "box") then
        return true, "📦 CHEST"
    elseif string.find(name, "scrap") or string.find(name, "metal") or string.find(name, "gear") then
        return true, "⚙️ SCRAP"
    elseif string.find(name, "food") or string.find(name, "can") or string.find(name, "meat") or string.find(name, "bread") or string.find(name, "apple") then
        return true, "🍖 FOOD"
    elseif string.find(name, "medkit") or string.find(name, "bandage") or string.find(name, "potion") then
        return true, "💊 HEAL"
    elseif string.find(name, "axe") or string.find(name, "chainsaw") or string.find(name, "sword") or string.find(name, "gun") or string.find(name, "weapon") then
        return true, "🗡️ WEAPON"
    end
    
    return false, ""
end

local function CreateItemESP(target, labelText)
    local adorneePart = target:IsA("BasePart") and target or (target:IsA("Model") and (target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")))
    if not adorneePart then return end
    
    local id = "ItemESP_" .. tostring(target:GetDebugId(0))
    if ItemsESPFolder:FindFirstChild(id) then return end
    
    local espHolder = Instance.new("Folder")
    espHolder.Name = id
    espHolder.Parent = ItemsESPFolder
    
    -- Gold Highlight
    local hl = Instance.new("Highlight")
    hl.Adornee = target
    hl.FillColor = Color3.fromRGB(255, 200, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.Parent = espHolder
    
    -- Billboard Label
    local bb = Instance.new("BillboardGui")
    bb.Adornee = adorneePart
    bb.Size = UDim2.new(0, 140, 0, 30)
    bb.StudsOffset = Vector3.new(0, 2, 0)
    bb.AlwaysOnTop = true
    bb.Parent = espHolder
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 220, 50)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.2
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.Text = labelText
    label.Parent = bb
    
    -- Distance Loop
    task.spawn(function()
        while espHolder.Parent and target.Parent do
            task.wait(0.3)
            pcall(function()
                local char = LocalPlayer.Character
                local myHrp = char and char:FindFirstChild("HumanoidRootPart")
                if myHrp and adorneePart.Parent then
                    local dist = math.floor((myHrp.Position - adorneePart.Position).Magnitude)
                    label.Text = labelText .. "\n[" .. tostring(dist) .. "m]"
                end
            end)
        end
        espHolder:Destroy()
    end)
end

task.spawn(function()
    while true do
        task.wait(2)
        if Toggles.ItemsESP then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") or obj:IsA("BasePart") then
                        local isLoot, labelText = IsLootItem(obj)
                        if isLoot then
                            CreateItemESP(obj, labelText)
                        end
                    end
                end
            end)
        else
            ClearItemsESP()
        end
    end
end)

--------------------------------------------------------------------
-- 5. FLY ENGINE (SMOOTH 3D WASD & MOBILE FLIGHT)
--------------------------------------------------------------------
local FlyBodyVel = nil
local FlyBodyGyro = nil
local FlyConnection = nil

local function StartFly()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if FlyBodyVel then FlyBodyVel:Destroy() end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end

        FlyBodyVel = Instance.new("BodyVelocity")
        FlyBodyVel.Velocity = Vector3.zero
        FlyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyVel.Parent = hrp

        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyGyro.CFrame = hrp.CFrame
        FlyBodyGyro.P = 15000
        FlyBodyGyro.Parent = hrp

        hum.PlatformStand = true

        FlyConnection = RunService.RenderStepped:Connect(function()
            if not Toggles.Fly or not hrp.Parent then
                return
            end

            local cam = Workspace.CurrentCamera
            local moveDir = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end

            -- Mobile Touch Movement Fallback
            if hum.MoveDirection.Magnitude > 0 then
                moveDir = moveDir + (cam.CFrame:VectorToWorldSpace(hum.MoveDirection))
            end

            FlyBodyGyro.CFrame = cam.CFrame
            FlyBodyVel.Velocity = moveDir.Magnitude > 0 and (moveDir.Unit * FlySpeed) or Vector3.zero
        end)
    end)
end

local function StopFly()
    pcall(function()
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
        if FlyBodyVel then
            FlyBodyVel:Destroy()
            FlyBodyVel = nil
        end
        if FlyBodyGyro then
            FlyBodyGyro:Destroy()
            FlyBodyGyro = nil
        end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end)
end

--------------------------------------------------------------------
-- 6. JUNEJO ULTRA SCRIPT HUB - OFFICIAL MASTER UI (5 ROWS COMPACT)
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_NightsForest"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = UIContainer

-- Total Height calculation:
-- Header (32) + Line (1) + Spacing (5) + (5 rows * 27) + Footer (36) = ~212px
local TotalFrameHeight = 215

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, TotalFrameHeight)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -math.floor(TotalFrameHeight / 2))
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

-- Header Bar
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
TitleLabel.Text = "99 NIGHTS IN THE FOREST"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseButton"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 4)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    StopFly()
    ClearChildrenESP()
    ClearItemsESP()
    Toggles.ChildrenESP = false
    Toggles.ItemsESP = false
    Toggles.Fly = false
    Toggles.InfiniteJump = false
    ScreenGui:Destroy()
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Name = "HeaderLine"
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Draggable Functionality
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

-- Content Frame (5 rows)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 0, 138)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper function for Toggle Rows (Flat & Borderless)
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Name = text .. "_Row"
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

-- Helper function for Action Button Rows (Teleports)
local function AddActionRow(text, btnText, callback)
    local Row = Instance.new("Frame")
    Row.Name = text .. "_Row"
    Row.Size = UDim2.new(1, 0, 0, 23)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -75, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(0, 70, 0, 20)
    ActionBtn.Position = UDim2.new(1, -70, 0.5, -10)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    ActionBtn.BorderSizePixel = 0
    ActionBtn.Text = btnText
    ActionBtn.TextColor3 = Color3.fromRGB(34, 197, 94)
    ActionBtn.TextSize = 11
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.Parent = Row
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ActionBtn
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = ActionBtn
    
    ActionBtn.MouseButton1Click:Connect(function()
        ActionBtn.Text = "Done!"
        ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        if callback then callback() end
        task.delay(0.8, function()
            if ActionBtn and ActionBtn.Parent then
                ActionBtn.Text = btnText
                ActionBtn.TextColor3 = Color3.fromRGB(34, 197, 94)
            end
        end)
    end)
end

--------------------------------------------------------------------
-- POPULATE ROWS (EXACT 5 USER REQUESTED FEATURES)
--------------------------------------------------------------------
-- 1. Missing Children ESP
AddToggleRow("Missing Children ESP", "ChildrenESP", function(enabled)
    if not enabled then ClearChildrenESP() end
end)

-- 2. Items & Chests ESP
AddToggleRow("Items & Chests ESP", "ItemsESP", function(enabled)
    if not enabled then ClearItemsESP() end
end)

-- 3. Campfire Teleport
AddActionRow("Campfire Teleport", "Teleport", function()
    TeleportToCampfire()
end)

-- 4. Fly Mode
AddToggleRow("Fly Mode", "Fly", function(enabled)
    if enabled then
        StartFly()
    else
        StopFly()
    end
end)

-- 5. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump")

--------------------------------------------------------------------
-- FOOTER (PERMANENT OFFICIAL BRANDING)
--------------------------------------------------------------------
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

print("[JUNEJO SCRIPT HUB] 99 Nights in the Forest Loaded (5 Verified Features)!")
