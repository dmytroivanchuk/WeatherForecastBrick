//
//  ViewController.swift
//  WeatherForecastBrick
//
//  Created by Dmytro Ivanchuk on 22.08.2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet var weatherConditionImageView: UIImageView!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var weatherConditionLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var infoButton: UIButton!
    
    let customAlert = CustomAlert()
    
    let locationManager = CLLocationManager()
    var weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        weatherManager.delegate = self
        customAlert.delegate = self
        
        configureInfoButton()
        
        setupCard()
    }
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        customAlert.showAlert(on: self, title: "INFO", message: "Brick is wet - raining\nBrick is dry - sunny\nBrick is hard to see - fog\nBrick with cracks - very hot\nBrick with snow - snow\nBrick is swinging- windy\nBrick is gone - No Internet")
        weatherConditionImageView.isHidden = true
        temperatureLabel.isHidden = true
        weatherConditionLabel.isHidden = true
        locationLabel.isHidden = true
        infoButton.isHidden = true
        
    }
    
    //MARK: - UIElements Property Configuration Methods
    
    func configureInfoButton() {
        if let lightOrange = UIColor(named: "lightOrange")?.cgColor, let darkOrange = UIColor(named: "darkOrange")?.cgColor {
            infoButton.applyGradient(colors: [lightOrange, darkOrange])
        }
        
        infoButton.layer.shadowColor = UIColor.black.cgColor
        infoButton.layer.shadowOffset = CGSize(width: 3, height: 0)
        infoButton.layer.shadowRadius = 3
        infoButton.layer.shadowOpacity = 0.3
    }
    
    //MARK: - Refresh Weather Functionality
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    let tapticFeedback = UINotificationFeedbackGenerator()
    
    func setupCard() {
    
                weatherConditionImageView.clipsToBounds = true
    
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recognzier:)))
                let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCardPan(recognizer:)))
    
                weatherConditionImageView.addGestureRecognizer(tapGestureRecognizer)
                weatherConditionImageView.addGestureRecognizer(panGestureRecognizer)
                weatherConditionImageView.isUserInteractionEnabled = true
            }
    
            @objc
            func handleCardTap(recognzier:UITapGestureRecognizer) {
                switch recognzier.state {
                case .ended:
                    animateTransition(duration: 0.2)
                    locationManager.startUpdatingLocation()
                    tapticFeedback.notificationOccurred(.success)
                default:
                    break
                }
            }
    
            @objc
            func handleCardPan (recognizer:UIPanGestureRecognizer) {
                switch recognizer.state {
                case .began:
                    startInteractiveTransition(duration: 0.2)
                case .changed:
                    let translation = recognizer.translation(in: weatherConditionImageView)
                    let fractionComplete = translation.y / 50
                    updateInteractiveTransition(fractionCompleted: fractionComplete)
                case .ended:
                    continueInteractiveTransition()
                    locationManager.startUpdatingLocation()
                    tapticFeedback.notificationOccurred(.success)
                default:
                    break
                }

            }
    
            func animateTransition(duration:TimeInterval) {
                let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                    self.weatherConditionImageView.frame.origin.y += 50
                }
                frameAnimator.startAnimation()
                runningAnimations.append(frameAnimator)
                
                frameAnimator.addCompletion { _ in
                    self.runningAnimations.removeAll()
                    let backframeAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                        self.weatherConditionImageView.frame.origin.y -= 50
                    }
                    backframeAnimator.startAnimation()
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
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: long)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//MARK: - WeatherManagerDelegate Methods

extension ViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.weatherConditionImageView.image = UIImage(named: weather.conditionImage)
            self.temperatureLabel.text = "\(weather.temperatureString)°"
            self.weatherConditionLabel.text = weather.condition
            
            let fullString = NSMutableAttributedString(string: "")
            
            let image1Attachment = NSTextAttachment()
            image1Attachment.image = UIImage(systemName: "paperplane.fill")
            let image1String = NSAttributedString(attachment: image1Attachment)
            
            let image2Attachment = NSTextAttachment()
            image2Attachment.image = UIImage(systemName: "magnifyingglass")
            let image2String = NSAttributedString(attachment: image2Attachment)
            
            fullString.append(image1String)
            fullString.append(NSAttributedString(string: " \(weather.cityName), \(weather.countryName ?? "") "))
            fullString.append(image2String)
            
            self.locationLabel.attributedText = fullString
            print(1)
        }
    }
    
    func didFailWithError(error: Error) {
        weatherConditionImageView.image = UIImage(named: "noInternet.png")
        temperatureLabel.text = "_ _"
        weatherConditionLabel.text = "_"
        locationLabel.text = "_ _"
        
    }
}

//MARK: - CustomAlert Delegate Methods

extension ViewController: CustomAlertDelegate {
    func updateView() {
        weatherConditionImageView.isHidden = false
        temperatureLabel.isHidden = false
        weatherConditionLabel.isHidden = false
        locationLabel.isHidden = false
        infoButton.isHidden = false
    }
}

//MARK: - UIButton Extension

extension UIButton {
    func applyGradient(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 15
        gradientLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
