-- requirements: lua-yaml
-- config_filepath = "~/.config/wireplumber/main.lua.d/config.yaml"
--
-- yaml = require("yaml")
-- om = ObjectManager {
--   Interest{ type = "node" },
--   Interest{ type = "port" },
--   Interest{ type = "link" }
-- }
-- om:activate()
--
-- -- configuration
-- devices = {}
-- links = {}
--
-- -- Load configuration from file
-- function read_config(filepath)
--   local file = io.open(filepath, "r")
--   if not file then
--     error ("Could not open config file: " .. filepath)
--   end
--   local content = file:read("*all")
--   file:close()
--   return yaml.parse(content)
-- end
-- function load_config(filepath)
--   local config = read_config(filepath)
--   for device in config['devices'] do
--     devices['device']['name'] = device
--     print(device)
--     print(device['name'])
--   end
-- end
--
-- load_config(config_filepath)

log = Log.open_topic ("s-custom")
local config = ... or {}

print('a')
list_kv(sm-settings)
print('a')
-- Access your settings
local my_setting = config["my_setting"] or "default value"
local device_name = config["device_name"] or "Default Device"
local threshold = config["threshold"] or 0
local my_list = config["my_list"] or {}
local nested_config = config["nested_config"] or {}

-- Use the configuration
print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
log:info(string.format("my_setting: %s", my_setting))
log:info(string.format("device_name: %s", device_name))
log:info(string.format("threshold: %d", threshold))
print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

-- Iterate over list items
for i, item in ipairs(my_list) do
    Log.info(string.format("List item %d: %s", i, item))
end

-- Access nested configuration
if nested_config["key1"] then
    Log.info(string.format("key1: %s", nested_config["key1"]))
end


-- Record expected device configuration
--




-- carla_mic_input = ObjectManager {
--   Interest {
--     type = "node",
--     Constraint { "node.name", "matches", "Gain - Mic - Condenser Boundary", type = "pw" }
-- }}
-- zoom_device = ObjectManager {
--   Interest {
--     type = "node",
--     Constraint { "node.name", "matches", "alsa_input.usb-ZOOM_Corporation_H4essential-00.pro-input-0", type = "pw" }
-- }}
-- virtual_mic_input = ObjectManager {
--   Interest {
--     type = "node",


--     Constraint { "node.name", "matches", "Virt. Mic", type = "pw" }
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
--
-- zoom_device:connect("object-added", function(_, node)
--   zoom_out = true
--   zoom_node = node
--   print("zoom_device = true")
--   update_routing()
-- end)
-- zoom_device:connect("object-removed", function(_, node)
--   zoom_out = false
--   print("zoom_device = false")
--   update_routing()
-- end)
--
-- virtual_mic_input:connect("object-added", function(_, node)
--   virt_in = true
--   virt_node = node
--   print("virt_in = true")
--   update_routing()
-- end)
-- virtual_mic_input:connect("object-removed", function(_, node)
--   virt_in = false
--   print("virt_in = false")
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




