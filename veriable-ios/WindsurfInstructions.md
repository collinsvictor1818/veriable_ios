# Windsurf Instructions

This repository contains the Veriable Retail iOS application. The following rules keep the codebase cohesive and the developer experience smooth when working with Windsurf or any other AI-assisted editor.

## Architecture
1. **UI Layer (Features + UIComponents)**
   - Built with SwiftUI following MVVM.
   - Views declare bindings and rely on `ObservableObject` view models.
   - View models never import SwiftUI.
2. **Domain Layer**
   - Defines `Entities` (Codable models) and `UseCases` (single responsibility business logic).
   - All dependencies are injected via protocols.
3. **Data Layer**
   - `API`, `Storage`, and `Repositories` abstractions implement the protocols consumed by use cases.
   - Networking relies on `async/await` and decodable responses.
4. **Core Layer**
   - Provides global state, dependency graph (`AppEnvironment`), logging, and error handling utilities.

## Coding Guidelines
1. **Swift Concurrency**: Prefer `async/await` over completion handlers. Wrap shared mutable state inside actors (see `CartStore`).
2. **Dependency Injection**: Use initializer injection with protocol types. No singletons except for SwiftUI `@StateObject` roots.
3. **Error Handling**: Throw typed errors (`AppError`) and surface user-facing messages via `UserFacingError` conformance.
4. **Logging**: Use `LoggerService` for diagnostics with meaningful categories.
5. **Styling**: Follow SwiftLint defaults, no trailing whitespace, limit line length to 120.

## File Organization
```
Core/
Domain/
Data/
Features/
UIComponents/
Tests/
```
Create new files inside the correct feature or layer. Avoid cross-layer imports that break the Clean Architecture boundaries.

## Testing
- Unit tests live under `Tests/Unit` and mirror the folder structure of the production code.
- UI tests go under `Tests/UITests` and leverage `XCTest` + `ViewInspector` (if added later) or snapshot tools.
- Every new ViewModel or UseCase must include a focused test covering success and failure paths.

## Accessibility & Theming
- Support Dynamic Type by using system fonts and scalable components.
- Ensure color choices work in both Light and Dark modes; prefer semantic colors.

## Pull Request Checklist
1. Run SwiftLint.
2. Execute unit and UI tests with the current Xcode version.
3. Update documentation/diagrams if architecture changes.
4. Add preview updates for new SwiftUI components.

Following these steps keeps the project production-ready and editor-friendly. Happy shipping!
