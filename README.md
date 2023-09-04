# Running 

## Overview 

This is an iOS app which allows a user to:
- Fetch their HealthKit based running workouts 
- Set distance based goals (e.g. a weekly running target)

## Technical Details 

### Architecture 

The app is built using [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) and generally follows the "TCA Style" which includes:
- Small frameworks (e.g. one framework per screen)
- SPM used for framework creation with a simple Xcodeproj importing local packages
- Controlled dependencies (HealthKit is abstracted as a dependency allowing the app to run in a preview / simulator)
- Unit tests for feature logic (including navigation)

### Support

The app runs on iOS 17+. The main reason for this limitation is to use SwiftData as a caching layer  
