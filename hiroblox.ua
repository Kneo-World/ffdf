local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CarFlyGUI"

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 170, 0, 290)
Frame.Active = true
Frame.Draggable = true

UIListLayout.Parent = Frame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local Point1, Point2, Point3
local FlySpeed = 80
local IsMoving = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Функция безопасного перемещения авто
local function SafeMove(targetCFrame)
    if not targetCFrame or IsMoving then return end
    IsMoving = true
    
    local character = LocalPlayer.Character
    if not character then IsMoving = false return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local targetModel = character:FindFirstChild("HumanoidRootPart")
    local isVehicle = false
    
    -- Проверяем, сидим ли в машине
    if humanoid and humanoid.SeatPart then
        targetModel = humanoid.SeatPart.Parent -- Модель машины
        isVehicle = true
    end

    if not targetModel then IsMoving = false return end

    -- Отключаем коллизию (чтобы не колбасило и не закидывало под карту)
    local originalVelocities = {}
    for _, part in pairs(targetModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.AssemblyLinearVelocity = Vector3.zero
            part.AssemblyAngularVelocity = Vector3.zero
        end
    end

    local mainPart = isVehicle and (targetModel.PrimaryPart or humanoid.SeatPart) or targetModel
    local currentSpeed = tonumber(FlySpeed) or 80
    local distance = (mainPart.Position - targetCFrame.Position).Magnitude
    local duration = distance / currentSpeed
    local startTime = tick()
    
    local startCFrame = mainPart.CFrame

    -- Плавный полет без конфликта физики
    while (tick() - startTime) < duration do
        if not character or not mainPart then break end
        local alpha = (tick() - startTime) / duration
        
        -- Поднимаем чуть выше земли (+3 студа), чтобы не застревать
        local nextCFrame = startCFrame:Lerp(targetCFrame + Vector3.new(0, 3, 0), alpha)
        
        if isVehicle then
            targetModel:PivotTo(nextCFrame)
        else
            mainPart.CFrame = nextCFrame
        end
        
        task.wait()
    end
    
    -- Финальная посадка
    if isVehicle then
        targetModel:PivotTo(targetCFrame)
    else
        mainPart.CFrame = targetCFrame
    end

    -- Включаем коллизию обратно
    task.wait(0.2)
    for _, part in pairs(targetModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
            part.AssemblyLinearVelocity = Vector3.zero
        end
    end
    
    IsMoving = false
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

local SpeedInput = Instance.new("TextBox")
SpeedInput.Parent = Frame
SpeedInput.Size = UDim2.new(1, -10, 0, 26)
SpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.PlaceholderText = "Скорость (80-120 для авто)"
SpeedInput.Text = "80"
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.TextSize = 13

SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val and val > 0 then FlySpeed = val else SpeedInput.Text = tostring(FlySpeed) end
end)

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

CreateButton("Лететь к Точке 1", Color3.fromRGB(70, 70, 150), function()
    task.spawn(function() SafeMove(Point1) end)
end)

CreateButton("Лететь к Точке 2", Color3.fromRGB(70, 70, 150), function()
    task.spawn(function() SafeMove(Point2) end)
end)

CreateButton("Лететь к Точке 3", Color3.fromRGB(70, 70, 150), function()
    task.spawn(function() SafeMove(Point3) end)
end)
