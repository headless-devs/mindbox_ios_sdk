//
//  ElementFactory.swift
//  Mindbox
//
//  Created by vailence on 04.08.2023.
//  Copyright © 2023 Mindbox. All rights reserved.
//

import UIKit

protocol ElementFactory {
    func create(from element: ContentElement, in view: UIView, with controller: UIViewController) -> UIView?
    func setupConstraints(for view: UIView, from element: ContentElement, in parentView: UIView)
}
