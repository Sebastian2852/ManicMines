return function(Context, Speed: number, Player: Player?)
	if Player == nil then
		Player = Context.Executor
	end

	local Character = Player.Character
	if not Character then
		return "FAILED: No character"
	end

	local Humanoid = Character:WaitForChild("Humanoid")
	local SpeedToSet = Speed == 0 and 16 or Speed

	Humanoid.WalkSpeed = SpeedToSet
	return "Set " .. Player.Name .. "'s walkspeed to " .. tostring(Speed)
end
