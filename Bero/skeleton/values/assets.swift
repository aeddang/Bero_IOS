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
    public static let noImg16_9 = "present"
    public static let noImg4_3 = "present"
    public static let noImg1_1 = "present"

}
extension Asset{
    
    
    struct brand {
        public static let logoLauncher =  "launcher"
        public static let logoWhite =  "logo_text"
        public static let logoPupping =  "logo_dog"
    }
    struct gnb {
        public static let walk = Asset.icon.paw
        public static let matching = Asset.icon.favorite_on
        public static let diary = Asset.icon.calendar
        public static let my = Asset.image.profile_user_default
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
        public static let lightening = "lightening"
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
        public static let checked_circle_green = "checked_circle_green"
        public static let goal = "goal"
        
        public static let favorite_off = "favorite_off"
        public static let favorite_on = "favorite_on"
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
        public static let drag_handle = "drag_handle"
        public static let female = "female"
        public static let food = "food"
        public static let human_friends = "human_friends"
        public static let male = "male"
        public static let point = "point"
        public static let remove_friend = "remove_friend"
        public static let vet = "vet"
        public static let hi = "hi"
    }
    

    struct image {
        public static let dog1 = "dog1"
        public static let dog2 = "dog2"
        public static let dog3 = "dog3"
        public static let dog4 = "dog4"
        public static let manWithDog = "manWithDog"
        public static let womanWithDog = "womanWithDog"
        public static let man = "man"
        public static let woman = "woman"
        public static let present = "present"
        public static let addDog = "add_dog"
        
        public static let profile_dog_default = "profile_dog_default"
        public static let profile_user_default = "profile_user_default"
        public static let profile_deco = "profile_deco"
    }
    struct shape {
        public static let point = "sp_point"
        public static let ellipse = "sp_ellipse"
        
       
    }
    struct ani {
        //public static let mic:[String] = (1...27).map{ "imgSearchMic" + $0.description.toFixLength(2) }
    }

}
