import SwiftUI

struct SignUpView: View {
	
	@State var currentPerson = Person()
	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(sortDescriptors: []) var persons: FetchedResults<Person> // Device-Stored Accounts
	
	// User-Entered Signup details
	@State var email: String = ""
	@State var username: String = ""
	@State var password: String = ""
	@State var firstName: String = ""
	@State var lastName: String = ""
	
	// Signup Status
	@State var isSignupSuccessful = false
	@State var isEntriesInvalid = false
	@State var isUsernameTaken = false
	
	
    var body: some View {
        
		ZStack{
			
			// Background
			LinearGradient(colors: [Color.lighterGray,.white], startPoint: .topLeading, endPoint: .bottomTrailing)
				.ignoresSafeArea()
			
			VStack {
				
				Image(systemName:"person.circle.fill")
					.resizable()
					.frame(width:100,height:100)
					.foregroundColor(Color.accentColor)
					.padding(30)
				
				HStack {
					
					TextField("First Name", text: $firstName)
						.textFieldStyle(.roundedBorder)
						.autocapitalization(.none)
						.disableAutocorrection(true)
						.font(.custom("Cochin", size:20))
					
					TextField("Last Name", text: $lastName)
						.textFieldStyle(.roundedBorder)
						.autocapitalization(.none)
						.disableAutocorrection(true)
						.font(.custom("Cochin", size:20))
					
				}
				
				
				TextField("Email", text:$email)
					.textFieldStyle(.roundedBorder)
					.autocapitalization(.none)
					.disableAutocorrection(true)
					.font(.custom("Cochin", size:20))
				
				TextField("Username", text:$username)
					.textFieldStyle(.roundedBorder)
					.autocapitalization(.none)
					.disableAutocorrection(true)
					.font(.custom("Cochin", size:20))
					.textContentType(.username)
				
				SecureInputView("Password", text:$password)
					.textFieldStyle(.roundedBorder)
					.autocapitalization(.none)
					.disableAutocorrection(true)
					.font(.custom("Cochin", size:20))
					.textContentType(.password)
				
				// Display message if signup was successful
					.popover(isPresented:$isSignupSuccessful) {
						ZStack {
							RadialGradient(gradient: Gradient(colors: [Color.lighterGray, .white,Color.lighterGray,.white]), center: .center, startRadius: 140, endRadius: 300)
							
							VStack{
								HStack{
									Image(systemName: "checkmark.circle.fill")
										.foregroundColor(Color.darkGreen)
									Text("Account succesfully made")
									
								}
								Text("Please log in")
								
								Button("Dismiss") {
									isSignupSuccessful = false
									
								}
								.buttonStyle(GreenButton())
								
							}
						}
					}
				
				// Display message if one or more entries were invalid
					.popover(isPresented:$isEntriesInvalid) {
						ZStack {
							RadialGradient(gradient: Gradient(colors: [Color.lighterGray, .white,Color.lighterGray,.white]), center: .center, startRadius: 140, endRadius: 300)
							
							VStack{
								HStack{
									Image(systemName: "x.circle.fill")
										.foregroundColor(Color.accentColor)
									Text("Invalid field entries")
									
								}
								
								Text("credentials have to be at least two characters ")
								Text("and email needs to be valid")
								
								Button("Dismiss") {
									isEntriesInvalid = false
								}
								.buttonStyle(AccountButton())
								
							}
						}
					}
				
				// Display message if username is already used by another account
					.popover(isPresented:$isUsernameTaken) {
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
									isUsernameTaken = false
								}
								.buttonStyle(AccountButton())
								
							}
						}
					}
				
				
				
				Button("Make Account") {
					
					
					if (isValidField(text:$firstName.wrappedValue) && isValidField(text:$lastName.wrappedValue) && isValidEmail(email: $email.wrappedValue)) {
						
						for person in persons {
							if (person.wrappedUsername == username) {
								isUsernameTaken = true
							}
						}
						if (!isUsernameTaken) {
							// Create account
							let newAccount = Person(context: viewContext)
							newAccount.setUsername(newUsername: username)
							newAccount.setPassword(newPassword: password)
							newAccount.setFirstName(newFirstName: firstName)
							newAccount.setLastName(newLastName: lastName)
							newAccount.setEmail(newEmail: email)
							try? viewContext.save()
							isSignupSuccessful = true
							
						}
						
						
					}
					
					else {
						isEntriesInvalid = true
					}
					
					
					
					
					
					
					
				}
				.buttonStyle(AccountButton())
				.font(.custom("Cochin", size:20))
				
				
				
			}
		}
		
		
		
		
    }
}

#Preview {
    SignUpView()
}
