local Boolean = {}
Boolean.__index = Boolean

export type Boolean = {
	CanBeNil: (self: Boolean, CanBeNil: boolean) -> Boolean,
	Check: (self: Boolean, Value: any) -> boolean,
}

function Boolean.New(): Boolean
	local self = setmetatable({}, Boolean)
	self._CanBeNil = false
	return self
end

function Boolean:CanBeNil(CanBeNil: boolean): Boolean
	self._CanBeNil = CanBeNil
	return self
end

function Boolean:Check(Value: any): boolean
	if type(Value) == "boolean" then
		return true
	else
		if type(Value) == "nil" then
			return self._CanBeNil
		end
	end

	return false
end

return Boolean
