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

        let photos: PrivateResource = .Photos

        proposeToAccess(photos, agreed: {
            print("I can access Photos. :]\n")

            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .SavedPhotosAlbum

                self.presentViewController(imagePicker, animated: true, completion: nil)
            }

        }, rejected: {
            self.alertNoPermissionToAccess(photos)
        })
    }

    @IBAction func takePhoto() {

        let camera: PrivateResource = .Camera

        proposeToAccess(camera, agreed: {
            print("I can access Camera. :]\n")

            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .Camera

                self.presentViewController(imagePicker, animated: true, completion: nil)
            }

        }, rejected: {
            self.alertNoPermissionToAccess(camera)
        })
    }

    @IBAction func recordAudio() {

        let microphone: PrivateResource = .Microphone

        proposeToAccess(microphone, agreed: {
            print("I can access Microphone. :]\n")

        }, rejected: {
            self.alertNoPermissionToAccess(microphone)
        })
    }

    @IBAction func readContacts() {

        let contacts: PrivateResource = .Contacts

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

        let location: PrivateResource = .Location(.WhenInUse)
        
        proposeToAccess(location, agreed: {
            print("I can access Location. :]\n")
            
        }, rejected: {
            self.alertNoPermissionToAccess(location)
        })
    }

}

