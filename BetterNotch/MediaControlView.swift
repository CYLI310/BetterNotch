//
//  MediaControlView.swift
//  BetterNotch
//
//  Created by Justin Li on 2025/12/4.
//

import SwiftUI
import MediaPlayer
import Combine

struct MediaControlView: View {
    @StateObject private var mediaManager = MediaPlayerManager()
    
    var body: some View {
        VStack(spacing: 20) {
            if mediaManager.isPlaying || mediaManager.currentTrack != nil {
                // Album art with waveform effect
                HStack(spacing: 20) {
                    // Album art
                    if let artwork = mediaManager.artwork {
                        Image(nsImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(white: 0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.3))
                            )
                    }
                    
                    // Track info and controls
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mediaManager.currentTrack?.title ?? "No Title")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(mediaManager.currentTrack?.artist ?? "Unknown Artist")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Playback controls
                        HStack(spacing: 24) {
                            Button(action: { mediaManager.previousTrack() }) {
                                Image(systemName: "backward.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { mediaManager.togglePlayPause() }) {
                                Image(systemName: mediaManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { mediaManager.nextTrack() }) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(height: 100)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Volume control (simplified)
                HStack(spacing: 12) {
                    Image(systemName: "speaker.fill")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 12))
                    
                    // Custom slider look
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 4)
                            
                            Capsule()
                                .fill(Color.white)
                                .frame(width: geometry.size.width * CGFloat(mediaManager.volume), height: 4)
                        }
                    }
                    .frame(height: 4)
                    
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 12))
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                
            } else {
                // No media playing state
                VStack(spacing: 16) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.2))
                    
                    Text("No Media Playing")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("Play music in Spotify or Apple Music")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.3))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct WaveformView: View {
    @State private var animationPhase: CGFloat = 0
    
    let barCount = 40
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 3)
                    .frame(height: barHeight(for: index))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                animationPhase = 1.0
            }
        }
    }
    
    func barHeight(for index: Int) -> CGFloat {
        let frequency = CGFloat(index) / CGFloat(barCount) * .pi * 4
        let amplitude = sin(frequency + animationPhase * .pi * 2) * 0.5 + 0.5
        return 20 + amplitude * 60
    }
}

class MediaPlayerManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTrack: Track?
    @Published var artwork: NSImage?
    @Published var volume: Double = 0.5
    
    private var updateTimer: Timer?
    private var currentPlayer: String?
    
    struct Track {
        let title: String
        let artist: String
        let album: String?
    }
    
    init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        // Update immediately
        updateNowPlayingInfo()
        
        // Then update every 2 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateNowPlayingInfo()
        }
    }
    
    func stopMonitoring() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func updateNowPlayingInfo() {
        MediaPlayerBridge.shared.getCurrentMediaInfo { [weak self] mediaInfo in
            guard let self = self else { return }
            
            if let mediaInfo = mediaInfo {
                print("✅ Media detected: \(mediaInfo.title) by \(mediaInfo.artist) on \(mediaInfo.playerName)")
                self.isPlaying = mediaInfo.isPlaying
                self.currentTrack = Track(
                    title: mediaInfo.title,
                    artist: mediaInfo.artist,
                    album: mediaInfo.album
                )
                self.artwork = mediaInfo.artwork
                self.currentPlayer = mediaInfo.playerName
            } else {
                print("ℹ️ No media currently playing")
                // No media playing
                self.isPlaying = false
                self.currentTrack = nil
                self.artwork = nil
                self.currentPlayer = nil
            }
        }
    }
    
    func togglePlayPause() {
        guard let player = currentPlayer else { return }
        MediaPlayerBridge.shared.playPause(player: player)
        
        // Update state immediately
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.updateNowPlayingInfo()
        }
    }
    
    func nextTrack() {
        guard let player = currentPlayer else { return }
        MediaPlayerBridge.shared.nextTrack(player: player)
        
        // Update state after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateNowPlayingInfo()
        }
    }
    
    func previousTrack() {
        guard let player = currentPlayer else { return }
        MediaPlayerBridge.shared.previousTrack(player: player)
        
        // Update state after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateNowPlayingInfo()
        }
    }
}
