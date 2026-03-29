--[[
    FONDI MM2 V3.6 // ULTIMATE EDITION
    - FIX: ESP (Chams) now works 100%
    - FIX: Fly & Noclip (Smooth & Stable)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local pg = LP:WaitForChild("PlayerGui")

local Settings = {
    ESP = false, Fly = false, Noclip = false, 
    KillAura = false, AutoCollect = false, AutoGrab = false,
    FlySpeed = 50
}

local KEY = "FONDI-MM2-FOREVER"

-- Ждем загрузки персонажа
local function GetChar() return LP.Character or LP.CharacterAdded:Wait() end
local function GetRoot() return GetChar():WaitForChild("HumanoidRootPart") end

-- [ УТИЛИТЫ ]
local function GetRole(p)
    if not p or not p:FindFirstChild("Backpack") then return "Innocent" end
    local char = p.Character
    if p.Backpack:FindFirstChild("Knife") or (char and char:FindFirstChild("Knife")) then return "Murderer" end
    if p.Backpack:FindFirstChild("Gun") or (char and char:FindFirstChild("Gun")) then return "Sheriff" end
    return "Innocent"
end

--------------------------------------------------
-- [ 1. ЛОГИКА ФУНКЦИЙ ]
--------------------------------------------------

-- ESP, Noclip и Aura
RunService.Stepped:Connect(function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- ESP (Chams)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character then
            local highlight = v.Character:FindFirstChild("Fondi_ESP")
            if Settings.ESP then
                if not highlight then
                    highlight = Instance.new("Highlight", v.Character)
                    highlight.Name = "Fondi_ESP"
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                end
                local role = GetRole(v)
                highlight.FillColor = (role == "Murderer" and Color3.new(1,0,0)) or (role == "Sheriff" and Color3.new(0,0,1)) or Color3.new(0,1,0)
            else
                if highlight then highlight:Destroy() end
            end
        end
    end

    -- Noclip
    if Settings.Noclip then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    -- Kill Aura
    if Settings.KillAura and GetRole(LP) == "Murderer" then
        local knife = char:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
        if knife and knife:FindFirstChild("Handle") then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    if (root.Position - v.Character.HumanoidRootPart.Position).Magnitude < 18 then
                        knife.Parent = char
                        firetouchinterest(v.Character.HumanoidRootPart, knife.Handle, 0)
                        firetouchinterest(v.Character.HumanoidRootPart, knife.Handle, 1)
                    end
                end
            end
        end
    end

    -- Auto Collect
    if Settings.AutoCollect then
        local container = workspace:FindFirstChild("CoinContainer")
        if container then
            for _, coin in pairs(container:GetChildren()) do
                if coin:IsA("BasePart") then coin.CFrame = root.CFrame end
            end
        end
    end
end)

-- Fly System
local bv
RunService.RenderStepped:Connect(function()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if Settings.Fly and root then
        if not bv then
            bv = Instance.new("BodyVelocity", root)
            bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        end
        local newVel = Vector3.new(0, 0.1, 0)
        local cam = workspace.CurrentCamera.CFrame
        if UIS:IsKeyDown(Enum.KeyCode.W) then newVel = newVel + cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then newVel = newVel - cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then newVel = newVel - cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then newVel = newVel + cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then newVel = newVel + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then newVel = newVel - Vector3.new(0, 1, 0) end
        bv.Velocity = newVel.Unit * Settings.FlySpeed
    else
        if bv then bv:Destroy(); bv = nil end
    end
end)

--------------------------------------------------
-- [ 2. ИНТЕРФЕЙС ]
--------------------------------------------------

local function BuildUI()
    local sg = Instance.new("ScreenGui", pg); sg.Name = "Fondi_MM2_V3.6"; sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 320, 0, 400); main.Position = UDim2.new(0.5, -160, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(20, 10, 40); main.Draggable = true; main.Active = true
    Instance.new("UICorner", main); Instance.new("UIStroke", main).Color = Color3.fromRGB(120, 50, 255)

    -- Картинка (ID 11318961749)
    local imgHolder = Instance.new("Frame", main)
    imgHolder.Size = UDim2.new(0, 130, 0, 130); imgHolder.Position = UDim2.new(1, 10, 0, 0)
    imgHolder.BackgroundColor3 = Color3.fromRGB(20, 10, 40); Instance.new("UICorner", imgHolder)
    Instance.new("UIStroke", imgHolder).Color = Color3.fromRGB(120, 50, 255)
    
    local img = Instance.new("ImageLabel", imgHolder)
    img.Size = UDim2.new(1, 0, 1, 0); img.BackgroundTransparency = 1
    img.Image = "rbxassetid://11318961749"; img.ScaleType = Enum.ScaleType.Fit

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 50); title.Text = "FONDI MM2 V3.6"; title.TextColor3 = Color3.new(1,1,1)
    title.Font = "GothamBold"; title.TextSize = 18; title.BackgroundTransparency = 1

    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -20, 1, -70); scroll.Position = UDim2.new(0, 10, 0, 60)
    scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 0
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

    local function CreateToggle(name, var)
        local b = Instance.new("TextButton", scroll)
        b.Size = UDim2.new(1, 0, 0, 40)
        b.BackgroundColor3 = Settings[var] and Color3.fromRGB(120, 50, 255) or Color3.fromRGB(40, 40, 50)
        b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamSemibold"
        Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function()
            Settings[var] = not Settings[var]
            b.BackgroundColor3 = Settings[var] and Color3.fromRGB(120, 50, 255) or Color3.fromRGB(40, 40, 50)
        end)
    end

    CreateToggle("ESP (ALL PLAYERS)", "ESP")
    CreateToggle("FLY (WASD + SPACE)", "Fly")
    CreateToggle("NOCLIP", "Noclip")
    CreateToggle("KILL AURA", "KillAura")
    CreateToggle("AUTO COLLECT", "AutoCollect")
    CreateToggle("AUTO GRAB GUN", "AutoGrab")

    UIS.InputBegan:Connect(function(key, chat)
        if not chat and key.KeyCode == Enum.KeyCode.Insert then sg.Enabled = not sg.Enabled end
    end)
end

--------------------------------------------------
-- [ 3. KEY SYSTEM ]
--------------------------------------------------
local keyGui = Instance.new("ScreenGui", pg)
local kFrame = Instance.new("Frame", keyGui)
kFrame.Size = UDim2.new(0, 300, 0, 150); kFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
kFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", kFrame)

local box = Instance.new("TextBox", kFrame)
box.Size = UDim2.new(0.8, 0, 0, 40); box.Position = UDim2.new(0.1, 0, 0.25, 0)
box.PlaceholderText = "ENTER KEY"; box.Text = ""; box.BackgroundColor3 = Color3.fromRGB(30,30,30); box.TextColor3 = Color3.new(1,1,1)

local btn = Instance.new("TextButton", kFrame)
btn.Size = UDim2.new(0.8, 0, 0, 35); btn.Position = UDim2.new(0.1, 0, 0.6, 0)
btn.Text = "CHECK KEY"; btn.BackgroundColor3 = Color3.fromRGB(120, 50, 255); btn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", btn)

btn.MouseButton1Click:Connect(function()
    if box.Text == KEY then
        keyGui:Destroy()
        BuildUI()
    else
        box.Text = ""; box.PlaceholderText = "WRONG KEY!"
    end
end)
