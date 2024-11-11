return {
    Name = "xp";
    Aliases = {};
    Description = "give a player some XP";
    Group = "DefaultAdmin";
    Args = {
        {
            Type = "player";
            Name = "Player";
            Description = "Player to give XP to";
        };
        {
            Type = "integer";
            Name = "Amount";
            Description = "Amount of Xp to give";
        }
    };
}