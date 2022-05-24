### icinga2-check-logfile

This is a simple *powershell script* that will parse a log file and alert based on a critical and an OK value.

#### Instructions

Copy file *icinga2-check-logfile.ps1* into the following directory: C:\Program Files\ICINGA2\sbin\ <br>

#### Execution

.\icinga2-check-logfile.ps1 -LogPath "LOG FILE PATH" -ErrorString "CRITICAL ALERT STRING" -OkString "RESET CRITICAL ALERT" <br><br>

When you execute the script it will return the exit code and the last ErrorString or OkString that it finds.

#### Icinga2 Example Check command
```
object CheckCommand "icinga2_check_logfile" { 
    import "plugin-check-command"
    command = [
        "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe"
    ]
    arguments += {
        "-ErrorString" = {
            order = 3
            value = "$errorstring$"
        }
        "-LogPath" = {
            order = 4
            value = "$logpath$"
        }
        "-OkString" = {
            order = 3
            value = "$okstring$"
        }
        "-command" = {
            order = 1
            value = "$ps_command$"
        }
        ";exit" = {
            order = 10
            value = "$$LastExitCode"
        }
    }
}
```
#### Icinga2 Example Service Templates
```
template Service "generic-service" {
    max_check_attempts = "3"
    check_interval = 5m
    retry_interval = 1m
    check_timeout = 30s
    enable_notifications = true
    enable_active_checks = true
    enable_passive_checks = false
    enable_event_handler = true
    enable_flapping = false
    enable_perfdata = false
    volatile = false
}
```
```
object Service "Check Log for error" {
    
    import "generic-service"
    check_command = "icinga2_check_logfile"
    
    vars.errorstring = "'this is your error string'"
    vars.logpath = "'the path of your logfile'"
    vars.okstring = "'string that will bring the alert back to OK'"
    vars.ps_command = "& 'C:\\Program Files\\ICINGA2\\sbin\\icinga2-check-logfile.ps1'"
}
```
