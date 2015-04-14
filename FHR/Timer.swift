//
//  Timer.swift
//  FHR
//
//  Created by Daniel Bevenius on 19/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public class Timer: NSObject {
    public typealias Callback = (Timer) -> ()

    private let start: NSTimeInterval
    private let callback: Callback
    private var timer: NSTimer!
    public let countDown: Double

    public convenience init(callback: Callback) {
        self.init(callback: callback, countDown: 0, startTime: NSDate.timeIntervalSinceReferenceDate())
    }

    public convenience init(callback: Callback, countDown: Double) {
        self.init(callback: callback, countDown: countDown, startTime: NSDate.timeIntervalSinceReferenceDate())
    }

    public init(callback: Callback, countDown: Double, startTime: NSTimeInterval) {
        self.callback = callback
        self.countDown = Double(countDown)
        start = startTime
        super.init()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("updateTime:"), userInfo: nil, repeats: true)
    }

    public class func fromTimer(timer: Timer, callback: Callback) -> Timer {
        return Timer(callback: callback, countDown: timer.countDown, startTime: timer.startTime())
    }

    public func stop() {
        timer.invalidate()
    }

    public func startTime() -> NSTimeInterval {
        return start
    }

    public func elapsedTime() -> (min: UInt8, sec: UInt8) {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime = countDown - (currentTime - start)
        if (elapsedTime < 0) {
            return (0, 0);
        }
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        return (minutes, UInt8(elapsedTime))
    }

    public class func timeAsString(min: UInt8, sec: UInt8) -> String {
        return "\(prefix(min)):\(prefix(sec))"
    }

    private class func prefix(time: UInt8) -> String {
        let timeStr = String(time)
        return time > 9 ? timeStr: "0" + timeStr
    }

    public func updateTime(timer: NSTimer) {
        callback(self)
    }

}
