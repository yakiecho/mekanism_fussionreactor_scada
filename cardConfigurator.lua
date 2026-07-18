local reader = peripheral.find("magnetic_card_manipulator")

if not reader then
    error("Mag Card Reader not found")
end

while true do
    term.clear()
    term.setCursorPos(1,1)

    print("====== MAG CARD TOOL ======")
    print("1. Read card")
    print("2. Write card")
    print("3. Erase card")
    print("4. Exit")
    print("5. Debug data")
    print()

    io.write("> ")
    local choice = read()

    if choice == "1" then

        print()
        print("Insert card...")

        local data = reader.readCard()

        print()
        print("Card content:")
        print(textutils.serialize(data))

        print()
        print("Press Enter...")
        read()

    elseif choice == "2" then

        print()
        print("Text to write:")
        local text = read()

        print("Insert card...")

        reader.writeCard(text)

        print("Done.")

        print()
        print("Press Enter...")
        read()

    elseif choice == "3" then

        print()
        print("Insert card...")

        reader.erase()

        print("Card erased.")

        print()
        print("Press Enter...")
        read()

    elseif choice == "5" then
        for _, method in ipairs(peripheral.getMethods(peripheral.getName(reader))) do
            print(method)
        end

        print()
        print("Press Enter...")
        read()

    elseif choice == "4" then
        break
    end
end