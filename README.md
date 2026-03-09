# Dinamo SSL Pinning Security App

iOS application demonstrating SSL Pinning with HC Dinamo Minsk hockey data. Includes a Python server that runs with valid/invalid certificates to showcase protection against Man-in-the-Middle attacks.

## Overview

Two main components:
- **iOS Client**: SwiftUI app with static SSL Pinning
- **Python Server**: HTTPS server with configurable certificates

Displays real statistics of HC Dinamo Minsk: season stats, recent games, top scorers.

## How It Works

| Server Certificate | App Behavior |
|-------------------|--------------|
| Valid | Connects successfully, shows data |
| Invalid | Blocks connection, shows error |

## Features

- SSL Pinning with embedded .der certificate
- Server modes: valid/invalid certificate
- HC Dinamo Minsk hockey data
- SwiftUI interface with gradients
- Error handling for SSL issues
- Simulator (localhost) and real device (Wi-Fi) support

## Tech Stack

**iOS:** SwiftUI, Combine, URLSession + custom delegate  
**Server:** Python 3, HTTPS, OpenSSL, JSON

## Quick Start
### 1.Clone & Generate Certificates
```bash
git clone https://github.com/AleinikK666/DinamoMobileSecurityApp.git
cd DinamoMobileSecurityApp/ssl-pinning-server
chmod +x generate_certs.sh
./generate_certs.sh
```

### 2.Start the Server
```bash
python3 server.py --cert valid --port 8443

or

python3 server.py --cert invalid --port 8443
```

### 3.Configure & Run iOS App

Open Dinammo.xcodeproj in Xcode and Press Run (⌘R).

#### Photo of Dinamo App
|  |  |
|![photo1](https://github.com/AleinikK666/DinamoMobileSecurityApp/blob/main/Photo/d1.png) | ![photo2](https://github.com/AleinikK666/DinamoMobileSecurityApp/blob/main/Photo/d2.png) |


## Author
Katya Aleinik, iOS-developer, connection: @katyaleinik
