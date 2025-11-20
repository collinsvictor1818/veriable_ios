# ML Model Training Guide

## Overview

This guide walks you through training a custom YOLOv8 model for product recognition using Ultralytics HUB.

## Prerequisites

- Python 3.8+
- Ultralytics account (free at hub.ultralytics.com)
- Dataset of product images
- GPU recommended (can use Colab/Kaggle for free GPU)

## Step 1: Prepare Your Dataset

### Dataset Structure

```
veriable-dataset/
├── images/
│   ├── train/          # 70% of images
│   ├── val/            # 20% of images
│   └── test/           # 10% of images
└── labels/
    ├── train/          # Corresponding labels
    ├── val/
    └── test/
```

### Label Format

Each image should have a corresponding `.txt` file with YOLO format:

```
class_id center_x center_y width height
```

Example (`image001.txt`):
```
0 0.5 0.5 0.3 0.4
1 0.2 0.3 0.15 0.2
```

Where:
- `class_id`: Integer representing the product class (0-indexed)
- `center_x`, `center_y`: Normalized center coordinates (0-1)
- `width`, `height`: Normalized box dimensions (0-1)

### Recommended Dataset Size

- **Minimum**: 100 images per class
- **Good**: 500 images per class
- **Excellent**: 1000+ images per class

### Data Collection Tips

1. **Variety**: Different angles, lighting, backgrounds
2. **Quality**: Clear, well-lit images
3. **Context**: Include products in realistic shopping scenarios
4. **Augmentation**: Will be applied during training

## Step 2: Annotation

### Using Roboflow (Recommended)

1. Create account at roboflow.com
2. Upload images
3. Use annotation tool to draw bounding boxes
4. Export in YOLO format

### Using LabelImg

```bash
pip install labelImg
labelImg
```

1. Open directory with images
2. Draw bounding boxes
3. Save in YOLO format

### Using CVAT

1. Create account at cvat.org
2. Create project
3. Upload images
4. Annotate with bounding boxes
5. Export in YOLO format

## Step 3: Create data.yaml

Create a `data.yaml` file describing your dataset:

```yaml
path: /path/to/veriable-dataset
train: images/train
val: images/val
test: images/test

# Classes
names:
  0: organic_eggs
  1: avocado
  2: whole_milk
  3: cold_brew
  4: almond_flour
  # Add more classes...

# Number of classes
nc: 5
```

## Step 4: Set Up Ultralytics HUB

### Create Account

1. Visit [hub.ultralytics.com](https://hub.ultralytics.com)
2. Sign up (free tier available)
3. Verify email

### Get API Key

1. Go to Settings
2. Copy your API key
3. Save securely

## Step 5: Upload Dataset

### Option A: Using Python

```python
from ultralytics import YOLO, hub

# Login
hub.login('YOUR_API_KEY')

# Upload dataset
hub.upload_dataset(
    path='/path/to/veriable-dataset',
    name='veriable-products-v1'
)
```

### Option B: Using Web Interface

1. Click "Datasets" in HUB
2. Click "Upload Dataset"
3. Drag and drop your dataset folder
4. Wait for processing

## Step 6: Create Training Project

1. Click "Models" → "New Model"
2. Select your dataset
3. Choose YOLOv8n (nano) for mobile
4. Name your model: "veriable-detector-v1"

## Step 7: Configure Training

### Recommended Settings for Mobile

```yaml
model: yolov8n.pt          # Nano model for mobile
epochs: 200                # Training iterations
imgsz: 640                 # Image size
batch: 16                  # Batch size (adjust for GPU)
patience: 50               # Early stopping patience
device: 0                  # GPU device (0 for first GPU)

# Augmentation
hsv_h: 0.015              # Hue augmentation
hsv_s: 0.7                # Saturation
hsv_v: 0.4                # Value
degrees: 10.0             # Rotation
translate: 0.1            # Translation
scale: 0.5                # Scaling
shear: 0.0                # Shearing
perspective: 0.0          # Perspective
flipud: 0.0               # Vertical flip
fliplr: 0.5               # Horizontal flip (50% chance)
mosaic: 1.0               # Mosaic augmentation
mixup: 0.0                # Mixup augmentation
```

## Step 8: Start Training

### Using HUB Interface

1. Click "Train" button
2. Select cloud GPU (or use local)
3. Monitor training in real-time

### Using Python (Local Training)

```python
from ultralytics import YOLO

# Load model
model = YOLO('yolov8n.pt')

# Train
results = model.train(
    data='data.yaml',
    epochs=200,
    imgsz=640,
    batch=16,
    name='veriable-v1',
    patience=50,
    save=True,
    device=0,  # Use GPU 0
    workers=8,
    project='runs/detect'
)
```

### Using Google Colab (Free GPU)

```python
# Install Ultralytics
!pip install ultralytics

# Clone your dataset
!git clone https://github.com/yourusername/veriable-dataset.git

# Train
from ultralytics import YOLO

model = YOLO('yolov8n.pt')
results = model.train(
    data='veriable-dataset/data.yaml',
    epochs=200,
    imgsz=640,
    batch=16
)
```

## Step 9: Monitor Training

### Metrics to Watch

- **mAP50**: Mean Average Precision at 50% IoU (target: >0.8)
- **mAP50-95**: mAP across IoU thresholds (target: >0.5)
- **Precision**: True positives / (True positives + False positives)
- **Recall**: True positives / (True positives + False negatives)
- **Loss**: Should decrease over time

### TensorBoard

```bash
tensorboard --logdir runs/detect/veriable-v1
```

## Step 10: Evaluate Model

```python
# Validate
results = model.val()

# Test on new images
results = model.predict(source='test_images/', save=True)

# Confusion matrix
from ultralytics.utils.plotting import plot_results
plot_results(results)
```

## Step 11: Export to CoreML

### Export Command

```python
from ultralytics import YOLO

# Load best weights
model = YOLO('runs/detect/veriable-v1/weights/best.pt')

# Export to CoreML
success = model.export(
    format='coreml',
    nms=True,           # Include NMS
    imgsz=640,          # Input size
    int8=False,         # Use FP16 for better accuracy
    half=True           # FP16 precision
)

print(f"CoreML model saved to: {success}")
```

### Output

This creates a `.mlpackage` or `.mlmodel` file optimized for iOS.

## Step 12: Integrate into Xcode

1. **Add Model to Project:**
   - Drag `.mlmodel` into Xcode
   - Check "Copy items if needed"
   - Add to target

2. **Verify Model:**
   - Click on `.mlmodel` in Xcode
   - Check inputs/outputs
   - Note model class name

3. **Use in Code:**
   ```swift
   import CoreML
   import Vision
   
   guard let model = try? VNCoreMLModel(for: YourModelName().model) else {
       return
   }
   ```

## Step 13: Optimize for Production

### Quantization (Optional)

```python
# Export with INT8 quantization for smaller size
model.export(
    format='coreml',
    int8=True,
    nms=True
)
```

### Model Pruning

```python
# Use YOLOv8n-pruned for even smaller size
model = YOLO('yolov8n-pruned.pt')
model.train(data='data.yaml', epochs=200)
```

## Troubleshooting

### Low Accuracy

- Increase dataset size
- Add more augmentation
- Train for more epochs
- Check label quality
- Balance class distribution

### Slow Inference

- Use YOLOv8n (nano) instead of larger models
- Reduce input size (320 instead of 640)
- Enable quantization
- Use GPU acceleration

### Model Too Large

- Use YOLOv8n
- Enable INT8 quantization
- Prune unnecessary layers
- Reduce input size

## Best Practices

1. **Start Small**: Begin with YOLOv8n
2. **Validate Often**: Check validation metrics
3. **Use Augmentation**: Improves generalization
4. **Save Checkpoints**: Keep best weights
5. **Version Control**: Track dataset and model versions
6. **Test on Device**: Verify performance on actual iOS device

## Resources

- [Ultralytics Docs](https://docs.ultralytics.com)
- [YOLOv8 Paper](https://arxiv.org/abs/2305.09972)
- [CoreML Guide](https://developer.apple.com/documentation/coreml)
- [Roboflow](https://roboflow.com) - Dataset management
- [CVAT](https://cvat.org) - Annotation tool
