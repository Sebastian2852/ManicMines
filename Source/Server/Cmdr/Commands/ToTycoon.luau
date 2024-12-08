return {
    Name = "tycoon";
    Aliases = {};
    Description = "Teleport to a player's tycoon";
    Group = "DefaultAdmin";
    Args = {
        {
            Type = "player";
            Name = "Tycoon";
            Description = "The player's tycoon to teleport to";
            Optional = true;
        }
    };
}