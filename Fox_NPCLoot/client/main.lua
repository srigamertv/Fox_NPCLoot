local EVENT_GROUP = 0
local EVENT_LOOT_COMPLETE = 1376140891
local GET_PED_ANIMAL_TYPE = 0x964000D355219FC0
local IS_ENTITY_FULLY_LOOTED = 0x8DE41E9902E85756

local resourceName = GetCurrentResourceName()
local processed = {}
local VorpCore

local function getEventValue(data, index)
    if not data then return nil end
    return tonumber(data[index] or data[tostring(index)])
end

local function detectFramework()
    local configured = string.lower(tostring(Config.Framework or 'auto'))

    if configured == 'vorp' then
        return GetResourceState('vorp_core') == 'started' and 'vorp' or nil
    end

    if configured == 'rsg' then
        return GetResourceState('rsg-core') == 'started' and 'rsg' or nil
    end

    if GetResourceState('vorp_core') == 'started' then
        return 'vorp'
    end

    if GetResourceState('rsg-core') == 'started' then
        return 'rsg'
    end
end

local function notify(message, notifyType)
    local framework = detectFramework()

    if framework == 'vorp' then
        VorpCore = VorpCore or exports.vorp_core:GetCore()

        if Config.useNotifyRight then
            VorpCore.NotifyRightTip(message, 4000)
        else
            VorpCore.NotifyTip(message, 4000)
        end
        return
    end

    if framework == 'rsg' then
        local ok, core = pcall(function()
            return exports['rsg-core']:GetCoreObject()
        end)

        if ok and core and core.Functions and core.Functions.Notify then
            core.Functions.Notify(message, notifyType or 'primary', 4000)
            return
        end
    end
end

RegisterNetEvent('Fox_NPCLoot:client:notify', function(message, notifyType)
    if type(message) ~= 'string' or message == '' then return end
    notify(message, notifyType)
end)

local function isHumanNpc(ped)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return false end
    if ped == PlayerPedId() or not IsEntityAPed(ped) then return false end
    if IsPedAPlayer(ped) then return false end
    if GetPedType(ped) ~= 4 then return false end

    local animalType = Citizen.InvokeNative(GET_PED_ANIMAL_TYPE, ped)
    if animalType and animalType ~= 0 then return false end

    return true
end

local function getNetworkId(entity)
    if not NetworkGetEntityIsNetworked(entity) then return 0 end
    local netId = NetworkGetNetworkIdFromEntity(entity)
    return tonumber(netId) or 0
end

CreateThread(function()
    while true do
        Wait(0)

        local eventCount = GetNumberOfEvents(EVENT_GROUP)
        if eventCount > 0 then
            for index = 0, eventCount - 1 do
                if GetEventAtIndex(EVENT_GROUP, index) == EVENT_LOOT_COMPLETE then
                    local eventData = exports[resourceName]:DataViewNativeGetEventData2(EVENT_GROUP, index, 3)
                    local looterPed = getEventValue(eventData, 0)
                    local lootedPed = getEventValue(eventData, 2)

                    if looterPed == PlayerPedId() and isHumanNpc(lootedPed) then
                        local fullyLooted = Citizen.InvokeNative(IS_ENTITY_FULLY_LOOTED, lootedPed)

                        if fullyLooted then
                            local now = GetGameTimer()
                            local last = processed[lootedPed] or 0

                            if now - last > 30000 then
                                processed[lootedPed] = now
                                TriggerServerEvent(
                                    'Fox_NPCLoot:server:giveReward',
                                    getNetworkId(lootedPed),
                                    GetEntityModel(lootedPed)
                                )
                            end
                        end
                    end
                end
            end
        end
    end
end)
