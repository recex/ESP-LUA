--[[
    DrawingLib.lua — Wrapper da biblioteca Drawing
    UTG TROLLING GUI — By RECEX
]]

local DrawingLib = {}

-- Cria um objeto de desenho (Square, Text, Line, Circle, etc.)
function DrawingLib.new(type, properties)
    local obj = Drawing.new(type)
    for prop, val in pairs(properties) do
        obj[prop] = val
    end
    return obj
end

-- Converte posição 3D do mundo para coordenadas de tela.
-- Retorna: Vector2 (x, y), onScreen, profundidade (Z)
function DrawingLib.getScreenPos(position)
    local camera = workspace.CurrentCamera
    local screenPos, onScreen = camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

return DrawingLib
