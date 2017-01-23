//
//  Reusable and Nib-loadable
//
//
//  Created by Andreas Braun on 19.12.16.
//
//

import UIKit

// MARK: ReusableView

protocol ReusableView { }

extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableView { }
extension UICollectionViewCell: ReusableView { }

// MARK: NibLoadableView

protocol NibLoadableView { }

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}

extension UITableViewCell: NibLoadableView { }
extension UICollectionViewCell: NibLoadableView { }

// MARK: Functionality

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type, bundle: Bundle? = nil) where T: NibLoadableView, T: ReusableView {
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        register(nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
}

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type, bundle: Bundle? = nil) where T: NibLoadableView, T: ReusableView {
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
}
