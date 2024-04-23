# Prompt
oh-my-posh init pwsh --config "c:/work/dotfiles/powershell/json.omp.json" | Invoke-Expression
Import-Module Terminal-Icons

# Auto suggestions
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Key "Ctrl+f" -Function ForwardWord
Set-PSReadLineOption -EditMode Emacs

# Not allow duplicates history
Set-PSReadlineOption -AddToHistoryHandler {
    param ($command)
    switch -regex ($command) {
        "SKIPHISTORY" {return $false}
        "^[a-z]$" {return $false}
        "exit" {return $false}
        "\.\." {return $false}
    }
    return $true
}

# Alias
Set-Alias vim code
Set-Alias grep findstr
function .. {
    Set-Location ..
}
function ll {
    exa -lag --icons --ignore-glob=".DS_Store|.localized" --sort=type --time-style=long-iso --no-permissions $args 
}


#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "C:\Users\maedat\miniconda3\Scripts\conda.exe") {
    (& "C:\Users\maedat\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion
