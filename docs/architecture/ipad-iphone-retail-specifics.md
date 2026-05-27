# iPad / iPhone Retail Specifics

This project intentionally models a retail app where iPhone and iPad do not only differ by layout.
They represent different field workflows.

## Product Rule

The iPhone is a selling device.

- The seller can select a client.
- The seller can start a sale from a product.
- The seller can add products to a cart.
- The seller can checkout with Tap to Pay.

The iPad is an assisted showroom device.

- The seller can browse products with a client.
- The seller can compare and curate products.
- The seller can share a selection with the client.
- The seller cannot create a cart or checkout from the iPad.

This is deliberately stricter than hiding buttons in the UI. The iPad has its own feature module:

```text
ProductShowroomFeature -> ProductCatalog
```

It does not depend on:

```text
CartFeature
PaymentFeature
```

## Why This Is Useful

This tests whether the modular architecture can support real product differences:

- shared product contract through `ProductCatalog`
- platform-specific feature ownership
- no accidental dependency from iPad consultation to cart or payment
- app-level composition through callbacks instead of feature-to-feature imports

## Module Responsibilities

`ProductCatalog` owns the shared product contract:

- `Product`
- `ProductRepository`
- `SearchProductsUseCase`

`ProductFeature` owns the iPhone-oriented product browsing and selling entry points:

- product list
- product detail
- add to cart callback
- start sale callback

`ProductShowroomFeature` owns the iPad-oriented consultation flow:

- showroom grid
- product search UI adapted to iPad
- selected products
- comparison panel
- client-aware presentation
- share-selection callback

The app target remains the composition root:

- it creates `ProductRepository`
- it creates the shared `SearchProductsUseCase`
- it creates the iPad `ProductShowroomViewModel`
- it handles cross-feature actions such as client selection and logging

## Shared Product Search

Product search is intentionally shared at the domain level, not at the screen level.

`ProductCatalog` owns the rule:

```swift
SearchProductsUseCase.execute(query:)
```

The shared behavior is:

- trim whitespace and new lines
- return the full catalog when the query is blank
- call `ProductRepository.searchProducts(query:)` when the query is not blank

The UI stays platform-specific:

- `ProductFeature` uses search inside the iPhone selling list.
- `ProductShowroomFeature` uses search inside the iPad showroom grid.

This avoids two problems:

- duplicating search semantics in each ViewModel
- forcing iPhone and iPad to share the same screen just because they share search behavior

## Dependency Shape

```text
ProductFeature --------\
CartFeature -----------+--> ProductCatalog
FavoritesFeature ------/
ProductShowroomFeature /

ProductFeature --------\
ProductShowroomFeature +--> ProductCatalog.SearchProductsUseCase

App Target -> ProductFeature
App Target -> ProductShowroomFeature
App Target -> CartFeature
App Target -> PaymentFeature
```

The important part is that `ProductShowroomFeature` does not know how selling works.
It only knows how to present and curate products.

## Example Product Fantasy

"On iPad, the seller prepares a premium selection with the client, compares products side by side, and sends the selection by email or SMS. Checkout must happen on iPhone or at the cashier."

This sounds simple, but it prevents shortcuts:

- iPad cannot reuse the iPhone product screen blindly.
- iPad cannot import cart just to reuse add-to-cart behavior.
- shared product data must live outside `ProductFeature`.
- cross-feature actions must be callbacks owned by the app target.
