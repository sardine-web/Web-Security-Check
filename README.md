<h1> Web Security Check </h1>

<h3> A comprehensive Bash script for automating web security assessments. Web Security Check is designed to help pentesters, security researchers, and bug bounty hunters quickly identify common vulnerabilities in web applications by performing checks like 403 bypasses, header injections, basic LFI testing, and other quick tricks.
Features </h3>

    Dynamic Target URL: Prompts the user to input a target URL.
    Common Checks:
        robots.txt presence
        Standard HTTP headers
        Security headers with explanations
    Security Headers Explanation:
        Includes headers like Strict-Transport-Security, X-Frame-Options, X-XSS-Protection, and X-Content-Type-Options with detailed descriptions.
    Quick Tricks:
        Modifies headers to test for unusual responses.
        Tests for debug parameters, cross-domain policies, and rate-limiting bypass.
    Header Injection:
        Injects custom headers (e.g., Client-IP, X-Forwarded-For) to test for IP-based security bypasses.
    Add Line Wrapping:
        Variations in request formatting to uncover misconfigurations.
    Basic LFI (Local File Inclusion):
        Tests for common LFI paths like /etc/passwd and /proc/self/environ.
    403 Bypass Techniques:
        Uses various path modifications and encoding to bypass 403 Forbidden restrictions.

<h2> Installation</h2>

Clone the repository and make the script executable:

<h2>bash</h2>

git clone https://github.com/yourusername/web-security-check.git
cd web-security-check
chmod +x web_security_check.sh

<h2>Usage</h2>

Run the script and enter the target URL when prompted:

bash

./web_security_check.sh

<h2>Example Output</h2>

The tool provides HTTP status codes, responses, and specific findings for each check. Here’s a sample output:

plaintext

Enter the target URL (e.g., http://example.com): http://targetsite.com
[+] Starting security checks on: http://targetsite.com

Checking robots.txt...
Found robots.txt file...

Checking headers...
[Headers output]

[+] Testing 403 Bypass Techniques for path: /admin
Normal request: 403
With semicolon: 200

<h2>Tests Performed</h2>

    robots.txt Check: Scans for the robots.txt file to discover hidden paths.
    Security Headers: Checks for secure headers to protect against attacks like XSS and clickjacking.
    HTTP Methods: Lists available HTTP methods, like OPTIONS, using nmap.
    403 Bypass Techniques: Applies multiple bypass techniques including:
        URL encoding (%2e, %20)
        Path modifications (.., ;, ~)
        Double slashes (//) and extra characters

<h2>Advanced Configuration</h2>

You can customize specific arrays and functions in the script to add:

    Additional LFI paths
    Custom headers for injection
    New 403 Bypass techniques

<h2>Disclaimer</h2>

This tool is intended for educational purposes and authorized testing only. Unauthorized use is prohibited and may be illegal. Use responsibly and respect target terms of service.
Contributing

Contributions are welcome! Please open an issue or pull request to discuss
