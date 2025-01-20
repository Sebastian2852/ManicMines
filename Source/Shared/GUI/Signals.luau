local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

return {
	ToggleHUDButtons = Signal.new(),
	ToggleHUDGold = Signal.new(),
	ToggleHotbar = Signal.new(),
}
