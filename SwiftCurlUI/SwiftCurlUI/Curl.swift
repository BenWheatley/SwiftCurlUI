//
//  Curl.swift
//  SwiftCurlUI
//
//  Created by Ben Wheatley on 02/11/2023.
//

import Foundation

struct Curl: Codable {
	let curlPath: String // I could make this a URL, but then the names get all confusion — curlURL etc. don't imply the path of the executable
	var arguments: [Curl.Argument] = []
	
	init(curlPath: String = "/usr/bin/curl") {
		self.curlPath = curlPath
	}
	
	func invoke() -> String {
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
	enum Argument: Codable {
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
		case limitRate(speed: HumanBytes)
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
		case maxFilesize(bytes: HumanBytes)
		case maxRedirs(num: UInt)
		case maxTime(fractionalSeconds: TimeInterval) // alias with '-m'
		// --metalink disabled in curl for security reasons, according to man page
		case negotiate
		case netrcFile(filename: String)
		case netrcOptional
		case netrc // alias with '-n'
		// -:, --next doesn't make sense within the GUI paradigm I'm currently creating
		case noAlpn
		case noBuffer // alias with '-N'
		case noClobber
		case noKeepalive
		case noProgressMeter
		case noSessionID
		case noProxy(noProxyList: String) // comma-separated list, or *
		case ntlmWb
		case ntlm
		case oauth2Bearer(token: String) // RFC 6750
		case outputDirectory(directory: String)
		case output(file: String) // alias with '-o'
		case parallelImmediate
		case parallelMax(num: UInt)
		case parallel // alias with '-Z'
		case pass(phrase: String) // (SSH TLS) Passphrase for the private key.
		case pathAsIs
		case pinnedPubKey(hashes: String) // either (1) path to a file, or (2) "sha256//" followed by base64-encoded sha256s separated by ";"
		case post301
		case post302
		case post303
		case preproxy(protocolHostPort: String) // [protocol://]host[:port]
		case progressBar // alias with '-#'
		case protoDefault(protocol: String)
		case protoRedirect(protocols: String)
		case proto(protocols: String) // see man page for details on the structure, too much for a mere comment
		case proxyAnyAuth
		case proxyBasic
		case proxyCANative
		case proxyCACert(file: String)
		case proxyCAPath(dir: String)
		case proxyCertType(type: String)
		case proxyCert(cert: String, password: String?) // if it has a password, concatenate with ':'
		case proxyCiphers(list: String)
		case proxyCrlfile(file: String)
		case proxyDigest
		case proxyHeader(header: String) // same rules as --header but not an alias
		case proxyHttp2
		case proxyInsecure
		case proxyKeyType(type: String)
		case proxyKey(key: String)
		case proxyNegotiate
		case proxyNTLM
		case proxyPass(phrase: String)
		case proxyPinnedPubKey(hashes: String)
		case proxyServiceName(name: String)
		case proxySSLAllowBeast
		case proxySSLAutoClientCert
		case proxyTLS13Ciphers(ciphersuiteList: String)
		case proxyTLSAuthType(type: String)
		case proxyTLSPassword(string: String)
		case proxyTLSUser(name: String)
		case proxyTLSv1
		case proxyUser(user: String, password: String) // alias with '-U', concatenate with ':'
		case proxy(protocolHostPort: String) // alias with '-x', [protocol://]host[:port]
		case proxy1_0(hostPort: String) // host[:port]
		case proxytunnel // alias with '-p'
		case pubKey(key: String)
		case quote(command: String) // alias with '-Q'
		case range(range: String) // alias with '-r', see man page for parsing rules
		case rate(maxRequestRate: String) // number of transfer starts per time unit, the user can specify s, m, h, d for obvious meanings, e.g., "5/s," more than 1000/s is counted as unrestricted
		case raw
		case referer(url: String) // alias with '-e'
		case remoteHeaderName // alias with '-J'
		case remoteNameAll
		case remoteName // alias with '-O'
		case remoteTime // alias with '-R'
		case removeOnError
		case requestTarget(path: String)
		case request(method: String) // alias with '-X', which ones you're allowed depend on your protocol, so this is best left as a String at least for the first version
		case resolve(hostPortAddr: String) // <[+]host:port:addr[,addr]...>
		case retryAllErrors
		case retryConnRefused
		case retryDelay(seconds: TimeInterval)
		case retryMaxTime(seconds: TimeInterval)
		case retry(number: UInt)
		case saslAuthorizationIdentity(identity: String)
		case saslInitialResponse
		case serviceName(name: String)
		case showError // alias with '-S'
		case silent // alias with '-s'
		case socks4(hostPort: String) // <host[:port]>
		case socks4a(hostPort: String) // <host[:port]>
		case socks5Basic
		case socks5_GSS_API_NEC
		case socks5_GSS_API_Service(name: String)
		case socks5_GSS_API
		case socks5Hostname(hostPort: String)
		case socks5(hostPort: String)
		case speedLimit(speed: UInt64) // alias with '-Y'; lower limit, bytes/second, over time window in speedTime
		case speedTime(seconds: TimeInterval) // alias with '-y', time window used by speedLimit
		case sslAllowBeast // From the man page: WARNING: this option loosens the SSL security, and by using this flag you ask for exactly that.
		case sslAutoClientCert
		case sslNoRevoke
		case sslRequired
		case sslRevokeBestEffort
		case ssl
		case sslv2 // alias with '-2'
		case sslv3 // alias with '-3'
		case stderr(file: String)
		case styledOutput
		case suppressConnectHeaders
		case tcpFastOpen
		case tcpNoDelay
		case telnetOption(option: String) // alias with '-t'; Supported options: TTYPE=<term>, XDISPLOC=<X display>, NEW_ENV=<var,val>; e.g. `curl -t TTYPE=vt100 …`
		case tftpBlockSize(value: UInt64) // block size on a TFTP server
		case tftpNoOptions
		case timeCond(time: String) // alias '-z'; this is a string representing a date, which can be "all sorts of date" formats
		case tlsMax(version: String) // valid values: [default, 1.0, 1.1, 1.2, 1.3]
		case tls13Ciphers(ciphersuiteList: String)
		case tlsauthtype(type: String) // only supported value: SRP
		case tlspassword(string: String)
		case tlsuser(name: String)
		case tlsv1_0
		case tlsv1_1
		case tlsv1_2
		case tlsv1_3
		case tlsv1 // alias with '-1'
		case trEncoding // request compressed Transfer-Encoding response
		case traceAscii(file: String)
		case traceConfig(string: String)
		case traceIDs
		case traceTime
		case trace(file: String)
		case unixSocket(path: String)
		case uploadFile(file: String) // alias with '-T'
		case urlQuery(data: String)
		case url(url: URL) // to fetch
		case useAscii // alias with '-B'
		case userAgent(name: String) // alias with '-A'
		case user(userPassword: String) // alias with '-u'
		case variable(nameText: String) // <[%]name=text/@file>
		case verbose // alias with '-v'
		case version // alias with '-V'
		case writeOut(format: String) // alias with '-w', format string is a decent-sized part of the man page all by itself
		case xattr
		
		func derivedArguments() -> [String] {
			[]
		}
	}
}

extension Curl {
	enum DelegationLevel: String, Codable {
		case none, policy, always
	}
}

extension Curl {
	enum FTPMethod: String, Codable {
		case multicwd, nocwd, singlecwd
	}
}

extension Curl {
	enum SSLClearCommandChannelMode: String, Codable {
		case active, passive
	}
}

extension Curl {
	enum KeyType: String, Codable {
		case DER, PEM, ENG
	}
}

extension Curl {
	enum KerberosLevel: String, Codable {
		case clear, safe, confidential, `private`
	}
}

extension Curl {
	struct HumanBytes: Codable {
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
		
		enum Base: String, Codable {
			case k, M, G, T, P
		}
	}
}
