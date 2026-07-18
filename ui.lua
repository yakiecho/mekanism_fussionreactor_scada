local ui = {}

local buttons = {}

-------------------------------------------------
-- Инициализация
-------------------------------------------------

function ui.init(target)

    if target then
        term.redirect(target)
    end

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

-------------------------------------------------
-- Экран
-------------------------------------------------

function ui.clear()

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1,1)

    buttons = {}

end

-------------------------------------------------
-- Заголовок
-------------------------------------------------

function ui.title(text)

    local w = term.getSize()

    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)

    term.setCursorPos(1,1)
    write(string.rep(" ", w))

    term.setCursorPos(math.floor((w - #text) / 2) + 1,1)
    write(text)

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

end

-------------------------------------------------
-- Прогресс
-------------------------------------------------

function ui.progress(x,y,width,value,color)

    color = color or colors.green

    local filled = math.floor(width * value)

    term.setCursorPos(x,y)

    for i=1,width do

        if i <= filled then
            term.setBackgroundColor(color)
        else
            term.setBackgroundColor(colors.gray)
        end

        write(" ")

    end

    term.setBackgroundColor(colors.black)

end

-------------------------------------------------
-- Надпись
-------------------------------------------------

function ui.label(x,y,text,color)

    term.setCursorPos(x,y)

    term.setTextColor(color or colors.white)

    write(text)

    term.setTextColor(colors.white)

end

-------------------------------------------------
-- Кнопка
-------------------------------------------------

function ui.button(x,y,w,text,color,enabled)

    enabled = enabled ~= false

    term.setBackgroundColor(enabled and color or colors.gray)

    term.setCursorPos(x,y)
    write(string.rep(" ",w))

    term.setCursorPos(
        x + math.floor((w - #text)/2),
        y
    )

    if enabled then
        term.setTextColor(colors.white)
    else
        term.setTextColor(colors.lightGray)
    end

    write(text)

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    table.insert(buttons,{
        x=x,
        y=y,
        w=w,
        h=1,
        text=text,
        enabled=enabled
    })

end

-------------------------------------------------
-- Проверка нажатия
-------------------------------------------------

function ui.getButton(x,y)

    for _,b in ipairs(buttons) do

        if b.enabled
        and x >= b.x
        and x < b.x + b.w
        and y == b.y then

            return b.text

        end

    end

end

-------------------------------------------------
-- Окно
-------------------------------------------------

function ui.window(x,y,w,h,title)

    term.setBackgroundColor(colors.lightGray)

    for yy=y,y+h-1 do
        term.setCursorPos(x,yy)
        write(string.rep(" ",w))
    end

    term.setBackgroundColor(colors.gray)

    term.setCursorPos(x,y)
    write(string.rep(" ",w))

    term.setCursorPos(
        x + math.floor((w-#title)/2),
        y
    )

    term.setTextColor(colors.white)
    write(title)

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

end

-------------------------------------------------
-- Затемнение
-------------------------------------------------

function ui.overlay()

    local w,h = term.getSize()

    term.setBackgroundColor(colors.gray)

    for y=1,h do
        term.setCursorPos(1,y)
        write(string.rep(" ",w))
    end

    term.setBackgroundColor(colors.black)

end

-------------------------------------------------
-- Центрирование
-------------------------------------------------

function ui.centerWindow(width,height)

    local w,h = term.getSize()

    return
        math.floor((w-width)/2)+1,
        math.floor((h-height)/2)+1

end

-------------------------------------------------
-- Диалог
-------------------------------------------------

function ui.dialog(title,message)

    local x,y = ui.centerWindow(34,7)

    ui.overlay()
    ui.window(x,y,34,7,title)

    ui.label(x+2,y+2,message)

    ui.button(
        x+12,
        y+5,
        10,
        "OK",
        colors.green,
        true
    )

end

return ui