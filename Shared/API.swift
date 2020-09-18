//
//  API.swift
//  photobeam
//
//  Created by Michael on 8/5/20.
//

import Foundation
import Moya
import PromiseKit

public enum PhotoBeamService {
    case register
    case connect(code: String)
    case accept(peerId: Int, shouldAccept: Bool)
    case query
    case set(data: Data)
    case get
    case clear
    case disconnect
//    case showUser(id: Int)
//    case createUser(firstName: String, lastName: String)
//    case updateUser(id: Int, firstName: String, lastName: String)
//    case showAccounts
}

// MARK: - TargetType Protocol Implementation
extension PhotoBeamService: TargetType {
    public var baseURL: URL {
        //return URL(string: "http://localhost:10000")!
        return URL(string: "https://beam.ngrok.io")!
    }
    
    public var path: String {
        switch self {
        case .register:
            return "/register"
        case .connect:
            return "/connect"
        case .accept:
            return "/accept"
        case .query:
            return "/query"
        case .set:
            return "/set"
        case .get:
            return "/get"
        case .clear:
            return "/clear"
        case .disconnect:
            return "/disconnect"
        }
    }
    public  var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    public var task: Task {
        switch self {
        case .register, .query, .get, .clear, .disconnect:
            return .requestPlain
        case .connect(let code):
            return .requestParameters(parameters: ["connectCode": code], encoding: JSONEncoding.default)
        case .accept(let peerId, let shouldAccept):
            return .requestParameters(parameters: ["peerId": peerId, "accept": shouldAccept], encoding: JSONEncoding.default)
        case .set(let data):
            let fileData = MultipartFormData(provider: .data(data), name: "file", fileName: "image.jpeg", mimeType: "image/jpeg")
            let multipartData = [fileData]
            return .uploadMultipart(multipartData)
            
//        case let .updateUser(_, firstName, lastName):  // Always sends parameters in URL, regardless of which HTTP method is used
//            return .requestParameters(parameters: ["first_name": firstName, "last_name": lastName], encoding: URLEncoding.queryString)
//        case let .createUser(firstName, lastName): // Always send parameters as JSON in request body
//            return .requestParameters(parameters: ["first_name": firstName, "last_name": lastName], encoding: JSONEncoding.default)
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .register, .connect, .query, .set, .get, .clear, .disconnect, .accept:
            return "Half measures are as bad as nothing at all.".utf8Encoded
//        case .showUser(let id):
//            return "{\"id\": \(id), \"first_name\": \"Harry\", \"last_name\": \"Potter\"}".utf8Encoded
//        case .createUser(let firstName, let lastName):
//            return "{\"id\": 100, \"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\"}".utf8Encoded
//        case .updateUser(let id, let firstName, let lastName):
//            return "{\"id\": \(id), \"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\"}".utf8Encoded
//        case .showAccounts:
//            // Provided you have a file named accounts.json in your bundle.
//            guard let url = Bundle.main.url(forResource: "accounts", withExtension: "json"),
//                let data = try? Data(contentsOf: url) else {
//                    return Data()
//            }
//            return data
        }
    }
    public var parameterEncoding: Moya.ParameterEncoding {
        return JSONEncoding.default
    }
    public var headers: [String: String]? {
        return [
            "Content-type": "application/json",
            "Authorization": ""
        ]
    }
}
//// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}

public extension MoyaProvider {
    func requestPromise(_ target: Target) -> Promise<Moya.Response> {
        return Promise<Moya.Response> { seal in
            self.request(target, completion: { (result) in
                switch result {
                case let .success(moyaResponse):
                    guard moyaResponse.statusCode == 200 else {
                        seal.reject(NSError(domain: "\(moyaResponse.statusCode)", code: moyaResponse.statusCode, userInfo: ["response_message": "Response message from server"]))
                        return;
                    }
                                                        
                    seal.fulfill(moyaResponse)
                case let .failure(error):
                    seal.reject(error)
                }
            })
        }
    }
}
