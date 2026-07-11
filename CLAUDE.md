# Routee iOS Project Guide

## Goal
Build the Routee MVP: record hiking routes, attach photos to route points, and create/share hiking recap images.
Prefer simple, shippable UIKit code over abstraction-heavy architecture.

## Stack
- Swift 6
- UIKit
- iOS 17+
- SnapKit
- NMapsMap
- Alamofire
- Swift Concurrency
- Combine only for continuous event streams or existing bindings

## Project Style
- Use programmatic UIKit only.
- Use SnapKit for all Auto Layout code.
- Do not use deprecated APIs.
- Prefer `final` classes.
- Default access level is `private`.
- Keep methods small and responsibility-focused.
- Use `// MARK: -` sections with one blank line above and below.
- Follow existing naming, folder structure, and conventions before introducing new patterns.
- Do not add dependencies unless clearly necessary.

## Architecture
Use a lightweight layered structure:

`ViewController/ViewModel -> Repository -> NetworkService -> Endpoint -> Alamofire`

Responsibilities:
- ViewController: rendering, user input, navigation, binding.
- View: reusable UI, layout, visual state only.
- ViewModel: screen state and presentation logic when needed.
- Repository: domain-level data access.
- NetworkService: request execution and decoding.
- Endpoint: path, method, headers, parameters.
- DTO: API payload only.

Rules:
- ViewController/ViewModel must not call `AF`, `Endpoint`, `NetworkService`, or `TokenManager` directly.
- Avoid Clean Architecture layers, protocols, factories, or use cases unless they solve a current problem.
- Do not create a ViewModel for static or trivial screens.

## Networking
- Use `async/await` as the default API style.
- Decode with `Decodable` and `serializingDecodable`.
- Use the shared `BaseResponse<T>` format.
- Send dates as ISO 8601 UTC strings.
- Send `TimeZone.current.identifier` only when the API requires timezone context.
- Centralize authentication and token refresh in an Alamofire interceptor.
- Never log access tokens, refresh tokens, authorization codes, or personal location data.

## Error Handling
- Use typed errors.
- Convert transport, HTTP, decoding, server, and authentication failures into project errors.
- UI decides how errors are displayed.
- Do not silently ignore errors with empty `catch` blocks.

## Concurrency
- UI state mutations must run on `@MainActor`.
- Prefer structured concurrency: `async let`, task groups, and child tasks.
- Avoid unstructured `Task` unless bridging from synchronous UIKit callbacks.
- Support cancellation for long-running network, image, and location operations.
- Do not use `DispatchQueue.main.async` when actor isolation solves the same problem.

## UIKit
- Separate layout from behavior.
- A custom `UIView` owns subviews, layout, styling, and visual state updates.
- A `UIViewController` owns lifecycle, navigation, user actions, permissions, and orchestration.
- Use delegation or closures for reusable view events.
- Capture `self` weakly only where a retained closure can create a cycle.
- Reuse existing UI components and design tokens before creating new ones.

## Map and Location
- Use WGS84 coordinates: latitude and longitude.
- Store route points as raw coordinates, not rendered images.
- Preserve server-provided `trackPointIndex` ordering.
- A photo capture must save the current route coordinate.
- Filter invalid points using timestamp, horizontal accuracy, distance, and speed.
- Avoid saving duplicate or noisy coordinates.
- Render the live route locally with a map path overlay.
- Fit the camera to all route coordinates when recording ends.
- Do not upload every location point individually unless real-time sharing is required.
- Prefer local buffering and batch upload after completion or at safe checkpoints.
- Never block the main thread with route processing or image rendering.

## Recap Image
- Treat map background, route overlay, photos, and text as separate layers.
- Generate recap output from stored coordinates and metadata.
- Do not use a saved route PNG as the source of truth.
- Keep rendering deterministic so the same data can reproduce the same recap.

## Security and Privacy
- Store server access and refresh tokens in Keychain.
- Do not persist Apple identity tokens after server authentication.
- Request the minimum location and photo permissions required.
- Explain permission purpose before system prompts when UX requires it.
- Avoid exposing precise user routes in logs, analytics, screenshots, or fixtures.

## Testing
Prioritize tests for:
- coordinate filtering
- route ordering
- distance/time calculations
- DTO decoding
- repository error mapping
- recap coordinate-to-point conversion

Do not add low-value tests for simple UIKit layout code.

## Change Rules
Before editing:
1. Read nearby files and follow existing patterns.
2. Identify the smallest valid change.
3. Reuse current abstractions.

After editing:
1. Check compile errors and actor isolation.
2. Check optionals, bounds, retain cycles, and cancellation.
3. Remove dead code, debug prints, unused imports, and duplicated logic.
4. Summarize changed files, behavior, and remaining risks briefly.

## Response Rules
- Answer in Korean.
- Be concise and implementation-focused.
- Show only the code needed for the requested change.
- Do not rewrite unrelated files.
- Do not invent missing project types or APIs; inspect the codebase first.
- When multiple solutions exist, recommend one and state the trade-off briefly.
- Point out architecture, concurrency, memory, security, or MVP-scope problems directly.
