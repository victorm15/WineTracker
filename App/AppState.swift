import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
	@Published var isAuthenticated = false
	@Published var currentPerson: Person?
}

