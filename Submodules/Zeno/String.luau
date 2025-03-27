local String = {}
String.__index = String

export type String = {
	LongerThan: (self: String, Length: number) -> String,
	ShorterThan: (self: String, Length: number) -> String,
	Check: (self: String, Value: any) -> boolean,
}

function String.New(): String
	local self = setmetatable({}, String)
	self._MinLength = nil
	self._MaxLength = nil
	self._CanBeNil = nil
	return self
end

function String:LongerThan(Length: number): String
	self._MinLength = Length
	return self
end

function String:ShorterThan(Length: number): String
	self._MaxLength = Length
	return self
end

function String:CanBeNil(CanBeNil: boolean): String
	self._CanBeNil = CanBeNil
	return self
end

function String:Check(Value: any): boolean
	if type(Value) == "string" then
		local StringLength = Value:len() :: number

		if self._MinLength then
			if StringLength < self._MinLength then
				return false
			end
		end

		if self._MaxLength then
			if StringLength > self._MaxLength then
				return false
			end
		end
		return true
	else
		if type(Value) == "nil" then
			return self._CanBeNil
		end
	end

	return false
end

return String
