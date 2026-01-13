#if canImport(Foundation)
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession: ResponseProviding {
	public func data(for request: Request) async throws -> Data {
		var components = URLComponents()
		components.scheme = "https"
		components.host = request.host
		components.path = request.path
		if !request.queryItems.isEmpty {
			components.queryItems = request.queryItems.map({ pair in
				URLQueryItem(name: pair.0, value: pair.1)
			})
		}
		
		guard let url = components.url else {
			throw URLError(.badURL)
		}
		var urlRequest = URLRequest(url: url)
		urlRequest.timeoutInterval = 3
		urlRequest.httpMethod = request.method.rawValue
		for (key, value) in request.headers {
			urlRequest.addValue(value, forHTTPHeaderField: key)
		}
		urlRequest.addValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Accept")
		urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
		
		let (data, response) = try await URLSession.shared.data(for: urlRequest)

		guard let httpResponse = response as? HTTPURLResponse else {
			ATResolveLogger.log(
				"Didn't get an http response",
				component: "UrlSession as ResponseProviding"
			)
			throw ATResolverError.requestFailed
		}
		
		guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
		else {
			ATResolveLogger.log(
				"Error in httpResponse with statusCode \(httpResponse.statusCode) with data \(String(decoding: data, as: UTF8.self)), response \(response)",
				component: "ATResolver"
			)

			throw ATResolverError.requestFailed
		}
		return data
	}
}
#endif
