#Critical Asset Monitor
Import-Module SqlServer

#DB Creation Notes

#Create assets db 
##Invoke-Sqlcmd -ServerInstance "localhost" -Query "CREATE DATABASE assets"

#Create assetlist table
##Invoke-Sqlcmd -ServerInstance "localhost" -Database "assets" -Query "CREATE TABLE assetList (
##hostname varchar(255) PRIMARY KEY,
##checkType varchar(255),
##additionalValue varchar(255)
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


#Create dropdown menu on the AssetManager new input page which populate the new monitortype column
#create conditional logic on helios-monitor which runs the ICMP/TCP/HTTP test based on the CheckType value associated with the asset'

#consider adding SN integration to look for tickets in the past day referencing the object/IP down and hyperlink in card

$assetPage = New-UDPage -Name "Home" -Icon home -Endpoint {
    New-UDLayout -Columns 3 -Content {
        $query = "SELECT MAX(iter) FROM assetData"
        $lastIter = (Invoke-Sqlcmd -ServerInstance "localhost" -Database "assets" -Query $query).column1
        $lastTen = ($lastIter - 9)
        $query = ("SELECT * FROM assetData WHERE iter > $lastTen") 
        $lastCheckResults = Invoke-Sqlcmd -ServerInstance "localhost" -Database "assets" -Query $query  #this has all the data

        $query = ("SELECT * FROM assetData WHERE iter = $lastIter") 
        $results = Invoke-Sqlcmd -ServerInstance "localhost" -Database "assets" -Query $query | Sort-Object -Property "hostname" -Unique #this has only the last check
        $colorArray = @("Red","#EF6845","#EF7B47","#EF8D49","#EFA04A","#EFB24C","#EFC54E","#EFD750","#EFEA52","Green")

        #Generate a card for each asset

        Foreach ($entry in $results) {
            $onlineArray = $LastCheckResults | Where-Object -Property "hostname" -EQ $entry.hostname | Select-Object "online"
            $onlineCount = 0
            Foreach ($value in $onlineArray.online) {
                If ($value -eq $true) {
                    $onlineCount += 1
                }
            }
            $cardColor = $colorArray[$onlineCount]
            $name = $entry.hostname
            $date = $entry.date
            $online = $entry.online
            If ($online) {
                $color = $cardColor
                $status = "online"
            }
            Else {
                $color = $cardColor
                $status = "offline"
            }

        $failCount = 9 - $onlineCount
        New-UDCard -Title "$name" -Text "System is $status. Last Checked on $date. Failed $failCount of the most recent tests." -BackgroundColor "$color" 
        }
    }
} -AutoRefresh -RefreshInterval 10

$inventoryPage = New-UDPage -Name "Asset Manager" -Icon address_book -Endpoint {
    $query = "Select * from assetList;"
    $assets = Invoke-SqlCmd -ServerInstance "localhost" -Database "assets" -Query $query
    $assetCount = $assets.Count
    New-UDRow -Columns {
        New-UDColumn -size 12 -Endpoint {
            New-UDCard -Text "There are $assetCount monitored systems"
            }
        New-UDColumn -size 6 -Endpoint {
            New-UDInput -Title "Add an asset" -SubmitText "Add" -Content {
                New-UDInputField -Type 'textbox' -Name "hostname" -Placeholder "ENTER IP OR HOSTNAME"
                New-UDInputField -Type 'select' -Name "checkType" -Placeholder "What type of check should this be?" -DefaultValue "ICMP" -Values @("ICMP","TCP","HTTP")
                New-UDInputField -Type 'textbox' -Name "additional" -Placeholder "Enter port or endpoint (NOT REQUIRED FOR ICMP"
            } -Endpoint {
                param($hostname,$checkType,$additional)
                $query = "INSERT INTO assetList (hostname,checkType,additionalValue) VALUES ('$hostname','$checkType','$additional');"
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

$Dashboard = New-UDDashboard -Title "Helios Asset Monitor" -Pages @($assetPage,$InventoryPage)

Start-UDDashboard -Dashboard $Dashboard -port 8088 -AutoReload