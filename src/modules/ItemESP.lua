local ItemESP = {}
local DrawingLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/recex/ESP-LUA/main/src/utils/DrawingLib.lua"))()

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

function ItemESP.Create(item)
      if not item:IsA("BasePart") then return end

      local text = DrawingLib.new("Text", {
              Text = item.Name,
              Size = 16,
              Center = true,
              Outline = true,
              Color = Color3.fromRGB(0, 255, 0),
              Visible = false
    })

      local connection
      connection = RunService.RenderStepped:Connect(function()
              if item.Parent then
                    local pos, onScreen = DrawingLib.getScreenPos(item.Position)
                    if onScreen then
                          text.Position = Vector2.new(pos.X, pos.Y)
                          text.Visible = true
        else
                          text.Visible = false
        end
      else
                    text:Remove()
                    connection:Disconnect()
      end
    end)
end

function ItemESP.Init()
      -- Exemplo: Procura por itens em uma pasta específica ou no workspace
      -- Você pode ajustar isso para o jogo que estiver jogando
      for _, item in pairs(Workspace:GetDescendants()) do
            if item:IsA("BasePart") and (item.Name:lower():find("card") or item.Name:lower():find("key")) then
                  ItemESP.Create(item)
    end
  end

      Workspace.DescendantAdded:Connect(function(item)
              if item:IsA("BasePart") and (item.Name:lower():find("card") or item.Name:lower():find("key")) then
                    ItemESP.C
