-- Components
GPU = nil
NIC = nil
Controls = {}
ModuleMap = {}
Materials = {}

-- State
PrevFeedbackTime = 0  -- Timestamp (ms) of the most recent update of the UI.

function InitMaterialControls(materialSymbol)
    if not CONTROLS[materialSymbol] then
        computer.panic("Undefined material "..materialSymbol.."!")
    end

    -- Look up the config data about where to find this control.
    local control = CONTROLS[materialSymbol]
    local panel = GetComponentByNick(control["panelName"])

    -- Look up each of the control modules and return them as a table.
    local controls = {
        materialSymbol = materialSymbol,
        panel          = panel,
        textDisplay    = GetModuleOnPanel(panel, Vector2Add(control["anchorPos"], CONTROL_OFFSET_TEXT_DISPLAY), control["panelIndex"]),
        graphicDisplay = GetModuleOnPanel(panel, Vector2Add(control["anchorPos"], CONTROL_OFFSET_GRAPHIC_DISPLAY), control["panelIndex"]),
        bypassButton   = GetModuleOnPanel(panel, Vector2Add(control["anchorPos"], CONTROL_OFFSET_BYPASS_BUTTON), control["panelIndex"]),
        targetDial     = GetModuleOnPanel(panel, Vector2Add(control["anchorPos"], CONTROL_OFFSET_TARGET_DIAL), control["panelIndex"]),
    }

    -- Clear any previous displayed values until new ones are provided by the storage controller.
    if (controls["bypassButton"] ~= nil) then
        controls["bypassButton"]:setColor(COLOR_TIMEOUT[1], COLOR_TIMEOUT[2], COLOR_TIMEOUT[3], COLOR_TIMEOUT[4])
    end
    if (controls["textDisplay"] ~= nil) then
        controls["textDisplay"].text = ""
    end
    if (controls["graphicDisplay"] ~= nil) then
        ClearGraphicDisplay(GPU, graphicDisplay, UI_CLEAR_COLOR, true)
    end

    return controls
end

function InitComponents()
    GPU = GetGPU()
    NIC = GetNIC()

    for materialSymbol, _ in pairs(CONTROLS) do
        -- Map {material symbol} => {controls} so we can look up panel displays for output of storage status from network events.
        local materialControls = InitMaterialControls(materialSymbol)
        Controls[materialSymbol] = materialControls

        -- Also map {panel module hash} => {material symbol} so we can look up the materials being modified by panel module events.
        if (materialControls["bypassButton"] ~= nil) then
            ModuleMap[materialControls["bypassButton"].hash] = materialSymbol
        end
        if (materialControls["targetDial"] ~= nil) then
            ModuleMap[materialControls["targetDial"].hash] = materialSymbol
        end
    end
end

function RegisterListeners()
    for materialSymbol, control in pairs(Controls) do
        local actionPrefix = nil
        local bypassButtonPos = Vector2Add(CONTROLS[materialSymbol]["anchorPos"], CONTROL_OFFSET_BYPASS_BUTTON)
        if Controls[materialSymbol]["bypassButton"] ~= nil then
            event.listen(Controls[materialSymbol]["bypassButton"])
            actionPrefix = "Listening to"
        else
            actionPrefix = "Missing"
        end
        print(actionPrefix.." bypass button at ("..bypassButtonPos["x"]..","..bypassButtonPos["y"]..") on "..CONTROLS[materialSymbol]["panelName"]..":"..CONTROLS[materialSymbol]["panelIndex"].."!")

        local targetDialPos = Vector2Add(CONTROLS[materialSymbol]["anchorPos"], CONTROL_OFFSET_TARGET_DIAL)
        if Controls[materialSymbol]["targetDial"] ~= nil then
            event.listen(Controls[materialSymbol]["targetDial"])
            actionPrefix = "Listening to"
        else
            actionPrefix = "Missing"
        end
        print(actionPrefix.." target dial at ("..targetDialPos["x"]..","..targetDialPos["y"]..") on "..CONTROLS[materialSymbol]["panelName"]..":"..CONTROLS[materialSymbol]["panelIndex"].."!")
    end
end

function IngestStorageStatus(message)
    local materialSymbol = message["material"]
    if (Materials[materialSymbol] == nil) then
        Materials[materialSymbol] = {}
    end

    Materials[materialSymbol]["sender"] = message["sender"]
    Materials[materialSymbol]["timestamp"] = computer.millis()

    -- Only mark the material as dirty if it has actually changed from the last time its status was provided.
    Materials[materialSymbol]["timeout"] = false
    Materials[materialSymbol]["isDirty"] = Materials[materialSymbol]["storeSize"] ~= message["storeSize"]
                                        or Materials[materialSymbol]["numStored"] ~= message["numStored"]
                                        or Materials[materialSymbol]["targetNum"] ~= message["targetNum"]
                                        or Materials[materialSymbol]["isIypassed"] ~= message["isBypassed"]

    Materials[materialSymbol]["symbol"] = message["material"]
    Materials[materialSymbol]["storeSize"] = message["storeSize"]
    Materials[materialSymbol]["numStored"] = message["numStored"]
    Materials[materialSymbol]["targetNum"] = message["targetNum"]
    Materials[materialSymbol]["isBypassed"] = message["isBypassed"]
    Materials[materialSymbol]["percentStored"] = math.floor((100 * message["numStored"] / message["storeSize"]) + 0.5)
    Materials[materialSymbol]["targetPercent"] = math.floor((100 * message["targetNum"] / message["storeSize"]) + 0.5)
end

function HandleNetworkMessage(eventData)
    local sender = eventData[3]
    local port = eventData[4]
    if (port == PORT_PING) then
        -- Handle pings from storage controllers by ingesting their status and registering them.
        -- We also reply directly to the sender so they can register this as their UI controller.
        local ping = ParseStoragePing(eventData)
        print("[RX] PING: "..ping["template"].." from "..sender)

        if (ping["template"] ~= "storage_controller") then
            return
        end

        IngestStorageStatus(ping)
        NIC:send(sender, PORT_PING, UiPong())
        print("[TX] PONG")
    elseif (port == PORT_PONG) then
        -- Handle pings from storage controllers by ingesting their status and registering them.
        local pong = ParseStoragePong(eventData)
        print("[RX] PONG: "..ping["template"].." from "..sender)

        if (pong["template"] ~= "storage_controller") then
            return
        end

        IngestStorageStatus(pong)
    elseif (port == PORT_STORAGE) then
        -- Handle storage status updates
        local message = ParseStorageStatus(eventData)
        print("[RX] MESSAGE: "..message["type"].." from "..sender)

        if (message["type"] == "StorageStatus") then
            -- Handle storage status updates by ingesting the data and updating the UI.
            IngestStorageStatus(message)
        end
    end
end

function HandleBypassButtonPush(materialSymbol)
    local material = Materials[materialSymbol]
    if (material == nil) then
        return
    end

    local newIsBypassed = not material["isBypassed"]
    NIC:send(material["sender"], PORT_STORAGE, UiSetIsBypassed(newIsBypassed))
    print("[TX] STORAGE: SetIsBypassed on "..material["sender"])
end

function HandleTargetDialChange(materialSymbol, anticlockwise)
    local material = Materials[materialSymbol]
    if (material == nil) then
        return
    end

    local change = -TARGET_DIAL_SENSITIVITY
    if (anticlockwise) then
        change = -1 * change
    end

    local targetPercent = math.floor((100 * material["targetNum"] / material["storeSize"]) + 0.5)
    local newTargetPercent = Clamp(material["targetPercent"] + change, 0, 100)
    NIC:send(material["sender"], PORT_STORAGE, UiSetTarget(newTargetPercent))
    print("[TX] STORAGE: SetTarget "..newTargetPercent.." on "..material["sender"])
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
        if eventType == "NetworkMessage" then
            HandleNetworkMessage(eventData)
            return
        end

        local materialSymbol = ModuleMap[eventData[2].hash]
        if eventType == "Trigger" then
            -- Toggle IsBypassed
            if (materialSymbol ~= nil) then
                HandleBypassButtonPush(materialSymbol)
            end
        elseif eventType == "PotRotate" then
            -- Update the target number of items to store based on the target dial being rotated.
            if (materialSymbol ~= nil) then
                local anticlockwise = eventData[3]
                HandleTargetDialChange(materialSymbol, anticlockwise)
            end
        end
    end
end

function SetBypassButtonStatus(materialSymbol)
    if (Controls[materialSymbol] == nil) then
        return
    end

    if (Controls[materialSymbol]["bypassButton"] == nil) then
        return
    end

    if (Materials[materialSymbol] == nil) then
        return
    end

    local button = Controls[materialSymbol]["bypassButton"]
    local timeout = Materials[materialSymbol]["timeout"]
    local isBypassed = Materials[materialSymbol]["isBypassed"]
    local numStored = Materials[materialSymbol]["numStored"]
    local targetNumStored = Materials[materialSymbol]["targetNum"]

    local color = nil
    if timeout then
        color = COLOR_TIMEOUT
    elseif (isBypassed and (numStored >= targetNumStored)) then
        color = COLOR_OVERBYPASS
    elseif (numStored >= targetNumStored) then
        color = COLOR_FLOWING
    elseif (isBypassed) then
        color = COLOR_BYPASSED
    else
        color = COLOR_HOLDING
    end

    button:setColor(color[1], color[2], color[3], color[4]);
end

function DrawText(materialSymbol)
    if (Materials[materialSymbol] == nil) then
        return
    end

    local textDisplay = Controls[materialSymbol]["textDisplay"]
    if (textDisplay == nil) then
        return
    end

    local timeoutNotice = ""
    if Materials[materialSymbol]["timeout"] then
        timeoutNotice = "    [D/C]"
    end

    local lines = {
        " "..materialSymbol.." ("..tonumber(string.format("%.0f", Materials[materialSymbol]["percentStored"])).."%)"..timeoutNotice,
        " = "..Materials[materialSymbol]["numStored"].." / "..Materials[materialSymbol]["storeSize"],
        " > "..Materials[materialSymbol]["targetNum"].." ("..Materials[materialSymbol]["targetPercent"].."%)"
    }

    textDisplay.size = 36
    textDisplay.text = table.concat(lines, '\n')
end

function DrawGraphics(materialSymbol)
    if (GPU == nil) then
        return
    end

    local graphicDisplay = Controls[materialSymbol]["graphicDisplay"]
    if (graphicDisplay == nil) then
        return
    end

    -- Clear the screen back to black (this also binds the display to the GPU so we don't need to do that).
    ClearGraphicDisplay(GPU, graphicDisplay, UI_CLEAR_COLOR, false)

    -- Draw fill meter.
    local x = 0
    local y = math.floor(UI_MODULE_SCREEN_SIZE["y"] / 4)
    local w = UI_MODULE_SCREEN_SIZE["x"]
    local h = UI_MODULE_SCREEN_SIZE["y"] / 2
    local storedFraction = Materials[materialSymbol]["percentStored"] / 100
    local targetFraction = Materials[materialSymbol]["targetPercent"] / 100
    local targetThickness = 1
    local borderPadding = 2
    ProgressBar(
        GPU,
        storedFraction, x, y, w, h, UI_METER_BG_COLOR, UI_METER_FG_COLOR,  -- Progress
        borderPadding, UI_METER_BORDER_COLOR,                              -- Border
        targetFraction, targetThickness, UI_METER_TARGET_COLOR             -- Target
    )

    GPU:flush()
end

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
