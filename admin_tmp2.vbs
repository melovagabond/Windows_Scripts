rem add user to local administrator group
NET LOCALGROUP Administrators "%USERDOMAIN%\%USERNAME%" /ADD

rem log off user
shutdown -L

rem sleep for a number of seconds(In this case 30 min)
TIMEOUT /T 30

rem remove the user
NET LOCALGROUP Administrators "%USERDOMAIN%\%USERNAME%" /del