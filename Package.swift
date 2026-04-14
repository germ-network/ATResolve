// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "ATResolve",
	platforms: [
		.macOS(.v12),
		.macCatalyst(.v13),
		.iOS(.v15),
		.tvOS(.v13),
		.watchOS(.v6),
		.visionOS(.v1),
	],
	products: [
		.library(
			name: "ATResolve",
			targets: ["ATResolve"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-async-dns-resolver.git", from: "0.4.0"),
		.package(
			url: "https://github.com/germ-network/GermConvenience.git",
			from: "0.1.1"
		),
	],
	targets: [
		.target(
			name: "ATResolve",
			dependencies: [
				.product(
					name: "AsyncDNSResolver",
					package: "swift-async-dns-resolver"
				),
				"GermConvenience",
			]
		),
		.testTarget(
			name: "ATResolveTests",
			dependencies: ["ATResolve"]
		),
	]
)
