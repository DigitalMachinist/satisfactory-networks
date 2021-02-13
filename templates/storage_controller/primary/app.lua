-- The type of item stored in this storage system.
ITEM_TYPE = "Concrete"

-- The expected max stack size for items in this storage system.
ITEM_STACK_SIZE = 500

-- All containers should use this nickname on the network.
CONTAINER_NAME = "Container"

-- The splitter should use this nickname on the network.
SPLITTER_NAME = "Splitter"
SPLITTER_OUTPUT = SPLITTER_OUTPUT_CENTER

-- The control panel should use this nickname on the network.
PANEL_NAME = "Panel"

-- The target dial's position on the panel (from the bottom-left).
TARGET_DIAL_POS = { x = 1, y = 0 }

-- State
TargetPercent = 100     --
TargetDial = nil
Components = nil
Splitter = nil
Panel = nil
OutputIndex = 0         -- The index of of the output the splitter last transferred an item to.

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

function GetTargetDial(panel, x, y)
    return panel:getModule(x, y)
end

function InitComponents()
    Containers = GetContainers(CONTAINER_NAME)
    Splitter = GetSplitter(SPLITTER_NAME)
    Panel = GetPanel(PANEL_NAME)
    GetTargetDial(Panel, TARGET_DIAL_POS["x"], TARGET_DIAL_POS["y"])
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

function App()
    InitComponents()

    local numStoredItems, storeSize = GetContainerUsage()
    local fraction = numStoredItems / storeSize
    local percent = fraction * 100

    local targetSensitivity = 1.0

    local targetPercent = 80
    local targetFraction = targetPercent / 100
    local targetNumStoredItems = math.floor(targetFraction * storeSize + 0.5)

    print("Usage: "..numStoredItems.." / "..storeSize)
    print("Percent: "..tonumber(string.format("%.0f", percent)).."%")
    print("Target Usage: "..targetNumStoredItems.." / "..storeSize)
    print("Target Percent: "..tonumber(string.format("%.0f", targetPercent)).."%")
end

App()



-- Transfer an item to any free output.
-- If the current output belt is blocked, try until one works or all fail.
-- This method should ensure maximum throughput since it will try all 3 outputs before the next Lua step.
function Transfer()
    for i = 1, SPLITTER_NUM_OUTPUTS do
        OutputIndex = math.fmod(OutputIndex + 1, 3)
        local transferred = Splitter:transferItem(OutputIndex)
        if Splitter:transferItem(OutputIndex) then
            break
        end
    end
end

-- Main Controller
function Component()
    FindComponents()

    event.listen(Splitter)

    while true do
        IsEnabled = Toggle:getState()
        if IsEnabled then
            -- If the splitter has items already sitting in its input queue, transfer them first.
            -- This will ensure that we start getting input events for new items entering the splitter's input queue.
            if next(Splitter:getMembers()) then
                Transfer()
            end

            -- Transfer an item for each ItemRequest event receives from the splitter, until we disable it.
            local e = event.pull(1)
            if e == "ItemRequest" then
                Transfer()
            end
        else
            -- Prevent "out of time" error for infinite loop timeout.
            computer.skip()
        end
    end
end