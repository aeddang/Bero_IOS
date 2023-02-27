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
        public static let neutral = "Nonbinary"
        public static let kmPerH = "kmPerH"
        public static let km = "km"
        public static let m = "m"
        public static let cm = "cm"
        public static let min = "min"
        public static let kg = "kg"
        public static let inch = "”"
        public static let exp = "EXP"
        public static let time = "Time"
        public static let years = "Years"
        public static let months = "Month"
        public static let weight = "Weight"
        public static let height = "Height"
        public static let immunization = "Immunization"
        public static let animalChip = "Animal chip"
        public static let animalId = "Animal ID"
        public static let microchip = "Microchip"
        public static let today = "Today"
        public static let walk = "Walk"
        public static let walks = "Walks"
        public static let near = "Near"
        public static let likes = "Likes"
        public static let share = "Share"
        public static let missions = "Missions"
        public static let stores = "Stores"
        public static let dogs = "Dogs"
        public static let users = "Users"
        public static let place = "Place"
        public static let filter = "Filter"
        
        public static let speed = "Speed"
        public static let distance = "Distance"
        public static let owners = "'s"
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
        public static var networkError = "We've lost your connection."
        public static var dataError = "No data."
        
        public static var location = "Please allow location access."
        public static var locationText = "According to Apple's policy, you must allow location access to send us your location"
        public static var locationBtn = "Go to grant permission"
        
        public static var locationDisable = "Unable to get location information. try again?"
        public static var locationFind = "Retrieving location information. Please wait."
        public static var dragdown = "Pull to close this page"
        
        public static var snsLoginError = "After login. Available."
        public static var getUserProfileError = "Failed to retrieve user information, Please try again in a few minutes"
        
        public static var addDogTitle = "Tell us about your dog!"
        public static var addDogText = "Add your dog and start this app."
        
        
        public static var completedError = "Save fail. retry."
        public static var completedNeedPicture = "Capture your moment to get rewards!"
        public static var completedNeedPictureError = "Need picture with your Dog. retry."
        public static var completedExitConfirm = "If you exit without receiving a reward, the completed walk record will not be saved. Are you sure you want to quit?"
        public static var completedAndMoveHistoryConfirm = "Would you like to check the walk result?"
        
        public static var noItemsSelected = "No items selected."
        
        public static var walkDisableRemovePet = "You cannot manage dogs while walking."
        public static var walkDisableEmptyWithPet = "Choose who you would like to walk with. You can switch it on My Page next time."
        
        public static var representativePetChangeConfirm = "Do you want to switch the main dog?"
        public static var representativeDisableRemovePet = "You cannot delete a main dog."
        
        public static var walkFinishWithMissionConfirm = "As you cancel, the mission will also end."
        public static var missionStartNeedWalkConfirm = "You can start the mission while walking. Would you like to start walking?"
        public static var missionCancelConfirm = "Do you want to quit the mission?"
        public static var missionStartPrevMissionCancel = "The mission is already in progress. play mission quit and retry."
        public static var missionStart = "Start the mission now."
        
        
        public static var friendRequest = "Friend request has been sent."
        public static var friendAccept = "Friend request has been accepted"
        public static var friendDeleteConfirm = "Do you want to remove %s as your friend?"
        
        public static var profileDeleteConfirm = "Remove profile photo?"
        public static var profileDeleteConfirmText = "It may not be restored once you delete."
        
        public static var chatRoomDeleteConfirm = "Do you want to leave the chatroom??"
        public static var chatRoomDeleteConfirmText = "The chat history will be permanently deleted, but still remains on the other user’s chat room."
        
        
        public static var chatDeleteConfirm = "Do you want to delete message?"
        public static var chatDeleteConfirmText = "The message will be deleted, and it will be shown as “Deleted message” on chatroom."
        
        public static var closeConfirm = "Do you want to quit?"
        public static var closeConfirmText = "Once you quit, the entered information will disappear."
        
        public static var accuseUserConfirm = "Do you want to report %s?"
        public static var accuseUserConfirmText = "As your report submitted, Bero administration team will take care of the issue. Continue to submit report."
        public static var accuseUserCompleted = "Report submitted."
        
        public static var accuseAlbumConfirm = "Do you want to report this post??"
        public static var accuseAlbumConfirmText = "As your report submitted, Bero administration team will take an action  after review shortly. "
        public static var accuseAlbumCompleted = "Report submitted."
        
        public static var firstChatMessage = "In the case of using inappropriate post or language, i agree that account suspension and use of Bero app may not be possible according to the terms and conditions."
        
        public static var needAgreement = "You should agree to the terms and conditions before using it."
        
          
        public static var blockUserConfirm = "Do you want to block %s?"
        public static var blockUserConfirmText = "Blocking user means your account may not be found by the user. You may unblock the user from Manage block list."
        public static var blockUserCompleted = "Blocked."
        
        public static var unblockUserConfirm = "Do you want to unblock %s?"
        public static var unblockUserCompleted = "Unblocked."
        
        public static var deleteAccountCheck = "Available after subscriber authentication."
        public static var deleteAccountConfirm = "Are you sure you want to delete your account?"
        public static var deleteAccountConfirmText = "Once you delete account permanently, it may not be restored again."
        public static var deleteAccounErrorAnotherSns = "The signed in account is different from the linked account"
        
        public static var deleteDogTitle = "Are you sure you want to delete %s’s profile?"
        public static var deleteDogText = "It may not be restored, once all of data, information, and history of selected dog deleted."
        public static var deleteConfirm = "Delete"
        
        public static var exposeConfirm = "Would you upload this photo "
        public static var exposed = "Public view"
        public static var unExposed = "Friends view only"
        
        public static var comingSoon = "Coming soon"
        public static var supportAction = "Support action"
        
        public static var signOutConfirm = "Are you sure you want to sign out?"
        public static var signOutConfirmText = "Once you sign out, you can sign back in whenever you want. See you soon!"
     
    }
    
    struct button {
        public static let later = "Maybe Later"
        public static let ok = "Okay"
        public static let prev = "Prev"
        public static let next = "Next"
        public static let skipNow = "Skip for now"
        public static let close = "Close"
        public static let complete = "Complete"
        public static let goBack = "Go Back"
        public static let save = "Save"
        public static let retry = "Retry"
        public static let reset = "Reset"
        public static let apply = "Apply"
        public static let more = "more"
        public static let delete = "Delete"
        public static let request = "Request"
        public static let remove = "Remove"
        public static let modify = "Modify"
        public static let selectAlbum = "Select from Gallery"
        public static let takeCamera = "Take a photo"
        public static let calendar = "Calendar"
        public static let album = "Album"
        public static let startWalking = "Start the walk"
        public static let startMission = "Start mission"
        public static let finish = "Finish"
        public static let finishTheWalk = "Finish the walk"
        public static let missionComplete = "Mission Complete"
        public static let walkComplete = "Walk Complete"
        public static let information = "Information"
        public static let unregistered = "Unregistered"
        public static let logOut = "Sign out"
        public static let push = "Push"
        
        public static let edit = "Edit"
        
        public static let viewMore = "View more"
        public static let terms = "Terms"
        public static let manageDogs = "Manage dogs"
        public static let addFriend = "Add friend"
        public static let requestFriend = "Request friend"
        public static let removeFriend = "Remove friend"
        public static let chat = "Chat"
        public static let requestSent = "Request sent"
        public static let all = "All"
        public static let returnToAllPosts = "Return to all posts"
        public static let reject = "Reject"
        public static let accept = "Accept"
        public static let checkAll = "Check All"
        public static let reply = "Reply"
        public static let accepAndClose = "Accept and close"
        public static let takeAnotherPhoto = "Take another photo"
        public static let visitProfile = "Visit profile"
        public static let leaveAmark = "Leave a mark"
        public static let hitTheArea = "Hit the area"
        public static let stop = "Stop"
        public static let redeemReward = "Redeem reward"
        public static let privacyAgreement = "Privacy usage agreement"
        public static let accuse = "Report"
        public static let share = "Share"
        public static let deleteRoom = "Delete room"
        public static let accuseUser = "Report user"
        public static let block = "Block"
        public static let unblock = "Unblock"
        public static let deleteAccount = "Delete account"
        public static let viewProfile = "View Profile"
        public static let learnMore = "Learn more"
        public static let manageChat = "Manage Chat"
    }
    
    struct sort {
        public static let all = "All"
        public static let notUsed = "notUsed"
        public static let friends = "Friends"
        public static let myFriends = "My friends"
        public static let aroundMe = "Around me"
        public static let new = "New"
        public static let complete = "Complete"
        public static let restaurant = "Restaurant"
        public static let cafe = "Cafe"
        public static let hospital = "Hospital"
        public static let hotel = "Hotel"
        public static let shop = "Shop"
        public static let vet = "Hospital"
        public static let salon = "Salon"
        public static let friendsText = "My friends’ posts only"
        public static let notUsedText = "invisible"
        public static let restaurantText = "Restaurant"
        public static let cafeText = "Cafe"
        public static let hospitalText = "Hospital"
        public static let hotelText = "Hotel"
        public static let shopText = "Shop"
        public static let vetText = "Hospital"
        public static let salonText = "Salon"
        
    }
    
    struct pageTitle {
        public static let my = "My"
        public static let setup = "Setup"
        public static let explore = "Explore"
        public static let chat = "Chat"
        public static let addDog = "Add a dog"
        public static let history = "History"
        public static let album = "Album"
        public static let tag = "Tags"
        public static let physicalInformation = "Physical information"
        public static let friends = "Friends"
        public static let friendRequest = "Friend request"
        public static let usersFriends = "%s's Friends"
        public static let chatRoom = "Chat room"
        public static let myPoint = "Point"
        public static let myDogs = "My family"
        public static let myProfile = "My Profile"
        public static let myLv = "My heart level"
        public static let dogProfile = "Dog profile"
        public static let healthInformation = "Health information"
        public static let usersDogs = "%s’s family"
        public static let walkHistory = "Walk history"
        public static let walkReport = "Walk report"
        public static let walkSummary = "Walk summary"
        public static let walkPicture = "Walk picture"
        public static let missionHistory = "Mission history"
        public static let completedMissions = "Completed missions"
        
        public static let privacy = "Privacy usage agreement"
        public static let service = "Terms of service agreement"
        public static let blockUser = "Manage block list"
        public static let myAccount = "My account"
        public static let alarm = "Alarm"
    }
    
    
    struct pageText {
        //for page
        public static let introText1_1 = "Walk your dog\nwith fun missions."
        public static let introText1_2 = "Meet other friends on the walk and\nget rewards from daily missions."
        public static let introText2_1 = "Save the\nunforgettable walk."
        public static let introText2_2 = "Capture the moments with your\ndog on the calendar."
        public static let introText3_1 = "Find dog-friendly\nplaces near you."
        public static let introText3_2 = "Filter places for your dog and leave\ntraces of your visits."
        public static let introComplete = "Let’s explore!"
        
        public static let loginText = "Let’s walk\nour dogs together!"
        public static let loginButtonText = "Continue with "
        
        public static let addDogCompletedText1 = "Nice to meet you"
        public static let addDogCompletedText2 = "Are you ready to go through the fun walks and meet other friends?"
        public static let addDogCompletedConfirm = "Let's explore!"
        public static let addDogEmpty = "No dog added yet."
        
        public static let myLvText = "Earn friendship to level up your heart!"
        public static let myLvText1 = "How to earn friendship"
        public static let myLvText2 = "Hi %s!"
        public static let myLvText3 = "Welcome to %s!"
        public static let myLvText4 = "Earn +%s friendship to level up!"
        
        public static let myPointText1 = "Collect rewards by walking your dog and change it into our virtual currency."
        public static let myPointText2 = "Store is coming soon"
     
        public static let earningHistory = "Earning history"
        
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
        public static let reportWalkDayCompareText2 = "walking days with others."
        public static let reportWalkDayCompareLess = "below the average of"
        public static let reportWalkDayCompareMore = "above the average of"
        public static let reportWalkDayCompareSame = "right about the same"
        
        public static let reportWalkDayCompareMe = "You"
        public static let reportWalkDayCompareOthers =  "Others"
        
        
        public static let reportWalkRecentlyUnit = "mins"
        public static let reportWalkRecentlyText1 = "You recently walked"
        public static let reportWalkRecentlyText2 = "in average for each walk."
        public static let reportWalkRecentlyTip = "The recommended time for each walk\nis between 20-40 mins."
        
        public static let exploreSeletReport = "Whose posts do you want to see?"
        
        public static let recommandUser = "Friends recommendation"
        public static let aroundUser = "Friends around me"
        public static let needTag = "In order to recommend a friend with a similar personality to my dog First, you need to register your dog's personality tag."
        
        public static let needRoute = "Path creation failed."
        
        
        //for component
        public static let introductionDefault = "Hello, I am @%s. Let’s be friends!"
        public static let historyCompleted = "%s completed"
        
        public static let walkLocationNotFound = "Where Are You?"
        public static let walkPlayText = "Today’s walk"
        public static let walkStartText = "Hi, %s.\nReady to walk?"
        public static let walkMissionCompletedText = "%s missions today"
        
        public static let walkFinishConfirm = "Finish the Walk?"
        public static let walkFinishSuccessTitle = "Here is the Rewards!"
        public static let walkFinishSuccessText = "Hope to see you next time!"
        
        public static let walkFinishFailTitle = "Oops...\nThe image didn’t work."
        public static let walkFinishFailText = "Take another photo with your dog’s face clearly shown in the center."
        
        public static let missionSuccessTitle = "Mission complete!"
        public static let missionSuccessText = "You visited %s during your walk. Receive the reward and continue walking."
        
        public static let walkStartChooseDogTitle = "Start the walk?"
        public static let walkStartChooseDogText = "Choose who you would like to walk with. You can switch it on My Page next time."
        public static let walkPlaceMarkText = "See who’ve visited in this place"
        public static let walkPlaceNoMarkText = "No marks are found yet."
        public static let walkMapMarkText = "%s marks left"
        public static let walkVisitorTitle = "%s marks left"
        public static let walkMissionTitleText = "Visit %s"
        
        public static let walkPlaceMarkDisAbleTitle = "You’re not near the place."
        public static let walkPlaceMarkDisAbleText = "Move closer to the place and let the GPS pinpoint your location."
        
        public static let chatRoomText = "Welcome! Say hello to your new friend. They are excited to hear from you!"
        public static let chatRoomDeletedMessage = "Deleted message"
        
        public static let setupNotification = "Announce Notification?"
        public static let levelUpText = "Level up!"
        
        public static let setupExpose = "auto expose?"
        public static let walkImageLimitedUpdate = "Up to %s photos can be updated"
    }
    
    struct lockScreen {
        //for page
        public static let start = "Today’s walk start"
        public static let walking = "Currently walking..."
        public static let end = "Today’s walk"
    }
}
