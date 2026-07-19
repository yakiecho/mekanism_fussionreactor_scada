local ReactorClass = require("FissionReactor") 
local config = require("config")
local reactor = ReactorClass:new(config)
local infoData = reactor:getInfoData()
local reader = peripheral.find("magnetic_card_manipulator")
dofile("/SCADA/sha256.lua")


local burnStep = 0.1
local panelLocked = true
local pinBuffer = ""


local monitor = peripheral.wrap(
    config.monitor
)

if config.monitor then
    monitor = peripheral.wrap(
        config.monitor
    )
end

if not monitor then
    monitor = peripheral.find(
        "monitor"
    )
end

term.redirect(monitor)
monitor.setTextScale(1)
local mw, mh = monitor.getSize()

local function progress(value, width)

    local filled = math.floor(value * width)

    for i = 1, width do

        if i <= filled then
            term.setBackgroundColor(colors.green)
        else
            term.setBackgroundColor(colors.gray)
        end

        write(" ")

    end

    term.setBackgroundColor(colors.black)

end


local buttons = {}

local function drawButton(x, y, w, text, color, enabled)

    term.setCursorPos(x,y)

    term.setBackgroundColor(color)

    write(
        string.rep(" ", w)
    )


    term.setCursorPos(
        x + 1,
        y
    )


    if enabled then
        term.setTextColor(colors.white)
    else
        term.setTextColor(colors.lightGray)
    end


    write(text)


    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)



    buttons[#buttons+1] = {

        x = x,
        y = y,
        w = w,
        h = 1,

        action = text,

        enabled = enabled

    }

end

local function unlockPanel()
    panelLocked = false
    pinBuffer = ""
end

local function lockPanel()
    panelLocked = true
    pinBuffer = ""
end

local function cardHandler()
    while true do
        if reader.hasCard() then

            local key = reader.readCard()

            if sha256(key) == config.cardKey then 
                unlockPanel()
            end

            -- reader.ejectCard()

            while reader.hasCard() do
                sleep(0.1)
            end
        end

        sleep(0.1)
    end
end

local function touchHandler()

    while true do

        local event, side, x, y =
            os.pullEvent("monitor_touch")

        for _,button in ipairs(buttons) do

            if button.enabled
                and x >= button.x
                and x <= button.x + button.w
                and y == button.y then

                if not panelLocked then
                    if button.action == "START" then

                        reactor:start()

                    elseif button.action == "UNLOCK" then

                        reactor:resetAlarm()

                    elseif button.action == "-" then

                        reactor:changeBurnRate(-burnStep)

                    elseif button.action == "STOP" then

                        reactor:stop()

                    elseif button.action == "PIN LOCK" then

                        lockPanel()

                    elseif button.action == "+" then

                        reactor:changeBurnRate(burnStep)
                    end

                elseif panelLocked then

                    if button.action == "CLR" then

                        pinBuffer = ""

                    elseif button.action == "OK" then
                        if sha256(pinBuffer) == config.pin then
                            unlockPanel()

                        else
                            pinBuffer = ""
                        end

                    elseif tonumber(button.action) then
                        if #pinBuffer < 8 then
                            pinBuffer = pinBuffer .. button.action
                        end

                    end

                    break

                end

            end

        end

    end

end


local function drawStatus(data)

    if reactor.emergency then

        term.setTextColor(colors.red)
        print("STATUS : SCRAM")

    elseif tostring(data.status) == "true" then

        term.setTextColor(colors.lime)
        print("STATUS : ONLINE")

    else

        term.setTextColor(colors.orange)
        print("STATUS : OFFLINE")

    end

    term.setTextColor(colors.white)

end

local function drawOverlayLockpanel()

    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.gray)

    for y = 1, mh do
        term.setCursorPos(1, y)
        write(string.rep(" ", mw))
    end

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

end


local function scadaLoop()
    while true do

        local data = reactor:getData()
        
        reactor:safetyCheck(data)

        term.clear()
        term.setCursorPos(1,1)

        print("========== FISSION SCADA ==========")

        drawStatus(data)

        print()

        print(string.format("Temperature : %7.1f C", data.temperature))
        print(string.format("Damage      : %7.2f %%", data.damage))
        print(string.format("Burn Rate   : %7.1f / %.1f", data.actualBurnRate, data.maxBurnRate))

        print()

        print("Fuel")
        progress(data.fuelPercent, 30)
        print((" %5.1f%%"):format(data.fuelPercent * 100))

        print("Waste")
        progress(data.wastePercent, 30)
        print((" %5.1f%%"):format(data.wastePercent * 100))

        print("Coolant")
        progress(data.coolantPercent, 30)
        print((" %5.1f%%"):format(data.coolantPercent * 100))

        print("Steam")
        progress(data.heatedCoolantPercent, 30)
        print((" %5.1f%%"):format(data.heatedCoolantPercent * 100))

        print()

        print(string.format("Fuel Assemblies : %d",infoData.fuelAssemblies))
        print(string.format("Boil Efficiency : %.2f%%",infoData.boilEfficiency*100))
        print(string.format("Size            : %dx%dx%d",
            infoData.length,
            infoData.width,
            infoData.height))

        if reactor.emergency then

            print()

            term.setTextColor(colors.red)

            print("EMERGENCY")
            print(reactor.alarm)

            term.setTextColor(colors.white)

        end

        buttons = {}

        if panelLocked then

            drawOverlayLockpanel()

            print(pinBuffer)

            local startX = math.floor((mw - 17) / 2) + 1
            local startY = math.floor((mh - 7) / 2) + 1

            drawButton(startX + 0,  startY + 0, 5, "1",   colors.gray, true)
            drawButton(startX + 6,  startY + 0, 5, "2",   colors.gray, true)
            drawButton(startX + 12, startY + 0, 5, "3",   colors.gray, true)

            drawButton(startX + 0,  startY + 2, 5, "4",   colors.gray, true)
            drawButton(startX + 6,  startY + 2, 5, "5",   colors.gray, true)
            drawButton(startX + 12, startY + 2, 5, "6",   colors.gray, true)

            drawButton(startX + 0,  startY + 4, 5, "7",   colors.gray, true)
            drawButton(startX + 6,  startY + 4, 5, "8",   colors.gray, true)
            drawButton(startX + 12, startY + 4, 5, "9",   colors.gray, true)

            drawButton(startX + 0,  startY + 6, 5, "CLR", colors.red,   true)
            drawButton(startX + 6,  startY + 6, 5, "0",   colors.gray,  true)
            drawButton(startX + 12, startY + 6, 5, "OK",  colors.green, true)

        else

            drawButton(
                30,
                mh - 2,
                10,
                "PIN LOCK",
                colors.orange,
                true
            )
            if reactor.emergency then

                drawButton(
                    30,
                    6,
                    5,
                    "-",
                    colors.gray,
                    false
                )

                drawButton(
                    36,
                    6,
                    5,
                    "+",
                    colors.gray,
                    false
                )

                drawButton(
                    2,
                    mh - 2,
                    10,
                    "START",
                    colors.gray,
                    false
                )

                drawButton(
                    15,
                    mh - 2,
                    10,
                    "UNLOCK",
                    colors.red,
                    true
                )


            else
                drawButton(
                    30,
                    6,
                    5,
                    "-",
                    colors.red,
                    true
                )

                drawButton(
                    36,
                    6,
                    5,
                    "+",
                    colors.green,
                    true
                )

                if data.status == "true" then
                    drawButton(
                        2,
                        mh - 2,
                        10,
                        "STOP",
                        colors.red,
                        true
                    )
                else
                    drawButton(
                        2,
                        mh - 2,
                        10,
                        "START",
                        colors.green,
                        true
                    )
                end

                drawButton(
                    15,
                    mh - 2,
                    10,
                    "UNLOCK",
                    colors.gray,
                    false
                )
            end
        end

        sleep(config.refreshRate)

    end
end

parallel.waitForAny(

    scadaLoop,

    touchHandler,

    cardHandler

)