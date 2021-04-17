function DetectTimeouts()
    for materialSymbol, _ in pairs(Materials) do
        Materials[materialSymbol]["timeout"] = Materials[materialSymbol]["timestamp"] < (computer.millis() - TIMEOUT_PERIOD_MS)
    end
end
