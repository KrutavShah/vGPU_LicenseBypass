@ECHO off
@setlocal EnableDelayedExpansion
@set "params=%*"
@cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
@set LF=^


@color 17
@SET command=#
@FOR /F "tokens=*" %%i in ('findstr -bv @ "%~f0"') DO SET command=!command!!LF!%%i
@powershell -noprofile -command !command! & goto:eof

# *** POWERSHELL CODE STARTS HERE *** #

    Write-Host 'Nvidia vGPU License bypass by Krutav Shah with help from the wonderful vGPU_Unlock community.'
    Write-Host '----------------------------------------------'
    Write-Host 'Nvidia vGPU is property of NVIDIA Corporation.'
    Write-Host ''
    sleep 1

    $RegistryPath = 'HKLM:\SOFTWARE\NVIDIA Corporation\Global\GridLicensing'
    $RegistryProps = @(
        @{
            Name         = 'UnlicensedUnrestrictedStateTimeout'
            PropertyType = 'DWORD'
            Value        = 0x5a0
        }
        @{
            Name         = 'UnlicensedRestricted1StateTimeout'
            PropertyType = 'DWORD'
            Value        = 0x5a0
        }
        @{
            Name         = 'DisableExpirationPopups'
            PropertyType = 'DWORD'
            Value        = 1
        }
        @{
            Name         = 'DisableSpecificPopups'
            PropertyType = 'DWORD'
            Value        = 1
        }
    )

    
    $time = '3AM'
    $taskName = 'Restart vGPU Driver'
    $taskDescr = "'Restart Nvidia vGPU device drivers daily at $time'"
    $taskScript = ('"& { Get-PnpDevice -Class Display -FriendlyName NVIDIA* | Foreach-Object -Process { Disable-PnpDevice -InstanceId $_.InstanceId; Start-Sleep -Seconds 5; Enable-PnpDevice -InstanceId $_.InstanceId } }"')

    try {
        Write-Host 'We will start by changing the unlicensed time from 20 mins to 1440 mins (1 day) with some registry keys'
        # Make sure the registry key path exists
        (New-Item -ItemType Directory -Path $RegistryPath -Force -ErrorAction SilentlyContinue | Out-Null)
        # Add/overwrite the properties
        foreach ($RegistryProp in $RegistryProps) { New-ItemProperty -Path $RegistryPath @RegistryProp -Force -InformationAction SilentlyContinue | Out-Null}
        Write-Host 'Done, continuing.' -Fore red
        Write-Host ''

        # Check if the task already exists; removes if present.
        Write-Output -InputObject ('Checking for existing Nvidia driver restart task and removing if present...')
        if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
            Write-Output -InputObject ('Found and unregistered existing Nvidia driver restart task.')
            Write-Output ''
        }

        # Create the driver restart task.
        Write-Output -InputObject ('Adding new scheduled task "{0}", every day at "{1}"...' -f $taskName,$time)
        $taskTrigger = New-ScheduledTaskTrigger -Daily -At $time
        $taskAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ('-WindowStyle Hidden -NonInteractive -NoProfile -Command {0} ' -f $taskScript)
        $task = Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Description $taskDescr
        Write-Output -InputObject ('Registered scheduled task "{0}"' -f $task.TaskName)
    } catch {
        throw $PSItem
    } finally {
        Write-Host 'Done.' -Fore red
    }

Write-Host ''
Write-Host 'Restarting vGPU drivers in 3 seconds. Please be patient, your screen may temporarily flash.'
sleep 3
Get-PnpDevice -Class Display -FriendlyName NVIDIA* | Foreach-Object -Process { Disable-PnpDevice -confirm:$false -InstanceId $_.InstanceId; Start-Sleep -Seconds 5; Enable-PnpDevice -confirm:$false -InstanceId $_.InstanceId}

Write-Host ''
Write-Host '(C) 2021 Krutav Shah. Original Powershell task script by Andrew H. at https://gist.github.com/neg2led'
Write-Host ''
sleep 1
Write-Host 'Completed, enjoy your free vGPU before Nvidia patches it!' -Fore red
Write-Host ''
Write-Host 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
exit