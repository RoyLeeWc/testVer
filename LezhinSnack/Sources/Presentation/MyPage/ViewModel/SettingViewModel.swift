//
//  SettingViewModel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/21/25.
//

import Combine
import UIKit

final class SettingViewModel {
    
    
    @Published var isPushGrant: Bool?
    @Published var isMarketingGrant: Bool?
    
    func getPushSetting() {
        AppContext.shared.getPushPermissionsState { [weak self] isGranted in
            self?.isPushGrant = isGranted
        }
    }
    
    func getMarketingSetting() {
        
    }
    
    func moveToAppSetting() {
        guard
            let url = URL(string: UIApplication.openNotificationSettingsURLString),
            UIApplication.shared.canOpenURL(url)
        else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    
    
}
