## Group: Object Instantiation & Serialization

This group tests the core functionality of creating MedicalFile objects from a map and converting them back.

---

### Test 1 (fromMap - Full Data)

`fromMap` correctly creates an object when all map fields are present.

**Scenario:** Provide a map with all keys, including non-nullable values for `fileType`, `fileSize`, and `deletedAt`.

**Assert:** The created `MedicalFile` object has all properties correctly populated with the expected values and data types.

### Test 2 (fromMap - Nullable Fields)

`fromMap` correctly handles null values for nullable fields.

**Scenario:** Provide a map where the values for `fileType`, `file_size_bytes`, and `deleted_at` are `null`.

**Assert:** The created `MedicalFile` object correctly assigns `null` to the `fileType`, `fileSize`, and `deletedAt` properties.

### Test 3 (fromMap - Type Mismatch)

`fromMap` throws a `TypeError` or `FormatException` if data types in the map are incorrect.

**Scenario:** Provide a map where a `String` is expected but an `int` is given (e.g., `'id': 123`).

**Assert:** The `MedicalFile.fromMap` factory throws an appropriate exception.

### Test 4 (toMap - Full Data)

`toMap` correctly creates a map when all object properties are non-null.

**Scenario:** Create a `MedicalFile` object with values for all properties, including `deletedAt`.

**Assert:** The resulting map contains all the correct key-value pairs, with `DateTime` objects correctly formatted as UTC ISO 8601 strings.

### Test 5 (toMap - Nullable Fields)

`toMap` correctly handles null properties.

**Scenario:** Create a `MedicalFile` object where `fileType`, `fileSize`, and `deletedAt` are `null`.

**Assert:** The resulting map correctly contains `null` values for the `file_type`, `file_size_bytes`, and `deleted_at` keys.

---

## Group: copyWith Method

This group tests the object's immutability and the functionality of the `copyWith` method.

---

### Test 1 (copyWith - Single Field)

`copyWith` creates a new instance with a single updated value.

**Scenario:** Call `copyWith` on an existing instance, changing only the `version` number.

**Assert:** A new object is returned with the updated `version`, while all other properties remain the same as the original. The original object is unchanged.

### Test 2 (copyWith - Multiple Fields)

`copyWith` creates a new instance with multiple updated values.

**Scenario:** Call `copyWith` to update `version`, `lastModifiedAt`, and `deletedAt` simultaneously.

**Assert:** A new object is returned with all specified properties updated correctly.

### Test 3 (copyWith - No Arguments)

`copyWith` with no arguments creates an identical but distinct copy.

**Scenario:** Call `copyWith()` with no parameters.

**Assert:** The new object is equal (`==`) to the original, but it is not the same instance (`identical()` returns false).

---

## Group: Equality and hashCode

This group tests the custom equality (`==`) implementation.

---

### Test 1 (Equality - Identical Objects)

Two separate instances with identical properties are considered equal.

**Scenario:** Create two `MedicalFile` objects (`fileA` and `fileB`) with the exact same property values.

**Assert:** `fileA == fileB` is `true`.

### Test 2 (Equality - Different Objects)

Two instances with at least one different property are not considered equal.

**Scenario:** Create two `MedicalFile` objects that differ only by their `version` number.

**Assert:** `fileA == fileB` is `false`.

### Test 3 (hashCode - Consistency)

Two equal objects have the same `hashCode`.

**Scenario:** Create two `MedicalFile` objects that are considered equal by the `==` operator.

**Assert:** `fileA.hashCode == fileB.hashCode` is `true`.

---

## Group: Computed Properties (Getters)

This group tests the logic of the custom getters `fileSizeFormatted` and `isImage`.

---

### Test 1 (fileSizeFormatted - Bytes)

Correctly formats sizes less than 1 KB.

**Scenario:** `fileSize` is 800.

**Assert:** `fileSizeFormatted` returns "800 B".

### Test 2 (fileSizeFormatted - Kilobytes)

Correctly formats sizes in kilobytes.

**Scenario:** `fileSize` is 1536 (1.5 KB).

**Assert:** `fileSizeFormatted` returns "1.5 KB".

### Test 3 (fileSizeFormatted - Megabytes)

Correctly formats sizes in megabytes.

**Scenario:** `fileSize` is 2097152 (2.0 MB).

**Assert:** `fileSizeFormatted` returns "2.0 MB".

### Test 4 (fileSizeFormatted - Edge Cases)

Correctly handles null, 0, and boundary values.

**Scenario:** `fileSize` is `null`, 0, or 1023.

**Assert:** Returns "N/A", "0 B", and "1023 B" respectively.

### Test 5 (isImage - Image Types)

`isImage` returns `true` for various common image file types.

**Scenario:** `fileType` is set to 'jpg', 'png', 'gif', and 'heic'.

**Assert:** `isImage` returns `true` for all cases.

### Test 6 (isImage - Case Insensitivity)

`isImage` correctly identifies image types regardless of case.

**Scenario:** `fileType` is set to 'JPG' or 'PnG'.

**Assert:** `isImage` returns `true`.

### Test 7 (isImage - Non-Image Types)

`isImage` returns `false` for non-image file types.

**Scenario:** `fileType` is set to 'pdf', 'docx', or `null`.

**Assert:** `isImage` returns `false` for all cases.