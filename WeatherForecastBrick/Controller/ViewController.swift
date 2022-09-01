//
//  ViewController.swift
//  WeatherForecastBrick
//
//  Created by Dmytro Ivanchuk on 22.08.2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet var weatherBrickImageView: UIImageView!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var weatherConditionLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var infoButton: UIButton!
    
    private let locationManager = CLLocationManager()
    private var weatherManager = WeatherManager(urlSession: URLSession.shared)
    private let customAlert = CustomAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        customAlert.delegate = self
        
        configureInfoButton()
        configureGestureRecognizers()
    }
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        customAlert.presentAlert(on: self, title: "INFO", message: "Brick is wet - raining\nBrick is dry - sunny\nBrick is hard to see - fog\nBrick with cracks - very hot\nBrick with snow - snow\nBrick is swinging- windy\nBrick is gone - No Internet")
    }
    
    //MARK: - UI Elements Property Configuration Methods
    
    func configureInfoButton() {
        // apply specified color gradient to infoButton
        if let lightOrange = UIColor(named: "lightOrange")?.cgColor, let darkOrange = UIColor(named: "darkOrange")?.cgColor {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [lightOrange, darkOrange]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0 + 0.5)
            gradientLayer.frame = infoButton.bounds
            gradientLayer.cornerRadius = 15
            gradientLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            infoButton.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        infoButton.layer.shadowColor = UIColor.black.cgColor
        infoButton.layer.shadowOffset = CGSize(width: 3, height: 0)
        infoButton.layer.shadowRadius = 3
        infoButton.layer.shadowOpacity = 0.3
    }
    
    func updateViewWithError() {
        self.weatherBrickImageView.image = UIImage(named: "noInternet.png")
        self.temperatureLabel.text = "_ _"
        self.weatherConditionLabel.text = "_"
        self.locationLabel.text = "_ _"
    }
    
    //MARK: - Refresh Weather Functionality
    
    var runningAnimations = [UIViewPropertyAnimator]()
    let animationDuration: TimeInterval = 0.2
    let animationLength: CGFloat = 50
    var animationProgressWhenInterrupted: CGFloat = 0
    let tapticFeedback = UINotificationFeedbackGenerator()
    
    func configureGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handlePan(recognizer:)))

        weatherBrickImageView.addGestureRecognizer(tapGestureRecognizer)
        weatherBrickImageView.addGestureRecognizer(panGestureRecognizer)
        weatherBrickImageView.isUserInteractionEnabled = true
    }
    
    // response to user's tap gestures
    @objc func handleTap(recognzier: UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransition(duration: animationDuration)
        default:
            break
        }
    }
    
    // response to user's pull gestures
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(duration: animationDuration)
        case .changed:
            let translation = recognizer.translation(in: weatherBrickImageView)
            let fractionComplete = translation.y / animationLength
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    // animate weatherBrickImageView and update user location as animations complete
    func animateTransition(duration: TimeInterval) {
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            self.weatherBrickImageView.frame.origin.y += 50
        }
        frameAnimator.startAnimation()
        runningAnimations.append(frameAnimator)
        
        frameAnimator.addCompletion { _ in
            
            let backframeAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                self.weatherBrickImageView.frame.origin.y -= 50
            }
            backframeAnimator.startAnimation()
            self.runningAnimations.append(backframeAnimator)
            
            backframeAnimator.addCompletion { _ in
                self.runningAnimations.removeAll()
                
                self.locationManager.startUpdatingLocation()
                self.tapticFeedback.notificationOccurred(.success)
            }
        }
    }
    
    func startInteractiveTransition(duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransition(duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }

    func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}

//MARK: - CLLocationManagerDelegate Methods

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: long) { weatherModel in
                guard let weather = weatherModel else {
                    DispatchQueue.main.async {
                        self.updateViewWithError()
                    }
                    return
                }
                
                let totalWeatherBrickAnimationTime = 0.4
                
                // execute code block after all weather brick animations are completed
                DispatchQueue.main.asyncAfter(deadline: .now() + totalWeatherBrickAnimationTime, execute: {
                    self.weatherBrickImageView.image = UIImage(named: weather.conditionImage)
                    if weather.windSpeed >= 15 {
                        self.weatherBrickImageView.transform = CGAffineTransform(rotationAngle: .pi / -15)
                    }
                    self.temperatureLabel.text = "\(weather.temperatureString)°"
                    self.weatherConditionLabel.text = weather.condition
                    
                    
                    // create attributedString with png images and assign it to locationLabel attributed text property
                    let attributedString = NSMutableAttributedString(string: "")
                    
                    let image1Attachment = NSTextAttachment()
                    image1Attachment.image = UIImage(systemName: "paperplane.fill")?.withTintColor(self.weatherConditionLabel.textColor)
                    let image1String = NSAttributedString(attachment: image1Attachment)
                    
                    let image2Attachment = NSTextAttachment()
                    image2Attachment.image = UIImage(systemName: "magnifyingglass")?.withTintColor(self.weatherConditionLabel.textColor)
                    let image2String = NSAttributedString(attachment: image2Attachment)
                    
                    attributedString.append(image1String)
                    attributedString.append(NSAttributedString(string: " \(weather.cityName), \(weather.countryName ?? "") "))
                    attributedString.append(image2String)
                    
                    self.locationLabel.attributedText = attributedString
                })
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        updateViewWithError()
    }
}

//MARK: - CustomAlert Delegate Methods

extension ViewController: CustomAlertDelegate {
    func updateView(isHidden: Bool) {
        [weatherBrickImageView, temperatureLabel, weatherConditionLabel, locationLabel, infoButton].forEach { $0.isHidden = isHidden
        }
    }
}
