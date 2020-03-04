macro(add_version major minor micro)
    set(PROJECT_MAJOR_VERSION ${major})
    set(PROJECT_MINOR_VERSION ${minor})
    set(PROJECT_MICRO_VERSION ${micro})
    set(PROJECT_VERSION 
        ${major}.${minor}.${micro}
    )
    set(${PROJECT_NAME}_MAJOR_VERSION ${major})
    set(${PROJECT_NAME}_MINOR_VERSION ${minor})
    set(${PROJECT_NAME}_MICRO_VERSION ${micro})
    set(${PROJECT_NAME}_VERSION 
        ${major}.${minor}.${micro}
    )
endmacro()