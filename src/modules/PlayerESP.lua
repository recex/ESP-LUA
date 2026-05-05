local PlayerESP = {}
local DrawingLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/recex/ESP-LUA/main/src/utils/DrawingLib.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

function PlayerESP.Create(player)
      local box = DrawingLib.new("Square", {
              Color = Color3.fromRGB(255, 0, 0),
              Thickness = 1,
              Filled = false,
              Visible = false
    })

      local name = DrawingLib.new("Text", {
              Text = player.Name,
              Size = 18,
              Center = true,
              Outline = true,
              Color = Color3.fromRGB(255, 255, 255),
              Visible = false
    })

      local connection
      connection = RunService.RenderStepped:Connect(function()
              if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    local pos, onScreen = DrawingLib.getScreenPos(hrp.Position)

                    if onScreen then
                          box.Size = Vector2.new(2000 / pos.Y, 3000 / pos.Y)
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

      player.AncestryChanged:Connect(function()
              if not player:IsDescendantOf(game) then
                    box:Remove()
                    name:Remove()
                    connection
