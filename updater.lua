local config = require("config")  

local USER = "yakiecho"
local REPO = "mekanism_fussionreactor_scada"

local CONFIG_FILE = "SCADA/config.lua"
local CONFIG_BACKUP = "config_backup.lua"

local VERSION_FILE = "SCADA/version.json"
local REMOTE_VERSION = 
    "https://raw.githubusercontent.com/yakiecho/mekanism_fussionreactor_scada/main/version.json"

local INSTALL_DIR = "SCADA"

local API = ("https://api.github.com/repos/%s/%s/contents")
    :format(USER, REPO)

local CACHE_FILE = "SCADA/.update"

local ignore = {
    ["install.lua"] = true,
    [".update"] = true
}

local function loadCache()

    if not fs.exists(CACHE_FILE) then
        return {}
    end


    local file = fs.open(CACHE_FILE,"r")

    local data = textutils.unserializeJSON(
        file.readAll()
    )

    file.close()

    return data or {}

end

local function backupConfig()

    if fs.exists(CONFIG_FILE) then

        print("Backup config...")
        fs.copy(
            CONFIG_FILE,
            CONFIG_BACKUP
        )

    end
end

local function migrateConfig()

    if not fs.exists(CONFIG_BACKUP) then
        return
    end

    print("Migrating config...")

    local oldConfig =
        dofile(CONFIG_BACKUP)
    local newConfig =
        dofile(CONFIG_FILE)


    for key,value in pairs(oldConfig) do
        if newConfig[key] ~= nil then
            newConfig[key] = value

        end
    end

    local file = fs.open(
        CONFIG_FILE,
        "w"
    )

    file.write(
        "return " ..
        textutils.serialize(newConfig)
    )

    file.close()
    fs.delete(CONFIG_BACKUP)
end

local function saveCache(data)

    local file = fs.open(
        CACHE_FILE,
        "w"
    )


    file.write(
        textutils.serializeJSON(data)
    )


    file.close()

end

local function getFiles(apiUrl, result)

    result = result or {}


    local response = http.get(apiUrl)

    if not response then
        error("GitHub unavailable")
    end


    local data = textutils.unserializeJSON(
        response.readAll()
    )


    response.close()



    for _,item in ipairs(data) do


        if item.type == "dir" then

            getFiles(
                item.url,
                result
            )


        elseif item.type == "file" then


            if not ignore[item.path] then

                result[item.path] = item

            end

        end


    end


    return result

end

local function download(item)


    local path = fs.combine(
        INSTALL_DIR,
        item.path
    )


    local dir = fs.getDir(path)


    if not fs.exists(dir) then
        fs.makeDir(dir)
    end



    print("Update: "..item.path)


    local request = http.get(
        item.download_url ..
        "?v=" ..
        item.sha
    )


    if request then


        local file = fs.open(
            path,
            "w"
        )


        file.write(
            request.readAll()
        )


        file.close()


        request.close()


    end

end

local function getRemoteVersionNeed()

    if not fs.exists(VERSION_FILE) then
        return true
    end


    local file = fs.open(
        VERSION_FILE,
        "r"
    )

    local data = textutils.unserializeJSON(
        file.readAll()
    )

    file.close()

    local request = http.get(
        REMOTE_VERSION
    )

    if not request then
        error("Cannot check version")
    end

    local data = textutils.unserializeJSON(
        request.readAll()
    )

    request.close()

    if remoteVersion.build > localVersion.build then
        return true
    end


    if remoteVersion.version ~= localVersion.version then
        return true
    end


    return false

end

local function needUpdate()

    if getRemoteVersionNeed() then
        return true
    end

    for path,item in pairs(remote) do
        newCache[path] = item.sha
        if old[path] ~= item.sha then
            return true
        end
    end
end

local function update()

    print("Checking updates...")

    local updateNeeded, version =
        needUpdate()


    if not updateNeeded then

        print(
            "SCADA is up to date"
        )

        return false
    end

    backupConfig()

    local old = loadCache()
    local remote = getFiles(API)
    local newCache = {}

    for path,item in pairs(remote) do
        newCache[path] = item.sha
        if old[path] ~= item.sha then
            download(item)
        end
    end

    saveCache(newCache)
    migrateConfig()
    print("Update complete!")

end

if config.update then 
    update()
end