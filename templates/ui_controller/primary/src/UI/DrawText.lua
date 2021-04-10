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
