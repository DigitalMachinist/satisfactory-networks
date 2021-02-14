-- Constants about the items to be stored.
ITEM_TYPE = "Concrete"
ITEM_STACK_SIZE = 500

-- The containers make up the actual storage medium backing the storage controller.
CONTAINER_NAME = "Container"
CONTAINER_UPDATE_COOLDOWN_MS = 1000

-- The splitter is used to control item flow and maintain the target number of items.
SPLITTER_NAME = "Splitter"
SPLITTER_OUTPUT = SPLITTER_OUTPUT_CENTER

-- The control panel is where all controls and displays will appear.
PANEL_NAME = "Panel"

-- The bypass toggle controls whether the storage system should store items *at all*.
BYPASS_TOGGLE_POS = { x = 0, y = 10 }
BYPASS_LED_POS = { x = 2, y = 10 }

-- The target dial controls the percentage of storage we're targeting to use.
TARGET_DIAL_POS = { x = 0, y = 9 }
TARGET_DIAL_SENSITIVITY = 1
TARGET_LED_POS = { x = 2, y = 9 }

-- Colours
COLOR_ENABLED = { r = 0.05, g = 1.0, b = 0.05, a = 1.0 }
COLOR_DISABLED = { r = 0, g = 0, b = 0, a = 0 }

-- Components
Components = nil
Splitter = nil
Panel = nil
BypassToggle = nil
BypassLED = nil
TargetDial = nil
TargetLED = nil

-- State
IsBypassed = false      -- Should the entire storage system be bypassed/disabled?
TargetPercent = nil     -- The percentage of the available storage we aim to use.
TargetNumStored = nil   -- The number of stored items we aim to keep (anything beyond this is overflow).
NumStored = nil         -- The current number of stored items.
StoreSize = nil         -- The total size of the storage media.
SpitterOutIndex = 0     -- The index of of the output the splitter last transferred an item to.
fs = filesystem

function GetContainers(nickname)
    local cContainers = component.findComponent(nickname)
    if cContainers == nil then
        computer.panic("No containers ("..nickname..") were found.")
    end

    return component.proxy(cContainers)
end

function GetSplitter(nickname)
    local cSplitter = component.findComponent(nickname)[1]
    if cSplitter == nil then
        computer.panic("Splitter ("..nickname..") not found.")
    end

    return component.proxy(cSplitter)
end

function GetPanel(nickname)
    local cPanel = component.findComponent(nickname)[1]
    if cPanel == nil then
        computer.panic("Panel ("..nickname..") not found.")
    end

    return component.proxy(cPanel)
end

function InitComponents()
    Containers = GetContainers(CONTAINER_NAME)
    Splitter = GetSplitter(SPLITTER_NAME)
    Panel = GetPanel(PANEL_NAME)
    BypassToggle = Panel:getModule(BYPASS_TOGGLE_POS["x"], BYPASS_TOGGLE_POS["y"])
    BypassLED = Panel:getModule(BYPASS_LED_POS["x"], BYPASS_LED_POS["y"])
    TargetDial = Panel:getModule(TARGET_DIAL_POS["x"], TARGET_DIAL_POS["y"])
    TargetLED = Panel:getModule(TARGET_LED_POS["x"], TARGET_LED_POS["y"])
end

function GetContainerUsage()
    local totalSize = 0;
    local totalUsed = 0;
    for _, container in pairs(Containers) do
        for _, inventory in pairs(container:getInventories()) do
            totalSize = totalSize + inventory.size * ITEM_STACK_SIZE
            totalUsed = totalUsed + inventory.itemCount
        end
    end

    return totalUsed, totalSize
end

function ReadTargetPercentStored(filepath)
    if (fs.exists(filepath) and fs.isFile(filepath)) then
        local f = fs.open(filepath, "r")
        local targetPercent = f:read("*all")
        f:close()

        return tonumber(targetPercent)
    end

    return nil
end

function WriteTargetPercentStored(filepath, targetPercent)
    if (fs.exists(filepath) and fs.isFile(filepath)) then
        local f = fs.open(filepath, "w")
        f:write(TargetPercent)
        f:close()
    end
end

function ComputeTargetNumStored(targetPercent)
    local targetFraction = targetPercent / 100
    return math.floor(targetFraction * StoreSize + 0.5)
end

function InitStorage()
    NumStored, StoreSize = GetContainerUsage()
    TargetPercent = ReadTargetPercentStored("/primary/data/TargetPercentStored")
    TargetNumStored = ComputeTargetNumStored(TargetPercent)
end

function PrintStorageStatus()
    local fraction = NumStored / StoreSize
    local percent = fraction * 100
    print("Usage: "..NumStored.." / "..StoreSize)
    print("Percent: "..tonumber(string.format("%.0f", percent)).."%")
    print("Target Usage: "..TargetNumStored.." / "..StoreSize)
    print("Target Percent: "..tonumber(string.format("%.0f", TargetPercent)).."%")
end

-- Transfer an item to any free output.
-- If the current output belt is blocked, try until one works or all fail.
-- This method should ensure maximum throughput since it will try all 3 outputs before the next Lua step.
function Transfer()
    for i = 1, SPLITTER_NUM_OUTPUTS do
        SpitterOutIndex = math.fmod(SpitterOutIndex + 1, SPLITTER_NUM_OUTPUTS)
        if Splitter:transferItem(SpitterOutIndex) then
            break
        end
    end
end

function Timestep(currentTimeMs)
    local nextTimeMs = computer.millis()
    local elapsedTimeMs = nextTimeMs - currentTimeMs
    return nextTimeMs, elapsedTimeMs
end

function SetBypassLEDStatus(isBypassed)
    if (isBypassed) then
        BypassLED:setColor(COLOR_ENABLED["r"], COLOR_ENABLED["g"], COLOR_ENABLED["b"], COLOR_ENABLED["a"])
    else
        BypassLED:setColor(COLOR_DISABLED["r"], COLOR_DISABLED["g"], COLOR_DISABLED["b"], COLOR_DISABLED["a"])
    end
end

function SetTargetLEDStatus(numStored, targetNumStored)
    if (numStored > targetNumStored) then
        TargetLED:setColor(COLOR_ENABLED["r"], COLOR_ENABLED["g"], COLOR_ENABLED["b"], COLOR_ENABLED["a"])
    else
        TargetLED:setColor(COLOR_DISABLED["r"], COLOR_DISABLED["g"], COLOR_DISABLED["b"], COLOR_DISABLED["a"])
    end
end

function HandleSplitter(isBypassed, numStored, targetNumStored)
    if (isBypassed or (numStored >= targetNumStored)) then
        Transfer()
    end
end

function HandleTargetDialChange(anticlockwise)
    local change = TARGET_DIAL_SENSITIVITY
    if (anticlockwise) then
        change = -1 * change
    end

    TargetPercent = Clamp(TargetPercent + change, 0, 100)
    WriteTargetPercentStored("/primary/data/TargetPercentStored", TargetPercent)
    TargetNumStored = ComputeTargetNumStored(TargetPercent)
end


function CoStorage()
    local elapsedTimeMs = 0
    local currentTimeMs = computer.millis()
    local containerUpdateCooldownMs = CONTAINER_UPDATE_COOLDOWN_MS

    while true do
        -- Update the container usage values (but only every CONTAINER_UPDATE_COOLDOWN_MS).
        currentTimeMs, elapsedTimeMs = Timestep(currentTimeMs)
        containerUpdateCooldownMs = containerUpdateCooldownMs - elapsedTimeMs
        if (containerUpdateCooldownMs <= 0) then
            containerUpdateCooldownMs = CONTAINER_UPDATE_COOLDOWN_MS
            NumStored, StoreSize = GetContainerUsage()
        end

        -- Check bypass toggle status and update LEDs if splitter should be transferring items.
        IsBypassed = not BypassToggle.state
        SetBypassLEDStatus(IsBypassed)
        SetTargetLEDStatus(NumStored, TargetNumStored)

        -- Release items out of storage if it's at target or bypassed.
        if (Splitter:getInput().type ~= nil) then
            -- print('Splitter input set')
            HandleSplitter(IsBypassed, NumStored, TargetNumStored)
        end

        event.pull(0.0)
    end
end

function CoPanelDisplays()
    local gpus = computer.getGPUs()
    for _, g in pairs(gpus) do
        print(g)
    end
    print()

    while true do
        -- UpdateNumericDisplay()
        -- UpdateGraphDisplay()

        event.pull(0.0)
    end
end

function CoPanelEvents()
    event.listen(TargetDial)
    print(TargetDial)

    while true do
        -- Handle the next event in the queue, if any.
        local eventData = {event.pull(0.0)}
        local eventType = eventData[1]
        if eventType == "PotRotate" then
            -- Update the target number of items to store based on the target dial being rotated.
            print("PotRotate")
            local anticlockwise = eventData[3]
            HandleTargetDialChange(anticlockwise)
        end
    end
end

function App()
    InitComponents()
    InitStorage()
    PrintStorageStatus()

    -- CoHandleStorage = Thread.create(CoStorage)
    -- CoHandlePanelDisplays = Thread.create(CoPanelDisplays)
    -- CoHandlePanelEvents = Thread.create(CoPanelEvents)
    -- Thread.run()

    CoPanelEvents()
end

App()
