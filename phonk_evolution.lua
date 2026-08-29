--[[
    JUNEJO ULTRA SCRIPT HUB - +1 PHONK EVOLUTION
    Target Game: +1 Phonk Evolution (Roblox)
    Game Link: https://www.roblox.com/games/104809044319701/1-Phonk-Evolution
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11) - Flat Borderless Rows Standard
    Status: Dedicated Direct Executable (7 Core Verified Features - V3 Smart Wins)
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = nil
pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

-- 7 Core Verified Feature Toggles
local Toggles = {
    AutoPower = false,
    AutoRebirth = false,
    InfiniteWins = false,
    AutoHatchEggs = false,
    Fly = false,
    WalkSpeed = false,
    InfiniteJump = false
}

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
    local names = {"JunejoPhonkEvolutionUI", "JunejoPhonkUI", "JunejoHubUI"}
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
-- SAFE GUI BUTTON CLICKER (SAFE FROM UI INTERCEPTION)
--------------------------------------------------------------------
local function ClickGuiButton(btn)
    if not btn then return end
    pcall(function()
        if firesignal then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.MouseButton1Down)
            firesignal(btn.MouseButton1Up)
            firesignal(btn.Activated)
        end
    end)
    pcall(function()
        if getconnections then
            for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                conn:Fire()
            end
            for _, conn in pairs(getconnections(btn.MouseButton1Down)) do
                conn:Fire()
            end
            for _, conn in pairs(getconnections(btn.Activated)) do
                conn:Fire()
            end
        end
    end)
end

--------------------------------------------------------------------
-- GUI CREATION (JUNEJO ULTRA SCRIPT HUB - EXACT 7-ROW COMPACT SPEC)
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoPhonkEvolutionUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true

-- Main Container Frame (Fixed Compact Standard 280px, Height: 275px for 7 rows)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 275)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -138)
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
TitleLabel.Text = "+1 PHONK EVOLUTION"
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

-- Draggable implementation attached to Header (Prevents click-swallowing on Mobile)
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

-- Content Frame (Height: 192px for 7 rows with 4px gap)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -28, 0, 192)
ContentFrame.Position = UDim2.new(0, 14, 0, 36)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Forward function declarations
local StartFlying, StopFlying, UpdateCharacterSpeed

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

-- Generate 7 Requested Toggle Rows
AddToggleRow("Auto Power (+1)", "AutoPower")
AddToggleRow("Auto Rebirth / Evolve", "AutoRebirth")
AddToggleRow("Infinite Wins", "InfiniteWins")
AddToggleRow("Auto Hatch Eggs", "AutoHatchEggs")
AddToggleRow("Fly Mode", "Fly", function(enabled)
    if enabled then
        StartFlying()
    else
        StopFlying()
    end
end)
AddToggleRow("WalkSpeed Boost (50)", "WalkSpeed", function(enabled)
    UpdateCharacterSpeed()
end)
AddToggleRow("Infinite Jump", "InfiniteJump")

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
        Text = "+1 Phonk Evolution Ready!",
        Duration = 4
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
-- 1. INFINITE JUMP ENGINE
--------------------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        pcall(function()
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and Toggles.InfiniteJump and input.KeyCode == Enum.KeyCode.Space then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
            end
        end)
    end
end)

--------------------------------------------------------------------
-- 2. WALKSPEED BOOST ENGINE (50 Speed)
--------------------------------------------------------------------
UpdateCharacterSpeed = function()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Toggles.WalkSpeed then
                hum.WalkSpeed = 50
            else
                hum.WalkSpeed = 16
            end
        end
    end)
end

local function BindSpeedListener(char)
    if not char then return end
    task.spawn(function()
        local hum = char:WaitForChild("Humanoid", 3)
        if hum then
            hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if Toggles.WalkSpeed and hum.WalkSpeed ~= 50 then
                    hum.WalkSpeed = 50
                end
            end)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    BindSpeedListener(newChar)
    if Toggles.WalkSpeed then
        UpdateCharacterSpeed()
    end
end)

if LocalPlayer.Character then
    BindSpeedListener(LocalPlayer.Character)
end

--------------------------------------------------------------------
-- 3. FLY MODE ENGINE (WASD + Mobile Controls)
--------------------------------------------------------------------
local flying = false
local flyBV, flyBG
local flySpeed = 55

StartFlying = function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        
        StopFlying()
        flying = true
        hum.PlatformStand = true
        
        flyBG = Instance.new("BodyGyro")
        flyBG.P = 9e4
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.CFrame = hrp.CFrame
        flyBG.Parent = hrp
        
        flyBV = Instance.new("BodyVelocity")
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Parent = hrp
        
        task.spawn(function()
            while flying and Toggles.Fly and char.Parent do
                local cam = Workspace.CurrentCamera
                local moveDir = Vector3.new(0, 0, 0)
                
                -- Keyboard WASD / Space / Shift Controls
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDir = moveDir + (cam.CFrame.LookVector)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDir = moveDir - (cam.CFrame.LookVector)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDir = moveDir - (cam.CFrame.RightVector)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDir = moveDir + (cam.CFrame.RightVector)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDir = moveDir + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDir = moveDir - Vector3.new(0, 1, 0)
                end
                
                -- Mobile / Touch virtual thumbstick fallback
                if hum.MoveDirection.Magnitude > 0 and moveDir.Magnitude == 0 then
                    moveDir = cam.CFrame:VectorToWorldSpace(hum.MoveDirection)
                end
                
                if moveDir.Magnitude > 0 then
                    flyBV.Velocity = moveDir.Unit * flySpeed
                else
                    flyBV.Velocity = Vector3.new(0, 0, 0)
                end
                
                flyBG.CFrame = cam.CFrame
                RunService.RenderStepped:Wait()
            end
            StopFlying()
        end)
    end)
end

StopFlying = function()
    flying = false
    pcall(function()
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end)
end

--------------------------------------------------------------------
-- 4. BULLETPROOF AUTO POWER (+1) SCREEN TAP & CLICK ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.04)
        if Toggles.AutoPower then
            pcall(function()
                local cam = Workspace.CurrentCamera
                local vpX = (cam and cam.ViewportSize.X > 0) and (cam.ViewportSize.X / 2) or 500
                local vpY = (cam and cam.ViewportSize.Y > 0) and (cam.ViewportSize.Y / 2) or 400

                -- Layer 1: Hardware-level Screen Mouse Tap Simulation (VIM)
                if VirtualInputManager then
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(vpX, vpY, 0, true, game, 0)
                        VirtualInputManager:SendMouseButtonEvent(vpX, vpY, 0, false, game, 0)
                    end)
                    pcall(function()
                        VirtualInputManager:SendTouchEvent(1, 0, vpX, vpY)
                        VirtualInputManager:SendTouchEvent(1, 2, vpX, vpY)
                    end)
                end

                -- Layer 2: VirtualUser Native Click Simulation
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(vpX, vpY))
                end)
                pcall(function()
                    VirtualUser:Button1Down(Vector2.new(vpX, vpY), cam.CFrame)
                    task.wait(0.01)
                    VirtualUser:Button1Up(Vector2.new(vpX, vpY), cam.CFrame)
                end)

                -- Layer 3: Tool Auto-Equip & Activate
                local char = LocalPlayer.Character
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack and char then
                    local equippedTool = char:FindFirstChildOfClass("Tool")
                    if not equippedTool then
                        for _, item in ipairs(backpack:GetChildren()) do
                            if item:IsA("Tool") then
                                item.Parent = char
                                equippedTool = item
                                break
                            end
                        end
                    end
                    if equippedTool then
                        equippedTool:Activate()
                    end
                end

                -- Layer 4: ScreenGui Tap Buttons Clicker
                if LocalPlayer:FindFirstChild("PlayerGui") then
                    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.Name ~= "JunejoPhonkEvolutionUI" and gui.Enabled then
                            for _, btn in ipairs(gui:GetDescendants()) do
                                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                                    local bn = btn.Name:lower()
                                    local bt = (btn:IsA("TextButton") and btn.Text or ""):lower()
                                    if bn:find("tap") or bn:find("click") or bn:find("power") or bn:find("train") or
                                       bt:find("tap") or bt:find("click") or bt:find("power") or bt:find("+1") then
                                        ClickGuiButton(btn)
                                    end
                                end
                            end
                        end
                    end
                end

                -- Layer 5: Deep ReplicatedStorage Click / Tap / Power Remotes Sweeper
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoPower then break end
                    local n = obj.Name:lower()
                    if n:find("click") or n:find("tap") or n:find("power") or n:find("train") or 
                       n:find("phonk") or n:find("punch") or n:find("gain") or n:find("add") or 
                       n:find("give") or n:find("hit") or n:find("workout") then
                        if not (n:find("rebirth") or n:find("egg") or n:find("buy") or n:find("shop")) then
                            if obj:IsA("RemoteEvent") then
                                pcall(function() obj:FireServer() end)
                                pcall(function() obj:FireServer(1) end)
                                pcall(function() obj:FireServer(true) end)
                                pcall(function() obj:FireServer("Click") end)
                                pcall(function() obj:FireServer("Tap") end)
                                pcall(function() obj:FireServer("Train") end)
                                pcall(function() obj:FireServer("Power") end)
                            elseif obj:IsA("RemoteFunction") then
                                pcall(function() obj:InvokeServer() end)
                                pcall(function() obj:InvokeServer(1) end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 5. AUTO REBIRTH / EVOLVE MULTI-LAYER ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(1)
        if Toggles.AutoRebirth then
            pcall(function()
                -- Layer 1: PlayerGui UI Rebirth Button Scanner
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, gui in ipairs(playerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.Name ~= "JunejoPhonkEvolutionUI" and gui.Enabled then
                            for _, descendant in ipairs(gui:GetDescendants()) do
                                if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
                                    local name = descendant.Name:lower()
                                    local text = descendant:IsA("TextButton") and descendant.Text:lower() or ""
                                    if name:find("rebirth") or name:find("evolve") or name:find("evolution") or
                                       text:find("rebirth") or text:find("evolve") or text:find("evolution") or
                                       text:find("yes") or text:find("confirm") then
                                        ClickGuiButton(descendant)
                                    end
                                end
                            end
                        end
                    end
                end

                -- Layer 2: All ReplicatedStorage Rebirth & Evolution Remotes
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoRebirth then break end
                    local n = obj.Name:lower()
                    if n:find("rebirth") or n:find("evolve") or n:find("evolution") or 
                       n:find("prestige") or n:find("ascend") or n:find("transform") then
                        if obj:IsA("RemoteEvent") then
                            pcall(function() obj:FireServer() end)
                            pcall(function() obj:FireServer(1) end)
                            pcall(function() obj:FireServer(true) end)
                            pcall(function() obj:FireServer("Rebirth") end)
                            pcall(function() obj:FireServer("Evolve") end)
                        elseif obj:IsA("RemoteFunction") then
                            pcall(function() obj:InvokeServer() end)
                            pcall(function() obj:InvokeServer(1) end)
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------
-- 6. SMART INFINITE WINS ENGINE (Zero-Freeze & Level-Adaptive)
--------------------------------------------------------------------
-- Helper: Auto-Dismiss / Suppress Requirement Popups
local function AutoDismissErrorPopups()
    pcall(function()
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not pGui then return end
        for _, gui in ipairs(pGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "JunejoPhonkEvolutionUI" and gui.Enabled then
                for _, label in ipairs(gui:GetDescendants()) do
                    if label:IsA("TextLabel") then
                        local t = label.Text:lower()
                        if (t:find("level") or t:find("need") or t:find("require") or t:find("locked") or t:find("unlock")) and 
                           not (t:find("ultra script hub") or t:find("phonk")) then
                            -- Close or hide the notification frame
                            local parentFrame = label:FindFirstAncestorOfClass("Frame")
                            if parentFrame then
                                parentFrame.Visible = false
                            end
                            for _, btn in ipairs(gui:GetDescendants()) do
                                if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and (btn.Name:lower():find("close") or btn.Name:lower():find("ok") or btn.Name:lower():find("x")) then
                                    ClickGuiButton(btn)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local cachedWinGates = {}
local lastWinScan = 0

local function GetAdaptiveWinGates()
    if os.time() - lastWinScan > 3 or #cachedWinGates == 0 then
        cachedWinGates = {}
        pcall(function()
            local starterGates = {}
            local otherGates = {}

            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not (LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character)) then
                    local n = obj.Name:lower()
                    local pName = obj.Parent and obj.Parent.Name:lower() or ""
                    local isWinPart = false
                    local isStarter = false

                    -- Check BillboardGui / SurfaceGui text indicators
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
                            for _, txt in ipairs(child:GetDescendants()) do
                                if txt:IsA("TextLabel") then
                                    local t = txt.Text:lower()
                                    if t:find("win") or t:find("trophy") or t:find("finish") or t:find("escape") or t:find("gate") then
                                        isWinPart = true
                                        if t:find("1") or t:find("stage 1") or t:find("level 1") or t:find("starter") or t:find("easy") then
                                            isStarter = true
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    end

                    -- Check Part or Folder name indicators
                    if not isWinPart then
                        if n:find("win") or n:find("finish") or n:find("escape") or n:find("gate") or 
                           n:find("trophy") or n:find("stage") or n:find("goal") or n:find("end") or 
                           pName:find("win") or pName:find("finish") or pName:find("gates") or pName:find("escape") or pName:find("track") then
                            isWinPart = true
                            if n:find("1") or n:find("start") or pName:find("1") or pName:find("start") then
                                isStarter = true
                            end
                        end
                    end

                    if isWinPart and obj.Size.Magnitude > 0.5 then
                        if isStarter then
                            table.insert(starterGates, obj)
                        else
                            table.insert(otherGates, obj)
                        end
                    end
                end
            end

            -- Priority order: Starter / Stage 1 gates FIRST (guaranteed to give wins without level lock), then others
            for _, g in ipairs(starterGates) do
                table.insert(cachedWinGates, g)
            end
            for _, g in ipairs(otherGates) do
                table.insert(cachedWinGates, g)
            end
        end)
        lastWinScan = os.time()
    end
    return cachedWinGates
end

task.spawn(function()
    while true do
        task.wait(0.08)
        if Toggles.InfiniteWins then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                -- Dismiss any level popups immediately
                AutoDismissErrorPopups()

                -- Layer 1: Adaptive Virtual Touch (Focus on Stage 1 / Starter and current unlocked gates)
                local winGates = GetAdaptiveWinGates()
                if hrp and firetouchinterest and #winGates > 0 then
                    for i = 1, math.min(#winGates, 8) do
                        if not Toggles.InfiniteWins then break end
                        local gate = winGates[i]
                        pcall(function()
                            if gate and gate.Parent then
                                firetouchinterest(hrp, gate, 0)
                                task.wait(0.005)
                                firetouchinterest(hrp, gate, 1)
                            end
                        end)
                    end
                end

                -- Layer 2: Direct ReplicatedStorage Remote Events Sweeper for Wins & Stages
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.InfiniteWins then break end
                    local n = obj.Name:lower()
                    if (n:find("win") or n:find("givewin") or n:find("claimwin") or n:find("addwin") or 
                        n:find("stagewin") or n:find("finish") or n:find("escape") or n:find("racewin") or 
                        n:find("complete") or n:find("pass") or n:find("reward") or n:find("bosshit") or n:find("fight")) and
                        not (n:find("rebirth") or n:find("buy") or n:find("egg")) then
                        if obj:IsA("RemoteEvent") then
                            pcall(function() obj:FireServer() end)
                            pcall(function() obj:FireServer(1) end)
                            pcall(function() obj:FireServer("1") end)
                            pcall(function() obj:FireServer("Stage1") end)
                            pcall(function() obj:FireServer("Zone1") end)
                            pcall(function() obj:FireServer("Win") end)
                            pcall(function() obj:FireServer("Claim") end)
                            pcall(function() obj:FireServer("Finish") end)
                            pcall(function() obj:FireServer(LocalPlayer) end)
                        elseif obj:IsA("RemoteFunction") then
                            pcall(function() obj:InvokeServer() end)
                            pcall(function() obj:InvokeServer(1) end)
                            pcall(function() obj:InvokeServer("Win") end)
                        end
                    end
                end

                -- Layer 3: Direct Boss / Enemy Hit Trigger in Workspace
                for _, model in ipairs(Workspace:GetChildren()) do
                    if not Toggles.InfiniteWins then break end
                    if model:IsA("Model") and model ~= char then
                        local enemyHum = model:FindFirstChildOfClass("Humanoid")
                        local enemyHrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
                        if enemyHum and enemyHrp and enemyHum.Health > 0 then
                            local mName = model.Name:lower()
                            if mName:find("boss") or mName:find("enemy") or mName:find("dummy") or mName:find("target") or mName:find("phonk") or mName:find("fighter") then
                                pcall(function()
                                    if hrp and firetouchinterest then
                                        firetouchinterest(hrp, enemyHrp, 0)
                                        task.wait(0.005)
                                        firetouchinterest(hrp, enemyHrp, 1)
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

--------------------------------------------------------------------
-- 7. AUTO HATCH EGGS ENGINE
--------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.3)
        if Toggles.AutoHatchEggs then
            pcall(function()
                -- Layer 1: Fire Hatch & Egg Remotes in ReplicatedStorage
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if not Toggles.AutoHatchEggs then break end
                    local name = obj.Name:lower()
                    if name:find("hatch") or name:find("openegg") or name:find("buyegg") or 
                       name:find("egghatch") or name:find("petegg") or name:find("open") then
                        if obj:IsA("RemoteEvent") then
                            pcall(function() obj:FireServer("Egg1", 1) end)
                            pcall(function() obj:FireServer("Basic", 1) end)
                            pcall(function() obj:FireServer(1, 1) end)
                            pcall(function() obj:FireServer("Common", 1) end)
                            pcall(function() obj:FireServer("Single") end)
                            pcall(function() obj:FireServer() end)
                        elseif obj:IsA("RemoteFunction") then
                            pcall(function() obj:InvokeServer("Egg1", 1) end)
                            pcall(function() obj:InvokeServer("Basic", 1) end)
                            pcall(function() obj:InvokeServer(1, 1) end)
                            pcall(function() obj:InvokeServer() end)
                        end
                    end
                end
                
                -- Layer 2: Trigger ProximityPrompts for Eggs
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local promptName = (prompt.Name .. " " .. (prompt.ObjectText or "") .. " " .. (prompt.ActionText or "")):lower()
                        if promptName:find("egg") or promptName:find("hatch") or promptName:find("pet") or promptName:find("open") then
                            pcall(function()
                                if fireproximityprompt then
                                    fireproximityprompt(prompt)
                                end
                            end)
                        end
                    end
                end
            end)
        end
    end
end)
