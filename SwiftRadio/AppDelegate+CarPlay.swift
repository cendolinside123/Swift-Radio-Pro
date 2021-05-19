//
//  AppDelegate+CarPlay.swift
//  SwiftRadio
//
//  Created by Fethi El Hassasna on 2019-02-02.
//  Copyright © 2019 matthewfecher.com. All rights reserved.
//

import Foundation
import MediaPlayer

extension AppDelegate {
    
    func setupCarPlay() {
        playableContentManager = MPPlayableContentManager.shared()
        
        playableContentManager?.delegate = self
        playableContentManager?.dataSource = self
        
        stationsViewController?.setupRemoteCommandCenter()
        stationsViewController?.updateLockScreen(with: nil)
    }
}

extension AppDelegate: MPPlayableContentDelegate {
    
    func playableContentManager(_ contentManager: MPPlayableContentManager, initiatePlaybackOfContentItemAt indexPath: IndexPath, completionHandler: @escaping (Error?) -> Void) {
        
        DispatchQueue.main.async {            
            if indexPath.count == 2 {
                let station = self.carplayPlaylist.stations[indexPath[1]]
                self.stationsViewController?.selectFromCarPlay(station)
            }
            completionHandler(nil)
            
            #if targetEnvironment(simulator)
                // Workaround to make the Now Playing working on the simulator:
                // Source: https://stackoverflow.com/questions/52818170/handling-playback-events-in-carplay-with-mpnowplayinginfocenter
                UIApplication.shared.endReceivingRemoteControlEvents()
                UIApplication.shared.beginReceivingRemoteControlEvents()
            #endif
        }
    }
    
    func beginLoadingChildItems(at indexPath: IndexPath, completionHandler: @escaping (Error?) -> Void) {
        carplayPlaylist.load { error in
            completionHandler(error)
        }
    }
}

extension AppDelegate: MPPlayableContentDataSource {
    
    func numberOfChildItems(at indexPath: IndexPath) -> Int {
        if indexPath.indices.count == 0 {
            return 2 // buat set banyak tab
        }
        
        if indexPath.first == 0 {
            return carplayPlaylist.stations.count
        } else if indexPath.first == 1{
            if indexPath.endIndex == 1 {
                return 1
            } else if indexPath.endIndex == 2 {
                return carplayPlaylist.stations.count
            } else {
                return 0
            }
        } else {
            return 0
        }
        
        
    }
    
    func contentItem(at indexPath: IndexPath) -> MPContentItem? {
        
        
        
        if indexPath.count == 1 {
            // Tab section
            //proses cari index tab
            if indexPath.first == 0 {
                let item = MPContentItem(identifier: "Stations")
                item.title = "Stations 1"
                item.isContainer = true
                item.isPlayable = false
                item.artwork = MPMediaItemArtwork(boundsSize: #imageLiteral(resourceName: "carPlayTab").size, requestHandler: { _ -> UIImage in
                    return #imageLiteral(resourceName: "carPlayTab")
                })
                return item
            } else if indexPath.first == 1 {
                let item = MPContentItem(identifier: "Favorite")
                item.title = "Favorite"
                item.isContainer = true
                item.isPlayable = false
                item.artwork = MPMediaItemArtwork(boundsSize: #imageLiteral(resourceName: "carPlayTab").size, requestHandler: { _ -> UIImage in
                    return #imageLiteral(resourceName: "carPlayTab")
                })
                return item
            } else {
                return nil
            }
        }
        else if indexPath.count == 2 {
            //proses cari index tab
            if indexPath.first == 0, indexPath.item < carplayPlaylist.stations.count {
                // Stations section
                let station = carplayPlaylist.stations[indexPath.item]

                let item = MPContentItem(identifier: "\(station.name)")
                item.title = station.name
                item.subtitle = station.desc
                item.isPlayable = true
                item.isStreamingContent = true

                if station.imageURL.contains("http") {
                    ImageLoader.sharedLoader.imageForUrl(urlString: station.imageURL) { image, _ in
                        DispatchQueue.main.async {
                            guard let image = image else { return }
                            item.artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ -> UIImage in
                                return image
                            })
                        }
                    }
                } else {
                    if let image = UIImage(named: station.imageURL) ?? UIImage(named: "stationImage") {
                        item.artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ -> UIImage in
                            return image
                        })
                    }
                }

                return item
            } else if indexPath.first == 1{
                let item = MPContentItem(identifier: "Pop")
                item.title = "Pop"
                item.isContainer = true
                item.isPlayable = false
                item.artwork = MPMediaItemArtwork(boundsSize: #imageLiteral(resourceName: "carPlayTab").size, requestHandler: { _ -> UIImage in
                    return #imageLiteral(resourceName: "carPlayTab")
                })
                return item
            } else {
                return nil
            }
            
        }
        else if indexPath.count == 3 {
            
            if indexPath.first == 1 {
                
                print("indexPath.last : \(indexPath.last)")
                
                if let index = indexPath.last, index < carplayPlaylist.stations.count {
                    let station = carplayPlaylist.stations[index]

                    let item = MPContentItem(identifier: "\(station.name)")
                    item.title = station.name
                    item.subtitle = station.desc
                    item.isPlayable = true
                    item.isStreamingContent = true

                    if station.imageURL.contains("http") {
                        ImageLoader.sharedLoader.imageForUrl(urlString: station.imageURL) { image, _ in
                            DispatchQueue.main.async {
                                guard let image = image else { return }
                                item.artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ -> UIImage in
                                    return image
                                })
                            }
                        }
                    } else {
                        if let image = UIImage(named: station.imageURL) ?? UIImage(named: "stationImage") {
                            item.artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ -> UIImage in
                                return image
                            })
                        }
                    }

                    return item
                } else {
                    return nil
                }
            } else {
                return nil
            }
            

        }
        else {
            return nil
        }
    }
}
