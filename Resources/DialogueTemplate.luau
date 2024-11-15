return {
	NpcName = "Test"; -- The name of the NPC
	InteractMessage = "Talk"; -- The interaction text that appears on the proximity prompt

    -- All the dialogue that can happen with this NPC
	Dialogue = {
		Text = "Awesome test dialogue"; -- What the dialogue should say
		LeaveText = "Bye"; -- The text to show as the "Leave" option
		CanLeave = true; -- Does the leave button appear

        -- The possible choices for this dialogue
		Choices = {
            -- Choices work like this:
            --[=[
                [OPTION TEXT] = DATA
            ]=]
            -- Where "OPTION TEXT" is the text that will appear on the button for that choice
            -- "DATA" is the actual dialogue that happens when you press the button; data is the same exact thing as the "Dialogue" tabe above

            -- Here is an example of a simple choice
			["Hello!"] = {
				Index = 1; -- This is the order the choice should appear (Leave option will ALWAYS be last)
				Text = "Hello There!";
				LeaveText = "Goodbye";
				CanLeave = true;
			};

            -- An example of a choice that has 2 sub-choices
			["Shut up"] = {
				Index = 2;
				Text = "How dare you!";
				CanLeave = false;

                -- Choices can has choices within them, there is no limit.
				Choices = {
					["You heard what I said"] = {
						Index = 1;
						Text = "Rude";
						LeaveText = "Shush";
						CanLeave = true;
					};

					["Nevermind"] = {
						Index = 2;
						Text = "Thats what I thought";
						LeaveText = "...";
						CanLeave = true;
					}
				}
			}
		}
	}
}
