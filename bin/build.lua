#!/usr/bin/env lua

local sources = {"lib/script/linking-mic2.lua", "lib/utils/debug.lua"}
local config = "etc/config.yaml"
local output = io.open("dist/monolith.lua", "w")

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
    local config = yaml.load(read_file(config_path))
    -- serialize config to Lua table literal
    return "local CONFIG = " .. serpent.block(config)
end

output:write(serialize_config(config), "\n\n")
for _, src in ipairs(sources) do
    output:write("-- ", src, "\n")
    output:write(read_file(src), "\n\n")
end
output:close()
