--[[
    Troll.lua — Trolling de jogadores
    UTG TROLLING GUI — By RECEX
]]

local BASE = "https://raw.githubusercontent.com/recex/ESP-LUA/main/src/"
local Utility = loadstring(game:HttpGet(BASE .. "utils/Utility.lua"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Troll = {}

function Troll.Init(Window, Shared)
    local Tab = Window:Tab("Troll", "🎯")

    local Target = Tab:Section("Alvo")
    local targetName = nil

    local function refreshTargets(dropdown)
        dropdown:SetOptions(Utility.GetPlayers())
    end

    local targetDropdown = Target:Dropdown("Jogador", Utility.GetPlayers(), nil, function(name)
        targetName = name
        Shared.SetTarget(Utility.FindPlayer(name))
    end)
    Target:Button("Atualizar lista", function()
        refreshTargets(targetDropdown)
        Window:Notification("Troll", "Lista de jogadores atualizada!")
    end)

    -- Atualiza a lista quando alguém entra/sai
    Players.PlayerAdded:Connect(function() refreshTargets(targetDropdown) end)
    Players.PlayerRemoving:Connect(function() refreshTargets(targetDropdown) end)

    local function getTarget()
        local p = Shared.GetTarget()
        if not p or not p.Parent then
            p = Utility.FindPlayer(targetName)
        end
        if not p then
            Window:Notification("Troll", "Selecione um jogador válido!", 2)
        end
        return p
    end

    ------------------------------------------------------------------
    local Kills = Tab:Section("Ações Básicas")

    Kills:Button("Matar", function()
        local p = getTarget()
        if not p then return end
        local char = Utility.GetCharacter(p)
        if char then
            char:BreakJoints()
        end
        local hum = Utility.GetHumanoid(p)
        if hum then hum.Health = 0 end
    end)

    Kills:Button("Explodir", function()
        local p = getTarget()
        if not p then return end
        local hrp = Utility.GetHRP(p)
        if hrp then
            Utility.Explode(hrp.Position, 15)
            hrp:Destroy()
        end
    end)

    local freezeState = false
    Kills:Toggle("Congelar", false, function(v)
        freezeState = v
        local p = getTarget()
        if p then Utility.Freeze(p, v) end
    end)

    Kills:Button("Fling (Impulso)", function()
        local p = getTarget()
        if p then Utility.Fling(p, 8000) end
    end)

    Kills:Button("Girar (Spin)", function()
        local p = getTarget()
        if p then Utility.Spin(p, 0.6) end
    end)

    Kills:Button("Slingshot", function()
        local p = getTarget()
        if not p then return end
        local hrp = Utility.GetHRP(p)
        if hrp then
            hrp.Velocity = Vector3.new(0, 300, 0)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 300, 0)
        end
    end)

    ------------------------------------------------------------------
    local Move = Tab:Section("Teleporte / Movimento")

    Move:Button("Teleportar até mim", function()
        local p = getTarget()
        if not p then return end
        local myHrp = Utility.GetHRP(LocalPlayer)
        if myHrp then
            Utility.Teleport(p, myHrp.Position)
        end
    end)

    Move:Button("Trazer até mim", function()
        local p = getTarget()
        if not p then return end
        local myHrp = Utility.GetHRP(LocalPlayer)
        local hrp = Utility.GetHRP(p)
        if myHrp and hrp then
            -- Welda o alvo no jogador local (método de "grab")
            pcall(function()
                local weld = Instance.new("Weld")
                weld.Part0 = hrp
                weld.Part1 = myHrp
                weld.C0 = CFrame.new(0, 3, 3)
                weld.Parent = hrp
            end)
        end
    end)

    Move:Button("Ir até ele", function()
        local p = getTarget()
        if not p then return end
        local hrp = Utility.GetHRP(p)
        local myHrp = Utility.GetHRP(LocalPlayer)
        if hrp and myHrp then
            myHrp.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
        end
    end)

    Move:Button("Atirar pro céu", function()
        local p = getTarget()
        if not p then return end
        local hrp = Utility.GetHRP(p)
        if hrp then
            hrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 500, 0))
        end
    end)

    local followLoop = nil
    Move:Toggle("Perseguir (Grab)", false, function(v)
        if followLoop then
            followLoop:Disconnect()
            followLoop = nil
        end
        if v then
            followLoop = RunService.RenderStepped:Connect(function()
                local p = Shared.GetTarget() or Utility.FindPlayer(targetName)
                if p then
                    local hrp = Utility.GetHRP(p)
                    local myHrp = Utility.GetHRP(LocalPlayer)
                    if hrp and myHrp then
                        hrp.CFrame = myHrp.CFrame + Vector3.new(0, 2, 3)
                    end
                end
            end)
        end
    end)

    ------------------------------------------------------------------
    local Appear = Tab:Section("Aparência do Alvo")

    Appear:Button("Invisível", function()
        local p = getTarget()
        if p then Utility.SetInvisible(p, true) end
    end)

    Appear:Button("Visível de novo", function()
        local p = getTarget()
        if p then Utility.SetInvisible(p, false) end
    end)

    local rainbowLoop = nil
    Appear:Toggle("Arco-íris", false, function(v)
        if rainbowLoop then rainbowLoop:Disconnect(); rainbowLoop = nil end
        if v then
            rainbowLoop = RunService.RenderStepped:Connect(function()
                local p = Shared.GetTarget() or Utility.FindPlayer(targetName)
                if p then
                    Utility.SetColor(p, Color3.fromHSV(tick() % 1, 1, 1))
                end
            end)
        end
    end)

    Appear:Button("Encolher (Mini)", function()
        local p = getTarget()
        if p then Utility.SetScale(p, 0.4) end
    end)

    Appear:Button("Crescer (Gigante)", function()
        local p = getTarget()
        if p then Utility.SetScale(p, 2.5) end
    end)

    Appear:Button("Remover ferramentas", function()
        local p = getTarget()
        if not p then return end
        local char = Utility.GetCharacter(p)
        if char then
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") then tool:Destroy() end
            end
        end
    end)

    Appear:Button("Desarmar", function()
        local p = getTarget()
        if not p then return end
        local hum = Utility.GetHumanoid(p)
        if hum then hum:UnequipTools() end
    end)

    ------------------------------------------------------------------
    local Chaos = Tab:Section("Caos")

    Chaos:Button("Sentar ele", function()
        local p = getTarget()
        if not p then return end
        local hum = Utility.GetHumanoid(p)
        if hum then hum.Sit = true end
    end)

    Chaos:Button("Dançar", function()
        local p = getTarget()
        if not p then return end
        local hum = Utility.GetHumanoid(p)
        if hum then
            local anims = {
                "http://www.roblox.com/asset/?id=27789359",
                "http://www.roblox.com/asset/?id=357668644",
                "http://www.roblox.com/asset/?id=33796059",
            }
            local anim = Instance.new("Animation")
            anim.AnimationId = anims[math.random(#anims)]
            local track = hum:LoadAnimation(anim)
            track:Play()
        end
    end)

    local lagLoop = nil
    Chaos:Toggle("Lag", false, function(v)
        if lagLoop then lagLoop:Disconnect(); lagLoop = nil end
        if v then
            lagLoop = RunService.RenderStepped:Connect(function()
                local p = Shared.GetTarget() or Utility.FindPlayer(targetName)
                local hrp = Utility.GetHRP(p)
                if hrp then
                    for i = 1, 8 do
                        local part = Instance.new("Part")
                        part.Size = Vector3.new(0.5, 0.5, 0.5)
                        part.Position = hrp.Position + Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
                        part.Anchored = true
                        part.CanCollide = false
                        part.Transparency = 1
                        part.Parent = Workspace
                        task.delay(0.4, function() part:Destroy() end)
                    end
                end
            end)
        end
    end)

    Chaos:Button("Sumir com a cabeça", function()
        local p = getTarget()
        if not p then return end
        local char = Utility.GetCharacter(p)
        if char and char:FindFirstChild("Head") then
            char.Head.Transparency = 1
            char.Head.CanCollide = false
        end
    end)

    Chaos:Button("Randomizador de tamanho", function()
        local p = getTarget()
        if not p then return end
        task.spawn(function()
            for i = 1, 20 do
                Utility.SetScale(p, 0.5 + math.random() * 2)
                task.wait(0.1)
            end
            Utility.SetScale(p, 1)
        end)
    end)

    Chaos:Button("Cair (noclip off)", function()
        local p = getTarget()
        if not p then return end
        local char = Utility.GetCharacter(p)
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    Window:Notification("Troll", "Módulo de trolling carregado!")
end

return Troll
