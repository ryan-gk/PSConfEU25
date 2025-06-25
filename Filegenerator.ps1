Measure-Command {
    $bigFileName = "plc_log.txt"
    $plcNames = 'PLC_A', 'PLC_B', 'PLC_C', 'PLC_D'
    $errorTypes = 'Sandextrator overload', 'Conveyor misalignment', 'Valve stuck', 'Temperature warning'
    $statusCodes = 'OK', 'WARN', 'ERR'
    
    # Use StringBuilder with capacity for 2000 lines to minimize resizing
    $sb = [System.Text.StringBuilder]::new(200000)  # ~100 chars * 2000 lines
    $rand = [System.Random]::new()  # Faster random number generation than Get-Random
    $startTime = [datetime]::Now  # Faster date retrieval than Get-Date
    $batchSize = 2000  # Increased batch size to reduce I/O calls
    
    try {
        # Use StreamWriter with 64KB buffer for efficient disk I/O
        $stream = [System.IO.StreamWriter]::new($bigFileName, $false, [System.Text.Encoding]::UTF8, 65536)
        
        for ([int]$i = 0; $i -lt 50000; $i++) {
            $timestamp = $startTime.AddSeconds(-$i).ToString("yyyy-MM-dd HH:mm:ss")
            $plc = $plcNames[$rand.Next(4)]  # Direct indexing is faster than pipeline Get-Random
            $operator = $rand.Next(101, 121)  # Faster range-based random
            $batchNum = $rand.Next(1000, 1101)
            $status = $statusCodes[$rand.Next(3)]
            $machineTemp = "{0:N2}" -f ($rand.Next(60, 110) + $rand.NextDouble())  # Inline formatting for speed
            $load = $rand.Next(101)
            
            if ($rand.Next(7) -eq 0) {
                # 1-in-7 chance optimized with single call
                $errorType = $errorTypes[$rand.Next(4)]
                if ($errorType -eq 'Sandextrator overload') {
                    $value = $rand.Next(1, 11)
                    # Use -f for faster string formatting instead of StringBuilder.Append
                    $line = "ERROR;$timestamp;$plc;$errorType;$value;$status;$operator;$batchNum;$machineTemp;$load" -f $null
                }
                else {
                    $line = "ERROR;$timestamp;$plc;$errorType;;$status;$operator;$batchNum;$machineTemp;$load" -f $null
                }
            }
            else {
                $line = "INFO;$timestamp;$plc;System running normally;;$status;$operator;$batchNum;$machineTemp;$load" -f $null
            }
            
            [void]$sb.AppendLine($line)
            
            # Write batch to avoid holding all 50,000 lines in memory
            if (($i + 1) % $batchSize -eq 0 -or $i -eq 49999) {
                $stream.Write($sb.ToString())
                $sb.Length = 0  # Faster reset than Clear() to reuse StringBuilder
            }
        }
    }
    finally {
        if ($stream) {
            $stream.Flush()  # Ensure all data is written
            $stream.Close()
        }
    }
}