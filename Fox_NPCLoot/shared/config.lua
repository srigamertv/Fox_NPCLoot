Config = {}

-- Framework: "auto", "vorp" ou "rsg"
Config.Framework = "auto"

-- Idioma: English | Portuguese_PT | Portuguese_BR | French | German | Spanish
Config.Language = "English"

-- VORP: true = NotifyRightTip / false = NotifyTip
-- RSG: usa a notificação padrão do RSG Core.
Config.useNotifyRight = false

Config.ServerCooldown = 1500
Config.MaxLootDistance = 5.0
Config.Debug = false

Config.canReceiveItems = true
Config.receiveItem = 35
Config.chanceGettingItem = 100
Config.items = {
    { name = "water",              label = "Agua",                 amount = 1 },
    { name = "ammorepeaternormal", label = "Normal Ammo Repeater", amount = 1 },
    { name = "ammoriflenormal",    label = "Normal Ammo Rifle",    amount = 1 },
}

Config.canReceiveMoney = false
Config.receiveMoney = 50
Config.chanceGettingMoney = 100
Config.money = { 0.5, 1, 1.5 }

Config.canReceiveGold = false
Config.receiveGold = 5
Config.chanceGettingGold = 10
Config.gold = { 1, 2, 3 }

Config.canReceiveWeapons = false
Config.receiveWeapon = 10
Config.chanceGettingWeapon = 100
Config.weapons = {
    { name = "WEAPON_REVOLVER_CATTLEMAN", label = "Cattleman Revolver" },
    { name = "WEAPON_REPEATER_CARBINE",   label = "Carbine Repeater" },
    { name = "WEAPON_RIFLE_VARMINT",      label = "Varmint Rifle" }
}
