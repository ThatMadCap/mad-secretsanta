local config = lib.require('config.cl_config')

---@class NearbyPlayer
---@field serverId number The server ID of the player
---@field name string The name of the player
---@field distance number The distance to the player (rounded to 2 decimals)

-- Get nearby players within configured radius
---@return NearbyPlayer[] formattedPlayers List of nearby players with their server IDs, names, and distances
local function getNearbyPlayers()
    local radius = config.nearbyPlayerRadius or 10.0
    local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(cache.ped), radius, true)
    local formattedPlayers = {}

    for i = 1, #nearbyPlayers do
        local player = nearbyPlayers[i]
        local playerId = player.id
        local playerServerId = GetPlayerServerId(playerId)
        local playerName = lib.callback.await('mad-secretsanta:server:getPlayerName', false, playerServerId)
        local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
        local myCoords = GetEntityCoords(cache.ped)
        local playerDistance = #(playerCoords - myCoords)

        formattedPlayers[#formattedPlayers + 1] = {
            serverId = playerServerId,
            name = playerName,
            distance = math.floor(playerDistance * 100) / 100
        }
    end

    return formattedPlayers
end

return {
    getNearbyPlayers = getNearbyPlayers
}
