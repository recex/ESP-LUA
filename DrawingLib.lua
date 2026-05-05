local DrawingLib = {}

function DrawingLib.new(type, properties)
    local obj = Drawing.new(type)
    for prop, val in pairs(properties) do
        obj[prop] = val
    end
    return obj
end

function DrawingLib.getScreenPos(position)
    local camera = workspace.CurrentCamera
    local screenPos, onScreen = camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

return DrawingLib
