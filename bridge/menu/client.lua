ClientMenu = {}

local GetResourceState = GetResourceState
local ipairs = ipairs

local menus = {
    {name = 'ox_lib', bridge = 'ox'},
    {name = 'qb-menu', bridge = 'qb'},
}

local menuFound = false

local config = lib.require('config.cl_config')
local selectedMenu = config.menu or 'ox_lib'

for _, resource in ipairs(menus) do
    if resource.name == selectedMenu and (resource.name == 'ox_lib' or GetResourceState(resource.name) == 'started') then
        -- because qb-menu just isn't enough, we need qb-input too lol
        if resource.bridge == 'qb' and GetResourceState('qb-input') ~= 'started' then
            lib.print.warn('qb-menu selected but qb-input not found: falling back to ox_lib')
            lib.load('bridge.menu.ox.client')
            menuFound = true
            break
        end

        lib.load(('bridge.menu.%s.client'):format(resource.bridge))
        lib.print.debug(('Menu system selected: %s'):format(resource.name))
        menuFound = true
        break
    end
end

if not menuFound then
    lib.load('bridge.menu.ox.client')
    lib.print.warn('Configured menu system not found: falling back to ox_lib')
end
