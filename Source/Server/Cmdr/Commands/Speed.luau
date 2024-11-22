return {
    Name = "speed";
    Aliases = {};
    Description = "Set a player's speed";
    Group = "DefaultAdmin";
    Args = {
        {
            Type = "integer";
            Name = "Speed";
            Description = "The speed to set the player (0 for default speed)"
        };
        {
            Type = "player";
            Name = "Player";
            Optional = true;
            Description = "Who the speed should be applied to"
        };
    };
}