 import SwiftUI

struct ManualScanResult {
    let productName: String
    let quantity: Int
}

struct ManualScanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var code: String = ""
    @State private var quantity: Int = 1
    let onConfirm: (ManualScanResult) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Product or barcode", text: $code)
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)
                }
                Section {
                    Button("Confirm Item") {
                        onConfirm(ManualScanResult(productName: code, quantity: quantity))
                        dismiss()
                    }
                    .disabled(code.isEmpty)
                }
            }
            .navigationTitle("Manual Scan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: { dismiss() })
                }
            }
        }
    }
}

struct ManualScanView_Previews: PreviewProvider {
    static var previews: some View {
        ManualScanView(onConfirm: { _ in })
    }
}
