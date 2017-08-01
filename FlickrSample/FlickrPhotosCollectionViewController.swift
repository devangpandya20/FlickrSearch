//
//  FlickrPhotosCollectionViewController.swift
//  FlickrSample
//
//  Created by Zensar on 01/08/17.
//  Copyright © 2017 Zensar. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

final class FlickrPhotosViewController: UICollectionViewController {
    
    // MARK: - Properties
    fileprivate let reuseIdentifier = "FlickrCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    fileprivate var searches = [FlickrSearchResults]()
    fileprivate let flickr = Flickr()
    fileprivate let itemsPerRow: CGFloat = 3
}
private extension FlickrPhotosViewController{
    func photoForIndexPath(indexPath: IndexPath) -> FlickrPhoto{
        return searches[(indexPath as NSIndexPath).section].searchResults[(indexPath as NSIndexPath).row];
    }
}
extension FlickrPhotosViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:.gray);
        textField.addSubview(activityIndicator)
        activityIndicator.frame=textField.bounds
        activityIndicator.startAnimating()
        
        flickr.searchFlickrForTerm(textField.text!) { (results, error) in
            activityIndicator.removeFromSuperview()
            
            if let error = error{
                print("Error Searching : \(error)")
                return
            }
            if let results = results{
                print ("Found \(results.searchResults.count) matching \(results.searchTerm)")
                self.searches.insert(results, at: 0);
                self.collectionView?.reloadData()
            }
        }
        textField.text = nil;
        textField.resignFirstResponder()
        return true
    }
}
extension FlickrPhotosViewController{
    override func numberOfSections(in collectionView: UICollectionView) -> Int{
        return searches.count
    }
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
    override func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,for: indexPath) as! FlickrPhotoCell
        let flickrPhoto = photoForIndexPath(indexPath: indexPath)
        cell.backgroundColor = UIColor.white
        cell.imageView.image = flickrPhoto.thumbnail
        return cell
    }
}
extension FlickrPhotosViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left*(itemsPerRow+1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem);
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
