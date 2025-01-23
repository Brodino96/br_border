--------------- # --------------- # --------------- # --------------- # ---------------

local defaultBypass = not Config.enabled
local players = {}

--------------- # --------------- # --------------- # --------------- # ---------------

local function isAdmin(id)
    return false
    --return IsPlayerAceAllowed(id, "admin")
end

local function toggleBypass(id, source)
    players[id] = not players[id]
    TriggerClientEvent("ox_lib:notify", source, {
        type = "info", title = "Bypapss per id ["..id.."] è ora ["..tostring(players[id]).."]"
    })
    TriggerClientEvent("br_immigration:sync", id, players[id])
end

--------------- # --------------- # --------------- # --------------- # ---------------

RegisterNetEvent("br_immigration:requestSync")
AddEventHandler("br_immigration:requestSync", function ()
    if players[source] == nil then
        players[source] = defaultBypass
    end

    if isAdmin(source) then
        players[source] = true
    end

    TriggerClientEvent("br_immigration:sync", source, players[source])
end)

--------------- # --------------- # --------------- # --------------- # ---------------

RegisterCommand("bypass", function (source, args)

    if args[1] == nil or GetPlayerPed(args[1]) == 0 then
        return TriggerClientEvent("ox_lib:notify", source, { type = "error", title = "Id inserito non valido" })
    end

    toggleBypass(args[1], source)
end, false)

--------------- # --------------- # --------------- # --------------- # ---------------