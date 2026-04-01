--[[
    FONDI MM2 V3.6 // ULTIMATE EDITION (REMASTERED)
    - NEW: Debug Console Prints (F9)
    - NEW: Smooth Notifications
    - NEW: Advanced Physics Fly
]]

print("------------------------------------------")
print("[FONDI_LOADER]: Инициализация скрипта...")
print("------------------------------------------")

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

-- [ СИСТЕМА УВЕДОМЛЕНИЙ ]
local function Notify(text, color)
    print("[FONDI_NOTIFY]: " .. tostring(text)) -- Дублируем уведомление в консоль
    
    local sg = pg:FindFirstChild("Fondi_Notify") or Instance.new("ScreenGui", pg)
    sg.Name = "Fondi_Notify"
    
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 220, 0, 45)
    frame.Position = UDim2.new(1, 10, 0.8, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = color or Color3.fromRGB(120, 50, 255)
    stroke.Thickness = 2

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = "GothamBold"
    lbl.TextSize = 13

    frame:TweenPosition(UDim2.new(1, -240, 0.8, 0), "Out", "Back", 0.5)
    task.delay(2.5, function()
        frame:TweenPosition(UDim2.new(1, 10, 0.8, 0), "In", "Quad", 0.5)
        task.wait(0.5)
        frame:Destroy()
    end)
end

-- [ ЛОГИКА ФУНКЦИЙ ]
RunService.Stepped:Connect(function()
    local char = LP.Character
    if not char then return end

    if Settings.Noclip then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- [ ADVANCED FLY ]
local flyBV, flyBG
RunService.RenderStepped:Connect(function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if Settings.Fly and root then
        if not flyBV then
            print("[FONDI_FLY]: Полет активирован")
            flyBV = Instance.new("BodyVelocity", root)
            flyBV.MaxForce = Vector3.new(1e7, 1e7, 1e7)
            flyBG = Instance.new("BodyGyro", root)
            flyBG.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
            flyBG.D = 100
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
            print("[FONDI_FLY]: Полет деактивирован")
            flyBV:Destroy(); flyBV = nil 
            flyBG:Destroy(); flyBG = nil 
        end
    end
end)

-- [ ИНТЕРФЕЙС ]
local function BuildUI()
    print("[FONDI_UI]: Создание интерфейса...")
    local sg = Instance.new("ScreenGui", pg); sg.Name = "Fondi_MM2_V3.6"; sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 280, 0, 360); main.Position = UDim2.new(0.5, -140, 0.5, -180)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); main.Active = true; main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)
    local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(120, 50, 255); stroke.Thickness = 2

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 50); title.Text = "FONDI MM2 V3.6"; title.TextColor3 = Color3.new(1,1,1)
    title.Font = "GothamBold"; title.TextSize = 18; title.BackgroundTransparency = 1

    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -20, 1, -70); scroll.Position = UDim2.new(0, 10, 0, 60)
    scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 0
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 8)

    local function CreateToggle(name, var)
        local b = Instance.new("TextButton", scroll)
        b.Size = UDim2.new(1, 0, 0, 45)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        b.Text = name; b.TextColor3 = Color3.fromRGB(180, 180, 180)
        b.Font = "GothamSemibold"; b.TextSize = 13
        Instance.new("UICorner", b)

        b.MouseButton1Click:Connect(function()
            Settings[var] = not Settings[var]
            local status = Settings[var] and "ON" or "OFF"
            
            print("[FONDI_CORE]: Функция " .. name .. " установлена в " .. status)
            
            local targetColor = Settings[var] and Color3.fromRGB(120, 50, 255) or Color3.fromRGB(30, 30, 35)
            local textColor = Settings[var] and Color3.new(1,1,1) or Color3.fromRGB(180, 180, 180)
            
            TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = targetColor, TextColor3 = textColor}):Play()
            Notify(name .. ": " .. status, Settings[var] and Color3.new(0,1,0) or Color3.new(1,0,0))
        end)
    end

    CreateToggle("PLAYER ESP", "ESP")
    CreateToggle("ADVANCED FLY", "Fly")
    CreateToggle("GHOST NOCLIP", "Noclip")
    CreateToggle("KILL AURA", "KillAura")
    CreateToggle("AUTO COINS", "AutoCollect")

    print("[FONDI_UI]: Интерфейс успешно собран.")
end

-- [ KEY SYSTEM ]
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
    print("[FONDI_AUTH]: Попытка активации ключом...")
    if box.Text == KEY then
        print("[FONDI_AUTH]: Ключ верный! Доступ разрешен.")
        keyGui:Destroy()
        BuildUI()
        Notify("SUCCESS: FONDI LOADED", Color3.new(0,1,0))
    else
        print("[FONDI_AUTH]: ОШИБКА: Неверный ключ: " .. tostring(box.Text))
        box.Text = ""; box.PlaceholderText = "INVALID KEY!"
        Notify("ERROR: WRONG KEY", Color3.new(1,0,0))
    end
end)

print("[FONDI_LOADER]: Скрипт готов к работе. Ожидание ввода ключа...")
