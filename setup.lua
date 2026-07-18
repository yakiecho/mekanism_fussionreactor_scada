local ui = require("ui")
local config = require("config")

local monitor

if config.monitor then
    monitor = peripheral.wrap(config.monitor)
end

if not monitor then
    monitor = peripheral.find("monitor")
end

if monitor then
    monitor.setTextScale(1)
    ui.init(monitor)
else
    ui.init()
end

local menu = {
    "Reactor",
    "Monitor",
    "Security",
    "Limits",
    "Save",
    "Exit"
}

local selected = 1

local function status(name)

    return peripheral.wrap(name) ~= nil

end

local function draw()

    ui.clear()
    ui.title("REACTOR SERVICE TERMINAL")

    ui.label(2,3,
        "Reactor      : "..(status(config.reactor) and "ONLINE" or "OFFLINE"),
        status(config.reactor) and colors.lime or colors.red
    )

    ui.label(2,4,
        "Monitor      : "..(status(config.monitor) and "ONLINE" or "OFFLINE"),
        status(config.monitor) and colors.lime or colors.red
    )

    ui.label(2,5,
        "Card Reader  : "..(peripheral.find("magnetic_card_manipulator") and "ONLINE" or "OFFLINE"),
        peripheral.find("magnetic_card_manipulator") and colors.lime or colors.red
    )

    ui.label(2,7,"Select menu:")

    local y = 9

    for i,name in ipairs(menu) do

        local color = colors.gray

        if i == selected then
            color = colors.orange
        end

        ui.button(
            4,
            y,
            18,
            name,
            color,
            true
        )

        y = y + 2

    end

end

local function reactorMenu()

    ui.clear()
    ui.title("REACTOR")

    ui.label(2,3,"Current peripheral:")

    ui.label(
        2,
        5,
        config.reactor,
        colors.yellow
    )

    ui.label(
        2,
        8,
        "Type new peripheral name:"
    )

    term.setCursorPos(2,10)

    local value = read()

    if value ~= "" then
        config.reactor = value
    end

end

local function monitorMenu()

    ui.clear()
    ui.title("MONITOR")

    ui.label(2,3,"Current monitor:")

    ui.label(
        2,
        5,
        config.monitor,
        colors.yellow
    )

    ui.label(
        2,
        8,
        "Type monitor peripheral:"
    )

    term.setCursorPos(2,10)

    local value = read()

    if value ~= "" then
        config.monitor = value
    end

end

local function securityMenu()

    ui.clear()

    ui.title("SECURITY")

    ui.label(2,3,"PIN")

    term.setCursorPos(2,5)
    config.pin = read("*")

    ui.label(2,7,"Card key")

    term.setCursorPos(2,9)
    config.cardKey = read()

end

local function limitsMenu()

    ui.clear()

    ui.title("LIMITS")

    local function ask(name,value)

        ui.label(2,term.getCursorPos(),name)

        local _,y = term.getCursorPos()

        term.setCursorPos(22,y)

        local txt = read(nil,nil,tostring(value))

        return tonumber(txt) or value

    end

    term.setCursorPos(2,3)
    config.maxTemperature = ask("Max Temperature",config.maxTemperature)

    term.setCursorPos(2,5)
    config.maxDamage = ask("Max Damage",config.maxDamage)

    term.setCursorPos(2,7)
    config.minFuel = ask("Min Fuel",config.minFuel)

    term.setCursorPos(2,9)
    config.minCoolant = ask("Min Coolant",config.minCoolant)

    term.setCursorPos(2,11)
    config.maxWaste = ask("Max Waste",config.maxWaste)

end

local function save()

    local file = fs.open("config.lua","w")

    file.write("return "..textutils.serialize(config))

    file.close()

    ui.dialog(
        "CONFIG",
        "Configuration saved."
    )

    repeat

        local _,_,x,y = os.pullEvent("monitor_touch")

    until ui.getButton(x,y) == "OK"

end

while true do

    draw()

    local _,_,x,y = os.pullEvent("monitor_touch")

    local button = ui.getButton(x,y)

    if button == "Reactor" then

        reactorMenu()

    elseif button == "Monitor" then

        monitorMenu()

    elseif button == "Security" then

        securityMenu()

    elseif button == "Limits" then

        limitsMenu()

    elseif button == "Save" then

        save()

    elseif button == "Exit" then

        break

    end

end