--=====================================
-- FONDI MM2 | FIXED GUI VERSION
--=====================================

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--=====================================
-- KEY SYSTEM
--=====================================
local VALID_KEY = "FONDI-MM2-FOREVER"
local KEY_ATTR = "FONDI_MM2_KEY"

local function HasKey()
    return LocalPlayer:GetAttribute(KEY_ATTR) == VALID_KEY
end

local function SaveKey()
    LocalPlayer:SetAttribute(KEY_ATTR, VALID_KEY)
end

--=====================================
-- SETTINGS
--=====================================
local Settings = {
    ESP = true,
    Tracers = true
}

--=====================================
-- ROLE
--=====================================
local function GetRole(p)
    if not p.Character then return "Innocent" end
    if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
        return "Murderer"
    end
    if p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
        return "Sheriff"
    end
    return "Innocent"
end

--=====================================
-- ESP
--=====================================
local ESP = {}

local function CreateESP(p)
    if p == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false

    local text = Drawing.new("Text")
    text.Size = 13
    text.Center = true
    text.Outline = true

    local tracer = Drawing.new("Line")
    tracer.Thickness = 1

    ESP[p] = {Box=box, Text=text, Tracer=tracer}
end

local function RemoveESP(p)
    if ESP[p] then
        for _,v in pairs(ESP[p]) do v:Remove() end
        ESP[p] = nil
    end
end

for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    for p,e in pairs(ESP) do
        local c = p.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")

        if Settings.ESP and hrp and hum and hum.Health > 0 then
            local pos, on = Camera:WorldToViewportPoint(hrp.Position)
            if on then
                local role = GetRole(p)
                local color =
                    role=="Murderer" and Color3.fromRGB(255,0,0) or
                    role=="Sheriff" and Color3.fromRGB(0,120,255) or
                    Color3.fromRGB(0,255,0)

                local size = Vector2.new(2000/pos.Z, 3000/pos.Z)
                e.Box.Size = size
                e.Box.Position = Vector2.new(pos.X,pos.Y) - size/2
                e.Box.Color = color
                e.Box.Visible = true

                e.Text.Text = p.Name.." ["..role.."]"
                e.Text.Position = Vector2.new(pos.X,pos.Y-size.Y/2-14)
                e.Text.Color = color
                e.Text.Visible = true

                if Settings.Tracers then
                    e.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    e.Tracer.To = Vector2.new(pos.X,pos.Y)
                    e.Tracer.Color = color
                    e.Tracer.Visible = true
                else
                    e.Tracer.Visible = false
                end
            end
        else
            e.Box.Visible=false
            e.Text.Visible=false
            e.Tracer.Visible=false
        end
    end
end)

--=====================================
-- GUI
--=====================================
local function CreateGUI()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "FONDI_MM2_GUI"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.25,0.45)
    frame.Position = UDim2.fromScale(0.375,0.3)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Active = true
    frame.Draggable = true

    -- HEADER
    local header = Instance.new("Frame", frame)
    header.Size = UDim2.fromScale(1,0.15)
    header.BackgroundColor3 = Color3.fromRGB(25,25,25)

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.fromScale(0.85,1)
    title.BackgroundTransparency = 1
    title.Text = "FONDI MM2"
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.new(1,1,1)
    title.TextXAlignment = Enum.TextXAlignment.Left

    local arrow = Instance.new("TextButton", header)
    arrow.Size = UDim2.fromScale(0.15,1)
    arrow.Position = UDim2.fromScale(0.85,0)
    arrow.Text = "▼"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextScaled = true
    arrow.BackgroundTransparency = 1
    arrow.TextColor3 = Color3.new(1,1,1)

    -- CONTENT
    local content = Instance.new("Frame", frame)
    content.Position = UDim2.fromScale(0,0.15)
    content.Size = UDim2.fromScale(1,0.85)
    content.BackgroundTransparency = 1

    local function Button(text,y,cb)
        local b = Instance.new("TextButton", content)
        b.Size = UDim2.fromScale(0.85,0.15)
        b.Position = UDim2.fromScale(0.075,y)
        b.Text = text
        b.Font = Enum.Font.Gotham
        b.TextScaled = true
        b.BackgroundColor3 = Color3.fromRGB(35,35,35)
        b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(cb)
    end

    Button("ESP",0.1,function() Settings.ESP = not Settings.ESP end)
    Button("TRACERS",0.3,function() Settings.Tracers = not Settings.Tracers end)

    -- COLLAPSE
    local collapsed = false
    arrow.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        arrow.Text = collapsed and "▲" or "▼"
        TweenService:Create(
            frame,
            TweenInfo.new(0.3,Enum.EasingStyle.Quad),
            {Size = collapsed and UDim2.fromScale(0.25,0.15) or UDim2.fromScale(0.25,0.45)}
        ):Play()
        content.Visible = not collapsed
    end)
end

--=====================================
-- START
--=====================================
if HasKey() then
    CreateGUI()
else
    local g = Instance.new("ScreenGui", game.CoreGui)
    local b = Instance.new("TextBox", g)
    b.Size = UDim2.fromScale(0.3,0.08)
    b.Position = UDim2.fromScale(0.35,0.45)
    b.PlaceholderText = "ENTER KEY"
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(20,20,20)
    b.TextColor3 = Color3.new(1,1,1)

    b.FocusLost:Connect(function()
        if b.Text == VALID_KEY then
            SaveKey()
            g:Destroy()
            CreateGUI()
        else
            b.Text = ""
            b.PlaceholderText = "WRONG KEY"
        end
    end)
end
