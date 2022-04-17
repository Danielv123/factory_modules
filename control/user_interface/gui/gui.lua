local draw_module_list  = require "control.user_interface.gui.module_list.draw_module_list"
local draw_module_info  = require "control.user_interface.gui.module_list.module_info.draw_module_info"
local draw_module_panel = require "control.user_interface.gui.module_list.module_info.module_panel.draw_module_panel"
local update_module_panel = require "control.user_interface.gui.module_list.module_info.module_panel.update_module_panel"

return {
    draw_module_list = draw_module_list,
    draw_module_info = draw_module_info,
    draw_module_panel = draw_module_panel,
    update_module_panel = update_module_panel,
}
