return {
    init_options = {
        provideFormatter = false,
    },
    settings = {
        json = {
            -- SchemaStore.nvim is registered with lze's `on_require` handler
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
        },
    },
}
