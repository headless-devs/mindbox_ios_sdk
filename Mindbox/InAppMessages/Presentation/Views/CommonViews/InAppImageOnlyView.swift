//
//  InAppImageOnlyView.swift
//  Mindbox
//
//  Created by Максим Казаков on 07.09.2022.
//

import UIKit

final class InAppImageOnlyView: UIView {
    var onClose: (() -> Void)?
    let imageView = UIImageView()
    let image: UIImage?

    init(image: UIImage) {
        self.image = image
        super.init(frame: .zero)
        customInit()
    }

    required init?(coder: NSCoder) {
        self.image = nil
        super.init(coder: coder)
        customInit()
    }

    func customInit() {
        guard let image = image else {
            return
        }
        
        imageView.contentMode = .scaleAspectFill
        imageView.image = image

        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
        layer.masksToBounds = true
    }
}
