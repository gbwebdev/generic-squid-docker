# Generic Squid Docker

Simply put: a docker wrapper to set-up squid basic settings with environment variables.

With fancy words: a lightweight, configurable Squid HTTP/HTTPS proxy server in a Docker container, designed for controlled outbound internet access. Perfect for securing containerized applications by restricting external network access to only approved domains, IP ranges, and ports.

## 🚀 Features

- **Domain Filtering**: Allow access to specific domains (with wildcard support)
- **IP/CIDR Filtering**: Control access by IP addresses and network ranges  
- **Port Restriction**: Limit allowed ports (defaults to 80 and 443)
- **HTTPS CONNECT Support**: Handles SSL/TLS connections with SNI filtering
- **Cache Control**: Optional caching (disabled by default for pure proxy mode)
- **Minimal Footprint**: Based on Alpine Linux for small image size
- **Environment-driven Configuration**: No manual config files needed

## 📦 Quick Start

### Using Docker Compose

#### Basic Setup

```yaml
services:
  squid:
    image: ghcr.io/gbwebdev/generic-squid-docker:latest
    ports:
      - "3128:3128"
    environment:
      ALLOW_DOMAINS: |
        .github.com
        api.github.com
        .pypi.org
      ALLOW_CIDRS: "192.168.1.0/24"
      ALLOW_PORTS: "80,443"
      DISABLE_CACHE: "true"
      BLOCK_BY_DEFAULT: "true"
```

#### Complete Example with Isolated Application

This example shows how to use the squid proxy to control internet access for a containerized application:

```yaml
version: '3.8'

services:
  # Squid proxy with restricted access
  squid:
    image: ghcr.io/gbwebdev/generic-squid-docker:latest
    networks:
      - default    # Access to internet
      - backend    # Access to backend applications
    environment:
      ALLOW_DOMAINS: |
        .github.com
        api.github.com
        .pypi.org
        httpbin.org
      ALLOW_PORTS: "80,443"
      DISABLE_CACHE: "true" 
      BLOCK_BY_DEFAULT: "true"
      DEBUG: "false"

  # Example application that can only access internet through squid
  app:
    image: alpine:latest
    networks:
      - backend  # Only connected to backend network, no direct internet
    environment:
      # Configure proxy for the application
      HTTP_PROXY: "http://squid:3128"
      HTTPS_PROXY: "http://squid:3128"
      http_proxy: "http://squid:3128"
      https_proxy: "http://squid:3128"
    command: |
      sh -c "
        apk add --no-cache curl &&
        echo 'Testing allowed domain (should work):' &&
        curl -s -o /dev/null -w '%%{http_code}' https://api.github.com/user || echo 'Failed' &&
        echo &&
        echo 'Testing blocked domain (should fail):' &&
        curl -s -o /dev/null -w '%%{http_code}' https://www.google.com --connect-timeout 5 || echo 'Blocked (expected)' &&
        echo &&
        echo 'Keeping container alive...' &&
        tail -f /dev/null
      "
    depends_on:
      - squid

networks:
  backend:
    driver: bridge
    internal: true   # No direct internet access for applications
```

### Using Docker Run

```bash
docker run -d \
  -p 3128:3128 \
  -e ALLOW_DOMAINS=".github.com,api.github.com" \
  -e ALLOW_PORTS="80,443" \
  -e DISABLE_CACHE="true" \
  ghcr.io/gbwebdev/generic-squid-docker:latest
```

## 🔧 Configuration

Configure the proxy using environment variables:

### Core Settings

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `ALLOW_DOMAINS` | Comma or newline-separated list of allowed domains (supports wildcards with `.`) | Empty | `.github.com,api.example.com` |
| `ALLOW_CIDRS` | Comma or newline-separated list of allowed IP ranges | Empty | `192.168.1.0/24,10.0.0.0/8` |
| `ALLOW_PORTS` | Comma-separated list of allowed ports | `80,443` | `80,443,8080,9418` |

### Behavior Settings

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `BLOCK_BY_DEFAULT` | Block all traffic not explicitly allowed | `true` | `true`, `false` |
| `DISABLE_CACHE` | Disable caching (pure forward proxy mode) | `true` | `true`, `false` |

### Logging Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `SQUID_ACCESS_LOG` | Access log location | `/var/log/squid/access.log` |
| `SQUID_CACHE_LOG` | Cache log location | `/var/log/squid/cache.log` |

### Debug Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `DEBUG` | Show configuration details on startup | `false` |

## 🌐 Usage Example

Allow access only to specific websites:

```yaml
environment:
  ALLOW_DOMAINS: |
    .google.com
    .stackoverflow.com
    .github.com
  ALLOW_PORTS: "80,443"
```

## 🔍 How It Works

1. **Domain Matching**: Uses Squid's `dstdomain` ACL for HTTP and `ssl::server_name` for HTTPS SNI
2. **IP Filtering**: Direct IP access controlled via `dst` ACL with CIDR support
3. **Port Control**: Restricts both HTTP and CONNECT methods to specified ports
4. **Default Deny**: All traffic is blocked unless explicitly allowed (configurable)

## 🛠️ Building Locally

```bash
# Clone the repository
git clone https://github.com/gbwebdev/generic-squid-docker.git
cd generic-squid-docker

# Build the image
docker build -t generic-squid-docker .

# Run with custom configuration
docker run -d \
  -p 3128:3128 \
  -e ALLOW_DOMAINS=".example.com" \
  -e DEBUG="true" \
  generic-squid-docker
```

## 🐛 Debugging

Enable debug mode to see the generated Squid configuration:

```yaml
environment:
  DEBUG: "true"
```

Check container logs:

```bash
docker logs <container-name>
```

Test proxy connectivity:

```bash
# Test HTTP
curl -x http://localhost:3128 http://example.com

# Test HTTPS  
curl -x http://localhost:3128 https://example.com
```

## 📋 Use Cases

- **CI/CD Pipelines**: Control external dependencies during builds
- **Development Environments**: Simulate restricted network conditions
- **Security Compliance**: Enforce outbound traffic policies
- **Microservices**: Add network security layer to containerized apps
- **Testing**: Create controlled network environments

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on [Squid Cache](http://www.squid-cache.org/) - a full-featured web proxy cache
- Uses [Alpine Linux](https://alpinelinux.org/) for minimal container footprint
A generic squid proxy containerized to be usable with envitonment variables
