# capacitor-plugin-photo-library

Photo Library for Capacitor 3

## Install

```bash
npm install capacitor-plugin-photo-library
npx cap sync
```

## API

<docgen-index>

* [`openPhotoPicker()`](#openphotopicker)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### openPhotoPicker()

```typescript
openPhotoPicker() => Promise<{ items: Photo[]; }>
```

**Returns:** <code>Promise&lt;{ items: Photo[]; }&gt;</code>

--------------------


### Interfaces


#### Photo

| Prop            | Type                |
| --------------- | ------------------- |
| **`id`**        | <code>string</code> |
| **`base64`**    | <code>string</code> |
| **`dataUrl`**   | <code>string</code> |
| **`filename`**  | <code>string</code> |
| **`mediaType`** | <code>string</code> |

</docgen-api>
