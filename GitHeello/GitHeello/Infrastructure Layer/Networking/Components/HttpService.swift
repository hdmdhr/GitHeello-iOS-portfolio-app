//
//  HttpService.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation

protocol HttpServiceProtocol {
    
    /// A generic function to send HTTP request and decode the response into the specified `Decodable` model
    /// - Parameters:
    ///   - endpoint: endpoint URL
    ///   - method: HTTP method
    ///   - responseType: Specify the generic type
    ///   - customHeaders: Optionally pass in special HTTP headers for this specific request
    ///   - customJsonDecoder: Optionally use a special `JSONDecoder` to decode the returned data of this request
    /// - Throws: `NetworkError`
    /// - Returns: The generic `Decodable` model
    func request<Response: Decodable>(endpoint: UrlConvertible,
                                      method: HttpMethod,
                                      responseType: Response.Type,
                                      customHeaders: [String: String],
                                      customJsonDecoder: JSONDecoder?) async throws -> Response
}

extension HttpServiceProtocol {
    /// Shortcut to use default [:] `customHeader` and nil `customJsonDecoder`
    func request<Response: Decodable>(endpoint: UrlConvertible,
                                      method: HttpMethod,
                                      responseType: Response.Type = Response.self) async throws -> Response
    {
        try await request(endpoint: endpoint,
                          method: method,
                          responseType: responseType,
                          customHeaders: [:],
                          customJsonDecoder: nil)
    }
}

// MARK: - HttpService

let gitHubApiService: HttpServiceProtocol = HttpService(
    urlSession: .shared,
    defaultHeaders: ["Accept": "application/vnd.github+json"],
    jsonDecoder: .gitHubApi)

class HttpService: HttpServiceProtocol {
    
    init(urlSession: URLSession, defaultHeaders: [String : String], jsonDecoder: JSONDecoder) {
        self.urlSession = urlSession
        self.defaultHeaders = defaultHeaders
        self.jsonDecoder = jsonDecoder
    }
    
    private let urlSession: URLSession
    private let defaultHeaders: [String: String]
    private let jsonDecoder: JSONDecoder
    
    func request<Response: Decodable>(endpoint: UrlConvertible,
                                      method: HttpMethod,
                                      responseType: Response.Type,
                                      customHeaders: [String: String] = [:],
                                      customJsonDecoder: JSONDecoder? = nil) async throws -> Response
    {
        var url = endpoint.url
        
        // add query (optional)
        if case .get(let provider) = method, let queryItems = try? provider?.queryItems() {
            url.append(queryItems: queryItems)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.method
        
        // add headers
        defaultHeaders.forEach { (key: String, value: String) in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        for header in customHeaders {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // TODO: - add authorization when needed
        
        // add body (optional)
        if case let .mutable(_, bodyDataProvider) = method, let provider = bodyDataProvider {
            do {
                urlRequest.httpBody = try provider.bodyData()
            } catch {
                // must be some kind of client side EncodingError
                throw NetworkError.invalidRequest(innerError: error)
            }
        }
        
        var _data: Data?
        
        do {
            debugPrintRequest(urlRequest)
            
            let (data, urlResponse) = try await urlSession.data(for: urlRequest)
            _data = data
            
            debugPrintResponse(urlRequest: urlRequest, urlResponse: urlResponse, data: data)

            let response = try (customJsonDecoder ?? jsonDecoder).decode(Response.self, from: data)
            
            return response
        } catch let urlError as URLError {
            throw NetworkError.urlError(urlError)
        } catch let decodingError as DecodingError {
            // try to extract the helpful error message from the response data
            let errorEnvelope = try? jsonDecoder.decode(ErrorEnvelope.self, from: _data ?? .init())
            throw NetworkError.decodingError(innerError: decodingError, message: errorEnvelope?.message)
        } catch {
            throw NetworkError.unknown(innerError: error)
        }
        
    }
    
}


// MARK: - Helpers

struct ErrorEnvelope: Decodable {
    let message: String
}

private func debugPrintRequest(_ urlRequest: URLRequest) {
    
    #if DEBUG  // print body
    if let bodyData = urlRequest.httpBody,
       let path = urlRequest.url?.path,
       let prettyString = bodyData.prettyJsonString {
        print("Body Data: \n", path, "\n", prettyString)
    }
    #endif
    
}

private func debugPrintResponse(urlRequest: URLRequest, urlResponse: URLResponse, data: Data) {
    
    #if DEBUG  // print response
    let debugMessage = [
        urlRequest.httpMethod,
        urlRequest.url?.relativeString,
        (urlResponse as? HTTPURLResponse)?.statusCode.toString,
        data.prettyJsonString
    ]
        .compactMap { $0 }
        .joined(separator: "\n")

    print(debugMessage)
    #endif
    
}
