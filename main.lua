--=====================================
-- FONDI MM2 | FULL SCRIPT
--=====================================

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
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
    Tracers = true,
    GuiTransparency = 0.1,
    EspColor = Color3.fromRGB(255,0,0)
}

--=====================================
-- ROLE DETECTION (FIXED)
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

--=====================================
-- RENDER LOOP
--=====================================
RunService.RenderStepped:Connect(function()
    for p,e in pairs(ESP) do
        local c = p.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")

        if Settings.ESP and hrp and hum and hum.Health > 0 then
            local pos, on = Camera:WorldToViewportPoint(hrp.Position)
            if on then
                local role = GetRole(p)
                local color = role=="Murderer" and Color3.fromRGB(255,0,0)
                    or role=="Sheriff" and Color3.fromRGB(0,140,255)
                    or Color3.fromRGB(0,255,0)

                e.Box.Color = color
                e.Box.Size = Vector2.new(2000/pos.Z, 3000/pos.Z)
                e.Box.Position = Vector2.new(pos.X,pos.Y) - e.Box.Size/2
                e.Box.Visible = true

                e.Text.Text = p.Name.." ["..role.."]"
                e.Text.Position = Vector2.new(pos.X, pos.Y - e.Box.Size.Y/2 - 14)
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
            e.Box.Visible=false e.Text.Visible=false e.Tracer.Visible=false
        end
    end
end)

--=====================================
-- GUI
--=====================================
local function CreateGUI()
    local gui = Instance.new("ScreenGui", game.CoreGui)

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.25,0.5)
    frame.Position = UDim2.fromScale(0.37,0.25)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BackgroundTransparency = Settings.GuiTransparency
    frame.Active = true
    frame.Draggable = true

    local header = Instance.new("Frame", frame)
    header.Size = UDim2.fromScale(1,0.12)
    header.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.fromScale(0.85,1)
    title.Text = "FONDI MM2"
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Left

    local arrow = Instance.new("TextButton", header)
    arrow.Size = UDim2.fromScale(0.15,1)
    arrow.Position = UDim2.fromScale(0.85,0)
    arrow.Text = "▼"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextScaled = true
    arrow.BackgroundTransparency = 1

    local content = Instance.new("ScrollingFrame", frame)
    content.Position = UDim2.fromScale(0,0.12)
    content.Size = UDim2.fromScale(1,0.88)
    content.CanvasSize = UDim2.new(0,0,1.2,0)
    content.ScrollBarThickness = 6
    content.BackgroundTransparency = 1

    local function Button(text,y,cb)
        local b = Instance.new("TextButton", content)
        b.Size = UDim2.fromScale(0.85,0.08)
        b.Position = UDim2.fromScale(0.075,y)
        b.Text = text
        b.Font = Enum.Font.Gotham
        b.TextScaled = true
        b.BackgroundColor3 = Color3.fromRGB(35,35,35)
        b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(cb)
    end

    Button("ESP",0.05,function() Settings.ESP = not Settings.ESP end)
    Button("TRACERS",0.15,function() Settings.Tracers = not Settings.Tracers end)

    -- TELEPORT
    Button("TELEPORT",0.25,function()
        local tp = Instance.new("Frame", gui)
        tp.Size = UDim2.fromScale(0.22,0.35)
        tp.Position = UDim2.fromScale(0.4,0.3)
        tp.BackgroundColor3 = Color3.fromRGB(25,25,25)
        tp.Active = true
        tp.Draggable = true

        local close = Instance.new("TextButton", tp)
        close.Size = UDim2.fromScale(0.15,0.12)
        close.Position = UDim2.fromScale(0.85,0)
        close.Text = "X"
        close.TextScaled = true
        close.BackgroundColor3 = Color3.fromRGB(150,50,50)
        close.MouseButton1Click:Connect(function() tp:Destroy() end)

        local list = Instance.new("ScrollingFrame", tp)
        list.Size = UDim2.fromScale(1,0.88)
        list.Position = UDim2.fromScale(0,0.12)
        list.CanvasSize = UDim2.new(0,0,1,0)
        list.ScrollBarThickness = 6

        local y = 0
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local b = Instance.new("TextButton", list)
                b.Size = UDim2.fromScale(0.9,0.1)
                b.Position = UDim2.fromScale(0.05,y)
                b.Text = p.Name
                b.TextScaled = true
                b.BackgroundColor3 = Color3.fromRGB(35,35,35)
                b.MouseButton1Click:Connect(function()
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame =
                            p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                    end
                end)
                y += 0.12
            end
        end
    end)

    -- COLLAPSE (SMOOTH)
    local collapsed = false
    arrow.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        arrow.Text = collapsed and "▲" or "▼"
        TweenService:Create(
            frame,
            TweenInfo.new(0.35,Enum.EasingStyle.Quad),
            {Size = collapsed and UDim2.fromScale(0.25,0.12) or UDim2.fromScale(0.25,0.5)}
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
    local gui = Instance.new("ScreenGui", game.CoreGui)
    local box = Instance.new("TextBox", gui)
    box.Size = UDim2.fromScale(0.3,0.08)
    box.Position = UDim2.fromScale(0.35,0.45)
    box.PlaceholderText = "ENTER KEY"
    box.TextScaled = true
    box.BackgroundColor3 = Color3.fromRGB(20,20,20)
    box.TextColor3 = Color3.new(1,1,1)

    box.FocusLost:Connect(function()
        if box.Text == VALID_KEY then
            SaveKey()
            gui:Destroy()
            CreateGUI()
        else
            box.Text = ""
            box.PlaceholderText = "WRONG KEY"
        end
    end)
end
