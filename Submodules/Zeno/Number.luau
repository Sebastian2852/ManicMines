local Number = {}
Number.__index = Number

export type Number = {
	Above: (self: Number, Min: number) -> Number,
	Below: (self: Number, Max: number) -> Number,
	WithinRange: (self: Number, Min: number, Max: number) -> Number,
	CanBeNil: (self: Number, CanBeNil: boolean) -> Number,
	Check: (self: Number, Value: any) -> boolean,
}

function Number.New(): Number
	local self = setmetatable({}, Number)
	self._Min = nil
	self._Max = nil
	self._CanBeNil = false
	return self
end

function Number:Above(Min: number): Number
	self._Min = Min
	return self
end

function Number:Below(Max: number): Number
	self._Max = Max
	return self
end

function Number:WithinRange(Min: number, Max: number): Number
	self:Below(Max)
	self:Above(Min)
	return self
end

function Number:CanBeNil(CanBeNil: boolean): Number
	self._CanBeNil = CanBeNil
	return self
end

function Number:Check(Value: any): boolean
	if type(Value) == "number" then
		if self._Min then
			if Value < self._Min then
				return false
			end
		end

		if self._Max then
			if Value > self._Max then
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

return Number
