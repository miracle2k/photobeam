//
//  DataStore.swift
//  photobeam
//
//  Created by Michael on 8/5/20.
//

import Foundation
import Combine
import Moya


struct AccountResponse: Decodable {
    let accountId: Int
    let connectCode: String
    let authKey: String
}


struct ConnectionState: Decodable {
    let peerId: Int
    let status: String
    let shouldFetch: Bool
}

struct DataState: Decodable {
    var account: AccountResponse?
    var connection: ConnectionState?
}

final class DataStore: ObservableObject {
    // https://useyourloaf.com/blog/swift-lazy-property-initialization/
    lazy var endpointClosure =  { (target: PhotoBeamService) -> Endpoint in
        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": self.state.account?.authKey ?? ""])
    }
    lazy var provider = MoyaProvider<PhotoBeamService>(endpointClosure: endpointClosure);
    
    // This is the last known account state
    @Published var state = DataState(account: nil, connection: nil);

    init() {
        let currentState = NSUbiquitousKeyValueStore.default.string(forKey: "state");
        if let data = currentState as? Data {
            do {
                let state = try JSONDecoder().decode(DataState.self, from: data)
                self.state.account = state.account;
                self.state.connection = state.connection;
            }
            catch {
            }
        } else {
          // not convertible to Data, keep default values
        }
    }
    
    // We have to do it now.
    public func ensureAccount() {
        if (state.account != nil) {
            return;
        }
        
        provider.request(.register) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    self.state.account = try moyaResponse.map(AccountResponse.self)
                } catch {
                    print(error)
                }
                
                // do something with the response data or statusCode
            case let .failure(error):
                // this means there was a network failure - either the request
                // wasn't sent (connectivity), or no response was received (server
                // timed out).  If the server responds with a 4xx or 5xx error, that
                // will be sent as a ".success"-ful response.
                print("Error")
            }
        }
    }
    
    // Request a connection to a peer
    public func connect(code: String) {
        provider.request(.connect(code: code)) { result in
            switch result {
            case let .success(moyaResponse):
                let data = moyaResponse.data
                let statusCode = moyaResponse.statusCode
                
                do {
                    self.state.account = try moyaResponse.map(AccountResponse.self)
                } catch {
                    print(error)
                }
                // do something with the response data or statusCode
            case let .failure(error):
                // this means there was a network failure - either the request
                // wasn't sent (connectivity), or no response was received (server
                // timed out).  If the server responds with a 4xx or 5xx error, that
                // will be sent as a ".success"-ful response.
                print("Error, request failed")
            }
        }
   }
    
    public func refreshState() {
        provider.request(.query) { result in
            switch result {
            case let .success(moyaResponse):
                let data = moyaResponse.data
                let statusCode = moyaResponse.statusCode
                
                do {
                    self.state.account = try moyaResponse.map(AccountResponse.self)
                } catch {
                    print(error)
                }
                // do something with the response data or statusCode
            case let .failure(error):
                // this means there was a network failure - either the request
                // wasn't sent (connectivity), or no response was received (server
                // timed out).  If the server responds with a 4xx or 5xx error, that
                // will be sent as a ".success"-ful response.
                print("Error, request failed")
            }
        }
   }
}
