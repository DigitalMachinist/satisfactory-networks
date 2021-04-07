-- Components
GPU = nil
NIC = nil
Controls = {}
ModuleMap = {}
Materials = {}

-- State
PrevFeedbackTime = 0  -- Timestamp (ms) of the most recent update of the UI.
mp = MessagePack()

function InitMaterialControls(materialSymbol)
    if not CONTROLS[materialSymbol] then
        computer.panic("Undefined material "..materialSymbol.."!")
    end

    -- Look up the config data about where to find this control.
    local control = CONTROLS[materialSymbol]
    local panel = GetComponentByNick(control["panelName"])

    -- Look up each of the control modules and return them as a table.
    return {
        materialSymbol = materialSymbol,
        panel          = panel,
        textDisplay    = GetModuleOnPanel(panel, Vector2Add(control["anchorPos"], CONTROL_OFFSET_TEXT_DISPLAY), control["panelIndex"]),
        graphicDisplay = GetModuleOnPanel(panel, Vector2Add(control["anchorPos"], CONTROL_OFFSET_GRAPHIC_DISPLAY), control["panelIndex"]),
        bypassButton   = GetModuleOnPanel(panel, Vector2Add(control["anchorPos"], CONTROL_OFFSET_BYPASS_BUTTON), control["panelIndex"]),
        targetDial     = GetModuleOnPanel(panel, Vector2Add(control["anchorPos"], CONTROL_OFFSET_TARGET_DIAL), control["panelIndex"]),
    }
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
        local bypassButton = control["bypassButton"]
        local bypassButtonPos = Vector2Add(CONTROLS[materialSymbol]["anchorPos"], CONTROL_OFFSET_BYPASS_BUTTON)
        if bypassButton then
            event.listen(bypassButton)
            actionPrefix = "Listening to"
        else
            actionPrefix = "Missing"
        end
        print(actionPrefix.." bypass button at ("..bypassButtonPos["x"]..","..bypassButtonPos["y"]..") on "..CONTROLS[materialSymbol]["panelName"]..":"..CONTROLS[materialSymbol]["panelIndex"].."!")

        local targetDial = control["targetDial"]
        local targetDialPos = Vector2Add(CONTROLS[materialSymbol]["anchorPos"], CONTROL_OFFSET_TARGET_DIAL)
        if targetDial then
            event.listen(targetDial)
            actionPrefix = "Listening to"
        else
            actionPrefix = "Missing"
        end
        print(actionPrefix.." target dial at ("..targetDialPos["x"]..","..targetDialPos["y"]..") on "..CONTROLS[materialSymbol]["panelName"]..":"..CONTROLS[materialSymbol]["panelIndex"].."!")
    end
end

function HandleBypassButtonPush(materialSymbol)
    if (Materials[materialSymbol] == nil) then
        return
    end

    NIC:send(
        Materials[materialSymbol]["sender"],
        PORT_STORAGE,
        mp.pack({
            type = "SetIsBypassed",
            data = not Materials[materialSymbol]['IsBypassed'])
        })
    )
end

function HandleTargetDialChange(materialSymbol, anticlockwise)
    if (Materials[materialSymbol] == nil) then
        return
    end

    local change = -TARGET_DIAL_SENSITIVITY
    if (anticlockwise) then
        change = -1 * change
    end

    local targetPercent = math.floor((100 * Materials[materialSymbol]["targetNum"] / Materials[materialSymbol]["storeSize"]) + 0.5)

    NIC:send(
        Materials[materialSymbol]["sender"],
        PORT_STORAGE,
        mp.pack({
            type = "SetTargetPercent",
            data = Clamp(Materials[materialSymbol]["targetPercent"] + change, 0, 100))
        })
    )
end

function IngestStorageStatus(messageData)
    local materialSymbol = messageData["material"]
    if (Materials[materialSymbol] == nil) then
        Materials[materialSymbol] = {}
    end

    -- Only mark the material as dirty if it has actually changed from the last time its status was provided.
    Materials[materialSymbol]["timeout"] = false
    Materials[materialSymbol]["isDirty"] = Materials[materialSymbol]["storeSize"] ~= messageData["storeSize"]
                                        or Materials[materialSymbol]["numStored"] ~= messageData["numStored"]
                                        or Materials[materialSymbol]["targetNum"] ~= messageData["targetNum"]
                                        or Materials[materialSymbol]["isIypassed"] ~= messageData["isBypassed"]

    Materials[materialSymbol]["symbol"] = messageData["material"]
    Materials[materialSymbol]["storeSize"] = messageData["storeSize"]
    Materials[materialSymbol]["numStored"] = messageData["numStored"]
    Materials[materialSymbol]["targetNum"] = messageData["targetNum"]
    Materials[materialSymbol]["isBypassed"] = messageData["isBypassed"]
    Materials[materialSymbol]["percentStored"] = math.floor((100 * messageData["numStored"] / messageData["storeSize"]) + 0.5)
    Materials[materialSymbol]["targetPercent"] = math.floor((100 * messageData["targetNum"] / messageData["storeSize"]) + 0.5)
    Materials[materialSymbol]["timestamp"] = computer.millis()
end

function HandleNetworkMessage(eventData)
    local sender = eventData[3]
    local port = eventData[4]
    local message = mp.unpack(eventData[5])
    if (port == PORT_PING) then
        print("Ping message received")
        -- Ingest the storage controller status contained in the message and reply so the storage controller
        -- can register this UI controller as its network UI endpoint. We'll also store the sender so we can
        -- conveniently push control events to them later.
        if (message["template"] == "storage_controller") then
            IngestStorageStatus(message["data"])
            local materialSymbol = message["data"]["material"]
            Materials[materialSymbol]["sender"] = sender
            NIC:send(sender, PORT_PING, mp.pack({
                template = "ui_controller"
            }))
        end
    elseif (port == PORT_STORAGE) then
        print("Storage message received")
        -- Ingest the storage controller status contained in the message.
        IngestStorageStatus(message["data"])
        local materialSymbol = message["data"]["material"]
        Materials[materialSymbol]["sender"] = sender
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
            -- Toggle IsBypassed
            local materialSymbol = ModuleMap[eventData[2]]
            if (materialSymbol ~= nil) then
                HandleBypassButtonPush(materialSymbol)
                print("Bypass updated to "..tostring(IsBypassed))
            end
        elseif eventType == "PotRotate" then
            -- Update the target number of items to store based on the target dial being rotated.
            local materialSymbol = ModuleMap[eventData[2]]
            if (materialSymbol ~= nil) then
                local anticlockwise = eventData[3]
                HandleTargetDialChange(materialSymbol, anticlockwise)
                print("Target updated to "..TargetPercent.." ("..TargetNumStored..")")
            end
        elseif eventType == "NetworkMessage" then
            HandleNetworkMessage(eventData)
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
    local targetNumStored = Materials[materialSymbol]["targetNumStored"]

    local color = nil
    if timeout then
        color = COLOR_TIMEOUT
    elseif (isBypassed and (numStored >= targetNumStored)) then
        color = COLOR_OVERBYPASS
    elseif (NumStored >= targetNumStored) then
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
        timeoutNotice = " D/Ced"
    end

    local lines = {
        " "..materialSymbol.." ("..tonumber(string.format("%.0f", Materials[materialSymbol]["percentStored"])).."%)"..timeoutNotice,
        " = "..Materials[materialSymbol]["numStored"].." / "..Materials[materialSymbol]["storeSize"],
        " > "..Materials[materialSymbol]["targetNum"].." ("..Materials[materialSymbol]["targetPercent"].."%)"
    }

    textDisplay.size = 36
    testDisplay.setMonospace(false)
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

    -- Point the GPU at the screen we want to render to right now.
    GPU:bindScreen(graphicDisplay)

    -- Clear the screen back to black.
    GPU:setBackground(UI_CLEAR_COLOR[1], UI_CLEAR_COLOR[2], UI_CLEAR_COLOR[3], UI_CLEAR_COLOR[4])
    GPU:fill(0, 0, GRAPHIC_STATUS_SCREEN_SIZE["x"], GRAPHIC_STATUS_SCREEN_SIZE["y"], " ", " ")
    -- GPU:flush() 

    -- Draw fill meter.
    local x = 0
    local y = math.floor(GRAPHIC_STATUS_SCREEN_SIZE["y"] / 4)
    local w = GRAPHIC_STATUS_SCREEN_SIZE["x"]
    local h = GRAPHIC_STATUS_SCREEN_SIZE["y"] / 2
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
    print()
    InitComponents()
    print()
    print("Starting...")
    print()
    RegisterListeners()

    NIC:open(PORT_PING)
    NIC:open(PORT_STORAGE)
    event.listen(NIC)

    while true do
        HandleEvents(MAX_EVENT_HANDLING_RATE)

        -- Poll every so many ms to force update the UI (but skip this most of the time)
        -- However, try to soft-update any materials that are dirty on every pass.
        if (computer.millis() >= PrevFeedbackTime + FEEDBACK_RATE_MS) then
            DetectTimeouts()
            OutputFeedback(true)
        else
            OutputFeedback(false)
        end
    end
end

App()
