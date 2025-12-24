# Schedule Autonomous Time Tasks
# Run this script as Administrator to create the scheduled tasks

$ahkPath = "C:\Users\YourName\AI\desktop-autonomous-time.ahk"
$workingDir = "C:\Users\YourName\AI"

# Morning autonomous time - 10:00 AM on weekdays
$morningAction = New-ScheduledTaskAction -Execute $ahkPath -WorkingDirectory $workingDir
$morningTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At 10:00AM
$morningSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName "Companion Autonomous Time - Morning" -Action $morningAction -Trigger $morningTrigger -Settings $morningSettings -Description "Triggers Desktop-AI autonomous time at 10am on weekdays"

# Afternoon autonomous time - 2:00 PM on weekdays  
$afternoonAction = New-ScheduledTaskAction -Execute $ahkPath -WorkingDirectory $workingDir
$afternoonTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At 2:00PM
$afternoonSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName "Companion Autonomous Time - Afternoon" -Action $afternoonAction -Trigger $afternoonTrigger -Settings $afternoonSettings -Description "Triggers Desktop-AI autonomous time at 2pm on weekdays"

Write-Host "Autonomous time tasks created!" -ForegroundColor Green
Write-Host "- Morning: 10:00 AM on weekdays"
Write-Host "- Afternoon: 2:00 PM on weekdays"
