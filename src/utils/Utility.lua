--[[
    Utility.lua — Funções auxiliares
    UTG TROLLING GUI — By RECEX
]]

local Utility = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Retorna lista de nomes de jogadores (exceto o local)
function Utility.GetPlayers()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    if #names == 0 then
        table.insert(names, "(ninguém)")
    end
    return names
end

-- Encontra um jogador pelo nome
function Utility.FindPlayer(name)
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name == name then
            return p
        end
    end
    return nil
end

-- Pega o personagem de um jogador
function Utility.GetCharacter(player)
    if player and player.Character then
        return player.Character
    end
    return nil
end

-- Pega o HumanoidRootPart
function Utility.GetHRP(player)
    local char = Utility.GetCharacter(player)
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
    return nil
end

-- Pega o Humanoid
function Utility.GetHumanoid(player)
    local char = Utility.GetCharacter(player)
    if char and char:FindFirstChildOfClass("Humanoid") then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

-- Espera o personagem existir
function Utility.WaitForCharacter(player, timeout)
    timeout = timeout or 10
    local t = 0
    while t < timeout do
        local hrp = Utility.GetHRP(player)
        if hrp then return hrp end
        task.wait(0.1)
        t = t + 0.1
    end
    return nil
end

-- Teleporta um personagem para uma posição (via CFrame)
function Utility.Teleport(player, position)
    local hrp = Utility.GetHRP(player)
    if hrp then
        hrp.CFrame = CFrame.new(position) + Vector3.new(0, 3, 0)
    end
end

-- Aplica uma "fling" (impulso violento) no personagem
function Utility.Fling(player, power)
    local hrp = Utility.GetHRP(player)
    if hrp then
        power = power or 5000
        hrp.Velocity = Vector3.new(
            math.random(-1, 1) * power,
            power * 1.5,
            math.random(-1, 1) * power
        )
        hrp.AssemblyAngularVelocity = Vector3.new(
            math.random(-1, 1) * 50,
            math.random(-1, 1) * 50,
            math.random(-1, 1) * 50
        )
    end
end

-- Gira o personagem
function Utility.Spin(player, speed)
    local hrp = Utility.GetHRP(player)
    if hrp then
        local function spinLoop()
            while hrp and hrp.Parent do
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, speed or 0.5, 0)
                task.wait()
            end
        end
        task.spawn(spinLoop)
    end
end

-- Congela / descongela
function Utility.Freeze(player, state)
    local char = Utility.GetCharacter(player)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Anchored = state
        end
    end
end

-- Torna invisível
function Utility.SetInvisible(player, state)
    local char = Utility.GetCharacter(player)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = state and 1 or 0
        end
    end
    local hum = Utility.GetHumanoid(player)
    if hum then
        hum.NameOcclusion = state and Enum.NameOcclusion.NoOcclusion or Enum.NameOcclusion.OccludeAll
    end
end

-- Deixa o personagem neon (cor)
function Utility.SetColor(player, color)
    local char = Utility.GetCharacter(player)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = color
        end
    end
end

-- Tamanho do personagem (escala ABSOLUTA — idempotente)
local originalSizes = {} -- cache [player][part] = Vector3 original

function Utility.SetScale(player, scale)
    local char = Utility.GetCharacter(player)
    if not char then return end
    local hum = Utility.GetHumanoid(player)
    if hum then
        hum.HipHeight = 2 * scale
    end

    local cache = originalSizes[player]
    if not cache then
        cache = {}
        originalSizes[player] = cache
    end

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if not cache[part] then
                cache[part] = part.Size
            end
            part.Size = cache[part] * scale
        end
    end
end

-- Transforma o R6/R15 no tamanho desejado (relativo ao HRP)
function Utility.SetBodyScale(player, scale)
    local char = Utility.GetCharacter(player)
    if not char then return end
    local hrp = Utility.GetHRP(player)
    local hum = Utility.GetHumanoid(player)
    if hum then
        hum.HipHeight = 2 * scale
    end
    if hrp then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part ~= hrp then
                part.Position = hrp.Position + (part.Position - hrp.Position) * scale
            end
        end
    end
end

-- Cria uma explosão visual na posição
function Utility.Explode(position, radius)
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastRadius = radius or 10
    explosion.BlastPressure = 500000
    explosion.DestroyJointRadiusPercent = 1
    explosion.Parent = Workspace
end

-- Notificação por chat do sistema (broadcast local)
function Utility.SystemMessage(text)
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("SendNotification", {
        Title = "UTG Trolling GUI",
        Text = text,
        Duration = 3,
    })
end

-- Checa se o personagem está em R6 ou R15
function Utility.GetRigType(player)
    local char = Utility.GetCharacter(player)
    if not char then return "R6" end
    if char:FindFirstChild("UpperTorso") and char:FindFirstChild("LowerTorso") then
        return "R15"
    end
    return "R6"
end

-- Loop com conexão limpa (RenderStepped)
function Utility.Loop(fn, every)
    every = every or 0
    local acc = 0
    return RunService.RenderStepped:Connect(function(dt)
        acc = acc + dt
        if acc >= every then
            acc = 0
            fn()
        end
    end)
end

-- Tween de CFrame/Valor simples
function Utility.Tween(object, properties, duration)
    return TweenService:Create(object, TweenInfo.new(duration or 0.5), properties)
end

return Utility
