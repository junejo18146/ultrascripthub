--[[
    JUNEJO ULTRA SCRIPT HUB - +1 SUPERHERO EVOLUTION
    Target Game: +1 Superhero Evolution (Roblox)
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11) - Flat & Borderless Standard
    Status: Direct Standalone Executable
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- Global Feature State Flags (Strictly Preserved)
_G.AutoPowerTrainActive = false
_G.AutoRebirthActive = false
_G.FlyActive = false
_G.FlySpeed = 60
_G.NoclipActive = false

-- Metamethod Remote Capture Storage
_G.CapturedPowerRemote = nil
_G.CapturedPowerArgs = nil
_G.CapturedRebirthRemote = nil
_G.CapturedRebirthArgs = nil

-- Prevent duplicate UI
pcall(function()
    if CoreGui:FindFirstChild("RobloxScriptUI_Badshah") then CoreGui.RobloxScriptUI_Badshah:Destroy() end
    if CoreGui:FindFirstChild("JunejoHubUI_Superhero") then CoreGui.JunejoHubUI_Superhero:Destroy() end
    if CoreGui:FindFirstChild("JunejoHubUI") then CoreGui.JunejoHubUI:Destroy() end
end)
pcall(function()
    if LocalPlayer:FindFirstChild("PlayerGui") then
        if LocalPlayer.PlayerGui:FindFirstChild("RobloxScriptUI_Badshah") then LocalPlayer.PlayerGui.RobloxScriptUI_Badshah:Destroy() end
        if LocalPlayer.PlayerGui:FindFirstChild("JunejoHubUI_Superhero") then LocalPlayer.PlayerGui.JunejoHubUI_Superhero:Destroy() end
        if LocalPlayer.PlayerGui:FindFirstChild("JunejoHubUI") then LocalPlayer.PlayerGui.JunejoHubUI:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_Superhero"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

-- Universal Safe Parenting
local function getParentUI()
    if gethui then
        local success, res = pcall(gethui)
        if success and res then return res end
    end
    local coreSuccess = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if coreSuccess and ScreenGui.Parent == CoreGui then
        return CoreGui
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

ScreenGui.Parent = getParentUI()

-- =================================================================
-- OFFICIAL JUNEJO FLAT & BORDERLESS UI STANDARD
-- =================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 225)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -112)
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
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "SUPERHERO EVOLUTION"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -28, 0, 4)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 160)
CloseButton.TextSize = 13
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header
CloseButton.MouseButton1Click:Connect(function()
    _G.AutoPowerTrainActive = false
    _G.AutoRebirthActive = false
    _G.FlyActive = false
    _G.NoclipActive = false
    ScreenGui:Destroy()
end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 0, 148)
ContentFrame.Position = UDim2.new(0, 12, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper function for Flat & Borderless Toggle Rows
local function AddToggleRow(text, getStatus, setStatus)
    local Row = Instance.new("Frame")
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
    CheckMark.BackgroundTransparency = getStatus() and 0 or 1
    CheckMark.BorderSizePixel = 0
    CheckMark.Parent = CheckBox
    
    local MarkCorner = Instance.new("UICorner")
    MarkCorner.CornerRadius = UDim.new(0, 2)
    MarkCorner.Parent = CheckMark
    
    RowBtn.MouseButton1Click:Connect(function()
        local newState = not getStatus()
        setStatus(newState)
        CheckMark.BackgroundTransparency = newState and 0 or 1
    end)
end

-- =================================================================
-- FEATURE ROWS CONFIGURATION (ALL FEATURES FROM SOURCE)
-- =================================================================

-- 1. Auto Power Train Toggle
AddToggleRow("Auto Power Train", function() return _G.AutoPowerTrainActive end, function(val)
    _G.AutoPowerTrainActive = val
    print("[Superhero Evolution] Auto Power Train set to:", val)
end)

-- 2. Auto Rebirth Toggle
AddToggleRow("Auto Rebirth", function() return _G.AutoRebirthActive end, function(val)
    _G.AutoRebirthActive = val
    print("[Superhero Evolution] Auto Rebirth set to:", val)
end)

-- 3. Fly Mode Toggle
AddToggleRow("Fly Mode", function() return _G.FlyActive end, function(val)
    _G.FlyActive = val
    print("[Superhero Evolution] Fly Mode set to:", val)
end)

-- 4. Integrated Fly Speed Row (- / + Pill Controller)
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, 0, 0, 23)
SpeedRow.BackgroundTransparency = 1
SpeedRow.Parent = ContentFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.55, 0, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Fly Speed"
SpeedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedRow

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
SpeedDisplay.Text = tostring(_G.FlySpeed)
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
    _G.FlySpeed = math.max(20, (_G.FlySpeed or 60) - 10)
    SpeedDisplay.Text = tostring(_G.FlySpeed)
end)

PlusBtn.MouseButton1Click:Connect(function()
    _G.FlySpeed = math.min(250, (_G.FlySpeed or 60) + 10)
    SpeedDisplay.Text = tostring(_G.FlySpeed)
end)

-- 5. Noclip Toggle
AddToggleRow("Noclip", function() return _G.NoclipActive end, function(val)
    _G.NoclipActive = val
    print("[Superhero Evolution] Noclip set to:", val)
end)

-- Footer (Pinned at bottom)
local Footer = Instance.new("Frame")
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

-- Smooth Dragging Mechanism
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

-- =================================================================
-- STARTUP NOTIFICATIONS & ANTI-AFK PROTECTION (PRESERVED)
-- =================================================================
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end)
end)

-- =================================================================
-- METAMETHOD REMOTE SNIFFER (EXACT PRESERVED LOGIC)
-- =================================================================
pcall(function()
    local gmt = getrawmetatable(game)
    if gmt and setreadonly then
        setreadonly(gmt, false)
        local oldNamecall = gmt.__namecall
        gmt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if method == "FireServer" or method == "InvokeServer" then
                local remoteName = string.lower(self.Name)
                if string.find(remoteName, "power") or string.find(remoteName, "train") or string.find(remoteName, "click") or string.find(remoteName, "strength") or string.find(remoteName, "energy") or string.find(remoteName, "punch") then
                    _G.CapturedPowerRemote = self
                    _G.CapturedPowerArgs = args
                elseif string.find(remoteName, "rebirth") or string.find(remoteName, "prestige") or string.find(remoteName, "ascend") then
                    _G.CapturedRebirthRemote = self
                    _G.CapturedRebirthArgs = args
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(gmt, true)
    end
end)

-- =================================================================
-- 1. FLY SYSTEM (MOBILE JOYSTICK & PC KEYBOARD COMPATIBLE)
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.03)
        if _G.FlyActive then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local camera = workspace.CurrentCamera
                
                if hrp and hum and camera then
                    local bv = hrp:FindFirstChild("HeroFlyBV") or Instance.new("BodyVelocity")
                    bv.Name = "HeroFlyBV"
                    bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                    bv.Parent = hrp
                    
                    local bg = hrp:FindFirstChild("HeroFlyBG") or Instance.new("BodyGyro")
                    bg.Name = "HeroFlyBG"
                    bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
                    bg.P = 10000
                    bg.Parent = hrp
                    
                    hum.PlatformStand = true
                    bg.CFrame = camera.CFrame
                    
                    local speed = _G.FlySpeed or 60
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        local flyVel = camera.CFrame.LookVector * speed
                        if math.abs(moveDir.Z) < 0.2 and math.abs(moveDir.X) > 0.5 then
                            flyVel = camera.CFrame.RightVector * speed * (moveDir.X > 0 and 1 or -1)
                        end
                        bv.Velocity = flyVel
                    else
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        else
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.PlatformStand = false
                end
                if hrp then
                    local bv = hrp:FindFirstChild("HeroFlyBV")
                    if bv then bv:Destroy() end
                    local bg = hrp:FindFirstChild("HeroFlyBG")
                    if bg then bg:Destroy() end
                end
            end)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    if not _G.FlyActive then
        local hrp = newChar:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("HeroFlyBV")
            if bv then bv:Destroy() end
            local bg = hrp:FindFirstChild("HeroFlyBG")
            if bg then bg:Destroy() end
        end
    end
end)

-- =================================================================
-- 2. AUTO POWER TRAIN ENGINE (+1 POWER GENERATOR & CLICKER)
-- =================================================================
local powerKeywords = {
    "power", "train", "addpower", "gainpower", "givepower", "click", "punch", "strength", "energy", "tap", "farm"
}

task.spawn(function()
    while true do
        task.wait(0.03)
        if _G.AutoPowerTrainActive then
            pcall(function()
                -- A. Fire Sniffed Captured Remote
                if _G.CapturedPowerRemote then
                    pcall(function()
                        if _G.CapturedPowerRemote:IsA("RemoteEvent") then
                            _G.CapturedPowerRemote:FireServer(unpack(_G.CapturedPowerArgs or {}))
                        elseif _G.CapturedPowerRemote:IsA("RemoteFunction") then
                            _G.CapturedPowerRemote:InvokeServer(unpack(_G.CapturedPowerArgs or {}))
                        end
                    end)
                end

                -- B. Deep Scan ReplicatedStorage Remotes
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local n = string.lower(obj.Name)
                        for _, kw in ipairs(powerKeywords) do
                            if string.find(n, kw) then
                                pcall(function()
                                    if obj:IsA("RemoteEvent") then
                                        obj:FireServer()
                                        obj:FireServer(1)
                                        obj:FireServer(true)
                                    elseif obj:IsA("RemoteFunction") then
                                        task.spawn(function()
                                            pcall(function()
                                                obj:InvokeServer()
                                                obj:InvokeServer(1)
                                            end)
                                        end)
                                    end
                                end)
                                break
                            end
                        end
                    end
                end

                -- C. Auto Equip and Activate Tools
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if LocalPlayer:FindFirstChild("Backpack") and hum then
                    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            hum:EquipTool(tool)
                            break
                        end
                    end
                end
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            tool:Activate()
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 3. NOCLIP ENGINE
-- =================================================================
RunService.Stepped:Connect(function()
    if _G.NoclipActive then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- =================================================================
-- 4. AUTO REBIRTH ENGINE
-- =================================================================
local rebirthKeywords = {
    "rebirth", "dorebirth", "buyrebirth", "prestige", "ascend", "rebirthremote", "rebirthevent", "rebirthfunction"
}

task.spawn(function()
    while true do
        task.wait(0.4)
        if _G.AutoRebirthActive then
            pcall(function()
                -- Fire Captured Rebirth Remote
                if _G.CapturedRebirthRemote then
                    pcall(function()
                        if _G.CapturedRebirthRemote:IsA("RemoteEvent") then
                            _G.CapturedRebirthRemote:FireServer(unpack(_G.CapturedRebirthArgs or {}))
                        elseif _G.CapturedRebirthRemote:IsA("RemoteFunction") then
                            _G.CapturedRebirthRemote:InvokeServer(unpack(_G.CapturedRebirthArgs or {}))
                        end
                    end)
                end

                -- Scan ReplicatedStorage for Rebirth Remotes
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local n = string.lower(obj.Name)
                        for _, kw in ipairs(rebirthKeywords) do
                            if string.find(n, kw) then
                                pcall(function()
                                    if obj:IsA("RemoteEvent") then
                                        obj:FireServer()
                                        obj:FireServer(1)
                                        obj:FireServer(true)
                                    elseif obj:IsA("RemoteFunction") then
                                        task.spawn(function()
                                            pcall(function()
                                                obj:InvokeServer()
                                                obj:InvokeServer(1)
                                            end)
                                        end)
                                    end
                                end)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)
