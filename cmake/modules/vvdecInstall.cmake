# vvdecInstall

set( RUNTIME_DEST ${CMAKE_INSTALL_BINDIR} )
set( LIBRARY_DEST ${CMAKE_INSTALL_LIBDIR} )
set( ARCHIVE_DEST ${CMAKE_INSTALL_LIBDIR} )

# install targets
macro( install_targets config_ )
  string( TOLOWER ${config_} config_lc_ )
  install( TARGETS             vvdec vvdecapp
           EXPORT              vvdecTargets-${config_lc_}
           CONFIGURATIONS      ${config_}
           RUNTIME DESTINATION ${RUNTIME_DEST}
           BUNDLE DESTINATION  ${RUNTIME_DEST}
           LIBRARY DESTINATION ${LIBRARY_DEST}
           ARCHIVE DESTINATION ${ARCHIVE_DEST} )
endmacro( install_targets )

# install pdb file for static and shared libraries
macro( install_lib_pdb lib_ )
  if( MSVC )
    install( FILES $<$<AND:$<PLATFORM_ID:Windows>,$<STREQUAL:$<TARGET_PROPERTY:${lib_},TYPE>,SHARED_LIBRARY>>:$<TARGET_PDB_FILE:${lib_}>>
             CONFIGURATIONS Debug DESTINATION ${RUNTIME_DEST} OPTIONAL )
    install( FILES $<$<AND:$<PLATFORM_ID:Windows>,$<STREQUAL:$<TARGET_PROPERTY:${lib_},TYPE>,SHARED_LIBRARY>>:$<TARGET_PDB_FILE:${lib_}>>
             CONFIGURATIONS RelWithDebInfo DESTINATION ${RUNTIME_DEST} OPTIONAL )
    install( FILES $<$<AND:$<PLATFORM_ID:Windows>,$<STREQUAL:$<TARGET_PROPERTY:${lib_},TYPE>,STATIC_LIBRARY>>:$<TARGET_FILE_DIR:${lib_}>/$<TARGET_PROPERTY:${lib_},NAME>.pdb>
             CONFIGURATIONS Debug DESTINATION ${ARCHIVE_DEST} OPTIONAL )
    install( FILES $<$<AND:$<PLATFORM_ID:Windows>,$<STREQUAL:$<TARGET_PROPERTY:${lib_},TYPE>,STATIC_LIBRARY>>:$<TARGET_FILE_DIR:${lib_}>/$<TARGET_PROPERTY:${lib_},NAME>.pdb>
             CONFIGURATIONS RelWithDebInfo DESTINATION ${ARCHIVE_DEST} OPTIONAL )
    #install( FILES $<$<AND:$<PLATFORM_ID:Windows>,$<STREQUAL:$<TARGET_PROPERTY:${lib_},TYPE>,STATIC_LIBRARY>>:$<TARGET_FILE_DIR:${lib_}>/${lib_}.pdb>
    #         CONFIGURATIONS Debug DESTINATION ${ARCHIVE_DEST} OPTIONAL )
    #install( FILES $<$<AND:$<PLATFORM_ID:Windows>,$<STREQUAL:$<TARGET_PROPERTY:${lib_},TYPE>,STATIC_LIBRARY>>:$<TARGET_FILE_DIR:${lib_}>/${lib_}.pdb>
    #         CONFIGURATIONS RelWithDebInfo DESTINATION ${ARCHIVE_DEST} OPTIONAL )
  endif()
endmacro( install_lib_pdb )

# install pdb file for executables
macro( install_exe_pdb exe_ )
  if( MSVC )
    install( FILES $<$<PLATFORM_ID:Windows>:$<TARGET_PDB_FILE:${exe_}>>  DESTINATION ${RUNTIME_DEST} CONFIGURATIONS Debug          OPTIONAL )
    install( FILES $<$<PLATFORM_ID:Windows>:$<TARGET_PDB_FILE:${exe_}>>  DESTINATION ${RUNTIME_DEST} CONFIGURATIONS RelWithDebInfo OPTIONAL )
  endif()
endmacro( install_exe_pdb )

# set interface include directories
target_include_directories( vvdec  SYSTEM INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}> )

# install headers
install( FILES     ${CMAKE_BINARY_DIR}/vvdec/version.h  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/vvdec )
install( DIRECTORY include/vvdec                        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} )

# install targets
install_targets( Release )
install_targets( Debug )
install_targets( RelWithDebInfo )

# install pdb files
install_lib_pdb( vvdec )
install_exe_pdb( vvdecapp )

# install emscripten generated files
if( ${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten" )
  install( PROGRAMS $<TARGET_FILE_DIR:vvdecapp>/vvdecapp.wasm DESTINATION ${RUNTIME_DEST} )
  install( PROGRAMS $<TARGET_FILE_DIR:vvdecapp>/vvdecapp.worker.js DESTINATION ${RUNTIME_DEST} )
endif()

# configure version file
configure_file( cmake/install/vvdecConfigVersion.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/vvdecConfigVersion.cmake @ONLY )

# install cmake releated files
install( FILES cmake/install/vvdecConfig.cmake                       DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/vvdec )
install( FILES ${CMAKE_CURRENT_BINARY_DIR}/vvdecConfigVersion.cmake  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/vvdec )

# set config postfix
if( BUILD_SHARED_LIBS )
  set( CONFIG_POSTFIX shared )
else()
  set( CONFIG_POSTFIX static )
endif()

# create target cmake files
install( EXPORT vvdecTargets-release        NAMESPACE vvdec:: FILE vvdecTargets-${CONFIG_POSTFIX}.cmake CONFIGURATIONS Release        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/vvdec )
install( EXPORT vvdecTargets-debug          NAMESPACE vvdec:: FILE vvdecTargets-${CONFIG_POSTFIX}.cmake CONFIGURATIONS Debug          DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/vvdec )
install( EXPORT vvdecTargets-relwithdebinfo NAMESPACE vvdec:: FILE vvdecTargets-${CONFIG_POSTFIX}.cmake CONFIGURATIONS RelWithDebInfo DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/vvdec )

configure_file( pkgconfig/libvvdec.pc.in ${CMAKE_CURRENT_BINARY_DIR}/pkgconfig/libvvdec.pc @ONLY )
install( FILES ${CMAKE_CURRENT_BINARY_DIR}/pkgconfig/libvvdec.pc DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig )

