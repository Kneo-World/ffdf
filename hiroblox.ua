local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CarBoostWaypoints"

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 180, 0, 270)
Frame.Active = true
Frame.Draggable = true

UIListLayout.Parent = Frame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local Point1, Point2, Point3
local DriveSpeed = 120 -- Скорость движения авто
local IsDriving = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Функция физической авто-езды к точке
local function DriveTo(targetCFrame)
    if not targetCFrame or IsDriving then return end
    IsDriving = true
    
    local character = LocalPlayer.Character
    if not character then IsDriving = false return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or not humanoid.SeatPart then
        print("Сначала сядьте в машину!")
        IsDriving = false
        return
    end

    local vehicleSeat = humanoid.SeatPart
    local vehicleModel = vehicleSeat.Parent
    local primaryPart = vehicleModel.PrimaryPart or vehicleSeat

    local speed = tonumber(DriveSpeed) or 120
    
    -- Цикл ускорения машины в сторону точки
    while IsDriving do
        if not character or not humanoid.SeatPart then break end
        
        local currentPos = primaryPart.Position
        local targetPos = targetCFrame.Position
        local distance = (Vector3.new(targetPos.X, currentPos.Y, targetPos.Z) - currentPos).Magnitude

        -- Если приехали близко к точке — останавливаемся
        if distance < 8 then
            primaryPart.AssemblyLinearVelocity = Vector3.zero
            break
        end

        -- Рассчитываем направление движения по земле
        local direction = (Vector3.new(targetPos.X, currentPos.Y, targetPos.Z) - currentPos).Unit
        
        -- Поворачиваем машину в сторону точки
        primaryPart.CFrame = CFrame.new(primaryPart.Position, primaryPart.Position + direction)
        
        -- Применяем физический Boost (как в Sakura Mod)
        primaryPart.AssemblyLinearVelocity = direction * speed

        task.wait(0.03)
    end
    
    IsDriving = false
end

local function CreateButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Frame
    btn.Size = UDim2.new(1, -10, 0, 26)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.MouseButton1Click:Connect(callback)
end

-- Поле ввода скорости езды
local SpeedInput = Instance.new("TextBox")
SpeedInput.Parent = Frame
SpeedInput.Size = UDim2.new(1, -10, 0, 26)
SpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.PlaceholderText = "Скорость (100-200)"
SpeedInput.Text = "120"
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.TextSize = 13

SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val and val > 0 then DriveSpeed = val else SpeedInput.Text = tostring(DriveSpeed) end
end)

-- Кнопки сохранения точек
CreateButton("Сохранить Точку 1", Color3.fromRGB(50, 120, 50), function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Point1 = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

CreateButton("Сохранить Точку 2", Color3.fromRGB(50, 120, 50), function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Point2 = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

CreateButton("Сохранить Точку 3", Color3.fromRGB(50, 120, 50), function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Point3 = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

-- Кнопки старта движения
CreateButton("Ехать к Точке 1", Color3.fromRGB(70, 70, 150), function()
    task.spawn(function() DriveTo(Point1) end)
end)

CreateButton("Ехать к Точке 2", Color3.fromRGB(70, 70, 150), function()
    task.spawn(function() DriveTo(Point2) end)
end)

CreateButton("Ехать к Точке 3", Color3.fromRGB(70, 70, 150), function()
    task.spawn(function() DriveTo(Point3) end)
end)

CreateButton("СТОП", Color3.fromRGB(150, 50, 50), function()
    IsDriving = false
end)
