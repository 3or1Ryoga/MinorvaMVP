//
//  VisionViewModel.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/08.
//

import Foundation
import SwiftUI

final class VisionsViewModel: ObservableObject {
    @Published var visions: [Vision] = []
    @Published var selectedVision: Vision? = nil
    @Published var showingAlert: Bool = false

    /// スワイプ削除の確認を行う
    func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            selectedVision = visions[index] // 選択したビジョンを格納
            showingAlert = true
        }
    }

    /// Firestore & リストから削除
    func deleteVisionFromList(_ vision: Vision) {
        if let currentUser = AuthManager.shared.getCurrentUser() {
            DatabaseManager.shared.deleteVision(for: currentUser.uid, visionId: vision.id) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.visions.removeAll { $0.id == vision.id } // ローカルリストから削除
                    }
                }
                print(error ?? "削除成功")
            }
        }
    }

    /// Firestore からビジョンを取得
    func fetchVisions() {
        if let currentUser = AuthManager.shared.getCurrentUser() {
            DatabaseManager.shared.fetchVisions(for: currentUser.uid) { fetchedVisions in
                DispatchQueue.main.async {
                    self.visions = fetchedVisions
                }
            }
        }
    }
}

