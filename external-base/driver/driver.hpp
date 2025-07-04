#include "../includess.h"

class driverss
{
private:
    HANDLE RobloxHandle = nullptr;
    HMODULE NtdllHandle = nullptr;
public:
    void init(DWORD RobloxPid)
    {
        if (this->RobloxHandle)
        {
            CloseHandle(this->RobloxHandle);
            this->RobloxHandle = nullptr;
        }

        if (RobloxPid != 0)
        {
            HANDLE handle = OpenProcess(PROCESS_ALL_ACCESS, FALSE, RobloxPid);
            if (!handle)
            {
                return;
            }
            this->RobloxHandle = handle;
        }
        else
        {
            return;
        }
    }


    HMODULE getntdllhandle() const {
        return this->NtdllHandle;
    }

    HANDLE getrbxhandle() const {
        return this->RobloxHandle;
    }

    bool ismemoryvalid(uintptr_t Address)
    {
        MEMORY_BASIC_INFORMATION MemoryInfo;
        if (VirtualQuery((void*)Address, &MemoryInfo, sizeof(MEMORY_BASIC_INFORMATION)) == 0) {
            return false;
        }

        return true;
    }


    LPVOID allocvirtualmemory(size_t Size, DWORD Type = MEM_COMMIT | MEM_RESERVE, DWORD Protected = PAGE_READWRITE) {
        if (!RobloxHandle) {
            return 0;
        }

        auto AllocatedMemory = VirtualAllocEx(RobloxHandle, nullptr, Size, Type, Protected);

        return AllocatedMemory ? AllocatedMemory : 0;
    }

    template <class T>
    T read(const uintptr_t Pointer)
    {
        T Value = {};
        if (!RobloxHandle) {
            return Value;
        }

        for (auto Attempts = 0; Attempts < 5;)
        {
            if (!this->ismemoryvalid(Pointer))
            {
                std::this_thread::sleep_for(std::chrono::milliseconds(10));
                Attempts++;
            }
            else
            {
                break;
            }
        }

        SIZE_T Readed = 0;

        BOOL Success = ReadProcessMemory(RobloxHandle, reinterpret_cast<LPCVOID>(Pointer), &Value, sizeof(T), &Readed);
        if (!Success || Readed != sizeof(T)) {
            return Value;
        }

        return Value;
    }

    template <class T>
    void write(const uintptr_t OldPointer, const T& ReplacePointer)
    {
        if (!RobloxHandle) {
            return;
        }

        for (auto Attempts = 0; Attempts < 5;)
        {
            if (!this->ismemoryvalid(OldPointer))
            {
                std::this_thread::sleep_for(std::chrono::milliseconds(10));
                Attempts++;
            }
            else
            {
                break;
            }
        }

        SIZE_T Written = 0;

        BOOL Success = WriteProcessMemory(RobloxHandle, reinterpret_cast<LPVOID>(OldPointer), &ReplacePointer, sizeof(T), &Written);
        if (!Success || Written != sizeof(T)) {
            return;
        }

        return;
    }
};

inline auto driver = std::make_unique<driverss>();