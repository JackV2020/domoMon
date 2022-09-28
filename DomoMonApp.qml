import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0;
import FileIO 1.0

App {

    property url tileURL : "DomoMonTile.qml"

	property url limitsURL : "DomoMonLimits.qml"
	property DomoMonLimits domomonLimits

	property url settingsURL : "DomoMonSettings.qml"
	property DomoMonSettings domomonSettings

    property bool activeMe : false

// ---------- tile croll count

    property int scrollCounter : 0

// data saved in user settings file

    property string settingFile : "file:///mnt/data/tsc/domomon.userSettings.json";

    property variant deviceName : []
    property variant deviceIdx : []
    property variant deviceValue : []
    property variant deviceLolim : []
    property variant deviceHilim : []
    property variant deviceLoAlarm : []
    property variant deviceHiAlarm : []

    property string ipAddress
    property string httpPort
    property string user
    property string pwd
    property string domoInterval

// fields on tile

    property string device1
    property string value1
    property string device2
    property string value2
    property string device3
    property string value3
    property string device4
    property string value4
    property string device5
    property string value5
    property string device6
    property string value6

    property bool freezeScroll;

// Tile alarm control

    property bool alarmlow	: false
    property bool alarmhigh : false
// blue
    property string lowTileColor : "#00f4ff"
// red
    property string highTileColor : "#ff0000"
// purple
    property string lowhighTileColor : "#ff00f4"

// Tile text color

// black on blue
    property string lowTileTextColor : "#000000"
// white on red
    property string highTileTextColor : "#ffffff"
// white on purple
    property string lowhighTileTextColor : "#ffffff"

// ---------- variable to receive data from Domoticz

	property variant dataJSON

// ---------- Location of settings file

	FileIO {
		id: userSettingsFile
		source: settingFile
 	}

// ---------- user settings from settings file

	property variant userSettingsJSON : {}

// ---------- Load the requirements

    function init() {

        const args = {
        thumbCategory: "general",
        thumbLabel: "DomoMon",
        thumbIcon: "qrc:/tsc/DomoticzSystrayIcon.png",
        thumbIconVAlignment: "center",
        thumbWeight: 30
        }

        registry.registerWidget("tile", tileURL, this, null, args);

        registry.registerWidget("screen", limitsURL, this, "domomonLimits");

        registry.registerWidget("screen", settingsURL, this, "domomonSettings");

    }

// ---------- Actions right after startup

	Component.onCompleted: {
		// read user settings
		try {
			userSettingsJSON = JSON.parse(userSettingsFile.read());

            var ii = 0

            for (ii = 0; ii < 18 ; ii++) {
                deviceLoAlarm.push( false )
                deviceHiAlarm.push( false )
            }

			ipAddress = userSettingsJSON['ipAddress'];
			httpPort = userSettingsJSON['httpPort'];
			if (httpPort.length < 2) httpPort = "8080";
			user = userSettingsJSON['user'];
			pwd = userSettingsJSON['pwd'];
			domoInterval = userSettingsJSON['domoInterval'];
			if (domoInterval.length < 2) domoInterval = "60";

			freezeScroll = (userSettingsJSON['freezeScroll'] == "yes") ? true : false
            deviceName  = userSettingsJSON['deviceName'].slice()
            deviceIdx   = userSettingsJSON['deviceIdx'].slice()
            deviceValue = userSettingsJSON['deviceValue'].slice()
            deviceLolim = userSettingsJSON['deviceLolim'].slice()
            deviceHilim = userSettingsJSON['deviceHilim'].slice()

            readDomoticzdevicesData()

		} catch(e) {

            var ii = 0

            for (ii = 0; ii < 18 ; ii++) {
                deviceName.push("x")
                deviceIdx.push("x")
                deviceValue.push("x")
                deviceLolim.push("x")
                deviceHilim.push("x")
                deviceLoAlarm.push(false)
                deviceHiAlarm.push(false)

                deviceName[ii] = ""
                deviceIdx[ii] = ""
                deviceValue[ii] = ""
                deviceLolim[ii] = ""
                deviceHilim[ii] = ""
            }

            ipAddress = ""
			httpPort = "8080"
            user = "view"
            pwd = "view"
            domoInterval = "10"
            freezeScroll = true
        }
	}

// ---------- Save user settings

	function saveSettings(){

 		var tmpUserSettingsJSON = {
            "ipAddress": ipAddress,
            "httpPort": httpPort,
            "user": user,
            "pwd": pwd,
            "domoInterval" : domoInterval,
            "freezeScroll" : (freezeScroll) ? "yes" : "no",

            "deviceName"  : deviceName,
            "deviceIdx"   : deviceIdx,
            "deviceValue" : deviceValue,
            "deviceLolim" : deviceLolim,
            "deviceHilim" : deviceHilim

		}

  		var doc3 = new XMLHttpRequest();
   		doc3.open("PUT", settingFile);
   		doc3.send(JSON.stringify(tmpUserSettingsJSON));
	}

// ---------------------------------------------------------------------

    function log(tolog) {

        var now      = new Date();
        var dateTime = now.getFullYear() + '-' +
                ('00'+(now.getMonth() + 1)   ).slice(-2) + '-' +
                ('00'+ now.getDate()         ).slice(-2) + ' ' +
                ('00'+ now.getHours()        ).slice(-2) + ":" +
                ('00'+ now.getMinutes()      ).slice(-2) + ":" +
                ('00'+ now.getSeconds()      ).slice(-2) + "." +
                ('000'+now.getMilliseconds() ).slice(-3);
        console.log(dateTime+' DomoMon : ' + tolog.toString())

    }

// ---------- Get Domoticz data

    function readDomoticzdevicesData()  {

        var connectionPath = ipAddress + ":" + httpPort;

        if ( connectionPath.length > 4 ) {

            var ii = 0

            var newalarmlow = false
            var newalarmhigh = false

            for (ii = 0; ii < 18 ; ii++) {

              deviceValue[ii] = "";
              deviceLoAlarm[ii] = false;
              deviceHiAlarm[ii] =  false;

              if (deviceIdx[ii] != "" ) {

                var xmlhttp = new XMLHttpRequest();

//                log("http://"+connectionPath+"/json.htm?type=devices&rid="+deviceIdx[ii]+"&username=" + Qt.btoa(user) + "&password=" + Qt.btoa(pwd));
                xmlhttp.open("GET", "http://"+connectionPath+"/json.htm?type=devices&rid="+deviceIdx[ii]+"&username=" + Qt.btoa(user) + "&password=" + Qt.btoa(pwd), false); // leave this false because we make a lot of requests.

                xmlhttp.timeout = 200; // time in milliseconds

                xmlhttp.ontimeout = function () {
//        XMLHttpRequest timed out. Do something here.
// this does not seem to be supported so I use xmlhttp.status below to detect all errors
                    log("timeout for "+ii);
                    value1 = value2 = value3 = value4 = value5 = value6 = "0";
                }

                xmlhttp.onreadystatechange = function() {

                    if (xmlhttp.readyState == XMLHttpRequest.DONE) {

                        if (xmlhttp.status === 200) {

                            dataJSON = JSON.parse(xmlhttp.responseText);

                            var SubType = "";
                            deviceValue[ii] = "";

                            try {
                                SubType = dataJSON['result'][0]['SubType'];
                            } catch(e) {
                                SubType = "unknown";
                                deviceValue[ii] = "idx Error"
                                log("Ongeldige idx : "+deviceIdx[ii]);
                                newalarmlow = true;
                                newalarmhigh = true;
                            }

                            if (deviceValue[ii] == "") {

                                if (deviceName[ii] == '' || deviceName[ii] == '..wait......') { deviceName[ii] = dataJSON['result'][0]['Name'] }

                                var value_ok = false;

// Try to get data from 'Data' or from 'Level', maybe other fields need to be added in future

                                try {
                                    deviceValue[ii] = dataJSON['result'][0]['Data']
                                    value_ok = true;
                                } catch(e) {
                                    if (SubType == "Selector Switch") {
                                        deviceValue[ii] = dataJSON['result'][0]['Level']+" %";
                                        value_ok = true;
                                    }
                                }
// Alarming
                                if ( ! value_ok ) {
                                    deviceValue[ii] = "Subtype Error";
                                    newalarmlow = true;
                                    newalarmhigh = true;
                                } else {
// If text value, maybe more text SubTypes to follow in the future.....
                                    if (
                                        (SubType == "Alert")                ||
                                        (SubType == "Switch")               ||
                                        (SubType == "Text")
                                    ) {
                                        if (deviceLolim[ii] != '') { deviceLoAlarm[ii] =            deviceValue[ii].search(deviceLolim[ii] ) >= 0 }
                                        if (deviceHilim[ii] != '') { deviceHiAlarm[ii] =            deviceValue[ii].search(deviceHilim[ii] ) >= 0 }
// else numeric value
                                    } else {
                                        if (deviceLolim[ii] != '') { deviceLoAlarm[ii] =          ( parseFloat(deviceValue[ii]) <= parseFloat(deviceLolim[ii]) ) }
                                        if (deviceHilim[ii] != '') { deviceHiAlarm[ii] =          ( parseFloat(deviceValue[ii]) >= parseFloat(deviceHilim[ii]) ) }
                                    }
                                    if (deviceLolim[ii] != '') { newalarmlow  = newalarmlow  || deviceLoAlarm[ii] }
                                    if (deviceHilim[ii] != '') { newalarmhigh = newalarmhigh || deviceHiAlarm[ii] }
                                }
                            }
                        } else {
                            log("timeout or communication error for "+ii+"  "+deviceIdx[ii]+"  "+deviceName[ii]);
                            newalarmlow = true;
                            newalarmhigh = true;
                        }
                    }
                }

                xmlhttp.send();

              }
            }

            alarmlow = newalarmlow
            alarmhigh = newalarmhigh

        } else {

            newalarmlow = true;
            newalarmhigh = true;
        }
    }

// ---------- Timer and refresh routine

// Timer in ms

	Timer {
		id: datetimeTimer
		interval: domoInterval * 1000
		running: activeMe
		repeat: true
		onTriggered: refreshScreen()
	}

	function refreshScreen() {

        readDomoticzdevicesData()

        if (dimState && freezeScroll) { scrollCounter = 0 }

        value1=deviceValue[ ( scrollCounter + 0 ) % deviceName.length ]
        value2=deviceValue[ ( scrollCounter + 1 ) % deviceName.length ]
        value3=deviceValue[ ( scrollCounter + 2 ) % deviceName.length ]
        value4=deviceValue[ ( scrollCounter + 3 ) % deviceName.length ]
        value5=deviceValue[ ( scrollCounter + 4 ) % deviceName.length ]
        value6=deviceValue[ ( scrollCounter + 5 ) % deviceName.length ]

        device1=deviceName[ ( scrollCounter + 0 ) % deviceName.length ]
        device2=deviceName[ ( scrollCounter + 1 ) % deviceName.length ]
        device3=deviceName[ ( scrollCounter + 2 ) % deviceName.length ]
        device4=deviceName[ ( scrollCounter + 3 ) % deviceName.length ]
        device5=deviceName[ ( scrollCounter + 4 ) % deviceName.length ]
        device6=deviceName[ ( scrollCounter + 5 ) % deviceName.length ]

//      prepare for next not empty screen of 6 devices by checking if there is at least 1 idx in that screen block

        var sumIdx = ""
        var ii = 0 // number of screens
        do {
            ii = ii + 1
            scrollCounter = (scrollCounter + 6) % deviceName.length // deviceName.length is number of elements in deviceName which is 18, result is 0, 6 or 12

            sumIdx = deviceIdx[scrollCounter + 0] + deviceIdx[scrollCounter + 1] + deviceIdx[scrollCounter + 2] + deviceIdx[scrollCounter + 3] + deviceIdx[scrollCounter + 4] + deviceIdx[scrollCounter + 5]
            sumIdx = sumIdx.replace(/\s+/g, '') // remove any spaces

        } while ( (sumIdx == '' ) && ( ii < 3 ) )

    }

// ---------- base64 encode and decode routines

// not used here because I found Qt.btoa

// btoa and atob alternatives found on  https://gist.github.com/oeon/0ada0457194ebf70ec2428900ba76255

  function b2a(a) {
    var c, d, e, f, g, h, i, j, o, b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=", k = 0, l = 0, m = "", n = [];
    if (!a) return a;
    do c = a.charCodeAt(k++), d = a.charCodeAt(k++), e = a.charCodeAt(k++), j = c << 16 | d << 8 | e,
    f = 63 & j >> 18, g = 63 & j >> 12, h = 63 & j >> 6, i = 63 & j, n[l++] = b.charAt(f) + b.charAt(g) + b.charAt(h) + b.charAt(i); while (k < a.length);
    return m = n.join(""), o = a.length % 3, (o ? m.slice(0, o - 3) :m) + "===".slice(o || 3);
  }

  function a2b(a) {
    var b, c, d, e = {}, f = 0, g = 0, h = "", i = String.fromCharCode, j = a.length;
    for (b = 0; 64 > b; b++) e["ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charAt(b)] = b;
    for (c = 0; j > c; c++) for (b = e[a.charAt(c)], f = (f << 6) + b, g += 6; g >= 8; ) ((d = 255 & f >>> (g -= 8)) || j - 2 > c) && (h += i(d));
    return h;
  }

}
