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
    
    var onSampleBuffer: ((CVPixelBuffer) -> Void)?
    
    var captureSession: AVCaptureSession {
        session
    }
    
    override init() {
        super.init()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
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
        session.beginConfiguration()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            session.commitConfiguration()
            throw CameraError.configurationFailed
        }
        
        guard let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else {
            session.commitConfiguration()
            throw CameraError.configurationFailed
        }
        session.addInput(input)
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        } else {
            session.commitConfiguration()
            throw CameraError.configurationFailed
        }
        session.commitConfiguration()
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if session.isRunning {
                session.stopRunning()
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        onSampleBuffer?(pixelBuffer)
    }
}
