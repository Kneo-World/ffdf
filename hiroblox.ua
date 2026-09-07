local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CustomWaypointGUI"

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
local FlySpeed = 25
local IsMoving = false -- Флаг защиты от бесконечного зацикливания

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function MoveToTarget(targetCFrame)
    if not targetCFrame or IsMoving then return end
    IsMoving = true
    
    local character = LocalPlayer.Character
    if not character then IsMoving = false return end
    
    -- Определяем, сидит ли игрок в машине или идет пешком
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if humanoid and humanoid.SeatPart then
        -- Если сидим в машине, двигаем корпус машины
        root = humanoid.SeatPart.Parent.PrimaryPart or humanoid.SeatPart
    end

    if not root then IsMoving = false return end

    local currentSpeed = tonumber(FlySpeed) or 25
    local stepSize = 8 -- Уменьшенный шаг, чтобы античит не триггерился
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local steps = math.floor(distance / stepSize)
    
    local startCFrame = root.CFrame
    
    for i = 1, steps do
        if not character or not root then break end
        
        local alpha = i / steps
        local nextPosition = startCFrame:Lerp(targetCFrame, alpha)
        
        root.CFrame = nextPosition
        
        local delayTime = stepSize / currentSpeed
        task.wait(delayTime)
    end
    
    if root then root.CFrame = targetCFrame end
    
    -- Пауза 1.5 сек, чтобы сервер сбросил накопленную дистанцию в логах
    task.wait(1.5)
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
SpeedInput.PlaceholderText = "Скорость (25 пешком / 70+ авто)"
SpeedInput.Text = "25"
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
    task.spawn(function() MoveToTarget(Point1) end)
end)

CreateButton("Лететь к Точке 2", Color3.fromRGB(70, 70, 150), function()
    task.spawn(function() MoveToTarget(Point2) end)
end)

CreateButton("Лететь к Точке 3", Color3.fromRGB(70, 70, 150), function()
    task.spawn(function() MoveToTarget(Point3) end)
end)
