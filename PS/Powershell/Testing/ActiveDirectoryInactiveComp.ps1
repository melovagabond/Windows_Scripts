﻿#--EXPORT AD COMPUTERS--

$Domain = (Get-WmiObject Win32_ComputerSystem).Domain
$DaysInactive = 180
$time = (Get-Date).Adddays(-($DaysInactive))
$Directory = (get-location).Drive.Name+":\temp\AD"
$File = "OLD_Computer.csv"
$FilePath = "$Directory\$File"

if(!(Test-Path -Path $Directory)){
    Write-Host "Creating temp directory..."
    New-Item -ItemType directory -Path $Directory -ErrorAction SilentlyContinue
    Write-Host "Temp directory created." -ForegroundColor Green
}
else{
    Write-Host "Temp directory exists. Proceeding..."
}

Write-Host "Outputting data..."
Try {
    Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp |
    select-object Name,@{Name="Last Login"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | export-csv "$FilePath" -notypeinformation
    Write-Host "Data output successfully." -ForegroundColor Green
}
Catch {
    Write-Warning "Couldn't output data."
    Exit
}

#========================================================

#--SEND EMAIL REPORT--

$Email = "themailman@techrunnerit.com"
$Password = "user_pass"
$InactiveComps = Import-Csv -Path "$FilePath" | ConvertTo-Html -Fragment
$Password | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "pass.txt"
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Email, (Get-Content "pass.txt" | ConvertTo-SecureString)
$mailBody =
"Inactive Computers:<br><br>
$InactiveComps"

Try {
    Write-Host "Sending email..."
    Send-MailMessage -Body $mailBody -BodyAsHtml -From $Email -To "itmail@techrunnerit.com" -Subject "Inactive Computers - $Domain" -Attachments "$FilePath" -Encoding $([System.Text.Encoding]::UTF8) -Credential $Credentials -SmtpServer "smtp.office365.com" -Port 587 -UseSsl | Out-Null
    Write-Host "Email sent successfully." -ForegroundColor Green
}
Catch {
    Write-Warning "Couldn't send email."
}

#--CLEANUP--
Try {
    Write-Host "Cleaning up..."
    Remove-Item -Path $Directory -Recurse
    Write-Host "Temp files deleted." -ForegroundColor Green
}
Catch {
    Write-Warning "Couldn't delete temp files."
}