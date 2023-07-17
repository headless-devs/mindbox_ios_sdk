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
    public let imageView: UIImageView
    private let crossView: CrossView
    private let onClose: () -> Void
    public var swipeDirection: UISwipeGestureRecognizer.Direction = .down
    private var crossViewVerticalOffsetPercent: CGFloat
    private var crossViewHorizontalOffsetPercent: CGFloat
    private let animationTime: TimeInterval
    
    enum Constants {
        static let defaultAnimationTime: TimeInterval = 0.3
        static let crossViewLineColor: UIColor = .black
        static let crossViewLineWidth: CGFloat = 2.0
        static let crossViewCrossSize: CGFloat = 20.0
        static let swipeThresholdFraction: CGFloat = 0.5
    }


    init(image: UIImage,
         onClose: @escaping () -> Void,
         crossViewVerticalOffsetPercent: CGFloat,
         crossViewHorizontalOffsetPercent: CGFloat,
         animationTime: TimeInterval = Constants.defaultAnimationTime) {
        self.imageView = UIImageView(image: image)
        self.crossView = CrossView(lineColor: Constants.crossViewLineColor, lineWidth: Constants.crossViewLineWidth, crossSize: Constants.crossViewCrossSize)
        self.onClose = onClose
        self.crossViewVerticalOffsetPercent = crossViewVerticalOffsetPercent
        self.crossViewHorizontalOffsetPercent = crossViewHorizontalOffsetPercent
        self.animationTime = animationTime
        super.init(frame: .zero)

        setupImageView()
        setupCrossView()
        setupPanGesture()
        setupCloseGesture()
    }

    private func setupImageView() {
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupCrossView() {
        addSubview(crossView)
        crossView.translatesAutoresizingMaskIntoConstraints = false
        crossView.layer.zPosition = 2
    }

    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        self.addGestureRecognizer(panGesture)
    }

    private func setupCloseGesture() {
        let closeGesture = UITapGestureRecognizer(target: self, action: #selector(crossAction))
        crossView.addGestureRecognizer(closeGesture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            crossView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: bounds.height * crossViewVerticalOffsetPercent / 100),
            crossView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -bounds.width * crossViewHorizontalOffsetPercent / 100),
            crossView.widthAnchor.constraint(equalToConstant: crossView.crossSize),
            crossView.heightAnchor.constraint(equalToConstant: crossView.crossSize)
        ])
    }

    @objc func crossAction() {
        onClose()
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        switch gesture.state {
        case .changed:
            handleSwipeGesture(translation: translation)
        case .ended, .cancelled:
            finalizeGesture(translation: translation)
        default:
            break
        }
    }

    private func handleSwipeGesture(translation: CGPoint) {
        if translation.y > 0 {
            self.transform = CGAffineTransform(translationX: 0, y: translation.y)
            self.alpha = max(0, 1 - abs(translation.y) / self.frame.height)
        }
    }

    private func finalizeGesture(translation: CGPoint) {
        if abs(translation.y) > self.frame.height * Constants.swipeThresholdFraction {
            UIView.animate(withDuration: animationTime, animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
            }) { [weak self] _ in
                self?.onClose()
            }
        } else {
            UIView.animate(withDuration: animationTime) {
                self.alpha = 1
                self.transform = .identity
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
