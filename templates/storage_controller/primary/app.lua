-- Components
GPU = nil
NIC = nil
Containers = nil
Splitter = nil
Panel = nil
BypassButton = nil
TargetDial = nil
TextStatusScreen = nil
GraphicStatusScreen = nil

-- State
IsBypassed = false    -- Should the entire storage system be bypassed/disabled?
TargetPercent = 100   -- The percentage of the available storage we aim to use.
TargetNumStored = nil -- The number of stored items we aim to keep (anything beyond this is overflow).
FractionStored = nil  -- The fraction of available storage that is filled with items [0, 1].
PercentStored = nil   -- The percentage of available storage that is filled with items [0, 100].
NumStored = nil       -- The current number of stored items [0, +inf].
StoreSize = nil       -- The total size of the storage media [0, +inf].
SplitterOutIndex = 0  -- The index of of the output the splitter last transferred an item to.
PrevFeedbackTime = 0  -- Timestamp (ms) of the most recent update of the UI.
NetworkUI = nil       -- Address of the network UI that will be handling I/O for this storage system.
mp = MessagePack()

function InitComponents()
    GPU = GetGPU(false)
    NIC = GetNIC(false)
    Containers = GetComponentsByNick(CONTAINER_NAME)
    Splitter = GetComponentByNick(SPLITTER_NAME)
    Panel = GetComponentByNick(PANEL_NAME)
    BypassButton = GetModuleOnPanel(Panel, BYPASS_BUTTON_POS)
    TargetDial = GetModuleOnPanel(Panel, TARGET_DIAL_POS)
    TextStatusScreen = GetModuleOnPanel(Panel, TEXT_STATUS_SCREEN_POS)
    GraphicStatusScreen = GetModuleOnPanel(Panel, GRAPHIC_STATUS_SCREEN_POS)
end

function GetContainerUsage()
    local totalSize = 0;
    local totalUsed = 0;
    local materialStackSize = MATERIALS[MATERIAL_SYMBOL]["stackSize"]
    for _, container in pairs(Containers) do
        for _, inventory in pairs(container:getInventories()) do
            totalSize = totalSize + inventory.size * materialStackSize
            totalUsed = totalUsed + inventory.itemCount
        end
    end

    return totalUsed, totalSize
end

function ComputeTargetNumStored(targetPercent)
    local targetFraction = targetPercent / 100
    return math.floor(targetFraction * StoreSize + 0.5)
end

function InitStorage()
    NumStored, StoreSize = GetContainerUsage()
    IsBypassed = ValueFileRead("/primary/data/IsBypassed") == "true"
    TargetPercent = tonumber(ValueFileRead("/primary/data/TargetPercentStored"))
    TargetNumStored = ComputeTargetNumStored(TargetPercent)
end

function GetStatus()
    return {
        material   = MATERIAL_SYMBOL,
        storeSize  = StoreSize,
        numStored  = NumStored,
        targetNum  = TargetNumStored,
        isBypassed = IsBypassed
    }
end

function InitNetworkUI()
    if (NIC == nil) then
        return
    end

    -- Before we know exactly who to contact, we'll ping and wait for a response from the appropriate controller.
    -- Note: We'll set NetworkUI with the response sender's address and use that from that point forward.
    NIC:broadcast(PORT_PING, mp.pack({
        template = "storage_controller",
        data = GetStatus()
    }))
end

function PrintStorageStatus()
    FractionStored = NumStored / StoreSize
    PercentStored = FractionStored * 100
    print("Material: "..MATERIAL_SYMBOL.. " ("..MATERIALS[MATERIAL_SYMBOL]["name"]..")")
    print("Usage: "..NumStored.." / "..StoreSize)
    print("Percent: "..tonumber(string.format("%.0f", PercentStored)).."%")
    print("Target Usage: "..TargetNumStored.." / "..StoreSize)
    print("Target Percent: "..tonumber(string.format("%.0f", TargetPercent)).."%")
end

-- Transfer an item to any free output.
-- If the current output belt is blocked, try until one works or all fail.
-- This method should ensure maximum throughput since it will try all 3 outputs before the next Lua step.
function Transfer()
    for i = 1, SPLITTER_NUM_OUTPUTS do
        SplitterOutIndex = math.fmod(SplitterOutIndex + 1, SPLITTER_NUM_OUTPUTS)
        if Splitter:transferItem(SplitterOutIndex) then
            break
        end
    end
end


function SetIsBypassed(newIsBypassed)
    IsBypassed = newIsBypassed
    ValueFileWrite("/primary/data/IsBypassed", IsBypassed)
    OutputFeedback()
end

function HandleBypassButtonPush()
    SetIsBypassed(not IsBypassed)
end

function SetTargetPercent(newTargetPercent)
    TargetPercent = Clamp(newTargetPercent, 0, 100)
    ValueFileWrite("/primary/data/TargetPercentStored", TargetPercent)
    TargetNumStored = ComputeTargetNumStored(TargetPercent)
    OutputFeedback()
end

function HandleTargetDialChange(anticlockwise)
    local change = -TARGET_DIAL_SENSITIVITY
    if (anticlockwise) then
        change = -1 * change
    end

    SetTargetPercent(TargetPercent + change)
end

function HandleNetworkMessage(eventData)
    local sender = eventData[3]
    local port = eventData[4]
    local message = mp.unpack(eventData[5])
    if (port == PORT_PING) then
        print("Ping message received")
        -- If a ping response is received, store the sender's address so we can message the UI controller directly from now on.
        -- Note: But only if the sender's template is set to ui_controller (so we ignore other storage_controller pings).
        if (message["template"] == "ui_controller") then
            NetworkUI = sender
        end
    elseif (port == PORT_STORAGE) then
        print("Storage message received")
        -- If a storage control signal is received, it *must* come from the registered UI controller to be considered valid.
        if (sender ~= NetworkUI) then
            return
        end

        if (message["type"] == "SetIsBypassed") then
            -- SetIsBypassed Handler
            -- Example: {
            --     type = "SetIsBypassed",
            --     data = true   
            -- }
            SetIsBypassed(message["data"])
            print("Bypass updated to "..tostring(IsBypassed))
        elseif (message["type"] == "SetTargetPercent") then
            -- SetTarget Handler
            -- Example: {
            --     type = "SetTargetPercent",
            --     data = 85   
            -- }
            SetTargetPercent(message["data"])
            print("Target updated to "..TargetPercent.." ("..TargetNumStored..")")
        end
    end
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
            -- Toggle IsBypassed when the bypass button is pressed.
            HandleBypassButtonPush()
            print("Bypass updated to "..tostring(IsBypassed))
        elseif eventType == "PotRotate" then
            -- Update the target number of items to store based on the target dial being rotated.
            local anticlockwise = eventData[3]
            HandleTargetDialChange(anticlockwise)
            print("Target updated to "..TargetPercent.." ("..TargetNumStored..")")
        elseif eventType == "NetworkMessage" then
            HandleNetworkMessage(eventData)
        end
    end
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

function SetBypassButtonStatus()
    if (BypassButton == nil) then
        return
    end

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

    BypassButton:setColor(color[1], color[2], color[3], color[4]);
end

function DrawText()
    if (TextStatusScreen == nil) then
        return
    end

    TextStatusScreen.size = 36
    local lines = {
        " "..MATERIAL_SYMBOL.." ("..tonumber(string.format("%.0f", PercentStored)).."%)",
        " = "..NumStored.." / "..StoreSize,
        " > "..TargetNumStored.." ("..TargetPercent.."%)"
    }
    TextStatusScreen.text = table.concat(lines, '\n')
end

function DrawGraphics()
    if (GPU == nil) then
        return
    end

    if (GraphicStatusScreen == nil) then
        return
    end

    -- Point the GPU at the screen we want to render to right now.
    GPU:bindScreen(GraphicStatusScreen)

    -- Clear the screen back to black.
    GPU:setBackground(UI_CLEAR_COLOR[1], UI_CLEAR_COLOR[2], UI_CLEAR_COLOR[3], UI_CLEAR_COLOR[4])
    GPU:fill(0, 0, GRAPHIC_STATUS_SCREEN_SIZE["x"], GRAPHIC_STATUS_SCREEN_SIZE["y"], " ", " ")
    -- GPU:flush()

    -- Draw fill meter.
    local x = 0
    local y = math.floor(GRAPHIC_STATUS_SCREEN_SIZE["y"] / 4)
    local w = GRAPHIC_STATUS_SCREEN_SIZE["x"]
    local h = GRAPHIC_STATUS_SCREEN_SIZE["y"] / 2
    local targetFraction = TargetPercent / 100
    local targetThickness = 1
    local borderPadding = 2
    ProgressBar(
        GPU,
        FractionStored, x, y, w, h, UI_METER_BG_COLOR, UI_METER_FG_COLOR,  -- Progress
        borderPadding, UI_METER_BORDER_COLOR,                              -- Border
        targetFraction, targetThickness, UI_METER_TARGET_COLOR             -- Target
    )

    GPU:flush()
end

function NetworkSendStatus()
    if (NIC == nil) then
        return
    end

    if (NetworkUI == nil) then
        return
    end

    NIC:send(NetworkUI, PORT_STORAGE, mp.pack({
        type = "status",
        data = GetStatus()
    }))
end

function OutputFeedback()
    SetBypassButtonStatus()
    DrawText()
    DrawGraphics()
    NetworkSendStatus()
    PrevFeedbackTime = computer.millis()
end

function App()
    RunFile("/primary/app_config.lua", true, "app config")
    IsBypassed = ValueFileRead("/primary/IsBypassed")
    TargetPercent = ValueFileRead("primary/TargetPercentStored")
    print()
    InitComponents()
    InitStorage()
    print("STORAGE STATUS:")
    PrintStorageStatus()
    print()
    print("Starting...")
    print()

    if (BypassButton) then
        event.listen(BypassButton)
    end

    if (TargetDial) then
        event.listen(TargetDial)
    end

    if (NIC) then
        NIC:open(PORT_PING)
        NIC:open(PORT_STORAGE)
        event.listen(NIC)
        InitNetworkUI()
    end

    while true do
        HandleEvents(MAX_EVENT_HANDLING_RATE)
        NumStored, StoreSize = GetContainerUsage()
        TransferItems(MAX_ITEM_TRANSFER_RATE)

        -- Poll every so many ms to update the UI (but skip this most of the time)
        if (computer.millis() >= PrevFeedbackTime + FEEDBACK_RATE_MS) then
            OutputFeedback()
            -- print("Tick "..computer.millis())
        end
    end
end

App()
