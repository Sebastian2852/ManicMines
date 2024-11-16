local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local DialogueController = Knit.CreateController { Name = "DialogueController" }

local DialogueService
local LogService
local CharacterController

local Camera = workspace.CurrentCamera
local OriginalCameraCFrame :CFrame

-- [[ TYPES ]] --

type DialogueChoice = {
    Text :string;
    Index :number;
    CanLeave :boolean;
    LeaveText :string?;
    Choices :{[string] :DialogChoice};
}

type InfoModule = {
    NpcName :string;
    InteractMessage :string;

    Dialogue :DialogueChoice;
}



-- [[ PRIVATE ]] --

local function TogglePrompts(New :boolean, Tag :string)
    for _, Prompt :ProximityPrompt in pairs(CollectionService:GetTagged(Tag)) do
        if not Prompt:IsA("ProximityPrompt") then
            Prompt:RemoveTag(Tag)
            LogService:Warn("Invalid object with prompt tag: "..Prompt:GetFullName())
            continue
        end

        Prompt.Enabled = New
    end
end



-- [[ PUBLIC ]] --

--[=[
Disable all dialogue related prompts
]=]
function DialogueController:DisablePrompts()
    DialogueService:GetTags():andThen(function(PromptTag :string, _)
        TogglePrompts(false, PromptTag)
    end)
end

--[=[
Enable all dialogue related prompts
]=]
function DialogueController:EnablePrompts()
    DialogueService:GetTags():andThen(function(PromptTag :string, _)
        TogglePrompts(true, PromptTag)
    end)
end

--[=[
Tweens the camera to the given part
]=]
function DialogueController:MoveToCameraToPart(Part :BasePart)
    Camera.CameraType = Enum.CameraType.Scriptable
    OriginalCameraCFrame = Camera.CFrame
    local CameraTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)
    local CameraTween = TweenService:Create(Camera, CameraTweenInfo, {CFrame = Part.CFrame})
    CameraTween:Play()
end

--[=[
Resets the camera back to the player
]=]
function DialogueController:ResetCamera()
    local CameraTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)
    local CameraTween = TweenService:Create(Camera, CameraTweenInfo, {CFrame = OriginalCameraCFrame or CFrame.new(0, 0, 0)})
    CameraTween:Play()
    CameraTween.Completed:Wait()
    Camera.CameraType = Enum.CameraType.Custom
end


-- [[ GUI ]] --

local DialogueComponent = Roact.Component:extend("Dialogue")
local EndDialogueEvent = Instance.new("BindableEvent")
local NextDialogueEvent = Instance.new("BindableEvent")

function DialogueComponent:EndDialogue()
    EndDialogueEvent:Fire()
end

function DialogueComponent:CreateResponseButton(Text :string, Order :number) :Roact.Element
    return Roact.createElement("TextButton", {
        Size = UDim2.fromScale(0.5, 0.15);
        BackgroundTransparency = 0.5;
        BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary;
        BorderSizePixel = 0;
        LayoutOrder = Order;

        Text = Text;
        TextScaled = true;
        AutomaticSize = Enum.AutomaticSize.X;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextColor3 = Core.UI.Theme.TextColor3;
        FontFace = Core.UI.Theme.TextFont;

        [Roact.Event.MouseButton1Click] = function()
            NextDialogueEvent:Fire(Text, self.props.Dialogue)
        end
    }, {
        TextSizing = Roact.createElement("UITextSizeConstraint", {
            MaxTextSize = 25;
            MinTextSize = 14;
        }, {})
    })
end

function DialogueComponent:CreateLeaveButton(Text :string, Order :number) :Roact.Element
    return Roact.createElement("TextButton", {
        Size = UDim2.fromScale(0.5, 0.15);
        BackgroundTransparency = 0.5;
        BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary;
        BorderSizePixel = 0;
        LayoutOrder = Order;

        Text = Text;
        TextScaled = true;
        AutomaticSize = Enum.AutomaticSize.X;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextColor3 = Core.UI.Theme.TextColor3;
        FontFace = Core.UI.Theme.TextFont;

        [Roact.Event.MouseButton1Click] = function()
            self:EndDialogue()
        end;
    }, {
        TextSizing = Roact.createElement("UITextSizeConstraint", {
            MaxTextSize = 25;
            MinTextSize = 14;
        }, {})
    })
end

function DialogueComponent:CreateResponses() :{Roact.Element}
    local Choices = {}

    local Info = self.props.Dialogue ::DialogueChoice

    if Info ~= nil then
        if Info.Choices ~= nil then
            for Text, Data in pairs(Info.Choices) do
                local Order = 0

                if Data.Index then
                    Order = Data.Index
                else
                    LogService:Warn("Dialogue missing index!")
                    Order = #Choices
                end
                LogService:Log("Creating choice: "..tostring(Text).."; at index: "..tostring(Order))
                table.insert(Choices, self:CreateResponseButton(Text, Order))
            end
        end
    end
    if self.props.Dialogue.CanLeave then
        table.insert(Choices, self:CreateLeaveButton(Info.LeaveText or "Leave", #Choices + 10))
    end

    return Choices
end

function DialogueComponent:render()
    LogService:Log("Rendering dialogue GUI")
    local NpcName = self.props.NpcName or "ERROR: NPC NAME NOT FOUND !!!"
    local Dialogue = self.props.Dialogue.Text or "ERROR: DIALOGUE NOT FOUND !!!"
    local Responses = self:CreateResponses()

    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        Main = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.5, 0.3);
            Position = UDim2.fromScale(0.5, 0.98);
            AnchorPoint = Core.UI.AnchorPoint.BottomCenter;

            BackgroundTransparency = 0.5;
            BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary;
            BorderSizePixel = 0;
        }, {
            NpcName = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.15);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Text = NpcName;
                RichText = true;
                TextScaled = true;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextColor3 = Core.UI.Theme.TextColor3;
                FontFace = Core.UI.Theme.TextFont;
            }, {});

            Dialogue = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.85);
                Position = UDim2.fromScale(0, 0.15);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Text = Dialogue;
                RichText = true;
                TextScaled = true;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Top;
                TextColor3 = Core.UI.Theme.TextColor3;
                FontFace = Core.UI.Theme.TextFont;
            }, {
                TextSizing = Roact.createElement("UITextSizeConstraint", {
                    MaxTextSize = 35;
                    MinTextSize = 14;
                }, {})
            });
        });

        Options = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.2, 0.3);
            Position = UDim2.fromScale(0.76, 0.98);
            AnchorPoint = Core.UI.AnchorPoint.BottomLeft;

            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.X;
        }, {
            Roact.createElement("UIListLayout", {
                Padding = UDim.new(0.03, 0);
                SortOrder = Enum.SortOrder.LayoutOrder;
                Wraps = true;
            }, {});

            table.unpack(Responses);
        })
    })
end



-- [[ KNIT ]] --

function DialogueController:KnitStart()
    DialogueService = Knit.GetService("DialogueService")
    LogService = Knit.GetService("LogService")
    CharacterController = Knit.GetController("CharacterController")

    DialogueService.StartDialogue:Connect(function(DialogueInfo :InfoModule, CamPart :BasePart)
        if CamPart == nil then
            LogService:Warn("No camera part for NPC")
            return
        end

        if DialogueInfo == nil then
            LogService:Warn("Invalid dialogue module, nil")
            return
        end

        if DialogueInfo.Dialogue == nil then
            LogService:Warn("Invalid dialogue module, no dialogue")
            return
        end

        self:DisablePrompts()
        self:MoveToCameraToPart(CamPart)
        CharacterController:DisableMovement()

        local App = Roact.createElement(DialogueComponent, {
            NpcName = DialogueInfo.NpcName;
            Dialogue = DialogueInfo.Dialogue;
        })

        local GUI = Roact.mount(App, Knit.Player.PlayerGui, "Dialogue")
        LogService:Log("Mounted dialogue GUI")

        local Update = NextDialogueEvent.Event:Connect(function(Choice :string, CurrentData :DialogueChoice)
            App = Roact.createElement(DialogueComponent, {
                NpcName = DialogueInfo.NpcName;
                Dialogue = CurrentData.Choices[Choice];
            })
            Roact.unmount(GUI)
            GUI = Roact.mount(App, Knit.Player.PlayerGui, "Dialogue")
        end)

        EndDialogueEvent.Event:Once(function()
            Roact.unmount(GUI)
            Update:Disconnect()
            LogService:Log("Unmounted dialogue GUI")
            self:ResetCamera()
            CharacterController:EnableMovement()
            self:EnablePrompts()
        end)
    end)

end

return DialogueController