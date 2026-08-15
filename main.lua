--[[
    UTG TROLLING GUI — O MELHOR GUI DE TROLLING
    By RECEX

    Recursos:
      🎯 Troll       — trolling em jogadores (matar, fling, spin, grab, etc.)
      🔄 Transformar — transformação de personagens (morphs estilo UTG V3)
      ✨ Fun         — fly, noclip, speed hack, poderes
      👁️ Visual      — ESP de jogadores, itens e NPCs
      🌍 Mundo       — trolling no mundo inteiro

    Compatível com Delta Executor, Fluxus, Hydrogen e outros executors.
    UI nativa (ScreenGui) — sem dependência de bibliotecas externas de UI.
]]

local ESP_BASE_URL = "https://raw.githubusercontent.com/recex/ESP-LUA/main/src/"

local function loadModule(path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(ESP_BASE_URL .. path))()
    end)
    if success then
        return result
    else
        warn("Falha ao carregar módulo: " .. path .. " | Erro: " .. tostring(result))
        return nil
    end
end

-- Carregar biblioteca de UI
local Interface = loadModule("ui/Interface.lua")
if not Interface then
    error("Não foi possível carregar a interface!")
end

-- Carregar módulos de funcionalidade
local Troll = loadModule("modules/Troll.lua")
local Transform = loadModule("modules/Transform.lua")
local Fun = loadModule("modules/Fun.lua")
local Visual = loadModule("modules/Visual.lua")
local World = loadModule("modules/World.lua")

-- Criar janela principal
local Window = Interface.CreateWindow({
    Title = "UTG TROLLING GUI",
    Subtitle = "by RECEX  •  O melhor GUI de trolling",
})

-- Estado compartilhado entre módulos
local Shared = {
    target = nil,
}
function Shared.SetTarget(p) Shared.target = p end
function Shared.GetTarget() return Shared.target end

-- Inicializar módulos
local modules = {
    { name = "Troll", mod = Troll },
    { name = "Transformar", mod = Transform },
    { name = "Fun", mod = Fun },
    { name = "Visual", mod = Visual },
    { name = "Mundo", mod = World },
}

for _, entry in ipairs(modules) do
    if entry.mod then
        local ok, err = pcall(function()
            entry.mod.Init(Window, Shared)
        end)
        if ok then
            print("[" .. entry.name .. "] Carregado com sucesso!")
        else
            warn("[" .. entry.name .. "] Erro ao inicializar: " .. tostring(err))
        end
    else
        warn("[" .. entry.name .. "] Módulo não encontrado.")
    end
end

-- Tecla para abrir/fechar a GUI
Window:ToggleKey(Enum.KeyCode.RightControl)

Window:Notification("UTG Trolling GUI", "Carregado com sucesso! Pressione RightControl para abrir/fechar.", 5)
print("UTG TROLLING GUI — Carregado com sucesso! By RECEX")
