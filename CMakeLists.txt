cmake_minimum_required(VERSION 3.3)
project(scopehal-sigrok-bridge)

# set(WARNINGS "-Wall -Wextra -Wuninitialized ")
# set(WARNINGS "${WARNINGS} -Wshadow -Wunsafe-loop-optimizations -Wpedantic -Wcast-align -Wwrite-strings")
# set(WARNINGS "${WARNINGS} -Wvla")
set(CMAKE_CXX_FLAGS "-g -fopenmp ${WARNINGS} --std=c++17 -mtune=native -ffast-math")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -fsanitize=address")

if(WIN32)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_USE_MATH_DEFINES -D_POSIX_THREAD_SAFE_FUNCTIONS")
endif()

list(APPEND PKGDEPS
	"libsigrok4DSL >= 0.2.0"
	"libusb-1.0 >= 1.0.16"
)

find_package(PkgConfig)
pkg_check_modules(PKGDEPS REQUIRED ${PKGDEPS})

include_directories(${PKGDEPS_INCLUDE_DIRS})

add_subdirectory("${PROJECT_SOURCE_DIR}/lib/log")
add_subdirectory("${PROJECT_SOURCE_DIR}/lib/scpi-server-tools")
add_subdirectory("${PROJECT_SOURCE_DIR}/lib/xptools")

add_executable(scopehal-sigrok-bridge
	src/main.cpp
	src/srbinding.cpp
	src/server.cpp
	src/SigrokSCPIServer.cpp
	src/WaveformServerThread.cpp
)

link_directories(${PKGDEPS_LIBRARY_DIRS})
target_link_libraries(scopehal-sigrok-bridge
	${PKGDEPS_LIBRARIES}
	xptools
	scpi-server-tools
	log
)

target_include_directories(scopehal-sigrok-bridge PRIVATE
	lib/
)

