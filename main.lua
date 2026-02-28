--==================================================
-- FONDI MM2 V3 | ELITE EDITION
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

--==================================================
-- KEY SYSTEM & CONFIG
--==================================================
local KEY = "FONDI-MM2-FOREVER"
local ATTR = "FONDI_MM2_KEY"
local CONFIG_FILE = "fondi_mm2_cfg.json"

local function HasKey() return LP:GetAttribute(ATTR) == KEY end
local function SaveKey() LP:SetAttribute(ATTR, KEY) end

local Settings = {
    ESP = true,
    Tracers = true,
    Fly = false,
    Noclip = false,
    FlySpeed = 60,
    SilentAim = false,
    KillAura = false,
    AutoCollect = false,
    AutoGrab = false,
    GodMode = false
}

-- Загрузка настроек
pcall(function()
    if isfile and isfile(CONFIG_FILE) then
        local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
        for i,v in pairs(decoded) do Settings[i] = v end
    end
end)

local function SaveSettings()
    pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(Settings))
        end
    end)
end

--==================================================
-- УВЕДОМЛЕНИЯ (NOTIFICATIONS)
--==================================================
local NotifyGui = Instance.new("ScreenGui", game.CoreGui)
local NotifyContainer = Instance.new("Frame", NotifyGui)
NotifyContainer.Size = UDim2.new(0, 250, 1, 0)
NotifyContainer.Position = UDim2.new(1, -260, 0, 0)
NotifyContainer.BackgroundTransparency = 1
local UIList = Instance.new("UIListLayout", NotifyContainer)
UIList.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIList.Padding = UDim.new(0, 10)

local function Notify(title, text, color)
    local frame = Instance.new("Frame", NotifyContainer)
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1
    
    local line = Instance.new("Frame", frame)
    line.Size = UDim2.new(0, 4, 1, 0)
    line.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    line.BorderSizePixel = 0

    local t = Instance.new("TextLabel", frame)
    t.Size = UDim2.new(1, -10, 0.5, 0)
    t.Position = UDim2.new(0, 10, 0, 5)
    t.Text = title
    t.Font = Enum.Font.GothamBold
    t.TextColor3 = color
    t.TextSize = 14
    t.BackgroundTransparency = 1
    t.TextXAlignment = Enum.TextXAlignment.Left

    local d = Instance.new("TextLabel", frame)
    d.Size = UDim2.new(1, -10, 0.5, 0)
    d.Position = UDim2.new(0, 10, 0.5, 0)
    d.Text = text
    d.Font = Enum.Font.Gotham
    d.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    d.TextSize = 12
    d.BackgroundTransparency = 1
    d.TextXAlignment = Enum.TextXAlignment.Left

    Instance.new("UICorner", frame)
    
    TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 0.1}):Play()
    task.delay(4, function()
        local tw = TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        tw:Play()
        tw.Completed:Connect(function() frame:Destroy() end)
    end)
end

--==================================================
-- ROLE LOGIC & ELITE FUNCTIONS
--==================================================
local function GetRole(p)
    if not p or not p:FindFirstChild("Backpack") then return "Innocent" end
    if p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife")) then return "Murderer" end
    if p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun")) then return "Sheriff" end
    return "Innocent"
end

-- 1. SILENT AIM (Для Шерифа)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "FireServer" and self.Name == "ShootGun" and Settings.SilentAim then
        for _, v in pairs(Players:GetPlayers()) do
            if GetRole(v) == "Murderer" and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                args[1] = v.Character.HumanoidRootPart.Position
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- 2. KILL AURA, AUTO-GRAB, AUTO-COLLECT, GOD MODE
RunService.Stepped:Connect(function()
    -- God Mode (Удаление Kill-пакета)
    if Settings.GodMode and LP.Character then
        pcall(function()
            if LP.Character:FindFirstChild("KillScript") then LP.Character.KillScript:Destroy() end
        end)
    end

    -- Kill Aura
    if Settings.KillAura and GetRole(LP) == "Murderer" then
        local knife = LP.Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
        if knife and knife:IsA("Tool") then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (LP.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 15 then
                        firetouchinterest(v.Character.HumanoidRootPart, knife.Handle, 0)
                        firetouchinterest(v.Character.HumanoidRootPart, knife.Handle, 1)
                    end
                end
            end
        end
    end

    -- Auto Grab Gun
    if Settings.AutoGrab then
        local gun = workspace:FindFirstChild("GunDrop")
        if gun and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = gun.CFrame
        end
    end

    -- Auto Collect Coins
    if Settings.AutoCollect and LP.Character then
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "CoinContainer" then
                for _, coin in pairs(v:GetChildren()) do
                    if coin:IsA("BasePart") then
                        coin.CFrame = LP.Character.HumanoidRootPart.CFrame
                    end
                end
            end
        end
    end
end)

--==================================================
-- СТАРЫЕ ФУНКЦИИ (БЕЗ ИЗМЕНЕНИЙ)
--==================================================
local KnownMurderer = nil
local KnownSheriff = nil

RunService.Heartbeat:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local role = GetRole(p)
        if role == "Murderer" and KnownMurderer ~= p then
            KnownMurderer = p
            Notify("MURDERER FOUND", p.DisplayName .. " is the Murderer!", Color3.fromRGB(255, 50, 50))
        elseif role == "Sheriff" and KnownSheriff ~= p then
            KnownSheriff = p
            Notify("SHERIFF FOUND", p.DisplayName .. " has the Gun!", Color3.fromRGB(50, 150, 255))
        end
    end
    if KnownSheriff and (not KnownSheriff.Character or not KnownSheriff.Character:FindFirstChild("Humanoid") or KnownSheriff.Character.Humanoid.Health <= 0) then
        Notify("SHERIFF DIED", "The gun is dropped!", Color3.fromRGB(255, 200, 50))
        KnownSheriff = nil
    end
end)

local ESP = {}
local function AddESP(p)
    if p == LP then return end
    local box = Drawing.new("Square"); box.Thickness = 2; box.Filled = false
    local text = Drawing.new("Text"); text.Size = 13; text.Center = true; text.Outline = true
    local tracer = Drawing.new("Line"); tracer.Thickness = 1
    ESP[p] = {Box=box, Text=text, Tracer=tracer}
end
local function RemoveESP(p) if ESP[p] then for _,v in pairs(ESP[p]) do v:Remove() end ESP[p] = nil end end
for _,p in ipairs(Players:GetPlayers()) do AddESP(p) end
Players.PlayerAdded:Connect(AddESP); Players.PlayerRemoving:Connect(RemoveESP)

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
                local color = role=="Murderer" and Color3.fromRGB(255,0,0) or role=="Sheriff" and Color3.fromRGB(0,120,255) or Color3.fromRGB(0,255,0)
                local size = Vector2.new(2000/pos.Z, 3000/pos.Z)
                e.Box.Size = size; e.Box.Position = Vector2.new(pos.X,pos.Y) - size/2; e.Box.Color = color; e.Box.Visible = true
                local dist = math.floor((LP.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                e.Text.Text = p.Name.." ["..role.."] ("..dist.."m)"; e.Text.Position = Vector2.new(pos.X,pos.Y-size.Y/2-14); e.Text.Color = color; e.Text.Visible = true
                if Settings.Tracers then
                    e.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); e.Tracer.To = Vector2.new(pos.X,pos.Y); e.Tracer.Color = color; e.Tracer.Visible = true
                else e.Tracer.Visible = false end
            else e.Box.Visible=false; e.Text.Visible=false; e.Tracer.Visible=false end
        else e.Box.Visible=false; e.Text.Visible=false; e.Tracer.Visible=false end
    end
end)

local FlyBV, FlyBG
RunService.RenderStepped:Connect(function()
    if Settings.Fly and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        if not FlyBV then
            FlyBV = Instance.new("BodyVelocity"); FlyBV.MaxForce = Vector3.new(1e9,1e9,1e9); FlyBV.Parent = hrp
            FlyBG = Instance.new("BodyGyro"); FlyBG.MaxTorque = Vector3.new(1e9,1e9,1e9); FlyBG.Parent = hrp
        end
        FlyBG.CFrame = Camera.CFrame
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        FlyBV.Velocity = move * Settings.FlySpeed
    else
        if FlyBV then FlyBV:Destroy() FlyBV=nil end
        if FlyBG then FlyBG:Destroy() FlyBG=nil end
    end
end)

RunService.Stepped:Connect(function()
    if Settings.Noclip and LP.Character then
        for _,v in ipairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

local lastTP = 0
local TP_COOLDOWN = 0.6
local function TeleportTo(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
    end
end
local function HuntTeleport()
    if tick() - lastTP < TP_COOLDOWN then return end
    lastTP = tick()
    if GetRole(LP) ~= "Murderer" then Notify("ERROR", "Only Murderer can use Hunt!", Color3.new(1,0,0)) return end
    local myPos = LP.Character.HumanoidRootPart.Position
    local nearest, dist = nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local d = (myPos - hrp.Position).Magnitude
                if d < dist then dist = d; nearest = p end
            end
        end
    end
    if nearest then TeleportTo(nearest) end
end

--==================================================
-- NEW MODERN GUI V3
--==================================================
local function CreateModernGUI()
    local MainGui = Instance.new("ScreenGui", game.CoreGui)
    local MainFrame = Instance.new("Frame", MainGui)
    MainFrame.Size = UDim2.new(0, 480, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true; MainFrame.Draggable = true
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = Color3.fromRGB(60, 60, 70); Stroke.Thickness = 2

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 130, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

    local Container = Instance.new("Frame", MainFrame)
    Container.Position = UDim2.new(0, 140, 0, 10)
    Container.Size = UDim2.new(1, -150, 1, -20)
    Container.BackgroundTransparency = 1

    local Tabs = {
        Visuals = Instance.new("Frame", Container),
        Combat = Instance.new("Frame", Container),
        Movement = Instance.new("Frame", Container),
        Farm = Instance.new("Frame", Container)
    }

    for _, f in pairs(Tabs) do 
        f.Size = UDim2.new(1, 0, 1, 0); f.Visible = false; f.BackgroundTransparency = 1
        local layout = Instance.new("UIListLayout", f); layout.Padding = UDim.new(0, 8)
    end
    Tabs.Visuals.Visible = true

    local function CreateTabButton(name, y, frame)
        local b = Instance.new("TextButton", Sidebar)
        b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
        b.Text = name; b.Font = Enum.Font.GothamSemibold; b.TextColor3 = Color3.new(0.7, 0.7, 0.7)
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 45); b.BorderSizePixel = 0; Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function()
            for _, f in pairs(Tabs) do f.Visible = false end
            frame.Visible = true
        end)
    end

    CreateTabButton("VISUALS", 50, Tabs.Visuals)
    CreateTabButton("COMBAT", 90, Tabs.Combat)
    CreateTabButton("MOVE", 130, Tabs.Movement)
    CreateTabButton("FARM", 170, Tabs.Farm)

    local function Toggle(name, parent, var, cb)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = Settings[var] and Color3.fromRGB(50, 150, 100) or Color3.fromRGB(45, 45, 50)
        btn.Text = name; btn.Font = Enum.Font.GothamSemibold; btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BorderSizePixel = 0; Instance.new("UICorner", btn)

        btn.MouseButton1Click:Connect(function()
            Settings[var] = not Settings[var]
            if cb then cb(Settings[var]) end
            btn.BackgroundColor3 = Settings[var] and Color3.fromRGB(50, 150, 100) or Color3.fromRGB(45, 45, 50)
            SaveSettings()
        end)
    end

    -- Visuals
    Toggle("ESP BOX", Tabs.Visuals, "ESP")
    Toggle("TRACERS", Tabs.Visuals, "Tracers")
    
    -- Combat
    Toggle("SILENT AIM", Tabs.Combat, "SilentAim")
    Toggle("KILL AURA", Tabs.Combat, "KillAura")
    Toggle("GOD MODE", Tabs.Combat, "GodMode")
    Toggle("HUNT TP (NEAREST)", Tabs.Combat, "tp_none", function() HuntTeleport() end)

    -- Movement
    Toggle("FLY", Tabs.Movement, "Fly")
    Toggle("NOCLIP", Tabs.Movement, "Noclip")

    -- Farm
    Toggle("AUTO COLLECT COINS", Tabs.Farm, "AutoCollect")
    Toggle("AUTO GRAB GUN", Tabs.Farm, "AutoGrab")

    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then MainFrame.Visible = not MainFrame.Visible end
    end)
    Notify("FONDI MM2 V3", "Press Insert to hide GUI", Color3.new(1,1,1))
end

--==================================================
-- START SYSTEM
--==================================================
if HasKey() then
    CreateModernGUI()
else
    local g = Instance.new("ScreenGui", game.CoreGui)
    local main = Instance.new("Frame", g)
    main.Size = UDim2.new(0, 300, 0, 150)
    main.Position = UDim2.new(0.5, -150, 0.4, 0)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", main)
    local box = Instance.new("TextBox", main)
    box.Size = UDim2.new(0.8, 0, 0, 40); box.Position = UDim2.new(0.1, 0, 0.4, 0)
    box.PlaceholderText = "ENTER KEY"; box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40); box.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function()
        if box.Text == KEY then SaveKey(); g:Destroy(); CreateModernGUI()
        else box.Text = ""; box.PlaceholderText = "WRONG KEY" end
    end)
end
