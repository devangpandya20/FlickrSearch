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
    
    var largePhotoIndexPath: NSIndexPath?{
        didSet{
            var indexPaths = [IndexPath]()
            if let largePhotoIndexPath = largePhotoIndexPath{
                indexPaths.append(largePhotoIndexPath as IndexPath)
            }
            if let oldValue = oldValue{
                indexPaths.append(oldValue as IndexPath);
            }
            collectionView?.performBatchUpdates({
                self.collectionView?.reloadItems(at: indexPaths)
            }, completion: { (completed) in
                if let largePhotoIndexPath = self.largePhotoIndexPath{
                    self.collectionView?.scrollToItem(at: (largePhotoIndexPath as NSIndexPath) as IndexPath, at:.centeredVertically , animated: true)
                }
            })
        }
    }
    
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
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FlickrPhotoHeaderView", for: indexPath) as! FlickrPhotoHeaderView
            headerView.lblSectionTitle.text = searches[(indexPath as NSIndexPath).section].searchTerm
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
    override func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,for: indexPath) as! FlickrPhotoCell
        let flickrPhoto = photoForIndexPath(indexPath: indexPath)

        cell.activityIndicator.stopAnimating()
        
        guard indexPath == largePhotoIndexPath as IndexPath? else {
            cell.imageView.image = flickrPhoto.thumbnail
            return cell
        }
        guard flickrPhoto.largeImage == nil else {
            cell.imageView.image = flickrPhoto.largeImage
            return cell
        }
        cell.imageView.image = flickrPhoto.thumbnail
        cell.activityIndicator.startAnimating()
        flickrPhoto.loadLargeImage { (loadedFlickrPhoto, error) in
            cell.activityIndicator.stopAnimating()
            guard (loadedFlickrPhoto.largeImage != nil) && error == nil else{
                return
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? FlickrPhotoCell, indexPath == self.largePhotoIndexPath as IndexPath? {
                cell.imageView.image = loadedFlickrPhoto.largeImage
            }
        }
       
        return cell
    }
}
extension FlickrPhotosViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath == largePhotoIndexPath as IndexPath?{
            let flickrPhoto = photoForIndexPath(indexPath: indexPath)
            var size = collectionView.bounds.size
            size.height -= topLayoutGuide.length
            size.height -= (sectionInsets.top + sectionInsets.right)
            size.width -= (sectionInsets.left + sectionInsets.right)
            return flickrPhoto.sizeToFillWidthOfSize(size)
        }
        
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
extension FlickrPhotosViewController{
    override func collectionView(_ collectionView: UICollectionView,
                                 shouldSelectItemAt indexPath: IndexPath) -> Bool {
        largePhotoIndexPath = indexPath as NSIndexPath
        return false
    }
}
