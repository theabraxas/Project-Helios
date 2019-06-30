# PROJECT Helios
*Still under development, probably not safe for production. Use at your own risk*

Project Helios is an uptime monitoring system meant to be easily deployable, simple to use, and easy to customize.

There are two components, the helios.ps1 file which is the webserver utilizing PowerShell UniversalDashboard and then helios-monitor.ps1 which is a background task which checks on the status of endpoints.

Right now it is only testing for ICMP connectivity but shortly there will be a feature added to tell it to monitor for different types of uptime - HTTP 200s, TCP port connectivity, or API repsponses

## Main page looks like the following and is auto refreshed every 10 seconds
![monitor homepage](https://raw.githubusercontent.com/theabraxas/Project-Helios/master/docs/images/monitor.png)

## Asset Manager looks like the following and allows control of what assets are being tested/managed
![monitor homepage](https://raw.githubusercontent.com/theabraxas/Project-Helios/master/docs/images/manager.png)
