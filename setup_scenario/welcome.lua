local ui = dofile("/SCADA/ui.lua")
local config = dofile("/SCADA/config.lua")

local welcome = {}

function welcome.run()

    while true do

        ui.clear()

        local w, h = term.getSize()

        -------------------------------------------------
        -- Шапка
        -------------------------------------------------

        ui.title("MEKANISM FISSION SCADA SETUP")

        -------------------------------------------------
        -- Главное окно
        -------------------------------------------------

        local x = 2
        local y = 3
        local pw = w - 2
        local ph = h - 6

        ui.panel(
            x,
            y,
            pw,
            ph,
            ""
        )

        ui.label(x + 2, y + 7,  "Version")
        ui.label(x + 20, y + 7, config.version or "1.0.0")

        ui.label(x + 2, y + 8,  "Build")
        ui.label(x + 20, y + 8, config.build or "2026.07.19", ui.theme.bg)

        ui.label(x + 2, y + 9,  "Developer")
        ui.label(x + 20, y + 9, "yakiecho")

        ui.label(x + 2, y + 10, "Repository")
        ui.label(x + 20, y + 10, "github.com/yakiecho/mekanism_fussionreactor_scada")

        ui.label(
            x + 2,
            y + 2,
            "This setup wizard will prepare the SCADA"
        )

        ui.label(
            x + 2,
            y + 3,
            "system for first operation."
        )

        ui.button(
            w - 16,
            h - 2,
            14,
            "START",
            colors.green,
            true
        )

        if config.first_start then
            ui.status(
                "Ready for commissioning",
                colors.green
            )
        else 
            ui.status(
                "You're already configured!\nOld configuration settings will be deleted!",
                colors.orange
            )
        end

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