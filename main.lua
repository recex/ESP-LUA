--[[
    Delta Executor ESP Script
    Arquivo principal
]]

-- Carrega configuraÃ§Ãµes
local Config = require("config")

-- Carrega utilitÃ¡rios
local Utils = require("utils")

-- Carrega mÃ³dulo ESP
local ESP = require("esp")

-- Menu principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESPMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Toggle principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- TÃ­tulo
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "ESP Script v1.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Toggle ESP
local function CreateToggle(name, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "Frame"
    ToggleFrame.Size = UDim2.new(1, -20, 0, 35)
    ToggleFrame.Position = UDim2.new(0, 10, 0, 60)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = MainFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 14
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Button"
    ToggleButton.Size = UDim2.new(0, 50, 0, 25)
    ToggleButton.Position = UDim2.new(1, -60, 0.5, -12.5)
    ToggleButton.BackgroundColor3 = default and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(100, 100, 100)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = default and "ON" or "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 12
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = ToggleFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = ToggleButton
    
    local enabled = default
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        ToggleButton.BackgroundColor3 = enabled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(100, 100, 100)
        ToggleButton.Text = enabled and "ON" or "OFF"
        callback(enabled)
    end)
    
    return ToggleFrame
end

-- Cria toggles
local espEnabled = false
CreateToggle("ESP", "ðŸƒ Player ESP", Config.espEnabled, function(state)
    espEnabled = state
    ESP.setEnabled(state)
end)

CreateToggle("BoxESP", "ðŸ“¦ Box ESP", Config.boxEspEnabled, function(state)
    ESP.setBoxEnabled(state)
end)

CreateToggle("NameESP", "ðŸ‘¤ Nome ESP", Config.nameEspEnabled, function(state)
    ESP.setNameEnabled(state)
end)

CreateToggle("HealthESP", "â¤ï¸ Vida ESP", Config.healthEspEnabled, function(state)
    ESP.setHealthEnabled(state)
end)

CreateToggle("Tracers", "ï¿½ï¸ Tracers", Config.tracersEnabled, function(state)
    ESP.setTracersEnabled(state)
end)

CreateToggle("Distance", "ðŸ“ DistÃ¢ncia", Config.distanceEnabled, function(state)
    ESP.setDistanceEnabled(state)
end)

-- Controles de cor
local ColorSection = Instance.new("Frame")
ColorSection.Name = "ColorSection"
ColorSection.Size = UDim2.new(1, -20, 0, 120)
ColorSection.Position = UDim2.new(0, 10, 0, 260)
ColorSection.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
ColorSection.BorderSizePixel = 0
ColorSection.Parent = MainFrame

local ColorCorner = Instance.new("UICorner")
ColorCorner.CornerRadius = UDim.new(0, 8)
ColorCorner.Parent = ColorSection

local ColorTitle = Instance.new("TextLabel")
ColorTitle.Size = UDim2.new(1, 0, 0, 25)
ColorTitle.Position = UDim2.new(0, 10, 0, 5)
ColorTitle.BackgroundTransparency = 1
ColorTitle.Text = "ðŸŽ¨ Cores do ESP"
ColorTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorTitle.TextSize = 12
ColorTitle.Font = Enum.Font.GothamBold
ColorTitle.TextXAlignment = Enum.TextXAlignment.Left
ColorTitle.Parent = ColorSection

local function CreateColorSlider(name, text, defaultColor, yPos, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 25)
    SliderFrame.Position = UDim2.new(0, 10, 0, yPos)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = ColorSection
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local ColorPreview = Instance.new("TextButton")
    ColorPreview.Size = UDim2.new(0, 40, 0, 20)
    ColorPreview.Position = UDim2.new(1, -45, 0.5, -10)
    ColorPreview.BackgroundColor3 = defaultColor
    ColorPreview.BorderSizePixel = 0
    ColorPreview.Text = ""
    ColorPreview.Parent = SliderFrame
    
    local PreviewCorner = Instance.new("UICorner")
    PreviewCorner.CornerRadius = UDim.new(0, 4)
    PreviewCorner.Parent = ColorPreview
    
    -- Ciclo de cores predefinidas
    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 165, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(255, 255, 255)
    }
    local colorIndex = 1
    
    ColorPreview.MouseButton1Click:Connect(function()
        colorIndex = (colorIndex % #colors) + 1
        ColorPreview.BackgroundColor3 = colors[colorIndex]
        callback(colors[colorIndex])
    end)
end

CreateColorSlider("EnemyColor", "Inimigo", Config.enemyColor, 30, function(color)
    ESP.setEnemyColor(color)
end)

CreateColorSlider("AllyColor", "Aliado", Config.allyColor, 55, function(color)
    ESP.setAllyColor(color)
end)

CreateColorSlider("TeamColor", "Time", Config.teamColor, 80, function(color)
    ESP.setTeamColor(color)
end)

-- Inicializa ESP
ESP.init()

print("ESP Script carregado com sucesso!")