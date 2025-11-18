import SwiftUI





struct AccountView: View {
	@ObservedObject var currentPerson: Person
	
	var body: some View {
		
		
		List {
					
					HStack{
						
						Text("Total recorded bottles:")
							.font(.custom("Cochin",size:20))
						
						Text("\(currentPerson.getTotalWineCount()+currentPerson.getTotalDrank())")
							.font(.custom("Cochin",size:50))
							.foregroundColor(Color.accentColor)
						
						
					}
					HStack{
						Text("Total unopened bottles:")
							.font(.custom("Cochin",size:20))
						Text("\(currentPerson.getTotalWineCount())")
							.font(.custom("Cochin",size:50))
							.foregroundColor(Color.accentColor)
						
						
					}
					HStack{
						Text("Total drank bottles:")
							.font(.custom("Cochin",size:20))
						Text("\(currentPerson.getTotalDrank())")
							.font(.custom("Cochin",size:50))
							.foregroundColor(Color.accentColor)
						
						
					}
//				}
			
			}
		.navigationTitle("")
		.toolbar {
			ToolbarItem(placement: .principal) {
				Text("Account Statistics")
					.font(.custom("Cochin", size: 34))
					.foregroundColor(.accentColor)
			}
		}
	}
}
