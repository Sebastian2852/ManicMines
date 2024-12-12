if not plugin then return end

local Toolbar = plugin:CreateToolbar("Manic Mines")
local PluginsModulesFolder = script.Parent.Plugins

for _, Module :ModuleScript in pairs(PluginsModulesFolder:GetChildren()) do
    local PluginInfo = require(Module)
    PluginInfo:CreatePluginButton(plugin, Toolbar)
end