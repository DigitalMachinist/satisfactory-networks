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
