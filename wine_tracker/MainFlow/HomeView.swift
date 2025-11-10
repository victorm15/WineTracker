import SwiftUI



struct HomeView: View {
	@ObservedObject var currentPerson: Person
    var body: some View {
	
		
		List {
			
			
			
			VStack {
				Text("Most owned wine")
					.font(.custom("Cochin", size: 20))
				if currentPerson.collectionLength()  {
					let wine = currentPerson.getMostOwned()
					VStack{
						HStack {
							Text("\(wine.wrappedName)")
								.font(.custom("Cochin-Bold",size:20))
							
							
							wine.wrappedImage
								.resizable()
								.frame(width:150,height:150)
						}
						HStack{
							Text("Creator:")
								.font(.custom("Cochin-Bold",size:20))
							Text(wine.wrappedCreator)
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Domain:")
								.font(.custom("Cochin-Bold",size:20))
							Text(wine.wrappedDomain)
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							if(wine.wrappedEdition.wrappedIsEdition) {
								Text("Vintage:")
									.font(.custom("Cochin-Bold",size:20))
							}
							else {
								Text("Edition:")
									.font(.custom("Cochin-Bold",size:20))
								
							}
							Text(String(wine.wrappedEdition.wrappedNumber))
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Type:")
								.font(.custom("Cochin-Bold",size:20))
							Text(wine.wrappedType)
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Unopened Bottles:")
								.font(.custom("Cochin-Bold",size:20))
							Text(String(wine.wrappedQuantity))
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Drank:")
								.font(.custom("Cochin-Bold",size:20))
							Text(String(wine.wrappedDrank))
								.font(.custom("Cochin", size: 20))
							
						}
						
						
						
						
						
						
						
						
						
						
						
						
						
						
					}
				}
				else {
					Text("Add a wine to the collection first.")
						.font(.custom("Cochin", size: 20))
						.foregroundStyle(.gray)
				}
			}
			
			
			
			
			
			VStack {
				Text("Favorite wine")
					.font(.custom("Cochin", size: 20))
				if currentPerson.collectionLength() {
					let wine = currentPerson.getFavoriteOwned()
					VStack{
						HStack {
							Text("\(wine.wrappedName)")
								.font(.custom("Cochin-Bold",size:20))
							
							
							wine.wrappedImage
								.resizable()
								.frame(width:150,height:150)
						}
						HStack{
							Text("Creator:")
								.font(.custom("Cochin-Bold",size:20))
							Text(wine.wrappedCreator)
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Domain:")
								.font(.custom("Cochin-Bold",size:20))
							Text(wine.wrappedDomain)
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							if(wine.wrappedEdition.wrappedIsEdition) {
								Text("Vintage:")
									.font(.custom("Cochin-Bold",size:20))
							}
							else {
								Text("Edition:")
									.font(.custom("Cochin-Bold",size:20))
								
							}
							Text(String(wine.wrappedEdition.wrappedNumber))
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Type:")
								.font(.custom("Cochin-Bold",size:20))
							Text(wine.wrappedType)
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Unopened Bottles:")
								.font(.custom("Cochin-Bold",size:20))
							Text(String(wine.wrappedQuantity))
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Drank:")
								.font(.custom("Cochin-Bold",size:20))
							Text(String(wine.wrappedDrank))
								.font(.custom("Cochin", size: 20))
							
						}
						
						
						
						
						
						
						
						
						
						
						
						
					}
				}
				
				else {
					Text("Add a wine to the collection first.")
						.font(.custom("Cochin", size: 20))
						.foregroundStyle(.gray)
				}
				
			}
			
			
			
			
			VStack {
				Text("You may need to buy some")
					.font(.custom("Cochin", size: 20))
				if currentPerson.collectionLength() {
					let wine = currentPerson.getBuyOwned()
					VStack{
						HStack {
							Text("\(wine.wrappedName)")
								.font(.custom("Cochin-Bold",size:20))
							
							
							wine.wrappedImage
								.resizable()
								.frame(width:150,height:150)
						}
						HStack{
							Text("Creator:")
								.font(.custom("Cochin-Bold",size:20))
							Text(wine.wrappedCreator)
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Domain:")
								.font(.custom("Cochin-Bold",size:20))
							Text(wine.wrappedDomain)
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							if(wine.wrappedEdition.wrappedIsEdition) {
								Text("Vintage:")
									.font(.custom("Cochin-Bold",size:20))
							}
							else {
								Text("Edition:")
									.font(.custom("Cochin-Bold",size:20))
								
							}
							Text(String(wine.wrappedEdition.wrappedNumber))
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Type:")
								.font(.custom("Cochin-Bold",size:20))
							Text(wine.wrappedType)
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Unopened Bottles:")
								.font(.custom("Cochin-Bold",size:20))
							Text(String(wine.wrappedQuantity))
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Drank:")
								.font(.custom("Cochin-Bold",size:20))
							Text(String(wine.wrappedDrank))
								.font(.custom("Cochin", size: 20))
							
						}
						
						
						
						
						
						
						
						
						
						
						
					}
				}
				
				else {
					Text("Add a wine to the collection first.")
						.font(.custom("Cochin", size: 20))
						.foregroundStyle(.gray)
				}
			}
			
			VStack {
				Text("Try something new?")
					.font(.custom("Cochin", size: 20))
				if currentPerson.collectionLength() {
					let wine = currentPerson.getTryOwned()
					VStack{
						HStack {
							Text("\(wine.wrappedName)")
								.font(.custom("Cochin-Bold",size:20))
							
							
							wine.wrappedImage
								.resizable()
								.frame(width:150,height:150)
						}
						HStack{
							Text("Creator:")
								.font(.custom("Cochin-Bold",size:20))
							Text(wine.wrappedCreator)
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Domain:")
								.font(.custom("Cochin-Bold",size:20))
							Text(wine.wrappedDomain)
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							if(wine.wrappedEdition.wrappedIsEdition) {
								Text("Vintage:")
									.font(.custom("Cochin-Bold",size:20))
							}
							else {
								Text("Edition:")
									.font(.custom("Cochin-Bold",size:20))
								
							}
							Text(String(wine.wrappedEdition.wrappedNumber))
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Type:")
								.font(.custom("Cochin-Bold",size:20))
							Text(wine.wrappedType)
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Unopened Bottles:")
								.font(.custom("Cochin-Bold",size:20))
							Text(String(wine.wrappedQuantity))
								.font(.custom("Cochin", size: 20))
							
						}
						HStack{
							Text("Drank:")
								.font(.custom("Cochin-Bold",size:20))
							Text(String(wine.wrappedDrank))
								.font(.custom("Cochin", size: 20))
							
						}
						
						
						
						
						
						
						
						
						
						
						
						
						
						
					}
					
				}
				
				else {
					Text("Add a wine to the collection first.")
						.font(.custom("Cochin", size: 20))
						.foregroundStyle(.gray)
				}
			}
	
			
			
			
			
			
			
			
			
			
		}
		.navigationTitle("")
		.toolbar {
			ToolbarItem(placement: .principal) {
				Text("Home")
					.font(.custom("Cochin", size: 34))
					.foregroundColor(.accentColor)
			}
		}
		
    }
}

