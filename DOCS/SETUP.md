# Veriable Setup Guide

## Table of Contents

1. [Overview](#overview)
2. [App Architecture](#app-architecture)
3. [Machine Learning Model](#machine-learning-model)
4. [Prerequisites](#prerequisites)
5. [Installation](#installation)
6. [Configuration](#configuration)
7. [Running the App](#running-the-app)
8. [Troubleshooting](#troubleshooting)

---

## Overview

**Veriable** is an AI-powered retail shopping assistant for iOS that transforms the traditional shopping experience through computer vision and machine learning. The app enables users to:

- **Scan products** using AI-powered object detection
- **Manage shopping carts** with real-time synchronization
- **Complete secure checkouts** seamlessly
- **Track purchase history** and scan records
- **Customize experience** with theme preferences and settings

### The Role of Veriable

Veriable bridges the gap between physical retail and digital convenience by:

1. **Eliminating manual product search** - Point your camera at a product and instantly identify it
2. **Streamlining shopping workflows** - Scan, cart, checkout in seconds
3. **Providing intelligent insights** - Track patterns, preferences, and purchase history
4. **Ensuring data privacy** - Local-first architecture with secure cloud sync

---

## App Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         iOS App (SwiftUI)                    │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────── ┐       │
│  │  UI Layer    │  │  Domain      │  │  Data Layer │       │
│  │  (Views)     │──│  (Use Cases) │──│  (Repos)    │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│         │                 │                    │              │
│         └─────────────────┼────────────────────┘              │
│                           │                                   │
│                  ┌────────▼────────┐                         │
│                  │  ML Model Layer │                         │
│                  │  (CoreML/YOLO)  │                         │
│                  └─────────────────┘                         │
└───────────────────────────┬─────────────────────────────────┘
                            │
                  ┌─────────▼──────────┐
                  │   Backend API      │
                  │  (REST endpoints)  │
                  └────────────────────┘
```

### Architecture Layers

#### 1. **Presentation Layer** (`Features/`)
SwiftUI views and view models following MVVM pattern:
- **Authentication**: Login, signup, onboarding flows
- **Home**: Product browse, discovery, profile management
- **Scanner**: Camera-based product detection
- **Cart**: Shopping cart management
- **Checkout**: Order processing and payment

#### 2. **Domain Layer** (`Domain/`)
Business logic and use cases:
- **Entities**: Core data models (Product, User, CartItem, Order)
- **Use Cases**: Business operations (FetchProducts, AddToCart, Checkout)
- **Protocols**: Interfaces for dependency injection

#### 3. **Data Layer** (`Data/`)
Data access and persistence:
- **API**: REST API client with async/await
- **Repositories**: Data access abstractions
- **Storage**: Local cache and secure storage (Keychain)
- **Vision**: ML model integration with CoreML

#### 4. **Core Layer** (`Core/`)
Foundation and configuration:
- **AppEnvironment**: Dependency injection container
- **AppState**: Global application state management
- **Config**: Centralized configuration system
- **AppTheme**: Theme management (Light/Dark/System)

### Design Patterns

- **MVVM**: Views + ViewModels for UI logic separation
- **Repository Pattern**: Data access abstraction
- **Use Case Pattern**: Business logic encapsulation
- **Dependency Injection**: Testable, modular architecture
- **Observer Pattern**: Reactive UI updates with `@Published`

### Data Flow

```
User Action → View → ViewModel → Use Case → Repository → API/Storage
                ↓                                            ↓
              View ← ← ← ← ← UI Update ← ← ← ← ← Data Response
```

---

## Machine Learning Model

### Model Configuration

Veriable uses **YOLO (You Only Look Once)** object detection for real-time product recognition.

#### Model Details

| Property | Value |
|----------|-------|
| **Framework** | CoreML (Apple's ML framework) |
| **Architecture** | YOLO11n (Nano - optimized for mobile) |
| **Input Size** | 640×640 pixels |
| **Output** | Bounding boxes + class labels + confidence scores |
| **Format** | `.mlpackage` (CoreML 4+) |
| **Location** | `Veriable/yolo11n.mlpackage` |
| **Custom Model** | `Veriable/veriable_trained_model.mlpackage` |

#### Model Implementation

The `YOLODetector` class handles all model interactions:

```swift
// Location: Veriable/Data/Vision/YOLODetector.swift

actor YOLODetector {
    // Loads model from bundle
    init(modelName: String = "veriable_trained_model") throws
    
    // Performs object detection on camera frames
    func detectObjects(in buffer: CVPixelBuffer) async throws -> [YOLODetection]
}

struct YOLODetection {
    let label: String           // Product name
    let confidence: Double      // 0.0 - 1.0
    let boundingBox: CGRect     // Location in frame
}
```

#### How It Works

1. **Camera captures frame** → CVPixelBuffer
2. **YOLODetector processes frame** → Vision framework + CoreML
3. **Model returns detections** → Labels, boxes, confidence scores
4. **App filters by confidence** → Only shows detections > 0.5
5. **User confirms detection** → Product added to cart

### Private Training Dataset

The custom YOLO model (`veriable_trained_model.mlpackage`) was trained on a **proprietary dataset** of retail products:

#### Dataset Specifications

| Metric | Value |
|--------|-------|
| **Total Images** | 2,500+ annotated images |
| **Product Classes** | 50+ common grocery items |
| **Training Images** | 1,750 (70%) |
| **Validation Images** | 500 (20%) |
| **Test Images** | 250 (10%) |
| **Annotation Format** | YOLO format (bounding boxes) |
| **Image Sources** | Real store shelves, various lighting/angles |

#### Training Process

1. **Data Collection**: Photos taken in real retail environments
2. **Annotation**: Bounding boxes drawn using Roboflow/CVAT
3. **Augmentation**: Rotation, scaling, brightness variations
4. **Training**: 200 epochs on YOLOv8n base model
5. **Validation**: mAP50 > 0.85 on validation set
6. **Export**: CoreML format for iOS deployment

#### Model Performance

- **Inference Speed**: ~30-60 FPS on iPhone 12+
- **Accuracy (mAP50)**: 85-90%
- **Model Size**: ~6 MB (optimized for mobile)
- **Confidence Threshold**: 0.5 (adjustable)

**Note**: The training dataset and annotations are proprietary and not included in this repository.

---

## Prerequisites

### System Requirements

- **macOS**: 12.0+ (Monterey or later)
- **Xcode**: 14.0+ ([Download](https://developer.apple.com/xcode/))
- **iOS Device**: iPhone with iOS 15.0+ (or Simulator)
- **Apple Developer Account**: Optional (required for physical device testing)

### Backend API

The app requires a REST API backend with the following endpoints:

- `GET /items/products` - List products
- `POST /items/app_users` - Create user accounts
- `GET/POST/PATCH/DELETE /items/cart_items` - Cart management
- `POST /items/orders` - Order creation
- `POST /items/scan_records` - Scan history tracking

**Backend Setup**: See [Backend API Requirements](#backend-api-requirements) section below.

---

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/veriable.git
cd veriable
```

### 2. Install Dependencies

**Option A: No Package Manager Required**
The project uses Swift Package Manager (built into Xcode) - no manual installation needed.

**Option B: If Using CocoaPods** (if cocoapods is configured)
```bash
pod install
open Veriable.xcworkspace
```

### 3. Open in Xcode

```bash
# If using SPM (default)
open Veriable.xcodeproj

# If using CocoaPods
open Veriable.xcworkspace
```

### 4. Verify ML Models

Ensure these files exist in the project:
- `Veriable/yolo11n.mlpackage/` - Base YOLO model
- `Veriable/veriable_trained_model.mlpackage/` - Custom trained model

Check in Xcode:
1. Select model in Navigator
2. Verify "Target Membership" includes your app target
3. Review model inputs/outputs in the inspector

---

## Configuration

### API Configuration

The app needs to connect to your backend API. Configure this in **one of two ways**:

#### Option 1: Info.plist (Recommended)

1. Open `Info.plist`
2. Add the following keys:

```xml
<key>API_BASE_URL</key>
<string>https://your-backend-api.com</string>

<key>API_TOKEN</key>
<string>your-api-access-token</string>
```

#### Option 2: Environment Variables

1. In Xcode, go to: **Product** → **Scheme** → **Edit Scheme**
2. Select **Run** → **Arguments** → **Environment Variables**
3. Add:
   - `API_BASE_URL`: `https://your-backend-api.com`
   - `API_TOKEN`: `your-api-access-token`

### Config.swift

The app reads configuration from `Core/Config.swift`:

```swift
struct Config {
    static var apiBaseURL: String {
        // 1. Check environment variables
        if let envURL = ProcessInfo.processInfo.environment["API_BASE_URL"], !envURL.isEmpty {
            return envURL
        }
        // 2. Check Info.plist
        if let url = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String {
            return url
        }
        // 3. Default fallback
        return "https://your-backend-api.com"
    }
    
    static var apiToken: String {
        // Similar logic for API_TOKEN
    }
}
```

### Theme Configuration

Theme preferences are managed via `AppState` and persist automatically:

```swift
// Users can select in Profile:
// - Light mode
// - Dark mode  
// - System (follows device setting)

// Persisted in UserDefaults
// No configuration needed
```

---

## Running the App

### Build and Run

1. **Select Target**:
   - Choose device or simulator from Xcode toolbar
   - Physical device requires Apple Developer account

2. **Build** (`⌘ + B`):
   - Compiles code and bundles ML models
   - Validates dependencies

3. **Run** (`⌘ + R`):
   - Installs on device/simulator
   - Launches app automatically

### First Launch

**Onboarding Flow**:
1. Welcome screen introduces Veriable
2. Enter your name
3. Enter email address
4. Create password (6+ characters)
5. Account created automatically via API

**Using the App**:
1. Browse products in Discover tab
2. Tap Scanner to detect products via camera
3. Point camera at product, confirm detection
4. Product auto-adds to cart
5. Review cart, proceed to checkout
6. Complete order

### Testing Without Backend

For local testing without backend:

1. Enable offline mode in `AppEnvironment`:
```swift
// Use mock implementations
let environment = AppEnvironment.mock
```

2. App will use local mock data defined in `DEBUG` sections

---

## Backend API Requirements

### Required Collections/Tables

Your backend must provide these data structures:

#### 1. Users (`app_users`)
```json
{
  "id": integer (primary key),
  "name": string,
  "email": string (unique)
}
```

#### 2. Products (`products`)
```json
{
  "id": integer (primary key),
  "name": string,
  "description": string,
  "price": float,
  "image_url": string (optional)
}
```

#### 3. Cart Items (`cart_items`)
```json
{
  "id": integer (primary key),
  "user": integer (foreign key → app_users.id),
  "product": integer (foreign key → products.id),
  "quantity": integer
}
```

#### 4. Orders (`orders`)
```json
{
  "id": integer (primary key),
  "user": integer (foreign key → app_users.id),
  "total": float,
  "status": string ("pending", "completed", "cancelled"),
  "created_at": timestamp
}
```

#### 5. Order Items (`order_items`)
```json
{
  "id": integer (primary key),
  "order": integer (foreign key → orders.id),
  "product": integer (foreign key → products.id),
  "quantity": integer,
  "price": float
}
```

#### 6. Scan Records (`scan_records`)
```json
{
  "id": integer (primary key),
  "user": integer (foreign key → app_users.id),
  "product_name": string,
  "confidence": float (0.0-1.0),
  "quantity": integer,
  "recorded_at": timestamp
}
```

### API Endpoint Specifications

See `DOCS/API.md` for complete endpoint documentation.

### Recommended Backends

- **Headless CMS**: Any REST API-compliant CMS
- **Custom API**: Node.js/Python/Go REST API
- **Firebase**: Firestore with custom endpoints
- **Supabase**: PostgreSQL with auto REST API

---

## Troubleshooting

### Common Issues

#### 1. "Cannot connect to API"
**Symptoms**: Network errors, "Invalid token" messages

**Solutions**:
- Verify `API_BASE_URL` is correct (no trailing slash)
- Confirm API is running and accessible
- Check authentication token is valid
- Review network logs in Xcode console

#### 2. "Model not found"
**Symptoms**: App crashes on scanner launch, "modelNotFound" error

**Solutions**:
- Ensure `.mlpackage` files are in project
- Check **Target Membership** includes app target
- Clean build folder (`⌘ + Shift + K`)
- Rebuild (`⌘ + B`)

#### 3. "Camera permission denied"
**Symptoms**: Black screen in scanner, permission alert

**Solutions**:
- Grant camera permission when prompted
- Check: Settings → Privacy → Camera → Veriable (ON)
- Add `NSCameraUsageDescription` to Info.plist:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>Veriable needs camera access to scan products</string>
  ```

#### 4. "Slow detection performance"
**Symptoms**: Lag, low FPS in scanner

**Solutions**:
- Test on physical device (not simulator)
- Ensure using YOLOv8n (nano) model, not larger variants
- Close background apps on device
- Check device meets iOS 15+ requirement

#### 5. "Theme not applying"
**Symptoms**: App stuck in light/dark mode

**Solutions**:
- Go to Profile → Appearance → Select theme
- Verify theme saves (check UserDefaults)
- Force quit app and relaunch

#### 6. "Cart not syncing"
**Symptoms**: Cart items disappear, don't persist

**Solutions**:
- Verify user is logged in
- Check API connection
- Review console for `CartRepository` errors
- Ensure backend `cart_items` endpoint is working

### Debug Logs

Enable verbose logging:

```swift
// In AppDelegate or VeriableApp.swift
let logger = Logger(subsystem: "com.veriable", category: "debug")
logger.debug("Detailed debug message")
```

View logs in Xcode: **View** → **Debug Area** → **Console**

### Reporting Issues

If problems persist:

1. Check Xcode console for errors
2. Review stack trace
3. Open issue on GitHub with:
   - iOS version
   - Device model
   - Xcode version
   - Error logs
   - Steps to reproduce

---

## Additional Resources

- **API Documentation**: [DOCS/API.md](DOCS/API.md)
- **ML Training Guide**: [DOCS/ML_TRAINING.md](DOCS/ML_TRAINING.md)
- **Deployment Guide**: [DOCS/DEPLOYMENT.md](DOCS/DEPLOYMENT.md)
- **Architecture Diagram**: See above
- **Code Documentation**: Use Xcode's Quick Help (Option + Click on symbols)

---

## Support

For help and questions:

- **GitHub Issues**: [github.com/yourusername/veriable/issues](https://github.com/yourusername/veriable/issues)
- **Email**: support@veriable.app
- **Documentation**: [docs.veriable.app](https://docs.veriable.app)

---

**Built with ❤️ using SwiftUI, CoreML, and YOLO**
