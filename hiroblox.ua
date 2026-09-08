-- ИСПРАВЛЕННЫЙ СКРИПТ (С ФИКСOМ ОБРАТНОГО ПУТИ)
local PointsForward = {
    [1] = CFrame.new(6637.86, 62.69, -453.26),
    [2] = CFrame.new(6599.02, 64.56, -424.08),
    [3] = CFrame.new(6600.16, 64.42, -390.50),
    [4] = CFrame.new(6624.86, 61.05, -343.51),
    [5] = CFrame.new(6602.76, 61.05, -299.59),
    [6] = CFrame.new(6589.30, 18.77, 113.57),
    [7] = CFrame.new(2937.30, 18.78, 113.59),
    [8] = CFrame.new(2781.26, 18.73, 129.71),
    [9] = CFrame.new(2643.82, 18.76, 113.50),
    [10] = CFrame.new(193.30, 18.80, 109.11),
    [11] = CFrame.new(172.23, 18.76, -45.46),
    [12] = CFrame.new(207.59, 18.74, -43.91),
}

local PointsBackward = {
    [1] = CFrame.new(208.09, 18.67, -59.19),
    [2] = CFrame.new(169.01, 18.77, -63.94),
    [3] = CFrame.new(161.65, 18.79, 135.47),
    [4] = CFrame.new(2354.04, 18.80, 142.57),
    [5] = CFrame.new(2768.20, 18.74, 158.01),
    [6] = CFrame.new(2945.64, 18.80, 146.56),
    [7] = CFrame.new(6602.97, 19.11, 143.63),
    [8] = CFrame.new(6597.14, 62.58, -299.14),
    [9] = CFrame.new(6630.71, 62.63, -330.19),
    [10] = CFrame.new(6596.61, 65.93, -399.14),
    [11] = CFrame.new(6615.44, 66.00, -463.07),
    [12] = CFrame.new(6615.44, 65.99, -463.05),
    [13] = CFrame.new(6610.83, 65.99, -441.75),
    [14] = CFrame.new(6610.46, 65.99, -439.59),
}

local ActionsForward = {
    [1] = "Exit_HoldE5",
    [12] = "Exit_HoldE1",
}

local ActionsBackward = {
    [12] = "Drive_HoldE1",
}

local DriveSpeed = 100
local IsDriving = false
local IsLooping = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Бессмертие
task.spawn(function()
    while true do
        task.wait(0.2)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = 999999
                hum.Health = 999999
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleBtn = Instance.new("TextButton")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CarAutoFarmGuiFixed"

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true

ToggleBtn.Parent = MainFrame
ToggleBtn.Size = UDim2.new(1, 0, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "🚗 AUTOFARM MENU [ — ]"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 12

local IsMinimized = false
ToggleBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        ScrollFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 220, 0, 20)
        ToggleBtn.Text = "🚗 AUTOFARM MENU [ + ]"
    else
        ScrollFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 220, 0, 300)
        ToggleBtn.Text = "🚗 AUTOFARM MENU [ — ]"
    end
end)

ScrollFrame.Parent = MainFrame
ScrollFrame.Position = UDim2.new(0, 0, 0, 22)
ScrollFrame.Size = UDim2.new(1, 0, 1, -22)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1100)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

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

local function SetVehicleDetectorsEnabled(vehicleModel, enabled)
    if not vehicleModel then return end
    for _, desc in pairs(vehicleModel:GetDescendants()) do
        if desc:IsA("ClickDetector") then
            desc.MaxActivationDistance = enabled and 32 or 0
        elseif desc:IsA("ProximityPrompt") then
            desc.Enabled = enabled
        end
    end
end

local function AnchorVehicle(vehicleModel, anchorState)
    if not vehicleModel then return end
    for _, part in pairs(vehicleModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = anchorState
        end
    end
end

local function ExecuteCustomAction(actionType, pointCFrame)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if actionType == "Exit_HoldE5" or actionType == "Exit_HoldE1" then
        if hum and hum.SeatPart and hrp then
            local vehicleSeat = hum.SeatPart
            local vehicleModel = vehicleSeat.Parent

            AnchorVehicle(vehicleModel, true)
            SetVehicleDetectorsEnabled(vehicleModel, false)

            hum.Jump = true
            task.wait(0.3)
            
            hrp.CFrame = pointCFrame + Vector3.new(6, 2, 0)
            task.wait(0.3)

            local holdAmount = (actionType == "Exit_HoldE5") and 5 or 1
            HoldE(1.5, holdAmount)
            task.wait(0.3)

            SetVehicleDetectorsEnabled(vehicleModel, true)
            AnchorVehicle(vehicleModel, false)

            hrp.CFrame = vehicleSeat.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.3)
            HoldE(0.2, 1)
            task.wait(0.8)
        end
    elseif actionType == "Drive_HoldE1" then
        task.wait(0.3)
        HoldE(1.5, 1)
        task.wait(0.3)
    end
end

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

        if distance < 12 then
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

-- Точный проход по всем 12 точкам вперёд
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

-- Точный проход по всем 14 точкам назад
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
        task.wait(1)
        
        RunBackwardRoute()
        if not IsLooping then break end
        task.wait(1)
    end
end

local function CreateButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = ScrollFrame
    btn.Size = UDim2.new(1, -12, 0, 18)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 10
    btn.MouseButton1Click:Connect(callback)
    return btn
end

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
