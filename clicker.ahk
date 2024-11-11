#Requires AutoHotkey v2.0

clicking := false
holdingS := false
moveMouse := true
position := 0
centerX := 0
mouseSpeed := 200
clickDelay := 1000

darkBg := "1E1E1E"
darkButton := "333333"
textColor := "FFFFFF"
accentColor := "007ACC"

myGui := Gui("+AlwaysOnTop -Caption -DPIScale")
myGui.BackColor := darkBg
myGui.SetFont("s10", "Segoe UI")

class CustomToggle {
    __New(gui, x, y, w, h, text, defaultState := false) {
        this.state := defaultState
        this.text := text
        
        this.button := gui.Add("Text", 
            Format("x{1} y{2} w{3} h{4} Center 0x200 Background{5} c{6}", 
                x, y, w, h, 
                darkButton, textColor),
            text . ": " . (defaultState ? "ON" : "OFF"))
        
        this.button.OnEvent("Click", this.Toggle.Bind(this))
    }
    
    Toggle(*) {
        this.state := !this.state
        this.button.Value := this.text . ": " . (this.state ? "ON" : "OFF")
        return this.state
    }
    
    SetState(state) {
        if (this.state != state) {
            this.Toggle()
        }
    }
}

buttonWidth := 145
spacing := 10
guiWidth := 320
column1X := spacing
column2X := guiWidth/2 + spacing/2

titleBar := myGui.Add("Text", Format("x0 y0 w{1} h30 Background{2}", guiWidth, darkBg))
statusText := myGui.Add("Text", Format("x0 y0 w{1} h30 Center 0x200 c{2}", guiWidth, textColor), "made by sin <3")
statusText.SetFont("s10")

closeButton := myGui.Add("Text", Format("x{1} y0 w40 h30 Center 0x200 Background{2} c{3}", 
    guiWidth - 40, darkBg, textColor), "×")
closeButton.SetFont("s10")

actionButton := myGui.Add("Text", Format("x{1} y40 w{2} h30 Center 0x200 Background{3} c{4}", 
    column1X, buttonWidth, darkButton, textColor), "Start")

autoClickToggle := CustomToggle(myGui, column1X, 80, buttonWidth, 30, "Autoclicker", false)

delayDisplay := myGui.Add("Text", Format("x{1} y120 w{2} h30 Center 0x200 Background{3} c{4}",
    column1X, buttonWidth, darkButton, textColor), "Click Delay: 1000ms")

githubButton := myGui.Add("Text", Format("x{1} y40 w{2} h30 Center 0x200 Background{3} c{4}",
    column2X, buttonWidth, darkButton, textColor), "Github")

moveMouseToggle := CustomToggle(myGui, column2X, 80, buttonWidth, 30, "Move Mouse", false)

holdSToggle := CustomToggle(myGui, column2X, 120, buttonWidth, 30, "Move Backwards", false)

exitText := myGui.Add("Text", Format("x10 y160 w{1} h30 Center 0x200 c{2}", 
    guiWidth - 20, textColor), "Press F7 to exit")

titleBar.OnEvent("Click", (*) => SendMessage(0xA1, 2))
statusText.OnEvent("Click", (*) => SendMessage(0xA1, 2))

actionButton.OnEvent("Click", ToggleScript)
delayDisplay.OnEvent("Click", ShowInputBox)
githubButton.OnEvent("Click", OpenGithub)

OpenGithub(*) {
    Run("https://github.com/sinnayuh/clicker")
}

ShowInputBox(*) {
    global delayDisplay, clicking, clickDelay, darkBg, darkButton, textColor
    if (!clicking) {
        inputGui := Gui("+ToolWindow +AlwaysOnTop -Caption")
        inputGui.BackColor := darkBg
        inputGui.SetFont("s10", "Segoe UI")
        
        input := inputGui.Add("Edit", "w120 h25 Center Number Background" darkButton " c" textColor, clickDelay)
        okButton := inputGui.Add("Text", "x10 y+5 w55 h25 Center 0x200 Background" darkButton " c" textColor, "OK")
        cancelButton := inputGui.Add("Text", "x+10 w55 h25 Center 0x200 Background" darkButton " c" textColor, "Cancel")
        
        okButton.OnEvent("Click", ProcessInput)
        cancelButton.OnEvent("Click", (*) => inputGui.Destroy())
        
        CoordMode("Mouse", "Screen")
        MouseGetPos(&mouseX, &mouseY)
        inputGui.Show(Format("x{1} y{2} w140 h65", mouseX, mouseY))
        
        ProcessInput(*) {
            newDelay := Integer(input.Value)
            if (newDelay > 0) {
                clickDelay := newDelay
                delayDisplay.Value := "Click Delay: " newDelay "ms"
            }
            inputGui.Destroy()
        }
    }
}

myGui.Show(Format("w{1} h200", guiWidth))

ToggleScript(*) {
    global clicking
    if (!clicking) {
        StartScript()
    } else {
        StopScript()
    }
}

StartScript(*) {
    global clicking, centerX, clickDelay
    if !clicking {
        MouseGetPos(&centerX)
        clicking := true
        UpdateTimers()
        
        SoundBeep(750, 500)
        actionButton.Value := "Stop"
        actionButton.Opt("Background" darkButton)
        statusText.Value := "made by sin <3"
        ToolTip("Script: ON")
    }
}

StopScript(*) {
    global clicking
    if clicking {
        clicking := false
        SetTimer(AutoClick, 0)
        SetTimer(MoveMousePattern, 0)
        
        if (holdSToggle.state) {
            SetTimer(PressS, 0)
            Send("{s up}")
        }
        
        SoundBeep(500, 500)
        actionButton.Value := "Start"
        actionButton.Opt("Background" darkButton)
        statusText.Value := "made by sin <3"
        ToolTip("Script: OFF")
        SetTimer(() => ToolTip(), -1000)
    }
}

UpdateTimers() {
    global clickDelay
    if (autoClickToggle.state) {
        SetTimer(AutoClick, clickDelay)
    }
    if (moveMouseToggle.state) {
        SetTimer(MoveMousePattern, clickDelay)
    }
    if (holdSToggle.state) {
        SetTimer(PressS, 100)
    }
}

AutoClick() {
    if (autoClickToggle.state) {
        MouseClick("Left")
    }
}

MoveMousePattern() {
    global position, centerX, moveMouseToggle
    
    if (moveMouseToggle.state) {
        MouseGetPos(, &currentY)
        quarterScreen := A_ScreenWidth * 0.25
        
        switch position {
            case 0:
                MouseMove(centerX - quarterScreen, currentY)
                position := 1
            case 1:
                MouseMove(centerX, currentY)
                position := 2
            case 2:
                MouseMove(centerX + quarterScreen, currentY)
                position := 3
            case 3:
                MouseMove(centerX, currentY)
                position := 0
        }
    }
}

F6::ToggleScript()

PressS() {
    Send("{s down}")
    Sleep(50)
    Send("{s up}")
    Sleep(50)
}

F7::
{
    StopScript()
    if (holdSToggle.state) {
        Send("{s up}")
    }
    myGui.Destroy()
    ExitApp()
}
