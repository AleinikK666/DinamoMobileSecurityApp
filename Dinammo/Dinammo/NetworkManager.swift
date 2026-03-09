//
//  NetworkManager.swift
//  Dinammo
//
//  Created by Екатерина Алейник on 5.03.26.
//

import Foundation
import SwiftUI
import Combine

class NetworkManager: ObservableObject {
    @Published var teamData: HockeyTeamData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sslError = false
    @Published var serverCertValid = true
    
    private var session: URLSession
    private var baseURL: String {
        #if targetEnvironment(simulator)
        // Для симулятора
        return "https://localhost:8443"
        #else
        // ДЛЯ РЕАЛЬНОГО УСТРОЙСТВА 
        return "https://192.168.100.119:8443"
        #endif
    }
    
    init() {
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config,
                                  delegate: SSLPinningManager.shared,
                                  delegateQueue: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSSLError),
                                               name: .sslPinningFailed,
                                               object: nil)
        
        #if !targetEnvironment(simulator)
        print("Реальное устройство, подключаюсь к: \(baseURL)")
        #endif
    }
    
    @objc private func handleSSLError() {
        DispatchQueue.main.async {
            self.sslError = true
            self.isLoading = false
            self.errorMessage = "Ошибка SSL Pinning: сертификат сервера изменен"
        }
    }
    
    func fetchData() {
        guard let url = URL(string: "\(baseURL)/stocks-data.json") else {
            errorMessage = "Неверный URL"
            return
        }
        
        print("Запрос к: \(url)")
        
        isLoading = true
        errorMessage = nil
        sslError = false
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("Ошибка сети: \(error)")
                    self?.errorMessage = "Ошибка: \(error.localizedDescription)"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Статус ответа: \(httpResponse.statusCode)")
                }
                
                guard let data = data else {
                    print("Нет данных")
                    self?.errorMessage = "Нет данных"
                    return
                }
                
                // Очищаем ответ от HTTP заголовков
                if let responseString = String(data: data, encoding: .utf8) {
                    if let jsonStart = responseString.firstIndex(of: "{"),
                       let jsonEnd = responseString.lastIndex(of: "}") {
                        
                        let jsonString = String(responseString[jsonStart...jsonEnd])
                        
                        if let jsonData = jsonString.data(using: .utf8) {
                            do {
                                let decoder = JSONDecoder()
                                let teamData = try decoder.decode(HockeyTeamData.self, from: jsonData)
                                print("Успешно загружены данные: \(teamData.team)")
                                self?.teamData = teamData
                                self?.checkCertificateStatus()
                                return
                            } catch {
                                print("Ошибка парсинга: \(error)")
                                self?.errorMessage = "Ошибка парсинга данных"
                            }
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func checkCertificateStatus() {
        guard let url = URL(string: "\(baseURL)/cert-status") else { return }
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка проверки статуса: \(error)")
                    return
                }
                
                if let data = data,
                   let responseString = String(data: data, encoding: .utf8) {
                    
                    if let jsonStart = responseString.firstIndex(of: "{"),
                       let jsonEnd = responseString.lastIndex(of: "}") {
                        
                        let jsonString = String(responseString[jsonStart...jsonEnd])
                        
                        if let jsonData = jsonString.data(using: .utf8),
                           let status = try? JSONDecoder().decode(CertStatus.self, from: jsonData) {
                            self?.serverCertValid = status.valid
                            print("Статус сертификата: \(status.valid ? "VALID" : "INVALID")")
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
