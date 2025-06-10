# Unit Test Plan for `SecureFileStorageService`

This document outlines the unit tests for the `SecureFileStorageService`. The service is responsible for securely picking, encrypting, storing, decrypting, and deleting user files, with a strong emphasis on isolating data between different users.

---

### Group: `getSecureStorageDirectory`

This group tests the logic for creating and retrieving the user-specific directory for storing encrypted files.

-   **Test 1 (Creates Directory):** Creates the secure directory for a specific user if it doesn't already exist.
    -   **Scenario:** Call the method for `userId: 'user-a'`. Mock `directoryExists` to return `false`.
    -   **Assert:** The `createDirectory` method is called exactly once with the correct path containing `/user-a`.

-   **Test 2 (Directory Exists):** Does NOT try to create the directory if it already exists for that user.
    -   **Scenario:** Mock `directoryExists` to return `true`. Call the method for `userId: 'user-a'`.
    -   **Assert:** The `createDirectory` method is never called.

---

### Group: `pickAndSecureFile`

This group tests the main public orchestration method that combines file picking and encryption.

-   **Test 1 (Happy Path):** A user successfully picks a file, and it gets encrypted and stored.
    -   **Scenario:** Mock `pickFile` to return a valid `PlatformFile`. Mock `_dbHelper.getMedicalFileMetadataByFilenameAndSize` to return `null` (no duplicate).
    -   **Assert:** The internal `encryptAndStoreFile` method is called with the correct `PlatformFile` and `userId`. The method returns the result from `encryptAndStoreFile`.

-   **Test 2 (User Cancels):** The user cancels the file picker.
    -   **Scenario:** Mock `pickFile` to return `null`.
    -   **Assert:** The method returns `null` immediately, and `encryptAndStoreFile` is never called.

-   **Test 3 (Duplicate File):** The user picks a file that they have already uploaded.
    -   **Scenario:** Mock `pickFile` to return a valid `PlatformFile`. Mock `_dbHelper.getMedicalFileMetadataByFilenameAndSize` to return an existing file's metadata.
    -   **Assert:** The method throws a `DuplicateFileException`, and `encryptAndStoreFile` is never called.

---

### Group: `encryptAndStoreFile`

This group tests the core encryption and storage logic, ensuring all operations are tied to the correct user.

-   **Test 1 (Happy Path):** Successfully encrypts and stores a file for a specific user.
    -   **Scenario:** Provide a valid `PlatformFile` and `userId: 'user-a'`.
    -   **Assert:** Verify that the encryption key is written to secure storage, the encrypted file is written to a path containing `/user-a`, and the `_dbHelper.saveMedicalFileMetadata` call includes `userId: 'user-a'`.

-   **Test 2-5 (Failure Cases & Cleanup):** Handles failures (read fails, write fails, key storage fails, DB fails) and triggers cleanup for the specific user's operation.
    -   **Scenario:** For each failure case, run the operation with `userId: 'user-a'`.
    -   **Assert:** Verify that the cleanup logic (deleting a partially saved file or key) is attempted for the correct user and file path.

-   **Test 6 (Zero-Byte File):** Correctly encrypts and stores an empty file for a specific user.
    -   **Assert:** Ensure all operations correctly associate the empty file with the provided `userId`.

-   **Test 7 (Invalid UserID):** Throws an `ArgumentError` if the `userId` is null or empty.
    -   **Scenario:** Attempt to call the method with a `null` or empty string for the `userId`.
    -   **Assert:** Expect an `ArgumentError` to be thrown immediately, preventing any file operations.

---

### Group: `decryptFile`

This group tests the decryption logic, focusing heavily on security and data access rules.

-   **Test 1 (Happy Path):** Successfully decrypts a file for its rightful owner.
    -   **Scenario:** Call `decryptFile` with `fileId: 'file-123'` and `userId: 'user-a'`. The mock database should return valid metadata for this combination.
    -   **Assert:** The file is successfully decrypted.

-   **Test 2 (Critical Security Test - Wrong User):** Returns `null` when a user tries to decrypt a file belonging to another user.
    -   **Scenario:** The database contains metadata for `fileId: 'file-xyz'` associated with `userId: 'user-b'`. Attempt to call `decryptFile` with `fileId: 'file-xyz'` but with `userId: 'user-a'`.
    -   **Assert:** The mock `_dbHelper.getMedicalFileMetadataById('file-xyz', 'user-a')` should be configured to return `null`. The `decryptFile` method must return `null` without attempting any file I/O or key retrieval.

-   **Test 3 (File Not Found):** Returns `null` if the encrypted file does not exist on disk, even if metadata and key are present.

-   **Test 4 (Key Not Found):** Returns `null` if the key/IV is not found in secure storage.

-   **Test 5 (Data Integrity Failure):** Returns `null` if the encrypted data has been tampered with (GCM tag mismatch).

-   **Test 6 (Malformed Data):** Returns `null` if the key/IV data retrieved from storage is corrupted, has the wrong format, or is not valid hex.

-   **Test 7 (No Metadata):** Returns `null` if the file metadata does not exist for the given `fileId` (e.g., it was deleted or never existed).
    -   **Scenario:** Call `decryptFile` with a `fileId` that does not exist in the database for the given user.
    -   **Assert:** The `_dbHelper.getMedicalFileMetadataById` returns `null`, and the method returns `null` without attempting key retrieval.

-   **Test 8 (Read Fails):** Returns `null` if reading the encrypted file from disk fails.
    -   **Scenario:** Mock `_fileSystemOps.readFileAsBytes` to throw an I/O exception.
    -   **Assert:** The method returns `null` and logs the file I/O error.

-   **Test 9 (Bad DB Path):** Returns `null` if the metadata contains a `null` or empty path for the encrypted file.
    -   **Scenario:** Mock `_dbHelper.getMedicalFileMetadataById` to return metadata where the `encryptedPath` value is `null` or `''`.
    -   **Assert:** The method returns `null` and logs the error.

---

### Group: `deleteEncryptedFileAndKey`

This group tests the low-level deletion logic. This method is simple and does not perform user checks; that is the responsibility of the calling service (`MedicalFilesNotifier`).

-   **Test 1 (Happy Path):** Deletes the file from disk and the key from secure storage.
    -   **Scenario:** Call with a valid `fileId` and `encryptedFilePath`. Mock `fileExists` to return `true` and `secureStorage.read` to return a key.
    -   **Assert:** `_fileSystemOps.deleteFile` is called with the correct path, and `_secureStorage.delete` is called with the correct key. Returns `true`.

-   **Test 2 (Resource Already Gone):** Handles cases where the file or key (or both) are already deleted.
    -   **Scenario:** Mock `fileExists` to return `false` and/or `secureStorage.read` to return `null`.
    -   **Assert:** The method completes gracefully without throwing errors and returns `true`.

-   **Test 3 (Partial Failure):** Handles an error during one of the deletion steps.
    -   **Scenario:** Set up the mock `_fileSystemOps.deleteFile` to throw an exception.
    -   **Assert:** The method should catch the exception and return `false`, indicating the operation was not fully successful.
