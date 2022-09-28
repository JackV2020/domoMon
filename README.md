This Toon app is to monitor up to 18 Domoticz Devices which have 1 numeric/text value.

 - Tile :
    - page between 3 sets of 6 Domoticz devices with their names and values on the tile
    - option to only show first page when dimmed (so put most interesting devices on page 1)
    - warn when values are not within optional configurable limits by changing tile color
    - warn when values contain an optional configurable string by changing tile color

 - is used by me to display Domoticz devices like :
    - solar panels generated today
    - solar panels generated week
    - solar panels generated month
    - airpressure
    - humidity in the house
    - temperature in another place in the house
    - active power usage
 - the same for the next devices but with optional limits defined :
    - solar panels inverter status ( Oke, Off, IP Error etc)
    - pi-hole status ( low when status is 0 )
    - salt level of my Aquacell water softener ( low alarm when 1 )
    - the 15 minute load of Toon ( high alarm above 1.25 )
    - a device accessible by pinging it ( low alarm when below 4 pings )

Since my values fit in 2 sets of 6, the Tile only pages between these 2 sets. Empty sets are skipped.

 - To show and configure everything this app has 3 screens :
    - 1 Tile showing 1 set of 6 Device at a time ( max 3 sets which it automatically pages between ) 
         The tile gives access to the Search Strings/Limits screen.
    - 1 Search Strings/Limits screen where optional search strings/lower and upper limits can be configured.
         When a value crosses a limit or contains a string the tile gets a color, more details on this below.
         The Limits screen gives access to the Settings screen.
    - 1 Settings screen to configure the Domoticz connection and up to 3 sets of 6 Custom Sensors idx values and names.
         The update interval is in seconds and you can toggle the paging behaviour of the tile.

When the app arrives in the store installing will be like for any other app.

For now to install manually without Toon store : 

 - Download the zip.
 - Unpack the zipfile.
 - Use FileZilla / WinSCP to create /qmf/qml/apps/domoMon on Toon.
 - Put at least the qml files in the new directory.
 - Restart the GUI or reboot your Toon.
 - Add the 'DomoMon' app like any other app to the screen.
    ( Click on a big + and add a tile for 'DomoMon' )

To configure :

 - After first startup there will be an empty tile with just a title "Domoticz".
 - Click on it to see the Limits Screen, click on the big button on the bottom to start the Settings Screen.
 - First enter your settings for user and password if you need these to access your Domoticz.
   ( When you need no user you can clear the fields by entering a single space or just leave the defaults in place )
 - After that enter the IP address and http port. ( default is 8080 )
 - ( When you want to change user and password after IP and port are ok you need to restart the GUI to re-login )
 - Now enter an idx of a Custom Sensor and the name of the Custom Sensor will be retrieved for you. Just wait...
 - When the idx does not exist it can not find the name and the name stays on wait...
 - You can change the name or just leave it for now. It may be too long for the tile and you may change it later.
 - To clear an idx you edit the field and put a space in it and save it. The name field will be cleared for you.
 - When you change an idx the new name will be retrieved for you. Just wait....
 - When you clear the name field by putting a space in it, the name will be retrieved from Domoticz again.
 - To save settings you need to click the Save button in the upper right corner.
 - To test settings just click the home button in the upper left corner. Changes are not save then. Remember to go back to this screen and click Save to save.
 - You can enter search strings and limits on the Search Strings/Limits Screen and use the home and Save buttons the same way.

The limits are including the value you give.
 - A low of 12.34 means less or equal to 12.34
 - A high of 98.76 means greater or equeal to 98.76

You can put text after a limit.
Examples for trailing text : 
    - units like                         : 10.12 kg
    - date of entering the limit like    : 1234 03-28

Search strings
 - Put a search string in the left field and when it is part of the data it will result in a low alarm.
 - Put a search string in the right field and when it is part of the data it will result in a high alarm.
 
Tile colors :
 - Neutral  : No alarms
 - Blue     : When at least one of the fields goes below a limit the tile will turn blue.
 - Red      : At least one value too high will result in the tile turning red.
 - Purple   : When one is too low and another too high the tile will go purple.

Limits Screen field colors :
 - Neutral  : field empty
 - Yellow   : limit value present
 - Blue     : low limit value in alarm
 - Red      : high limit in alarm
 
In the screenshots folder you can see on screenshot 3 and 5 that I, for demo purpose, entered wrong values for the "Aquacell zout" limits resulting in some colored limits on the Limits Screen and a purple Tile.

Notes.
 - Repeat the same idx on the same place in the 3 sets to have the Custom Sensor always vissible while the Tile pages.
 - There is no check on the Limits fields to validate if the low < high and high > low or values are numeric.
     Validation could be put on but we would miss some fun......
     Just to test, put a high in the low and a low in the high and the tile will have color.

Thanks for reading and enjoy.
