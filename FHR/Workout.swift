//
//  Workout.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

public class Workout: NSManagedObject, WorkoutProtocol {

    @NSManaged public var modelName: String
    @NSManaged public var modelDescription: String
    @NSManaged public var modelLanguage: String
    @NSManaged public var modelCategories: String
    @NSManaged public var modelType: String
    @NSManaged public var modelImage: NSData
    @NSManaged public var reps: RepsWorkout?
    @NSManaged public var timed: DurationWorkout?

    public func name() -> String {
        return modelName
    }

    public func desc() -> String {
        return modelDescription
    }

    public lazy var lazyCategories: [Category] = {
        // needs to be unowned otherwise a strong ref will hang around
        // after ARC has set a ref to self to nil.
        [unowned self] in
        let array = split(self.modelCategories) { $0 == "," }
        return array.map { Category(rawValue: $0)! }
        }()

    public func categories() -> [Category] {
        return lazyCategories;
    }

    public func language() -> String {
        return modelLanguage
    }

    public func image() -> NSData {
        return modelImage
    }

    public func type() -> Type {
        if let r = reps {
            return r.type()
        }
        if let t = timed {
            return t.type()
        }
        fatalError("Neither reps or timed workout!")
    }

}
