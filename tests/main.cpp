#include "SDL3/SDL.h"
#include "SDL3/SDL_main.h"
#include "SDL3/SDL_init.h"
#include "SDL3/SDL_vulkan.h"

auto main() -> int {
    SDL_Init(0);
    SDL_main();
    return 0;
}
