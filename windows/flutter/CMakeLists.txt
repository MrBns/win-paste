cmake_minimum_required(VERSION 3.14)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Configuration provided via flutter tool.
include(${EPHEMERAL_DIR}/generated_config.cmake)

set(WRAPPER_ROOT "${EPHEMERAL_DIR}/cpp_client_wrapper")

# === Flutter Library ===
set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/flutter_windows.dll")

# Published to parent scope for install step.
set(FLUTTER_LIBRARY ${FLUTTER_LIBRARY} PARENT_SCOPE)
set(FLUTTER_ICU_DATA_FILE "${EPHEMERAL_DIR}/icudtl.dat" PARENT_SCOPE)
set(PROJECT_BUILD_DIR "${PROJECT_BINARY_DIR}/" PARENT_SCOPE)
set(AOT_LIBRARY "${PROJECT_BINARY_DIR}/windows/app.so" PARENT_SCOPE)

list(APPEND FLUTTER_LIBRARY_HEADERS
  "flutter_export.h"
  "flutter_windows.h"
  "flutter_messenger.h"
  "flutter_plugin_registrar.h"
  "flutter_texture_registrar.h"
)
list(TRANSFORM FLUTTER_LIBRARY_HEADERS PREPEND "${EPHEMERAL_DIR}/")
add_library(flutter INTERFACE)
target_include_directories(flutter INTERFACE "${EPHEMERAL_DIR}")
target_link_libraries(flutter INTERFACE "${FLUTTER_LIBRARY}")
add_dependencies(flutter flutter_assemble)

# === Wrapper ===
set(WRAPPER_SOURCES
  "cpp_client_wrapper/flutter_engine.cc"
  "cpp_client_wrapper/flutter_view_controller.cc"
)
list(TRANSFORM WRAPPER_SOURCES PREPEND "${EPHEMERAL_DIR}/")
add_library(flutter_wrapper_app STATIC ${WRAPPER_SOURCES})
apply_standard_settings(flutter_wrapper_app)
set(CPPFLAGS_FROM_FLUTTER "-DFLUTTER_ENGINE_NO_PROTOTYPES")
target_compile_definitions(flutter_wrapper_app PUBLIC ${CPPFLAGS_FROM_FLUTTER})
target_link_libraries(flutter_wrapper_app PUBLIC flutter)
target_include_directories(flutter_wrapper_app PUBLIC "${WRAPPER_ROOT}")
add_dependencies(flutter_wrapper_app flutter_assemble)

# === Flutter tool backend ===
add_custom_target(flutter_assemble DEPENDS
  "${FLUTTER_LIBRARY}"
  "${FLUTTER_ICU_DATA_FILE}"
)
add_custom_command(TARGET flutter_assemble PRE_BUILD
  COMMAND "${CMAKE_COMMAND}" -E env
    "FLUTTER_ROOT=${FLUTTER_ROOT}"
    "PROJECT_DIR=${FLUTTER_TARGET_PLATFORM_SOURCE_DIR}"
  "${FLUTTER_TOOL_ENVIRONMENT_VARIABLES}"
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
)
