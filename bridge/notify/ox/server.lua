--- @usage Displays a notification for the specified player
--- @param target number serverId of the player
--- @param ... table notification data
function ServerNotify.notify(target, ...)
    TriggerClientEvent('ox_lib:notify', target, ...)
end