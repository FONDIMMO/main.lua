--==================================================
-- FONDI MM2 V3.2 | ПЕРЕЗАПУСК ЯДРА
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- Ждем персонажа
local Character = LP.Character or LP.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

local Settings = {
    ESP = false, Tracers = false, Fly = false, 
    Noclip = false, SilentAim = false, KillAura = false, 
    AutoCollect = false, AutoGrab = false, GodMode = false
}

local KEY = "FONDI-MM2-FOREVER"

-- [ УТИЛИТЫ ]
local function GetRole(p)
    if not p or not p:FindFirstChild("Backpack") then return "Innocent" end
    local char = p.Character
    if p.Backpack:FindFirstChild("Knife") or (char and char:FindFirstChild("Knife")) then return "Murderer" end
    if p.Backpack:FindFirstChild("Gun") or (char and char:FindFirstChild("Gun")) then return "Sheriff" end
    return "Innocent"
end

--==================================================
-- ЛОГИКА ФУНКЦИЙ (ИСПРАВЛЕНО)
--==================================================

-- Обновление ссылок на персонажа при смерти
LP.CharacterAdded:Connect(function(char)
    Character = char
    Root = char:WaitForChild("HumanoidRootPart")
end)

RunService.Heartbeat:Connect(function()
    if not Root then return end

    -- 1. KILL AURA (ИСПРАВЛЕНО: Теперь через прямой Touch)
    if Settings.KillAura and GetRole(LP) == "Murderer" then
        local knife = Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
        if knife and knife:FindFirstChild("Handle") then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = v.Character.HumanoidRootPart
                    if (Root.Position - targetRoot.Position).Magnitude < 18 then
                        -- Эмуляция удара
                        knife.Parent = Character
                        firetouchinterest(targetRoot, knife.Handle, 0)
                        firetouchinterest(targetRoot, knife.Handle, 1)
                    end
                end
            end
        end
    end

    -- 2. AUTO-COLLECT (ИСПРАВЛЕНО: Поиск по всем контейнерам)
    if Settings.AutoCollect then
        for _, v in pairs(workspace:GetDescendants()) do
            if (v.Name == "CoinVisual" or v.Name == "TouchInterest") and v.Parent then
                local coinPart = v.Parent
                if coinPart:IsA("BasePart") then
                    -- Телепортируем монету к себе (самый надежный метод)
                    coinPart.CFrame = Root.CFrame
                end
            end
        end
    end

    -- 3. AUTO-GRAB GUN (ИСПРАВЛЕНО: Поиск упавшего пистолета)
    if Settings.AutoGrab then
        local drop = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("Gun", true)
        if drop and drop:IsA("BasePart") then
            Root.CFrame = drop.CFrame
        end
    end

    -- 4. NOCLIP
    if Settings.Noclip then
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

--==================================================
-- ИНТЕРФЕЙС И КЛЮЧ
--==================================================

local function BuildUI()
    local sg = Instance.new("ScreenGui", game.CoreGui)
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 350, 0, 380)
    frame.Position = UDim2.new(0.5, -175, 0.5, -190)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.Active = true; frame.Draggable = true
    Instance.new("UICorner", frame)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 40); title.Text = "FONDI V3.2 [FIXED]"; title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1; title.Font = "GothamBold"

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -20, 1, -60); scroll.Position = UDim2.new(0, 10, 0, 50)
    scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,1.5,0)
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

    local function CreateToggle(name, var)
        local b = Instance.new("TextButton", scroll)
        b.Size = UDim2.new(1, 0, 0, 40)
        b.BackgroundColor3 = Settings[var] and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(40, 40, 40)
        b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamSemibold"
        Instance.new("UICorner", b)
        
        b.MouseButton1Click:Connect(function()
            Settings[var] = not Settings[var]
            b.BackgroundColor3 = Settings[var] and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(40, 40, 40)
        end)
    end

    CreateToggle("ESP BOXES", "ESP")
    CreateToggle("KILL AURA (KNIFE)", "KillAura")
    CreateToggle("AUTO COLLECT COINS", "AutoCollect")
    CreateToggle("AUTO GRAB GUN", "AutoGrab")
    CreateToggle("NOCLIP (WALK THRU WALLS)", "Noclip")
    CreateToggle("FLY", "Fly")

    -- Скрыть/Показать на Insert
    UIS.InputBegan:Connect(function(key)
        if key.KeyCode == Enum.KeyCode.Insert then sg.Enabled = not sg.Enabled end
    end)
end

-- СИСТЕМА КЛЮЧА
local keyGui = Instance.new("ScreenGui", game.CoreGui)
local kFrame = Instance.new("Frame", keyGui)
kFrame.Size = UDim2.new(0, 300, 0, 150); kFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
kFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", kFrame)

local box = Instance.new("TextBox", kFrame)
box.Size = UDim2.new(0.8, 0, 0, 40); box.Position = UDim2.new(0.1, 0, 0.3, 0)
box.PlaceholderText = "KEY: FONDI-MM2-FOREVER"; box.Text = ""; box.BackgroundColor3 = Color3.fromRGB(40,40,40); box.TextColor3 = Color3.new(1,1,1)

local btn = Instance.new("TextButton", kFrame)
btn.Size = UDim2.new(0.8, 0, 0, 35); btn.Position = UDim2.new(0.1, 0, 0.65, 0)
btn.Text = "CHECK KEY"; btn.BackgroundColor3 = Color3.fromRGB(0, 120, 200); btn.TextColor3 = Color3.new(1,1,1)

btn.MouseButton1Click:Connect(function()
    if box.Text == KEY then
        keyGui:Destroy()
        BuildUI()
    else
        box.Text = ""; box.PlaceholderText = "INVALID KEY"
    end
end)
