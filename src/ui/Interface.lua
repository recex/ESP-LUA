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
