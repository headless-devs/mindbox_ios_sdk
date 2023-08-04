//
//  ModalViewController.swift
//  Mindbox
//
//  Created by Максим Казаков on 07.09.2022.
//

import UIKit

final class ModalViewController: UIViewController {
    
    var inAppView: InAppImageOnlyView?
    var layers = [UIView]()
    var elements = [UIView]()
    private let elementFactories: [ContentElementType: ElementFactory] = [
        .closeButton: CloseButtonElementFactory()
    ]

    init(
        inAppUIModel: InAppFormData,
        onPresented: @escaping () -> Void,
        onTapAction: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        self.inAppUIModel = inAppUIModel
        self.onPresented = onPresented
        self.onClose = onClose
        self.onTapAction = onTapAction
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let inAppUIModel: InAppFormData
    private let onPresented: () -> Void
    private let onClose: () -> Void
    private let onTapAction: () -> Void

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.2)
        setupLayers()
        
        inAppView = InAppImageOnlyView(image: inAppUIModel.image)
        guard let inAppView = inAppView else {
            return
        }
        
        let onTapDimmedViewGesture = UITapGestureRecognizer(target: self, action: #selector(onTapDimmedView))
        view.addGestureRecognizer(onTapDimmedViewGesture)
        view.isUserInteractionEnabled = true
        view.addSubview(inAppView)
        layers.append(inAppView)
        
        inAppView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inAppView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inAppView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inAppView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            inAppView.widthAnchor.constraint(equalTo: inAppView.heightAnchor, multiplier: 3 / 4)
        ])
        let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage))
        inAppView.addGestureRecognizer(imageTapGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let inAppView = inAppView else {
            return
        }
        
        setupElements()
    }

    private var viewWillAppearWasCalled = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !viewWillAppearWasCalled else { return }
        viewWillAppearWasCalled = true
        onPresented()
    }
    
    @objc func onCloseButton(_ gesture: UILongPressGestureRecognizer) {
        guard let crossView = elements.first else {
            return
        }
        
        let location = gesture.location(in: crossView)
        let isInsideCrossView = crossView.bounds.contains(location)
        if gesture.state == .ended && isInsideCrossView {
            onClose()
        }
    }

    @objc private func onTapDimmedView() {
        onClose()
    }

    @objc private func onTapImage() {
        onTapAction()
    }
    
    private func setupLayers() {
        
    }
    
    private func setupElements() {
        guard inAppUIModel.content.type == .modal else  {
            return
        }
        
        guard let elements = inAppUIModel.content.content?.elements?.elements,
              let inappView = layers.first else {
            return
        }
        
        for element in elements {
            if let factory = elementFactories[element.type] {
                let elementView = factory.create(from: element, in: inappView, with: self)
                if let elementView = elementView {
                    self.elements.append(elementView)
                    inappView.addSubview(elementView)
                    factory.setupConstraints(for: elementView, from: element, in: inappView)
                }
            }
        }
    }
}
