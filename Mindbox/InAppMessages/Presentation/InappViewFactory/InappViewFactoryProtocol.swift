//
//  InappViewFactory.swift
//  Mindbox
//
//  Created by vailence on 12.07.2023.
//  Copyright © 2023 Mindbox. All rights reserved.
//

import UIKit
import Foundation

protocol InAppPresentationFactoryProtocol {
    func create(inAppUIModel: InAppMessageUIModel) -> UIViewController
}

// View по центру экрана без анимации
class ModalViewFactory: InAppPresentationFactoryProtocol {
    
    var myView: UIView?
    
    func create(inAppUIModel: InAppMessageUIModel) -> UIViewController {
        let viewController = InAppMessageViewController(inAppUIModel: inAppUIModel) {
            
        } onTapAction: {
            
        } onClose: {
            
        }

        return viewController
    }
    
    func setupConstraints(in parentView: UIView) {
        
    }
    
    func animateConstraints(in parentView: UIView, withDuration duration: TimeInterval) {
        // Тут не нужна анимация
    }
}
//
//// Снэкбар внизу экрана
//class BottomSnackbarViewFactory: InAppPresentationFactoryProtocol {
//
//    private let height: CGFloat
//    private var edgeConstraint: NSLayoutConstraint?
//
//    init(height: CGFloat) {
//        self.height = height
//    }
//
//    private var snackbarView: SnackbarView?
//    var imageHeight: CGFloat?
//
//    func create(inAppUIModel: InAppMessageUIModel) -> UIView {
//        let view = SnackbarView(inAppUIModel: inAppUIModel)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        snackbarView = view
//        return view
//    }
//
//    func setupConstraints(in parentView: UIView) {
//        guard let view = snackbarView else {
//            return
//        }
//
//        let edgeConstraint = view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: height)
//
//        NSLayoutConstraint.activate([
//            view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
//            view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
//            edgeConstraint,
//            view.heightAnchor.constraint(equalToConstant: height)
//        ])
//
//        self.edgeConstraint = edgeConstraint
//    }
//
//    func animateConstraints(in parentView: UIView, withDuration duration: TimeInterval) {
//        guard let edgeConstraint = self.edgeConstraint else {
//            return
//        }
//
//        parentView.layoutIfNeeded()
//
//        UIView.animate(withDuration: duration) {
//            edgeConstraint.constant = 0
//            parentView.layoutIfNeeded()
//        }
//    }
//}
//
//// Снэкбар вверху экрана
//class TopSnackbarViewFactory: InAppPresentationFactory {
//
//    private let height: CGFloat
//    private var edgeConstraint: NSLayoutConstraint?
//
//    init(height: CGFloat) {
//        self.height = height
//    }
//
//    private var snackbarView: SnackbarView?
//    var imageHeight: CGFloat?
//
//    func create(inAppUIModel: InAppMessageUIModel) -> UIView {
//        let view = SnackbarView(inAppUIModel: inAppUIModel)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        snackbarView = view
//        return view
//    }
//
//    func setupConstraints(in parentView: UIView) {
//        guard let view = snackbarView else {
//            return
//        }
//
//        let edgeConstraint = view.topAnchor.constraint(equalTo: parentView.topAnchor, constant: -height)
//
//        NSLayoutConstraint.activate([
//            view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
//            view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
//            edgeConstraint,
//            view.heightAnchor.constraint(equalToConstant: height)
//        ])
//
//        self.edgeConstraint = edgeConstraint
//    }
//
//    func animateConstraints(in parentView: UIView, withDuration duration: TimeInterval) {
//        guard let edgeConstraint = self.edgeConstraint else {
//            return
//        }
//
//        parentView.layoutIfNeeded()
//
//        UIView.animate(withDuration: duration) {
//            edgeConstraint.constant = 0
//            parentView.layoutIfNeeded()
//        }
//    }
//}
