local Scheme = require(script.Scheme)
local Number = require(script.Number)
local String = require(script.String)
local Boolean = require(script.Boolean)

local ZenoAPI = {}
ZenoAPI.Scheme = Scheme.New

ZenoAPI.Number = Number.New
ZenoAPI.String = String.New
ZenoAPI.Boolean = Boolean.New
return ZenoAPI
