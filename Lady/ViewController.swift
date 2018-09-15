//
//  ViewController.swift
//  Lady
//
//  Created by NIX on 15/7/11.
//  Copyright (c) 2015年 nixWork. All rights reserved.
//

import UIKit
import Proposer

class ViewController: UIViewController {

    @IBAction func choosePhoto() {
        let photos: PrivateResource = .photos
        let propose: Propose = {
            proposeToAccess(photos, agreed: {
                print("I can access Photos. :]\n")
                if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
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

    @IBAction func takePhoto() {
        let camera: PrivateResource = .camera
        let propose: Propose = {
            proposeToAccess(camera, agreed: {
                print("I can access Camera. :]\n")
                if UIImagePickerController.isSourceTypeAvailable(.camera){
                    let imagePicker = UIImagePickerController()
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }, rejected: {
                self.alertNoPermissionToAccess(camera)
            })
        }
        showProposeMessageIfNeedFor(camera, andTryPropose: propose)
    }

    @IBAction func recordAudio() {
        let microphone: PrivateResource = .microphone
        let propose: Propose = {
            proposeToAccess(microphone, agreed: {
                print("I can access Microphone. :]\n")
            }, rejected: {
                self.alertNoPermissionToAccess(microphone)
            })
        }
        showProposeMessageIfNeedFor(microphone, andTryPropose: propose)
    }

    @IBAction func readContacts() {
        let contacts: PrivateResource = .contacts
        let propose: Propose = {
            proposeToAccess(contacts, agreed: {
                print("I can access Contacts. :]\n")
            }, rejected: {
                self.alertNoPermissionToAccess(contacts)
            })
        }
        showProposeMessageIfNeedFor(contacts, andTryPropose: propose)
    }

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

    @IBAction func addReminder() {
        let reminders: PrivateResource = .reminders
        let propose: Propose = {
            proposeToAccess(reminders, agreed: {
                print("I can access Reminders. :]\n")
            }, rejected: {
                self.alertNoPermissionToAccess(reminders)
            })
        }
        showProposeMessageIfNeedFor(reminders, andTryPropose: propose)
    }

    @IBAction func addCalendarEvent() {
        let calendar: PrivateResource = .calendar
        let propose: Propose = {
            proposeToAccess(calendar, agreed: {
                print("I can access Calendar. :]\n")
            }, rejected: {
                self.alertNoPermissionToAccess(calendar)
            })
        }
        showProposeMessageIfNeedFor(calendar, andTryPropose: propose)
    }

    @IBAction func sendNotifications() {
        let settings = UIUserNotificationSettings(
            types: [.alert, .badge, .sound],
            categories: nil
        )
        let notifications: PrivateResource = .notifications(settings)
        let propose: Propose = {
            proposeToAccess(notifications, agreed: {
                print("I can send Notifications. :]\n")
            }, rejected: {
                self.alertNoPermissionToAccess(notifications)
            })
        }
        showProposeMessageIfNeedFor(notifications, andTryPropose: propose)
    }
}

