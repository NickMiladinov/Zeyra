## Group: Initialization and State Loading

This group tests the initial state of the notifier and the `_loadFiles` method.

---

### Test 1 (Initial State - No User)

Initial state is loading, then settles on an empty list if no user is logged in.

**Scenario:** The `userSpecificDatabaseHelperProvider` returns `null`.

**Assert:** The notifier's initial state is `AsyncValue.loading()`. It then transitions to `AsyncValue.data([])` without throwing an error.

### Test 2 (Initial State - With User)

`_loadFiles` successfully loads and sets files on initialization.

**Scenario:** Provide a mock `DatabaseHelper` that returns a list of two valid file metadata maps.

**Assert:** The state transitions from `AsyncValue.loading()` to `AsyncValue.data()` containing a list of two `MedicalFile` objects.

### Test 3 (Initial State - DB Error)

State becomes `AsyncValue.error` if `_loadFiles` throws an exception.

**Scenario:** The mock `DatabaseHelper`'s `getMedicalFilesMetadata` method is configured to throw an exception.

**Assert:** The notifier's final state is an `AsyncValue.error` instance containing the thrown exception.

### Test 4 (refreshFiles)

Calling `refreshFiles` re-triggers the file loading logic.

**Scenario:** After a successful initial load, call `refreshFiles`.

**Assert:** The `getMedicalFilesMetadata` method on the mock `DatabaseHelper` is called a second time.

---

## Group: pickAndSecureFile Method

This group tests the file addition workflow, including all success and failure paths.

---

### Test 1 (Success Flow)

On success, the method returns `true` and reloads the file list.

**Scenario:** The mock `SecureFileStorageService` successfully returns a new `MedicalFile` object.

**Assert:** The method returns `true`, and the `_loadFiles` method is called again to refresh the state.

### Test 2 (User Cancellation)

Handles a `null` result from the service gracefully.

**Scenario:** The `pickAndSecureFile` method on the service returns `null` (simulating the user canceling the file picker).

**Assert:** The method returns `false`, and the state of the notifier does not change. `_loadFiles` is not called.

### Test 3 (Duplicate File Exception)

Catches `DuplicateFileException` and updates the state to error.

**Scenario:** The service throws a `DuplicateFileException`.

**Assert:** The method returns `false`, and the notifier's state becomes an `AsyncValue.error` containing the exception.

### Test 4 (Generic Exception)

Catches a generic exception from the service and updates the state to error.

**Scenario:** The service throws a generic `Exception`.

**Assert:** The method returns `false`, and the notifier's state becomes `AsyncValue.error`.

### Test 5 (No User Logged In)

Fails immediately if no user is logged in.

**Scenario:** The notifier is initialized with a `null` `userId`.

**Assert:** The method returns `false` immediately without calling the `SecureFileStorageService`, and the state is updated to `AsyncValue.error`.

---

## Group: decryptFile Method

This group tests the logic for decrypting a single file.

---

### Test 1 (Success Flow)

Returns the decrypted file bytes on success.

**Scenario:** The `decryptFile` method on the service successfully returns a `Uint8List`.

**Assert:** The method returns the correct `Uint8List` data. The notifier's state remains unchanged.

### Test 2 (Decryption Failure)

Returns `null` if the service fails to decrypt.

**Scenario:** The service's `decryptFile` method returns `null` (e.g., key not found, file corrupted).

**Assert:** The method returns `null`.

### Test 3 (Generic Exception)

Returns `null` if the service throws an exception.

**Scenario:** The service's `decryptFile` method throws an `Exception`.

**Assert:** The method returns `null` after catching the exception.

### Test 4 (No User Logged In)

Fails immediately and returns `null` if no user is logged in.

**Scenario:** The notifier is initialized with a `null` `userId`.

**Assert:** The method returns `null` without calling the `SecureFileStorageService`.

---

## Group: deleteMedicalFile Method

This group tests the complete file deletion workflow.

---

### Test 1 (Success Flow)

Deletes from services and refreshes the file list.

**Scenario:** Both the `SecureFileStorageService` and `DatabaseHelper` mocks complete their deletion methods successfully.

**Assert:** The method returns `true`, and `_loadFiles` is called at the end to refresh the state.

### Test 2 (Secure Storage Fails)

Aborts if the encrypted file and key cannot be deleted.

**Scenario:** The `deleteEncryptedFileAndKey` method on the service returns `false`.

**Assert:** The method returns `false`. The `deleteMedicalFileMetadata` method on the `DatabaseHelper` is never called. The state does not change.

### Test 3 (Database Fails)

Handles exceptions during metadata deletion and sets the state to error.

**Scenario:** The `SecureFileStorageService` deletion succeeds, but the `deleteMedicalFileMetadata` method on the `DatabaseHelper` throws an exception.

**Assert:** The method returns `false`, and the notifier's state becomes `AsyncValue.error`.

### Test 4 (No User Logged In)

Fails immediately if no user is logged in.

**Scenario:** The notifier is initialized with a `null` `userId` or `null` `DatabaseHelper`.

**Assert:** The method returns `false` without calling any service methods.