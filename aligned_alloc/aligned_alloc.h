/**********************************************************************************************
 * @file aligned_alloc.h
 * @brief alloc aligned memory
 * @author Hankin Liu
 * @license All rights reserved.
************************************************************************************************/
#pragma once
#include <cstdlib>
#include <memory>
#include <stdexcept>
#include <type_traits>
#if defined(_WIN32) || defined(_WIN64)
#include <malloc.h>
#endif

namespace aligned {

namespace detail {
    inline bool is_power_of_2(std::size_t n)
    {
        return (n != 0 && ((n & (n - 1)) == 0));
    }

    inline void* allocate_aligned_memory(std::size_t alignment, std::size_t size) {
        if (! is_power_of_2(alignment) || size == 0) {
            return nullptr;
        }
#if __cplusplus >= 201703L
        return std::aligned_alloc(alignment, size);
#elif defined(_WIN32) || defined(_WIN64)
        return _aligned_malloc(size, alignment);
#elif defined(__ANDROID__) || defined(__APPLE__) || defined(__unix__) || defined(__linux__)
        {
            void* ptr = nullptr;
            auto ret = posix_memalign(&ptr, alignment, size);
            return (ret == 0) ? ptr : nullptr;
        }
#else
        #error "No aligned memory allocation implementation available for this platform"
#endif
    }

    inline void deallocate_aligned_memory(void* ptr) {
        if (! ptr) {
            return;
        }
#if __cplusplus >= 201703L
        std::free(ptr);
#elif defined(_WIN32) || defined(_WIN64)
        _aligned_free(ptr);
#else
        std::free(ptr);
#endif
    }

    template<typename T, bool Trivial = std::is_trivially_destructible<T>::value>
    struct AlignedDeleterImpl {
        static void destruct(T* ptr) {
            if (ptr) {
                ptr->~T();
            }
        }
    };

    template<typename T>
    struct AlignedDeleterImpl<T, true> {
        static void destruct(T* ptr) {
            // do nothing
        }
    };

    template<typename T>
    struct AlignedDeleter {
        void operator()(T* ptr) const {
            if (ptr) {
                AlignedDeleterImpl<T>::destruct(ptr);
                deallocate_aligned_memory(ptr);
            }
        }
    };

    struct RawDeleter {
        void operator()(void* p) const {
            if (p) {
                deallocate_aligned_memory(p);
            }
        }
    };

} // namespace detail

template <typename T, typename... Args>
std::unique_ptr<T, detail::AlignedDeleter<T>> make_unique_aligned(std::size_t alignment, Args&&... args)
{
    static_assert(std::is_destructible<T>::value, "T must be destructible");
    void* ptr = detail::allocate_aligned_memory(sizeof(T), alignment);
    if (!ptr) {
        throw std::bad_alloc();
    }
    try {
        T* obj = new (ptr) T(std::forward<Args>(args)...);
        return std::unique_ptr<T, detail::AlignedDeleter<T>>(obj);
    } catch (...) {
        detail::deallocate_aligned_memory(ptr);
        throw;
    }
}

template <typename T, typename... Args>
inline std::unique_ptr<T, detail::AlignedDeleter<T>> make_unique_auto_aligned(Args&&... args)
{
    return make_unique_aligned<T>(alignof(T), std::forward<Args>(args)...);
}

template <typename T, typename... Args>
std::shared_ptr<T> make_shared_aligned(std::size_t alignment, Args&&... args)
{
    static_assert(std::is_destructible<T>::value, "T must be destructible");
    void* ptr = detail::allocate_aligned_memory(alignment, sizeof(T));
    if (!ptr) {
        throw std::bad_alloc();
    }
    T* obj = nullptr;
    try {
        obj = new (ptr) T(std::forward<Args>(args)...);
    } catch (...) {
        detail::deallocate_aligned_memory(ptr);
        throw;
    }

    return std::shared_ptr<T>(obj, [](T* ptr) {
        if (ptr) {
            detail::AlignedDeleterImpl<T>::destruct(ptr);
            detail::deallocate_aligned_memory(ptr);
        }
    });
}

template <typename T, typename... Args>
inline std::shared_ptr<T> make_shared_auto_aligned(Args&&... args)
{
    return make_shared_aligned<T>(alignof(T), std::forward<Args>(args)...);
}

inline std::unique_ptr<void, detail::RawDeleter> alloc_unique_buffer(std::size_t alignment, std::size_t size)
{
    void* ptr = detail::allocate_aligned_memory(alignment, size);
    return std::unique_ptr<void, detail::RawDeleter>(ptr);
}

inline std::shared_ptr<void> alloc_shared_buffer(std::size_t alignment, std::size_t size)
{
    void* ptr = detail::allocate_aligned_memory(alignment, size);
    return std::shared_ptr<void>(ptr, [](void* p) {
        detail::deallocate_aligned_memory(p);
    });
}

} // namespace aligned

