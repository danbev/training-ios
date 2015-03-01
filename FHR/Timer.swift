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
    private let timer: NSTimer!
    private let countDown: Double

    public convenience init(callback: Callback) {
        self.init(countDown: 0, callback: callback)
    }

    public init(countDown: Int, callback: Callback) {
        self.callback = callback
        self.countDown = Double(countDown * 60)
        start = NSDate.timeIntervalSinceReferenceDate()
        super.init()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("updateTime:"), userInfo: nil, repeats: true)
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