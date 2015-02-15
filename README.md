# Faster Harder Stronger

## Prerequisites 
Xcode Version 6.1.1

## Building

Building can be done by opening the project in Xcode:

    open FHR.xcworkspace

or you can use the command line:

    xcodebuild -project FHR.xcodeproj -scheme FHR -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO

Please make sure that you are running the correct version of Xcode also on the command line. You can check
your version using:

    xcode-select -p

To set the version to different version:

    sudo xcode-select -switch /Applications/Xcode_version
    

## Testing
Tests can be run from with in Xcode using Product->Test menu option (CMD+U).  
You can also run test from the command:

    xcodebuild -project FHR.xcodeproj -scheme FHR -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO -destination 'platform=iOS Simulator,name=iPhone 5s'  test


## Data model
### Types of workouts
#### Duration based
One excercise for a certain amount of time.

#### Repition based
One excercise performed a certain number of times.
When do we do rep based? 
We do 100 (up to ten and back down again)
We to repbased during with two alternating excercises. For example:
10 stot, 10 Luitenant dan.

#### Interval based
Two excercises where one it the main excercies and the other is the "rest" excercise.
The two excercies would be of type Duration based. 

#### Warmup
Should warmup be separate. In almost all cases these would be duration based.

#### Rest
Not a warmup per say but something that each workout should define. Some excercises will require a longer rest period than others.
Perhaps this could be returned from a completed workout. 

## Workout types

### Upper body

### Lower body

### Carido

All workouts except possibly warmup will need to have a rest period after it. 
When a workout is done, focus should return to the main screen and display a countdown of resting time. 
During this time, the next workout task should also be visible incase the users does not know how to perform it.

When the rest timer expires, it should automatically display the next workout view and start it. 

The workout view:
We need instructions, but these will most often only be needed once or twice. After learning the exercise people will get 
the hang of it and just do it. 
The rest countdown should be displayed on the workout view as well. If users need more details about the workout, there should be
an info icon. When clicking that icon the description and the image can be displayed. This could possibly show a new view with that
information, and at the same time stop the rest count down to give the user time to read/watch the instructions video.


Do we need an id for each workout? 
How do we enable adding new workouts.

### Workout object
__name__
The name of the workout.

__desc__
A text description of the workout. 
