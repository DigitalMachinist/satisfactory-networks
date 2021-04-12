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
