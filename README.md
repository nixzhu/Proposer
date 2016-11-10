<p>
<a href="http://cocoadocs.org/docsets/Proposer"><img src="https://img.shields.io/cocoapods/v/Proposer.svg?style=flat"></a>
<a href="https://github.com/Carthage/Carthage/"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
</p>

# Proposer

Proposer provides a single API to request permission for access **Camera**, **Photos**, **Microphone**, **Contacts**, **Reminders**, **Calendar**, **Location** or **Notifications**.

## Requirements

Swift 3.0, iOS 8.0

(Swift 2.3, use version 0.9.1)

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
    let photos: PrivateResource = .photos
    let propose: Propose = {
        proposeToAccess(photos, agreed: {
            print("I can access Photos. :]\n")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .savedPhotosAlbum
                self.present(imagePicker, animated: true, completion: nil)
            }
        }, rejected: {
            self.alertNoPermissionToAccess(photos)
        })
    }
    showProposeMessageIfNeedFor(photos, andTryPropose: propose)
}
```

When you want to get user's location, thanks to Swift's enum, you can even choose the usage mode:

```swift
@IBAction func shareLocation() {
    let location: PrivateResource = .location(.whenInUse)
    let propose: Propose = {
        proposeToAccess(location, agreed: {
            print("I can access Location. :]\n")
        }, rejected: {
            self.alertNoPermissionToAccess(location)
        })
    }
    showProposeMessageIfNeedFor(location, andTryPropose: propose)
}
```

Depending on your needs, you must add a `NSLocationWhenInUseUsageDescription` or `NSLocationAlwaysUsageDescription` to your Info.plist

See the demo for more information.

I recommend you add a `UIViewController+Proposer.swift` file (like the demo) for show localized alert before the first proposal or when propose failed.

## Installation

Feel free to drag `Proposer.swift` to your iOS Project. But it's recommended to use Carthage (or CocoaPodsr) .

### Carthage

```ogdl
github "nixzhu/Proposer" >= 1.1.0
```

#### CocoaPods

```ruby
pod 'Proposer', '~> 1.1.0'
```

# Contact

NIX [@nixzhu](https://twitter.com/nixzhu)

## License

Proposer is available under the MIT license. See the LICENSE file for more info.
