// true: Capture will automatically begin upon mission start
// false: Capture will not begin until set to true (e.g. in mission init.sqf AND ocap_main_minPlayerCount is met.
// Setting to false allows for mission-specific capture
ocap_main_capture = true;

// true: Export capture files to a remote server via FTP (use if web server and game server are separate boxes
// false: Export capture files locally (use if web server and game server run on the same box
ocap_main_exportRemote = false;

/*
== Remote details ==
Configure these values if ocap_main_exportRemote = true
NOTE: This feature is not yet implemented

Please setup a new FTP user on your web server with it's
default/home directory set to the /data/ directory in the web files.
Ensure the user has write access to that directory.
*/
ocap_main_exportHost = ""; // URL/IP of your FTP server
ocap_main_exportUsername = "";
ocap_main_exportPassword = "";
// == Remote details end ==


/*
== Local details ==
Configure these values if ocap_main_exportRemote = false
*/
// Absolute path to OCAP web root directory (must include trailing '/'
ocap_main_exportPath = "C:/apache/htdocs/ocap/"; // e.g. "C:/apache/htdocs/ocap/"
// == Local details end ==


ocap_main_exportURL = "http://localhost/ocap/"; // URL to OCAP root directory (must include trailing '/'
ocap_main_frameCaptureDelay = 1; // Delay between each frame capture. Default: 1
ocap_main_minPlayerCount = 1; // Minimum player count before capture begins. Set this to 0 for immediate capture (assuming ocap_main_endCaptureOnNoPlayers = false

// End (and export capture once players are no longer present
ocap_main_endCaptureOnNoPlayers = true;

ocap_main_debug = true; // Debug mode
