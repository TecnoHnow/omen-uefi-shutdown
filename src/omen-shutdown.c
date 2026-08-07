#include <efi.h>
#include <efilib.h>

EFI_STATUS
EFIAPI
efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    InitializeLib(ImageHandle, SystemTable);

    Print(L"\r\nOMEN UEFI Shutdown\r\n");
    Print(L"Calling ResetSystem(EfiResetShutdown)...\r\n");

    /* Keep the exact delay used by the field-tested implementation. */
    uefi_call_wrapper(BS->Stall, 1, 2000000);

    uefi_call_wrapper(
        RT->ResetSystem,
        4,
        EfiResetShutdown,
        EFI_SUCCESS,
        0,
        NULL
    );

    /* A successful ResetSystem() call never returns. */
    Print(L"ERROR: ResetSystem returned.\r\n");

    while (1) {
        uefi_call_wrapper(BS->Stall, 1, 1000000);
    }

    return EFI_SUCCESS;
}
