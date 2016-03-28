//
//  Proposer.swift
//  Lady
//
//  Created by NIX on 15/7/11.
//  Copyright (c) 2015年 nixWork. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import AddressBook
import EventKit
import CoreLocation

public enum PrivateResource {
    case Photos
    case Camera
    case Microphone
    case Contacts
    case Reminders
    case Calendar

    public enum LocationUsage {
        case WhenInUse
        case Always
    }
    case Location(LocationUsage)

    public var isNotDeterminedAuthorization: Bool {
        switch self {
        case .Photos:
            return PHPhotoLibrary.authorizationStatus() == .NotDetermined
        case .Camera:
            return AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .NotDetermined
        case .Microphone:
            return AVAudioSession.sharedInstance().recordPermission() == .Undetermined
        case .Contacts:
            return ABAddressBookGetAuthorizationStatus() == .NotDetermined
        case .Reminders:
            return EKEventStore.authorizationStatusForEntityType(.Reminder) == .NotDetermined
        case .Calendar:
            return EKEventStore.authorizationStatusForEntityType(.Event) == .NotDetermined
        case .Location:
            return CLLocationManager.authorizationStatus() == .NotDetermined
        }
    }

    public var isAuthorized: Bool {
        switch self {
        case .Photos:
            return PHPhotoLibrary.authorizationStatus() == .Authorized
        case .Camera:
            return AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Authorized
        case .Microphone:
            return AVAudioSession.sharedInstance().recordPermission() == .Granted
        case .Contacts:
            return ABAddressBookGetAuthorizationStatus() == .Authorized
        case .Reminders:
            return EKEventStore.authorizationStatusForEntityType(.Reminder) == .Authorized
        case .Calendar:
            return EKEventStore.authorizationStatusForEntityType(.Event) == .Authorized
        case .Location(let usage):
            switch usage {
            case .WhenInUse:
                return CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse
            case .Always:
                return CLLocationManager.authorizationStatus() == .AuthorizedAlways
            }
        }
    }
}

public typealias Propose = () -> Void

public typealias ProposerAction = () -> Void

public func proposeToAccess(resource: PrivateResource, agreed successAction: ProposerAction, rejected failureAction: ProposerAction) {

    switch resource {

    case .Photos:
        proposeToAccessPhotos(agreed: successAction, rejected: failureAction)

    case .Camera:
        proposeToAccessCamera(agreed: successAction, rejected: failureAction)

    case .Microphone:
        proposeToAccessMicrophone(agreed: successAction, rejected: failureAction)

    case .Contacts:
        proposeToAccessContacts(agreed: successAction, rejected: failureAction)

    case .Reminders:
        proposeToAccessEventForEntityType(.Reminder, agreed: successAction, rejected: failureAction)

    case .Calendar:
        proposeToAccessEventForEntityType(.Event, agreed: successAction, rejected: failureAction)

    case .Location(let usage):
        proposeToAccessLocation(usage, agreed: successAction, rejected: failureAction)
    }
}

private func proposeToAccessPhotos(agreed successAction: ProposerAction, rejected failureAction: ProposerAction) {
    PHPhotoLibrary.requestAuthorization { status in
        dispatch_async(dispatch_get_main_queue()) {
            switch status {
            case .Authorized:
                successAction()
            default:
                failureAction()
            }
        }
    }
}

private func proposeToAccessCamera(agreed successAction: ProposerAction, rejected failureAction: ProposerAction) {
    AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
        dispatch_async(dispatch_get_main_queue()) {
            granted ? successAction() : failureAction()
        }
    }
}

private func proposeToAccessMicrophone(agreed successAction: ProposerAction, rejected failureAction: ProposerAction) {
    AVAudioSession.sharedInstance().requestRecordPermission { granted in
        dispatch_async(dispatch_get_main_queue()) {
            granted ? successAction() : failureAction()
        }
    }
}

private func proposeToAccessContacts(agreed successAction: ProposerAction, rejected failureAction: ProposerAction) {

    switch ABAddressBookGetAuthorizationStatus() {

    case .Authorized:
        successAction()

    case .NotDetermined:
        if let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue() {
            ABAddressBookRequestAccessWithCompletion(addressBook, { granted, error in
                dispatch_async(dispatch_get_main_queue()) {
                    if granted {
                        successAction()
                    } else {
                        failureAction()
                    }
                }
            })
        }

    default:
        failureAction()
    }
}

private func proposeToAccessEventForEntityType(entityYype: EKEntityType, agreed successAction: ProposerAction, rejected failureAction: ProposerAction) {

    switch EKEventStore.authorizationStatusForEntityType(entityYype) {
    case .Authorized:
        successAction()
    case .NotDetermined:
        EKEventStore().requestAccessToEntityType(entityYype) { granted, error in
            dispatch_async(dispatch_get_main_queue()) {
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

private func proposeToAccessLocation(locationUsage: PrivateResource.LocationUsage, agreed successAction: ProposerAction, rejected failureAction: ProposerAction) {

    switch CLLocationManager.authorizationStatus() {

    case .AuthorizedWhenInUse:
        if locationUsage == .WhenInUse {
            successAction()
        } else {
            failureAction()
        }

    case .AuthorizedAlways:
        successAction()

    case .NotDetermined:
        if CLLocationManager.locationServicesEnabled() {

            let locationManager = CLLocationManager()
            _locationManager = locationManager

            let delegate = LocationDelegate(locationUsage: locationUsage, successAction: successAction, failureAction: failureAction)
            _locationDelegate = delegate

            locationManager.delegate = delegate

            switch locationUsage {

            case .WhenInUse:
                locationManager.requestWhenInUseAuthorization()

            case .Always:
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

// MARK: LocationDelegate

private var _locationDelegate: LocationDelegate? // as strong ref

class LocationDelegate: NSObject, CLLocationManagerDelegate {

    let locationUsage: PrivateResource.LocationUsage
    let successAction: ProposerAction
    let failureAction: ProposerAction

    init(locationUsage: PrivateResource.LocationUsage, successAction: ProposerAction, failureAction: ProposerAction) {
        self.locationUsage = locationUsage
        self.successAction = successAction
        self.failureAction = failureAction
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        dispatch_async(dispatch_get_main_queue()) {

            switch status {

            case .AuthorizedWhenInUse:
                self.locationUsage == .WhenInUse ? self.successAction() : self.failureAction()

                _locationManager = nil
                _locationDelegate = nil

            case .AuthorizedAlways:
                self.locationUsage == .Always ? self.successAction() : self.failureAction()

                _locationManager = nil
                _locationDelegate = nil

            case .Denied:
                self.failureAction()

                _locationManager = nil
                _locationDelegate = nil

            default:
                break
            }
        }
    }
}

