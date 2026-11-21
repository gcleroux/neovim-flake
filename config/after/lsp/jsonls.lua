return {
    init_options = {
        provideFormatter = false,
    },
    settings = {
        json = {
            validate = { enable = true },
        },
    },
    -- Set in place: the client sends the settings table it was created with,
    -- so assigning a new config.settings here would never reach the server.
    before_init = function(_, config)
        config.settings.json.schemas = require("schemastore").json.schemas()
    end,
}
