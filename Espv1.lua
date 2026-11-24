-- ==========================================
-- NullTalal Advanced ESP | Made By NullTalal
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Enabled = true,
    Box = true,
    Health = true,
    Name = true,
    Distance = true,
    ESPColor = Color3.fromRGB(0, 255, 204)
}

-- ==========================================
-- 1. إعدادات الرسم (Drawing Table)
-- ==========================================
local ESP_Objects = {}

local function createDrawings(player)
    local objects = {
        Box = Drawing.new("Square"),
        Health = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }
    
    -- إعدادات المربع (Box)
    objects.Box.Thickness = 1
    objects.Box.Filled = false
    
    -- إعدادات الصحة (Health)
    objects.Health.Thickness = 1
    objects.Health.Filled = true
    
    -- إعدادات الاسم (Name)
    objects.Name.Center = true
    objects.Name.Outline = true
    objects.Name.Size = 14
    objects.Name.Font = 2 -- خط روبلوكس
    
    -- إعدادات المسافة (Distance)
    objects.Distance.Center = true
    objects.Distance.Outline = true
    objects.Distance.Size = 12
    objects.Distance.Font = 2

    ESP_Objects[player] = objects
end

-- ==========================================
-- 2. الواجهة (UI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NullTalal_ESP_V2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local ToggleOpenBtn = Instance.new("TextButton")
ToggleOpenBtn.Size = UDim2.new(0, 110, 0, 35)
ToggleOpenBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleOpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ToggleOpenBtn.Text = "ESP Settings"
ToggleOpenBtn.TextColor3 = Color3.fromRGB(0, 255, 204)
ToggleOpenBtn.Font = Enum.Font.GothamBold
ToggleOpenBtn.TextSize = 12
ToggleOpenBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleOpenBtn).CornerRadius = UDim.new(0, 6)
local stroke1 = Instance.new("UIStroke", ToggleOpenBtn)
stroke1.Color = Color3.fromRGB(0, 255, 204)
stroke1.Thickness = 1

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 200, 0, 260)
Main.Position = UDim2.new(0, 20, 0, 65)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local stroke2 = Instance.new("UIStroke", Main)
stroke2.Color = Color3.fromRGB(0, 255, 204)
stroke2.Thickness = 1

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.Text = "NullTalal ESP | V2"
Title.TextColor3 = Color3.fromRGB(0, 255, 204)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = Main

local function createToggle(text, yPos, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(30, 30, 40)
    btn.Text = text .. (default and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.Parent = Main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(30, 30, 40)
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        if callback then callback(state) end
    end)
end

createToggle("Master ESP", 40, Settings.Enabled, function(s) Settings.Enabled = s end)
createToggle("Box (مربع)", 75, Settings.Box, function(s) Settings.Box = s end)
createToggle("Health (صحة)", 110, Settings.Health, function(s) Settings.Health = s end)
createToggle("Name (اسم)", 145, Settings.Name, function(s) Settings.Name = s end)
createToggle("Distance (مسافة)", 180, Settings.Distance, function(s) Settings.Distance = s end)

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 0, 235)
Credit.BackgroundTransparency = 1
Credit.Text = "Made By NullTalal"
Credit.TextColor3 = Color3.fromRGB(100, 100, 100)
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 10
Credit.Parent = Main

-- أنميشن القائمة
local isOpen = true
local openTween = TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, 260)})
local closeTween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 200, 0, 0)})

ToggleOpenBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    if isOpen then openTween:Play() else closeTween:Play() end
end)

-- ==========================================
-- 3. حلقة التحديث (ESP Logic)
-- ==========================================
Players.PlayerAdded:Connect(createDrawings)
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createDrawings(p) end
end

Players.PlayerRemoving:Connect(function(player)
    if ESP_Objects[player] then
        for _, obj in pairs(ESP_Objects[player]) do
            obj:Remove()
        end
        ESP_Objects[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local objects = ESP_Objects[p]
            if not objects then continue end
            
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            
            if hrp and head and hum and hum.Health > 0 and Settings.Enabled then
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local headPos, _ = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    -- حساب الأبعاد
                    local height = math.abs(headPos.Y - hrpPos.Y) * 1.5
                    local width = height * 0.6
                    local topLeft = Vector2.new(hrpPos.X - width / 2, headPos.Y - (height * 0.2))
                    
                    -- 1. المربع (Box)
                    objects.Box.Visible = Settings.Box
                    objects.Box.Color = Settings.ESPColor
                    objects.Box.Position = topLeft
                    objects.Box.Size = Vector2.new(width, height)
                    
                    -- 2. الصحة (Health)
                    objects.Health.Visible = Settings.Health
                    local healthPct = hum.Health / hum.MaxHealth
                    objects.Health.Color = Color3.fromRGB(255 * (1 - healthPct), 255 * healthPct, 0)
                    objects.Health.Position = Vector2.new(topLeft.X - 6, topLeft.Y + height - (height * healthPct))
                    objects.Health.Size = Vector2.new(3, height * healthPct)
                    
                    -- 3. الاسم (Name)
                    objects.Name.Visible = Settings.Name
                    objects.Name.Color = Settings.ESPColor
                    objects.Name.Text = p.Name
                    objects.Name.Position = Vector2.new(hrpPos.X, topLeft.Y - 15)
                    
                    -- 4. المسافة (Distance)
                    objects.Distance.Visible = Settings.Distance
                    objects.Distance.Color = Color3.fromRGB(255, 255, 255)
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                    objects.Distance.Text = dist .. "m"
                    objects.Distance.Position = Vector2.new(hrpPos.X, topLeft.Y + height + 5)
                    
                else
                    -- إخفاء إذا كان خارج الشاشة
                    for _, obj in pairs(objects) do obj.Visible = false end
                end
            else
                -- إخفاء إذا مات
                for _, obj in pairs(objects) do obj.Visible = false end
            end
        end
    end
end)

print("[+] NullTalal Advanced ESP V2 Loaded | Made By NullTalal")
