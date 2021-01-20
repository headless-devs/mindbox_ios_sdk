//
//  MobileApplicationInstalledRequest.swift
//  MindBox
//
//  Created by Mikhail Barilov on 18.01.2021.
//  Copyright © 2021 Mikhail Barilov. All rights reserved.
//

import Foundation

class MobileApplicationInstalledRequest: RequestModel {
    let operationPath = "/v3/operations/async"
    let operationType = "MobileApplicationInstalled"
    init(
        endpoint: String,
        deviceUUID: String,
        installationId: String?,
        apnsToken: String?
    ) {
        let headers = APIServiceConstant.defaultHeaders

        let isTokenAvailable = apnsToken?.isEmpty == false
        var body: [String: Any] = ["IsTokenAvailable": isTokenAvailable]
        if let apnsToken = apnsToken {
            body["Token"] = apnsToken
        }
        if let installationId = installationId {
            body["installationId"] = installationId
        }
        
        super.init(path: operationPath,
                   method: .post,
                   parameters: [
                    "endpointId": endpoint,
                    "operation": operationType,
                    "deviceUUID": deviceUUID
            ],
                   headers: headers,
                   body: body
        )
    }
    
}
