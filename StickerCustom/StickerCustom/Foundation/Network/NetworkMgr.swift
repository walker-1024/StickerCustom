//
//  NetworkMgr.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/16.
//

import Foundation
import Alamofire

class NetworkMgr {

    static let shared = NetworkMgr()

    private init() { }

    func request(API: WebAPI, parameters: [String: String]? = nil, headers: [String: String]? = nil) -> NetworkRequest {
        let url = API.path
        let method = API.method
        var urlRequest: URLRequest!
        if method == .get {
            if let paras = parameters {
                let paraStr = paras.compactMap({ (key, value) in
                    return "\(key)=\(value)"
                }).joined(separator: "&")
                urlRequest = URLRequest(url: URL(string: url + "?" + paraStr)!, method: method, headers: headers)
            } else {
                urlRequest = URLRequest(url: URL(string: url)!, method: method, headers: headers)
            }
        } else {
            urlRequest = URLRequest(url: URL(string: url)!, method: method, headers: headers)
            if let paraData = try? JSONEncoder().encode(parameters) {
                urlRequest.httpBody = paraData
            }
        }
        return NetworkRequest(urlRequest: urlRequest)
    }

    func request(config: WebAPIConfig, parameters: [String: String]? = nil, headers: [String: String]? = nil) -> NetworkRequest {
        guard let API = WebAPIMgr.shared.getAPI(in: config.subspec, for: config.function) else {
            return NetworkRequest(isBadConfig: true)
        }
        return request(API: API, parameters: parameters, headers: headers)
    }

    func request<Paras: Codable>(API: WebAPI, parameters: Paras? = nil, headers: [String: String]? = nil) -> NetworkRequest {
        let url = API.path
        let method = API.method
        var urlRequest: URLRequest!
        if method == .get {
            if let paras = parameters {
                let structMirror = Mirror(reflecting: paras).children
                let paraStr = structMirror.compactMap({ (key, value) in
                    guard let key = key else { return "" }
                    return "\(key)=\(value)"
                }).joined(separator: "&")
                urlRequest = URLRequest(url: URL(string: url + "?" + paraStr)!, method: method, headers: headers)
            } else {
                urlRequest = URLRequest(url: URL(string: url)!, method: method, headers: headers)
            }
        } else {
            urlRequest = URLRequest(url: URL(string: url)!, method: method, headers: headers)
            if let paraData = try? JSONEncoder().encode(parameters) {
                urlRequest.httpBody = paraData
            }
        }
        return NetworkRequest(urlRequest: urlRequest)
    }

    func request<Paras: Codable>(config: WebAPIConfig, parameters: Paras? = nil, headers: [String: String]? = nil) -> NetworkRequest {
        guard let API = WebAPIMgr.shared.getAPI(in: config.subspec, for: config.function) else {
            return NetworkRequest(isBadConfig: true)
        }
        return request(API: API, parameters: parameters, headers: headers)
    }

    // 故意把传的类型分为了 UploadData 和 UploadFile，因为文件的 fileName 不能设 nil，否则会请求失败
    func upload<Model: Codable>(API: WebAPI, parameters: [UploadData]? = nil, files: [UploadFile]? = nil, headers: [String: String]? = nil, completion: @escaping (NetworkResult<Model>) -> Void) {
        let urlRequest = URLRequest(url: URL(string: API.path)!, method: API.method, headers: headers)
        AF.upload(multipartFormData: { multiPart in
            if let params = parameters {
                for para in params {
                    multiPart.append(para.data, withName: para.key)
                }
            }
            if let files = files {
                for file in files {
                    multiPart.append(file.data, withName: file.key, fileName: file.fileName, mimeType: file.mimeType)
                }
            }
        }, with: urlRequest).responseData { response in
            switch response.result {
            case .success(let data):
                if let model = try? JSONDecoder().decode(Model.self, from: data) {
                    completion(.success(model))
                } else {
                    completion(.failure(.decodeError))
                }
            case .failure(_):
                completion(.failure(.requestFail))
            }
        }
    }

    func upload<Model: Codable>(config: WebAPIConfig, parameters: [UploadData]? = nil, files: [UploadFile]? = nil, headers: [String: String]? = nil, completion: @escaping (NetworkResult<Model>) -> Void) {
        guard let API = WebAPIMgr.shared.getAPI(in: config.subspec, for: config.function) else {
            completion(.failure(.badConfig))
            return
        }
        upload(API: API, parameters: parameters, files: files, headers: headers, completion: completion)
    }
}

extension URLRequest {
    init(url: URL, method: HTTPMethod, headers: [String: String]? = nil) {
        self.init(url: url)
        self.httpMethod = method.rawValue
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserConfigMgr.shared.getValue(of: .token) as? String {
            self.setValue(token, forHTTPHeaderField: "Authorization")
        }
        if let headers = headers {
            for (key, value) in headers {
                self.setValue(value, forHTTPHeaderField: key)
            }
        }
    }
}

struct UploadData: Codable {
    var key: String
    var data: Data
}

struct UploadFile: Codable {
    var key: String
    var data: Data
    // 注意，如果是一个文件，upload 时候文件的 fileName 不能设 nil，否则会请求失败，报错如下
    // Alamofire.AFError.ResponseSerializationFailureReason.inputDataNilOrZeroLength)
    var fileName: String
    var mimeType: String?
}
