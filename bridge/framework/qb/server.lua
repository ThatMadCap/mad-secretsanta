local QBCore = exports['qb-core']:GetCoreObject()

function ServerFramework.getCitizenId(source)
    local player = QBCore.Functions.GetPlayer(source)
    return player and player.PlayerData.citizenid
end

function ServerFramework.getPlayerName(citizenId)
    local result = MySQL.single.await('SELECT charinfo FROM players WHERE citizenid = ?', {citizenId})

    if result and result.charinfo then
        local charinfo = json.decode(result.charinfo)
        if charinfo then
            return ('%s %s'):format(charinfo.firstname or '', charinfo.lastname or ''):gsub('^%s+', ''):gsub('%s+$', '')
        end
    end

    return 'Unknown'
end

function ServerFramework.validateCitizenId(citizenId)
    local result = MySQL.scalar.await('SELECT COUNT(*) FROM players WHERE citizenid = ?', {citizenId})
    return result and result > 0
end
