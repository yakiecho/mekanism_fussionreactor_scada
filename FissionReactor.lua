FissionReactor = {}

FissionReactor.__index = FissionReactor
local speaker = peripheral.find("speaker")
local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()
local alarmPlayed = false

function FissionReactor:new(config)

    local obj = {}

    setmetatable(obj, FissionReactor)


    obj.name = config.reactor

    obj.device = peripheral.wrap(obj.name)


    if not obj.device then
        error("Reactor not found: "..obj.name)
    end


    obj.config = {

        maxTemperature = config.maxTemperature,

        minFuel = config.minFuel,

        minCoolant = config.minCoolant,

        maxWaste = config.maxWaste,

        maxDamage = config.maxDamage
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
        for chunk in io.lines("SCADA/alarm2.dfpwm", 16 * 1024) do
           local buffer = decoder(chunk)

           while not speaker.playAudio(buffer) do
               os.pullEvent("speaker_audio_empty")
           end
        end
    end
end


-------------------------------------------------
-- Управление
-------------------------------------------------


function FissionReactor:start()

    if self.emergency then
        return false, "Emergency lock"
    end

    if not tostring(self.device.getStatus()) == "true" then
        self.device.activate()
    end
    
    return true

end

function FissionReactor:stop()

    if tostring(self.device.getStatus()) == "true" then
        self.device.scram()
    end

    return true

end


function FissionReactor:scram(reason)

    if tostring(self.device.getStatus()) == "true" then
        self.device.scram()
    end

    self.emergency = true
    self.alarm = reason or "Unknown"

    if not alarmPlayed then

        alarmPlayed = true

        parallel.waitForAny(
            function()
                alarm()
            end,

            function()
                os.sleep(0)
            end
        )

    end
    
end


function FissionReactor:resetAlarm()

    self.emergency = false

    alarmPlayed = false

    self.alarm = nil

end


function FissionReactor:changeBurnRate(value)

    if self.emergency then
        return false
    end

    local current = self.device.getBurnRate()

    local max = self.device.getMaxBurnRate()

    local newRate = current + value

    if newRate < 0 then
        newRate = 0
    end

    if newRate > max then
        newRate = max
    end

    self.device.setBurnRate(
        newRate
    )

    return true, newRate
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

        temperature =
            self.device.getTemperature() - 273.15,

        damage =
            self.device.getDamagePercent(),

        actualBurnRate =
            self.device.getActualBurnRate(),

        maxBurnRate =
            self.device.getMaxBurnRate(),

        fuelPercent =
            self.device.getFuelFilledPercentage(),

        wastePercent =
            self.device.getWasteFilledPercentage(),

        coolantPercent =
            self.device.getCoolantFilledPercentage(),

        burnRate =
            self.device.getBurnRate(),

        heatedCoolantPercent =
            self.device.getHeatedCoolantFilledPercentage()

    }

end


function FissionReactor:getInfoData()

    return {

        boilEfficiency =
            self.device.getBoilEfficiency(),

        fuelAssemblies =
            self.device.getFuelAssemblies(),

        width =
            self.device.getWidth(),

        length =
            self.device.getLength(),

        height =
            self.device.getHeight(),

    }

end




-- function FissionReactor:getData()

--     return {

--         -------------------------------------------------
--         -- Status
--         -------------------------------------------------

--         status = self.device.getStatus(),
--         formed = self.device.isFormed(),
--         forceDisabled = self.device.isForceDisabled(),

--         -------------------------------------------------
--         -- Reactor
--         -------------------------------------------------

--         temperature = self.device.getTemperature() - 273.15,
--         damage = self.device.getDamagePercent(),
--         heatCapacity = self.device.getHeatCapacity(),
--         heatingRate = self.device.getHeatingRate(),
--         environmentalLoss = self.device.getEnvironmentalLoss(),

--         -------------------------------------------------
--         -- Burn
--         -------------------------------------------------

--         burnRate = self.device.getBurnRate(),
--         actualBurnRate = self.device.getActualBurnRate(),
--         maxBurnRate = self.device.getMaxBurnRate(),

--         -------------------------------------------------
--         -- Fuel
--         -------------------------------------------------

--         fuel = self.device.getFuel(),
--         fuelCapacity = self.device.getFuelCapacity(),
--         fuelNeeded = self.device.getFuelNeeded(),
--         fuelPercent = self.device.getFuelFilledPercentage(),

--         -------------------------------------------------
--         -- Waste
--         -------------------------------------------------

--         waste = self.device.getWaste(),
--         wasteCapacity = self.device.getWasteCapacity(),
--         wasteNeeded = self.device.getWasteNeeded(),
--         wastePercent = self.device.getWasteFilledPercentage(),

--         -------------------------------------------------
--         -- Coolant
--         -------------------------------------------------

--         coolant = self.device.getCoolant(),
--         coolantCapacity = self.device.getCoolantCapacity(),
--         coolantNeeded = self.device.getCoolantNeeded(),
--         coolantPercent = self.device.getCoolantFilledPercentage(),

--         -------------------------------------------------
--         -- Steam
--         -------------------------------------------------

--         heatedCoolant = self.device.getHeatedCoolant(),
--         heatedCoolantCapacity = self.device.getHeatedCoolantCapacity(),
--         heatedCoolantNeeded = self.device.getHeatedCoolantNeeded(),
--         heatedCoolantPercent = self.device.getHeatedCoolantFilledPercentage(),

--         -------------------------------------------------
--         -- Other
--         -------------------------------------------------

--         boilEfficiency = self.device.getBoilEfficiency(),
--         fuelAssemblies = self.device.getFuelAssemblies(),

--         width = self.device.getWidth(),
--         length = self.device.getLength(),
--         height = self.device.getHeight(),

--         logicMode = self.device.getLogicMode(),
--         redstoneMode = self.device.getRedstoneMode()

--     }

-- end



-------------------------------------------------
-- Безопасность
-------------------------------------------------


function FissionReactor:safetyCheck(data)


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

    if tostring(self.device.getStatus()) == "true" then
        self:resetAlarm()
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