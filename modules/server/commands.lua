local config = lib.require('config.sv_config')

if config.command.enable then
    lib.addCommand(config.command.name or 'secretsanta', {
        help = 'Open the Secret Santa menu',
    }, function(source)
        if source == 0 then return end
        TriggerClientEvent('mad-secretsanta:client:openMenu', source)
    end)

    lib.print.debug(('Registered command: /%s'):format(config.command.name or 'secretsanta'))
end