//
//  main.swift
//  SupportCreateBundleRealm
//
//  Created by Diana Maria Perez Afanador on 7/11/23.
//

enum App {
    static func main() async {
        let run = Task {
            return await Command().generateBundleRealm()
        }

        await run.value
        run.cancel()
    }
}

import Foundation
import RealmSwift

let APPID = "APPID"

struct Command {
    @MainActor
    func generateBundleRealm() async {
        let app = RealmSwift.App(id: APPID)

        do {
            let credentials = Credentials.anonymous // Setup user credentials, this user must have permission to the data you want to be embedded in the bundle Realm.
            // Login a user with permissions to the data you want to bundle.
            let user = try await app.login(credentials: credentials)

            // Set current workspace path for output
            let fileManager = FileManager.default
            let currentDirectoryPath = URL(string: fileManager.currentDirectoryPath)!
            let directoryPath = currentDirectoryPath.appendingPathComponent("Output")
            if !FileManager.default.fileExists(atPath: directoryPath.path) {
                try FileManager.default.createDirectory(atPath: directoryPath.path, withIntermediateDirectories: true, attributes: nil)
            }
            let originalRealmPath = directoryPath.appending(path: "bundleRealm.realm")

            // Set the configuration for the synced realm
            var configuration = user.flexibleSyncConfiguration { subs in
                // Specified the Flexible Sync query used to retrieve the data to be stored in the bundle Realm
                subs.append(QuerySubscription<Dog> { $0.name == "Manuela" })
            }

            // Set the file url to your output path
            configuration.fileURL = originalRealmPath
            // Create the realm
            let syncedRealm = try await Realm(configuration: configuration, downloadBeforeOpen: .always)
        } catch {
            print("Error \(error)")
        }
    }
}

await App.main()
