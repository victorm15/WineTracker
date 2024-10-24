//
//  ContentView.swift
//  \
//
//  Created by Victor Mauger on 12.07.2024.
//
//test gitty

import SwiftUI
import CoreData
import UIKit
import Combine
import PhotosUI







struct ContentView: View{
    @State var currentPerson = Person()
    @Environment(\.managedObjectContext) private var viewContext
    @State var email: String = ""
    @State var username: String = ""
    @State var password: String = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var isActive = false
    @State var makeSuccess = false
    @State var makeFailure = false
    @State var usernameTaken = false
    @State var UsernameAttempt = ""
    @State var PasswordAttempt = ""
    @State var logInSuccess = false
    @State var logInFailure = false
    @FetchRequest(
        sortDescriptors: []) var persons: FetchedResults<Person>
    
    
    
    
    
    
    var body: some View {
        TabView() {
            NavigationStack() {
                ZStack{
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
                            .popover(isPresented:$makeSuccess) {
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
                                            makeSuccess = false
                                            isActive = true
                                        }
                                        .buttonStyle(GreenButton())
                                        
                                    }
                                }
                            }
                            .popover(isPresented:$makeFailure) {
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
                                            makeFailure = false
                                        }
                                        .buttonStyle(AccountButton())
                                        
                                    }
                                }
                            }
                            .popover(isPresented:$usernameTaken) {
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
                                            usernameTaken = false
                                        }
                                        .buttonStyle(AccountButton())
                                        
                                    }
                                }
                            }
                        
                        Button("Make Account") {
                            for person in persons {
                                if (person.wrappedUsername == username) {
                                    usernameTaken = true
                                }
                            }
                            if (!usernameTaken) {
                                if (isValidField(text:$firstName.wrappedValue) && isValidField(text:$lastName.wrappedValue) && isValidEmail(email: $email.wrappedValue)) {
                                    
                                    
                                        let newAccount = Person(context: viewContext)
                                        newAccount.username = username
                                        newAccount.password = password
                                        newAccount.firstName = firstName
                                        newAccount.lastName = lastName
                                        newAccount.email = email
                                        try? viewContext.save()
                                        makeSuccess = true
                                    
                                    
                                }
                                else {
                                    makeFailure = true
                                }

                            }
                                                        
                            
                            
                        }
                        .buttonStyle(AccountButton())
                        .font(.custom("Cochin", size:20))
                        
                        
                        
                    }
                }
            }
            .tabItem {
                Text("Sign Up")
                Image(systemName:"person.fill.badge.plus")
            }
            NavigationStack {
                ZStack {
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
                        
                        
                        
                        
                        
                        
                        
                        Button ("Log In")  {
                            if (persons.count != 0) {
                                for person in persons {
                                    if (person.wrappedUsername == UsernameAttempt) {
                                        if (person.wrappedPassword == PasswordAttempt) {
                                            currentPerson = person
                                            logInSuccess = true
                                        }
                                        
                                    }
                                }
                                
                                
                            }
                            if (!logInSuccess) {
                                logInFailure = true
                            }
                            
                            
                            
                            
                            
                            
                        }
                        .buttonStyle(AccountButton())
                        .font(.custom("Cochin", size:20))
                        .navigationDestination(isPresented: $logInSuccess) {
                            HomeView(currentPerson: currentPerson)
                                .toolbar(.hidden,for: .tabBar)
                                .navigationBarBackButtonHidden()
                        }
                        
                        
                        
                    }
                    
                    
                    
                }
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
            }
            .tabItem {
                Text("Log In")
                Image(systemName:"person.badge.key.fill")
            }
            
            
        }
        
        
        
        
        
        
        
    }
}




struct HomeView: View {
    var currentPerson: Person
    @State var count = 0
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: []) var persons: FetchedResults<Person>
    @State var wineName: String = ""
    @State var wineDomain: String = ""
    @State var wineCreator: String = ""
    @State var wineType: String = "Red Wine"
    @State var wineQuantity: String = ""
    @State var wineDrank: String = ""
    @State var sortType: String = "NameD"
    @State var currentCollection: [Item] = []
    @State var searchRequest: String = ""
    @State var filterType: String = "Name"
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State var backToLogIn = false
    @State var wineTypeFilter = "Any"
    @State var newUsername = ""
    @State var newEmail = ""
    @State var newFirst = ""
    @State var newLast = ""
    @State var newPassword = ""
    @State var isEdition = true
    @State var editionNumber = ""
    @State var linkGoBack = false
    @State var newUsernameTaken = false
    @State var newWineType = ""
    @State private var newAvatarItem: PhotosPickerItem?
    @State private var newAvatarImage: Image?
    @State var wineExists = false
    @State var wineEditExists = false
    @State var invalidEntries = false
    @State var invalidChange = false
    @State var proposeDeletion = false
    @State var usernameAttempt = ""
    @State var logInFailure = false
    @State var logInSuccess = false
    @State var passwordAttempt = ""
    @State var mergingAccount: Person?
    
    
    var body: some View {

        TabView(){
            
            
            
            NavigationStack(){
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
                                    Text("\(filterType) v")
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
                                
                                
                                
                                    
                            ForEach(currentPerson.getWines(FilterType: filterType, FilterString: searchRequest, SortType: sortType,WineType: wineTypeFilter,viewContext: viewContext)) { item in
                                        
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
                                                                        wineQuantity = String(item.quantity)
                                                                    }
                                                                    if(wineDrank == "") {
                                                                        wineDrank = String(item.drank)
                                                                    }
                                                                    if(editionNumber == "") {
                                                                        isEdition = !item.wrappedEdition.isEdition
                                                                        editionNumber = String(item.wrappedEdition.number)
                                                                    }
                                                                    
                                                                   
                                                                    
                                                                    
                                                                    var flag = false
                                                                    let collection = currentPerson.itemsArray
                                                                    for wine in collection {
                                                                        
                                                                        if(item.wrappedName == wine.wrappedName &&
                                                                           item.wrappedDomain == wine.wrappedDomain &&
                                                                           item.wrappedCreator == wine.wrappedCreator &&
                                                                           item.wrappedEdition.isEdition == wine.wrappedEdition.isEdition &&
                                                                           item.wrappedEdition.number == wine.wrappedEdition.number &&
                                                                           item.wrappedType == wine.wrappedType){
                                                                            continue
                                                                        }
                                                                            
                                                                        
                                                                        if(wine.wrappedName == wineName &&
                                                                           wine.wrappedDomain == wineDomain &&
                                                                           wine.wrappedCreator == wineCreator &&
                                                                           wine.wrappedEdition.isEdition == !isEdition &&
                                                                           wine.wrappedEdition.number == Int16(editionNumber) ?? 0 &&
                                                                           wine.wrappedType == wineType) {
                                                                        
                                                                        
                                                                        
                                                                        
                                                                        
                                                                        
                                                                            flag = true
                                                                        
                                                                        
                                                                        
                                                                        
                                                                        }
                                                                    
                                                                        
                                                                        
                                                                    }

                                                                    
                                                                    
                                                                    
                                                                    wineEditExists = flag
                                                                    
                                                                    
                                                                    
                                                                    
                                                                    
                                                                    
                                                                    
                                                                    
                                                                    
                                                                    
                                                                    
                                                                    
                                                                    
                                                                    if(!wineEditExists) {
                                                                        let newItem = Item(context: viewContext)
                                                                        newItem.name = wineName
                                                                        newItem.owner = currentPerson
                                                                        newItem.creator = wineCreator
                                                                        newItem.domain = wineDomain
                                                                        newItem.drank = Int16(wineDrank) ?? 0
                                                                        newItem.quantity = Int16(wineQuantity) ?? 0
                                                                        newItem.type = wineType
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
                                                    if(item.wrappedEdition.isEdition) {
                                                        Text("Vintage:")
                                                            .font(.custom("Cochin-Bold",size:20))
                                                    }
                                                    else {
                                                        Text("Edition:")
                                                            .font(.custom("Cochin-Bold",size:20))
                                                        
                                                    }
                                                    Text(String(item.wrappedEdition.number))
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
                                                    Text(String(item.quantity))
                                                        .font(.custom("Cochin", size: 20))
                                                    
                                                }
                                                HStack{
                                                    Text("Drank:")
                                                        .font(.custom("Cochin-Bold",size:20))
                                                    Text(String(item.drank))
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
            .tabItem {
                Text("Collection")
                Image(systemName:"list.bullet")
            }

            
            NavigationStack(){
                
                Text("Account Statistics")
                    .font(.custom("Cochin", size: 34))
                    .fontWeight(.bold)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .foregroundColor(Color.accentColor)
                
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
                }
                
                
            }
            .background(Color(UIColor.systemBackground))
            .tabItem {
                Text("Account")
                Image(systemName:"person.fill")
            }

            NavigationStack() {
                Text("Home")
                            .font(.custom("Cochin", size: 34))
                            .fontWeight(.bold)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .foregroundColor(Color.accentColor)

                List {
                                                        
                    if(currentPerson.collectionLength()) {
                        VStack {
                            Text("Most owned wine")
                                .font(.custom("Cochin", size: 20))
                            VStack{
                                HStack {
                                    Text("\(currentPerson.getMostOwned().wrappedName)")
                                        .font(.custom("Cochin-Bold",size:20))
                                    
                                    
                                    currentPerson.getMostOwned().wrappedImage
                                        .resizable()
                                        .frame(width:150,height:150)
                                }
                                HStack{
                                    Text("Creator:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(currentPerson.getMostOwned().wrappedCreator)
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Domain:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(currentPerson.getMostOwned().wrappedDomain)
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    if(currentPerson.getMostOwned().wrappedEdition.isEdition) {
                                        Text("Vintage:")
                                            .font(.custom("Cochin-Bold",size:20))
                                    }
                                    else {
                                        Text("Edition:")
                                            .font(.custom("Cochin-Bold",size:20))
                                        
                                    }
                                    Text(String(currentPerson.getMostOwned().wrappedEdition.number))
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Type:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(currentPerson.getMostOwned().wrappedType)
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Unopened Bottles:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(String(currentPerson.getMostOwned().quantity))
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Drank:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(String(currentPerson.getMostOwned().drank))
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                            }
                            
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                        VStack {
                            Text("Favorite wine")
                                .font(.custom("Cochin", size: 20))
                            VStack{
                                HStack {
                                    Text("\(currentPerson.getFavoriteOwned().wrappedName)")
                                        .font(.custom("Cochin-Bold",size:20))
                                    
                                    
                                    currentPerson.getFavoriteOwned().wrappedImage
                                        .resizable()
                                        .frame(width:150,height:150)
                                }
                                HStack{
                                    Text("Creator:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(currentPerson.getFavoriteOwned().wrappedCreator)
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Domain:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(currentPerson.getFavoriteOwned().wrappedDomain)
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    if(currentPerson.getFavoriteOwned().wrappedEdition.isEdition) {
                                        Text("Vintage:")
                                            .font(.custom("Cochin-Bold",size:20))
                                    }
                                    else {
                                        Text("Edition:")
                                            .font(.custom("Cochin-Bold",size:20))
                                        
                                    }
                                    Text(String(currentPerson.getFavoriteOwned().wrappedEdition.number))
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Type:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(currentPerson.getFavoriteOwned().wrappedType)
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Unopened Bottles:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(String(currentPerson.getFavoriteOwned().quantity))
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Drank:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(String(currentPerson.getFavoriteOwned().drank))
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                
                                
                                
                                                                
                                
                                
                                
                                
                                
                                
                                
                                
                            }

                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                        }
                        VStack {
                            Text("You may need to buy some")
                                .font(.custom("Cochin", size: 20))
                            VStack{
                                HStack {
                                    Text("\(currentPerson.getBuyOwned().wrappedName)")
                                        .font(.custom("Cochin-Bold",size:20))
                                    
                                    
                                    currentPerson.getBuyOwned().wrappedImage
                                        .resizable()
                                        .frame(width:150,height:150)
                                }
                                HStack{
                                    Text("Creator:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(currentPerson.getBuyOwned().wrappedCreator)
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Domain:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(currentPerson.getBuyOwned().wrappedDomain)
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    if(currentPerson.getBuyOwned().wrappedEdition.isEdition) {
                                        Text("Vintage:")
                                            .font(.custom("Cochin-Bold",size:20))
                                    }
                                    else {
                                        Text("Edition:")
                                            .font(.custom("Cochin-Bold",size:20))
                                        
                                    }
                                    Text(String(currentPerson.getBuyOwned().wrappedEdition.number))
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Type:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(currentPerson.getBuyOwned().wrappedType)
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Unopened Bottles:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(String(currentPerson.getBuyOwned().quantity))
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Drank:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(String(currentPerson.getBuyOwned().drank))
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                            }

                        }
                        
                        VStack {
                            Text("Try something new?")
                                .font(.custom("Cochin", size: 20))
                            VStack{
                                HStack {
                                    Text("\(currentPerson.getTryOwned().wrappedName)")
                                        .font(.custom("Cochin-Bold",size:20))
                                    
                                    
                                    currentPerson.getTryOwned().wrappedImage
                                        .resizable()
                                        .frame(width:150,height:150)
                                }
                                HStack{
                                    Text("Creator:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(currentPerson.getTryOwned().wrappedCreator)
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Domain:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(currentPerson.getTryOwned().wrappedDomain)
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    if(currentPerson.getTryOwned().wrappedEdition.isEdition) {
                                        Text("Vintage:")
                                            .font(.custom("Cochin-Bold",size:20))
                                    }
                                    else {
                                        Text("Edition:")
                                            .font(.custom("Cochin-Bold",size:20))
                                        
                                    }
                                    Text(String(currentPerson.getTryOwned().wrappedEdition.number))
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Type:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(currentPerson.getTryOwned().wrappedType)
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Unopened Bottles:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(String(currentPerson.getTryOwned().quantity))
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                HStack{
                                    Text("Drank:")
                                        .font(.custom("Cochin-Bold",size:20))
                                    Text(String(currentPerson.getTryOwned().drank))
                                        .font(.custom("Cochin", size: 20))
                                    
                                }
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                            }

                            
                        }
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    
                }
                
                
            }
            .tabItem {
                Text("Home")
                Image(systemName:"house.fill")
            }
            
            
            
            NavigationStack(){
                ZStack{
                    LinearGradient(colors: [ Color.lighterGray, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    VStack{
                        Text("Add Wine")
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
                                newItem.name = wineName
                                newItem.owner = currentPerson
                                newItem.creator = wineCreator
                                newItem.domain = wineDomain
                                newItem.drank = Int16(wineDrank) ?? 0
                                newItem.quantity = Int16(wineQuantity) ?? 0
                                newItem.type = wineType
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
                        }
                        .offset(x:90,y:-45)
                        
                        
                    }
                    
                    
                    
                }
                
                
                
                
                                
                
                
                
                
            }
            .tabItem {
                Text("Add Wine")
                Image(systemName:"plus.circle.fill")
            }
            
            
            
            NavigationStack(){
                VStack(spacing: 0) {
                            
                    Text("Settings")
                                .font(.custom("Cochin", size: 34))
                                .fontWeight(.bold)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .foregroundColor(Color.accentColor)
                            
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
                                            currentPerson.username = newUsername
                                            try? viewContext.save()
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
                                                currentPerson.firstName = newFirst
                                                currentPerson.lastName = newLast
                                                try? viewContext.save()
                                            }
                                            else if(newFirst != ""){
                                                currentPerson.firstName = newFirst
                                                try? viewContext.save()
                                            }
                                            else if(newLast != "") {
                                                currentPerson.lastName = newLast
                                                try? viewContext.save()
                                            }

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
                                                currentPerson.password = newPassword
                                                try? viewContext.save()
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
                                            currentPerson.email = newEmail
                                            try? viewContext.save()
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
                                    backToLogIn = true
                                }
                                .font(.custom("Cochin",size:20))
                                .buttonStyle(AccountButton())
                                .navigationDestination(isPresented: $backToLogIn) {
                                    ContentView()
                                        .toolbar(.hidden,for: .tabBar)
                                        .navigationBarBackButtonHidden()
                                }
                                
                            }
                            
                        } label: {
                            Text("Log out of account")
                                .font(.custom("Cochin",size:20))
                        }
                        
                        NavigationLink {
                            Button {
                                backToLogIn = true
                                deleteAccount(person: currentPerson)
                            } label :{Text("Delete")}.buttonStyle(AccountButton())
                                .navigationDestination(isPresented: $backToLogIn) {
                                    ContentView()
                                        .toolbar(.hidden,for: .tabBar)
                                        .navigationBarBackButtonHidden()
                                }

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
                                                                newWine.name = wine.wrappedName
                                                                newWine.domain = wine.wrappedDomain
                                                                newWine.creator = wine.wrappedCreator
                                                                newWine.quantity = wine.quantity
                                                                newWine.drank = wine.drank
                                                                newWine.edition = wine.wrappedEdition
                                                                newWine.owner = currentPerson
                                                                newWine.type = wine.wrappedType
                                                                if let imageData = wine.image {
                                                                    newWine.image = imageData
                                                                }
                                                                else {
                                                                    wine.setImage(Simage: wine.wrappedImage)
                                                                }
                                                                
                                                                
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
                                                                newWine.name = wine.wrappedName
                                                                newWine.domain = wine.wrappedDomain
                                                                newWine.creator = wine.wrappedCreator
                                                                newWine.quantity = wine.quantity
                                                                newWine.drank = wine.drank
                                                                newWine.edition = wine.wrappedEdition
                                                                newWine.owner = currentPerson
                                                                newWine.type = wine.wrappedType
                                                                if let imageData = wine.image {
                                                                    newWine.image = imageData
                                                                }
                                                                else {
                                                                    wine.setImage(Simage: wine.wrappedImage)
                                                                }
                                                                viewContext.delete(merge)
                                                                try? viewContext.save()
                                                                
                                                                
                                                            }
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
                        }
                        .background(Color(UIColor.systemBackground))
                
                
                
                
                
                                
                
                
                
                
                
                
                
                
                
            }
            .tabItem {
                Text("Settings")
                Image(systemName:"gear")
            }
            
        }
        
        .tint(Color.accentColor)
        .onAppear(perform: {
            UITabBar.appearance().unselectedItemTintColor = UIColor(rgb:0x797979)
            
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.accentColor)]
            
        })
        
        
        
        
        
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private func addExistingWine(person:Person, typpe: String) {
        let collection = person.itemsArray
        for item in collection {
            if(item.wrappedName == wineName && item.wrappedDomain == wineDomain && item.wrappedCreator == wineCreator && item.wrappedEdition.isEdition == !isEdition && item.wrappedEdition.number == Int16(editionNumber) ?? 0 && item.wrappedType == typpe) {
                
                let quant = item.quantity
                let dran = item.drank
                deleteWine(wine: item)
                let newItem = Item(context:viewContext)
                newItem.name = wineName
                newItem.owner = currentPerson
                newItem.creator = wineCreator
                newItem.domain = wineDomain
                newItem.drank = (Int16(wineDrank) ?? 0) + dran
                newItem.quantity = (Int16(wineQuantity) ?? 0) + quant
                newItem.type = typpe
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
            if(item.wrappedName == wineName && item.wrappedDomain == wineDomain && item.wrappedCreator == wineCreator && item.wrappedEdition.isEdition == !isEdition && item.wrappedEdition.number == Int16(editionNumber) ?? 0 && item.wrappedType == wineType) {
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
    private func addWine(person: Person) {
        let newItem = Item(context:viewContext)
        newItem.name = "do"
        newItem.owner = person
        newItem.creator = "wineCreator"
        newItem.domain = "wineOrigin"
        newItem.drank = 1
        newItem.quantity = 2
        newItem.type = "Red Wine"
        newItem.setImage(Simage: Image("Image"))
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
        newItem.name = name
        newItem.owner = person
        newItem.creator = wineCreator
        newItem.domain = wineDomain
        newItem.drank = Int16(wineDrank) ?? 0
        newItem.quantity = Int16(wineQuantity) ?? 0
        newItem.type = wineType
        newItem.setImage(Simage: avatarImage ?? Image("Image"))
        addEditon(wine: newItem)
        
        try? viewContext.save()
        
        
        
        
        
    }
    private func addEditon(wine: Item) {
        let newEdition = Edition(context:viewContext)
        newEdition.isEdition = isEdition
        newEdition.number = Int16(editionNumber) ?? 2024
        newEdition.wine = wine
        try? viewContext.save()
    
        
    }
    
    
}










#Preview {
    ContentView().environment(\.managedObjectContext,PersistenceController.preview.container.viewContext)
}







