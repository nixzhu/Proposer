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
import CoreLocation

public enum PrivateResource {
    case Photos
    case Camera
    case Microphone
    case Contacts

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
        case .Location:
            return CLLocationManager.authorizationStatus() == .NotDetermined
        }
    }
}

public typealias Propose = () -> Void

public typealias ProposerAction = () -> Void

public func proposeToAccess(resource: PrivateResource, succeeded succeededAction: ProposerAction, failed failedAction: ProposerAction) {

    switch resource {

    case .Photos:
        requestPhotos(succeededAction, failedAction)

    case .Camera:
        requestCamera(succeededAction, failedAction)

    case .Microphone:
        requestMicrophone(succeededAction, failedAction)

    case .Contacts:
        requestContacts(succeededAction, failedAction)

    case .Location(let usage):
        requestLocation(usage, succeededAction, failedAction)
    }
}

private func requestPhotos(succeeded: ProposerAction, failed: ProposerAction) {
    PHPhotoLibrary.requestAuthorization { status in
        dispatch_async(dispatch_get_main_queue()) {
            switch status {
            case .Authorized:
                succeeded()
            default:
                failed()
            }
        }
    }
}

private func requestCamera(succeeded: ProposerAction, failed: ProposerAction) {
    AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
        dispatch_async(dispatch_get_main_queue()) {
            granted ? succeeded() : failed()
        }
    }
}

private func requestMicrophone(succeeded: ProposerAction, failed: ProposerAction) {
    AVAudioSession.sharedInstance().requestRecordPermission { granted in
        dispatch_async(dispatch_get_main_queue()) {
            granted ? succeeded() : failed()
        }
    }
}

private func requestContacts(succeeded: ProposerAction, failed: ProposerAction) {

    switch ABAddressBookGetAuthorizationStatus() {

    case .Authorized:
        succeeded()

    case .NotDetermined:
        if let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue() {
            ABAddressBookRequestAccessWithCompletion(addressBook, { granted, error in
                dispatch_async(dispatch_get_main_queue()) {
                    if granted {
                        succeeded()
                    } else {
                        failed()
                    }
                }
            })
        }

    default:
        failed()
    }
}

private var _locationManager: CLLocationManager? // as strong ref

private func requestLocation(locationUsage: PrivateResource.LocationUsage, succeeded: ProposerAction, failed: ProposerAction) {

    switch CLLocationManager.authorizationStatus() {

    case .AuthorizedWhenInUse:
        if locationUsage == .WhenInUse {
            succeeded()
        } else {
            failed()
        }

    case .AuthorizedAlways:
        succeeded()

    case .NotDetermined:
        if CLLocationManager.locationServicesEnabled() {

            let locationManager = CLLocationManager()

            _locationManager = locationManager

            let delegate = LocationDelegate(locationUsage: locationUsage, succeeded: succeeded, failed: failed)
            locationManager.delegate = delegate

            _locationDelegate = delegate

            switch locationUsage {

            case .WhenInUse:
                locationManager.requestWhenInUseAuthorization()

            case .Always:
                locationManager.requestAlwaysAuthorization()
            }

            locationManager.startUpdatingLocation()

        } else {
            failed()
        }

    default:
        failed()
    }
}

// MARK: LocationDelegate

private var _locationDelegate: LocationDelegate? // as strong ref

class LocationDelegate: NSObject, CLLocationManagerDelegate {

    let locationUsage: PrivateResource.LocationUsage
    let succeeded: ProposerAction
    let failed: ProposerAction

    init(locationUsage: PrivateResource.LocationUsage, succeeded: ProposerAction, failed: ProposerAction) {
        self.locationUsage = locationUsage
        self.succeeded = succeeded
        self.failed = failed
    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        dispatch_async(dispatch_get_main_queue()) {

            switch status {

            case .AuthorizedWhenInUse:
                self.locationUsage == .WhenInUse ? self.succeeded() : self.failed()

                _locationManager = nil
                _locationDelegate = nil

            case .AuthorizedAlways:
                self.locationUsage == .Always ? self.succeeded() : self.failed()

                _locationManager = nil
                _locationDelegate = nil

            case .Denied:
                self.failed()

                _locationManager = nil
                _locationDelegate = nil

            default:
                break
            }
        }
    }
}

