//
//  TrayView.swift
//  BetterNotch
//
//  Created by Justin Li on 2025/12/4.
//

import SwiftUI
import UniformTypeIdentifiers
import Combine

struct TrayView: View {
    @StateObject private var trayManager = FileTrayManager()
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("File Tray")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                if !trayManager.files.isEmpty {
                    Button(action: { trayManager.clearAll() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Drop Zone / File List
            ZStack {
                if trayManager.files.isEmpty {
                    // Empty Drop Zone
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.down.doc")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.2))
                        
                        Text("Drop Files Here")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                            .foregroundColor(isDragging ? .blue : .white.opacity(0.1))
                    )
                    .padding(20)
                } else {
                    // File List
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 16)], spacing: 16) {
                            ForEach(trayManager.files) { file in
                                FileCard(file: file) {
                                    trayManager.removeFile(file)
                                }
                                .onTapGesture {
                                    trayManager.openFile(file)
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
                trayManager.handleDrop(providers: providers)
                return true
            }
        }
    }
}

struct FileCard: View {
    let file: TrayFile
    let onDelete: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: file.url.path))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                
                VStack(spacing: 2) {
                    Text(file.name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Text(file.sizeString)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .onDrag {
                NSItemProvider(contentsOf: file.url) ?? NSItemProvider()
            }
            
            if isHovering {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.4))
                        .background(Color.black.opacity(0.5).clipShape(Circle()))
                }
                .buttonStyle(.plain)
                .offset(x: 4, y: -4)
            }
        }
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

struct TrayFile: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    let icon: NSImage
    let size: Int64
    
    var sizeString: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

class FileTrayManager: ObservableObject {
    @Published var files: [TrayFile] = []
    
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    self.addFile(url: url)
                }
            }
        }
        return true
    }
    
    func addFile(url: URL) {
        DispatchQueue.main.async {
            // Check if file already exists
            guard !self.files.contains(where: { $0.url == url }) else { return }
            
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            
            // Get file size
            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
            let size = attributes?[.size] as? Int64 ?? 0
            
            let file = TrayFile(
                name: url.lastPathComponent,
                url: url,
                icon: icon,
                size: size
            )
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                self.files.append(file)
            }
        }
    }
    
    func removeFile(_ file: TrayFile) {
        withAnimation {
            files.removeAll { $0.id == file.id }
        }
    }
    
    func openFile(_ file: TrayFile) {
        NSWorkspace.shared.open(file.url)
    }
    
    func clearAll() {
        withAnimation {
            files.removeAll()
        }
    }
}
