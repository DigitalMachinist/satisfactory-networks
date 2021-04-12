-- Required: The main disk to boot from (config, functions, component instructions).
DRIVE_UUID_PRIMARY = "DD42F6AD401ABECA9D59FEBB0E95C026"

-- Optional: Any secondary disk connected to the computer.
DRIVE_UUID_SECONDARY = nil

-- Optional: Set this to require that only the floppy matching this UUID will mount.
-- Use this to protect your computer against an incorrect disk being used to make changes to it.
DRIVE_UUID_FLOPPY = nil

-- How each drive will be referred to in the filesystem.
DRIVE_ALIAS_PRIMARY = "primary"
DRIVE_ALIAS_SECONDARY = "secondary"
DRIVE_ALIAS_FLOPPY = "floppy"

-- State
__Drives = nil
fs = filesystem

-- Functions
function MapDrives()
    local drives = fs.childs("/dev")
    -- for _, drive in pairs(drives) do
    --     print(drive)
    -- end
    local drivesMap = {};
    for _, drive in pairs(drives) do
        if drive ~= "serial" then
            local alias = ""
            if drive == DRIVE_UUID_PRIMARY then
                alias = DRIVE_ALIAS_PRIMARY
            elseif drive == DRIVE_UUID_SECONDARY then
                alias = DRIVE_ALIAS_SECONDARY
            else
                -- Anything else must be a floppy because we can't predict a floppy's UUID.
                alias = DRIVE_ALIAS_FLOPPY
            end

            drivesMap[alias] = drive
        end
    end

    return drivesMap
end

function InitFilesystem()
    -- Initialize /dev
    if fs.initFileSystem("/dev") == false then
        computer.panic("Unable to initialize the filesystem.")
    end

    __Drives = MapDrives()
end

function PrintConnectedDrives()
    -- Find the length of the longest alias word so we can format the list based on that.
    local length = math.max(
        string.len(DRIVE_ALIAS_FLOPPY),
        string.len(DRIVE_ALIAS_PRIMARY),
        string.len(DRIVE_ALIAS_SECONDARY)
    )

    print("DRIVES:")
    print(string.format("%-"..length.."s", DRIVE_ALIAS_FLOPPY).." --> "..(__Drives[DRIVE_ALIAS_FLOPPY] or "Not inserted"))
    print(string.format("%-"..length.."s", DRIVE_ALIAS_PRIMARY).." --> "..(__Drives[DRIVE_ALIAS_PRIMARY] or "Not connected"))
    print(string.format("%-"..length.."s", DRIVE_ALIAS_SECONDARY).." --> "..(__Drives[DRIVE_ALIAS_SECONDARY] or "Not connected"))
end

function MountFloppy()
    if __Drives[DRIVE_ALIAS_FLOPPY] ~= nil then
        if DRIVE_UUID_FLOPPY ~= nil and __Drives[DRIVE_ALIAS_FLOPPY] ~= DRIVE_UUID_FLOPPY then
            computer.panic("Inserted floppy "..__Drives[DRIVE_ALIAS_FLOPPY].." does not match expected "..DRIVE_UUID_FLOPPY..".")
        end
        print("Mounting /dev/"..__Drives[DRIVE_ALIAS_FLOPPY].." as "..DRIVE_ALIAS_FLOPPY.."...")
        fs.mount("/dev/"..__Drives[DRIVE_ALIAS_FLOPPY], "/"..DRIVE_ALIAS_FLOPPY)
    end
end

function MountPrimary()
    if __Drives[DRIVE_ALIAS_PRIMARY] == nil then
        computer.panic("Primary drive is not connected.")
    end
    print("Mounting /dev/"..DRIVE_UUID_PRIMARY.." as "..DRIVE_ALIAS_PRIMARY.."...")
    fs.mount("/dev/"..DRIVE_UUID_PRIMARY, "/"..DRIVE_ALIAS_PRIMARY)
end

function MountSecondary()
    if DRIVE_UUID_SECONDARY ~= nil then
        if __Drives[DRIVE_ALIAS_SECONDARY] == nil then
            computer.panic("Secondary drive is not connected. Set DRIVE_UUID_SECONDARY=nil if no secondary drive is expected.")
        end
        print("Mounting /dev/"..DRIVE_UUID_SECONDARY.." as "..DRIVE_ALIAS_SECONDARY.."...")
        fs.mount("/dev/"..DRIVE_UUID_SECONDARY, "/"..DRIVE_ALIAS_SECONDARY)
    end
end

function MountAllDrives()
    MountFloppy()
    MountPrimary()
    MountSecondary()
end

function UpdateEEPROM(filepathEEPROM, tagLock)
    if fs.exists(tagLock) == false then
        print "Seems like an EEPROM update is in order."

        -- Read in the new EEPROM code from the given filepath.
        local f = assert(fs.open(filepathEEPROM, "r"))
        local content = f:read("*all")
        f:close()

        -- Update the computer's EEPROM code to the file contents.
        computer.setEEPROM(content)

        -- Create the a lockfile to prevent further updates.
        f = assert(fs.open(tagLock, "w"))
        f:close()

        -- Reboot the computer.
        print("Restarting NOW to apply EEPROM update...")
        print()
        print("=== RESTART! ===")
        print()
        computer.reset()
    else
        print "No EEPFROM update performed."
    end
end

function LoadLibrariesRecursive(dirpath)
    local nodes = fs.childs(dirpath)
    for i,node in pairs(nodes) do
        local path = dirpath.."/"..node
        if fs.isDir(path) then
            -- Recursively load subdirectories.
            LoadLibrariesRecursive(path)
        else
            -- Only load *.lua files
            if path:sub(-4) == ".lua" then
                --print(i..". "..path.."...")
                fs.doFile(path)
            else
                --print(i..". "..path.." (non-Lua) skipped...")
            end
        end
    end
end

function LoadLibraries(dirpath)
    if fs.exists(dirpath) and fs.isDir(dirpath) then
        print(dirpath.." folder exists! Attempting to load libraries...")
        LoadLibrariesRecursive(dirpath)
    end
end

function RunApp(filepath)
    if (fs.exists(filepath) and fs.isFile(filepath)) == false then
        computer.panic("Unable to find app instructions at "..filepath..".")
    end

    print("Running app instructions at "..filepath.."...")
    if fs.doFile(filepath) == false then
        computer.panic("Unable to run app instructions.")
    end
end

function Main()
    InitFilesystem()
    PrintConnectedDrives()
    print()
    MountAllDrives()
    print()
    UpdateEEPROM("/primary/eeprom.lua", "/primary/tags/update_lock")
    print()
    LoadLibraries("/primary/libraries")
    print()
    RunApp("/primary/app.lua")
    print()
    print("STOPPED")
end

-- RUN IT!
Main()
