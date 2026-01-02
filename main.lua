-- =====================================
-- FONDI MM2 SCRIPT | STABLE XENO
-- =====================================

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- ================= ROLE =================
local function getRole(p)
    if p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife")) then
        return "Murderer"
    end
    if p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

-- ================= ESP =================
local ESP = {}

local function addESP(p)
    if p == LP then return end
    local t = Drawing.new("Text")
    t.Center = true
    t.Outline = true
    t.Size = 14
    ESP[p] = t
end

local function remESP(p)
    if ESP[p] then
        ESP[p]:Remove()
        ESP[p] = nil
    end
end

for _,p in pairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(remESP)

RunService.RenderStepped:Connect(function()
    for p,t in pairs(ESP) do
        local c = p.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health > 0 then
            local pos, on = Camera:WorldToViewportPoint(hrp.Position)
            if on then
                local role = getRole(p)
                t.Text = p.Name.." ["..role.."]"
                t.Color =
                    role=="Murderer" and Color3.fromRGB(255,0,0) or
                    role=="Sheriff" and Color3.fromRGB(0,150,255) or
                    Color3.fromRGB(0,255,0)
                t.Position = Vector2.new(pos.X, pos.Y - 25)
                t.Visible = true
            else
                t.Visible = false
            end
        else
            t.Visible = false
        end
    end
end)

-- ================= AUTO COIN =================
local AutoCoin = false

task.spawn(function()
    while task.wait(0.6) do
        if AutoCoin and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            for _,v in pairs(workspace:GetChildren()) do
                if v:IsA("Model") and v.Name:lower():find("coin") then
                    local part = v:FindFirstChildWhichIsA("BasePart")
                    if part then
                        LP.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0,2,0)
                        task.wait(0.08)
                    end
                end
            end
        end
    end
end)

-- ================= FLY + NOCLIP =================
local Fly = false
local BV, BG

local function startFly()
    local hrp = LP.Character.HumanoidRootPart
    BV = Instance.new("BodyVelocity", hrp)
    BG = Instance.new("BodyGyro", hrp)
    BV.MaxForce = Vector3.new(1e9,1e9,1e9)
    BG.MaxTorque = Vector3.new(1e9,1e9,1e9)
    Fly = true
end

local function stopFly()
    Fly = false
    if BV then BV:Destroy() end
    if BG then BG:Destroy() end
end

RunService.RenderStepped:Connect(function()
    if Fly and LP.Character then
        local hrp = LP.Character.HumanoidRootPart
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
        BV.Velocity = dir * 70
        BG.CFrame = Camera.CFrame
        for _,v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- ================= GUI =================
local gui = Instance.new("ScreenGui", game.CoreGui)
local f = Instance.new("Frame", gui)
f.Size = UDim2.fromScale(0.25,0.45)
f.Position = UDim2.fromScale(0.38,0.3)
f.BackgroundColor3 = Color3.fromRGB(20,20,20)
f.Active = true
f.Draggable = true

local title = Instance.new("TextLabel", f)
title.Size = UDim2.fromScale(1,0.15)
title.BackgroundTransparency = 1
title.Text = "FONDI MM2 | STABLE"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)

local function button(text, y, cb)
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.fromScale(0.8,0.18)
    b.Position = UDim2.fromScale(0.1,y)
    b.Text = text
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(cb)
end

button("AUTO COIN FARM", 0.25, function()
    AutoCoin = not AutoCoin
end)

button("FLY / NOCLIP", 0.48, function()
    if Fly then stopFly() else startFly() end
end)

print("FONDI MM2 STABLE loaded")
