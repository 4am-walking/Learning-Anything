<#
    Title: File Integrity Monitor
    Author: Chandler Matheny
    Date: 07/27/2023
    Purpose: Create a FIM that creates a hash baseline of a file and notifies the user if the file has been modified
#>

Write-Host "Test the integrity of your files!"
$path = Read-Host -Prompt "Please enter the path (ex: .\Downloads):"

Write-Host "What would you like to do?"
Write-Host "A) Collect a new Baseline?"
Write-Host "B) Begin monitoring files with saved Baseline?"

$response = Read-Host -Prompt "Please enter 'A' or 'B'"

Write-Host "User entered $($response)"

Function Calculate-File-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Erase-Baseline-If-Already-Exists() {
    $baselineExists = Test-Path -Path .\baseline.txt
    Remove-Item -Path .\baseline.txt
}


if ($response -eq "A".ToUpper()) {
    # Delete baseline if already exists
    Erase-Baseline-If-Already-Exists

    # Calculate hash from the target files and store in baseline.txt
    Write-Host "Calculate Hashes, make new baseline.txt" -ForegroundColor Cyan

    #Collect all files in the target folder
    $files = Get-ChildItem -Path $path

    #For file, calculate the hash, and write to baseline.txt
    foreach ($f in $files) {
       $hash = Calculate-File-Hash $f.FullName
       "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
    }

} elseif ($response -eq "B".ToUpper()) {
    # Begin monitoring files with saved Baseline
    Write-Host "Read existing baseline.txt, start monitoring files." -ForegroundColor Yellow

    $fileHashDictionary = @{}

    # Load file|hash from baseline.txt and store them in a dictionary
    $filePathesAndHashes = Get-Content -Path .\baseline.txt
    foreach ($f in $filePathesAndHashes) {
        $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
        
    }

    # Begin (continuously) monitoring files with saved Baseline
    while ($true) {
        Start-Sleep -Seconds 3

        $files = Get-ChildItem -Path $path

        foreach ($key in $fileHashDictionary.Keys) {
            $baselineFileStillExists = Test-Path -Path $key
            if (-Not $baselineFileStillExists) {
            # One of the baseline files msut have been deleted, notify the user
            Write-Host "$($key) has been deleted!" -ForegroundColor DarkRed -BackgroundColor Gray
        }

        foreach ($f in $files) {
            $hash = Calculate-File-Hash $f.FullName
            #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append

            if ($fileHashDictionary[$hash.Path] -eq $null) {
                # A new file has been created.
                Write-Host "$($hash.Path) has been created!" -ForegroundColor Green
            } else {
                # Notify if a new file has been changed.
                if ($fileHashDictionary[$hash.Path] -eq $hash.Hash) {
                    # The file has not changed.

                } else {
                    #File has been compromised.
                    Write-Host "$($hash.Path) hase changed!" -ForegroundColor Red
                }
            }

            
            }
        }
    }
}
