//
//  PhotoAlbumCellView.swift
//  Virtual Tourist
//
//  Created by William K Hughes on 11/5/20.
//

import Foundation
import UIKit

class PhotoAlbumCellView: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView! = {
        let imageView = UIImageView()
        return imageView
    }()
}
