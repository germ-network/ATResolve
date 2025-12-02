//
//  HTTPRequester.swift
//  ATResolve
//
//  Created by Mark @ Germ on 12/1/25.
//

import Foundation

///Allows the client to choose between URLSession (Foundation) or AsyncHTTPClient,
///Or another networking library of their choice

//from Dave Delong
public struct HTTPMethod: Hashable, Sendable {
	public static let get = HTTPMethod(rawValue: "GET")
	public static let post = HTTPMethod(rawValue: "POST")
	public static let put = HTTPMethod(rawValue: "PUT")
	public static let delete = HTTPMethod(rawValue: "DELETE")

	public let rawValue: String
}

public struct GenericHTTPSComponents {
	let host: String
	let path: String
	let method: HTTPMethod
	let headers: [String: String]
	let queryItems: [(String, String?)]
}

public protocol HTTPSRequester {
	func request(parameters: GenericHTTPSComponents) async throws -> Data
}

extension HTTPSRequester {
	func decodeJSON<T: Decodable>(
		host: String,
		path: String,
		method: HTTPMethod = .get,
		headers: [String: String] = [:],
		queryItems: [(String, String)] = []
	) async throws -> T {
		let result = try await request(
			parameters: .init(
				host: host,
				path: path,
				method: method,
				headers: headers,
				queryItems: queryItems
			)
		)

		return try JSONDecoder().decode(T.self, from: result)
	}

}
