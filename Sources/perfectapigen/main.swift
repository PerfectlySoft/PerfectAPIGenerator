
import Darwin
import PerfectLib
import PerfectMustache
import Foundation

var sourcesRoot: String? = nil
var templateFile: String? = nil
var destinationFile: String? = nil

var args = CommandLine.arguments.makeIterator()
var currArg = args.next()

func usage() {
	print("Usage: \(CommandLine.arguments.first!) [--root sources_root] [--template mustache_template] [--dest destination_file]")
	exit(0)
}

func argFirst() -> String {
	currArg = args.next()
	guard let frst = currArg else {
		print("Argument requires value.")
		exit(-1)
	}
	return frst
}

let validArgs = [
	"--root": {
		sourcesRoot = argFirst()
	},
	"--dest": {
		destinationFile = argFirst()
	},
	"--template": {
		templateFile = argFirst()
	},
	"--help": {
		usage()
	}]

while let arg = currArg {
	if let closure = validArgs[arg.lowercased()] {
		closure()
	}
	currArg = args.next()
}

guard let srcs = sourcesRoot else {
	usage()
	exit(0)
}

struct ProcError: Error {
	let code: Int
	let msg: String?
}

func runProc(cmd: String, args: [String], read: Bool = false) throws -> String? {

	let envs = [("PATH", "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local:/usr/local/Cellar:~/.swiftenv/"),
	            ("HOME", ProcessInfo.processInfo.environment["HOME"]!),
	            ("LANG", "en_CA.UTF-8")]

	let proc = try SysProcess(cmd, args: args, env: envs)
	var ret: String?
	if read {
		var ary = [UInt8]()
		while true {
			do {
				guard let s = try proc.stdout?.readSomeBytes(count: 1024) , s.count > 0 else {
					break
				}
				ary.append(contentsOf: s)
			} catch PerfectLib.PerfectError.fileError(let code, _) {
				if code != EINTR {
					break
				}
			}
		}
		ret = UTF8Encoding.encode(bytes: ary)
	}
	let res = try proc.wait(hang: true)
	if res != 0 {
		let s = try proc.stderr?.readString()
		throw ProcError(code: Int(res), msg: s)
	}
	return ret
}

//	"Perfect-FastCGI/":"PerfectFastCGI",
let repoList = [
	"Perfect-CURL/":"PerfectCURL",
	"Perfect-HTTP/":"PerfectHTTP",
	"Perfect-HTTPServer/":"PerfectHTTPServer",
	"Perfect-MongoDB/":"MongoDB",
	"Perfect-Mustache/":"PerfectMustache",
	"Perfect-MySQL/":"MySQL",
	"Perfect-Net/":"PerfectNet",
	"Perfect-Notifications/":"PerfectNotifications",
	"Perfect-PostgreSQL/":"PostgreSQL",
	"Perfect-Redis/":"PerfectRedis",
	"Perfect-SQLite/":"SQLite",
	"Perfect-Thread/":"PerfectThread",
	"Perfect-WebSockets/":"PerfectWebSockets",
	"PerfectLib/":"PerfectLib"
]

//	"Perfect-FastCGI/",
let repoListOrdered = [
	"PerfectLib/",
	"Perfect-CURL/",
	"Perfect-HTTP/",
	"Perfect-HTTPServer/",
	"Perfect-MongoDB/",
	"Perfect-Mustache/",
	"Perfect-MySQL/",
	"Perfect-Net/",
	"Perfect-Notifications/",
	"Perfect-PostgreSQL/",
	"Perfect-Redis/",
	"Perfect-SQLite/",
	"Perfect-Thread/",
	"Perfect-WebSockets/"
]


/*

let repoList = [
"PerfectLib/":"PerfectLib",
"Perfect-CURL/":"PerfectCURL"

]

let repoList = [
	"Perfect-CURL/":"PerfectCURL",
	"Perfect-FastCGI/":"PerfectFastCGI",
	"Perfect-HTTP/":"PerfectHTTP",
	"Perfect-HTTPServer/":"PerfectHTTPServer",
	"Perfect-MongoDB/":"MongoDB",
	"Perfect-Mustache/":"PerfectMustache",
	"Perfect-MySQL/":"MySQL",
	"Perfect-Net/":"PerfectNet",
	"Perfect-Notifications/":"PerfectNotifications",
	"Perfect-PostgreSQL/":"PostgreSQL",
	"Perfect-Redis/":"PerfectRedis",
	"Perfect-SQLite/":"SQLite",
	"Perfect-Thread/":"PerfectThread",
	"Perfect-WebSockets/":"PerfectWebSockets",
	"PerfectLib/":"PerfectLib"
]

*/

let workingDir = Dir.workingDir

func processAPISubstructure(_ substructures: [Any]) -> [[String:Any]]? {

	func cleanKey(_ key: String) -> String {
		if key.hasPrefix("key.") {
			return key[key.index(key.startIndex, offsetBy: 4)..<key.endIndex]
		}
		return key
	}
	
	func getType(_ value: String) -> String {
		switch value {
		case "source.lang.swift.decl.var.instance":
			return "var"
		case "source.lang.swift.decl.var.static":
			return "static var"
		case "source.lang.swift.decl.var.global":
			return "global var"
		case "source.lang.swift.decl.var.parameter":
			return "var parameter"
		case "source.lang.swift.decl.class":
			return "class"
		case "source.lang.swift.decl.struct":
			return "struct"
		case "source.lang.swift.decl.typealias":
			return "typealias"
		case "source.lang.swift.decl.protocol":
			return "protocol"
		case "source.lang.swift.decl.extension":
			return "extension"
		case "source.lang.swift.decl.function.method.instance":
			return "method"
		case "source.lang.swift.decl.function.method.static":
			return "static method"
		case "source.lang.swift.decl.function.free":
			return "function"
		case "source.lang.swift.decl.enum":
			return "enum"
		case "source.lang.swift.decl.enumcase": // filtered out
			return "enum case"
		case "source.lang.swift.decl.enumelement":
			return "case"
		default:
			fatalError("Unknown type \(value)")
		}
	}
	
	var retAry = [[String:Any]]()
	top:
	for substructure in substructures {
		guard let substructure = substructure as? [String:Any] else {
			continue
		}
		var subDict = [String:Any]()
		var wasInternal = false
		var wasEnumElement = false
		var wasEnumCase = false
		var subSubstructure: [Any]?
		
		for (key, value) in substructure {
			let key = cleanKey(key)
			switch key {
			case "accessibility":
				if let value = value as? String {
					guard value == "source.lang.swift.accessibility.public" || value == "source.lang.swift.accessibility.internal" else {
						continue top
					}
					wasInternal = value == "source.lang.swift.accessibility.internal"
				}
			case "doc.name", "name", "doc.comment",
			     "parsed_declaration", "typename":
				subDict[key] = value
			case "kind":
				if let value = value as? String {
					subDict[key] = getType(value)
					wasEnumElement = value == "source.lang.swift.decl.enumelement"
					wasEnumCase = value == "source.lang.swift.decl.enumcase"
				}
			case "substructure":
				subSubstructure = value as? [Any]
			default:
				()
			}
		}
		guard !wasInternal || wasEnumElement else {
			continue
		}
		guard subDict.count > 0 else {
			continue
		}
		if let subSubstructure = subSubstructure, let ss = processAPISubstructure(subSubstructure) {
			if wasEnumCase {
				retAry.append(contentsOf: ss)
				continue
			} else {
				subDict["substructure"] = ss
			}
		} else if let kind = subDict["kind"] as? String , kind == "extension" {
			continue
		} else {
			subDict["substructure"] = [[String:Any]]()
		}
		retAry.append(subDict)
	}
	guard retAry.count > 0 else {
		return nil
	}
	return retAry
}

func processAPIInfo(projectName: String, apiInfo: [Any]) -> [[String:Any]] {
	var projectsList = [[String:Any]]()
	for subDict in apiInfo {
		guard let subDict = subDict as? [String:Any] else {
			continue
		}
		for (file, v) in subDict {
			guard let v = v as? [String:Any] else {
				continue
			}
			guard let substructure = v["key.substructure"] as? [Any] else {
				continue
			}
			if let sub = processAPISubstructure(substructure) {
				var projDict = [String:Any]()
				projDict["file"] = file
				projDict["substructure"] = sub
				projectsList.append(projDict)
			}
		}
	}
	return projectsList
}

func fixProjectName(_ name: String) -> String {
	if name[name.index(before: name.endIndex)] == "/" {
		return name[name.startIndex..<name.index(before: name.endIndex)]
	}
	return name
}

var projectsAry = [[String:Any]]()
let srcsDir = Dir(srcs)

func getAllSwiftFiles(inDir: Dir) throws -> [String] {
	let inPath = inDir.path
	var ret = [String]()
	try inDir.forEachEntry {
		path in
		let currFullPath = "\(inPath)\(path)"
		if File(currFullPath).isDir {
			ret.append(contentsOf: try getAllSwiftFiles(inDir: Dir(currFullPath)))
		} else if path.filePathExtension == "swift" {
			ret.append(currFullPath)
		}
	}
	return ret
}

for name in repoListOrdered {
	guard let target = repoList[name] else {
		break
	}

	print("Working in: \(name)")

	let repoDirPath = srcs + "/" + name
	let repoDir = Dir(repoDirPath)
	try repoDir.setAsWorkingDir()
	
	let sourcekitten = "/usr/local/bin/sourcekitten"
	let skArgs1 = ["doc", "--single-file"]
	let skArgs2 = ["--", "-c"]
	
	let git = "git"
	let gitPullArgs = ["pull"]
	
	do {
		_ = try runProc(cmd: git, args: gitPullArgs)
		let files = try getAllSwiftFiles(inDir: Dir(repoDirPath + "Sources"))
		var decodedApiInfo = [Any]()
		for swiftFile in files {
			let apiInfo = try runProc(cmd: sourcekitten, args: skArgs1 + [swiftFile] + skArgs2 + [swiftFile], read: true)
			let thisDecodedApiInfo = try apiInfo?.jsonDecode() as? [String:Any]
			decodedApiInfo.append(thisDecodedApiInfo as Any)
		}
		let projectAPI = processAPIInfo(projectName: name, apiInfo: decodedApiInfo)
		var projectInfo = [String:Any]()
		projectInfo["name"] = fixProjectName(name)
		projectInfo["files"] = projectAPI
		projectsAry.append(projectInfo)
	} catch {
		print("GOT EXCEPTION \(error)")
	}
}

let resDict: [String:Any] = ["projects":projectsAry]

try workingDir.setAsWorkingDir()

var resultText: String?

if let template = templateFile {
	let context = MustacheEvaluationContext(templatePath: template, map: resDict)
	let collector = MustacheEvaluationOutputCollector()
	resultText = try context.formulateResponse(withCollector: collector)
} else { // write out json
	resultText = try resDict.jsonEncodedString()
}

let f: File?
if let dest = destinationFile {
	f = File(dest)
	try f?.open(.truncate)
} else {
	f = fileStdout
}
try f?.write(string: resultText!)

