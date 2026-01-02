-- =====================================
-- FONDI MM2 SCRIPT | XENO STABLE FULL
-- =====================================

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- =====================================
-- KEY SYSTEM
-- =====================================
local VALID_KEY = "FONDI-MM2-FOREVER-9X7Q"
local VALID_KEY = "FONDI-MM2-FOREVER-6H1W"

local function hasKey()
    return LP:GetAttribute("FONDI_MM2_KEY") == VALID_KEY
end

local function saveKey()
    pcall(function()
        LP:SetAttribute("FONDI_MM2_KEY", VALID_KEY)
    end)
end

local function KeyUI(onSuccess)
    if hasKey() then
        onSuccess()
        return
    end

    local gui = Instance.new("ScreenGui", game.CoreGui)
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.32,0.22)
    frame.Position = UDim2.fromScale(0.5,0.5)
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Active = true
    frame.Draggable = true

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.fromScale(1,0.3)
    title.BackgroundTransparency = 1
    title.Text = "FONDI MM2 | KEY"
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.new(1,1,1)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.fromScale(0.85,0.25)
    box.Position = UDim2.fromScale(0.075,0.35)
    box.PlaceholderText = "Enter Key"
    box.TextScaled = true
    box.BackgroundColor3 = Color3.fromRGB(30,30,30)
    box.TextColor3 = Color3.new(1,1,1)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.fromScale(0.85,0.22)
    btn.Position = UDim2.fromScale(0.075,0.68)
    btn.Text = "UNLOCK"
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)

    btn.MouseButton1Click:Connect(function()
        if box.Text == VALID_KEY then
            saveKey()
            gui:Destroy()
            onSuccess()
        else
            box.Text = ""
            box.PlaceholderText = "INVALID KEY"
        end
    end)
end

-- =====================================
-- ROLE DETECTION
-- =====================================
local function getRole(p)
    if p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife")) then
        return "Murderer"
    end
    if p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

-- =====================================
-- ESP (WH)
-- =====================================
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

-- =====================================
-- FLY + NOCLIP
-- =====================================
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

-- =====================================
-- MAIN GUI + TELEPORT
-- =====================================
local function CreateMainGUI()
    local gui = Instance.new("ScreenGui", game.CoreGui)

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.25,0.6)
    frame.Position = UDim2.fromScale(0.38,0.25)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Active = true
    frame.Draggable = true

    local header = Instance.new("Frame", frame)
    header.Size = UDim2.fromScale(1,0.12)
    header.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.fromScale(0.85,1)
    title.BackgroundTransparency = 1
    title.Text = "MM2 | FONDI"
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.new(1,1,1)
    title.TextXAlignment = Enum.TextXAlignment.Left

    local arrow = Instance.new("TextButton", header)
    arrow.Size = UDim2.fromScale(0.15,1)
    arrow.Position = UDim2.fromScale(0.85,0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextScaled = true
    arrow.TextColor3 = Color3.new(1,1,1)

    local content = Instance.new("Frame", frame)
    content.Position = UDim2.fromScale(0,0.12)
    content.Size = UDim2.fromScale(1,0.88)
    content.BackgroundTransparency = 1

    local function btn(text,y,cb)
        local b = Instance.new("TextButton", content)
        b.Size = UDim2.fromScale(0.8,0.12)
        b.Position = UDim2.fromScale(0.1,y)
        b.Text = text
        b.TextScaled = true
        b.BackgroundColor3 = Color3.fromRGB(40,40,40)
        b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(cb)
    end

    btn("FLY / NOCLIP",0.1,function()
        if Fly then stopFly() else startFly() end
    end)

    btn("TELEPORT",0.28,function()
        local tp = Instance.new("Frame", gui)
        tp.Size = UDim2.fromScale(0.25,0.4)
        tp.Position = UDim2.fromScale(0.37,0.3)
        tp.BackgroundColor3 = Color3.fromRGB(20,20,20)
        tp.Active = true
        tp.Draggable = true

        local close = Instance.new("TextButton", tp)
        close.Size = UDim2.fromScale(0.15,0.12)
        close.Position = UDim2.fromScale(0.85,0)
        close.Text = "X"
        close.TextScaled = true
        close.BackgroundColor3 = Color3.fromRGB(200,50,50)
        close.TextColor3 = Color3.new(1,1,1)
        close.MouseButton1Click:Connect(function()
            tp:Destroy()
        end)

        local list = Instance.new("ScrollingFrame", tp)
        list.Position = UDim2.fromScale(0,0.12)
        list.Size = UDim2.fromScale(1,0.88)
        list.CanvasSize = UDim2.new(0,0,0,0)
        list.ScrollBarThickness = 6

        local y = 0
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LP then
                local b = Instance.new("TextButton", list)
                b.Size = UDim2.fromScale(0.9,0.14)
                b.Position = UDim2.fromScale(0.05,y)
                b.Text = p.Name
                b.TextScaled = true
                b.BackgroundColor3 = Color3.fromRGB(35,35,35)
                b.TextColor3 = Color3.new(1,1,1)
                b.MouseButton1Click:Connect(function()
                    local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and my then
                        my.CFrame = hrp.CFrame + Vector3.new(0,3,0)
                    end
                end)
                y += 0.16
            end
        end
        list.CanvasSize = UDim2.new(0,0,y,0)
    end)

    local collapsed = false
    arrow.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        arrow.Text = collapsed and "▲" or "▼"
        TweenService:Create(
            frame,
            TweenInfo.new(0.25),
            {Size = collapsed and UDim2.fromScale(0.25,0.12) or UDim2.fromScale(0.25,0.6)}
        ):Play()
        content.Visible = not collapsed
    end)
end

-- =====================================
-- START
-- =====================================
KeyUI(CreateMainGUI)
