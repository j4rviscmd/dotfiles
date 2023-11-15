# Prompt
Import-Module posh-git
oh-my-posh init pwsh --config "$env:USERPROFILE\.config\powershell\takurou.omp.json"| Invoke-Expression

Import-Module Terminal-Icons

# Auto suggestions
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView 
Set-PSReadLineOption -EditMode Emacs


# Alias
Set-Alias ll ls
Set-Alias vim nvim
Set-Alias grep findstr 
function .. {
    Set-Location ..
}

# peco
Set-PSReadLineKeyHandler -chord Ctrl+r -scriptBlock { SelectandExecHistory }
function global:SelectandExecHistory()
{
   $selectCmd = (tail -20 (Get-PSReadLineOption).HistorySavePath)|peco --select-1 --on-cancel error
   if ($?) {
      [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
      [System.Windows.Forms.SendKeys]::SendWait($selectCmd)
   } else {
      [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
   }
}

# nvim
# sample $env:MYENV = "This is my env."
$env:XDG_CONFIG_HOME = $HOME + "\.config"

