import AsyncDNSResolver

enum ATResolverError: Error {
	case urlInvalid
	case requestFailed
}

public struct ResolvedData: Codable, Hashable, Sendable {
	public let did: String
	public let handle: String
	public let serviceEndpoint: String?
}

public struct BlueskyProfile: Codable, Hashable, Sendable {
	public let did: String
	public let handle: String
	public let displayName: String
}

public struct PLCDirectoryResolveDidResponse: Codable, Hashable, Sendable {
	public struct Service: Codable, Hashable, Sendable {
		public let id: String
		public let type: String
		public let serviceEndpoint: String
	}
	
	public let id: String
	public let service: [Service]
	
	public var pds: Service? {
		service.first(where: { $0.type == "AtprotoPersonalDataServer" })
	}
}

public struct ATResolver<Requester: HTTPSRequester> {
	public let requester: Requester

	public init(requester: Requester) {
		self.requester = requester
	}
	
	public func didForDomain(_ name: String) async throws -> String? {
		// I don't understand exactly why, but this triggers a timeout. When I do it with `dig` it returns right away...
		if name.hasSuffix(".bsky.social") {
			return nil
		}

		return await withTaskGroup(of: Optional<String>.self) { group in
			let requester = requester
			group.addTask {
				await Self.checkWellKnown(handle: name, requester: requester)
			}
			
			group.addTask {
				await Self.checkDNS(handle: name)
			}
			
			let first = await group.next()
			if let first {
				return first
			}
			
			return await group.next() ?? nil
		}
	}
	
	static func checkWellKnown(handle: String, requester: Requester) async -> String? {
		do {
			let dataResult = try await requester.request(
				parameters: .init(
					host: handle,
					path: "/.well-known/atproto-did",
					method: .get,
					headers: ["Accept": "text/plain;charset=UTF-8"],
					queryItems: []
				)
			)
			let result = String(data: dataResult, encoding: .utf8)
			
			if let result {
				//workaround if we get erroneous 200 code but body return is e.g.
				//"404 error"
				guard result.hasPrefix("did:") else {
					return nil
				}
			}
			return result
		} catch {
			return nil
		}
	}
	
	static func checkDNS(handle: String) async -> String? {
		do {
			let resolver = try AsyncDNSResolver()
			let txtRecords = try await resolver.queryTXT(
				name: "_atproto." + handle
			)
			let didRecord = txtRecords.first { record in
				record.txt.hasPrefix("did=")
			}
			return didRecord?.txt.components(separatedBy: "=").last
		} catch {
			return nil
		}
	}
	
	
	public func didForHandle(_ handle: String) async throws -> String? {
		if let did = try await didForDomain(handle) {
			return did
		}
		
		return try await blueskyGetProfile(handle).did
	}
	
	public func blueskyGetProfile(_ actor: String) async throws -> BlueskyProfile {
		try await requester.decodeJSON(
			host: "public.api.bsky.app",
			path: "/xrpc/app.bsky.actor.getProfile",
			headers: ["Accept": "application/json"],
			queryItems: [("actor", actor)]
		)
	}
	
	public func plcDirectoryQuery(
		_ did: String
	) async throws -> PLCDirectoryResolveDidResponse {
		try await requester.decodeJSON(
			host: "plc.directory",
			path: "/\(did)",
			headers: ["Accept": "application/json"]
		)
	}
	
	public func resolveHandle(_ handle: String) async throws -> ResolvedData? {
		guard let did = try await didForHandle(handle) else {
			return nil
		}

		print("did: \(did)")
		let directoryResult = try await plcDirectoryQuery(did)
		
		return ResolvedData(did: did, handle: handle, serviceEndpoint: directoryResult.pds?.serviceEndpoint)
	}
}

extension ATResolver: Sendable where Requester: Sendable {}

#if canImport(Foundation)
import Foundation

extension ResolvedData {
	public var personalDataServerURL: URL? {
		serviceEndpoint.flatMap(URL.init(string:))
	}
}
#endif
