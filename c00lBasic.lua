local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Ожидаем RemoteEvent
local CMoonRemote = ReplicatedStorage:WaitForChild("CMoonRemote")

-- Создаем видимые всем эффекты
local function createEffectForAll(effectName, position)
    -- Отправляем на сервер, чтобы переслал всем
    CMoonRemote:FireServer(effectName, position)
end

-- Обработчик эффектов от других игроков
CMoonRemote.OnClientEvent:Connect(function(senderPlayer, effectName, position)
    if senderPlayer == Player then return end -- Свои эффекты мы обрабатываем отдельно
    
    if effectName == "GravityFlip" then
        spawnGravityFlipEffect(position)
    elseif effectName == "GravityPush" then
        spawnGravityPushEffect(position)
    end
end)

-- Эффекты (одинаковые для всех игроков)
function spawnGravityFlipEffect(position)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.7
    part.Color = Color3.fromRGB(255, 100, 100)
    part.Size = Vector3.new(10, 0.2, 10)
    part.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(90), 0, 0)
    part.Material = Enum.Material.Neon
    part.Parent = workspace
    
    -- Анимация
    local duration = 1.5
    local start = time()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = time() - start
        if elapsed > duration then
            connection:Disconnect()
            part:Destroy()
            return
        end
        
        local progress = elapsed/duration
        part.Transparency = 0.3 + progress*0.7
        part.Size = Vector3.new(10 + 15*progress, 0.2, 10 + 15*progress)
    end)
end

function spawnGravityPushEffect(position)
    local part = Instance.new("Part")
    part.Shape = Enum.PartType.Ball
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.5
    part.Color = Color3.fromRGB(200, 150, 255)
    part.Size = Vector3.new(5, 5, 5)
    part.Position = position
    part.Material = Enum.Material.Neon
    part.Parent = workspace
    
    local duration = 1.2
    local start = time()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = time() - start
        if elapsed > duration then
            connection:Disconnect()
            part:Destroy()
            return
        end
        
        local progress = elapsed/duration
        part.Size = Vector3.new(5 + 20*progress, 5 + 20*progress, 5 + 20*progress)
        part.Transparency = 0.5 + progress*0.5
    end)
end

-- Управление способностями
local abilities = {
    {
        name = "Gravity Flip",
        key = Enum.KeyCode.Q,
        cooldown = 8,
        ready = true,
        action = function()
            local target = HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 15
            spawnGravityFlipEffect(target)
            createEffectForAll("GravityFlip", target)
        end
    },
    {
        name = "Gravity Push",
        key = Enum.KeyCode.E,
        cooldown = 4,
        ready = true,
        action = function()
            spawnGravityPushEffect(HumanoidRootPart.Position)
            createEffectForAll("GravityPush", HumanoidRootPart.Position)
        end
    }
}

-- Обработка ввода
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    for _, ability in ipairs(abilities) do
        if input.KeyCode == ability.key and ability.ready then
            ability.ready = false
            ability.action()
            
            task.delay(ability.cooldown, function()
                ability.ready = true
            end)
        end
    end
end)

-- Постоянная аура персонажа
local function createAura()
    local aura = Instance.new("Part")
    aura.Name = "CMoonAura"
    aura.Shape = Enum.PartType.Ball
    aura.Size = Vector3.new(12, 12, 12)
    aura.Transparency = 0.85
    aura.Color = Color3.fromRGB(255, 120, 120)
    aura.Material = Enum.Material.Neon
    aura.Anchored = false
    aura.CanCollide = false
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = HumanoidRootPart
    weld.Part1 = aura
    weld.Parent = aura
    
    aura.Parent = Character
    
    -- Анимация ауры
    RunService.Heartbeat:Connect(function()
        local pulse = math.sin(time() * 3) * 0.5 + 1
        aura.Size = Vector3.new(12 * pulse, 12 * pulse, 12 * pulse)
    end)
end

-- Инициализация
createAura()
print("C-Moon powers activated! Use Q (Flip) and E (Push)")
