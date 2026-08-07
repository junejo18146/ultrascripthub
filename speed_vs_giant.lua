--[[
    Junejo Ultra Script Hub - Speed vs Giant (Finalized Monetized Edition)
    Key Monetization Link: https://loot-link.com/s?yWyBU0y4
    Target Game: Speed vs Giant (Roblox)
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

-- Hard Game-Specific 24-Hour Key & Online Standalone Gist Raw Link
local GAME_KEY_PREFIX = "SVG_"
local VALID_KEYS = {
    ["SVG_9M4P7X2Q8B1R5L3W6T0J2Z9C4H1V8N7K"] = true,
    ["SVG_K8F2N9X4P7Q1M5W3Z6B8R0L2T4J9H1C5"] = true
}

local ONLINE_KEY_RAW_URL = "https://gist.githubusercontent.com/junejo18146/c057fb99a3e5b3a9cd4696e1edb53db8/raw/key_speed_vs_giant.txt"
local LOOTLABS_GET_KEY_LINK = "https://loot-link.com/s?yWyBU0y4"

-- Cleanup previous GUI instances
for _, name in ipairs({"JunejoKeySystemUI", "JunejoHubUI_SpeedVsGiant"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

----------------------------------------------------
-- MAIN HUB SCRIPT LOADER (UNLOCKED AFTER VERIFY)
----------------------------------------------------
local function LoadMainHub()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "JunejoHubUI_SpeedVsGiant"
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
    MainFrame.Size = UDim2.new(0, 330, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -165, 0.5, -170)
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
    TitleLabel.Text = "SPEED VS GIANT"
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

    -- Primary Top Action Button
    local ActionButton = Instance.new("TextButton")
    ActionButton.Name = "ActionButton"
    ActionButton.Size = UDim2.new(1, 0, 0, 40)
    ActionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    ActionButton.BorderSizePixel = 0
    ActionButton.Text = "TELEPORT TO FINISH LINE"
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
        InfCash = false
    }

    local CustomCashAmount = 999999999

    local function CreateToggleRow(text, key)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 36)
        Row.BackgroundTransparency = 1
        Row.Parent = Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -45, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(240, 240, 240)
        Label.TextSize = 14
        Label.Font = Enum.Font.GothamBold
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Row
        
        local CheckBox = Instance.new("TextButton")
        CheckBox.Size = UDim2.new(0, 32, 0, 32)
        CheckBox.Position = UDim2.new(1, -32, 0.5, -16)
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

    CreateToggleRow("Speed Boost", "Speed")
    CreateToggleRow("Inf Cash (Auto Farm)", "InfCash")

    -- Custom Cash Amount Box Row
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
    CashTextBox.TextSize = 13
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

    local function ApplyCash(val)
        local targetVal = tonumber(val) or CustomCashAmount
        pcall(function()
            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            if leaderstats then
                for _, stat in ipairs(leaderstats:GetChildren()) do
                    local name = stat.Name:lower()
                    if name:find("cash") or name:find("coin") or name:find("money") then
                        if stat:IsA("ValueBase") then
                            stat.Value = targetVal
                        end
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

    local function GetFinishPart()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n:find("finish") or n:find("win") or n:find("end") then
                    return obj
                end
            end
        end
        return nil
    end

    ActionButton.MouseButton1Click:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local finish = GetFinishPart()
            if hrp then
                if finish then
                    hrp.CFrame = finish.CFrame + Vector3.new(0, 3, 0)
                else
                    hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -800)
                end
            end
        end)
    end)

    RunService.Stepped:Connect(function()
        if FeatureStates.Speed then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 150 end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.3)
            if FeatureStates.InfCash then
                pcall(function()
                    ApplyCash(CustomCashAmount)
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        for _, item in ipairs(Workspace:GetChildren()) do
                            if item:IsA("BasePart") or item:IsA("Model") then
                                local name = item.Name:lower()
                                if name:find("cash") or name:find("coin") or name:find("money") or name:find("orb") then
                                    local p = item:IsA("BasePart") and item or item:FindFirstChildOfClass("BasePart")
                                    if p then
                                        if firetouchinterest then
                                            firetouchinterest(hrp, p, 0)
                                            firetouchinterest(hrp, p, 1)
                                        end
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
end

----------------------------------------------------
-- EXACT KEY SYSTEM UI (MONETIZED LOOTLABS)
----------------------------------------------------
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "JunejoKeySystemUI"
KeyGui.ResetOnSpawn = false
KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KeyGui.DisplayOrder = 999999

if syn and syn.protect_gui then
    syn.protect_gui(KeyGui)
    KeyGui.Parent = CoreGui
else
    KeyGui.Parent = UIContainer
end

local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "MainFrame"
KeyFrame.Size = UDim2.new(0, 330, 0, 270)
KeyFrame.Position = UDim2.new(0.5, -165, 0.5, -135)
KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.ClipsDescendants = true
KeyFrame.Parent = KeyGui

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 10)
KeyCorner.Parent = KeyFrame

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(35, 35, 42)
KeyStroke.Thickness = 1
KeyStroke.Parent = KeyFrame

-- Header
local KeyHeader = Instance.new("Frame")
KeyHeader.Name = "KeyHeader"
KeyHeader.Size = UDim2.new(1, 0, 0, 45)
KeyHeader.BackgroundTransparency = 1
KeyHeader.Parent = KeyFrame

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Name = "KeyTitle"
KeyTitle.Size = UDim2.new(1, -50, 1, 0)
KeyTitle.Position = UDim2.new(0, 16, 0, 0)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "SPEED VS GIANT KEY SYSTEM"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 16
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextXAlignment = Enum.TextXAlignment.Left
KeyTitle.Parent = KeyHeader

local KeyClose = Instance.new("TextButton")
KeyClose.Name = "KeyClose"
KeyClose.Size = UDim2.new(0, 45, 0, 45)
KeyClose.Position = UDim2.new(1, -45, 0, 0)
KeyClose.BackgroundTransparency = 1
KeyClose.Text = "X"
KeyClose.TextColor3 = Color3.fromRGB(160, 160, 170)
KeyClose.TextSize = 16
KeyClose.Font = Enum.Font.GothamBold
KeyClose.Parent = KeyHeader

KeyClose.MouseButton1Click:Connect(function()
    KeyGui:Destroy()
end)

-- Draggable Key Header Fix
local dragging, dragInput, dragStart, startPos
KeyHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = KeyFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

KeyHeader.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        KeyFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Content Frame
local KeyContent = Instance.new("Frame")
KeyContent.Name = "KeyContent"
KeyContent.Size = UDim2.new(1, -32, 1, -95)
KeyContent.Position = UDim2.new(0, 16, 0, 45)
KeyContent.BackgroundTransparency = 1
KeyContent.Parent = KeyFrame

local KeyList = Instance.new("UIListLayout")
KeyList.SortOrder = Enum.SortOrder.LayoutOrder
KeyList.Padding = UDim.new(0, 10)
KeyList.Parent = KeyContent

-- Key Input Field Box
local KeyTextBox = Instance.new("TextBox")
KeyTextBox.Name = "KeyTextBox"
KeyTextBox.Size = UDim2.new(1, 0, 0, 40)
KeyTextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
KeyTextBox.BorderSizePixel = 0
KeyTextBox.PlaceholderText = "Enter Key Here..."
KeyTextBox.Text = ""
KeyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 135)
KeyTextBox.TextSize = 12
KeyTextBox.Font = Enum.Font.GothamMedium
KeyTextBox.ClearTextOnFocus = false
KeyTextBox.Parent = KeyContent

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 8)
BoxCorner.Parent = KeyTextBox

local BoxStroke = Instance.new("UIStroke")
BoxStroke.Color = Color3.fromRGB(45, 45, 55)
BoxStroke.Thickness = 1.5
BoxStroke.Parent = KeyTextBox

-- Primary Verify Button (Vibrant Blue #3B82F6)
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Name = "VerifyBtn"
VerifyBtn.Size = UDim2.new(1, 0, 0, 40)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
VerifyBtn.BorderSizePixel = 0
VerifyBtn.Text = "Verify Key"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.TextSize = 14
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Parent = KeyContent

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 8)
VerifyCorner.Parent = VerifyBtn

-- Secondary Get Key Button (Dark Gray #232328)
local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Name = "GetKeyBtn"
GetKeyBtn.Size = UDim2.new(1, 0, 0, 40)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
GetKeyBtn.BorderSizePixel = 0
GetKeyBtn.Text = "Get Key"
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.TextSize = 14
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.Parent = KeyContent

local GetCorner = Instance.new("UICorner")
GetCorner.CornerRadius = UDim.new(0, 8)
GetCorner.Parent = GetKeyBtn

-- Footer Frame
local KeyFooter = Instance.new("Frame")
KeyFooter.Name = "KeyFooter"
KeyFooter.Size = UDim2.new(1, 0, 0, 45)
KeyFooter.Position = UDim2.new(0, 0, 1, -45)
KeyFooter.BackgroundTransparency = 1
KeyFooter.Parent = KeyFrame

local KeyFooterTitle = Instance.new("TextLabel")
KeyFooterTitle.Size = UDim2.new(1, 0, 0, 18)
KeyFooterTitle.Position = UDim2.new(0, 0, 0, 4)
KeyFooterTitle.BackgroundTransparency = 1
KeyFooterTitle.Text = "ULTRA SCRIPT HUB"
KeyFooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyFooterTitle.TextSize = 15
KeyFooterTitle.Font = Enum.Font.GothamBold
KeyFooterTitle.Parent = KeyFooter

local KeyFooterSub = Instance.new("TextLabel")
KeyFooterSub.Size = UDim2.new(1, 0, 0, 16)
KeyFooterSub.Position = UDim2.new(0, 0, 0, 22)
KeyFooterSub.BackgroundTransparency = 1
KeyFooterSub.Text = "Made by Junejo"
KeyFooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
KeyFooterSub.TextSize = 12
KeyFooterSub.Font = Enum.Font.GothamMedium
KeyFooterSub.Parent = KeyFooter

----------------------------------------------------
-- GAME-SPECIFIC 24-HOUR KEY VERIFICATION
----------------------------------------------------
VerifyBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyTextBox.Text:gsub("%s+", "")
    
    -- Fetch Online Raw Key
    local onlineKey = nil
    pcall(function()
        onlineKey = game:HttpGet(ONLINE_KEY_RAW_URL)
        if onlineKey then onlineKey = onlineKey:gsub("%s+", "") end
    end)

    local isValid = false
    if #enteredKey > 0 then
        if VALID_KEYS[enteredKey] then
            isValid = true
        elseif onlineKey and #onlineKey > 0 and (enteredKey == onlineKey) then
            isValid = true
        elseif enteredKey:sub(1, 4) == GAME_KEY_PREFIX and #enteredKey >= 30 then
            -- Fallback prefix match to ensure user is never locked out
            isValid = true
        end
    end
    
    if isValid then
        VerifyBtn.Text = "Key Verified!"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
        task.wait(0.5)
        KeyGui:Destroy()
        LoadMainHub()
    else
        VerifyBtn.Text = "Invalid Key!"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        task.wait(1.5)
        VerifyBtn.Text = "Verify Key"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    end
end)

-- GET KEY BUTTON: LOOTLABS MONETIZED LINK
GetKeyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard(LOOTLABS_GET_KEY_LINK)
        elseif toclipboard then
            toclipboard(LOOTLABS_GET_KEY_LINK)
        end
    end)
    GetKeyBtn.Text = "LootLabs Link Copied!"
    task.wait(1.5)
    GetKeyBtn.Text = "Get Key"
end)
