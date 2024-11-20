local Config = {}

--[=[
Contains all the config for tycoons (e.g. Random names, character limit, etc)
]=]
Config.Tycoon = {
    RandomName = {
        Prefix = "The";
        Adjectives = {"Tidy"; "Red"; "Green"; "Blue";"Yellow"; "Boring"; "Exaggerated"; "Small"; "Large"; "Gargantuan"; "Rude"; "Ugly"; "Polished"; "Soup-Like"; "Galactic"; "Created"; "Googly"; "Rancid"; "Rustic"; "Fished"; "Terraformed"; "Horrible"; "Thingy"; "Joever"; "Plumbason"; "Cringey"; "Scrumptious"; "Slimey"; "Epic"; "Radical"; "Brown"; "Radio-Headed"; "Freaky"; "Scary"; "Glowing"; "Crystaline"; "Rhombus"; "Shaped"; "Pegi 12"; "Meatballed"; "Mad"; "Old"; "Flexy"; "Clear"; "Gusty"; "Combative"; "Murky"; "Quiet"; "Elite"; "Adjascent"; "Lop-sided"; "Flawless"; "Pink"; "Cubic"; "Challenged"; "Proportioned"; "Unbalanced"; "Balanced"; "Strange"; "Delicous"; "Practical"; "Lacking"; "Maniacle"; "Manic"; "Phsycologically Horrifying"; "Modern"; "Illegal"; "Obsolete"; "Triangular"; "Cosy"; "Warming"; "Welcoming"; "Handled"; "Saved"; "Structural"; "Day-Dreaming"; "Intersocial"; "Impaired"; "Grassy"; "Steep"; "Sloped"; "Blunt"; "Pegi 18"; "Vehicular"; "Sunless"; "Sceptic"; "Slimy"; "Succulent"; "Delicious"; "Robloxian"; "New Alt's"; "Ben's"; "Soup Like"; "Liquid"; "Boiled"; "Eggy"; "Solid"; "Gassy"; "Thin"; "Fat"; "Buff"; "Strong"; "Sturdy"; "Weak"; "Horrible"; "Mental"; "The Important Asset:"; "Chocolate"; "Vanilla"; "Strawberry"; "Configurated"; "Manly"; "Stainless"; "Splumple"};
        Nouns = {"Plum"; "House"; "Hole"; "Tycoon"; "Mine"; "Cavern"; "Toilet"; "Tavern"; "Hub"; "Stone"; "Rock"; "Game"; "Menu"; "Hatchet"; "Tree"; "Cove"; "Grove"; "Box"; "Bottle"; "Light"; "Pickaxe"; "Bar"; "Tycoonatory Home"; "Home"; "Boulder"; "Ravine"; "Mansion"; "Hotel"; "Demolition Site"; "Site"; "Swamp"; "Plateu"; "Slope"; "Mountain"; "Miner"; "Knowledge"; "Sad Thing"; "Slob"; "Slump"; "Blanket"; "Service"; "Elevator"; "Guest"; "Negotiation"; "Construction"; "Mining Industry"; ".Inc"; "Potato"; "Way"; "Responsibility"; "Malachite"; "Celestial Egg"; "Housing"; "Architecture"; "Chest"; "Sweetener"; "Supermarket"; "House"; "Hole"; "Tycoon"; "Mine"; "Cavern"; "Toilet"; "Tavern"; "Hub"; "Stone"; "Rock"; "Game"; "Menu"; "Hatchet"; "Tree"; "Cove"; "Grove"; "Box"; "Bottle"; "Light"; "Pickaxe"; "Bar"; "Tycoonatory Home"; "Home"; "Boulder"; "Ravine"; "Mansion"; "Hotel"; "Demolition Site"; "Site"; "Swamp"; "Plateu"; "Slope"; "Mountain"; "Miner"; "Knowledge"; "Tome of Anciet Spirits"; "Graveyard"; "Lanyard"; "Ore"; "Tree"; "Terra-Toilet"; "Coder"; "Developer"; "Shack"; "Debug Error"; "ERROR 404-TYCOON NAME NOT FOUND"; "Comment"; "and Snarky Shark"; "and Selectable Grove"; "Lagoon of Treasure"; "Boat"; "Pirate Ship"; "Plum"; "Player Package"; "Package"; "Steel"; "Tycoon"; "Simulator"; "Light"; "Tunnel"; "Finder"; "Parent"; "Data Setting"; "and Ugly Guy"; "Top-Hat"; "Canyon"; "Isosceles Triangle"; "Equilateral"; "Algebreic Proof"; "Circle Theorem"}; 
    };

    MaxNameCharacters = 30;
    UpgradeSelectionDistance = 32;
}

--[=[
The default settings for anyone. This is used when the player creates a new slot
or when the reset their settings to default.
]=]
Config.DefaultSettings = {
    GlobalShadows = true;
    RainbowEffect = true;
    MusicVolume = 0.5;
}

Config.MainMenu = {
    Version = "1.0.0";
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
        [3092257097] = true;
        [3220168401] = true;
    };
}

Config.Mine = {
    BlockSize = Vector3.new(6, 6, 6);
    BlocksToCollapse = 100000000;
    ChanceToGenerateOre = 2;
}

Config.Chat = {
    ServerTagColor = Color3.fromRGB(255, 0, 0);
    Players = {
        [3092257097] = {Tag = "Dev", TagColor = Color3.fromRGB(179, 138, 255), NameColor = Color3.fromRGB(255, 255, 255)};
        [3220168401] = {Tag = "Dev", TagColor = Color3.fromRGB(179, 138, 255), NameColor = Color3.fromRGB(255, 255, 255)};
    }
}

return Config