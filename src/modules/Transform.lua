--[[
    Transform.lua — Transformação de personagens (morphs / skins)
    UTG TROLLING GUI — By RECEX
    Inclui transformações de tamanho, aparência, materiais e cópia de visual.
]]

local BASE = "https://raw.githubusercontent.com/recex/ESP-LUA/main/src/"
local Utility = loadstring(game:HttpGet(BASE .. "utils/Utility.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Transform = {}

-- Paleta de morphs clássicos (tema de transformação estilo UTG V3)
local MORPHS = {
    ["Normal"] = {
        Material = nil, Head = nil, Torso = nil, Arms = nil, Legs = nil, Scale = 1, Transparency = 0,
    },
    ["Dourado"] = {
        Material = Enum.Material.Metal,
        Head = Color3.fromRGB(255, 215, 0), Torso = Color3.fromRGB(255, 200, 0),
        Arms = Color3.fromRGB(255, 190, 0), Legs = Color3.fromRGB(255, 170, 0),
        Scale = 1, Transparency = 0,
    },
    ["Herobrine"] = {
        Material = Enum.Material.Plastic,
        Head = Color3.fromRGB(0, 170, 170), Torso = Color3.fromRGB(0, 150, 150),
        Arms = Color3.fromRGB(0, 140, 140), Legs = Color3.fromRGB(0, 130, 130),
        Scale = 1, Transparency = 0,
    },
    ["Demônio de Fogo"] = {
        Material = Enum.Material.Neon,
        Head = Color3.fromRGB(255, 40, 40), Torso = Color3.fromRGB(40, 0, 0),
        Arms = Color3.fromRGB(120, 0, 0), Legs = Color3.fromRGB(60, 0, 0),
        Scale = 1.2, Transparency = 0,
    },
    ["Fantasma de Gelo"] = {
        Material = Enum.Material.Glass,
        Head = Color3.fromRGB(160, 230, 255), Torso = Color3.fromRGB(120, 200, 255),
        Arms = Color3.fromRGB(100, 180, 255), Legs = Color3.fromRGB(80, 160, 255),
        Scale = 1, Transparency = 0.35,
    },
    ["Galáxia"] = {
        Material = Enum.Material.Neon,
        Head = Color3.fromRGB(140, 80, 255), Torso = Color3.fromRGB(60, 30, 160),
        Arms = Color3.fromRGB(90, 50, 220), Legs = Color3.fromRGB(40, 20, 120),
        Scale = 1, Transparency = 0,
    },
    ["Neon Verde"] = {
        Material = Enum.Material.Neon,
        Head = Color3.fromRGB(0, 255, 80), Torso = Color3.fromRGB(0, 200, 60),
        Arms = Color3.fromRGB(0, 170, 50), Legs = Color3.fromRGB(0, 140, 40),
        Scale = 1, Transparency = 0,
    },
    ["Sombra"] = {
        Material = Enum.Material.Slate,
        Head = Color3.fromRGB(20, 20, 25), Torso = Color3.fromRGB(15, 15, 20),
        Arms = Color3.fromRGB(15, 15, 20), Legs = Color3.fromRGB(10, 10, 15),
        Scale = 1, Transparency = 0.2,
    },
    ["Caveira"] = {
        Material = Enum.Material.SmoothPlastic,
        Head = Color3.fromRGB(245, 245, 245), Torso = Color3.fromRGB(30, 30, 35),
        Arms = Color3.fromRGB(30, 30, 35), Legs = Color3.fromRGB(30, 30, 35),
        Scale = 1, Transparency = 0,
    },
}

local morphNames = {}
for name, _ in pairs(MORPHS) do
    table.insert(morphNames, name)
end
table.sort(morphNames)

local function getParts(player)
    local char = Utility.GetCharacter(player)
    local parts = { Head = nil, Torso = nil, Arms = {}, Legs = {}, Other = {} }
    if not char then return parts end

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local n = part.Name:lower()
            if n == "head" then
                parts.Head = part
            elseif n:find("torso") or n == "upperleg" or n == "lowerleg" then
                if n:find("leg") then
                    table.insert(parts.Legs, part)
                else
                    parts.Torso = part
                end
            elseif n:find("arm") or n:find("hand") then
                table.insert(parts.Arms, part)
            elseif n:find("leg") then
                table.insert(parts.Legs, part)
            else
                table.insert(parts.Other, part)
            end
        end
    end
    return parts
end

local function applyMorph(player, morph)
    local char = Utility.GetCharacter(player)
    if not char then return end

    local parts = getParts(player)
    local all = {}
    local function add(t)
        for _, p in pairs(t) do if p then table.insert(all, p) end end
    end
    add(parts.Arms)
    add(parts.Legs)
    add(parts.Other)
    if parts.Head then table.insert(all, parts.Head) end
    if parts.Torso then table.insert(all, parts.Torso) end

    for _, part in pairs(all) do
        if morph.Material then
            part.Material = morph.Material
        end
        part.Transparency = morph.Transparency or 0
    end

    if morph.Head and parts.Head then parts.Head.Color = morph.Head end
    if morph.Torso and parts.Torso then parts.Torso.Color = morph.Torso end
    for _, p in pairs(parts.Arms) do if morph.Arms then p.Color = morph.Arms end end
    for _, p in pairs(parts.Legs) do if morph.Legs then p.Color = morph.Legs end end

    local hum = Utility.GetHumanoid(player)
    if hum then
        hum.HipHeight = 2 * (morph.Scale or 1)
    end
end

local function copyAppearance(from, to)
    local fromParts = getParts(from)
    local toParts = getParts(to)

    if fromParts.Head and toParts.Head then
        toParts.Head.Color = fromParts.Head.Color
        toParts.Head.Material = fromParts.Head.Material
    end
    if fromParts.Torso and toParts.Torso then
        toParts.Torso.Color = fromParts.Torso.Color
        toParts.Torso.Material = fromParts.Torso.Material
    end
    -- Copia cores dos braços e pernas
    local function copyList(src, dst)
        for i, p in pairs(dst) do
            local s = src[i]
            if s then
                p.Color = s.Color
                p.Material = s.Material
            end
        end
    end
    copyList(fromParts.Arms, toParts.Arms)
    copyList(fromParts.Legs, toParts.Legs)
end

function Transform.Init(Window, Shared)
    local Tab = Window:Tab("Transformar", "🔄")

    ------------------------------------------------------------------
    local Morphs = Tab:Section("Morphs (Transformações)")
    Morphs:Label("Escolha uma transformação de personagem:")

    local morphDropdown = Morphs:Dropdown("Transformação", morphNames, "Normal", function(name)
        local p = LocalPlayer
        applyMorph(p, MORPHS[name] or MORPHS["Normal"])
        Window:Notification("Transformar", "Você virou: " .. name .. "!")
    end)

    Morphs:Button("Aplicar", function()
        local name = morphDropdown.GetValue()
        applyMorph(LocalPlayer, MORPHS[name] or MORPHS["Normal"])
        Window:Notification("Transformar", "Transformação aplicada: " .. name .. "!")
    end)

    ------------------------------------------------------------------
    local Size = Tab:Section("Tamanho")

    Size:Button("Gigante (2.5x)", function()
        Utility.SetScale(LocalPlayer, 2.5)
    end)
    Size:Button("Mini (0.4x)", function()
        Utility.SetScale(LocalPlayer, 0.4)
    end)
    Size:Button("Normal", function()
        Utility.SetScale(LocalPlayer, 1)
    end)

    Size:Slider("Tamanho manual", 0.2, 5, 1, function(v)
        Utility.SetScale(LocalPlayer, v)
    end)

    ------------------------------------------------------------------
    local Body = Tab:Section("Proporções do Corpo")

    local function stretchAxis(axis, factor)
        local char = Utility.GetCharacter(LocalPlayer)
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                if axis == "X" then
                    part.Size = Vector3.new(part.Size.X * factor, part.Size.Y, part.Size.Z)
                elseif axis == "Y" then
                    part.Size = Vector3.new(part.Size.X, part.Size.Y * factor, part.Size.Z)
                elseif axis == "Z" then
                    part.Size = Vector3.new(part.Size.X, part.Size.Y, part.Size.Z * factor)
                end
            end
        end
    end

    Body:Button("Pauzão (magro)", function() stretchAxis("X", 0.4); stretchAxis("Z", 0.4) end)
    Body:Button("Largão (gordo)", function() stretchAxis("X", 2); stretchAxis("Z", 2) end)
    Body:Button("Chapado (flat)", function() stretchAxis("Y", 0.3) end)
    Body:Button("Altão", function() stretchAxis("Y", 1.6) end)
    Body:Button("Resetar corpo", function()
        Utility.SetScale(LocalPlayer, 1)
        applyMorph(LocalPlayer, MORPHS["Normal"])
    end)

    ------------------------------------------------------------------
    local Visual = Tab:Section("Visual / Material")

    Visual:Button("Modo Neon", function()
        local char = Utility.GetCharacter(LocalPlayer)
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Neon
            end
        end
    end)

    Visual:Button("Modo Vidro (Glass)", function()
        local char = Utility.GetCharacter(LocalPlayer)
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Glass
                part.Transparency = 0.3
            end
        end
    end)

    Visual:Button("Modo Ouro", function()
        applyMorph(LocalPlayer, MORPHS["Dourado"])
    end)

    local rainbowLoop = nil
    Visual:Toggle("Arco-íris (self)", false, function(v)
        if rainbowLoop then rainbowLoop:Disconnect(); rainbowLoop = nil end
        if v then
            rainbowLoop = RunService.RenderStepped:Connect(function()
                Utility.SetColor(LocalPlayer, Color3.fromHSV(tick() % 1, 1, 1))
            end)
        end
    end)

    Visual:Toggle("Fantasma (invisível)", false, function(v)
        Utility.SetInvisible(LocalPlayer, v)
    end)

    ------------------------------------------------------------------
    local Copy = Tab:Section("Copiar Visual")

    Copy:Label("Copie a aparência de outro jogador.")
    local copyTarget = nil
    Copy:Dropdown("Copiar de", Utility.GetPlayers(), nil, function(name)
        copyTarget = Utility.FindPlayer(name)
    end)

    Copy:Button("Virar esse jogador (cópia)", function()
        local p = copyTarget or Shared.GetTarget()
        if not p then
            Window:Notification("Transformar", "Selecione um jogador para copiar!", 2)
            return
        end
        copyAppearance(p, LocalPlayer)
        Window:Notification("Transformar", "Aparência copiada de " .. p.Name .. "!")
    end)

    Copy:Button("Copiar tamanho", function()
        local p = copyTarget or Shared.GetTarget()
        if not p then return end
        local theirHrp = Utility.GetHRP(p)
        local myHrp = Utility.GetHRP(LocalPlayer)
        if theirHrp and myHrp then
            local scale = theirHrp.Size.Y / myHrp.Size.Y
            Utility.SetScale(LocalPlayer, scale)
        end
    end)

    Window:Notification("Transformar", "Módulo de transformação carregado!")
end

return Transform
