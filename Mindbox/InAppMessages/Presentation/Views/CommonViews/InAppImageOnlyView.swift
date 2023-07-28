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
    let uiModel: InAppMessageUIModel?

    init(uiModel: InAppMessageUIModel) {
        self.uiModel = uiModel
        super.init(frame: .zero)
        customInit()
    }

    required init?(coder: NSCoder) {
        self.uiModel = nil
        super.init(coder: coder)
        customInit()
    }

    func customInit() {
        guard let uiModel = uiModel else {
            return
        }
        
        let image = uiModel.image
        imageView.contentMode = .scaleAspectFill
        imageView.image = image

        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
        layer.masksToBounds = true
    }
}
