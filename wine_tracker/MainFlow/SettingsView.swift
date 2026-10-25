import SwiftUI
import CoreData

struct SettingsView: View {
	@ObservedObject var currentPerson: Person
	@FetchRequest(sortDescriptors: []) var persons: FetchedResults<Person>
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject var appState: AppState

	@State var newUsername = ""
	@State var newEmail = ""
	@State var newFirst = ""
	@State var newLast = ""
	@State var newPassword = ""

	@State var newUsernameTaken = false
	@State var invalidChange = false

	@State var passwordAttempt = ""
	@State var usernameAttempt = ""

	@State var proposeDeletion = false

	@State var logInFailure = false
	@State var logInSuccess = false

	@State var mergingAccount: Person?
	@State private var biometricLoginOn = false

	@State var searchRequest: String = ""

    var body: some View {
			List {
					NavigationLink{
						ZStack{
							VStack{
								Text("Account Details")
									.font(.custom("Cochin", size: 34))
									.fontWeight(.bold)
									.padding(.top, 16)
									.padding(.bottom, 8)
									.frame(maxWidth: .infinity, alignment: .leading)
									.padding(.horizontal)
									.foregroundColor(Color.accentColor)
								List{
									HStack{
										Text("Username:")
											.font(.custom("Cochin-Bold",size:20))
										Text(currentPerson.wrappedUsername)
											.font(.custom("Cochin",size:20))
									}
									.padding(.top,5)
									HStack{
										Text("Name:")
											.font(.custom("Cochin-Bold",size:20))
										Text("\(currentPerson.wrappedFirstName), \(currentPerson.wrappedLastName)")
											.font(.custom("Cochin",size:20))
									}
									.padding(.top,5)
									HStack{
										Text("Email:")
											.font(.custom("Cochin-Bold",size:20))
										Text(currentPerson.wrappedEmail)
											.font(.custom("Cochin",size:20))
									}
									.padding(.top,5)
								}
							}
						}
					} label : {
						Text("View account details")
							.font(.custom("Cochin",size:20))
					}

					NavigationLink{
						ZStack{
							LinearGradient(colors: [ Color.lighterGray, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
								.ignoresSafeArea()

							VStack{
								Text("Change Username")
									.font(.custom("Cochin", size: 34))
									.fontWeight(.bold)
									.padding(.top, 16)
									.padding(.bottom, 8)
									.padding(.horizontal)
									.foregroundColor(Color.accentColor)
									.offset(y:-250)
									.popover(isPresented:$newUsernameTaken) {
										ZStack {
											RadialGradient(gradient: Gradient(colors: [Color.lighterGray, .white,Color.lighterGray,.white]), center: .center, startRadius: 140, endRadius: 300)

											VStack{
												HStack{
													Image(systemName: "x.circle.fill")
														.foregroundColor(Color.accentColor)
													Text("Username Taken")
												}
												Text("Please choose another username")

												Button("Dismiss") {
													newUsernameTaken = false
												}
												.buttonStyle(AccountButton())
											}
										}
									}
									.popover(isPresented:$invalidChange) {
										ZStack {
											RadialGradient(gradient: Gradient(colors: [Color.lighterGray, .white,Color.lighterGray,.white]), center: .center, startRadius: 140, endRadius: 300)

											VStack{
												HStack{
													Image(systemName: "x.circle.fill")
														.foregroundColor(Color.accentColor)
													Text("Invalid entry")
												}
												Text("Please provide a valid credential")

												Button("Dismiss") {
													invalidChange = false
												}
												.buttonStyle(AccountButton())
											}
										}
									}

								TextField("New Username",text:$newUsername)
									.textFieldStyle(.roundedBorder)
									.autocapitalization(.none)
									.disableAutocorrection(true)
									.font(.custom("Cochin", size:20))
									.offset(y:-50)
								Button("Change Username") {
									invalidChange = Person.normalizedUsername(newUsername) == ""
									newUsernameTaken = Person.isUsernameTaken(newUsername, in: viewContext)

									if(!invalidChange && !newUsernameTaken) {
										currentPerson.setUsername(newUsername: newUsername)
										try? viewContext.save()
										newUsername = ""
									}
								}
								.buttonStyle(AccountButton())
							}
						}
					} label: {
						Text("Edit account username")
							.font(.custom("Cochin",size:20))
					}

					NavigationLink{
						ZStack{
							LinearGradient(colors: [ Color.lighterGray, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
								.ignoresSafeArea()

							VStack{
								Text("Change Name")
									.font(.custom("Cochin", size: 34))
									.fontWeight(.bold)
									.padding(.top, 16)
									.padding(.bottom, 8)
									.padding(.horizontal)
									.foregroundColor(Color.accentColor)
									.offset(y:-250)
								TextField("New First Name",text:$newFirst)
									.textFieldStyle(.roundedBorder)
									.autocapitalization(.none)
									.disableAutocorrection(true)
									.font(.custom("Cochin", size:20))
									.offset(y:-50)
								TextField("New Last Name",text:$newLast)
									.textFieldStyle(.roundedBorder)
									.autocapitalization(.none)
									.disableAutocorrection(true)
									.font(.custom("Cochin", size:20))
									.offset(y:-50)
									.popover(isPresented:$invalidChange) {
										ZStack {
											RadialGradient(gradient: Gradient(colors: [Color.lighterGray, .white,Color.lighterGray,.white]), center: .center, startRadius: 140, endRadius: 300)

											VStack{
												HStack{
													Image(systemName: "x.circle.fill")
														.foregroundColor(Color.accentColor)
													Text("Invalid entry")
												}
												Text("Please provide a valid credential")

												Button("Dismiss") {
													invalidChange = false
												}
												.buttonStyle(AccountButton())
											}
										}
									}

								Button("Change Name") {
									invalidChange = (newFirst == "" && newLast == "")
									if(!invalidChange) {
										if(newFirst != "" && newLast != "") {
											currentPerson.setFirstName(newFirstName: newFirst)

											currentPerson.setLastName(newLastName: newLast)
											try? viewContext.save()
										}
										else if(newFirst != ""){
											currentPerson.setFirstName(newFirstName: newFirst)
											try? viewContext.save()
										}
										else if(newLast != "") {
											currentPerson.setLastName(newLastName: newLast)
											try? viewContext.save()
										}
										newFirst = ""
										newLast = ""
									}
								}
								.buttonStyle(AccountButton())
							}
						}
					} label: {
						Text("Edit account name")
							.font(.custom("Cochin",size:20))
					}

					NavigationLink{
						ZStack{
							LinearGradient(colors: [ Color.lighterGray, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
								.ignoresSafeArea()

							VStack{
								Text("Change Password")
									.font(.custom("Cochin", size: 34))
									.fontWeight(.bold)
									.padding(.top, 16)
									.padding(.bottom, 8)
									.padding(.horizontal)
									.foregroundColor(Color.accentColor)
									.offset(y:-250)
									.popover(isPresented:$invalidChange) {
										ZStack {
											RadialGradient(gradient: Gradient(colors: [Color.lighterGray, .white,Color.lighterGray,.white]), center: .center, startRadius: 140, endRadius: 300)

											VStack{
												HStack{
													Image(systemName: "x.circle.fill")
														.foregroundColor(Color.accentColor)
													Text("Invalid entry")
												}
												Text("Please provide a valid credential")

												Button("Dismiss") {
													invalidChange = false
												}
												.buttonStyle(AccountButton())
											}
										}
									}

								SecureInputView("New Password",text:$newPassword)
									.textFieldStyle(.roundedBorder)
									.autocapitalization(.none)
									.disableAutocorrection(true)
									.textContentType(.newPassword)
									.font(.custom("Cochin", size:20))
									.offset(y:-50)
								Button("Change Password") {
									invalidChange = !isValidPassword(newPassword)
									if (!invalidChange) {
										let password = newPassword
										newPassword = ""
										Task {
											invalidChange = !(await PasswordStore.save(password, for: currentPerson.accountID))
										}
									}
								}
								.buttonStyle(AccountButton())
							}
						}
					} label: {
						Text("Change password")
							.font(.custom("Cochin",size:20))
					}

					NavigationLink{
						ZStack{
							LinearGradient(colors: [ Color.lighterGray, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
								.ignoresSafeArea()

							VStack{
								Text("Change Email")
									.font(.custom("Cochin", size: 34))
									.fontWeight(.bold)
									.padding(.top, 16)
									.padding(.bottom, 8)
									.padding(.horizontal)
									.foregroundColor(Color.accentColor)
									.offset(y:-250)
									.popover(isPresented:$invalidChange) {
										ZStack {
											RadialGradient(gradient: Gradient(colors: [Color.lighterGray, .white,Color.lighterGray,.white]), center: .center, startRadius: 140, endRadius: 300)

											VStack{
												HStack{
													Image(systemName: "x.circle.fill")
														.foregroundColor(Color.accentColor)
													Text("Invalid entry")
												}
												Text("Please provide a valid credential")

												Button("Dismiss") {
													invalidChange = false
												}
												.buttonStyle(AccountButton())
											}
										}
									}

								TextField("New Email",text:$newEmail)
									.textFieldStyle(.roundedBorder)
									.autocapitalization(.none)
									.disableAutocorrection(true)
									.font(.custom("Cochin", size:20))
									.offset(y:-50)
								Button("Change Email") {
									invalidChange = !isValidEmail(email: newEmail)

									if(!invalidChange) {
										currentPerson.setEmail(newEmail: newEmail)
										try? viewContext.save()
										newEmail = ""
									}
								}
								.buttonStyle(AccountButton())
							}
						}
					} label: {
						Text("Change email")
							.font(.custom("Cochin",size:20))
					}

					if BiometricLogin.isAvailable {
						Toggle("Log in with \(BiometricLogin.biometryName)", isOn: $biometricLoginOn)
							.font(.custom("Cochin",size:20))
							.onChange(of: biometricLoginOn) { _, isOn in
								if isOn {
									biometricLoginOn = BiometricLogin.enable(for: currentPerson)
								} else {
									BiometricLogin.forget(accountID: currentPerson.accountID)
								}
							}
					}

					NavigationLink{
						ZStack{
							LinearGradient(colors: [ Color.lighterGray, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
								.ignoresSafeArea()

							Button("Log Out") {
								appState.currentPerson = nil
							}
							.font(.custom("Cochin",size:20))
							.buttonStyle(AccountButton())
						}
					} label: {
						Text("Log out of account")
							.font(.custom("Cochin",size:20))
					}

					NavigationLink {
						Button {
							appState.currentPerson = nil
							deleteAccount(person: currentPerson)
						} label :{Text("Delete")}.buttonStyle(AccountButton())
					} label : {
						Text("Delete account")
							.font(.custom("Cochin",size:20))
					}
					NavigationLink {
						ZStack{
							LinearGradient(colors: [ Color.lighterGray, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
								.ignoresSafeArea()

							VStack{
								Text("Merge Accounts")
									.font(.custom("Cochin", size: 34))
									.fontWeight(.bold)
									.padding(.top, 16)
									.padding(.bottom, 8)
									.padding(.horizontal)
									.foregroundColor(Color.accentColor)
									.offset(y:-250)
								TextField("Username", text:$usernameAttempt)
									.textFieldStyle(.roundedBorder)
									.autocapitalization(.none)
									.disableAutocorrection(true)
									.font(.custom("Cochin", size:20))
								SecureInputView("Password", text:$passwordAttempt)
									.textFieldStyle(.roundedBorder)
									.autocapitalization(.none)
									.disableAutocorrection(true)
									.font(.custom("Cochin", size:20))
									.popover(isPresented:$logInFailure) {
										ZStack {
											RadialGradient(gradient: Gradient(colors: [Color.lighterGray, .white,Color.lighterGray,.white]), center: .center, startRadius: 140, endRadius: 300)

											VStack{
												HStack{
													Image(systemName: "x.circle.fill")
														.foregroundColor(Color.accentColor)
													Text("Log in failure")
														.font(.custom("Cochin", size:20))
												}
												Text("Please check credentials")
													.font(.custom("Cochin", size:20))

												Button("Dismiss") {
													logInFailure = false
												}
												.buttonStyle(AccountButton())
												.font(.custom("Cochin", size:20))
											}
										}
									}

								Button ("Merge")  {
									let other = Person.withUsername(usernameAttempt, in: viewContext).flatMap { $0 == currentPerson ? nil : $0 }
									let password = passwordAttempt
									Task {
										if await PasswordStore.verify(password, for: other?.accountID), let other {
											mergingAccount = other
											proposeDeletion = true
										} else {
											logInFailure = true
										}
									}
								}
								.buttonStyle(AccountButton())
								.popover(isPresented:$proposeDeletion) {
									ZStack {
										RadialGradient(gradient: Gradient(colors: [Color.lighterGray, .white,Color.lighterGray,.white]), center: .center, startRadius: 140, endRadius: 300)

										VStack{
											Text("Delete other account in process?")
												.font(.custom("Cochin", size:20))

											HStack {
												Button("No") {
													if let merge = mergingAccount {
														for wine in merge.itemsArray {
															let newWine = Item(context: viewContext)
															newWine.setName(newName: wine.wrappedName)
															newWine.setDomain(newDomain: wine.wrappedDomain)
															newWine.setCreator(newCreator: wine.wrappedCreator)
															newWine.setQuantity(newQuantity: wine.wrappedQuantity)
															newWine.setDrank(newDrank: wine.wrappedDrank)
															newWine.edition = wine.wrappedEdition
															newWine.owner = currentPerson
															newWine.setType(newType: wine.wrappedType)
															newWine.setImageData(newImageData: wine.wrappedImageData)

															try? viewContext.save()
														}
														searchRequest = "s"
														searchRequest = ""
														currentPerson.updateCache(viewContext: viewContext)
													}

													proposeDeletion = false
												}
												.buttonStyle(AccountButton())
												.font(.custom("Cochin", size:20))
												Button("Yes") {
													if let merge = mergingAccount {
														for wine in merge.itemsArray {
															let newWine = Item(context: viewContext)
															newWine.setName(newName: wine.wrappedName)
															newWine.setDomain(newDomain: wine.wrappedDomain)
															newWine.setCreator(newCreator: wine.wrappedCreator)
															newWine.setQuantity(newQuantity: wine.wrappedQuantity)
															newWine.setDrank(newDrank: wine.wrappedDrank)
															newWine.edition = wine.wrappedEdition
															newWine.owner = currentPerson
															newWine.setType(newType: wine.wrappedType)
															newWine.setImageData(newImageData: wine.wrappedImageData)
														}
														merge.deleteCredentials()
														viewContext.delete(merge)
														try? viewContext.save()
														currentPerson.updateCache(viewContext: viewContext)
														searchRequest = "s"
														searchRequest = ""
													}

													proposeDeletion = false
												}
												.buttonStyle(AccountButton())
												.font(.custom("Cochin", size:20))
											}
										}
									}
								}
							}
						}
					} label : {
						Text("Merge accounts")
							.font(.custom("Cochin", size: 20))
					}
			}
			.navigationTitle("")
			.onAppear { biometricLoginOn = BiometricLogin.isEnabled(for: currentPerson) }
			.toolbar {
				ToolbarItem(placement: .principal) {
					Text("Settings")
						.font(.custom("Cochin", size: 34))
						.foregroundColor(.accentColor)
				}
			}
    }

	private func deleteAccount(person: Person) {
		person.deleteCredentials()
		viewContext.delete(person)
		try? viewContext.save()
	}
}

#Preview {
	NavigationStack {
		SettingsView(currentPerson: PersistenceController.previewPerson)
	}
	.previewEnvironment()
}
