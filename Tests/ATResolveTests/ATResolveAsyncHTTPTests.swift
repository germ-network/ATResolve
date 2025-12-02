//
//  ATResolveAsyncHTTPTests.swift
//  ATResolve
//
//  Created by Mark @ Germ on 12/1/25.
//

#if canImport(AsyncHTTPClient)
import ATResolve
import Foundation
import AsyncHTTPClient
import Testing

//Test API with AsyncHTTPClient
struct ATResolveAsyncHTTPTests {
	@Test
	func resolveHandle() async throws {
		let resolver = ATResolver(requester: HTTPClient.shared)
		
		let data = try await resolver.resolveHandle("massicotte.org")
		
		#expect(data?.did == "did:plc:klsh7edzj3jmxucibyjqstb3")
		#expect(data?.handle == "massicotte.org")
		#expect(data?.serviceEndpoint == "https://milkcap.us-west.host.bsky.network")
	}
}
#endif
