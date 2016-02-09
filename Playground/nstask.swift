import Cocoa
import Foundation

var task: NSTask = NSTask()
var pipe: NSPipe = NSPipe()

task.launchPath = "/bin/ls"
task.arguments = ["-la"]
task.standardOutput = pipe
task.launch()

var handle = pipe.fileHandleForReading
var data = handle.readDataToEndOfFile()
var result_s = NSString(data: data, encoding: NSUTF8StringEncoding)

print(result_s)

// chmod +x nstask.swift
// xcrun swift nstask.swift -f /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/Library/Frameworks
