--[[
    JUNEJO ULTRA SCRIPT HUB - STEAL AN EGG
    Target Game: Steal An Egg (Roblox)
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11) - Flat Borderless Rows & Slider Standard
    Features Included:
        1. Auto Steal Eggs (Instant ProximityPrompt & Remote Fire)
        2. Auto Teleport to Base (Instant Return to Base on Steal)
        3. Set Base Position (Saves Current Location as Base)
        4. Auto Hatch Eggs (Instant Egg Hatch & Open Remotes)
        5. WalkSpeed Boost + Interactive Speed Slider (16 - 150 Speed)
        6. Anti-AFK Engine (Auto 20-minute Idle Disconnect Protection)
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

-- Variables & State
local Toggles = {
    AutoSteal = false,
    AutoTeleportBase = false,
    AutoHatch = false,
    WalkSpeed = false
}

local SpeedValue = 50
local SavedBaseCFrame = nil

-- Initialize Base CFrame
pcall(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        SavedBaseCFrame = hrp.CFrame
    end
end)

-- Safe UI Parent resolver (Delta Mobile, Arceus X, Fluxus, Codex, PC)
local function GetSafeUIContainer()
    local container = nil
    
    pcall(function()
        if gethui then
            container = gethui()
        end
    end)
    
    if not container then
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
            if playerGui then
                container = playerGui
            end
        end)
    end
    
    if not container then
        pcall(function()
            if syn and syn.protect_gui then
                container = CoreGui
            end
        end)
    end
    
    if not container then
        pcall(function()
            container = CoreGui
        end)
    end
    
    return container or LocalPlayer:WaitForChild("PlayerGui")
end

local UIContainer = GetSafeUIContainer()

-- Cleanup previous UI instances safely
pcall(function()
    local names = {"JunejoStealAnEggUI", "StealAnEggUI", "JunejoHubUI"}
    for _, name in ipairs(names) do
        pcall(function()
            if CoreGui and CoreGui:FindFirstChild(name) then
                CoreGui[name]:Destroy()
            end
        end)
        pcall(function()
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
                LocalPlayer.PlayerGui[name]:Destroy()
            end
        end)
        pcall(function()
            if gethui and gethui():FindFirstChild(name) then
                gethui()[name]:Destroy()
            end
        end)
    end
end)

--------------------------------------------------------------------
-- GUI CREATION (JUNEJO ULTRA SCRIPT HUB - EXACT COMPACT SPEC)
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoStealAnEggUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true

-- Main Container Frame (Fixed Compact Standard 280px, Height: 270px)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 270)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Corner & Border Stroke
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Header Frame (Height: 34px)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundTransparency = 1
Header.Active = true
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "STEAL AN EGG"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
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

-- Draggable implementation attached to Header
local dragging = false
local dragInput, dragStart, startPos

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

-- Content Frame (Height: 188px)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -28, 0, 188)
ContentFrame.Position = UDim2.new(0, 14, 0, 36)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper function to generate clean, borderless toggle rows
local function AddToggleRow(text, configKey, onToggleCallback)
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
        if onToggleCallback then
            pcall(function()
                onToggleCallback(Toggles[configKey])
            end)
        end
    end)
end

-- Helper function to generate sleek Action Buttons
local function AddActionButton(text, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 24)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = Row
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Btn
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(45, 45, 55)
    Stroke.Thickness = 1.2
    Stroke.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

-- Helper function to generate sleek WalkSpeed Slider Row
local function AddSliderRow(title, min, max, defaultVal, onValueChanged)
    local SliderCard = Instance.new("Frame")
    SliderCard.Size = UDim2.new(1, 0, 0, 36)
    SliderCard.BackgroundTransparency = 1
    SliderCard.Parent = ContentFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 0, 16)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderCard

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0.35, 0, 0, 16)
    ValLabel.Position = UDim2.new(0.65, 0, 0, 0)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = tostring(defaultVal)
    ValLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValLabel.TextSize = 12
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    Label.Parent = SliderCard

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 6)
    Track.Position = UDim2.new(0, 0, 0, 22)
    Track.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Track.BorderSizePixel = 0
    Track.Parent = SliderCard

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local TrackStroke = Instance.new("UIStroke")
    TrackStroke.Color = Color3.fromRGB(45, 45, 55)
    TrackStroke.Thickness = 1
    TrackStroke.Parent = Track

    local initialRatio = math.clamp((defaultVal - min) / (max - min), 0, 1)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(initialRatio, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local Handle = Instance.new("Frame")
    Handle.Size = UDim2.new(0, 12, 0, 12)
    Handle.Position = UDim2.new(initialRatio, -6, 0.5, -6)
    Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Handle.BorderSizePixel = 0
    Handle.Parent = Track

    local HandleCorner = Instance.new("UICorner")
    HandleCorner.CornerRadius = UDim.new(1, 0)
    HandleCorner.Parent = Handle

    local sliding = false

    local function updateSlider(inputX)
        local trackPos = Track.AbsolutePosition.X
        local trackWidth = Track.AbsoluteSize.X
        if trackWidth <= 0 then return end
        local ratio = math.clamp((inputX - trackPos) / trackWidth, 0, 1)
        local value = math.floor(min + ((max - min) * ratio))
        
        ValLabel.Text = tostring(value)
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        Handle.Position = UDim2.new(ratio, -6, 0.5, -6)
        
        if onValueChanged then
            pcall(function()
                onValueChanged(value)
            end)
        end
    end

    SliderCard.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

-- 1. Auto Steal Toggle
AddToggleRow("Auto Steal (Instant)", "AutoSteal")

-- 2. Auto Teleport to Base Toggle
AddToggleRow("Auto Teleport to Base", "AutoTeleportBase")

-- 3. Set Base Position Action Button
AddActionButton("Set Current Base Position", function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            StarterGui:SetCore("SendNotification", {
                Title = "BASE POSITION SAVED",
                Text = "Base coordinates successfully updated!",
                Duration = 2.5
            })
        end
    end)
end)

-- 4. Auto Hatch Eggs Toggle
AddToggleRow("Auto Hatch Eggs", "AutoHatch")

-- 5. Fast WalkSpeed Boost Toggle + Slider
AddToggleRow("Fast WalkSpeed Boost", "WalkSpeed", function(enabled)
    pcall(function()
        if not enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end)
end)

AddSliderRow("WalkSpeed Multiplier", 16, 150, 50, function(val)
    SpeedValue = val
end)

-- Footer Frame (Pinned at bottom, Height: 44px)
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

-- Safely Mount ScreenGui
local mounted = false
pcall(function()
    ScreenGui.Parent = UIContainer
    mounted = true
end)

if not mounted or not ScreenGui.Parent then
    pcall(function()
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        mounted = true
    end)
end

-- Success Notification Pop-up
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "ULTRA SCRIPT HUB",
        Text = "Steal An Egg Loaded!",
        Duration = 3
    })
end)

--------------------------------------------------------------------
-- ANTI-AFK SYSTEM (Prevents 20-minute idle disconnect)
--------------------------------------------------------------------
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

--------------------------------------------------------------------
-- FAST WALKSPEED LOOP (Clean Vector Velocity Engine)
--------------------------------------------------------------------
RunService.Stepped:Connect(function()
    if Toggles.WalkSpeed then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                char.Humanoid.WalkSpeed = SpeedValue
                if char.Humanoid.MoveDirection.Magnitude > 0 then
                    char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(
                        char.Humanoid.MoveDirection.X * SpeedValue,
                        char.HumanoidRootPart.AssemblyLinearVelocity.Y,
                        char.Humanoid.MoveDirection.Z * SpeedValue
                    )
                end
            end
        end)
    end
end)

--------------------------------------------------------------------
-- 1. AUTO STEAL & TELEPORT BASE LOOP
--------------------------------------------------------------------
local function FirePromptSafely(prompt)
    pcall(function()
        prompt.HoldDuration = 0
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait(0.01)
            prompt:InputHoldEnd()
        end
    end)
end

task.spawn(function()
    while task.wait(0.05) do
        if Toggles.AutoSteal then
            pcall(function()
                for _, prompt in pairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoSteal then break end
                    if prompt:IsA("ProximityPrompt") then
                        local objText = prompt.ObjectText:lower()
                        local actText = prompt.ActionText:lower()
                        if objText:find("egg") or actText:find("steal") or actText:find("take") or actText:find("grab") then
                            FirePromptSafely(prompt)
                            
                            if Toggles.AutoTeleportBase and SavedBaseCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                task.wait(0.08)
                                LocalPlayer.Character.HumanoidRootPart.CFrame = SavedBaseCFrame
                            end
                        end
                    end
                end
                
                -- Remote Events Sweep
                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoSteal then break end
                    if v:IsA("RemoteEvent") then
                        local vName = v.Name:lower()
                        if vName:find("steal") or vName:find("takeegg") or vName:find("grabegg") then
                            v:FireServer()
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 2. AUTO HATCH EGGS LOOP
--------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.25) do
        if Toggles.AutoHatch then
            pcall(function()
                for _, prompt in pairs(Workspace:GetDescendants()) do
                    if not Toggles.AutoHatch then break end
                    if prompt:IsA("ProximityPrompt") then
                        local actText = prompt.ActionText:lower()
                        local objText = prompt.ObjectText:lower()
                        if actText:find("hatch") or actText:find("place") or actText:find("open") or objText:find("hatch") then
                            FirePromptSafely(prompt)
                        end
                    end
                end
                
                -- Remote Events Sweep
                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoHatch then break end
                    if v:IsA("RemoteEvent") then
                        local vName = v.Name:lower()
                        if vName:find("hatch") or vName:find("placeegg") or vName:find("openegg") then
                            v:FireServer()
                        end
                    end
                end
            end)
        end
    end
end)
