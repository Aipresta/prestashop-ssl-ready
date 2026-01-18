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
```

### .gitignore - **Not needed**
- This repo only has a Dockerfile and workflow file
- Nothing to ignore

### LICENSE - **Optional, but if public use MIT:**
```
MIT License - it's the most permissive and common
