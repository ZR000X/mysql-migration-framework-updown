#!/bin/bash

# Load environment variables from .env file
if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            Set-Item -Path "Env:$($matches[1])" -Value $matches[2]
        }
    }
    Write-Output "Loaded environment variables from .env file."
} else {
    Write-Output "No .env file found."
}

# Function to read the last applied version
function Get-LastAppliedVersion {
    if (Test-Path "migration_config.txt") {
        return [int](Get-Content "migration_config.txt")
    } else {
        return 0
    }
}

# Function to update the last applied version
function Set-LastAppliedVersion {
    param (
        [int]$version
    )
    Set-Content -Path "migration_config.txt" -Value $version
}

# Function to apply SQL files
function Apply-SqlFiles {
    param (
        [string]$direction,
        [int]$start,
        [int]$end
    )

    $lastApplied = Get-LastAppliedVersion

    if ($direction -eq 'up' -and $start -ne $lastApplied -and $start -ne ($lastApplied + 1)) {
        Write-Output "Error: Current version is $lastApplied. You must apply migrations sequentially."
        return
    }

    if ($direction -eq 'down' -and $start -ne $lastApplied) {
        Write-Output "Error: Current version is $lastApplied. You must apply migrations sequentially."
        return
    }

    # Sort files in reverse order for down migrations
    if ($direction -eq 'down') {
        $files = Get-ChildItem -Path "migrations" -Filter "*.sql" | Sort-Object Name -Descending
    } else {
        $files = Get-ChildItem -Path "migrations" -Filter "*.sql" | Sort-Object Name
    }

    foreach ($file in $files) {
        $seq = [int]($file.Name -replace '\D', '')
        $fileDirection = if ($file.Name -match '_up_') { 'up' } elseif ($file.Name -match '_down_') { 'down' } else { '' }

        if ($direction -eq 'up' -and $seq -ge $start -and $seq -le $end -and $fileDirection -eq $direction) {
            Write-Output "Applying $file"
            Get-Content "$($file.FullName)" | mysql --protocol=TCP -h 127.0.0.1 -P 3306 -u root -pShaun722001 1>$null
            if ($LASTEXITCODE -eq 0) {
                Set-LastAppliedVersion -version $seq
            } else {
                Write-Output "Error applying $file. Migration halted."
                return
            }
        }

        if ($direction -eq 'down' -and $seq -le $start -and $seq -gt $end -and $fileDirection -eq $direction) {
            Write-Output "Applying $file"
            Get-Content "$($file.FullName)" | mysql --protocol=TCP -h 127.0.0.1 -P 3306 -u root -pShaun722001 1>$null
            if ($LASTEXITCODE -eq 0) {
                Set-LastAppliedVersion -version ($seq - 1)
            } else {
                Write-Output "Error applying $file. Migration halted."
                return
            }
        }
    }
}

# Main script logic
$command = $args[0]
$start = [int]$args[1]
$end = if ($args.Count -gt 2) { [int]$args[2] } else { $start }

switch ($command) {
    'up' { Apply-SqlFiles -direction 'up' -start $start -end $end }
    'down' { Apply-SqlFiles -direction 'down' -start $start -end $end }
    'updown' {
        Apply-SqlFiles -direction 'up' -start $start -end $end
        Apply-SqlFiles -direction 'down' -start $start -end $end
    }
    default { Write-Output "Unknown command: $command" }
}