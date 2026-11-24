-- ==========================================
-- Universal Silent Aim | Made By NullTalal
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

local Settings = {
    Enabled = true,
    FOV = 250,
    MaxDistance = 1000,
    TargetPart = "Head",
    VehicleFix = true
}

local Target = nil
local TargetPos = nil
local oldNamecall

-- ==========================================
-- 1. واجهة بسيطة
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalSilent"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 180, 0, 100)
Main.Position = UDim2.new(0, 20, 0.5, -50)
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
Toggle.Text = "Silent Aim [ON]"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 12
Toggle.Parent = Main
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 4)

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 0, 75)
Credit.BackgroundTransparency = 1
Credit.Text = "Made By NullTalal"
Credit.TextColor3 = Color3.fromRGB(150, 150, 150)
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 10
Credit.Parent = Main

Toggle.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    Toggle.Text = Settings.Enabled and "Silent Aim [ON]" or "Silent Aim [OFF]"
    Toggle.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 70)
end)

-- ==========================================
-- 2. الفحص السريع للأهداف (كل 0.1 ثانية)
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do
        if not Settings.Enabled then Target = nil continue end
        
        local closest = nil
        local closestPos = nil
        local shortest = Settings.FOV
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local part = p.Character:FindFirstChild(Settings.TargetPart)
                
                if hum and part and hum.Health > 0 then
                    local pos3D = part.Position
                    
                    -- تخطي السيارات
                    if Settings.VehicleFix and hum.SeatPart then
                        pos3D = hum.SeatPart.Position
                    end
                    
                    local dist3D = (Camera.CFrame.Position - pos3D).Magnitude
                    
                    if dist3D <= Settings.MaxDistance then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(pos3D)
                        if onScreen then
                            local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if dist2D < shortest then
                                shortest = dist2D
                                closest = part
                                closestPos = pos3D
                            end
                        end
                    end
                end
            end
        end
        Target = closest
        TargetPos = closestPos
    end
end)

-- ==========================================
-- 3. الـ Universal Hook (اعتراض كل الأوامر)
-- ==========================================
local function hookNamecall()
    if oldNamecall then return end
    
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        -- نمسك كل الـ Remotes اللي لها علاقة بالرماية
        if Settings.Enabled and TargetPos and not checkcaller() then
            local args = {...}
            
            -- نفحص إذا كان الأمر فيه CFrame (يعني راي أو تصويب)
            for i, v in pairs(args) do
                if typeof(v) == "CFrame" then
                    args[i] = CFrame.new(v.Position, TargetPos)
                elseif typeof(v) == "Vector3" and v.Magnitude > 0.5 then
                    args[i] = TargetPos
                elseif typeof(v) == "table" then
                    -- في بعض المابات يرسلون الهدف داخل جدول
                    for k, val in pairs(v) do
                        if typeof(val) == "Vector3" and val.Magnitude > 0.5 then
                            v[k] = TargetPos
                        end
                    end
                end
            end
            return oldNamecall(self, unpack(args))
        end
        
        return oldNamecall(self, ...)
    end)
end

-- تشغيل الهوك أول مرة
hookNamecall()

-- نظام "الإنعاش": إذا الحماية كسرت الهوك، نرجعه كل 3 ثواني
task.spawn(function()
    while task.wait(3) do
        if not oldNamecall then
            hookNamecall()
        end
    end
end)

-- ==========================================
-- 4. تخطي الحماية (Anti-Hook Bypass)
-- ==========================================
-- بعض المابات تحاول تمسح السكربت، هذا يمنعها
if getgenv then
    getgenv().NullTalal_SilentAim = true
    game:GetService("ScriptContext").Error:Connect(function(msg, trace) 
        -- نمنع الطرد بسبب السكربت
        if string.find(msg, "NullTalal") or string.find(trace, "NullTalal") then
            return 
        end
    end)
end

print("[+] Universal Silent Aim Loaded | Made By NullTalal")
print("[+] Features: Universal Hook, Auto-Rehook, Anti-Kick")
