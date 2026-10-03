local Framework
local Core
local lastLoot = {}

local function debugPrint(message)
    if Config.Debug then
        print(('[Fox_NPCLoot] %s'):format(message))
    end
end

local function getLang()
    return Translation.Langs[Config.Language] or Translation.Langs.English
end

local function resolveFramework()
    if Framework and Core then return true end

    local configured = string.lower(tostring(Config.Framework or 'auto'))

    if (configured == 'auto' or configured == 'vorp') and GetResourceState('vorp_core') == 'started' then
        Framework = 'vorp'
        Core = exports.vorp_core:GetCore()
        return true
    end

    if (configured == 'auto' or configured == 'rsg') and GetResourceState('rsg-core') == 'started' then
        Framework = 'rsg'
        Core = exports['rsg-core']:GetCoreObject()
        return true
    end

    return false
end

local function getPlayer(source)
    if not resolveFramework() then return nil end

    if Framework == 'vorp' then
        local user = Core.getUser(source)
        return user and user.getUsedCharacter or nil
    end

    return Core.Functions.GetPlayer(source)
end

local function notify(source, message, notifyType)
    TriggerClientEvent('Fox_NPCLoot:client:notify', source, message, notifyType or 'inform')
end

local function validRoll(receiveValue, chanceValue)
    local receive = math.floor(tonumber(receiveValue) or 0)
    local chance = math.floor(tonumber(chanceValue) or 0)

    if receive <= 0 or chance <= 0 then return false end
    if receive >= chance then return true end

    return math.random(1, chance) <= receive
end

local function pickRandom(list)
    if type(list) ~= 'table' or #list == 0 then return nil end
    return list[math.random(1, #list)]
end

local function formatNumber(value)
    local number = tonumber(value) or 0
    if number == math.floor(number) then
        return tostring(math.floor(number))
    end
    return string.format('%.2f', number):gsub('0+$', ''):gsub('%.$', '')
end

local function canCarryItem(source, itemName, amount)
    if Framework == 'vorp' then
        local ok, result = pcall(function()
            return exports.vorp_inventory:canCarryItem(source, itemName, amount)
        end)
        return ok and result == true
    end

    local ok, result = pcall(function()
        return exports['rsg-inventory']:CanAddItem(source, string.lower(itemName), amount)
    end)
    return ok and result == true
end

local function addItem(source, itemName, amount)
    if Framework == 'vorp' then
        local ok, result = pcall(function()
            return exports.vorp_inventory:addItem(source, itemName, amount, {})
        end)
        return ok and result ~= false
    end

    local ok, result = pcall(function()
        return exports['rsg-inventory']:AddItem(
            source,
            string.lower(itemName),
            amount,
            nil,
            nil,
            'fox-npcloot'
        )
    end)
    return ok and result == true
end

local function addMoney(source, amount, moneyType)
    amount = tonumber(amount)
    if not amount or amount <= 0 then return false end

    if Framework == 'vorp' then
        local player = getPlayer(source)
        if not player then return false end
        local currency = moneyType == 'gold' and 1 or 0
        player.addCurrency(currency, amount)
        return true
    end

    local player = getPlayer(source)
    if not player then return false end
    return player.Functions.AddMoney(moneyType == 'gold' and 'gold' or 'cash', amount, 'fox-npcloot') == true
end

local function canCarryWeapon(source, weaponName)
    if Framework == 'vorp' then
        local ok, result = pcall(function()
            return exports.vorp_inventory:canCarryWeapons(source, 1, nil, weaponName)
        end)
        return ok and result == true
    end

    local itemName = string.lower(weaponName)
    local ok, result = pcall(function()
        return exports['rsg-inventory']:CanAddItem(source, itemName, 1)
    end)
    return ok and result == true
end

local function addWeapon(source, weaponName)
    if Framework == 'vorp' then
        local ok, result = pcall(function()
            return exports.vorp_inventory:createWeapon(source, weaponName, {}, {}, {})
        end)
        return ok and result ~= false
    end

    local itemName = string.lower(weaponName)
    local ok, result = pcall(function()
        return exports['rsg-inventory']:AddItem(
            source,
            itemName,
            1,
            nil,
            nil,
            'fox-npcloot-weapon'
        )
    end)
    return ok and result == true
end

local function validateLootEntity(source, netId, clientModel)
    netId = tonumber(netId) or 0
    if netId <= 0 then return true end

    local entity = NetworkGetEntityFromNetworkId(netId)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return false end
    if GetEntityType(entity) ~= 1 then return false end

    local playerPed = GetPlayerPed(source)
    if not playerPed or playerPed == 0 then return false end

    local playerCoords = GetEntityCoords(playerPed)
    local entityCoords = GetEntityCoords(entity)
    if #(playerCoords - entityCoords) > (tonumber(Config.MaxLootDistance) or 5.0) then
        return false
    end

    local expectedModel = tonumber(clientModel)
    if expectedModel and expectedModel ~= 0 and GetEntityModel(entity) ~= expectedModel then
        return false
    end

    return true
end

local function rewardItem(source, lang)
    if not Config.canReceiveItems then return end

    if not validRoll(Config.receiveItem, Config.chanceGettingItem) then
        notify(source, lang.noItem, 'inform')
        return
    end

    local reward = pickRandom(Config.items)
    if not reward or type(reward.name) ~= 'string' then return end

    local amount = math.max(1, math.floor(tonumber(reward.amount) or 1))
    local label = reward.label or reward.name

    if not canCarryItem(source, reward.name, amount) then
        notify(source, (lang.ItemsFull or lang.invFullItems) .. label, 'error')
        return
    end

    if addItem(source, reward.name, amount) then
        notify(source, ('%s%dx %s'):format(lang.youGot, amount, label), 'success')
    end
end

local function rewardMoney(source, lang)
    if not Config.canReceiveMoney then return end
    if not validRoll(Config.receiveMoney, Config.chanceGettingMoney) then
        notify(source, lang.noMoney, 'inform')
        return
    end

    local amount = tonumber(pickRandom(Config.money))
    if amount and amount > 0 and addMoney(source, amount, 'cash') then
        notify(source, lang.youGot .. formatNumber(amount) .. lang.currency, 'success')
    end
end

local function rewardGold(source, lang)
    if not Config.canReceiveGold then return end
    if not validRoll(Config.receiveGold, Config.chanceGettingGold) then
        notify(source, lang.noGold, 'inform')
        return
    end

    local amount = tonumber(pickRandom(Config.gold))
    if amount and amount > 0 and addMoney(source, amount, 'gold') then
        notify(source, lang.youGot .. formatNumber(amount) .. lang.nugget, 'success')
    end
end

local function rewardWeapon(source, lang)
    if not Config.canReceiveWeapons then return end
    if not validRoll(Config.receiveWeapon, Config.chanceGettingWeapon) then
        notify(source, lang.noWeapon, 'inform')
        return
    end

    local reward = pickRandom(Config.weapons)
    if not reward or type(reward.name) ~= 'string' then return end

    if not canCarryWeapon(source, reward.name) then
        notify(source, lang.invFullWeapon, 'error')
        return
    end

    if addWeapon(source, reward.name) then
        notify(source, lang.youGot .. (reward.label or reward.name), 'success')
    end
end

RegisterNetEvent('Fox_NPCLoot:server:giveReward', function(netId, model)
    local source = source
    local now = GetGameTimer()
    local cooldown = math.max(500, math.floor(tonumber(Config.ServerCooldown) or 1500))

    if lastLoot[source] and now - lastLoot[source] < cooldown then
        debugPrint(('Evento bloqueado por cooldown: %s'):format(source))
        return
    end

    if not resolveFramework() then return end
    if not getPlayer(source) then return end
    if not validateLootEntity(source, netId, model) then return end

    lastLoot[source] = now

    local lang = getLang()
    rewardItem(source, lang)
    rewardMoney(source, lang)
    rewardGold(source, lang)
    rewardWeapon(source, lang)
end)

AddEventHandler('playerDropped', function()
    lastLoot[source] = nil
end)

CreateThread(function()
    while not resolveFramework() do
        Wait(1000)
    end

    print(('[Fox_NPCLoot] Framework detectado: %s'):format(string.upper(Framework)))
end)
