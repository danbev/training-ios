# Faster Harder Stronger

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

