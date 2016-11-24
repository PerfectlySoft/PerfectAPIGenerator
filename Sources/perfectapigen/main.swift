
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

let repositoryBaseURL = "https://github.com/PerfectlySoft/"

let repoListOrdered = [

	("PerfectLib/","PerfectLib"),
	("Perfect-CURL/","PerfectCURL"),
	("Perfect-Filemaker/","FileMaker"),
	("Perfect-HTTP/","PerfectHTTP"),
	("Perfect-HTTPServer/","PerfectHTTPServer"),
	("Perfect-Logger/","Logger"),
	("Perfect-MongoDB/","MongoDB"),
	("Perfect-Mustache/","PerfectMustache"),
	("Perfect-MySQL/","MySQL"),
	("Perfect-MariaDB/","MariaDB"),
	("Perfect-Net/","PerfectNet"),
	("Perfect-Notifications/","PerfectNotifications"),
	("Perfect-PostgreSQL/","PostgreSQL"),
	("Perfect-Redis/","PerfectRedis"),
	("Perfect-RequestLogger/","RequestLogger"),
	("Perfect-SQLite/","SQLite"),
	("Perfect-Thread/","PerfectThread"),
	("Perfect-Turnstile-PostgreSQL/","Perfect-Turnstile-PostgreSQL"),
	("Perfect-Turnstile-SQLite/","Perfect-Turnstile-SQLite"),
	("Perfect-WebSockets/","PerfectWebSockets"),
	("Perfect-XML/","XML"),
	("Perfect-Zip/","Zip")

]


let workingDir = Dir.workingDir

// find a better place for this
var undocumentedElements = [[String:Any]]()


func processAPISubstructure(_ substructures: [Any]) -> [[String:Any]]? {

	if substructures.count == 0 {
		return nil
	}
//	print(substructures)

	func cleanKey(_ key: String) -> String {
		//		if key.hasPrefix("key.") {
		//			return key[key.index(key.startIndex, offsetBy: 4)..<key.endIndex]
		//		}
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
			return "func"
		case "source.lang.swift.decl.function.method.static":
			return "static func"
		case "source.lang.swift.decl.function.subscript":
			return "subscript"
		case "source.lang.swift.decl.function.constructor":
			return "func"
		case "source.lang.swift.decl.function.free":
			return "func"
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
		var wasDocumented = false
		var simpleKind = ""
		for (key, value) in substructure {
			let key = cleanKey(key)
			switch key {
			case "key.accessibility":
				guard let value = value as? String,
					value == "source.lang.swift.accessibility.public" || value == "source.lang.swift.accessibility.internal" else {
						continue top
				}
				wasInternal = value == "source.lang.swift.accessibility.internal"
			case "key.substructure":
				subSubstructure = value as? [Any]
			case "key.attributes":
				guard let attrAry = value as? [[String:Any]] else {
					continue
				}
				for attr in attrAry {
					if let keyAttribute = attr["key.attribute"] as? String, keyAttribute == "source.decl.attribute.available" {
						continue top
					}
				}

			case "key.doc.declaration":
				subDict[key] = (value as? String)?.replacingOccurrences(of: ": <<error type>>", with: "").replacingOccurrences(of: "-> <<error type>>", with: "") ?? ""
			case "key.doc.full_as_xml", "key.fully_annotated_decl", "key.annotated_decl":
				continue
			case "key.doc.parameters", "key.doc.discussion", "key.doc.result_discussion":
				// we don't handle these but it might be a good idea to do so
				continue
			case "key.kind":
				if let value = value as? String {
					simpleKind = getType(value)
					subDict["key.kind.simple"] = simpleKind
					wasEnumElement = value == "source.lang.swift.decl.enumelement"
					wasEnumCase = value == "source.lang.swift.decl.enumcase"
					subDict["key.isextension"] = (simpleKind == "extension")
				}
				fallthrough
			default:
				subDict[key] = value
			}
		}


		if let parsed_declaration = subDict["key.parsed_declaration"] {
			var decl = parsed_declaration as! String
			if decl.hasPrefix("public ") {
				decl = decl.stringByReplacing(string: "public ", withString: "")
			}
			if decl.hasPrefix("final ") {
				decl = decl.stringByReplacing(string: "final ", withString: "")
			}
			if let kind = subDict["kind"] {
				if decl.hasPrefix("\(kind) ") {
					decl = decl.stringByReplacing(string: "\(kind) ", withString: "")
				}
			}

			let prefixes = ["func ","let ","static let ","case ","static var ","var ","class ","static ", "struct ", "enum ", "protocol ", "static func "]
			for pf in prefixes {
				if decl.hasPrefix(pf) {
					decl = decl.stringByReplacing(string: pf, withString: "")
				}
			}

			if decl.hasSuffix("{}") {
				decl = decl.stringByReplacing(string: "{}", withString: "")
			}

			subDict["key.parsed_declaration"] = decl
			subDict["key.name"] = decl

		}

		guard !wasInternal || wasEnumElement else {
			continue
		}
		guard subDict.count > 0 else {
			continue
		}
		let docDeclTest = subDict["key.doc.declaration"] as? String
		if nil == docDeclTest || docDeclTest!.isEmpty {
			subDict["key.doc.declaration"] = subDict["key.parsed_declaration"]
		}
		wasDocumented = (nil != subDict["key.doc.comment"]) || simpleKind == "extension" // extension blocks arguably do not need docs
		if !wasDocumented {
			subDict["key.doc.comment"] = ""
		}
		if simpleKind == "case", let name = subDict["key.name"] {
			subDict["key.doc.declaration"] = "case \(name)"
		}

		if let subSubstructure = subSubstructure, let ss = processAPISubstructure(subSubstructure) {
			if wasEnumCase {
				retAry.append(contentsOf: ss)
				continue
			} else {
				subDict["key.substructure"] = ss
			}
		} else if simpleKind == "extension" {
			continue
		} else {
			subDict["key.substructure"] = [[String:Any]]()
		}
		retAry.append(subDict)

		if !wasDocumented {
			undocumentedElements.append(subDict)
		}
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
				var repoFileComponents = [String]()
				var foundSources = false
				for component in file.filePathComponents {
					if component == "Sources" {
						foundSources = true
					}
					if foundSources {
						repoFileComponents.append(component)
					}
				}
				let joinedFile = repoFileComponents.joined(separator: "/")
				projDict["key.repo.file"] = joinedFile
				projDict["key.repo.path"] = "blob/master/" + joinedFile
				projDict["key.substructure"] = sub
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

for (name, target) in repoListOrdered {

	print("Working in: \(name)")

	let repoDirPath = srcs + "/" + name
	let repoDir = Dir(repoDirPath)
	try repoDir.setAsWorkingDir()

	let sourcekitten = "/usr/local/bin/sourcekitten"
	let skArgs1 = ["doc", "--single-file"]
	let skArgs2 = ["--", "-c"] // YOU MUST ADD THESE FLAGS or sourcekit will not give you doc comment info for the single-file

	let git = "git"
	let gitPullArgs = ["pull"]

	do {
		_ = try runProc(cmd: git, args: gitPullArgs)
		let files = try getAllSwiftFiles(inDir: Dir(repoDirPath + "Sources"))
		var decodedApiInfo = [Any]()
		for swiftFile in files {
			let apiInfo = try runProc(cmd: sourcekitten, args: skArgs1 + [swiftFile] + skArgs2 + [swiftFile], read: true)
			//			print("\(apiInfo)")
			let thisDecodedApiInfo = try apiInfo?.jsonDecode() as? [String:Any]
			decodedApiInfo.append(thisDecodedApiInfo as Any)
		}
		let projectAPI = processAPIInfo(projectName: name, apiInfo: decodedApiInfo)
		var projectInfo = [String:Any]()

		let repoName = repositoryBaseURL + name
		projectInfo["key.repo"] = repoName
		projectInfo["key.name"] = fixProjectName(name)
		projectInfo["key.files"] = projectAPI
		projectsAry.append(projectInfo)
	} catch {
		print("GOT EXCEPTION \(error)")
	}
}


let resDict: [String:Any] = ["key.projects":projectsAry, "key.undocumented":undocumentedElements]
//let resDict: [String:Any] = ["projects":projectsAry]

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

