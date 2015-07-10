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

    @IBAction func takePhoto() {

        let camera: PrivateResource = .Camera

        proposeToAccess(camera, succeeded: {
            print("I can access Camera. :]\n")

            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .Camera

                self.presentViewController(imagePicker, animated: true, completion: nil)
            }

        }, failed: {
            self.alertNoPermissionToAccess(camera)
        })
    }

    @IBAction func recordAudio() {

        let microphone: PrivateResource = .Microphone

        proposeToAccess(microphone, succeeded: {
            print("I can access Microphone. :]\n")

        }, failed: {
            self.alertNoPermissionToAccess(microphone)
        })
    }

    @IBAction func readContacts() {

        let contacts: PrivateResource = .Contacts

        let propose: Propose = {

            proposeToAccess(contacts, succeeded: {
                print("I can access Contacts. :]\n")

            }, failed: {
                self.alertNoPermissionToAccess(contacts)
            })
        }

        showProposeMessageIfNeedFor(contacts, andTryPropose: propose)
    }

    @IBAction func shareLocation() {

        let location: PrivateResource = .Location(.WhenInUse)
        
        proposeToAccess(location, succeeded: {
            print("I can access Location. :]\n")
            
        }, failed: {
            self.alertNoPermissionToAccess(location)
        })
    }

}

