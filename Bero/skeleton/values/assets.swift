//
//  asset.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/15.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
struct Asset {}
extension Asset {
    public static let appIcon = "launcher"
    public static let appIconCircle = "app_icon_circle"
    public static let noImg16_9 = "noimage_16_9"
    public static let noImg4_3 = "noimage_4_3"
    public static let noImg1_1 = "noimage_1_1"

}
extension Asset{
    
    
    struct brand {
        public static let logoLauncher =  "launcher"
        public static let logoWhite =  "logo_text"
        public static let logoPupping =  "logo_dog"
    }
    struct gnb {
        public static let walk = Asset.icon.paw
        public static let explore = Asset.icon.explore
        public static let chat = Asset.icon.chat
        public static let matching = Asset.icon.favorite_on
        public static let diary = Asset.icon.calendar
        public static let my = Asset.icon.my
    }
    struct map {
         
        public static let pinMission = "pin_mission"
        public static let pinMissionOn = "pin_mission_on"
        public static let pinMissionCompleted = "pin_mission_mark"
        
        public static let pinUser = "pin_user"
        
        public static let pinCafe = "pin_cafe"
        public static let pinPark = "pin_park"
        public static let pinVet = "pin_vet"
        
        public static let pinCafeMark = "pin_cafe_mark"
        public static let pinParkMark = "pin_park_mark"
        public static let pinVetMark = "pin_vet_mark"
        
        public static let myLocationOff = "pin_my_location_off"
        public static let myLocationOn = "pin_my_location_on"
        public static let myWalkingOff = "pin_my_walking_off"
        public static let myWalkingOn = "pin_my_walking_on"
        public static let locator = "locator"
        
    }
    
   
    struct icon {
        public static let calendar = "calendar"
        public static let copy = "copy"
        public static let delete = "delete"
        public static let edit = "edit"
        public static let filter_filled = "filter_filled"
        public static let schedule = "schedule"
        public static let search = "search"
        public static let settings = "settings"
        public static let sync = "sync"
        public static let exp = "exp"
        public static let arrow_right = "arrow_right"
        public static let back = "back"
        public static var close = "close"
        public static let direction_down = "direction_down"
        public static let direction_left = "direction_left"
        public static let direction_right = "direction_right"
        public static let direction_up = "direction_up"
        public static let more_vert = "more_vert"
        public static let refresh = "refresh"
        public static let swap_horizontal = "swap_horizontal"
        
        public static let add_circle_filled = "add_circle_filled"
        public static let add_circle_outline = "add_circle_outline"
        public static let check = "check"
        public static let checked_circle = "checked_circle"
        public static let erase = "erase"
        public static let status_normal = "status_normal"
        public static let status_warning = "status_warning"
        
        public static let notification_off = "notification_off"
        public static let notification_on = "notification_on"
        public static let chat  = "chat"
        public static let sms = "sms"
        
        public static let add_photo = "add_photo"
        public static let album  = "album"
        public static let chart  = "chart"
        public static let lightening_circle = "lightening_circle"
        public static let paw = "paw"
        public static let shopping_cart = "shopping_cart"
        public static let view_gallery = "view_gallery"
        public static let map = "map"
        
        public static let fast_forward  = "fast_forward"
        public static let fast_rewind = "fast_rewind"
        public static let play_circle_filled = "play_circle_filled"
        public static let play_circle_outline = "play_circle_outline"
        public static let stop =  "stop"
        public static let pause =  "pause"
       
        public static let difficulty_easy = "difficulty_easy"
        public static let difficulty_hard = "difficulty_hard"
        public static let double_arrow = "double_arrow"
        public static let explore = "explore"
        public static let navigation_filled  = "navigation_filled"
        public static let navigation_outline  = "navigation_outline"
        public static let place_pin = "place_pin"
        public static let walk  = "walk"
        public static let weather_sunny  = "weather_sunny"
        public static let speed  = "speed"
        
        public static let beenhere = "beenhere"
        public static let my_location  = "my_location"
        public static let add_location = "add_location"
        public static let arrived = "arrived"
        public static let goal = "goal"
        
        public static let favorite_off = "favorite_off"
        public static let favorite_on = "favorite_on"
        public static let favorite_on_big = "favorite_on_big"
        public static let star_off  = "star_off"
        public static let star_on  = "star_on"
        
        public static let dog_friends = "dog_friends"
        public static let google  = "google"
        public static let health = "health"
        public static let tag = "tag"
        public static let vaccine = "vaccine"
        
        public static let add_friend = "add_friend"
        public static let add = "add"
        public static let ball = "ball"
        public static let beauty = "beauty"
        public static let bone = "bone"
        public static let coin = "coin"
        public static let female = "female"
        public static let food = "food"
        public static let human_friends = "human_friends"
        public static let male = "male"
        public static let point = "point"
        public static let remove_friend = "remove_friend"
        public static let vet = "vet"
        public static let hi = "hi"
        public static let cloudy = "cloudy"
        public static let rain = "rain"
        public static let lightening = "lightening"
        public static let sunny = "hi"
        public static let minimize = "minimize"
        public static let maximize = "maximize"
        public static let send = "send"
        public static let place = "place"
        public static let my = "my"
        public static let share = "share"
        public static let block = "block"
        public static let notice = "notice"
        public static let search_user = "search_user"
        public static let camera = "camera"
        public static let pin_drop = "pin_drop"
        public static let neutralized = "neutralized"
        public static let global = "global"
        public static let warning = "warning"
        public static let route_flag = "route_flag"
        public static let exit = "exit"
        public static let account = "account"
        public static let policy = "policy"
        public static let terms = "terms"
        public static let store = "store"
    }
    

    struct image {
        public static let present = "present"
        public static let addDog = "add_dog"
        public static let puppy = "puppy"
        public static let profile_dog_default = "profile_dog_default"
        public static let profile_user_default = "profile_user_default"
        public static let profile_deco = "profile_deco"
        public static let route_bg = "route_bg"
        
    }
    
    struct intro {
        public static let onboarding_img_0 = "onboarding_img_0"
        public static let onboarding_img_1 = "onboarding_img_1"
        public static let onboarding_img_2 = "onboarding_img_2"
        public static let onboarding_img_3 = "onboarding_img_3"
        
    }
    struct shape {
        public static let point = "sp_point"
        public static let ellipse = "sp_ellipse"
        
       
    }
    struct ani {
        //public static let mic:[String] = (1...27).map{ "imgSearchMic" + $0.description.toFixLength(2) }
    }
    struct character {
        public static let rand:[String] = (1...5).map{ "character_" + $0.description }
        public static let randOn:[String] = (1...5).map{ "character_" + $0.description + "_on" }
        
    }
    
    struct sound {
        public static let start:String = "start"
        public static let end:String = "end"
        public static let push:String = "push"
        public static let reward:String = "reward"
        public static let find:String = "find"
        public static let success:String = "success"
        public static let ready:String = "ready"
        public static let tick:String = "tick"
        public static let shotLong:String = "shot_long"
        public static let shot:String = "shot"
        
        public static let mission:String = "mission"
        public static let walk:String = "walk"
    }
}
