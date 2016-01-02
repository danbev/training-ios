# Faster Harder Stronger
A simple app to simulates the training I was used to before going on parental leave. What I liked with my training was that it was instense which meant that there was no time to think of anything else but the current excersice. I also liked that we never knew what was coming for each session. The only thing we knew was that one day would be upperbody, one day lowerbody, one day cardio. So this is what I set out to create. 

## Features  
* Randomized workouts, without repeating a previous exercise
* Add workouts using the app
* History that shows the lastest workout time for a given execerise

See [Screen shots](#screen-shots) to get an ide of what the app looks like visually.

## Coming soon
* The ability to upload/send workouts to be added to the main store of workouts.
* Add more items to this list I have many ideas (but not enough time :) )

## Known issues
* After upgrading to Swift 2.0 I the manual addition of repition based workouts and prebens workouts stopped working. 
* The UI looks terrible on Iphone 4.0 and earlier. This will be investigated further


## Building

Building can be done by opening the project in Xcode:

    open FHS.xcodeproj

or you can use the command line:

    xcodebuild -project FHS.xcodeproj -scheme FHS -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO

Please make sure that you are running the correct version of Xcode also on the command line. You can check
your version using:

    xcode-select -p

To set the version to different version:

    sudo xcode-select -switch /Applications/Xcode_version
    

## Testing
Tests can be run from with in Xcode using Product->Test menu option (CMD+U).  
You can also run test from the command:

    xcodebuild -project FHS.xcodeproj -scheme FHS -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO -destination 'platform=iOS Simulator,name=iPhone 5s'  test


## Creating new workout stores

    xcodebuild -project FHS.xcodeproj -scheme StoreCreator install

## Screen shots
### Main screen  
![Main screen](./docs/images/main.png?raw=true)

### Repition based workout screen  
![Repition workout screen](./docs/images/reps_workout.png?raw=true)

### Duration based workout screen
![Duration workout screen](./docs/images/duration_workout.png?raw=true)

### Settings screen 
![Settings screen](./docs/images/settings.png?raw=true)

### Workout stores screen 
This screen allow you to choose which stores workouts will be chosen from. 
_FHS_ is the default store that ships with the app.
_testing_ is also shipped with the app and contains workouts with short workout and rest times so one does not have to wait too long to manually test things.
_UserWorkouts_ is created when a workout is added using the app.
![Stores screen](./docs/images/stores.png?raw=true)

### Create workout settings screen
![Create workout settings screen](./docs/images/add_workout_settings.png?raw=true)
