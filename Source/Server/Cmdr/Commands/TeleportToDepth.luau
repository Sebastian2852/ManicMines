return {
    Name = "depthteleport";
    Aliases = {};
    Description = "Teleport a player to a certain depth in the mine";
    Group = "DefaultAdmin";
    Args = {
        {
            Type = "integer";
            Name = "Depth";
            Description = "Depth to teleport to"
        };
        {
            Type = "player";
            Name = "Player";
            Description = "Player to teleport";
            Optional = true;
        }
    };
}