--[[
List entries in a table.
]]
function list_kv(tab)
  for key, value in pairs(tab) do
    print(key .. ": " .. tostring(value))
  end
end
