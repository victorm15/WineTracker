# iOS Wine Collection Tracking Application

## Features
* Designed UI using SwiftUI
* Provided on-device persistence with CoreData
* Leveraged caching to speed up large queries
* Used OOP principles to represent accounts and wines with an aggregate relationship
* Wrote a quicksort implementation to sort and filter wines based on object attributes
* Created account authentication page

## Application Screenshots


## Authentication Pages

#### Signup Page
<img src="Screenshots/Signup.png" alt="Sign Up Page" width="150" height="326">

* Create account which persists on-device
* Checks for valid fields (including email in format `XXXXX@XXX.XXX`)
* Compares with stored accounts to verify unique username

#### Login Page
<img src="Screenshots/LogIn.png" alt="Log In Page" width="150" height="326">

* Checks entered username and password, displaying message to user in case of invalid credentials
* Passes authenticated password to app state for use in main pages

## Main Pages

#### Collection Page
<p float="left">
  <img src="Screenshots/CollectionView.png" alt="Collection Page" width="150" height="326">
  <img src="Screenshots/Arrow.png" alt="Arrow" width="60" height="326">
  <img src="Screenshots/CollectionOpenView.png" alt="Collection Open Page" width="150" height="326">
</p>

* View collection of wines based on sorting and filtering criteria
* Expand individual wines into a detailed view where they can be edited or deleted
* If a wine is edited into one which already exists, merging the two objects is proposed

#### Account Statistics Page
<img src="Screenshots/AccountView.png" alt="Account Page" width="150" height="326">

#### Home Page
<img src="Screenshots/HomeView.png" alt="Home Page" width="150" height="326">

#### Add wine Page
<img src="Screenshots/AddWineView.png" alt="Add Wine Page" width="150" height="326">

* Checks if the wine already exists and proposes to merge the new wine with the existing wine if it does

<img src="Screenshots/SettingsView.png" alt="Settings Page" width="150" height="326">

* Edit account object attributes
* Can merge another account's collection with the current account's, requiring authentication for the source account
