//
//  SearchView.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/08.
//

import SwiftUI

struct VisionsView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var viewModel: VisionsViewModel

    var body: some View {
        ZStack {
            LinearGradient(colors: [settings.firstColor.opacity(0.3), settings.secondColor.opacity(0.5)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()

            VStack {
                NavigationView {
                    List {
                        ForEach(viewModel.visions) { vision in
                            VStack(alignment: .leading) {
                                Text(vision.title)
                                    .font(.headline)
                                Text(vision.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(vision.createdAt, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 5)
                        }
                        .onDelete(perform: viewModel.confirmDelete) // スワイプ時に確認アラート
                    }
                    .navigationTitle("Visions")
                    .navigationBarItems(trailing: NavigationLink(destination: SetVisionView()) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    })
                    .onAppear {
                        viewModel.fetchVisions()
                    }
                }
            }
        }
        .safeAreaInset(edge: .top) { Color.clear.frame(height: 0) } // SafeAreaを明示
        .alert("本当に削除しますか？", isPresented: $viewModel.showingAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                if let selectedVision = viewModel.selectedVision {
                    viewModel.deleteVisionFromList(selectedVision)
                }
            }
        } message: {
//            Text(selectedVision?.title ?? "選択されたビジョンがありません")
            Text("\n\(viewModel.selectedVision?.title ?? "タイトルなし")\n説明：\(viewModel.selectedVision?.description ?? "説明なし")\n")
        }
    }
}
