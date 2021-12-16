//
//  NetworkRequest.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/16.
//

import Foundation

class NetworkRequest {

    var isBadConfig: Bool = false
    var urlRequest: URLRequest!

    init(isBadConfig: Bool) {
        self.isBadConfig = true
    }

    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }

    func responseDict(completion: @escaping (NetworkResult<[String: Any]>) -> Void) {
        if isBadConfig {
            completion(.failure(.badConfig))
            return
        }

        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil, let data = data {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
                    completion(.failure(.decodeError))
                    return
                }
                guard let dict = json as? [String: Any] else {
                    completion(.failure(.decodeError))
                    return
                }
                completion(.success(dict))
            } else {
                completion(.failure(.requestFail))
            }
        }
        dataTask.resume()
    }

    func responseString(completion: @escaping (NetworkResult<String>) -> Void) {
        if isBadConfig {
            completion(.failure(.badConfig))
            return
        }

        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil, let data = data {
                if let str = String(data: data, encoding: .utf8) {
                    completion(.success(str))
                } else {
                    completion(.failure(.decodeError))
                }
            } else {
                completion(.failure(.requestFail))
            }
        }
        dataTask.resume()
    }

    func responseData(completion: @escaping (NetworkResult<Data>) -> Void) {
        if isBadConfig {
            completion(.failure(.badConfig))
            return
        }

        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil, let data = data {
                completion(.success(data))
            } else {
                completion(.failure(.requestFail))
            }
        }
        dataTask.resume()
    }

    func responseModel<Model: Codable>(completion: @escaping (NetworkResult<Model>) -> Void) {
        if isBadConfig {
            completion(.failure(.badConfig))
            return
        }

        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil, let data = data {
                if let model = try? JSONDecoder().decode(Model.self, from: data) {
                    completion(.success(model))
                } else {
                    completion(.failure(.decodeError))
                }
            } else {
                completion(.failure(.requestFail))
            }
        }
        dataTask.resume()
    }

}
