import SwiftUI

struct RecentScansView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationView {
            List {
                if appState.scanHistory.isEmpty {
                    Text("No recent scans available.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(appState.scanHistory) { record in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.productName)
                                .font(.headline)
                            HStack(spacing: 8) {
                                if let conf = record.confidence {
                                    Text("Confidence: \(Int(conf * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Text(record.recordedAt, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(record.recordedAt, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Recent Scans")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") { dismiss() }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    RecentScansView()
        .environmentObject(AppState.mock)
}
#endif
