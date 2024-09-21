local PackagesToFind = {
    ["Knit"] = false;
    ["Iris"] = false;
}

return function ()
    print("!!! Starting package testing... !!!")
    print("-----------------------------------")

    print("Checking for packages folder")

    local PackagesFolder = game.ReplicatedStorage:FindFirstChild("Packages")
    if not PackagesFolder then warn("No packages folder found! run `wally install` to fix") return end
    print("Packages folder valid")

    for _, PackageModule :ModuleScript in pairs(PackagesFolder:GetChildren()) do
        if not PackageModule:IsA("ModuleScript") then continue end
        local Valid = false
        for PackageName, Found in pairs(PackagesToFind) do
            if Found then
                break
            end

            if PackageName == PackageModule.Name then
                PackagesToFind[PackageName] = true
                Valid = true
                break
            end
        end

        if not Valid then
            warn("Unneeded package: "..PackageModule.Name)
        end
    end

    local FoundAllPackages = true
    for PackageName, Found in pairs(PackagesToFind) do
        if not Found then
            warn("Couldnt find package: "..PackageName)
            FoundAllPackages = false
        else
            print("Found package: "..PackageName)
        end
    end

    if not FoundAllPackages then
        warn("Couldn't find all packages!")
        return
    end

    print("Packages valid")
end