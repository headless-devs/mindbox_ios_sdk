//
//  ContentElementPositionMargin.swift
//  Mindbox
//
//  Created by vailence on 04.08.2023.
//  Copyright © 2023 Mindbox. All rights reserved.
//

import Foundation

struct ContentElementPositionMargin: Decodable, Equatable {
    let kind: PositionMarginKind
    let top: Double?
    let right: Double?
    let left: Double?
    let bottom: Double?
    
    enum CodingKeys: CodingKey {
        case kind
        case top
        case right
        case left
        case bottom
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<ContentElementPositionMargin.CodingKeys> = try decoder.container(keyedBy: ContentElementPositionMargin.CodingKeys.self)
        
        self.kind = try container.decode(PositionMarginKind.self, forKey: ContentElementPositionMargin.CodingKeys.kind)
        self.top = try container.decodeIfPresent(Double.self, forKey: ContentElementPositionMargin.CodingKeys.top)
        self.right = try container.decodeIfPresent(Double.self, forKey: ContentElementPositionMargin.CodingKeys.right)
        self.left = try container.decodeIfPresent(Double.self, forKey: ContentElementPositionMargin.CodingKeys.left)
        self.bottom = try container.decodeIfPresent(Double.self, forKey: ContentElementPositionMargin.CodingKeys.bottom)
        
        if !ContentElementPositionMarginValidator().isValid(item: self) {
            throw DecodingError.dataCorruptedError(
                forKey: .kind,
                in: container,
                debugDescription: "Position margin corrupted."
            )
        }
    }
    
    init(kind: PositionMarginKind, top: Double? = nil, right: Double? = nil, left: Double? = nil, bottom: Double? = nil) {
        self.kind = kind
        self.top = top
        self.right = right
        self.left = left
        self.bottom = bottom
    }
}
