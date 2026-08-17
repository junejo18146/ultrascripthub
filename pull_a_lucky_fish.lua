--[[
    JUNEJO ULTRA SCRIPT HUB - PULL A LUCKY FISH (V2 MULTI-LAYER ENGINE)
    Target Game: Pull a Lucky Fish (Roblox)
    Game URL: https://www.roblox.com/games/112781315318195/Pull-a-Lucky-Fish
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11)
    Status: Unlocked Direct Standalone Execution (Keyless Edition)
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Safe UI Parent getter (compatible with Delta and all mobile/PC executors)
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
for _, name in ipairs({"JunejoLuckyFishUI", "JunejoHubUI_LuckyFish", "JunejoPullLuckyFishMain"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

-- Feature States
local Toggles = {
    AutoFish = false,
    InstantLastZone = false,
    AutoCollectCash = false,
    AutoSellFish = false,
    AutoRebirth = false,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

local CustomSpeedValue = 60

--------------------------------------------------------------------
-- ANTI-AFK SYSTEM
--------------------------------------------------------------------
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

--------------------------------------------------------------------
-- ADVANCED MULTI-LAYER AUTOMATION HELPERS
--------------------------------------------------------------------

-- 1. Deep Remotes Broadcaster (Searches all Folders & Packages)
local function BroadcastRemotes(keywords, argSets)
    pcall(function()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local lname = obj.Name:lower()
                local parentName = obj.Parent and obj.Parent.Name:lower() or ""
                
                for _, kw in ipairs(keywords) do
                    if lname:find(kw) or parentName:find(kw) then
                        if obj:IsA("RemoteEvent") then
                            obj:FireServer()
                            for _, arg in ipairs(argSets or {}) do
                                pcall(function() obj:FireServer(unpack(arg)) end)
                            end
                        elseif obj:IsA("RemoteFunction") then
                            pcall(function() obj:InvokeServer() end)
                        end
                        break
                    end
                end
            end
        end
    end)
end

-- 2. Trigger All Proximity Prompts & Click Detectors
local function TriggerAllPrompts(keywords)
    pcall(function()
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local pname = (prompt.Parent and prompt.Parent.Name or prompt.Name):lower()
                for _, kw in ipairs(keywords) do
                    if pname:find(kw) then
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        end
                        break
                    end
                end
            elseif prompt:IsA("ClickDetector") then
                local cname = (prompt.Parent and prompt.Parent.Name or prompt.Name):lower()
                for _, kw in ipairs(keywords) do
                    if cname:find(kw) then
                        if fireclickdetector then
                            fireclickdetector(prompt)
                        end
                        break
                    end
                end
            end
        end
    end)
end

-- 3. Click / Tap GUI Buttons for Fishing QTE & Claims
local function ClickGuiButtons(keywords)
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        
        for _, btn in ipairs(playerGui:GetDescendants()) do
            if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                local bname = btn.Name:lower()
                local btext = btn:IsA("TextButton") and btn.Text:lower() or ""
                
                for _, kw in ipairs(keywords) do
                    if bname:find(kw) or btext:find(kw) then
                        if firesignal then
                            firesignal(btn.MouseButton1Click)
                            firesignal(btn.MouseButton1Down)
                            firesignal(btn.Activated)
                        end
                        break
                    end
                end
            end
        end
    end)
end

-- 4. Touch Interest on Target Workspace Parts
local function TouchMatchingParts(keywords)
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local pname = part.Name:lower()
                for _, kw in ipairs(keywords) do
                    if pname:find(kw) then
                        if firetouchinterest then
                            firetouchinterest(hrp, part, 0)
                            task.wait(0.005)
                            firetouchinterest(hrp, part, 1)
                        end
                        break
                    end
                end
            end
        end
    end)
end

-- 5. Find Farthest / Best Fishing Zone & Player Base
local function GetZoneAndBase()
    local bestZone = nil
    local baseSpot = nil

    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local origin = hrp and hrp.Position or Vector3.new(0, 0, 0)
        local maxDist = 0

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local n = obj.Name:lower()
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
                if part then
                    -- Base / Plot
                    if n:find("base") or n:find("plot") or n:find("dock") or n:find("home") or n:find(LocalPlayer.Name:lower()) then
                        if not baseSpot then baseSpot = part end
                    end
                    -- Zone
                    if n:find("zone") or n:find("deep") or n:find("ocean") or n:find("lake") or n:find("island") or n:find("water") or n:find("spot") then
                        local dist = (part.Position - origin).Magnitude
                        if dist > maxDist then
                            maxDist = dist
                            bestZone = part
                        end
                    end
                end
            end
        end
    end)
    return bestZone, baseSpot
end

--------------------------------------------------------------------
-- 7 MULTI-LAYER AUTOMATION LOOPS
--------------------------------------------------------------------

-- 1. Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        pcall(function()
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

-- 2. WalkSpeed Boost Manager
RunService.Stepped:Connect(function()
    if Toggles.WalkSpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        pcall(function()
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = CustomSpeedValue
        end)
    end
end)

-- 3. AUTO FISH & FAST PULL (Continuous Multi-Layer Pulse)
task.spawn(function()
    while true do
        task.wait(0.05)
        if Toggles.AutoFish then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local backpack = LocalPlayer:FindFirstChild("Backpack")

                -- Layer A: Equip Fishing Tool / Rod
                if backpack and hum then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            hum:EquipTool(tool)
                        end
                    end
                end

                -- Layer B: Tool Activation & Mouse Click Simulation
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            tool:Activate()
                            -- If tool has remote inside, fire it
                            for _, remote in ipairs(tool:GetDescendants()) do
                                if remote:IsA("RemoteEvent") then
                                    remote:FireServer()
                                    remote:FireServer(true)
                                    remote:FireServer(1)
                                end
                            end
                        end
                    end
                end

                -- Layer C: Rapid Click Simulation for Fast Pull / Reeling
                VirtualUser:Button1Down(Vector2.new(500, 500))
                task.wait(0.01)
                VirtualUser:Button1Up(Vector2.new(500, 500))

                -- Layer D: Click Onscreen Fishing Minigame / Reel Buttons
                ClickGuiButtons({"reel", "pull", "catch", "fish", "cast", "tap", "click", "hit", "hook", "strike"})

                -- Layer E: Deep Remotes Broadcaster for Fishing
                BroadcastRemotes(
                    {"fish", "cast", "reel", "pull", "catch", "hook", "bite", "strike", "throw", "rod", "bobber", "claimfish"},
                    {
                        {"Cast", true, 1},
                        {"Reel", true, 1},
                        {"Pull", true, 1},
                        {"Catch", true},
                        {true},
                        {1},
                        {"Instant"}
                    }
                )

                -- Layer F: Trigger Fishing Prompts
                TriggerAllPrompts({"fish", "cast", "reel", "pull", "catch", "hook", "water"})
            end)
        end
    end
end)

-- 4. INSTANT LAST ZONE (Deep Ocean Teleport & Instant Catch)
task.spawn(function()
    while true do
        task.wait(0.4)
        if Toggles.InstantLastZone then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local lastZone, baseSpot = GetZoneAndBase()
                    if lastZone then
                        -- Teleport to deepest zone
                        hrp.CFrame = lastZone.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.15)
                        
                        -- Fire fishing sequence
                        BroadcastRemotes({"cast", "fish", "pull", "reel", "catch"}, {{"Cast", true}, {"Reel", true}})
                        ClickGuiButtons({"reel", "pull", "catch", "fish"})
                    end
                end
            end)
        end
    end
end)

-- 5. AUTO COLLECT BASE CASH (5-Layer Income Harvesting)
task.spawn(function()
    while true do
        task.wait(0.15)
        if Toggles.AutoCollectCash then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                -- Layer A: Remote Broadcaster for Base & Tank Cash
                BroadcastRemotes(
                    {"collect", "claim", "income", "cash", "money", "tank", "payout", "deposit", "withdraw", "giver", "currency"},
                    {
                        {"Collect", true},
                        {"Claim", true},
                        {true},
                        {1}
                    }
                )

                -- Layer B: Trigger Prompts on Tanks & Collector Pads
                TriggerAllPrompts({"collect", "claim", "cash", "money", "tank", "coin", "payout", "atm", "bank", "pad"})

                -- Layer C: Click UI Claim Buttons
                ClickGuiButtons({"collect", "claim", "claimall", "collectall", "payout", "withdraw", "take"})

                -- Layer D: Touch Collector Pads
                TouchMatchingParts({"collector", "cash", "coin", "money", "deposit", "pad", "bank", "atm", "income", "tank"})

                -- Layer E: Floating Money Drops Teleport
                if hrp then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not Toggles.AutoCollectCash then break end
                        if obj:IsA("BasePart") then
                            local n = obj.Name:lower()
                            if n:find("coin") or n:find("cash") or n:find("money") or n:find("drop") or n:find("gem") or n:find("dollar") then
                                if firetouchinterest then
                                    firetouchinterest(hrp, obj, 0)
                                    task.wait(0.005)
                                    firetouchinterest(hrp, obj, 1)
                                end
                                obj.CFrame = hrp.CFrame
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 6. AUTO SELL LOW TIER FISH (Merchant & Remote Broadcaster)
task.spawn(function()
    while true do
        task.wait(0.8)
        if Toggles.AutoSellFish then
            pcall(function()
                -- Layer A: Remote Firing for Low/Common Fish Sell
                BroadcastRemotes(
                    {"sell", "sellfish", "selllow", "sellcommon", "sellduplicate", "sellall", "merchant", "trader"},
                    {
                        {"Common", true},
                        {"Uncommon", true},
                        {"Low", true},
                        {"Duplicate", true},
                        {"SellAll", true},
                        {true}
                    }
                )

                -- Layer B: Trigger Merchant / Sell Prompts
                TriggerAllPrompts({"sell", "merchant", "shop", "trader", "buyer", "market"})

                -- Layer C: Click UI Sell Buttons
                ClickGuiButtons({"sell", "sellall", "sellcommon", "selllow", "confirm"})

                -- Layer D: Touch Sell Pads
                TouchMatchingParts({"sell", "merchant", "trader", "shop", "market"})
            end)
        end
    end
end)

-- 7. AUTO REBIRTH
task.spawn(function()
    while true do
        task.wait(1.2)
        if Toggles.AutoRebirth then
            pcall(function()
                BroadcastRemotes(
                    {"rebirth", "prestige", "ascend", "rankup", "reset"},
                    {
                        {"Rebirth", true},
                        {true},
                        {1}
                    }
                )
                ClickGuiButtons({"rebirth", "prestige", "ascend", "confirm"})
                TriggerAllPrompts({"rebirth", "prestige", "ascend"})
            end)
        end
    end
end)

--------------------------------------------------------------------
-- UNIFIED JUNEJO EXECUTIVE UI
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoLuckyFishUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = UIContainer
end

-- Main Container Frame (Width: 280px, Height: 300px)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 300)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -150)
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
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "PULL A LUCKY FISH"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 34, 0, 34)
CloseButton.Position = UDim2.new(1, -34, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 170)
CloseButton.TextSize = 14
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
ContentFrame.Size = UDim2.new(1, -28, 0, 210)
ContentFrame.Position = UDim2.new(0, 14, 0, 36)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper function to add tight compact toggle rows (Full row clickable)
local function AddToggleRow(text, configKey)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 24)
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
        if configKey == "WalkSpeedBoost" and not Toggles.WalkSpeedBoost then
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
                end
            end)
        end
    end)
end

-- Add Automation Features
AddToggleRow("Auto Fish (Fast Pull)", "AutoFish")
AddToggleRow("Instant Last Zone", "InstantLastZone")
AddToggleRow("Auto Collect Base Cash", "AutoCollectCash")
AddToggleRow("Auto Sell Low Fish", "AutoSellFish")
AddToggleRow("Auto Rebirth", "AutoRebirth")
AddToggleRow("Infinite Jump", "InfiniteJump")

-- WalkSpeed Row with Speed Modifier Controls
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, 0, 0, 24)
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
    if not Toggles.WalkSpeedBoost then
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            end
        end)
    end
end)

-- Speed Value Adjuster (+ / - Controls)
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
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
end)

-- Footer Frame
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 44)
Footer.Position = UDim2.new(0, 0, 1, -44)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 16)
FooterTitle.Position = UDim2.new(0, 0, 0, 5)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 13
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 14)
FooterSub.Position = UDim2.new(0, 0, 0, 21)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 11
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.Parent = Footer
