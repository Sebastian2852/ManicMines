local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local MainMenuController = Knit.CreateController { Name = "MainMenuController" }

local DataService
local LogService
local TextFilteringService

-- [[ PUBLIC ]] --

function MainMenuController:PickRandomName() :string
    local Name = Core.GameConfig.Tycoon.RandomName.Prefix

    local Adjectives = Core.GameConfig.Tycoon.RandomName.Adjectives
    local Nouns = Core.GameConfig.Tycoon.RandomName.Nouns

    local RandomAdjective = Adjectives[math.random(1, #Adjectives)]
    local RandomNoun = Nouns[math.random(1, #Nouns)]

    Name = Name.." "..RandomAdjective.." "..RandomNoun
    return Name
end



-- [[ GUI ]] --

local MainMenuComponent = Roact.Component:extend("MainMenu")

local HideMenu = Instance.new("BindableEvent")

function MainMenuComponent:Text(Hovered :boolean, HoveredText :string, NormalText :string) :string
    return Hovered and HoveredText or NormalText
end

function MainMenuComponent:CreateUsedSlotFrame(Slot :Core.SlotInfo)
    local TimeNow = os.time()
    local TimeDifferent = TimeNow - (Slot.LastPlayed or 0)
    local TimeText = Core.Util:TimeAgo(TimeDifferent)

    local ShowSlotDelete = self.state.CurrentDeletingSlot == Slot.SlotID

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 0.3);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        LayoutOrder = Slot.SlotID;
    }, {
        DeleteSlot = ShowSlotDelete and Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.6, 0.9);
            Position = UDim2.fromScale(1.1, 0.5);
            AnchorPoint = Core.UI.AnchorPoint.LeftCenter;

            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            Arrow = Roact.createElement("ImageLabel", {
                Size = UDim2.fromScale(0.3, 1);
                Position = Core.UI.Position.LeftCenter;
                AnchorPoint = Core.UI.AnchorPoint.LeftCenter;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Image = "rbxassetid://12008863261";
                Rotation = 180;
                ImageTransparency = 0.5;
                ImageColor3 = Core.UI.Theme.BackgroundColorPrimary;
                ScaleType = Enum.ScaleType.Fit;
            }, {});

            Container = Roact.createElement("Frame", {
                Size = UDim2.fromScale(0.7, 0.9);
                Position = Core.UI.Position.RightCenter;
                AnchorPoint = Core.UI.AnchorPoint.RightCenter;

                BorderSizePixel = 0;
                BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary;
                BackgroundTransparency = 0.5;
            }, {
                Title = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(1, 0.5);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;

                    Text = "Delete slot "..tostring(Slot.SlotID).."?";
                    TextScaled = true;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Theme.TextColor3;
                }, {});

                Buttons = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1, 0.5);
                    Position = Core.UI.Position.BottomCenter;
                    AnchorPoint = Core.UI.AnchorPoint.BottomCenter;

                    BorderSizePixel = 0;
                    BackgroundTransparency = 1;
                }, {
                    Layout = Roact.createElement("UIListLayout", {
                        Padding = UDim.new(0.1, 0);
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        FillDirection = Enum.FillDirection.Horizontal;
                        VerticalAlignment = Enum.VerticalAlignment.Center;
                        HorizontalAlignment = Enum.HorizontalAlignment.Center;
                    }, {});

                    YesButton = Roact.createElement("TextButton", {
                        Size = UDim2.fromScale(0.4, 0.35);
                        BackgroundColor3 = Core.UI.Theme.OpenButtonColor;
                        LayoutOrder = 2;

                        Text = "Yes";
                        TextScaled = true;
                        FontFace = Core.UI.Theme.TextFont;
                        TextColor3 = Core.UI.Color.White;

                        [Roact.Event.MouseButton1Click] = function()
                            self:setState({
                                SlotInfos = "none";
                            })
                            DataService:DeleteSlot(Slot.SlotID)
                            task.wait(1)
                            DataService:GetSlotsInfo():andThen(function(Info)
                                LogService:Log("Updating slot info")
                                self:setState({
                                    SlotInfos = Info;
                                })
                            end)
                        end
                    }, {
                        Corners = Roact.createElement("UICorner", {
                            CornerRadius = UDim.new(0.3, 0)
                        }, {});
                    });

                    NoButton = Roact.createElement("TextButton", {
                        Size = UDim2.fromScale(0.4, 0.35);
                        BackgroundColor3 = Core.UI.Theme.CloseButtonColor;
                        LayoutOrder = 1;

                        Text = "No";
                        TextScaled = true;
                        FontFace = Core.UI.Theme.TextFont;
                        TextColor3 = Core.UI.Color.White;

                        [Roact.Event.MouseButton1Click] = function()
                            self:setState({
                                CurrentDeletingSlot = 0;
                            })
                        end;
                    }, {
                        Corners = Roact.createElement("UICorner", {
                            CornerRadius = UDim.new(0.3, 0)
                        }, {});
                    });
                })
            })
        });

        Left = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.5, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            TycoonName = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.3);
                Position = UDim2.fromScale(0.5, 0.2);
                AnchorPoint = Core.UI.AnchorPoint.TopCenter;

                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Text = Slot.TycoonName;
                TextScaled = true;
                FontFace = Core.UI.Theme.TextFont;
                TextColor3 = Core.UI.Theme.TextColor3;
            }, {});

            Buttons = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.5);
                Position = Core.UI.Position.BottomCenter;
                AnchorPoint = Core.UI.AnchorPoint.BottomCenter;

                BorderSizePixel = 0;
                BackgroundTransparency = 1;
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    Padding = UDim.new(0.1, 0);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    FillDirection = Enum.FillDirection.Horizontal;
                    VerticalAlignment = Enum.VerticalAlignment.Center;
                    HorizontalAlignment = Enum.HorizontalAlignment.Center;
                }, {});

                PlayButton = Roact.createElement("TextButton", {
                    Size = UDim2.fromScale(0.4, 0.35);
                    BackgroundColor3 = Core.UI.Theme.OpenButtonColor;
                    LayoutOrder = 1;

                    Text = "Play";
                    TextScaled = true;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Color.White;

                    [Roact.Event.MouseButton1Click] = function()
                        DataService:LoadData(Slot.SlotID)
                        task.wait(1)
                        HideMenu:Fire()
                    end
                }, {
                    Corners = Roact.createElement("UICorner", {
                        CornerRadius = UDim.new(0.3, 0)
                    }, {});
                });

                DeleteButton = Roact.createElement("TextButton", {
                    Size = UDim2.fromScale(0.4, 0.35);
                    BackgroundColor3 = Core.UI.Theme.CloseButtonColor;
                    LayoutOrder = 2;

                    Text = "Delete";
                    TextScaled = true;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Color.White;

                    [Roact.Event.MouseButton1Click] = function()
                        self:setState({
                            CurrentDeletingSlot = Slot.SlotID;
                        })
                    end;
                }, {
                    Corners = Roact.createElement("UICorner", {
                        CornerRadius = UDim.new(0.3, 0)
                    }, {});
                });
            })
        });

        Right = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.45, 1);
            Position = Core.UI.Position.RightCenter;
            AnchorPoint = Core.UI.AnchorPoint.RightCenter;

            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            Layout = Roact.createElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder;
                VerticalAlignment = Enum.VerticalAlignment.Center;
            }, {});

            LastPlayed = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.2);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Text = "- Last Played: "..TimeText;
                TextScaled = true;
                FontFace = Core.UI.Theme.TextFont;
                TextColor3 = Core.UI.Theme.TextColor3;
                TextXAlignment = Enum.TextXAlignment.Left;
            }, {});

            Gold = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.2);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Text = "- Gold: "..tostring(Slot.Gold);
                TextScaled = true;
                FontFace = Core.UI.Theme.TextFont;
                TextColor3 = Core.UI.Theme.TextColor3;
                TextXAlignment = Enum.TextXAlignment.Left;
            }, {});
        })
    })
end

function MainMenuComponent:CreateUnUsedSlotFrame(Slot :Core.SlotInfo)
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 0.3);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        LayoutOrder = Slot.SlotID;
    }, {
        Title = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 0.25);
            Position = UDim2.fromScale(0, 0.1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Text = "Unused slot";
            TextScaled = true;
            FontFace = Core.UI.Theme.TextFont;
            TextColor3 = Core.UI.Theme.TextColor3;
        }, {});

        Buttons = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.5);
            Position = Core.UI.Position.BottomCenter;
            AnchorPoint = Core.UI.AnchorPoint.BottomCenter;

            BorderSizePixel = 0;
            BackgroundTransparency = 1;
        }, {
            Layout = Roact.createElement("UIListLayout", {
                Padding = UDim.new(0.1, 0);
                SortOrder = Enum.SortOrder.LayoutOrder;
                FillDirection = Enum.FillDirection.Horizontal;
                VerticalAlignment = Enum.VerticalAlignment.Center;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
            }, {});

            CreateButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.4, 0.35);
                BackgroundColor3 = Core.UI.Theme.OpenButtonColor;
                LayoutOrder = 1;

                Text = "Create";
                TextScaled = true;
                FontFace = Core.UI.Theme.TextFont;
                TextColor3 = Core.UI.Color.White;

                [Roact.Event.MouseButton1Click] = function()
                    self:setState({
                        SelectSlotVisible = false;
                        CreateSlotVisible = true;
                        CurrentSlot = Slot.SlotID;
                    })
                end
            }, {
                Corners = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0.3, 0)
                }, {});
            });
        });
    })
end

function MainMenuComponent:CreateSlotFrames()
    local SlotInfos = self.state.SlotInfos

    local Elements = {
        Layout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder;
        }, {})
    }

    for _, Slot in pairs(SlotInfos) do
        if Slot.Used then
            Elements[tostring(Slot.SlotID)] = self:CreateUsedSlotFrame(Slot)
        else
            Elements[tostring(Slot.SlotID)] = self:CreateUnUsedSlotFrame(Slot)
        end
    end

    return Elements
end

function MainMenuComponent:init()
    self:setState({
        SelectSlotVisible = false;
        SlotInfos = "none";
    })

    DataService:GetSlotsInfo():andThen(function(Info)
        LogService:Log("Updating slot info")
        self:setState({
            SlotInfos = Info;
        })
    end)
end

function MainMenuComponent:render()
    LogService:Log("Rendering main menu")
    local SlotFrames = {}

    if self.state.SlotInfos == "none" then
        SlotFrames = {Text = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Text = "Loading";
            TextScaled = true;
            FontFace = Core.UI.Theme.TextFont;
            TextColor3 = Core.UI.Theme.TextColorDisabled;
        }, {})}
    else
        SlotFrames = self:CreateSlotFrames()
    end

    local SlotCreationNameInputRef = Roact.createRef()

    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
        IgnoreGuiInset = true;
    }, {
        LeftSide = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.7, 1);
            BackgroundColor3 = Core.UI.Color.White;
            BorderSizePixel = 0;
        }, {
            Gradient = Roact.createElement("UIGradient", {
                Color = ColorSequence.new(Core.UI.Theme.BackgroundColorDark);
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0, 0);
                    NumberSequenceKeypoint.new(1, 1, 0);
                })
            }, {});

            TextArea = Roact.createElement("Frame", {
                Size = UDim2.fromScale(0.5, 0.2);
                Position = UDim2.fromScale(0.05, 0.1);
                AnchorPoint = Core.UI.AnchorPoint.TopLeft;

                BackgroundTransparency = 1;
                BorderSizePixel = 0;
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder;
                }, {});

                GameName = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(1, 0.8);
                    LayoutOrder = 1;
                    BackgroundTransparency = 1;

                    Text = "Manic Mines";
                    TextScaled = true;
                    TextColor3 = Core.UI.Theme.TextColor3;
                    FontFace = Core.UI.Theme.TextFont;
                    TextYAlignment = Enum.TextYAlignment.Bottom;
                    TextXAlignment = Enum.TextXAlignment.Left;
                }, {});

                UpdateName = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(1, 0.2);
                    LayoutOrder = 1;
                    BackgroundTransparency = 1;

                    Text = "The recode update";
                    TextScaled = true;
                    TextColor3 = Core.UI.Theme.TextColorDisabled;
                    FontFace = Core.UI.Theme.TextFont;
                    TextYAlignment = Enum.TextYAlignment.Top;
                    TextXAlignment = Enum.TextXAlignment.Left;
                }, {});
            });

            Buttons = Roact.createElement("Frame", {
                Size = UDim2.fromScale(0.15, 0.4);
                Position = UDim2.fromScale(0.05, 0.5);
                AnchorPoint = Core.UI.AnchorPoint.TopLeft;

                BackgroundTransparency = 1;
                BorderSizePixel = 0;
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder;
                }, {});

                PlayButton = Roact.createElement("TextButton", {
                    Size = UDim2.fromScale(1, 0.1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 1;

                    Text = self:Text(self.state.PlayHovered, "<b><u>> Play</u></b>", "> Play");
                    TextScaled = true;
                    RichText = true;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Color.White;
                    TextXAlignment = Enum.TextXAlignment.Left;

                    [Roact.Event.MouseEnter] = function()
                        self:setState({
                            PlayHovered = true;
                        })
                    end;

                    [Roact.Event.MouseLeave] = function()
                        self:setState({
                            PlayHovered = false;
                        })
                    end;

                    [Roact.Event.MouseButton1Click] = function()
                        self:setState({
                            SelectSlotVisible = not self.state.SelectSlotVisible;
                            CreateSlotVisible = false;
                        })
                    end;
                }, {});

                CreditsButton = Roact.createElement("TextButton", {
                    Size = UDim2.fromScale(1, 0.1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 2;

                    Text = self:Text(self.state.CreditsHovered, "<b><u>> Credits</u></b>", "> Credits");
                    TextScaled = true;
                    RichText = true;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Color.White;
                    TextXAlignment = Enum.TextXAlignment.Left;

                    [Roact.Event.MouseEnter] = function()
                        self:setState({
                            CreditsHovered = true;
                        })
                    end;

                    [Roact.Event.MouseLeave] = function()
                        self:setState({
                            CreditsHovered = false;
                        })
                    end;
                }, {});

                QuitButton = Roact.createElement("TextButton", {
                    Size = UDim2.fromScale(1, 0.1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 3;

                    Text = self:Text(self.state.QuitHovered, "<b><u>> Quit</u></b>", "> Quit");
                    TextScaled = true;
                    RichText = true;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Color.White;
                    TextXAlignment = Enum.TextXAlignment.Left;

                    [Roact.Event.MouseEnter] = function()
                        self:setState({
                            QuitHovered = true;
                        })
                    end;

                    [Roact.Event.MouseLeave] = function()
                        self:setState({
                            QuitHovered = false;
                        })
                    end;

                    [Roact.Event.MouseButton1Click] = function()
                        Knit.Player:Kick("You quit :(")
                    end
                }, {});
            })
        });

        SelectSlot = self.state.SelectSlotVisible and Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.3, 0.5);
            Position = Core.UI.Position.Center;
            AnchorPoint = Core.UI.AnchorPoint.Center;

            BackgroundTransparency = 0.5;
            BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary;
        }, {
            Title = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Text = "Save slots";
                TextColor3 = Core.UI.Theme.TextColor3;
                TextScaled = true;
                FontFace = Core.UI.Theme.TextFont;
            }, {});

            Slots = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.9);
                Position = Core.UI.Position.BottomCenter;
                AnchorPoint = Core.UI.AnchorPoint.BottomCenter;
                BackgroundTransparency = 1;
            }, SlotFrames);
        });

        CreateSlot = self.state.CreateSlotVisible and Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.3, 0.5);
            Position = Core.UI.Position.Center;
            AnchorPoint = Core.UI.AnchorPoint.Center;

            BackgroundTransparency = 0.5;
            BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary;
        }, {
            Layout = Roact.createElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder;
                VerticalFlex = Enum.UIFlexAlignment.Fill;
            }, {});

            Title = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                LayoutOrder = 1;

                Text = "Create slot";
                TextColor3 = Core.UI.Theme.TextColor3;
                TextScaled = true;
                FontFace = Core.UI.Theme.TextFont;
            }, {});

            NameInput = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.3);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                LayoutOrder = 2;
            }, {
                Title = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(1, 0.25);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;

                    Text = "Tycoon name";
                    TextScaled = true;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Theme.TextColor3;
                    TextXAlignment = Enum.TextXAlignment.Left;
                }, {});

                InputContainer = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(0.9, 0.2);
                    Position = Core.UI.Position.Center;
                    AnchorPoint = Core.UI.AnchorPoint.Center;
                    BackgroundTransparency = 0.75;
                    BackgroundColor3 = Core.UI.Theme.BackgroundColorLight;
                    BorderSizePixel = 0;
                }, {
                    Input = Roact.createElement("TextBox", {
                        Size = UDim2.fromScale(0.9, 1);
                        Position = Core.UI.Position.LeftCenter;
                        AnchorPoint = Core.UI.AnchorPoint.LeftCenter;
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;

                        Text = MainMenuController:PickRandomName();
                        PlaceholderText = "Tycoon name";
                        TextScaled = true;
                        FontFace = Core.UI.Theme.TextFont;
                        TextColor3 = Core.UI.Theme.TextColor3;

                        [Roact.Ref] = SlotCreationNameInputRef;

                        [Roact.Event.FocusLost] = function(Object :TextBox)
                            local Text = Object.Text
                            TextFilteringService:FilterTextFromUserToEveryone(Text):andThen(function(FilteredText)
                                Object.Text = FilteredText
                            end)
                        end;
                    }, {});

                    RandomizeButton = Roact.createElement("ImageButton", {
                        Size = UDim2.fromScale(1, 1);
                        Position = Core.UI.Position.TopRight;
                        AnchorPoint = Core.UI.AnchorPoint.TopRight;
                        SizeConstraint = Enum.SizeConstraint.RelativeYY;
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;

                        Image = Core.UI.Images.RandomizeButton;
                        ScaleType = Enum.ScaleType.Fit;

                        [Roact.Event.MouseButton1Click] = function()
                            local RandomName = MainMenuController:PickRandomName()
                            local Input = SlotCreationNameInputRef:getValue() :: TextBox
                            if not Input then return end

                            Input.Text = RandomName
                        end;
                    }, {});
                });
            });

            Settings = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.3);
                BackgroundTransparency = 0.5;
                BackgroundColor3 = Core.UI.Color.Black;
                BorderSizePixel = 0;
                LayoutOrder = 3;
            }, {
                Blocked = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1, 1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                }, {
                    Label = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(1, 1);
                        Position = Core.UI.Position.Center;
                        AnchorPoint = Core.UI.AnchorPoint.Center;
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;

                        Rotation = 10;
                        Text = "Coming Soon!";
                        TextScaled = true;
                        FontFace = Core.UI.Theme.TextFont;
                        TextColor3 = Core.UI.Color.White;
                    }, {})
                });

                Title = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(1, 0.25);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;

                    Text = "Settings";
                    TextScaled = true;
                    TextTransparency = 0.5;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Theme.TextColor3;
                    TextXAlignment = Enum.TextXAlignment.Left;
                }, {});
            });

            Buttons = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                LayoutOrder = 4;
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    Padding = UDim.new(0.1, 0);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalAlignment = Enum.HorizontalAlignment.Center;
                    VerticalAlignment = Enum.VerticalAlignment.Center;
                }, {});

                CreateButton = Roact.createElement("TextButton", {
                    Size = UDim2.fromScale(0.4, 0.35);
                    BackgroundColor3 = Core.UI.Theme.OpenButtonColor;
                    LayoutOrder = 2;

                    Text = "Create";
                    TextScaled = true;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Color.White;

                    [Roact.Event.MouseButton1Click] = function()
                        local SlotInfo = {
                            Name = SlotCreationNameInputRef:getValue().Text;
                            Tutorial = false; -- For later when slot settings are made
                        }
                        DataService:NewSlot(self.state.CurrentSlot, SlotInfo)
                        task.wait(1)
                        HideMenu:Fire()
                    end;
                }, {
                    Corners = Roact.createElement("UICorner", {
                        CornerRadius = UDim.new(0.3, 0)
                    }, {});
                });

                CancelButton = Roact.createElement("TextButton", {
                    Size = UDim2.fromScale(0.4, 0.35);
                    BackgroundColor3 = Core.UI.Theme.CloseButtonColor;
                    LayoutOrder = 1;

                    Text = "Cancel";
                    TextScaled = true;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Color.White;

                    [Roact.Event.MouseButton1Click] = function()
                        self:setState({
                            SelectSlotVisible = true;
                            CreateSlotVisible = false;
                        })
                    end;
                }, {
                    Corners = Roact.createElement("UICorner", {
                        CornerRadius = UDim.new(0.3, 0)
                    }, {});
                });
            });
        })
    })
end



-- [[ KNIT ]] --

function MainMenuController:KnitStart()
    DataService = Knit.GetService("DataService")
    TextFilteringService = Knit.GetService("TextFilteringService")
    LogService = Knit.GetService("LogService")

    local LightingController = Knit.GetController("LightingController")

    local App = Roact.createElement(MainMenuComponent)
    local MainMenuTree = Roact.mount(App, Knit.Player.PlayerGui, "MainMenu")
    LogService:Log("Mounted main menu")

    local Blur = Instance.new("BlurEffect")
    Blur.Name = "MainMenuBlur"
    Blur.Size = 15
    Blur.Enabled = true

    Blur = LightingController:AddPersistentObject(Blur)

    HideMenu.Event:Connect(function()
        Roact.unmount(MainMenuTree)
        Blur:Destroy()
        LogService:Log("unmounted main menu")
    end)
end

return MainMenuController