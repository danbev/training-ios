# Faster Harder Stronger
A simple app to simulates the training I was used to before becoming a parent. What I liked with my training was that it was instense which meant that there was no time to think of anything else but the current excersice. I also liked that we never knew what was coming for each session. The only thing we knew was that one day would be upperbody, one day lowerbody, one day cardio. So this is what I set out to create. I will still be doing session in a group but I won't be able to do that three times a week as I used to which is the reason for creating it.

## Features  
* Randomized workouts, without repeating a previous exercise
* Add workouts using the app
* History that shows the lastest workout time for a given execerise

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
