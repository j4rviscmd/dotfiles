# Prompt
Import-Module posh-git
oh-my-posh init pwsh --config "$env:USERPROFILE\.config\powershell\takurou.omp.json"| Invoke-Expression

Import-Module Terminal-Icons

# Auto suggestions
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Emacs

# Not allow duplicates history
Set-PSReadlineOption -AddToHistoryHandler {
    param ($command)
    switch -regex ($command) {
        "SKIPHISTORY" {return $false}
        "^[a-z]$" {return $false}
        "exit" {return $false}
    }
    return $true
}

# Alias
Set-Alias ll ls
Set-Alias vim nvim
Set-Alias grep findstr
function .. {
    Set-Location ..
}

# peco
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class KeyboardSimulator
{
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

    public const int VK_RETURN = 0x0D;
    public const int KEYEVENTF_KEYUP = 0x0002;

    public static void SimulateKeyEnter()
    {
        keybd_event(VK_RETURN, 0, 0, UIntPtr.Zero);
        keybd_event(VK_RETURN, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
    }
}
"@
# press enter key
# [KeyboardSimulator]::SimulateKeyEnter()

Set-PSReadLineKeyHandler -chord Ctrl+r -scriptBlock { SelectandExecHistory }
function global:SelectandExecHistory()
{
   $selectCmd = (tail -20 (Get-PSReadLineOption).HistorySavePath) | peco --select-1 --on-cancel error
   # if ($?) {
   if (-not $selectCmd) {
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    # return
   } else {
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
     [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selectCmd)
    # press enter key
     [KeyboardSimulator]::SimulateKeyEnter()
   }
}



# nvim
# sample $env:MYENV = "This is my env."
$env:XDG_CONFIG_HOME = $HOME + "\.config"

