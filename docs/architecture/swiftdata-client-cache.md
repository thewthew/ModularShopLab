# SwiftData client cache

This project uses SwiftData as a small local cache for recently seen clients.

The cache is intentionally not the source of truth. Client search and creation still go through `ClientRepository`:

```text
ClientSearchViewModel
  -> ClientRepository.searchClients(query:)
  -> RecentClientStore.record(results)

ClientFormViewModel
  -> SaveClientUseCase
     -> ClientRepository.createClient/updateClient
     -> RecentClientStore.record(savedClient)
```

## Module boundary

SwiftData lives inside `ClientFeature/Data`:

```text
ClientFeature
├─ Domain
│  ├─ Client
│  ├─ ClientRepository
│  ├─ SaveClientUseCase
│  └─ RecentClientStore
├─ Data
│  ├─ RemoteClientRepository
│  ├─ RecentClientRecord
│  └─ SwiftDataRecentClientStore
└─ UI
   ├─ ClientSearchView
   └─ ClientFormViewModel
```

The UI and use cases depend on the `RecentClientStore` protocol. Only the app composition root creates the concrete SwiftData implementation:

```text
AppDependencies
  -> ModelContainer(RecentClientRecord)
  -> SwiftDataRecentClientStore
  -> ClientFeatureDependencies
```

This keeps SwiftData out of the ViewModels and prevents the app target from becoming a persistence dumping ground.

## Current behavior

- Searched clients are stored after a successful search.
- Created and updated clients are stored after a successful save.
- The Clients tab shows a "Recent clients" section.
- The Home tab shows a compact "Recent clients" section.
- The mock scheme uses an in-memory SwiftData store.
- The standard scheme uses the default on-device SwiftData store.

## Concurrency rule

`SwiftDataRecentClientStore` is `@MainActor` because this sample uses a regular `ModelContext` created from the composition root. That keeps SwiftData access serialized and avoids sharing a mutable `ModelContext` across isolation domains.

If this cache became heavier, the next step would be a dedicated SwiftData actor or model actor. For this project, main-actor isolation is enough because the stored dataset is tiny and only supports lightweight retail UI shortcuts.
