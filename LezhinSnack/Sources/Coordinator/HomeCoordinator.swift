//
//  HomeCoordinator.swift
//  LezhinSnack
//
//  Created by lwc on 9/19/25.
//

import UIKit
import Combine

final class HomeCoordinator {
  private let navigation: UINavigationController
  private let interactor: HomeViewerPrefetchInteractor
  private var bag = Set<AnyCancellable>()

  init(navigation: UINavigationController, interactor: HomeViewerPrefetchInteractor) {
    self.navigation = navigation
    self.interactor = interactor
  }

  func bind(_ vm: HomeViewModel) {
    print(" bind called once?", ObjectIdentifier(self))
    vm.playRequested
      .receive(on: RunLoop.main)
      .sink { [weak self] input in
          self?.showViewer(type: .mainViewer, playInput: input)
      }
      .store(in: &bag)
  }
    // AppCoordinator (또는 HomeCoordinator)
    func showViewer(type: ViewerType, playInput: PlayInput) {
        let route = ViewerRoute.main(playInput)
        if let vc = AppContext.container.resolve(ViewerViewController.self, arguments: type, route) {
            navigation.pushViewController(vc, animated: true)
        }
    }
}
