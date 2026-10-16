
-- MOGTOP | Simple UI Demo
-- For your own Roblox Studio experience

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "MogtopUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 260)
main.Position = UDim2.new(0.5, -150, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 45)
title.Position = UDim2.new(0, 12, 0, 5)
title.BackgroundTransparency = 1
title.Text = "✳ MOGTOP"
title.TextColor3 = Color3.fromRGB(255, 65, 65)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 35, 0, 35)
close.Position = UDim2.new(1, -42, 0, 10)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(160, 35, 35)
close.Parent = main
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 35)
status.Position = UDim2.new(0, 10, 0, 55)
status.BackgroundTransparency = 1
status.Text = "ARACHNID • CONTROL PANEL"
status.TextColor3 = Color3.fromRGB(190, 190, 200)
status.TextSize = 12
status.Parent = main

local function makeButton(text, y, message)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -30, 0, 42)
    button.Position = UDim2.new(0, 15, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(38, 38, 45)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.Parent = main

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = button

    button.MouseButton1Click:Connect(function()
        status.Text = message
    end)
end

makeButton("Collection Tracker", 100, "Tracker demo enabled")
makeButton("Income Overview", 150, "Income overview demo")
makeButton("Settings", 200, "Settings coming soon")
