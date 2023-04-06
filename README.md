# YPersistence
_A Core Data wrapper that leverages the power of generics to allow you to work with custom model objects_

Licensing
----------
Y-Persistence is licensed under the [Apache 2.0 license](LICENSE).


Documentation
----------

Documentation is automatically generated from source code comments and rendered as a static website hosted via GitHub Pages at:  https://yml-org.github.io/ypersistence-ios/

Usage
----------

### YPersistence

You will need to instantiate a `PersistenceManager`. This should be called
    on application launch. You should then use Dependency Injection to pass to classes that need it.

The standard initializer lets you specify the modelName, mergePolicy, although it provides sensible defaults for mergePolicy and bundle you need to provide a modelName.

```swift
// Declare an instance of the persistence manager, so that it can be injected where needed.
init(
    modelName: String, 
    mergePolicy: AnyObject = NSErrorMergePolicy, 
    bundle: Bundle = .main
)
```

### PersistenceManager

Each persistence manager has two `NSManagedObjectContext`, `mainContext` and `workerContext`.

`mainContext` returns the main context, suitable for read-only operations.

`workerContext` a new private queue context, suitable for short-lived add, edit, delete operations or for reading from a background thread.


you can perfrom multiple operations on persistence manager like

#### Fetch

Fetches managed object records from Core Data. Returns an array of managed object records matching the (optional) predicate and optionally sorted.
 Throws any error executing the fetch request.

```swift
func fetchRecords<T: DataRecord>(
    predicate: NSPredicate? = nil,
    sortDescriptors: [NSSortDescriptor]? = nil
)
```

Fetches records from Core Data and convert those to models.
    Returns an unsorted array of model objects matching the uids.
    Throws any error executing the fetch request.
    
```swift
func fetchModels<T: RecordToModel>(
    entity: T.Type,
    uids: [T.UidType]? = nil
)
```

Fetches a single matching record from Core Data and convert it to a model object. Returns the matching model object if found, otherwise nil.
    Throws any error executing the fetch request.
    
```swift
func fetchModel<T: RecordToModel>(
    entity: T.Type,
    uid: T.UidType
)
```
#### Delete

Delete all records for an entity (database table). Best to perform on a background thread. Throws any error saving the context after the deletion.

```swift
func manualDeleteAll(
    entityName: String,
    saveEvery: Int = 500,
    context: NSManagedObjectContext? = nil
)
```

Delete entity from Core Data using batch delete. This will not respect rules or relations. Cascade delete of dependent entities will not occur. Throws any error executing the batch delete request or the subsequent save.

```swift
func batchDeleteAll(
    entityName: String,
    context: NSManagedObjectContext? = nil
)
```

Delete records with the matching unique identifier. Throws any error saving the context after the deletion.

```swift
func delete<Record: DataRecord>(entity: Record.Type, uid: Record.UidType)
```

Delete records with the matching unique identifiers. Throws any error saving the context after the deletion.

```swift
func delete<Record: DataRecord>(entity: Record.Type, uids: [Record.UidType])
```

Delete the specified model. Throws any error saving the context after the deletion.

```swift
func deleteModel<Record: ModelRepresentable>(entity: Record.Type, model: Record.ModelType)
```

#### Clear

List of all entities to be erased upon `clear()`. Default is list of all entities in the model, which would erase all entities in the database. Returns an array of entity names to be cleared.

```swift
func entityNamesForClear() -> [String]
```

Clear the datbase model. By default this will fetch a list of entity names. Throws any error executing the delete or subsequent save.

```swift
func clear()
```

#### Save

Converts an array of models to Core Data records and synchronously saves them. Should be called from a non-blocking thread.

```swift
func save<Record>(
    entity: Record.Type,
    models: [Record.ModelType],
    shouldOverwrite: Bool,
    context: NSManagedObjectContext? = nil
)
```

Converts an array of models to Core Data records and saves them.

```swift
func saveWithOverwrite<Record>(
    entity: Record.Type,
    models: [Record.ModelType],
    context: NSManagedObjectContext? = nil
)
```

Similar to `saveWithOverwrite` we have `saveWithoutOverwrite` update the existing records, new records will be inserted, and any duplicates will be removed.

These are some of the operations that you can perfrom on `PersistenceManager`. 

Some operations can be perfrom on `workerContext` and `mainContext`.

```swift
// Asynchronous save method. Performs the save asychronously on the context's queue.
// Returns nil if successful, otherwise returns an error
func saveChanges(_ completion: SaveCompletion? = nil)

// Synchronous save method. Performs the save sychronously on the context's queue.
// Throws any error thrown from `save()` on this context or any parent context.
func saveChangesAndWait() 
```

If you need to perform some work on main thead you can use the below method. If called from the main thread, the block will be executed immediately and synchronously.

```swift
// Here work is the block of work to be executed on the main thread.
func executeOnMain(execute work: @escaping @convention(block) () -> Void)
```

Dependencies
----------

Y-Persistence is not dependent on any external framework.

Installation
----------

You can add Y-Persistence to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Add Packages...**
2. Enter "[https://github.com/yml-org/ypersistence-ios](https://github.com/yml-org/ypersistence-ios)" into the package repository URL text field
3. Click **Add Package**

Contributing to Y-Persistence
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
