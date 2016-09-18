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

    @IBAction func takePhoto() {

        let camera: PrivateResource = .camera

        proposeToAccess(camera, agreed: {
            print("I can access Camera. :]\n")

            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera

                self.present(imagePicker, animated: true, completion: nil)
            }

        }, rejected: {
            self.alertNoPermissionToAccess(camera)
        })
    }

    @IBAction func recordAudio() {

        let microphone: PrivateResource = .microphone

        proposeToAccess(microphone, agreed: {
            print("I can access Microphone. :]\n")

        }, rejected: {
            self.alertNoPermissionToAccess(microphone)
        })
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
        
        proposeToAccess(location, agreed: {
            print("I can access Location. :]\n")
            
        }, rejected: {
            self.alertNoPermissionToAccess(location)
        })
    }

    @IBAction func addReminder() {

        let reminders: PrivateResource = .reminders

        proposeToAccess(reminders, agreed: { 
            print("I can access Reminders. :]\n")

        }, rejected: {
            self.alertNoPermissionToAccess(reminders)
        })
    }

    @IBAction func addCalendarEvent() {

        let calendar: PrivateResource = .calendar

        proposeToAccess(calendar, agreed: {
            print("I can access Calendar. :]\n")

        }, rejected: {
            self.alertNoPermissionToAccess(calendar)
        })
    }
}

