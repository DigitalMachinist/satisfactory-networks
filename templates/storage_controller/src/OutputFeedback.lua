function OutputFeedback()
    SetBypassButtonStatus()
    DrawText()
    DrawGraphics()
    NetworkSendStatus()
    PrevFeedbackTime = computer.millis()
end
