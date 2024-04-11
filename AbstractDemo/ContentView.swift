//
//  ContentView.swift
//  AbstractDemo
//
//  Created by Yu Ma on 2023/12/1.
//

import SwiftUI
import SwiftyJSON

struct ContentView: View {
    @State private var responseData: JSON?
    @State private var isButtonClicked: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var featureKey: String = ""
    @State private var customerId: String = ""
    @State private var clientId: String = ""
    
    @State private var showFeatureKeyHistory: Bool = false
    @State private var showCustomerIdHistory: Bool = false
    @State private var showClientIdHistory: Bool = false
    
    var body: some View {
        VStack {
            InputTextField(title: "Feature Key:", key: "historyFeatureKey", content: $featureKey, showHistory: $showFeatureKeyHistory)
            InputTextField(title: "Customer Id:", key: "historyCustomerIdKey", content: $customerId, showHistory: $showCustomerIdHistory)
            InputTextField(title: "Client Id:", key: "historyClientIdKey", content: $clientId, showHistory: $showClientIdHistory)
        }
    
        Button(action: {
            isButtonClicked = true
            saveInputContent()
            fetchData()
            featureKey = ""
            clientId = ""
            customerId = ""
        }) {
            Text("点击我，发送请求")
                .font(.headline)
                .padding(10)
        }
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
        .padding()
        
        ScrollView {
            VStack {
                if(isButtonClicked) {
                    Text("开始发送请求......")
                        .foregroundStyle(Color.green)
                        .fontWeight(.bold)
                        .padding(5)
                    
                    if let responseData = responseData {
                        if(errorMessage.isEmpty) {
                            Text("返回结果如下：")
                                .foregroundStyle(Color.blue)
                                .fontWeight(.bold)
                        } else {
                            Text(errorMessage)
                                .foregroundStyle(Color.red)
                        }
                       
                        Text(responseData.rawString() ?? "")
                            .font(.body)
                    }
                } else {
                    Text("请输入内容，然后点击按钮发送请求！！！")
                        .foregroundStyle(Color.red)
                        .fontWeight(.bold)

                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 400)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 2)
        )
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.gray, radius: 4, x: 0, y: 2)
        )
        
        
        Spacer()
    }
    
    func saveInputContent() {
        addContentToHistory(key: "historyFeatureKey", value: featureKey)
        addContentToHistory(key: "historyCustomerIdKey", value: customerId)
        addContentToHistory(key: "historyClientIdKey", value: clientId)
    }
    
    func addContentToHistory(key: String, value: String) {
        var history = UserDefaults.standard.stringArray(forKey: key) ?? []
        
        if !history.contains(value) && !value.isEmpty {
            history.append(value)
            UserDefaults.standard.set(history, forKey: key)
        }
    }
    
    func fetchData() {
        let featureKeyParam = featureKey.isEmpty ? "" : "/\(featureKey)"
        guard let url = URL(string: "http://127.0.0.1:8080/customers/featureConfigs\(featureKeyParam)") else {
            print("无效URL")
            return
        }
        
        let params:[String: Any] = [
            "customerId": customerId,
            "clientId": clientId
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: params) else {
            print("无效请求-body-Json数据")
            return
        }
       
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("请求失败，Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
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
                self.responseData = JSON(data)
                self.errorMessage = "数据按照FeatureConfigResponseModel解析失败，Error: \(error.localizedDescription) 其原始信息如下："
                print(errorMessage)
            }
            
        }.resume()
    }
}

struct InputTextField: View {
    var title: String
    var key: String
    @Binding var content: String
    @Binding var showHistory: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                TextField("请输入\(title)", text: $content, onEditingChanged: { editingChanged in
                    showHistory = editingChanged
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onTapGesture {
                    showHistory = true
                }
            }
            if showHistory {
                if let history = UserDefaults.standard.stringArray(forKey: key), !history.isEmpty {
                    List(history, id: \.self) { item in
                        Button(action: {
                            content = item
                            showHistory = false
                        }){
                            Text(item)
                        }
                    }
                    .frame(height: 100)
                }
            }
        }
    }
}

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

struct CustomerId: Codable {
    public let customerId: String
    public let clientId: String
    public let attributes: [String: String]?
}
