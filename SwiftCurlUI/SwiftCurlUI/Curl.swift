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
		case dumpHeader(filename: String) // alias with '-D'
		case egdFile(file: String)
		case engine(name: String) // the UI for this could be a popup list, populated from calling the command `curl --engine list`
		case etagCompare(filename: String)
		case expect100Timeout(seconds: TimeInterval)
		case failEarly
		case failWithBody
		case fail // alias with '-f'
		case falseStart
		case formEscape
		case formString(name: String, value: String) // concatenate with =
		case form(name: String, content: String) // concatenate with =
		case ftpAccount(data: String)
		case ftpAlternativeToUser(command: String)
		case ftpCreateDirs
		case ftpMethod(method: FTPMethod)
		case ftpPasv
		case ftpPort(address: String) // alias with '-P'; address is one of interface (e.g. "eth0"), IP address, host name, or "-"
		case ftpPret
		case ftpSkipPasvIp
		case ftpSSLClearCommandChannelMode(mode: SSLClearCommandChannelMode)
		case ftpSSLClearCommandChannel
		case ftpSSLControl
		case get
		case globOff // alias with '-g'
		case happyEyeballsTimeoutMs(milliseconds: UInt64)
		case haproxyClientIp
		case haproxyProtocol
		case head // alias with '-I'
		case header(header: String) // alias with '-H', filenames will only be recognised as such when preceded with '@' (e.g. `@filename.txt`), read from stdin with `@-`
		case help(category: String) // alias with '-h'
		case hostpubmd5(md5: String)
		case hostpubsha256(sha256: String)
		case hsts(fileName: String)
		case http0_9
		case http1_0 // alias with '-0'
		case http1_1
		case http2PriorKnowledge
		case http2
		case http3Only // man page says: **WARNING**: this option is experimental. Do not use in production.
		case http3 // man page says: **WARNING**: this option is experimental. Do not use in production.
		case ignoreContentLength
		case include // alias with '-i'
		case insecure // alias with '-k'
		case interface(name: String)
		case ipfsGateway(url: URL)
		case ipv4 // alias with '-4'
		case ipv6 // alias with '-6'
		case json(data: String) // is a shortcut for --data [arg] --header "Content-Type: application/json" --header "Accept: application/json"; If <data> starts with '@' it is interpreted as a filename to read the data from; if <data> is a hyphen '-' it reads the data from stdin
		case junkSessionCookies // alias with '-j'
		case keepaliveTime(seconds: TimeInterval)
		case keyType(type: KeyType) // type is DER, PEM, or ENG
		case key(key: String) // man page says private key "file name" rather than "value"
		case krb(level: KerberosLevel) // Kerberos; values are clear, safe, confidential, or private
		case libcurl(file: String) // creates libcurl-using C source code to perform task (instead of or as well as?) performing task
		case limitRate(speed: LimitRate) // measured in bytes/second, unless a suffix (k, M, G, T, P) is appended, these are 1024-based
		case listOnly // alias with '-l'
		case localPort(low: UInt16, high: UInt16?) // either "low" (for a single value) or "low-high" (for a range)
		case locationTrusted
		case location // alias with '-L'
		case loginOptions(options: String)
		case mailAuth(emailAddress: String)
		case mailFrom(emailAddress: String)
		case mailRcptAllowFails
		case mailRcpt(emailAddress: String)
		case manual // alias with '-M', the manual
		case maxFilesize(bytes: Int)
		
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

extension Curl {
	enum FTPMethod: String {
		case multicwd, nocwd, singlecwd
	}
}

extension Curl {
	enum SSLClearCommandChannelMode: String {
		case active, passive
	}
}

extension Curl {
	enum KeyType: String {
		case DER, PEM, ENG
	}
}

extension Curl {
	enum KerberosLevel: String {
		case clear, safe, confidential, `private`
	}
}

extension Curl {
	struct LimitRate {
		let value: UInt
		let base: Base?
		
		var toString: String {
			switch base {
			case .none: return "\(value)"
			case .k: return "\(value/1024)"
			case .M: return "\(value/(1024 * 1024))"
			case .G: return "\(value/(1024 * 1024 * 1024))"
			case .T: return "\(value/(1024 * 1024 * 1024 * 1024))"
			case .P: return "\(value/(1024 * 1024 * 1024 * 1024 * 1024))"
			}
		}
		
		enum Base: String {
			case k, M, G, T, P
		}
	}
}
