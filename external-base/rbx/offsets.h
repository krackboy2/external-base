#include "../includess.h"

#define rebase(x) x + (uintptr_t)GetModuleHandle(sFuck(L"RobloxPlayerBeta.exe"))
#define hyperion(x) x + (uintptr_t)GetModuleHandle(sFuck(L"RobloxPlayerBeta.dll"))

namespace offsets {
	static uintptr_t name = 0x78;
	static uintptr_t children = 0x80;
	static uintptr_t descriptor = 0x18;
	static uintptr_t size = 0x8;

	static uintptr_t bypass = 0x708;

	static uintptr_t iscore = 0x1a0;
	static uintptr_t mflags = 0x1a0 - 0x4;

	static uintptr_t datamodelpointer = 0x67633D8;
	static uintptr_t faketorealdatamodel = 0x1B8;

	static uintptr_t modulebytecode = 0x158;

	static uintptr_t value = 0xD8;

	namespace player {
		static uintptr_t localplayer = 0x128;
		static uintptr_t walkspeed = 0x1D8;
		static uintptr_t walkspeedcheck = 0x3B0;
		static uintptr_t jumppower = 0x1B8;
	};
};