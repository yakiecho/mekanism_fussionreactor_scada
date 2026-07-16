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

    return string.rep("=", filled) ..
           string.rep("-", width - filled)

end


local function drawStatus(data)

    if reactor.emergency then

        term.setTextColor(colors.red)
        print("STATUS : SCRAM")

    elseif data.status == "active" then

        term.setTextColor(colors.lime)
        print("STATUS : ONLINE")

    else

        term.setTextColor(colors.orange)
        print("STATUS : OFFLINE")

    end

    term.setTextColor(colors.white)

end

while true do

    reactor:safetyCheck()

    local data = reactor:getData()

    term.clear()
    term.setCursorPos(1,1)

    print("========== FISSION SCADA ==========")

    drawStatus(data)

    print()

    print(string.format("Temperature : %7.1f K", data.temperature))
    print(string.format("Damage      : %7.2f %%", data.damage))
    print(string.format("Burn Rate   : %7.1f / %.1f", data.actualBurnRate, data.maxBurnRate))
    print(string.format("Heating     : %7.1f", data.heatingRate))
    print(string.format("Heat Loss   : %7.1f", data.environmentalLoss))

    print()

    print("Fuel")
    print(progress(data.fuelPercent,30),
          string.format("%5.1f%%",data.fuelPercent*100))

    print("Waste")
    print(progress(data.wastePercent,30),
          string.format("%5.1f%%",data.wastePercent*100))

    print("Coolant")
    print(progress(data.coolantPercent,30),
          string.format("%5.1f%%",data.coolantPercent*100))

    print("Steam")
    print(progress(data.heatedCoolantPercent,30),
          string.format("%5.1f%%",data.heatedCoolantPercent*100))

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