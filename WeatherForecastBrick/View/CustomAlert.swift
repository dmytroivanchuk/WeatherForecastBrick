//
//  CustomAlert.swift
//  WeatherForecastBrick
//
//  Created by Dmytro Ivanchuk on 24.08.2022.
//

import UIKit

protocol CustomAlertDelegate {
    func updateView(isHidden: Bool)
}

// create CustomAlert class, responsible for creation of alert window, its background view, animations and updating main view of ViewController, in which custom alert will be shown
class CustomAlert {
    var delegate: CustomAlertDelegate?
    
    // create reference to main view of ViewController, in which custom alert will be shown
    var targetView: UIView?
    
    // configure initial custom alert window itself
    let alertView: UIView = {
        let alertView = UIView()
        alertView.backgroundColor = UIColor(named: "lightOrange")
        alertView.layer.cornerRadius = 15
        alertView.layer.shadowColor = UIColor(named: "darkOrange")?.cgColor
        alertView.layer.shadowOffset = CGSize(width: 8, height: 0)
        alertView.layer.shadowRadius = 0
        alertView.layer.shadowOpacity = 1
        return alertView
    }()
    
    // configure initial background view, displayed behind custom alert window
    let backgroundView: UIView = {
        let backgroundView = UIView()
        
        // configure initial background view's image
        let backgroundImageView: UIImageView = {
            let backgroundImageView = UIImageView()
            backgroundImageView.frame = backgroundView.bounds
            backgroundImageView.image = UIImage(named: "image_background.png")
            return backgroundImageView
        }()
        
        backgroundView.addSubview(backgroundImageView)
        return backgroundView
    }()
    
    
    func presentAlert(on viewController: UIViewController, title: String, message: String) {
        guard let targetView = viewController.view else {
            return
        }
        
        // update reference to target view, in which custom alert will be shown
        self.targetView = targetView
        
        // hide all UI elements in target view, before alert window is shown
        delegate?.updateView(isHidden: true)
        
        // configure alert window and its background view bounds to be correctly displayed in targetView
        backgroundView.frame = targetView.bounds
        alertView.frame = CGRect(x: targetView.frame.width * 0.128, y: -380, width: targetView.frame.width * 0.75, height: 380)
        
        
        // configure UI elements inside alert window, based on its bounds
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: alertView.frame.width, height: 80))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Ubuntu-Bold", size: 18)
        
        
        let messageLabel = UILabel(frame: CGRect(x: 30, y: 80, width: 215, height: 215))
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont(name: "Ubuntu-Regular", size: 15)
        let attrString = NSMutableAttributedString(string: message)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 15
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: message.count))
        messageLabel.attributedText = attrString
        
        
        let actionButton = UIButton(frame: CGRect(x: 0, y: 320, width: 115, height: 30))
        actionButton.center.x = titleLabel.center.x
        actionButton.setTitle("Hide", for: .normal)
        actionButton.setTitleColor(.darkGray, for: .normal)
        actionButton.titleLabel?.font = UIFont(name: "Ubuntu-Medium", size: 15)
        actionButton.layer.cornerRadius = actionButton.frame.height / 2
        actionButton.layer.borderWidth = 1
        actionButton.layer.borderColor = UIColor.darkGray.cgColor
        actionButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        
        
        alertView.addSubview(titleLabel)
        alertView.addSubview(messageLabel)
        alertView.addSubview(actionButton)
        
        // add alert window and its background view to target view
        targetView.addSubview(backgroundView)
        targetView.addSubview(alertView)
        
        // animate alert window pop-up
        let presentAlertAnimator = UIViewPropertyAnimator(duration: 0.25, dampingRatio: 1) {
            self.alertView.center = targetView.center
        }
        presentAlertAnimator.startAnimation()
    }
    
    
    @objc func dismissAlert() {
        // pass the reference of target view, in which custom alert will be shown
        guard let targetView = targetView else {
            return
        }
        
        // animate alert window dismissal
        let dismissAlertAnimator = UIViewPropertyAnimator(duration: 0.25, dampingRatio: 1) {
            self.alertView.frame = CGRect(x: 40, y: targetView.frame.height, width: targetView.frame.width - 80, height: 300)
        }
        dismissAlertAnimator.startAnimation()
        dismissAlertAnimator.addCompletion { _ in
            self.alertView.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
            self.delegate?.updateView(isHidden: false)
        }
    }
}
