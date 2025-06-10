# Test Plan: DatabaseHelper

## Group: DatabaseHelper Initialization & Structure
*This group tests the per-user database creation and schema integrity.*

### Test 1 (Creates User-Specific Database): `_initDatabase` creates a database in a directory unique to the `userId`.
- **Scenario:** Instantiate `DatabaseHelper` with `userId: 'user-a'`.
- **Assert:** The `openDatabase` call receives a path containing `.../user_databases/user-a/medical_files.db`.

### Test 2 (Table Creation on `_onCreate`): The `medical_files` table is created with the correct future-proof schema.
- **Scenario:** A new database is created for a user.
- **Assert:** The table schema contains all specified columns (`id`, `user_id`, `created_at`, `last_modified_at`, `version`, `deleted_at`) with their correct types and constraints (PRIMARY KEY, NOT NULL, NULL, DEFAULT 1).

---

## Group: `saveMedicalFileMetadata` Tests
*This group tests the logic for inserting and updating records, including the new system-managed fields.*

### Test 1 (Successful Insert): Successfully inserts a single valid metadata entry and correctly sets system fields.
- **Scenario:** Save a new file record.
- **Assert:** The record is saved, `created_at` and `last_modified_at` are set to the current time, and `version` is set to 1.

### Test 2 (Successful Update): Replaces an entry on duplicate ID and correctly updates system fields.
- **Scenario:** Insert a record. Then insert a second record with the same `id`.
- **Assert:** The new record overwrites the old one, `last_modified_at` is updated, and `version` is incremented.

### Test 3 (Constraint Violation): Throws `DatabaseException` if a `NOT NULL` constraint is violated (e.g., `user_id`).
- **Scenario:** Attempt to save a record with a `null` `user_id` or `original_filename`.
- **Assert:** A `DatabaseException` is thrown.

---

## Group: `getMedicalFileMetadata` Tests
*This group tests all data retrieval methods, ensuring they respect soft deletes.*

### Test 1 (Empty Database): Returns an empty list when the database is empty or contains only soft-deleted items.
- **Scenario:** Query for files when none have been added, or after all existing files have been soft-deleted.
- **Assert:** The method returns an empty list (`[]`).

### Test 2 (Correct Ordering): Returns entries ordered by `created_at` descending.
- **Scenario:** Insert records with different `created_at` timestamps.
- **Assert:** The returned list is ordered from newest to oldest based on creation date.

### Test 3 (Excludes Soft-Deleted Files): All `get` methods correctly filter out records where `deleted_at` is not `NULL`.
- **Scenario:** Add three files. Soft-delete one of them.
- **Assert:** `getMedicalFilesMetadata` returns a list with only two files. `getMedicalFileMetadataById` for the deleted file returns `null`.

---

## Group: `deleteMedicalFileMetadata` (Soft Delete) Tests
*This group specifically tests the soft delete functionality.*

### Test 1 (Successful Soft Delete): Successfully "deletes" an existing entry by updating its fields.
- **Scenario:** Soft-delete an existing file.
- **Assert:** The record is not removed from the database. Instead, its `deleted_at` column is populated with a timestamp, `last_modified_at` is updated, and its `version` number is incremented.

### Test 2 (Non-Existent ID): Attempting to delete a non-existent ID does not error and does not affect other records.
- **Scenario:** Call `deleteMedicalFileMetadata` with a file ID that doesn't exist.
- **Assert:** The function completes without throwing an error, and other records in the database remain unchanged.

### Test 3 (Idempotent): Calling delete on an already soft-deleted file has no effect.
- **Scenario:** Soft-delete a file. Then, call `deleteMedicalFileMetadata` on the same file ID again.
- **Assert:** The `deleted_at` and `version` fields of the record remain unchanged from the first deletion.

---

## Group: User Data Isolation Tests
*This is the most critical group, ensuring a user's `DatabaseHelper` instance can never see or affect another user's data. Note: these tests require instantiating two `DatabaseHelper`s with different `userId`s pointing to the same in-memory database.*

### Test 1 (Get All Files): `getMedicalFilesMetadata` only returns files for the instance's `userId`.
- **Scenario:** Populate a test database with files for `user-a` and `user-b`. Instantiate `DatabaseHelper('user-a')`.
- **Assert:** Calling `getMedicalFilesMetadata` returns only the files belonging to `user-a`.

### Test 2 (Get File by ID): `getMedicalFileMetadataById` returns `null` if the file ID belongs to another user.
- **Scenario:** Using `DatabaseHelper('user-a')`, try to fetch a file ID known to belong to `user-b`.
- **Assert:** The result is `null`.

### Test 3 (Delete File): `deleteMedicalFileMetadata` does not soft-delete a file if the `userId` does not match.
- **Scenario:** Using `DatabaseHelper('user-a')`, try to delete a file ID known to belong to `user-b`.
- **Assert:** The file record for `user-b` remains unchanged (its `deleted_at` is still `NULL`).

### Test 4 (Duplicate Check): `getMedicalFileMetadataByFilenameAndSize` is scoped to the instance's user.
- **Scenario:** `user-a` and `user-b` both have a file named `report.pdf` of the same size.
- **Assert:** Using `DatabaseHelper('user-a')`, the duplicate check correctly finds the file. Using `DatabaseHelper('user-c')` with the same filename and size returns `null`.