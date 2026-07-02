# AGENTS.md

This guide is for AI coding agents and contributors working on the Routee iOS project.

## Project Overview

Routee-iOS is an iOS app built with UIKit and Swift. Keep changes small, readable, and aligned with the existing project structure.

Primary project path:

- `Routee-iOS/Routee-iOS.xcodeproj`
- App source: `Routee-iOS/Routee-iOS`

## General Rules

- Prefer simple UIKit patterns over introducing new architecture layers too early.
- Keep responsibilities separated, but do not over-engineer into full Clean Architecture unless the feature clearly needs it.
- Follow the existing folder structure and naming style.
- Do not commit local secrets, `.xcconfig` values, tokens, API keys, or generated build artifacts.
- `Config.xcconfig` must be used only as a build configuration file. Do not add it to `Copy Bundle Resources`.
- Avoid force unwraps. SwiftLint has `force_unwrapping` enabled.
- Keep SwiftLint warnings clean when practical.

## Agent Token Budget

Minimize token usage while preserving correctness.

- Start with targeted searches using `rg` or `rg --files`.
- Read only files that are directly relevant to the current task.
- Prefer small file excerpts over dumping entire files.
- Avoid repeating project architecture explanations unless the task asks for them.
- Summarize command output instead of pasting long logs.
- Do not inspect generated files, build products, or package caches unless they are directly relevant.
- When changing code, keep diffs focused on the requested behavior.
- In final responses, mention only the files changed, key decisions, and verification performed.
- If a task is ambiguous, ask one concise question or make a reasonable assumption and state it briefly.

## Architecture Direction

The project uses a lightweight layered structure, not strict Clean Architecture.

Expected flow:

```text
ViewController / ViewModel
-> Repository
-> NetworkService
-> EndPoint
-> Alamofire
-> BaseResponse<T>
-> DTO
```

### Presentation

View controllers and view models should handle UI state and user actions.

They should not:

- Build API URLs directly
- Call `DefaultNetworkService` directly
- Access token storage directly
- Know request header details

They should call repositories instead.

### Repository

Repositories own domain data flow.

Examples:

- `AuthRepository` handles login, logout, auto-login, token refresh, and token persistence.
- Future repositories such as `UserRepository` or `QuestRepository` should group feature-specific data operations.

Repositories may:

- Call `NetworkService`
- Call token/keychain storage
- Convert DTOs into app-facing models if needed

Repositories should not:

- Contain UIKit logic
- Render UI states
- Know view controller details

### NetworkService

`NetworkService` / `DefaultNetworkService` is the common HTTP client.

Responsibilities:

- Execute Alamofire requests
- Decode `BaseResponse<T>`
- Return the inner `T`
- Map common network errors
- Log request/response metadata safely

It should not:

- Save tokens
- Decide login state
- Contain feature-specific business rules
- Expose sensitive tokens in logs

### EndPoint

`EndPoint` defines API request metadata:

- `basePath`
- `path`
- `method`
- `headers`
- `queryParameters`
- `bodyParameters`
- `parameterEncoding`

Do not let `EndPoint` depend on UI state or token storage directly.

URL/config failures should be explicit. Avoid falling back to empty URLs or empty config values.

### DTO

DTOs represent server response shapes only.

Guidelines:

- Use `Decodable`.
- Use `Sendable` for response DTOs used across async boundaries.
- Keep DTOs free of UI logic and persistence logic.
- `BaseResponse<T>` is the common server response wrapper.

### Token Storage

Token storage should be abstracted behind a protocol such as `TokenManager` or `TokenStorage`.

Guidelines:

- Store access/refresh tokens in Keychain, not `UserDefaults`.
- Repository should be the main caller of token storage.
- Do not log access tokens, refresh tokens, Apple identity tokens, or authorization codes.

## Networking Review Checklist

When reviewing network-related changes, check:

- ViewModel calls Repository, not `NetworkService` directly.
- Repository owns login/token/auto-login flow.
- `NetworkService` only handles transport, decoding, and common errors.
- `EndPoint` only describes request metadata.
- `BaseResponse<T>` and DTO `Sendable` constraints are consistent.
- `Authorization`, Apple identity token, authorization code, and refresh token are not logged.
- Config lookup does not silently return `""` for required values.
- URL creation does not fall back to `URL(string: "")!`.
- Continuations are always resumed exactly once.
- Swift 6 concurrency warnings are not ignored.

## Swift Concurrency

The project may use Swift 6 concurrency checks.

Guidelines:

- Network DTOs should generally be `Decodable & Sendable`.
- Avoid capturing non-Sendable class instances inside `@Sendable` closures.
- If helper methods do not use instance state, prefer `static` methods and call them with `Self`.
- UI state updates should happen on the main actor.
- Network, DTO, repository, and persistence code should not be unnecessarily main-actor isolated.

## Logging

Use `RouteeLogger` for project logging.

## Config

Runtime config values come from `Info.plist` through build settings.

Important:

- Keep secret/local values in ignored `.xcconfig` files.
- Keep `Config.xcconfig` out of app bundle resources.

## SwiftLint

SwiftLint config lives at:

- `Routee-iOS/.swiftlint.yml`

Current expectations include:

- Sorted imports
- No force unwraps
- No excessive whitespace
- 100-character line warning
- 120-character line error

Prefer fixing warnings rather than disabling rules locally.

## Git Safety

- Do not revert unrelated user changes.
- Do not rewrite history unless explicitly asked.
- Do not run destructive git commands without explicit approval.
- Keep commits focused by feature or fix.

## Recommended Feature Flow

For a new API:

1. Add response DTO.
2. Add or extend feature `EndPoint`.
3. Add repository method.
4. Call repository from ViewModel.
5. Keep token/config/persistence details outside the ViewModel.
