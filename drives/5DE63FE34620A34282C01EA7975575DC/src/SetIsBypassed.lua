function SetIsBypassed(newIsBypassed)
    IsBypassed = newIsBypassed
    ValueFileWrite("/primary/data/IsBypassed", IsBypassed)
    OutputFeedback()
end
