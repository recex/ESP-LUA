--[[
    Visual.lua — ESP (players, itens, NPCs) integrado à GUI
    UTG TROLLING GUI — By RECEX
]]

local BASE = "https://raw.githubusercontent.com/recex/ESP-LUA/main/src/"
local DrawingLib = loadstring(game:HttpGet(BASE .. "utils/DrawingLib.lua"))()
local Utility = loadstring(game:HttpGet(BASE .. "utils/Utility.lua"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Visual = {}

local State = {
    players = false,
    items = false,
    npcs = false,
    boxes = true,
    names = true,
    distance = true,
}

-- Conexões ativas
local activePlayers = {}
local activeItems = {}
local activeNpcs = {}

local function makeBox(color)
    return DrawingLib.new("Square", {
        Color = color,
        Thickness = 1.5,
        Filled = false,
        Visible = false,
    })
end

local function makeText(color, size)
    return DrawingLib.new("Text", {
        Size = size or 16,
        Center = true,
        Outline = true,
        Color = color,
        Visible = false,
    })
end

----------------------------------------------------------------
-- PLAYER ESP
----------------------------------------------------------------
local function createPlayerESP(player)
    local box = makeBox(Color3.fromRGB(255, 70, 70))
    local name = makeText(Color3.fromRGB(255, 255, 255), 17)

    local conn = RunService.RenderStepped:Connect(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen, depth = DrawingLib.getScreenPos(hrp.Position)
            if onScreen then
                local scale = 1000 / math.max(depth, 0.001)
                local w = 2 * scale
                local h = 3 * scale
                if State.boxes then
                    box.Size = Vector2.new(w, h)
                    box.Position = Vector2.new(pos.X - w / 2, pos.Y - h / 2)
                    box.Visible = true
                end
                if State.names then
                    name.Position = Vector2.new(pos.X, pos.Y - h / 2 - 18)
                    name.Visible = true
                end
            else
                box.Visible = false
                name.Visible = false
            end
        else
            box.Visible = false
            name.Visible = false
        end
    end)

    local entry = { box = box, name = name, conn = conn }
    activePlayers[player] = entry
    return entry
end

local function startPlayerESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not activePlayers[p] then
            createPlayerESP(p)
        end
    end
    Players.PlayerAdded:Connect(function(p)
        if p ~= LocalPlayer and not activePlayers[p] then
            createPlayerESP(p)
        end
    end)
    Players.PlayerRemoving:Connect(function(p)
        local entry = activePlayers[p]
        if entry then
            entry.box:Remove()
            entry.name:Remove()
            entry.conn:Disconnect()
            activePlayers[p] = nil
        end
    end)
end

local function stopPlayerESP()
    for p, entry in pairs(activePlayers) do
        entry.box:Remove()
        entry.name:Remove()
        entry.conn:Disconnect()
        activePlayers[p] = nil
    end
end

----------------------------------------------------------------
-- ITEM ESP
----------------------------------------------------------------
local function isItem(obj)
    if not obj:IsA("BasePart") then return false end
    if obj:IsA("Accessory") or obj:IsA("Tool") then return false end
    if obj:FindFirstAncestorOfClass("Model") then
        local model = obj:FindFirstAncestorOfClass("Model")
        if Players:GetPlayerFromCharacter(model) then return false end
    end
    return true
end

local function createItemESP(item)
    local text = makeText(Color3.fromRGB(0, 220, 255), 14)
    local conn = RunService.RenderStepped:Connect(function()
        if item and item:IsDescendantOf(Workspace) then
            local pos, onScreen = DrawingLib.getScreenPos(item.Position)
            if onScreen then
                text.Text = item.Name
                text.Position = Vector2.new(pos.X, pos.Y)
                text.Visible = true
            else
                text.Visible = false
            end
        else
            text:Remove()
            conn:Disconnect()
            activeItems[item] = nil
        end
    end)
    activeItems[item] = { text = text, conn = conn }
end

local function startItemESP()
    for _, child in pairs(Workspace:GetDescendants()) do
        if isItem(child) then
            createItemESP(child)
        end
    end
    Workspace.DescendantAdded:Connect(function(child)
        if isItem(child) then
            createItemESP(child)
        end
    end)
end

local function stopItemESP()
    for item, entry in pairs(activeItems) do
        entry.text:Remove()
        entry.conn:Disconnect()
        activeItems[item] = nil
    end
end

----------------------------------------------------------------
-- NPC ESP
----------------------------------------------------------------
local function isNpc(model)
    return model:IsA("Model")
        and model:FindFirstChild("Humanoid")
        and model:FindFirstChild("HumanoidRootPart")
        and not Players:GetPlayerFromCharacter(model)
end

local function createNpcESP(npc)
    local box = makeBox(Color3.fromRGB(0, 220, 90))
    local name = makeText(Color3.fromRGB(255, 255, 255), 15)
    local conn = RunService.RenderStepped:Connect(function()
        if npc and npc:IsDescendantOf(Workspace) and npc:FindFirstChild("HumanoidRootPart") then
            local hrp = npc.HumanoidRootPart
            local pos, onScreen, depth = DrawingLib.getScreenPos(hrp.Position)
            if onScreen then
                local scale = 1000 / math.max(depth, 0.001)
                local w = 2 * scale
                local h = 3 * scale
                box.Size = Vector2.new(w, h)
                box.Position = Vector2.new(pos.X - w / 2, pos.Y - h / 2)
                box.Visible = State.boxes
                name.Text = npc.Name
                name.Position = Vector2.new(pos.X, pos.Y - h / 2 - 18)
                name.Visible = State.names
            else
                box.Visible = false
                name.Visible = false
            end
        else
            box.Visible = false
            name.Visible = false
        end
    end)
    activeNpcs[npc] = { box = box, name = name, conn = conn }
end

local function startNpcESP()
    for _, child in pairs(Workspace:GetChildren()) do
        if isNpc(child) then createNpcESP(child) end
    end
    Workspace.ChildAdded:Connect(function(child)
        if isNpc(child) then createNpcESP(child) end
    end)
end

local function stopNpcESP()
    for npc, entry in pairs(activeNpcs) do
        entry.box:Remove()
        entry.name:Remove()
        entry.conn:Disconnect()
        activeNpcs[npc] = nil
    end
end

----------------------------------------------------------------
function Visual.Init(Window, Shared)
    local Tab = Window:Tab("Visual", "👁️")

    local PlayersSec = Tab:Section("ESP de Jogadores")
    PlayersSec:Toggle("Ativar ESP (jogadores)", false, function(v)
        State.players = v
        if v then startPlayerESP() else stopPlayerESP() end
    end)
    PlayersSec:Toggle("Caixas (Boxes)", true, function(v) State.boxes = v end)
    PlayersSec:Toggle("Nomes", true, function(v) State.names = v end)

    local ItemsSec = Tab:Section("ESP de Itens")
    ItemsSec:Toggle("Ativar ESP (itens)", false, function(v)
        State.items = v
        if v then startItemESP() else stopItemESP() end
    end)

    local NpcsSec = Tab:Section("ESP de NPCs")
    NpcsSec:Toggle("Ativar ESP (NPCs)", false, function(v)
        State.npcs = v
        if v then startNpcESP() else stopNpcESP() end
    end)

    Window:Notification("Visual", "Módulo Visual (ESP) carregado!")
end

return Visual
