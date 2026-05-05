local ItemESP = {}
local DrawingLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/src/utils/DrawingLib.lua"))()

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local espItems = {}

local function createItemESP(item)
    local name = DrawingLib.new("Text", {
        Text = item.Name,
        Size = 16,
        Center = true,
        Outline = true,
        Color = Color3.fromRGB(0, 255, 255),
        Visible = false
    })

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if item and item:IsDescendantOf(Workspace) and item:IsA("BasePart") then
            local pos, onScreen = DrawingLib.getScreenPos(item.Position)

            if onScreen then
                name.Position = Vector2.new(pos.X, pos.Y)
                name.Visible = true
            else
                name.Visible = false
            end
        else
            name:Remove()
            connection:Disconnect()
            espItems[item] = nil
        end
    end)

    espItems[item] = {name = name, connection = connection}
end

function ItemESP.Init()
    for _, child in pairs(Workspace:GetChildren()) do
        if child:IsA("BasePart") and not child:IsA("Accessory") and not child:IsA("Tool") and not child:IsA("Model") then -- Filtro básico
            createItemESP(child)
        end
    end

    Workspace.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") and not child:IsA("Accessory") and not child:IsA("Tool") and not child:IsA("Model") then
            createItemESP(child)
        end
    end)

    Workspace.ChildRemoved:Connect(function(child)
        if espItems[child] then
            espItems[child].name:Remove()
            espItems[child].connection:Disconnect()
            espItems[child] = nil
        end
    end)
end

return ItemESP
