local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CaveDecorClass = {}
CaveDecorClass.__index = CaveDecorClass

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local TroveClass = require(ReplicatedStorage.Packages.trove)

local MineService

function CaveDecorClass.New(DecorModel: Model, InitialPosition: Vector3, Tint: Color3)
	if MineService == nil then
		MineService = Knit.GetService("MineService")
	end

	local self = setmetatable({}, CaveDecorClass)

	self._Trove = TroveClass.new()
	self.Model = DecorModel:Clone()
	self.Destroyed = false

	local ModelDestroyConnection = self.Model.Destroying:Connect(function()
		self:_Destroy()
	end)

	self._Trove:Add(self.Model)
	self._Trove:Add(ModelDestroyConnection)

	local Hitbox = self.Model:FindFirstChild("Hitbox") :: Part
	Hitbox.Size = Hitbox.Size - Vector3.new(1, 0, 1)
	self.Model.PrimaryPart = Hitbox
	self.Model.Parent = workspace
	self.Model:PivotTo(CFrame.new(InitialPosition))

	self:SnapToGround(Tint)

	return self
end

function CaveDecorClass:_FindAttachedStone()
	if self.Model then
		local Model = self.Model :: Model
		local HitBox = Model.PrimaryPart
		local BoundsSize = HitBox.Size
		local BoundsCFrame = HitBox.CFrame

		local PositionCFrame = BoundsCFrame - Vector3.new(0, BoundsSize.Y / 2, 0)

		local Params = OverlapParams.new()
		Params.FilterDescendantsInstances = { workspace.Game.Mine }
		Params.FilterType = Enum.RaycastFilterType.Include

		local Parts = workspace:GetPartBoundsInBox(PositionCFrame, Vector3.new(BoundsSize.X, 7, BoundsSize.Z), Params)

		for i, Block: Part in pairs(Parts) do
			if Block.CFrame.Position.Y > PositionCFrame.Position.Y then
				table.remove(Parts, i)
				continue
			end

			local Destroy = Block.Destroying:Connect(function()
				self:Destroy()
			end)

			self._Trove:Add(Destroy)
		end
	else
		warn("No model")
	end
end

function CaveDecorClass:SnapToGround(Tint: Color3)
	local Model = self.Model
	local Hitbox = Model:FindFirstChild("Hitbox") :: Part

	local ModelCFrame = Hitbox.CFrame
	local ModelSize = Hitbox.Size

	local CornerOffsets = {
		Vector3.new(-ModelSize.X / 2, -ModelSize.Y / 2, -ModelSize.Z / 2),
		Vector3.new(ModelSize.X / 2, -ModelSize.Y / 2, -ModelSize.Z / 2),
		Vector3.new(-ModelSize.X / 2, -ModelSize.Y / 2, ModelSize.Z / 2),
		Vector3.new(ModelSize.X / 2, -ModelSize.Y / 2, ModelSize.Z / 2),
	}

	local CornerCFrames = {}

	for _, Offset: Vector3 in pairs(CornerOffsets) do
		table.insert(CornerCFrames, ModelCFrame * CFrame.new(Offset))
	end

	local Hits = 0
	local HitPositions = {}

	for _, CornerCFrame: CFrame in pairs(CornerCFrames) do
		local RayOrigin = CornerCFrame.Position
		local RayDirection = Vector3.new(0, -7, 0)
		local RaycastParams = RaycastParams.new()
		RaycastParams.FilterDescendantsInstances = { game.Workspace.Game.Mine }
		RaycastParams.FilterType = Enum.RaycastFilterType.Include

		local RaycastResult = workspace:Raycast(RayOrigin, RayDirection, RaycastParams)

		if RaycastResult then
			Hits += 1
			table.insert(HitPositions, RaycastResult.Position)
		end
	end

	if Hits ~= 4 then
		Model:Destroy()
		return
	end

	local HitY = HitPositions[1].Y

	for _, Position: Vector3 in pairs(HitPositions) do
		if Position.Y ~= HitY then
			Model:Destroy()
			return
		end
	end

	local NewCFrame = ModelCFrame - Vector3.new(0, (ModelCFrame.Position.Y - HitY) - (ModelSize.Y / 2), 0)
	Model:PivotTo(NewCFrame)

	local Params = OverlapParams.new()
	Params.FilterDescendantsInstances = { Model }
	Params.FilterType = Enum.RaycastFilterType.Exclude
	local Parts = workspace:GetPartsInPart(Hitbox, Params)

	for _, Part: BasePart in pairs(Parts) do
		if Part.CFrame.Position.Y < NewCFrame.Position.Y then
			Model:Destroy()
			return
		end
	end

	self:_RandomizeModelRotation()
	self:_FindAttachedStone()
	self:_ApplyStoneColors(Tint)

	return Model
end

function CaveDecorClass:_RandomizeModelRotation()
	if self.Model and self.Model.PrimaryPart then
		local NumberGenerator = MineService:GetRandomObject()
		local Model = self.Model :: Model

		Model:PivotTo(Model.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(NumberGenerator:NextInteger(0, 360)), 0))
	end
end

function CaveDecorClass:_ApplyStoneColors(Tint: Color3)
	if self.Model and self.Model.PrimaryPart then
		local NumberGenerator = MineService:GetRandomObject()

		for _, Object: Part in pairs(self.Model:GetDescendants()) do
			if Object:HasTag("Mine/LayerColor") then
				local DecorY = Object.CFrame.Position.Y
				local Layer = MineService:YLevelToLayer(DecorY)
				Object.Color = Layer.Stone.Color
				Object.Color = Object.Color:Lerp(
					Layer:GetAttribute("BlockColorOffset"),
					NumberGenerator:NextNumber(0, Layer:GetAttribute("BlockColorOffsetLerp"))
				)
				Object.Color = Core.Util:TintColor(Object.Color, Tint)
				Object.Material = Layer.Stone.Material
				Object.MaterialVariant = Layer.Stone.MaterialVariant
			end
		end
	end
end

function CaveDecorClass:_Destroy()
	return Promise.new(function()
		local Module = self.Model:FindFirstChildWhichIsA("ModuleScript")
		if Module then
			require(Module)(MineService)
		end

		self._Trove:Destroy()
		table.clear(self)
		self = nil
	end)
end

function CaveDecorClass:Destroy()
	self:_Destroy()
end

return {
	New = CaveDecorClass.New,
}
