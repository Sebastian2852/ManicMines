local RunService = game:GetService("RunService")
local Scheme = {}
Scheme.__index = Scheme

local NumberClass = require(script.Parent.Number)
local StringClass = require(script.Parent.String)
local BooleanClass = require(script.Parent.Boolean)
local TableClass = require(script.Parent.Table)

export type Arg = NumberClass.Number | StringClass.String | BooleanClass.Boolean | TableClass.Table

export type Scheme = {
	AddArg: (self: Scheme, Arg: Arg) -> Scheme,
	Check: (self: Scheme, ...any) -> boolean,
}

function Scheme.New(): Scheme
	local self = setmetatable({}, Scheme)
	self._Args = {}
	return self
end

function Scheme:AddArg(Arg: Arg): Scheme
	table.insert(self._Args, Arg)
	return self
end

function Scheme:AttachEvent(Event: RemoteEvent, Handler: (...any) -> nil)
	if RunService:IsServer() then
		Event.OnServerEvent:Connect(function(_, ...)
			local ValidArgs = self:Check(...)
			if not ValidArgs then
				return
			end

			Handler(...)
		end)
	else
		error(":AttachEvent() is intended for server only")
	end

	return self
end

function Scheme:Check(...: any): boolean
	local ValuesToCheck = { ... }
	local Valid = true

	for i, Value in ValuesToCheck do
		local Arg = self._Args[i]

		if Arg == nil then
			warn("Extra arg data not found for passed value; failing closed")
			Valid = false
			break
		end

		local Sucess = Arg:Check(Value)
		if Sucess == false then
			Valid = false
			break
		end
	end

	return Valid
end

return Scheme
