-- =====================================
-- FONDI MM2 SCRIPT (MAIN.LUA)
-- Version 1.2 FIXED
-- =====================================

local VERSION = "1.2"
print("FONDI MM2 loaded | Version "..VERSION)

-- ===== SERVICES =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
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
        if table.find(ValidKeys, box.Text) then
            LocalPlayer:SetAttribute("FONDI_MM2_KEY", box.Text)
            gui:Destroy()
            onSuccess()
        else
            box.Text = ""
            box.PlaceholderText = "INVALID KEY"
        end
    end)
end

-- ===== ROLE DETECTION (FIXED WH) =====
local function getRole(player)
    if player.Backpack:FindFirstChild("Knife") or
       (player.Character and player.Character:FindFirstChild("Knife")) then
        return "Murderer"
    end
    if player.Backpack:FindFirstChild("Gun") or
       (player.Character and player.Character:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

local function roleColor(role)
    if role == "Murderer" then
        return Color3.fromRGB(255,0,0)
    elseif role == "Sheriff" then
        return Color3.fromRGB(0,140,255)
    else
        return Color3.fromRGB(0,255,0)
    end
end

-- ===== ESP (WH FIXED) =====
local ESP = {}

local function createESP(player)
    if player == LocalPlayer then return end
    ESP[player] = Drawing.new("Text")
    ESP[player].Center = true
    ESP[player].Outline = true
    ESP[player].Size = 14
end

local function removeESP(player)
    if ESP[player] then
        ESP[player]:Remove()
        ESP[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for player,txt in pairs(ESP) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp and hum and hum.Health > 0 then
            local pos,vis = Camera:WorldToViewportPoint(hrp.Position)
            if vis then
                local role = getRole(player)
                txt.Text = player.Name.." ["..role.."]"
                txt.Color = roleColor(role)
                txt.Position = Vector2.new(pos.X, pos.Y - 30)
                txt.Visible = true
            else
                txt.Visible = false
            end
        else
            txt.Visible = false
        end
    end
end)

for _,p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

-- ===== GUI =====
local function CreateMainGUI()
    local gui = Instance.new("ScreenGui", game.CoreGui)

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.24,0.7)
    frame.Position = UDim2.fromScale(0.38,0.25)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Active = true
    frame.Draggable = true

    local header = Instance.new("TextLabel", frame)
    header.Size = UDim2.fromScale(1,0.1)
    header.BackgroundTransparency = 1
    header.Text = "MM2 | FONDI"
    header.Font = Enum.Font.GothamBold
    header.TextSize = 22
    header.TextColor3 = Color3.new(1,1,1)

    -- TELEPORT BUTTON
    local tpBtn = Instance.new("TextButton", frame)
    tpBtn.Size = UDim2.fromScale(0.8,0.1)
    tpBtn.Position = UDim2.fromScale(0.1,0.15)
    tpBtn.Text = "TELEPORT"
    tpBtn.Font = Enum.Font.GothamBold
    tpBtn.TextSize = 18
    tpBtn.TextColor3 = Color3.new(1,1,1)
    tpBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)

    tpBtn.MouseButton1Click:Connect(function()
        local tpGui = Instance.new("Frame", gui)
        tpGui.Size = UDim2.fromScale(0.25,0.4)
        tpGui.Position = UDim2.fromScale(0.37,0.3)
        tpGui.BackgroundColor3 = Color3.fromRGB(20,20,20)
        tpGui.Active = true
        tpGui.Draggable = true

        local close = Instance.new("TextButton", tpGui)
        close.Size = UDim2.fromScale(0.15,0.1)
        close.Position = UDim2.fromScale(0.85,0)
        close.Text = "X"
        close.BackgroundColor3 = Color3.fromRGB(200,50,50)
        close.TextColor3 = Color3.new(1,1,1)
        close.MouseButton1Click:Connect(function()
            tpGui:Destroy()
        end)

        local list = Instance.new("ScrollingFrame", tpGui)
        list.Position = UDim2.fromScale(0,0.1)
        list.Size = UDim2.fromScale(1,0.9)
        list.CanvasSize = UDim2.new(0,0,0,0)
        list.ScrollBarThickness = 6

        local y = 0
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local b = Instance.new("TextButton", list)
                b.Size = UDim2.fromScale(0.9,0.12)
                b.Position = UDim2.fromScale(0.05,y)
                b.Text = p.Name
                b.Font = Enum.Font.Gotham
                b.TextSize = 16
                b.TextColor3 = Color3.new(1,1,1)
                b.BackgroundColor3 = Color3.fromRGB(35,35,35)

                b.MouseButton1Click:Connect(function()
                    local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    local my = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and my then
                        my.CFrame = hrp.CFrame + Vector3.new(0,3,0)
                    end
                end)

                y += 0.14
            end
        end
        list.CanvasSize = UDim2.new(0,0,y,0)
    end)
end

-- ===== START =====
CreateKeyUI(CreateMainGUI)
