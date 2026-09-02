--[[
    JUNEJO ULTRA SCRIPT HUB - PULL AN EGG
    Target Game: Pull An Egg (Roblox)
    Game Link: https://www.roblox.com/games/70640255604878/Pull-An-Egg
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11) - Flat & Borderless Standard
    Status: Standalone Executable (Enhanced Multi-Engine Rebirth & Optimized Features)
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Safe UI Parent Resolver
local function GetUIContainer()
    local container = nil
    pcall(function()
        if gethui then container = gethui() end
    end)
    if not container then
        pcall(function()
            if syn and syn.protect_gui then container = CoreGui end
        end)
    end
    return container or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
end

local UIContainer = GetUIContainer()

-- Cleanup previous UI instances of this game
pcall(function()
    for _, name in ipairs({"JunejoHubUI_PullAnEgg", "JunejoPullAnEggUI"}) do
        if CoreGui and CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
        if gethui and gethui():FindFirstChild(name) then gethui()[name]:Destroy() end
    end
end)

--------------------------------------------------------------------
-- CONFIGURATION & STATE
--------------------------------------------------------------------
local Toggles = {
    RareEggESP = false,
    AutoPullEggs = false,
    AutoRebirth = false,
    CollectCash = false,
    NoClip = false,
    WalkSpeedBoost = false,
    Fly = false
}

local CustomSpeedValue = 50

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
-- NOCLIP SYSTEM
--------------------------------------------------------------------
RunService.Stepped:Connect(function()
    if Toggles.NoClip and LocalPlayer.Character then
        pcall(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

--------------------------------------------------------------------
-- WALKSPEED SYSTEM
--------------------------------------------------------------------
local function UpdateCharacterSpeed()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Toggles.WalkSpeedBoost and CustomSpeedValue or 16
        end
    end)
end

RunService.Stepped:Connect(function()
    if Toggles.WalkSpeedBoost and not Toggles.Fly and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= CustomSpeedValue then
            hum.WalkSpeed = CustomSpeedValue
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    UpdateCharacterSpeed()
end)

--------------------------------------------------------------------
-- FLY SYSTEM (PC & MOBILE TOUCH COMPATIBLE)
--------------------------------------------------------------------
local flyBg, flyBv, flyConn

local function StopFly()
    pcall(function()
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if flyBg then flyBg:Destroy() flyBg = nil end
        if flyBv then flyBv:Destroy() flyBv = nil end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end)
end

local function StartFly()
    StopFly()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        hum.PlatformStand = true

        flyBg = Instance.new("BodyGyro")
        flyBg.P = 9e4
        flyBg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBg.CFrame = hrp.CFrame
        flyBg.Parent = hrp

        flyBv = Instance.new("BodyVelocity")
        flyBv.Velocity = Vector3.new(0, 0, 0)
        flyBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBv.Parent = hrp

        flyConn = RunService.RenderStepped:Connect(function()
            if not Toggles.Fly or not hrp or not hrp.Parent or not hum or not hum.Parent then
                StopFly()
                return
            end
            hum.PlatformStand = true
            local camera = Workspace.CurrentCamera
            local vel = Vector3.new(0, 0, 0)

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0, 1, 0) end

            flyBv.Velocity = vel * CustomSpeedValue
            flyBg.CFrame = camera.CFrame
        end)
    end)
end

--------------------------------------------------------------------
-- AUTOMATION ENGINES
--------------------------------------------------------------------

-- 1. Auto Pull Eggs
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoPullEggs then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- 1. Proximity Prompts
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not Toggles.AutoPullEggs then break end
                        if obj:IsA("ProximityPrompt") then
                            local pName = obj.Parent and obj.Parent.Name:lower() or ""
                            if pName:find("egg") or pName:find("pull") or pName:find("grab") or pName:find("steal") or pName:find("take") then
                                if fireproximityprompt then
                                    fireproximityprompt(obj, 0)
                                    fireproximityprompt(obj)
                                end
                            end
                        end
                    end
                    -- 2. Touch Interest / Touch Pads
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not Toggles.AutoPullEggs then break end
                        if obj:IsA("TouchTransmitter") then
                            local parent = obj.Parent
                            if parent and parent:IsA("BasePart") then
                                local pName = parent.Name:lower()
                                if pName:find("egg") or pName:find("nest") or pName:find("pull") then
                                    if firetouchinterest then
                                        firetouchinterest(hrp, parent, 0)
                                        task.wait()
                                        firetouchinterest(hrp, parent, 1)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. ROBUST MULTI-ENGINE AUTO REBIRTH (FIXED & FULLY OPTIMIZED)
task.spawn(function()
    while true do
        task.wait(1.0)
        if Toggles.AutoRebirth then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                -- Method A: Scan ReplicatedStorage for ALL Rebirth Remotes (Events & Functions)
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoRebirth then break end
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
                        local n = string.lower(obj.Name)
                        if n:find("rebirth") or n:find("prestige") or n:find("ascend") or n:find("resetstats") or n:find("multiplierrestyle") then
                            if obj:IsA("RemoteEvent") then
                                obj:FireServer()
                                obj:FireServer(1)
                                obj:FireServer(true)
                                obj:FireServer("Rebirth")
                                obj:FireServer({})
                            elseif obj:IsA("RemoteFunction") then
                                task.spawn(function()
                                    pcall(function() obj:InvokeServer() end)
                                    pcall(function() obj:InvokeServer(1) end)
                                    pcall(function() obj:InvokeServer(true) end)
                                end)
                            end
                        end
                    end
                end

                -- Method B: Scan Workspace for Rebirth ProximityPrompts
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoRebirth then break end
                    if prompt:IsA("ProximityPrompt") then
                        local pName = (prompt.Name .. " " .. (prompt.Parent and prompt.Parent.Name or "")):lower()
                        if pName:find("rebirth") or pName:find("ascend") or pName:find("prestige") then
                            if fireproximityprompt then
                                fireproximityprompt(prompt, 0)
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end

                -- Method C: Scan Workspace for Rebirth Touch Pads
                if hrp then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not Toggles.AutoRebirth then break end
                        if obj:IsA("TouchTransmitter") then
                            local parent = obj.Parent
                            if parent and parent:IsA("BasePart") then
                                local pName = parent.Name:lower()
                                if pName:find("rebirth") or pName:find("ascend") or pName:find("prestige") then
                                    if firetouchinterest then
                                        firetouchinterest(hrp, parent, 0)
                                        task.wait()
                                        firetouchinterest(hrp, parent, 1)
                                    end
                                end
                            end
                        end
                    end
                end

                -- Method D: Scan PlayerGui for Rebirth Buttons & Trigger Click Signals
                if LocalPlayer:FindFirstChild("PlayerGui") then
                    for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                            local gName = (gui.Name .. " " .. (gui:IsA("TextButton") and gui.Text or "")):lower()
                            if gName:find("rebirth") or gName:find("ascend") or gName:find("prestige") or gName:find("confirm rebirth") then
                                pcall(function()
                                    if firesignal then
                                        firesignal(gui.MouseButton1Click)
                                        firesignal(gui.Activated)
                                        firesignal(gui.MouseButton1Down)
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

-- 3. Collect Cash (Passive & Drops)
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.CollectCash then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                -- Remotes
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local rName = remote.Name:lower()
                        if rName:find("cash") or rName:find("collect") or rName:find("claim") or rName:find("income") or rName:find("money") or rName:find("coin") then
                            remote:FireServer()
                            remote:FireServer(1)
                        end
                    end
                end

                -- Proximity Prompts
                if hrp then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            local pName = obj.Parent and obj.Parent.Name:lower() or ""
                            if pName:find("cash") or pName:find("money") or pName:find("claim") or pName:find("collect") or pName:find("coin") then
                                if fireproximityprompt then fireproximityprompt(obj) end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. Rare Egg ESP & Instant Teleport
local rareHighlights = {}
task.spawn(function()
    while true do
        task.wait(1.0)
        if Toggles.RareEggESP then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local targetRareEgg = nil
                local shortestDist = math.huge

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") or obj:IsA("BasePart") then
                        local name = obj.Name:lower()
                        if (name:find("rare") or name:find("legend") or name:find("mythic") or name:find("gold") or name:find("huge") or name:find("secret") or name:find("epic")) and name:find("egg") then
                            if not obj:FindFirstChild("JunejoRareESP") then
                                local hl = Instance.new("Highlight")
                                hl.Name = "JunejoRareESP"
                                hl.FillColor = Color3.fromRGB(255, 215, 0)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.3
                                hl.Parent = obj
                                table.insert(rareHighlights, hl)
                            end
                            if hrp then
                                local partPos = obj:IsA("BasePart") and obj.Position or (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart"))
                                if partPos then
                                    local pos = typeof(partPos) == "Vector3" and partPos or partPos.Position
                                    local dist = (hrp.Position - pos).Magnitude
                                    if dist < shortestDist and dist > 5 then
                                        shortestDist = dist
                                        targetRareEgg = pos
                                    end
                                end
                            end
                        end
                    end
                end

                if targetRareEgg and hrp then
                    hrp.CFrame = CFrame.new(targetRareEgg + Vector3.new(0, 3, 0))
                end
            end)
        else
            if #rareHighlights > 0 then
                for _, hl in ipairs(rareHighlights) do
                    if hl and hl.Parent then hl:Destroy() end
                end
                rareHighlights = {}
            end
        end
    end
end)

--------------------------------------------------------------------
-- MASTER JUNEJO EXECUTIVE UI
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_PullAnEgg"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = UIContainer
end

-- Main Frame (280px Width, 275px Height for 7 Rows)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 275)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -137)
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

-- Header
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
TitleLabel.Text = "PULL AN EGG"
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

-- Draggable Functionality (Mouse & Touch)
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
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

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Name = "HeaderLine"
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 0, 195)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper Function for Standard Flat Toggle Rows
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Name = text:gsub("%s+", "") .. "Row"
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

-- 1. Rare Egg ESP / TP
AddToggleRow("Rare Egg ESP", "RareEggESP")

-- 2. Auto Pull Eggs
AddToggleRow("Auto Pull Eggs", "AutoPullEggs")

-- 3. Auto Rebirth (Multi-Engine Fixed)
AddToggleRow("Auto Rebirth", "AutoRebirth")

-- 4. Collect Cash
AddToggleRow("Collect Cash", "CollectCash")

-- 5. NoClip
AddToggleRow("NoClip", "NoClip")

-- 6. WalkSpeed Row with Integrated Pill Controller (- / +)
local SpeedRow = Instance.new("Frame")
SpeedRow.Name = "WalkSpeedRow"
SpeedRow.Size = UDim2.new(1, 0, 0, 23)
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
    UpdateCharacterSpeed()
end)

local SpeedControlFrame = Instance.new("Frame")
SpeedControlFrame.Name = "SpeedControlFrame"
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
    UpdateCharacterSpeed()
end)

PlusBtn.MouseButton1Click:Connect(function()
    CustomSpeedValue = math.min(300, CustomSpeedValue + 15)
    SpeedDisplay.Text = tostring(CustomSpeedValue)
    UpdateCharacterSpeed()
end)

-- 7. Fly
AddToggleRow("Fly", "Fly", function(enabled)
    if enabled then StartFly() else StopFly() end
end)

-- Footer (Pinned at Bottom)
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
