//
//  PhotoAlbumViewControllerExtension.swift
//  Virtual Tourist
//
//  Created by William K Hughes on 11/5/20.
//

import Foundation
import UIKit
import MapKit

extension PhotoAlbumViewController: MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    //MARK: - Views

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
        let reuseId = "pin"
            
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
            
        return pinView
    }
    
    func showActivity(_ state:Bool){
        state ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        activityIndicator.isHidden = !state
        navigationController?.toolbar.isUserInteractionEnabled = !state
        navigationController?.navigationBar.isUserInteractionEnabled = !state
    }

    func showError(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(okButton)
        present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: - Collection Views
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       return fetchedResultsController.sections?.count ?? 1
   }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return photos.count
   }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          let padding: CGFloat =  25
          let collectionViewSize = collectionView.frame.size.width - padding

          return CGSize(width: collectionViewSize/4, height: collectionViewSize/3)
      }
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCellView", for: indexPath) as! PhotoAlbumCellView
       
       if let data = photos[indexPath.row].imageData{
           cell.imageView?.image = UIImage(data: data)
       }
       return cell
   }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       deleteImage(image: photos[indexPath.row])
       photos.remove(at: indexPath.row)
       collectionView.reloadData()
   }

    func deleteImage(image: Photo){
        dataController.viewContext.delete(image)
        try? dataController.viewContext.save()
    }
}
