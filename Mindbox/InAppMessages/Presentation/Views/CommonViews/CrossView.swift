//
//  CrossView.swift
//  Mindbox
//
//  Created by vailence on 11.07.2023.
//  Copyright © 2023 Mindbox. All rights reserved.
//

import UIKit

class CrossView: UIView {
    
    var lineColor: UIColor = .black
    var lineWidth: CGFloat = 1.0
    var crossSize: CGFloat = 30.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
    }
    
    convenience init(lineColor: UIColor, lineWidth: CGFloat, crossSize: CGFloat) {
        self.init()
        
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.crossSize = crossSize
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineWidth(lineWidth)
        lineColor.setStroke()
        context.setLineCap(.round)
        
        // Рисуем первую диагональ
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: crossSize, y: crossSize))
        
        // Рисуем вторую диагональ
        context.move(to: CGPoint(x: crossSize, y: 0))
        context.addLine(to: CGPoint(x: 0, y: crossSize))
        
        context.strokePath()
    }
}
