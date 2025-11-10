import SwiftUI






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
									HStack{
										Text("Password:")
											.font(.custom("Cochin-Bold",size:20))
										Text(currentPerson.wrappedPassword)
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
									invalidChange = newUsername == ""
									for person in persons {
										if person.wrappedUsername == newUsername {
											newUsernameTaken = true
										}
									}
									
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
								
								TextField("New Password",text:$newPassword)
									.textFieldStyle(.roundedBorder)
									.autocapitalization(.none)
									.disableAutocorrection(true)
									.font(.custom("Cochin", size:20))
									.offset(y:-50)
								Button("Change Password") {
									invalidChange = newPassword == ""
									if (!invalidChange) {
										if(newPassword != "") {
											currentPerson.setPassword(newPassword: newPassword)
											try? viewContext.save()
											newPassword = ""
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
					
					NavigationLink{
						ZStack{
							LinearGradient(colors: [ Color.lighterGray, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
								.ignoresSafeArea()
							
							
							Button("Log Out") {
								appState.currentPerson = nil
								appState.isAuthenticated = false
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
							appState.isAuthenticated = false
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
									if (persons.count != 0) {
										for person in persons {
											if (person != currentPerson) {
												if (person.wrappedPassword == passwordAttempt && person.wrappedUsername == usernameAttempt) {
													
													mergingAccount = person
													proposeDeletion = true
													
													
												}
												
											}
										}
										
										
									}
									if (!proposeDeletion) {
										logInFailure = true
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
			.toolbar {
				ToolbarItem(placement: .principal) {
					Text("Settings")
						.font(.custom("Cochin", size: 34))
						.foregroundColor(.accentColor)
				}
			}
		
		
		
    }
	
	private func deleteAccount(person: Person) {
		viewContext.delete(person)
		try? viewContext.save()
	}
	
}




