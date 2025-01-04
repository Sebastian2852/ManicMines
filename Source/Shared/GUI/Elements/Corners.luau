local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)

return function(Radius: number)
	Radius = math.clamp(Radius, 0, 1)
	return Roact.createElement("UICorner", {
		CornerRadius = UDim.new(Radius, 0),
	}, {})
end
