//
//  SnackBar.swift
//  Mindbox
//
//  Created by vailence on 11.07.2023.
//

import UIKit

enum SnackbarType {
    case top
    case bottom
}

class SnackbarView: UIView {
    let imageView: UIImageView
    let crossView: CrossView
    
    private let onClose: () -> Void

    var swipeDirection: UISwipeGestureRecognizer.Direction = .down // значение по умолчанию

    init(image: UIImage,
         onClose: @escaping () -> Void) {
        self.imageView = UIImageView(image: image)
        self.crossView = CrossView(lineColor: .white, lineWidth: 2.0, crossSize: 20.0)
        self.onClose = onClose
        super.init(frame: .zero)
        
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        
        addSubview(imageView)
        addSubview(crossView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        crossView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            crossView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10),
            crossView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
            crossView.widthAnchor.constraint(equalToConstant: crossView.crossSize),
            crossView.heightAnchor.constraint(equalToConstant: crossView.crossSize)
        ])

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        self.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        switch gesture.state {
        case .changed:
            if swipeDirection == .up && translation.y < 0 {
                self.transform = CGAffineTransform(translationX: 0, y: translation.y)
                self.alpha = max(0, 1 - abs(translation.y) / self.frame.height)
            }
            else if swipeDirection == .down && translation.y > 0 {
                self.transform = CGAffineTransform(translationX: 0, y: translation.y)
                self.alpha = max(0, 1 - abs(translation.y) / self.frame.height)
            }
        case .ended, .cancelled:
            if abs(translation.y) > self.frame.height / 2 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0
                    self.transform = CGAffineTransform(translationX: 0, y: self.swipeDirection == .up ? -self.frame.height : self.frame.height)
                }) { [weak self] _ in
                    self?.onClose()
//                    self.removeFromSuperview()
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.alpha = 1
                    self.transform = .identity
                }
            }
        default:
            break
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SnackbarViewController: UIViewController {
    
    var inAppUIModel: InAppMessageUIModel!
    var type: SnackbarType = .bottom

    private var snackbarView: SnackbarView!
    private var edgeConstraint: NSLayoutConstraint?
    
    private let onPresented: () -> Void
    private let onClose: () -> Void
    private let onTapAction: () -> Void

    init(with inAppUIModel: InAppMessageUIModel,
         type: SnackbarType,
         onPresented: @escaping () -> Void,
         onTapAction: @escaping () -> Void,
         onClose: @escaping () -> Void) {
        self.inAppUIModel = inAppUIModel
        self.type = type
        self.onPresented = onPresented
        self.onClose = onClose
        self.onTapAction = onTapAction

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("🔴")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.snackbarView = SnackbarView(image: inAppUIModel.image, onClose: onClose)
        snackbarView.translatesAutoresizingMaskIntoConstraints = false
        snackbarView.isUserInteractionEnabled = true
        let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage))
        snackbarView.addGestureRecognizer(imageTapGestureRecognizer)
        
        view.addSubview(snackbarView)
        
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateConstraints(withDuration: 0.5)
    }
    
    private func setupConstraints() {
        let imageHeight = inAppUIModel.image.size.height
        let screenHeight = UIScreen.main.bounds.height
        let oneThirdScreenHeight = screenHeight / 3.0
        let finalHeight = (imageHeight < oneThirdScreenHeight) ? imageHeight : oneThirdScreenHeight

        self.view.frame = CGRect(x: 0, y: screenHeight - finalHeight, width: UIScreen.main.bounds.width, height: finalHeight)
        NSLayoutConstraint.activate([
            snackbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            snackbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            snackbarView.heightAnchor.constraint(equalToConstant: finalHeight),
        ])
        
        switch type {
        case .top:
            setupTopConstraint(with: finalHeight)
        case .bottom:
            setupBottomConstraint(with: finalHeight)
        }
    }
    
    private func setupTopConstraint(with height: CGFloat) {
        snackbarView.swipeDirection = .up
        edgeConstraint = snackbarView.topAnchor.constraint(equalTo: view.topAnchor, constant: height)
        edgeConstraint?.isActive = true
    }
    
    private func setupBottomConstraint(with height: CGFloat) {
        snackbarView.swipeDirection = .down
        edgeConstraint = snackbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: height)
        edgeConstraint?.isActive = true
    }
    
    private func animateConstraints(withDuration duration: TimeInterval) {
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: duration) {
            self.edgeConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    @objc private func onTapImage() {
         onTapAction()
    }
}
