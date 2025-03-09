local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DiscordBridge = require(ReplicatedStorage.Packages.DiscordBridge)

local URL =
	"https://discord.com/api/webhooks/1348327491739324426/rz87d8gY2BNltY7Uk9IJi2vxOVPfWA3jnB3thdc5ysuuOm6i07tmgbLD_QgdoCXZ3bjd"
local Hook = DiscordBridge.Hook.new({ URL })

local OreAnnouncer = {}

function OreAnnouncer:AnnounceOreMined(Player: Player, OreName: string, _: Color3, Rarity: number)
	local Message = DiscordBridge.Message
		.new()
		:WithName("Ore Announcer")
		:WithAvatar(
			"https://static.wikia.nocookie.net/manic-mines/images/d/d1/ManicMinesLogo.png/revision/latest?cb=20250309161803"
		)
		:AddEmbed(
			`{Player.DisplayName} mined {OreName}`,
			`{Player.DisplayName} (@{Player.Name})`,
			`{Player.DisplayName} mined {OreName} which is a 1 in {Rarity}`,
			"",
			Color3.new(1, 1, 1)
		)

	Hook:SendMessage(Message)
end

return OreAnnouncer
