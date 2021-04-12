-- Components
GPU = nil
NIC = nil
Controls = {}
ModuleMap = {}
Materials = {}

-- State
PrevFeedbackTime = 0  -- Timestamp (ms) of the most recent update of the UI.

function DetectTimeouts()
    for materialSymbol, _ in pairs(Materials) do
        Materials[materialSymbol]["timeout"] = Materials[materialSymbol]["timestamp"] < (computer.millis() - TIMEOUT_PERIOD_MS)
    end
end

function OutputFeedback(force)
    if force == nil then
        force = true
    end

    for materialSymbol, _ in pairs(Materials) do
        if (force or Materials[materialSymbol]["isDirty"]) then
            SetBypassButtonStatus(materialSymbol)
            DrawText(materialSymbol)
            DrawGraphics(materialSymbol)
        end
    end

    PrevFeedbackTime = computer.millis()
end

function App()
    RunFile("/primary/app_config.lua", true, "app config")
    RunFile("/primary/env_config.lua", true, "env config")
    LoadLibrariesRecursive("/primary/src")
    print()
    InitComponents()
    print()
    print("Starting...")
    print()
    RegisterListeners()

    NIC:open(PORT_PING)
    NIC:open(PORT_STORAGE)
    event.listen(NIC)

    FlushEventQueue(MAX_EVENT_HANDLING_RATE)

    NIC:broadcast(PORT_PING, UiPing())

    while true do
        HandleEvents(MAX_EVENT_HANDLING_RATE)

        -- Poll every so many ms to force update the UI (but skip this most of the time)
        -- However, try to soft-update any materials that are dirty on every pass.
        if (computer.millis() >= PrevFeedbackTime + FEEDBACK_RATE_MS) then
            DetectTimeouts()
            OutputFeedback(true)
        -- else
        --     OutputFeedback(false)
        end
    end
end

App()
