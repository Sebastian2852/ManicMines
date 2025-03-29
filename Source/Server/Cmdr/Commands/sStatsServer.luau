local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function()
	local AdminService = Knit.GetService("AdminService")
	local StartTime = AdminService:GetServerStartTime() :: DateTime
	local LocalTime = StartTime:ToLocalTime()

	local StartTimeString =
		`{LocalTime["Day"]}/{LocalTime["Month"]}/{LocalTime["Year"]} - {LocalTime["Hour"]}:{LocalTime["Minute"]}:{LocalTime["Second"]}`

	return `Server started: {StartTimeString} || Total players who joined: {AdminService:GetTotalPlayerJoinCount()}`
end
