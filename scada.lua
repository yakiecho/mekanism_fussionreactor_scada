local ReactorClass = require("FissionReactor") 
local config = require("config")
local reactor = ReactorClass:new(config)
local infoData = reactor:getInfoData()
local burnStep = 0.1

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


local function touchHandler()

    while true do

        local event, side, x, y =
            os.pullEvent("monitor_touch")

        for _,button in ipairs(buttons) do

            if button.enabled
                and x >= button.x
                and x <= button.x + button.w
                and y == button.y then

                if button.action == "START" then

                    reactor:start()

                elseif button.action == "UNLOCK" then

                    reactor:resetAlarm()

                elseif button.action == "-" then

                    reactor:changeBurnRate(-burnStep)

                elseif button.action == "STOP" then

                    reactor:stop()

                elseif button.action == "+" then

                    reactor:changeBurnRate(burnStep)
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



local function scadaLoop()
    while true do

        buttons = {}
        local data = reactor:getData()
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

    end
end

parallel.waitForAny(

    scadaLoop,

    touchHandler

)