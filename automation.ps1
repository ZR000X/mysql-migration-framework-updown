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

# Function to apply SQL files
function Apply-SqlFiles {
    param (
        [string]$direction,
        [int]$start,
        [int]$end
    )

    Write-Output "Applying SQL files for $direction from $start to $end."

    $files = Get-ChildItem -Path "migrations" -Filter "*.sql" | Sort-Object Name

    foreach ($file in $files) {
        $seq = [int]($file.Name -replace '\D', '')
        $fileDirection = if ($file.Name -match '_up_') { 'up' } elseif ($file.Name -match '_down_') { 'down' } else { '' }

        Write-Output "Processing file: $file"
        Write-Output "Sequence number: $seq"
        Write-Output "File direction: $fileDirection"

        if ($seq -ge $start -and $seq -le $end -and $fileDirection -eq $direction) {
            Write-Output "Applying $file"
            Write-Output "Running: Get-Content '$($file.FullName)' | mysql --protocol=TCP -h 127.0.0.1 -P 3306 -u root -pShaun722001"
            Get-Content "$($file.FullName)" | mysql --protocol=TCP -h 127.0.0.1 -P 3306 -u root -pShaun722001
        } else {
            Write-Output "Skipping $file (sequence: $seq, direction: $fileDirection)"
        }
    }
}

# Main script logic
$command = $args[0]
$start = [int]$args[1]
$end = if ($args.Count -gt 2) { [int]$args[2] } else { $start }

Write-Output "Command: $command, Start: $start, End: $end"

switch ($command) {
    'up' { Apply-SqlFiles -direction 'up' -start $start -end $end }
    'down' { Apply-SqlFiles -direction 'down' -start $start -end $end }
    'updown' {
        Apply-SqlFiles -direction 'up' -start $start -end $end
        Apply-SqlFiles -direction 'down' -start $start -end $end
    }
    default { Write-Output "Unknown command: $command" }
}
