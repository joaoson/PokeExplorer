//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 15/06/25.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - Image Cache Manager

@MainActor
class ImageCacheManager: ObservableObject {
    static let shared = ImageCacheManager()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private let maxMemoryCacheSize = 100 * 1024 * 1024 // 100MB
    private let maxDiskCacheSize = 500 * 1024 * 1024   // 500MB
    private let maxCacheAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    
    private init() {
        memoryCache.totalCostLimit = maxMemoryCacheSize
        memoryCache.countLimit = 200 // Max 200 images in memory
        
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("PokemonImageCache")
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        Task {
            await cleanExpiredCache()
        }
    }
    
    // MARK: - Cache Operations
    
    func cachedImage(for url: String) -> UIImage? {
        let key = NSString(string: url)
        
        if let image = memoryCache.object(forKey: key) {
            return image
        }
        
        if let image = loadImageFromDisk(url: url) {
            // Store in memory cache for faster access
            let cost = Int(image.size.width * image.size.height * 4) // Rough memory cost
            memoryCache.setObject(image, forKey: key, cost: cost)
            return image
        }
        
        return nil
    }
    
    func cacheImage(_ image: UIImage, for url: String) {
        let key = NSString(string: url)
        
        let cost = Int(image.size.width * image.size.height * 4)
        memoryCache.setObject(image, forKey: key, cost: cost)
        
        Task {
            await saveImageToDisk(image, url: url)
        }
    }
    
    // MARK: - Disk Cache Operations
    
    private func loadImageFromDisk(url: String) -> UIImage? {
        let filename = generateFilename(from: url)
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        if let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
           let creationDate = attributes[.creationDate] as? Date,
           Date().timeIntervalSince(creationDate) > maxCacheAge {
            try? fileManager.removeItem(at: fileURL)
            return nil
        }
        
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    private func saveImageToDisk(_ image: UIImage, url: String) async {
        guard let imageData = image.pngData() else { return }
        
        let filename = generateFilename(from: url)
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("❌ Failed to save image to disk: \(error)")
        }
    }
    
    private func generateFilename(from url: String) -> String {
        return url.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
    }
    
    // MARK: - Cache Management
    
    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
    
    func clearDiskCache() async {
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
        } catch {
            print("❌ Failed to clear disk cache: \(error)")
        }
    }
    
    func clearAllCache() async {
        clearMemoryCache()
        await clearDiskCache()
    }
    
    private func cleanExpiredCache() async {
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.creationDateKey])
            
            let expiredFiles = files.filter { fileURL in
                guard let resourceValues = try? fileURL.resourceValues(forKeys: [.creationDateKey]),
                      let creationDate = resourceValues.creationDate else { return false }
                
                return Date().timeIntervalSince(creationDate) > maxCacheAge
            }
            
            for file in expiredFiles {
                try fileManager.removeItem(at: file)
            }
            
            print("🧹 Cleaned \(expiredFiles.count) expired cache files")
        } catch {
            print("❌ Failed to clean expired cache: \(error)")
        }
    }
    
    func getCacheSize() -> (memory: Int, disk: Int) {
        let memorySize = memoryCache.totalCostLimit
        
        var diskSize = 0
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            diskSize = files.reduce(0) { total, fileURL in
                let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                return total + fileSize
            }
        } catch {
            print("❌ Failed to calculate disk cache size: \(error)")
        }
        
        return (memory: memorySize, disk: diskSize)
    }
}

// MARK: - Cached Async Image View

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: String
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @StateObject private var loader = ImageLoader()
    @ObservedObject private var cacheManager = ImageCacheManager.shared
    
    init(
        url: String,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .onAppear {
            loader.loadImage(from: url)
        }
    }
}

// MARK: - Image Loader

@MainActor
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private var currentURL: String?
    private let cacheManager = ImageCacheManager.shared
    
    func loadImage(from urlString: String) {
        // Avoid reloading the same image
        guard urlString != currentURL else { return }
        
        currentURL = urlString
        image = nil
        
        // Check cache first
        if let cachedImage = cacheManager.cachedImage(for: urlString) {
            self.image = cachedImage
            return
        }
        
        // Load from network
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                guard let downloadedImage = UIImage(data: data) else {
                    await MainActor.run {
                        self.isLoading = false
                    }
                    return
                }
                
                // Cache the image
                cacheManager.cacheImage(downloadedImage, for: urlString)
                
                await MainActor.run {
                    // Only update if this is still the current URL
                    if urlString == self.currentURL {
                        self.image = downloadedImage
                    }
                    self.isLoading = false
                }
                
            } catch {
                print("❌ Failed to load image: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Convenience Initializers

extension CachedAsyncImage where Content == Image, Placeholder == ProgressView<EmptyView, EmptyView> {
    init(url: String) {
        self.init(
            url: url,
            content: { $0 },
            placeholder: { ProgressView() }
        )
    }
}

extension CachedAsyncImage where Placeholder == ProgressView<EmptyView, EmptyView> {
    init(
        url: String,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(
            url: url,
            content: content,
            placeholder: { ProgressView() }
        )
    }
}

// MARK: - Cache Statistics View (for debugging)

struct CacheStatisticsView: View {
    @State private var memorySize = 0
    @State private var diskSize = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Image Cache Statistics")
                .font(.headline)
            
            Text("Memory Cache: \(ByteCountFormatter.string(fromByteCount: Int64(memorySize), countStyle: .memory))")
            Text("Disk Cache: \(ByteCountFormatter.string(fromByteCount: Int64(diskSize), countStyle: .file))")
            
            HStack {
                Button("Clear Memory") {
                    ImageCacheManager.shared.clearMemoryCache()
                    updateStats()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Clear All") {
                    Task {
                        await ImageCacheManager.shared.clearAllCache()
                        updateStats()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .onAppear {
            updateStats()
        }
    }
    
    private func updateStats() {
        let stats = ImageCacheManager.shared.getCacheSize()
        memorySize = stats.memory
        diskSize = stats.disk
    }
}
