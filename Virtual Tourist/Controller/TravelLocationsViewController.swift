//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by William K Hughes on 11/4/20.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController, NSFetchedResultsControllerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    fileprivate func setupFetchResultsController(){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Fetch cold not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        setupFetchResultsController()
        setupMap()
        gestureRecognition()
        mapView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func gestureRecognition(){
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecogniser)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UIGestureRecognizer){
        if gestureRecognizer.state != .began {return}
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let newPin = Pin(context: dataController.viewContext)
        newPin.latitude = touchMapCoordinate.latitude
        newPin.longitude = touchMapCoordinate.longitude
        newPin.dateCreated = Date()
        try? dataController.viewContext.save()
        
        let newAnnotation = AnnotationView(coordinate: touchMapCoordinate, pin: newPin)
        mapView.addAnnotation(newAnnotation)
    }

}
