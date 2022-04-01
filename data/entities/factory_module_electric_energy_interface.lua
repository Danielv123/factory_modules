return {
    type = "electric-energy-interface",
    name = "factory-module-electric-energy-interface",
    icon = "__base__/graphics/icons/assembling-machine-1.png",
    icon_size = 64, icon_mipmaps = 4,
    localised_name = {"item-name.factory-module"},
    flags = {},
    max_health = 150,
    collision_box = {{0, 0}, {0, 0}},
    selection_box = {{-0, -0}, {0, 0}},
    selectable_in_game = true, -- Should be false in final release
    energy_source =
    {
      type = "electric",
      buffer_capacity = "10GJ",
      usage_priority = "secondary-input",
      input_flow_limit = "1GW",
      output_flow_limit = "1GW"
    },
    energy_production = "0kW",
    energy_usage = "100kW",
    picture =
    {
      filename = "__core__/graphics/empty.png",
      priority = "extra-high",
      width = 1,
      height = 1
    },
    order = "h-e-e-i"
}
