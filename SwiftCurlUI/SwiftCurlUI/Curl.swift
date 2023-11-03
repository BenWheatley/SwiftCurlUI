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
		case certType(type: ClientCertificateType)
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
			switch self {
			case .abstractUnixSocket(let path): return ["--abstract-unix-socket", path]
			case .altSvc(let fileName): return ["--alt-svc", fileName]
			case .anyAuth: return ["--anyauth"]
			case .append: return ["--append"]
			case .awsSigV4(providerInfo: let providerInfo): return ["--aws-sigv4", providerInfo]
			case .basic: return ["--basic"]
			case .caNative: return ["--ca-native"]
			case .caCert(let file): return ["--cacert", file]
			case .caPath(let directory): return ["--capath", directory]
			case .certStatus: return ["--cert-status"]
			case .certType(let type): return ["--cert-type", type.rawValue]
			case .cert(let certificate, let password):
				guard let password = password else { return ["--cert", certificate] }
				return ["--cert", "\(certificate):\(password)"]
			case .ciphers(let cipherList): return ["--ciphers", cipherList.joined(separator: "-")]
			case .compressedSsh: return ["--compressed-ssh"]
			case .compressed: return ["--compressed"]
			case .config(let file): return ["--config", file]
			case .connectTimeout(let seconds): return ["--connect-timeout", String(seconds)] // TODO: how does String(double) construct numbers in different locales? I need "12.34" everywhere, no variation.
			case .connectTo(let host1, let port1, let host2, let port2):
				return ["--connect-to", "\(host1):\(port1):\(host2):\(port2)"]
			case .continueAt(let offset): return ["--continue-at", String(offset)]
			case .cookieJar(let filename): return ["--cookie-jar", filename]
			case .cookie(let dataOrFilename): return ["--cookie", dataOrFilename]
			case .createDirs: return ["--create-dirs"]
			case .createFileMode(let mode): return ["--create-file-mode", mode.toString]
			case .crlf: return ["--crlf"]
			case .crlFile(let file): return ["--crlfile", file]
			case .curves(let algorithmList): return ["--curves", algorithmList.joined(separator: ":")]
			case .dataAscii(let data): return ["--data-ascii", data]
			case .dataBinary(let data): return ["--data-binary", data]
			case .dataRaw(let data): return ["--data-raw", data]
			case .dataUrlEncode(let data): return ["--data-urlencode", data]
			case .delegation(let level): return ["--delegation", level.rawValue]
			case .digest: return ["--digest"]
			case .disableEprt: return ["--disable-eprt"]
			case .disableEpsv: return ["--disable-epsv"]
			case .disable: return ["--disable"]
			case .disallowUsernameInUrl: return ["--disallow-username-in-url"]
			case .dnsInterface(let interface): return ["--dns-interface", interface]
			case .dnsIpv4Addr(let address): return ["--dns-ipv4-addr", address]
			case .dnsIpv6Addr(let address): return ["--dns-ipv6-addr", address]
			case .dnsServers(let addresses): return ["--dns-servers", addresses.joined(separator: ",")]
			case .dohCertStatus: return ["--doh-cert-status"]
			case .dohInsecure: return ["--doh-insecure"]
			case .dohUrl(let url): return ["--doh-url", url.absoluteString]
			case .dumpHeader(let filename): return ["--dump-header", filename]
			case .egdFile(file: let file):
				<#code#>
			case .engine(name: let name):
				<#code#>
			case .etagCompare(filename: let filename):
				<#code#>
			case .expect100Timeout(seconds: let seconds):
				<#code#>
			case .failEarly:
				<#code#>
			case .failWithBody:
				<#code#>
			case .fail:
				<#code#>
			case .falseStart:
				<#code#>
			case .formEscape:
				<#code#>
			case .formString(name: let name, value: let value):
				<#code#>
			case .form(name: let name, content: let content):
				<#code#>
			case .ftpAccount(data: let data):
				<#code#>
			case .ftpAlternativeToUser(command: let command):
				<#code#>
			case .ftpCreateDirs:
				<#code#>
			case .ftpMethod(method: let method):
				<#code#>
			case .ftpPasv:
				<#code#>
			case .ftpPort(address: let address):
				<#code#>
			case .ftpPret:
				<#code#>
			case .ftpSkipPasvIp:
				<#code#>
			case .ftpSSLClearCommandChannelMode(mode: let mode):
				<#code#>
			case .ftpSSLClearCommandChannel:
				<#code#>
			case .ftpSSLControl:
				<#code#>
			case .get:
				<#code#>
			case .globOff:
				<#code#>
			case .happyEyeballsTimeoutMs(milliseconds: let milliseconds):
				<#code#>
			case .haproxyClientIp:
				<#code#>
			case .haproxyProtocol:
				<#code#>
			case .head:
				<#code#>
			case .header(header: let header):
				<#code#>
			case .help(category: let category):
				<#code#>
			case .hostpubmd5(md5: let md5):
				<#code#>
			case .hostpubsha256(sha256: let sha256):
				<#code#>
			case .hsts(fileName: let fileName):
				<#code#>
			case .http0_9:
				<#code#>
			case .http1_0:
				<#code#>
			case .http1_1:
				<#code#>
			case .http2PriorKnowledge:
				<#code#>
			case .http2:
				<#code#>
			case .http3Only:
				<#code#>
			case .http3:
				<#code#>
			case .ignoreContentLength:
				<#code#>
			case .include:
				<#code#>
			case .insecure:
				<#code#>
			case .interface(name: let name):
				<#code#>
			case .ipfsGateway(url: let url):
				<#code#>
			case .ipv4:
				<#code#>
			case .ipv6:
				<#code#>
			case .json(data: let data):
				<#code#>
			case .junkSessionCookies:
				<#code#>
			case .keepaliveTime(seconds: let seconds):
				<#code#>
			case .keyType(type: let type):
				<#code#>
			case .key(key: let key):
				<#code#>
			case .krb(level: let level):
				<#code#>
			case .libcurl(file: let file):
				<#code#>
			case .limitRate(speed: let speed):
				<#code#>
			case .listOnly:
				<#code#>
			case .localPort(low: let low, high: let high):
				<#code#>
			case .locationTrusted:
				<#code#>
			case .location:
				<#code#>
			case .loginOptions(options: let options):
				<#code#>
			case .mailAuth(emailAddress: let emailAddress):
				<#code#>
			case .mailFrom(emailAddress: let emailAddress):
				<#code#>
			case .mailRcptAllowFails:
				<#code#>
			case .mailRcpt(emailAddress: let emailAddress):
				<#code#>
			case .manual:
				<#code#>
			case .maxFilesize(bytes: let bytes):
				<#code#>
			case .maxRedirs(num: let num):
				<#code#>
			case .maxTime(fractionalSeconds: let fractionalSeconds):
				<#code#>
			case .negotiate:
				<#code#>
			case .netrcFile(filename: let filename):
				<#code#>
			case .netrcOptional:
				<#code#>
			case .netrc:
				<#code#>
			case .noAlpn:
				<#code#>
			case .noBuffer:
				<#code#>
			case .noClobber:
				<#code#>
			case .noKeepalive:
				<#code#>
			case .noProgressMeter:
				<#code#>
			case .noSessionID:
				<#code#>
			case .noProxy(noProxyList: let noProxyList):
				<#code#>
			case .ntlmWb:
				<#code#>
			case .ntlm:
				<#code#>
			case .oauth2Bearer(token: let token):
				<#code#>
			case .outputDirectory(directory: let directory):
				<#code#>
			case .output(file: let file):
				<#code#>
			case .parallelImmediate:
				<#code#>
			case .parallelMax(num: let num):
				<#code#>
			case .parallel:
				<#code#>
			case .pass(phrase: let phrase):
				<#code#>
			case .pathAsIs:
				<#code#>
			case .pinnedPubKey(hashes: let hashes):
				<#code#>
			case .post301:
				<#code#>
			case .post302:
				<#code#>
			case .post303:
				<#code#>
			case .preproxy(protocolHostPort: let protocolHostPort):
				<#code#>
			case .progressBar:
				<#code#>
			case .protoDefault(protocol: let protocol):
				<#code#>
			case .protoRedirect(protocols: let protocols):
				<#code#>
			case .proto(protocols: let protocols):
				<#code#>
			case .proxyAnyAuth:
				<#code#>
			case .proxyBasic:
				<#code#>
			case .proxyCANative:
				<#code#>
			case .proxyCACert(file: let file):
				<#code#>
			case .proxyCAPath(dir: let dir):
				<#code#>
			case .proxyCertType(type: let type):
				<#code#>
			case .proxyCert(cert: let cert, password: let password):
				<#code#>
			case .proxyCiphers(list: let list):
				<#code#>
			case .proxyCrlfile(file: let file):
				<#code#>
			case .proxyDigest:
				<#code#>
			case .proxyHeader(header: let header):
				<#code#>
			case .proxyHttp2:
				<#code#>
			case .proxyInsecure:
				<#code#>
			case .proxyKeyType(type: let type):
				<#code#>
			case .proxyKey(key: let key):
				<#code#>
			case .proxyNegotiate:
				<#code#>
			case .proxyNTLM:
				<#code#>
			case .proxyPass(phrase: let phrase):
				<#code#>
			case .proxyPinnedPubKey(hashes: let hashes):
				<#code#>
			case .proxyServiceName(name: let name):
				<#code#>
			case .proxySSLAllowBeast:
				<#code#>
			case .proxySSLAutoClientCert:
				<#code#>
			case .proxyTLS13Ciphers(ciphersuiteList: let ciphersuiteList):
				<#code#>
			case .proxyTLSAuthType(type: let type):
				<#code#>
			case .proxyTLSPassword(string: let string):
				<#code#>
			case .proxyTLSUser(name: let name):
				<#code#>
			case .proxyTLSv1:
				<#code#>
			case .proxyUser(user: let user, password: let password):
				<#code#>
			case .proxy(protocolHostPort: let protocolHostPort):
				<#code#>
			case .proxy1_0(hostPort: let hostPort):
				<#code#>
			case .proxytunnel:
				<#code#>
			case .pubKey(key: let key):
				<#code#>
			case .quote(command: let command):
				<#code#>
			case .range(range: let range):
				<#code#>
			case .rate(maxRequestRate: let maxRequestRate):
				<#code#>
			case .raw:
				<#code#>
			case .referer(url: let url):
				<#code#>
			case .remoteHeaderName:
				<#code#>
			case .remoteNameAll:
				<#code#>
			case .remoteName:
				<#code#>
			case .remoteTime:
				<#code#>
			case .removeOnError:
				<#code#>
			case .requestTarget(path: let path):
				<#code#>
			case .request(method: let method):
				<#code#>
			case .resolve(hostPortAddr: let hostPortAddr):
				<#code#>
			case .retryAllErrors:
				<#code#>
			case .retryConnRefused:
				<#code#>
			case .retryDelay(seconds: let seconds):
				<#code#>
			case .retryMaxTime(seconds: let seconds):
				<#code#>
			case .retry(number: let number):
				<#code#>
			case .saslAuthorizationIdentity(identity: let identity):
				<#code#>
			case .saslInitialResponse:
				<#code#>
			case .serviceName(name: let name):
				<#code#>
			case .showError:
				<#code#>
			case .silent:
				<#code#>
			case .socks4(hostPort: let hostPort):
				<#code#>
			case .socks4a(hostPort: let hostPort):
				<#code#>
			case .socks5Basic:
				<#code#>
			case .socks5_GSS_API_NEC:
				<#code#>
			case .socks5_GSS_API_Service(name: let name):
				<#code#>
			case .socks5_GSS_API:
				<#code#>
			case .socks5Hostname(hostPort: let hostPort):
				<#code#>
			case .socks5(hostPort: let hostPort):
				<#code#>
			case .speedLimit(speed: let speed):
				<#code#>
			case .speedTime(seconds: let seconds):
				<#code#>
			case .sslAllowBeast:
				<#code#>
			case .sslAutoClientCert:
				<#code#>
			case .sslNoRevoke:
				<#code#>
			case .sslRequired:
				<#code#>
			case .sslRevokeBestEffort:
				<#code#>
			case .ssl:
				<#code#>
			case .sslv2:
				<#code#>
			case .sslv3:
				<#code#>
			case .stderr(file: let file):
				<#code#>
			case .styledOutput:
				<#code#>
			case .suppressConnectHeaders:
				<#code#>
			case .tcpFastOpen:
				<#code#>
			case .tcpNoDelay:
				<#code#>
			case .telnetOption(option: let option):
				<#code#>
			case .tftpBlockSize(value: let value):
				<#code#>
			case .tftpNoOptions:
				<#code#>
			case .timeCond(time: let time):
				<#code#>
			case .tlsMax(version: let version):
				<#code#>
			case .tls13Ciphers(ciphersuiteList: let ciphersuiteList):
				<#code#>
			case .tlsauthtype(type: let type):
				<#code#>
			case .tlspassword(string: let string):
				<#code#>
			case .tlsuser(name: let name):
				<#code#>
			case .tlsv1_0:
				<#code#>
			case .tlsv1_1:
				<#code#>
			case .tlsv1_2:
				<#code#>
			case .tlsv1_3:
				<#code#>
			case .tlsv1:
				<#code#>
			case .trEncoding:
				<#code#>
			case .traceAscii(file: let file):
				<#code#>
			case .traceConfig(string: let string):
				<#code#>
			case .traceIDs:
				<#code#>
			case .traceTime:
				<#code#>
			case .trace(file: let file):
				<#code#>
			case .unixSocket(path: let path):
				<#code#>
			case .uploadFile(file: let file):
				<#code#>
			case .urlQuery(data: let data):
				<#code#>
			case .url(url: let url):
				<#code#>
			case .useAscii:
				<#code#>
			case .userAgent(name: let name):
				<#code#>
			case .user(userPassword: let userPassword):
				<#code#>
			case .variable(nameText: let nameText):
				<#code#>
			case .verbose:
				<#code#>
			case .version:
				<#code#>
			case .writeOut(format: let format):
				<#code#>
			case .xattr:
				<#code#>
			}
		}
	}
}

extension Curl {
	enum ClientCertificateType: String, Codable {
		case PEM, DER, ENG, P12
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
