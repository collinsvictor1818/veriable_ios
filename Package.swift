// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "Veriable",
  platforms: [
    .iOS(.v15),
    .macOS(.v13),
  ],
  products: [
    .library(name: "VeriableLib", targets: ["VeriableLib"])
  ],
  targets: [
    .target(
      name: "VeriableLib",
      path: ".",
      exclude: [
        "Veriable/VeriableApp.swift",
        "Features/Scanner/ObjectDetector.swift",
        "Features/Scanner/ObjectScannerView.swift",
        "Veriable/UIComponents/CameraPreview.swift",
        "Veriable.xcodeproj",
        "Tests",
        "Docs",
        "README.md",
        "SETUP.md",
        "CONTRIBUTING.md",
        ".git",
        ".gitignore",
        "buildServer.json",
      ],
      sources: [
        "Veriable/Domain",
        "Veriable/Data",
        "Veriable/Core",
        "Veriable/UIComponents",
        "Features",  // Features is at root
      ]
    ),
    .testTarget(
      name: "VeriableTests",
      dependencies: ["VeriableLib"],
      path: "Tests/VeriableTests"
    ),
  ]
)
