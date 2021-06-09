//
//  DiscountResponse.swift
//  Mindbox
//
//  Created by lbr on 08.06.2021.
//  Copyright © 2021 Mikhail Barilov. All rights reserved.
//

import Foundation

open class DiscountResponse: Decodable {
    public let amount: Double?
    public let amountType: DiscountAmountTypeResponse?
}
