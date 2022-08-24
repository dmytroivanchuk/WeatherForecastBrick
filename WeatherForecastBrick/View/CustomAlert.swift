//
//  CustomAlert.swift
//  WeatherForecastBrick
//
//  Created by Dmytro Ivanchuk on 24.08.2022.
//

import UIKit

protocol CustomAlertDelegate {
    func updateView()
}

class CustomAlert {
    
    var delegate: CustomAlertDelegate?
    
    var targetView: UIView?
    
    let backgroundView: UIView = {
        let backgroundView = UIView()
        
        let backgroundImageView: UIImageView = {
            let backgroundImageView = UIImageView()
            backgroundImageView.frame = backgroundView.bounds
            backgroundImageView.image = UIImage(named: "image_background.png")
            return backgroundImageView
        }()
        
        backgroundView.addSubview(backgroundImageView)
        
        return backgroundView
    }()
    
    let alertView: UIView = {
        let alertView = UIView()
        alertView.backgroundColor = UIColor(named: "lightOrange")
        alertView.layer.cornerRadius = 15
        
        if let darkOrange = UIColor(named: "darkOrange")?.cgColor {
            alertView.layer.shadowColor = darkOrange
            alertView.layer.shadowOffset = CGSize(width: 8, height: 0)
            alertView.layer.shadowRadius = 0
            alertView.layer.shadowOpacity = 1
        }
        
        return alertView
    }()
    
    func showAlert(on viewController: UIViewController, title: String, message: String) {
        guard let targetView = viewController.view else {
            return
        }
        
        self.targetView = targetView
        
        backgroundView.frame = targetView.bounds
        alertView.frame = CGRect(x: targetView.frame.width * 0.128, y: -380, width: targetView.frame.width * 0.75, height: 380)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: alertView.frame.width, height: 80))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Ubuntu-Bold", size: 18)
        alertView.addSubview(titleLabel)
        
        let messageLabel = UILabel(frame: CGRect(x: 30, y: 80, width: 215, height: 215))
        messageLabel.numberOfLines = 0
        let attrString = NSMutableAttributedString(string: message)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 15
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: message.count))
        messageLabel.attributedText = attrString
        messageLabel.font = UIFont(name: "Ubuntu-Regular", size: 15)
        alertView.addSubview(messageLabel)
        
        let actionButton = UIButton(frame: CGRect(x: 0, y: 320, width: 115, height: 30))
        actionButton.center.x = titleLabel.center.x
        actionButton.setTitle("Hide", for: .normal)
        actionButton.setTitleColor(.darkGray, for: .normal)
        actionButton.titleLabel?.font = UIFont(name: "Ubuntu-Medium", size: 15)
        actionButton.layer.cornerRadius = actionButton.frame.height / 2
        actionButton.layer.borderWidth = 1
        actionButton.layer.borderColor = UIColor.darkGray.cgColor
        actionButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        alertView.addSubview(actionButton)
        
        targetView.addSubview(backgroundView)
        targetView.addSubview(alertView)
        
        UIView.animate(withDuration: 0.25) {
            self.alertView.center = targetView.center
        }
    }
    
    @objc func dismissAlert() {
        guard let targetView = targetView else {
            return
        }
        UIView.animate(withDuration: 0.25) {
            self.alertView.frame = CGRect(x: 40, y: targetView.frame.height, width: targetView.frame.width - 80, height: 300)
        } completion: { done in
            self.alertView.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
            self.delegate?.updateView()
        }
    }
}
