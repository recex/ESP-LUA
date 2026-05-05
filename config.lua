--[[
    ConfiguraÃ§Ãµes do Script ESP
    Edite os valores aqui para personalizar
]]

local Config = {}

-- ============ CONFIGURAÃ‡Ã•ES DE ESP ============

-- Estado inicial dos mÃ³dulos
Config.espEnabled = true           -- ESP principal ativado
Config.boxEspEnabled = true        -- Box ao redor do jogador
Config.nameEspEnabled = true       -- Nome do jogador
Config.healthEspEnabled = true     -- Barra de vida
Config.tracersEnabled = false      -- Linhas atÃ© os jogadores
Config.distanceEnabled = true      -- DistÃ¢ncia atÃ© o jogador

-- ============ CORES ============

-- Cor para jogadores inimigos
Config.enemyColor = Color3.fromRGB(255, 0, 0)

-- Cor para aliados
Config.allyColor = Color3.fromRGB(0, 255, 0)

-- Cor para jogadores do mesmo time
Config.teamColor = Color3.fromRGB(0, 100, 255)

-- Cor para Box ESP
Config.boxColor = Color3.fromRGB(255, 255, 255)

-- Cor para Tracers
Config.tracerColor = Color3.fromRGB(255, 255, 255)

-- ============ OPÃ‡Ã•ES DE VISUALIZAÃ‡ÃƒO ============

-- Grossura das linhas
Config.lineThickness = 1

-- Tamanho do Box ESP
Config.boxSize = 2

-- Mostrar apenas jogadores visÃ­veis
Config.visibilityCheck = false

-- Alcance mÃ¡ximo do ESP (0 = infinito)
Config.maxDistance = 500

-- Mostrar NPCs
Config.showNPCs = false

-- Mostrar jogadores mortos
Config.showDeadPlayers = false

-- ============ OPÃ‡Ã•ES DE MENU ============

-- PosiÃ§Ã£o do menu
Config.menuPosition = UDim2.new(0, 20, 0, 20)

-- Cor de fundo do menu
Config.menuBackgroundColor = Color3.fromRGB(30, 30, 35)

-- Cor do texto do menu
Config.menuTextColor = Color3.fromRGB(255, 255, 255)

-- Opacidade do menu (0-1)
Config.menuOpacity = 1

return Config