FissionReactor = {}

FissionReactor.__index = FissionReactor

local speaker = peripheral.find("speaker")
local alarmPlayed = false

function FissionReactor:new(name)

    local obj = {}

    setmetatable(obj, FissionReactor)


    obj.name = name or "fissionReactorLogicAdapter_0"

    obj.device = peripheral.wrap(obj.name)


    if not obj.device then
        error("Reactor not found: "..obj.name)
    end


    obj.config = {

        maxTemperature = 1000,

        maxDamage = 0,

        minFuel = 0.05,

        minCoolant = 0.10,

        maxWaste = 0.95

    }


    obj.emergency = false

    obj.alarm = nil


    return obj

end


local function alarm()

    if not speaker then
        return
    end

    for i = 1, 4 do

        speaker.playNote("saw", 3, 24)
        sleep(0.15)

        speaker.playNote("saw", 3, 12)
        sleep(0.15)

    end

end


-------------------------------------------------
-- Управление
-------------------------------------------------


function FissionReactor:start()

    if self.emergency then
        return false, "Emergency lock"
    end

    self.device.activate()

    return true

end



function FissionReactor:scram(reason)

    self.device.scram()

    self.emergency = true

    if not alarmPlayed then
        alarm()
        alarmPlayed = true
    end

    self.alarm = reason or "Unknown"

end



function FissionReactor:resetAlarm()

    self.emergency = false

    alarmPlayed = false

    self.alarm = nil

end



function FissionReactor:setBurnRate(rate)

    if self.emergency then
        return false
    end

    self.device.setBurnRate(rate)

    return true

end



-------------------------------------------------
-- Получение данных
-------------------------------------------------


function FissionReactor:getData()

    return {

        -------------------------------------------------
        -- Status
        -------------------------------------------------

        status = self.device.getStatus(),
        formed = self.device.isFormed(),
        forceDisabled = self.device.isForceDisabled(),

        -------------------------------------------------
        -- Reactor
        -------------------------------------------------

        temperature = self.device.getTemperature() - 273.15,
        damage = self.device.getDamagePercent(),
        heatCapacity = self.device.getHeatCapacity(),
        heatingRate = self.device.getHeatingRate(),
        environmentalLoss = self.device.getEnvironmentalLoss(),

        -------------------------------------------------
        -- Burn
        -------------------------------------------------

        burnRate = self.device.getBurnRate(),
        actualBurnRate = self.device.getActualBurnRate(),
        maxBurnRate = self.device.getMaxBurnRate(),

        -------------------------------------------------
        -- Fuel
        -------------------------------------------------

        fuel = self.device.getFuel(),
        fuelCapacity = self.device.getFuelCapacity(),
        fuelNeeded = self.device.getFuelNeeded(),
        fuelPercent = self.device.getFuelFilledPercentage(),

        -------------------------------------------------
        -- Waste
        -------------------------------------------------

        waste = self.device.getWaste(),
        wasteCapacity = self.device.getWasteCapacity(),
        wasteNeeded = self.device.getWasteNeeded(),
        wastePercent = self.device.getWasteFilledPercentage(),

        -------------------------------------------------
        -- Coolant
        -------------------------------------------------

        coolant = self.device.getCoolant(),
        coolantCapacity = self.device.getCoolantCapacity(),
        coolantNeeded = self.device.getCoolantNeeded(),
        coolantPercent = self.device.getCoolantFilledPercentage(),

        -------------------------------------------------
        -- Steam
        -------------------------------------------------

        heatedCoolant = self.device.getHeatedCoolant(),
        heatedCoolantCapacity = self.device.getHeatedCoolantCapacity(),
        heatedCoolantNeeded = self.device.getHeatedCoolantNeeded(),
        heatedCoolantPercent = self.device.getHeatedCoolantFilledPercentage(),

        -------------------------------------------------
        -- Other
        -------------------------------------------------

        boilEfficiency = self.device.getBoilEfficiency(),
        fuelAssemblies = self.device.getFuelAssemblies(),

        width = self.device.getWidth(),
        length = self.device.getLength(),
        height = self.device.getHeight(),

        logicMode = self.device.getLogicMode(),
        redstoneMode = self.device.getRedstoneMode()

    }

end



-------------------------------------------------
-- Безопасность
-------------------------------------------------


function FissionReactor:safetyCheck()


    local data = self:getData()



    if data.temperature >= self.config.maxTemperature then

        self:scram(
            "HIGH TEMPERATURE"
        )

        return false

    end



    if data.damage > self.config.maxDamage then

        self:scram(
            "REACTOR DAMAGE"
        )

        return false

    end



    if data.fuelPercent  <= self.config.minFuel then

        self:scram(
            "LOW FUEL"
        )

        return false

    end



    if data.coolantPercent  <= self.config.minCoolant then

        self:scram(
            "LOW COOLANT"
        )

        return false

    end



    if data.wastePercent  >= self.config.maxWaste then

        self:scram(
            "WASTE FULL"
        )

        return false

    end



    return true

end



-------------------------------------------------
-- Настройка лимитов
-------------------------------------------------


function FissionReactor:setLimits(data)


    for key,value in pairs(data) do

        if self.config[key] then

            self.config[key] = value

        end

    end


end



return FissionReactor