--[[
    JUNEJO ULTRA SCRIPT HUB - +1 PHONK EVOLUTION
    Target Game: +1 Phonk Evolution (Roblox)
    Game Link: https://www.roblox.com/games/104809044319701/1-Phonk-Evolution
    Author: Made by Junejo (junejo18146)
    Repository: junejo18146/ultrascripthub
    Theme: Unified Junejo Executive Dark UI (#0F0F11) - Flat Borderless Rows Standard
    Status: Dedicated Direct Executable (5 Core Verified Features)
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

-- 5 Core Verified Feature Toggles
local Toggles = {
    AutoPower = false,
    AutoRebirth = false,
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
-- GUI CREATION (JUNEJO ULTRA SCRIPT HUB - EXACT 5-ROW COMPACT SPEC)
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoPhonkEvolutionUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true

-- Main Container Frame (Fixed Compact Standard 280px, Height: 220px for 5 rows)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 220)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -110)
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

-- Content Frame (Height: 136px for 5 rows with 4px gap)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -28, 0, 136)
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

-- Generate 5 Core Verified Toggle Rows
AddToggleRow("Auto Power (+1)", "AutoPower")
AddToggleRow("Auto Rebirth / Evolve", "AutoRebirth")
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
