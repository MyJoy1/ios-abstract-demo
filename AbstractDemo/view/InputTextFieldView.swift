//
//  InputTextFieldView.swift
//  AbstractDemo
//
//  Created by Yu Ma on 2024/4/11.
//

import Foundation
import SwiftUI


struct InputTextFieldView: View {
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
