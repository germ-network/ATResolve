//
//  ResponseProviding.swift
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

public struct Request: Sendable {
	public let host: String
	public let path: String
	public let method: HTTPMethod
	public let headers: [String: String]
	public let queryItems: [(String, String?)]
}

public protocol ResponseProviding {
	func data(for: Request) async throws -> Data
}

extension ResponseProviding {
	func decodeJSON<T: Decodable>(
		host: String,
		path: String,
		method: HTTPMethod = .get,
		headers: [String: String] = [:],
		queryItems: [(String, String)] = []
	) async throws -> T {
		let result = try await data(
			for: .init(
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
