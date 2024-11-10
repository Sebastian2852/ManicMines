return {
    Name = "collapsemine";
    Aliases = {"minegobyebye"};
    Description = "Force the mine to collapse with an optional new seed";
    Group = "DefaultAdmin";
    Args = {
        {
            Type = "integer";
            Name = "Seed";
            Description = "An optional seed for the new ore";
            Optional = true;
        }
    };
}