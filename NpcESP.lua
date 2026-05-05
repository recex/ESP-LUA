local NpcESP = {}
local DrawingLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/src/utils/DrawingLib.lua"))()

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local espNpcs = {}

local function isNpc(model)
    return model:IsA("Model") and model:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(model)
end

local function createNpcESP(npc)
    local box = DrawingLib.new("Square", {
        Color = Color3.fromRGB(0, 255, 0),
        Thickness = 1,
        Filled = false,
        Visible = false
    })

    local name = DrawingLib.new("Text", {
        Text = npc.Name,
        Size = 16,
        Center = true,
        Outline = true,
        Color = Color3.fromRGB(255, 255, 255),
        Visible = false
    })

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if npc and npc:IsDescendantOf(Workspace) and npc:FindFirstChild("HumanoidRootPart") then
            local hrp = npc.HumanoidRootPart
            local pos, onScreen = DrawingLib.getScreenPos(hrp.Position)

            if onScreen then
                box.Size = Vector2.new(2000 / pos.Y, 3000 / pos.Y) -- Escala simples
                box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                box.Visible = true

                name.Position = Vector2.new(pos.X, pos.Y - box.Size.Y / 2 - 20)
                name.Visible = true
            else
                box.Visible = false
                name.Visible = false
            end
        else
            box.Visible = false
            name.Visible = false
        end
    end)

    espNpcs[npc] = {box = box, name = name, connection = connection}
end

function NpcESP.Init()
    for _, child in pairs(Workspace:GetChildren()) do
        if isNpc(child) then
            createNpcESP(child)
        end
    end

    Workspace.ChildAdded:Connect(function(child)
        if isNpc(child) then
            createNpcESP(child)
        end
    end)

    Workspace.ChildRemoved:Connect(function(child)
        if espNpcs[child] then
            espNpcs[child].box:Remove()
            espNpcs[child].name:Remove()
            espNpcs[child].connection:Disconnect()
            espNpcs[child] = nil
        end
    end)
end

return NpcESP
