#conditional check for connection type (ICMP, TCP, HTTP)
#ICMP is done. 
#TCP = Test-NetConnection $hostname -Port # -InformationLevel Quiet
#HTTP - Invoke-WebRequest ??

While ($true) {
    $runTime = Measure-Command {
        $query = "SELECT * FROM assetlist" #get devices to ping this loop
        $assets = (Invoke-SqlCmd -ServerInstance "localhost" -Database "assets" -Query $query)

        $query = "SELECT MAX(iter) FROM assetData" #determine the last ping attempt # and iterate it forward by one
        $lastIter = (Invoke-Sqlcmd -ServerInstance "localhost" -Database "assets" -Query $query).Column1 
        $nextIter = $lastIter + 1 
        
        $queries = @() #list of queries to execute when pings are done.

        #Ping Stuff
        Foreach ($asset in $assets) {
            $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

            If ($asset.CheckType -eq "ICMP") {
                $online = (Test-Connection -ComputerName $asset.hostname -Count 1 -Quiet)
            } ElseIf ($asset.CheckType -eq "TCP") {
                $online = (Test-NetConnection $asset.hostname -Port $asset.additionalValue -InformationLevel Quiet)
            }

            If (-Not $online) {
                $online = 0}
            Else {
                $online = 1}
            $hostname = $asset.hostname
            $query = "INSERT INTO assetData (date,hostname,iter,online) VALUES ('$date','$hostname','$nextIter','$online')"
            $queries += $query
        }
        foreach ($query in $queries) {
            Invoke-Sqlcmd -ServerInstance "localhost" -Database "assets" -Query $query
        }
        $query = "UPDATE assetData SET completed=1 WHERE iter=$nextIter;"
        Invoke-SqlCmd -ServerInstance "localhost" -Database "assets" -Query $query
    }
    If ($runTime.TotalSeconds -lt 120) {
        $sleepTime = 120 - $runTime.TotalSeconds
        Sleep -Seconds $sleepTime
    }
}