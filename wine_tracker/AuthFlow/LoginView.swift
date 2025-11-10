import SwiftUI




struct LoginView: View {
	
	// User-Entered Login details
	@State var UsernameAttempt = ""
	@State var PasswordAttempt = ""
	
	// Login Status
	@State var isCredentialsWrong = false
	@State var isLoginSuccessful = false
	@State var currentPerson = Person()
	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(sortDescriptors: []) var persons: FetchedResults<Person> // Device-Stored Accounts
	@EnvironmentObject var appState: AppState
	
	
    var body: some View {
        
		ZStack {
			
			// Background
			LinearGradient(colors: [Color.lighterGray,.white], startPoint: .topLeading, endPoint: .bottomTrailing)
				.ignoresSafeArea()
			
			
			VStack {
				
				Image(systemName:"person.circle.fill")
					.resizable()
					.frame(width:100,height:100)
					.foregroundColor(Color.accentColor)
					.padding(30)
				
				TextField("Username", text:$UsernameAttempt)
					.textFieldStyle(.roundedBorder)
					.autocapitalization(.none)
					.disableAutocorrection(true)
					.font(.custom("Cochin", size:20))
				
				
				SecureInputView("Password", text:$PasswordAttempt)
					.textFieldStyle(.roundedBorder)
					.autocapitalization(.none)
					.disableAutocorrection(true)
					.font(.custom("Cochin", size:20))
					.popover(isPresented:$isLoginSuccessful) {
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
									isLoginSuccessful = false
									
								}
								.buttonStyle(GreenButton())
								
							}
						}
					}
				
				
				 // Display message if login credentials are incorrect
				.popover(isPresented:$isCredentialsWrong) {
					
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
								isCredentialsWrong = false
							}
							.buttonStyle(AccountButton())
							.font(.custom("Cochin", size:20))
							
						}
					}
				}
				
				
				
				
				
				
				
				Button ("Log In")  {
					
					for person in persons {
						
						if (person.wrappedUsername == UsernameAttempt && person.wrappedPassword == PasswordAttempt) {
							appState.currentPerson = person
							appState.isAuthenticated = true
							isLoginSuccessful = true
							return
						}
						
					}
					
					if (!isLoginSuccessful) {
						isCredentialsWrong = true
					}
					
					
					
					
					
					
				}
				.buttonStyle(AccountButton())
				.font(.custom("Cochin", size:20))
				
				
				
			}
			
		}
		
		
		
		
    }
}

#Preview {
    LoginView()
		.environmentObject(AppState())
}
