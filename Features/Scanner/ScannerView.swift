import SwiftUI
import AVFoundation

struct ScannerView: View {
    @State private var isScanning = false
    @State private var scannedCode: String?
    @State private var showAlert = false
    @State private var errorMessage = ""
    @State private var torchOn = false
    @State private var useFrontCamera = false
    @Environment(\.presentationMode) var presentationMode

    var onCodeScanned: ((String) -> Void)?
    var onDetections: (([YOLODetection]) -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Camera preview
            ScannerRepresentable(
                isScanning: $isScanning,
                scannedCode: $scannedCode,
                errorMessage: $errorMessage,
                useFrontCamera: $useFrontCamera,
                torchOn: $torchOn,
                onDetections: onDetections
            )
            .edgesIgnoringSafeArea(.all)
            
            // Overlay with transparent center
            GeometryReader { geometry in
                let centerRect = CGRect(
                    x: geometry.size.width * 0.15,
                    y: geometry.size.height * 0.3,
                    width: geometry.size.width * 0.7,
                    height: geometry.size.width * 0.7
                )
                
                // Semi-transparent overlay
                Path { path in
                    path.addRect(geometry.frame(in: .local))
                    path.addRoundedRect(
                        in: centerRect,
                        cornerSize: CGSize(width: 20, height: 20)
                    )
                }
                .fill(Color.black.opacity(0.6), style: FillStyle(eoFill: true))
                
                // Scanner frame
                RoundedRectangle(cornerRadius: 20)
                    .stroke(BrandColor.primary, lineWidth: 3)
                    .frame(width: centerRect.width, height: centerRect.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Scanner animation
                ScannerAnimationView()
                    .frame(width: centerRect.width - 10, height: 4)
                    .position(
                        x: geometry.size.width / 2,
                        y: isScanning ? centerRect.maxY - 5 : centerRect.minY + 5
                    )
                    .animation(
                        Animation.linear(duration: 2).repeatForever(autoreverses: false),
                        value: isScanning
                    )
            }
            
            // Top controls
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        useFrontCamera.toggle()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Button(action: {
                        torchOn.toggle()
                    }) {
                        Image(systemName: torchOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.top, 50)
                
                Spacer()
                
                Text("Position the barcode within the frame to scan")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            isScanning = true
        }
        .onDisappear {
            isScanning = false
            torchOn = false
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Scan Result"),
                message: Text(scannedCode ?? "No code found"),
                dismissButton: .default(Text("OK")) {
                    isScanning = true
                    scannedCode = nil
                }
            )
        }
        .onChange(of: scannedCode) { newValue in
            if let code = newValue {
                isScanning = false
                showAlert = true
                onCodeScanned?(code)
            }
        }
        .onChange(of: errorMessage) { newValue in
            if !newValue.isEmpty {
                showAlert = true
            }
        }
    }
}

// Removed toggleTorch(on:) method entirely

// MARK: - Scanner Animation View
struct ScannerAnimationView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.clear, BrandColor.accent, .clear]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Scanner Representable
struct ScannerRepresentable: UIViewControllerRepresentable {
    @Binding var isScanning: Bool
    @Binding var scannedCode: String?
    @Binding var errorMessage: String
    @Binding var useFrontCamera: Bool
    @Binding var torchOn: Bool
    var onDetections: (([YOLODetection]) -> Void)? = nil
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        if isScanning {
            uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
        uiViewController.setCameraPosition(useFrontCamera ? .front : .back)
        uiViewController.setTorch(on: torchOn)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ScannerViewDelegate {
        var parent: ScannerRepresentable
        
        init(_ parent: ScannerRepresentable) {
            self.parent = parent
        }
        
        func didFindCode(_ code: String) {
            parent.scannedCode = code
            parent.isScanning = false
        }
        
        func didFailWithError(_ error: Error) {
            parent.errorMessage = error.localizedDescription
        }
        
        func didDetectObjects(_ objects: [YOLODetection]) {
            parent.onDetections?(objects)
        }
    }
}

// MARK: - Scanner View Controller
protocol ScannerViewDelegate: AnyObject {
    func didFindCode(_ code: String)
    func didFailWithError(_ error: Error)
    func didDetectObjects(_ objects: [YOLODetection])
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: ScannerViewDelegate?

    private var currentPosition: AVCaptureDevice.Position = .back
    private var videoOutput: AVCaptureVideoDataOutput?
    private var yoloDetector: YOLODetector?
    private var isProcessingFrame = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            yoloDetector = try YOLODetector(modelName: "YOLO11n")
        } catch {
            delegate?.didFailWithError(error)
        }
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = device(for: currentPosition) else {
            delegate?.didFailWithError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No video capture device available"]))
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.didFailWithError(error)
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            delegate?.didFailWithError(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Could not add video input"]))
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                .upce, .code39, .code39Mod43, .code93, .code128,
                .ean8, .ean13, .aztec, .pdf417, .itf14, .dataMatrix, .qr
            ]
            
            // Add video data output for YOLO processing
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
            ]
            let queue = DispatchQueue(label: "camera.video.queue")
            videoOutput.setSampleBufferDelegate(self, queue: queue)
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
                self.videoOutput = videoOutput
            } else {
                delegate?.didFailWithError(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "Could not add video data output"]))
            }
        } else {
            delegate?.didFailWithError(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Could not add metadata output"]))
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    private func device(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        #if targetEnvironment(simulator)
        return AVCaptureDevice.default(for: .video)
        #else
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) ?? AVCaptureDevice.default(for: .video)
        #endif
    }
    
    func setCameraPosition(_ position: AVCaptureDevice.Position) {
        guard position != currentPosition else { return }
        captureSession.beginConfiguration()

        // Remove existing video inputs
        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput, deviceInput.device.hasMediaType(.video) {
                captureSession.removeInput(deviceInput)
            }
        }

        // Select new device and add input
        guard let newDevice = device(for: position),
              let newInput = try? AVCaptureDeviceInput(device: newDevice),
              captureSession.canAddInput(newInput) else {
            captureSession.commitConfiguration()
            return
        }
        captureSession.addInput(newInput)

        // Update mirroring for front camera if supported
        if let connection = (previewLayer?.connection ?? captureSession.connections.first), connection.isVideoMirroringSupported {
            connection.isVideoMirrored = (position == .front)
        }
        if let videoConnection = videoOutput?.connection(with: .video), videoConnection.isVideoMirroringSupported {
            videoConnection.isVideoMirrored = (position == .front)
        }

        captureSession.commitConfiguration()
        currentPosition = position
        // Torch will be reapplied by the representable update
    }

    func toggleCamera() {
        let newPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back
        setCameraPosition(newPosition)
    }
    
    func startScanning() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    func stopScanning() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func setTorch(on: Bool) {
        guard let deviceInput = captureSession?.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first else { return }
        let device = deviceInput.device
        guard device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else {
                return
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didFindCode(stringValue)
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard output === videoOutput,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let yoloDetector = yoloDetector,
              !isProcessingFrame else { return }
        
        isProcessingFrame = true
        Task {
            defer { isProcessingFrame = false }
            do {
                let detections = try await yoloDetector.detectObjects(in: pixelBuffer)
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didDetectObjects(detections)
                }
            } catch {
                // Swallow per-frame errors to avoid spamming
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

// MARK: - Preview
struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView()
            .preferredColorScheme(.dark)
    }
}
