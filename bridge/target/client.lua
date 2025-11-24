ClientTarget = {}

local GetResourceState = GetResourceState

local targets = {
    {name = 'ox_target', bridge = 'ox'},
    {name = 'qb-target', bridge = 'qb'},
}

local targetFound = false

for _, resource in ipairs(targets) do
    if GetResourceState(resource.name) == 'started' then
        lib.load(('bridge.target.%s.client'):format(resource.bridge))
        lib.print.debug(('Target system found: %s'):format(resource.name))
        targetFound = true
        break
    end
end

if not targetFound then
    lib.print.warn('No target system found (ox_target or qb-target)')
end
