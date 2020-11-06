# Invoke-OnMotion
Execute the specified command when laptop motion is detected.
The script uses ThinkPad acceleration sensor to detect laptop motion.

The command given in the script parameter will be executed when the sensor detects the device is moving. **Thinkpad laptops only.**

### Use case
Put your laptop on your desk and wait a few seconds, then run the script with a command such as force to shut down. If you or someone take your laptop from your desk, it will automatically turn off.

Another command that you can execute is, for example, disconnecting the encrypted drives.

### Parameters
**ScriptBlock**
Command to be executed when motion is detected.

**ReadIntervalMS**
The time interval in milliseconds between the sensor readings.

**PositionDelta**
The difference between the current position and the starting position of the device at which the command will be executed. 
The smaller the value, the greater the sensitivity to motion.

### Examples
**Run notepad when laptop moves.**
```
.\Invoke-OnMotion.ps1 -ScriptBlock { notepad.exe }
```

**Run as background job, force to shutdown when laptop moves.**
```
Start-Job -ScriptBlock { 
    c:\Scripts\Invoke-OnMotion.ps1 -ScriptBlock { 
        shutdown.exe /s /f /t 0
    }
}
```
**Run as background join, force to dismount encrypted drives.**
```
Start-Job -ScriptBlock { 
    c:\Scripts\Invoke-OnMotion.ps1 -ScriptBlock { 
        & 'C:\Program Files\VeraCrypt\VeraCrypt.exe' /f /d /s
    }
}
```
### Reference
https://www.codeproject.com/Articles/32303/Using-the-APS-Accelerometer-in-Lenovo-Laptops

