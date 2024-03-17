
/*
    VAFFANCULOOOO
 */


#include <Boot.h>


EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    EFI_STATUS status;
    EFI_INPUT_KEY key;
    ST = SystemTable;

    InitializeLib(ImageHandle, SystemTable); // Init GNU-EFI, SystemTable is the computer EFI system table

    // Print a string
    status = ST->ConOut->OutputString(ST->ConOut, L"E' ora di esplodere!\r\n");
    if (EFI_ERROR(status)) return status;

    // Clear console input buffer. We need to flush out any previous keystroke
    status = ST->ConIn->Reset(ST->ConIn, FALSE);
    if (EFI_ERROR(status)) return status;

    // Wait for any keystroke
    while ((status = ST->ConIn->ReadKeyStroke(ST->ConIn, &key)) == EFI_NOT_READY);

    return EFI_SUCCESS;
}