return {
    -- Notification system to use (ox_lib, qb-core, mad-thoughts, custom)
    notify = 'ox_lib',

    -- Menu system to use (ox_lib, qb-menu)
    menu = 'ox_lib',

    -- How far you can select nearby players
    nearbyPlayerRadius = 10.0,

    -- Target interaction icon
    targetIcon = 'fas fa-gift',

    -- Secret Santa target locations (box zone)
    locations = {
        {
            coords = vec3(-241.24, -338.33, 29.98),
            size = vec3(2.0, 2.0, 2.0),
            rotation = 0,
            debug = false
        },
        {
            coords = vec3(250.46, -1026.79, 29.26),
            size = vec3(1.0, 2.0, 2.0),
            rotation = 30,
            debug = false
        },
        -- Add/remove locations as needed
        -- {
        --     coords = vec3(x, y, z),
        --     size = vec3(2.0, 2.0, 2.0),
        --     rotation = 0,
        --     debug = false
        -- },
    }
}