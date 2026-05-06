local NpcESP = {}
local DrawingLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/recex/ESP-LUA/main/src/utils/DrawingLib.lua"))()

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

function NpcESP.Create(npc)
      local head = npc:FindFirstChild("Head")
      if not head then return end

      local text = DrawingLib.new("Text", {
              Text = "[NPC] " .. npc.Name,
              Size = 16,
              Center = true,
              Outline = true,
              Color = Color3.fromRGB(255, 255, 0),
              Visible = false
    })

      local connection
      connection = RunService.RenderStepped:Connect(function()
              if npc.Parent and head.Parent then
                    local pos, onScreen = DrawingLib.getScreenPos(head.Position)
                    if onScreen then
                          text.Position = Vector2.new(pos.X, pos.Y - 20)
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

function NpcESP.Init()
      -- Procura por NPCs (geralmente modelos com Humanoid que não são jogadores)
      for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(obj) then
                  NpcESP.Create(obj)
    end
  end

      Workspace.DescendantAdded:Connect(function(obj)
              if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(obj) then
                    NpcESP.Create(obj)
      end
    end)
end

return NpcESP
