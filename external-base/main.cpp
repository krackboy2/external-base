#include "includess.h"
#include "deps/includes.h"

HWND ReturnedHwnd = NULL;
BOOL CALLBACK WindowsProcess(HWND hwnd, LPARAM lParam) {
    DWORD windowProcessId;
    GetWindowThreadProcessId(hwnd, &windowProcessId);
    if (windowProcessId == (DWORD)lParam) {
        ReturnedHwnd = hwnd;
        return FALSE;
    }
    return TRUE;
}

HWND gethandle(DWORD processId) {
    EnumWindows(WindowsProcess, processId);
    return ReturnedHwnd;
}

HMODULE GetResourceModule() {
    HMODULE Module;
    GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, (LPCTSTR)GetResourceModule, &Module);
    return Module;
}

int main()
{
    std::cout << "external sexyy volt <3\n";

    DWORD rpid = process()->getrbx();
    while (!rpid)
    {
        std::cout << "roblox not detected!\n\r";
        rpid = process()->getrbx();
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    HWND wnd;

    while (!(wnd = gethandle(rpid))) {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    uintptr_t hyperionaddr = process()->gethyperion(rpid);
    if (!hyperionaddr)
    {
        std::cout << "oh shit, i can't get hyperion base! exiting in 2 seconds...\n";
        std::this_thread::sleep_for(std::chrono::seconds(2));
        exit(-1);
    }

    globals::hyperionbase = hyperionaddr;

    driver->init(rpid);

    while (!driver->getrbxhandle()) {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    {
        std::cout << "oh good, driver initialized!\n";
        auto datamodel = rbxinstance()->getdatamodel();
        if (!datamodel.valid(false))
        {
            while (true) { }
        }
        auto starterplayer = datamodel.findfirstchildofclass("StarterPlayer");
        if (!starterplayer.valid(false))
        {
            while (true) { }
        }
        auto corepackages = datamodel.findfirstchildofclass("CorePackages");
        if (!corepackages.valid(false))
        {
            while (true) { }
        }
        auto packages = corepackages.findfirstchild("Packages");
        if (!packages.valid(false))
        {
            while (true) { }
        }
        auto _index = packages.findfirstchild("_Index");
        if (!_index.valid(false))
        {
            while (true) { }
        }
        auto collisionmatchers2d = _index.findfirstchild("CollisionMatchers2D");
        if (!collisionmatchers2d.valid(false))
        {
            while (true) { }
        }
        auto collisionmatchers2d2 = collisionmatchers2d.findfirstchild("CollisionMatchers2D");
        if (!collisionmatchers2d2.valid(false))
        {
            while (true) { }
        }
        auto jest = collisionmatchers2d2.findfirstchild("Jest");
        if (!jest.valid(false))
        {
            while (true) { }
        }
        auto coregui = datamodel.findfirstchildofclass("CoreGui");
        if (!coregui.valid(false))
        {
            while (true) { }
        }
        auto rbxgui = coregui.findfirstchild("RobloxGui");
        if (!rbxgui.valid(false))
        {
            while (true) { }
        }
        auto modules = rbxgui.findfirstchild("Modules");
        if (!modules.valid(false))
        {
            while (true) { }
        }
        auto playerlist = modules.findfirstchild("PlayerList");
        if (!playerlist.valid(false))
        {
            while (true) { }
        }
        auto playerlistmanager = playerlist.findfirstchild("PlayerListManager");
        if (!playerlistmanager.valid(false))
        {
            while (true) { }
        }
        HMODULE Module = GetResourceModule();
        if (Module == NULL)
        {
            std::cout << "error while getting res1\n";
            while (true) { }
        }

        HRSRC Resource = FindResourceW(Module, MAKEINTRESOURCE(Lua), MAKEINTRESOURCE(Init));
        if (Resource == NULL)
        {
            std::cout << "error while getting res2\n";
            while (true) { }
        }
        HGLOBAL Data = LoadResource(Module, Resource);
        if (Data == NULL)
        {
            std::cout << "error while getting res3\n";
            while (true) { }
        }
        void* LockedData = LockResource(Data);
        if (LockedData == NULL)
        {
            std::cout << "error while getting res4\n";
            while (true) { }
        }
        driver->write<uintptr_t>(playerlistmanager.self + offsets::size, jest.self);
        std::cout << "playerlistmanager: " << std::to_string(playerlistmanager.self) << "\n";
        jest.removecoredetections();
        jest.setbytecode(luau::zstdcompresse(luau::compilee("coroutine['wrap'](function(...)" + std::string(static_cast<char*>(LockedData), SizeofResource(Module, Resource)) + "\nend)() while task['wait'](9e9) do task['wait'](9e9) end")));
        while (GetForegroundWindow() != wnd) { SetForegroundWindow(wnd); std::this_thread::sleep_for(std::chrono::milliseconds(20)); }; SendMessageW(wnd, WM_CLOSE, NULL, NULL); Sleep(150);
        driver->write<uintptr_t>(playerlistmanager.self + offsets::size, playerlistmanager.self);
        std::cout << "executor loaded!\n";
        executor::bridge::init();
        execution::execute("print('executor loaded!')");
    }

    while (process()->getrbx()) { Sleep(5000); }

    exit(0);

    return 0;
}