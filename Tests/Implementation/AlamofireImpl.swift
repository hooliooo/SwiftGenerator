//
//  File.swift
//  
//
//  Created by Julio Miguel Alorro on 5/2/20.
//

import Alamofire
import Foundation

public enum HttpClientConstants {

    public static let networkQueue: DispatchQueue = DispatchQueue(
        label: "Network Queue",
        qos: DispatchQoS.userInitiated
    )

    public static let session: Session = {
        let s = Session(
            configuration: URLSessionConfiguration.default,
            delegate: SessionDelegate(),
            rootQueue: HttpClientConstants.networkQueue,
            startRequestsImmediately: true,
            requestQueue: nil,
            serializationQueue: nil,
            interceptor: nil,
            serverTrustManager: nil,
            redirectHandler: nil,
            cachedResponseHandler: nil,
            eventMonitors: []
        )
        return s
    }()

}

open class HttpClient {

    /**
     Initializer
     */
    public init(session: Session, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }

    /**
     The Session instance used for networking
     */
    public final let session: Session

    /**
     The base URL string
     */
    public final let baseURL: String

}
