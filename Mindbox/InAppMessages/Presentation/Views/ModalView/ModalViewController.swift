//
//  ModalViewController.swift
//  Mindbox
//
//  Created by Максим Казаков on 07.09.2022.
//

import UIKit

final class ModalViewController: UIViewController {
    
    var layers = [UIView]()
    var elements = [UIView]()
    private let elementFactories: [ContentElementType: ElementFactory] = [
        .closeButton: CloseButtonElementFactory()
    ]
    
    private let layersFactories: [ContentBackgroundLayerType: LayerFactory] = [
        .image: ImageLayerFactory()
    ]

    init(
        inAppUIModel: InAppFormData,
        onPresented: @escaping () -> Void,
        onTapAction: @escaping (ContentBackgroundLayerAction?) -> Void,
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
    private let onTapAction: (ContentBackgroundLayerAction?) -> Void

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.2)
        let onTapDimmedViewGesture = UITapGestureRecognizer(target: self, action: #selector(onTapDimmedView))
        view.addGestureRecognizer(onTapDimmedViewGesture)
        view.isUserInteractionEnabled = true
        
        setupLayers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        guard let crossView = gesture.view else {
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

    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? InAppImageOnlyView else {
            return
        }
        
        let action = imageView.action
        onTapAction(action)
    }
    
    private func setupLayers() {
        guard inAppUIModel.content.type == .modal else  {
            return
        }
        
        guard let layers = inAppUIModel.content.content?.background.layers.elements else {
            return
        }
        
        for layer in layers {
            if let factory = layersFactories[layer.type] {
                let layerView = factory.create(from: inAppUIModel.image, action: layer.action, in: view, with: self)
                if let layerView = layerView {
                    self.layers.append(layerView)
                    view.addSubview(layerView)
                    factory.setupConstraints(for: layerView, in: view)
                }
            }
        }
    }
    
    private func setupElements() {
        guard inAppUIModel.content.type == .modal else  {
            return
        }
        
        guard let elements = inAppUIModel.content.content?.elements?.elements,
              let inappView = layers.first(where: { $0 is InAppImageOnlyView }) else {
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
