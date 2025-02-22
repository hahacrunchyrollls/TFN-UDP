# Jerico-UDP Custom Script

A customized UDP script installer that uses Hysteria server core. This script supports user management and automatic configuration of UDP services.

## Features

- Easy installation and management
- User management system with SQLite database
- Automatic SSL certificate generation
- Customizable server settings
- Multi-user support
- Speed limiting capabilities
- Domain configuration
- Obfuscation support

## Requirements

- Linux-based operating system (Ubuntu recommended)
- Root access
- Domain pointed to your server's IP
- Open UDP ports

## Installation

```bash
curl -sL https://raw.githubusercontent.com/hahacrunchyrollls/UDP-SCRIPT/main/install.sh | bash
```

## Post-Installation

After installation, you can manage the UDP service using the command:

```bash
udp
```

## Management Features

1. User Management
   - Add new users
   - Edit user passwords
   - Delete users
   - View all users

2. Server Configuration
   - Change domain
   - Modify obfuscation string
   - Adjust upload/download speeds
   - Restart server
   - Uninstall server

## Default Configuration

- Protocol: UDP
- Default Port: 36712
- Default Obfuscation: "jerico"
- Default Password: "jerico"

## File Locations

- Config Directory: `/etc/hysteria/`
- User Database: `/etc/hysteria/udpusers.db`
- Config File: `/etc/hysteria/config.json`
- SSL Certificates:
  - `/etc/hysteria/hysteria.server.crt`
  - `/etc/hysteria/hysteria.server.key`

## Management Commands

After installation, use these commands in the UDP manager:

1. Add User: Option 1
2. Edit User: Option 2
3. Delete User: Option 3
4. List Users: Option 4
5. Change Domain: Option 5
6. Change Obfs: Option 6
7. Change Upload Speed: Option 7
8. Change Download Speed: Option 8
9. Restart Server: Option 9
10. Uninstall Server: Option 10

## Support

For issues and support, contact:
- Telegram: @jerico555
## Credits

Modified by Jerico
Credits to Khaled AGN
Based on Hysteria server core

## Warning

This script is meant for educational purposes only. Please ensure you comply with your local laws and regulations when using this script.
