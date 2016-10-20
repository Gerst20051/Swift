//: Playground - noun: a place where people can play

import UIKit

var mainWidth: CGFloat = 320.0
var columnWidth: CGFloat = mainWidth / 3.0
var remainder = columnWidth.truncatingRemainder(dividingBy: floor(columnWidth))


var test = "en_US,fr_CA,es_US"

var arr = test.characters.split { $0 == "," }.map { String($0) }.map { $0.characters.split { $0 == "_" }.map { String($0) } }.map { $0.first! }
arr

NSUUID().uuidString
