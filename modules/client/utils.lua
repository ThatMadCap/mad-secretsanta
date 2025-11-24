-- Format Unix timestamp to something readable
local function formatDateTime(timestamp)
    if not timestamp then return end

    local currentTime = GetCloudTimeAsInt()
    local diff = currentTime - timestamp

    -- 1 hour
    if diff < 3600 then
        local minutes = math.floor(diff / 60)
        if minutes < 1 then
            return 'Just now'
        end
        return ('%d min ago'):format(minutes)
    end

    -- 24 hours
    if diff < 86400 then
        local hours = math.floor(diff / 3600)
        return ('%d hour%s ago'):format(hours, hours > 1 and 's' or '')
    end

    -- days
    local days = math.floor(diff / 86400)
    return ('%d day%s ago'):format(days, days > 1 and 's' or '')
end

return {
    formatDateTime = formatDateTime
}
