//
//  ContentView.swift
//  SupportHELPFlexiibleSync
//
//  Created by Diana Maria Perez Afanador on 17/10/23.
//

import SwiftUI
import RealmSwift

let APPID = "APPID" // Set you APPID for testing
let realmApp = RealmSwift.App(id: APPID)

struct ContentView: View {
    @ObservedObject var app: RealmSwift.App = realmApp
    @State var isRealmOpen: Bool = false

    // View to test the bundle realm data and synchronisation
    var body: some View {
        VStack {
            if isRealmOpen,
                let user = app.currentUser {
                NewView()
                    .environment(\.realmConfiguration, user.flexibleSyncConfiguration())
            } else {
                ProgressView()
            }
        }
        .padding()
        .task {
            await openRealm()
        }
    }

    func openRealm() async {
        do {
            let myActor = MyActor()
            let user = try await app.login(credentials: .anonymous)
            try await myActor.openRealm(user: user)
            isRealmOpen = true
            print(await myActor.getDataCount())
        } catch {
            print(error)
        }
    }
}

struct NewView: View {
    @ObservedResults(Dog.self) var dogs

    var body: some View {
        NavigationStack {
            ZStack {
                List(dogs) { dog in
                    HStack {
                        Text(dog.name)
                        Text(dog.age, format: .number)
                    }
                }
            }
            .navigationBarItems(trailing: Button("Add", action: {
                Task {
                    create()
                }
            }))
        }
    }

    func create() {
        let dog = Dog()
        dog.name = "Tomas"
        dog.age = 7
        dog.breed = "Mixed"
        $dogs.append(dog)
    }
}

actor MyActor {
    private var realm: Realm!

    init() {}

    func openRealm(user: User) async throws {
        Logger.shared.level = .all

        // get path for the bundle realm
        let bundleRealmURL = Bundle.main.url(forResource: "bundleRealm", withExtension: ".realm")
        print("The bundled realm URL is: \(String(describing: bundleRealmURL))")
        // Create a configuration for the app user's realm, you can use a configuration with some
        // initial subscriptions or you can add them later.
        var newUserConfig = user.flexibleSyncConfiguration(initialSubscriptions: { subs in
            subs.append(QuerySubscription<Dog> { $0.name == "Tomas" })
            subs.append(QuerySubscription<Dog> { $0.name == "Manuela" })// The subscriptions used can be the same as the ones from the bundle realm or you can create extra subscriptions over you bundle realm, and this will be added on top of the subscriptions from the original realm.
        }, rerunOnOpen: true)
        // When you use the `seedFilePath` parameter, this copies the
        // realm at the specified path for use with the user's config
        newUserConfig.seedFilePath = bundleRealmURL
        // Open the synced realm, downloading any changes before opening it.
        // This starts with the existing data in the bundled realm, but checks
        // for any updates to the data before opening it in your application.
        realm = try await Realm(configuration: newUserConfig, actor: self, downloadBeforeOpen: .once)
        print("Successfully opened the bundled realm")
    }

    func getDataCount() -> Int {
        return realm.objects(Dog.self).count
    }

    public func setSubscription<T: Object>(
        name: String,
        query: @escaping ((Query<T>) -> Query<Bool>)
    ) async throws {
        let subscriptions = realm.subscriptions
        try await subscriptions.update {
            // Is this subscription changing to be updated?, this may be why is expecting server changes each time
            if let currentSubscription = subscriptions.first(named: name) {
                currentSubscription.updateQuery(toType: T.self, where: query)
            } else {
                subscriptions.append(QuerySubscription<T>(name: name, query: query))
            }
        }
    }

    public func setSubscription_option<T: Object>(
        name: String,
        query: @escaping ((Query<T>) -> Query<Bool>)
    ) async throws -> Results<T>? {
        let results = try await realm.objects(T.self).where(query).subscribe(name: name, waitForSync: .onCreation, timeout: 20.0)
        return results
    }
}
