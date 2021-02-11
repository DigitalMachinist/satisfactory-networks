-- The execution mode. Accepts: [DEFAULT]
MODE = "DEFAULT"

-- Required: The main disk to boot from (config, functions, component instructions).
-- This *can* be a floppy if you want to boot from a floppy.
DRIVE_UUID_PRIMARY = "54AAEAAC4DDFE3560E8ADE8B9D940DF5"

-- Optional: Any secondary disk connected to the computer.
DRIVE_UUID_SECONDARY = nil

-- Optional: Set this to require that only the floppy matching this UUID will mount.
-- Use this to protect your computer against an incorrect disk being used to make changes to it.
DRIVE_UUID_FLOPPY = nil

-- How each drive will be referred to in the filesystem.
DRIVE_ALIAS_PRIMARY = "primary"
DRIVE_ALIAS_SECONDARY = "secondary"
DRIVE_ALIAS_FLOPPY = "floppy"

-- File paths
FILE_CONFIG = "config.lua"
DIR_FUNCTIONS = "functions"
DIR_COMPONENT = "component"
FILE_COMPONENT = "component.lua"

-- State
__Drives = nil
fs = filesystem

-- Functions
function MapDrives()
    local drives = {};
    for _, drive in pairs(fs.childs("/dev")) do
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

            drives[alias] = drive
        end
    end

    return drives
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
        print(DRIVE_UUID_FLOPPY)
        print(__Drives[DRIVE_ALIAS_FLOPPY])
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

function MountAll()
    -- Initialize /dev
    if fs.initFileSystem("/dev") == false then
        computer.panic("Unable to initialize the filesystem.")
    end

    __Drives = MapDrives()
    PrintConnectedDrives()
    print()

    MountFloppy()
    MountPrimary()
    MountSecondary()
    print()
end

function RunConfig(fileConfig)
    if fs.exists(fileConfig) and fs.isFile(fileConfig) then
        print(fileConfig.." exists! Attempting to load configuration...")
        if fs.doFile(fileConfig) == false then
            print("Unable to run "..fileConfig..". Skipping...")
        end
    end
end

-- Load files into Lua as functions
-- TODO: Recursively traverse directory structure.
function LoadFunctions(dirFunctions)
    if fs.exists(dirFunctions) and fs.isDir(dirFunctions) then
        print(dirFunctions.." folder exists! Attempting to load functions...")
        local nodes = fs.childs(dirFunctions)
        for i,node in pairs(nodes) do
            local filepath = dirFunctions.."/"..node
            if fs.isFile(filepath) then
                if filepath:sub(-4) == ".lua" then
                    print("Loading "..filepath.." as a function...")
                    local filename = node:sub(0, string.len(node) - 4)
                    _G[filename] = fs.loadFile(filepath)
                    print(i..". "..filepath.." loaded into global table as "..filename.."()")
                end
            end
        end
    end
end

function RunComponent(fileComponent)
    if (fs.exists(fileComponent) and fs.isFile(fileComponent)) == false then
        computer.panic("Unable to find component instructions at "..fileComponent..".")
    end

    print("Running component instructions at "..fileComponent.."...")
    if fs.doFile(fileComponent) == false then
        computer.panic("Unable to run component instructions.")
    end
end

function ModeDefault()
    MountAll()

    RunConfig("/"..DRIVE_ALIAS_PRIMARY.."/"..FILE_CONFIG)
    print()
    LoadFunctions("/"..DRIVE_ALIAS_PRIMARY.."/"..DIR_FUNCTIONS)
    print()

    -- This is the entrypoint to the component instructions.
    RunComponent("/"..DRIVE_ALIAS_PRIMARY.."/"..DIR_COMPONENT.."/"..FILE_COMPONENT)
end

function Main()
    if MODE == 'DEFAULT' then
        ModeDefault()
    else
        computer.panic("Unexpected execution mode ("..MODE..")")
    end

    print()
    print("STOPPED")
end

-- RUN IT!
Main()