-- :InsertCRDSchema -- pick a Kubernetes CRD schema from datreeio/CRDs-catalog
-- and insert the matching yaml-language-server modeline.

local M = {}

local tree_url = "https://api.github.com/repos/datreeio/CRDs-catalog/git/trees/main?recursive=1"
local raw_url = "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/"
local cache_file = vim.fn.stdpath("cache") .. "/crd_schemas.txt"
local max_age = 24 * 60 * 60

local function fetch()
    local result = vim.system({
        "curl",
        "--fail",
        "--silent",
        "--show-error",
        "--location",
        "--max-time",
        "10",
        "--header",
        "Accept: application/vnd.github.v3+json",
        tree_url,
    }):wait()
    if result.code ~= 0 then
        return nil, vim.trim(result.stderr)
    end

    local ok, data = pcall(vim.json.decode, result.stdout)
    if not ok or type(data) ~= "table" or type(data.tree) ~= "table" then
        return nil, "unexpected response from GitHub"
    end

    local schemas = {}
    for _, node in ipairs(data.tree) do
        if node.type == "blob" and node.path:match("%.json$") then
            table.insert(schemas, node.path)
        end
    end
    return schemas
end

local function schema_list()
    local stat = vim.uv.fs_stat(cache_file)
    if stat and os.time() - stat.mtime.sec < max_age then
        return vim.fn.readfile(cache_file)
    end

    local schemas, err = fetch()
    if schemas then
        vim.fn.writefile(schemas, cache_file)
        return schemas
    end
    if stat then
        vim.notify("Could not refresh the CRD schemas, using the cached list: " .. err, vim.log.levels.WARN)
        return vim.fn.readfile(cache_file)
    end
    vim.notify("Could not fetch the CRD schemas: " .. err, vim.log.levels.ERROR)
    return {}
end

function M.insert_modeline()
    local schemas = schema_list()
    if #schemas == 0 then
        return
    end

    require("fzf-lua").fzf_exec(schemas, {
        prompt = "Select CRD Schema> ",
        actions = {
            ["default"] = function(selected)
                if not selected or not selected[1] then
                    return
                end
                local modeline = "# yaml-language-server: $schema=" .. raw_url .. selected[1]
                local row = vim.api.nvim_win_get_cursor(0)[1]
                vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { modeline })
            end,
        },
    })
end

return M
