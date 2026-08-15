--[[
    World.lua — Trolling no mundo inteiro
    UTG TROLLING GUI — By RECEX
]]

local BASE = "https://raw.githubusercontent.com/recex/ESP-LUA/main/src/"
local Utility = loadstring(game:HttpGet(BASE .. "utils/Utility.lua"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local World = {}

function World.Init(Window, Shared)
    local Tab = Window:Tab("Mundo", "🌍")

    local Everyone = Tab:Section("Todos os jogadores")

    Everyone:Button("Explodir todos", function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local hrp = Utility.GetHRP(p)
                if hrp then Utility.Explode(hrp.Position, 12) end
            end
        end
        Window:Notification("Mundo", "Kaboom! 💥")
    end)

    Everyone:Button("Matar todos", function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = Utility.GetCharacter(p)
                if char then char:BreakJoints() end
                local hum = Utility.GetHumanoid(p)
                if hum then hum.Health = 0 end
            end
        end
    end)

    Everyone:Button("Fling todos", function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then Utility.Fling(p, 9000) end
        end
    end)

    Everyone:Button("Trazer todos até mim", function()
        local myHrp = Utility.GetHRP(LocalPlayer)
        if not myHrp then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                Utility.Teleport(p, myHrp.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
            end
        end
    end)

    local apocalypseLoop = nil
    Everyone:Toggle("Apocalipse (explosões)", false, function(v)
        if apocalypseLoop then apocalypseLoop:Disconnect(); apocalypseLoop = nil end
        if v then
            apocalypseLoop = RunService.RenderStepped:Connect(function()
                local myHrp = Utility.GetHRP(LocalPlayer)
                if not myHrp then return end
                if math.random() < 0.1 then
                    Utility.Explode(myHrp.Position + Vector3.new(math.random(-60, 60), 0, math.random(-60, 60)), 20)
                end
            end)
        end
    end)

    ------------------------------------------------------------------
    local Env = Tab:Section("Ambiente")

    Env:Button("Escurecer o céu", function()
        local Lighting = game:GetService("Lighting")
        Lighting.Brightness = 0
        Lighting.ClockTime = 0
        Lighting.FogEnd = 20
        Lighting.FogColor = Color3.fromRGB(30, 0, 30)
    end)

    Env:Button("Restaurar iluminação", function()
        local Lighting = game:GetService("Lighting")
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
    end)

    Env:Button("Luz de festa (rainbow)", function()
        local Lighting = game:GetService("Lighting")
        task.spawn(function()
            for i = 1, 100 do
                Lighting.Ambient = Color3.fromHSV(tick() % 1, 1, 1)
                Lighting.OutdoorAmbient = Color3.fromHSV((tick() + 0.5) % 1, 1, 1)
                task.wait(0.05)
            end
            Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        end)
    end)

    Env:Button("Chuva de esferas", function()
        local myHrp = Utility.GetHRP(LocalPlayer)
        if not myHrp then return end
        task.spawn(function()
            for i = 1, 40 do
                local ball = Instance.new("Part")
                ball.Shape = Enum.PartType.Ball
                ball.Size = Vector3.new(2, 2, 2)
                ball.Material = Enum.Material.Neon
                ball.Color = Color3.fromHSV(math.random(), 1, 1)
                ball.CanCollide = true
                ball.Position = myHrp.Position + Vector3.new(math.random(-20, 20), 30 + i, math.random(-20, 20))
                ball.Parent = Workspace
                task.delay(10, function() ball:Destroy() end)
            end
        end)
    end)

    Window:Notification("Mundo", "Módulo Mundo carregado!")
end

return World
