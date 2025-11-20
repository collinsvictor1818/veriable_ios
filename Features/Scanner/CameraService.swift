import AVFoundation
import Foundation
import SwiftUI
import Combine // 💡 FIX: Import Combine for @Published and ObservableObject

// Define errors specific to the camera service
enum CameraServiceError: Error {
    case invalidInput
    case missingCaptureDevice
    case torchNotAvailable
    case configurationFailed
}

final class CameraService: NSObject, ObservableObject {

    let captureSession = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    
    // Published properties for the ViewModel to observe
    @Published var isFlashlightOn: Bool = false
    @Published var currentPosition: AVCaptureDevice.Position = .back // Start with the back camera

    var onSampleBuffer: ((CVPixelBuffer) -> Void)?
    
    private var currentInput: AVCaptureDeviceInput?
    private var currentDevice: AVCaptureDevice?

    func requestAuthorizationStatus() async -> AVAuthorizationStatus {
        await AVCaptureDevice.requestAccess(for: .video)
        return AVCaptureDevice.authorizationStatus(for: .video)
    }

    func configureSession() throws {
        // Start with the initial setup (back camera)
        try setupDeviceInput(position: .back)
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        // Remove existing outputs if necessary
        if captureSession.outputs.isEmpty {
            output.setSampleBufferDelegate(self, queue: .global())
            output.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            } else {
                throw CameraServiceError.configurationFailed
            }
        }
        
        captureSession.commitConfiguration()
    }
    
    /// Helper to find a device and set it as the session input
    private func setupDeviceInput(position: AVCaptureDevice.Position) throws {
        captureSession.beginConfiguration()
        
        // 1. Remove the existing input if one is present
        if let currentInput = currentInput {
            captureSession.removeInput(currentInput)
            self.currentInput = nil
        }
        
        // 2. Find the new device
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                     for: .video,
                                                     position: position)
        else {
            throw CameraServiceError.missingCaptureDevice
        }
        
        // 3. Create and add the new input
        let newInput = try AVCaptureDeviceInput(device: newDevice)
        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
            self.currentInput = newInput
              self.currentDevice = newDevice
            self.currentPosition = position // Update published position
        } else {
            throw CameraServiceError.invalidInput
        }
        
        // Ensure connection orientation is correct
        if let connection = output.connection(with: .video), connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
            // connection.automaticallyAdjustsVideoOrientation = true // ❌ FIX: This property is removed/deprecated
            connection.isVideoMirrored = position == .front
        }

        captureSession.commitConfiguration()
    }

    // MARK: - New Control Methods 📸

    func switchDevicePosition() async throws {
        stopTorch() // Always turn off the torch before switching
        
        let newPosition: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
        try setupDeviceInput(position: newPosition)
        
        // Restart the session if it was running, as configuration changes can stop it.
        if !captureSession.isRunning {
            startSession()
        }
    }

    func toggleTorch() async throws {
        guard let device = currentDevice, device.hasTorch else {
            throw CameraServiceError.torchNotAvailable
        }

        try device.lockForConfiguration()
        
        if device.isTorchActive {
            device.torchMode = .off
            isFlashlightOn = false
        } else {
            // Set torch intensity to max
            try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            isFlashlightOn = true
        }
        
        device.unlockForConfiguration()
    }
    
    private func stopTorch() {
        guard let device = currentDevice, device.isTorchActive else { return }
        try? device.lockForConfiguration()
        device.torchMode = .off
        device.unlockForConfiguration()
        isFlashlightOn = false
    }

    // MARK: - Session Lifecycle

    func startSession() {
        if !captureSession.isRunning {
            // Must be done on a background queue to prevent UI blocking
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        if captureSession.isRunning { captureSession.stopRunning() }
        stopTorch()
    }
}

// Delegate remains the same
extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
            
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        onSampleBuffer?(buffer)
    }
}
