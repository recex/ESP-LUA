--[[
    MÃ³dulo de UtilitÃ¡rios
    FunÃ§Ãµes auxiliares para o script
]]

local Utils = {}

-- FunÃ§Ã£o para verificar se o jogo estÃ¡ carregado
function Utils.waitForGame()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
end

-- FunÃ§Ã£o para criar um botÃ£o de toggle estilizado
function Utils.createToggleButton(parent, name, text, defaultState, onToggle)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = ToggleFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = ToggleFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = ToggleFrame
    
    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Size = UDim2.new(0, 50, 0, 25)
    button.Position = UDim2.new(1, -55, 0.5, -12.5)
    button.BackgroundColor3 = defaultState and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(100, 100, 100)
    button.BorderSizePixel = 0
    button.Text = defaultState and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.Parent = ToggleFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    local enabled = defaultState
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.BackgroundColor3 = enabled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(100, 100, 100)
        button.Text = enabled and "ON" or "OFF"
        onToggle(enabled)
    end)
    
    return {
        frame = ToggleFrame,
        button = button,
        isEnabled = function() return enabled end,
        setEnabled = function(state)
            enabled = state
            button.BackgroundColor3 = enabled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(100, 100, 100)
            button.Text = enabled and "ON" or "OFF"
        end
    }
end

-- FunÃ§Ã£o para criar um slider
function Utils.createSlider(parent, name, text, min, max, default, onChange)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = name
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = SliderFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -60, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = SliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0, 40, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = SliderFrame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Name = "SliderBG"
    sliderBg.Size = UDim2.new(1, -20, 0, 10)
    sliderBg.Position = UDim2.new(0, 10, 0, 32)
    sliderBg.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = SliderFrame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 5)
    sliderCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 5)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Name = "SliderButton"
    sliderButton.Size = UDim2.new(0, 20, 0, 20)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.BorderSizePixel = 0
    sliderButton.Text = ""
    sliderButton.Parent = sliderBg
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = sliderButton
    
    local currentValue = default
    local dragging = false
    
    local function updateSlider(value)
        value = math.clamp(value, min, max)
        currentValue = value
        valueLabel.Text = tostring(value)
        
        local percent = (value - min) / (max - min)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderButton.Position = UDim2.new(percent - 0.5, 0, 0.5, 0)
        
        onChange(value)
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    sliderBg.MouseButton1Down:Connect(function(x)
        dragging = true
        local pos = x - sliderBg.AbsolutePosition.X
        local percent = pos / sliderBg.AbsoluteSize.X
        updateSlider(min + (max - min) * percent)
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local pos = game:GetService("UserInputService"):GetMouseLocation().X - sliderBg.AbsolutePosition.X
            local percent = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
            updateSlider(min + (max - min) * percent)
        end
    end)
    
    updateSlider(default)
    
    return {
        frame = SliderFrame,
        getValue = function() return currentValue end,
        setValue = function(value) updateSlider(value) end
    }
end

-- FunÃ§Ã£o para notificar o usuÃ¡rio
function Utils.notify(text, duration)
    duration = duration or 3
    
    local NotificationGui = game:GetService("CoreGui"):FindFirstChild("NotificationGui")
    if not NotificationGui then
        NotificationGui = Instance.new("ScreenGui")
        NotificationGui.Name = "NotificationGui"
        NotificationGui.ResetOnSpawn = false
        NotificationGui.Parent = game:GetService("CoreGui")
    end
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 50)
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    notification.BorderSizePixel = 0
    notification.Parent = NotificationGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = notification
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.Parent = notification
    
    -- AnimaÃ§Ã£o de entrada
    notification.Position = UDim2.new(0.5, -150, 1, 50)
    notification:TweenPosition(UDim2.new(0.5, -150, 1, -60), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    
    -- Remove apÃ³s duraÃ§Ã£o
    task.delay(duration, function()
        notification:TweenPosition(UDim2.new(0.5, -150, 1, 50), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
        task.wait(0.3)
        notification:Destroy()
    end)
end

-- FunÃ§Ã£o para formatar distÃ¢ncia
function Utils.formatDistance(distance)
    if not distance then return "?" end
    
    if distance >= 1000 then
        return string.format("%.1fkm", distance / 1000)
    else
        return string.format("%.0fm", distance)
    end
end

-- FunÃ§Ã£o para verificar se o jogador estÃ¡ no ar
function Utils.isInAir(player)
    if not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    return humanoid.FloorMaterial == Enum.Material.Air
end

-- FunÃ§Ã£o para obter o ping do jogador
function Utils.getPing(player)
    local stats = player:GetNetworkPing()
    return math.floor(stats * 1000)
end

return Utils