# Veriable - AI-Powered Retail Shopping Assistant

Veriable is an innovative iOS application that combines computer vision, machine learning, and modern e-commerce features to create a seamless shopping experience. The app uses AI to identify products through your camera, manage your shopping cart, and process orders through a robust backend system.

## 🎯 What Veriable Does

Veriable transforms the traditional shopping experience by:

- **AI Product Recognition**: Scan products with your camera using a custom-trained YOLOv8 model
- **Smart Shopping Cart**: Automatically add scanned items to your cart with real-time backend synchronization
- **Seamless Checkout**: Complete purchases with integrated order management
- **Scan History**: Track all your scanned products with confidence scores
- **User Authentication**: Secure login system with personalized experiences
- **Product Catalog**: Browse products with images, descriptions, and pricing

## 🚀 Vision & Future Goals

Veriable aims to become a comprehensive retail assistant that:

- Provides nutritional information and product recommendations
- Offers price comparisons across different stores
- Suggests recipes based on scanned ingredients
- Integrates with loyalty programs and digital wallets
- Supports offline mode for areas with poor connectivity
- Expands to support multiple retail categories beyond groceries

## 📱 Features

### Current Features

✅ **AI-Powered Product Scanning**
- Custom YOLOv8 model trained on retail products
- Real-time object detection with confidence scores
- Automatic product identification

✅ **User Management**
- Email-based authentication
- Automatic user creation
- Persistent user sessions

✅ **Shopping Cart**
- Real-time synchronization with Directus backend
- Offline support with local caching
- Quantity management
- Cart persistence across sessions

✅ **Order Processing**
- Complete checkout workflow
- Order history in backend
- Order item tracking

✅ **Product Catalog**
- Product images and descriptions
- Price information
- Backend-driven inventory

✅ **Scan History**
- Local and cloud-based scan records
- Confidence score tracking
- Timestamp recording

## 🏗️ Architecture

### Technology Stack

- **Frontend**: SwiftUI (iOS 15+)
- **Backend**: Directus (Headless CMS)
- **ML Framework**: CoreML with YOLOv8
- **Networking**: URLSession with async/await
- **Local Storage**: Keychain for secure data
- **Image Processing**: Vision framework

### Backend Collections

```
app_users
├── id (Integer, PK)
├── name (String)
└── email (String)

products
├── id (Integer, PK)
├── name (String)
├── description (Text)
├── price (Float)
└── image_url (String)

cart_items
├── id (Integer, PK)
├── user (M2O → app_users)
├── product (M2O → products)
└── quantity (Integer)

orders
├── id (Integer, PK)
├── user (M2O → app_users)
├── total (Float)
├── status (String)
└── created_at (Timestamp)

order_items
├── id (Integer, PK)
├── order (M2O → orders)
├── product (M2O → products)
├── quantity (Integer)
└── price (Float)

scan_records
├── id (Integer, PK)
├── user (M2O → app_users)
├── product_name (String)
├── confidence (Float)
├── recorded_at (Timestamp)
└── quantity (Integer)
```

## 🤖 ML Model Training with Ultralytics HUB

### Overview

Veriable uses a custom YOLOv8 model trained specifically for retail product recognition. The model is trained using Ultralytics HUB, a cloud-based platform for training and deploying YOLO models.

### Training Process

#### 1. Dataset Preparation

```bash
# Organize your dataset in YOLO format
dataset/
├── images/
│   ├── train/
│   ├── val/
│   └── test/
└── labels/
    ├── train/
    ├── val/
    └── test/
```

**Dataset Structure:**
- Images should be in JPG or PNG format
- Labels should be in YOLO format (.txt files)
- Each label file contains: `class_id center_x center_y width height`

#### 2. Create Ultralytics HUB Account

1. Visit [Ultralytics HUB](https://hub.ultralytics.com)
2. Sign up for a free account
3. Create a new project

#### 3. Upload Dataset

```bash
# Install Ultralytics
pip install ultralytics

# Upload dataset to HUB
from ultralytics import YOLO

# Login to HUB
YOLO.login('YOUR_API_KEY')

# Upload dataset
dataset = YOLO.upload_dataset('path/to/dataset', project='veriable-products')
```

#### 4. Configure Training

In Ultralytics HUB:
- Select YOLOv8n (nano) for mobile deployment
- Set epochs: 100-300 (depending on dataset size)
- Image size: 640x640
- Batch size: 16 (adjust based on GPU)
- Augmentation: Enable (rotation, flip, scale)

#### 5. Train Model

```python
from ultralytics import YOLO

# Initialize model
model = YOLO('yolov8n.pt')

# Train
results = model.train(
    data='veriable-products.yaml',
    epochs=200,
    imgsz=640,
    batch=16,
    name='veriable-v1'
)
```

#### 6. Export to CoreML

```python
# Export trained model to CoreML
model = YOLO('runs/detect/veriable-v1/weights/best.pt')
model.export(format='coreml', nms=True, imgsz=640)
```

This generates a `.mlmodel` file optimized for iOS.

#### 7. Add Model to Xcode Project

1. Drag the `.mlmodel` file into your Xcode project
2. Xcode automatically generates Swift interfaces
3. The model is now ready to use in your app

### Model Integration in App

```swift
import CoreML
import Vision

// Load model
guard let model = try? VNCoreMLModel(for: YourModel(configuration: MLModelConfiguration()).model) else {
    return
}

// Create request
let request = VNCoreMLRequest(model: model) { request, error in
    guard let results = request.results as? [VNRecognizedObjectObservation] else {
        return
    }
    
    // Process detections
    for observation in results {
        let label = observation.labels.first?.identifier
        let confidence = observation.confidence
        // Handle detection
    }
}

// Perform detection
let handler = VNImageRequestHandler(ciImage: image)
try? handler.perform([request])
```

### Model Performance Tips

- **Dataset Quality**: Use 1000+ images per class for best results
- **Augmentation**: Enable to improve generalization
- **Class Balance**: Ensure similar number of samples per class
- **Validation**: Use 20% of data for validation
- **Fine-tuning**: Start with pre-trained weights for faster convergence

## 📦 Installation

### Prerequisites

- macOS 12.0+ with Xcode 14.0+
- iOS 15.0+ device or simulator
- Directus instance (cloud or self-hosted)
- CocoaPods or Swift Package Manager

### Backend Setup (Directus)

#### Option 1: Cloud Deployment (Recommended)

1. **Deploy to Sliplane/Railway/Render:**
   ```bash
   # Use one-click deploy or Docker
   docker run -p 8055:8055 \
     -e KEY=your-secret-key \
     -e SECRET=your-secret \
     -e ADMIN_EMAIL=admin@example.com \
     -e ADMIN_PASSWORD=password \
     directus/directus
   ```

2. **Access Directus Admin:**
   - Navigate to `https://your-instance.com`
   - Login with admin credentials
   - The schema is automatically created by the app setup scripts

#### Option 2: Local Development

```bash
# Install Directus
npm init directus-project veriable-backend

# Start Directus
cd veriable-backend
npx directus start

# Access at http://localhost:8055
```

### iOS App Setup

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/yourusername/veriable.git
   cd veriable
   ```

2. **Install Dependencies:**
   ```bash
   # If using CocoaPods
   pod install
   
   # Open workspace
   open Veriable.xcworkspace
   ```

3. **Configure Environment:**

   Create or edit `Info.plist` to add:
   ```xml
   <key>API_BASE_URL</key>
   <string>https://your-directus-instance.com</string>
   <key>API_TOKEN</key>
   <string>your-directus-access-token</string>
   ```

   Or set environment variables in Xcode scheme:
   - Edit Scheme → Run → Arguments → Environment Variables
   - Add `API_BASE_URL` and `API_TOKEN`

4. **Get Directus Access Token:**
   ```bash
   # Login to Directus and create a static token
   # Settings → Access Tokens → Create Token
   # Copy the token and add to your configuration
   ```

5. **Build and Run:**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run
   - The app will create the necessary backend schema on first run

### First Run Setup

1. **Launch the app**
2. **Login/Signup** with your email
3. **Browse products** from the catalog
4. **Scan products** using the camera (requires ML model)
5. **Add to cart** and checkout

## 🔧 Configuration

### Config.swift

The app uses a centralized configuration system:

```swift
// Reads from environment variables or Info.plist
Config.apiBaseURL  // Directus instance URL
Config.apiToken    // Directus access token
```

### Environment Variables

Set these in Xcode or Info.plist:

- `API_BASE_URL`: Your Directus instance URL (default: `https://veriable.sliplane.app`)
- `API_TOKEN`: Your Directus static access token

## 📂 Project Structure

```
Veriable/
├── Core/
│   ├── AppEnvironment.swift      # Dependency injection
│   ├── AppState.swift             # Global app state
│   └── Config.swift               # Configuration management
├── Data/
│   ├── API/
│   │   ├── APIClient.swift        # Network client
│   │   ├── ProductAPI.swift       # Product endpoints
│   │   ├── UserAPI.swift          # User endpoints
│   │   ├── CartAPI.swift          # Cart endpoints
│   │   ├── OrderAPI.swift         # Order endpoints
│   │   └── ScanRecordAPI.swift    # Scan record endpoints
│   └── Repositories/
│       ├── ProductRepository.swift
│       ├── CartRepository.swift
│       └── UserRepository.swift
├── Domain/
│   ├── Entities/
│   │   ├── Product.swift
│   │   ├── User.swift
│   │   ├── CartItem.swift
│   │   └── ScanRecord.swift
│   └── UseCases/
│       ├── FetchProductsUseCase.swift
│       ├── AddToCartUseCase.swift
│       └── CheckoutUseCase.swift
├── Features/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── AuthViewModel.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── HomeViewModel.swift
│   ├── Scanner/
│   │   └── ScannerView.swift
│   ├── Cart/
│   │   ├── CartView.swift
│   │   └── CartViewModel.swift
│   └── Checkout/
│       └── CheckoutView.swift
└── VeriableApp.swift              # App entry point
```

## 🔐 Security

- **API Token**: Stored securely, never hardcoded in production
- **Keychain**: Used for sensitive local data
- **HTTPS**: All API communication is encrypted
- **User Authentication**: Email-based with backend validation

## 🧪 Testing

```bash
# Run unit tests
cmd + U in Xcode

# Run UI tests
Select UI Test target and run
```

## 🐛 Troubleshooting

### Common Issues

**1. "Cannot connect to backend"**
- Check `API_BASE_URL` is correct
- Verify Directus instance is running
- Check network connectivity

**2. "Invalid token"**
- Regenerate access token in Directus
- Update `API_TOKEN` in configuration

**3. "Model not found"**
- Ensure `.mlmodel` file is added to Xcode project
- Check model is included in target membership

**4. "Cart not syncing"**
- Verify user is logged in
- Check cart_items collection exists in Directus
- Review console logs for API errors

## 📝 API Documentation

### Authentication

All API requests require Bearer token authentication:

```swift
Authorization: Bearer YOUR_TOKEN
```

### Endpoints

#### Products
- `GET /items/products` - List all products
- `GET /items/products/:id` - Get product details

#### Cart
- `GET /items/cart_items?filter[user][_eq]=:userId` - Get user's cart
- `POST /items/cart_items` - Add item to cart
- `PATCH /items/cart_items/:id` - Update cart item
- `DELETE /items/cart_items/:id` - Remove from cart

#### Orders
- `POST /items/orders` - Create order
- `POST /items/order_items` - Add order items

#### Users
- `GET /items/app_users?filter[email][_eq]=:email` - Find user
- `POST /items/app_users` - Create user

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👥 Authors

- **Collins Koech** - Initial development

## 🙏 Acknowledgments

- Ultralytics for YOLOv8 and training platform
- Directus for the headless CMS
- Apple for SwiftUI and CoreML frameworks

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Email: support@veriable.app
- Documentation: https://docs.veriable.app

---

**Built with ❤️ using SwiftUI, CoreML, and Directus**
