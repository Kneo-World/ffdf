local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CarAutoFarmGui10"

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Position = UDim2.new(0.02, 0, 0.05, 0)
Frame.Size = UDim2.new(0, 200, 0, 720)
Frame.Active = true
Frame.Draggable = true

UIListLayout.Parent = Frame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

local PointsForward = {}
local PointsBackward = {}
local DriveSpeed = 100
local IsDriving = false
local IsLooping = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Функция ЗАЖАТИЯ клавиши E
local function HoldE(holdTime, times)
    times = times or 1
    holdTime = holdTime or 1.5
    
    for i = 1, times do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(holdTime)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.3)
    end
end

-- Плавный метод езды
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
    primaryPart.AssemblyAngularVelocity = Vector3.zero
    
    while IsDriving or IsLooping do
        if not character or not humanoid.SeatPart then break end
        
        local currentPos = primaryPart.Position
        local targetPos = targetCFrame.Position
        local distance = (Vector3.new(targetPos.X, currentPos.Y, targetPos.Z) - currentPos).Magnitude

        if distance < 10 then
            primaryPart.AssemblyLinearVelocity = Vector3.zero
            primaryPart.AssemblyAngularVelocity = Vector3.zero
            return true
        end

        local direction = (Vector3.new(targetPos.X, currentPos.Y, targetPos.Z) - currentPos).Unit
        local targetRot = CFrame.new(primaryPart.Position, primaryPart.Position + direction)
        
        primaryPart.CFrame = primaryPart.CFrame:Lerp(targetRot, 0.2)
        primaryPart.AssemblyAngularVelocity = Vector3.zero
        primaryPart.AssemblyLinearVelocity = (direction * speed) + Vector3.new(0, 1, 0)

        task.wait(0.03)
    end
    
    primaryPart.AssemblyLinearVelocity = Vector3.zero
    primaryPart.AssemblyAngularVelocity = Vector3.zero
    return false
end

-- Маршрут ВПРЕД (1..10)
local function RunForwardRoute()
    for i = 1, 10 do
        if not (IsDriving or IsLooping) then break end
        if PointsForward[i] then
            
            DriveToPoint(PointsForward[i])
            
            -- На ТОЧКЕ 1: Вылезти, зажать E 5 раз, сесть обратно
            if i == 1 then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hum and hum.SeatPart and hrp then
                    local vehicleSeat = hum.SeatPart
                    
                    hum.Jump = true
                    task.wait(0.3)
                    
                    hrp.CFrame = PointsForward[1] + Vector3.new(0, 2, 0)
                    task.wait(0.3)
                    
                    HoldE(1.5, 5)
                    task.wait(0.3)
                    
                    hrp.CFrame = vehicleSeat.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.3)
                    
                    HoldE(0.2, 1)
                    task.wait(0.8)
                end
                
            -- На ТОЧКЕ 10: Вылезти, сдавать (E 1.5 сек), сесть обратно
            elseif i == 10 then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hum and hum.SeatPart and hrp then
                    local vehicleSeat = hum.SeatPart
                    
                    hum.Jump = true
                    task.wait(0.3)
                    
                    hrp.CFrame = PointsForward[10] + Vector3.new(0, 2, 0)
                    task.wait(0.3)
                    
                    HoldE(1.5, 1)
                    task.wait(0.3)
                    
                    hrp.CFrame = vehicleSeat.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.3)
                    
                    HoldE(0.2, 1)
                    task.wait(0.8)
                end
            end
        end
    end
end

-- Маршрут НАЗАД (1..10)
local function RunBackwardRoute()
    for i = 1, 10 do
        if not (IsDriving or IsLooping) then break end
        if PointsBackward[i] then
            DriveToPoint(PointsBackward[i])
            
            -- На ТОЧКЕ 8 НАЗАД: Зажатие E на 1.5 секунды (прямо из машины)
            if i == 8 then
                task.wait(0.3)
                HoldE(1.5, 1)
                task.wait(0.3)
            end
        end
    end
end

-- Бесконечный цикл фарма
local function StartAutoFarmLoop()
    while IsLooping do
        RunForwardRoute()
        if not IsLooping then break end
        task.wait(0.5)
        
        RunBackwardRoute()
        if not IsLooping then break end
        task.wait(0.5)
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
end

local function CreateButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Frame
    btn.Size = UDim2.new(1, -10, 0, 18)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 10
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Поле ввода скорости
local SpeedInput = Instance.new("TextBox")
SpeedInput.Parent = Frame
SpeedInput.Size = UDim2.new(1, -10, 0, 18)
SpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.PlaceholderText = "Скорость (80-120)"
SpeedInput.Text = "100"
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.TextSize = 11

SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val and val > 0 then DriveSpeed = val else SpeedInput.Text = tostring(DriveSpeed) end
end)

-- Сохранение 10 точек ВПРЕД
for i = 1, 10 do
    CreateButton("Сохранить Вперед " .. i, Color3.fromRGB(40, 110, 50), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            PointsForward[i] = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end)
end

-- Сохранение 10 точек НАЗАД
for i = 1, 10 do
    CreateButton("Сохранить Назад " .. i, Color3.fromRGB(120, 80, 40), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            PointsBackward[i] = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end)
end

-- Разовый проезд
CreateButton("▶ ЕХАТЬ ВПРЕД (1 РАЗ)", Color3.fromRGB(50, 100, 180), function()
    if IsLooping or IsDriving then return end
    IsDriving = true
    task.spawn(function()
        RunForwardRoute()
        IsDriving = false
    end)
end)

CreateButton("◀ ЕХАТЬ НАЗАД (1 РАЗ)", Color3.fromRGB(150, 80, 150), function()
    if IsLooping or IsDriving then return end
    IsDriving = true
    task.spawn(function()
        RunBackwardRoute()
        IsDriving = false
    end)
end)

-- Зацикливание
local LoopBtn
LoopBtn = CreateButton("🔄 ЗАЦИКЛИВАНИЕ: ВЫКЛ 🔄", Color3.fromRGB(180, 50, 50), function()
    IsLooping = not IsLooping
    if IsLooping then
        LoopBtn.Text = "🔄 ЗАЦИКЛИВАНИЕ: ВКЛ 🔄"
        LoopBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        task.spawn(StartAutoFarmLoop)
    else
        LoopBtn.Text = "🔄 ЗАЦИКЛИВАНИЕ: ВЫКЛ 🔄"
        LoopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        IsDriving = false
    end
end)

CreateButton("⛔ СТОП ВСЕ ⛔", Color3.fromRGB(120, 30, 30), function()
    IsLooping = false
    IsDriving = false
    if LoopBtn then
        LoopBtn.Text = "🔄 ЗАЦИКЛИВАНИЕ: ВЫКЛ 🔄"
        LoopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end)
