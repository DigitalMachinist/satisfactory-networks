-- Components
Containers = nil
Splitter = nil
Panel = nil
BypassButton = nil
TargetDial = nil
FlowLED = nil

-- State
IsBypassed = false      -- Should the entire storage system be bypassed/disabled?
TargetPercent = 100     -- The percentage of the available storage we aim to use.
TargetNumStored = nil   -- The number of stored items we aim to keep (anything beyond this is overflow).
NumStored = nil         -- The current number of stored items.
StoreSize = nil         -- The total size of the storage media.
SpitterOutIndex = 0     -- The index of of the output the splitter last transferred an item to.
fs = filesystem

function LoadConfig(filepath)
    if (fs.exists(filepath) and fs.isFile(filepath)) == false then
        computer.panic("Unable to find app config at "..filepath..".")
    end

    print("Loading app config from "..filepath.."...")
    fs.doFile(filepath)
end

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
    BypassButton = Panel:getModule(BYPASS_BUTTON_POS["x"], BYPASS_BUTTON_POS["y"])
    TargetDial = Panel:getModule(TARGET_DIAL_POS["x"], TARGET_DIAL_POS["y"])
    FlowLED = Panel:getModule(FLOW_LED_POS["x"], FLOW_LED_POS["y"])
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

function ReadValueFile(filepath)
    if (fs.exists(filepath) and fs.isFile(filepath)) then
        local f = fs.open(filepath, "r")
        local value = f:read("*all")
        f:close()

        return value
    end

    return nil
end

function WriteValueFile(filepath, value)
    local exists = fs.exists(filepath)
    if (not exists or (exists and fs.isFile(filepath))) then
        local f = fs.open(filepath, "w")
        f:write(tostring(value))
        f:close()
    end
end

function ComputeTargetNumStored(targetPercent)
    local targetFraction = targetPercent / 100
    return math.floor(targetFraction * StoreSize + 0.5)
end

function InitStorage()
    NumStored, StoreSize = GetContainerUsage()
    IsBypassed = ReadValueFile("/primary/data/IsBypassed") == "true"
    TargetPercent = tonumber(ReadValueFile("/primary/data/TargetPercentStored"))
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

function SetFlowLEDStatus()
    local color = nil
    if (IsBypassed and (NumStored >= TargetNumStored)) then
        color = COLOR_OVERBYPASS
    elseif (NumStored >= TargetNumStored) then
        color = COLOR_FLOWING
    elseif (IsBypassed) then
        color = COLOR_BYPASSED
    else
        color = COLOR_HOLDING
    end

    FlowLED:setColor(color["r"], color["g"], color["b"], color["a"]);
end

function HandleBypassButtonPush()
    IsBypassed = not IsBypassed
    WriteValueFile("/primary/data/IsBypassed", IsBypassed)
end

function HandleTargetDialChange(anticlockwise)
    local change = -TARGET_DIAL_SENSITIVITY
    if (anticlockwise) then
        change = -1 * change
    end

    TargetPercent = Clamp(TargetPercent + change, 0, 100)
    WriteValueFile("/primary/data/TargetPercentStored", TargetPercent)
    TargetNumStored = ComputeTargetNumStored(TargetPercent)
end

function HandleEvents(maxEventsToPop)
    for i = 1, maxEventsToPop do
        local eventData = {event.pull(0)}
        local eventType = eventData[1]
        if eventType == nil then
            -- If no eventType was set, the last event has been popped and we should return to the caller.
            return
        end

        --print("Event: "..eventType)
        if eventType == "Trigger" then
            -- Toggle IsBypassed
            HandleBypassButtonPush()
            print("Bypass updated to "..tostring(IsBypassed))
        elseif eventType == "PotRotate" then
            -- Update the target number of items to store based on the target dial being rotated.
            local anticlockwise = eventData[3]
            HandleTargetDialChange(anticlockwise)
            print("Target updated to "..TargetPercent.." ("..TargetNumStored..")")
        end
    end
end

function ReadInput()
    -- TODO: Maybe only run this occasionally because it could be expensive...
    NumStored, StoreSize = GetContainerUsage()
end

function TransferItems(maxItemsToTransfer)
    for i = 1, maxItemsToTransfer do
        -- If the splitter's input buffer is empty, return immediately.
        if (Splitter:getInput().type == nil) then
            return;
        end

        -- If storage is still filling up to the target and the bypass hasn't been enabled, we don't want to transfer.
        if ((NumStored < TargetNumStored) and not IsBypassed) then
            return
        end

        -- Otherwise transfer (if the storage is at target or bypass is enabled).
        Transfer()
    end
end

function OutputFeedback()
    SetFlowLEDStatus()
end

function App()
    LoadConfig("/primary/app_config.lua")
    print()
    InitComponents()
    InitStorage()
    print("STORAGE STATUS:")
    PrintStorageStatus()
    print()

    event.listen(BypassButton)
    event.listen(TargetDial)

    while true do
        HandleEvents(MAX_EVENT_HANDLING_RATE)
        ReadInput()
        TransferItems(MAX_ITEM_TRANSFER_RATE)
        OutputFeedback()
    end
end

App()
