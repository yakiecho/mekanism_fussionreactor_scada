local reader = peripheral.find("magnetic_card_manipulator")

if not reader then
    error("Magnetic Card Manipulator not found")
end

local function clear()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1,1)
end

local function pause()
    print()
    print("Press any key...")
    os.pullEvent("key")
end

local function waitCard()

    while not reader.hasCard() do
        clear()

        print("===================================")
        print("     MAGNETIC CARD PROGRAMMER")
        print("===================================")
        print()
        print("Insert magnetic card...")

        sleep(0.2)
    end

end

while true do

    waitCard()

    clear()

    print("===================================")
    print("     MAGNETIC CARD PROGRAMMER")
    print("===================================")
    print()

    print("Card label : "..tostring(reader.getLabel()))
    print("Card data  : "..tostring(reader.readCard()))
    print()

    print("1. Write key")
    print("2. Read card")
    print("3. Rename card")
    print("4. Lock card")
    print("5. Eject")
    print("0. Exit")
    print()

    write("> ")

    local choice = read()

    if choice == "1" then

        write("Key: ")
        local key = read()

        if reader.writeCard(key) then
            print("Key written.")
        else
            print("Write failed.")
        end

        pause()

    elseif choice == "2" then

        print()
        print("Card data:")
        print(reader.readCard())

        pause()

    elseif choice == "3" then

        write("Label: ")
        local label = read()

        reader.setLabel(label)

        print("Label changed.")

        pause()

    elseif choice == "4" then

        reader.setSecure(true)

        print("Card locked.")

        pause()

    elseif choice == "5" then

        reader.ejectCard()

    elseif choice == "0" then

        break

    end

end