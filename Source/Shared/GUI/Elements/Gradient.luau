local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)

return function(Color :ColorSequence, Rotation :number)
    return Roact.createElement("UIGradient", {
        Color = Color;
        Rotation = Rotation or 0;
    }, {})
end