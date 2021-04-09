function SerializeFlatTable(table, propSeparator, kvSeparator)
    if propSeparator == nil then
        propSeparator = "|"
    end

    if kvSeparator == nil then
        kvSeparator = "="
    end

    local serialized = "";
    for key, value in pairs(table) do
        if value == nil then
            value = "_NIL_"
        elseif type(value) == 'boolean' then
            if value then
                value = "true"
            else
                value = "false"
            end
        end

        serialized = serialized..key..kvSeparator..value..propSeparator
    end

    return serialized:sub(0, -2)
end