--[[
    JUNEJO ULTRA SCRIPT HUB - SAVE ANIMALS!
    Official Roblox Script for Save Animals! (Place ID: 123822115505881)
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
for _, name in ipairs({"JunejoKeySystemUI_SaveAnimals", "JunejoHubUI_SaveAnimals"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

-- Key Configuration & Links
local GAME_KEY_PREFIX = "SA_"
local ONLINE_KEY_RAW_URL = "https://raw.githubusercontent.com/junejo18146/ultrascripthub/main/key_save_animals.txt"
local LOOTLABS_GET_KEY_LINK = "https://loot-link.com/s?24QWQW16"

local VALID_KEYS = {
    ["SA_K8F2N9X4P7Q1M5W3Z6B8R0L2T4J9H1C5"] = true
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
-- MAIN HUB SCRIPT IMPLEMENTATION (AFTER VERIFICATION)
----------------------------------------------------
local function LaunchMainHub()
    if UIContainer:FindFirstChild("JunejoHubUI_SaveAnimals") then
        UIContainer.JunejoHubUI_SaveAnimals:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "JunejoHubUI_SaveAnimals"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = UIContainer

    -- Main Modal Frame (Compact Size: 310 x 340)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 310, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -155, 0.5, -170)
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
    TitleLabel.Text = "SAVE ANIMALS!"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
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
    ScrollContent.CanvasSize = UDim2.new(0, 0, 0, 250)
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
        AutoRescue = false,
        AutoRebirth = false,
        AutoClaim = false,
        InfJump = false,
        Fly = false,
        FlySpeed = 50
    }

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
    -- 5 UPDATED FEATURES IMPLEMENTATION
    ----------------------------------------------------

    -- 1. Auto Rescue Animal
    AddToggle("Auto Rescue Animal", false, function(v)
        Flags.AutoRescue = v
    end)

    task.spawn(function()
        while task.wait(0.25) do
            if Flags.AutoRescue then
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart

                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if not Flags.AutoRescue then break end
                            if obj:IsA("ProximityPrompt") then
                                if fireproximityprompt then
                                    fireproximityprompt(obj, 1)
                                else
                                    pcall(function() obj:InputHoldBegan() end)
                                end
                            elseif obj:IsA("ClickDetector") then
                                if fireclickdetector then
                                    fireclickdetector(obj)
                                end
                            elseif obj:IsA("TouchTransmitter") and obj.Parent then
                                local name = obj.Parent.Name:lower()
                                if name:find("animal") or name:find("cage") or name:find("rescue") or name:find("pet") or name:find("steal") or name:find("zoo") then
                                    firetouchinterest(hrp, obj.Parent, 0)
                                    task.wait(0.01)
                                    firetouchinterest(hrp, obj.Parent, 1)
                                end
                            end
                        end

                        local function scanRemotes(folder)
                            for _, item in ipairs(folder:GetChildren()) do
                                if not Flags.AutoRescue then break end
                                if item:IsA("RemoteEvent") then
                                    local name = item.Name:lower()
                                    if name:find("rescue") or name:find("steal") or name:find("animal") or name:find("cage") or name:find("grab") or name:find("take") or name:find("interact") or name:find("save") or name:find("pet") then
                                        item:FireServer()
                                    end
                                elseif item:IsA("Folder") or item:IsA("Configuration") or item:IsA("Model") then
                                    scanRemotes(item)
                                end
                            end
                        end

                        if ReplicatedStorage then
                            scanRemotes(ReplicatedStorage)
                        end
                    end
                end)
            end
        end
    end)

    -- 2. Auto Rebirth (Multi-Layer Scanner & Execution)
    AddToggle("Auto Rebirth", false, function(v)
        Flags.AutoRebirth = v
    end)

    task.spawn(function()
        while task.wait(1.5) do
            if Flags.AutoRebirth then
                pcall(function()
                    -- Layer 1: Trigger Rebirth Remote Events & Functions in ReplicatedStorage
                    local function scanRebirthRemotes(folder)
                        for _, item in ipairs(folder:GetChildren()) do
                            if not Flags.AutoRebirth then break end
                            if item:IsA("RemoteEvent") or item:IsA("RemoteFunction") then
                                local name = item.Name:lower()
                                if name:find("rebirth") or name:find("prestige") or name:find("ascend") or name:find("reset") then
                                    if item:IsA("RemoteEvent") then
                                        item:FireServer()
                                    elseif item:IsA("RemoteFunction") then
                                        pcall(function() item:InvokeServer() end)
                                    end
                                end
                            elseif item:IsA("Folder") or item:IsA("Configuration") or item:IsA("Model") then
                                scanRebirthRemotes(item)
                            end
                        end
                    end

                    if ReplicatedStorage then
                        scanRebirthRemotes(ReplicatedStorage)
                    end

                    -- Layer 2: Click Rebirth GUI buttons in PlayerGui
                    if LocalPlayer:FindFirstChild("PlayerGui") then
                        for _, guiItem in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                            if not Flags.AutoRebirth then break end
                            if guiItem:IsA("TextButton") or guiItem:IsA("ImageButton") then
                                local bName = guiItem.Name:lower()
                                local bText = (guiItem:IsA("TextButton") and guiItem.Text or ""):lower()
                                if bName:find("rebirth") or bName:find("prestige") or bText:find("rebirth") or bText:find("prestige") then
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

    -- 3. Auto Claim Rewards
    AddToggle("Auto Claim Rewards", false, function(v)
        Flags.AutoClaim = v
    end)

    task.spawn(function()
        while task.wait(1.0) do
            if Flags.AutoClaim then
                pcall(function()
                    if LocalPlayer:FindFirstChild("PlayerGui") then
                        for _, guiItem in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                            if not Flags.AutoClaim then break end
                            if guiItem:IsA("TextButton") or guiItem:IsA("ImageButton") then
                                local bName = guiItem.Name:lower()
                                local bText = (guiItem:IsA("TextButton") and guiItem.Text or ""):lower()
                                if bName:find("claim") or bName:find("reward") or bName:find("daily") or bName:find("gift") or bName:find("free") or bName:find("spin") or bName:find("chest") or bText:find("claim") or bText:find("collect") or bText:find("free") then
                                    if firesignal then
                                        pcall(function() firesignal(guiItem.MouseButton1Click) end)
                                        pcall(function() firesignal(guiItem.Activated) end)
                                    end
                                end
                            end
                        end
                    end

                    local function scanRewardRemotes(folder)
                        for _, item in ipairs(folder:GetChildren()) do
                            if not Flags.AutoClaim then break end
                            if item:IsA("RemoteEvent") then
                                local name = item.Name:lower()
                                if name:find("reward") or name:find("daily") or name:find("gift") or name:find("free") or name:find("spin") or name:find("wheel") or name:find("chest") or name:find("box") or name:find("playtime") or name:find("online") or name:find("claim") then
                                    item:FireServer()
                                end
                            elseif item:IsA("Folder") or item:IsA("Configuration") or item:IsA("Model") then
                                scanRewardRemotes(item)
                            end
                        end
                    end

                    if ReplicatedStorage then
                        scanRewardRemotes(ReplicatedStorage)
                    end
                end)
            end
        end
    end)

    -- 4. Infinite Jump
    AddToggle("Infinite Jump", false, function(v)
        Flags.InfJump = v
    end)

    UserInputService.JumpRequest:Connect(function()
        if Flags.InfJump then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)

    -- 5. Fly Mode 🪽
    AddToggle("Fly 🪽 Mode", false, function(v)
        Flags.Fly = v
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local hrp = char.HumanoidRootPart

            if Flags.Fly then
                local bg = Instance.new("BodyGyro")
                bg.Name = "JunejoFlyGyro"
                bg.P = 9e4
                bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.cframe = hrp.CFrame
                bg.Parent = hrp

                local bv = Instance.new("BodyVelocity")
                bv.Name = "JunejoFlyVelocity"
                bv.velocity = Vector3.new(0, 0.1, 0)
                bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Parent = hrp

                task.spawn(function()
                    local camera = Workspace.CurrentCamera
                    while Flags.Fly and char:FindFirstChild("HumanoidRootPart") do
                        task.wait()
                        local vel = Vector3.new(0, 0, 0)
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            vel = vel + camera.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            vel = vel - camera.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            vel = vel - camera.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            vel = vel + camera.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            vel = vel + Vector3.new(0, 1, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            vel = vel - Vector3.new(0, 1, 0)
                        end

                        bv.velocity = vel * Flags.FlySpeed
                        bg.cframe = camera.CFrame
                    end
                    if bg then bg:Destroy() end
                    if bv then bv:Destroy() end
                end)
            else
                if hrp:FindFirstChild("JunejoFlyGyro") then hrp.JunejoFlyGyro:Destroy() end
                if hrp:FindFirstChild("JunejoFlyVelocity") then hrp.JunejoFlyVelocity:Destroy() end
            end
        end)
    end)
end

----------------------------------------------------
-- DIRECT LAUNCH (KEY SYSTEM DISABLED)
----------------------------------------------------
LaunchMainHub()
