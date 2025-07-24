/**********************************************************************************************
 * @file hook_malloc.cpp
 * @brief hook malloc function call
 * @author Hankin Liu
 * @license All right reserved.
************************************************************************************************/
#include <unistd.h>
#include <iostream>
#include <cstring>
#include <chrono>
#include <sys/syscall.h>
#include <cstdlib>
#include <dlfcn.h>

using namespace std;

#define MAX_COUNT 100

struct stats
{
    uint64_t count{ 0 };
    uint64_t total_us{ 0 };
};

thread_local stats stat{};
using MallocFunc = void* (*)(size_t);
static MallocFunc real_malloc = nullptr;

inline pid_t get_tid() {
    return static_cast<pid_t>(::syscall(SYS_gettid));
}

static inline uint64_t get_timestamp()
{
    return std::chrono::high_resolution_clock::now().time_since_epoch().count();
}

extern "C" void* malloc(size_t size)
{
    if (!real_malloc) {
        real_malloc = (MallocFunc)dlsym(RTLD_NEXT, "malloc");
        if (!real_malloc) {
            std::cerr << "Failed to resolve real malloc" << std::endl;
            std::exit(-1);
        }
    }
    auto start = get_timestamp();
    void* ptr = real_malloc(size);
    auto end = get_timestamp();

    ++stat.count;
    stat.total_us += (end - start);
    if (stat.count == MAX_COUNT) {
        printf("[Malloc Stat] Tid = %ju, total_time = [%ju]ns, count = %ju, avg_time = [%lf]ns\n",
               (uint64_t)get_tid(), stat.total_us, MAX_COUNT, (double)(stat.total_us / MAX_COUNT));
        stat.count = 0;
        stat.total_us = 0;
    }
    return ptr;
}
