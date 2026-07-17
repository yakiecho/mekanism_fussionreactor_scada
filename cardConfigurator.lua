local reader = peripheral.find("mag_card_reader")

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
    print()

    io.write("> ")
    local choice = read()

    if choice == "1" then

        print()
        print("Insert card...")

        os.pullEvent("mag_card_insert")

        local data = reader.read()

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

        os.pullEvent("mag_card_insert")

        reader.write(text)

        print("Done.")

        print()
        print("Press Enter...")
        read()

    elseif choice == "3" then

        print()
        print("Insert card...")

        os.pullEvent("mag_card_insert")

        reader.erase()

        print("Card erased.")

        print()
        print("Press Enter...")
        read()

    elseif choice == "4" then
        break
    end
end