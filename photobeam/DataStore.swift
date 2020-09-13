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
import PromiseKit
import WidgetKit


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
    
    // If we are currently uploading something
    @Published var isUploading = false;
    
    // The image last sent
    @Published var sentImage: UIImage?
    @Published var receivedImage: UIImage?
    
    let toBeSentFileUrl = getDocumentsDirectory().appendingPathComponent("toBeSent.jpg")
    let sentFileUrl = getDocumentsDirectory().appendingPathComponent("sent.jpg")
    let receivedUrl = getDocumentsDirectory().appendingPathComponent("output.jpg")
    
    var timer: Timer?
    
    private var subscribers = Set<AnyCancellable>()
    init() {
        // NSUbiquitousKeyValueStore
        let currentState = UserDefaults.standard.data(forKey: "state")
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
                UserDefaults.standard.set(encoded, forKey: "state")
                //NSUserDefaults.default.synchronize()
                
                let currentState = UserDefaults.standard.data(forKey: "state")
                print(currentState)
            }
            catch {
            }
        }.store(in: &subscribers)
        
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.loop), userInfo: nil, repeats: true)
        self.reloadImages()
    }
    
    @objc func loop() {
        self.refreshState();
    }
    
    private func reloadImages() {
        if (FileManager.default.fileExists(atPath: toBeSentFileUrl.path)) {
            self.sentImage = UIImage(contentsOfFile: toBeSentFileUrl.path);
        } else if FileManager.default.fileExists(atPath: sentFileUrl.path) {
            self.sentImage = UIImage(contentsOfFile: sentFileUrl.path);
        }
                
        if (FileManager.default.fileExists(atPath: receivedUrl.path)) {
            self.receivedImage = UIImage(contentsOfFile: receivedUrl.path);
        }
        
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
    
    // Request a connection to a peer using a code. This returns a promise. If the code is invalid,
    // this promise will throw with a 400 error. TODO: Rewrite this to return a bool, and recover from the 400.
    public func connect(code: String) -> Promise<Void> {
        firstly {
            provider.requestPromise(.connect(code: code))
        }.done { moyaResponse in
            do {
                self.state.connection = try moyaResponse.map(ConnectionState.self)
            } catch {
                print(error)
            }
        }
    }
    
    /**
     * Upload an image.
     */
    public func setImage(image: UIImage) -> Promise<Void>  {
        // Save it as "to be sent".
        let data = image.jpegData(compressionQuality: 0.9)!;
        do {
            try data.write(to: toBeSentFileUrl)
            reloadImages()
        }
        catch {
            print("Failed to save file")
            return Promise.value(())
        }
        
        self.isUploading = true;
        return firstly {
            provider.requestPromise(.set(data: data))
        }.done { moyaResponse in
            do {
                self.state.account = try moyaResponse.map(AccountResponse.self)
            } catch {
                print(error)
            }
        }.ensure {
            self.isUploading = false;
        }
    }
    
    public func disconnect() {
        firstly {
            provider.requestPromise(.disconnect)
        }.then { queryResponse -> Promise<Void> in
            self.state.connection = try queryResponse.map(ConnectionState.self)
            
            try? FileManager.default.removeItem(at: self.toBeSentFileUrl)
            try? FileManager.default.removeItem(at: self.sentFileUrl)
            try? FileManager.default.removeItem(at: self.receivedUrl)
            
            return Promise.value(());
        }.catch { err in
            print("Error", err)
        }
    }
    
    public func respondToConnectionRequest(shouldAccept: Bool) {
        guard let peerId = self.state.connection?.peerId else {
            return
        }
        
        firstly {
            provider.requestPromise(.accept(peerId: peerId, shouldAccept: shouldAccept))
        }.then { queryResponse -> Promise<Void> in
            do {
                self.state.connection = try queryResponse.map(ConnectionState.self)
            } catch {
                print(error)
            }
            
            return Promise.value(());
        }.catch { err in
            print("Error", err)
        }
    }
    
    public func refreshState() {
        firstly {
            provider.requestPromise(.query)
        }.then { queryResponse -> Promise<Void> in
            do {
                self.state.connection = try queryResponse.map(ConnectionState.self)
            } catch {
                print(error)
            }
            
            self.isInitialized = true;
            
            return self.fetchIfNecessary()
        }.catch { err in
            print("DataStore.refreshState(): failed with an error: ", err)
            // Error 401=Unauthorized? Creating a new account automatically is an issue, but we
            // might want to switch to an "unauthorized" state.
        }
    }
    
    // This will fetch a new photo if we are told there is one.
    public func fetchIfNecessary() -> Promise<Void> {
        if (self.state.connection?.shouldFetch ?? false) {
            print("ok, fetching remote payload")
            return firstly {
                provider.requestPromise(.get)
            }.then { (fetchResponse: Moya.Response) -> Guarantee<Void> in
                print("payload fetched, writing it to file.")
                do {
                    try fetchResponse.data.write(to: self.receivedUrl)
                }
                catch {
                    print("Failed to save file")
                }
                
                self.reloadImages()
                WidgetCenter.shared.reloadTimelines(ofKind: "com.photobeam.widget")
                return Guarantee.value(())
            }.then { (response: Void) -> Promise<Void> in
                print("Calling clear payload")
                return self.provider.requestPromise(.clear).map { _ in () }
            }
        }
        
        return Promise.value(())
    }
}
