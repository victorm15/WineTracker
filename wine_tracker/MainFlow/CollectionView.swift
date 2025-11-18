import SwiftUI
import Combine
import PhotosUI




struct CollectionView: View {
	@ObservedObject var currentPerson: Person
	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(sortDescriptors: []) var persons: FetchedResults<Person>
	
	// Sorting and Filtering
	@State var filterType: String = "Name"
	@State var sortType: String = "NameD"
	@State var searchRequest: String = ""
	@State var wineTypeFilter = "Any"
	@State var isEdition = true
	@State var editionNumber = ""
	
	@State var linkGoBack = false
	
	// Adding new wines
	@State var wineName: String = ""
	@State var wineDomain: String = ""
	@State var wineCreator: String = ""
	@State var wineType: String = "Red Wine"
	@State var wineQuantity: String = ""
	@State var wineDrank: String = ""
	@State private var avatarItem: PhotosPickerItem?
	@State private var avatarImage: Image?
	
	// Editing wines
	@State var newWineType = ""
	@State private var newAvatarItem: PhotosPickerItem?
	@State private var newAvatarImage: Image?
	@State var wineEditExists = false
	
	
	
    var body: some View {
        
		ZStack {
			LinearGradient(colors: [.white,Color.veryLightGray,.white], startPoint: .topLeading, endPoint: .topTrailing)
				.ignoresSafeArea()
			
			VStack {
				
				
				HStack {
					Menu {
						
						Button {
							filterType = "Name"
						} label: {
							Text("Name")
								.font(.custom("Cochin", size:20))
							
						}
						Button {
							filterType = "Domain"
						} label: {
							Text("Domain")
								.font(.custom("Cochin", size:20))
							
						}
						Button {
							filterType = "Creator"
						} label:{
							Text("Creator")
								.font(.custom("Cochin", size:20))
							
						}
					}label: {
						ZStack {
							Text("\(filterType)  v")
								.font(.custom("Cochin", size:20))
							
							
						}
						
						
					}
					TextField("Search:",text:$searchRequest)
						.textFieldStyle(.roundedBorder)
						.autocapitalization(.none)
						.disableAutocorrection(true)
						.font(.custom("Cochin", size:20))
						.frame(width:200)
					Menu {
						Button {
							wineTypeFilter = "Any"
						} label: {
							Text("Any")
								.font(.custom("Cochin", size:20))
						}
						Button {
							wineTypeFilter = "Red Wine"
						} label: {
							Text("Red Wine")
								.font(.custom("Cochin", size:20))
						}
						Button {
							wineTypeFilter = "White Wine"
						} label: {
							Text("White Wine")
								.font(.custom("Cochin", size:20))
						}
						Button {
							wineTypeFilter = "Champagne"
						} label: {
							Text("Champagne")
								.font(.custom("Cochin", size:20))
						}
						
						
						
					}label : {
						Image(systemName:"cone.fill")
							.resizable()
							.frame(width:30,height:30)
							.rotationEffect(.degrees(180))
					}
					
					Menu {
						
						Button {
							sortType = "NameD"
						} label: {
							Text("Sort by Name Descending")
								.font(.custom("Cochin", size:20))
							
						}
						Button {
							sortType = "NameA"
						} label: {
							Text("Sort by Name Ascending")
								.font(.custom("Cochin", size:20))
							
						}
						Button {
							sortType = "CreatorD"
						} label: {
							Text("Sort by Creator Descending")
								.font(.custom("Cochin", size:20))
							
						}
						Button {
							sortType = "CreatorA"
						} label: {
							Text("Sort by Creator Ascending")
								.font(.custom("Cochin", size:20))
							
						}
						Button {
							sortType = "DomainD"
						} label: {
							Text("Sort by Domain Descending")
								.font(.custom("Cochin", size:20))
							
						}
						Button {
							sortType = "DomainA"
						} label: {
							Text("Sort by Domain Ascending")
								.font(.custom("Cochin", size:20))
							
						}
					} label : {
						Image(systemName:"arrow.up.and.down.circle.fill")
							.resizable()
							.frame(width:30,height:30)
					}
					
					
					
					
				}
				
				
				
				
				List {
					
					
					
					
					ForEach(currentPerson.getWines(FilterType: filterType, FilterString: searchRequest, SortType: sortType,WineType: wineTypeFilter, viewContext: viewContext)) { item in
						
						NavigationLink(){
							GeometryReader { geometry in
								HStack{
									Button {
										deleteWine(wine: item)
										currentPerson.updateCache(viewContext: viewContext)
										linkGoBack = true
									} label : {
										Image(systemName: "trash")
									}
									.navigationDestination(isPresented: $linkGoBack) {
										HomeView(currentPerson: currentPerson)
											.navigationBarBackButtonHidden()
											.toolbar(.hidden,for: .tabBar)
									}
									
									NavigationLink {
										
										
										ZStack{
											LinearGradient(colors: [ Color.lighterGray, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
												.ignoresSafeArea()
											VStack{
												Text("Modify Wine")
													.font(.custom("Cochin", size: 40))
													.foregroundColor(Color.accentColor)
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
														Text("^ \(newWineType) ^")
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
															.foregroundColor(Color.accentColor)
														
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
												
												
												
												
												
												
												
												
												Button("Save Changes") {
													
													
													
													
													
													
													if(wineName == "") {
														wineName = item.wrappedName
													}
													if(wineDomain == "") {
														wineDomain = item.wrappedDomain
													}
													if(wineCreator == "") {
														wineCreator = item.wrappedCreator
													}
													if(newWineType == "") {
														wineType = item.wrappedType
														newWineType = item.wrappedType
													}
													else {
														wineType = newWineType
													}
													if(wineQuantity == "") {
														wineQuantity = String(item.wrappedQuantity)
													}
													if(wineDrank == "") {
														wineDrank = String(item.wrappedDrank)
													}
													if(editionNumber == "") {
														isEdition = item.wrappedEdition.wrappedIsEdition
														editionNumber = String(item.wrappedEdition.wrappedNumber)
													}
													
													
													
													
													var flag = false
													let collection = currentPerson.itemsArray
													for wine in collection {
														
														if(item.wrappedName == wine.wrappedName &&
														   item.wrappedDomain == wine.wrappedDomain &&
														   item.wrappedCreator == wine.wrappedCreator &&
														   item.wrappedEdition.wrappedIsEdition == wine.wrappedEdition.wrappedIsEdition &&
														   item.wrappedEdition.wrappedNumber == wine.wrappedEdition.wrappedNumber &&
														   item.wrappedType == wine.wrappedType){
															continue
														}
														
														
														if(wine.wrappedName == wineName &&
														   wine.wrappedDomain == wineDomain &&
														   wine.wrappedCreator == wineCreator &&
														   wine.wrappedEdition.wrappedIsEdition == isEdition &&
														   wine.wrappedEdition.wrappedNumber == Int16(editionNumber) ?? 0 &&
														   wine.wrappedType == wineType) {
															
															
															
															
															
															
															flag = true
															
															
															
															
														}
														
														
														
													}
													
													
													
													
													wineEditExists = flag
													
													
													
													
													
													
													
													
													
													
													
													
													
													if(!wineEditExists) {
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
														
														linkGoBack = true
														viewContext.delete(item)
														try? viewContext.save()
														wineName = ""
														wineType = "Red Wine"
														wineDomain = ""
														wineCreator = ""
														wineQuantity = ""
														wineDrank = ""
														isEdition = true
														editionNumber = ""
														
													}
													currentPerson.updateCache(viewContext: viewContext)
													
													
													
													
													
													
													
													
													
													
													
													
												}
												.navigationDestination(isPresented: $linkGoBack) {
													HomeView(currentPerson: currentPerson)
														.navigationBarBackButtonHidden()
														.toolbar(.hidden,for:.tabBar)
													
													
													
												}
												.popover(isPresented:$wineEditExists) {
													ZStack {
														RadialGradient(gradient: Gradient(colors: [Color.lighterGray, .white,Color.lighterGray,.white]), center: .center, startRadius: 140, endRadius: 300)
														
														VStack{
															Text("Wine Already Exists")
															Text("Add To Recorded Bottles?")
															HStack{
																Button("No") {
																	wineEditExists = false
																	
																}
																.buttonStyle(AccountButton())
																Button("Yes") {
																	linkGoBack = true
																	
																	
																	
																	addExistingWine(person: currentPerson,typpe:wineType)
																	
																	
																	
																	
																	
																	
																	viewContext.delete(item)
																	try? viewContext.save()
																	currentPerson.updateCache(viewContext: viewContext)
																	wineEditExists = false
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
												}
												.offset(x:90,y:-45)
												
											}
											
											
											
										}
										
										
										
										
										
										
										
										
										
										
										
										
										
									} label : {
										Text("Edit")
											.font(.custom("Cochin",size:20))
									}
									
								}
								
								
								
								
								
								.position(x: geometry.size.width-80, y: 0)
								
							}
							
							
							
							
							
							
							
							VStack{
								HStack {
									Text("\(item.wrappedName)")
										.font(.custom("Cochin-Bold",size:20))
									
									
									item.wrappedImage
										.resizable()
										.frame(width:150,height:150)
								}
								HStack{
									Text("Creator:")
										.font(.custom("Cochin-Bold",size:20))
									Text(item.wrappedCreator)
										.font(.custom("Cochin", size: 20))
									
								}
								HStack{
									Text("Domain:")
										.font(.custom("Cochin-Bold",size:20))
									Text(item.wrappedDomain)
										.font(.custom("Cochin", size: 20))
									
								}
								HStack{
									if(item.wrappedEdition.wrappedIsEdition) {
										Text("Vintage:")
											.font(.custom("Cochin-Bold",size:20))
									}
									else {
										Text("Edition:")
											.font(.custom("Cochin-Bold",size:20))
										
									}
									Text(String(item.wrappedEdition.wrappedNumber))
										.font(.custom("Cochin", size: 20))
									
								}
								HStack{
									Text("Type:")
										.font(.custom("Cochin-Bold",size:20))
									Text(item.wrappedType)
										.font(.custom("Cochin", size: 20))
									
								}
								HStack{
									Text("Unopened Bottles:")
										.font(.custom("Cochin-Bold",size:20))
									Text(String(item.wrappedQuantity))
										.font(.custom("Cochin", size: 20))
									
								}
								HStack{
									Text("Drank:")
										.font(.custom("Cochin-Bold",size:20))
									Text(String(item.wrappedDrank))
										.font(.custom("Cochin", size: 20))
									
								}
								
								
								
								
								
								
								
								
								
								
								
								
								
								
							}
							.offset(y:-350)
						} label:{
							
							ZStack{
								Text("\(item.wrappedName)")
									.font(.custom("Cochin-Bold",size:20))
									.offset(y:-20)
									.frame(width:175)
								Text("\(item.wrappedCreator),\(item.wrappedDomain)")
									.font(.custom("Cochin", size: 20))
									.offset(y:0)
									.frame(width:175)
								
								
								
								item.wrappedImage
									.resizable()
									.frame(width:80,height:80)
									.offset(x:165)
								
							}
							
						}
						
						
						
					}
					
					
					
					
					
					
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
	private func deleteAccount(person: Person) {
		viewContext.delete(person)
		try? viewContext.save()
	}
	private func deleteWine(wine: Item) {
		viewContext.delete(wine)
		try? viewContext.save()
	}
	private func deletePerson(offsets: IndexSet) {
		withAnimation {
			offsets.map { persons[$0] }.forEach(viewContext.delete)
			
			do {
				try viewContext.save()
			} catch {
				let nsError = error as NSError
				fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			}
		}
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


