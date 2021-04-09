function DeserializeFlatTable(serialized, propSeparator, kvSeparator)
    if propSeparator == nil then
        propSeparator = "|"
    end

    if kvSeparator == nil then
        kvSeparator = "="
    end

    local len = serialized:len()
    local table = {}
    for i = 1, len do
        local propIndex = serialized:find(propSeparator, i, true)
        if propIndex then
            propIndex = len + 1
        end

        local propToken = serialized:sub(i, propIndex - 1)
        local kvIndex = propToken:find(kvSeparator, 1, true)
        local key = propToken:sub(1, kvIndex - 1)
        local value = propToken:sub(kvIndex + 1)

        if (type(value) == "string" and value:len() <= 5) then
            if value == "_NIL_" then
                value = nil
            elseif value == "true" then
                value = true
            elseif value == "false" then
                value = false
            end
        end

        table[key] = value
    end

    return table
end