# Project Helios
*Still under development, probably not safe for production. Use at your own risk*

Project Helios is an uptime monitoring system meant to be easily deployable, simple to use, and easy to customize.

There are three components, the helios.ps1 file which is the webserver utilizing PowerShell UniversalDashboard, the SQL Express backend server to store data, and the helios-monitor.ps1 which is a background task which checks on the status of endpoints.

Right now it is only testing for ICMP and TCP connectivity but shortly there will be features to monitor HTTP and API responses

## Main page looks like the following and is auto refreshed every 10 seconds
![monitor homepage](https://raw.githubusercontent.com/theabraxas/Project-Helios/master/docs/images/monitor.png)

## Asset Manager looks like the following and allows control of what assets are being tested/managed
![monitor homepage](https://raw.githubusercontent.com/theabraxas/Project-Helios/master/docs/images/manager.png)

## Getting Started
1) Install SQL Express

2) Run the database creation commands from the top commented out portions of helios.ps1

3) Launch helios.ps1

4) Launch helios-monitor.ps1 to start recording data

5) Go to the 'Asset Manager' page in Helios to add hosts to monitor
