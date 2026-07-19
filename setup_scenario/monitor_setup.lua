local ui = dofile("/SCADA/ui.lua")
local config = dofile("/SCADA/config.lua")

local monitorSetup = {}

local modes = {
        "Main SCADA",
        "Reactor",
        "Pipes",
        "Cables",
        "Energy",
        "Statistics",
        "Alarm panel",
        "abcdef",
        "abcdef1",
        "abcdef2",
        "abcdef3",
        "abcdef4",
        "abcdef5",
        "abcdef6",
        "abcdef7",
        "abcdef8",

    }

    local modes_keynames = {
        "mainscada",
        "reactor",
        "pipes",
        "cables",
        "energy",
        "statistics",
        "alarmpanel",
        "abcdef",
        "abcdef1",
        "abcdef2",
        "abcdef3",
        "abcdef4",
        "abcdef5",
        "abcdef6",
        "abcdef7",
        "abcdef8",
    }

local modeNames = {}

local monitorSelected = 1
local modeSelected = 1

local monitorScroll = 0
local modeScroll = 0

local startMonitorY = 5
local startModeY = 5

for i, key in ipairs(modes_keynames) do
    modeNames[key] = modes[i]
end

local function saveDisplays(state)

    config.displays = {}

    for _, monitor in ipairs(state.monitors) do
        config.displays[monitor.name] = monitor.mode
    end

    local file = fs.open("/SCADA/config.lua", "w")

    file.write("return ")
    file.write(textutils.serialize(config))

    file.close()

end

function monitorSetup.run(state)

    state = state or {}
    state.monitors = state.monitors or {}

    if next(state.monitors) == nil and config.displays then

        for monitor_id, mode_id in pairs(config.displays) do

            table.insert(
                state.monitors,
                {
                    name = monitor_id,
                    mode = mode_id
                }
            )

        end

    end

    local names = {}

    for _,name in ipairs(peripheral.getNames()) do
        if peripheral.getType(name) == "monitor" then
            table.insert(names,name)
        end
    end

    table.sort(names)

    while true do

        ui.clear()

        local w,h = term.getSize()

        local listHeight = h - 2

        ui.title("DISPLAY CONFIGURATION")

        -------------------------------------------------
        -- Мониторы
        -------------------------------------------------

        ui.panel(
            1,
            3,
            25,
            h-5,
            "Monitors"
        )

        local visibleMonitors = h - 8
        local start = monitorScroll + 1
        local finish = math.min(
            #names,
            start + visibleMonitors - 1
        )

        for i = start, finish do

            local name = names[i]
            local y = startMonitorY + (i - start)




            local bg

            if i == monitorSelected then
                bg = colors.blue
            else
                bg = ui.theme.panelDark
            end

            ui.label(
                3,
                y,
                name,
                colors.white,
                bg
            )

            local assigned = nil

            for _, v in ipairs(state.monitors) do

                if v.name == name then

                    assigned = modeNames[v.mode]
                    break

                end

            end

            if assigned then

                ui.label(
                    string.len(name) + 3,
                    y,
                    "->",
                    colors.white,
                    colors.green
                )

                ui.label(
                    string.len(name) + 5,
                    y,
                    assigned,
                    colors.white,
                    colors.green
                )
            end

        end

        -------------------------------------------------
        -- Роли
        -------------------------------------------------

        ui.panel(
            28,
            3,
            24,
            h-5,
            "Display role"
        )



        local visibleModes = h - 8
        local start = modeScroll + 1
        local finish = math.min(
            #modes,
            start + visibleModes - 1
        )

        for i = start, finish do
            local mode = modes[i]
            local y = startModeY + (i - start)



            if  i==modeSelected then
                selectionitemcolor = colors.blue
            else
                selectionitemcolor = ui.theme.panelDark
            end

            ui.label(
                30,
                y,
                mode,
                colors.white,
                selectionitemcolor
            )

        end

        -------------------------------------------------
        -- Кнопки
        -------------------------------------------------

        ui.button(
            w-44,
            h-3,
            12,
            "ASSIGN",
            colors.green,
            #names>0
        )

        ui.button(
            w-30,
            h-3,
            12,
            "REMOVE",
            colors.red,
            #names>0
        )

        ui.button(
            w-16,
            h-3,
            14,
            "CONTINUE",
            colors.green,
            true
        )

        ui.button(
            13,
            h-2,
            6,
            "D>",
            colors.gray,
            monitorScroll > 0
        )

        ui.button(
            20,
            h-2,
            6,
            "<D",
            colors.gray,
            monitorScroll + visibleMonitors < #names
        )


        ui.button(
            39,
            h-2,
            6,
            "M>",
            colors.gray,
            modeScroll > 0
        )

        ui.button(
            46,
            h-2,
            6,
            "<M",
            colors.gray,
            modeScroll + visibleModes < #modes
        )

        ui.status(
            ("%d monitor(s) detected"):format(#names),
            colors.blue
        )

        -------------------------------------------------
        -- Обработка
        -------------------------------------------------

        local _,_,mx,my=os.pullEvent("mouse_click")

        local button=ui.getButton(mx,my)

        if button == "D>" then

            monitorScroll = math.max(
                0,
                monitorScroll - 1
            )


        elseif button == "<D" then

            monitorScroll = math.min(
                #names - visibleMonitors,
                monitorScroll + 1
            )


        elseif button == "M>" then

            modeScroll = math.max(
                0,
                modeScroll - 1
            )


        elseif button == "<M" then

            modeScroll = math.min(
                #modes - visibleModes,
                modeScroll + 1
            )

        elseif button=="ASSIGN" then

            if names[monitorSelected] then

                local current=names[monitorSelected]
                local role = modes_keynames[modeSelected]

                local found=false

                for _,v in ipairs(state.monitors) do

                    if v.name==current then
                        v.mode=role
                        found=true
                        break
                    end

                end

                if not found then

                    table.insert(
                        state.monitors,
                        {
                            name=current,
                            mode=role
                        }
                    )

                end

            end

        elseif button=="REMOVE" then

            local current=names[monitorSelected]

            for i,v in ipairs(state.monitors) do

                if v.name==current then
                    table.remove(state.monitors,i)
                    break
                end

            end

        elseif button=="CONTINUE" then

            saveDisplays(state)

            return True

        else

            if mx>=4 and mx<=24 then

                local id=my-4
                id = id + monitorScroll

                if names[id] then
                    monitorSelected=id
                end

            end

            if mx>=30 and mx<=50 then

                local id=my-4
                id = id + modeScroll

                if modes[id] then
                    modeSelected=id
                end

            end

        end

    end

end

-- return monitorSetup

monitorSetup.run()