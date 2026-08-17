--[[
    JUNEJO ULTRA SCRIPT HUB - CAPYBARAS VS PLANTS!
    Official Roblox Script for Capybaras VS Plants (Place ID: 104973076655377)
    Created for junejo18146
    GitHub Repository: junejo18146/ultrascripthub
--]]

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Container Helper (Compatible with Delta Executor and all mobile/PC executors)
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
for _, name in ipairs({"JunejoKeySystemUI_Capybaras", "JunejoHubUI_Capybaras"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

-- Key Configuration & Links
local GAME_KEY_PREFIX = "CVP_"
local ONLINE_KEY_RAW_URL = "https://raw.githubusercontent.com/junejo18146/ultrascripthub/main/key_capybaras_vs_plants.txt"
local LOOTLABS_GET_KEY_LINK = "https://lootdest.org/s?nGsQXoyj"

local VALID_KEYS = {
    ["CVP_K8F2N9X4P7Q1M5W3Z6B8R0L2T4J9H1C5"] = true
}

-- Fetch Live Online Keys from GitHub
pcall(function()
    local onlineKeyData = game:HttpGet(ONLINE_KEY_RAW_URL)
    if onlineKeyData then
        for line in onlineKeyData:gmatch("[^\r\n]+") do
            local cleanKey = line:gsub("%s+", "")
            if #cleanKey > 5 then
                VALID_KEYS[cleanKey] = true
            end
        end
    end
end)

----------------------------------------------------
-- SAFE BACKGROUND AUTO CLOSE SOCIAL / GROUP POPUPS HANDLER
----------------------------------------------------
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local targets = {LocalPlayer:FindFirstChild("PlayerGui"), CoreGui}
            for _, guiParent in ipairs(targets) do
                if guiParent then
                    for _, elem in ipairs(guiParent:GetDescendants()) do
                        -- NEVER click anything inside Junejo UI!
                        if elem:FindFirstAncestor("JunejoKeySystemUI_Capybaras") or elem:FindFirstAncestor("JunejoHubUI_Capybaras") then
                            continue
                        end
                        if elem:IsA("TextButton") or elem:IsA("ImageButton") then
                            local txt = (elem:IsA("TextButton") and elem.Text or ""):lower()
                            local name = elem.Name:lower()
                            -- Only click external Roblox dialog "Not Now" buttons
                            if txt == "not now" or txt:find("not now") then
                                if firesignal then
                                    pcall(function() firesignal(elem.MouseButton1Click) end)
                                    pcall(function() firesignal(elem.Activated) end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

----------------------------------------------------
-- MAIN HUB SCRIPT IMPLEMENTATION (AFTER VERIFICATION)
----------------------------------------------------
local function LaunchMainHub()
    if UIContainer:FindFirstChild("JunejoHubUI_Capybaras") then
        UIContainer.JunejoHubUI_Capybaras:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "JunejoHubUI_Capybaras"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999999
    ScreenGui.Parent = UIContainer

    -- Main Modal Frame (Compact Size: 320 x 350)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -175)
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
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 14, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "CAPYBARAS VS PLANTS"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 15
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 42, 0, 42)
    CloseButton.Position = UDim2.new(1, -42, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(160, 160, 170)
    CloseButton.TextSize = 15
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = Header

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Make Header Draggable
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

    -- Scrollable Content Frame (Auto Canvas)
    local ScrollContent = Instance.new("ScrollingFrame")
    ScrollContent.Name = "ScrollContent"
    ScrollContent.Size = UDim2.new(1, -24, 1, -95)
    ScrollContent.Position = UDim2.new(0, 12, 0, 44)
    ScrollContent.BackgroundTransparency = 1
    ScrollContent.BorderSizePixel = 0
    ScrollContent.ScrollBarThickness = 3
    ScrollContent.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
    ScrollContent.CanvasSize = UDim2.new(0, 0, 0, 260)
    ScrollContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollContent.Parent = MainFrame

    local UIList = Instance.new("UIListLayout")
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 8)
    UIList.Parent = ScrollContent

    -- Footer Frame
    local Footer = Instance.new("Frame")
    Footer.Name = "Footer"
    Footer.Size = UDim2.new(1, 0, 0, 50)
    Footer.Position = UDim2.new(0, 0, 1, -50)
    Footer.BackgroundTransparency = 1
    Footer.Parent = MainFrame

    local FooterTitle = Instance.new("TextLabel")
    FooterTitle.Size = UDim2.new(1, 0, 0, 18)
    FooterTitle.Position = UDim2.new(0, 0, 0, 6)
    FooterTitle.BackgroundTransparency = 1
    FooterTitle.Text = "ULTRA SCRIPT HUB"
    FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    FooterTitle.TextSize = 14
    FooterTitle.Font = Enum.Font.GothamBold
    FooterTitle.Parent = Footer

    local FooterSub = Instance.new("TextLabel")
    FooterSub.Size = UDim2.new(1, 0, 0, 16)
    FooterSub.Position = UDim2.new(0, 0, 0, 24)
    FooterSub.BackgroundTransparency = 1
    FooterSub.Text = "Made by Junejo"
    FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
    FooterSub.TextSize = 11
    FooterSub.Font = Enum.Font.GothamMedium
    FooterSub.Parent = Footer

    ----------------------------------------------------
    -- SCRIPT STATES & HELPER FUNCTIONS
    ----------------------------------------------------
    local Flags = {
        AutoFarm = false,
        AutoBuyBest = false,
        AutoCollectMoney = false,
        InfiniteJump = false
    }

    -- Infinite Jump Listener
    UserInputService.JumpRequest:Connect(function()
        if Flags.InfiniteJump then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)

    -- Helper: Toggle Row Generator
    local function AddToggle(text, default, callback)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 34)
        Row.BackgroundTransparency = 1
        Row.Parent = ScrollContent

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -40, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(240, 240, 240)
        Label.TextSize = 13
        Label.Font = Enum.Font.GothamBold
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Row

        local CheckBox = Instance.new("TextButton")
        CheckBox.Size = UDim2.new(0, 28, 0, 28)
        CheckBox.Position = UDim2.new(1, -28, 0.5, -14)
        CheckBox.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
        CheckBox.BorderSizePixel = 0
        CheckBox.Text = ""
        CheckBox.Parent = Row

        local CheckCorner = Instance.new("UICorner")
        CheckCorner.CornerRadius = UDim.new(0, 6)
        CheckCorner.Parent = CheckBox

        local CheckStroke = Instance.new("UIStroke")
        CheckStroke.Color = Color3.fromRGB(45, 45, 55)
        CheckStroke.Thickness = 1
        CheckStroke.Parent = CheckBox

        local CheckMark = Instance.new("Frame")
        CheckMark.Size = UDim2.new(0.6, 0, 0.6, 0)
        CheckMark.Position = UDim2.new(0.2, 0, 0.2, 0)
        CheckMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        CheckMark.BackgroundTransparency = default and 0 or 1
        CheckMark.Parent = CheckBox

        local MarkCorner = Instance.new("UICorner")
        MarkCorner.CornerRadius = UDim.new(0, 3)
        MarkCorner.Parent = CheckMark

        local toggled = default or false
        CheckBox.MouseButton1Click:Connect(function()
            toggled = not toggled
            CheckMark.BackgroundTransparency = toggled and 0 or 1
            if callback then callback(toggled) end
        end)
    end

    ----------------------------------------------------
    -- ULTRA-ROBUST MULTI-LAYER FEATURE IMPLEMENTATION
    ----------------------------------------------------

    -- 1. Auto Farm 💰 (Complete Ultra Farming Loop)
    AddToggle("Auto Farm 💰", false, function(v)
        Flags.AutoFarm = v
    end)

    task.spawn(function()
        while task.wait(0.15) do
            if Flags.AutoFarm then
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart

                        -- Auto Tool Equip & Activate
                        local tool = char:FindFirstChildOfClass("Tool")
                        if not tool and LocalPlayer:FindFirstChild("Backpack") then
                            tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if tool and char:FindFirstChildOfClass("Humanoid") then
                                char.Humanoid:EquipTool(tool)
                            end
                        end
                        if tool then
                            tool:Activate()
                        end

                        -- Layer 1: Target Filtering for ProximityPrompts, ClickDetectors & Touch
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if not Flags.AutoFarm then break end
                            if obj:IsA("ProximityPrompt") then
                                local pName = (obj.Parent and obj.Parent.Name or ""):lower()
                                local oText = (obj.ObjectText or ""):lower()
                                local aText = (obj.ActionText or ""):lower()
                                local fullText = pName .. " " .. oText .. " " .. aText

                                if not (fullText:find("group") or fullText:find("join") or fullText:find("event") or fullText:find("social") or fullText:find("community") or fullText:find("like") or fullText:find("badge") or fullText:find("pass")) then
                                    if fireproximityprompt then fireproximityprompt(obj, 1) end
                                end
                            elseif obj:IsA("ClickDetector") then
                                local cName = (obj.Parent and obj.Parent.Name or ""):lower()
                                if not (cName:find("group") or cName:find("join") or cName:find("event")) then
                                    if fireclickdetector then fireclickdetector(obj) end
                                end
                            elseif obj:IsA("TouchTransmitter") and obj.Parent then
                                local tName = obj.Parent.Name:lower()
                                if tName:find("plant") or tName:find("boss") or tName:find("enemy") or tName:find("wave") or tName:find("attack") or tName:find("capybara") or tName:find("crop") or tName:find("harvest") then
                                    firetouchinterest(hrp, obj.Parent, 0)
                                    task.wait(0.01)
                                    firetouchinterest(hrp, obj.Parent, 1)
                                end
                            end
                        end

                        -- Layer 2: Farm & Attack Remotes Scanner
                        local function scanFarmRemotes(folder)
                            for _, item in ipairs(folder:GetChildren()) do
                                if not Flags.AutoFarm then break end
                                if item:IsA("RemoteEvent") or item:IsA("RemoteFunction") then
                                    local name = item.Name:lower()
                                    if name:find("attack") or name:find("hit") or name:find("farm") or name:find("damage") or name:find("plant") or name:find("wave") or name:find("fight") or name:find("shoot") or name:find("kill") or name:find("combat") or name:find("harvest") then
                                        if not (name:find("group") or name:find("social") or name:find("event")) then
                                            if item:IsA("RemoteEvent") then
                                                item:FireServer()
                                                item:FireServer(true)
                                                item:FireServer(1)
                                            elseif item:IsA("RemoteFunction") then
                                                pcall(function() item:InvokeServer() end)
                                            end
                                        end
                                    end
                                elseif item:IsA("Folder") or item:IsA("Configuration") or item:IsA("Model") then
                                    scanFarmRemotes(item)
                                end
                            end
                        end

                        if ReplicatedStorage then
                            scanFarmRemotes(ReplicatedStorage)
                        end
                    end
                end)
            end
        end
    end)

    -- 2. Auto Buy Best Capybara 🐹
    AddToggle("Auto Buy Best Capybara 🐹", false, function(v)
        Flags.AutoBuyBest = v
    end)

    task.spawn(function()
        while task.wait(0.5) do
            if Flags.AutoBuyBest then
                pcall(function()
                    -- Layer 1: Remotes for buying best capybara / unit upgrades
                    local function scanCapybaraRemotes(folder)
                        for _, item in ipairs(folder:GetChildren()) do
                            if not Flags.AutoBuyBest then break end
                            if item:IsA("RemoteEvent") or item:IsA("RemoteFunction") then
                                local name = item.Name:lower()
                                if name:find("capybara") or name:find("unit") or name:find("buybest") or name:find("strongest") or name:find("upgradeunit") or name:find("summon") or name:find("upgrade") then
                                    if item:IsA("RemoteEvent") then
                                        item:FireServer()
                                        item:FireServer(true)
                                        item:FireServer(1)
                                    elseif item:IsA("RemoteFunction") then
                                        pcall(function() item:InvokeServer() end)
                                    end
                                end
                            elseif item:IsA("Folder") or item:IsA("Configuration") or item:IsA("Model") then
                                scanCapybaraRemotes(item)
                            end
                        end
                    end

                    if ReplicatedStorage then
                        scanCapybaraRemotes(ReplicatedStorage)
                    end

                    -- Layer 2: Auto-click Unit Shop Buttons in PlayerGui
                    if LocalPlayer:FindFirstChild("PlayerGui") then
                        for _, guiItem in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                            if not Flags.AutoBuyBest then break end
                            if guiItem:IsA("TextButton") or guiItem:IsA("ImageButton") then
                                local bName = guiItem.Name:lower()
                                local bText = (guiItem:IsA("TextButton") and guiItem.Text or ""):lower()
                                if bName:find("buybest") or bName:find("upgrade") or bText:find("buy best") or bText:find("upgrade capybara") or bText:find("best") then
                                    if firesignal then
                                        pcall(function() firesignal(guiItem.MouseButton1Click) end)
                                        pcall(function() firesignal(guiItem.Activated) end)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)

    -- 3. Auto Collect Money 💵
    AddToggle("Auto Collect Money 💵", false, function(v)
        Flags.AutoCollectMoney = v
    end)

    task.spawn(function()
        while task.wait(0.15) do
            if Flags.AutoCollectMoney then
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart

                        -- Layer 1: TouchInterest & BasePart Money Drops
                        for _, item in ipairs(Workspace:GetDescendants()) do
                            if not Flags.AutoCollectMoney then break end
                            if item:IsA("BasePart") then
                                local iName = item.Name:lower()
                                if iName:find("cash") or iName:find("coin") or iName:find("money") or iName:find("drop") or iName:find("reward") or iName:find("collector") or iName:find("collect") or iName:find("bank") or iName:find("income") or iName:find("deposit") or iName:find("orb") or iName:find("currency") or iName:find("plot") then
                                    firetouchinterest(hrp, item, 0)
                                    task.wait(0.01)
                                    firetouchinterest(hrp, item, 1)
                                end
                            end
                        end

                        -- Layer 2: Universal Remote Scanner for Money Collection
                        local function scanCollectRemotes(folder)
                            for _, item in ipairs(folder:GetChildren()) do
                                if not Flags.AutoCollectMoney then break end
                                if item:IsA("RemoteEvent") then
                                    local name = item.Name:lower()
                                    if name:find("collect") or name:find("claimcash") or name:find("income") or name:find("money") or name:find("cash") or name:find("deposit") or name:find("payout") or name:find("earn") or name:find("coin") or name:find("claim") then
                                        item:FireServer()
                                        item:FireServer(true)
                                        item:FireServer(1)
                                    end
                                elseif item:IsA("Folder") or item:IsA("Configuration") or item:IsA("Model") then
                                    scanCollectRemotes(item)
                                end
                            end
                        end

                        if ReplicatedStorage then
                            scanCollectRemotes(ReplicatedStorage)
                        end
                    end
                end)
            end
        end
    end)

    -- 4. Infinite Jump 🪽
    AddToggle("Infinite Jump 🪽", false, function(v)
        Flags.InfiniteJump = v
    end)

end

----------------------------------------------------
-- DIRECT LAUNCH (KEY SYSTEM DISABLED)
----------------------------------------------------
LaunchMainHub()
