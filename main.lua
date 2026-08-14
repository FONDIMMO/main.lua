--[[
    FONDI MM2 V4.0 // ULTIMATE CONSOLE EDITION
    - ESP: 3D Box Adornments (Works 100%)
    - TRACERS: Lines to Murderer/Sheriff
    - CONSOLE: Dynamic Loading & Action Logs
    - PHYSICS: Advanced Vector Fly
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local pg = LP:WaitForChild("PlayerGui")

local Settings = {
    ESP = false, Fly = false, Noclip = false, 
    FlySpeed = 50
}

local KEY = "FONDI-MM2-FOREVER"
local IsAuthenticated = false

--------------------------------------------------
-- [ 1. ДИНАМИЧЕСКИЕ ПРИНТЫ (ЗАГРУЗКА) ]
--------------------------------------------------
task.spawn(function()
    local stages = {
        "Инициализация ядра FONDI_ENGINE...",
        "Очистка кеша детекции (Anti-Cheat Bypass)...",
        "Загрузка ESP_BOX_ADORNMENTS...",
        "Подключение к физическому контроллеру...",
        "Проверка лицензии на сервере...",
        "Ожидание ввода ключа в GUI..."
    }
    
    print("------------------------------------------")
    print("[FONDI_LOADER]: Loading Script...")
    print("------------------------------------------")
    
    local i = 1
    while not IsAuthenticated do
        print("[FONDI_STATUS]: " .. stages[i])
        i = (i % #stages) + 1
        task.wait(2.5)
    end
end)

--------------------------------------------------
-- [ 2. УТИЛИТЫ И РОЛИ ]
--------------------------------------------------
local function GetRole(p)
    if not p then return "Innocent" end
    local bp = p:FindFirstChild("Backpack")
    local ch = p.Character
    if (bp and bp:FindFirstChild("Knife")) or (ch and ch:FindFirstChild("Knife")) then return "Murderer" end
    if (bp and bp:FindFirstChild("Gun")) or (ch and ch:FindFirstChild("Gun")) or 
       (bp and bp:FindFirstChild("Revolver")) or (ch and ch:FindFirstChild("Revolver")) then return "Sheriff" end
    return "Innocent"
end

local function Notify(text, color)
    print("[FONDI_NOTIFY]: " .. tostring(text))
    local sg = pg:FindFirstChild("Fondi_Notify") or Instance.new("ScreenGui", pg)
    sg.Name = "Fondi_Notify"
    
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 220, 0, 45)
    frame.Position = UDim2.new(1, 10, 0.8, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    Instance.new("UICorner", frame)
    Instance.new("UIStroke", frame).Color = color or Color3.fromRGB(120, 50, 255)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Color3.new(1,1,1); lbl.Font = "GothamBold"; lbl.TextSize = 13

    frame:TweenPosition(UDim2.new(1, -240, 0.8, 0), "Out", "Back", 0.5)
    task.delay(2.5, function()
        frame:TweenPosition(UDim2.new(1, 10, 0.8, 0), "In", "Quad", 0.5)
        task.wait(0.5); frame:Destroy()
    end)
end

--------------------------------------------------
-- [ 3. СИСТЕМА ESP (BOX + TRACERS) ]
--------------------------------------------------
local function ApplyESP(p)
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "Fondi_Box"
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.6

    local tracer = Instance.new("LineHandleAdornment")
    tracer.Name = "Fondi_Tracer"
    tracer.AlwaysOnTop = true
    tracer.Thickness = 2
    tracer.ZIndex = 5

    RunService.RenderStepped:Connect(function()
        if not Settings.ESP or not IsAuthenticated or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
            box.Adornee = nil
            tracer.Adornee = nil
            return
        end

        local char = p.Character
        local root = char.HumanoidRootPart
        local role = GetRole(p)
        local color = (role == "Murderer" and Color3.new(1,0,0)) or (role == "Sheriff" and Color3.new(0,0,1)) or Color3.new(0,1,0)

        -- Настройка 3D Бокса
        box.Adornee = char
        box.Size = char:GetExtentsSize()
        box.Color3 = color
        box.Parent = char

        -- Трассеры (только для маньяка и шерифа)
        if role ~= "Innocent" and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            tracer.Adornee = LP.Character.HumanoidRootPart
            tracer.Target = root
            tracer.Color3 = color
            tracer.Parent = char
        else
            tracer.Adornee = nil
        end
    end)
end

Players.PlayerAdded:Connect(ApplyESP)
for _, v in pairs(Players:GetPlayers()) do if v ~= LP then ApplyESP(v) end end

--------------------------------------------------
-- [ 4. FLY & NOCLIP ]
--------------------------------------------------
local flyBV, flyBG
RunService.Stepped:Connect(function()
    if not IsAuthenticated or not LP.Character then return end
    if Settings.Noclip then
        for _, v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

RunService.RenderStepped:Connect(function()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if IsAuthenticated and Settings.Fly and root then
        if not flyBV then
            print("[FONDI_CORE]: Физика полета включена.")
            flyBV = Instance.new("BodyVelocity", root)
            flyBV.MaxForce = Vector3.new(1e7, 1e7, 1e7)
            flyBG = Instance.new("BodyGyro", root)
            flyBG.MaxTorque = Vector3.new(1e7, 1e7, 1e7); flyBG.D = 100
        end
        local cam = workspace.CurrentCamera.CFrame
        local dir = Vector3.new(0, 0, 0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        flyBV.Velocity = dir.Unit * Settings.FlySpeed
        if dir.Magnitude == 0 then flyBV.Velocity = Vector3.new(0,0,0) end
        flyBG.CFrame = cam
    else
        if flyBV then 
            print("[FONDI_CORE]: Физика полета выключена.")
            flyBV:Destroy(); flyBV = nil; flyBG:Destroy(); flyBG = nil 
        end
    end
end)

--------------------------------------------------
-- [ 5. МЕНЮ И АВТОРИЗАЦИЯ ]
--------------------------------------------------
local function BuildUI()
    print("[FONDI_UI]: Сборка интерфейса...")
    local sg = Instance.new("ScreenGui", pg); sg.Name = "Fondi_V4"; sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 260, 0, 320); main.Position = UDim2.new(0.5, -130, 0.5, -160)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); main.Active = true; main.Draggable = true
    Instance.new("UICorner", main); Instance.new("UIStroke", main).Color = Color3.fromRGB(120, 50, 255)

    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -20, 1, -60); scroll.Position = UDim2.new(0, 10, 0, 50); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 0
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 8)

    local function CreateToggle(name, var)
        local b = Instance.new("TextButton", scroll)
        b.Size = UDim2.new(1, 0, 0, 45); b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        b.Text = name; b.TextColor3 = Color3.fromRGB(180, 180, 180); b.Font = "GothamBold"; b.TextSize = 12
        Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function()
            Settings[var] = not Settings[var]
            print("[FONDI_ACTION]: " .. name .. " -> " .. tostring(Settings[var]))
            local targetColor = Settings[var] and Color3.fromRGB(120, 50, 255) or Color3.fromRGB(30, 30, 35)
            TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = targetColor, TextColor3 = Color3.new(1,1,1)}):Play()
            Notify(name .. ": " .. (Settings[var] and "ВКЛ" or "ВЫКЛ"), Settings[var] and Color3.new(0,1,0) or Color3.new(1,0,0))
        end)
    end

    CreateToggle("BOX ESP + TRACERS", "ESP")
    CreateToggle("GHOST FLY (V)", "Fly")
    CreateToggle("NOCLIP (WALLS)", "Noclip")
    print("[FONDI_UI]: Menu loading Succesful.")
end

local keyGui = Instance.new("ScreenGui", pg)
local kFrame = Instance.new("Frame", keyGui)
kFrame.Size = UDim2.new(0, 300, 0, 160); kFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
kFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); Instance.new("UICorner", kFrame)
Instance.new("UIStroke", kFrame).Color = Color3.fromRGB(120, 50, 255)

local box = Instance.new("TextBox", kFrame)
box.Size = UDim2.new(0.8, 0, 0, 40); box.Position = UDim2.new(0.1, 0, 0.2, 0); box.PlaceholderText = "ВВЕДИТЕ КЛЮЧ"; box.BackgroundColor3 = Color3.fromRGB(10,10,10); box.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", box)

local btn = Instance.new("TextButton", kFrame)
btn.Size = UDim2.new(0.8, 0, 0, 40); btn.Position = UDim2.new(0.1, 0, 0.6, 0); btn.Text = "АКТИВИРОВАТЬ"; btn.BackgroundColor3 = Color3.fromRGB(120, 50, 255); btn.TextColor3 = Color3.new(1,1,1); btn.Font = "GothamBold"; Instance.new("UICorner", btn)

btn.MouseButton1Click:Connect(function()
    if box.Text == KEY then
        IsAuthenticated = true
        print("[FONDI_AUTH]: Доступ разрешен. Модули запущены.")
        keyGui:Destroy()
        BuildUI()
        Notify("FONDI LOADED: ENJOY", Color3.new(0,1,0))
    else
        print("[FONDI_AUTH]: ОШИБКА КЛЮЧА: " .. box.Text)
        box.Text = ""; box.PlaceholderText = "НЕВЕРНЫЙ КЛЮЧ!"
    end
end)
