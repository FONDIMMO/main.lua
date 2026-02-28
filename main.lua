--==================================================
-- FONDI MM2 V3.1 | FINAL VERSION
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

local function HasKey() return LP:GetAttribute(ATTR) == KEY end
local function SaveKey() LP:SetAttribute(ATTR, KEY) end

local Settings = {
    ESP = true, Tracers = true, Fly = false, Noclip = false, FlySpeed = 60,
    SilentAim = false, KillAura = false, AutoCollect = false, AutoGrab = false, GodMode = false
}

--==================================================
-- УВЕДОМЛЕНИЯ (NOTIFICATIONS)
--==================================================
local function Notify(title, text, color)
    local NotifyGui = game.CoreGui:FindFirstChild("FondiNotify") or Instance.new("ScreenGui", game.CoreGui)
    NotifyGui.Name = "FondiNotify"
    
    local frame = Instance.new("Frame", NotifyGui)
    frame.Size = UDim2.new(0, 250, 0, 60)
    frame.Position = UDim2.new(1, 0, 0.8, 0) -- Начальная позиция за экраном
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", frame)
    Instance.new("UIStroke", frame).Color = color or Color3.new(1,1,1)

    local t = Instance.new("TextLabel", frame)
    t.Size = UDim2.new(1, -10, 0.5, 0); t.Position = UDim2.new(0, 10, 0, 5)
    t.Text = title; t.Font = Enum.Font.GothamBold; t.TextColor3 = color; t.BackgroundTransparency = 1; t.TextXAlignment = 0

    local d = Instance.new("TextLabel", frame)
    d.Size = UDim2.new(1, -10, 0.5, 0); d.Position = UDim2.new(0, 10, 0.5, 0)
    d.Text = text; d.Font = Enum.Font.Gotham; d.TextColor3 = Color3.new(0.8,0.8,0.8); d.BackgroundTransparency = 1; d.TextXAlignment = 0

    frame:TweenPosition(UDim2.new(1, -260, 0.8, 0), "Out", "Quart", 0.5)
    task.delay(3, function()
        frame:TweenPosition(UDim2.new(1, 0, 0.8, 0), "In", "Quart", 0.5)
        task.wait(0.5)
        frame:Destroy()
    end)
end

--==================================================
-- ЛОГИКА ФУНКЦИЙ
--==================================================
local function GetRole(p)
    if not p or not p:FindFirstChild("Backpack") then return "Innocent" end
    if p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife")) then return "Murderer" end
    if p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun")) then return "Sheriff" end
    return "Innocent"
end

-- Основной цикл элитных функций
RunService.Stepped:Connect(function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Kill Aura (Murderer)
    if Settings.KillAura and GetRole(LP) == "Murderer" then
        pcall(function()
            local knife = LP.Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
            if knife then
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        if (LP.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude < 18 then
                            firetouchinterest(v.Character.HumanoidRootPart, knife.Handle, 0)
                            firetouchinterest(v.Character.HumanoidRootPart, knife.Handle, 1)
                        end
                    end
                end
            end
        end)
    end

    -- Auto Collect Coins
    if Settings.AutoCollect then
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "CoinContainer" or v.Name == "Coin" then
                    for _, c in pairs(v:GetChildren()) do
                        if c:IsA("BasePart") then c.CFrame = LP.Character.HumanoidRootPart.CFrame end
                    end
                end
            end
        end)
    end

    -- Noclip
    if Settings.Noclip then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

--==================================================
-- ИНТЕРФЕЙС
--==================================================
local function CreateEliteGUI()
    local MainGui = Instance.new("ScreenGui", game.CoreGui)
    local MainFrame = Instance.new("Frame", MainGui)
    MainFrame.Size = UDim2.new(0, 480, 0, 320); MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35); MainFrame.Active = true; MainFrame.Draggable = true
    Instance.new("UICorner", MainFrame)

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 130, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", Sidebar)

    local Container = Instance.new("Frame", MainFrame)
    Container.Position = UDim2.new(0, 140, 0, 10); Container.Size = UDim2.new(1, -150, 1, -20); Container.BackgroundTransparency = 1

    local Tabs = {
        Visuals = Instance.new("Frame", Container),
        Combat = Instance.new("Frame", Container),
        Farm = Instance.new("Frame", Container)
    }

    for name, f in pairs(Tabs) do 
        f.Size = UDim2.new(1, 0, 1, 0); f.Visible = (name == "Visuals"); f.BackgroundTransparency = 1
        Instance.new("UIListLayout", f).Padding = UDim.new(0, 8)
    end

    local function AddTab(name, y, frame)
        local b = Instance.new("TextButton", Sidebar)
        b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
        b.Text = name; b.Font = "GothamSemibold"; b.TextColor3 = Color3.new(0.8,0.8,0.8)
        b.BackgroundColor3 = Color3.fromRGB(40,40,45); Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do t.Visible = false end
            frame.Visible = true
        end)
    end

    AddTab("VISUALS", 50, Tabs.Visuals)
    AddTab("COMBAT", 90, Tabs.Combat)
    AddTab("FARM", 130, Tabs.Farm)

    local function Toggle(name, parent, var)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, 0, 0, 35); btn.Text = name; btn.Font = "GothamSemibold"; btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Settings[var] and Color3.fromRGB(50, 150, 100) or Color3.fromRGB(45, 45, 50)
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(function()
            Settings[var] = not Settings[var]
            btn.BackgroundColor3 = Settings[var] and Color3.fromRGB(50, 150, 100) or Color3.fromRGB(45, 45, 50)
        end)
    end

    Toggle("ESP BOX", Tabs.Visuals, "ESP")
    Toggle("TRACERS", Tabs.Visuals, "Tracers")
    Toggle("SILENT AIM", Tabs.Combat, "SilentAim")
    Toggle("KILL AURA", Tabs.Combat, "KillAura")
    Toggle("GOD MODE", Tabs.Combat, "GodMode")
    Toggle("AUTO COLLECT", Tabs.Farm, "AutoCollect")
    Toggle("AUTO GRAB GUN", Tabs.Farm, "AutoGrab")

    UIS.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.Insert then MainFrame.Visible = not MainFrame.Visible end end)
    Notify("FONDI V3.1", "Welcome! Press Insert to toggle.", Color3.new(0,1,0.5))
end

--==================================================
-- START (KEY SYSTEM CHECK)
--==================================================
if HasKey() then
    CreateEliteGUI()
else
    local g = Instance.new("ScreenGui", game.CoreGui)
    local f = Instance.new("Frame", g)
    f.Size = UDim2.new(0, 300, 0, 150); f.Position = UDim2.new(0.5, -150, 0.4, 0); f.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Instance.new("UICorner", f)
    
    local box = Instance.new("TextBox", f)
    box.Size = UDim2.new(0.8, 0, 0, 40); box.Position = UDim2.new(0.1, 0, 0.4, 0)
    box.PlaceholderText = "ENTER KEY"; box.Text = ""; box.BackgroundColor3 = Color3.fromRGB(35,35,35); box.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", box)

    box.FocusLost:Connect(function()
        if box.Text == KEY then
            SaveKey()
            g:Destroy()
            CreateEliteGUI()
        else
            box.Text = ""; box.PlaceholderText = "WRONG KEY"
        end
    end)
end
