//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by William K Hughes on 11/4/20.
//

import Foundation
import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIToolbar!
    
    // MARK: - Properties: Variables and Constants
    
    var dataController: DataController!
    var pin: Pin!
    var photos: [Photo] = []
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    let numberOfCellsPerRow: CGFloat = 3
    
    //MARK: - Fileprivate Functions
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func centerMapOnLocation(_ location: CLLocation, mapView: MKMapView) {
        
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    fileprivate func setUpMap() {
        self.mapView.delegate = self
        self.mapView.isZoomEnabled = false
        self.mapView.isScrollEnabled = false
        
        let clLocation = CLLocation(latitude: pin.latitude, longitude: pin.longitude)
        
        centerMapOnLocation(clLocation , mapView: self.mapView)
        setUpPin()
    }
            
    fileprivate func setUpPin() {
                
        var annotations = [MKPointAnnotation]()
        let lat = CLLocationDegrees((pin.value(forKeyPath: "latitude") as? Double) ?? 0.0 )
        let long = CLLocationDegrees((pin.value(forKeyPath: "longitude") as? Double) ?? 0.0 )
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        annotations.append(annotation)
        
        self.mapView.addAnnotations(annotations)
    }
    
    fileprivate func setUpCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        flowLayout.scrollDirection = .vertical
        self.collectionView.collectionViewLayout = self.flowLayout
    }
    
    //MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
        loadFlickrImages()
        setUpCollection()
        setUpMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.delegate = self
        collectionView.dataSource = self
        setupFetchedResultsController()
        setupCells()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //MARK: - Functions
    
    func setupCells(){
        
        guard (fetchedResultsController.fetchedObjects?.count != 0) else{
            loadFlickrImages()
            return
        }
        
        showActivity(true)
        photos = fetchedResultsController.fetchedObjects!
        collectionView.reloadData()
        showActivity(false)
    }
    
    func loadFlickrImages() {
        showActivity(true)
        FlickrClient.getPhotosSearch(latitude: pin.latitude, longitude:  pin.longitude, completion: handleFlickrImagesSearchResponse)
    }

    func handleFlickrImagesSearchResponse(response: FlickrResponse?, error: Error?){
        guard error == nil , response != nil else {
            showActivity(false)
            showError(title: "Error", message: error?.localizedDescription ?? "try again later")
            return
        }
        
        guard (response?.photos?.photo.count ?? 0) > 0 else {
            showActivity(false)
            showError(title: "No Photos Found", message: "No photos found at this location, try again later")
            return
        }
        
        photos = []
        for photoData in (response?.photos?.photo)! {
            let photo = Photo(context:dataController.viewContext)
            photo.imageData = UIImage(named: "placeholderImage")!.pngData()
            photos.append(photo)
            
            FlickrClient.loadImage(photoData: photoData, image: photo, completion: handleLoadImage)
        }
        collectionView.reloadData()
        showActivity(false)
    }
    
    func handleLoadImage(image: Photo, data: Data?, error: Error?){
        guard data != nil, error == nil else {
            photos.remove(at: photos.firstIndex(of: image)!)
            dataController.viewContext.delete(image)
            return
        }
        
        guard photos.contains(image) else{
            return
        }
        
        image.imageData = data
        image.dateCreated = Date()
        image.pin = pin

        try? dataController.viewContext.save()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func getNewCollection(_ sender: Any) {
        for image in photos{
            deleteImage(image: image)
        }
        photos = []
        collectionView.reloadData()
        loadFlickrImages()
    }
    
    
}
