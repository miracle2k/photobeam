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
    case setprops(apnsToken: String)
    case connect(code: String)
    case accept(peerId: Int, shouldAccept: Bool)
    case query
    case set(data: Data)
    case get
    case clear
    case disconnect
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
        case .setprops:
            return "/setprops"
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
        case .setprops(let apnsToken):
            return .requestParameters(parameters: ["apnsToken": apnsToken], encoding: JSONEncoding.default)
        case .set(let data):
            let fileData = MultipartFormData(provider: .data(data), name: "file", fileName: "image.jpeg", mimeType: "image/jpeg")
            let multipartData = [fileData]
            return .uploadMultipart(multipartData)
        }
    }
    
    public var sampleData: Data {
        return "".utf8Encoded
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
    func requestPromise(_ target: Target, allowedCodes: [Int] = []) -> Promise<Moya.Response> {
        return Promise<Moya.Response> { seal in
            self.request(target, completion: { (result) in
                switch result {
                case let .success(moyaResponse):
                    guard allowedCodes.contains(moyaResponse.statusCode) || moyaResponse.statusCode == 200 else {
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
