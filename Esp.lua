-- ==========================================
-- NullTalal Premium ESP | Made By NullTalal
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    PlayerESP = true,
    ItemESP = true,
    ESPColor = Color3.fromRGB(255, 0, 0) -- اللون الافتراضي (أحمر)
}

-- ==========================================
-- 1. الواجهة (UI) مع الأنميشن
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NullTalal_ESP"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- زر فتح وقفل القائمة
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 100, 0, 35)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ToggleBtn.Text = "Open ESP"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(0, 255, 204)

-- القائمة الرئيسية
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 220, 0, 280)
Main.Position = UDim2.new(0, 20, 0, 65)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- عنوان القائمة
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Title.Text = "NullTalal ESP | V1"
Title.TextColor3 = Color3.fromRGB(0, 255, 204)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = Main

-- دالة إنشاء الأزرار
local function createButton(text, yPos, isToggle, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = isToggle and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(35, 35, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.Parent = Main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local state = isToggle
    btn.MouseButton1Click:Connect(function()
        if isToggle then
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(35, 35, 45)
        end
        if callback then callback(state) end
    end)
end

-- أزرار التحكم
createButton("Player ESP [ON]", 45, true, function(s) Settings.PlayerESP = s end)
createButton("Item ESP [ON]", 85, true, function(s) Settings.ItemESP = s end)

-- تغيير الألوان
local lblColor = Instance.new("TextLabel")
lblColor.Size = UDim2.new(0.9, 0, 0, 20)
lblColor.Position = UDim2.new(0.05, 0, 0, 125)
lblColor.BackgroundTransparency = 1
lblColor.Text = "ESP Color:"
lblColor.TextColor3 = Color3.fromRGB(200, 200, 200)
lblColor.Font = Enum.Font.Gotham
lblColor.TextSize = 11
lblColor.TextXAlignment = Enum.TextXAlignment.Left
lblColor.Parent = Main

local colorBtn1 = createButton("Red", 150, false, function() Settings.ESPColor = Color3.fromRGB(255, 0, 0) end)
local colorBtn2 = createButton("Green", 185, false, function() Settings.ESPColor = Color3.fromRGB(0, 255, 0) end)
local colorBtn3 = createButton("Purple", 220, false, function() Settings.ESPColor = Color3.fromRGB(170, 0, 255) end)

-- حقوقك
local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 0, 255)
Credit.BackgroundTransparency = 1
Credit.Text = "Made By NullTalal"
Credit.TextColor3 = Color3.fromRGB(100, 100, 100)
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 10
Credit.Parent = Main

-- حركة فتح وقفل القائمة (Animation)
local isOpen = true
local openTween = TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 220, 0, 280)})
local closeTween = TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 220, 0, 0)})

ToggleBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    if isOpen then openTween:Play() else closeTween:Play() end
end)

-- ==========================================
-- 2. نظام ESP (اللاعبين والأغراض)
-- ==========================================
local PlayerHighlights = {}

-- دالة تحديث ESP اللاعبين
local function updatePlayerESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hl = PlayerHighlights[player]
            
            if Settings.PlayerESP then
                if not hl or not hl.Parent then
                    hl = Instance.new("Highlight")
                    hl.FillColor = Settings.ESPColor
                    hl.OutlineColor = Settings.ESPColor
                    hl.FillTransparency = 0.5
                    hl.Parent = player.Character
                    PlayerHighlights[player] = hl
                else
                    hl.FillColor = Settings.ESPColor
                    hl.OutlineColor = Settings.ESPColor
                    hl.Enabled = true
                end
            else
                if hl then hl.Enabled = false end
            end
        end
    end
end

-- دالة ESP الأغراض
local function updateItemESP()
    for _, obj in pairs(workspace:GetChildren()) do
        if Settings.ItemESP then
            -- البحث عن أدوات أو أغراض لها Handle (زي الأسلحة والفلوس)
            if obj:IsA("Model") and obj:FindFirstChild("Handle") and not obj:FindFirstChildOfClass("Humanoid") then
                if not obj:FindFirstChild("NullESP") then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "NullESP"
                    billboard.Size = UDim2.new(0, 100, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = obj

                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.Text = obj.Name
                    text.TextColor3 = Settings.ESPColor
                    text.Font = Enum.Font.GothamBold
                    text.TextSize = 12
                    text.TextStrokeTransparency = 0
                    text.Parent = billboard
                else
                    -- تحديث اللون إذا غيرته
                    local text = obj.NullESP:FindFirstChildOfClass("TextLabel")
                    if text then text.TextColor3 = Settings.ESPColor end
                end
            end
        else
            -- حذف الـ ESP حق الأغراض إذا طفيته
            local esp = obj:FindFirstChild("NullESP")
            if esp then esp:Destroy() end
        end
    end
end

-- ==========================================
-- 3. الحلقة الرئيسية (عشان ما يسبب لاق)
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        updatePlayerESP()
        updateItemESP()
    end
end)

-- تنظيف عند خروج اللاعب
Players.PlayerRemoving:Connect(function(player)
    if PlayerHighlights[player] then
        PlayerHighlights[player]:Destroy()
        PlayerHighlights[player] = nil
    end
end)

print("[+] NullTalal Premium ESP Loaded")
