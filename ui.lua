local ui = {}

local buttons = {}


ui.theme = {
    bg = colors.black,
    panel = colors.gray,
    panelDark = colors.lightGray,
    border = colors.white,

    text = colors.white,
    textDark = colors.lightGray,

    green = colors.green,
    red = colors.red,
    orange = colors.orange,
    blue = colors.blue,
    cyan = colors.cyan,
    gray = colors.gray
}


function ui.init(target)

    if target then
        term.redirect(target)
    end

    term.setBackgroundColor(ui.theme.bg)
    term.setTextColor(ui.theme.text)
    term.clear()

end


function ui.clear()

    term.setBackgroundColor(ui.theme.bg)
    term.setTextColor(ui.theme.text)
    term.clear()
    term.setCursorPos(1,1)

    buttons = {}

end


function ui.background()

    local w,h = term.getSize()

    term.setBackgroundColor(ui.theme.bg)

    for y=1,h do
        term.setCursorPos(1,y)
        write(string.rep(" ",w))
    end

end


function ui.title(text)

    local w = term.getSize()

    term.setBackgroundColor(ui.theme.panel)
    term.setTextColor(ui.theme.text)

    term.setCursorPos(1,1)
    write(string.rep(" ",w))

    term.setCursorPos(
        math.floor((w-#text)/2)+1,
        1
    )

    write(text)

    term.setBackgroundColor(ui.theme.bg)

end


function ui.status(text,color)

    local w,h = term.getSize()

    term.setBackgroundColor(color or ui.theme.panel)
    term.setTextColor(colors.white)

    term.setCursorPos(1,h)
    write(string.rep(" ",w))

    term.setCursorPos(1,h)
    write(text)

    term.setBackgroundColor(ui.theme.bg)
    term.setTextColor(ui.theme.text)

end


function ui.panel(x,y,w,h,title)

    term.setBackgroundColor(ui.theme.panelDark)

    for yy=y,y+h-1 do
        term.setCursorPos(x,yy)
        write(string.rep(" ",w))
    end

    paintutils.drawBox(
        x,
        y,
        x+w-1,
        y+h-1,
        ui.theme.border
    )

    if title then

        term.setCursorPos(
            x+2,
            y
        )

        term.setBackgroundColor(ui.theme.panel)

        if title ~= "" then 
            write(" "..title.." ")
        end

        term.setBackgroundColor(ui.theme.panelDark)

    end

end


function ui.label(x, y, text, color, bgcolor)

    term.setCursorPos(x, y)

    if color then
        term.setTextColor(color)
    else
        term.setTextColor(ui.theme.text)
    end

    if bgcolor then
        term.setBackgroundColor(bgcolor)
    end

    write(text)

    term.setTextColor(ui.theme.text)
end


function ui.progress(x,y,w,value,color)

    color = color or ui.theme.green

    local fill = math.floor(w*value)

    term.setCursorPos(x,y)

    for i=1,w do

        if i<=fill then
            term.setBackgroundColor(color)
        else
            term.setBackgroundColor(colors.gray)
        end

        write(" ")

    end

    term.setBackgroundColor(ui.theme.bg)

end


function ui.separator(y)

    local w = term.getSize()

    term.setCursorPos(2, y)
    term.setBackgroundColor(ui.theme.bg)
    term.setTextColor(ui.theme.border)

    write(string.rep("-", w - 2))

    term.setTextColor(ui.theme.text)

end


function ui.value(x, y, name, value)

    ui.label(x, y, name)
    ui.label(x + 18, y, tostring(value), ui.theme.cyan)

end


function ui.list(x, y, w, h, items, selected)

    ui.panel(x, y, w, h, "Detected displays")

    for i = 1, h - 2 do

        local index = i

        if items[index] then

            local bg = ui.theme.panelDark

            if index == selected then
                bg = colors.blue
            end

            term.setCursorPos(x + 1, y + i)
            term.setBackgroundColor(bg)

            write(string.rep(" ", w - 2))

            ui.label(
                x + 2,
                y + i,
                items[index],
                colors.white,
                bg
            )

        end

    end

    term.setBackgroundColor(ui.theme.bg)

end


function ui.button(x,y,w,text,color,enabled)

    enabled = enabled ~= false

    local bg = enabled and color or colors.gray

    paintutils.drawBox(
        x,
        y,
        x+w-1,
        y,
        color
    )

    term.setBackgroundColor(bg)

    term.setCursorPos(x,y)
    write(string.rep(" ",w))

    term.setCursorPos(
        x+math.floor((w-#text)/2),
        y
    )

    if enabled then
        term.setTextColor(ui.theme.text)
    else
        term.setTextColor(ui.theme.text)
    end

    write(text)

    table.insert(buttons,{
        x=x,
        y=y,
        w=w,
        h=1,
        text=text,
        enabled=enabled
    })

end


function ui.getButton(x,y)

    for _,b in ipairs(buttons) do

        if b.enabled
        and x>=b.x
        and x<b.x+b.w
        and y==b.y then

            return b.text

        end
    end
end


function ui.overlay()

    local w,h = term.getSize()

    term.setBackgroundColor(colors.gray)

    for y=1,h do
        term.setCursorPos(1,y)
        write(string.rep(" ",w))
    end

    term.setBackgroundColor(ui.theme.bg)

end


function ui.centerWindow(w,h)

    local tw,th = term.getSize()

    return
        math.floor((tw-w)/2)+1,
        math.floor((th-h)/2)+1

end


function ui.dialog(title,message)

    local x,y = ui.centerWindow(40,8)

    ui.overlay()

    ui.panel(
        x,
        y,
        40,
        8,
        title
    )

    ui.label(
        x+2,
        y+2,
        message
    )

    ui.button(
        x+15,
        y+6,
        10,
        "OK",
        ui.theme.green
    )

end


function ui.infoBox(x,y,w,title,lines)

    ui.panel(x,y,w,#lines+3,title)

    for i,v in ipairs(lines) do
        ui.label(
            x+2,
            y+1+i,
            v
        )
    end

end

return ui