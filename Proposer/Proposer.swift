//
//  Proposer.swift
//  Lady
//
//  Created by NIX on 15/7/11.
//  Copyright (c) 2015年 nixWork. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AddressBook
import Contacts
import EventKit
import CoreLocation

public enum PrivateResource {
    case photos
    case camera
    case microphone
    case contacts
    case reminders
    case calendar
    public enum LocationUsage {
        case whenInUse
        case always
    }
    case location(LocationUsage)
    case notifications(UIUserNotificationSettings)

    public var isNotDeterminedAuthorization: Bool {
        switch self {
        case .photos:
            return PHPhotoLibrary.authorizationStatus() == .notDetermined
        case .camera:
            return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .notDetermined
        case .microphone:
            return AVAudioSession.sharedInstance().recordPermission() == .undetermined
        case .contacts:
            return ABAddressBookGetAuthorizationStatus() == .notDetermined
        case .reminders:
            return EKEventStore.authorizationStatus(for: .reminder) == .notDetermined
        case .calendar:
            return EKEventStore.authorizationStatus(for: .event) == .notDetermined
        case .location:
            return CLLocationManager.authorizationStatus() == .notDetermined
        case .notifications:
            return UIApplication.shared.notificationAuthorizationStatus == .notDetermined
        }
    }

    public var isAuthorized: Bool {
        switch self {
        case .photos:
            return PHPhotoLibrary.authorizationStatus() == .authorized
        case .camera:
            return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized
        case .microphone:
            return AVAudioSession.sharedInstance().recordPermission() == .granted
        case .contacts:
            return ABAddressBookGetAuthorizationStatus() == .authorized
        case .reminders:
            return EKEventStore.authorizationStatus(for: .reminder) == .authorized
        case .calendar:
            return EKEventStore.authorizationStatus(for: .event) == .authorized
        case .location(let usage):
            switch usage {
            case .whenInUse:
                return CLLocationManager.authorizationStatus() == .authorizedWhenInUse
            case .always:
                return CLLocationManager.authorizationStatus() == .authorizedAlways
            }
        case .notifications:
            return UIApplication.shared.notificationAuthorizationStatus == .authorized
        }
    }
}

public typealias Propose = () -> Void
public typealias ProposerAction = () -> Void

public func proposeToAccess(_ resource: PrivateResource, agreed successAction: @escaping ProposerAction, rejected failureAction: @escaping ProposerAction) {
    switch resource {
    case .photos:
        proposeToAccessPhotos(agreed: successAction, rejected: failureAction)
    case .camera:
        proposeToAccessCamera(agreed: successAction, rejected: failureAction)
    case .microphone:
        proposeToAccessMicrophone(agreed: successAction, rejected: failureAction)
    case .contacts:
        proposeToAccessContacts(agreed: successAction, rejected: failureAction)
    case .reminders:
        proposeToAccessEventForEntityType(.reminder, agreed: successAction, rejected: failureAction)
    case .calendar:
        proposeToAccessEventForEntityType(.event, agreed: successAction, rejected: failureAction)
    case .location(let usage):
        proposeToAccessLocation(usage, agreed: successAction, rejected: failureAction)
    case .notifications(let settings):
        proposeToSendNotifications(settings, agreed: successAction, rejected: failureAction)
    }
}

private func proposeToAccessPhotos(agreed successAction: @escaping ProposerAction, rejected failureAction: @escaping ProposerAction) {
    PHPhotoLibrary.requestAuthorization { status in
        DispatchQueue.main.async {
            switch status {
            case .authorized:
                successAction()
            default:
                failureAction()
            }
        }
    }
}

private func proposeToAccessCamera(agreed successAction: @escaping ProposerAction, rejected failureAction: @escaping ProposerAction) {
    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
        DispatchQueue.main.async {
            granted ? successAction() : failureAction()
        }
    }
}

private func proposeToAccessMicrophone(agreed successAction: @escaping ProposerAction, rejected failureAction: @escaping ProposerAction) {
    AVAudioSession.sharedInstance().requestRecordPermission { granted in
        DispatchQueue.main.async {
            granted ? successAction() : failureAction()
        }
    }
}

private func proposeToAccessContacts(agreed successAction: @escaping ProposerAction, rejected failureAction: @escaping ProposerAction) {
    if #available(iOS 9.0, *) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            successAction()
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        successAction()
                    } else {
                        failureAction()
                    }
                }
            }
        default:
            failureAction()
        }
    } else {
        switch ABAddressBookGetAuthorizationStatus() {
        case .authorized:
            successAction()
        case .notDetermined:
            if let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue() {
                ABAddressBookRequestAccessWithCompletion(addressBook) { granted, error in
                    DispatchQueue.main.async {
                        if granted {
                            successAction()
                        } else {
                            failureAction()
                        }
                    }
                }
            }
        default:
            failureAction()
        }
    }
}

private func proposeToAccessEventForEntityType(_ entityYype: EKEntityType, agreed successAction: @escaping ProposerAction, rejected failureAction: @escaping ProposerAction) {
    switch EKEventStore.authorizationStatus(for: entityYype) {
    case .authorized:
        successAction()
    case .notDetermined:
        EKEventStore().requestAccess(to: entityYype) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    successAction()
                } else {
                    failureAction()
                }
            }
        }
    default:
        failureAction()
    }
}

private var _locationManager: CLLocationManager? // as strong ref

private func proposeToAccessLocation(_ locationUsage: PrivateResource.LocationUsage, agreed successAction: @escaping ProposerAction, rejected failureAction: @escaping ProposerAction) {
    switch CLLocationManager.authorizationStatus() {
    case .authorizedWhenInUse:
        if locationUsage == .whenInUse {
            successAction()
        } else {
            failureAction()
        }
    case .authorizedAlways:
        successAction()
    case .notDetermined:
        if CLLocationManager.locationServicesEnabled() {
            let locationManager = CLLocationManager()
            _locationManager = locationManager
            let delegate = LocationDelegate(locationUsage: locationUsage, successAction: successAction, failureAction: failureAction)
            _locationDelegate = delegate
            locationManager.delegate = delegate
            switch locationUsage {
            case .whenInUse:
                locationManager.requestWhenInUseAuthorization()
            case .always:
                locationManager.requestAlwaysAuthorization()
            }
            locationManager.startUpdatingLocation()
        } else {
            failureAction()
        }
    default:
        failureAction()
    }
}

private func proposeToSendNotifications(_ settings: UIUserNotificationSettings, agreed successAction: @escaping ProposerAction, rejected failureAction: @escaping ProposerAction) {
    switch UIApplication.shared.notificationAuthorizationStatus {
    case .notDetermined:
        let notificationMan = NotificationMan {
            if UIApplication.shared.notificationAuthorizationStatus == .authorized {
                successAction()
            } else {
                failureAction()
            }
        }
        _notificationMan = notificationMan
        UIApplication.shared.registerUserNotificationSettings(settings)
    case .authorized:
        UIApplication.shared.registerUserNotificationSettings(settings)
        successAction()
    case .denied:
        failureAction()
    }
}

// MARK: LocationDelegate

private var _locationDelegate: LocationDelegate? // as strong ref

private class LocationDelegate: NSObject, CLLocationManagerDelegate {

    let locationUsage: PrivateResource.LocationUsage
    let successAction: ProposerAction
    let failureAction: ProposerAction

    init(locationUsage: PrivateResource.LocationUsage, successAction: @escaping ProposerAction, failureAction: @escaping ProposerAction) {
        self.locationUsage = locationUsage
        self.successAction = successAction
        self.failureAction = failureAction
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .authorizedWhenInUse:
                self.locationUsage == .whenInUse ? self.successAction() : self.failureAction()
                _locationManager = nil
                _locationDelegate = nil
            case .authorizedAlways:
                self.locationUsage == .always ? self.successAction() : self.failureAction()
                _locationManager = nil
                _locationDelegate = nil
            case .denied:
                self.failureAction()
                _locationManager = nil
                _locationDelegate = nil
            default:
                break
            }
        }
    }
}

// MARK: NotificationMan

private let askedForNotificationPermissionKey = "Proposer.AskedForNotificationPermission"

private extension UIApplication {

    enum NotificationAuthorizationStatus {
        case notDetermined
        case authorized
        case denied
    }

    var notificationAuthorizationStatus: NotificationAuthorizationStatus {
        if UIApplication.shared.currentUserNotificationSettings?.types.isEmpty == false {
            return .authorized
        }
        let asked = UserDefaults.standard.bool(forKey: askedForNotificationPermissionKey)
        return asked ? .denied : .notDetermined
    }
}

private var _notificationMan: NotificationMan?

private class NotificationMan: NSObject {

    var finish: (() -> Void)? = nil

    init(_ finish: (() -> Void)?) {
        super.init()

        self.finish = finish
        NotificationCenter.default.addObserver(self, selector: #selector(requestingNotifications), name: .UIApplicationWillResignActive, object: nil)
    }

    @objc private func requestingNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finishedRequestingNotifications), name: .UIApplicationDidBecomeActive, object: nil)
    }

    @objc private func finishedRequestingNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
        UserDefaults.standard.set(true, forKey: askedForNotificationPermissionKey)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            self?.finish?()
        }
    }
}

