//
//  ListMoviesUI.swift
//  UpComingMoviesKMM
//
//  Created by Felipe Menezes on 24/01/22.
//  Copyright © 2023 FMMobile. All rights reserved.
//

import SwiftUI
import shared

@available(iOS 15.0, *)
struct ListMoviesUIView: View {
    @StateObject var viewModel = ListUIViewModel()
    @State private var isLast = false
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.movies, id: \.id) { movie in
                    NavigationLink {
                        Text(movie.overview)
                            .padding(24.0)
                    } label: {
                        let rowModel = MovieRowUIViewModel(movie: movie)
                        MovieRowUI(rowModel: rowModel)
                    } .onAppear {
                        isLast = viewModel.movies.last == movie
                        if isLast {
                            Task { try? await loadMore() }
                        }
                    }
                }.listStyle(.plain)
                if isLast {
                    ProgressView()
                }
            }.navigationTitle(viewModel.title)
            .onAppear {
                Task { try? await loadMovies() }
            }
            .refreshable {
                try? await refresh()
            }
        }
    }
}

@available(iOS 15.0, *)
extension ListMoviesUIView {
    func titleForView() -> String? {
        return viewModel.title
    }

    private func loadMovies() async throws {
        viewModel.forwardPage()
        try await viewModel.moviesList()
    }

    private func refresh() async throws {
        viewModel.resetPage()
        try await loadMovies()
    }

    // MARK: Scrolling Load
    private func loadMore() async throws {
         viewModel.forwardPage()
         try await loadMovies()
    }
}
@available(iOS 15.0, *)
struct ListMoviesUIView_Previews: PreviewProvider {
    static var previews: some View {
        ListMoviesUIView(viewModel: ListUIViewModel())
    }
}
