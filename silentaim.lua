-- ==========================================
-- Universal Silent Aim V1.1 | Made By NullTalal
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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
ScreenGui.Name = "UniversalSilent"
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
Toggle.Text = "Silent Aim [ON]"
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

FOVBox.FocusLost:Connect(function()
    local num = tonumber(FOVBox.Text:match("%d+"))
    if num then Settings.FOV = num end
    FOVBox.Text = "FOV: " .. Settings.FOV
end)

-- 3. تحديث الدائرة
RunService.RenderStepped:Connect(function()
    local screenSize = Camera.ViewportSize
    fovCircle.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    fovCircle.Radius = Settings.FOV
    fovCircle.Visible = Settings.Enabled
end)

-- 4. الفحص السريع
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

-- 5. الهوك
local function hookNamecall()
    if oldNamecall then return end
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if Settings.Enabled and TargetPos and not checkcaller() then
            local args = {...}
            for i, v in pairs(args) do
                if typeof(v) == "CFrame" then
                    args[i] = CFrame.new(v.Position, TargetPos)
                elseif typeof(v) == "Vector3" and v.Magnitude > 0.5 then
                    args[i] = TargetPos
                elseif typeof(v) == "table" then
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

hookNamecall()

task.spawn(function()
    while task.wait(3) do
        if not oldNamecall then hookNamecall() end
    end
end)

print("[+] Universal Silent Aim V1.1 Loaded | Made By NullTalal")
