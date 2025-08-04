#include <iostream>
#include <cassert>
#include "../aligned_alloc.h"

struct alignas(64) Vec64 {
    float data[16];
    Vec64(float val) {
        for (int i = 0; i < 16; ++i)
            data[i] = val;
    }
    ~Vec64() {
        std::cout << "Vec64 destroyed\n";
    }
};

// 检查内存地址是否对齐
bool is_aligned(void* ptr, std::size_t alignment) {
    return reinterpret_cast<std::uintptr_t>(ptr) % alignment == 0;
}

void test_make_unique_aligned_explicit() {
    auto ptr = aligned::make_unique_aligned<Vec64>(64, 3.14f);
    std::cout << "make_unique_aligned explicit ok: " << ptr->data[0] << "\n";
    assert(is_aligned(ptr.get(), 64));
}

void test_make_unique_aligned_auto_alignof() {
    auto ptr = aligned::make_unique_auto_aligned<Vec64>(1.23f);
    std::cout << "make_unique_aligned auto-alignof ok: " << ptr->data[0] << "\n";
    assert(is_aligned(ptr.get(), alignof(Vec64)));
}

void test_make_shared_aligned_explicit() {
    auto ptr = aligned::make_shared_aligned<Vec64>(64, 2.71f);
    std::cout << "make_shared_aligned explicit ok: " << ptr->data[0] << "\n";
    assert(is_aligned(ptr.get(), 64));
}

void test_make_shared_aligned_auto_alignof() {
    auto ptr = aligned::make_shared_auto_aligned<Vec64>(6.28f);
    std::cout << "make_shared_aligned auto-alignof ok: " << ptr->data[0] << "\n";
    assert(is_aligned(ptr.get(), alignof(Vec64)));
}

void test_alloc_unique_buffer() {
    constexpr std::size_t alignment = 128;
    constexpr std::size_t size = 1024;
    auto buf = aligned::alloc_unique_buffer(alignment, size);
    std::cout << "alloc_unique_buffer ok\n";
    assert(is_aligned(buf.get(), alignment));
}

void test_alloc_shared_buffer() {
    constexpr std::size_t alignment = 256;
    constexpr std::size_t size = 2048;
    auto buf = aligned::alloc_shared_buffer(alignment, size);
    std::cout << "alloc_shared_buffer ok\n";
    assert(is_aligned(buf.get(), alignment));
}

int main() {
    try {
        test_make_unique_aligned_explicit();
        test_make_unique_aligned_auto_alignof();
        test_make_shared_aligned_explicit();
        test_make_shared_aligned_auto_alignof();
        test_alloc_unique_buffer();
        test_alloc_shared_buffer();
    } catch (const std::exception& e) {
        std::cerr << "Exception: " << e.what() << "\n";
        return 1;
    }
    std::cout << "All tests passed!\n";
    return 0;
}
