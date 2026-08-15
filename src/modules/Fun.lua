--[[
    Fun.lua — Melhorias e poderes pessoais (fly, noclip, speed, etc.)
    UTG TROLLING GUI — By RECEX
]]

local BASE = "https://raw.githubusercontent.com/recex/ESP-LUA/main/src/"
local Utility = loadstring(game:HttpGet(BASE .. "utils/Utility.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Fun = {}

-- Estado global de toggles
local State = {
    fly = false,
    noclip = false,
    speed = false,
    infiniteJump = false,
    superJump = false,
}

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

function Fun.Init(Window, Shared)
    local Tab = Window:Tab("Fun", "✨")

    ------------------------------------------------------------------
    local Move = Tab:Section("Movimento")

    -- FLY
    local flyConn = nil
    local flyKeys = { W = false, S = false, A = false, D = false, Space = false }
    Move:Toggle("Voar (Fly)", false, function(v)
        State.fly = v
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        if not v then return end

        local char = getChar()
        local hum = Utility.GetHumanoid(LocalPlayer)
        if hum then hum.PlatformStand = true end

        flyConn = RunService.RenderStepped:Connect(function()
            local hrp = Utility.GetHRP(LocalPlayer)
            if not hrp then return end

            local speed = 40
            local dir = Vector3.new(0, 0, 0)
            if flyKeys.W then dir = dir + (Workspace.CurrentCamera.CFrame.LookVector * speed) end
            if flyKeys.S then dir = dir - (Workspace.CurrentCamera.CFrame.LookVector * speed) end
            if flyKeys.A then dir = dir - (Workspace.CurrentCamera.CFrame.RightVector * speed) end
            if flyKeys.D then dir = dir + (Workspace.CurrentCamera.CFrame.RightVector * speed) end
            if flyKeys.Space then dir = dir + Vector3.new(0, speed, 0) end

            hrp.Velocity = dir
            hrp.AssemblyLinearVelocity = dir
        end)
    end)

    -- Captura teclas de voo
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        local k = input.KeyCode
        if k == Enum.KeyCode.W then flyKeys.W = true end
        if k == Enum.KeyCode.S then flyKeys.S = true end
        if k == Enum.KeyCode.A then flyKeys.A = true end
        if k == Enum.KeyCode.D then flyKeys.D = true end
        if k == Enum.KeyCode.Space then flyKeys.Space = true end
    end)
    UserInputService.InputEnded:Connect(function(input, processed)
        if processed then return end
        local k = input.KeyCode
        if k == Enum.KeyCode.W then flyKeys.W = false end
        if k == Enum.KeyCode.S then flyKeys.S = false end
        if k == Enum.KeyCode.A then flyKeys.A = false end
        if k == Enum.KeyCode.D then flyKeys.D = false end
        if k == Enum.KeyCode.Space then flyKeys.Space = false end
    end)

    -- NOCLIP
    local noclipConn = nil
    Move:Toggle("Noclip (atravessar)", false, function(v)
        State.noclip = v
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        if not v then return end
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end)

    -- SPEED
    local speedConn = nil
    local speedSlider = nil
    local function applySpeed(v)
        if speedConn then speedConn:Disconnect(); speedConn = nil end
        if not v then return end
        speedConn = RunService.RenderStepped:Connect(function()
            local hum = Utility.GetHumanoid(LocalPlayer)
            local hrp = Utility.GetHRP(LocalPlayer)
            if hum and hrp then
                hum.WalkSpeed = speedSlider and speedSlider.GetValue() or 50
            end
        end)
    end

    local speedToggle = Move:Toggle("Speed Hack", false, function(v)
        State.speed = v
        applySpeed(v)
    end)

    speedSlider = Move:Slider("Velocidade", 20, 200, 50, function(v)
        if State.speed then
            local hum = Utility.GetHumanoid(LocalPlayer)
            if hum then hum.WalkSpeed = v end
        end
    end)

    -- JUMP
    Move:Slider("Pulo (JumpPower)", 50, 500, 50, function(v)
        local hum = Utility.GetHumanoid(LocalPlayer)
        if hum then hum.JumpPower = v end
    end)

    Move:Toggle("Pulo infinito", false, function(v)
        State.infiniteJump = v
    end)

    -- Infinite jump: detecta espaço para re-pular
    RunService.RenderStepped:Connect(function()
        if not State.infiniteJump then return end
        local hum = Utility.GetHumanoid(LocalPlayer)
        if hum and hum.FloorMaterial == Enum.Material.Air and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    ------------------------------------------------------------------
    local Powers = Tab:Section("Poderes")

    Powers:Button("Dar item aleatório", function()
        -- Cria um Tool fake na mochila
        local tool = Instance.new("Tool")
        tool.Name = "Item UTG"
        tool.Parent = LocalPlayer.Backpack
        Window:Notification("Fun", "Item adicionado à mochila!")
    end)

    Powers:Button("Super pulo (1x)", function()
        local hum = Utility.GetHumanoid(LocalPlayer)
        if hum then
            local old = hum.JumpPower
            hum.JumpPower = 500
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            task.delay(2, function() hum.JumpPower = old end)
        end
    end)

    local gravityLoop = nil
    Powers:Toggle("Gravidade baixa", false, function(v)
        if gravityLoop then gravityLoop:Disconnect(); gravityLoop = nil end
        if v then
            gravityLoop = RunService.RenderStepped:Connect(function()
                local hrp = Utility.GetHRP(LocalPlayer)
                if hrp and hrp.AssemblyLinearVelocity.Y < -20 then
                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -20, hrp.AssemblyLinearVelocity.Z)
                end
            end)
        end
    end)

    Powers:Button("Correr muito rápido (burst)", function()
        local hum = Utility.GetHumanoid(LocalPlayer)
        local hrp = Utility.GetHRP(LocalPlayer)
        if hum and hrp then
            hrp.Velocity = Workspace.CurrentCamera.CFrame.LookVector * 300
        end
    end)

    ------------------------------------------------------------------
    local Misc = Tab:Section("Diversos")

    Misc:Button("Spawnar NPC aliado", function()
        -- Cria um Model fake de NPC perto de você
        local hrp = Utility.GetHRP(LocalPlayer)
        if not hrp then return end
        local model = Instance.new("Model")
        model.Name = "NPC UTG"
        local part = Instance.new("Part")
        part.Size = Vector3.new(2, 5, 1)
        part.Position = hrp.Position + Vector3.new(0, 2, 5)
        part.Anchored = true
        part.Color = Color3.fromRGB(130, 90, 255)
        part.Material = Enum.Material.Neon
        part.Parent = model
        model.Parent = Workspace
        Window:Notification("Fun", "NPC spawnado!")
    end)

    Misc:Button("FOV alto (zoom out)", function()
        Workspace.CurrentCamera.FieldOfView = 120
        Window:Notification("Fun", "FOV = 120")
    end)
    Misc:Button("FOV normal", function()
        Workspace.CurrentCamera.FieldOfView = 70
    end)

    Window:Notification("Fun", "Módulo Fun carregado!")
end

return Fun
