//
//  LZSnackConcurrencyManager.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/16/25.
//


struct LZSnackConcurrencyManager {
    
    // 메인 진입점
    static func background<T>(
        _ operation: @escaping @Sendable () async throws -> T
    ) -> BackgroundTask<T> {
        return BackgroundTask(operation: operation)
    }
    
    // 결과값 없는 작업용
    static func background(
        _ operation: @escaping @Sendable () async throws -> Void
    ) -> BackgroundTask<Void> {
        return BackgroundTask(operation: operation)
    }
    
    
    /// MainActor에서 실행하고, 에러를 onError가 있으면 호출부에, 없으면 중앙 처리
    static func run(
        _ operation: @escaping @Sendable () async throws -> Void,
        onError: ((Error) -> Void)? = nil
    ) {
        Task { @MainActor in
            do {
                try await operation()
            } catch {
                if let onError = onError {
                    onError(error)
                } else {
                    AppErrorHandler.handle(error)
                }
            }
        }
    }

    /// T 인스턴스를 [weak] 캡처하고, 에러를 onError가 있으면 호출부에, 없으면 중앙 처리
    static func run<T: AnyObject>(
        _ target: T,
        operation: @escaping @Sendable (T) async throws -> Void,
        onError: ((Error) -> Void)? = nil
    ) {
        Task { @MainActor [weak target] in
            guard let target = target else { return }
            do {
                try await operation(target)
            } catch {
                if let onError = onError {
                    onError(error)
                } else {
                    AppErrorHandler.handle(error)
                }
            }
        }
    }
}

struct AppErrorHandler {
    /// 에러를 처리하는 중앙 메서드
    static func handle(_ error: Error) {
        // 1) 콘솔에 출력
        #if DEBUG
        print("🛑 AppError: \(error)")
        #endif
    }
}

// MARK: - 메서드 체이닝을 위한 BackgroundTask 클래스
class BackgroundTask<T> {
    private let operation: @Sendable () async throws -> T
    private var onSuccessHandler: (@Sendable (T) -> Void)?
    private var onErrorHandler: (@Sendable (Error) -> Void)?
    private var onFinallyHandler: (@Sendable () -> Void)?
    
    init(operation: @escaping @Sendable () async throws -> T) {
        self.operation = operation
    }
    
    // MARK: - 콜백 체이닝 메서드들
    
    @discardableResult
    func onSuccess(_ handler: @escaping @Sendable (T) -> Void) -> BackgroundTask<T> {
        self.onSuccessHandler = { result in
            Task { @MainActor in
                handler(result)
            }
        }
        return self
    }
    
    @discardableResult
    func onError(_ handler: @escaping @MainActor (Error) -> Void) -> BackgroundTask<T> {
        self.onErrorHandler = { error in
            Task { @MainActor in
                handler(error)
            }
        }
        return self
    }
    
    @discardableResult
    func onFinally(_ handler: @escaping @MainActor () -> Void) -> BackgroundTask<T> {
        self.onFinallyHandler = {
            Task { @MainActor in
                handler()
            }
        }
        return self
    }
    
    // MARK: - 자동 할당 메서드들
    
    @discardableResult
    func assignTo<Object: AnyObject>(
        _ keyPath: ReferenceWritableKeyPath<Object, T>,
        on object: Object
    ) -> BackgroundTask<T> {
        return onSuccess { [weak object] result in
            object?[keyPath: keyPath] = result
        }
    }
    
    @discardableResult
    func assignTo<Object: AnyObject>(
        _ keyPath: ReferenceWritableKeyPath<Object, T?>,
        on object: Object
    ) -> BackgroundTask<T> {
        return onSuccess { [weak object] result in
            object?[keyPath: keyPath] = result
        }
    }
    
    // MARK: - 실행 메서드
    
    @discardableResult
    func execute() -> BackgroundTask<T> {
        Task.detached {
            do {
                let result = try await self.operation()
                await MainActor.run {
                    self.onSuccessHandler?(result)
                    self.onFinallyHandler?()
                }
            } catch {
                await MainActor.run {
                    self.onErrorHandler?(error) ?? AppErrorHandler.handle(error)
                    self.onFinallyHandler?()
                }
            }
        }
        return self
    }
}

// MARK: - 자동 실행을 위한 편의 확장
extension BackgroundTask {
    
    // 체이닝이 끝나면 자동으로 실행되도록 하는 메서드들
    @discardableResult
    func run() -> BackgroundTask<T> {
        return execute()
    }
    
    // 가장 간단한 사용을 위한 메서드
    @discardableResult
    func start() -> BackgroundTask<T> {
        return execute()
    }
}



@MainActor
func publishValue<Value>(_ destination: inout Value, _ newValue: Value) {
    destination = newValue
}
