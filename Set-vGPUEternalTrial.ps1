<#
.SYNOPSIS
    Set vGPU VM instance into eternal trial.
.DESCRIPTION
    Configures a Windows vGPU client for a 24-hour trial period and automatic daily driver restarts.
.EXAMPLE
    Set-vGPUEternalTrial -RestartTime 2AM
.EXAMPLE
    Set-vGPUEternalTrial -RestartTime 3AM -Filter '*GRID*'
.INPUTS
    None.
.OUTPUTS
    None
.NOTES
    None
.FUNCTIONALITY
    Adds two registry keys and a scheduled task.
#>

[CmdletBinding()]
[OutputType([String])]
Param (
    # Restart time
    [Parameter(Mandatory = $false,
        HelpMessage = 'Time of day to auto-restart the driver, defaults to 3:00am local')]
    [Alias('Time')]
    [ValidateNotNullOrEmpty()]
    [string]
    $RestartTime = '3AM',

    # Device friendly name filter.
    [Parameter(Mandatory = $false,
        HelpMessage = "Filter for FriendlyName of devices to restart, defaults to 'nVidia*'")]
    [ValidateNotNullOrEmpty()]
    [String]
    $Filter = 'nVidia*'
)

process {
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
            Name         = 'UnlicensedRestricted2StateTimeout'
            PropertyType = 'DWORD'
            Value        = 0x5a0
        }
        @{
            Name         = 'DisableExpirationPopups'
            PropertyType = 'DWORD'
            Value        = 0x1
        }
        @{
            Name         = 'DisableSpecificPopups'
            PropertyType = 'DWORD'
            Value        = 0x1
        }
    )

    $taskName = 'Restart vGPU Driver'
    $taskDescr = 'Restart nVidia vGPU device drivers daily at {0}' -f $RestartTime
    $taskScript = ( '& { Get-PnpDevice -PresentOnly -Class Display -FriendlyName ' + ('"{0}"' -f $Filter) + ' | Foreach-Object -Process { Disable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false; Start-Sleep -Seconds 7; Enable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false} }')

    try {
        Write-Output -InputObject ('Setting unlicensed state timeout registry properties to 24 hours')
        # Make sure the registry key exists
            (New-Item -ItemType Directory -Path $RegistryPath -Force -ErrorAction SilentlyContinue | Out-Null)
        # Add/overwrite the properties
        foreach ($RegistryProp in $RegistryProps) { New-ItemProperty -Path $RegistryPath @RegistryProp -Force -InformationAction SilentlyContinue }

        # check for existing task and remove if present
        Write-Output -InputObject ('Checking for existing scheduled task and removing if present')
        if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
            Write-Output -InputObject ('Found and unregistered existing scheduled task')
        }

        # Create daily restart scheduled task
        Write-Output -InputObject ('Adding new scheduled task "{0}", daily at {1}' -f $taskName, $RestartTime)
        $taskPrincipal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType 'ServiceAccount' -RunLevel 'Highest' -ProcessTokenSidType 'Default'
        $taskSettings = New-ScheduledTaskSettingsSet # don't need any specifics here
        $taskTrigger = New-ScheduledTaskTrigger -Daily -At $RestartTime
        $taskAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ('-WindowStyle Hidden -NonInteractive -NoProfile -Command "{0}" ' -f $taskScript)
        $task = Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Description $taskDescr -Principal $taskPrincipal -Settings $taskSettings
        Write-Output -InputObject ('Registered scheduled task "{0}"' -f $task.TaskName)
    } catch {
        throw $PSItem
    } finally {
        Write-Output -InputObject ('Done.')
    }
}

