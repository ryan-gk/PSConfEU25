Measure-Command{
$bigFileName = "plc_log.txt"
$plcNames = 'PLC_A','PLC_B','PLC_C','PLC_D'
$errorTypes = @(
    'Sandextrator overload',
    'Conveyor misalignment',
    'Valve stuck',
    'Temperature warning'
)
$statusCodes = 'OK','WARN','ERR'
 
$logLines = @()
 
for ($i=0; $i -lt 50000; $i++) {
    $timestamp = (Get-Date).AddSeconds(-$i).ToString("yyyy-MM-dd HH:mm:ss")
    $plc = $plcNames | Get-Random
    $operator = Get-Random -Minimum 101 -Maximum 121
    $batch = Get-Random -Minimum 1000 -Maximum 1101
    $status = $statusCodes | Get-Random
    $machineTemp = [math]::Round((Get-Random -Minimum 60 -Maximum 110) + (Get-Random),2)
    $load = Get-Random -Minimum 0 -Maximum 101
 
    if ((Get-Random -Minimum 1 -Maximum 8) -eq 4) {
        $errorType = $errorTypes | Get-Random
        if ($errorType -eq 'Sandextrator overload') {
            $value = (Get-Random -Minimum 1 -Maximum 11)
            $msg = "ERROR; $timestamp; $plc; $errorType; $value; $status; $operator; $batch; $machineTemp; $load"
        } else {
            $msg = "ERROR; $timestamp; $plc; $errorType; ; $status; $operator; $batch; $machineTemp; $load"
        }
    } else {
        $msg = "INFO; $timestamp; $plc; System running normally; ; $status; $operator; $batch; $machineTemp; $load"
    }
 
    $logLines += $msg
}
 
Set-Content -Path $bigFileName -Value $logLines
Write-Output "PLC log file generated."
}