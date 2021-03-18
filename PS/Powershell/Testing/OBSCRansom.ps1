﻿#############################################################################
#If Powershell is running the 32-bit version on a 64-bit machine, we 
#need to force powershell to run in 64-bit mode .
#############################################################################
if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    write-warning "Y'arg Matey, we're off to 64-bit land....."
    if ($myInvocation.Line) {
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile $myInvocation.Line
    }else{
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -file "$($myInvocation.InvocationName)" $args
    }
exit $lastexitcode
}

$String = "*.bkp"
$TargetDir = "\\obsc-ds01\badstuff"

$Drives = Gwmi Win32_LogicalDisk -Filter "DriveType = 3"
Foreach ($Drive in $Drives.DeviceID) {
    Foreach ($Item in (Get-ChildItem -Path $Drive -Recurse -Include $String)) {
        Write-Host "Found " $Item.FullName
    }
}