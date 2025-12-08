#!/usr/bin/env lua

local output_filename = 'monolith.lua'
local map_file = 'dist/' .. output_filename .. '.map'
local lyaml = require('lyaml')


function list_kv(tab)
  for key, value in pairs(tab) do
    print(key .. ': ' .. tostring(value))
  end
end
function read_file(path)
  local f = assert(io.open(path))
  local content = f:read('*a')
  f:close()
  return content
end
function find_src_origin_map_idx(map, line_no)
  for k,v in ipairs(map) do
    if (v.s <= line_no and v.e >= line_no) then
      return k
    end
  end
end
function replace_at_idx(str, substr, i_start, i_end)
  s_begin = string.sub(str, 0, i_start-1)
  s_end = string.sub(str, i_end, #str)
  return s_begin .. substr .. s_end
end

function main()
  map = lyaml.load(read_file(map_file))

  -- local count = 1
  while true do
    local line = io.read()
    if line == nil then break end
    s1_a, s1_b = string.find(line, output_filename)
    if s1_a then
      -- lua stacktrace
      s2_a, s2_b = string.find(
        line,
        '%[string "' .. output_filename .. '"]%:%d*:'
      )
      if s2_a then
        -- [string "monolith.lua"]:58:
        --          |           |  |
        --          |           |  d_start 24 chars in
        --          |           f_end = f_start + #output_filename
        --          f_start = 9 chars in
        -- line_no = 58
        --
        -- filename
        f_start = s2_a + 9 -- or s1_a?
        f_end   = f_start + #output_filename
        -- line_no
        d_start = f_end + 3
        d_end   = s2_b
        --
        line_no = tonumber(string.sub(line, d_start, d_end-1))
        map_idx = find_src_origin_map_idx(map, line_no)
        line_no_new = (line_no - map[map_idx].s)
        line = replace_at_idx(line, line_no_new, d_start, d_end)
        line = replace_at_idx(line, map[map_idx].file, f_start, f_end)
      end

      -- wpexec log-line
      s2_a, s2_b = string.find(
        line,
        output_filename .. ':%d*:'
      )
      if s2_a then
        -- I 00:00:00.000000  s-custom monolith.lua:100:main: <logline>
        --
        -- filename
        f_start = s1_a
        f_end   = s1_a + #output_filename
        --  line_no
        d_start = f_end + 1
        d_end   = s2_b
        --
        line_no = tonumber(string.sub(line, d_start, d_end-1))
        map_idx = find_src_origin_map_idx(map, line_no)
        line_no_new = (line_no - map[map_idx].s)
        line = replace_at_idx(line, line_no_new, d_start, d_end)
        line = replace_at_idx(line, map[map_idx].file, f_start, f_end)
      end
    end
    io.write(line, '\n')
  end
end

main()
