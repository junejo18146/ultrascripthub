--[[
    JUNEJO ULTRA SCRIPT HUB - GARDEN CLEANER EVOLUTION (V6 PERFECTION FIX)
    GitHub: junejo18146 / ultrascripthub
    Theme: Exact Junejo Dark Matte Template (#0F0F11, 320x380px)
    Key System Monetization Enabled
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- Global Feature Config
local Config = {
    KeyRawUrl = "https://raw.githubusercontent.com/junejo18146/ultrascripthub/main/key_garden_cleaner_evolution.txt",
    FallbackKey = "GCE_K8F2N9X4P7Q1M5W3Z6B8R0L2T4J9H1C5",
    LootLabsUrl = "https://lootdest.org/s?GardenCleanerKey",
    
    AutoLeaves = false,
    AutoClean = false,
    AutoSell = false,
    AutoRebirth = false,
    AutoUpgrades = false,
    AutoCollectCoins = false,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

-- Cleanup Previous Instantiations
if CoreGui:FindFirstChild("JunejoGardenCleanerKeyUI") then
    CoreGui.JunejoGardenCleanerKeyUI:Destroy()
end
if CoreGui:FindFirstChild("JunejoGardenCleanerMainUI") then
    CoreGui.JunejoGardenCleanerMainUI:Destroy()
end

--------------------------------------------------------------------------------
-- DRAGGABLE HELPER
--------------------------------------------------------------------------------
local function MakeDraggable(guiObject, handleObject)
    handleObject = handleObject or guiObject
    local dragging, dragInput, dragStart, startPos

    handleObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handleObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--------------------------------------------------------------------------------
-- STABLE AUTOMATION LOOPS (PERFECT CLEAN & NO VISUAL TRAILING)
--------------------------------------------------------------------------------

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- WalkSpeed Boost Lock
RunService.RenderStepped:Connect(function()
    if Config.WalkSpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 50
    end
end)

-- 1 & 2. AUTO LEAVES & AUTO CLEAN GARDEN (PERFECT CLEAN & ZERO VISUAL TRAILING)
task.spawn(function()
    while task.wait(0.03) do
        if Config.AutoLeaves or Config.AutoClean then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")

                if root and hum then
                    -- Hold Click Simulation
                    VirtualUser:Button1Down(Vector2.new(500, 500))

                    -- Equip & Activate Tool
                    local backpack = LocalPlayer.Backpack
                    if backpack then
                        for _, tool in pairs(backpack:GetChildren()) do
                            if tool:IsA("Tool") then
                                hum:EquipTool(tool)
                            end
                        end
                    end
                    for _, tool in pairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            tool:Activate()
                        end
                    end

                    -- Supercharged Leaf Collection with Instant Transparency (No Visual Trailing)
                    for _, item in pairs(workspace:GetDescendants()) do
                        if not (Config.AutoLeaves or Config.AutoClean) then break end
                        if item:IsA("BasePart") and item.Parent then
                            local n = item.Name:lower()
                            local pName = item.Parent.Name:lower()

                            if n:find("leaf") or n:find("leaves") or n:find("dirt") or n:find("weed") or n:find("trash") or n:find("clean") or n:find("starter") or pName:find("leaf") or pName:find("leaves") or item:FindFirstChildOfClass("TouchTransmitter") then
                                -- Make completely invisible & non-collidable so NO trailing line appears on screen
                                pcall(function()
                                    item.CanCollide = false
                                    item.Transparency = 1
                                    for _, child in pairs(item:GetChildren()) do
                                        if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SpecialMesh") then
                                            pcall(function() child.Transparency = 1 end)
                                        end
                                    end
                                end)

                                -- Touch Interest
                                if firetouchinterest then
                                    firetouchinterest(root, item, 0)
                                    task.wait()
                                    firetouchinterest(root, item, 1)
                                end

                                -- Instant Position Touch
                                pcall(function()
                                    item.CFrame = root.CFrame
                                end)

                                -- Proximity Prompt
                                local prompt = item:FindFirstChildOfClass("ProximityPrompt") or item.Parent:FindFirstChildOfClass("ProximityPrompt")
                                if prompt and fireproximityprompt then
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end

                    -- Remotes Broadcaster
                    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") then
                            local rName = remote.Name:lower()
                            if rName:find("clean") or rName:find("leaf") or rName:find("collect") or rName:find("mow") or rName:find("swing") or rName:find("rake") or rName:find("vacuum") then
                                pcall(function() remote:FireServer() end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. AUTO SELL BAG
task.spawn(function()
    while task.wait(0.3) do
        if Config.AutoSell then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")

                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local rName = remote.Name:lower()
                        if rName:find("sell") or rName:find("deposit") or rName:find("convert") then
                            pcall(function() remote:FireServer() end)
                        end
                    end
                end

                if root then
                    for _, item in pairs(workspace:GetDescendants()) do
                        if not Config.AutoSell then break end
                        if item:IsA("BasePart") and (item.Name:lower():find("sell") or item.Name:lower():find("deposit")) then
                            if firetouchinterest then
                                firetouchinterest(root, item, 0)
                                task.wait(0.02)
                                firetouchinterest(root, item, 1)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. AUTO REBIRTH
task.spawn(function()
    while task.wait(0.8) do
        if Config.AutoRebirth then
            pcall(function()
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local rName = remote.Name:lower()
                        if rName:find("rebirth") or rName:find("ascend") or rName:find("prestige") then
                            pcall(function() remote:FireServer() end)
                        end
                    end
                end
            end)
        end
    end
end)

-- 5. AUTO UPGRADES
task.spawn(function()
    while task.wait(0.8) do
        if Config.AutoUpgrades then
            pcall(function()
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local rName = remote.Name:lower()
                        if rName:find("upgrade") or rName:find("buy") then
                            pcall(function()
                                remote:FireServer("Cleaner")
                                remote:FireServer("Bag")
                                remote:FireServer("Speed")
                                remote:FireServer("Capacity")
                            end)
                        end
                    end
                end
            end)
        end
    end
end)

-- 6. AUTO COLLECT COINS
task.spawn(function()
    while task.wait(0.2) do
        if Config.AutoCollectCoins then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")

                if root then
                    for _, item in pairs(workspace:GetDescendants()) do
                        if not Config.AutoCollectCoins then break end
                        if item:IsA("BasePart") then
                            local n = item.Name:lower()
                            if n:find("coin") or n:find("gem") or n:find("cash") or n:find("money") or n:find("orb") then
                                if firetouchinterest then
                                    firetouchinterest(root, item, 0)
                                    task.wait()
                                    firetouchinterest(root, item, 1)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------------------
-- MAIN EXECUTION HUB UI (EXACT JUNEJO UI TEMPLATE)
--------------------------------------------------------------------------------
local function LoadMainHub()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "JunejoGardenCleanerMainUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
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

    MakeDraggable(MainFrame, Header)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "GARDEN CLEANER EVOLUTION"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
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

    -- Content Scrolling Frame
    local Content = Instance.new("ScrollingFrame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -32, 1, -115)
    Content.Position = UDim2.new(0, 16, 0, 45)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 3
    Content.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    Content.CanvasSize = UDim2.new(0, 0, 0, 360)
    Content.Parent = MainFrame

    local UIList = Instance.new("UIListLayout")
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 10)
    UIList.Parent = Content

    -- Toggle Switch Row (EXACT JUNEJO TEMPLATE)
    local function AddToggleRow(order, text, configKey)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 36)
        Row.BackgroundTransparency = 1
        Row.LayoutOrder = order
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
        CheckMark.BackgroundTransparency = Config[configKey] and 0 or 1
        CheckMark.Parent = CheckBox

        local MarkCorner = Instance.new("UICorner")
        MarkCorner.CornerRadius = UDim.new(0, 4)
        MarkCorner.Parent = CheckMark

        -- Full Row Touch Overlay
        local OverlayBtn = Instance.new("TextButton")
        OverlayBtn.Size = UDim2.new(1, 0, 1, 0)
        OverlayBtn.BackgroundTransparency = 1
        OverlayBtn.Text = ""
        OverlayBtn.ZIndex = 5
        OverlayBtn.Parent = Row

        OverlayBtn.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            CheckMark.BackgroundTransparency = Config[configKey] and 0 or 1
            if configKey == "WalkSpeedBoost" and not Config.WalkSpeedBoost then
                pcall(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
                    end
                end)
            end
        end)
    end

    -- Add Features
    AddToggleRow(1, "Auto Initial Leaves", "AutoLeaves")
    AddToggleRow(2, "Auto Clean Garden", "AutoClean")
    AddToggleRow(3, "Auto Sell Bag", "AutoSell")
    AddToggleRow(4, "Auto Rebirth", "AutoRebirth")
    AddToggleRow(5, "Auto Upgrades", "AutoUpgrades")
    AddToggleRow(6, "Auto Collect Coins", "AutoCollectCoins")
    AddToggleRow(7, "WalkSpeed Boost", "WalkSpeedBoost")
    AddToggleRow(8, "Infinite Jump", "InfiniteJump")

    -- Footer Frame
    local Footer = Instance.new("Frame")
    Footer.Name = "Footer"
    Footer.Size = UDim2.new(1, 0, 0, 65)
    Footer.Position = UDim2.new(0, 0, 1, -65)
    Footer.BackgroundTransparency = 1
    Footer.Parent = MainFrame

    local FooterTitle = Instance.new("TextLabel")
    FooterTitle.Size = UDim2.new(1, 0, 0, 20)
    FooterTitle.Position = UDim2.new(0, 0, 0, 10)
    FooterTitle.BackgroundTransparency = 1
    FooterTitle.Text = "ULTRA SCRIPT HUB"
    FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    FooterTitle.TextSize = 16
    FooterTitle.Font = Enum.Font.GothamBold
    FooterTitle.Parent = Footer

    local FooterSub = Instance.new("TextLabel")
    FooterSub.Size = UDim2.new(1, 0, 0, 18)
    FooterSub.Position = UDim2.new(0, 0, 0, 32)
    FooterSub.BackgroundTransparency = 1
    FooterSub.Text = "Made by Junejo"
    FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
    FooterSub.TextSize = 13
    FooterSub.Font = Enum.Font.GothamMedium
    FooterSub.Parent = Footer
end

--------------------------------------------------------------------------------
-- KEY SYSTEM WINDOW
--------------------------------------------------------------------------------
----------------------------------------------------
-- DIRECT LAUNCH (KEY SYSTEM DISABLED)
----------------------------------------------------
LoadMainHub()
