--[[
    JUNEJO ULTRA SCRIPT HUB - GARDEN CLEANER EVOLUTION
    Target Game: Garden Cleaner Evolution (Roblox)
    Created for junejo18146
    GitHub Repository: junejo18146/ultrascripthub
    Status: Unlocked Direct Execution (3-Feature Edition)
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

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

-- Cleanup Previous Instantiations
for _, name in ipairs({"JunejoGardenCleanerMainUI", "JunejoGardenCleanerKeyUI", "JunejoHubUI_GardenCleaner"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

-- Global Feature Config (3 Selected Features Only)
local Config = {
    AutoLeaves = false,
    WalkSpeedBoost = false,
    InfiniteJump = false
}

--------------------------------------------------------------------------------
-- ANTI-AFK SYSTEM
--------------------------------------------------------------------------------
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

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
-- STABLE AUTOMATION LOOPS (3 FEATURES)
--------------------------------------------------------------------------------

-- 1. Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        pcall(function()
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

-- 2. WalkSpeed Boost Lock (50 Speed)
RunService.RenderStepped:Connect(function()
    if Config.WalkSpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        pcall(function()
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 50
        end)
    end
end)

-- 3. Auto Initial Leaves (Instant collection & tool activation)
task.spawn(function()
    while task.wait(0.05) do
        if Config.AutoLeaves then
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

                    -- Supercharged Leaf Collection with Zero Visual Trailing
                    for _, item in pairs(Workspace:GetDescendants()) do
                        if not Config.AutoLeaves then break end
                        if item:IsA("BasePart") and item.Parent then
                            local n = item.Name:lower()
                            local pName = item.Parent.Name:lower()

                            if n:find("leaf") or n:find("leaves") or n:find("starter") or n:find("initial") or pName:find("leaf") or pName:find("leaves") or item:FindFirstChildOfClass("TouchTransmitter") then
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

                    -- Remotes Broadcaster for Leaves
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

--------------------------------------------------------------------------------
-- MAIN EXECUTION HUB UI (JUNEJO ULTRA COMPACT DARK UI)
--------------------------------------------------------------------------------
local function LoadMainHub()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "JunejoGardenCleanerMainUI"
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
    MainFrame.Size = UDim2.new(0, 300, 0, 270)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -135)
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
    TitleLabel.TextSize = 14
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

    -- Content Frame
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -32, 0, 150)
    Content.Position = UDim2.new(0, 16, 0, 48)
    Content.BackgroundTransparency = 1
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

    -- Add 3 Selected Features Only
    AddToggleRow(1, "Auto Initial Leaves", "AutoLeaves")
    AddToggleRow(2, "WalkSpeed Boost (50)", "WalkSpeedBoost")
    AddToggleRow(3, "Infinite Jump", "InfiniteJump")

    -- Footer Frame
    local Footer = Instance.new("Frame")
    Footer.Name = "Footer"
    Footer.Size = UDim2.new(1, 0, 0, 58)
    Footer.Position = UDim2.new(0, 0, 1, -58)
    Footer.BackgroundTransparency = 1
    Footer.Parent = MainFrame

    local FooterTitle = Instance.new("TextLabel")
    FooterTitle.Size = UDim2.new(1, 0, 0, 18)
    FooterTitle.Position = UDim2.new(0, 0, 0, 8)
    FooterTitle.BackgroundTransparency = 1
    FooterTitle.Text = "ULTRA SCRIPT HUB"
    FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    FooterTitle.TextSize = 15
    FooterTitle.Font = Enum.Font.GothamBold
    FooterTitle.Parent = Footer

    local FooterSub = Instance.new("TextLabel")
    FooterSub.Size = UDim2.new(1, 0, 0, 16)
    FooterSub.Position = UDim2.new(0, 0, 0, 28)
    FooterSub.BackgroundTransparency = 1
    FooterSub.Text = "Made by Junejo"
    FooterSub.TextColor3 = Color3.fromRGB(136, 136, 153)
    FooterSub.TextSize = 12
    FooterSub.Font = Enum.Font.GothamMedium
    FooterSub.Parent = Footer
end

--------------------------------------------------------------------------------
-- DIRECT LAUNCH (KEYLESS & UNLOCKED)
--------------------------------------------------------------------------------
LoadMainHub()
