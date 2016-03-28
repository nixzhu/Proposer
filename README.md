<p>
<a href="http://cocoadocs.org/docsets/Proposer"><img src="https://img.shields.io/cocoapods/v/Proposer.svg?style=flat"></a> 
<a href="https://github.com/Carthage/Carthage/"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a> 
</p>

# Proposer

Proposer provides a single API to request permission for access **Camera**, **Photos**, **Microphone**, **Contacts**, **Reminders**, **Calendar** or **Location**.

## Requirements

Swift 2.0, iOS 8.0

## Example

Only one single API:

```swift
proposeToAccess(_:agreed:rejected:)
```

In real world:

```swift
import Proposer
```

```swift
@IBAction func choosePhoto() {

    let photos: PrivateResource = .Photos

    proposeToAccess(photos, agreed: {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .SavedPhotosAlbum

            self.presentViewController(imagePicker, animated: true, completion: nil)
        }

    }, rejected: {
        self.alertNoPermissionToAccess(photos)
    })
}
```

When you want to get user's location, thanks to Swift's enum, you can even choose the usage mode:

```swift
@IBAction func shareLocation() {

    let location: PrivateResource = .Location(.WhenInUse)
    
    proposeToAccess(location, agreed: {
        print("I can access Location. :]\n")
        
    }, rejected: {
        self.alertNoPermissionToAccess(location)
    })
}
```

Depending on your needs, you must add a `NSLocationWhenInUseUsageDescription` or `NSLocationAlwaysUsageDescription` to your Info.plist

See the demo for more information.

I recommend you add a `UIViewController+Proposer.swift` file (like the demo) for show localized alert before the first proposal or when propose failed.

## Installation

Feel free to drag `Proposer.swift` to your iOS Project. But it's recommended to use CocoaPods or Carthage.

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ [sudo] gem install cocoapods
```

To integrate Proposer into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Proposer', '~> 0.8.0'
```

Then, run the following command:

```bash
$ pod install
```

You should open the `{Project}.xcworkspace` instead of the `{Project}.xcodeproj` after you installed anything from CocoaPods.

For more information about how to use CocoaPods, I suggest [this tutorial](http://www.raywenderlich.com/64546/introduction-to-cocoapods-2).

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager for Cocoa application. To install the carthage tool, you can use [Homebrew](http://brew.sh).

```bash
$ brew update
$ brew install carthage
```

To integrate Proposer into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "nixzhu/Proposer" >= 0.8.0
```

Then, run the following command to build the Proposer framework:

```bash
$ carthage update
```

At last, you need to set up your Xcode project manually to add the Proposer framework.

On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, drag and drop each framework you want to use from the Carthage/Build folder on disk.

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script with the following content:

```
/usr/local/bin/carthage copy-frameworks
```

and add the paths to the frameworks you want to use under “Input Files”:

```
$(SRCROOT)/Carthage/Build/iOS/Proposer.framework
```

For more information about how to use Carthage, please see its [project page](https://github.com/Carthage/Carthage).

## Contact

NIX [@nixzhu](https://twitter.com/nixzhu)

## License

Proposer is available under the MIT license. See the LICENSE file for more info.
