--[[ MOGTOP V10.1 | VERIFIED BUILD | [S] By : root_.3 ]]
repeat task.wait() until game:IsLoaded()

local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = P.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

local Config = {
    Speed = 60,
    JumpPower = 50,
    AutoSteal = true,
    AutoSell = true,
    Aimbot = true,
    ESP = true,
    AntiRagdoll = true,
    AntiVoid = true,
    AutoRespawn = true,
    PingLagger = false,
    LaggerPower = 100000,
    StealRadius = 25,
    SellInterval = 3,
    SwingDelay = 0.12
}

local function getChar()
    local c = LP.Character
    if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChildOfClass("Humanoid") then
        return c, c.HumanoidRootPart, c:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function notify(title, text, color)
    local sg = Instance.new("ScreenGui")
    sg.ResetOnSpawn = false
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = LP:WaitForChild("PlayerGui") end
    
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 250, 0, 50)
    f.Position = UDim2.new(0.5, -125, 0, 30)
    f.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", f).Color = color or Color3.fromRGB(0, 255, 0)
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -20, 1, -10)
    lbl.Position = UDim2.new(0, 10, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = "["..title.."] "..text
    lbl.TextColor3 = color or Color3.fromRGB(0, 255, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextWrapped = true
    
    pcall(function()
        TweenService:Create(f, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -125, 0, 60)}):Play()
    end)
    task.delay(2, function()
        pcall(function()
            local tw = TweenService:Create(f, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -125, 0, -60)})
            tw:Play()
            tw.Completed:Wait()
        end)
        sg:Destroy()
    end)
end

-- Prompt Cache
local promptCache = {}
local lastCache = 0
local function refreshPromptCache()
    local newCache = {}
    local plots = workspace:FindFirstChild("Plots")
    if plots then
        pcall(function()
            for _, plot in ipairs(plots:GetChildren()) do
                for _, obj in ipairs(plot:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and obj.Enabled then
                        local text = tostring(obj.ActionText)
                        if text:find("Steal") or text:find("Take") then
                            table.insert(newCache, obj)
                        end
                    end
                end
            end
        end)
    end
    promptCache = newCache
    lastCache = tick()
end

-- Sell Remote (بحث ذكي بدون Recursive)
local sellRemote = nil
local lastSellSearch = 0
local function findSellRemote()
    if tick() - lastSellSearch < 5 then
        return sellRemote
    end
    lastSellSearch = tick()
    
    local names = {"SellAll", "SellPets", "SellPet", "Sell", "SellAllPets"}
    for _, name in ipairs(names) do
        local found = RS:FindFirstChild(name)
        if found and (found:IsA("RemoteEvent") or found:IsA("RemoteFunction")) then
            sellRemote = found
            return found
        end
    end
    
    local folders = {RS, RS:FindFirstChild("Remotes"), RS:FindFirstChild("Events"), RS:FindFirstChild("Network")}
    for _, folder in ipairs(folders) do
        if folder then
            for _, v in pairs(folder:GetChildren()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    local n = string.lower(v.Name)
                    if n == "sellall" or n == "sellpets" or n == "sellpet" or n == "sell" then
                        sellRemote = v
                        return v
                    end
                end
            end
        end
    end
    return sellRemote
end

-- Lagger Payload
local laggerPayload = nil
local lastLaggerPower = -1
local function buildLaggerPayload()
    if lastLaggerPower == Config.LaggerPower and laggerPayload then return end
    local nested = {{}}
    local current = nested[1]
    for _ = 1, 186 do
        local n = {}
        table.insert(current, n)
        current = n
    end
    laggerPayload = {}
    for _ = 1, math.min(math.floor(Config.LaggerPower / 188), 10000) do
        table.insert(laggerPayload, nested)
    end
    lastLaggerPower = Config.LaggerPower
end

-- Main Loop
local lastSwing = 0
local lastESP = 0
local lastRespawn = 0
local safeCFrame = nil
local respawnCooldown = false

R.Heartbeat:Connect(function()
    local c, h, m = getChar()
    if not h or not m then
        if Config.AutoRespawn and not respawnCooldown then
            respawnCooldown = true
            task.delay(3, function() respawnCooldown = false end)
            pcall(function()
                if LP.Character then LP.Character:BreakJoints() end
            end)
        end
        return
    end
    if m.Health <= 0 then return end

    m.WalkSpeed = Config.Speed
    m.JumpPower = Config.JumpPower
    m.UseJumpPower = true

    if Config.AntiRagdoll then
        local state = m:GetState()
        if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
            m:ChangeState(Enum.HumanoidStateType.GettingUp)
            h.AssemblyLinearVelocity = Vector3.zero
            h.AssemblyAngularVelocity = Vector3.zero
        end
    end

    if Config.AntiVoid then
        if m.FloorMaterial ~= Enum.Material.Air then
            safeCFrame = h.CFrame
        end
        if h.Position.Y < -100 and safeCFrame then
            h.CFrame = safeCFrame + Vector3.new(0, 5, 0)
            h.AssemblyLinearVelocity = Vector3.zero
        end
    end

    -- إصلاح: استخدام المهام المتوازية للسرقة بدل task.wait
    if Config.AutoSteal then
        if tick() - lastCache > 0.5 then refreshPromptCache() end
        for _, prompt in ipairs(promptCache) do
            if prompt.Parent and prompt.Enabled then
                local part = prompt.Parent
                if part:IsA("Attachment") then part = part.Parent end
                if part and part:IsA("BasePart") then
                    if (h.Position - part.Position).Magnitude <= Config.StealRadius then
                        task.spawn(function()
                            pcall(function()
                                if fireproximityprompt then
                                    fireproximityprompt(prompt)
                                else
                                    prompt:InputHoldBegin()
                                    task.wait(0.05)
                                    prompt:InputHoldEnd()
                                end
                            end)
                        end)
                    end
                end
            end
        end
    end

    if Config.Aimbot and tick() - lastSwing > Config.SwingDelay then
        local bestTarget, bestDist = nil, math.huge
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP and p.Character then
                local t = p.Character:FindFirstChild("HumanoidRootPart")
                local tm = p.Character:FindFirstChildOfClass("Humanoid")
                if t and tm and tm.Health > 0 then
                    local d = (h.Position - t.Position).Magnitude
                    if d < bestDist and d <= 15 then
                        bestDist = d
                        bestTarget = t
                    end
                end
            end
        end

        if bestTarget then
            m.AutoRotate = false
            local look = (bestTarget.Position - h.Position).Unit
            h.CFrame = CFrame.lookAt(h.Position, h.Position + Vector3.new(look.X, 0, look.Z))
            local bat = c:FindFirstChildWhichIsA("Tool")
            if not bat then
                local bp = LP:FindFirstChild("Backpack")
                if bp then
                    for _, t in ipairs(bp:GetChildren()) do
                        if t:IsA("Tool") and (t.Name:lower():find("bat") or t.Name:lower():find("slap")) then
                            m:EquipTool(t)
                            bat = t
                            break
                        end
                    end
                end
            end
            if bat and bestDist <= 10 then
                lastSwing = tick()
                pcall(function()
                    bat:Activate()
                    local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
                    if ev then ev:FireServer() end
                end)
            end
        else
            m.AutoRotate = true
        end
    end
end)

-- Sell Loop
task.spawn(function()
    while task.wait(Config.SellInterval) do
        if not Config.AutoSell then continue end
        local sr = findSellRemote()
        if sr and sr.Parent then
            pcall(function()
                if sr:IsA("RemoteEvent") then
                    sr:FireServer("SellAll")
                    sr:FireServer()
                elseif sr:IsA("RemoteFunction") then
                    sr:InvokeServer("SellAll")
                end
            end)
        end
    end
end)

-- Lagger Loop
task.spawn(function()
    while task.wait(0.125) do
        if not Config.PingLagger then continue end
        buildLaggerPayload()
        local rrs = game:FindFirstChild("RobloxReplicatedStorage")
        if rrs then
            local remote = rrs:FindFirstChild("SetPlayerBlockList")
            if remote and remote:IsA("RemoteEvent") then
                pcall(function() remote:FireServer(laggerPayload) end)
            end
        end
    end
end)

-- Anti AFK
pcall(function()
    LP.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

-- ESP
local espCache = {}
R.RenderStepped:Connect(function()
    local now = tick()
    if now - lastESP < 0.05 then return end
    lastESP = now
    if not Config.ESP then
        for _, v in pairs(espCache) do pcall(function() v.Box.Visible = false; v.Name.Visible = false end) end
        return
    end
    if not Drawing then return end
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP then
            if not espCache[p] then
                local ok1, box = pcall(function() return Drawing.new("Square") end)
                if not ok1 then return end
                local ok2, name = pcall(function() return Drawing.new("Text") end)
                if not ok2 then return end
                box.Thickness = 1; box.Color = Color3.fromRGB(255, 0, 0); box.Filled = false
                name.Size = 14; name.Center = true; name.Outline = true; name.Color = Color3.new(1,1,1)
                espCache[p] = {Box = box, Name = name}
            end
            local cache = espCache[p]
            local char = p.Character
            local head = char and char:FindFirstChild("Head")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if head and root and hum and hum.Health > 0 then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                local bPos, bOnScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                if onScreen and bOnScreen then
                    local height = math.abs(pos.Y - bPos.Y)
                    local width = height * 0.6
                    cache.Box.Size = Vector2.new(width, height)
                    cache.Box.Position = Vector2.new(pos.X - width/2, pos.Y)
                    cache.Name.Position = Vector2.new(pos.X, pos.Y - 16)
                    cache.Name.Text = p.Name
                    cache.Box.Visible = true; cache.Name.Visible = true
                else
                    cache.Box.Visible = false; cache.Name.Visible = false
                end
            else
                cache.Box.Visible = false; cache.Name.Visible = false
            end
        end
    end
end)

-- GUI
local sg = Instance.new("ScreenGui")
sg.Name = "MOGTOP_V10_1"
sg.ResetOnSpawn = false
pcall(function() sg.Parent = game:GetService("CoreGui") end)
if not sg.Parent then sg.Parent = LP:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 260, 0, 500)
frame.Position = UDim2.new(0, 20, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(255, 50, 50)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -30, 0, 30)
title.BackgroundTransparency = 1
title.Text = "MOGTOP V10.1"
title.TextColor3 = Color3.fromRGB(255, 50, 50)
title.Font = Enum.Font.GothamBlack
title.TextSize = 14

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 12
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    notify("MOGTOP", "Hidden. Right Shift to show.", Color3.fromRGB(255, 200, 50))
end)

local content = Instance.new("Frame", frame)
content.Size = UDim2.new(1, -10, 1, -40)
content.Position = UDim2.new(0, 5, 0, 35)
content.BackgroundTransparency = 1
Instance.new("UIListLayout", content).Padding = UDim.new(0, 5)

local function addInput(name, key, min, max)
    local row = Instance.new("Frame", content)
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local box = Instance.new("TextBox", row)
    box.Size = UDim2.new(0.35, 0, 0, 22)
    box.Position = UDim2.new(0.6, 0, 0.5, -11)
    box.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    box.BorderSizePixel = 0
    box.Text = tostring(Config[key])
    box.TextColor3 = Color3.fromRGB(255, 50, 50)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 12
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        if val then
            Config[key] = math.clamp(val, min, max)
            box.Text = tostring(Config[key])
        else
            box.Text = tostring(Config[key])
        end
    end)
end

local function addToggle(name, key)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    btn.Text = name .. ": " .. (Config[key] and "ON" or "OFF")
    btn.TextColor3 = Config[key] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        btn.Text = name .. ": " .. (Config[key] and "ON" or "OFF")
        btn.TextColor3 = Config[key] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    end)
end

addInput("Walk Speed", "Speed", 16, 200)
addInput("Jump Power", "JumpPower", 50, 300)
addInput("Swing Delay", "SwingDelay", 0.01, 1)
addInput("Sell Interval", "SellInterval", 0.5, 10)
addInput("Lagger Power", "LaggerPower", 10000, 500000)
addToggle("Auto Steal", "AutoSteal")
addToggle("Auto Sell", "AutoSell")
addToggle("Aimbot", "Aimbot")
addToggle("ESP", "ESP")
addToggle("Anti Ragdoll", "AntiRagdoll")
addToggle("Anti Void", "AntiVoid")
addToggle("Auto Respawn", "AutoRespawn")
addToggle("Ping Lagger", "PingLagger")

U.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end)

local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
U.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
U.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

notify("MOGTOP V10.1", "Loaded successfully!", Color3.fromRGB(0, 255, 0))
