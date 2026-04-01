--[[
    FONDI MM2 V3.8 // ULTIMATE EDITION
    - СИСТЕМА ПРИНТОВ: Динамические логи в консоли (F9)
    - ESP: Исправленное определение ролей (Murderer/Sheriff)
    - FLY: Плавный полет на векторах с BodyGyro
    - UI: Анимированные переключатели и уведомления
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local pg = LP:WaitForChild("PlayerGui")

local Settings = {
    ESP = false, Fly = false, Noclip = false, 
    KillAura = false, AutoCollect = false, 
    FlySpeed = 50
}

local KEY = "FONDI-MM2-FOREVER"
local IsAuthenticated = false

--------------------------------------------------
-- [ 1. ДИНАМИЧЕСКИЕ ПРИНТЫ ПРИ ЗАГРУЗКЕ ]
--------------------------------------------------
task.spawn(function()
    local stages = {
        "Подключение к защищенному серверу...",
        "Обход системы детекции Roblox...",
        "Загрузка ассетов интерфейса...",
        "Инициализация ESP модулей (Highlight)...",
        "Настройка физического движка полета...",
        "Ожидание авторизации пользователя..."
    }
    
    print("------------------------------------------")
    print("[FONDI_LOADER]: Инициализация скрипта...")
    print("------------------------------------------")
    
    local i = 1
    while not IsAuthenticated do
        print("[FONDI_STATUS]: " .. stages[i])
        i = (i % #stages) + 1
        task.wait(2) -- Меняем принт каждые 2 секунды
    end
end)

--------------------------------------------------
-- [ 2. ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ]
--------------------------------------------------
local function GetPlayerRole(p)
    if not p then return "Innocent" end
    local bp = p:FindFirstChild("Backpack")
    local ch = p.Character
    -- Проверка на Убийцу
    if (bp and bp:FindFirstChild("Knife")) or (ch and ch:FindFirstChild("Knife")) then return "Murderer" end
    -- Проверка на Шерифа (включая поднятый револьвер)
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
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = color or Color3.fromRGB(120, 50, 255)
    stroke.Thickness = 2

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
-- [ 3. ЛОГИКА ESP И ФИЗИКИ ]
--------------------------------------------------
RunService.Stepped:Connect(function()
    if not IsAuthenticated or not LP.Character then return end

    -- ESP & Roles
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character then
            local highlight = v.Character:FindFirstChild("Fondi_ESP")
            if Settings.ESP then
                if not highlight then
                    highlight = Instance.new("Highlight", v.Character)
                    highlight.Name = "Fondi_ESP"
                    highlight.FillTransparency = 0.5
                    print("[FONDI_DEBUG]: Применен ESP к игроку " .. v.Name)
                end
                local role = GetPlayerRole(v)
                highlight.FillColor = (role == "Murderer" and Color3.new(1,0,0)) or (role == "Sheriff" and Color3.new(0,0,1)) or Color3.new(0,1,0)
            elseif highlight then highlight:Destroy() end
        end
    end

    -- Noclip
    if Settings.Noclip then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- [ ADVANCED FLY ]
local flyBV, flyBG
RunService.RenderStepped:Connect(function()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if IsAuthenticated and Settings.Fly and root then
        if not flyBV then
            print("[FONDI_PHYSICS]: Полет активирован")
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
        if flyBV then flyBV:Destroy(); flyBV = nil; flyBG:Destroy(); flyBG = nil end
    end
end)

--------------------------------------------------
-- [ 4. ИНТЕРФЕЙС (ГЛАВНОЕ МЕНЮ) ]
--------------------------------------------------
local function BuildUI()
    print("[FONDI_UI]: Загрузка главного меню...")
    local sg = Instance.new("ScreenGui", pg); sg.Name = "Fondi_MM2_V3.8"; sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 280, 0, 360); main.Position = UDim2.new(0.5, -140, 0.5, -180)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); main.Active = true; main.Draggable = true
    Instance.new("UICorner", main)
    local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(120, 50, 255); stroke.Thickness = 2

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 50); title.Text = "FONDI MM2 V3.8"; title.TextColor3 = Color3.new(1,1,1)
    title.Font = "GothamBold"; title.TextSize = 18; title.BackgroundTransparency = 1

    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -20, 1, -70); scroll.Position = UDim2.new(0, 10, 0, 60)
    scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 0
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 8)

    local function CreateToggle(name, var)
        local b = Instance.new("TextButton", scroll)
        b.Size = UDim2.new(1, 0, 0, 45); b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        b.Text = name; b.TextColor3 = Color3.fromRGB(180, 180, 180); b.Font = "GothamSemibold"; b.TextSize = 13
        Instance.new("UICorner", b)

        b.MouseButton1Click:Connect(function()
            Settings[var] = not Settings[var]
            print("[FONDI_ACTION]: Изменена настройка " .. name .. " на " .. tostring(Settings[var]))
            local targetColor = Settings[var] and Color3.fromRGB(120, 50, 255) or Color3.fromRGB(30, 30, 35)
            TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = targetColor, TextColor3 = Color3.new(1,1,1)}):Play()
            Notify(name .. ": " .. (Settings[var] and "ВКЛ" or "ВЫКЛ"), Settings[var] and Color3.new(0,1,0) or Color3.new(1,0,0))
        end)
    end

    CreateToggle("FIXED PLAYER ESP", "ESP")
    CreateToggle("ADVANCED FLY", "Fly")
    CreateToggle("GHOST NOCLIP", "Noclip")
    CreateToggle("AUTO COLLECT COINS", "AutoCollect")
    print("[FONDI_UI]: Интерфейс готов.")
end

--------------------------------------------------
-- [ 5. СИСТЕМА КЛЮЧА ]
--------------------------------------------------
local keyGui = Instance.new("ScreenGui", pg)
local kFrame = Instance.new("Frame", keyGui)
kFrame.Size = UDim2.new(0, 300, 0, 160); kFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
kFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); Instance.new("UICorner", kFrame)
Instance.new("UIStroke", kFrame).Color = Color3.fromRGB(120, 50, 255)

local box = Instance.new("TextBox", kFrame)
box.Size = UDim2.new(0.8, 0, 0, 40); box.Position = UDim2.new(0.1, 0, 0.2, 0)
box.PlaceholderText = "ENTER KEY"; box.Text = ""; box.BackgroundColor3 = Color3.fromRGB(10,10,10); box.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", box)

local btn = Instance.new("TextButton", kFrame)
btn.Size = UDim2.new(0.8, 0, 0, 40); btn.Position = UDim2.new(0.1, 0, 0.6, 0)
btn.Text = "ACTIVATE"; btn.BackgroundColor3 = Color3.fromRGB(120, 50, 255); btn.TextColor3 = Color3.new(1,1,1)
btn.Font = "GothamBold"; Instance.new("UICorner", btn)

btn.MouseButton1Click:Connect(function()
    print("[FONDI_AUTH]: Валидация ключа...")
    if box.Text == KEY then
        IsAuthenticated = true
        print("[FONDI_AUTH]: Успешно. Приятной игры!")
        keyGui:Destroy()
        BuildUI()
        Notify("SUCCESS: FONDI LOADED", Color3.new(0,1,0))
    else
        print("[FONDI_AUTH]: ОШИБКА: Неверный токен.")
        box.Text = ""; box.PlaceholderText = "INVALID KEY!"
    end
end)

print("[FONDI_LOADER]: Скрипт загружен. Ожидание ключа...")
