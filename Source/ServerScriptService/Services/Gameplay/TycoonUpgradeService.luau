local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[=[
THIS SYSTEM NEEDS TO BE REWORKED

Currently it does everything at the start of the game. That is fine until we conisder things like other players. If you were to invite someone they could use your
upgrades as their own, which shouldn't happen.

The way it is setup right now it is impossible to do the above nor pass anything like "TycoonOwner" or "Level". So rather than doing everything at the start we should do it
by getting the tycoon service to tell us when a new upgrade has been made and then check if anything has a matching tag then set it up right then and there.
]=]

local Knit = require(ReplicatedStorage.Packages.Knit)

local TycoonUpgradeService = Knit.CreateService {
    Name = "TycoonUpgradeService";
    Client = {
        OpenStorage = Knit.CreateSignal();
    };
}

return TycoonUpgradeService