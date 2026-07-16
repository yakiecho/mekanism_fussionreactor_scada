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



reactor:start()



while true do


    reactor:safetyCheck()


    local data = reactor:getData()



    print("----------------")

    print(
        "Status:",
        data.status
    )


    print(
        "Temperature:",
        math.floor(data.temperature)
    )


    print(
        "Burn:",
        data.burnRate
    )


    print(
        "Fuel:",
        math.floor(data.fuel*100).."%"
    )


    print(
        "Coolant:",
        math.floor(data.coolant*100).."%"
    )


    print(
        "Waste:",
        math.floor(data.waste*100).."%"
    )



    if reactor.emergency then

        print(
            "!!! SCRAM !!!"
        )

        print(
            reactor.alarm
        )

    end


    sleep(1)

end