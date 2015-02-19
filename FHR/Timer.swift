//
//  Timer.swift
//  FHR
//
//  Created by Daniel Bevenius on 19/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public class Timer {
    public typealias Callback = (NSTimer) -> ()

    private let start: NSTimeInterval
    private let callback: Callback
    private let timer: NSTimer!
    private let countDown: Double

    public convenience init(callback: Callback) {
        self.init(callback: callback, countDown: 0)
    }

    public init(callback: Callback, countDown: Int) {
        self.callback = callback
        self.countDown = Double(countDown * 60)
        start = NSDate.timeIntervalSinceReferenceDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("update:"), userInfo: nil, repeats: true)
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
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        let seconds = UInt8(elapsedTime)
        //elapsedTime -= NSTimeInterval(seconds)
        return (minutes, seconds)
    }

    public class func timeAsString(min: UInt8, sec: UInt8) -> String {
        //let strMinutes = prefix(min)
        //let strSeconds = prefix(sec)
        return "\(prefix(min)):\(prefix(sec))"
    }

    private class func prefix(time: UInt8) -> String {
        let timeStr = String(time)
        return time > 9 ? timeStr: "0" + timeStr
    }

    func update(timer: NSTimer) {
        callback(timer)
    }

}
