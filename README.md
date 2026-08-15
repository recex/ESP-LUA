# UTG TROLLING GUI — By RECEX 🎯

O **melhor** GUI de trolling para Roblox, com transformações de personagem, trolling de jogadores, ESP e muito mais.

## ⚡ Como usar

Cole no seu executor (Delta Executor, Fluxus, Hydrogen, etc.) e execute. Use `RightControl` para abrir/fechar a GUI.

### Opção 1 — Single-file (recomendado, 1 fetch só)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/recex/ESP-LUA/main/release.lua"))()
```

### Opção 2 — Modular (carrega os módulos via HTTP)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/recex/ESP-LUA/main/main.lua"))()
```

## 🧩 Recursos

| Aba | Descrição |
|-----|-----------|
| 🎯 **Troll** | Matar, explodir, fling, spin, congelar, teleportar, trazer, perseguir (grab), lag, dançar... |
| 🔄 **Transformar** | Morphs de personagem (estilo UTG V3), tamanho, proporções, neon, vidro, ouro, arco-íris, fantasma e **cópia de visual** |
| ✨ **Fun** | Voar (fly), noclip, speed hack, pulo infinito, gravidade baixa, super pulo |
| 👁️ **Visual** | ESP de jogadores, itens e NPCs (caixas + nomes) |
| 🌍 **Mundo** | Explodir/matar/fling todos, apocalipse, controle de iluminação, chuva de esferas |

## 🗂️ Estrutura

```
release.lua              # Build single-file (tudo embutido, recomendado)
main.lua                 # Loader modular
src/
  ui/
    Interface.lua        # Biblioteca de UI nativa (ScreenGui)
  utils/
    DrawingLib.lua       # Wrapper da biblioteca Drawing
    Utility.lua          # Helpers (teleporte, fling, scale, etc.)
  modules/
    Troll.lua            # Trolling de jogadores
    Transform.lua        # Transformação de personagens
    Fun.lua              # Poderes / melhorias pessoais
    Visual.lua           # ESP
    World.lua            # Trolling no mundo
```

## ⚠️ Aviso

Feito para fins educacionais e de entretenimento. Use de forma responsável e apenas em jogos onde seja permitido.

---

**By RECEX**
