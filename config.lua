local config = {

    -- Периферия реактора
    reactor = "fissionReactorLogicAdapter_0",


    -- Монитор
    monitor = "monitor_0",


    -- Автообновление
    update = true,


    -- Интервал обновления данных
    refreshRate = 0,

    pin = "1234",

    -- Лимиты безопасности

    maxTemperature = 950,

    maxDamage = 0,

    minFuel = 0.10,

    minCoolant = 0.20,

    maxWaste = 0.90,


    -- Цветовая тема

    colors = {

        background = colors.black,

        text = colors.white,

        online = colors.lime,

        offline = colors.orange,

        alarm = colors.red

    }

}


return config