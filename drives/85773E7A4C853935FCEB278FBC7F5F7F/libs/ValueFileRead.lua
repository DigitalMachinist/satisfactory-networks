function ValueFileRead(filepath)
    if (fs.exists(filepath) and fs.isFile(filepath)) then
        local f = fs.open(filepath, "r")
        local value = f:read("*all")
        f:close()

        return value
    end

    return nil
end
