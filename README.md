# Fox_NPCLoot

Sistema de recompensa ao saquear NPCs humanos no RedM, com suporte a **VORP** e **RSG**.

## 🔥 Funcionalidades

- Detecta quando o jogador termina de saquear um NPC.
- Recompensas processadas no servidor.
- Itens, dinheiro, ouro e armas configuráveis.
- Chances independentes para cada tipo de recompensa.
- Validação de distância/modelo quando o NPC possui Network ID.
- Cooldown server-side contra spam.
- Verificação de capacidade antes de entregar itens ou armas.
- Traduções incluídas em `shared/translation.lua`.

## 🛠️ Instalação

1. Coloque a pasta `Fox_NPCLoot` em `resources`.
2. Adicione:

```cfg
ensure Fox_NPCLoot
```

3. Configure `shared/config.lua`.

## 📦 Dependências

### VORP
- `vorp_core`
- `vorp_inventory`

### RSG
- `rsg-core`
- `rsg-inventory`

## 🎲 Chances

Exemplo:

```lua
Config.receiveItem = 35
Config.chanceGettingItem = 100
```

Nesse exemplo, o item tem 35% de chance.

## ✍️ Créditos

Desenvolvido e adaptado por **SR.IGAMER TV | FOX**.

<br>

**MINHA LOJA:**
<div>
  <a href="https://discord.gg/ySk8WVzY5n" target="_blank"><img src="https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white" target="_blank"></a>
</div>

<br>

**Siga-nos:**
<div>
  <a href="https://www.youtube.com/@SRIGAMERTV" target="_blank"><img src="https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white" target="_blank"></a>
  <a href="https://www.instagram.com/sr.igamer_tv" target="_blank"><img src="https://img.shields.io/badge/-Instagram-%23E4405F?style=for-the-badge&logo=instagram&logoColor=white" target="_blank"></a>
  <a href="https://discord.gg/kh2KTGvaVX" target="_blank"><img src="https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white" target="_blank"></a>
</div>

<br>

**Entrar-contato:**
<div>
  <a href="mailto:kelvinsom22kb@gmail.com"><img src="https://img.shields.io/badge/-Gmail-%23333?style=for-the-badge&logo=gmail&logoColor=white" target="_blank"></a>
</div>

## 🛡️ Licença

Distribuído sob a licença MIT. Consulte o arquivo `LICENSE`.
