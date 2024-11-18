--[=[
TODO:
    - Add a setting to only make the proximity prompt appear for the owner of the tycoon.
    - Add a function to set the proximity prompt parent (would get the Level and model and returns the parent)
]=]

local UpgradeSetup = {}

-- Does this upgrade have a proximity prompt
UpgradeSetup.HasPrompt = true

-- Should the proximity prompt be put in the hitbox
UpgradeSetup.ParentToHitbox = true

--[=[
ONLY IF `HasPrompt` IS TRUE

This function is expected to return 2 strings. First the action string and then second the object string.
The function is provided with all of the info needed (TycoonName, Level, MaxLevel).
]=]
function UpgradeSetup.CreatePrompt(TycoonName :string, Level :number, MaxLevel :number) :(string, string)
    print("Data recieved: \nName: "..TycoonName.."\nLevel: "..Level.."\nMaxLevel: "..MaxLevel)
    return "Action", "Object"
end

--[=[
ONLY IF `HasPrompt` IS TRUE

This function doesnt need to return anything. This function is called when the proximity prompt is triggered. This function
is provided with the player who triggered the prompt and the owner of the tycoon.
]=]
function UpgradeSetup.Triggered(Player :Player, IsOwner :boolean)
    print("Data recieved: \nPlayer: "..tostring(Player.Name).."\nIsOwner: "..tostring(IsOwner))
end

return UpgradeSetup