# Prompt
Import-Module posh-git
oh-my-posh init pwsh --config "$env:USERPROFILE\.config\powershell\takurou.omp.json"| Invoke-Expression

Import-Module Terminal-Icons

# Auto suggestions
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView


# Alias
Set-Alias ll ls
Set-Alias vim nvim
Set-Alias grep findstr

# nvim
# sample $env:MYENV = "This is my env."
$env:XDG_CONFIG_HOME = $HOME + "\.config"

# Utilities
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}