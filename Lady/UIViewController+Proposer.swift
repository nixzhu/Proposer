//
//  UIViewController+Proposer.swift
//  Lady
//
//  Created by NIX on 15/7/11.
//  Copyright (c) 2015年 nixWork. All rights reserved.
//

import UIKit
import Proposer

extension PrivateResource {

    var proposeMessage: String {
        switch self {
        case .Photos:
            return NSLocalizedString("Proposer need to access your Photos to choose photo.", comment: "")
        case .Camera:
            return NSLocalizedString("Proposer need to access your Camera to take photo.", comment: "")
        case .Microphone:
            return NSLocalizedString("Proposer need to access your Microphone to record audio.", comment: "")
        case .Contacts:
            return NSLocalizedString("Proposer need to access your Contacts to match friends.", comment: "")
        case .Location:
            return NSLocalizedString("Proposer need to get your Location to share to your friends.", comment: "")
        }
    }

    var noPermissionMessage: String {
        switch self {
        case .Photos:
            return NSLocalizedString("Proposer can NOT access your Photos, but you can change it in iOS Settings.", comment: "")
        case .Camera:
            return NSLocalizedString("Proposer can NOT access your Camera, but you can change it in iOS Settings.", comment: "")
        case .Microphone:
            return NSLocalizedString("Proposer can NOT access your Microphone, but you can change it in iOS Settings.", comment: "")
        case .Contacts:
            return NSLocalizedString("Proposer can NOT access your Contacts, but you can change it in iOS Settings.", comment: "")
        case .Location:
            return NSLocalizedString("Proposer can NOT get your Location, but you can change it in iOS Settings.", comment: "")
        }
    }
}

extension UIViewController {

    private func showDialogWithTitle(title: String, message: String, cancelTitle: String, confirmTitle: String, withCancelAction cancelAction : (() -> Void)?, confirmAction: (() -> Void)?) {

        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)

            let cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: .Cancel) { _ in
                cancelAction?()
            }
            alertController.addAction(cancelAction)

            let confirmAction: UIAlertAction = UIAlertAction(title: confirmTitle, style: .Default) { _ in
                confirmAction?()
            }
            alertController.addAction(confirmAction)

            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    func showProposeMessageIfNeedFor(resource: PrivateResource, andTryPropose propose: Propose) {

        if resource.isNotDeterminedAuthorization {
            showDialogWithTitle(NSLocalizedString("Notice", comment: ""), message: resource.proposeMessage, cancelTitle: NSLocalizedString("Not now", comment: ""), confirmTitle: NSLocalizedString("OK", comment: ""), withCancelAction: nil, confirmAction: {
                propose()
            })

        } else {
            propose()
        }
    }

    func alertNoPermissionToAccess(resource: PrivateResource) {

        showDialogWithTitle(NSLocalizedString("Sorry", comment: ""), message: resource.noPermissionMessage, cancelTitle: NSLocalizedString("Dismiss", comment: ""), confirmTitle: NSLocalizedString("Change it now", comment: ""), withCancelAction: nil, confirmAction: {
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        })
    }
}
