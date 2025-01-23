-------------------- # -------------------- # -------------------- # --------------------

local bypass = false
local walking = false

-------------------- # -------------------- # -------------------- # --------------------

local function barakobama()
    DoScreenFadeOut(800)
    Wait(1000)

    CreateThread(function ()
        while walking do
            Wait(0)
            DisableAllControlActions(0)
        end
    end)
end

local function donaldtrump()
    Wait(3000)
    DoScreenFadeIn(800)
    Wait(1500)
    walking = false
    ClearPedTasks(PlayerPedId())
end

local function removePlayerClothes(playerPed)
    local clothes = {
        { id = 1, set = 0 }, -- mask
        { id = 3, set = 15 }, -- hands
        { id = 4, set = 14 }, -- legs
        { id = 5, set = 0 }, -- bags
        { id = 6, set = 34 }, -- shoes
        { id = 7, set = 0 }, -- accessory
        { id = 8, set = 15 }, -- shirt
        { id = 9, set = 0 }, -- kevlar
        { id = 10, set = 0 }, -- badge
        { id = 11, set = 15 }, -- torso
    }
    local props = {
        { id = 0, set = -1 },
        { id = 1, set = -1 },
        { id = 2, set = -1 },
        { id = 6, set = -1 },
        { id = 7, set = -1 },
    }

    for i = 1, #clothes do
        SetPedComponentVariation(playerPed, clothes[i].id, clothes[i].set, 0, 0)
        --exports["p-clothing"]:toggleClothing(clothes[i])
    end
    for k = 1, #props do
        SetPedPropIndex(playerPed, props[k].id, props[k].set, 0, true)
        --exports["p-clothing"]:toggleProps(props[k])
    end
end

local function useRandomRespawn(playerPed, pCoords)
    local node = Config.nodes.random.feet.nodes[math.random(1, #Config.nodes.random.feet.nodes)]

    barakobama() -- Screen to black

    SetEntityCoords(playerPed, node.x, node.y, node.z, false, false, false, false)
    SetEntityHeading(playerPed, node.w)

    removePlayerClothes(playerPed)

    donaldtrump() -- Screen to game
end

local function onFeet(playerPed, pCoords)

    local useRandom = false
    math.randomseed(42069, GetGameTimer())
    local generated = math.random(1, 100)

    for i = 1, Config.nodes.random.feet.chance do
        if math.random(1, 100) == generated then
            useRandom = true
        end
    end

    if true then
    --if useRandom then
        return useRandomRespawn(playerPed, pCoords)
    end

    local closestNode
    local nodeDistance = 999999999.9
    local playerC = vec3(pCoords.x, pCoords.y, pCoords.z)

    for i = 1, #Config.nodes.feet do
        if #(playerC - vec3(Config.nodes.feet[i].x, Config.nodes.feet[i].y, Config.nodes.feet[i].z)) < nodeDistance then
            closestNode = Config.nodes.feet[i]
        end
    end

    barakobama() -- Screen to black

    SetEntityCoords(playerPed, closestNode.x, closestNode.y, closestNode.z, false, false, false, false)
    SetEntityHeading(playerPed, closestNode.w)

    local coords = GetEntityCoords(playerPed) + (GetEntityForwardVector(playerPed) * 30)
    TaskGoToCoordAnyMeans(playerPed, coords.x, coords.y, coords.z, 1.0, 0, false, 0, 0)

    donaldtrump() -- Screen to game
end

local function onCar(playerPed, pCoords)

    local closestNode
    local nodeDistance = 999999999.9

    local veh = GetVehiclePedIsIn(playerPed, false)
    local vehType = GetVehicleType(veh)

    local seats = GetVehicleModelNumberOfSeats(GetEntityModel(veh))

    if seats < 1 then
        return onFeet(playerPed, pCoords)
    end

    for i = -1, seats - 1 do
        local ped = GetPedInVehicleSeat(veh, i)
        -- If the ped is a player and i'm not that player then just do the blackout
        if IsPedAPlayer(ped) and ped ~= playerPed then
            barakobama()
            donaldtrump()
            return
        end

        if ped == playerPed then
            break
        end
    end

    if vehType == "heli" or vehType == "plane" or vehType == "boat" or vehType == "submarine" then
        return
    end

    for i = 1, #Config.nodes.car do
        local dist = #(pCoords - vec3(Config.nodes.car[i].x, Config.nodes.car[i].y, Config.nodes.car[i].z))
        if dist < nodeDistance then
            closestNode = Config.nodes.car[i]
            nodeDistance = dist
        end
    end

    barakobama()

    SetEntityCoords(veh, closestNode.x, closestNode.y, closestNode.z, false, false, false, false)
    SetEntityHeading(veh, closestNode.w)

    local coords = GetEntityCoords(veh) + (GetEntityForwardVector(veh) * 100)

    if GetPedInVehicleSeat(veh, -1) == playerPed then
        TaskVehicleDriveToCoord(playerPed, veh, coords.x, coords.y, coords.z, 30.0, 1.0, GetEntityModel(veh), 786603, 0, 1)
    end

    donaldtrump()

end

local function immigrate()

    local playerPed = PlayerPedId()
    local pCoords = GetEntityCoords(playerPed)

    walking = true

    if not IsPedInAnyVehicle(playerPed, false) then
        return onFeet(playerPed, pCoords)
    end

    onCar(playerPed, pCoords)

end

-------------------- # -------------------- # -------------------- # --------------------

local wall = PolyZone:Create(Config.wall.coords, {
    name = "we_have_to_build_a_wall",
    minZ = Config.wall.height.min,
    maxZ = Config.wall.height.max,
    debugGrid = Config.debugMode,
})

wall:onPlayerInOut(function (inside)
    if inside and not bypass then
        immigrate()
    end
end)

-------------------- # -------------------- # -------------------- # --------------------

RegisterNetEvent("br_immigration:sync")
AddEventHandler("br_immigration:sync", function (value)
    bypass = value
end)

TriggerServerEvent("br_immigration:requestSync")


TriggerEvent("chat:addSuggestion", "/bypass", "Permette al giocatore indicato di andare verso la città", {
    { name = "[ID]", help = "Id del giocatore su cui eseguire il comando"}
})

AddEventHandler("onResourceStop", function (rname)
    if rname ~= GetCurrentResourceName() then
        return
    end

    wall:destroy()
end)

-------------------- # -------------------- # -------------------- # --------------------