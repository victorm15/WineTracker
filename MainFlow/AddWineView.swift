import SwiftUI
import Combine
import PhotosUI
import CoreData

struct AddWineView: View {
	@ObservedObject var currentPerson: Person
	@Environment(\.managedObjectContext) private var viewContext
	
	@State var wineName: String = ""
	@State var wineDomain: String = ""
	@State var wineCreator: String = ""
	@State var wineType: String = "Red Wine"
	@State var wineQuantity: String = ""
	@State var wineDrank: String = ""
	
	@State var isEdition = true
	@State var editionNumber = ""
	
	@State private var avatarItem: PhotosPickerItem?
	@State private var avatarImage: Image?
	
	@State var wineExists = false
	@State var invalidEntries = false
	
//	var onSaved: () -> Void
	
    var body: some View {
        
		
		ZStack{
			LinearGradient(colors: [ Color(UIColor(rgb: 0xf2f2f7)), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
				.ignoresSafeArea()
			VStack{
				TextField("Wine Name", text:$wineName)
					.textFieldStyle(.roundedBorder)
					.autocapitalization(.none)
					.disableAutocorrection(true)
					.font(.custom("Cochin", size:20))
				TextField("Wine Domain", text:$wineDomain)
					.textFieldStyle(.roundedBorder)
					.autocapitalization(.none)
					.disableAutocorrection(true)
					.font(.custom("Cochin", size:20))
				TextField("Wine Creator", text:$wineCreator)
					.textFieldStyle(.roundedBorder)
					.autocapitalization(.none)
					.disableAutocorrection(true)
					.font(.custom("Cochin", size:20))
				
				
				HStack {
					TextField("Unopened Bottles", text:$wineQuantity)
						.textFieldStyle(.roundedBorder)
						.autocapitalization(.none)
						.keyboardType(.numberPad)
						.disableAutocorrection(true)
						.font(.custom("Cochin", size:20))
						.onReceive(Just(wineQuantity)) { newValue in
							let filtered = newValue.filter { "0123456789".contains($0) }
							if filtered != newValue {
								self.wineQuantity = filtered
							}
						}
					TextField("Bottles Drank", text:$wineDrank)
						.textFieldStyle(.roundedBorder)
						.autocapitalization(.none)
						.keyboardType(.numberPad)
						.disableAutocorrection(true)
						.font(.custom("Cochin", size:20))
						.onReceive(Just(wineDrank)) { newValue in
							let filtered = newValue.filter { "0123456789".contains($0) }
							if filtered != newValue {
								self.wineDrank = filtered
							}
						}
					
					
				}
				
				
				Text("Type")
					.font(.custom("Cochin", size:20))
					.foregroundStyle(.gray)
				Menu {
					Button {
						wineType = "Red Wine"
					} label: {
						Text("Red Wine")
							.font(.custom("Cochin", size:20))
					}
					Button {
						wineType = "White Wine"
					} label: {
						Text("White Wine")
							.font(.custom("Cochin", size:20))
					}
					Button {
						wineType = "Champagne"
					} label: {
						Text("Champagne")
							.font(.custom("Cochin", size:20))
					}
				} label: {
					ZStack{
						Rectangle()
							.fill(.white)
							.frame(height:30)
						Text("^ \(wineType) ^")
							.foregroundColor(Color.lighterGray)
							.font(.custom("Cochin", size:20))
					}
					
				}
				
				HStack{
					
					VStack{
						Text("Vintage")
							.font(.custom("Cochin", size:20))
							.foregroundColor(Color.accentColor)
						Toggle(isOn: $isEdition) {}
							.offset(x:-25)
						
					}
					
					
					
					
					
					if (isEdition) {
						TextField("Vintage Year", text:$editionNumber)
							.textFieldStyle(.roundedBorder)
							.autocapitalization(.none)
							.keyboardType(.numberPad)
							.disableAutocorrection(true)
							.font(.custom("Cochin", size:20))
							.onReceive(Just(editionNumber)) { newValue in
								let filtered = newValue.filter { "0123456789".contains($0) }
								if filtered != newValue {
									self.editionNumber = filtered
								}
							}
							.frame(width: 280)
							.offset(y:15)
					}
					else {
						TextField("Edition Number", text:$editionNumber)
							.textFieldStyle(.roundedBorder)
							.autocapitalization(.none)
							.keyboardType(.numberPad)
							.disableAutocorrection(true)
							.font(.custom("Cochin", size:20))
							.onReceive(Just(editionNumber)) { newValue in
								let filtered = newValue.filter { "0123456789".contains($0) }
								if filtered != newValue {
									self.editionNumber = filtered
								}
							}
							.frame(width:280)
							.offset(y:15)
						
					}
					
					
					
					
					
					
					
					
					
				}
				VStack {
					Text("Image")
						.font(.custom("Cochin", size:20))
						.foregroundColor(Color.accentColor)
					
					VStack{
						PhotosPicker(selection: $avatarItem, matching: .images,label: {
							if let image = avatarImage {
								image
									.resizable()
									.frame(width:100,height:100)
							}
							else{
								Image(systemName:"plus.square.dashed")
									.resizable()
									.frame(width:100,height:100)
									.foregroundColor(Color.accentColor)
								
							}
						})
					}
					.onChange(of: avatarItem) {
						Task {
							if let loaded = try? await avatarItem?.loadTransferable(type: Image.self) {
								avatarImage = loaded
							} else {
								print("Failed")
							}
						}
					}
					
				}
				
				
				
				
				
				
				
				Button("Add Wine") {
					if(Int32(wineQuantity) ?? 0>999) {
						wineQuantity = String(999)
					}
					if(Int32(wineDrank) ?? 0>999) {
						wineDrank = String(999)
					}
					
					invalidEntries = (wineName == "" || wineDomain == "" || wineCreator == "" || wineQuantity == "" || wineDrank == "" || editionNumber == "")
					wineExists = wineExists(person: currentPerson)
					if(!wineExists && !invalidEntries) {
						let newItem = Item(context: viewContext)
						newItem.setName(newName: wineName)
						newItem.owner = currentPerson
						newItem.setCreator(newCreator: wineCreator)
						newItem.setDomain(newDomain: wineDomain)
						newItem.setDrank(newDrank: Int16(wineDrank) ?? 0)
						newItem.setQuantity(newQuantity: Int16(wineQuantity) ?? 0)
						newItem.setType(newType: wineType)
						newItem.setImage(Simage: avatarImage ?? Image("Image"))
						addEditon(wine: newItem)
						
						
						
						try? viewContext.save()
						wineName = ""
						wineType = "Red Wine"
						wineDomain = ""
						wineCreator = ""
						wineQuantity = ""
						wineDrank = ""
						isEdition = true
						editionNumber = ""
						avatarImage = nil
						avatarItem = nil
						
//						onSaved()
//						dismiss()
						
						
					}
					currentPerson.updateCache(viewContext: viewContext)
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
				}
				.popover(isPresented:$wineExists) {
					ZStack {
						RadialGradient(gradient: Gradient(colors: [Color.lighterGray, .white,Color.lighterGray,.white]), center: .center, startRadius: 140, endRadius: 300)
						
						VStack{
							Text("Wine Already Exists")
							Text("Add To Recorded Bottles?")
							HStack{
								Button("No") {
									wineExists = false
									
								}
								.buttonStyle(AccountButton())
								Button("Yes") {
									addExistingWine(person: currentPerson,typpe:wineType)
									currentPerson.updateCache(viewContext: viewContext)
									
									wineExists = false
									wineName = ""
									wineType = "Red Wine"
									wineDomain = ""
									wineCreator = ""
									wineQuantity = ""
									wineDrank = ""
									isEdition = true
									editionNumber = ""
									
								}
							}
						}
					}
				}
				.popover(isPresented:$invalidEntries) {
					ZStack {
						RadialGradient(gradient: Gradient(colors: [Color.lighterGray, .white,Color.lighterGray,.white]), center: .center, startRadius: 140, endRadius: 300)
						
						VStack{
							Text("One or more of the fields is empty")
							Text("Please provide entries to each text field")
							HStack{
								Button("Ok") {
									invalidEntries = false
									
								}
								.buttonStyle(AccountButton())
							}
						}
					}
				}
				
				
				
				
				
				.buttonStyle(AccountButton())
				.font(.custom("Cochin", size:20))
				Button("Clear") {
					wineName = ""
					wineDomain = ""
					wineType = "Red Wine"
					wineQuantity = ""
					wineDrank = ""
					wineCreator = ""
					isEdition = false
					editionNumber = ""
					avatarImage = nil
					avatarItem = nil
				}
				.offset(x:90,y:-45)
				
				
			}
			.navigationTitle("")
			.toolbar {
				ToolbarItem(placement: .principal) {
					Text("Add Wine")
						.font(.custom("Cochin", size: 34))
						.foregroundColor(.accentColor)
				}
			}
		}
			
			
		
		
		
		
		
    }
	
	private func addExistingWine(person:Person, typpe: String) {
		let collection = person.itemsArray
		for item in collection {
			if(item.wrappedName == wineName && item.wrappedDomain == wineDomain && item.wrappedCreator == wineCreator && item.wrappedEdition.wrappedIsEdition == isEdition && item.wrappedEdition.wrappedNumber == Int16(editionNumber) ?? 0 && item.wrappedType == typpe) {
				
				let quant = item.wrappedQuantity
				let dran = item.wrappedDrank
				deleteWine(wine: item)
				let newItem = Item(context:viewContext)
				newItem.setName(newName: wineName)
				newItem.owner = currentPerson
				newItem.setCreator(newCreator: wineCreator)
				newItem.setDomain(newDomain: wineDomain)
				newItem.setDrank(newDrank: (Int16(wineDrank) ?? 0) + dran)
				newItem.setQuantity(newQuantity: (Int16(wineQuantity) ?? 0) + quant)
				newItem.setType(newType: typpe)
				newItem.setImage(Simage: avatarImage ?? Image("Image"))
				addEditon(wine: newItem)
				
				try? viewContext.save()
				
				
				
				
				
				
			}
			
			
			
			
		}
		
		
		
	}
	
	private func wineExists(person: Person)->Bool {
		var flag = false
		let collection = person.itemsArray
		for item in collection {
			if(item.wrappedName == wineName && item.wrappedDomain == wineDomain && item.wrappedCreator == wineCreator && item.wrappedEdition.wrappedIsEdition == isEdition && item.wrappedEdition.wrappedNumber == Int16(editionNumber) ?? 0 && item.wrappedType == wineType) {
				flag = true
			}
			
			
			
		}
		return flag
		
		
		
		
	}
	
	private func deleteWine(wine: Item) {
		viewContext.delete(wine)
		try? viewContext.save()
	}
	
	private func addWineCustom(person: Person,name: String) {
		let newItem = Item(context:viewContext)
		newItem.setName(newName: name)
		newItem.owner = person
		newItem.setCreator(newCreator: wineCreator)
		newItem.setDomain(newDomain: wineDomain)
		newItem.setDrank(newDrank: Int16(wineDrank) ?? 0)
		newItem.setQuantity(newQuantity:Int16(wineQuantity) ?? 0)
		newItem.setType(newType: wineType)
		newItem.setImage(Simage: avatarImage ?? Image("Image"))
		addEditon(wine: newItem)
		
		try? viewContext.save()
		
		
		
		
		
	}
	
	private func addEditon(wine: Item) {
		let newEdition = Edition(context:viewContext)
		newEdition.setIsEdition(newIsEdition: isEdition)
		newEdition.setNumber(newNumber: Int16(editionNumber) ?? 2024)
		newEdition.wine = wine
		try? viewContext.save()
		
		
	}
	
	
}
