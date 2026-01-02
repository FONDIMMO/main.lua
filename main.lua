--==================================================
-- FONDI MM2 | XENO
-- FULL ESP FIXED VERSION
--==================================================

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--==================================================
-- KEY SYSTEM (1 TIME)
--==================================================

local VALID_KEYS = {
    "FONDI-MM2-FOREVER-9X7Q",
}

local function hasKey()
    return LocalPlayer:GetAttribute("FONDI_KEY") ~= nil
end

local function isValidKey(key)
    for _,k in pairs(VALID_KEYS) do
        if k == key then return true end
    end
    return false
end

local function saveKey(key)
    LocalPlayer:SetAttribute("FONDI_KEY", key)
end

local function KeyUI(callback)
    if hasKey() then callback() return end

    local gui = Instance.new("ScreenGui", game.CoreGui)
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.3,0.22)
    frame.Position = UDim2.fromScale(0.35,0.4)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Active = true
    frame.Draggable = true

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.fromScale(1,0.3)
    title.BackgroundTransparency = 1
    title.Text = "ENTER KEY"
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.new(1,1,1)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.fromScale(0.85,0.25)
    box.Position = UDim2.fromScale(0.075,0.35)
    box.PlaceholderText = "FONDI-XXXX-XXXX"
    box.Font = Enum.Font.Gotham
    box.TextScaled = true
    box.BackgroundColor3 = Color3.fromRGB(30,30,30)
    box.TextColor3 = Color3.new(1,1,1)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.fromScale(0.85,0.22)
    btn.Position = UDim2.fromScale(0.075,0.65)
    btn.Text = "UNLOCK"
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)

    btn.MouseButton1Click:Connect(function()
        if isValidKey(box.Text) then
            saveKey(box.Text)
            gui:Destroy()
            callback()
        else
            box.Text = ""
            box.PlaceholderText = "INVALID KEY"
        end
    end)
end

--==================================================
-- SETTINGS
--==================================================

local Settings = {
    ESP = true,
    Boxes = true,
    Names = true,
    Tracers = true
}

--==================================================
-- ROLE DETECT (ALWAYS)
--==================================================

local function getRole(p)
    if p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife")) then
        return "Murderer"
    end
    if p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun")) then
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

--==================================================
-- ESP SYSTEM (FIXED)
--==================================================

local ESP = {}

local function createESP(p)
    if p == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Visible = false

    local name = Drawing.new("Text")
    name.Size = 13
    name.Center = true
    name.Outline = true
    name.Visible = false

    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Visible = false

    ESP[p] = {Box=box, Name=name, Tracer=tracer}
end

local function removeESP(p)
    if ESP[p] then
        for _,v in pairs(ESP[p]) do v:Remove() end
        ESP[p] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for p,e in pairs(ESP) do
        local c = p.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")

        if Settings.ESP and hrp and hum and hum.Health > 0 then
            local pos,on = Camera:WorldToViewportPoint(hrp.Position)
            if on then
                local role = getRole(p)
                local color = roleColor(role)
                local scale = 2000 / pos.Z
                local size = Vector2.new(scale, scale*1.5)

                if Settings.Boxes then
                    e.Box.Size = size
                    e.Box.Position = Vector2.new(pos.X-size.X/2, pos.Y-size.Y/2)
                    e.Box.Color = color
                    e.Box.Visible = true
                else
                    e.Box.Visible = false
                end

                if Settings.Names then
                    e.Name.Text = p.Name.." ["..role.."]"
                    e.Name.Position = Vector2.new(pos.X, pos.Y-size.Y/2-14)
                    e.Name.Color = color
                    e.Name.Visible = true
                else
                    e.Name.Visible = false
                end

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
                e.Name.Visible=false
                e.Tracer.Visible=false
            end
        else
            e.Box.Visible=false
            e.Name.Visible=false
            e.Tracer.Visible=false
        end
    end
end)

for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

--==================================================
-- GUI
--==================================================

local function MainGUI()
    local gui = Instance.new("ScreenGui", game.CoreGui)

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.24,0.35)
    frame.Position = UDim2.fromScale(0.38,0.33)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Active = true
    frame.Draggable = true

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.fromScale(1,0.2)
    title.BackgroundTransparency = 1
    title.Text = "MM2 | FONDI"
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.new(1,1,1)

    local function btn(txt,y,cb)
        local b = Instance.new("TextButton", frame)
        b.Size = UDim2.fromScale(0.8,0.18)
        b.Position = UDim2.fromScale(0.1,y)
        b.Text = txt
        b.Font = Enum.Font.Gotham
        b.TextScaled = true
        b.BackgroundColor3 = Color3.fromRGB(35,35,35)
        b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(cb)
    end

    btn("ESP",0.25,function() Settings.ESP = not Settings.ESP end)
    btn("BOXES",0.45,function() Settings.Boxes = not Settings.Boxes end)
    btn("NAMES",0.65,function() Settings.Names = not Settings.Names end)
    btn("TRACERS",0.85,function() Settings.Tracers = not Settings.Tracers end)
end

--==================================================
-- START
--==================================================

KeyUI(MainGUI)
