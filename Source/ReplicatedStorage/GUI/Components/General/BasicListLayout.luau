local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local Enums = require(ReplicatedStorage.Game.Modules.Enums)

return function(ListType :Enums.Enum)
    return Roact.createElement("UIListLayout", {
        SortOrder = ListType == Enums.UiListType.ByLayoutOrder and Enum.SortOrder.LayoutOrder or Enum.SortOrder.Name
    }, {})
end