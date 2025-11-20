import SwiftUI

struct ScannerView: View {
    @StateObject private var viewModel = ScannerViewModel()
    @EnvironmentObject private var appState: AppState
    @State private var selectedDetection: ScannerViewModel.Detection?
    @State private var isShowingManualSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                cameraPreview
                detectionOverlay
                VStack {
                    header
                    Spacer()
                    detectionPanel
                }
                .padding()
            }
            .navigationTitle("Scan")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { appState.switchTab(.discover) }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: manualScan) {
                        Image(systemName: "barcode.viewfinder")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
        .sheet(isPresented: $isShowingManualSheet) {
            ManualScanView()
                .presentationDetents([.medium])
        }
        .alert(item: Binding.constant(viewModel.errorMessage == nil ? nil : AlertItem(message: viewModel.errorMessage!))) { item in
            Alert(title: Text("Scanner"), message: Text(item.message), dismissButton: .default(Text("OK")))
        }
    }
    
    private var cameraPreview: some View {
        CameraPreview(session: viewModel.session)
            .ignoresSafeArea()
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .padding(32)
            )
    }
    
    private var detectionOverlay: some View {
        GeometryReader { proxy in
            ForEach(viewModel.detections) { detection in
                boundingBox(for: detection, in: proxy.size)
                    .onTapGesture {
                        selectedDetection = detection
                    }
                    .animation(.easeInOut(duration: 0.3), value: detection.id)
            }
        }
    }
    
    private func boundingBox(for detection: ScannerViewModel.Detection, in size: CGSize) -> some View {
        let rect = detection.boundingBox
        let width = rect.width * size.width
        let height = rect.height * size.height
        let x = rect.midX * size.width
        let y = rect.midY * size.height
        
        return RoundedRectangle(cornerRadius: 16)
            .stroke(BrandColor.primary, lineWidth: 3)
            .background(RoundedRectangle(cornerRadius: 16).fill(BrandColor.primary.opacity(0.15)))
            .frame(width: width, height: height)
            .position(x: x, y: y)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(detection.name)
                        .font(.caption)
                        .foregroundColor(.white)
                    Text("Confidence \(Int(detection.confidence * 100))%")
                        .font(.caption2)
                        .foregroundColor(BrandColor.accent)
                }
                .padding(8)
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
                .padding(6)
            }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Smart Scanner")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundColor(.white)
            Text(viewModel.hintMessage)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var detectionPanel: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            if let detection = selectedDetection {
                VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                    Text(detection.name)
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundColor(.white)
                    Text("Confidence \(Int(detection.confidence * 100))%")
                        .foregroundColor(BrandColor.accent)
                    PrimaryButton(title: "Add to Cart") {
                        addDetectedItem(detection)
                    }
                }
            } else {
                Text("Tap a highlighted product to confirm or use manual scan.")
                    .foregroundColor(.white)
                PrimaryButton(title: "Manual Scan", action: manualScan)
            }
            
            HStack {
                Label("Items in cart", systemImage: "cart")
                    .foregroundColor(.white)
                Spacer()
                Text("\(appState.cartItems.count)")
                    .foregroundColor(.white)
            }
            .padding(.vertical, BrandSpacing.xs)
            .padding(.horizontal, BrandSpacing.md)
            .background(Color.white.opacity(0.1))
            .cornerRadius(BrandCornerRadius.medium)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: BrandCornerRadius.large))
    }
    
    private func addDetectedItem(_ detection: ScannerViewModel.Detection) {
        let product = placeholderProduct(for: detection)
        appState.addProductToCart(product)
    }
    
    private func placeholderProduct(for detection: ScannerViewModel.Detection) -> Product {
        switch detection.name.lowercased() {
        case "avocado":
            return Product(id: "scan-avocado", name: "Organic Avocado", description: "Fresh Hass avocado", price: 2.49, imageUrl: nil)
        case "milk carton":
            return Product(id: "scan-milk", name: "Whole Milk", description: "1 gallon carton", price: 3.59, imageUrl: nil)
        case "organic banana":
            return Product(id: "scan-banana", name: "Organic Bananas", description: "Sweet and ripe", price: 0.99, imageUrl: nil)
        default:
            return Product(id: detection.id.uuidString,
                           name: detection.name,
                           description: "Detected item",
                           price: 4.99,
                           imageUrl: nil)
        }
    }
    
    private func manualScan() {
        selectedDetection = nil
        viewModel.hintMessage = "Point your camera at the barcode"
        isShowingManualSheet = true
    }
}

private struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView()
            .environmentObject(AppState.mock)
    }
}
