function ValueFileWrite(filepath, value)
    local exists = fs.exists(filepath)
    if (not exists or (exists and fs.isFile(filepath))) then
        local f = fs.open(filepath, "w")
        f:write(tostring(value))
        f:close()
    end
end
