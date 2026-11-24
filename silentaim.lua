-- ==========================================
-- Universal Silent Aim V1 | Made By NullTalal
-- Mouse, Raycast & Hitbox Bypass
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

local Settings = {
    Enabled = true,
    FOV = 250,
    MaxDistance = 1000,
    TargetPart = "Head",
    VehicleFix = true
}

local Target = nil
local TargetPart = nil
local oldIndex, oldNamecall

-- ==========================================
-- 1. رسم دائرة الـ FOV
-- ==========================================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.NumSides = 40
fovCircle.Radius = Settings.FOV
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(0, 255, 204)
fovCircle.Transparency = 1
fovCircle.Visible = true

-- ==========================================
-- 2. الواجهة (UI) مع الأنميشن
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalSilentV1"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- زر فتح وقفل القائمة
local ToggleOpenBtn = Instance.new("TextButton")
ToggleOpenBtn.Size = UDim2.new(0, 100, 0, 35)
ToggleOpenBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleOpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleOpenBtn.Text = "Open Menu"
ToggleOpenBtn.TextColor3 = Color3.fromRGB(0, 255, 204)
ToggleOpenBtn.Font = Enum.Font.GothamBold
ToggleOpenBtn.TextSize = 13
ToggleOpenBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleOpenBtn).CornerRadius = UDim.new(0, 6)
local stroke1 = Instance.new("UIStroke", ToggleOpenBtn)
stroke1.Color = Color3.fromRGB(0, 255, 204)
stroke1.Thickness = 1

-- القائمة الرئيسية
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 200, 0, 160)
Main.Position = UDim2.new(0, 20, 0, 65)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
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
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.Text = "NullTalal | Silent Aim"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = Main

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0.9, 0, 0, 30)
Toggle.Position = UDim2.new(0.05, 0, 0, 40)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
Toggle.Text = "Silent Aim V1 [ON]"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 12
Toggle.Parent = Main
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 4)

local FOVBox = Instance.new("TextBox")
FOVBox.Size = UDim2.new(0.9, 0, 0, 25)
FOVBox.Position = UDim2.new(0.05, 0, 0, 80)
FOVBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
FOVBox.Text = "FOV: " .. Settings.FOV
FOVBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVBox.Font = Enum.Font.Gotham
FOVBox.TextSize = 11
FOVBox.Parent = Main
Instance.new("UICorner", FOVBox).CornerRadius = UDim.new(0, 4)

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 0, 130)
Credit.BackgroundTransparency = 1
Credit.Text = "Made By NullTalal | V1"
Credit.TextColor3 = Color3.fromRGB(100, 100, 100)
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 10
Credit.Parent = Main

-- الأنميشن (فتح وقفل)
local isOpen = true
local openTween = TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, 160)})
local closeTween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 200, 0, 0)})

ToggleOpenBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    if isOpen then openTween:Play() else closeTween:Play() end
end)

Toggle.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    Toggle.Text = Settings.Enabled and "Silent Aim V1 [ON]" or "Silent Aim V1 [OFF]"
    Toggle.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 70)
end)

FOVBox.FocusLost:Connect(function()
    local num = tonumber(FOVBox.Text:match("%d+"))
    if num then Settings.FOV = num end
    FOVBox.Text = "FOV: " .. Settings.FOV
end)

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Radius = Settings.FOV
    fovCircle.Visible = Settings.Enabled
end)

-- ==========================================
-- 3. فحص الأهداف
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do
        if not Settings.Enabled then Target = nil TargetPart = nil continue end
        local closest = nil
        local closestPart = nil
        local shortest = Settings.FOV
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local part = p.Character:FindFirstChild(Settings.TargetPart)
                
                if hum and part and hum.Health > 0 then
                    local pos3D = part.Position
                    local targetPartToUse = part
                    
                    if Settings.VehicleFix and hum.SeatPart then 
                        pos3D = hum.SeatPart.Position 
                        targetPartToUse = hum.SeatPart
                    end
                    
                    local dist3D = (Camera.CFrame.Position - pos3D).Magnitude
                    if dist3D <= Settings.MaxDistance then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(pos3D)
                        if onScreen then
                            local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if dist2D < shortest then
                                shortest = dist2D
                                closest = pos3D
                                closestPart = targetPartToUse
                            end
                        end
                    end
                end
            end
        end
        Target = closest
        TargetPart = closestPart
    end
end)

-- ==========================================
-- 4. الهوك رقم 1: خداع الماوس (Mouse.Hit)
-- ==========================================
local function hookMouse()
    if oldIndex then return end
    oldIndex = hookmetamethod(game, "__index", function(t, k)
        if not checkcaller() and Settings.Enabled and Target then
            if t == Mouse then
                if k == "Hit" then
                    return CFrame.new(Target)
                elseif k == "Target" then
                    return TargetPart
                end
            end
        end
        return oldIndex(t, k)
    end)
end

-- ==========================================
-- 5. الهوك رقم 2: اعتراض الطلقات (Namecall)
-- ==========================================
local function hookNamecall()
    if oldNamecall then return end
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        if Settings.Enabled and Target and not checkcaller() then
            local args = {...}
            local newArgs = {}
            
            for i, v in pairs(args) do
                if typeof(v) == "CFrame" then
                    newArgs[i] = CFrame.new(v.Position, Target)
                elseif typeof(v) == "Vector3" and v.Magnitude > 0.5 then
                    newArgs[i] = Target
                elseif typeof(v) == "Instance" and v:IsA("BasePart") then
                    newArgs[i] = TargetPart
                elseif typeof(v) == "table" then
                    local newTable = {}
                    for k, val in pairs(v) do
                        if typeof(val) == "Vector3" and val.Magnitude > 0.5 then
                            newTable[k] = Target
                        elseif typeof(val) == "Instance" and val:IsA("BasePart") then
                            newTable[k] = TargetPart
                        else
                            newTable[k] = val
                        end
                    end
                    newArgs[i] = newTable
                else
                    newArgs[i] = v
                end
            end
            
            return oldNamecall(self, unpack(newArgs))
        end
        
        return oldNamecall(self, ...)
    end)
end

hookMouse()
hookNamecall()

-- إنعاش الهوك إذا الحماية مسحته
task.spawn(function()
    while task.wait(3) do
        if not oldIndex then hookMouse() end
        if not oldNamecall then hookNamecall() end
    end
end)

print("[+] Universal Silent Aim V1 Loaded | Made By NullTalal")
