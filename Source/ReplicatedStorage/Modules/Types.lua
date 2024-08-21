local Types = {}

--[[
An ore list is used in places like awarding the player with a set of ores
]]--
export type OreListItem = {
    Name :string;
    Amount :number;
}
export type OreList = {OreListItem}

export type Settings = {
    GlobalShadows :boolean;
}

return Types