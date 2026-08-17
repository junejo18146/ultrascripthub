--[[
    JUNEJO ULTRA SCRIPT HUB - CLEAN YOUR KEYCAPS
    Game: Clean Your Keycaps (Roblox)
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Version: 3.0 (Focused 5-Feature Edition)
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------
-- CLEANUP PREVIOUS UI INSTANCES
--------------------------------------------------------------------
if CoreGui:FindFirstChild("JunejoCleanKeycapsUI") then
    CoreGui.JunejoCleanKeycapsUI:Destroy()
end

--------------------------------------------------------------------
-- TOGGLE STATES (5 FEATURES ONLY)
--------------------------------------------------------------------
local Toggles = {
    AutoWash = false,
    AutoDunk = false,
    AutoCollect = false,
    AutoRebirth = false,
    InfiniteJump = false
}

--------------------------------------------------------------------
-- ANTI-AFK SYSTEM
--------------------------------------------------------------------
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

--------------------------------------------------------------------
-- AUTOMATION HELPERS
--------------------------------------------------------------------

-- 1. Helper: Fire matching Remotes in DataModel
local function FireRemotesByKeywords(keywords, defaultArgs)
    pcall(function()
        for _, descendant in ipairs(game:GetDescendants()) do
            if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
                local lname = string.lower(descendant.Name)
                for _, kw in ipairs(keywords) do
                    if lname:find(kw) then
                        if descendant:IsA("RemoteEvent") then
                            descendant:FireServer(unpack(defaultArgs or {}))
                            descendant:FireServer()
                        elseif descendant:IsA("RemoteFunction") then
                            pcall(function() descendant:InvokeServer(unpack(defaultArgs or {})) end)
                            pcall(function() descendant:InvokeServer() end)
                        end
                        break
                    end
                end
            end
        end
    end)
end

-- 2. Helper: Trigger matching ProximityPrompts & ClickDetectors
local function TriggerPromptsAndClicks(keywords)
    pcall(function()
        for _, descendant in ipairs(Workspace:GetDescendants()) do
            local lname = string.lower(descendant.Name)
            if descendant:IsA("ProximityPrompt") then
                local combined = lname .. " " .. string.lower(descendant.ActionText .. " " .. descendant.ObjectText)
                for _, kw in ipairs(keywords) do
                    if combined:find(kw) then
                        if fireproximityprompt then
                            fireproximityprompt(descendant, 0)
                        end
                        break
                    end
                end
            elseif descendant:IsA("ClickDetector") then
                local pName = string.lower(descendant.Parent and descendant.Parent.Name or "")
                for _, kw in ipairs(keywords) do
                    if lname:find(kw) or pName:find(kw) then
                        if fireclickdetector then
                            fireclickdetector(descendant)
                        end
                        break
                    end
                end
            end
        end
    end)
end

-- 3. Helper: Touch interest on matching workspace parts
local function TouchPartsByKeywords(keywords)
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") then
                    local pname = string.lower(part.Name)
                    for _, kw in ipairs(keywords) do
                        if pname:find(kw) then
                            if firetouchinterest then
                                firetouchinterest(hrp, part, 0)
                                task.wait(0.01)
                                firetouchinterest(hrp, part, 1)
                            end
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- 4. Helper: Activate Held/Backpack Tool
local function ActivateMatchingTools(keywords)
    pcall(function()
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        
        if char then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    local tname = string.lower(item.Name)
                    for _, kw in ipairs(keywords) do
                        if tname:find(kw) then
                            item:Activate()
                            break
                        end
                    end
                end
            end
        end
        
        if backpack and char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    local tname = string.lower(item.Name)
                    for _, kw in ipairs(keywords) do
                        if tname:find(kw) then
                            if hum then hum:EquipTool(item) end
                            task.wait(0.05)
                            item:Activate()
                            break
                        end
                    end
                end
            end
        end
    end)
end

--------------------------------------------------------------------
-- 5 FEATURE AUTOMATION LOOPS
--------------------------------------------------------------------

-- 1. Auto Wash Keycaps 🧼
task.spawn(function()
    while true do
        task.wait(0.1)
        if Toggles.AutoWash then
            pcall(function()
                ActivateMatchingTools({"sponge", "soap", "wash", "clean", "scrub"})
                FireRemotesByKeywords({"wash", "scrub", "clean", "soap", "sponge", "rub", "work"}, {"Scrub", true, 1})
                TriggerPromptsAndClicks({"wash", "scrub", "clean", "soap", "sponge"})
                TouchPartsByKeywords({"wash", "scrub", "clean", "station", "sink"})
            end)
        end
    end
end)

-- 2. Auto Dunk & Rinse 🚰
task.spawn(function()
    while true do
        task.wait(0.15)
        if Toggles.AutoDunk then
            pcall(function()
                FireRemotesByKeywords({"dunk", "rinse", "water", "dip", "polish", "tub", "soak"}, {"Dunk", true, 1})
                TriggerPromptsAndClicks({"dunk", "rinse", "water", "dip", "polish", "tub", "soak"})
                TouchPartsByKeywords({"dunk", "rinse", "water", "tub", "polish"})
            end)
        end
    end
end)

-- 3. Auto Collect Cash 💰 (SUPERCHARGED ADVANCED ENGINE)
task.spawn(function()
    while true do
        task.wait(0.1)
        if Toggles.AutoCollect then
            pcall(function()
                -- Layer A: Remote Firing
                FireRemotesByKeywords({
                    "collect", "claim", "cash", "coin", "money", "currency", "reward", 
                    "giver", "deposit", "withdraw", "collectcash", "collectmoney", "addcash"
                }, {})

                -- Layer B: Prompts & Click Detectors
                TriggerPromptsAndClicks({
                    "collect", "claim", "cash", "coin", "money", "giver", "deposit", 
                    "collector", "register", "bank", "pad", "total"
                })

                -- Layer C: Touch Interest on Collector Pads & Money Parts
                TouchPartsByKeywords({
                    "cash", "coin", "money", "drop", "gem", "currency", "collector", 
                    "giver", "deposit", "pad", "total", "bill", "reward", "register"
                })

                -- Layer D: Character HRP Teleport to Drops & Collectors
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    
                    -- Scan Workspace for dropped cash parts or collector pads
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local name = string.lower(obj.Name)
                            if name:find("cash") or name:find("coin") or name:find("money") or name:find("drop") or name:find("collector") or name:find("giver") then
                                pcall(function()
                                    if firetouchinterest then
                                        firetouchinterest(hrp, obj, 0)
                                        task.wait(0.005)
                                        firetouchinterest(hrp, obj, 1)
                                    end
                                    -- Teleport drop to player
                                    if name:find("drop") or name:find("coin") or name:find("cash") then
                                        obj.CFrame = hrp.CFrame
                                    end
                                end)
                            end
                        end
                    end
                end

                -- Layer E: Scan PlayerGui for UI Collect/Claim Buttons
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, guiObj in ipairs(playerGui:GetDescendants()) do
                        if guiObj:IsA("TextButton") or guiObj:IsA("ImageButton") then
                            local bText = string.lower(guiObj.Name .. " " .. (guiObj:IsA("TextButton") and guiObj.Text or ""))
                            if bText:find("collect") or bText:find("claim") or bText:find("reward") then
                                pcall(function()
                                    if guiObj.Visible then
                                        for _, connection in ipairs(getconnections(guiObj.MouseButton1Click)) do
                                            connection:Fire()
                                        end
                                        for _, connection in ipairs(getconnections(guiObj.Activated)) do
                                            connection:Fire()
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. Auto Rebirth 🔄
task.spawn(function()
    while true do
        task.wait(1.0)
        if Toggles.AutoRebirth then
            pcall(function()
                FireRemotesByKeywords({"rebirth", "dorebirth", "performrebirth", "prestige", "reset"}, {})
                TriggerPromptsAndClicks({"rebirth", "prestige"})
            end)
        end
    end
end)

-- 5. Infinite Jump ⚡
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end)

--------------------------------------------------------------------
-- ULTRA COMPACT JUNEJO EXECUTIVE UI (5 FEATURES PERFECT FIT)
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoCleanKeycapsUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Container Frame (Width: 270px, Height: 200px - Fits 5 Items Perfectly!)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 270, 0, 200)
MainFrame.Position = UDim2.new(0.5, -135, 0.5, -100)
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
TitleLabel.Size = UDim2.new(1, -35, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "CLEAN YOUR KEYCAPS"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -32, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 170)
CloseButton.TextSize = 13
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

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

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 1, -74)
ContentFrame.Position = UDim2.new(0, 12, 0, 32)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 3)
UIList.Parent = ContentFrame

-- Helper function to add tight compact toggle rows (Click anywhere on row to toggle!)
local function AddToggleRow(text, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 22)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame
    
    local RowBtn = Instance.new("TextButton")
    RowBtn.Size = UDim2.new(1, 0, 1, 0)
    RowBtn.BackgroundTransparency = 1
    RowBtn.Text = ""
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
    CheckMark.BackgroundTransparency = default and 0 or 1
    CheckMark.Parent = CheckBox
    
    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark
    
    local toggled = default or false
    
    local function ToggleState()
        toggled = not toggled
        CheckMark.BackgroundTransparency = toggled and 0 or 1
        if callback then callback(toggled) end
    end
    
    RowBtn.MouseButton1Click:Connect(ToggleState)
end

-- POPULATE EXACT 5 REQUESTED TOGGLE ROWS
AddToggleRow("Auto Wash Keycaps 🧼", false, function(v) Toggles.AutoWash = v end)
AddToggleRow("Auto Dunk & Rinse 🚰", false, function(v) Toggles.AutoDunk = v end)
AddToggleRow("Auto Collect Cash 💰", false, function(v) Toggles.AutoCollect = v end)
AddToggleRow("Auto Rebirth 🔄", false, function(v) Toggles.AutoRebirth = v end)
AddToggleRow("Infinite Jump ⚡", false, function(v) Toggles.InfiniteJump = v end)

-- Footer Frame
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
FooterTitle.TextSize = 13
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

print("[JUNEJO ULTRA HUB]: Clean Your Keycaps (v3.0) loaded successfully!")
