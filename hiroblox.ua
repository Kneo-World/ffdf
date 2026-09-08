local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CarAutoFarmGuiCustom"

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Position = UDim2.new(0.02, 0, 0.05, 0)
Frame.Size = UDim2.new(0, 210, 0, 850)
Frame.Active = true
Frame.Draggable = true

UIListLayout.Parent = Frame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

local PointsForward = {}
local PointsBackward = {}

-- Настройки действий: [индекс] = "Action1", "Action2" или "Action3"
local ActionsForward = {}
local ActionsBackward = {}

local DriveSpeed = 100
local IsDriving = false
local IsLooping = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

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

-- Логика выполнения кастомных действий
local function ExecuteCustomAction(actionType, pointCFrame)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if actionType == "Exit_HoldE5" then
        -- Вылезти, зажать E 5 раз, сесть
        if hum and hum.SeatPart and hrp then
            local vehicleSeat = hum.SeatPart
            hum.Jump = true
            task.wait(0.3)
            hrp.CFrame = pointCFrame + Vector3.new(0, 2, 0)
            task.wait(0.3)
            HoldE(1.5, 5)
            task.wait(0.3)
            hrp.CFrame = vehicleSeat.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.3)
            HoldE(0.2, 1)
            task.wait(0.8)
        end

    elseif actionType == "Exit_HoldE1" then
        -- Вылезти, зажать E 1 раз, сесть
        if hum and hum.SeatPart and hrp then
            local vehicleSeat = hum.SeatPart
            hum.Jump = true
            task.wait(0.3)
            hrp.CFrame = pointCFrame + Vector3.new(0, 2, 0)
            task.wait(0.3)
            HoldE(1.5, 1)
            task.wait(0.3)
            hrp.CFrame = vehicleSeat.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.3)
            HoldE(0.2, 1)
            task.wait(0.8)
        end

    elseif actionType == "Drive_HoldE1" then
        -- Просто зажать E 1.5 сек (в машине)
        task.wait(0.3)
        HoldE(1.5, 1)
        task.wait(0.3)
    end
end

-- Езда с защитой от застревания
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
    local startTime = tick()
    
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

        if tick() - startTime > 6 then
            primaryPart.CFrame = primaryPart.CFrame + Vector3.new(0, 3, 0)
            primaryPart.AssemblyLinearVelocity = primaryPart.CFrame.LookVector * (speed * 0.8)
            task.wait(0.5)
            startTime = tick()
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

local function RunForwardRoute()
    for i = 1, 20 do
        if not (IsDriving or IsLooping) then break end
        if PointsForward[i] then
            DriveToPoint(PointsForward[i])
            if ActionsForward[i] then
                ExecuteCustomAction(ActionsForward[i], PointsForward[i])
            end
        end
    end
end

local function RunBackwardRoute()
    for i = 1, 20 do
        if not (IsDriving or IsLooping) then break end
        if PointsBackward[i] then
            DriveToPoint(PointsBackward[i])
            if ActionsBackward[i] then
                ExecuteCustomAction(ActionsBackward[i], PointsBackward[i])
            end
        end
    end
end

local function StartAutoFarmLoop()
    while IsLooping do
        RunForwardRoute()
        if not IsLooping then break end
        task.wait(0.5)
        
        RunBackwardRoute()
        if not IsLooping then break end
        task.wait(0.5)
    end
end

local function CreateButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Frame
    btn.Size = UDim2.new(1, -10, 0, 16)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 10
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ЭЛЕМЕНТЫ УПРАВЛЕНИЯ НАСТРОЙКОЙ ДЕЙСТВИЙ
local PointNumInput = Instance.new("TextBox")
PointNumInput.Parent = Frame
PointNumInput.Size = UDim2.new(1, -10, 0, 16)
PointNumInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PointNumInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PointNumInput.PlaceholderText = "Номер точки (1-20)"
PointNumInput.Text = "1"
PointNumInput.Font = Enum.Font.SourceSans
PointNumInput.TextSize = 10

local IsForward = true
local DirectionBtn
DirectionBtn = CreateButton("Направление: ВПЕРЕД", Color3.fromRGB(70, 70, 120), function()
    IsForward = not IsForward
    DirectionBtn.Text = IsForward and "Направление: ВПЕРЕД" or "Направление: НАЗАД"
end)

CreateButton("🚶 ВЫЛЕЗТИ + E (x5) + СЕСТЬ", Color3.fromRGB(130, 60, 130), function()
    local p = tonumber(PointNumInput.Text)
    if p and p >= 1 and p <= 20 then
        if IsForward then ActionsForward[p] = "Exit_HoldE5" else ActionsBackward[p] = "Exit_HoldE5" end
        print("На точку " .. p .. " (" .. (IsForward and "Вперед" or "Назад") .. ") назначено: Вылезти + E x5")
    end
end)

CreateButton("🚶 ВЫЛЕЗТИ + E (x1) + СЕСТЬ", Color3.fromRGB(100, 60, 150), function()
    local p = tonumber(PointNumInput.Text)
    if p and p >= 1 and p <= 20 then
        if IsForward then ActionsForward[p] = "Exit_HoldE1" else ActionsBackward[p] = "Exit_HoldE1" end
        print("На точку " .. p .. " (" .. (IsForward and "Вперед" or "Назад") .. ") назначено: Вылезти + E x1")
    end
end)

CreateButton("🚗 ПРОСТО E (x1)", Color3.fromRGB(60, 100, 150), function()
    local p = tonumber(PointNumInput.Text)
    if p and p >= 1 and p <= 20 then
        if IsForward then ActionsForward[p] = "Drive_HoldE1" else ActionsBackward[p] = "Drive_HoldE1" end
        print("На точку " .. p .. " (" .. (IsForward and "Вперед" or "Назад") .. ") назначено: Просто E")
    end
end)

-- СКОПИРОВАТЬ ВСЁ В КЛИПБОРД
CreateButton("📋 СКОПИРОВАТЬ СКРИПТ В КЛИПБОРД 📋", Color3.fromRGB(200, 140, 0), function()
    local str = "-- ПОЛНЫЙ СКРИПТ С ТОЧКАМИ И ДЕЙСТВИЯМИ\n"
    str = str .. "local PointsForward = {\n"
    for i = 1, 20 do
        if PointsForward[i] then
            local cf = PointsForward[i]
            str = str .. string.format("    [%d] = CFrame.new(%.2f, %.2f, %.2f),\n", i, cf.X, cf.Y, cf.Z)
        end
    end
    str = str .. "}\n\nlocal PointsBackward = {\n"
    for i = 1, 20 do
        if PointsBackward[i] then
            local cf = PointsBackward[i]
            str = str .. string.format("    [%d] = CFrame.new(%.2f, %.2f, %.2f),\n", i, cf.X, cf.Y, cf.Z)
        end
    end
    str = str .. "}\n\nlocal ActionsForward = {\n"
    for i, act in pairs(ActionsForward) do
        str = str .. string.format("    [%d] = %q,\n", i, act)
    end
    str = str .. "}\n\nlocal ActionsBackward = {\n"
    for i, act in pairs(ActionsBackward) do
        str = str .. string.format("    [%d] = %q,\n", i, act)
    end
    str = str .. "}\n"
    
    if setclipboard then
        setclipboard(str)
        print("Полный скрипт скопирован в буфер!")
    else
        print(str)
    end
end)

-- Сохранение точек
for i = 1, 20 do
    CreateButton("Вперед " .. i, Color3.fromRGB(40, 110, 50), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            PointsForward[i] = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end)
end

for i = 1, 20 do
    CreateButton("Назад " .. i, Color3.fromRGB(120, 80, 40), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            PointsBackward[i] = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end)
end

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

CreateButton("⛔ СТОП ⛔", Color3.fromRGB(120, 30, 30), function()
    IsLooping = false
    IsDriving = false
    if LoopBtn then
        LoopBtn.Text = "🔄 ЗАЦИКЛИВАНИЕ: ВЫКЛ 🔄"
        LoopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end)
