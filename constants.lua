return {
    ENERGY_INTERFACE_COUNT = 100, -- 1 to 100
    MIN_MODULE_SIZE = 6, -- Minimum wall length - 1, so a value of 6 means the smallest module allowed is 7x7
    WALL_PIECES = {"stone-wall", "steel-chest", "wooden-chest", "constant-combinator", "gate", "express-transport-belt"}, -- Allowed module wall pieces
    MODULE_UPDATE_INTERVAL = 32, -- How often modules are updated
    MODULE_ACTIVE_CHECK_INTERVAL = 32, -- How often modules are checked for validity
    MODULE_POWER_UPDATE_INTERVAL = 32, -- How often modules are checked for power consumption
    NOT_ALLOWED_IN_MODULE = {
        "roboport",
        "logistic-chest-active-provider",
        "logistic-chest-passive-provider",
        "logistic-chest-requester",
        "logistic-chest-buffer",
        "logistic-chest-storage",
    }
}
