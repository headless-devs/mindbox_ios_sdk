//
//  CrossView.swift
//  Mindbox
//
//  Created by vailence on 18.07.2023.
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
        let path = UIBezierPath()

        path.lineWidth = lineWidth
        path.lineCapStyle = .round

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: crossSize, y: crossSize))
        path.move(to: CGPoint(x: crossSize, y: 0))
        path.addLine(to: CGPoint(x: 0, y: crossSize))

        lineColor.setStroke()

        path.stroke()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round

        self.layer.addSublayer(shapeLayer)
    }
}
