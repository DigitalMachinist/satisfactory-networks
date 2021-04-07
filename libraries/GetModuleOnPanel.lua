function GetModuleOnPanel(panel, position, panelIndex)
    if (string.find(panel.internalName, "^LargeVerticalControlPanel") ~= nil) then
        return panel:getModule(position["x"], position["y"], panelIndex)
    else
        return panel:getModule(position["x"], position["y"])
    end
end
