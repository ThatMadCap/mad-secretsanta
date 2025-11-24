local Ox = lib.require '@ox_core.lib.init'

function ServerFramework.getCitizenId(source)
    local player = Ox.GetPlayer(source)
    return player and player.stateId
end

function ServerFramework.getPlayerName(citizenId)
    local result = MySQL.single.await('SELECT firstname, lastname FROM characters WHERE stateId = ?', {citizenId})

    if result then
        return ('%s %s'):format(result.firstname, result.lastname)
    end

    return 'Unknown'
end

function ServerFramework.validateCitizenId(citizenId)
    local result = MySQL.scalar.await('SELECT COUNT(*) FROM characters WHERE stateId = ?', {citizenId})
    return result and result > 0
end
