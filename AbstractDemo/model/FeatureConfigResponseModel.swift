//
//  FeatureConfigModel.swift
//  AbstractDemo
//
//  Created by Yu Ma on 2024/4/11.
//

import Foundation
import SwiftyJSON

struct FeatureConfigResponseModel: Codable {
    public let id: String
    public let featureKey: String
    public let key: String?
    public let data: JSON?
    public let saData: [String: String]?
    public let expiredAt: Date?
    public let priority: Int?
    public let updateAt: Date?
}
