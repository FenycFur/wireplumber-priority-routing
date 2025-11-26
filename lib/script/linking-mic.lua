-- Named after direction of signal
zoom_out = false
zoom_port_name = "capture_AUX2"
zoom_node = nil
carla_in = false
carla_port_name = "input"
carla_node = nil
virt_in = false
virt_port_name = "Virt. Mic:input_0"
virt_node = nil

om = ObjectManager {
  Interest{ type = "node" },
  Interest{ type = "port" },
  Interest{ type = "link" }
}
carla_mic_input = ObjectManager {
  Interest {
    type = "node",
    Constraint { "node.name", "matches", "Gain - Mic - Condenser Boundary", type = "pw" }
}}
zoom_device = ObjectManager {
  Interest {
    type = "node",
    Constraint { "node.name", "matches", "alsa_input.usb-ZOOM_Corporation_H4essential-00.pro-input-0", type = "pw" }
}}
virtual_mic_input = ObjectManager {
  Interest {
    type = "node",
    Constraint { "node.name", "matches", "Virt. Mic", type = "pw" }
}}


carla_mic_input:connect("object-added", function(_, node)
  carla_in = true
  carla_node = node
  print("carla_in = true")
  update_routing()
end)
carla_mic_input:connect("object-removed", function(_, node)
  carla_in = false
  print("carla_in = false")
  update_routing()
end)

zoom_device:connect("object-added", function(_, node)
  zoom_out = true
  zoom_node = node
  print("zoom_device = true")
  update_routing()
end)
zoom_device:connect("object-removed", function(_, node)
  zoom_out = false
  print("zoom_device = false")
  update_routing()
end)

virtual_mic_input:connect("object-added", function(_, node)
  virt_in = true
  virt_node = node
  print("virt_in = true")
  update_routing()
end)
virtual_mic_input:connect("object-removed", function(_, node)
  virt_in = false
  print("virt_in = false")
  update_routing()
end)


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

function list_kv(tab)
  for key, value in pairs(tab) do
    print(key .. ": " .. tostring(value))
  end
end

function get_port_name(port_id)
    for port in om:iterate {type = "port"} do
        if port.properties["object.id"] == tostring(port_id) then
            return port.properties["port.name"]
        end
    end
    return nil
end


function update_routing()
  if not zoom_out then
    return
  end

  print('disconnecting all links')
  -- Iterate through all links. Disconnect all port links which connect
  -- from our ZOOM H4's capture_AUX2 port to anywhere.
  for link in om:iterate {type = "link"} do
    local props = link.properties
    local link_output_port_name = get_port_name(props["link.output.port"])
    -- If the current link's output-connected (source) node id is the same
    -- as the zoom_node's id, AND that source port is what we expect:
    -- Disconnect it.
    if    props["link.output.node"] == zoom_node.properties["object.id"]
      and link_output_port_name     == zoom_port_name then
      link:request_destroy()
    end
  end

  print('checking rules')
  if zoom_out then
    if carla_in then
      print('connecting to carla')
      link_ports(zoom_node, zoom_port_name, carla_node, carla_port_name)
    elseif virt_in then
      print('connecting to virt mic')
      link_ports(zoom_node, zoom_port_name, virt_node, virt_node_name)
    end
  end
end

om:activate()
carla_mic_input:activate()
zoom_device:activate()
virtual_mic_input:activate()




