local ui = require("ui")

local welcome = {}

function welcome.run(state)

    while true do

        ui.clear()

        local w, h = term.getSize()

        -------------------------------------------------
        -- Шапка
        -------------------------------------------------

        ui.title("MEKANISM FISSION SCADA")

        -------------------------------------------------
        -- Главное окно
        -------------------------------------------------

        local x = 3
        local y = 3
        local pw = w - 4
        local ph = h - 6

        ui.panel(
            x,
            y,
            pw,
            ph,
            "Commissioning Wizard"
        )

        ui.label(
            x + 2,
            y + 2,
            "Welcome."
        )

        ui.label(
            x + 2,
            y + 4,
            "This wizard will prepare the SCADA"
        )

        ui.label(
            x + 2,
            y + 5,
            "system for first operation."
        )

        ui.separator(y + 7)

        ui.label(
            x + 2,
            y + 9,
            "The following steps will be completed:"
        )

        ui.label(x + 4, y + 11, "• Reactor detection")
        ui.label(x + 4, y + 12, "• Monitor selection")
        ui.label(x + 4, y + 13, "• Magnetic card setup")
        ui.label(x + 4, y + 14, "• Security PIN")
        ui.label(x + 4, y + 15, "• Safety limits")
        ui.label(x + 4, y + 16, "• Final diagnostics")

        ui.separator(y + ph - 4)

        ui.label(
            x + 2,
            y + ph - 3,
            "Estimated setup time: less than 2 minutes."
        )

        ui.button(
            w - 16,
            h - 2,
            14,
            "START",
            colors.green,
            true
        )

        ui.status(
            "Ready for commissioning",
            colors.green
        )

        -------------------------------------------------
        -- Обработка
        -------------------------------------------------

        local _, _, bx, by = os.pullEvent("mouse_click")

        local button = ui.getButton(bx, by)

        if button == "START" then
            return true
        end

    end

end

return welcome