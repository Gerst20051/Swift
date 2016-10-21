import Cocoa
import Foundation

let task = Process()
let pipe = Pipe()

task.launchPath = "/bin/ls"
task.arguments = ["-la"]
task.standardOutput = pipe
task.launch()

let handle = pipe.fileHandleForReading
let data = handle.readDataToEndOfFile()
let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)

print(output)

// chmod +x nstask.swift
// xcrun swift nstask.swift -f /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/Library/Frameworks
