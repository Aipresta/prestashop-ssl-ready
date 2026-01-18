# PrestaShop SSL-Ready

PrestaShop 9 with reverse proxy support pre-configured for use behind Coolify/Traefik.

## What's Different
- Apache `remoteip` module enabled
- Configured to trust X-Forwarded-For headers from private networks
- Ready for SSL termination at reverse proxy level

## Usage
```yaml
image: ghcr.io/aipresta/prestashop-ssl-ready:latest
```
MIT License - it's the most permissive and common
