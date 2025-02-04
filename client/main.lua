-------------------- # -------------------- # -------------------- # --------------------

local bypass = false
local walking = false

-------------------- # -------------------- # -------------------- # --------------------

---Turns the screen black and disable the player controls
---@return nil
local function blackout()
    DoScreenFadeOut(800)
    Wait(1000)

    CreateThread(function ()
        while walking do
            Wait(0)
            DisableAllControlActions(0)
        end
    end)
end

---Sets the screen to the game and enables the player controls
---@return nil
local function awakening()
    Wait(3000)
    DoScreenFadeIn(800)
    Wait(1500)
    walking = false
    ClearPedTasks(PlayerPedId())
end

---Brings back the player when on feet
---@param playerPed integer The ped's handle
---@param pCoords vector3 The player coordinates
local function onFeet(playerPed, pCoords)

    local closestNode = Config.nodes.feet[1]
    local nodeDist = #(pCoords - vec3(closestNode.x, closestNode.y, closestNode.z))

    for i = 2, #Config.nodes.feet do
        local dist = #(pCoords - vec3(Config.nodes.feet[i].x, Config.nodes.feet[i].y, Config.nodes.feet[i].z))
        if dist < nodeDist then
            closestNode = Config.nodes.feet[i]
            nodeDist = dist
        end
    end

    blackout()

    SetEntityCoords(playerPed, closestNode.x, closestNode.y, closestNode.z, false, false, false, false)
    SetEntityHeading(playerPed, closestNode.w)

    local coords = GetEntityCoords(playerPed) + (GetEntityForwardVector(playerPed) * 30)
    TaskGoToCoordAnyMeans(playerPed, coords.x, coords.y, coords.z, 1.0, 0, false, 0, 0)

    awakening()
end

---Brings back the player when in a car
---@param playerPed integer The ped's handle
---@param pCoords vector3 The player coordinates
local function onCar(playerPed, pCoords)

    local veh = GetVehiclePedIsIn(playerPed, false)
    if not DoesEntityExist(veh) then
        return onFeet(playerPed, pCoords)
    end

    local vehType = GetVehicleType(veh)
    if vehType == "heli" or vehType == "plane" or vehType == "boat" or vehType == "submarine" then
        return
    end

    local seats = GetVehicleModelNumberOfSeats(GetEntityModel(veh))
    if seats < 1 then
        return onFeet(playerPed, pCoords)
    end

    local driver = GetPedInVehicleSeat(veh, -1)
    -- check if i'm not the driver and if the driver is a player
    if driver ~= playerPed and IsPedAPlayer(driver) then
        blackout()
        awakening()
        return
    end

    local closestNode = Config.nodes.car[1]
    local nodeDist = #(pCoords - vec3(closestNode.x, closestNode.y, closestNode.z))

    for i = 2, #Config.nodes.car do
        local dist = #(pCoords - vec3(Config.nodes.car[i].x, Config.nodes.car[i].y, Config.nodes.car[i].z))
        if dist < nodeDist then
            closestNode = Config.nodes.car[i]
            nodeDist = dist
        end
    end

    blackout()

    SetEntityCoords(veh, closestNode.x, closestNode.y, closestNode.z, false, false, false, false)
    SetEntityHeading(veh, closestNode.w)

    local coords = GetEntityCoords(veh) + (GetEntityForwardVector(veh) * 100)

    if GetPedInVehicleSeat(veh, -1) == playerPed then
        TaskVehicleDriveToCoord(playerPed, veh, coords.x, coords.y, coords.z, 30.0, 1.0, GetEntityModel(veh), 786603, 0, 1)
    end

    awakening()

end

---Initializes the process
---@return nil
local function init()

    if not Config.enabled then
        return
    end

    local playerPed = PlayerPedId()
    local pCoords = GetEntityCoords(playerPed)

    walking = true -- Used later

    if not IsPedInAnyVehicle(playerPed, false) then
        return onFeet(playerPed, pCoords)
    end

    return onCar(playerPed, pCoords)
end

-------------------- # -------------------- # -------------------- # --------------------

--- Creates the wall
local wall = PolyZone:Create(Config.wall.coords, {
    name = "we_have_to_build_a_wall",
    minZ = Config.wall.height.min,
    maxZ = Config.wall.height.max,
    debugGrid = Config.debugMode,
})

wall:onPlayerInOut(function (inside)
    if inside and not bypass then
        init()
    end
end)

-------------------- # -------------------- # -------------------- # --------------------

RegisterNetEvent("br_border:sync")
AddEventHandler("br_border:sync", function (value)
    bypass = value
end)

TriggerServerEvent("br_border:sync")


TriggerEvent("chat:addSuggestion", "/bypass", "Permette al giocatore indicato di andare verso la città", {
    { name = "[ID]", help = "Id del giocatore su cui eseguire il comando"}
})

AddEventHandler("onResourceStop", function (name)
    if name ~= GetCurrentResourceName() then
        return
    end

    wall:destroy()
end)

-------------------- # -------------------- # -------------------- # --------------------