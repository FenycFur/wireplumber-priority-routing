--[[
Main script
]]
log = Log.open_topic ("s-custom")

-- -- Iterate over list items
-- for i, item in ipairs(my_list) do
--   Log.info(string.format("List item %d: %s", i, item))
-- end
-- -- Access nested configuration
-- if nested_config["key1"] then
--   Log.info(string.format("key1: %s", nested_config["key1"]))
-- end

-- carla_mic_input = ObjectManager {
--   Interest {
--     type = "node",
--     Constraint { "node.name", "matches", "Gain - Mic - Condenser Boundary", type = "pw" }
-- }}
--
--
-- carla_mic_input:connect("object-added", function(_, node)
--   carla_in = true
--   carla_node = node
--   print("carla_in = true")
--   update_routing()
-- end)
-- carla_mic_input:connect("object-removed", function(_, node)
--   carla_in = false
--   print("carla_in = false")
--   update_routing()
-- end)

function link_ports(source_node, source_port, target_node, target_port)
  local link = Link("link-factory", {
    ["link.output.node"] = source_node.properties["object.id"],
    ["link.output.port"] = source_port,
    ["link.input.node"] = target_node.properties["object.id"],
    ["link.input.port"] = target_port,
    ["object.linger"] = true,
    ["node.passive"] = true
  })
  link:activate(Feature.Proxy.BOUND)
  return link
end

function get_port_name(port_id)
  for port in om:iterate {type = "port"} do
    if port.properties["object.id"] == tostring(port_id) then
      return port.properties["port.name"]
    end
  end
  return nil
end

function main()
  managed_objects = {}
  for _, device in ipairs(config['devices']) do
    log:info(string.format("%s", device["name"]))
    log:info(string.format("%s", device["selector_fieldname"]))
    log:info(string.format("%s", device["selector_value"]))
  end
end

main()

-- function update_routing()
--   if not zoom_out then
--     return
--   end
--
--   -- Iterate through all links. Disconnect all port links which connect
--   -- from our ZOOM H4's capture_AUX2 port to anywhere.
--   for link in om:iterate {type = "link"} do
--     local props = link.properties
--     local link_output_port_name = get_port_name(props["link.output.port"])
--     -- If the current link's output-connected (source) node id is the same
--     -- as the zoom_node's id, AND that source port is what we expect:
--     -- Disconnect it.
--     if    props["link.output.node"] == zoom_node.properties["object.id"]
--       and link_output_port_name     == zoom_port_name then
--       link:request_destroy()
--     end
--   end
--
--   if zoom_out then
--     if carla_in then
--       link_ports(zoom_node, zoom_port_name, carla_node, carla_port_name)
--     elseif virt_in then
--       link_ports(zoom_node, zoom_port_name, virt_node, virt_node_name)
--     end
--   end
-- end

-- carla_mic_input:activate()
-- zoom_device:activate()
-- virtual_mic_input:activate()




