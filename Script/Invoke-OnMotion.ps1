<#
.SYNOPSIS
K!2020. Execute the specified command when laptop motion is detected. 
Thinkpad laptops only.

.DESCRIPTION
The command given in the script parameter will be executed when the sensor 
detects the device is moving. The script uses ThinkPad acceleration sensor 
to detect laptop motion.

.PARAMETER ScriptBlock
Command to be executed when motion is detected.

.PARAMETER ReadIntervalMS
The time interval in milliseconds between the sensor readings.

.PARAMETER PositionDelta
The difference between the current position and the starting position of 
the device at which the command will be executed. 
The smaller the value, the greater the sensitivity to motion.

.EXAMPLE
.\Invoke-OnMotion.ps1 -ScriptBlock { notepad.exe }

.EXAMPLE
Start-Job -ScriptBlock { 
    c:\Scripts\Invoke-OnMotion.ps1 -ScriptBlock { 
        shutdown.exe /s /f /t 0
    }
}

.LINK
https://github.com/krcs/Invoke-OnMotion

#>
#Requires -Assembly c:\Windows\system32\sensor64.dll
param(
    [Parameter(Position=0,mandatory=$true)]
    [System.Management.Automation.ScriptBlock]$ScriptBlock = $(throw "Specify command to execute."),
    [Parameter(Position=1)]
    [int]$ReadIntervalMS = 1000,
    [Parameter(Position=2)]
    [int]$PositionDelta = 15
)

if (-not (Test-Path "C:\Windows\system32\sensor64.dll")) {
    write-host -Foreground RED "Error: sensor64.dll not found."
    exit
}

$sensor = @"
    using System.Runtime.InteropServices;

    public sealed class Sensor
    {
        [DllImport("sensor64.dll")]
        public static extern void ShockproofGetAccelerometerData(ref AccelerometerData accelerometerData);

        [StructLayout(LayoutKind.Sequential)]
        public struct AccelerometerData
        {
            public int Status;
            public short X;
            public short Y;
            public short XX;
            public short YY;
            public byte Temperature;
            public short X0;
            public short Y0;
        }

        public void ReadSensor(ref AccelerometerData accelerometerData) {
           ShockproofGetAccelerometerData(ref accelerometerData);
        }
    }
"@

Add-Type -TypeDefinition $sensor -WarningAction SilentlyContinue | Out-Null

[Sensor+AccelerometerData]$accelerometerData = New-Object -TypeName Sensor+AccelerometerData
[Sensor]$sensor = New-Object -TypeName Sensor

function Get-Position() {
    $sensor.ReadSensor([ref] $accelerometerData); 
    return @{
        X = $accelerometerData.XX
        Y = $AccelerometerData.YY
    }
}

$startPosition = Get-Position

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | out-null

while ($true) {
    $currentPosition = Get-Position
    $deltaX = [Math]::Abs($currentPosition.X-$startPosition.X)
    $deltaY = [Math]::Abs($currentPosition.Y-$startPosition.Y)
    if ($deltaX -gt $PositionDelta -or $deltaY -gt $PositionDelta) {
        Invoke-Command -ScriptBlock $ScriptBlock
    }
    Start-Sleep -Milliseconds $ReadIntervalMS
}
