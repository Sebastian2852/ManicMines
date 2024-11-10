local Test = {}

Test.HasPrompt = true
Test.ParentToHitbox = true

function Test.CreatePrompt(TycoonName :string, Level :number, MaxLevel :number)
    print("Data recieved: \nName: "..TycoonName.."\nLevel: "..Level.."\nMaxLevel: "..MaxLevel)
    return "Action", "Object"
end

function Test.Triggered(Player :Player, IsOwner :boolean)
    print("Data recieved: \nPlayer: "..tostring(Player.Name).."\nIsOwner: "..tostring(IsOwner))
end

return Test