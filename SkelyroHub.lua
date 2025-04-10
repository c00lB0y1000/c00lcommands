local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Главное меню GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.ResetOnSpawn = false
screenGui.Name = "CheatHub"

local currentUI -- сюда будет сохраняться текущий активный интерфейс чита

-- Хелпер для кнопок
local function createMenuButton(parent, position, text, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 200, 0, 40)
	button.Position = position
	button.Text = text
	button.Parent = parent
	button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 18
	button.BorderSizePixel = 2
	button.BorderColor3 = Color3.fromRGB(0, 255, 0)
	button.MouseButton1Click:Connect(callback)
	return button
end

-- Удаление текущего UI
local function clearCurrentUI()
	if currentUI then
		currentUI:Destroy()
		currentUI = nil
	end
end

-- Тестовые функции для разных плейсов
local function loadCheatForPlace1()
	clearCurrentUI()

	local ui = Instance.new("Frame")
	ui.Size = UDim2.new(0, 300, 0, 200)
	ui.Position = UDim2.new(0.5, -150, 0.5, -100)
	ui.AnchorPoint = Vector2.new(0.5, 0.5)
	ui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ui.BorderSizePixel = 2
	ui.BorderColor3 = Color3.fromRGB(0, 255, 0)
	ui.Parent = screenGui
	currentUI = ui

	local label = Instance.new("TextLabel", ui)
	label.Size = UDim2.new(1, 0, 0.3, 0)
	label.Text = "Place 1 Cheat Activated"
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 20

	createMenuButton(ui, UDim2.new(0, 50, 0, 100), "Back", function()
		clearCurrentUI()
		screenGui.Enabled = true
	end)
end

local function loadCheatForPlace2()
	clearCurrentUI()

	local ui = Instance.new("Frame")
	ui.Size = UDim2.new(0, 300, 0, 200)
	ui.Position = UDim2.new(0.5, -150, 0.5, -100)
	ui.AnchorPoint = Vector2.new(0.5, 0.5)
	ui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ui.BorderSizePixel = 2
	ui.BorderColor3 = Color3.fromRGB(255, 0, 0)
	ui.Parent = screenGui
	currentUI = ui

	local label = Instance.new("TextLabel", ui)
	label.Size = UDim2.new(1, 0, 0.3, 0)
	label.Text = "Place 2 Cheat Activated"
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 20

	createMenuButton(ui, UDim2.new(0, 50, 0, 100), "Back", function()
		clearCurrentUI()
		screenGui.Enabled = true
	end)
end

-- Главное меню кнопок
createMenuButton(screenGui, UDim2.new(0, 50, 0, 50), "Cheat for Place 1", function()
	screenGui.Enabled = false
	loadCheatForPlace1()
end)

createMenuButton(screenGui, UDim2.new(0, 50, 0, 110), "Cheat for Place 2", function()
	screenGui.Enabled = false
	loadCheatForPlace2()
end)
