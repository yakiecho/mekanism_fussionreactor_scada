FissionReactor = {}

FissionReactor.__index = FissionReactor


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

    self.alarm = reason or "Unknown"

end



function FissionReactor:resetAlarm()

    self.emergency = false

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

        status = self.device.getStatus(),

        temperature = self.device.getTemperature(),

        damage = self.device.getDamagePercent(),

        burnRate = self.device.getBurnRate(),

        actualBurnRate = self.device.getActualBurnRate(),


        fuel = self.device.getFuelFilledPercentage(),

        coolant = self.device.getCoolantFilledPercentage(),

        waste = self.device.getWasteFilledPercentage()

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



    if data.fuel <= self.config.minFuel then

        self:scram(
            "LOW FUEL"
        )

        return false

    end



    if data.coolant <= self.config.minCoolant then

        self:scram(
            "LOW COOLANT"
        )

        return false

    end



    if data.waste >= self.config.maxWaste then

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