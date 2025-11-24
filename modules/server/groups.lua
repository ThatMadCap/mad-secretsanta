local config = lib.require('config.sv_config')
lib.locale()

-- Helper functions ----------------------------------------

-- Assign random gifts to players
local function createGiftAssignments(memberCount)
    local gifts = {}
    local availableGifts = {}

    for i = 1, #config.giftList do
        availableGifts[#availableGifts + 1] = config.giftList[i]
    end

    while #availableGifts < memberCount do
        for i = 1, #config.giftList do
            availableGifts[#availableGifts + 1] = config.giftList[i]
            if #availableGifts >= memberCount then break end
        end
    end

    for i = 1, memberCount do
        local randomIndex = math.random(#availableGifts)
        gifts[i] = availableGifts[randomIndex]
        table.remove(availableGifts, randomIndex)
    end

    return gifts
end

-- Assign Secret Santa recipients
local function createValidAssignments(members)
    local assignments = {}
    local availableRecipients = {}

    for i = 1, #members do
        availableRecipients[i] = {}
        for j = 1, #members do
            if i ~= j then
                availableRecipients[i][#availableRecipients[i] + 1] = members[j]
            end
        end
    end

    for i = 1, #members do
        local pool = availableRecipients[i]

        if #pool == 0 then
            lib.print.error('No available recipients for member ' .. i)
            return nil
        end

        local randomIndex = math.random(#pool)
        assignments[i] = pool[randomIndex]

        -- prevent dupes
        for j = 1, #members do
            if j ~= i then
                for k = #availableRecipients[j], 1, -1 do
                    if availableRecipients[j][k] == assignments[i] then
                        table.remove(availableRecipients[j], k)
                    end
                end
            end
        end
    end

    return assignments
end

-- Callback registrations ----------------------------------------

-- Create a new Secret Santa group
lib.callback.register('mad-secretsanta:server:createGroup', function(source, groupName)
    local citizenId = ServerFramework.getCitizenId(source)

    if not citizenId then
        return {success = false, message = 'player_not_found'}
    end

    -- sanitize input
    if type(groupName) ~= 'string' then
        return {success = false, message = 'invalid_group_name'}
    end

    groupName = groupName:gsub('^%s+', ''):gsub('%s+$', '')

    if groupName == '' or #groupName < 3 or #groupName > 50 then
        return {success = false, message = 'invalid_group_name'}
    end

    groupName = groupName:gsub('[<>"\'/\\]', '')

    local existingGroup = MySQL.single.await('SELECT id FROM secretsanta_groups WHERE group_name = ?', {groupName})
    if existingGroup then
        return {success = false, message = 'group_name_taken'}
    end

    local groupId = MySQL.insert.await('INSERT INTO secretsanta_groups (creator_citizenid, group_name, status) VALUES (?, ?, ?)', {
        citizenId,
        groupName,
        'creating'
    })

    if not groupId then
        return {success = false, message = 'database_error'}
    end

    MySQL.insert.await('INSERT INTO secretsanta_members (group_id, citizen_id, is_creator) VALUES (?, ?, ?)', {
        groupId,
        citizenId,
        true
    })

    lib.print.debug(('Group "%s" created by %s (ID: %s)'):format(groupName, citizenId, groupId))

    return {success = true, message = 'group_created', groupId = groupId}
end)

-- Add a member to a group
lib.callback.register('mad-secretsanta:server:addMember', function(source, groupId, targetSource)
    if type(groupId) ~= 'number' or type(targetSource) ~= 'number' then
        return {success = false, message = 'invalid_input'}
    end

    local citizenId = ServerFramework.getCitizenId(source)
    local targetCitizenId = ServerFramework.getCitizenId(targetSource)

    if not citizenId or not targetCitizenId then
        return {success = false, message = 'player_not_found'}
    end

    local creatorCheck = MySQL.single.await('SELECT id FROM secretsanta_members WHERE group_id = ? AND citizen_id = ? AND is_creator = 1', {
        groupId,
        citizenId
    })

    if not creatorCheck then
        return {success = false, message = 'not_creator'}
    end

    local group = MySQL.single.await('SELECT status FROM secretsanta_groups WHERE id = ?', {groupId})
    if not group then
        return {success = false, message = 'group_not_found'}
    end

    if group.status == 'ready' then
        return {success = false, message = 'group_already_ready'}
    end

    local existingMember = MySQL.single.await('SELECT id FROM secretsanta_members WHERE group_id = ? AND citizen_id = ?', {
        groupId,
        targetCitizenId
    })

    if existingMember then
        return {success = false, message = 'already_in_group'}
    end

    if config.singleGroupOnly then
        local activeGroups = MySQL.query.await([[
            SELECT sm.id FROM secretsanta_members sm
            JOIN secretsanta_groups sg ON sm.group_id = sg.id
            WHERE sm.citizen_id = ? AND sg.status = 'creating'
        ]], {targetCitizenId})

        if #activeGroups > 0 then
            return {success = false, message = 'player_in_another_group'}
        end
    end

    local memberCount = MySQL.scalar.await('SELECT COUNT(*) FROM secretsanta_members WHERE group_id = ?', {groupId})
    if memberCount >= config.maxGroupSize then
        return {success = false, message = 'group_full'}
    end

    MySQL.insert.await('INSERT INTO secretsanta_members (group_id, citizen_id, is_creator) VALUES (?, ?, ?)', {
        groupId,
        targetCitizenId,
        false
    })

    ServerNotify.notify(source, {
        title = locale('secret_santa'),
        description = locale('member_added_creator'),
        type = 'success'
    })

    ServerNotify.notify(targetSource, {
        title = locale('secret_santa'),
        description = locale('member_added_member'),
        type = 'inform'
    })

    lib.print.debug(('Player %s added to group %s'):format(targetCitizenId, groupId))

    return {success = true, message = 'member_added'}
end)

-- Remove a member from a group
lib.callback.register('mad-secretsanta:server:removeMember', function(source, groupId, targetCitizenId)
    if type(groupId) ~= 'number' or type(targetCitizenId) ~= 'string' then
        return {success = false, message = 'invalid_input'}
    end

    local citizenId = ServerFramework.getCitizenId(source)

    if not citizenId then
        return {success = false, message = 'player_not_found'}
    end

    local creatorCheck = MySQL.single.await('SELECT id FROM secretsanta_members WHERE group_id = ? AND citizen_id = ? AND is_creator = 1', {
        groupId,
        citizenId
    })

    if not creatorCheck then
        return {success = false, message = 'not_creator'}
    end

    local targetCheck = MySQL.single.await('SELECT is_creator FROM secretsanta_members WHERE group_id = ? AND citizen_id = ?', {
        groupId,
        targetCitizenId
    })

    if not targetCheck then
        return {success = false, message = 'member_not_found'}
    end

    if targetCheck.is_creator then
        return {success = false, message = 'cannot_remove_creator'}
    end

    MySQL.query.await('DELETE FROM secretsanta_members WHERE group_id = ? AND citizen_id = ?', {
        groupId,
        targetCitizenId
    })

    lib.print.debug(('Player %s removed from group %s'):format(targetCitizenId, groupId))

    return {success = true, message = 'member_removed'}
end)

-- Disband a group
lib.callback.register('mad-secretsanta:server:disbandGroup', function(source, groupId)
    if type(groupId) ~= 'number' then
        return {success = false, message = 'invalid_input'}
    end

    local citizenId = ServerFramework.getCitizenId(source)

    if not citizenId then
        return {success = false, message = 'player_not_found'}
    end

    local creatorCheck = MySQL.single.await('SELECT id FROM secretsanta_members WHERE group_id = ? AND citizen_id = ? AND is_creator = 1', {
        groupId,
        citizenId
    })

    if not creatorCheck then
        return {success = false, message = 'not_creator'}
    end

    MySQL.query.await('DELETE FROM secretsanta_groups WHERE id = ?', {groupId})

    lib.print.debug(('Group %s disbanded by %s'):format(groupId, citizenId))

    return {success = true, message = 'group_disbanded'}
end)

-- Ready up a group and assign Secret Santas
lib.callback.register('mad-secretsanta:server:readyGroup', function(source, groupId, useGiftList)
    if type(groupId) ~= 'number' or type(useGiftList) ~= 'boolean' then
        return {success = false, message = 'invalid_input'}
    end

    local citizenId = ServerFramework.getCitizenId(source)

    if not citizenId then
        return {success = false, message = 'player_not_found'}
    end

    local creatorCheck = MySQL.single.await('SELECT id FROM secretsanta_members WHERE group_id = ? AND citizen_id = ? AND is_creator = 1', {
        groupId,
        citizenId
    })

    if not creatorCheck then
        return {success = false, message = 'not_creator'}
    end

    local group = MySQL.single.await('SELECT status FROM secretsanta_groups WHERE id = ?', {groupId})
    if not group then
        return {success = false, message = 'group_not_found'}
    end

    if group.status == 'ready' then
        return {success = false, message = 'group_already_ready'}
    end

    local members = MySQL.query.await('SELECT citizen_id FROM secretsanta_members WHERE group_id = ?', {groupId})

    if #members < config.minGroupSize then
        return {success = false, message = 'not_enough_members'}
    end

    local citizenIds = {}
    for i = 1, #members do
        citizenIds[i] = members[i].citizen_id
    end

    local assignments = createValidAssignments(citizenIds)

    if not assignments then
        lib.print.error('Failed to create valid assignments for group ' .. groupId)
        return {success = false, message = 'assignment_failed'}
    end

    local gifts = nil
    if useGiftList then
        gifts = createGiftAssignments(#citizenIds)
    end

    for i = 1, #citizenIds do
        if gifts then
            MySQL.update.await('UPDATE secretsanta_members SET assigned_to_citizen_id = ?, assigned_gift = ? WHERE group_id = ? AND citizen_id = ?', {
                assignments[i],
                gifts[i],
                groupId,
                citizenIds[i]
            })
        else
            MySQL.update.await('UPDATE secretsanta_members SET assigned_to_citizen_id = ? WHERE group_id = ? AND citizen_id = ?', {
                assignments[i],
                groupId,
                citizenIds[i]
            })
        end
    end

    MySQL.update.await('UPDATE secretsanta_groups SET status = ?, use_gift_list = ? WHERE id = ?', {'ready', useGiftList and 1 or 0, groupId})

    for i = 1, #citizenIds do
        local memberSource = nil
        for _, playerId in ipairs(GetPlayers()) do
            if ServerFramework.getCitizenId(playerId) == citizenIds[i] then
                memberSource = playerId
                break
            end
        end

        if memberSource then
            local recipientName = ServerFramework.getPlayerName(assignments[i])
            local description = locale('your_recipient'):format(recipientName)

            if gifts then
                description = description .. '\n' .. locale('gift_assigned'):format(gifts[i])
            end

            ServerNotify.notify(tonumber(memberSource), {
                title = locale('secret_santa'),
                description = description,
                type = 'success',
                duration = 10000
            })
        end
    end

    lib.print.debug(('Group %s is now ready with assignments'):format(groupId))

    return {success = true, message = 'group_ready'}
end)

-- Get player's groups
lib.callback.register('mad-secretsanta:server:getMyGroups', function(source)
    local citizenId = ServerFramework.getCitizenId(source)

    if not citizenId then
        return {success = false, message = 'player_not_found'}
    end

    local groups = MySQL.query.await([[
        SELECT 
            sg.id,
            sg.group_name,
            sg.status,
            sg.created_at,
            sm.is_creator,
            sm.assigned_to_citizen_id,
            (SELECT COUNT(*) FROM secretsanta_members WHERE group_id = sg.id) as member_count
        FROM secretsanta_groups sg
        JOIN secretsanta_members sm ON sg.id = sm.group_id
        WHERE sm.citizen_id = ?
        ORDER BY sg.created_at DESC
    ]], {citizenId})

    return {success = true, groups = groups or {}}
end)

-- Get group details
lib.callback.register('mad-secretsanta:server:getGroupDetails', function(source, groupId)
    if type(groupId) ~= 'number' then
        return {success = false, message = 'invalid_input'}
    end

    local citizenId = ServerFramework.getCitizenId(source)

    if not citizenId then
        return {success = false, message = 'player_not_found'}
    end

    local memberCheck = MySQL.single.await('SELECT is_creator, assigned_to_citizen_id, assigned_gift FROM secretsanta_members WHERE group_id = ? AND citizen_id = ?', {
        groupId,
        citizenId
    })

    if not memberCheck then
        return {success = false, message = 'not_in_group'}
    end

    local group = MySQL.single.await('SELECT * FROM secretsanta_groups WHERE id = ?', {groupId})

    if not group then
        return {success = false, message = 'group_not_found'}
    end

    local members = MySQL.query.await('SELECT citizen_id, is_creator, assigned_to_citizen_id, assigned_gift FROM secretsanta_members WHERE group_id = ?', {groupId})

    for i = 1, #members do
        members[i].name = ServerFramework.getPlayerName(members[i].citizen_id)
        if members[i].assigned_to_citizen_id and group.status == 'ready' then
            members[i].assigned_to_name = ServerFramework.getPlayerName(members[i].assigned_to_citizen_id)
        end
    end

    return {
        success = true,
        group = group,
        members = members,
        isCreator = memberCheck.is_creator,
        assignment = memberCheck.assigned_to_citizen_id and group.status == 'ready' and ServerFramework.getPlayerName(memberCheck.assigned_to_citizen_id) or nil,
        assignedGift = memberCheck.assigned_gift
    }
end)

-- Get player name by server ID
lib.callback.register('mad-secretsanta:server:getPlayerName', function(source, targetSource)
    if type(targetSource) ~= 'number' then
        return 'Unknown'
    end

    local citizenId = ServerFramework.getCitizenId(targetSource)
    if not citizenId then
        return GetPlayerName(targetSource)
    end
    return ServerFramework.getPlayerName(citizenId)
end)
