#Critical Asset Monitor
Import-Module SqlServer

#DB Creation Notes

#Create assets db 
##Invoke-Sqlcmd -ServerInstance "localhost" -Query "CREATE DATABASE assets"

#Create assetlist table
##Invoke-Sqlcmd -ServerInstance "localhost" -Database "assets" -Query "CREATE TABLE assetList (
##hostname varchar(255) PRIMARY KEY,
##checkType varchar(255),
##);"

#Invoke-Sqlcmd -ServerInstance "localhost" -Database "assets" -Query "CREATE TABLE assetData (
#date datetime,
#hostname varchar(255),
#online bit,
#iter int,
#completed bit)"

#tweak it to run with no data fed to the database pre-launch
### For now run the following `Invoke-Sqlcmd -ServerInstance "localhost" -Database "assets" -Query "INSERT INTO assetList (hostname) VALUES ('8.8.8.8');"
### And then run `Invoke-Sqlcmd -ServerInstance "localhost" -Database "assets" -Query "INSERT INTO assetData (hostname,iter,online) VALUES ('8.8.8.8',0,1);"
#edit endpoint to iterate the assets based on the new asset table
#Add logic to concurrently run test-connections
#why don't the nav buttons work?????

##phase2
#add logic to pull last 10 pings, record failure % based on last 10-20 pings

$assetPage = New-UDPage -Name "Home" -Icon home -Endpoint {
    New-UDLayout -Columns 3 -Content {
        $query = "SELECT MAX(iter) FROM assetData"
        $lastIter = (Invoke-Sqlcmd -ServerInstance "localhost" -Database "assets" -Query $query).column1
        $query = ("SELECT * FROM assetData WHERE iter = $lastiter") 
        $results = Invoke-Sqlcmd -ServerInstance "localhost" -Database "assets" -Query $query | Sort-Object -Property "hostname" -Unique
            Foreach ($entry in $results) {
                $name = $entry.hostname
                $date = $entry.date
                $online = $entry.online
                If ($online) {
                    $color = "Green"
                    $status = "online"
                }
                Else {
                    $color = "Red"
                    $status = "offline"
                }
        New-UDCard -Title "$name" -Text "Last Checked on $date" -BackgroundColor "$color" 
        }
    }
} -AutoRefresh -RefreshInterval 10

$inventoryPage = New-UDPage -Name "Asset Manager" -Icon address_book -Endpoint{
    $query = "Select * from assetList;"
    $assets = Invoke-SqlCmd -ServerInstance "localhost" -Database "assets" -Query $query
    $assetCount = $assets.ItemArray.Count
    New-UDRow -Columns {
        New-UDColumn -size 12 -Endpoint {
            #New-UDCard -Text "There are $assetCount monitored systems"
            New-UDCard -Text "There are 0 monitored systems"
            }
        New-UDColumn -size 6 -Endpoint {
            New-UDInput -Title "Add an asset" -SubmitText "Add" -Endpoint {
                param($hostname)
                $query = "INSERT INTO assetList (hostname) VALUES ('$hostname');"
                Invoke-SqlCmd -ServerInstance "localhost" -Database "assets" -Query $query
                New-UDInputAction -Toast "Added Asset"
            }
        }
        New-UDColumn -size 6 -Endpoint {
            New-UDInput -Title "Remove an asset" -SubmitText "Add" -Endpoint {
                param($hostname)
                $query = "DELETE FROM assetList WHERE hostname='$hostname';"
                Invoke-SqlCmd -ServerInstance "localhost" -Database "assets" -Query $query
                New-UDInputAction -Toast "Removed Asset"
            }
        }
    }
}

$Dashboard = New-UDDashboard -Title "Critical Asset Monitor" -Pages @($assetPage,$InventoryPage)

Start-UDDashboard -Dashboard $Dashboard -port 8088 -AutoReload