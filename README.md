![Y—Persistence](https://user-images.githubusercontent.com/1037520/231502247-ab3b7245-1066-482e-856f-6e349945de6e.jpeg)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fyml-org%2Fypersistence-ios%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/yml-org/ypersistence-ios) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fyml-org%2Fypersistence-ios%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/yml-org/ypersistence-ios)  
_A Core Data wrapper that leverages the power of generics to allow you to work with custom model objects._

Licensing
----------
Y—Persistence is licensed under the [Apache 2.0 license](LICENSE).

Documentation
----------

Documentation is automatically generated from source code comments and rendered as a static website hosted via GitHub Pages at:  https://yml-org.github.io/ypersistence-ios/

Usage
----------

### YPersistence

`PersistenceManager` serves as a wrapper for Core Data's `NSPersistentContainer` and also vends managed object contexts for performing core data operations.

You will need to instantiate one `PersistenceManager` per `NSPersistentContainer`. This should be done
    on application launch. You should then use Dependency Injection to pass to classes that need it.

The standard initializer lets you specify the model name, merge policy, and bundle. It provides sensible defaults for merge policy and bundle, but you need to provide a model name.

Prior to first use, you need to call `load` on the persistence manager, which is an asynchronous operation. Usually it is fast, but can take several seconds when a migration needs to occur. 

```swift
import YPersistence

final class AppCoordinator {
    let persistenceManager = PersistenceManager(modelName: "MyModel")
    
    func configure(completion: @escaping () -> Void) {
        // configure analytics, network, etc.
        ...
        
        // configure persistence
        persistenceManager.load { _ in
            completion()
        }
    }
}
```

### PersistenceManager

Each persistence manager has three methods for vending managed object contexts:

`mainContext` returns the main context, suitable for read-only operations on the main thread only.

`workerContext` returns a new private queue context, suitable for short-lived add, edit, or delete operations.

`contextForThread` returns a context that is suitable for read-only operations on the current thread only. When called from the main thread, it will return `mainContext`. When called from a background thread, it will create a new private queue context for that thread (if none yet exists) and cache it.

In most simple use cases, you don't even need to worry about managing contexts because for save and delete operations a local `workerContext` will be created, and for fetch operations the appropriate `contextForThread` will be used. For advanced use cases, we support passing in the context that you wish to use.
 
**Important:** All writing to the Core Data container should be done through short-lived worker contexts. Reading can be done from any context as long as it is done in the same thread on which the context was created.

### Protocols

Y—Persistence leverages the power of generics to allow you to do common operations such as fetch, save, and delete without having to create separate queries for each entity (SQL table). It also lets you convert between Core Data `NSManagedObject` and generic model objects (struct or class). In order for this to work, the model objects need to conform to different protocols.

```swift
// a business object
struct Person {
    let personId: String
    let name: String
}

// a managed object
class PersonRecord: NSManagedObject {
    @NSManaged var id: String!
    @NSManaged var name: String!
}
```

#### `CoreModel`

The `CoreModel` protocol is used to represent any uniquely identifiable model object. It requires a model object to have a unique identifier, but that identifier can be any appropriate type (`String`, `Int`, or `UUID` are common types). Essentially all model objects used in Y—Persistence (whether they be JSON model objects or Core Data `NSManagedObject`s) need to conform to `CoreModel`.

* `UidType: UniqueIdentifier` the type of field that will be used as the unique identifier. 
* `uid: UidType` the unique identifier for this object

```swift
extension Person: CoreModel {
    typealias UidType = String
    public var uid: String { personId }
}

extension PersonRecord: CoreModel {
    typealias UidType = String
    public var uid: String { id ?? "" }
}
```

#### `DataRecord`

The `DataRecord` protocol is used to represent any Core Data record. It extends `CoreModel`, so our records need to be uniquely identifiable (so that we can fetch, delete, or save). It requires:

* `entityName: String` the name of the Core Data entity (SQL table)
* `uidKey: String` the name of the attribute (SQL column) that serves as unique key. Defaults to "uid".

```swift
extension PersonRecord: DataRecord {
    static var entityName: String { "PersonRecord" }
    static var uidKey: String { "id" }    
}
```

#### `ModelRepresentable`

The `ModelRepresentable` protocol is used to represent any Core Data record that can be associated with a model object (which can be any struct or class that conforms to `CoreModel`). This will be used to help convert between the Core Data record and a business model object.

* `ModelType: CoreModel` the associated model object for this type of record.
* `uid: ModelType.UidType` the record's unique identifier (which matches the associated model's unique identifier).

```swift
extension PersonRecord: ModelRepresentable {
    typealias ModelType = Person
}
```

#### `RecordFromModel`

The `RecordFromModel` protoocl is used to represent any Core Data record that can be populated from an associated model object. Common use case: save records to Core Data from model objects returned from an API call.

* `func fromModel(_ model: ModelType)` populates the Core Data record from a model object.

```swift
extension PersonRecord: RecordFromModel {
    func fromModel(_ model: Person) {
        id = model.personId
        name = model.name
    }
}
```

#### `RecordToModel`

The `RecordToModel` protocol is used to represent any Core Data record that can be used to populate an associated model object. Common use case: fetch records from Core Data as model objects that can be used in API POST request (or handed off to UI as thread-safe model objects).

* `func toModel() -> ModelType` converts the Core Data record to a model object.

```swift
extension PersonRecord: RecordToModel {
    func toModel() -> Person {
        Person(
            personId: id ?? "",
            name: name ?? ""
        )
    }
}
```

### Common Operations

Conforming to some of the protocols above allows Y—Persistence to perform generic operations such as fetch, save, and delete without having to build unique queries for each different entity (SQL table) in your Core Data model.

#### Fetch

Fetching can be done by a single uid or an array of uids and can return either a record (`NSManagedObject` subclass) or a model.

```swift
func fetchPerson(uid: String) throws -> Person? {
    try persistenceManager.fetchModel(entity: PersonRecord.self, uid: uid)
}

func fetchPeople(uids: [String]) throws -> [Person] {
    try persistenceManager.fetchModel(entity: PersonRecord.self, uids: uids)
}
```

#### Delete

Deletes can be performed by passing uids or by passing single or multiple model objects (from which the uid is extracted).

```swift
func deletePeople(by uids: [String]) throws {
    try persistenceManager.deleteRecords(entity: PersonRecord.self, uids: uids)
}

func delete(person: Person) throws {
    try persistenceManager.deleteModel(entity: PersonRecord.self, model: person)
}

func delete(people: [Person]) throws {
    try persistenceManager.deleteModels(entity: PersonRecord.self, models: people)
}
```

#### Save

Saves can be performed on an array of model objects and can optionally overwrite existing records. Use `shouldOverwrite: true` when replacing local records with remote models or `false` when you are caching results of a paged fetch.

```swift
func save(people: [Person]) throws {
    try persistenceManager.save(
        entity: PersonRecord.self, 
        models: people,
        shouldOverwrite: true
    )
}
```

Installation
----------

You can add Y—Persistence to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Add Packages...**
2. Enter "[https://github.com/yml-org/ypersistence-ios](https://github.com/yml-org/ypersistence-ios)" into the package repository URL text field
3. Click **Add Package**

Contributing to Y—Persistence
----------

### Requirements

#### SwiftLint (linter)
```
brew install swiftlint
```

#### Jazzy (documentation)
```
sudo gem install jazzy
```

### Setup

Clone the repo and open `Package.swift` in Xcode.

### Versioning strategy

We utilize [semantic versioning](https://semver.org).

```
{major}.{minor}.{patch}
```

e.g.

```
1.0.5
```

### Branching strategy

We utilize a simplified branching strategy for our frameworks.

* main (and development) branch is `main`
* both feature (and bugfix) branches branch off of `main`
* feature (and bugfix) branches are merged back into `main` as they are completed and approved.
* `main` gets tagged with an updated version # for each release
 
### Branch naming conventions:

```
feature/{ticket-number}-{short-description}
bugfix/{ticket-number}-{short-description}
```
e.g.
```
feature/CM-44-button
bugfix/CM-236-textview-color
```

### Pull Requests

Prior to submitting a pull request you should:

1. Compile and ensure there are no warnings and no errors.
2. Run all unit tests and confirm that everything passes.
3. Check unit test coverage and confirm that all new / modified code is fully covered.
4. Run `swiftlint` from the command line and confirm that there are no violations.
5. Run `jazzy` from the command line and confirm that you have 100% documentation coverage.
6. Consider using `git rebase -i HEAD~{commit-count}` to squash your last {commit-count} commits together into functional chunks.
7. If HEAD of the parent branch (typically `main`) has been updated since you created your branch, use `git rebase main` to rebase your branch.
    * _Never_ merge the parent branch into your branch.
    * _Always_ rebase your branch off of the parent branch.

When submitting a pull request:

* Use the [provided pull request template](.github/pull_request_template.md) and populate the Introduction, Purpose, and Scope fields at a minimum.
* If you're submitting before and after screenshots, movies, or GIF's, enter them in a two-column table so that they can be viewed side-by-side.

When merging a pull request:

* Make sure the branch is rebased (not merged) off of the latest HEAD from the parent branch. This keeps our git history easy to read and understand.
* Make sure the branch is deleted upon merge (should be automatic).

### Releasing new versions
* Tag the corresponding commit with the new version (e.g. `1.0.5`)
* Push the local tag to remote

Generating Documentation (via Jazzy)
----------

You can generate your own local set of documentation directly from the source code using the following command from Terminal:
```
jazzy
```
This generates a set of documentation under `/docs`. The default configuration is set in the default config file `.jazzy.yaml` file.

To view additional documentation options type:
```
jazzy --help
```
A GitHub Action automatically runs each time a commit is pushed to `main` that runs Jazzy to generate the documentation for our GitHub page at: https://yml-org.github.io/ypersistence-ios/
