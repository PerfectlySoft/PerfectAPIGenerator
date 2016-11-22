import PackageDescription

let package = Package(
	name: "PerfectAPIGen",
	targets: [
		Target(name: "perfectapigen", dependencies: [])
	],
	dependencies: [
		.Package(url: "https://github.com/PerfectlySoft/PerfectLib.git", majorVersion: 2, minor: 0),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", majorVersion: 2, minor: 0),
		.Package(url: "https://github.com/iamjono/SwiftString.git", majorVersion: 1)
	],
	exclude: []
)
