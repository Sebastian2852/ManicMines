local ReplicatedStorage = game:GetService("ReplicatedStorage")
return function(_, PlayerToGive: Player, Ore: string, Amount: number)
	local Data = ReplicatedStorage.PlayerData:FindFirstChild(PlayerToGive.UserId)
	if not Data then
		return "Failed to get " .. PlayerToGive.Name .. "'s data folder"
	end

	local Value = Data.Inventory.Ores:FindFirstChild(Ore)
	if not Value then
		return "Failed to find the data for ore" .. tostring(Ore)
	end

	Value.Value += Amount
	return "Gave " .. PlayerToGive.Name .. " " .. tostring(Amount) .. " " .. tostring(Ore)
end
