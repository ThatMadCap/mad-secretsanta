function ClientTarget.AddBoxZone(data)
    return exports.ox_target:addBoxZone({
        coords = data.coords,
        size = data.size or vec3(2, 2, 2),
        rotation = data.rotation or 0,
        debug = data.debug or false,
        options = data.options
    })
end

function ClientTarget.RemoveZone(zoneId)
    exports.ox_target:removeZone(zoneId)
end
