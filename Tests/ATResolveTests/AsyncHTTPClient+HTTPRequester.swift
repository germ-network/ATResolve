//
//  File.swift
//  ATResolve
//
//  Created by Mark @ Germ on 12/1/25.
//

#if canImport(AsyncHTTPClient)
import ATResolve
import AsyncHTTPClient
//should be CoreFoundation, for Data type
import Foundation
import NIOHTTP1
import NIOFoundationCompat

extension ATResolve.HTTPMethod {
	var convert: NIOHTTP1.HTTPMethod {
		get throws {
			switch rawValue {
			case ATResolve.HTTPMethod.get.rawValue:
					.GET
			case ATResolve.HTTPMethod.post.rawValue:
					.POST
			case ATResolve.HTTPMethod.put.rawValue:
					.PUT
			case ATResolve.HTTPMethod.delete.rawValue:
					.DELETE
			default:
				throw URLError(.badURL)
			}
		}
	}
}

extension HTTPClient: HTTPSRequester {
	public func request(
		parameters: ATResolve.GenericHTTPSComponents
	) async throws -> Data {
		var components = URLComponents()
		components.scheme = "https"
		components.host = parameters.host
		components.path = parameters.path
		components.queryItems = parameters.queryItems.map({ pair in
			URLQueryItem(name: pair.0, value: pair.1)
		})
		
		guard let url = components.url else {
			throw URLError(.badURL)
		}
		
		var request = HTTPClientRequest(url: url.absoluteString)
		request.method = try parameters.method.convert
		
		let response = try await execute(request, timeout: .seconds(30))
		var body = try await response.body.collect(upTo: 1024 * 1024)
		
		guard response.status == .ok else {
			print("response:", response)
			throw URLError(.badServerResponse)
		}
		let result = body.readData(length: body.readableBytes)
		
		guard let result else {
			throw URLError(.badServerResponse)
		}
		return result
	}
}
#endif
