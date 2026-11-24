-- ==========================================
-- Universal Silent Aim V4 | Made By NullTalal
-- Mouse, Raycast & Hitbox Bypass
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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

-- 1. رسم دائرة الـ FOV
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.NumSides = 40
fovCircle.Radius = Settings.FOV
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(0, 255, 204)
fovCircle.Transparency = 1
fovCircle.Visible = true

-- 2. الواجهة
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalSilentV4"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 180, 0, 130)
Main.Position = UDim2.new(0, 20, 0.5, -65)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0.9, 0, 0, 30)
Toggle.Position = UDim2.new(0.05, 0, 0, 10)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
Toggle.Text = "Silent Aim V4 [ON]"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 12
Toggle.Parent = Main
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 4)

local FOVBox = Instance.new("TextBox")
FOVBox.Size = UDim2.new(0.9, 0, 0, 25)
FOVBox.Position = UDim2.new(0.05, 0, 0, 50)
FOVBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
FOVBox.Text = "FOV: " .. Settings.FOV
FOVBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVBox.Font = Enum.Font.Gotham
FOVBox.TextSize = 11
FOVBox.Parent = Main
Instance.new("UICorner", FOVBox).CornerRadius = UDim.new(0, 4)

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 0, 105)
Credit.BackgroundTransparency = 1
Credit.Text = "Made By NullTalal | V4"
Credit.TextColor3 = Color3.fromRGB(150, 150, 150)
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 10
Credit.Parent = Main

Toggle.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    Toggle.Text = Settings.Enabled and "Silent Aim V4 [ON]" or "Silent Aim V4 [OFF]"
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

-- 3. فحص الأهداف (تصويب على الرأس أو كرسي السيارة)
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

-- 4. الهوك رقم 1: خداع الماوس (Mouse.Hit)
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
            -- خداع الكاميرا أيضاً
            if t == Camera then
                if k == "CFrame" then
                    -- نخلي الكاميرا تتطلع على الهدف بدون ما تحرك الشاشة
                    -- (بعض المابات تعتمد على اتجاه الكاميرا)
                end
            end
        end
        return oldIndex(t, k)
    end)
end

-- 5. الهوك رقم 2: اعتراض الطلقات (Namecall)
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

print("[+] Universal Silent Aim V4 Loaded | Made By NullTalal")
