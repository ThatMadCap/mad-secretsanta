function ClientMenu.Open(data)
    lib.registerContext({
        id = data.id,
        title = data.title,
        menu = data.menu,
        onExit = data.onExit,
        options = data.options
    })

    lib.showContext(data.id)
end

function ClientMenu.Close()
    lib.hideContext()
end

function ClientMenu.InputDialog(title, rows)
    return lib.inputDialog(title, rows)
end

function ClientMenu.AlertDialog(data)
    return lib.alertDialog({
        header = data.header,
        content = data.content,
        centered = data.centered,
        cancel = data.cancel,
        labels = data.labels
    })
end
