#!/usr/bin/env lua

-- Source files
--- Source lua, concatenated in reverse order
local filepaths_source = {"lib/script/linking-mic2.lua", "lib/utils/debug.lua"}
--- Yaml config file
local filepath_config = "etc/config.yaml"
--- Output filename
local filepath_output = "dist/monolith.lua"

--[[
https://stackoverflow.com/a/41350070
]]
local function reversedipairsiter(t, i)
    i = i - 1
    if i ~= 0 then
        return i, t[i]
    end
end
function reversedipairs(t)
    return reversedipairsiter, t, #t + 1
end

local function read_file(path)
    local f = assert(io.open(path))
    local content = f:read("*a")
    f:close()
    return content
end

--[[
Convert yaml configuration to LUA code.
]]
local function serialize_config(config_path)
    local yaml = require("yaml")
    local config = yaml.eval(read_file(config_path))
    -- serialize config to Lua table literal
    local serpent = require("serpent")
    return "config = " .. serpent.block(config)
end

os.remove(filepath_output)
output = io.open(filepath_output, "w")
output:write(serialize_config(filepath_config), "\n\n")
for _, src in reversedipairs(filepaths_source) do
    output:write("-- ", src, "\n")
    output:write(read_file(src), "\n\n")
end
output:close()
