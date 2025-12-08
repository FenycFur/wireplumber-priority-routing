#!/usr/bin/env lua

-- Source files
--- Source lua, concatenated in reverse order
local filepaths_source = {'lib/script/linking-mic2.lua', 'lib/utils/debug.lua'}
--- Yaml config file
local filepath_config = 'etc/config.yaml'
--- Output filename
local dir_output = 'dist'
local name_output = 'monolith.lua'

-- System packages
local lyaml = require('lyaml')

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
function read_file(path)
    local f = assert(io.open(path))
    local content = f:read('*a')
    f:close()
    return content
end

--[[
Convert yaml configuration to LUA code.
]]
function list_kv(tab)
  for key, value in pairs(tab) do
    print(key .. ': ' .. tostring(value))
  end
end
local function serialize_config(config_path)
    -- local yaml = require("yaml")
    -- local config = yaml.eval(read_file(config_path))
    config = lyaml.load(read_file(config_path))
    -- serialize config to Lua table literal
    local serpent = require('serpent')
    return 'config = ' .. serpent.block(config)
end
--[[
]]
function count_lines(str)
  return select(2, str:gsub('\n', '\n')) + 1
end

--[[
]]
function write_map_entry(map, line, content_filepath, content)
  new_line = line + count_lines(content)
  table.insert(t_map, {file=content_filepath, s=line, e=new_line})
  return new_line + 1
end

--[[
]]
function main()
  local out_monolith = dir_output .. '/' .. name_output
  local out_map = out_monolith .. '.map'

  -- Clean up previously built files
  os.remove(out_monolith)
  os.remove(out_map)

  -- Start writing to monolith, and tracking code origin
  f_monolith = io.open(out_monolith, 'w')
  t_map ={}

  -- Config
  local content = serialize_config(filepath_config)
  f_monolith:write(content, '\n')
  local line = 0
  line = write_map_entry(t_map, line, filepath_config, content)

  -- Requirements
  for _, src in reversedipairs(filepaths_source) do
      f_monolith:write('-- ', src, '\n')
      content = read_file(src)
      f_monolith:write(content, '\n')
      line = write_map_entry(t_map, line, src, content)
  end
  f_monolith:close()

  f_map = io.open(out_map, 'w')
  f_map:write(lyaml.dump({t_map}))
  f_map:close()
end

main()
