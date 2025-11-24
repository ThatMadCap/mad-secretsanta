ServerFramework = {}

local GetResourceState = GetResourceState
local ipairs = ipairs

local frameworks = {
    {name = 'ox_core', bridge = 'ox'},
    {name = 'qb-core', bridge = 'qb'},
    {name = 'qbx_core', bridge = 'qbx'},
    {name = 'es_extended', bridge = 'esx'},
}

local frameworkFound = false

for _, resource in ipairs(frameworks) do
    if GetResourceState(resource.name) == 'started' then
        lib.load(('bridge.framework.%s.server'):format(resource.bridge))
        lib.print.debug(('Framework found: %s'):format(resource.name))
        frameworkFound = true
        break
    end
end

if not frameworkFound then
    lib.load('bridge.framework.custom.server')
    lib.print.warn('No framework resource found: falling back to custom')
end