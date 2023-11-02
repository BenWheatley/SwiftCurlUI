//
//  Curl.swift
//  SwiftCurlUI
//
//  Created by Ben Wheatley on 02/11/2023.
//

import Foundation

enum Curl { // namespace
	static let curlPath = "/usr/bin/curl" // I could make this a URL, but then the names get all confusion — curlURL etc. don't imply the path of the executable
	
	static func invoke(arguments: [Curl.Argument]) -> String {
		let task = Process()
		task.executableURL = URL(fileURLWithPath: curlPath)
		
		// Specify the command-line arguments
		var computedArguments: [String] = []
		arguments.forEach {
			computedArguments += $0.derivedArguments()
		}
		task.arguments = computedArguments
		
		// Optionally, you can set the working directory if needed
		task.currentDirectoryPath = "/path/to/your/working/directory"
		
		let pipe = Pipe()
		task.standardOutput = pipe
		
		do {
			try task.run()
			task.waitUntilExit()
			
			let data = pipe.fileHandleForReading.readDataToEndOfFile()
			if let output = String(data: data, encoding: .utf8) {
				print("Output: \(output)")
			}
		} catch {
			print("Error: \(error.localizedDescription)")
		}
		
		return ""
	}
}

extension Curl {
	enum Argument {
		case abstractUnixSocket(path: String)
		case altSvc(fileName: String)
		case anyAuth
		case append
		case awsSigV4(providerInfo: String) // There's a more complex pattern to the provider info than I can see how to fit into this signature sensibly
		case basic
		case caNative
		case caCert(file: String)
		case caPath(directory: String)
		case certStatus
		case certType(type: String)
		case cert(certificate: String, password: String? = nil)
		case ciphers(cipherList: [String]) // when turning into an argument, concatenate with hyphens e.g. "ECDHE-ECDSA-AES256-CCM8"
		case compressedSsh
		case compressed
		case config(file: String)
		case connectTimeout(seconds: TimeInterval) // when turned into a string, decimal must be a '.' regardless of locale
		case connectTo(host1: String, port1: String, host2: String, port2: String) // when stringified, concatenate with ':', e.g. "example.com:443:example.net:8443"
		case continueAt(offset: UInt64) // offset will never be negative
		case cookieJar(filename: String) // "-" means "stdout"
		case cookie(dataOrFilename: String) // if there's a "=", it's data; otherswise it's a filename; if it's "-" this means "stdin"
		case createDirs
		case createFileMode(mode: FileMode) // Unix file mode when stringified, so a 4-digit octal number.
		case crlf
		case crlFile(file: String)
		case curves(algorithmList: [String]) // when stringified multiple algorithms can be provided by separating them with ":"
		case dataAscii(data: String) // this is just an alias for -d, --data <data>
		case dataBinary(data: String)
		case dataRaw(data: String)
		case dataUrlEncode(data: String)
		case delegation(level: DelegationLevel) // You can use an enum for level if it has predefined values
		case digest
		case disableEprt
		case disableEpsv
		case disable
		case disallowUsernameInUrl
		case dnsInterface(interface: String)
		case dnsIpv4Addr(address: String)
		case dnsIpv6Addr(address: String)
		case dnsServers(addresses: [String])
		case dohCertStatus
		case dohInsecure
		case dohUrl(url: URL)
		case dumpHeader(filename: String)
		case egdFile(file: String)
		case engine(name: String)
		case etagCompare(filename: String)
		case expect100Timeout(seconds: Double)
		case failEarly
		case failWithBody
		case fail
		case falseStart
		case formEscape
		case formString(name: String)
		case form(name: String)
		case ftpAccount(data: String)
		case ftpAlternativeToUser(command: String)
		case ftpCreateDirs
		case ftpMethod(method: String)
		case ftpPasv
		case ftpPort(address: String)
		case ftpPret
		case ftpSkipPasvIp
		case ftpSslCccMode(mode: String)
		case ftpSslCcc
		case ftpSslControl
		case get
		
		func derivedArguments() -> [String] {
			[]
		}
	}
}

extension Curl {
	enum DelegationLevel: String {
		case none, policy, always
	}
}
