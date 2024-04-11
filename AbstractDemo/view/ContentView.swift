//
//  ContentView.swift
//  AbstractDemo
//
//  Created by Yu Ma on 2023/12/1.
//

import SwiftUI
import SwiftyJSON

struct ContentView: View {
    @State private var isButtonClicked: Bool = false
    
    @State private var featureKey: String = ""
    @State private var customerId: String = ""
    @State private var clientId: String = ""
    
    @State private var showFeatureKeyHistory: Bool = false
    @State private var showCustomerIdHistory: Bool = false
    @State private var showClientIdHistory: Bool = false
    
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            InputTextFieldView(title: "Feature Key:", key: "historyFeatureKey", content: $featureKey, showHistory: $showFeatureKeyHistory)
            InputTextFieldView(title: "Customer Id:", key: "historyCustomerIdKey", content: $customerId, showHistory: $showCustomerIdHistory)
            InputTextFieldView(title: "Client Id:", key: "historyClientIdKey", content: $clientId, showHistory: $showClientIdHistory)
        }
        
        Button(action: {
            isButtonClicked = true
            saveInputContent()
            viewModel.fetchData(featureKey: featureKey, customerId: customerId, clientId: clientId)
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
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundStyle(Color.red)
                    } else if let responseData = viewModel.responseData {
                        Text("返回结果如下：")
                            .foregroundStyle(Color.blue)
                            .fontWeight(.bold)
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
    
}
