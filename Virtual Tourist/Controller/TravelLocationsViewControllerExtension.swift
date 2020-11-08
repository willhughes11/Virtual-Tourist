//
//  TravelLocationsViewControllerExtension.swift
//  Virtual Tourist
//
//  Created by William K Hughes on 11/5/20.
//

import Foundation
import MapKit

extension TravelLocationsViewController: MKMapViewDelegate {
    
    func setupMap(){
        var annotations = [AnnotationView]()
        
        for pin in fetchedResultsController!.fetchedObjects! {
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = AnnotationView(coordinate: coordinate, pin: pin)
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
        self.mapView.reloadInputViews()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pinAnnotation = view.annotation as! AnnotationView
        performSegue(withIdentifier: "PhotoAlbumViewSegue", sender: pinAnnotation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PhotoAlbumViewSegue"{
            let photoAlbumView = segue.destination as! PhotoAlbumViewController
            let pinAnnotation = sender as! AnnotationView
            photoAlbumView.pin = pinAnnotation.pin
            photoAlbumView.dataController = dataController
        }
    }
}

