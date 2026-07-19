local config = require("config")  

local USER = "yakiecho"
local REPO = "mekanism_fussionreactor_scada"

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

local function update()

    print("Checking updates...")

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

    print("Update complete!")

end

if config.update then 
    update()
end