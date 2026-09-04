-- ====================================================
-- JUNEJO ULTRA SCRIPT HUB - BREAK A BRAINROT EGG (OFFICIAL)
-- Game: Break a Brainrot Egg
-- Author: Made by Junejo (junejo18146)
-- GitHub: https://github.com/junejo18146/ultrascripthub
-- Universal Mobile (Delta / Codex / Fluxus) & PC Compatible
-- ====================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Clean all previous UI instances safely
for _, name in ipairs({"JunejoHubUI_BreakBrainrotEgg", "JunejoBreakBrainrotUI", "JunejoBreakEggHub"}) do
    pcall(function()
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end)
end

-- Global Configuration & State
local Toggles = {
    AutoBreakRare = false,
    RareEggESP = false,
    AutoBuyHammer = false,
    AutoRebirth = false,
    FlyMode = false,
    Noclip = false,
    InfiniteJump = false,
    WalkSpeedBoost = false,
    AntiAFK = true
}

local CustomSpeedValue = 100
local SavedBaseCFrame = nil
local CurrentRareEggESPInstances = {}
local CooldownEggs = {}

-- Safe Alive Check
local function isAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- Screen Notification Helper
local function ShowNotification(title, message)
    pcall(function()
        local sg = CoreGui:FindFirstChild("JunejoHubUI_BreakBrainrotEgg") or (LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("JunejoHubUI_BreakBrainrotEgg"))
        if not sg then return end

        local oldNotify = sg:FindFirstChild("JunejoToast")
        if oldNotify then oldNotify:Destroy() end

        local Toast = Instance.new("Frame")
        Toast.Name = "JunejoToast"
        Toast.Size = UDim2.new(0, 260, 0, 42)
        Toast.Position = UDim2.new(0.5, -130, 0.12, 0)
        Toast.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        Toast.BorderSizePixel = 0
        Toast.ZIndex = 999
        Toast.Parent = sg

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 8)
        ToastCorner.Parent = Toast

        local ToastStroke = Instance.new("UIStroke")
        ToastStroke.Color = Color3.fromRGB(60, 60, 80)
        ToastStroke.Thickness = 1.2
        ToastStroke.Parent = Toast

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -12, 0, 16)
        TitleLbl.Position = UDim2.new(0, 8, 0, 4)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
        TitleLbl.TextSize = 11
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.ZIndex = 1000
        TitleLbl.Parent = Toast

        local MsgLbl = Instance.new("TextLabel")
        MsgLbl.Size = UDim2.new(1, -12, 0, 16)
        MsgLbl.Position = UDim2.new(0, 8, 0, 20)
        MsgLbl.BackgroundTransparency = 1
        MsgLbl.Text = message
        MsgLbl.TextColor3 = Color3.fromRGB(230, 230, 240)
        MsgLbl.TextSize = 10
        MsgLbl.Font = Enum.Font.GothamMedium
        MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
        MsgLbl.ZIndex = 1000
        MsgLbl.Parent = Toast

        task.delay(3.5, function()
            if Toast and Toast.Parent then
                local tween = TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                tween:Play()
                TitleLbl.TextTransparency = 1
                MsgLbl.TextTransparency = 1
                ToastStroke.Transparency = 1
                task.wait(0.35)
                if Toast then Toast:Destroy() end
            end
        end)
    end)
end

-- Universal Instant ProximityPrompt Trigger
local function InstantTriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = math.huge
        prompt.RequiresLineOfSight = false
        prompt.Enabled = true

        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt, 1)
            fireproximityprompt(prompt)
        end
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
        end
    end)
end

-- Universal Touch Interest Trigger
local function InstantTouch(part, targetPart)
    if not part or not targetPart then return end
    pcall(function()
        if firetouchinterest then
            firetouchinterest(part, targetPart, 0)
            firetouchinterest(part, targetPart, 1)
            firetouchinterest(targetPart, part, 0)
            firetouchinterest(targetPart, part, 1)
        end
    end)
end

-- Tool Auto-Equip Helper (Equips Highest Tier Hammer / Damage Weapon)
local function EquipBestTool()
    pcall(function()
        if not isAlive() then return end
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return end

        local currentTool = char:FindFirstChildOfClass("Tool")
        if not currentTool then
            local hammerTool = nil
            -- Search backpack for hammers or weapons
            for _, t in ipairs(backpack:GetChildren()) do
                if t:IsA("Tool") then
                    local n = t.Name:lower()
                    if n:find("hammer") or n:find("axe") or n:find("mallet") or n:find("weapon") or n:find("pick") or n:find("sword") then
                        hammerTool = t
                    end
                end
            end
            if not hammerTool then
                hammerTool = backpack:FindFirstChildOfClass("Tool")
            end
            if hammerTool then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:EquipTool(hammerTool) end
            end
        end
    end)
end

-- Speed Update Helper
local function UpdateCharacterSpeed()
    pcall(function()
        if isAlive() then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if Toggles.WalkSpeedBoost then
                    hum.WalkSpeed = CustomSpeedValue
                else
                    hum.WalkSpeed = 16
                end
            end
        end
    end)
end

-- ====================================================
-- UNLOCKED RAREST EGG SCANNER & DISTANCE ENGINE
-- (RULE: ONLY UNLOCKED EGGS, MAXIMUM DISTANCE = RAREST)
-- ====================================================
local function GetLocationKey(pos)
    return math.floor(pos.X / 4) .. "_" .. math.floor(pos.Y / 4) .. "_" .. math.floor(pos.Z / 4)
end

local function IsBaseOrPlotItem(obj)
    if not obj then return false end
    local charModel = obj:FindFirstAncestorOfClass("Model")
    if charModel and Players:GetPlayerFromCharacter(charModel) then
        return true
    end
    local current = obj
    local depth = 0
    while current and depth < 7 do
        if current == Workspace or current == game then break end
        local n = current.Name:lower()
        if n:find("plot") or n:find("base") or n:find("incubator") or n:find("hatchery") or n:find("tycoon") or n:find("house") or n:find("myslot") or n:find("mybase") or n:find("deposit") or n:find("stand") then
            return true
        end
        current = current.Parent
        depth = depth + 1
    end
    return false
end

-- Comprehensive Lock Inspector (Filters out locked zones, locked eggs & paywalled eggs)
local function IsEggLocked(obj, prompt)
    -- 1. Check ProximityPrompt state & texts
    if prompt then
        if not prompt.Enabled then return true end
        local pt = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
        if pt:find("lock") or pt:find("requir") or pt:find("need") or pt:find("closed") or pt:find("cannot") or pt:find("reach") or pt:find("buy area") or pt:find("unlock zone") or pt:find("level req") or pt:find("rebirth req") then
            return true
        end
    end

    -- 2. Check Object & Ancestor Zone Lock Names/Attributes
    if obj and obj:IsA("Instance") then
        local current = obj
        local depth = 0
        while current and depth < 6 do
            if current == Workspace or current == game then break end
            local n = current.Name:lower()
            if n:find("locked") or n:find("barrier") or n:find("zone_lock") or n:find("closed") or n:find("blocked") or n:find("levelreq") or n:find("rebirthreq") or n:find("lockedzone") or n:find("lockedegg") then
                return true
            end

            -- Check Attributes for locked flags
            local attrLocked = false
            pcall(function()
                for attr, val in pairs(current:GetAttributes()) do
                    local an = tostring(attr):lower()
                    if (an:find("lock") and val == true) or (an:find("unlock") and val == false) or (an:find("avail") and val == false) or (an:find("open") and val == false) then
                        attrLocked = true
                        break
                    end
                end
            end)
            if attrLocked then return true end

            current = current.Parent
            depth = depth + 1
        end

        -- 3. Check for Lock TextLabels, ForceFields or Lock Overlays inside egg model
        local isTextLocked = false
        pcall(function()
            for _, desc in ipairs(obj:GetDescendants()) do
                if desc:IsA("TextLabel") or desc:IsA("TextBox") then
                    local txt = desc.Text:lower()
                    if txt:find("locked") or txt:find("requires") or txt:find("need rebirth") or txt:find("reach zone") or txt:find("level req") or txt:find("unlock at") then
                        isTextLocked = true
                        break
                    end
                elseif desc:IsA("ForceField") then
                    isTextLocked = true
                    break
                end
            end
        end)
        if isTextLocked then return true end
    end

    return false
end

local function GetEggDisplayName(obj, prompt, distFromBase)
    local detectedName = "Brainrot Egg"

    if prompt then
        if prompt.ObjectText and prompt.ObjectText ~= "" and #prompt.ObjectText > 1 then
            detectedName = prompt.ObjectText
        elseif prompt.ActionText and prompt.ActionText ~= "" and #prompt.ActionText > 2 and not prompt.ActionText:lower():find("hold") and not prompt.ActionText:lower():find("e to") then
            detectedName = prompt.ActionText
        end
    end

    if detectedName == "Brainrot Egg" and obj then
        if obj.Name and obj.Name ~= "" and obj.Name ~= "Part" and obj.Name ~= "MeshPart" and obj.Name ~= "Model" and obj.Name ~= "ProximityPrompt" and obj.Name ~= "Attachment" then
            detectedName = obj.Name
        elseif obj.Parent and obj.Parent ~= Workspace and obj.Parent.Name ~= "Map" and obj.Parent.Name ~= "Models" then
            detectedName = obj.Parent.Name
        end
    end

    return detectedName
end

-- UNLOCKED RAREST EGG FUNCTION: Scans ONLY UNLOCKED eggs and picks the FURTHEST from Base
local function FindRarestEgg(hrpPosition)
    local candidates = {}
    local now = os.clock()

    if not SavedBaseCFrame and isAlive() then
        SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
    local basePos = SavedBaseCFrame and SavedBaseCFrame.Position or hrpPosition

    -- 1. Gather all UNLOCKED candidates from ProximityPrompts across Workspace
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local pPart = prompt.Parent
            local targetPos = nil

            if pPart:IsA("BasePart") then
                targetPos = pPart.CFrame
            elseif pPart:IsA("Attachment") then
                targetPos = pPart.WorldCFrame
            elseif pPart:IsA("Model") and pPart.PrimaryPart then
                targetPos = pPart.PrimaryPart.CFrame
            elseif pPart:IsA("Model") then
                local bp = pPart:FindFirstChildWhichIsA("BasePart")
                if bp then targetPos = bp.CFrame end
            end

            if targetPos then
                local locKey = GetLocationKey(targetPos.Position)
                local isCoolingDown = CooldownEggs[locKey] and (now < CooldownEggs[locKey])
                local inBaseOrPlot = IsBaseOrPlotItem(pPart)
                local locked = IsEggLocked(pPart, prompt)

                -- Only consider active, UNLOCKED eggs outside Base
                if not isCoolingDown and not inBaseOrPlot and not locked then
                    local distFromBase = (targetPos.Position - basePos).Magnitude
                    if distFromBase > 18 then
                        local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. pPart.Name):lower()
                        local isEgg = act:find("break") or act:find("hit") or act:find("egg") or act:find("brainrot") or act:find("lucky") or act:find("steal") or act:find("grab") or act:find("pick") or act:find("collect") or act == "" or act == " "

                        if isEgg then
                            local eggName = GetEggDisplayName(pPart, prompt, distFromBase)
                            table.insert(candidates, {
                                targetCFrame = targetPos,
                                prompt = prompt,
                                part = pPart:IsA("BasePart") and pPart or pPart:FindFirstChildWhichIsA("BasePart"),
                                locKey = locKey,
                                eggName = eggName,
                                distFromBase = distFromBase
                            })
                        end
                    end
                end
            end
        end
    end

    -- 2. Gather UNLOCKED candidates from Workspace models/parts as fallback
    if #candidates == 0 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if (name:find("egg") or name:find("brainrot") or name:find("block") or name:find("lucky")) and not name:find("gui") and not name:find("ui") then
                local tCFrame = nil
                local targetPart = nil

                if obj:IsA("BasePart") then
                    tCFrame = obj.CFrame
                    targetPart = obj
                elseif obj:IsA("Model") and obj.PrimaryPart then
                    tCFrame = obj.PrimaryPart.CFrame
                    targetPart = obj.PrimaryPart
                elseif obj:IsA("Model") then
                    local p = obj:FindFirstChildWhichIsA("BasePart")
                    if p then
                        tCFrame = p.CFrame
                        targetPart = p
                    end
                end

                if tCFrame then
                    local locKey = GetLocationKey(tCFrame.Position)
                    local isCoolingDown = CooldownEggs[locKey] and (now < CooldownEggs[locKey])
                    local inBaseOrPlot = IsBaseOrPlotItem(obj)
                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    local locked = IsEggLocked(obj, prompt)

                    if not isCoolingDown and not inBaseOrPlot and not locked then
                        local distFromBase = (tCFrame.Position - basePos).Magnitude
                        if distFromBase > 18 then
                            local eggName = GetEggDisplayName(obj, prompt, distFromBase)
                            table.insert(candidates, {
                                targetCFrame = tCFrame,
                                prompt = prompt,
                                part = targetPart,
                                locKey = locKey,
                                eggName = eggName,
                                distFromBase = distFromBase
                            })
                        end
                    end
                end
            end
        end
    end

    if #candidates == 0 then
        return nil, nil, nil, nil, "No Unlocked Egg Found", 0
    end

    -- 3. STRICTLY SORT CANDIDATES BY MAXIMUM DISTANCE FROM BASE (FARTHEST UNLOCKED EGG FIRST)
    table.sort(candidates, function(a, b)
        return a.distFromBase > b.distFromBase
    end)

    local best = candidates[1]
    return best.targetCFrame, best.prompt, best.part, best.locKey, best.eggName, math.floor(best.distFromBase)
end

-- Break Rare Egg Attack Loop on Target
local function PerformEggBreakAttack(targetCFrame, prompt, eggPart)
    EquipBestTool()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
        if tool:FindFirstChild("Handle") and eggPart then
            InstantTouch(tool.Handle, eggPart)
        end
    end

    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(500, 500))

    if prompt then
        InstantTriggerPrompt(prompt)
    end
    if eggPart and char:FindFirstChild("HumanoidRootPart") then
        InstantTouch(char.HumanoidRootPart, eggPart)
    end

    -- Fire any damage / hit / attack Remotes
    pcall(function()
        for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
            local n = rem.Name:lower()
            if n:find("hit") or n:find("damage") or n:find("break") or n:find("attack") or n:find("smash") or n:find("click") or n:find("mine") then
                if rem:IsA("RemoteEvent") then
                    if eggPart then rem:FireServer(eggPart) end
                    rem:FireServer()
                elseif rem:IsA("RemoteFunction") then
                    if eggPart then rem:InvokeServer(eggPart) end
                end
            end
        end
    end)
end

-- 1-Click Action: Break Unlocked Rare Egg (Teleports & breaks furthest unlocked egg on the spot)
local function BreakRareEggAction()
    if not isAlive() then return end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetCFrame, prompt, eggPart, locKey, eggName, distFromBase = FindRarestEgg(hrp.Position)
    if targetCFrame then
        if locKey then CooldownEggs[locKey] = os.clock() + 3 end

        ShowNotification("💎 Breaking Unlocked Rare Egg", "👑 " .. eggName .. " (" .. tostring(distFromBase) .. " studs away)")
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = targetCFrame * CFrame.new(0, 2.5, 0)
        task.wait(0.15)

        for i = 1, 5 do
            PerformEggBreakAttack(targetCFrame, prompt, eggPart)
            task.wait(0.1)
        end

        ShowNotification("✓ Unlocked Rare Egg Hit!", "👑 Attacked " .. eggName .. " (" .. tostring(distFromBase) .. " studs from base)!")
    else
        ShowNotification("No Unlocked Egg Found", "Scanning map... No active unlocked eggs found.")
    end
end

-- 1-Click Action: Teleport to Unlocked Rare Egg (Teleports to furthest unlocked egg and stays there)
local function TeleportToRareEggAction()
    if not isAlive() then return end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetCFrame, prompt, eggPart, _, eggName, distFromBase = FindRarestEgg(hrp.Position)
    if targetCFrame then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = targetCFrame * CFrame.new(0, 3.2, 0)
        task.wait(0.15)
        if prompt then InstantTriggerPrompt(prompt) end
        if eggPart then InstantTouch(hrp, eggPart) end
        ShowNotification("⚡ Teleported to Unlocked Egg", "👑 " .. eggName .. " (Furthest: " .. tostring(distFromBase) .. " studs)")
    else
        ShowNotification("No Unlocked Egg Found", "Scanning map... No active unlocked eggs found.")
    end
end

-- ====================================================
-- OFFICIAL JUNEJO COMPACT SCROLLING UI (280x285px)
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JunejoHubUI_BreakBrainrotEgg"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local guiParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 285)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -142)
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

local function enableHeaderDrag(dragHandle, targetFrame)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
enableHeaderDrag(Header, MainFrame)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "BREAK A BRAINROT EGG"
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
CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Header Separation Line
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -24, 0, 1)
HeaderLine.Position = UDim2.new(0, 12, 0, 32)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Scrollable Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -16, 0, 205)
ContentFrame.Position = UDim2.new(0, 10, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 80)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 320)
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)
UIList.Parent = ContentFrame

-- Helper Function: Add Debounced Toggle Row
local function AddToggleRow(text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 24)
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
    
    local lastClick = 0
    RowBtn.MouseButton1Click:Connect(function()
        local now = os.clock()
        if now - lastClick < 0.12 then return end
        lastClick = now
        Toggles[configKey] = not Toggles[configKey]
        CheckMark.BackgroundTransparency = Toggles[configKey] and 0 or 1
        if callback then callback(Toggles[configKey]) end
    end)
end

-- Helper Function: Add Action Button Row
local function AddActionButton(text, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 24)
    Row.BackgroundTransparency = 1
    Row.Parent = ContentFrame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.Parent = Row
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Btn
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn
    
    local lastClick = 0
    Btn.MouseButton1Click:Connect(function()
        local now = os.clock()
        if now - lastClick < 0.25 then return end
        lastClick = now
        if callback then callback(Btn) end
    end)
end

-- ====================================================
-- REGISTER ALL REQUESTED TOGGLES & ACTIONS
-- ====================================================

-- 1. Break Unlocked Rare Egg (1-Click Instant Action)
AddActionButton("💎 Break Unlocked Rare Egg", function(btn)
    btn.Text = "⏳ Breaking Rare Egg..."
    btn.TextColor3 = Color3.fromRGB(255, 215, 0)
    BreakRareEggAction()
    task.delay(1.5, function()
        btn.Text = "💎 Break Unlocked Rare Egg"
        btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    end)
end)

-- 2. Teleport to Unlocked Rare Egg (1-Click Instant Action)
AddActionButton("⚡ Teleport to Unlocked Rare Egg", function(btn)
    btn.Text = "⏳ Teleporting..."
    btn.TextColor3 = Color3.fromRGB(220, 50, 255)
    TeleportToRareEggAction()
    task.delay(1.5, function()
        btn.Text = "⚡ Teleport to Unlocked Rare Egg"
        btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    end)
end)

-- 3. Auto Break Unlocked Rare Egg (Continuous Loop)
AddToggleRow("Auto Break Unlocked Rare Egg", "AutoBreakRare", function(state)
    if state and isAlive() then
        ShowNotification("Auto Break Unlocked Rare Egg", "Active: Seeking & breaking furthest unlocked eggs across zones!")
    end
end)

-- 4. Unlocked Rare Egg ESP (Neon Magenta Glowing Highlight + Distance Billboard)
AddToggleRow("Unlocked Rare Egg ESP", "RareEggESP", function(state)
    if not state then
        for _, inst in pairs(CurrentRareEggESPInstances) do
            pcall(function() inst:Destroy() end)
        end
        CurrentRareEggESPInstances = {}
    end
end)

-- 5. Auto Buy Best Hammer & Upgrades
AddToggleRow("Auto Buy Best Hammer", "AutoBuyHammer", function(state)
    if state then
        ShowNotification("Auto Buy Best Hammer", "Active: Purchasing best hammers & tool upgrades from shop!")
    end
end)

-- 6. Auto Rebirth (Automatic Prestige Engine)
AddToggleRow("Auto Rebirth", "AutoRebirth", function(state)
    if state then
        ShowNotification("Auto Rebirth", "Active: Automatically rebirthing for Cash & Power multiplier!")
    end
end)

-- 7. Action Button: Set Current Base Position
AddActionButton("📍 Set Current Base Position", function(btn)
    if isAlive() then
        SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        btn.Text = "✓ Base Location Saved!"
        btn.TextColor3 = Color3.fromRGB(80, 255, 120)
        task.delay(1.5, function()
            btn.Text = "📍 Set Current Base Position"
            btn.TextColor3 = Color3.fromRGB(240, 240, 240)
        end)
    end
end)

-- 8. Action Button: Teleport to Base
AddActionButton("⚡ Teleport to Base", function(btn)
    if isAlive() then
        if not SavedBaseCFrame then
            SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = SavedBaseCFrame * CFrame.new(0, 2, 0)
        btn.Text = "✓ Teleported to Base!"
        task.delay(1.2, function()
            btn.Text = "⚡ Teleport to Base"
        end)
    end
end)

-- 9. Fly Mode (Smooth 3D Flight)
AddToggleRow("Fly Mode (3D Flight)", "FlyMode", function(state) end)

-- 10. Noclip Mode
AddToggleRow("Noclip (Phase Walls)", "Noclip", function(state) end)

-- 11. Infinite Jump
AddToggleRow("Infinite Jump", "InfiniteJump", function(state) end)

-- 12. Integrated WalkSpeed Row with - / + Pill Adjuster
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, -6, 0, 24)
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

local SpeedMarkCorner = Instance.new("UICorner")
SpeedMarkCorner.CornerRadius = UDim.new(0, 2)
SpeedMarkCorner.Parent = SpeedCheckMark

local lastSpeedClick = 0
SpeedToggleBtn.MouseButton1Click:Connect(function()
    local now = os.clock()
    if now - lastSpeedClick < 0.15 then return end
    lastSpeedClick = now
    Toggles.WalkSpeedBoost = not Toggles.WalkSpeedBoost
    SpeedCheckMark.BackgroundTransparency = Toggles.WalkSpeedBoost and 0 or 1
    UpdateCharacterSpeed()
end)

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

-- Footer Frame
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

-- ====================================================
-- 1. CONTINUOUS AUTO BREAK UNLOCKED RARE EGG ENGINE
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoBreakRare and isAlive() then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                local targetCFrame, prompt, eggPart, locKey, eggName, distFromBase = FindRarestEgg(hrp.Position)

                if targetCFrame then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.CFrame = targetCFrame * CFrame.new(0, 2.2, 0)
                    task.wait(0.1)

                    -- Attack and Break Egg
                    PerformEggBreakAttack(targetCFrame, prompt, eggPart)

                    -- Trigger any nearby drops or prompts
                    for _, p in ipairs(Workspace:GetDescendants()) do
                        if p:IsA("ProximityPrompt") and p.Parent then
                            local pPos = p.Parent:IsA("BasePart") and p.Parent.Position or nil
                            if pPos and (pPos - hrp.Position).Magnitude < 30 then
                                InstantTriggerPrompt(p)
                            end
                        end
                    end
                    task.wait(0.15)
                else
                    task.wait(0.5)
                end
            end
        end
    end
end)

-- ====================================================
-- 2. COMPREHENSIVE AUTO BUY BEST HAMMER ENGINE
-- ====================================================
task.spawn(function()
    while true do
        task.wait(1.0)
        if Toggles.AutoBuyHammer and isAlive() then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            -- A. Fire Shop / Hammer Purchase Remotes in ReplicatedStorage
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    local n = rem.Name:lower()
                    if n:find("buy") or n:find("hammer") or n:find("tool") or n:find("weapon") or n:find("upgrade") or n:find("purchase") or n:find("craft") then
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer()
                            rem:FireServer("Best")
                            rem:FireServer("Hammer")
                            rem:FireServer(1)
                            rem:FireServer(true)
                            rem:FireServer("Tool")
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer()
                            rem:InvokeServer("Best")
                            rem:InvokeServer("Hammer")
                        end
                    end
                end
            end)

            -- B. Proximity Prompts on Hammer Stands in Workspace
            pcall(function()
                if hrp then
                    for _, prompt in ipairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Parent then
                            local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                            if act:find("hammer") or act:find("buy") or act:find("upgrade") or act:find("tool") or act:find("shop") or act:find("weapon") then
                                local pPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or nil
                                if pPos and (pPos - hrp.Position).Magnitude < 160 then
                                    InstantTriggerPrompt(prompt)
                                end
                            end
                        end
                    end
                end
            end)

            -- C. Touch Pads on Hammer Shop in Workspace
            pcall(function()
                if hrp then
                    for _, part in ipairs(Workspace:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local n = part.Name:lower()
                            if (n:find("hammerpad") or n:find("buypad") or n:find("upgradepad") or n:find("shop") or n:find("toolpad")) and (part.Position - hrp.Position).Magnitude < 120 then
                                InstantTouch(hrp, part)
                            end
                        end
                    end
                end
            end)

            -- D. PlayerGui Shop Button Simulator
            pcall(function()
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui then
                    for _, btn in ipairs(pgui:GetDescendants()) do
                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                            local txt = (btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or "")):lower()
                            local isBuyBtn = txt:find("buy") or txt:find("purchase") or txt:find("equip best") or txt:find("upgrade") or txt:find("unlock") or txt:find("max")
                            local isRobux = txt:find("robux") or txt:find("r$") or txt:find("pass") or txt:find("gift") or txt:find("buy cash") or txt:find("gem")
                            
                            if isBuyBtn and not isRobux then
                                if getconnections then
                                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
                                    for _, conn in ipairs(getconnections(btn.MouseButton1Down)) do conn:Fire() end
                                    for _, conn in ipairs(getconnections(btn.Activated)) do conn:Fire() end
                                end
                            end
                        end
                    end
                end
            end)

            -- E. Auto-Equip newly purchased best hammer from backpack
            EquipBestTool()
        end
    end
end)

-- ====================================================
-- 3. AUTO REBIRTH ENGINE
-- ====================================================
task.spawn(function()
    while true do
        task.wait(0.8)
        if Toggles.AutoRebirth and isAlive() then
            local hrp = LocalPlayer.Character.HumanoidRootPart

            -- 1. Rebirth Remotes Trigger
            pcall(function()
                for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                    local n = rem.Name:lower()
                    if n:find("rebirth") or n:find("prestige") or n:find("ascend") or n:find("evolve") then
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer()
                            rem:FireServer(1)
                            rem:FireServer(true)
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer()
                            rem:InvokeServer(1)
                        end
                    end
                end
            end)

            -- 2. Rebirth Proximity Prompts
            pcall(function()
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Parent then
                        local act = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                        if act:find("rebirth") or act:find("prestige") or act:find("ascend") then
                            local pPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or nil
                            if pPos and (pPos - hrp.Position).Magnitude < 120 then
                                InstantTriggerPrompt(prompt)
                            end
                        end
                    end
                end
            end)

            -- 3. Rebirth Touch Pads
            pcall(function()
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local n = part.Name:lower()
                        if (n:find("rebirth") or n:find("prestige") or n:find("ascend")) and (part.Position - hrp.Position).Magnitude < 90 then
                            InstantTouch(hrp, part)
                        end
                    end
                end
            end)

            -- 4. GUI Rebirth Buttons
            pcall(function()
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui then
                    for _, btn in ipairs(pgui:GetDescendants()) do
                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                            local txt = (btn.Name .. " " .. (btn:IsA("TextButton") and btn.Text or "")):lower()
                            if (txt:find("rebirth") or txt:find("prestige")) and not txt:find("robux") and not txt:find("pass") and not txt:find("shop") then
                                if getconnections then
                                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
                                    for _, conn in ipairs(getconnections(btn.Activated)) do conn:Fire() end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================================================
-- 4. UNLOCKED RARE BRAINROT EGG ESP ENGINE (MAGENTA NEON & LIVE BILLBOARD)
-- ====================================================
RunService.RenderStepped:Connect(function()
    if Toggles.RareEggESP then
        local myPos = isAlive() and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero
        local targetCFrame, prompt, eggPart, _, eggName, distFromBase = FindRarestEgg(myPos)

        if eggPart or (targetCFrame and targetCFrame.Position) then
            local hostObj = eggPart or (prompt and prompt.Parent)
            if hostObj and (hostObj:IsA("BasePart") or hostObj:IsA("Model")) then
                if not hostObj:FindFirstChild("JunejoRareEggHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "JunejoRareEggHighlight"
                    hl.FillColor = Color3.fromRGB(220, 30, 255)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.2
                    hl.OutlineTransparency = 0
                    hl.Parent = hostObj
                    table.insert(CurrentRareEggESPInstances, hl)
                end

                if not hostObj:FindFirstChild("JunejoRareEggBillboard") then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "JunejoRareEggBillboard"
                    bb.Size = UDim2.new(0, 220, 0, 42)
                    bb.StudsOffset = Vector3.new(0, 3.5, 0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = hostObj:IsA("BasePart") and hostObj or hostObj:FindFirstChildWhichIsA("BasePart")
                    bb.Parent = hostObj

                    local tagLabel = Instance.new("TextLabel")
                    tagLabel.Name = "TagLabel"
                    tagLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    tagLabel.Position = UDim2.new(0, 0, 0, 0)
                    tagLabel.BackgroundTransparency = 1
                    tagLabel.Text = "👑 UNLOCKED RARE: " .. eggName
                    tagLabel.TextColor3 = Color3.fromRGB(255, 60, 255)
                    tagLabel.TextStrokeTransparency = 0
                    tagLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    tagLabel.TextSize = 11
                    tagLabel.Font = Enum.Font.GothamBold
                    tagLabel.Parent = bb

                    local distLabel = Instance.new("TextLabel")
                    distLabel.Name = "DistLabel"
                    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
                    distLabel.BackgroundTransparency = 1
                    distLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
                    distLabel.TextStrokeTransparency = 0
                    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    distLabel.TextSize = 10
                    distLabel.Font = Enum.Font.GothamMedium
                    distLabel.Parent = bb
                    table.insert(CurrentRareEggESPInstances, bb)
                end

                local bb = hostObj:FindFirstChild("JunejoRareEggBillboard")
                if bb and bb:FindFirstChild("DistLabel") and isAlive() then
                    local myDist = math.floor((hostObj:GetPivot().Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                    bb.DistLabel.Text = "Base: " .. tostring(distFromBase) .. "s | Me: " .. myDist .. "s"
                end
            end
        end
    end
end)

-- ====================================================
-- 5. FLY MODE (UNIVERSAL MOBILE & PC FLIGHT)
-- ====================================================
local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local FlySpeed = 65

local function EnableFly()
    if not isAlive() then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Name = "JunejoFlyVelocity"
    FlyBodyVelocity.MaxForce = Vector3.new(9e5, 9e5, 9e5)
    FlyBodyVelocity.Velocity = Vector3.zero
    FlyBodyVelocity.Parent = hrp
    
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.Name = "JunejoFlyGyro"
    FlyBodyGyro.MaxTorque = Vector3.new(9e5, 9e5, 9e5)
    FlyBodyGyro.CFrame = hrp.CFrame
    FlyBodyGyro.Parent = hrp
end

local function DisableFly()
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
    if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
end

RunService.RenderStepped:Connect(function()
    if Toggles.FlyMode and isAlive() then
        if not FlyBodyVelocity or not FlyBodyVelocity.Parent then
            EnableFly()
        end
        local cam = Workspace.CurrentCamera
        local moveDir = Vector3.zero
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        if hum and hum.MoveDirection.Magnitude > 0 and moveDir.Magnitude == 0 then
            moveDir = (cam.CFrame.LookVector * hum.MoveDirection.Z * -1) + (cam.CFrame.RightVector * hum.MoveDirection.X)
            if hum.Jump then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
        end
        
        if FlyBodyGyro then FlyBodyGyro.CFrame = cam.CFrame end
        if FlyBodyVelocity then
            if moveDir.Magnitude > 0 then
                FlyBodyVelocity.Velocity = moveDir.Unit * (Toggles.WalkSpeedBoost and CustomSpeedValue or FlySpeed)
            else
                FlyBodyVelocity.Velocity = Vector3.zero
            end
        end
    else
        if FlyBodyVelocity or FlyBodyGyro then
            DisableFly()
        end
    end
end)

-- ====================================================
-- 6. NOCLIP ENGINE & SPEED KEEPER
-- ====================================================
RunService.Stepped:Connect(function()
    if isAlive() then
        if Toggles.Noclip or Toggles.AutoBreakRare then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        if Toggles.WalkSpeedBoost then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = CustomSpeedValue end
        end
    end
end)

-- ====================================================
-- 7. INFINITE JUMP (MOBILE & PC UNIVERSAL)
-- ====================================================
UIS.JumpRequest:Connect(function()
    if Toggles.InfiniteJump and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function()
    if Toggles.InfiniteJump and isAlive() then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Jump then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Character Added Re-hook
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateCharacterSpeed()
end)

-- ====================================================
-- 8. ANTI-AFK ENGINE
-- ====================================================
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end
end)
