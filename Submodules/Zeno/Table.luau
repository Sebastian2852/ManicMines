local Table = {}
Table.__index = Table

local NumberClass = require(script.Parent.Number)

export type Table = {
	SizeBiggerThan: (self: Table, MinSize: number) -> Table,
	SizeSmallerThan: (self: Table, MaxSize: number) -> Table,
	CanBeNil: (self: Table, CanBeNil: boolean) -> Table,
	Check: (self: Table, Value: any) -> boolean,
}

function Table.New(): Table
	local self = setmetatable({}, Table)
	self._CanBeNil = false
	self._MinSize = 0
	self._MaxSize = nil
	return self
end

function Table:SizeBiggerThan(MinSize: number): Table
	local ValidSize = NumberClass.New():Above(0):Check(MinSize)
	if not ValidSize then
		error("Min size of a table must be above 0")
		return self
	end

	self._MinSize = MinSize
	return self
end

function Table:SizeSmallerThan(MaxSize: number): Table
	local ValidSize = NumberClass.New():Above(0):Check(MaxSize)
	if not ValidSize then
		error("Max size of a table must be above 0")
		return self
	end

	self._MaxSize = MaxSize
	return self
end

function Table:CanBeNil(CanBeNil: boolean): Table
	self._CanBeNil = CanBeNil
	return self
end

function Table:Check(Value: any): boolean
	if type(Value) == "table" then
		return true
	else
		if type(Value) == "nil" then
			return self._CanBeNil
		end
	end

	return false
end

return Table
