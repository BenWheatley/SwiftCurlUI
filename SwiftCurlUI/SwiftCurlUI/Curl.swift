//
//  Curl.swift
//  SwiftCurlUI
//
//  Created by Ben Wheatley on 02/11/2023.
//

import Foundation

class Curl: Codable, ObservableObject {
	let curlPath: String // I could make this a URL, but then the names get all confusion — curlURL etc. don't imply the path of the executable
	
	var arguments = Arguments()
	
	var stdin: String = ""
	var stdout: String = ""
	var stderr: String = ""
	
	init(curlPath: String = "/usr/bin/curl") {
		self.curlPath = curlPath
	}
	
	func invoke() -> String {
		let task = Process()
		task.executableURL = URL(fileURLWithPath: curlPath)
		
		task.arguments = arguments.buildArguments()
		
		// Optionally, you can set the working directory if needed
		task.currentDirectoryPath = "/path/to/your/working/directory"
		
		let output = Pipe()
		let error = Pipe()
		task.standardOutput = output
		task.standardError = error
		
		do {
			try task.run()
			task.waitUntilExit()
			
			if let output = String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) {
				print("Output: \(output)")
				stdout = output
			}
			if let error = String(data: error.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) {
				print("Error: \(error)")
				stderr = error
			}
		} catch {
			print("Exception: \(error.localizedDescription)")
		}
		
		return ""
	}
}

extension Curl {
	struct Arguments: Codable {
		var abstractUnixSocket: /*path:*/ String?
		var altSvc: /*fileName:*/ String?
		var anyAuth: Bool = false
		var append: Bool = false
		var awsSigV4: /*providerInfo:*/ String? // There's a more complex pattern to the provider info than I can see how to fit into this signature sensibly
		var basic: Bool = false
		var caNative: Bool = false
		var caCert: /*file:*/ String?
		var caPath: /*directory:*/ String?
		var certStatus: Bool = false
		var certType: /*type:*/ ClientCertificateType?
		var cert: (certificate: String, password: String?)?
		var ciphers: /*cipherList:*/ [String]? // when turning into an argument, concatenate with hyphens e.g. "ECDHE-ECDSA-AES256-CCM8"
		var compressedSsh: Bool = false
		var compressed: Bool = false
		var config: /*file:*/ String?
		var connectTimeout: /*seconds:*/ TimeInterval? // when turned into a string, decimal must be a '.' regardless of locale
		var connectTo: (host1: String, port1: String, host2: String, port2: String)? // when stringified, concatenate with ':', e.g. "example.com:443:example.net:8443"
		var continueAt: /*offset:*/ UInt64? // offset will never be negative
		var cookieJar: /*filename:*/ String? // "-" means "stdout"
		var cookie: /*dataOrFilename:*/ String? // if there's a "=", it's data; otherswise it's a filename; if it's "-" this means "stdin"
		var createDirs: Bool = false
		var createFileMode: /*mode:*/ FileMode? // Unix file mode when stringified, so a 4-digit octal number.
		var crlf: Bool = false
		var crlFile: /*file:*/ String?
		var curves: /*algorithmList:*/ [String]? // when stringified multiple algorithms can be provided by separating them with ":"
		var dataAscii: /*data:*/ String? // this is just an alias for -d, --data <data>
		var dataBinary: /*data:*/ String?
		var dataRaw: /*data:*/ String?
		var dataUrlEncode: /*data:*/ String?
		var delegation: /*level:*/ DelegationLevel? // You can use an enum for level if it has predefined values
		var digest: Bool = false
		var disableEprt: Bool = false
		var disableEpsv: Bool = false
		var disable: Bool = false
		var disallowUsernameInUrl: Bool = false
		var dnsInterface: /*interface:*/ String?
		var dnsIpv4Addr: /*address:*/ String?
		var dnsIpv6Addr: /*address:*/ String?
		var dnsServers: /*addresses:*/ [String]?
		var dohCertStatus: Bool = false
		var dohInsecure: Bool = false
		var dohUrl: /*url:*/ URL?
		var dumpHeader: /*filename:*/ String? // alias with '-D'
		var egdFile: /*file:*/ String?
		var engine: /*name:*/ String? // the UI for this could be a popup list, populated from calling the command `curl --engine list`
		var etagCompare: /*filename:*/ String?
		var expect100Timeout: /*seconds:*/ TimeInterval?
		var failEarly: Bool = false
		var failWithBody: Bool = false
		var fail: Bool = false // alias with '-f'
		var falseStart: Bool = false
		var formEscape: Bool = false
		var formString: (name: String, value: String)? // concatenate with =
		var form: (name: String, content: String)? // concatenate with =
		var ftpAccount: /*data:*/ String?
		var ftpAlternativeToUser: /*command:*/ String?
		var ftpCreateDirs: Bool = false
		var ftpMethod: /*method:*/ FTPMethod?
		var ftpPasv: Bool = false
		var ftpPort: /*address:*/ String? // alias with '-P'; address is one of interface (e.g. "eth0"), IP address, host name, or "-"
		var ftpPret: Bool = false
		var ftpSkipPasvIp: Bool = false
		var ftpSSLClearCommandChannelMode: /*mode:*/ SSLClearCommandChannelMode?
		var ftpSSLClearCommandChannel: Bool = false
		var ftpSSLControl: Bool = false
		var get: Bool = false
		var globOff: Bool = false // alias with '-g'
		var happyEyeballsTimeoutMs: /*milliseconds:*/ UInt64?
		var haproxyClientIp: Bool = false
		var haproxyProtocol: Bool = false
		var head: Bool = false // alias with '-I'
		var header: /*header:*/ String? // alias with '-H', filenames will only be recognised as such when preceded with '@' (e.g. `@filename.txt`), read from stdin with `@-`
		var help: /*category:*/ String? // alias with '-h'
		var hostpubmd5: /*md5:*/ String?
		var hostpubsha256: /*sha256:*/ String?
		var hsts: /*fileName:*/ String?
		var http0_9: Bool = false
		var http1_0: Bool = false // alias with '-0'
		var http1_1: Bool = false
		var http2PriorKnowledge: Bool = false
		var http2: Bool = false
		var http3Only: Bool = false // man page says: **WARNING**: this option is experimental. Do not use in production.
		var http3: Bool = false // man page says: **WARNING**: this option is experimental. Do not use in production.
		var ignoreContentLength: Bool = false
		var include: Bool = false // alias with '-i'
		var insecure: Bool = false // alias with '-k'
		var interface: /*name:*/ String?
		var ipfsGateway: /*url:*/ URL?
		var ipv4: Bool = false // alias with '-4'
		var ipv6: Bool = false // alias with '-6'
		var json: /*data:*/ String? // is a shortcut for --data [arg] --header "Content-Type: application/json" --header "Accept: application/json"; If <data> starts with '@' it is interpreted as a filename to read the data from; if <data> is a hyphen '-' it reads the data from stdin
		var junkSessionCookies: Bool = false // alias with '-j'
		var keepaliveTime: /*seconds:*/ TimeInterval?
		var keyType: /*type:*/ KeyType? // type is DER, PEM, or ENG
		var key: /*key:*/ String? // man page says private key "file name" rather than "value"
		var krb: /*level:*/ KerberosLevel? // Kerberos; values are clear, safe, confidential, or private
		var libcurl: /*file:*/ String? // creates libcurl-using C source code to perform task (instead of or as well as?) performing task
		var limitRate: /*speed:*/ HumanBytes?
		var listOnly: Bool = false // alias with '-l'
		var localPort: (low: UInt16, high: UInt16?)? // either "low" (for a single value) or "low-high" (for a range)
		var locationTrusted: Bool = false
		var location: Bool = false // alias with '-L'
		var loginOptions: /*options:*/ String?
		var mailAuth: /*emailAddress:*/ String?
		var mailFrom: /*emailAddress:*/ String?
		var mailRcptAllowFails: Bool = false
		var mailRcpt: /*emailAddress:*/ String?
		var manual: Bool = false // alias with '-M', the manual
		var maxFilesize: /*bytes:*/ HumanBytes?
		var maxRedirs: /*num:*/ UInt?
		var maxTime: /*fractionalSeconds:*/ TimeInterval? // alias with '-m'
		// --metalink disabled in curl for security reasons, according to man page
		var negotiate: Bool = false
		var netrcFile: /*filename:*/ String?
		var netrcOptional: Bool = false
		var netrc: Bool = false // alias with '-n'
		// -:, --next doesn't make sense within the GUI paradigm I'm currently creating
		var noAlpn: Bool = false
		var noBuffer: Bool = false // alias with '-N'
		var noClobber: Bool = false
		var noKeepalive: Bool = false
		var noProgressMeter: Bool = false
		var noSessionID: Bool = false
		var noProxy: /*noProxyList:*/ [String]? // comma-separated list, or *
		var ntlmWb: Bool = false
		var ntlm: Bool = false
		var oauth2Bearer: /*token:*/ String? // RFC 6750
		var outputDirectory: /*directory:*/ String?
		var output: /*file:*/ String? // alias with '-o'
		var parallelImmediate: Bool = false
		var parallelMax: /*num:*/ UInt?
		var parallel: Bool = false // alias with '-Z'
		var pass: /*phrase:*/ String? // (SSH TLS) Passphrase for the private key.
		var pathAsIs: Bool = false
		var pinnedPubKey: /*hashes:*/ String? // either (1) path to a file, or (2) "sha256//" followed by base64-encoded sha256s separated by ";"
		var post301: Bool = false
		var post302: Bool = false
		var post303: Bool = false
		var preproxy: /*protocolHostPort:*/ String? // [protocol://]host[:port]
		var progressBar: Bool = false // alias with '-#'
		var protoDefault: /*protocol:*/ String?
		var protoRedirect: /*protocols:*/ String?
		var proto: /*protocols:*/ String? // see man page for details on the structure, too much for a mere comment
		var proxyAnyAuth: Bool = false
		var proxyBasic: Bool = false
		var proxyCANative: Bool = false
		var proxyCACert: /*file:*/ String?
		var proxyCAPath: /*dir:*/ String?
		var proxyCertType: /*type:*/ ClientCertificateType?
		var proxyCert: (cert: String, password: String?)? // if it has a password, concatenate with ':'
		var proxyCiphers: /*list:*/ [String]?
		var proxyCRLFile: /*file:*/ String?
		var proxyDigest: Bool = false
		var proxyHeader: /*header:*/ String? // same rules as --header but not an alias
		var proxyHttp2: Bool = false
		var proxyInsecure: Bool = false
		var proxyKeyType: /*type:*/ String?
		var proxyKey: /*key:*/ String?
		var proxyNegotiate: Bool = false
		var proxyNTLM: Bool = false
		var proxyPass: /*phrase:*/ String?
		var proxyPinnedPubKey: /*hashes:*/ String?
		var proxyServiceName: /*name:*/ String?
		var proxySSLAllowBeast: Bool = false
		var proxySSLAutoClientCert: Bool = false
		var proxyTLS13Ciphers: /*ciphersuiteList:*/ [String]?
		var proxyTLSAuthType: /*type:*/ TLSAuthenticationType?
		var proxyTLSPassword: /*string:*/ String?
		var proxyTLSUser: /*name:*/ String?
		var proxyTLSv1: Bool = false
		var proxyUser: (user: String, password: String)? // alias with '-U', concatenate with ':'
		var proxy: /*protocolHostPort:*/ String? // alias with '-x', [protocol://]host[:port]
		var proxy1_0: /*hostPort:*/ String? // host[:port]
		var proxytunnel: Bool = false // alias with '-p'
		var pubKey: /*key:*/ String?
		var quote: /*command:*/ String? // alias with '-Q'
		var range: /*range:*/ String? // alias with '-r', see man page for parsing rules
		var rate: /*maxRequestRate:*/ RequestRate? // number of transfer starts per time unit, the user can specify s, m, h, d for obvious meanings, e.g., "5/s," more than 1000/s is counted as unrestricted
		var raw: Bool = false
		var referer: /*url:*/ URL? // alias with '-e'
		var remoteHeaderName: Bool = false // alias with '-J'
		var remoteNameAll: Bool = false
		var remoteName: Bool = false // alias with '-O'
		var remoteTime: Bool = false // alias with '-R'
		var removeOnError: Bool = false
		var requestTarget: /*path:*/ String?
		var request: /*method:*/ String? // alias with '-X', which ones you're allowed depend on your protocol, so this is best left as a String at least for the first version
		var resolve: /*hostPortAddr:*/ String? // <[+]host:port:addr[,addr]...>
		var retryAllErrors: Bool = false
		var retryConnRefused: Bool = false
		var retryDelay: /*seconds:*/ TimeInterval?
		var retryMaxTime: /*seconds:*/ TimeInterval?
		var retry: /*number:*/ UInt?
		var saslAuthorizationIdentity: /*identity:*/ String?
		var saslInitialResponse: Bool = false
		var serviceName: /*name:*/ String?
		var showError: Bool = false // alias with '-S'
		var silent: Bool = false // alias with '-s'
		var socks4: /*hostPort:*/ String? // <host[:port]>
		var socks4a: /*hostPort:*/ String? // <host[:port]>
		var socks5Basic: Bool = false
		var socks5_GSS_API_NEC: Bool = false
		var socks5_GSS_API_Service: /*name:*/ String?
		var socks5_GSS_API: Bool = false
		var socks5Hostname: /*hostPort:*/ String?
		var socks5: /*hostPort:*/ String?
		var speedLimit: /*speed:*/ UInt64? // alias with '-Y'; lower limit, bytes/second, over time window in speedTime
		var speedTime: /*seconds:*/ TimeInterval? // alias with '-y', time window used by speedLimit
		var sslAllowBeast: Bool = false // From the man page: WARNING: this option loosens the SSL security, and by using this flag you ask for exactly that.
		var sslAutoClientCert: Bool = false
		var sslNoRevoke: Bool = false
		var sslRequired: Bool = false
		var sslRevokeBestEffort: Bool = false
		var ssl: Bool = false
		var sslv2: Bool = false // alias with '-2'
		var sslv3: Bool = false // alias with '-3'
		var stderr: /*file:*/ String?
		var styledOutput: Bool = false
		var suppressConnectHeaders: Bool = false
		var tcpFastOpen: Bool = false
		var tcpNoDelay: Bool = false
		var telnetOption: /*option:*/ String? // alias with '-t'; Supported options: TTYPE=<term>, XDISPLOC=<X display>, NEW_ENV=<var,val>; e.g. `curl -t TTYPE=vt100 …`
		var tftpBlockSize: /*value:*/ UInt64? // block size on a TFTP server
		var tftpNoOptions: Bool = false
		var timeCond: (date: Date, olderThan: Bool)? // alias '-z'; this is a string representing a date, which can be "all sorts of date" formats
		var tlsMax: /*version:*/ TLSVersion? // valid values: [default, 1.0, 1.1, 1.2, 1.3]
		var tls13Ciphers: /*ciphersuiteList:*/ [String]?
		var tlsAuthType: /*type:*/ TLSAuthenticationType? // only supported value: SRP
		var tlspassword: /*string:*/ String?
		var tlsuser: /*name:*/ String?
		var tlsv1_0: Bool = false
		var tlsv1_1: Bool = false
		var tlsv1_2: Bool = false
		var tlsv1_3: Bool = false
		var tlsv1: Bool = false // alias with '-1'
		var trEncoding: Bool = false // request compressed Transfer-Encoding response
		var traceAscii: /*file:*/ String?
		var traceConfig: /*string:*/ String?
		var traceIDs: Bool = false
		var traceTime: Bool = false
		var trace: /*file:*/ String?
		var unixSocket: /*path:*/ String?
		var uploadFile: /*file:*/ String? // alias with '-T'
		var urlQuery: /*data:*/ String?
		var url: /*url:*/ URL? // to fetch
		var useAscii: Bool = false // alias with '-B'
		var userAgent: /*name:*/ String? // alias with '-A'
		var user: (user: String, password: String)? // alias with '-u'
		var variable: /*nameText:*/ String? // <[%]name=text/@file>
		var verbose: Bool = false // alias with '-v'
		var version: Bool = false // alias with '-V'
		var writeOut: /*format:*/ String? // alias with '-w', format string is a decent-sized part of the man page all by itself
		var xattr: Bool = false
		
		func mergeNotNil(value: String?, block: (String)->()) {
			if let value = value, !value.isEmpty { block(value) }
		}
		
		func buildArguments() -> [String] {
			var result: [String] = []
			mergeNotNil(value: abstractUnixSocket) { result += ["--abstract-unix-socket", $0] }
			mergeNotNil(value: altSvc) { result += ["--alt-svc", $0] }
			if anyAuth { result += ["--anyauth"] }
			if append { result += ["--append"] }
			mergeNotNil(value: awsSigV4) { result += ["--aws-sigv4", $0] }
			if basic { result += ["--basic"] }
			if caNative { result += ["--ca-native"] }
			mergeNotNil(value: caCert) { result += ["--cacert", $0] }
			mergeNotNil(value: caPath) { result += ["--capath", $0] }
			if certStatus { result += ["--cert-status"] }
			mergeNotNil(value: certType?.rawValue) { result += ["--cert-type", $0] }
			if let cert = cert {
				guard let password = cert.password else { result += ["--cert", cert.certificate] }
				result += ["--cert", "\(cert.certificate):\(password)"]
			}
			mergeNotNil(value: ciphers?.joined(separator: "-")) { result += ["--ciphers", $0] }
			if compressedSsh { result += ["--compressed-ssh"] }
			if compressed { result += ["--compressed"] }
			mergeNotNil(value: config) { result += ["--config", $0] }
			if let seconds = connectTimeout {
				result += ["--connect-timeout", String(seconds)] // TODO: how does String(double) construct numbers in different locales? I need "12.34" everywhere, no variation.
			}
			if let info = connectTo {
				result += ["--connect-to", "\(info.host1):\(info.port1):\(info.host2):\(info.port2)"]
			}
			if let location = continueAt { result += ["--continue-at", String(location)] }
			mergeNotNil(value: cookieJar) { result += ["--cookie-jar", $0] }
			mergeNotNil(value: cookie) { result += ["--cookie", $0] }
			if createDirs { result += ["--create-dirs"] }
			mergeNotNil(value: createFileMode?.toString) { result += ["--create-file-mode", $0] }
			if crlf { result += ["--crlf"] }
			mergeNotNil(value: crlFile) { result += ["--crlfile", $0] }
			mergeNotNil(value: curves?.joined(separator: ":")) { result += ["--curves", $0] }
			mergeNotNil(value: dataAscii) { result += ["--data-ascii", $0] }
			mergeNotNil(value: dataBinary) { result += ["--data-binary", $0] }
			mergeNotNil(value: dataRaw) { result += ["--data-raw", $0] }
			mergeNotNil(value: dataUrlEncode) { result += ["--data-urlencode", $0] }
			mergeNotNil(value: delegation?.rawValue) { result += ["--delegation", $0] }
			if digest { result += ["--digest"] }
			if disableEprt { result += ["--disable-eprt"] }
			if disableEpsv { result += ["--disable-epsv"] }
			if disable { result += ["--disable"] }
			if disallowUsernameInUrl { result += ["--disallow-username-in-url"] }
			mergeNotNil(value: dnsInterface) { result += ["--dns-interface", $0] }
			mergeNotNil(value: dnsIpv4Addr) { result += ["--dns-ipv4-addr", $0] }
			mergeNotNil(value: dnsIpv6Addr) { result += ["--dns-ipv6-addr", $0] }
			mergeNotNil(value: dnsServers?.joined(separator: ",")) { result += ["--dns-servers", $0] }
			if dohCertStatus { result += ["--doh-cert-status"] }
			if dohInsecure { result += ["--doh-insecure"] }
			mergeNotNil(value: url?.absoluteString) { result += ["--doh-url", $0] }
			mergeNotNil(value: dumpHeader) { result += ["--dump-header", $0] }
			mergeNotNil(value: egdFile) { result += ["--egd-file", $0] }
			mergeNotNil(value: engine) { result += ["--engine", $0] }
			mergeNotNil(value: etagCompare) { result += ["--etag-compare", $0] }
			if let seconds = expect100Timeout {
				result += ["--expect100-timeout", String(seconds)]
			}
			if failEarly { result += ["--fail-early"] }
			if failWithBody { result += ["--fail-with-body"] }
			if fail { result += ["--fail"] }
			if falseStart { result += ["--false-start"] }
			if formEscape { result += ["--form-escape"] }
			if let (name, value) = formString {
				result += ["--form-string", "\(name)=\(value)"]
			}
			if let (name, content) = form {
				result += ["--form", "\(name)=\(content)"]
			}
			mergeNotNil(value: ftpAccount) { result += ["--ftp-account", $0] }
			mergeNotNil(value: ftpAlternativeToUser) { result += ["--ftp-alternative-to-user", $0] }
			if ftpCreateDirs { result += ["--ftp-create-dirs"] }
			mergeNotNil(value: ftpMethod?.rawValue) { result += ["--ftp-method", $0] }
			if ftpPasv { result += ["--ftp-pasv"] }
			mergeNotNil(value: ftpPort) { result += ["--ftp-port", $0] }
			if ftpPret { result += ["--ftp-pret"] }
			if ftpSkipPasvIp { result += ["--ftp-skip-pasv-ip"] }
			mergeNotNil(value: ftpSSLClearCommandChannelMode?.rawValue) { result += ["--ftp-ssl-ccc-mode", $0] }
			if ftpSSLClearCommandChannel { result += ["--ftp-ssl-ccc"] }
			if ftpSSLControl { result += ["--ftp-ssl-control"] }
			if get { result += ["--get"] }
			if globOff { result += ["--globoff"] }
			mergeNotNil(value: ftpSSLClearCommandChannelMode?.rawValue) { result += ["--ftp-ssl-ccc-mode", $0] }
			if ftpSSLClearCommandChannel { result += ["--ftp-ssl-ccc"] }
			if ftpSSLControl { result += ["--ftp-ssl-control"] }
			if get { result += ["--get"] }
			if globOff { result += ["--globoff"] }
			if let milliseconds = happyEyeballsTimeoutMs {
				result += ["--happy-eyeballs-timeout-ms", String(milliseconds)]
			}
			if haproxyClientIp { result += ["--haproxy-clientip"] }
			if haproxyProtocol { result += ["--haproxy-protocol"] }
			if head { result += ["--head"] }
			mergeNotNil(value: header) { result += ["--header", $0] }
			if let category = help { // TODO: Unusually, this can be independently nil or empty — consider impact on UI
				if category.isEmpty {
					result += ["--help"]
				} else {
					result += ["--help", category]
				}
			}
			mergeNotNil(value: hostpubmd5) { result += ["--hostpubmd5", $0] }
			mergeNotNil(value: hostpubsha256) { result += ["--hostpubsha256", $0] }
			mergeNotNil(value: hsts) { result += ["--hsts", $0] }
			if http0_9 { result += ["--http0.9"] }
			if http1_0 { result += ["--http1.0"] }
			if http1_1 { result += ["--http1.1"] }
			if http2PriorKnowledge { result += ["--http2-prior-knowledge"] }
			if http2 { result += ["--http2"] }
			if http3Only { result += ["--http3-only"] }
			if http3 { result += ["--http3"] }
			if ignoreContentLength { result += ["--ignore-content-length"] }
			if include { result += ["--include"] }
			if insecure { result += ["--insecure"] }
			mergeNotNil(value: interface) { result += ["--interface", $0] }
			mergeNotNil(value: ipfsGateway?.absoluteString) { result += ["--ipfs-gateway", $0] }
			if ipv4 { result += ["--ipv4"] }
			if ipv6 { result += ["--ipv6"] }
			mergeNotNil(value: json) { result += ["--json", $0] }
			if junkSessionCookies { result += ["--junk-session-cookies"] }
			if let seconds = keepaliveTime { result += ["--keepalive-time", String(seconds)] }
			mergeNotNil(value: keyType?.rawValue) { result += ["--key-type", $0] }
			mergeNotNil(value: key) { result += ["--key", $0] }
			mergeNotNil(value: krb?.rawValue) { result += ["--krb", $0] }
			mergeNotNil(value: libcurl) { result += ["--libcurl", $0] }
			mergeNotNil(value: limitRate?.toString) { result += ["--limit-rate", $0] }
			if listOnly { result += ["--list-only"] }
			if let (low, high) = localPort {
				guard let high = high else { result += ["--local-port", "\(low)"] }
				result += ["--local-port", "\(low)-\(high)"]
			}
			if locationTrusted { result += ["--location-trusted"] }
			if location { result += ["--location"] }
			mergeNotNil(value: loginOptions) { result += ["--login-options", $0] }
			mergeNotNil(value: mailAuth) { result += ["--mail-auth", $0] }
			mergeNotNil(value: mailFrom) { result += ["--mail-from", $0] }
			if mailRcptAllowFails { result += ["--mail-rcpt-allowfails"] }
			mergeNotNil(value: mailRcpt) { result += ["--mail-rcpt", $0] }
			if manual { result += ["--manual"] }
			mergeNotNil(value: maxFilesize?.toString) { result += ["--max-filesize", $0] }
			if let num = maxRedirs { result += ["--max-redirs", String(num)] }
			if let fractionalSeconds = maxTime { result += ["--max-time", String(fractionalSeconds)] }
			if negotiate { result += ["--negotiate"] }
			mergeNotNil(value: netrcFile) { result += ["--netrc-file", $0] }
			if netrcOptional { result += ["--netrc-optional"] }
			if netrc { result += ["--netrc"] }
			if noAlpn { result += ["--no-alpn"] }
			if noBuffer { result += ["--no-buffer"] }
			if noClobber { result += ["--no-clobber"] }
			if noKeepalive { result += ["--no-keepalive"] }
			if noProgressMeter { result += ["--no-progress-meter"] }
			if noSessionID { result += ["--no-sessionid"] }
			mergeNotNil(value: noProxy?.joined(separator: ",")) { result += ["--noproxy", $0] }
			if ntlmWb { result += ["--ntlm-wb"] }
			if ntlm { result += ["--ntlm"] }
			mergeNotNil(value: oauth2Bearer) { result += ["--oauth2-bearer", $0] }
			mergeNotNil(value: outputDirectory) { result += ["--output-dir", $0] }
			mergeNotNil(value: output) { result += ["--output", $0] }
			if parallelImmediate { result += ["--parallel-immediate"] }
			if let num = parallelMax { result += ["--parallel-max", String(num)] }
			if parallel { result += ["--parallel"] }
			mergeNotNil(value: pass) { result += ["--pass", $0] }
			if pathAsIs { result += ["--path-as-is"] }
			mergeNotNil(value: pinnedPubKey) { result += ["--pinnedpubkey", $0] }  // would be something like `"sha256//" + ….joined(separator: ";")` if I use an array rather than a String for hashes
			if post301 { result += ["--post301"] }
			if post302 { result += ["--post302"] }
			if post303 { result += ["--post303"] }
			mergeNotNil(value: preproxy) { result += ["--preproxy", $0] }
			if progressBar { result += ["--progress-bar"] }
			mergeNotNil(value: protoDefault) { result += ["--proto-default", $0] }
			mergeNotNil(value: protoRedirect) { result += ["--proto-redir", $0] }  // would be `….joined(separator: ",")` if I was using something more complex than String
			mergeNotNil(value: proto) { result += ["--proto", $0] } // would be `….joined(separator: ",")` if I was using something more complex than String
			if proxyAnyAuth { result += ["--proxy-anyauth"] }
			if proxyBasic { result += ["--proxy-basic"] }
			if proxyCANative { result += ["--proxy-ca-native"] }
			mergeNotNil(value: proxyCACert) { result += ["--proxy-cacert", $0] }
			mergeNotNil(value: proxyCAPath) { result += ["--proxy-capath", $0] }
			if let type = proxyCertType?.rawValue { result += ["--proxy-cert-type", type] }
			if let (cert, password) = proxyCert {
				guard let password = password else { result += ["--proxy-cert", cert] }
				result += ["--proxy-cert", "\(cert):\(password)"]
			}
			mergeNotNil(value: proxyCiphers?.joined(separator: "-")) { result += ["--proxy-ciphers", $0] }
			mergeNotNil(value: proxyCRLFile) { result += ["--proxy-crlfile", $0] }
			if proxyDigest { result += ["--proxy-digest"] }
			mergeNotNil(value: proxyHeader) { result += ["--proxy-header", $0] }
			if proxyHttp2 { result += ["--proxy-http2"] }
			if proxyInsecure { result += ["--proxy-insecure"] }
			mergeNotNil(value: proxyKeyType) { result += ["--proxy-key-type", $0] }
			mergeNotNil(value: proxyKey) { result += ["--proxy-key", $0] }
			if proxyNegotiate { result += ["--proxy-negotiate"] }
			if proxyNTLM { result += ["--proxy-ntlm"] }
			mergeNotNil(value: proxyPass) { result += ["--proxy-pass", $0] }
			mergeNotNil(value: proxyPinnedPubKey) { result += ["--proxy-pinnedpubkey", $0] } // would be something like `"sha256//" + ….joined(separator: ";")` if I use an array rather than a String for hashes
			mergeNotNil(value: proxyServiceName) { result += ["--proxy-service-name", $0] }
			if proxySSLAllowBeast { result += ["--proxy-ssl-allow-beast"] }
			if proxySSLAutoClientCert { result += ["--proxy-ssl-auto-client-cert"] }
			mergeNotNil(value: proxyTLS13Ciphers?.joined(separator: "_")) { result += ["--proxy-tls13-ciphers", $0] }
			mergeNotNil(value: proxyTLSAuthType?.rawValue) { result += ["--proxy-tlsauthtype", $0] }
			mergeNotNil(value: proxyTLSPassword) { result += ["--proxy-tlspassword", $0] }
			mergeNotNil(value: proxyTLSUser) { result += ["--proxy-tlsuser", $0] }
			if proxyTLSv1 { result += ["--proxy-tlsv1"] }
			if let (user, password) = proxyUser { result += ["--proxy-user", "\(user):\(password)"] }
			mergeNotNil(value: proxy) { result += ["--proxy", $0] }
			mergeNotNil(value: proxy1_0) { result += ["--proxy1.0", $0] }
			if proxytunnel { result += ["--proxytunnel"] }
			mergeNotNil(value: pubKey) { result += ["--pubkey", $0] }
			mergeNotNil(value: quote) { result += ["--quote", $0] }
			mergeNotNil(value: range) { result += ["--range", $0] }
			mergeNotNil(value: rate?.toString) { result += ["--rate", $0] }
			if raw { result += ["--raw"] }
			mergeNotNil(value: referer?.absoluteString) { result += ["--referer", $0] }
			if remoteHeaderName { result += ["--remote-header-name"] }
			if remoteNameAll { result += ["--remote-name-all"] }
			if remoteName { result += ["--remote-name"] }
			if remoteTime { result += ["--remote-time"] }
			if removeOnError { result += ["--remove-on-error"] }
			mergeNotNil(value: requestTarget) { result += ["--request-target", $0] }
			mergeNotNil(value: request) { result += ["--request", $0] }
			mergeNotNil(value: resolve) { result += ["--resolve", $0] }
			if retryAllErrors { result += ["--retry-all-errors"] }
			if retryConnRefused { result += ["--retry-connrefused"] }
			if let retryDelay = retryDelay { result += ["--retry-delay", String(retryDelay)] }
			if let retryMaxTime = retryMaxTime { result += ["--retry-max-time", String(retryMaxTime)] }
			if let retry = retry { result += ["--retry", String(retry)] }
			mergeNotNil(value: saslAuthorizationIdentity) { result += ["--sasl-authzid", $0] }
			if saslInitialResponse { result += ["--sasl-ir"] }
			mergeNotNil(value: serviceName) { result += ["--service-name", $0] }
			if showError { result += ["--show-error"] }
			if silent { result += ["--silent"] }
			mergeNotNil(value: socks4) { result += ["--socks4", $0] }
			mergeNotNil(value: socks4a) { result += ["--socks4a", $0] }
			if socks5Basic { result += ["--socks5-basic"] }
			if socks5_GSS_API_NEC { result += ["--socks5-gssapi-nec"] }
			mergeNotNil(value: socks5_GSS_API_Service) { result += ["--socks5-gssapi-service", $0] }
			if socks5_GSS_API { result += ["--socks5-gssapi"] }
			mergeNotNil(value: socks5Hostname) { result += ["--socks5-hostname", $0] }
			mergeNotNil(value: socks5) { result += ["--socks5", $0] }
			if let speedLimit = speedLimit { result += ["--speed-limit", String(speedLimit)] }
			if let speedTime = speedTime { result += ["--speed-time", String(speedTime)] }
			if sslAllowBeast { result += ["--ssl-allow-beast"] }
			if sslAutoClientCert { result += ["--ssl-auto-client-cert"] }
			if sslNoRevoke { result += ["--ssl-no-revoke"] }
			if sslRequired { result += ["--ssl-reqd"] }
			if sslRevokeBestEffort { result += ["--ssl-revoke-best-effort"] }
			if ssl { result += ["--ssl"] }
			if sslv2 { result += ["--sslv2"] }
			if sslv3 { result += ["--sslv3"] }
			mergeNotNil(value: stderr) { result += ["--stderr", $0] }
			if styledOutput { result += ["--styled-output"] }
			if suppressConnectHeaders { result += ["--suppress-connect-headers"] }
			if tcpFastOpen { result += ["--tcp-fastopen"] }
			if tcpNoDelay { result += ["--tcp-nodelay"] }
			mergeNotNil(value: telnetOption) { result += ["--telnet-option", $0] }
			if let tftpBlockSize = tftpBlockSize { result += ["--tftp-blksize", String(tftpBlockSize)] }
			if tftpNoOptions { result += ["--tftp-no-options"] }
			
			
			switch self {
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
