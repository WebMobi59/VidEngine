//
//  Math.swift
//
//  Created by David Gavilan on 3/19/16.
//  Copyright © 2016 David Gavilan. All rights reserved.
//

import Foundation
import UIKit

let PI      : Float = 3.1415926535897932384626433832795
let PI_2    = 0.5 * PI
let PI2     = 2.0 * PI
let PI_INV  = 1.0 / PI
let NORM_SQR_ERROR_TOLERANCE : Float = 0.001
let π       : Double = Double(PI)

/// Converts angle in degrees to radians
func DegToRad(angle: Float) -> Float {
    return angle * (PI/180.0)
}
/// Gets the sign of a number
func Sign(n: Float) -> Float {
    return (n>=0) ?1:-1
}
/// Max
func Max(a: CGFloat, b: CGFloat) -> CGFloat {
    return (a>=b) ?a:b
}
func Max(a: Float, b: Float) -> Float {
    return (a>=b) ?a:b
}
func Max(a: Int, b: Int) -> Int {
    return (a>=b) ?a:b
}
/// Min
func Min(a: CGFloat, b: CGFloat) -> CGFloat {
    return (a<=b) ?a:b
}
func Min(a: Float, b: Float) -> Float {
    return (a<=b) ?a:b
}
func Min(a: Int, b: Int) -> Int {
    return (a<=b) ?a:b
}
/// Ceil for ints
func CeilDiv(a: Int, b: Int) -> Int {
    return (a + b - 1) / b
}
/// Clamp
func Clamp(value: CGFloat, lowest: CGFloat, highest: CGFloat) -> CGFloat {
    return (value<lowest) ?lowest:(value>highest) ?highest:value
}
func Clamp(value: Float, lowest: Float, highest: Float) -> Float {
    return (value<lowest) ?lowest:(value>highest) ?highest:value
}
func Clamp(value: Int, lowest: Int, highest: Int) -> Int {
    return (value<lowest) ?lowest:(value>highest) ?highest:value
}
/// Random Int. Preferred to rand() % upperBound
func Rand(upperBound: UInt32) -> UInt32 {
    return arc4random_uniform(upperBound)
}
/// Random Float between 0 and 1
func Randf() -> Float {
    return Float(Rand(10000)) * 0.0001
    // or use drand48? needs a seed srand48
}
/// Random sign
func RandSign() -> Float {
    return (Rand(2) == 0 ? -1.0 : 1.0)
}
/// Random event with given probabily
func RandEvent(probality: Float) -> Bool {
    let r = Float(Rand(10000))
    return r < 10000.0 * probality
}
extension Array {
    func shuffled() -> [Element] {
        var list = self
        for i in 0..<(list.count - 1) {
            // I need a seeded rand() to make it deterministic
            let upperBound = UInt32(list.count - i)
            let j = Int(UInt32(rand()) % upperBound) + i
            //let j = Int(arc4random_uniform(upperBound)) + i
            guard i != j else { continue }
            swap(&list[i], &list[j])
        }
        return list
    }
}
