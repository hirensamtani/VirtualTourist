//
//  PhotosCollectionViewController.swift
//  VirtualTourist
//
//  Created by Hiren Samtani on 27/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class PhotosCollectionViewController: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    // Pin
    var selectedPin: Pin?
    // FlickrPhotos
    var photos: [Photo] = [Photo]()
    // Data Stack
    var stack: DataController?
    // Flow Layout
    var flowLayout: UICollectionViewFlowLayout {
        return self.photosCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    var defaults = UserDefaults.standard
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flowLayout.estimatedItemSize = CGSize(width: 100, height: 100)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        stack = delegate.stack
        
        initMap()
       
        if (selectedPin?.photos?.count)! <= 0 {
            loadPhotos()
        } else {
            photos = (selectedPin?.photos)!.allObjects as! [Photo]
            
        }
        
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = floor(self.photosCollectionView.frame.size.width / 3)
        layout.itemSize = CGSize(width: width, height: width)
        photosCollectionView.collectionViewLayout = layout
       
    }
    
    // MARK: Initializers
    func initMap() {
        mapView.delegate = self
        mapView.addAnnotation(selectedPin!)
        mapView.centerCoordinate = selectedPin!.coordinate
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
    }
    
    // MARK: Fetch Photos
    func loadPhotos() {
        FlickrClient.sharedInstance().getLocationPhotos(pin: selectedPin!, latitude: selectedPin!.latitude, longitude: selectedPin!.longitude) { (_ result: [Photo]?, _ error: NSError?) in
            self.photos = result!
            self.performUIUpdatesOnMain {
                self.photosCollectionView.reloadData()
            }
        }
    }
    
    
    @IBAction func newCollection(_ sender: Any) {
        
        for photo in photos {
//            stack?.context.delete(photo)
        
            stack?.viewContext.delete(photo)
        }
        photos = [Photo]()
        photosCollectionView.reloadData()
        loadPhotos()
        
    }
    
    
    
}


// MARK: MKMapViewDelegate
extension PhotosCollectionViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.animatesDrop = false
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}

// MARK: CollectionDelegate
extension PhotosCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! PhotoViewCell
        let flickrPhoto = photos[indexPath.row]
        let photoUrl = flickrPhoto.flickrUrl
        cell.photo.image = UIImage(named: "placeholder")
        
        
        
        if let data = flickrPhoto.data {
            let image = UIImage(data: data as Data)
            cell.photo.image = image
            cell.hideLoading()
        } else {
            cell.showLoading()
            let _ = FlickrClient.sharedInstance().taskForGETImage(filePath: photoUrl!, completionHandlerForImage: { (imageData, error) in
                if let image = UIImage(data: imageData!) {
                    self.performUIUpdatesOnMain {
                        cell.hideLoading()
                        flickrPhoto.data = imageData! as Data
                        try? self.stack?.viewContext.save()
                        cell.photo.image = image
                    }
                } else {
                    debugPrint("Error loading image: \(String(describing: error))")
                }
            })
            
        }
        
        return cell
        
    }
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        stack?.viewContext.delete(photo)
        photos.remove(at: indexPath.row)
        photosCollectionView.reloadData()
    }
    
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
}
