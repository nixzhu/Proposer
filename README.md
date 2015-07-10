# Proposer

Proposer provides a simple API to request permission for access Camera, Photos, Microphone, Contacts, Location.

## Example

Only one single API:

```swift
proposeToAccess(resource:succeeded:failed:)
```

In real world:

```swift
@IBAction func choosePhoto() {

    let photos: PrivateResource = .Photos

    proposeToAccess(photos, succeeded: {
        print("I can access Photos. :]\n")

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .SavedPhotosAlbum

            self.presentViewController(imagePicker, animated: true, completion: nil)
        }

    }, failed: {
        self.alertNoPermissionToAccess(photos)
    })
}
```

See the demo for more information.

I recommend you add a `UIViewController+Proposer.swift` file (like the demo) for show localized alert before propose or when propose failed.

## Installation

Feel free to drag `Proposer.swift` to your iOS Project. Or use CocoaPods.

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ [sudo] gem install cocoapods
```

To integrate Wormhole into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Proposer', '~> 0.5'
```

Then, run the following command:

```bash
$ pod install
```

You should open the `{Project}.xcworkspace` instead of the `{Project}.xcodeproj` after you installed anything from CocoaPods.

For more information about how to use CocoaPods, I suggest [this tutorial](http://www.raywenderlich.com/64546/introduction-to-cocoapods-2).

## License

Proposer is available under the MIT license. See the LICENSE file for more info.