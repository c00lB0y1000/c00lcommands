

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local flying = false
local speed = 50
local bodyGyro, bodyVelocity
local direction = Vector3.new()

local noclip = false

local shiftHeld = false
local normalSpeed = 16
local sprintSpeed = 32
local espEnabled = false
local beams = {}
local originalTransparency = {}
local updateConnection = nil -- для отключения цикла потом

local screenGui

local function setupGUIAndConnections()
    screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player.PlayerGui
    screenGui.Enabled = true
    screenGui.ResetOnSpawn = false  -- Ensure GUI persists across respawns

    local badgeText = Instance.new("TextLabel")
    badgeText.Parent = screenGui
    badgeText.Size = UDim2.new(0, 200, 0, 50)
    badgeText.Position = UDim2.new(0, 10, 0, 10)
    badgeText.Text = "c00lB0yGUI"
    badgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    badgeText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    badgeText.BackgroundTransparency = 0.5
    badgeText.TextSize = 18
    badgeText.Font = Enum.Font.GothamBold
    badgeText.TextXAlignment = Enum.TextXAlignment.Center
    badgeText.TextYAlignment = Enum.TextYAlignment.Center
    badgeText.BorderSizePixel = 2
    badgeText.BorderColor3 = Color3.fromRGB(0, 255, 0)

    local flightBadge = Instance.new("TextLabel")
    flightBadge.Parent = screenGui
    flightBadge.Size = UDim2.new(0, 200, 0, 50)
    flightBadge.Position = UDim2.new(0, 10, 0, 70)
    flightBadge.Text = "Fly: off"
    flightBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
    flightBadge.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    flightBadge.BackgroundTransparency = 0.5
    flightBadge.TextSize = 18
    flightBadge.Font = Enum.Font.GothamBold
    flightBadge.TextXAlignment = Enum.TextXAlignment.Center
    flightBadge.TextYAlignment = Enum.TextYAlignment.Center
    flightBadge.BorderSizePixel = 2
    flightBadge.BorderColor3 = Color3.fromRGB(0, 255, 0)

    local noclipBadge = Instance.new("TextLabel")
    noclipBadge.Parent = screenGui
    noclipBadge.Size = UDim2.new(0, 200, 0, 50)
    noclipBadge.Position = UDim2.new(0, 10, 0, 130)
    noclipBadge.Text = "Noclip: off"
    noclipBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
    noclipBadge.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    noclipBadge.BackgroundTransparency = 0.5
    noclipBadge.TextSize = 18
    noclipBadge.Font = Enum.Font.GothamBold
    noclipBadge.TextXAlignment = Enum.TextXAlignment.Center
    noclipBadge.TextYAlignment = Enum.TextYAlignment.Center
    noclipBadge.BorderSizePixel = 2
    noclipBadge.BorderColor3 = Color3.fromRGB(0, 255, 0)

    local sprintBadge = Instance.new("TextLabel")
    sprintBadge.Parent = screenGui
    sprintBadge.Size = UDim2.new(0, 200, 0, 50)
    sprintBadge.Position = UDim2.new(0, 10, 0, 190)
    sprintBadge.Text = "Sprint: off"
    sprintBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
    sprintBadge.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    sprintBadge.BackgroundTransparency = 0.5
    sprintBadge.TextSize = 18
    sprintBadge.Font = Enum.Font.GothamBold
    sprintBadge.TextXAlignment = Enum.TextXAlignment.Center
    sprintBadge.TextYAlignment = Enum.TextYAlignment.Center
    sprintBadge.BorderSizePixel = 2
    sprintBadge.BorderColor3 = Color3.fromRGB(0, 255, 0)

    local helpWindow = Instance.new("TextLabel")
    helpWindow.Parent = screenGui
    helpWindow.Size = UDim2.new(0, 300, 0, 150)
    helpWindow.Position = UDim2.new(0, 220, 0, 10)
    helpWindow.Text = "HotKey:\nF - Fly\nR - Noclip\nShift - Sprint\nT - teleport of cursor\nZ - ESP"
    helpWindow.TextColor3 = Color3.fromRGB(255, 255, 255)
    helpWindow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    helpWindow.BackgroundTransparency = 0.5
    helpWindow.TextSize = 18
    helpWindow.Font = Enum.Font.GothamBold
    helpWindow.TextXAlignment = Enum.TextXAlignment.Left
    helpWindow.TextYAlignment = Enum.TextYAlignment.Top
    helpWindow.BorderSizePixel = 2
    helpWindow.BorderColor3 = Color3.fromRGB(0, 255, 0)

    local toggleHelpButton = Instance.new("TextButton")
    toggleHelpButton.Parent = screenGui
    toggleHelpButton.Size = UDim2.new(0, 200, 0, 50)
    toggleHelpButton.Position = UDim2.new(0, 700, 0, 70)
    toggleHelpButton.Text = "hide help list"
    toggleHelpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleHelpButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    toggleHelpButton.BackgroundTransparency = 0.5
    toggleHelpButton.TextSize = 18
    toggleHelpButton.Font = Enum.Font.GothamBold
    toggleHelpButton.TextXAlignment = Enum.TextXAlignment.Center
    toggleHelpButton.TextYAlignment = Enum.TextYAlignment.Center
    toggleHelpButton.BorderSizePixel = 2
    toggleHelpButton.BorderColor3 = Color3.fromRGB(0, 255, 0)

    local helpVisible = true
    toggleHelpButton.MouseButton1Click:Connect(function()
        helpVisible = not helpVisible
        helpWindow.Visible = helpVisible
        toggleHelpButton.Text = helpVisible and "hide help list" or "show help list"
    end)

    local supportWindow = Instance.new("TextLabel")
    supportWindow.Parent = screenGui
    supportWindow.Size = UDim2.new(0, 300, 0, 150)
    supportWindow.Position = UDim2.new(0, 220, 0, 10)
    supportWindow.Text = "АААААААА"
    supportWindow.TextColor3 = Color3.fromRGB(255, 255, 255)
    supportWindow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    supportWindow.BackgroundTransparency = 0.5
    supportWindow.TextSize = 18
    supportWindow.Font = Enum.Font.GothamBold
    supportWindow.TextXAlignment = Enum.TextXAlignment.Left
    supportWindow.TextYAlignment = Enum.TextYAlignment.Top
    supportWindow.BorderSizePixel = 2
    supportWindow.BorderColor3 = Color3.fromRGB(0, 255, 0)
    supportWindow.Visible = false
    supportWindow.TextWrapped = true

    local togglesupportButton = Instance.new("TextButton")
    togglesupportButton.Parent = screenGui
    togglesupportButton.Size = UDim2.new(0, 200, 0, 50)
    togglesupportButton.Position = UDim2.new(0, 700, 0, 10)
    togglesupportButton.Text = "show support list"
    togglesupportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    togglesupportButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    togglesupportButton.BackgroundTransparency = 0.5
    togglesupportButton.TextSize = 18
    togglesupportButton.Font = Enum.Font.GothamBold
    togglesupportButton.TextXAlignment = Enum.TextXAlignment.Center
    togglesupportButton.TextYAlignment = Enum.TextYAlignment.Center
    togglesupportButton.BorderSizePixel = 2
    togglesupportButton.BorderColor3 = Color3.fromRGB(0, 255, 0)

    local supportVisible = false
    togglesupportButton.MouseButton1Click:Connect(function()
        supportVisible = not supportVisible
        supportWindow.Visible = supportVisible
        togglesupportButton.Text = supportVisible and "hide support list" or "show support list"
    end)

    local espBadge = Instance.new("TextLabel")
    espBadge.Parent = screenGui
    espBadge.Size = UDim2.new(0, 200, 0, 50)
    espBadge.Position = UDim2.new(0, 10, 0, 310)
    espBadge.Text = "ESP: off"
    espBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
    espBadge.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    espBadge.BackgroundTransparency = 0.5
    espBadge.TextSize = 18
    espBadge.Font = Enum.Font.GothamBold
    espBadge.TextXAlignment = Enum.TextXAlignment.Center
    espBadge.TextYAlignment = Enum.TextYAlignment.Center
    espBadge.BorderSizePixel = 2
    espBadge.BorderColor3 = Color3.fromRGB(0, 255, 0)

    local spectateInput = Instance.new("TextBox")
    spectateInput.Parent = screenGui
    spectateInput.Size = UDim2.new(0, 200, 0, 40)
    spectateInput.Position = UDim2.new(0, 700, 0, 310)
    spectateInput.PlaceholderText = "Enter username"
    spectateInput.Text = ""
    spectateInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    spectateInput.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    spectateInput.BackgroundTransparency = 0.5
    spectateInput.TextSize = 18
    spectateInput.Font = Enum.Font.GothamBold
    spectateInput.BorderSizePixel = 2
    spectateInput.BorderColor3 = Color3.fromRGB(0, 255, 0)

    local spectateButton = Instance.new("TextButton")
    spectateButton.Parent = screenGui
    spectateButton.Size = UDim2.new(0, 200, 0, 40)
    spectateButton.Position = UDim2.new(0, 700, 0, 180)
    spectateButton.Text = "Spectate"
    spectateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    spectateButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    spectateButton.BackgroundTransparency = 0.5
    spectateButton.TextSize = 18
    spectateButton.Font = Enum.Font.GothamBold
    spectateButton.BorderSizePixel = 2
    spectateButton.BorderColor3 = Color3.fromRGB(0, 255, 0)

    local stopSpectateButton = Instance.new("TextButton")
    stopSpectateButton.Parent = screenGui
    stopSpectateButton.Size = UDim2.new(0, 200, 0, 40)
    stopSpectateButton.Position = UDim2.new(0, 700, 0, 230)
    stopSpectateButton.Text = "Stop Spectate"
    stopSpectateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopSpectateButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    stopSpectateButton.BackgroundTransparency = 0.5
    stopSpectateButton.TextSize = 18
    stopSpectateButton.Font = Enum.Font.GothamBold
    stopSpectateButton.BorderSizePixel = 2
    stopSpectateButton.BorderColor3 = Color3.fromRGB(255, 0, 0)

    stopSpectateButton.MouseButton1Click:Connect(function()
        workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Humanoid")
        supportWindow.Text = "Spectate stopped"
    end)

    local speedBox = Instance.new("TextBox")
    speedBox.Parent = screenGui
    speedBox.Size = UDim2.new(0, 200, 0, 50)
    speedBox.Position = UDim2.new(0, 10, 0, 250)
    speedBox.PlaceholderText = "Speed of fly"
    speedBox.Text = tostring(speed)
    speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    speedBox.BackgroundTransparency = 0.3
    speedBox.TextSize = 18
    speedBox.Font = Enum.Font.GothamBold
    speedBox.TextXAlignment = Enum.TextXAlignment.Center
    speedBox.ClearTextOnFocus = false
    speedBox.BorderSizePixel = 2
    speedBox.BorderColor3 = Color3.fromRGB(0, 255, 255)

    speedBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newSpeed = tonumber(speedBox.Text)
            if newSpeed then
                speed = newSpeed
            else
                speedBox.Text = tostring(speed)
            end
        end
    end)


    spectateButton.MouseButton1Click:Connect(function()
        local targetName = spectateInput.Text
        local targetPlayer = Players:FindFirstChild(targetName)

        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            workspace.CurrentCamera.CameraSubject = targetPlayer.Character:FindFirstChild("Humanoid")
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

            print("Spectating: " .. targetName)
        else
            print("Player not found or not loaded.")
        end
    end)

    local function startFlying()
        humanoid.PlatformStand = true
    
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 9e4
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.CFrame = humanoidRootPart.CFrame
        bodyGyro.Parent = humanoidRootPart
    
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Parent = humanoidRootPart
    
        RunService:BindToRenderStep("Flying", Enum.RenderPriority.Input.Value, function()
            bodyGyro.CFrame = workspace.CurrentCamera.CFrame
            bodyVelocity.Velocity = workspace.CurrentCamera.CFrame:VectorToWorldSpace(direction * speed)
        end)
    
        print("Flight started")
        flightBadge.Text = "Fly: on"
    end
    
    local function stopFlying()
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVelocity then bodyVelocity:Destroy() end
        RunService:UnbindFromRenderStep("Flying")
        humanoid.PlatformStand = false
    
        print("Flight stopped")
        flightBadge.Text = "Fly: off"
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        local key = input.KeyCode

        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
        
            local key = input.KeyCode
        
            if key == Enum.KeyCode.F then
                flying = not flying
                if flying then
                    startFlying()
                else
                    stopFlying()
                end
            end
        
            -- Update direction based on key input
            if key == Enum.KeyCode.W then
                direction = Vector3.new(0, 0, -1)
            elseif key == Enum.KeyCode.S then
                direction = Vector3.new(0, 0, 1)
            elseif key == Enum.KeyCode.A then
                direction = Vector3.new(-1, 0, 0)
            elseif key == Enum.KeyCode.D then
                direction = Vector3.new(1, 0, 0)
            elseif key == Enum.KeyCode.Space then
                direction = Vector3.new(0, 1, 0)
            elseif key == Enum.KeyCode.LeftControl then
                direction = Vector3.new(0, -1, 0)
            end
        end)

        if key == Enum.KeyCode.R then
            noclip = not noclip
            noclipBadge.Text = noclip and "Noclip: on" or "Noclip: off"
        end

        if key == Enum.KeyCode.T then
            local target = player:GetMouse().Hit
            if target then
                local newPosition = target.Position + Vector3.new(0, 5, 0)
                humanoidRootPart.CFrame = CFrame.new(newPosition)
            end
        end

        if key == Enum.KeyCode.LeftShift then
            shiftHeld = true
            if humanoid then
                humanoid.WalkSpeed = sprintSpeed
                sprintBadge.Text = "Sprint: on"
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if flying then
            direction = Vector3.zero
        end

        if input.KeyCode == Enum.KeyCode.LeftShift then
            shiftHeld = false
            if humanoid then
                humanoid.WalkSpeed = normalSpeed
                sprintBadge.Text = "Sprint: off"
            end
        end
    end)

-- Создание ESP лучей
local function createESPLine(fromPart, toPart)
    local attachment0 = Instance.new("Attachment", fromPart)
    local attachment1 = Instance.new("Attachment", toPart)

    local beam = Instance.new("Beam")
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Color = ColorSequence.new(Color3.new(0, 1, 0)) -- зелёный
    beam.Width0 = 0.1
    beam.Width1 = 0.1
    beam.FaceCamera = true
    beam.LightEmission = 1
    beam.Parent = fromPart

    table.insert(beams, {
        beam = beam,
        attachment0 = attachment0,
        attachment1 = attachment1
    })

    espBadge.Text = "ESP: on"
end

-- Очистка ESP
local function clearESP()
    for _, obj in ipairs(beams) do
        if obj.beam then obj.beam:Destroy() end
        if obj.attachment0 then obj.attachment0:Destroy() end
        if obj.attachment1 then obj.attachment1:Destroy() end
    end
    beams = {}

    -- Возврат прозрачности деталей Workspace
    for part, oldValue in pairs(originalTransparency) do
        if part and part:IsA("BasePart") then
            part.Transparency = oldValue
        end
    end
    originalTransparency = {}

    espBadge.Text = "ESP: off"
end

-- Воллхак — делает все детали в Workspace полупрозрачными
local function applyWallhack()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not Players:GetPlayerFromCharacter(obj:FindFirstAncestorOfClass("Model")) then
            originalTransparency[obj] = obj.Transparency
            obj.Transparency = 0.7
        end
    end
end

-- Включение/выключение ESP
local function toggleESP()
    espEnabled = not espEnabled
    clearESP()

    if espEnabled then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                createESPLine(humanoidRootPart, otherPlayer.Character.HumanoidRootPart)
            end
        end
        applyWallhack()
    end
end

-- Обработка новых игроков
Players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function()
        if espEnabled then
            task.wait(1)
            if newPlayer.Character and newPlayer.Character:FindFirstChild("HumanoidRootPart") then
                createESPLine(humanoidRootPart, newPlayer.Character.HumanoidRootPart)
            end
        end
    end)
end)

-- Клавиша Z для включения ESP
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Z then
        toggleESP()
    end
end)

RunService.Stepped:Connect(function()
    if noclip and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

local function resetStatuses()
    flying = false
    noclip = false
    shiftHeld = false
    espEnabled = false
    
    speed = 50
    direction = Vector3.new()

    flightBadge.Text = "Fly: off"
    noclipBadge.Text = "Noclip: off"
    sprintBadge.Text = "Sprint: off"
    humanoid.WalkSpeed = normalSpeed
end

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")

    if bodyGyro then bodyGyro:Destroy() end
    if bodyVelocity then bodyVelocity:Destroy() end

    resetStatuses()
    setupGUIAndConnections()
end)

setupGUIAndConnections()
humanoid.WalkSpeed = normalSpeed
