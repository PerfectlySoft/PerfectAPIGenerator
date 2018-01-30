import PackageDescription

let package = Package(
	name: "PerfectAPIGen",
	targets: [
		Target(name: "perfectapigen", dependencies: [])
	],
	dependencies: [
		.Package(url: "https://github.com/PerfectlySoft/Perfect.git", majorVersion: 3),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", majorVersion: 3),
		.Package(url: "https://github.com/iamjono/SwiftString.git", majorVersion: 2)
	],
	exclude: []
)
