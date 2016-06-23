import Cocoa
import Foundation

var task: NSTask = NSTask()
var pipe: NSPipe = NSPipe()

// task.launchPath = "DIFFDIR=\"$HOME/diffcheck/\" && mkdir -p \"$DIFFDIR\" && mv -f \"$DIFFDIR/currentclean.json\" \"$DIFFDIR/old.json\" 2>/dev/null; true && DIFFURL=\"https://passportmobile.net/builds/330/mobile/api/index.php/getstrings?locale=en_US&operatorId=117&system=Mobile\" && curl --silent -o \"$DIFFDIR/current.json\" \"$DIFFURL\" && jq '.' \"$DIFFDIR/current.json\" > \"$DIFFDIR/currentclean.json\" && diffchecker --expires day \"$DIFFDIR/old.json\" \"$DIFFDIR/currentclean.json\""

task.launchPath = "/usr/local/bin/diffchecker"

// task.launchPath = "/bin/ls"
// task.arguments = ["-la"]
task.standardOutput = pipe
task.launch()

var handle = pipe.fileHandleForReading
var data = handle.readDataToEndOfFile()
var result_s = NSString(data: data, encoding: NSUTF8StringEncoding)

print(result_s)
