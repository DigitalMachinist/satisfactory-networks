function MergeTables(t1, t2)
    local t3 = {}
    for key, value in pairs(t1) do
        t3[key] = value
    end
    for key, value in pairs(t2) do
        t3[key] = value
    end

    return t3
end