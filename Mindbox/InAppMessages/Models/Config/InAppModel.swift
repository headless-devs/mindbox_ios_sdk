//
//  InAppModel.swift
//  Mindbox
//
//  Created by vailence on 15.06.2023.
//  Copyright © 2023 Mindbox. All rights reserved.
//

import Foundation

struct InApp: Decodable, Equatable {
    let id: String?
    let sdkVersion: SdkVersion?
    let targeting: Targeting?
    let form: InAppForm?
}

struct InAppForm: Decodable, Equatable {
    let variants: [Variant]?
    
    struct Variant: Decodable, Equatable {
        let type: FormType?
        let content: Content?
        
        enum CodingKeys: String, CodingKey {
            case type = "$type"
            case content
        }
    }
}

enum FormType: String, Decodable, Equatable {
    case modal
    case snackbar
    case unknown
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let type: String = try container.decode(String.self)
        self = FormType(rawValue: type) ?? .unknown
    }
}

struct Content: Decodable, Equatable {
    let background: Background?
//    let elements: [Element]?
}

struct Background: Decodable, Equatable {
    let layers: [Layer]?

    struct Layer: Decodable, Equatable {
        let type: LayerType?
//        let action: Action
//        let source: Source

        enum CodingKeys: String, CodingKey {
            case type = "$type"
//            case action
//            case source
        }

        enum LayerType: String, Decodable, Equatable {
            case image
            case unknown
            
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let type: String = try container.decode(String.self)
                self = LayerType(rawValue: type) ?? .unknown
            }
        }
//
//        struct Action: Decodable, Equatable {
//            let type: ActionType
//            let intentPayload: String
//            let value: String
//
//            enum CodingKeys: String, CodingKey {
//                case type = "$type"
//                case intentPayload
//                case value
//            }
//
//            enum ActionType: String, Decodable, Equatable {
//                case redirectUrl
//            }
//        }
//
//        struct Source: Decodable, Equatable {
//            let type: SourceType
//            let value: String
//
//            enum CodingKeys: String, CodingKey {
//                case type = "$type"
//                case value
//            }
//
//            enum SourceType: String, Decodable, Equatable {
//                case url
//            }
//        }
    }
}

//    struct Content: Decodable, Equatable {
//        let background: Background
//        let elements: [Element]?
//
//        struct Element: Decodable, Equatable {
//            let type: ElementType
//            let color: String?
//            let lineWidth: Int?
//            let size: Size?
//            let position: Position?
//            let gravity: Gravity?
//
//            enum CodingKeys: String, CodingKey {
//                case type = "$type"
//                case color
//                case lineWidth
//                case size
//                case position
//                case gravity
//            }
//
//            enum ElementType: String, Decodable, Equatable {
//                case closeButton
//            }
//
//            struct Size: Decodable, Equatable {
//                let kind: SizeKind
//                let width: Double
//                let height: Double
//
//                enum SizeKind: String, Decodable, Equatable {
//                    case dp
//                }
//            }
//
//            struct Position: Decodable, Equatable {
//                let margin: Margin?
//
//                struct Margin: Decodable, Equatable {
//                    let kind: MarginKind
//                    let top: Double
//                    let right: Double
//                    let left: Double
//                    let bottom: Double
//
//                    enum MarginKind: String, Decodable, Equatable {
//                        case proportion
//                    }
//                }
//            }
//
//            struct Gravity: Decodable, Equatable {
//                let horizontal: String
//                let vertical: String
//            }
//        }
//    }
