#if canImport(Foundation)
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession: HTTPSRequester {
	public func request(parameters: GenericHTTPSComponents) async throws -> Data {
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
		var request = URLRequest(url: url)
		request.httpMethod = parameters.method.rawValue
		for (key, value) in parameters.headers {
			request.addValue(value, forHTTPHeaderField: key)
		}
		request.addValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Accept")
		let (data, response) = try await URLSession.shared.data(for: request)

		guard
			let httpResponse = response as? HTTPURLResponse,
			httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
		else {
			print("data:", String(decoding: data, as: UTF8.self))
			print("response:", response)

			throw ATResolverError.requestFailed
		}
		return data
	}
}
#endif
