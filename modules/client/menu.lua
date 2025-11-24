local proximity = lib.require('modules.client.proximity')
local utils = lib.require('modules.client.utils')
local config = lib.require('config.sv_config')
lib.locale()

local enableGiftList = config.enableGiftList

-- Menu functions ----------------------------------------

-- Main Secret Santa menu
local function openMainMenu()
    local options = {
        {
            title = locale('create_group'),
            description = locale('create_group_desc'),
            icon = 'plus',
            onSelect = function()
                local input = ClientMenu.InputDialog(locale('create_group'), {
                    {
                        type = 'input',
                        label = locale('group_name_label'),
                        description = locale('group_name_desc'),
                        required = true,
                        min = 3,
                        max = 50
                    }
                })

                if not input or not input[1] then return end

                local result = lib.callback.await('mad-secretsanta:server:createGroup', false, input[1])

                if not result then
                    ClientNotify.notify({
                        title = locale('secret_santa'),
                        description = 'No response from server',
                        type = 'error'
                    })
                    return
                end

                local notifType = result.success and 'success' or 'error'
                ClientNotify.notify({
                    title = locale('secret_santa'),
                    description = locale(result.message),
                    type = notifType
                })
            end
        },
        {
            title = locale('my_groups'),
            description = locale('my_groups_desc'),
            icon = 'users',
            onSelect = function()
                OpenMyGroupsMenu()
            end
        }
    }

    ClientMenu.Open({
        id = 'secretsanta_main',
        title = locale('secret_santa'),
        options = options
    })
end

-- My Groups menu
function OpenMyGroupsMenu()
    local result = lib.callback.await('mad-secretsanta:server:getMyGroups', false)

    if not result.success then
        ClientNotify.notify({
            title = locale('secret_santa'),
            description = locale(result.message),
            type = 'error'
        })
        return
    end

    if #result.groups == 0 then
        ClientNotify.notify({
            title = locale('secret_santa'),
            description = locale('no_groups'),
            type = 'inform'
        })
        return
    end

    local options = {}

    for i = 1, #result.groups do
        local group = result.groups[i]
        local statusIcon = group.status == 'ready' and 'check' or 'clock'
        local statusText = group.status == 'ready' and locale('status_ready') or locale('status_creating')

        local groupOption = {
            title = group.group_name,
            description = ('%s | %s %s'):format(statusText, locale('members'), group.member_count),
            icon = statusIcon,
            metadata = {
                {label = locale('created'), value = utils.formatDateTime(group.created_at)},
                {label = locale('role'), value = group.is_creator and locale('creator') or locale('member')}
            },
            onSelect = function()
                OpenGroupDetailsMenu(group.id)
            end
        }

        options[#options + 1] = groupOption
    end

    options[#options + 1] = {
        title = locale('back'),
        icon = 'arrow-left',
        onSelect = function()
            openMainMenu()
        end
    }

    ClientMenu.Open({
        id = 'secretsanta_mygroups',
        title = locale('my_groups'),
        menu = 'secretsanta_main',
        options = options
    })
end

-- Group Details menu
function OpenGroupDetailsMenu(groupId)
    local result = lib.callback.await('mad-secretsanta:server:getGroupDetails', false, groupId)

    if not result.success then
        ClientNotify.notify({
            title = locale('secret_santa'),
            description = locale(result.message),
            type = 'error'
        })
        return
    end

    local options = {}

    if result.group.status == 'ready' and result.assignment then
        local description = result.assignment
        if result.assignedGift then
            description = description .. '\n\n' .. locale('your_gift') .. ': ' .. result.assignedGift
        end

        options[#options + 1] = {
            title = locale('your_assignment'),
            description = description,
            icon = 'user',
            iconColor = '#06CE6B'
        }
    end

    -- Members section
    options[#options + 1] = {
        title = locale('members_list'),
        icon = 'users',
        iconColor = '#2B78FC',
        disabled = true
    }

    for i = 1, #result.members do
        local member = result.members[i]
        local roleText = member.is_creator and (' (%s)'):format(locale('creator')) or ''

        options[#options + 1] = {
            title = member.name .. roleText,
            icon = 'user',
            disabled = true
        }
    end

    -- Creator actions
    if result.isCreator and result.group.status == 'creating' then
        options[#options + 1] = {
            title = locale('add_nearby_player'),
            description = locale('add_nearby_player_desc'),
            icon = 'user-plus',
            onSelect = function()
                OpenNearbyPlayersMenu(groupId)
            end
        }

        -- Remove member option
        options[#options + 1] = {
            title = locale('remove_member'),
            description = locale('remove_member_desc'),
            icon = 'user-minus',
            onSelect = function()
                OpenRemoveMemberMenu(groupId, result.members)
            end
        }

        -- Ready group option
        options[#options + 1] = {
            title = locale('ready_group'),
            description = locale('ready_group_desc'),
            icon = 'check-circle',
            iconColor = '#06CE6B',
            onSelect = function()
                local confirm = ClientMenu.AlertDialog({
                    header = locale('ready_group'),
                    content = locale('ready_group_confirm'),
                    centered = true,
                    cancel = true
                })

                if confirm ~= 'confirm' then return end

                local useGiftList = false

                -- Use gift list?
                if enableGiftList then
                    local useGifts = ClientMenu.AlertDialog({
                        header = locale('gift_list_title'),
                        content = locale('gift_list_prompt'),
                        centered = true,
                        cancel = true,
                        labels = {
                            confirm = locale('gift_list_yes'),
                            cancel = locale('gift_list_no')
                        }
                    })

                    useGiftList = useGifts == 'confirm'
                end

                local readyResult = lib.callback.await('mad-secretsanta:server:readyGroup', false, groupId, useGiftList)

                if not readyResult.success then
                    ClientNotify.notify({
                        title = locale('secret_santa'),
                        description = locale(readyResult.message),
                        type = 'error'
                    })
                    return
                end

                ClientNotify.notify({
                    title = locale('secret_santa'),
                    description = locale(readyResult.message),
                    type = 'success'
                })
                OpenMyGroupsMenu()
            end
        }
    end

    -- Disband option
    if result.isCreator then
        options[#options + 1] = {
            title = locale('disband_group'),
            description = locale('disband_group_desc'),
            icon = 'trash',
            iconColor = '#FE2436',
            onSelect = function()
                local confirm = ClientMenu.AlertDialog({
                    header = locale('disband_group'),
                    content = locale('disband_group_confirm'),
                    centered = true,
                    cancel = true
                })

                if confirm ~= 'confirm' then return end

                local disbandResult = lib.callback.await('mad-secretsanta:server:disbandGroup', false, groupId)

                if not disbandResult.success then
                    ClientNotify.notify({
                        title = locale('secret_santa'),
                        description = locale(disbandResult.message),
                        type = 'error'
                    })
                    return
                end

                ClientNotify.notify({
                    title = locale('secret_santa'),
                    description = locale(disbandResult.message),
                    type = 'success'
                })
                OpenMyGroupsMenu()
            end
        }
    end

    options[#options + 1] = {
        title = locale('back'),
        icon = 'arrow-left',
        onSelect = function()
            OpenMyGroupsMenu()
        end
    }

    ClientMenu.Open({
        id = 'secretsanta_groupdetails',
        title = result.group.group_name,
        menu = 'secretsanta_mygroups',
        options = options
    })
end

-- Nearby Players menu
function OpenNearbyPlayersMenu(groupId)
    local nearbyPlayers = proximity.getNearbyPlayers()
    local myServerId = GetPlayerServerId(PlayerId())

    -- filter out self
    local filteredPlayers = {}
    for i = 1, #nearbyPlayers do
        if nearbyPlayers[i].serverId ~= myServerId then
            filteredPlayers[#filteredPlayers + 1] = nearbyPlayers[i]
        end
    end

    if #filteredPlayers == 0 then
        ClientNotify.notify({
            title = locale('secret_santa'),
            description = locale('no_nearby_players'),
            type = 'inform'
        })
        return
    end

    local options = {}

    for i = 1, #filteredPlayers do
        local player = filteredPlayers[i]

        -- Add player option
        options[#options + 1] = {
            title = player.name,
            description = ('%s: %.2fm'):format(locale('distance'), player.distance),
            icon = 'user',
            onSelect = function()
                local addResult = lib.callback.await('mad-secretsanta:server:addMember', false, groupId, player.serverId)

                if not addResult.success then
                    ClientNotify.notify({
                        title = locale('secret_santa'),
                        description = locale(addResult.message),
                        type = 'error'
                    })
                    return
                end

                OpenGroupDetailsMenu(groupId)
            end
        }
    end

    options[#options + 1] = {
        title = locale('back'),
        icon = 'arrow-left',
        onSelect = function()
            OpenGroupDetailsMenu(groupId)
        end
    }

    ClientMenu.Open({
        id = 'secretsanta_nearbyplayers',
        title = locale('nearby_players'),
        menu = 'secretsanta_groupdetails',
        options = options
    })
end

-- Remove Member menu
function OpenRemoveMemberMenu(groupId, members)
    local options = {}

    for i = 1, #members do
        local member = members[i]

        if not member.is_creator then
            options[#options + 1] = {
                title = member.name,
                icon = 'user-minus',
                iconColor = '#FB8607',
                onSelect = function()
                    local confirmText = locale('remove_member_confirm')
                    local confirm = ClientMenu.AlertDialog({
                        header = locale('remove_member'),
                        content = confirmText and confirmText:format(member.name) or ('Remove %s?'):format(member.name),
                        centered = true,
                        cancel = true
                    })

                    if confirm ~= 'confirm' then return end

                    local removeResult = lib.callback.await('mad-secretsanta:server:removeMember', false, groupId, member.citizen_id)

                    if not removeResult.success then
                        ClientNotify.notify({
                            title = locale('secret_santa'),
                            description = locale(removeResult.message),
                            type = 'error'
                        })
                        return
                    end

                    ClientNotify.notify({
                        title = locale('secret_santa'),
                        description = locale(removeResult.message),
                        type = 'success'
                    })
                    OpenGroupDetailsMenu(groupId)
                end
            }
        end
    end

    if #options == 0 then
        ClientNotify.notify({
            title = locale('secret_santa'),
            description = locale('no_members_to_remove'),
            type = 'inform'
        })
        return
    end

    options[#options + 1] = {
        title = locale('back'),
        icon = 'arrow-left',
        onSelect = function()
            OpenGroupDetailsMenu(groupId)
        end
    }

    ClientMenu.Open({
        id = 'secretsanta_removemember',
        title = locale('remove_member'),
        menu = 'secretsanta_groupdetails',
        options = options
    })
end

return {
    openMainMenu = openMainMenu
}
