import Foundation

struct FootwearPhotoStore {
    static func persistImageData(_ data: Data) throws -> URL {
        let directory = try ensurePhotoDirectory()
        let fileURL = directory.appendingPathComponent("\(UUID().uuidString).jpg")
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }

    private static func ensurePhotoDirectory() throws -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let directory = base.appendingPathComponent("FootwearPhotos", isDirectory: true)

        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory
    }
}
