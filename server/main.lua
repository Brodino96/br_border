--------------- # --------------- # --------------- # --------------- # ---------------

local defaultBypass = not Config.enabled
local players = {}

--------------- # --------------- # --------------- # --------------- # ---------------

---Checks if the player is part of the staff
---@param id number The player serverId
---@return boolean
local function isStaff(id)
    return true
end

---Toggles the bypass mode for the given player
---@param id number The target server id
---@return nil
local function toggleBypass(id)

    local serverId = tostring(id)
    players[serverId] = not players[serverId]

    TriggerClientEvent("br_border:sync", id, players[serverId])
end

--------------- # --------------- # --------------- # --------------- # ---------------

RegisterNetEvent("br_border:sync")
AddEventHandler("br_border:sync", function ()

    if players[source] == nil then
        players[source] = defaultBypass
    end

    if isStaff(source) then
        players[source] = true
    end

    TriggerClientEvent("br_border:sync", source, players[source])
end)

--------------- # --------------- # --------------- # --------------- # ---------------

RegisterCommand("bypass", function (source, args)

    if not isStaff(source) then
        return
    end

    if not args[1] then
        return
    end

    toggleBypass(args[1])
end, false)

--------------- # --------------- # --------------- # --------------- # ---------------