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

//disable being able to make two accounts with the same username
//return error in sign up + log in page
//statisitcs: how many wines from a specific region... juggling data... most owned wine name etc.
// copy down arrays of collection





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
    @State var editionType: String = "Vintage"
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
    
    
    
    var body: some View {

        TabView(){
            
            
            
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
                List {
                    ForEach(persons) { person in
                        NavigationLink {
                            List{
                                ForEach(person.itemsArray) { item in
                                    Text("\(item.wrappedName)")
                                        .font(.custom("Cochin", size:20))
                                    
                                }
                            }
                            
                            .toolbar {
                                ToolbarItem() {
                                    Button("add") {
                                        addWine(person: person)
                                    }
                                    .font(.custom("Cochin", size:20))
                                }
                            }
                        } label: {
                            Text("\(person.username ?? "fail")")
                                .font(.custom("Cochin", size:20))
                        }
                    }
                    .onDelete(perform: deletePerson)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
                
                
                
            }
            .tabItem {
                Text("Collection")
                Image(systemName:"list.bullet")
            }
            
            
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
                            ForEach(currentPerson.getArray(FilterType: filterType, FilterString: searchRequest, SortType: sortType,WineType: wineTypeFilter)) { item in
                                ZStack{
                                        Text("\(item.wrappedName)")
                                            .font(.custom("Cochin-Bold",size:20))
                                            .offset(y:-20)
                                        Text("\(item.wrappedCreator),\(item.wrappedDomain)")
                                            .font(.custom("Cochin", size: 20))
                                            .offset(y:0)
                                    
                                    
                                    
                                    item.wrappedImage
                                        .resizable()
                                        .frame(width:80,height:80)
                                        .offset(x:200)
                                        
                                }

                                
                                
                            }
                        }
                        
                        
                    }
                }
            }
            .tabItem {
                Text("View3")
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

                        HStack{
                            Menu {
                                Button {
                                    editionType = "Vintage"
                                } label: {
                                    Text("Vintage")
                                        .font(.custom("Cochin", size:20))
                                }
                                Button {
                                    editionType = "Edition"
                                } label: {
                                    Text("Edition")
                                        .font(.custom("Cochin", size:20))
                                }
                            } label: {
                                ZStack{
                                    Rectangle()
                                        .fill(.white)
                                        .frame(height:30)
                                    Text("^ \(editionType) ^")
                                        .foregroundColor(Color.lighterGray)
                                        .font(.custom("Cochin", size:20))
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
                        
                        
                        Button("Add Wine") {
                            addWineCustom(person: currentPerson, name: wineName)
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
                            editionType = "Vintage"
                        }
                        .offset(x:90,y:-45)
                        Button("Quick") {
                            wineName = "Name"
                            wineDomain = "Domain"
                            wineType = "Red Wine"
                            wineQuantity = "12"
                            wineDrank = "2"
                            wineCreator = "Creator"
                            editionType = "Vintage"

                        }
                        VStack{
                            PhotosPicker("Select avatar", selection: $avatarItem, matching: .images)
                            avatarImage?
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
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
                    
                    
                    
                }
                
                
                
                
                                
                
                
                
                
            }
            .tabItem {
                Text("View4")
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
                                LinearGradient(colors: [ Color.lighterGray, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    .ignoresSafeArea()

                                VStack{
                                Text("Account Details")
                                    .font(.custom("Cochin", size: 34))
                                    .fontWeight(.bold)
                                    .padding(.top, 16)
                                    .padding(.bottom, 8)
                                    .padding(.horizontal)
                                    .foregroundColor(Color.accentColor)
                                    .offset(y:-200)
                                
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
                                TextField("New Username",text:$newUsername)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .font(.custom("Cochin", size:20))
                                    .offset(y:-50)
                                Button("Change Username") {
                                    if(newUsername != "") {
                                        currentPerson.username = newUsername
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

                                Button("Change Name") {
                                    if(newFirst != "" && newLast != "") {
                                        currentPerson.firstName = newFirst
                                        currentPerson.lastName = newLast
                                    }
                                    else if(newFirst != ""){
                                        currentPerson.firstName = newFirst
                                    }
                                    else if(newLast != "") {
                                        currentPerson.lastName = newLast
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
                                TextField("New Password",text:$newPassword)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .font(.custom("Cochin", size:20))
                                    .offset(y:-50)
                                Button("Change Password") {
                                    if(newPassword != "") {
                                        currentPerson.password = newPassword
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
                                TextField("New Email",text:$newEmail)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .font(.custom("Cochin", size:20))
                                    .offset(y:-50)
                                Button("Change Email") {
                                    if(isValidEmail(email: newEmail)) {
                                        currentPerson.email = newEmail
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

                                        
                        
                        
                    }
                        }
                        .background(Color(UIColor.systemBackground))
                
                
                
                
                
                                
                
                
                
                
                
                
                
                
                
            }
            .tabItem {
                Text("View5")
                Image(systemName:"gear")
            }
            
        }
        
        .tint(Color.accentColor)
        .onAppear(perform: {
            UITabBar.appearance().unselectedItemTintColor = UIColor(rgb:0x797979)
            
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.accentColor)]
            
        })
        
        
        
        
        
        
        
        
        
        
        
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
        newItem.setVintage(vintage:"Vintage2013")
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
        newItem.setVintage(vintage: "Vintage2013")
        newItem.setImage(Simage: avatarImage ?? Image("Image"))
        try? viewContext.save()
        
        
        
        
        
    }    
    
    
}











#Preview {
    ContentView().environment(\.managedObjectContext,PersistenceController.preview.container.viewContext)
}







