//
//  Errors.swift
//  ConferenceTime
//
//  Created by Drew Crawford on 5/13/17.
//  Copyright © 2017 DrewCrawfordApps. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentingError(closure: () throws -> ()) {
        do {
            try closure()
        }
        catch {
            DispatchQueue.main.async {
                let u = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
                u.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    u.dismiss(animated: true, completion: nil)
                }))
                self.present(u, animated: true, completion: nil)
            }
        }
    }
}
