--[[
    MÃ³dulo ESP
    ResponsÃ¡vel por toda a funcionalidade de visualizaÃ§Ã£o de jogadores
]]

local ESP = {}

-- Estado interno
local state = {
    enabled = false,
    boxEnabled = true,
    nameEnabled = true,
    healthEnabled = true,
    tracersEnabled = false,
    distanceEnabled = true,
    enemyColor = Color3.fromRGB(255, 0, 0),
    allyColor = Color3.fromRGB(0, 255, 0),
    teamColor = Color3.fromRGB(0, 100, 255),
    maxDistance = 500,
    showNPCs = false
}

-- Pasta para os elementos visuais
local ESPFolder = nil

-- FunÃ§Ã£o para obter o jogador local
local function getLocalPlayer()
    return game:GetService("Players").LocalPlayer
end

-- FunÃ§Ã£o para verificar se Ã© aliado
local function isAlly(player)
    local localPlayer = getLocalPlayer()
    if not localPlayer or not player then return false end
    
    if localPlayer.Team == player.Team then
        return true
    end
    return false
end

-- FunÃ§Ã£o para obter a cor baseada no tipo
local function getColor(player)
    local localPlayer = getLocalPlayer()
    
    if player == localPlayer then
        return state.teamColor
    elseif isAlly(player) then
        return state.allyColor
    else
        return state.enemyColor
    end
end

-- FunÃ§Ã£o para calcular distÃ¢ncia
local function getDistance(player)
    local localPlayer = getLocalPlayer()
    if not localPlayer or not player.Character then return nil end
    
    local localPos = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetPos = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not localPos or not targetPos then return nil end
    
    return (localPos.Position - targetPos.Position).Magnitude
end

-- FunÃ§Ã£o para criar outline (efeito de borda)
local function createOutline(parent, color, thickness)
    local outline = Instance.new("OutlineEffect")
    outline.Color = color
    outline.Visible = true
    outline.FillColor = Color3.new(0, 0, 0)
    outline.FillTransparency = 1
    outline.Transparency = 0
    
    if parent:IsA("BasePart") then
        local clone = parent:Clone()
        clone.Transparency = 1
        clone.Material = Enum.Material.SmoothPlastic
        clone.CastShadow = false
        clone.Anchored = true
        clone.CanCollide = false
        
        for _, child in ipairs(clone:GetChildren()) do
            if child:IsA("Decal") or child:IsA("Texture") then
                child:Destroy()
            end
        end
        
        clone.Parent = ESPFolder
        return clone
    end
    
    return nil
end

-- FunÃ§Ã£o para criar TextLabel no BillboardGui
local function createBillboardLabel(parent, text, textColor, textSize)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESPLabel"
    billboardGui.Size = UDim2.new(0, 100, 0, 30)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.Adornee = parent
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = ESPFolder
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 0.5
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.Text = text
    label.TextColor3 = textColor
    label.TextSize = textSize or 14
    label.Font = Enum.Font.GothamBold
    label.Parent = billboardGui
    
    return billboardGui
end

-- FunÃ§Ã£o para criar Box ESP
local function createBoxESP(player)
    if not player.Character then return end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local color = getColor(player)
    
    -- Cria um billboard para mostrar informaÃ§Ãµes
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESPBox"
    billboardGui.Size = UDim2.new(4, 0, 5, 0)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.Adornee = humanoidRootPart
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = ESPFolder
    
    -- Frame principal do box
    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "Box"
    boxFrame.Size = UDim2.new(1, 0, 1, 0)
    boxFrame.BackgroundTransparency = 1
    boxFrame.BorderSizePixel = 0
    boxFrame.Parent = billboardGui
    
    -- Bordas do box
    local corners = {
        {Offset = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0, 3, 0, 3)},  -- TopLeft
        {Offset = UDim2.new(1, -3, 0, 0), Size = UDim2.new(0, 3, 0, 3)},  -- TopRight
        {Offset = UDim2.new(0, 0, 1, -3), Size = UDim2.new(0, 3, 0, 3)},  -- BottomLeft
        {Offset = UDim2.new(1, -3, 1, -3), Size = UDim2.new(0, 3, 0, 3)}  -- BottomRight
    }
    
    for _, corner in ipairs(corners) do
        local cornerFrame = Instance.new("Frame")
        cornerFrame.Position = corner.Offset
        cornerFrame.Size = corner.Size
        cornerFrame.BackgroundColor3 = color
        cornerFrame.BorderSizePixel = 0
        cornerFrame.Parent = boxFrame
    end
    
    -- Nome do jogador
    if state.nameEnabled then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 0, -20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = color
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = boxFrame
    end
    
    -- DistÃ¢ncia
    if state.distanceEnabled then
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "Distance"
        distanceLabel.Size = UDim2.new(1, 0, 0, 15)
        distanceLabel.Position = UDim2.new(0, 0, 1, 0)
        distanceLabel.BackgroundTransparency = 1
        
        local dist = getDistance(player)
        distanceLabel.Text = dist and math.floor(dist) .. "m" or ""
        distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distanceLabel.TextSize = 11
        distanceLabel.Font = Enum.Font.Gotham
        distanceLabel.Parent = boxFrame
    end
    
    return billboardGui
end

-- FunÃ§Ã£o para criar Health Bar
local function createHealthBar(player)
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not humanoidRootPart then return end
    
    local color = getColor(player)
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "HealthBar"
    billboardGui.Size = UDim2.new(4, 0, 0.5, 0)
    billboardGui.StudsOffset = Vector3.new(0, 4, 0)
    billboardGui.Adornee = humanoidRootPart
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = ESPFolder
    
    -- Background
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bg.BorderSizePixel = 0
    bg.Parent = billboardGui
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = bg
    
    -- Health fill
    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = bg
    
    local healthCorner = Instance.new("UICorner")
    healthCorner.CornerRadius = UDim.new(0, 4)
    healthCorner.Parent = healthFill
    
    -- Atualiza a barra de vida
    local function updateHealthBar()
        local maxHealth = humanoid.MaxHealth
        local currentHealth = humanoid.Health
        local healthPercent = currentHealth / maxHealth
        
        healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
        
        -- Muda cor baseada na vida
        if healthPercent > 0.6 then
            healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        elseif healthPercent > 0.3 then
            healthFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        else
            healthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
    
    updateHealthBar()
    humanoid.HealthChanged:Connect(updateHealthBar)
    
    return billboardGui
end

-- FunÃ§Ã£o para criar Tracer
local function createTracer(player)
    if not player.Character then return end
    
    local localPlayer = getLocalPlayer()
    local localCharacter = localPlayer and localPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not localRoot or not targetRoot then return end
    
    local color = getColor(player)
    
    -- Cria ScreenGui para o tracer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Tracer"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = ESPFolder
    
    local line = Instance.new("LineHandleAdornment")
    line.Name = "Line"
    line.Thickness = 2
    line.Color = color
    line.Transparency = 0
    line.Adornee = localRoot
    line.Parent = screenGui
    
    -- Atualiza a posiÃ§Ã£o da linha
    local runService = game:GetService("RunService")
    local connection
    
    connection = runService.RenderStepped:Connect(function()
        if not state.tracersEnabled then
            connection:Disconnect()
            return
        end
        
        local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        
        line.Length = (localRoot.Position - targetRoot.Position).Magnitude
        line.CFrame = CFrame.lookAt(localRoot.Position, targetRoot.Position)
    end)
    
    return screenGui
end

-- FunÃ§Ã£o para adicionar ESP a um jogador
local function addESP(player)
    -- NÃ£o adicionar para o local player se nÃ£o configurado
    if player == getLocalPlayer() and not state.showLocalPlayer then return end
    
    -- Verifica se jÃ¡ tem ESP
    if player.Character and player.Character:FindFirstChild("ESPFolder") then return end
    
    -- Cria pasta para armazenar elementos do ESP
    local espFolder = Instance.new("Folder")
    espFolder.Name = "ESPFolder"
    espFolder.Parent = ESPFolder
    
    -- Adiciona Box ESP
    if state.boxEnabled then
        createBoxESP(player)
    end
    
    -- Adiciona Health Bar
    if state.healthEnabled then
        createHealthBar(player)
    end
    
    -- Adiciona Tracer
    if state.tracersEnabled then
        createTracer(player)
    end
end

-- FunÃ§Ã£o para remover ESP de um jogador
local function removeESP(player)
    local espFolder = ESPFolder:FindFirstChild("ESPFolder")
    if espFolder then
        espFolder:Destroy()
    end
end

-- FunÃ§Ã£o para limpar todos os ESPs
local function clearAllESP()
    for _, child in ipairs(ESPFolder:GetChildren()) do
        if child:IsA("Folder") or child:IsA("BillboardGui") or child:IsA("ScreenGui") then
            child:Destroy()
        end
    end
end

-- Inicializa o mÃ³dulo ESP
function ESP.init()
    -- Cria pasta principal para elementos visuais
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "ESPMainFolder"
    ESPFolder.Parent = workspace
    
    -- Conecta eventos de jogadores
    local players = game:GetService("Players")
    
    -- Adiciona ESP para jogadores jÃ¡ no jogo
    for _, player in ipairs(players:GetPlayers()) do
        if player ~= getLocalPlayer() or state.showLocalPlayer then
            if player.Character then
                addESP(player)
            end
            
            player.CharacterAdded:Connect(function(character)
                -- Espera o personagem carregar
                task.wait(0.5)
                if state.enabled then
                    addESP(player)
                end
            end)
        end
    end
    
    -- Adiciona ESP quando jogador entrar
    players.PlayerAdded:Connect(function(player)
        if player ~= getLocalPlayer() or state.showLocalPlayer then
            player.CharacterAdded:Connect(function(character)
                task.wait(0.5)
                if state.enabled then
                    addESP(player)
                end
            end)
        end
    end)
    
    -- Remove ESP quando jogador sair
    players.PlayerRemoving:Connect(function(player)
        removeESP(player)
    end)
    
    print("ESP inicializado!")
end

-- FunÃ§Ãµes de configuraÃ§Ã£o

function ESP.setEnabled(enabled)
    state.enabled = enabled
    
    if enabled then
        -- Mostra todos os jogadores
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= getLocalPlayer() then
                addESP(player)
            end
        end
    else
        clearAllESP()
    end
end

function ESP.setBoxEnabled(enabled)
    state.boxEnabled = enabled
    if not enabled then
        for _, billboard in ipairs(ESPFolder:GetDescendants()) do
            if billboard:IsA("BillboardGui") and billboard.Name == "ESPBox" then
                billboard:Destroy()
            end
        end
    else
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            addESP(player)
        end
    end
end

function ESP.setNameEnabled(enabled)
    state.nameEnabled = enabled
    for _, billboard in ipairs(ESPFolder:GetDescendants()) do
        if billboard:IsA("BillboardGui") and billboard:FindFirstChild("Name") then
            billboard.Name:Remove()
        end
    end
end

function ESP.setHealthEnabled(enabled)
    state.healthEnabled = enabled
    for _, billboard in ipairs(ESPFolder:GetDescendants()) do
        if billboard:IsA("BillboardGui") and billboard.Name == "HealthBar" then
            billboard:Destroy()
        end
    end
    if enabled then
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= getLocalPlayer() then
                createHealthBar(player)
            end
        end
    end
end

function ESP.setTracersEnabled(enabled)
    state.tracersEnabled = enabled
    if not enabled then
        for _, screenGui in ipairs(ESPFolder:GetChildren()) do
            if screenGui:IsA("ScreenGui") and screenGui.Name == "Tracer" then
                screenGui:Destroy()
            end
        end
    end
end

function ESP.setDistanceEnabled(enabled)
    state.distanceEnabled = enabled
end

function ESP.setEnemyColor(color)
    state.enemyColor = color
end

function ESP.setAllyColor(color)
    state.allyColor = color
end

function ESP.setTeamColor(color)
    state.teamColor = color
end

return ESP