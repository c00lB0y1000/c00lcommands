local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Очистка старого GUI если есть
if player.PlayerGui:FindFirstChild("CheatHub") then
	player.PlayerGui:FindFirstChild("CheatHub"):Destroy()
end

-- Создание ScreenGui
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "CheatHub"
screenGui.ResetOnSpawn = false

-- Фон меню
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 300, 0, 250)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

-- Скруглённые углы
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 10)

-- Layout для кнопок
local uiList = Instance.new("UIListLayout", mainFrame)
uiList.Padding = UDim.new(0, 10)
uiList.FillDirection = Enum.FillDirection.Vertical
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.VerticalAlignment = Enum.VerticalAlignment.Center

-- Название
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -20, 0, 40)
title.Text = "Cheat Hub"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24

-- Хелпер для создания кнопок
local function createScriptButton(name, rawURL)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -40, 0, 40)
	button.Text = name
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.Gotham
	button.TextSize = 18
	button.Parent = mainFrame

	local corner = Instance.new("UICorner", button)
	corner.CornerRadius = UDim.new(0, 6)

	button.MouseButton1Click:Connect(function()
		-- Удаляем старый интерфейс если есть
		for _, v in pairs(player.PlayerGui:GetChildren()) do
			if v.Name == "InjectedCheat" then
				v:Destroy()
			end
		end

		-- Удаляем меню CheatHub
		screenGui:Destroy()

		-- Загружаем и выполняем скрипт
		local success, result = pcall(function()
			local scriptSource = game:HttpGet(rawURL)
			local func = loadstring(scriptSource)
			if func then
				func()
			end
		end)

		if not success then
			warn("Ошибка загрузки скрипта:", result)
		end
	end)
end

-- 🔗 Пример добавления скриптов из GitHub:
createScriptButton("ESP Script", "https://raw.githubusercontent.com/c00lB0y1000/c00lcommands/refs/heads/main/c00lBasic.lua")
createScriptButton("Fly Hack", "https://raw.githubusercontent.com/username/repo/main/fly.lua")
createScriptButton("Auto Farm", "https://raw.githubusercontent.com/username/repo/main/autofarm.lua")
