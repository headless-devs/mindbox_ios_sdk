//
//  SnackBar.swift
//  Mindbox
//
//  Created by vailence on 11.07.2023.
//

import Foundation

enum SnackbarPosition {
    case top
    case bottom
}

class SnackbarView: UIView {
    let imageView: UIImageView
    
    init(inAppUIModel: InAppMessageUIModel) {
        self.imageView = UIImageView(image: UIImage(named: "Group2")!)
        
        super.init(frame: .zero)
        
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SnackbarViewController: UIViewController {
    let snackbarView: SnackbarView
    private let onTapAction: () -> Void
    private let snackbarPosition: SnackbarPosition
    
    init(
        inAppUIModel: InAppMessageUIModel,
        onTapAction: @escaping () -> Void,
        position: SnackbarPosition
    ) {
        self.snackbarView = SnackbarView(inAppUIModel: inAppUIModel)
        self.onTapAction = onTapAction
        self.snackbarPosition = position
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(snackbarView)
        snackbarView.translatesAutoresizingMaskIntoConstraints = false

        // Привязка snackbarView ко всем сторонам контроллера
        NSLayoutConstraint.activate([
            snackbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            snackbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            snackbarView.topAnchor.constraint(equalTo: view.topAnchor),
            snackbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        snackbarView.addGestureRecognizer(tap)
        
        // Начальная позиция за пределами экрана
        view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)

        // Анимация появления снизу вверх
        UIView.animate(withDuration: 1.0) {
            self.view.transform = CGAffineTransform.identity
        }
    }

    
    @objc private func buttonTapped() {
        onTapAction()
        dismiss(animated: true, completion: nil)
    }
}
