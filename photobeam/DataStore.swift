//
//  DataStore.swift
//  photobeam
//
//  Created by Michael on 8/5/20.
//

import Foundation
import UIKit
import Combine
import Moya


struct AccountResponse: Codable {
    let accountId: Int
    let connectCode: String
    let authKey: String
}


struct ConnectionState: Codable {
    let peerId: Int
    let status: String
    let shouldFetch: Bool
    let shouldPeerFetch: Bool
}

struct DataState: Codable {
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
    // If the state has been loaded a single time at least.
    @Published var isInitialized = false;
    
    private var subscribers = Set<AnyCancellable>()
    init() {
        let currentState = NSUbiquitousKeyValueStore.default.data(forKey: "state")
        if let data = currentState {
            do {
                let state = try JSONDecoder().decode(DataState.self, from: data)
                self.state.account = state.account;
                self.state.connection = state.connection;
            }
            catch {
            }
        } else {
            // not convertible to Data, keep default values
            print("No state in storage, starting fresh")
        } 
        
        // We need to store the subscription, or it'll be removed when this goes out of scope.
        // But we can't assign to an instance variable, because swift?
        self.$state.sink() {
            print ("state now: \($0)")
            do {
                let encoded = try JSONEncoder().encode($0)
                print("Writing state to storage")
                NSUbiquitousKeyValueStore.default.set(encoded, forKey: "state")
                NSUbiquitousKeyValueStore.default.synchronize()
                
                let currentState = NSUbiquitousKeyValueStore.default.data(forKey: "state")
                print(currentState)
            }
            catch {
            }
        }.store(in: &subscribers)
    }
    
    // We have to do it now.
    public func ensureAccount() {
        // TODO: in this case, we probably want to refresh the account, ensure it is valid!
        if (state.account != nil) {
            self.refreshState();
            self.isInitialized = true;
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
                
                self.isInitialized = true;
                
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
    
    public func setImage(image: UIImage) {
        provider.request(.set(data: image.jpegData(compressionQuality: 0.9)!)) { result in
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
                    self.state.connection = try moyaResponse.map(ConnectionState.self)
                } catch {
                    print(error)
                }
                print("---- done")
                self.isInitialized = true;
            
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
