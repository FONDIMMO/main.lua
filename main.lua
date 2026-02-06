--==================================================
-- FONDI MM2 | FIXED HUNT ASSIST
--==================================================

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

--==================================================
-- KEY SYSTEM
--==================================================
local KEY = "FONDI-MM2-FOREVER"
local ATTR = "FONDI_MM2_KEY"

local function HasKey()
    return LP:GetAttribute(ATTR) == KEY
end

local function SaveKey()
    LP:SetAttribute(ATTR, KEY)
end

--==================================================
-- SETTINGS
--==================================================
local Settings = {
    ESP = true,
    Tracers = true,
    Fly = false,
    Noclip = false
}

--==================================================
-- ROLE CHECK
--==================================================
local function GetRole(p)
    if p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife")) then
        return "Murderer"
    end
    if p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

--==================================================
-- ESP
--==================================================
local ESP = {}

local function AddESP(p)
    if p == LP then return end

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

for _,p in ipairs(Players:GetPlayers()) do AddESP(p) end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end

    for p,e in pairs(ESP) do
        local c = p.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")

        if Settings.ESP and hrp and hum and hum.Health > 0 then
            local pos,on = Camera:WorldToViewportPoint(hrp.Position)
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

                local dist = math.floor(
                    (LP.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                )

                e.Text.Text = p.Name.." ["..role.."] ("..dist.."m)"
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
            else
                e.Box.Visible=false
                e.Text.Visible=false
                e.Tracer.Visible=false
            end
        else
            e.Box.Visible=false
            e.Text.Visible=false
            e.Tracer.Visible=false
        end
    end
end)

--==================================================
-- FLY (FIXED)
--==================================================
local FlyBV, FlyBG
local FlySpeed = 60

RunService.RenderStepped:Connect(function()
    if Settings.Fly and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart

        if not FlyBV then
            FlyBV = Instance.new("BodyVelocity")
            FlyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
            FlyBV.Parent = hrp

            FlyBG = Instance.new("BodyGyro")
            FlyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
            FlyBG.Parent = hrp
        end

        FlyBG.CFrame = Camera.CFrame

        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

        FlyBV.Velocity = move * FlySpeed
    else
        if FlyBV then FlyBV:Destroy() FlyBV=nil end
        if FlyBG then FlyBG:Destroy() FlyBG=nil end
    end
end)

--==================================================
-- NOCLIP (FIXED)
--==================================================
RunService.Stepped:Connect(function()
    if Settings.Noclip and LP.Character then
        for _,v in ipairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

--==================================================
-- TELEPORT
--==================================================
local function TeleportTo(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame =
            player.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
    end
end

--==================================================
-- HUNT ASSIST (FIXED)
--==================================================
local lastTP = 0
local TP_COOLDOWN = 0.6

local function GetNearestTarget()
    if GetRole(LP) ~= "Murderer" then return nil end
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return nil end

    local myPos = LP.Character.HumanoidRootPart.Position
    local nearest, dist = nil, math.huge

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local d = (myPos - hrp.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = p
                end
            end
        end
    end
    return nearest
end

local function HuntTeleport()
    if tick() - lastTP < TP_COOLDOWN then return end
    lastTP = tick()

    local target = GetNearestTarget()
    if target then
        TeleportTo(target)
    end
end

--==================================================
-- GUI
--==================================================
local function CreateGUI()
    local gui = Instance.new("ScreenGui", game.CoreGui)

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.28,0.6)
    frame.Position = UDim2.fromScale(0.36,0.2)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Active = true
    frame.Draggable = true

    local function Button(text,y,cb)
        local b = Instance.new("TextButton", frame)
        b.Size = UDim2.fromScale(0.85,0.08)
        b.Position = UDim2.fromScale(0.075,y)
        b.Text = text
        b.TextScaled = true
        b.BackgroundColor3 = Color3.fromRGB(35,35,35)
        b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(cb)
    end

    Button("ESP",0.05,function() Settings.ESP = not Settings.ESP end)
    Button("TRACERS",0.15,function() Settings.Tracers = not Settings.Tracers end)
    Button("FLY",0.25,function() Settings.Fly = not Settings.Fly end)
    Button("NOCLIP",0.35,function() Settings.Noclip = not Settings.Noclip end)
    Button("HUNT TP (NEAREST)",0.45,function() HuntTeleport() end)
end

--==================================================
-- START
--==================================================
if HasKey() then
    CreateGUI()
else
    local g = Instance.new("ScreenGui", game.CoreGui)
    local box = Instance.new("TextBox", g)
    box.Size = UDim2.fromScale(0.3,0.08)
    box.Position = UDim2.fromScale(0.35,0.45)
    box.PlaceholderText = "ENTER KEY"
    box.TextScaled = true
    box.BackgroundColor3 = Color3.fromRGB(20,20,20)
    box.TextColor3 = Color3.new(1,1,1)

    box.FocusLost:Connect(function()
        if box.Text == KEY then
            SaveKey()
            g:Destroy()
            CreateGUI()
        else
            box.Text = ""
            box.PlaceholderText = "WRONG KEY"
        end
    end)
end
