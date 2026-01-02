-- =====================================
-- FONDI MM2 SCRIPT
-- =====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ================= SETTINGS =================
local Settings = {
    ESP = true,
    MurdererOnly = false,
    Tracers = true,
    AimAssist = false,
    AimFOV = 120
}

-- ================= ROLE =================
local function getRole(p)
    local c = p.Character
    if not c then return "Innocent" end
    if c:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife") then
        return "Murderer"
    end
    if c:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun") then
        return "Sheriff"
    end
    return "Innocent"
end

local function roleColor(role)
    if role == "Murderer" then
        return Color3.fromRGB(255,0,0)
    elseif role == "Sheriff" then
        return Color3.fromRGB(0,120,255)
    else
        return Color3.fromRGB(0,255,0)
    end
end

-- ================= ESP =================
local ESP = {}

local function createESP(player)
    if player == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Visible = false

    local text = Drawing.new("Text")
    text.Size = 13
    text.Center = true
    text.Outline = true
    text.Visible = false

    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Visible = false

    ESP[player] = {Box=box, Text=text, Tracer=tracer}
end

local function removeESP(player)
    if ESP[player] then
        for _,v in pairs(ESP[player]) do
            v:Remove()
        end
        ESP[player] = nil
    end
end

-- ================= AIM =================
local function getClosestMurderer()
    local closest, dist = nil, Settings.AimFOV
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == "Murderer" then
            local c = p.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local pos, on = Camera:WorldToViewportPoint(hrp.Position)
                if on then
                    local d = (Vector2.new(pos.X,pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if d < dist then
                        dist = d
                        closest = hrp
                    end
                end
            end
        end
    end
    return closest
end

-- ================= UPDATE =================
RunService.RenderStepped:Connect(function()
    if Settings.AimAssist then
        local target = getClosestMurderer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    for p,e in pairs(ESP) do
        local c = p.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")

        if Settings.ESP and hrp and hum and hum.Health > 0 then
            local role = getRole(p)
            if Settings.MurdererOnly and role ~= "Murderer" then
                e.Box.Visible=false
                e.Text.Visible=false
                e.Tracer.Visible=false
            else
                local pos,on = Camera:WorldToViewportPoint(hrp.Position)
                if on then
                    local color = roleColor(role)
                    local scale = 2000 / pos.Z
                    local size = Vector2.new(scale, scale*1.5)

                    e.Box.Size = size
                    e.Box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                    e.Box.Color = color
                    e.Box.Visible = true

                    e.Text.Text = p.Name.." ["..role.."]"
                    e.Text.Position = Vector2.new(pos.X, pos.Y - size.Y/2 - 14)
                    e.Text.Color = color
                    e.Text.Visible = true

                    if Settings.Tracers then
                        e.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        e.Tracer.To = Vector2.new(pos.X, pos.Y)
                        e.Tracer.Color = color
                        e.Tracer.Visible = true
                    else
                        e.Tracer.Visible = false
                    end
                else
                    e.Box.Visible=false
                    e.Text.Visible=false
                    e.Tracer.Visible=false
                end
            end
        else
            e.Box.Visible=false
            e.Text.Visible=false
            e.Tracer.Visible=false
        end
    end
end)

for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

-- ================= GUI =================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FONDI_MM2_GUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.24,0.45)
frame.Position = UDim2.fromScale(0.38,0.32)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

-- HEADER (ФИКСИРОВАННЫЙ)
local HEADER_HEIGHT = 0.12

local header = Instance.new("Frame", frame)
header.Size = UDim2.fromScale(1, HEADER_HEIGHT)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.fromScale(0.85,1)
title.BackgroundTransparency = 1
title.Text = "MM2 | FONDI"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left

local arrow = Instance.new("TextButton", header)
arrow.Size = UDim2.fromScale(0.15,1)
arrow.Position = UDim2.fromScale(0.85,0)
arrow.BackgroundTransparency = 1
arrow.Text = "▼"
arrow.Font = Enum.Font.GothamBold
arrow.TextScaled = true
arrow.TextColor3 = Color3.fromRGB(200,200,200)

-- CONTENT
local content = Instance.new("Frame", frame)
content.Position = UDim2.fromScale(0, HEADER_HEIGHT)
content.Size = UDim2.fromScale(1, 1 - HEADER_HEIGHT)
content.BackgroundTransparency = 1

local function makeButton(text, y, callback)
    local b = Instance.new("TextButton", content)
    b.Position = UDim2.fromScale(0.1,y)
    b.Size = UDim2.fromScale(0.8,0.15)
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextScaled = true
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.MouseButton1Click:Connect(callback)
end

makeButton("ESP",0.05,function() Settings.ESP = not Settings.ESP end)
makeButton("MURDERER ONLY",0.25,function() Settings.MurdererOnly = not Settings.MurdererOnly end)
makeButton("TRACERS",0.45,function() Settings.Tracers = not Settings.Tracers end)
makeButton("AIM ASSIST",0.65,function() Settings.AimAssist = not Settings.AimAssist end)

-- ================= COLLAPSE FIX =================
local collapsed = false
local FULL_SIZE = frame.Size
local COLLAPSED_SIZE = UDim2.fromScale(0.24, HEADER_HEIGHT)

arrow.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    content.Visible = not collapsed
    frame.Size = collapsed and COLLAPSED_SIZE or FULL_SIZE
    arrow.Text = collapsed and "▲" or "▼"
end)

print("FONDI MM2 loaded")
