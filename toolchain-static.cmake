# Copyright (C) 2025 Ian Torres <iantorres@outlook.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

if (ENABLE_STATIC_LINKING)
    set(CURL_USE_STATIC_LIBS ON)
    set(Boost_USE_STATIC_LIBS ON)
    set(Boost_USE_STATIC_RUNTIME ON)
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libraries" FORCE)
    set(ZLIB_USE_STATIC_LIBS ON)
    set(OPENSSL_USE_STATIC_LIBS TRUE)

    if (ENABLE_CI)
        set(OPENSSL_CRYPTO_LIBRARY "/usr/lib/libcrypto.a")
        set(OPENSSL_SSL_LIBRARY "/usr/lib/libssl.a")
        set(CURL_LIBRARY "/usr/lib/libcurl.a")
        set(ZLIB_LIBRARY "/usr/lib/libz.a")
    else ()
        if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
            set(ARCH_LIB_DIR "/usr/lib/aarch64-linux-gnu")
        elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
            set(ARCH_LIB_DIR "/usr/lib/x86_64-linux-gnu")
        else()
            message(FATAL_ERROR "Arquitectura no soportada: ${CMAKE_SYSTEM_PROCESSOR}")
        endif()
        set(CURL_LIBRARY "${ARCH_LIB_DIR}/libcurl.a")
        set(ZLIB_LIBRARY "${ARCH_LIB_DIR}/libz.a")
    endif ()
endif ()