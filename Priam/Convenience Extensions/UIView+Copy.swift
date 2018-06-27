//
//  UIView+Copy.swift
//  Priam
//
//  Created by Vincent on 2018/4/26.
//  Copyright © 2018 Vincent. All rights reserved.
//

extension UIView
{
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }

    var screenshot: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        if let tableView = self as? UITableView {
            tableView.superview!.layer.render(in: UIGraphicsGetCurrentContext()!)
        } else {
            layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
    func takeSnapShot(currentView: UIView , addViews: [UIView], hideViews: [UIView]) -> UIImage {
        
        
        for hideView in hideViews {
            hideView.isHidden = true
        }
        
        UIGraphicsBeginImageContextWithOptions(currentView.frame.size, false, 0.0)
        
        currentView.drawHierarchy(in: currentView.bounds, afterScreenUpdates: true)
        for addView in addViews{
            addView.drawHierarchy(in: addView.frame, afterScreenUpdates: true)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        for hideView in hideViews {
            hideView.isHidden = false
        }
        
        return image!
    }
}
