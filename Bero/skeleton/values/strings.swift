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
        public static let appName = "Bero"
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
        public static let exp = "EXP"
        public static let weight = "Weight"
        public static let height = "Height"
        public static let immunization = "Immunization"
        public static let animalChip = "Animal chip"
        public static let animalId = "Animal ID"
        public static let microchip = "Microchip"
        public static let today = "Today"
        public static let walk = "Walk"
        public static let near = "Near"
        public static let likes = "likes"
        public static let missions = "missions"
    }
    
    struct gnb {
        public static let walk = "Walk"
        public static let explore = "Explore"
        public static let chat = "Chat"
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
      
        public static var noItemsSelected = "No items selected."
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
        public static let finish = "Finish"
        public static let finishTheWalk = "Finish the walk"
        public static let missionComplete = "Mission Complete"
        public static let walkComplete = "Walk Complete"
        public static let information = "Information"
        public static let unregistered = "Unregistered"
        
        public static let edit = "Edit"
        public static let viewMore = "View more"
        public static let manageDogs = "Manage dogs"
        public static let addFriend = "Add friend"
        public static let chat = "Chat"
        public static let requestSent = "Request sent"
        public static let removeFriend = "Remove friend"
        public static let all = "All"
        public static let returnToAllPosts = "Return to all posts"
        public static let reject = "Reject"
        public static let accept = "Accept"
        public static let checkAll = "Check All"
    }
    
    struct pageTitle {
        public static let my = "My"
        public static let explore = "Explore"
        public static let chat = "Chat"
        public static let addDog = "Add a dog"
        public static let history = "History"
        public static let album = "Album"
        public static let tag = "Tags"
        public static let physicalInformation = "Physical information"
        public static let friends = "friends"
        public static let myDogs = "My dogs"
        public static let myProfile = "My Profile"
        public static let myLv = "My Heart Level"
        public static let dogProfile = "Dog Profile"
        public static let healthInformation = "Health Information"
        public static let usersDogs = "%s’s dogs"
        public static let walkHistory = "Walk History"
        public static let walkReport = "Walk Report"
        public static let missionHistory = "Mission History"
        public static let completedMissions = "Completed missions"
    }
    

    struct pageText {
        //for page
        public static let introText1_1 = "Walk your dog\nwith fun missions."
        public static let introText1_2 = "Walking dogs never been this\nfun! Explore new routes with\nthe daily and monthly missions."
        public static let introText2_1 = "Earn Encrypted\nCoins as you walk."
        public static let introText2_2 = "Walk your dog and earn\nfinancial rewards. The coins are\ndesignated to your dog!"
        public static let introText3_1 = "Make a local dog\ncommunity."
        public static let introText3_2 = "Find new local dog friends to\nwalk with and share\ninformation."
        public static let introComplete = "Let’s explore!"
        
        public static let loginText = "Let’s walk\nour dogs together!"
        public static let loginButtonText = "Continue with "
        
        public static let addDogCompletedText1 = "Nice to meet you"
        public static let addDogCompletedText2 = "There are so many fun walks and dog friends waiting for you!"
        public static let addDogCompletedConfirm = "Start exploring"
        public static let addDogEmpty = "No dog added yet."
        
        public static let myLvText = "Earn friendship to level up your heart!"
        public static let myLvText1 = "How to earn friendship"
        public static let myLvText2 = "Hi %s!"
        public static let myLvText3 = "Welcome to %s!"
        public static let myLvText4 = "Earn +%s friendship to level up!"
        
        public static let walkHistoryText1 = "Walked in total"
        public static let missionHistoryText1 = "completed in total"
        public static let walkHistorySeletReport = "Whose report do you want to see?"
        
        
        
        public static let reportWalkSummaryWeekly = "Weekly"
        public static let reportWalkSummaryMonthly = "Monthly"
       
        public static let reportWalkDayUnit = "days"
        public static let reportWalkDayText = "You’ve walked"
        public static let reportWalkDayWeek = "in total this week."
        public static let reportWalkDayMonth = "in total this month."

        public static let reportWalkDayCompleted = "You achieved the goal! Good job!"
        public static let reportWalkDayContinue = "Walk %s days";

        public static let reportWalkDayCompareText1 = "This is"
        public static let reportWalkDayCompareText2 = "as the average of others."
        public static let reportWalkDayCompareLess = "day less"
        public static let reportWalkDayCompareMore = "day more"
        public static let reportWalkDayCompareSame = "just the same"
        
        public static let reportWalkDayCompareMe = "You"
        public static let reportWalkDayCompareOthers =  "Others"

        public static let reportWalkRecentlyUnit = "mins"
        public static let reportWalkRecentlyText1 = "Your recently walked"
        public static let reportWalkRecentlyText2 = "in average for each walk."
        public static let reportWalkRecentlyTip = "The recommended time for each walk\nis between 20-40 mins."
        
        public static let exploreSeletReport = "Whose posts do you want to see?"
        
        
        //for component
        public static let introductionDefault = "Hello, I am @%s. Let’s be friends!"
        public static let historyCompleted = "%s completed"
        
        
        public static let missionCompletedSaved = "Mission saved."
        public static let walkCompletedSaved = "Mission saved."
        
        public static let walkLocationNotFound = "Where Are You?"
        public static let walkNoWalksText = "No walks today"
        public static let walkMissionCompletedText = "%s missions today"
        
    }
    
}
