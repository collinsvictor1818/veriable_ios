import AVFoundation

enum CameraError: Error {
    case configurationFailed
    case unauthorized
}

final class CameraService: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "CameraService.SessionQueue")
    private let videoOutput = AVCaptureVideoDataOutput()
    private let videoOutputQueue = DispatchQueue(label: "CameraService.VideoOutputQueue")
    
    private var currentPosition: AVCaptureDevice.Position = .back

    private func device(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        #if targetEnvironment(simulator)
        // In the simulator, fall back to the default video device (e.g., your Mac's camera)
        return AVCaptureDevice.default(for: .video)
        #else
        // On device, prefer a wide-angle camera at the requested position; fall back to any video device
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) ?? AVCaptureDevice.default(for: .video)
        #endif
    }
    
    var onSampleBuffer: ((CVPixelBuffer) -> Void)?
    
    var captureSession: AVCaptureSession {
        session
    }
    
    override init() {
        super.init()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
        
        #if !targetEnvironment(simulator)
        if AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) == nil,
           AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil {
            currentPosition = .front
        }
        #endif
    }
    
    func requestAuthorizationStatus() async -> AVAuthorizationStatus {
        await withCheckedContinuation { continuation in
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized, .restricted, .denied:
                continuation.resume(returning: AVCaptureDevice.authorizationStatus(for: .video))
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted ? .authorized : .denied)
                }
            @unknown default:
                continuation.resume(returning: .denied)
            }
        }
    }
    
    func configureSession() throws {
        sessionQueue.sync { // Use sync to ensure configuration is complete before returning
            session.beginConfiguration()
            session.sessionPreset = .high
            
            // 💡 --- START OF CHANGES --- 💡
            // Choose device based on the currentPosition, with platform-appropriate fallbacks
            guard let captureDevice = device(for: currentPosition) else {
                session.commitConfiguration()
                return
            }
            // 💡 --- END OF CHANGES --- 💡
            
            // Use the new 'captureDevice' variable
            guard let input = try? AVCaptureDeviceInput(device: captureDevice), session.canAddInput(input) else {
                session.commitConfiguration()
                return
            }
            session.addInput(input)
            
            if let connection = videoOutput.connection(with: .video) {
                if connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = (currentPosition == .front)
                }
            }
            
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            } else {
                session.commitConfiguration()
                return
            }
            session.commitConfiguration()
        }
        // Check if session is configured properly
        if !session.inputs.isEmpty && !session.outputs.isEmpty {
            return // Success
        } else {
            throw CameraError.configurationFailed // Throw error if setup failed
        }
    }

    func toggleCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            let newPosition: AVCaptureDevice.Position = (self.currentPosition == .back) ? .front : .back
            self.setCameraPosition(newPosition)
        }
    }

    func setCameraPosition(_ position: AVCaptureDevice.Position) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard self.currentPosition != position else { return }

            self.session.beginConfiguration()

            // Remove existing video inputs
            for input in self.session.inputs {
                if let deviceInput = input as? AVCaptureDeviceInput, deviceInput.device.hasMediaType(.video) {
                    self.session.removeInput(deviceInput)
                }
            }

            // Select new device
            guard let newDevice = self.device(for: position),
                  let newInput = try? AVCaptureDeviceInput(device: newDevice),
                  self.session.canAddInput(newInput) else {
                // Revert configuration if we cannot switch
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(newInput)

            // Ensure output is present
            if self.session.outputs.contains(self.videoOutput) == false {
                if self.session.canAddOutput(self.videoOutput) {
                    self.session.addOutput(self.videoOutput)
                    self.videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                }
            }

            // Update mirroring for front camera
            if let connection = self.videoOutput.connection(with: .video), connection.isVideoMirroringSupported {
                connection.isVideoMirrored = (position == .front)
            }

            self.session.commitConfiguration()
            self.currentPosition = position
        }
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        onSampleBuffer?(pixelBuffer)
    }
}

