function RunFile(filepath, isCritical, description)
    if (description == nil) then
        description = ""
    end

    if (isCritical and (not fs.exists(filepath) or not fs.isFile(filepath))) then
        computer.panic("Unable to find "..description.." at "..filepath..".")
    end

    print("Running "..description.." at "..filepath.."...")
    fs.doFile(filepath)
end