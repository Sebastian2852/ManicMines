local Config = {}

--[=[
Contains all the config for tycoons (e.g. Random names, character limit, etc)
]=]
Config.Tycoon = {
    RandomName = {
        Prefix = "The";
        Adjectives = {"Tidy"; "Red"; "Green"; "Blue";"Yellow"; "Boring"; "Exaggerated"; "Small"; "Large"; "Gargantuan"; "Rude"; "Ugly"; "Polished"; "Soup-Like"; "Galactic"; "Created"; "Googly"; "Rancid"; "Rustic"; "Fished"; "Terraformed"; "Horrible"; "Thingy"; "Joever"; "Plumbason"; "Cringey"; "Scrumptious"; "Slimey"; "Epic"; "Radical"; "Brown"; "Radio-Headed"; "Freaky"; "Scary"; "Glowing"; "Crystaline"; "Rhombus"; "Shaped"; "Pegi 12"; "Meatballed"; "Mad"; "Old"; "Flexy"; "Clear"; "Gusty"; "Combative"; "Murky"; "Quiet"; "Elite"; "Adjascent"; "Lop-sided"; "Flawless"; "Pink"; "Cubic"; "Challenged"; "Proportioned"; "Unbalanced"; "Balanced"; "Strange"; "Delicous"; "Practical"; "Lacking"; "Maniacle"; "Manic"; "Phsycologically Horrifying"; "Modern"; "Illegal"; "Obsolete"; "Triangular"; "Cosy"; "Warming"; "Welcoming"; "Handled"; "Saved"; "Structural"; "Day-Dreaming"; "Intersocial"; "Impaired"; "Grassy"; "Steep"; "Sloped"; "Blunt"; "Pegi 18"; "Vehicular"; "Sunless"; "Sceptic"};
        Nouns = {"Plum"; "House"; "Hole"; "Tycoon"; "Mine"; "Cavern"; "Toilet"; "Tavern"; "Hub"; "Stone"; "Rock"; "Game"; "Menu"; "Hatchet"; "Tree"; "Cove"; "Grove"; "Box"; "Bottle"; "Light"; "Pickaxe"; "Bar"; "Tycoonatory Home"; "Home"; "Boulder"; "Ravine"; "Mansion"; "Hotel"; "Demolition Site"; "Site"; "Swamp"; "Plateu"; "Slope"; "Mountain"; "Miner"; "Knowledge"; "Sad Thing"; "Slob"; "Slump"; "Blanket"; "Service"; "Elevator"; "Guest"; "Negotiation"; "Construction"; "Mining Industry"; ".Inc"; "Potato"; "Way"; "Responsibility"; "Malachite"; "Celestial Egg"; "Housing"; "Architecture"; "Chest"; "Sweetener"; "Supermarket"};
    };

    MaxNameCharacters = 30;
};

--[=[
The default settings for anyone. This is used when the player creates a new slot
or when the reset their settings to default.
]=]
Config.DefaultSettings = {
    GlobalShadows = true;
    RainbowEffect = true;
};

Config.MainMenu = {
    Version = "1.3";
    --[=[
    All the credits for the game; main menu will automatically fill out the credits gui with these names. DO NOT EDIT YET!!
    ]=]
    Credits = {};

    --[=[
    The changelog for the current version split up into different categories. Show on startup shows the changelog when the players plays the game for the first time in this version. DO NOT EDIT YET!!
    ]=]
    ChangeLog = {
        BugFixes = {};
        New = {};
        Removed = {};
        ShowOnStartup = false;
    };
}

Config.Admins = {
    Admins = {
        [3092257097] = {
            CanDoOtherPlayer = true; -- Can they mess with other players
        }
    };
}

Config.Mine = {
    BlockSize = Vector3.new(6, 6, 6)
}

return Config