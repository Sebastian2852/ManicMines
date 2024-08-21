local Config = {}

--[=[
Contains all the config for tycoons (e.g. Random names, character limit, etc)
]=]
Config.Tycoon = {
    RandomNames = {
        "Random Name 1";
        "Random Name 2";
        "Random Name 3";
    };

    MaxNameCharacters = 16;
}

--[=[
The default settings for anyone. This is used when the player creates a new slot
or when the reset their settings to default.
]=]
Config.DefaultSettings = {
    GlobalShadows = true;
}

return Config