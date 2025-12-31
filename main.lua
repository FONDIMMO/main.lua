-- =====================================
-- FONDI MM2 SCRIPT (MAIN.LUA)
-- Последняя версия: 1.0
-- =====================================

-- ===== VERSION =====
local VERSION = "1.0"
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

local function CheckKey(k) return table.find(ValidKeys, k) ~= nil end
local function SaveKey(k) pcall(function() LocalPlayer:SetAttribute("FONDI_MM2_KEY", k) end) end

local function Notify(text)
    local gui = Instance.new("ScreenGui", game.CoreGui)
    local lbl = Instance.new("TextLabel", gui)
    lbl.Size = UDim2.fromScale(0.3,0.08)
    lbl.Position = UDim2.fromScale(0.35,0.1)
    lbl.BackgroundTransparency = 1
    lbl.TextTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true
    lbl.TextColor3 = Color3.new(1,1,1)
    TweenService:Create(lbl, TweenInfo.new(0.4), {TextTransparency=0}):Play()
    task.delay(2,function()
        TweenService:Create(lbl, TweenInfo.new(0.4), {TextTransparency=1}):Play()
        task.delay(0.4,function() gui:Destroy() end)
    end)
end

local function CreateKeyUI(onSuccess)
    if KeyAccepted then onSuccess() return end
    local gui = Instance.new("ScreenGui", game.CoreGui)
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0,0)
    frame.Position = UDim2.fromScale(0.5,0.5)
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Active = true
    frame.Draggable = true
    TweenService:Create(frame, TweenInfo.new(0.4,Enum.EasingStyle.Back), {Size=UDim2.fromScale(0.32,0.22)}):Play()

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.fromScale(1,0.25)
    title.BackgroundTransparency = 1
    title.Text = "FONDI MM2 | KEY"
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.new(1,1,1)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.fromScale(0.85,0.25)
    box.Position = UDim2.fromScale(0.075,0.35)
    box.PlaceholderText = "Enter Key"
    box.Font = Enum.Font.Gotham
    box.TextScaled = true
    box.TextColor3 = Color3.new(1,1,1)
    box.BackgroundColor3 = Color3.fromRGB(30,30,30)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.fromScale(0.85,0.22)
    btn.Position = UDim2.fromScale(0.075,0.68)
    btn.Text = "UNLOCK"
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)

    btn.MouseButton1Click:Connect(function()
        if CheckKey(box.Text) then
            SaveKey(box.Text)
            KeyAccepted = true
            gui:Destroy()
            Notify("KEY ACCEPTED")
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
    AimAssist = false,
    AimFOV = 120
}

-- ===== ROLE =====
local function getRole(p)
    local c = p.Character
    if not c then return "Innocent" end
    if c:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife") then return "Murderer" end
    if c:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun") then return "Sheriff" end
    return "Innocent"
end

local function roleColor(r)
    if r=="Murderer" then return Color3.fromRGB(255,0,0)
    elseif r=="Sheriff" then return Color3.fromRGB(0,120,255)
    else return Color3.fromRGB(0,255,0) end
end

-- ===== ESP =====
local ESP = {}
local function createESP(p)
    if p==LocalPlayer then return end
    local box = Drawing.new("Square"); box.Thickness=2; box.Filled=false; box.Visible=false
    local txt = Drawing.new("Text"); txt.Size=13; txt.Center=true; txt.Outline=true; txt.Visible=false
    local tr = Drawing.new("Line"); tr.Thickness=1; tr.Visible=false
    ESP[p]={Box=box, Text=txt, Tracer=tr}
end
local function removeESP(p)
    if ESP[p] then for _,v in pairs(ESP[p]) do v:Remove() end ESP[p]=nil end
end

-- ===== AIM ASSIST =====
local function getClosestMurderer()
    local best,dist=nil,Settings.AimFOV
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and getRole(p)=="Murderer" then
            local c=p.Character
            local hrp=c and c:FindFirstChild("HumanoidRootPart")
            local hum=c and c:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health>0 then
                local pos,on=Camera:WorldToViewportPoint(hrp.Position)
                if on then
                    local d=(Vector2.new(pos.X,pos.Y)-UIS:GetMouseLocation()).Magnitude
                    if d<dist then dist=d best=hrp end
                end
            end
        end
    end
    return best
end

-- ===== MAIN LOOP =====
RunService.RenderStepped:Connect(function()
    if Settings.AimAssist then
        local t=getClosestMurderer()
        if t then Camera.CFrame=CFrame.new(Camera.CFrame.Position,t.Position) end
    end
    for p,e in pairs(ESP) do
        local c=p.Character
        local hrp=c and c:FindFirstChild("HumanoidRootPart")
        local hum=c and c:FindFirstChildOfClass("Humanoid")
        if Settings.ESP and hrp and hum and hum.Health>0 then
            local role=getRole(p)
            if Settings.MurdererOnly and role~="Murderer" then
                e.Box.Visible=false e.Text.Visible=false e.Tracer.Visible=false
            else
                local pos,on=Camera:WorldToViewportPoint(hrp.Position)
                if on then
                    local col=roleColor(role)
                    local scale=2000/pos.Z
                    local size=Vector2.new(scale,scale*1.5)
                    e.Box.Size=size
                    e.Box.Position=Vector2.new(pos.X-size.X/2,pos.Y-size.Y/2)
                    e.Box.Color=col
                    e.Box.Visible=true
                    e.Text.Text=p.Name.." ["..role.."]"
                    e.Text.Position=Vector2.new(pos.X,pos.Y-size.Y/2-14)
                    e.Text.Color=col
                    e.Text.Visible=true
                    if Settings.Tracers then
                        e.Tracer.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
                        e.Tracer.To=Vector2.new(pos.X,pos.Y)
                        e.Tracer.Color=col
                        e.Tracer.Visible=true
                    else e.Tracer.Visible=false end
                else e.Box.Visible=false e.Text.Visible=false e.Tracer.Visible=false end
            end
        else
            e.Box.Visible=false e.Text.Visible=false e.Tracer.Visible=false
        end
    end
end)

for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

-- ===== GUI =====
local function CreateMainGUI()
    local gui=Instance.new("ScreenGui",game.CoreGui)
    local frame=Instance.new("Frame",gui)
    frame.Size=UDim2.fromScale(0.24,0.85)
    frame.Position=UDim2.fromScale(0.38,0.32)
    frame.BackgroundColor3=Color3.fromRGB(20,20,20)
    frame.Active=true
    frame.Draggable=true

    local header=Instance.new("Frame",frame)
    header.Size=UDim2.fromScale(1,0.1)
    header.BackgroundTransparency=1
    local title=Instance.new("TextLabel",header)
    title.Size=UDim2.fromScale(0.85,1)
    title.BackgroundTransparency=1
    title.Text="MM2 | FONDI"
    title.Font=Enum.Font.GothamBold
    title.TextScaled=true
    title.TextColor3=Color3.new(1,1,1)
    title.TextXAlignment=Enum.TextXAlignment.Left

    local arrow=Instance.new("TextButton",header)
    arrow.Size=UDim2.fromScale(0.15,1)
    arrow.Position=UDim2.fromScale(0.85,0)
    arrow.Text="▼"
    arrow.BackgroundTransparency=1
    arrow.Font=Enum.Font.GothamBold
    arrow.TextScaled=true
    arrow.TextColor3=Color3.new(1,1,1)

    local content=Instance.new("Frame",frame)
    content.Position=UDim2.fromScale(0,0.1)
    content.Size=UDim2.fromScale(1,0.9)
    content.BackgroundTransparency=1

    local function makeButton(txt,y,cb)
        local b=Instance.new("TextButton",content)
        b.Position=UDim2.fromScale(0.1,y)
        b.Size=UDim2.fromScale(0.8,0.08)
        b.Text=txt
        b.Font=Enum.Font.Gotham
        b.TextScaled=true
        b.TextColor3=Color3.new(1,1,1)
        b.BackgroundColor3=Color3.fromRGB(35,35,35)
        b.MouseButton1Click:Connect(cb)
    end

    makeButton("ESP",0.05,function() Settings.ESP=not Settings.ESP end)
    makeButton("MURDERER ONLY",0.15,function() Settings.MurdererOnly=not Settings.MurdererOnly end)
    makeButton("TRACERS",0.25,function() Settings.Tracers=not Settings.Tracers end)
    makeButton("AIM ASSIST",0.35,function() Settings.AimAssist=not Settings.AimAssist end)

    -- TELEPORT ONLY
    makeButton("TELEPORT",0.45,function()
        local tpGui=Instance.new("Frame",gui)
        tpGui.Size=UDim2.fromScale(0.24,0.4)
        tpGui.Position=UDim2.fromScale(0.38,0.38)
        tpGui.BackgroundColor3=Color3.fromRGB(20,20,20)
        tpGui.Active=true
        tpGui.Draggable=true

        local tpHeader=Instance.new("TextLabel",tpGui)
        tpHeader.Size=UDim2.fromScale(0.9,0.1)
        tpHeader.Position = UDim2.fromScale(0,0)
        tpHeader.BackgroundTransparency=1
        tpHeader.Text="Teleport To Player"
        tpHeader.Font=Enum.Font.GothamBold
        tpHeader.TextColor3=Color3.new(1,1,1)
        tpHeader.TextScaled=true

        local closeBtn = Instance.new("TextButton", tpGui)
        closeBtn.Size = UDim2.fromScale(0.1,0.1)
        closeBtn.Position = UDim2.fromScale(0.9,0)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
        closeBtn.Text = "X"
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextScaled = true
        closeBtn.TextColor3 = Color3.new(1,1,1)
        closeBtn.MouseButton1Click:Connect(function() tpGui:Destroy() end)

        local content=Instance.new("ScrollingFrame",tpGui)
        content.Size=UDim2.fromScale(1,0.9)
        content.Position=UDim2.fromScale(0,0.1)
        content.BackgroundTransparency=1
        content.CanvasSize=UDim2.new(0,0,0,0)
        content.ScrollBarThickness=8

        local function updatePlayers()
            content:ClearAllChildren()
            local y=0
            for _,p in pairs(Players:GetPlayers()) do
                if p~=LocalPlayer then
                    local b=Instance.new("TextButton",content)
                    b.Size=UDim2.fromScale(0.9,0.1)
                    b.Position=UDim2.fromScale(0.05,y)
                    b.BackgroundColor3=Color3.fromRGB(35,35,35)
                    b.Text=p.Name
                    b.Font=Enum.Font.Gotham
                    b.TextColor3=Color3.new(1,1,1)
                    b.TextScaled=true
                    b.MouseButton1Click:Connect(function()
                        local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0,3,0)
                        end
                    end)
                    y=y+0.12
                end
            end
            content.CanvasSize=UDim2.new(0,0,y,0)
        end
        updatePlayers()
        Players.PlayerAdded:Connect(updatePlayers)
        Players.PlayerRemoving:Connect(updatePlayers)
    end)

    -- COLLAPSE
    local collapsed=false
    arrow.MouseButton1Click:Connect(function()
        collapsed=not collapsed
        content.Visible=not collapsed
        frame.Size=collapsed and UDim2.fromScale(0.24,0.1) or UDim2.fromScale(0.24,0.85)
        arrow.Text=collapsed and "▲" or "▼"
    end)
end

-- ===== START SCRIPT =====
CreateKeyUI(CreateMainGUI)
