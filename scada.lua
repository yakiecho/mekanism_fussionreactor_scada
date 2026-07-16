local ReactorClass = require("FissionReactor")

local reactor = ReactorClass:new(
    "fissionReactorLogicAdapter_0"
)


reactor:setLimits({

    maxTemperature = 950,

    minFuel = 0.10,

    minCoolant = 0.20,

    maxWaste = 0.90

})


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
    print(string.format("Heating     : %7.1f", data.heatingRate))
    print(string.format("Heat Loss   : %7.1f", data.environmentalLoss))

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

    print(string.format("Fuel Assemblies : %d",data.fuelAssemblies))
    print(string.format("Boil Efficiency : %.2f%%",data.boilEfficiency*100))
    print(string.format("Size            : %dx%dx%d",
        data.length,
        data.width,
        data.height))

    if reactor.emergency then

        print()

        term.setTextColor(colors.red)

        print("EMERGENCY")
        print(reactor.alarm)

        term.setTextColor(colors.white)

    end

end