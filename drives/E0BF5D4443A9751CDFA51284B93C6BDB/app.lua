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

function App()
    RunFile("/primary/app_config.lua", true, "app config")
    RunFile("/primary/env_config.lua", true, "env config")
    LoadLibrariesRecursive("/primary/src")
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

    if BypassButton then
        event.listen(BypassButton)
    end

    if TargetDial then
        event.listen(TargetDial)
    end

    if NIC then
        NIC:open(PORT_PING)
        NIC:open(PORT_STORAGE)
        event.listen(NIC)
    end

    FlushEventQueue(MAX_EVENT_HANDLING_RATE)

    if NIC then
        NIC:broadcast(PORT_PING, StoragePing())
    end

    while true do
        HandleEvents(MAX_EVENT_HANDLING_RATE)
        NumStored, StoreSize = GetContainerUsage()
        TransferItems(MAX_ITEM_TRANSFER_RATE)

        -- Poll every so many ms to update the UI (but skip this most of the time)
        if (computer.millis() >= PrevFeedbackTime + FEEDBACK_RATE_MS) then
            OutputFeedback()
        end
    end
end

App()
