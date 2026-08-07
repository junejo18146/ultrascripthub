--[[
    Junejo Ultra Script Hub - Wash the House (Testing Edition v3 - Speed Slider & Auto Farm Patch)
    Target Game: Wash the House (Roblox)
    Created for junejo18146
--]]

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Safe UI Parent getter (compatible with all Roblox executors)
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

-- Cleanup previous GUI instances
for _, name in ipairs({"JunejoHubUI_WashTheHouse"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

----------------------------------------------------
-- MAIN HUB SCRIPT
----------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_WashTheHouse"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = UIContainer
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
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
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "WASH THE HOUSE"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 45, 0, 45)
CloseButton.Position = UDim2.new(1, -45, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 170)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Make Draggable
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

-- Content Container
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -32, 1, -95)
Content.Position = UDim2.new(0, 16, 0, 45)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 10)
UIList.Parent = Content

-- Primary Top Action Button: TELEPORT TO NEXT ROOM
local ActionButton = Instance.new("TextButton")
ActionButton.Name = "ActionButton"
ActionButton.Size = UDim2.new(1, 0, 0, 40)
ActionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
ActionButton.BorderSizePixel = 0
ActionButton.Text = "TELEPORT TO NEXT ROOM"
ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionButton.TextSize = 13
ActionButton.Font = Enum.Font.GothamBold
ActionButton.Parent = Content

local ActionCorner = Instance.new("UICorner")
ActionCorner.CornerRadius = UDim.new(0, 8)
ActionCorner.Parent = ActionButton

-- Footer Frame
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 45)
Footer.Position = UDim2.new(0, 0, 1, -45)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 18)
FooterTitle.Position = UDim2.new(0, 0, 0, 4)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 15
FooterTitle.Font = Enum.Font.GothamBold
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 16)
FooterSub.Position = UDim2.new(0, 0, 0, 22)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
FooterSub.TextSize = 12
FooterSub.Font = Enum.Font.GothamMedium
FooterSub.Parent = Footer

----------------------------------------------------
-- FEATURES LOGIC
----------------------------------------------------
local FeatureStates = {
    Speed = false,
    InfWater = false,
    AutoSort = false,
    AutoClean = false,
    AutoFarmCoins = false
}

local CustomSpeedValue = 100
local CustomCashAmount = 999999999

local function CreateToggleRow(text, key)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 34)
    Row.BackgroundTransparency = 1
    Row.Parent = Content
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -45, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local CheckBox = Instance.new("TextButton")
    CheckBox.Size = UDim2.new(0, 30, 0, 30)
    CheckBox.Position = UDim2.new(1, -30, 0.5, -15)
    CheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    CheckBox.BorderSizePixel = 0
    CheckBox.Text = ""
    CheckBox.Parent = Row
    
    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 8)
    CheckCorner.Parent = CheckBox
    
    local CheckStroke = Instance.new("UIStroke")
    CheckStroke.Color = Color3.fromRGB(45, 45, 55)
    CheckStroke.Thickness = 1.5
    CheckStroke.Parent = CheckBox
    
    local CheckMark = Instance.new("Frame")
    CheckMark.Size = UDim2.new(0.6, 0, 0.6, 0)
    CheckMark.Position = UDim2.new(0.2, 0, 0.2, 0)
    CheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CheckMark.BackgroundTransparency = 1
    CheckMark.Parent = CheckBox
    
    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 4)
    MarkCorner.Parent = CheckMark
    
    CheckBox.MouseButton1Click:Connect(function()
        FeatureStates[key] = not FeatureStates[key]
        CheckMark.BackgroundTransparency = FeatureStates[key] and 0 or 1
    end)
end

-- SPEED MANAGING ROW (CUSTOM INPUT LINE + SET SPEED)
local SpeedControlRow = Instance.new("Frame")
SpeedControlRow.Name = "SpeedControlRow"
SpeedControlRow.Size = UDim2.new(1, 0, 0, 38)
SpeedControlRow.BackgroundTransparency = 1
SpeedControlRow.Parent = Content

local SpeedTextBox = Instance.new("TextBox")
SpeedTextBox.Name = "SpeedTextBox"
SpeedTextBox.Size = UDim2.new(0.66, 0, 1, 0)
SpeedTextBox.Position = UDim2.new(0, 0, 0, 0)
SpeedTextBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
SpeedTextBox.BorderSizePixel = 0
SpeedTextBox.PlaceholderText = "Enter Speed (e.g. 100)..."
SpeedTextBox.Text = "100"
SpeedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedTextBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 140)
SpeedTextBox.TextSize = 12
SpeedTextBox.Font = Enum.Font.GothamMedium
SpeedTextBox.ClearTextOnFocus = false
SpeedTextBox.Parent = SpeedControlRow

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedTextBox

local SpeedStroke = Instance.new("UIStroke")
SpeedStroke.Color = Color3.fromRGB(45, 45, 55)
SpeedStroke.Thickness = 1.5
SpeedStroke.Parent = SpeedTextBox

local SetSpeedButton = Instance.new("TextButton")
SetSpeedButton.Name = "SetSpeedButton"
SetSpeedButton.Size = UDim2.new(0.30, 0, 1, 0)
SetSpeedButton.Position = UDim2.new(0.70, 0, 0, 0)
SetSpeedButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SetSpeedButton.BorderSizePixel = 0
SetSpeedButton.Text = "SET SPEED"
SetSpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SetSpeedButton.TextSize = 11
SetSpeedButton.Font = Enum.Font.GothamBold
SetSpeedButton.Parent = SpeedControlRow

local SetBtnCorner = Instance.new("UICorner")
SetBtnCorner.CornerRadius = UDim.new(0, 6)
SetBtnCorner.Parent = SetSpeedButton

SetSpeedButton.MouseButton1Click:Connect(function()
    local num = tonumber(SpeedTextBox.Text)
    if num then CustomSpeedValue = num end
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = CustomSpeedValue end
    end)
    FeatureStates.Speed = true
end)

CreateToggleRow("Enable Speed Boost", "Speed")
CreateToggleRow("Auto Farm Coins (Collect Drops)", "AutoFarmCoins")
CreateToggleRow("Infinite Pressure & Water", "InfWater")
CreateToggleRow("Auto Sort Objects", "AutoSort")
CreateToggleRow("Auto Clean Dirt", "AutoClean")

-- Custom Cash Input Box Row
local CashInputRow = Instance.new("Frame")
CashInputRow.Name = "CashInputRow"
CashInputRow.Size = UDim2.new(1, 0, 0, 38)
CashInputRow.BackgroundTransparency = 1
CashInputRow.Parent = Content

local CashTextBox = Instance.new("TextBox")
CashTextBox.Name = "CashTextBox"
CashTextBox.Size = UDim2.new(0.66, 0, 1, 0)
CashTextBox.Position = UDim2.new(0, 0, 0, 0)
CashTextBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
CashTextBox.BorderSizePixel = 0
CashTextBox.PlaceholderText = "Enter Cash..."
CashTextBox.Text = "9999999"
CashTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
CashTextBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 140)
CashTextBox.TextSize = 12
CashTextBox.Font = Enum.Font.GothamMedium
CashTextBox.ClearTextOnFocus = false
CashTextBox.Parent = CashInputRow

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = CashTextBox

local BoxStroke = Instance.new("UIStroke")
BoxStroke.Color = Color3.fromRGB(45, 45, 55)
BoxStroke.Thickness = 1.5
BoxStroke.Parent = CashTextBox

local AddCashButton = Instance.new("TextButton")
AddCashButton.Name = "AddCashButton"
AddCashButton.Size = UDim2.new(0.30, 0, 1, 0)
AddCashButton.Position = UDim2.new(0.70, 0, 0, 0)
AddCashButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
AddCashButton.BorderSizePixel = 0
AddCashButton.Text = "ADD CASH"
AddCashButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AddCashButton.TextSize = 11
AddCashButton.Font = Enum.Font.GothamBold
AddCashButton.Parent = CashInputRow

local AddBtnCorner = Instance.new("UICorner")
AddBtnCorner.CornerRadius = UDim.new(0, 6)
AddBtnCorner.Parent = AddCashButton

-- Deep Comprehensive Cash Injector
local function ApplyCash(val)
    local targetVal = tonumber(val) or CustomCashAmount
    pcall(function()
        for _, obj in ipairs(LocalPlayer:GetDescendants()) do
            if obj:IsA("ValueBase") then
                local n = obj.Name:lower()
                if n:find("cash") or n:find("coin") or n:find("money") or n:find("dollar") or n:find("clean") or n:find("balance") or n:find("val") then
                    obj.Value = targetVal
                end
            end
        end

        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local n = remote.Name:lower()
                if n:find("cash") or n:find("coin") or n:find("money") or n:find("earn") or n:find("reward") or n:find("clean") or n:find("add") then
                    pcall(function()
                        remote:FireServer(targetVal)
                        remote:FireServer("Cash", targetVal)
                        remote:FireServer(100000)
                    end)
                end
            end
        end
    end)
end

AddCashButton.MouseButton1Click:Connect(function()
    local text = CashTextBox.Text
    local num = tonumber(text)
    if num then CustomCashAmount = num end
    ApplyCash(CustomCashAmount)
end)

-- Teleport to Next Room Logic
local CurrentRoomIndex = 1
local function TeleportToNextRoom()
    pcall(function()
        local rooms = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local n = obj.Name:lower()
                if n:find("room") or n:find("door") or n:find("house") or n:find("stage") or n:find("area") or n:find("floor") then
                    table.insert(rooms, obj)
                end
            end
        end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if #rooms > 0 then
                CurrentRoomIndex = (CurrentRoomIndex % #rooms) + 1
                local targetObj = rooms[CurrentRoomIndex]
                local targetCF = targetObj:IsA("Model") and targetObj:GetPivot() or targetObj.CFrame
                hrp.CFrame = targetCF + Vector3.new(0, 3, 0)
            else
                hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -40)
            end
        end
    end)
end

ActionButton.MouseButton1Click:Connect(function()
    TeleportToNextRoom()
end)

-- Speed Boost Loop (Managed by CustomSpeedValue)
RunService.Stepped:Connect(function()
    if FeatureStates.Speed then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = CustomSpeedValue end
        end)
    end
end)

-- Infinite Pressure & Water Capacity Loop
RunService.Stepped:Connect(function()
    if FeatureStates.InfWater then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, item in ipairs(char:GetChildren()) do
                    if item:IsA("Tool") then
                        for _, v in ipairs(item:GetDescendants()) do
                            if v:IsA("ValueBase") then
                                local name = v.Name:lower()
                                if name:find("water") or name:find("pressure") or name:find("tank") or name:find("fuel") or name:find("ammo") then
                                    v.Value = 999999
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Background Processing Loop (Coins, Sort, Clean)
task.spawn(function()
    while true do
        task.wait(0.15)
        
        -- AUTO FARM COINS (Scattered Coin Collection)
        if FeatureStates.AutoFarmCoins then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, item in ipairs(Workspace:GetDescendants()) do
                        if item:IsA("BasePart") or item:IsA("Model") then
                            local n = item.Name:lower()
                            if n:find("coin") or n:find("cash") or n:find("dollar") or n:find("money") or n:find("drop") or n:find("orb") or n:find("reward") then
                                local p = item:IsA("BasePart") and item or item:FindFirstChildOfClass("BasePart")
                                if p then
                                    p.CFrame = hrp.CFrame
                                    if firetouchinterest then
                                        firetouchinterest(hrp, p, 0)
                                        firetouchinterest(hrp, p, 1)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end

        -- AUTO CLEAN DIRT
        if FeatureStates.AutoClean then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Texture") or obj:IsA("Decal") then
                        local n = obj.Name:lower()
                        if n:find("dirt") or n:find("stain") or n:find("clean") or n:find("grime") or n:find("mess") or n:find("spot") then
                            if obj:IsA("Texture") or obj:IsA("Decal") then
                                obj.Transparency = 1
                            elseif obj:IsA("BasePart") then
                                obj.Transparency = 1
                                if firetouchinterest and hrp then
                                    firetouchinterest(hrp, obj, 0)
                                    firetouchinterest(hrp, obj, 1)
                                end
                            end
                        end
                    end
                end
            end)
        end

        -- AUTO SORT OBJECTS (Universal ProximityPrompt / ClickDetector / Teleport)
        if FeatureStates.AutoSort then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                -- Fire all ProximityPrompts & ClickDetectors in workspace
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and fireproximityprompt then
                        pcall(function() fireproximityprompt(obj, 0) end)
                    elseif obj:IsA("ClickDetector") and fireclickdetector then
                        pcall(function() fireclickdetector(obj) end)
                    end
                end

                -- Teleport sortable items to Player
                if hrp then
                    for _, item in ipairs(Workspace:GetDescendants()) do
                        if item:IsA("Model") or item:IsA("BasePart") then
                            local n = item.Name:lower()
                            if n:find("trash") or n:find("toy") or n:find("box") or n:find("item") or n:find("cloth") or n:find("dirty") or n:find("cup") or n:find("bottle") or n:find("can") or n:find("mess") or n:find("object") or n:find("prop") or n:find("sort") then
                                local p = item:IsA("BasePart") and item or item:FindFirstChildOfClass("BasePart")
                                if p and not p:IsDescendantOf(char) then
                                    p.CFrame = hrp.CFrame
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)
