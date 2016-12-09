//
//  Timer.swift
//  FHR
//
//  Created by Daniel Bevenius on 30/05/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

open class Timer: NSObject {
    public typealias Callback = (Timer) -> ()

    fileprivate let start: TimeInterval
    fileprivate let callback: Callback
    fileprivate var timer: Foundation.Timer!

    public convenience init(callback: @escaping Callback) {
        self.init(callback: callback, startTime: Date.timeIntervalSinceReferenceDate)
    }

    public init(callback: @escaping Callback, startTime: TimeInterval) {
        self.callback = callback
        start = startTime
        super.init()
        timer = Foundation.Timer.scheduledTimer(timeInterval: 0.01, target:self, selector: #selector(Timer.updateTime(_:)), userInfo: nil, repeats: true)
    }

    open class func fromTimer(_ timer: Timer, callback: @escaping Callback) -> Timer {
        return Timer(callback: callback, startTime: timer.startTime())
    }

    open func stop() {
        timer.invalidate()
    }

    open func startTime() -> TimeInterval {
        return start
    }

    open func isDone() -> Bool {
        let t = elapsedTime()
        return t.min == 0 && t.sec <= 0
    }

    open func duration() -> Double {
        let currentTime = Date.timeIntervalSinceReferenceDate
        return currentTime - start
    }

    open func elapsedTime() -> (min: UInt8, sec: UInt8, fra: UInt8) {
        let currentTime = Date.timeIntervalSinceReferenceDate
        var elapsedTime: TimeInterval = currentTime - start
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        let fraction = UInt8(elapsedTime * 100)
        return (minutes, seconds, fraction)
    }

    open class func elapsedTime(_ duration: Double) -> (min: UInt8, sec: UInt8, fra: UInt8) {
        var elapsedTime: TimeInterval = duration
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        let fraction = UInt8(elapsedTime * 100)
        return (minutes, seconds, fraction)
    }

    open class func timeAsString(_ min: UInt8, sec: UInt8, fra: UInt8) -> String {
        return "\(prefix(min)):\(prefix(sec)):\(prefix(fra))"
    }

    fileprivate class func prefix(_ time: UInt8) -> String {
        let timeStr = String(time)
        return time > 9 ? timeStr: "0" + timeStr
    }

    open func updateTime(_ timer: Foundation.Timer) {
        callback(self)
    }
    
}
