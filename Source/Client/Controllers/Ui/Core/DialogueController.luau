local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local DialogueKit = ReplicatedStorage.Packages.DialogueKit

local DialogueController = Knit.CreateController { Name = "DialogueController" }

-- [[ PUBLIC ]] --

function DialogueController:SetupSkin(ScreenGui: ScreenGui)
	local Theme = require(ReplicatedStorage.Game.GUI.Theme)
	local CustomSkin = DialogueKit.Skins.Custom.CustomSkin

	CustomSkin.DialogueIcon.Visible = false

	CustomSkin.DialogueText.Size = UDim2.fromScale(0.448, 0.195)
	CustomSkin.DialogueText.BackgroundColor3 = Theme.BackgroundColor
	CustomSkin.DialogueText.BackgroundTransparency = 0.5

	CustomSkin.DialogueTitle.BackgroundTransparency = 0.5
	CustomSkin.DialogueTitle.BackgroundColor3 = Theme.BackgroundColor

	local DialogueLabel = CustomSkin.DialogueText.DialogueTextLabel
	DialogueLabel.Size = UDim2.new(1, -15, 0.9, -15)
	DialogueLabel.Position = UDim2.new(0.5, 0, 0, 8)
	DialogueLabel.AnchorPoint = Vector2.new(0.5, 0)
	DialogueLabel.FontFace = Theme.Font
	DialogueLabel.TextColor3 = Theme.TextColor
	DialogueLabel.RichText = true

	local TitleLabel = CustomSkin.DialogueText.DialogueTextLabel
	TitleLabel.FontFace = Theme.Font
	TitleLabel.TextColor3 = Theme.TextColor

	local ContinueButton = CustomSkin.ContinueButton
	ContinueButton.BackgroundTransparency = 1
	ContinueButton.Size = UDim2.new(0.448, -15, 0.025, 0)
	ContinueButton.Position = UDim2.new(0.5, 2, 0.936, 0)
	ContinueButton.ContinueButton.BackgroundTransparency = 1
	ContinueButton.TextLabel.Size = UDim2.fromScale(0.125, 1)
	ContinueButton.TextLabel.Position = UDim2.fromScale(1, 1)
	ContinueButton.TextLabel.AnchorPoint = Vector2.new(1, 1)
	ContinueButton.TextLabel.FontFace = Theme.Font

	local Replies = CustomSkin.DialogueReplies
	Replies.AnchorPoint = Vector2.new(0, 1)
	Replies.Position = UDim2.fromScale(0.73, 0.95)
	Replies.Size = UDim2.fromScale(0.2, 0.225)
	Replies.UIPadding:Destroy()

	local RepliesLayout = Replies.UIGridLayout
	RepliesLayout.CellPadding = UDim2.fromScale(0, 0.05)
	RepliesLayout.CellSize = UDim2.fromScale(1, 0.15)
	RepliesLayout.FillDirection = Enum.FillDirection.Vertical
	RepliesLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	RepliesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

	local ReplyButton = Replies.CustomReply
	ReplyButton.BackgroundColor3 = Theme.BackgroundColor
	ReplyButton.TextLabel.TextColor3 = Theme.TextColor
	ReplyButton.TextLabel.FontFace = Theme.Font
	ReplyButton.TextLabel.TextXAlignment = Enum.TextXAlignment.Left

	local DialogueModule = ScreenGui.Main.DialoguesModule :: ModuleScript
	ScreenGui:FindFirstChild("DialogueFrame"):Destroy()
	DialogueModule:ClearAllChildren()

	local Reply = CustomSkin.DialogueReplies.CustomReply
	Reply.Name = "Reply"
	Reply.Parent = DialogueModule

	CustomSkin.Name = "DialogueFrame"
	CustomSkin.Visible = false
	CustomSkin.Parent = ScreenGui
end

-- [[ KNIT ]] --

function DialogueController:KnitStart()
	local NewGUI = DialogueKit.Dialogues:Clone()
	self:SetupSkin(NewGUI)
	NewGUI.Parent = Knit.Player.PlayerGui
end

return DialogueController
