//
//  strings.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

extension String {
    func loaalized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    struct app {
        public static let appName = "appName"
        public static let confirm = "Confirm"
        public static let cancel = "Cancel"
        
        public static let name = "Name"
        public static let gender = "Gender"
        public static let age = "Age"
        public static let introduction = "Introduction"
        public static let male = "Male"
        public static let female = "Female"
        
        public static let kmPerH = "kmPerH"
        public static let km = "km"
        public static let m = "m"
        public static let cm = "cm"
        public static let min = "min"
        public static let kg = "kg"
        public static let inch = "”"
        
        public static let weight = "Weight"
        public static let height = "Height"
        public static let immunization = "Immunization"
        public static let animalChip = "Animal chip"
        public static let animalId = "Animal ID"
        public static let microchip = "Microchip"
        
    }
    
    struct gnb {
        public static let walk = "Walk"
        public static let matching = "Matching"
        public static let diary = "Diary"
        public static let my = "My"
    }
    
    struct location {
        public static let notFound = "locationNotFound"
    }
    
    struct alert {
        public static var apns = "Bero notification"
        public static var api = "Bero notification"
        public static var apiErrorServer = "Connection lost. Please try again later."
        public static var apiErrorClient = "Please check the internet connection and try again."
        public static var networkError = "Your internet connection is unstable."
        public static var dataError = "No data."
        
        public static var location = "Please allow location access."
        public static var locationText = "According to Apple's policy, you must allow location access to send us your locatoin"
        public static var locationBtn = "Go to grant permission"
        
        public static var locationDisable = "Unable to get location information. try again?"
        public static var locationFind = "Retrieving location information. Please wait."
        public static var dragdown = "Pull to close this page"
        
        public static var snsLoginError = "After login. Available."
        public static var getUserProfileError = "Failed to retrieve user information, Please try again in a few minutes"
        
        public static var addDogTitle = "Add your dog"
        public static var addDogText = "Start with telling more about your dog."
        
        public static var deleteDogTitle = "Are you sure you want to delete Bero’s profile?"
        public static var deleteDogText = "The data, information, and history of the dog will be permanently deleted."
        public static var deleteDogConfirm = "Yes, delete"
        
        public static var completedError = "Save fail. retry."
        public static var completedNeedPicture = "Need picture with your Dog."
        public static var completedNeedPictureError = "Need picture with your Dog. retry."
        public static var completedExitConfirm = "If you exit without receiving a reward, the completed walk record will not be saved. Are you sure you want to quit?"
      
        
    }
    
    struct button {
        public static let later = "Later"
        public static let ok = "Ok"
        public static let prev = "Prev"
        public static let next = "Next"
        public static let skipNow = "Skip for now"
        public static let close = "Close"
        public static let goBack = "Go back"
        public static let save = "Save"
        public static let retry = "Retry"
        public static let reset = "Reset"
        public static let apply = "Apply"
        public static let more = "more"
        public static let delete = "Delete"
        public static let modify = "Modify"
        public static let selectAlbum = "Select from Gallery"
        public static let takeCamera = "Take a photo"
        public static let calendar = "Calendar"
        public static let album = "Album"
        public static let startWalking = "Start walking"
        public static let missionComplete = "Mission Complete"
        public static let walkComplete = "Walk Complete"
        public static let information = "Information"
        public static let unregistered = "Unregistered"
        
        public static let edit = "Edit"
        public static let viewMore = "View more"
        public static let manageDogs = "Manage dogs"

    }
    
    struct pageTitle {
        public static let my = "My"
        public static let addDog = "Add a dog"
        public static let history = "History"
        public static let album = "Album"
        public static let tag = "Tags"
        public static let physicalInformation = "Physical information"
        public static let friends = "friends"
        public static let myDogs = "My dogs"
        public static let myProfile = "My Profile"
        public static let dogProfile = "Dog Profile"
        public static let healthInformation = "Health Information"
    }
    

    struct pageText {
        public static let introText1_1 = "Walk your dog\nwith fun missions."
        public static let introText1_2 = "Walking dogs never been this\nfun! Explore new routes with\nthe daily and monthly missions."
        public static let introText2_1 = "Earn Encrypted\nCoins as you walk."
        public static let introText2_2 = "Walk your dog and earn\nfinancial rewards. The coins are\ndesignated to your dog!"
        public static let introText3_1 = "Make a local dog\ncommunity."
        public static let introText3_2 = "Find new local dog friends to\nwalk with and share\ninformation."
        public static let introComplete = "Let’s explore!"
        
        public static let loginText = "Let’s walk\nour dogs together!"
        public static let loginButtonText = "Continue with "
        
        public static let introductionDefault = "Hello, I am @%s. Let’s be friends!"
        
        
        public static let addDogCompletedText1 = "Nice to meet you"
        public static let addDogCompletedText2 = "There are so many fun walks and dog friends waiting for you!"
        public static let addDogCompletedConfirm = "Start exploring"
        public static let addDogEmpty = "No dog added yet."
        public static let historyCompleted = "%s completed"
        
        public static let missionCompletedSaved = "Mission saved."
        public static let walkCompletedSaved = "Mission saved."
        
        
    }
    
}
