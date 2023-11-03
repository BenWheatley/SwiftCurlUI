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
		case help(category: String?) // alias with '-h'
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
		case noProxy(noProxyList: [String]) // comma-separated list, or *
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
		case proxyCertType(type: ClientCertificateType)
		case proxyCert(cert: String, password: String?) // if it has a password, concatenate with ':'
		case proxyCiphers(list: [String])
		case proxyCRLFile(file: String)
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
		case proxyTLS13Ciphers(ciphersuiteList: [String])
		case proxyTLSAuthType(type: TLSAuthenticationType)
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
		case rate(maxRequestRate: RequestRate) // number of transfer starts per time unit, the user can specify s, m, h, d for obvious meanings, e.g., "5/s," more than 1000/s is counted as unrestricted
		case raw
		case referer(url: URL) // alias with '-e'
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
		case timeCond(date: Date, olderThan: Bool) // alias '-z'; this is a string representing a date, which can be "all sorts of date" formats
		case tlsMax(version: TLSVersion) // valid values: [default, 1.0, 1.1, 1.2, 1.3]
		case tls13Ciphers(ciphersuiteList: [String])
		case tlsAuthType(type: TLSAuthenticationType) // only supported value: SRP
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
		case user(user: String, password: String) // alias with '-u'
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
			case .egdFile(let file): return ["--egd-file", file]
			case .engine(let name): return ["--engine", name]
			case .etagCompare(let filename): return ["--etag-compare", filename]
			case .expect100Timeout(let seconds): return ["--expect100-timeout", String(seconds)]
			case .failEarly: return ["--fail-early"]
			case .failWithBody: return ["--fail-with-body"]
			case .fail: return ["--fail"]
			case .falseStart: return ["--false-start"]
			case .formEscape: return ["--form-escape"]
			case .formString(let name, let value): return ["--form-string", "\(name)=\(value)"]
			case .form(let name, let content): return ["--form", "\(name)=\(content)"]
			case .ftpAccount(let data): return ["--ftp-account", data]
			case .ftpAlternativeToUser(let command): return ["--ftp-alternative-to-user", command]
			case .ftpCreateDirs: return ["--ftp-create-dirs"]
			case .ftpMethod(let method): return ["--ftp-method", method.rawValue]
			case .ftpPasv: return ["--ftp-pasv"]
			case .ftpPort(let address): return ["--ftp-port", address]
			case .ftpPret: return ["--ftp-pret"]
			case .ftpSkipPasvIp: return ["--ftp-skip-pasv-ip"]
			case .ftpSSLClearCommandChannelMode(let mode): return ["--ftp-ssl-ccc-mode", mode.rawValue]
			case .ftpSSLClearCommandChannel: return ["--ftp-ssl-ccc"]
			case .ftpSSLControl: return ["--ftp-ssl-control"]
			case .get: return ["--get"]
			case .globOff: return ["--globoff"]
			case .happyEyeballsTimeoutMs(let milliseconds): return ["--happy-eyeballs-timeout-ms", String(milliseconds)]
			case .haproxyClientIp: return ["--haproxy-clientip"]
			case .haproxyProtocol: return ["--haproxy-protocol"]
			case .head: return ["--head"]
			case .header(let header): return ["--header", header]
			case .help(let category):
				guard let category = category else { return ["--help"] }
				return ["--help", category]
			case .hostpubmd5(let md5): return ["--hostpubmd5", md5]
			case .hostpubsha256(let sha256): return ["--hostpubsha256", sha256]
			case .hsts(let fileName): return ["--hsts", fileName]
			case .http0_9: return ["--http0.9"]
			case .http1_0: return ["--http1.0"]
			case .http1_1: return ["--http1.1"]
			case .http2PriorKnowledge: return ["--http2-prior-knowledge"]
			case .http2: return ["--http2"]
			case .http3Only: return ["--http3-only"]
			case .http3: return ["--http3"]
			case .ignoreContentLength: return ["--ignore-content-length"]
			case .include: return ["--include"]
			case .insecure: return ["--insecure"]
			case .interface(let name): return ["--interface", name]
			case .ipfsGateway(let url): return ["--ipfs-gateway", url.absoluteString]
			case .ipv4: return ["--ipv4"]
			case .ipv6: return ["--ipv6"]
			case .json(let data): return ["--json", data]
			case .junkSessionCookies: return ["--junk-session-cookies"]
			case .keepaliveTime(let seconds): return ["--keepalive-time", String(seconds)]
			case .keyType(let type): return ["--key-type", type.rawValue]
			case .key(let key): return ["--key", key]
			case .krb(let level): return ["--krb", level.rawValue]
			case .libcurl(let file): return ["--libcurl", file]
			case .limitRate(let speed): return ["--limit-rate", speed.toString]
			case .listOnly: return ["--list-only"]
			case .localPort(let low, let high):
				guard let high = high else { return ["--local-port", "\(low)"] }
				return ["--local-port", "\(low)-\(high)"]
			case .locationTrusted: return ["--location-trusted"]
			case .location: return ["--location"]
			case .loginOptions(let options): return ["--login-options", options]
			case .mailAuth(let emailAddress): return ["--mail-auth", emailAddress]
			case .mailFrom(let emailAddress): return ["--mail-from", emailAddress]
			case .mailRcptAllowFails: return ["--mail-rcpt-allowfails"]
			case .mailRcpt(let emailAddress): return ["--mail-rcpt", emailAddress]
			case .manual: return ["--manual"]
			case .maxFilesize(let bytes): return ["--max-filesize", bytes.toString]
			case .maxRedirs(let num): return ["--max-redirs", String(num)]
			case .maxTime(let fractionalSeconds): return ["--max-time", String(fractionalSeconds)]
			case .negotiate: return ["--negotiate"]
			case .netrcFile(let filename): return ["--netrc-file", filename]
			case .netrcOptional: return ["--netrc-optional"]
			case .netrc: return ["--netrc"]
			case .noAlpn: return ["--no-alpn"]
			case .noBuffer: return ["--no-buffer"]
			case .noClobber: return ["--no-clobber"]
			case .noKeepalive: return ["--no-keepalive"]
			case .noProgressMeter: return ["--no-progress-meter"]
			case .noSessionID: return ["--no-sessionid"]
			case .noProxy(let noProxyList): return ["--noproxy", noProxyList.joined(separator: ",")]
			case .ntlmWb: return ["--ntlm-wb"]
			case .ntlm: return ["--ntlm"]
			case .oauth2Bearer(let token): return ["--oauth2-bearer", token]
			case .outputDirectory(let directory): return ["--output-dir", directory]
			case .output(let file): return ["--output", file]
			case .parallelImmediate: return ["--parallel-immediate"]
			case .parallelMax(let num): return ["--parallel-max", String(num)]
			case .parallel: return ["--parallel"]
			case .pass(let phrase): return ["--pass", phrase]
			case .pathAsIs: return ["--path-as-is"]
			case .pinnedPubKey(let hashes): return ["--pinnedpubkey", hashes] // would be something like `"sha256//" + ….joined(separator: ";")` if I use an array rather than a String for hashes
			case .post301: return ["--post301"]
			case .post302: return ["--post302"]
			case .post303: return ["--post303"]
			case .preproxy(let protocolHostPort): return ["--preproxy", protocolHostPort]
			case .progressBar: return ["--progress-bar"]
			case .protoDefault(let `protocol`): return ["--proto-default", `protocol`]
			case .protoRedirect(let protocols): return ["--proto-redir", protocols] // would be `….joined(separator: ",")` if I was using something more complex than String
			case .proto(let protocols): return ["--proto", protocols] // would be `….joined(separator: ",")` if I was using something more complex than String
			case .proxyAnyAuth: return ["--proxy-anyauth"]
			case .proxyBasic: return ["--proxy-basic"]
			case .proxyCANative: return ["--proxy-ca-native"]
			case .proxyCACert(let file): return ["--proxy-cacert", file]
			case .proxyCAPath(let dir): return ["--proxy-capath", dir]
			case .proxyCertType(let type): return ["--proxy-cert-type", type.rawValue]
			case .proxyCert(let cert, let password):
				guard let password = password else { return ["--proxy-cert", cert] }
				return ["--proxy-cert", "\(cert):\(password)"]
			case .proxyCiphers(let list): return ["--proxy-ciphers", list.joined(separator: "-")]
			case .proxyCRLFile(let file): return ["--proxy-crlfile", file]
			case .proxyDigest: return ["--proxy-digest"]
			case .proxyHeader(let header): return ["--proxy-header", header]
			case .proxyHttp2: return ["--proxy-http2"]
			case .proxyInsecure: return ["--proxy-insecure"]
			case .proxyKeyType(let type): return ["--proxy-key-type", type]
			case .proxyKey(let key): return ["--proxy-key", key]
			case .proxyNegotiate: return ["--proxy-negotiate"]
			case .proxyNTLM: return ["--proxy-ntlm"]
			case .proxyPass(let phrase): return ["--proxy-pass", phrase]
			case .proxyPinnedPubKey(let hashes): return ["--proxy-pinnedpubkey", hashes] // would be something like `"sha256//" + ….joined(separator: ";")` if I use an array rather than a String for hashes
			case .proxyServiceName(let name): return ["--proxy-service-name", name]
			case .proxySSLAllowBeast: return ["--proxy-ssl-allow-beast"]
			case .proxySSLAutoClientCert: return ["--proxy-ssl-auto-client-cert"]
			case .proxyTLS13Ciphers(let ciphersuiteList): return ["--proxy-tls13-ciphers", ciphersuiteList.joined(separator: "_")]
			case .proxyTLSAuthType(let type): return ["--proxy-tlsauthtype", type.rawValue]
			case .proxyTLSPassword(let string): return ["--proxy-tlspassword", string]
			case .proxyTLSUser(let name): return ["--proxy-tlsuser", name]
			case .proxyTLSv1: return ["--proxy-tlsv1"]
			case .proxyUser(let user, let password): return ["--proxy-user", "\(user):\(password)"]
			case .proxy(let protocolHostPort): return ["--proxy", protocolHostPort]
			case .proxy1_0(let hostPort): return ["--proxy1.0", hostPort]
			case .proxytunnel: return ["--proxytunnel"]
			case .pubKey(let key): return ["--pubkey", key]
			case .quote(let command): return ["--quote", command]
			case .range(let range): return ["--range", range]
			case .rate(let maxRequestRate): return ["--rate", maxRequestRate.toString]
			case .raw: return ["--raw"]
			case .referer(let url): return ["--referer", url.absoluteString]
			case .remoteHeaderName: return ["--remote-header-name"]
			case .remoteNameAll: return ["--remote-name-all"]
			case .remoteName: return ["--remote-name"]
			case .remoteTime: return ["--remote-time"]
			case .removeOnError: return ["--remove-on-error"]
			case .requestTarget(let path): return ["--request-target", path]
			case .request(let method): return ["--request", method]
			case .resolve(let hostPortAddr): return ["--resolve", hostPortAddr]
			case .retryAllErrors: return ["--retry-all-errors"]
			case .retryConnRefused: return ["--retry-connrefused"]
			case .retryDelay(let seconds): return ["--retry-delay", String(seconds)]
			case .retryMaxTime(let seconds): return ["--retry-max-time", String(seconds)]
			case .retry(let number): return ["--retry", String(number)]
			case .saslAuthorizationIdentity(let identity): return ["--sasl-authzid", identity]
			case .saslInitialResponse: return ["--sasl-ir"]
			case .serviceName(let name): return ["--service-name", name]
			case .showError: return ["--show-error"]
			case .silent: return ["--silent"]
			case .socks4(let hostPort): return ["--socks4", hostPort]
			case .socks4a(let hostPort): return ["--socks4a", hostPort]
			case .socks5Basic: return ["--socks5-basic"]
			case .socks5_GSS_API_NEC: return ["--socks5-gssapi-nec"]
			case .socks5_GSS_API_Service(let name): return ["--socks5-gssapi-service", name]
			case .socks5_GSS_API: return ["--socks5-gssapi"]
			case .socks5Hostname(let hostPort): return ["--socks5-hostname", hostPort]
			case .socks5(let hostPort): return ["--socks5", hostPort]
			case .speedLimit(let speed): return ["--speed-limit", String(speed)]
			case .speedTime(let seconds): return ["--speed-time", String(seconds)]
			case .sslAllowBeast: return ["--ssl-allow-beast"]
			case .sslAutoClientCert: return ["--ssl-auto-client-cert"]
			case .sslNoRevoke: return ["--ssl-no-revoke"]
			case .sslRequired: return ["--ssl-reqd"]
			case .sslRevokeBestEffort: return ["--ssl-revoke-best-effort"]
			case .ssl: return ["--ssl"]
			case .sslv2: return ["--sslv2"]
			case .sslv3: return ["--sslv3"]
			case .stderr(let file): return ["--stderr", file]
			case .styledOutput: return ["--styled-output"]
			case .suppressConnectHeaders: return ["--suppress-connect-headers"]
			case .tcpFastOpen: return ["--tcp-fastopen"]
			case .tcpNoDelay: return ["--tcp-nodelay"]
			case .telnetOption(let option): return ["--telnet-option", option]
			case .tftpBlockSize(let value): return ["--tftp-blksize", String(value)]
			case .tftpNoOptions: return ["--tftp-no-options"]
			case .timeCond(let date, let olderThan): return ["--time-cond", (olderThan ? "-" : "") + ISO8601DateFormatter.string(from: date, timeZone: TimeZone.current)]
			case .tlsMax(let version): return ["--tls-max", version.rawValue]
			case .tls13Ciphers(let ciphersuiteList): return ["--tls13-ciphers", ciphersuiteList.joined(separator: "_")]
			case .tlsAuthType(let type): return ["--tlsauthtype", type.rawValue]
			case .tlspassword(let string): return ["--tlspassword", string]
			case .tlsuser(let name): return ["--tlsuser", name]
			case .tlsv1_0: return ["--tlsv1.0"]
			case .tlsv1_1: return ["--tlsv1.1"]
			case .tlsv1_2: return ["--tlsv1.2"]
			case .tlsv1_3: return ["--tlsv1.3"]
			case .tlsv1: return ["--tlsv1"]
			case .trEncoding: return ["--tr-encoding"]
			case .traceAscii(let file): return ["--trace-ascii", file]
			case .traceConfig(let string): return ["--trace-config", string]
			case .traceIDs: return ["--trace-ids"]
			case .traceTime: return ["--trace-time"]
			case .trace(let file): return ["--trace", file]
			case .unixSocket(let path): return ["--unix-socket", path]
			case .uploadFile(let file): return ["--upload-file", file]
			case .urlQuery(let data): return ["--url-query", data]
			case .url(let url): return ["--url", url.absoluteString]
			case .useAscii: return ["--use-ascii"]
			case .userAgent(let name): return ["--user-agent", name]
			case .user(let user, let password): return ["--user", "\(user):\(password)"]
			case .variable(let nameText): return ["--variable", nameText]
			case .verbose: return ["--verbose"]
			case .version: return ["--version"]
			case .writeOut(let format): return ["--write-out", format]
			case .xattr: return ["--xattr"]
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
	struct RequestRate: Codable {
		let value: UInt
		let unit: Unit
		
		var toString: String {
			"\(value)/\(unit.rawValue)"
		}
		
		enum Unit: String, Codable {
			case s, m, h, d
		}
	}
}

extension Curl {
	enum SSLClearCommandChannelMode: String, Codable {
		case active, passive
	}
}

extension Curl {
	enum TLSVersion: String, Codable {
		case `default`
		case _1_0 = "1.0"
		case _1_1 = "1.1"
		case _1_2 = "1.2"
		case _1_3 = "1.3"
	}
	
	enum TLSAuthenticationType: String, Codable {
		case SRP
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
