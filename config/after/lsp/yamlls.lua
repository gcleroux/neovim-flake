-- yamlls only associates schemas by file name, so a "kubernetes" glob would
-- flag every non-Kubernetes YAML file. Instead, each buffer that looks like a
-- manifest gets its own URI associated with the Kubernetes schema; yamlls
-- then fetches CRD schemas for custom resources on its own.
local function is_kubernetes_manifest(bufnr)
    if vim.fs.basename(vim.api.nvim_buf_get_name(bufnr)):match("^kustomization%.ya?ml$") then
        return false
    end
    local api_version, kind = false, false
    for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
        api_version = api_version or line:match("^apiVersion:") ~= nil
        kind = kind or line:match("^kind:") ~= nil
        if api_version and kind then
            return true
        end
    end
    return false
end

local function associate_kubernetes(client, bufnr)
    if not is_kubernetes_manifest(bufnr) then
        return
    end
    local schemas = client.settings.yaml.schemas
    schemas.kubernetes = schemas.kubernetes or {}
    local uri = vim.uri_from_bufnr(bufnr)
    if not vim.list_contains(schemas.kubernetes, uri) then
        table.insert(schemas.kubernetes, uri)
        client:notify("workspace/didChangeConfiguration", { settings = client.settings })
    end
end

return {
    settings = {
        yaml = {
            -- The oldest cluster managed; bump it when that cluster is upgraded.
            kubernetesVersion = "1.34.1",
            schemas = {
                ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
                ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
                ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
                ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
                ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
                ["http://json.schemastore.org/ansible-playbook"] = "*play*.{yml,yaml}",
                ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
                ["https://json.schemastore.org/dependabot-v2"] = ".github/dependabot.{yml,yaml}",
                ["https://json.schemastore.org/gitlab-ci"] = "*gitlab-ci*.{yml,yaml}",
                ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json"] = "*api*.{yml,yaml}",
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
                ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = "*flow*.{yml,yaml}",
            },
        },
    },
    on_attach = function(client, bufnr)
        associate_kubernetes(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePost", {
            group = vim.api.nvim_create_augroup("yamlls_kubernetes_" .. bufnr, { clear = true }),
            buffer = bufnr,
            callback = function()
                associate_kubernetes(client, bufnr)
            end,
        })
    end,
}
