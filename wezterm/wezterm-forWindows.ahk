/*
https://ahkwiki.net/Examples
*/
Ctrl::
  ApplicationBinaryName=wezterm-gui.exe
  ApplicationBinaryPath="C:\Program Files\WezTerm\wezterm-gui.exe"
  KeyWait, Ctrl, U
  KeyWait, Ctrl, D T0.3
  If ErrorLevel=0 
  {
    Process, Exist, %ApplicationBinaryName%
    If ErrorLevel <> 0
    {
      WinGet, WinState, MinMax, ahk_exe %ApplicationBinaryName%
      If WinState=-1
      {
        WinActivate, ahk_exe %ApplicationBinaryName%
      }
      Else
      {
        WinMinimize, ahk_exe %ApplicationBinaryName%
      }
    }
    Else
    {
      Run, %ApplicationBinaryPath%
      return 
    }
  }
  Else
  {
    Send,{Ctrl}
  }
return
