local config = lib.require 'config.cl_config'
local menu = lib.require('modules.client.menu')

lib.locale()

-- Register target zones ---------------------------------------------

CreateThread(function()
    if not config.locations then
        lib.print.error('No Secret Santa locations configured!')
        return
    end

    if not ClientTarget.AddBoxZone then
        lib.print.warn('No target system found')
        return
    end

    for i = 1, #config.locations do
        local location = config.locations[i]

        ClientTarget.AddBoxZone({
            name = ('secretsanta_location_%s'):format(i),
            coords = location.coords,
            size = location.size or vec3(2, 2, 2),
            rotation = location.rotation or 0,
            debug = location.debug or false,
            options = {
                {
                    name = ('secretsanta_location_%s'):format(i),
                    icon = config.targetIcon or 'fas fa-gift',
                    label = locale('open_secret_santa'),
                    onSelect = function()
                        menu.openMainMenu()
                    end,
                    action = function()
                        menu.openMainMenu()
                    end
                }
            }
        })

        lib.print.debug(('Registered target zone at %s'):format(location.coords))
    end

    lib.print.info(('Secret Santa: %s location(s) registered'):format(#config.locations))
end)

-- Event Registration ------------------------------------------------

-- Open menu from command
RegisterNetEvent('mad-secretsanta:client:openMenu', function()
    menu.openMainMenu()
end)