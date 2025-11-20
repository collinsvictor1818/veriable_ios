# Deployment Guide

## Backend Deployment (Directus)

### Option 1: Sliplane (Recommended)

1. **Create Account:**
   - Visit [sliplane.app](https://sliplane.app)
   - Sign up for free tier

2. **Deploy Directus:**
   ```bash
   # One-click deploy
   # Select Directus template
   # Configure environment variables
   ```

3. **Environment Variables:**
   ```env
   KEY=generate-random-key-here
   SECRET=generate-random-secret-here
   ADMIN_EMAIL=admin@example.com
   ADMIN_PASSWORD=secure-password
   DB_CLIENT=postgres
   DB_HOST=your-db-host
   DB_PORT=5432
   DB_DATABASE=directus
   DB_USER=directus
   DB_PASSWORD=secure-password
   ```

4. **Access:**
   - Your instance: `https://your-app.sliplane.app`
   - Admin panel: `https://your-app.sliplane.app/admin`

### Option 2: Railway

1. **Create Account:**
   - Visit [railway.app](https://railway.app)
   - Connect GitHub

2. **Deploy:**
   ```bash
   # Click "New Project"
   # Select "Deploy from Template"
   # Search for "Directus"
   # Configure variables
   ```

3. **Custom Domain:**
   - Settings → Domains
   - Add custom domain
   - Update DNS records

### Option 3: Self-Hosted (Docker)

1. **Create docker-compose.yml:**
   ```yaml
   version: '3'
   services:
     directus:
       image: directus/directus:latest
       ports:
         - 8055:8055
       volumes:
         - ./database:/directus/database
         - ./uploads:/directus/uploads
       environment:
         KEY: 'your-secret-key'
         SECRET: 'your-secret'
         ADMIN_EMAIL: 'admin@example.com'
         ADMIN_PASSWORD: 'password'
         DB_CLIENT: 'sqlite3'
         DB_FILENAME: '/directus/database/data.db'
   ```

2. **Deploy:**
   ```bash
   docker-compose up -d
   ```

3. **Access:**
   - http://localhost:8055

### Option 4: DigitalOcean

1. **Create Droplet:**
   - Ubuntu 22.04
   - 2GB RAM minimum
   - Add SSH key

2. **Install Docker:**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   ```

3. **Deploy Directus:**
   ```bash
   docker run -d \
     -p 8055:8055 \
     -e KEY=your-key \
     -e SECRET=your-secret \
     -e ADMIN_EMAIL=admin@example.com \
     -e ADMIN_PASSWORD=password \
     directus/directus
   ```

## iOS App Deployment

### TestFlight (Beta Testing)

1. **Archive App:**
   - Product → Archive in Xcode
   - Wait for archive to complete

2. **Upload to App Store Connect:**
   - Window → Organizer
   - Select archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Upload

3. **Configure TestFlight:**
   - App Store Connect → TestFlight
   - Add internal testers
   - Add external testers (optional)
   - Submit for review

4. **Invite Testers:**
   - Share TestFlight link
   - Testers install TestFlight app
   - Accept invitation

### App Store Release

1. **Prepare Assets:**
   - App icon (1024x1024)
   - Screenshots (all device sizes)
   - App preview video (optional)
   - Privacy policy URL
   - Support URL

2. **App Store Connect:**
   - Create new app
   - Fill in metadata
   - Upload screenshots
   - Set pricing
   - Submit for review

3. **Review Process:**
   - Apple reviews app (1-3 days)
   - Address any issues
   - App goes live after approval

## Environment Configuration

### Production Config

Update `Config.swift` or use Xcode build configurations:

```swift
// Production
API_BASE_URL=https://your-production-directus.com
API_TOKEN=your-production-token

// Staging
API_BASE_URL=https://your-staging-directus.com
API_TOKEN=your-staging-token

// Development
API_BASE_URL=http://localhost:8055
API_TOKEN=your-dev-token
```

### Xcode Build Configurations

1. **Create Configurations:**
   - Project → Info → Configurations
   - Duplicate "Release" → "Staging"

2. **Set Environment Variables:**
   - Edit Scheme → Run
   - Arguments → Environment Variables
   - Add variables per configuration

## CI/CD Setup

### GitHub Actions

Create `.github/workflows/ios.yml`:

```yaml
name: iOS CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: latest-stable
    
    - name: Install dependencies
      run: pod install
    
    - name: Build
      run: xcodebuild -workspace Veriable.xcworkspace -scheme Veriable -destination 'platform=iOS Simulator,name=iPhone 14' build
    
    - name: Test
      run: xcodebuild -workspace Veriable.xcworkspace -scheme Veriable -destination 'platform=iOS Simulator,name=iPhone 14' test
```

### Fastlane

1. **Install:**
   ```bash
   gem install fastlane
   fastlane init
   ```

2. **Configure Fastfile:**
   ```ruby
   default_platform(:ios)
   
   platform :ios do
     desc "Build and test"
     lane :test do
       scan(scheme: "Veriable")
     end
     
     desc "Deploy to TestFlight"
     lane :beta do
       build_app(scheme: "Veriable")
       upload_to_testflight
     end
     
     desc "Deploy to App Store"
     lane :release do
       build_app(scheme: "Veriable")
       upload_to_app_store
     end
   end
   ```

3. **Run:**
   ```bash
   fastlane beta
   ```

## Monitoring & Analytics

### Sentry (Error Tracking)

1. **Install:**
   ```ruby
   pod 'Sentry'
   ```

2. **Initialize:**
   ```swift
   import Sentry
   
   SentrySDK.start { options in
       options.dsn = "your-dsn"
       options.environment = "production"
   }
   ```

### Firebase Analytics

1. **Install:**
   ```ruby
   pod 'Firebase/Analytics'
   ```

2. **Initialize:**
   ```swift
   import Firebase
   
   FirebaseApp.configure()
   ```

## Security Checklist

- [ ] API tokens stored securely (not in code)
- [ ] HTTPS enforced for all API calls
- [ ] App Transport Security configured
- [ ] Sensitive data encrypted
- [ ] Code obfuscation enabled
- [ ] Certificate pinning implemented
- [ ] Keychain used for credentials
- [ ] Debug logs disabled in production

## Performance Optimization

### App Size

- Enable bitcode
- Use asset catalogs
- Remove unused resources
- Optimize images
- Use on-demand resources

### Launch Time

- Lazy load heavy resources
- Defer non-critical initialization
- Use background threads
- Optimize image loading

### Network

- Implement caching
- Use compression
- Batch requests
- Implement retry logic

## Backup & Recovery

### Directus Backup

```bash
# Backup database
docker exec directus-db pg_dump -U directus > backup.sql

# Backup uploads
tar -czf uploads.tar.gz ./uploads
```

### Restore

```bash
# Restore database
docker exec -i directus-db psql -U directus < backup.sql

# Restore uploads
tar -xzf uploads.tar.gz
```

## Scaling

### Horizontal Scaling

- Use load balancer
- Multiple Directus instances
- Shared database
- Shared file storage (S3)

### Vertical Scaling

- Increase server resources
- Optimize database queries
- Add caching layer (Redis)
- Use CDN for static assets

## Troubleshooting

### App Won't Connect

- Check API_BASE_URL
- Verify Directus is running
- Check firewall rules
- Verify SSL certificate

### Slow Performance

- Enable caching
- Optimize images
- Use CDN
- Add database indexes

### Build Failures

- Clean build folder
- Update dependencies
- Check Xcode version
- Verify code signing
