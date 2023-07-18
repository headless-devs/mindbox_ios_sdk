//
//  SnackBarViewController.swift
//  Mindbox
//
//  Created by vailence on 17.07.2023.
//  Copyright © 2023 Mindbox. All rights reserved.
//

import UIKit

class SnackbarViewController: UIViewController {
    
    var inAppUIModel: InAppMessageUIModel!
    var snackbarView: SnackbarView!
    var edgeConstraint: NSLayoutConstraint?

    let onPresented: () -> Void
    let onClose: () -> Void
    let onTapAction: () -> Void
    
    enum Constants {
        static let crossViewVerticalOffsetPercent: CGFloat = 3
        static let crossViewHorizontalOffsetPercent: CGFloat = 3
        static let animationDuration: TimeInterval = 0.5
        static let screenPart: CGFloat = 3.0
        static let oneThirdScreenHeight: CGFloat = UIScreen.main.bounds.height / Constants.screenPart
    }

    init(with inAppUIModel: InAppMessageUIModel,
         onPresented: @escaping () -> Void,
         onTapAction: @escaping () -> Void,
         onClose: @escaping () -> Void) {
        self.inAppUIModel = inAppUIModel
        self.onPresented = onPresented
        self.onClose = onClose
        self.onTapAction = onTapAction

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.snackbarView = SnackbarView(image: inAppUIModel.image,
                                         onClose: onClose,
                                         crossViewVerticalOffsetPercent: Constants.crossViewVerticalOffsetPercent,
                                         crossViewHorizontalOffsetPercent: Constants.crossViewHorizontalOffsetPercent)
        snackbarView.translatesAutoresizingMaskIntoConstraints = false
        snackbarView.isUserInteractionEnabled = true
        snackbarView.swipeDirection = swipeDirection
        let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage))
        snackbarView.imageView.addGestureRecognizer(imageTapGestureRecognizer)
        view.addSubview(snackbarView)

        setupConstraints()
    }

    var swipeDirection: UISwipeGestureRecognizer.Direction {
        fatalError("This method must be overridden")
    }
    
    func setupConstraints() {
        fatalError("This method must be overridden")
    }
    
    private func animateConstraints(withDuration duration: TimeInterval) {
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: duration) {
            self.edgeConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    @objc func onTapImage() {
         onTapAction()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateConstraints(withDuration: Constants.animationDuration)
        onPresented()
    }
}

class TopSnackbarViewController: SnackbarViewController {

    override var swipeDirection: UISwipeGestureRecognizer.Direction {
        return .up
    }
    
    override func setupConstraints() {
        let imageHeight = inAppUIModel.image.size.height
        let screenHeight = UIScreen.main.bounds.height
        let safeAreaTopOffset = view.safeAreaInsets.top
        let finalHeight = (imageHeight < Constants.oneThirdScreenHeight) ? imageHeight : Constants.oneThirdScreenHeight

        self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: finalHeight + safeAreaTopOffset)
        
        NSLayoutConstraint.activate([
            snackbarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            snackbarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            snackbarView.heightAnchor.constraint(equalToConstant: finalHeight),
        ])
        
        setupTopConstraint(with: finalHeight)
    }
    
    private func setupTopConstraint(with height: CGFloat) {
        edgeConstraint = snackbarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -height)
        edgeConstraint?.isActive = true
    }
}

class BottomSnackbarViewController: SnackbarViewController {

    override var swipeDirection: UISwipeGestureRecognizer.Direction {
        return .down
    }
    
    override func setupConstraints() {
        let imageHeight = inAppUIModel.image.size.height
        let screenHeight = UIScreen.main.bounds.height
        let safeAreaBottomOffset = view.safeAreaInsets.bottom
        let finalHeight = (imageHeight < Constants.oneThirdScreenHeight) ? imageHeight : Constants.oneThirdScreenHeight

        self.view.frame = CGRect(x: 0, y: screenHeight - finalHeight - safeAreaBottomOffset, width: UIScreen.main.bounds.width, height: finalHeight)

        NSLayoutConstraint.activate([
            snackbarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            snackbarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            snackbarView.heightAnchor.constraint(equalToConstant: finalHeight),
        ])

        setupBottomConstraint(with: finalHeight)
    }

    private func setupBottomConstraint(with height: CGFloat) {
        edgeConstraint = snackbarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: height)
        edgeConstraint?.isActive = true
    }
}
