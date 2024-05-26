# Running 

## Overview 

This is an iOS app which allows a user to:
- Fetch their HealthKit based running workouts 
- Set distance based goals (e.g. a weekly running target)
- View a summary of goals in widget(s)

The app is built as a combination of a place to experiment with new features (iOS / TCA) and to create a simple app I wanted to use. The app is available on the [App Store](https://apps.apple.com/gb/app/running-goals/id6463000485) but it might not be up to date there since I mostly install via TestFlight

### Features 

| Goals | Goal Detail | Runs | Widgets |
| --- | --- | --- | --- |
| ![Simulator Screenshot - iPhone 14 Pro Max - 2023-09-04 at 20 49 14](https://github.com/wattson12/Running/assets/1217873/4b08557f-f629-4790-91c0-a9bd3ea88c4b) | ![Simulator Screenshot - iPhone 14 Pro Max - 2023-09-04 at 20 49 28](https://github.com/wattson12/Running/assets/1217873/e57ecf6c-9b23-4766-8511-fbb9674a1f32) | ![Simulator Screenshot - iPhone 14 Pro Max - 2023-09-04 at 20 49 31](https://github.com/wattson12/Running/assets/1217873/90af42b8-f235-42ab-a1c1-9cac5af9184d) | ![Simulator Screenshot - iPhone 14 Pro Max - 2023-09-04 at 20 57 12](https://github.com/wattson12/Running/assets/1217873/6ced2a3c-377f-4527-bee6-8b39be4b2bec) |

There are also some rougher / WIP features hidden behind feature flags (flags are toggleable in the settings menu when running from Xcode / TestFlight builds)

## Technical Details 

### Architecture 

The app is architected using [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) and generally follows the "TCA Style" which includes:
- Small frameworks (e.g. one framework per screen)
- SPM used for framework creation with a simple Xcode project importing local packages
- Controlled dependencies (e.g. HealthKit is abstracted as a dependency allowing the app to run more predictably in a preview / simulator)
- Unit tests (not as much as I would write if I was getting paid for this, but some basics are covered)

All UI is in SwiftUI 

### Tooling 

- [SwiftGen](https://github.com/SwiftGen/SwiftGen) for creating type safe references to resources
- [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) (via git hook) to format the code
