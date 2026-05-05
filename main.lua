--[[
    ESP Script Profissional
    Organizado por Manus AI
    Compatível com Delta Executor
]]

local ESP_BASE_URL = "https://raw.githubusercontent.com/SEU_USUARIO/ESP-LUA/main/src/"

local function loadModule(path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(ESP_BASE_URL .. path))()
    end)
    if success then
        return result
    else
        warn("Falha ao carregar módulo: " .. path .. " | Erro: " .. tostring(result))
    end
end

-- Carregar Módulos
local PlayerESP = loadModule("modules/PlayerESP.lua")
local ItemESP = loadModule("modules/ItemESP.lua")
local NpcESP = loadModule("modules/NpcESP.lua")

-- Inicializar
if PlayerESP then
    PlayerESP.Init()
    print("ESP de Jogadores Inicializado!")
end

if ItemESP then
    ItemESP.Init()
    print("ESP de Itens Inicializado!")
end

if NpcESP then
    NpcESP.Init()
    print("ESP de NPCs Inicializado!")
end

print("Script ESP Carregado com Sucesso!")
