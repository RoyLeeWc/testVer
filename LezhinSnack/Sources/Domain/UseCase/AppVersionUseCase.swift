//
//  AppVersionUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/4/25.
//

protocol AppVersionUseCaseProtocol {
    /// 성공 시 SUCCESS만 통과. 그 외는 nil 반환(=통과 정책)
    func executeCheck(currentVersion: String) async throws -> AppVerCheckDTO?
}

final class AppVersionUseCase: AppVersionUseCaseProtocol {
    private let repo: AppVersionRepositoryProtocol
    init(repo: AppVersionRepositoryProtocol) { self.repo = repo }

    func executeCheck(currentVersion: String) async throws -> AppVerCheckDTO? {
        let dto = try await repo.check(parameters: ["version": currentVersion])
        // 서버 정책: 성공 코드만 유효, 아니면 nil로 내려 상위에서 무시(통과)
        guard dto.responseCode == APIResultType.success else { return nil }
        return dto
    }
}
