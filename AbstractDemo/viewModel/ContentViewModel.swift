//
//  ContentViewModel.swift
//  AbstractDemo
//
//  Created by Yu Ma on 2024/4/11.
//

import Foundation
import SwiftyJSON

class ContentViewModel: ObservableObject {
    @Published var responseData: JSON?
    @Published var errorMessage: String = ""
    
    func fetchData(featureKey: String, customerId: String, clientId: String) {
        let featureKeyParam = featureKey.isEmpty ? "" : "/\(featureKey)"
        guard let url = URL(string: "http://127.0.0.1:8080/customers/featureConfigs\(featureKeyParam)") else {
            DispatchQueue.main.async {
                self.errorMessage = "无效URL"
            }
            print("无效URL")
            return
        }
        
        let params: [String: Any] = [
            "customerId": customerId,
            "clientId": clientId
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: params) else {
            DispatchQueue.main.async {
                self.errorMessage = "无效请求-body-Json数据"
            }
            print("无效请求-body-Json数据")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                print("请求失败，Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "未接收到数据！"
                }
                print("未接收到数据！")
                return
            }
            
            // 将数据按照FeatureConfigResponseModel来进行解析
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let responseModel = try decoder.decode(FeatureConfigResponseModel.self, from: data)
                
                DispatchQueue.main.async {
                    if let responseData = responseModel.data {
                        self.responseData = responseData
                    } else {
                        print("数据解析失败！！")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.responseData = JSON(data)
                    self.errorMessage = "数据按照FeatureConfigResponseModel解析失败，Error: \(error.localizedDescription) 其原始信息如下："
                    print(self.errorMessage)
                }
            }
        }.resume()
    }
}
