--=====================================
-- FONDI MM2 | XENO SCRIPT
--=====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--=====================================
-- KEY SYSTEM
--=====================================

local VALID_KEYS = {
    "FONDI-MM2-FOREVER-9X7Q",
    -- сюда просто добавляешь новые ключи
}

local function hasKey()
    return LocalPlayer:GetAttribute("FONDI_KEY") ~= nil
end

local function isValidKey(key)
    for _,k in pairs(VALID_KEYS) do
        if k == key then
            return true
        end
    end
    return false
end

local function saveKey(key)
    LocalPlayer:SetAttribute("FONDI_KEY", key)
end

--=====================================
-- KEY UI
--=====================================

local function KeyUI(onSuccess)
    if hasKey() then
        onSuccess()
        return
    end

    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "FONDI_KEY_GUI"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.3,0.22)
    frame.Position = UDim2.fromScale(0.35,0.39)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Active = true
    frame.Draggable = true

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.fromScale(1,0.3)
    title.BackgroundTransparency = 1
    title.Text = "ENTER KEY"
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.new(1,1,1)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.fromScale(0.85,0.25)
    box.Position = UDim2.fromScale(0.075,0.35)
    box.PlaceholderText = "FONDI-XXXX-XXXX"
    box.Font = Enum.Font.Gotham
    box.TextScaled = true
    box.BackgroundColor3 = Color3.fromRGB(30,30,30)
    box.TextColor3 = Color3.new(1,1,1)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.fromScale(0.85,0.22)
    btn.Position = UDim2.fromScale(0.075,0.65)
    btn.Text = "UNLOCK"
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)

    btn.MouseButton1Click:Connect(function()
        if isValidKey(box.Text) then
            saveKey(box.Text)
            gui:Destroy()
            onSuccess()
        else
            box.Text = ""
            box.PlaceholderText = "INVALID KEY"
        end
    end)
end

--=====================================
-- SETTINGS
--=====================================

local Settings = {
    ESP = true,
    Tracers = true,
    AimAssist = false
}

--=====================================
-- ROLE DETECT (ALWAYS)
--=====================================

local function getRole(p)
    local c = p.Character
    if not c then return "Innocent" end
    if c:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife") then
        return "Murderer"
    end
    if c:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun") then
        return "Sheriff"
    end
    return "Innocent"
end

--=====================================
-- ESP
--=====================================

local ESP = {}

local function createESP(p)
    if p == LocalPlayer then return end
    local t = Drawing.new("Text")
    t.Size = 13
    t.Center = true
    t.Outline = true
    ESP[p] = t
end

local function removeESP(p)
    if ESP[p] then
        ESP[p]:Remove()
        ESP[p] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for p,txt in pairs(ESP) do
        local c = p.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp and Settings.ESP then
            local pos,on = Camera:WorldToViewportPoint(hrp.Position)
            if on then
                txt.Text = p.Name.." ["..getRole(p).."]"
                txt.Position = Vector2.new(pos.X,pos.Y-25)
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

--=====================================
-- GUI
--=====================================

local function MainGUI()
    local gui = Instance.new("ScreenGui", game.CoreGui)

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.24,0.3)
    frame.Position = UDim2.fromScale(0.38,0.35)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Active = true
    frame.Draggable = true

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.fromScale(1,0.25)
    title.BackgroundTransparency = 1
    title.Text = "MM2 | FONDI"
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.new(1,1,1)

    local function btn(text,y,cb)
        local b = Instance.new("TextButton", frame)
        b.Size = UDim2.fromScale(0.8,0.18)
        b.Position = UDim2.fromScale(0.1,y)
        b.Text = text
        b.Font = Enum.Font.Gotham
        b.TextScaled = true
        b.BackgroundColor3 = Color3.fromRGB(35,35,35)
        b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(cb)
    end

    btn("ESP",0.3,function() Settings.ESP = not Settings.ESP end)
    btn("TRACERS",0.52,function() Settings.Tracers = not Settings.Tracers end)
end

--=====================================
-- START
--=====================================

KeyUI(MainGUI)
