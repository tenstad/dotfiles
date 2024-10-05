#Requires AutoHotkey v2.0

interval := 3000
logpath := "C:\Users\xxx\keystrokes"

counter := KeyCounter()
counter.Start()

class KeyCounter {
    __New() {
        this.actionsLastSec := 0

        this.count := 0
        loop read, this.LogFile() {
            this.count += StrSplit(A_LoopReadLine, " ")[2]
        }
        this.prev := this.count

        this.countgui := StatGui(0, 1172)
        this.countText := this.countgui.AddText("_____")
        this.countText.Value := this.count
        this.countgui.Show()

        this.warngui := WarnGui(() => this.countgui.ShowOnTop())

        this.interval := interval
        this.timer := () => this.Log()

        this.hook := InputHook()
        this.hook.KeyOpt("{All}", "V N")
        this.hook.OnKeyUp := (ih, vk, sc) => this.OnPress(ih, vk, sc)
    }

    Start() {
        SetTimer this.timer, this.interval
        this.hook.Start()
    }

    Stop() {
        SetTimer this.timer, 0
        this.hook.Stop()
    }

    OnPress(ih, vk, sc) {
        this.count++

        this.actionsLastSec++
        SetTimer () => (
            this.actionsLastSec--
            SetTimer(, 0)), 1000

        if (this.actionsLastSec > 11) {
            this.warngui.Warn(10 * (this.actionsLastSec - 11))
        }

        this.countText.Value := this.count
    }

    Log() {
        diff := this.count - this.prev
        if (diff > 0) {
            FileAppend(Format("{:i} {:i}`n", CurrentMillis(), diff), this.LogFile())
        }

        this.prev := this.count
    }

    LogFile() {
        return Format("{:s}\{:s}.txt", logpath, CurrentDay())
    }
}

class StatGui {
    __New(x, y) {
        this.x := x
        this.y := y

        this.tray := WinExist("ahk_class Shell_TrayWnd")

        this.gui := Gui(, "")
        this.gui.Opt("+AlwaysOnTop +ToolWindow +Disabled -SysMenu -Caption -DPIScale +Owner" this.tray)
        this.gui.SetFont("s6 w200 cFFFFFF", "Courier")
        this.gui.BackColor := "FFFFFE"
        WinSetTransColor("FFFFFE", this.gui)

        ; DwmSetWindowAttribute(hwnd, dwAttribute, pvAttribute, cbAttribute)
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", this.gui.hwnd,
            "uint", 12, ; DWMWA_EXCLUDED_FROM_PEEK
            "uint*", 1, "uint", 4)

        ; SetWinEventHook(eventMin, eventMax, hmodWinEventProc, pfnWinEventProc, idProcess, idThread, dwFlags)
        DllCall("SetWinEventHook"
            , "UInt", 0x8005 ; EVENT_OBJECT_FOCUS
            , "UInt", 0x800B ; EVENT_OBJECT_LOCATIONCHANGE
            , "Ptr", 0
            , "Ptr", CallbackCreate(WinEventHookProc)
            , "UInt", 0
            , "UInt", 0
            , "UInt", 0x2 ; WINEVENT_SKIPOWNPROCESS
        )

        WinEventHookProc(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime) {
            if (hwnd && idObject != 0xFFFFFFF7 ; CURSOR
            ) {
                this.ShowOnTop()
            }
        }
    }

    AddText(text) {
        return this.gui.Add("Text", , text)
    }

    Show() {
        this.gui.Show("NoActivate " "x" this.x " y" this.y)
    }

    ShowOnTop() {
        ; SetWindowPos(hWnd, hWndInsertAfter, X, Y, cx, cy, uFlags)
        DllCall("SetWindowPos", "ptr", this.tray, "ptr", this.gui.hwnd,
            "int", 1000, "int", 0, "int", 0, "int", 0, "uint",
            0x010   ; SWP_NOACTIVATE
            | 0x002 ; SWP_NOMOVE
            | 0x200 ; SWP_NOOWNERZORDER
        )
    }
}

class WarnGui {
    __New(onClear) {
        this.duration := 200
        this.minOpacity := 0
        this.maxOpacity := 200

        this.onClear := onClear
        this.gui := ""
        this.timer := () => this.Clear()
    }

    Warn(opacity) {
        opacity := Min(Max(opacity, this.minOpacity), this.maxOpacity)

        SetTimer(this.timer, 0)
        if (!this.gui) {
            this.gui := Gui(, "")
            this.gui.Opt("+AlwaysOnTop +Disabled -SysMenu +Owner -Caption -DPIScale")
            this.gui.BackColor := "FF0000"
        }

        WinSetTransColor(Format("000000 {:i}", opacity), this.gui)
        this.gui.Show("NoActivate"
            " x" SysGet(76) ; SM_XVIRTUALSCREEN
            " y" SysGet(77) ; SM_YVIRTUALSCREEN
            " w" SysGet(78) ; SM_CXVIRTUALSCREEN
            " h" SysGet(79) ; SM_CYVIRTUALSCREEN
        )
        SetTimer(this.timer, this.duration)
    }

    Clear() {
        SetTimer(this.timer, 0)
        if (this.gui) {
            this.gui.Destroy()
            this.gui := ""
            this.onClear.Call()
        }
    }
}

CurrentDay() {
    return DateDiff(A_NowUTC, "1970", "days")
}

CurrentMillis() {
    return DateDiff(A_NowUTC, "1970", "seconds") * 1000 + A_MSec
}
