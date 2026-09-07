local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CarBoostWaypoints"

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Position = UDim2.new(0.05, 0, 0.15, 0)
Frame.Size = UDim2.new(0, 190, 0, 520)
Frame.Active = true
Frame.Draggable = true

UIListLayout.Parent = Frame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

-- Массив под 8 точек
local Points = {}
local DriveSpeed = 100
local IsDriving = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Функция подъёма машины через отключение Collider колес
local function LiftVehicle()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    
    local vehicleSeat = humanoid.SeatPart
    local vehicleModel = vehicleSeat.Parent
    
    local colliders = {}
    local wheelsFolder = vehicleModel:FindFirstChild("Wheels") or vehicleModel:FindFirstChild("wheels")
    
    if wheelsFolder then
        for _, wheel in pairs(wheelsFolder:GetChildren()) do
            local collider = wheel:FindFirstChild("Collider") or wheel:FindFirstChild("collider")
            if collider and collider:IsA("BasePart") then
                table.insert(colliders, collider)
            end
        end
    else
        for _, part in pairs(vehicleModel:GetDescendants()) do
            if part.Name == "Collider" and part:IsA("BasePart") then
                table.insert(colliders, part)
            end
        end
    end
    
    for _, collider in pairs(colliders) do
        collider.CanCollide = false
        collider.AssemblyLinearVelocity = Vector3.zero
        collider.AssemblyAngularVelocity = Vector3.zero
    end
    
    if vehicleModel.PrimaryPart then
        vehicleModel.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
        vehicleModel.PrimaryPart.AssemblyAngularVelocity = Vector3.zero
    end

    local currentPivot = vehicleModel:GetPivot()
    vehicleModel:PivotTo(currentPivot + Vector3.new(0, 6, 0))
    
    task.wait(0.3)
    
    for _, collider in pairs(colliders) do
        if collider and collider.Parent then
            collider.CanCollide = true
        end
    end
end

-- Функция движения к ОДНОЙ конкретной точке
local function DriveToPoint(targetCFrame)
    if not targetCFrame then return false end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or not humanoid.SeatPart then return false end

    local vehicleSeat = humanoid.SeatPart
    local vehicleModel = vehicleSeat.Parent
    local primaryPart = vehicleModel.PrimaryPart or vehicleSeat

    local speed = tonumber(DriveSpeed) or 100
    
    while IsDriving do
        if not character or not humanoid.SeatPart then break end
        
        local currentPos = primaryPart.Position
        local targetPos = targetCFrame.Position
        local distance = (Vector3.new(targetPos.X, currentPos.Y, targetPos.Z) - currentPos).Magnitude

        if distance < 10 then
            primaryPart.AssemblyLinearVelocity = Vector3.zero
            primaryPart.AssemblyAngularVelocity = Vector3.zero
            return true -- Успешно доехали до точки
        end

        local direction = (Vector3.new(targetPos.X, currentPos.Y, targetPos.Z) - currentPos).Unit
        local targetRot = CFrame.new(primaryPart.Position, primaryPart.Position + direction)
        
        primaryPart.CFrame = primaryPart.CFrame:Lerp(targetRot, 0.2)
        primaryPart.AssemblyAngularVelocity = Vector3.zero
        primaryPart.AssemblyLinearVelocity = (direction * speed) + Vector3.new(0, 1, 0)

        task.wait(0.03)
    end
    
    return false
end

-- Функция последовательного маршрута по нескольким точкам
local function DriveRoute(routePointIndexes)
    if IsDriving then return end
    IsDriving = true
    
    for _, idx in ipairs(routePointIndexes) do
        if not IsDriving then break end
        if Points[idx] then
            DriveToPoint(Points[idx])
        end
    end
    
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.SeatPart then
            local primaryPart = humanoid.SeatPart.Parent.PrimaryPart or humanoid.SeatPart
            primaryPart.AssemblyLinearVelocity = Vector3.zero
            primaryPart.AssemblyAngularVelocity = Vector3.zero
        end
    end
    
    IsDriving = false
end

local function CreateButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Frame
    btn.Size = UDim2.new(1, -10, 0, 22)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.MouseButton1Click:Connect(callback)
end

-- Ввод скорости
local SpeedInput = Instance.new("TextBox")
SpeedInput.Parent = Frame
SpeedInput.Size = UDim2.new(1, -10, 0, 22)
SpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.PlaceholderText = "Скорость (80-120)"
SpeedInput.Text = "100"
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.TextSize = 12

SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val and val > 0 then DriveSpeed = val else SpeedInput.Text = tostring(DriveSpeed) end
end)

-- Поднять машину
CreateButton("⬆ ПОДНЯТЬ МАШИНУ ⬆", Color3.fromRGB(200, 100, 30), function()
    LiftVehicle()
end)

-- Сохранение 4 точек ВПРЕД (1, 2, 3, 4)
for i = 1, 4 do
    CreateButton("Сохранить Вперед " .. i, Color3.fromRGB(40, 110, 50), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Points[i] = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end)
end

-- Сохранение 4 точек НАЗАД (5, 6, 7, 8)
for i = 5, 8 do
    CreateButton("Сохранить Назад " .. (i - 4), Color3.fromRGB(120, 80, 40), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Points[i] = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end)
end

-- Авто-маршрут ВПРЕД (по точкам 1 -> 2 -> 3 -> 4)
CreateButton("▶ ЕХАТЬ ВПРЕД (1-4)", Color3.fromRGB(50, 100, 180), function()
    task.spawn(function()
        DriveRoute({1, 2, 3, 4})
    end)
end)

-- Авто-маршрут НАЗАД (по точкам 5 -> 6 -> 7 -> 8)
CreateButton("◀ ЕХАТЬ НАЗАД (1-4)", Color3.fromRGB(150, 80, 150), function()
    task.spawn(function()
        DriveRoute({5, 6, 7, 8})
    end)
end)

-- Кнопка СТОП
CreateButton("⛔ СТОП ⛔", Color3.fromRGB(160, 40, 40), function()
    IsDriving = false
end)
