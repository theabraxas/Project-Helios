While ($true) {
    $runTime = Measure-Command {
        $query = "SELECT * FROM assetlist" #get devices to ping this loop
        $assets = (Invoke-SqlCmd -ServerInstance "localhost" -Database "assets" -Query $query).ItemArray 

        $query = "SELECT MAX(iter) FROM assetData" #determine the last ping attempt # and iterate it forward by one
        $lastIter = (Invoke-Sqlcmd -ServerInstance "localhost" -Database "assets" -Query $query).Column1 
        $nextIter = $lastIter + 1 
        
        $queries = @() #list of queries to execute when pings are done.

        #Ping Stuff
        Foreach ($asset in $assets) {
            $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $online = (Test-Connection -ComputerName $asset -Count 1 -Quiet)
            If (-Not $online) {
                $online = 0}
            Else {
                $online = 1}
            $query = "INSERT INTO assetData (date,hostname,iter,online) VALUES ('$date','$asset','$nextIter','$online')"
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