-- =====================================
-- FONDI MM2 SCRIPT (MAIN.LUA)
-- Version 1.1
-- =====================================

local VERSION = "1.1"
print("FONDI MM2 loaded | Version "..VERSION)

-- ===== SERVICES =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ===== KEY SYSTEM =====
local ValidKeys = {"FONDI-MM2-FOREVER-9X7Q"}
local KeyAccepted = false

pcall(function()
    local saved = LocalPlayer:GetAttribute("FONDI_MM2_KEY")
    if saved and table.find(ValidKeys, saved) then
        KeyAccepted = true
    end
end)

local function CheckKey(k)
    return table.find(ValidKeys, k) ~= nil
end

local function SaveKey(k)
    pcall(function()
        LocalPlayer:SetAttribute("FONDI_MM2_KEY", k)
    end)
end

local function CreateKeyUI(onSuccess)
    if KeyAccepted then onSuccess() return end

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
    title.TextSize = 22
    title.TextColor3 = Color3.new(1,1,1)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.fromScale(0.85,0.25)
    box.Position = UDim2.fromScale(0.075,0.35)
    box.PlaceholderText = "Enter Key"
    box.Font = Enum.Font.Gotham
    box.TextSize = 18
    box.TextColor3 = Color3.new(1,1,1)
    box.BackgroundColor3 = Color3.fromRGB(30,30,30)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.fromScale(0.85,0.22)
    btn.Position = UDim2.fromScale(0.075,0.68)
    btn.Text = "UNLOCK"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)

    btn.MouseButton1Click:Connect(function()
        if CheckKey(box.Text) then
            SaveKey(box.Text)
            KeyAccepted = true
            gui:Destroy()
            onSuccess()
        else
            box.Text = ""
            box.PlaceholderText = "INVALID KEY"
        end
    end)
end

-- ===== SETTINGS =====
local Settings = {
    ESP = true,
    MurdererOnly = false,
    Tracers = true,
    AimAssist = false
}

-- ===== ROLE =====
local function getRole(p)
    local c = p.Character
    if not c then return "Innocent" end
    if c:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife") then return "Murderer" end
    if c:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun") then return "Sheriff" end
    return "Innocent"
end

-- ===== GUI =====
local function CreateMainGUI()
    local gui = Instance.new("ScreenGui", game.CoreGui)

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.24,0.85)
    frame.Position = UDim2.fromScale(0.38,0.32)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Active = true
    frame.Draggable = true

    -- HEADER (НЕ МЕНЯЕТСЯ)
    local header = Instance.new("Frame", frame)
    header.Size = UDim2.fromScale(1,0.1)
    header.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.fromScale(0.85,1)
    title.BackgroundTransparency = 1
    title.Text = "MM2 | FONDI"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextColor3 = Color3.new(1,1,1)
    title.TextXAlignment = Enum.TextXAlignment.Left

    local arrow = Instance.new("TextButton", header)
    arrow.Size = UDim2.fromScale(0.15,1)
    arrow.Position = UDim2.fromScale(0.85,0)
    arrow.Text = "▼"
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 22
    arrow.TextColor3 = Color3.new(1,1,1)

    -- CONTENT
    local content = Instance.new("Frame", frame)
    content.Position = UDim2.fromScale(0,0.1)
    content.Size = UDim2.fromScale(1,0.9)
    content.BackgroundTransparency = 1

    local function makeButton(txt,y,cb)
        local b = Instance.new("TextButton", content)
        b.Position = UDim2.fromScale(0.1,y)
        b.Size = UDim2.fromScale(0.8,0.08)
        b.Text = txt
        b.Font = Enum.Font.Gotham
        b.TextSize = 18
        b.TextColor3 = Color3.new(1,1,1)
        b.BackgroundColor3 = Color3.fromRGB(35,35,35)
        b.MouseButton1Click:Connect(cb)
    end

    makeButton("ESP",0.05,function() Settings.ESP = not Settings.ESP end)
    makeButton("MURDERER ONLY",0.15,function() Settings.MurdererOnly = not Settings.MurdererOnly end)
    makeButton("TRACERS",0.25,function() Settings.Tracers = not Settings.Tracers end)
    makeButton("AIM ASSIST",0.35,function() Settings.AimAssist = not Settings.AimAssist end)

    -- ===== COLLAPSE WITH ANIMATION =====
    local collapsed = false
    local openSize = UDim2.fromScale(0.24,0.85)
    local closedSize = UDim2.fromScale(0.24,0.1)

    arrow.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        arrow.Text = collapsed and "▲" or "▼"

        local tween = TweenService:Create(
            frame,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = collapsed and closedSize or openSize}
        )
        tween:Play()

        if collapsed then
            task.delay(0.25,function()
                content.Visible = false
            end)
        else
            content.Visible = true
        end
    end)
end

-- ===== START =====
CreateKeyUI(CreateMainGUI)
