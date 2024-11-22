return {
    Name = "opengui";
    Aliases = {"gui"};
    Description = "Open a given GUI";
    Group = "DefaultAdmin";
    Args = {
        {
            Type = "gui";
            Name = "Gui";
            Description = "Which GUI to open?";
        };
        {
            Type = "player";
            Name = "Player";
            Description = "The player to open the GUI for";
            Optional = true;
        };
    };
}