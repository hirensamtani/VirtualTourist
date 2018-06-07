//
//  MapPinsViewController.swift
//  VirtualTourist
//
//  Created by Hiren Samtani on 27/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapPinsViewController: UIViewController {

    enum MapUserDefaultKeys: String {
        case persistantMapCenterLongitude, persistantMapCenterLatitude, persistantMapSpanX, persistantMapSpanY
    }
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var annotations: [MKAnnotation] = [MKAnnotation]()
    // Pins
    var pins: [Pin] = [Pin]()
    var selectedPin: Pin?
    var stack: DataController!
    
    var defaults = UserDefaults.standard
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        stack = delegate.stack
        pins = fetchPins()
        
        mapView.delegate = self
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapPinsViewController.longPress(_:)))
        longPressRecognizer.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecognizer)
        
        populateMap()
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detail") {
            let collectionVC = segue.destination as! PhotosCollectionViewController
            collectionVC.selectedPin = self.selectedPin
        }
    }
    
    // MARK: Pin and Annotations
    func populateMap() {
        
        //Initialize Region and Auto Save
        let centerLong = (defaults.object(forKey: MapUserDefaultKeys.persistantMapCenterLongitude.rawValue) as? Double) ?? 77
        let centerLat = (defaults.object(forKey: MapUserDefaultKeys.persistantMapCenterLatitude.rawValue) as? Double) ?? 28
        let spanX = (defaults.object(forKey: MapUserDefaultKeys.persistantMapSpanX.rawValue) as? Double) ?? 25.0
        let spanY = (defaults.object(forKey: MapUserDefaultKeys.persistantMapSpanY.rawValue) as? Double) ?? 25.0
        let center = CLLocationCoordinate2DMake(centerLat, centerLong)
        let span = MKCoordinateSpanMake(spanX, spanY)
        let region = MKCoordinateRegionMake(center, span)
        mapView.setRegion(region, animated: false)
        autoSaveRegion(3)
        
        
        for pin in pins {
            mapView.addAnnotation(pin)
        }
    }
    
    
    
    func autoSaveRegion(_ delayInSeconds : Int) {
        if delayInSeconds > 0 {
            saveCurrentRegionLocation()
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSaveRegion(delayInSeconds)
            }
        }
    }
    
    func saveCurrentRegionLocation() {
        defaults.set(mapView.region.center.latitude as Double, forKey: MapUserDefaultKeys.persistantMapCenterLatitude.rawValue)
        defaults.set(mapView.region.center.longitude as Double, forKey: MapUserDefaultKeys.persistantMapCenterLongitude.rawValue)
        defaults.set(mapView.region.span.latitudeDelta, forKey: MapUserDefaultKeys.persistantMapSpanX.rawValue)
        defaults.set(mapView.region.span.longitudeDelta, forKey: MapUserDefaultKeys.persistantMapSpanY.rawValue)
    }
    
    
    func createPin(_ location: CLLocationCoordinate2D) -> Pin {
        let pin: Pin = Pin(coordinate: location, title: "", context: stack.viewContext)
        print("Pin object created:\n\(pin)")
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveViewContext()
        print("Pin created, stack saved")
        
        return pin
    }
    
    func fetchPins() -> [Pin] {
        var pins = [Pin]()
        let fr: NSFetchRequest<NSFetchRequestResult> = Pin.fetchRequest()

        do {
             let results = try stack.viewContext.fetch(fr) as! [Pin]
            pins = results
        } catch let e as NSError {
            print("Error while trying to perform a search: \n\(e)")
        }

        return pins
    }
    
    
}

// MARK: MKMapViewDelegate
extension MapPinsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.animatesDrop = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        selectedPin = view.annotation as? Pin
        performSegue(withIdentifier: "detail", sender: self)
    }
    
    
    
}

// MARK: Long Press
extension MapPinsViewController {
    @objc func longPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != UIGestureRecognizerState.began {
            return
        }
        let touchPoint: CGPoint = gesture.location(in: mapView)
        let touchCoordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        mapView.addAnnotation(createPin(touchCoordinate))
    }
}

