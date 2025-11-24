function ClientTarget.AddBoxZone(data)
    local zoneName = data.name or ('zone_%s'):format(math.random(1000, 9999))

    exports['qb-target']:AddBoxZone(zoneName, data.coords, data.size.x or 2, data.size.y or 2, {
        name = zoneName,
        heading = data.rotation or 0,
        debugPoly = data.debug or false,
        minZ = data.coords.z - 1,
        maxZ = data.coords.z + 2
    }, {
        options = data.options,
        distance = 2.5
    })

    return zoneName
end

function ClientTarget.RemoveZone(zoneName)
    exports['qb-target']:RemoveZone(zoneName)
end
