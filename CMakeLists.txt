cmake_minimum_required(VERSION 3.13.0)

project(fitpackpp LANGUAGES C CXX Fortran)

include(cmake/add_version.cmake)

add_version(1 0 0)

option( INSTALL_DEPS "Install upstream dependencies" OFF)

# if(${CMAKE_Fortran_COMPILER} MATCHES "ifort.*")
#     set(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS} -fltconsistency")
#     set(CMAKE_Fortran_FLAGS_DEBUG   "${CMAKE_Fortran_FLAGS} -fltconsistency")
# endif()

set(fitpack_SRC
    fitpack/bispev.f
    fitpack/curfit.f
    fitpack/fpback.f
    fitpack/fpbisp.f
    fitpack/fpchec.f
    fitpack/fpcurf.f
    fitpack/fpbspl.f
    fitpack/fpdisc.f
    fitpack/fpgivs.f
    fitpack/fpknot.f
    fitpack/fporde.f
    fitpack/fprank.f
    fitpack/fprati.f
    fitpack/fprota.f
    fitpack/fpsurf.f
    fitpack/parder.f
    fitpack/splder.f
    fitpack/splev.f
    fitpack/surfit.f
)
add_library(fitpack ${fitpack_SRC})

# C++ interface
include(FortranCInterface)
FortranCInterface_HEADER(FCMangle.h
                         MACRO_NAMESPACE "FC_"
                         SYMBOL_NAMESPACE ""
                         SYMBOLS curfit splev splder surfit bispev parder)
FortranCInterface_VERIFY(CXX)

set(fitpackpp_SRC
    fitpackpp/BSplineCurve.cpp
    fitpackpp/BSplineSurface.cpp)
add_library(fitpackpp ${fitpackpp_SRC})
target_include_directories(fitpackpp PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/fitpackpp>
    $<INSTALL_INTERFACE:include>
)
target_include_directories(fitpackpp PRIVATE ${CMAKE_BINARY_DIR})
target_link_libraries(fitpackpp PUBLIC fitpack)


include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
set(PROJECT_VERSION     "${${PROJECT_NAME}_VERSION}")
set(generated_dir       "${CMAKE_CURRENT_BINARY_DIR}/generated")
set(config_install_dir  "lib/cmake/${PROJECT_NAME}")
set(version_config      "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config      "${generated_dir}/${PROJECT_NAME}Config.cmake")
set(targets_export_name "${PROJECT_NAME}Targets")
set(namespace           "${PROJECT_NAME}::")
write_basic_package_version_file(
    "${version_config}" COMPATIBILITY SameMajorVersion
)
configure_package_config_file(
    "cmake/config.cmake.in"
    "${project_config}"
    INSTALL_DESTINATION "${config_install_dir}"
)
install(TARGETS fitpackpp fitpack
    EXPORT "${targets_export_name}"
    BUNDLE DESTINATION . COMPONENT Runtime
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT Runtime
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Library
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Library
)
install(
    DIRECTORY fitpackpp/
    DESTINATION include/fitpackpp
    FILES_MATCHING PATTERN "*.h"
)
install(
    FILES       "${project_config}" "${version_config}"
    DESTINATION "${config_install_dir}"
)
install(
    EXPORT      "${targets_export_name}"
    NAMESPACE   "${namespace}"
    DESTINATION "${config_install_dir}"
)
if(INSTALL_DEPS)
    if(WIN32)
        configure_file(
            cmake/win/bundle.cmake.in 
            ${CMAKE_BINARY_DIR}/bundle.cmake @ONLY
        )
    elseif(UNIX)
        configure_file(
            cmake/lx/bundle.cmake.in
            ${CMAKE_BINARY_DIR}/bundle.cmake @ONLY
        )
    endif()
    install(
        SCRIPT ${CMAKE_BINARY_DIR}/bundle.cmake
        COMPONENT Dependencies
    )
endif()
