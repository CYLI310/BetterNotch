//
//  MediaPlayerBridge.swift
//  BetterNotch
//
//  Created by Justin Li on 2025/12/4.
//

import Foundation
import AppKit

class MediaPlayerBridge {
    
    static let shared = MediaPlayerBridge()
    
    private init() {}
    
    struct MediaInfo {
        let title: String
        let artist: String
        let album: String?
        let artwork: NSImage?
        let isPlaying: Bool
        let playerName: String
    }
    
    func getCurrentMediaInfo(completion: @escaping (MediaInfo?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Try Spotify first
            if let spotifyInfo = self.getSpotifyInfo() {
                DispatchQueue.main.async {
                    completion(spotifyInfo)
                }
                return
            }
            
            // Try Apple Music
            if let musicInfo = self.getAppleMusicInfo() {
                DispatchQueue.main.async {
                    completion(musicInfo)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    private func getSpotifyInfo() -> MediaInfo? {
        let script = """
        tell application "System Events"
            set isRunning to (name of processes) contains "Spotify"
        end tell
        
        if isRunning then
            tell application "Spotify"
                if player state is playing or player state is paused then
                    set trackName to name of current track
                    set artistName to artist of current track
                    set albumName to album of current track
                    set isPlaying to (player state is playing)
                    return trackName & "|||" & artistName & "|||" & albumName & "|||" & isPlaying
                end if
            end tell
        end if
        return ""
        """
        
        guard let result = runAppleScript(script), !result.isEmpty else {
            return nil
        }
        
        let components = result.components(separatedBy: "|||")
        guard components.count >= 4 else { return nil }
        
        return MediaInfo(
            title: components[0],
            artist: components[1],
            album: components[2],
            artwork: getSpotifyArtwork(),
            isPlaying: components[3] == "true",
            playerName: "Spotify"
        )
    }
    
    private func getAppleMusicInfo() -> MediaInfo? {
        let script = """
        tell application "System Events"
            set isRunning to (name of processes) contains "Music"
        end tell
        
        if isRunning then
            tell application "Music"
                if player state is playing or player state is paused then
                    set trackName to name of current track
                    set artistName to artist of current track
                    set albumName to album of current track
                    set isPlaying to (player state is playing)
                    return trackName & "|||" & artistName & "|||" & albumName & "|||" & isPlaying
                end if
            end tell
        end if
        return ""
        """
        
        guard let result = runAppleScript(script), !result.isEmpty else {
            return nil
        }
        
        let components = result.components(separatedBy: "|||")
        guard components.count >= 4 else { return nil }
        
        return MediaInfo(
            title: components[0],
            artist: components[1],
            album: components[2],
            artwork: nil,
            isPlaying: components[3] == "true",
            playerName: "Music"
        )
    }
    
    private func getSpotifyArtwork() -> NSImage? {
        if let spotifyApp = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == "com.spotify.client" }) {
            return spotifyApp.icon
        }
        return nil
    }
    
    func playPause(player: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let script: String
            if player == "Spotify" {
                script = "tell application \"Spotify\" to playpause"
            } else {
                script = "tell application \"Music\" to playpause"
            }
            _ = self.runAppleScript(script)
        }
    }
    
    func nextTrack(player: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let script: String
            if player == "Spotify" {
                script = "tell application \"Spotify\" to next track"
            } else {
                script = "tell application \"Music\" to next track"
            }
            _ = self.runAppleScript(script)
        }
    }
    
    func previousTrack(player: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let script: String
            if player == "Spotify" {
                script = "tell application \"Spotify\" to previous track"
            } else {
                script = "tell application \"Music\" to previous track"
            }
            _ = self.runAppleScript(script)
        }
    }
    
    private func runAppleScript(_ source: String) -> String? {
        var error: NSDictionary?
        guard let scriptObject = NSAppleScript(source: source) else {
            return nil
        }
        
        let output = scriptObject.executeAndReturnError(&error)
        
        if let error = error {
            print("AppleScript Error: \(error)")
            return nil
        }
        
        return output.stringValue
    }
}
