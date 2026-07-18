local USER = "yakiecho"
local REPO = "mekanism_fussionreactor_scada"

local INSTALL_DIR = "SCADA"

local API = ("https://api.github.com/repos/%s/%s/contents"):format(USER, REPO)

local ignore = {
    ["install.lua"] = true,
    [".update"] = true
}

local function removeOld()

    if fs.exists(INSTALL_DIR) then

        print("Removing old SCADA...")

        fs.delete(INSTALL_DIR)

    end

end

local function downloadDirectory(apiUrl, currentPath)

    local response = http.get(apiUrl)

    if not response then
        error("Cannot connect to GitHub")
    end


    local data = textutils.unserializeJSON(
        response.readAll()
    )

    response.close()


    for _, item in ipairs(data) do


        local path = fs.combine(
            currentPath,
            item.path
        )


        if item.type == "dir" then


            if not fs.exists(path) then
                fs.makeDir(path)
            end


            downloadDirectory(
                item.url,
                path
            )


        elseif item.type == "file" then


            if not ignore[item.path] then


                print("Downloading "..path)


                local fileRequest = http.get(
                    item.download_url ..
                    "?v=" ..
                    item.sha
                )


                if fileRequest then


                    local dir = fs.getDir(path)


                    if dir ~= "" and not fs.exists(dir) then
                        fs.makeDir(dir)
                    end


                    if fs.exists(path) then
                        fs.delete(path)
                    end


                    local file = fs.open(
                        path,
                        "w"
                    )


                    file.write(
                        fileRequest.readAll()
                    )


                    file.close()


                    fileRequest.close()


                else

                    print(
                        "Failed "..path
                    )

                end

            end

        end

    end

end

local function installStartup()

    local startupCode = [[
print("Starting SCADA...")

shell.run("SCADA/updater.lua")

shell.run("SCADA/scada.lua")
]]


    local file = fs.open(
        "startup.lua",
        "w"
    )


    file.write(
        startupCode
    )


    file.close()

end

print("Starting installation...")

removeOld()

fs.makeDir(INSTALL_DIR)

downloadDirectory(
    API,
    INSTALL_DIR
)

installStartup()

print("")
print("Installation complete!")
print("Installed into: "..INSTALL_DIR)