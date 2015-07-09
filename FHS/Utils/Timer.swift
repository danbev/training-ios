//
//  Timer.swift
//  FHR
//
//  Created by Daniel Bevenius on 30/05/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public class Timer: NSObject {
    public typealias Callback = (Timer) -> ()

    private let start: NSTimeInterval
    private let callback: Callback
    private var timer: NSTimer!

    public convenience init(callback: Callback) {
        self.init(callback: callback, startTime: NSDate.timeIntervalSinceReferenceDate())
    }

    public init(callback: Callback, startTime: NSTimeInterval) {
        self.callback = callback
        start = startTime
        super.init()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target:self, selector: Selector("updateTime:"), userInfo: nil, repeats: true)
    }

    public class func fromTimer(timer: Timer, callback: Callback) -> Timer {
        return Timer(callback: callback, startTime: timer.startTime())
    }

    public func stop() {
        timer.invalidate()
    }

    public func startTime() -> NSTimeInterval {
        return start
    }

    public func isDone() -> Bool {
        let t = elapsedTime()
        return t.min == 0 && t.sec <= 0
    }

    public func duration() -> Double {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        return currentTime - start
    }

    public func elapsedTime() -> (min: UInt8, sec: UInt8, fra: UInt8) {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime: NSTimeInterval = currentTime - start
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        let fraction = UInt8(elapsedTime * 100)
        return (minutes, seconds, fraction)
    }

    public class func elapsedTime(duration: Double) -> (min: UInt8, sec: UInt8, fra: UInt8) {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime: NSTimeInterval = duration
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        let fraction = UInt8(elapsedTime * 100)
        return (minutes, seconds, fraction)
    }

    public class func timeAsString(min: UInt8, sec: UInt8, fra: UInt8) -> String {
        return "\(prefix(min)):\(prefix(sec)):\(prefix(fra))"
    }

    private class func prefix(time: UInt8) -> String {
        let timeStr = String(time)
        return time > 9 ? timeStr: "0" + timeStr
    }

    public func updateTime(timer: NSTimer) {
        callback(self)
    }
    
}
