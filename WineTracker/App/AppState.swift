import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
	@Published var currentPerson: Person?
}

