//
//  FlickrPhotoCell.swift
//  FlickrSample
//
//  Created by Zensar on 01/08/17.
//  Copyright © 2017 Zensar. All rights reserved.
//

import UIKit

class FlickrPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override var isSelected: Bool{
        didSet{
            imageView.layer.borderWidth = isSelected ? 10 : 0
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.borderColor = themeColor.cgColor
        isSelected = false
    }
}
