--[[
    UTG TROLLING GUI — VERSÃO SINGLE-FILE (self-contained)
    By RECEX

    Este arquivo embute TODOS os módulos. Nenhuma dependência externa.
    Use: loadstring(game:HttpGet("https://raw.githubusercontent.com/recex/ESP-LUA/main/release.lua"))()
]]

local Utility = (function()
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

end)()
local DrawingLib = (function()
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

end)()
local Interface = (function()
--[[
    Interface.lua — Biblioteca de UI nativa (ScreenGui)
    UTG TROLLING GUI — By RECEX
    Tema escuro moderno com arrastar, abas, seções e elementos interativos.

    Uso:
        local Interface = loadstring(game:HttpGet(...))()
        local Window = Interface.CreateWindow({ Title = "..." })
        local Tab = Window:Tab("Jogadores")
        local Sec = Tab:Section("Troll")
        Sec:Button("Matar", function() end)
        Sec:Toggle("Freeze", false, function(v) end)
]]

local Interface = {}

-- Compatibilidade (Luau <-> Lua 5.1)
if not math.clamp then
    function math.clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end
end
if not table.find then
    function table.find(t, val, init)
        for i = init or 1, #t do
            if t[i] == val then return i end
        end
        return nil
    end
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

local Theme = {
    BG       = Color3.fromRGB(16, 16, 22),
    BG2      = Color3.fromRGB(25, 25, 34),
    BG3      = Color3.fromRGB(35, 35, 47),
    BG4      = Color3.fromRGB(46, 46, 61),
    Accent   = Color3.fromRGB(130, 90, 255),
    Accent2  = Color3.fromRGB(95, 62, 205),
    Text     = Color3.fromRGB(232, 232, 238),
    Sub      = Color3.fromRGB(150, 150, 162),
    Border   = Color3.fromRGB(58, 58, 74),
    Danger   = Color3.fromRGB(200, 60, 60),
}

function Interface.GetTheme(key)
    return Theme[key]
end
function Interface.SetTheme(key, value)
    Theme[key] = value
end

local function Create(cls, props)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do
        if k == "Parent" then
            obj.Parent = v
        else
            obj[k] = v
        end
    end
    return obj
end

local function Corner(radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    return c
end

local function Stroke(instance, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Parent = instance
    return s
end

----------------------------------------------------------------
-- SECTION
----------------------------------------------------------------
local Section = {}
Section.__index = Section

function Section.new(tab, name)
    local self = setmetatable({}, Section)
    self.tab = tab

    local frame = Create("Frame", {
        Parent = tab.page,
        BackgroundColor3 = Theme.BG2,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
    })
    frame:AddChild(Corner(8))

    local header = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Theme.BG3,
        Size = UDim2.new(1, 0, 0, 30),
        BorderSizePixel = 0,
    })
    header:AddChild(Corner(8))

    Create("TextLabel", {
        Parent = header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
    })

    local content = Create("Frame", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 34),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
    })
    local contentList = Create("UIListLayout", {
        Parent = content,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    Create("UIPadding", {
        Parent = content,
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 4),
    })

    self.frame = frame
    self.header = header
    self.content = content
    self.contentList = contentList

    return self
end

function Section:Refresh()
    -- O dimensionamento é feito automaticamente via AutomaticSize.
end

function Section:Label(text)
    local lbl = Create("TextLabel", {
        Parent = self.content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Text = text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextColor3 = Theme.Sub,
        Font = Enum.Font.Gotham,
        TextSize = 13,
    })
    self:Refresh()
    return lbl
end

function Section:Button(name, callback)
    local btn = Create("TextButton", {
        Parent = self.content,
        BackgroundColor3 = Theme.BG3,
        Size = UDim2.new(1, 0, 0, 32),
        Text = name,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        BorderSizePixel = 0,
    })
    btn:AddChild(Corner(6))
    btn.MouseButton1Click:Connect(function()
        btn.BackgroundColor3 = Theme.Accent2
        task.delay(0.15, function()
            btn.BackgroundColor3 = Theme.BG3
        end)
        if callback then callback() end
    end)
    self:Refresh()
    return btn
end

function Section:Toggle(name, default, callback)
    local value = default or false
    local btn = Create("TextButton", {
        Parent = self.content,
        BackgroundColor3 = Theme.BG3,
        Size = UDim2.new(1, 0, 0, 32),
        Text = "",
        BorderSizePixel = 0,
    })
    btn:AddChild(Corner(6))

    Create("TextLabel", {
        Parent = btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
    })

    local knob = Create("Frame", {
        Parent = btn,
        BackgroundColor3 = Theme.BG4,
        Position = UDim2.new(1, -48, 0, 6),
        Size = UDim2.new(0, 38, 0, 20),
        BorderSizePixel = 0,
    })
    knob:AddChild(Corner(10))
    local dot = Create("Frame", {
        Parent = knob,
        BackgroundColor3 = Theme.Sub,
        Position = UDim2.new(0, 3, 0, 3),
        Size = UDim2.new(0, 14, 0, 14),
        BorderSizePixel = 0,
    })
    dot:AddChild(Corner(7))

    local function render()
        knob.BackgroundColor3 = value and Theme.Accent or Theme.BG4
        dot.Position = value and UDim2.new(0, 21, 0, 3) or UDim2.new(0, 3, 0, 3)
        dot.BackgroundColor3 = value and Color3.fromRGB(255, 255, 255) or Theme.Sub
    end
    render()

    btn.MouseButton1Click:Connect(function()
        value = not value
        render()
        if callback then callback(value) end
    end)

    self:Refresh()
    return {
        SetValue = function(v)
            value = v
            render()
            if callback then callback(v) end
        end,
        GetValue = function() return value end,
    }
end

function Section:Slider(name, min, max, default, callback)
    local value = default or min
    local frame = Create("Frame", {
        Parent = self.content,
        BackgroundColor3 = Theme.BG3,
        Size = UDim2.new(1, 0, 0, 46),
        BorderSizePixel = 0,
    })
    frame:AddChild(Corner(6))

    Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 4),
        Size = UDim2.new(0, 200, 0, 16),
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
    })

    local valLabel = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 4),
        Size = UDim2.new(1, -20, 0, 16),
        Text = tostring(value),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
    })

    local track = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Theme.BG4,
        Position = UDim2.new(0, 10, 0, 26),
        Size = UDim2.new(1, -20, 0, 8),
        BorderSizePixel = 0,
    })
    track:AddChild(Corner(4))
    local fill = Create("Frame", {
        Parent = track,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0,
    })
    fill:AddChild(Corner(4))

    local function setFromMouse(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * rel
        value = math.floor(value * 10) / 10
        valLabel.Text = tostring(value)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        if callback then callback(value) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setFromMouse(Mouse.X)
            local conn = Mouse.Move:Connect(function()
                setFromMouse(Mouse.X)
            end)
            Mouse.Button1Up:Once(function()
                conn:Disconnect()
            end)
        end
    end)

    fill.Size = UDim2.new(math.clamp((value - min) / (max - min), 0, 1), 0, 1, 0)

    self:Refresh()
    return {
        SetValue = function(v)
            value = v
            valLabel.Text = tostring(v)
            fill.Size = UDim2.new(math.clamp((v - min) / (max - min), 0, 1), 0, 1, 0)
        end,
        GetValue = function() return value end,
    }
end

function Section:Dropdown(name, options, default, callback)
    local value = default or options[1] or ""
    local frame = Create("Frame", {
        Parent = self.content,
        BackgroundColor3 = Theme.BG3,
        Size = UDim2.new(1, 0, 0, 32),
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    frame:AddChild(Corner(6))

    Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 120, 1, 0),
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.Sub,
        Font = Enum.Font.Gotham,
        TextSize = 13,
    })

    local selected = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 130, 0, 0),
        Size = UDim2.new(1, -140, 1, 0),
        Text = value,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
    })

    local listFrame = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Theme.BG4,
        Position = UDim2.new(0, 0, 0, 32),
        Size = UDim2.new(1, 0, 1, -32),
        BorderSizePixel = 0,
    })
    local list = Create("UIListLayout", { Parent = listFrame, SortOrder = Enum.SortOrder.LayoutOrder })

    local open = false
    local function renderOptions()
        for _, child in pairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, opt in pairs(options) do
            local b = Create("TextButton", {
                Parent = listFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                Text = opt,
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                BorderSizePixel = 0,
            })
            b.MouseButton1Click:Connect(function()
                value = opt
                selected.Text = opt
                open = false
                frame.Size = UDim2.new(1, 0, 0, 32)
                if callback then callback(opt) end
            end)
        end
    end
    renderOptions()

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            open = not open
            frame.Size = open and UDim2.new(1, 0, 0, 32 + #options * 26) or UDim2.new(1, 0, 0, 32)
        end
    end)

    self:Refresh()
    return {
        SetOptions = function(newOptions)
            options = newOptions
            if not value or not table.find(options, value) then
                value = options[1] or ""
                selected.Text = value
            end
            renderOptions()
        end,
        SetValue = function(v)
            value = v
            selected.Text = v
        end,
        GetValue = function() return value end,
    }
end

function Section:TextBox(name, placeholder, callback)
    local frame = Create("Frame", {
        Parent = self.content,
        BackgroundColor3 = Theme.BG3,
        Size = UDim2.new(1, 0, 0, 32),
        BorderSizePixel = 0,
    })
    frame:AddChild(Corner(6))

    Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 120, 1, 0),
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.Sub,
        Font = Enum.Font.Gotham,
        TextSize = 13,
    })

    local box = Create("TextBox", {
        Parent = frame,
        BackgroundColor3 = Theme.BG4,
        Position = UDim2.new(0, 130, 0, 5),
        Size = UDim2.new(1, -140, 1, -10),
        PlaceholderText = placeholder or "",
        Text = "",
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.Sub,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
    })
    box:AddChild(Corner(5))
    box.FocusLost:Connect(function(enter)
        if enter and callback then callback(box.Text) end
    end)

    self:Refresh()
    return box
end

----------------------------------------------------------------
-- TAB
----------------------------------------------------------------
local Tab = {}
Tab.__index = Tab

function Tab.new(window, name, icon)
    local self = setmetatable({}, Tab)
    self.window = window
    self.name = name

    local btn = Create("TextButton", {
        Parent = window.tabsHolder,
        BackgroundColor3 = Theme.BG3,
        Size = UDim2.new(1, 0, 0, 38),
        Text = (icon and icon .. "  " or "") .. name,
        TextColor3 = Theme.Sub,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        BorderSizePixel = 0,
    })
    btn:AddChild(Corner(7))

    local page = Create("ScrollingFrame", {
        Parent = window.contentHolder,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        Visible = false,
        BorderSizePixel = 0,
    })
    local list = Create("UIListLayout", {
        Parent = page,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    Create("UIPadding", {
        Parent = page,
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    })

    btn.MouseButton1Click:Connect(function()
        window:SelectTab(self)
    end)

    self.button = btn
    self.page = page
    self.list = list
    self.sections = {}

    window.tabs[name] = self
    table.insert(window.tabOrder, self)

    return self
end

function Tab:RefreshCanvas()
    self.page.CanvasSize = UDim2.new(0, 0, 0, self.list.AbsoluteContentSize.Y + 16)
end

function Tab:Section(name)
    local section = Section.new(self, name)
    table.insert(self.sections, section)
    return section
end

----------------------------------------------------------------
-- WINDOW
----------------------------------------------------------------
local Window = {}
Window.__index = Window

function Interface.CreateWindow(config)
    config = config or {}
    local self = setmetatable({}, Window)

    self.Title = config.Title or "UTG Trolling GUI"
    self.Subtitle = config.Subtitle or "by RECEX"
    local accent = config.Accent or Theme.Accent
    self.accent = accent

    local gui = Create("ScreenGui", {
        Name = self.Title,
        Parent = PlayerGui,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
    })
    self.gui = gui

    local main = Create("Frame", {
        Parent = gui,
        BackgroundColor3 = Theme.BG,
        Position = UDim2.new(0, 60, 0, 90),
        Size = UDim2.new(0, 560, 0, 430),
        BorderSizePixel = 0,
    })
    main:AddChild(Corner(10))
    Stroke(main, Theme.Border, 1)
    self.main = main

    -- Topbar
    local topbar = Create("Frame", {
        Parent = main,
        BackgroundColor3 = Theme.BG2,
        Size = UDim2.new(1, 0, 0, 48),
        BorderSizePixel = 0,
    })
    topbar:AddChild(Corner(10))

    Create("TextLabel", {
        Parent = topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 4),
        Size = UDim2.new(0, 380, 0, 24),
        Text = self.Title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
    })
    Create("TextLabel", {
        Parent = topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 27),
        Size = UDim2.new(0, 300, 0, 16),
        Text = self.Subtitle,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = accent,
        Font = Enum.Font.Gotham,
        TextSize = 12,
    })

    local minimize = Create("TextButton", {
        Parent = topbar,
        BackgroundColor3 = Theme.BG3,
        Position = UDim2.new(1, -92, 0, 10),
        Size = UDim2.new(0, 38, 0, 28),
        Text = "—",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        BorderSizePixel = 0,
    })
    minimize:AddChild(Corner(6))
    local minimized = false
    minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        self.tabsHolder.Visible = not minimized
        self.contentHolder.Visible = not minimized
        main.Size = minimized and UDim2.new(0, 560, 0, 48) or UDim2.new(0, 560, 0, 430)
    end)

    local close = Create("TextButton", {
        Parent = topbar,
        BackgroundColor3 = Theme.Danger,
        Position = UDim2.new(1, -46, 0, 10),
        Size = UDim2.new(0, 38, 0, 28),
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        BorderSizePixel = 0,
    })
    close:AddChild(Corner(6))
    close.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)

    -- Arrastar
    local dragging, offset
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            offset = Vector2.new(Mouse.X - main.Position.X.Offset, Mouse.Y - main.Position.Y.Offset)
        end
    end)
    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    Mouse.Move:Connect(function()
        if dragging then
            main.Position = UDim2.new(0, Mouse.X - offset.X, 0, Mouse.Y - offset.Y)
        end
    end)

    local tabsHolder = Create("Frame", {
        Parent = main,
        BackgroundColor3 = Theme.BG2,
        Position = UDim2.new(0, 0, 0, 48),
        Size = UDim2.new(0, 130, 1, -48),
        BorderSizePixel = 0,
    })
    Create("UIListLayout", {
        Parent = tabsHolder,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    Create("UIPadding", {
        Parent = tabsHolder,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    })
    self.tabsHolder = tabsHolder

    local contentHolder = Create("Frame", {
        Parent = main,
        BackgroundColor3 = Theme.BG,
        Position = UDim2.new(0, 130, 0, 48),
        Size = UDim2.new(1, -130, 1, -48),
        BorderSizePixel = 0,
    })
    self.contentHolder = contentHolder

    self.tabs = {}
    self.tabOrder = {}

    function self:SelectTab(tab)
        for _, t in pairs(self.tabOrder) do
            local active = (t == tab)
            t.page.Visible = active
            t.button.BackgroundColor3 = active and accent or Theme.BG3
            t.button.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Theme.Sub
        end
        self.currentTab = tab
    end

    function self:Tab(name, icon)
        local t = Tab.new(self, name, icon)
        if #self.tabOrder == 1 then
            self:SelectTab(t)
        end
        return t
    end

    function self:Notification(title, text, duration)
        local notif = Create("Frame", {
            Parent = gui,
            BackgroundColor3 = Theme.BG2,
            Position = UDim2.new(0, -330, 1, -90),
            Size = UDim2.new(0, 300, 0, 70),
            BorderSizePixel = 0,
        })
        notif:AddChild(Corner(8))
        Stroke(notif, accent, 2)

        local bar = Create("Frame", {
            Parent = notif,
            BackgroundColor3 = accent,
            Size = UDim2.new(0, 4, 1, 0),
            BorderSizePixel = 0,
        })
        bar:AddChild(Corner(2))

        Create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 8),
            Size = UDim2.new(1, -20, 0, 18),
            Text = title,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = accent,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
        })
        Create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 28),
            Size = UDim2.new(1, -20, 0, 34),
            Text = text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextColor3 = Theme.Sub,
            Font = Enum.Font.Gotham,
            TextSize = 13,
        })

        TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 16, 1, -90),
        }):Play()

        task.delay(duration or 3, function()
            TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(0, -330, 1, -90),
            }):Play()
            task.delay(0.4, function()
                notif:Destroy()
            end)
        end)
    end

    function self:ToggleKey(key)
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == key then
                gui.Enabled = not gui.Enabled
            end
        end)
    end

    return self
end

return Interface

end)()
local Troll = (function()
--[[
    Troll.lua — Trolling de jogadores
    UTG TROLLING GUI — By RECEX
]]


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
end)()
local Transform = (function()
--[[
    Transform.lua — Transformação de personagens (morphs / skins)
    UTG TROLLING GUI — By RECEX
    Inclui transformações de tamanho, aparência, materiais e cópia de visual.
]]


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
end)()
local Fun = (function()
--[[
    Fun.lua — Melhorias e poderes pessoais (fly, noclip, speed, etc.)
    UTG TROLLING GUI — By RECEX
]]


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
end)()
local Visual = (function()
--[[
    Visual.lua — ESP (players, itens, NPCs) integrado à GUI
    UTG TROLLING GUI — By RECEX
]]


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
end)()
local World = (function()
--[[
    World.lua — Trolling no mundo inteiro
    UTG TROLLING GUI — By RECEX
]]


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
end)()

-- Criar janela principal
local Window = Interface.CreateWindow({
    Title = "UTG TROLLING GUI",
    Subtitle = "by RECEX  •  O melhor GUI de trolling",
})

-- Estado compartilhado entre módulos
local Shared = {
    target = nil,
}
function Shared.SetTarget(p) Shared.target = p end
function Shared.GetTarget() return Shared.target end

-- Inicializar módulos
local modules = {
    { name = "Troll", mod = Troll },
    { name = "Transformar", mod = Transform },
    { name = "Fun", mod = Fun },
    { name = "Visual", mod = Visual },
    { name = "Mundo", mod = World },
}

for _, entry in ipairs(modules) do
    if entry.mod then
        local ok, err = pcall(function()
            entry.mod.Init(Window, Shared)
        end)
        if ok then
            print("[" .. entry.name .. "] Carregado com sucesso!")
        else
            warn("[" .. entry.name .. "] Erro ao inicializar: " .. tostring(err))
        end
    end
end

-- Tecla para abrir/fechar a GUI
Window:ToggleKey(Enum.KeyCode.RightControl)

Window:Notification("UTG Trolling GUI", "Carregado com sucesso! Pressione RightControl para abrir/fechar.", 5)
print("UTG TROLLING GUI — Carregado com sucesso! By RECEX")
