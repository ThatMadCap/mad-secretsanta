-- Convert ox_lib menu format to qb-menu format
local function convertOptions(options)
    local qbOptions = {}

    for i = 1, #options do
        local opt = options[i]

        local params = {}

        if opt.disabled then
            params.event = nil
            params.isAction = false
        elseif opt.onSelect then
            params.isAction = true
            params.event = opt.onSelect
        elseif opt.serverEvent then
            params.event = opt.serverEvent
            params.isServer = true
        end

        qbOptions[#qbOptions + 1] = {
            header = opt.title,
            txt = opt.description,
            icon = opt.icon,
            params = params
        }
    end

    return qbOptions
end

function ClientMenu.Open(data)
    local qbData = {
        {
            header = data.title,
            isMenuHeader = true,
            icon = 'fas fa-gift'
        }
    }

    local converted = convertOptions(data.options)
    for i = 1, #converted do
        qbData[#qbData + 1] = converted[i]
    end

    exports['qb-menu']:openMenu(qbData)
end

function ClientMenu.Close()
    exports['qb-menu']:closeMenu()
end

function ClientMenu.InputDialog(title, rows)
    local inputs = {}
    for i = 1, #rows do
        local row = rows[i]
        inputs[#inputs + 1] = {
            text = row.label,
            name = ('input_%s'):format(i),
            type = row.type == 'number' and 'number' or 'text',
            isRequired = row.required
        }
    end

    local result = exports['qb-input']:ShowInput({
        header = title,
        inputs = inputs
    })

    if result then
        local output = {}
        for i = 1, #rows do
            output[i] = result[('input_%s'):format(i)]
        end
        return output
    end

    return nil
end

function ClientMenu.AlertDialog(data)
    -- FIXME:
    -- qb-menu doesn't have alert dialogs, use ox_lib as fallback
    return lib.alertDialog({
        header = data.header,
        content = data.content,
        centered = data.centered,
        cancel = data.cancel,
        labels = data.labels
    })
end
