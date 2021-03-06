-- Components
GPU = nil
Containers = nil
Splitter = nil
Panel = nil
BypassButton = nil
TargetDial = nil
FlowLED = nil
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
SpitterOutIndex = 0   -- The index of of the output the splitter last transferred an item to.
PrevFeedbackTime = 0  -- Timestamp (ms) of the most recent update of the UI.

fs = filesystem

function InitComponents()
    GPU = GetGPU()
    NIC = GetNIC()
    Panel = GetComponentByNick(PANEL_NAME)
    BypassButton = GetModuleOnPanel(Panel, BYPASS_BUTTON_POS)
    TargetDial = GetModuleOnPanel(Panel, TARGET_DIAL_POS)
    FlowLED = GetModuleOnPanel(FLOW_LED_POS)
    TextStatusScreen = GetModuleOnPanel(TEXT_STATUS_SCREEN_POS)
    GraphicStatusScreen = GetModuleOnPanel(GRAPHIC_STATUS_SCREEN_POS)
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

    FlowLED:setColor(color[1], color[2], color[3], color[4]);
end

function HandleBypassButtonPush()
    IsBypassed = not IsBypassed
    ValueFileWrite("/primary/data/IsBypassed", IsBypassed)
    OutputFeedback()
end

function HandleTargetDialChange(anticlockwise)
    local change = -TARGET_DIAL_SENSITIVITY
    if (anticlockwise) then
        change = -1 * change
    end

    TargetPercent = Clamp(TargetPercent + change, 0, 100)
    ValueFileWrite("/primary/data/TargetPercentStored", TargetPercent)
    TargetNumStored = ComputeTargetNumStored(TargetPercent)
    OutputFeedback()
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

function OutputFeedback()
    SetFlowLEDStatus()
    DrawText()
    DrawGraphics()
    PrevFeedbackTime = computer.millis()
end

function DrawText()
    if (TextStatusScreen == nil) then
        return
    end

    TextStatusScreen.size = 36
    local lines = {
        " "..ITEM_TYPE.." ("..tonumber(string.format("%.0f", PercentStored)).."%)",
        " = "..NumStored.." / "..StoreSize,
        " > "..TargetNumStored.." ("..TargetPercent.."%)"
    }
    TextStatusScreen.text = table.concat(lines, '\n')
end

function DrawGraphics()
    if (GPU == nil) then
        return
    end

    -- Point the GPU at the screen we want to render to right now.
    GPU:bindScreen(GraphicStatusScreen)

    -- Clear the screen back to black.
    GPU:setBackground(UI_CLEAR_COLOR[1], UI_CLEAR_COLOR[2], UI_CLEAR_COLOR[3], UI_CLEAR_COLOR[4])
    GPU:fill(0, 0, GRAPHIC_STATUS_SCREEN_SIZE["x"], GRAPHIC_STATUS_SCREEN_SIZE["y"], " ", " ")
    GPU:flush()

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

function App()
    RunFile("/primary/app_config.lua", true, "app config")
    print()
    InitComponents()
    InitStorage()
    print("STORAGE STATUS:")
    PrintStorageStatus()
    print()
    print("Starting...")
    print()

    event.listen(BypassButton)
    event.listen(TargetDial)

    while true do
        HandleEvents(MAX_EVENT_HANDLING_RATE)
        ReadInput()
        TransferItems(MAX_ITEM_TRANSFER_RATE)

        -- Poll every so many ms to update the UI (but skip this most of the time)
        if (computer.millis() >= PrevFeedbackTime + FEEDBACK_RATE_MS) then
            OutputFeedback()
        end
    end
end

App()
