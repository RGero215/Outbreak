//
//  BeaconViewController.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/30/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import HDAugmentedReality
import Alamofire

class BeaconViewController: UIViewController, CLLocationManagerDelegate {
    
    var user: User?
    
    
    var arViewController: ARViewController!
    var mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    var locationManager:CLLocationManager = CLLocationManager()
    
    var isCapture: Bool = false
    
   
    var arannotation: ARAnnotation?
//    var arannotation2: ARAnnotation?
    
    var startedLoadingPOIs = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.fillSuperview()
        mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        isCapture = false
        fetchUserProfile()
    }
    
    
    func fetchBeacons() {
        
        guard let uuid = user?.UUID else {return}
        guard let majorInt = user?.major else {return}
        guard let minorInt = user?.minor else {return}
        guard let name = user?.fullName else {return}
        
        
        let userUUID = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let major: CLBeaconMajorValue = CLBeaconMajorValue(majorInt)
        let minor: CLBeaconMinorValue = CLBeaconMinorValue(minorInt)
        let identifier = name
        
        
        if #available(iOS 13, *) {
            // use the shiny new one
            let identetyConstraint = CLBeaconIdentityConstraint(uuid: userUUID, major: major)
            let userIdentifier = CLBeaconRegion(beaconIdentityConstraint: identetyConstraint, identifier: identifier)
            
            
            locationManager.startMonitoring(for: userIdentifier)
            locationManager.startRangingBeacons(satisfying: identetyConstraint)
        } else {
            // use the old one
            let drugs = CLBeaconRegion(proximityUUID: userUUID, major: major, minor: minor, identifier: identifier)
            
            locationManager.startMonitoring(for: drugs)
            locationManager.startRangingBeacons(in: drugs)
        }
        arannotation = addAnnotation(identifier: identifier, title: name, location: locationManager.location!)
        print("Coordinate to jessie: ", locationManager.location)
        
    }
    
    func addAnnotation(identifier: String, title: String, location: CLLocation) -> ARAnnotation {
        return ARAnnotation(identifier: identifier, title: title, location: location)!
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            // User has authorized the application - range beacon
           
            fetchBeacons()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        guard let discoveredBeacon = beacons.first?.proximity else {print("Couldn't find any beacon"); return}
        
        
        
                
            switch discoveredBeacon {
            case .immediate:
                presentARController()
                print("You been too close to Jessie ...")
            case .near:
                presentARController()
                print("Careful Jessie is close to me...")
            case .far:
                mapView.addAnnotation(arannotation!)
                print("Jessie is Far away...")
            case .unknown:
                mapView.addAnnotation(arannotation!)

            }
        
    }
    
    func presentARController(){
        
        if presentedViewController == nil && !isCapture {
            arViewController = ARViewController()
            // Presenter - handles visual presentation of annotations
            let presenter = arViewController.presenter!
//            let annotations = [arannotation, arannotation2].compactMap{ $0 }
            presenter.presenterTransform = ARPresenterStackTransform()

            arViewController.dataSource = self
            arViewController.trackingManager.userDistanceFilter = 0
            arViewController.trackingManager.reloadDistanceFilter = 75
            arViewController.setAnnotations([arannotation!])
            
            let radar = RadarMapView()
            radar.startMode = .centerUser(span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            radar.trackingMode = .centerUserWhenNearBorder(span: nil)
            radar.indicatorRingType = .segmented(segmentColor: nil, userSegmentColor: nil)
            radar.maxDistance = 5000    // Limit bcs it drains battery if lots of annotations (>200), especially if indicatorRingType is .precise
            arViewController.addAccessory(radar, leading: 15, trailing: nil, top: nil, bottom: 15, width: nil, height: 150)
            arViewController.modalPresentationStyle = .fullScreen
            self.present(arViewController, animated: true, completion: nil)
        }
        
    }
    
    
    
    func showInfoView(forPlace place: ARAnnotation) {
        let alert = UIAlertController(title: place.title , message: place.identifier, preferredStyle: UIAlertController.Style.alert)
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.isCapture = true
            self.arViewController.dismiss(animated: true, completion: nil)
        }
      alert.addAction(okAction)
        
      
      arViewController.present(alert, animated: true, completion: nil)
    }
}

extension BeaconViewController {
    
    
  func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    return true
  }
    
    
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    if locations.count > 0 {
      let location = locations.last!
      if location.horizontalAccuracy < 100 {
        manager.stopUpdatingLocation()
        let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.region = region
        
            if !startedLoadingPOIs {
              startedLoadingPOIs = true
                
                DispatchQueue.main.async {
                    self.mapView.addAnnotations([self.arannotation!])
                }
            }
        }
      
    }
  }
    
    func fetchUserProfile() {

        let url = "\(Service.shared.baseUrl)/profile"
        AF.request(url)
            .validate(statusCode: 200..<300)
            .responseData { (dataResp) in
                let data = dataResp.data ?? Data()
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    self.user = user
                    
                    print(self.user!)
                    
                } catch {
                    print("Failed to decode user:", error)
                }
        }
    }
}



extension BeaconViewController: ARDataSource {
  func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
    let annotationView = AnnotationView()
    annotationView.annotation = viewForAnnotation
    annotationView.delegate = self
    annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
    
    return annotationView
  }
}

extension BeaconViewController: AnnotationViewDelegate {
  func didTouch(annotationView: AnnotationView) {
    if let annotation = annotationView.annotation {
      
        
        DispatchQueue.main.async {
            print("touching...")
            annotation.subtitle = "You've been Capture"
            
            self.showInfoView(forPlace: annotation)
          
        }
        
    }
  }
}





