local ESX = exports['es_extended']:getSharedObject()

function ServerFramework.getCitizenId(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.identifier
end

function ServerFramework.getPlayerName(citizenId)
    local result = MySQL.single.await('SELECT firstname, lastname FROM users WHERE identifier = ?', {citizenId})

    if result then
        return ('%s %s'):format(result.firstname or '', result.lastname or ''):gsub('^%s+', ''):gsub('%s+$', '')
    end

    return 'Unknown'
end

function ServerFramework.validateCitizenId(citizenId)
    local result = MySQL.scalar.await('SELECT COUNT(*) FROM users WHERE identifier = ?', {citizenId})
    return result and result > 0
end
