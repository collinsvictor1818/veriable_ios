import SwiftUI
import AVFoundation

struct ObjectScannerView: View {
    @StateObject private var vm = ScannerViewModel()
    let onAddToCart: (ScannerViewModel.Detection) -> Void
    
    var body: some View {
        ZStack {
            CameraPreview(session: vm.session)
                .ignoresSafeArea()
            
            // Detection Boxes
            ForEach(vm.detections) { detection in
                DetectionBox(detection: detection)
                    .onTapGesture {
                        onAddToCart(detection)
                    }
            }
            
            // UI Controls and Info
            VStack {
                // Top controls (Camera Switcher & Flashlight)
                HStack {
                    Spacer()
                    
                    // Flashlight Button
                    Button {
                        vm.toggleFlashlight()
                    } label: {
                        Image(systemName: vm.isFlashlightOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.title2)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    
                    // Camera Switcher Button
                    Button {
                        vm.switchCamera()
                    } label: {
                        Image(systemName: "camera.rotate.fill")
                            .font(.title2)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top)
                
                Spacer()
                
                // Hint Message
                Text(vm.hintMessage)
                    .padding(12)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 40)
            }
        }
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }
}

// DetectionBox and other structs remain the same...

struct DetectionBox: View {
    let detection: ScannerViewModel.Detection
    
    var body: some View {
        GeometryReader { geo in
            let rect = CGRect(
                x: detection.boundingBox.minX * geo.size.width,
                y: (1 - detection.boundingBox.maxY) * geo.size.height,
                width: detection.boundingBox.width * geo.size.width,
                height: detection.boundingBox.height * geo.size.height
            )
            
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                
                Text("\(detection.name) \(Int(detection.confidence * 100))%")
                    .padding(4)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .offset(x: 0, y: -22)
            }
            .position(x: rect.midX, y: rect.midY)
        }
    }
}
