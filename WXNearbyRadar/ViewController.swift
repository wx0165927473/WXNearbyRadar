//
//  ViewController.swift
//  WXNearbyRadar
//
//  Created by Xin Wu on 2/22/16.
//  Copyright © 2016 Xin Wu. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    let locManager = CLLocationManager()
    let mapView = MKMapView()
    var radarView : RadarView!
    var userAvatarImageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Location Manager Init
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingLocation()
        
        // Map View Init
        mapView.frame = CGRectMake(10, 100, self.view.frame.width - 20, self.view.frame.width - 20)
        mapView.delegate = self
        mapView.userInteractionEnabled = false
        mapView.zoomEnabled = false
        mapView.layer.cornerRadius = mapView.frame.height / 2
        self.view.addSubview(mapView)
        
        // Radar View Init
        radarView = RadarView.init(frame: CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height))
        radarView.layer.contentsScale = UIScreen.mainScreen().scale
        radarView.alpha = 0.8
        mapView.addSubview(radarView)
        
        // User Avatar Init
        userAvatarImageView = UIImageView(image: UIImage(named: "avatar"))
        userAvatarImageView.backgroundColor = UIColor.grayColor()
        userAvatarImageView.frame.size = CGSizeMake(mapView.frame.width / 3.5, mapView.frame.height / 3.5)
        userAvatarImageView.frame.origin = CGPointMake(mapView.center.x - userAvatarImageView.frame.width / 2, mapView.center.y - userAvatarImageView.frame.height / 2)
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.bounds.width / 2
        userAvatarImageView.layer.borderWidth = 3
        userAvatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        userAvatarImageView.clipsToBounds = true
        self.view.addSubview(userAvatarImageView)
        
        // Add ripple animation to avatar
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("tapAvatarImageAction:"))
        userAvatarImageView.userInteractionEnabled = true
        userAvatarImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // Start spinning the radar and ripple anim
        spinRadar()
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("tapAvatarImageAction:"), userInfo: nil, repeats: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Radar Animation
    func spinRadar() {
        let spin = CABasicAnimation(keyPath: "transform.rotation")
        // Change spinning speed here
        spin.duration = 2
        spin.toValue = NSNumber(double: M_PI)
        spin.cumulative = true
        spin.removedOnCompletion = false
        spin.repeatCount = MAXFLOAT;
        radarView.layer.addAnimation(spin, forKey: "spinRadarView")
    }
    
    // MARK: Location Delegate Methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        
        // Change how detail you want the map to show (smaller means more detailed)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: false)
        locManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
    
    // MARK: Ripple Animation
    func tapAvatarImageAction(img: AnyObject) {
        let stroke = UIColor(red: 192/255, green: 57/255, blue: 43/255, alpha: 1.0)
        let pathFrame = CGRectMake(-CGRectGetMidX(userAvatarImageView.bounds), -CGRectGetMidY(userAvatarImageView.bounds), userAvatarImageView.bounds.size.width, userAvatarImageView.bounds.size.height)
        let path = UIBezierPath(roundedRect: pathFrame, cornerRadius: mapView.layer.cornerRadius)
        let shapePosition = mapView.convertPoint(mapView.center, fromView: nil)
        
        let circleShape = CAShapeLayer()
        circleShape.path = path.CGPath
        circleShape.position = shapePosition
        circleShape.fillColor = UIColor.clearColor().CGColor
        circleShape.opacity = 0
        circleShape.strokeColor = stroke.CGColor
        circleShape.lineWidth = 1.3
        mapView.layer.addSublayer(circleShape)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            circleShape.removeFromSuperlayer()
        }
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        scaleAnimation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(3.5, 3.5, 1))
        
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 1
        alphaAnimation.toValue = 0
        
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, alphaAnimation]
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        circleShape.addAnimation(animation, forKey: nil)
        
        CATransaction.commit()
    }
    
}

