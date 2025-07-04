#pragma once

#include "../../includess.h"

class CProcesses
{
public:
    DWORD getrbx() {
        DWORD RobloxPid = 0;
        SIZE_T MemoryUsage = 0; // For avoiding Roblox ghosts processes

        HANDLE SnapShot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
        if (SnapShot != INVALID_HANDLE_VALUE) {
            PROCESSENTRY32 Process;
            Process.dwSize = sizeof(PROCESSENTRY32);

            if (Process32First(SnapShot, &Process)) {
                do {
                    if (std::wstring(Process.szExeFile) == L"RobloxPlayerBeta.exe" || std::wstring(Process.szExeFile) == L"eurotrucks2.exe") {
                        HANDLE RobloxProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, Process.th32ProcessID);
                        if (RobloxProcess) {
                            PROCESS_MEMORY_COUNTERS pmc;
                            if (GetProcessMemoryInfo(RobloxProcess, &pmc, sizeof(pmc))) {
                                if (pmc.WorkingSetSize > MemoryUsage) {
                                    MemoryUsage = pmc.WorkingSetSize;
                                    RobloxPid = Process.th32ProcessID;
                                }
                            }
                            CloseHandle(RobloxProcess);
                        }
                    }
                } while (Process32Next(SnapShot, &Process));
            }
            CloseHandle(SnapShot);
        }
        else {
            std::cout << "Couldn't create snapshot for finding Roblox!\n";
        }

        return RobloxPid;
    }

    uintptr_t gethyperion(DWORD RobloxProcessId)
    {
        if (RobloxProcessId != 0)
        {
            HANDLE SnapShot = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE | TH32CS_SNAPMODULE32, RobloxProcessId);
            if (SnapShot != INVALID_HANDLE_VALUE) {
                MODULEENTRY32 RobloxModule;
                RobloxModule.dwSize = sizeof(MODULEENTRY32);

                if (!Module32First(SnapShot, &RobloxModule)) {
                    CloseHandle(SnapShot);
                    std::cout << "Error getting hyperion base-1!\n";
                    return 0;
                }

                std::wstring WString = RobloxModule.szModule;
                std::string ModuleName(WString.begin(), WString.end());
                if (!ModuleName.empty())
                {
                    if (ModuleName.find("RobloxPlayerBeta.exe") != std::string::npos || ModuleName.find("eurotrucks2.exe") != std::string::npos) {
                        uintptr_t base = reinterpret_cast<uintptr_t>(RobloxModule.modBaseAddr);
                        CloseHandle(SnapShot);
                        return base;
                    }
                }
            }
        }
    };
};

static auto process = std::make_unique<CProcesses>;