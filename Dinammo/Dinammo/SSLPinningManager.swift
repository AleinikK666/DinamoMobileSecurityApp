//
//  SSLPinningManager.swift
//  Dinammo
//
//  Created by Екатерина Алейник on 5.03.26.
//

import Foundation

class SSLPinningManager: NSObject, URLSessionDelegate {
    static let shared = SSLPinningManager()
    
    private let pinnedCertificateData: Data
    private let port = 8443
    
    private var host: String {
        #if targetEnvironment(simulator)
        return "localhost"
        #else
        
        return "192.168.100.0" // Change the IP address to yours
        #endif
    }
    
    override private init() {
        guard let certPath = Bundle.main.path(forResource: "valid_cert", ofType: "der"),
              let certData = try? Data(contentsOf: URL(fileURLWithPath: certPath)) else {
            fatalError("Сертификат valid_cert.der не найден!")
        }
        
        self.pinnedCertificateData = certData
        super.init()
        
        #if !targetEnvironment(simulator)
        print("SSL Pinning хост: \(host)")
        #endif
    }
    
    func urlSession(_ session: URLSession,
                   didReceive challenge: URLAuthenticationChallenge,
                   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        print("SSL Challenge для: \(challenge.protectionSpace.host):\(challenge.protectionSpace.port)")
        
        guard challenge.protectionSpace.host == host,
              challenge.protectionSpace.port == port,
              challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            print("SSL Pinning: проверка не пройдена")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
        
        if serverCertificateData == pinnedCertificateData {
            print("SSL Pinning: сертификат совпадает")
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            print("SSL Pinning: сертификат НЕ совпадает")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .sslPinningFailed, object: nil)
            }
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

extension Notification.Name {
    static let sslPinningFailed = Notification.Name("sslPinningFailed")
}
