set (NAME oldreader)

set (UINAME ${NAME}UI)
set (DAEMONTARGET ${NAME}_target)
set (UITARGET ${UINAME}_target)

# ----------------------------------------------------------
# Daemon Plugin
# ----------------------------------------------------------

vala_precompile(VALA_C ${DAEMONTARGET}
    oldreaderAPI.vala
    oldreaderInterface.vala
    oldreaderUtils.vala
    oldreaderConnection.vala

PACKAGES
    libpeas-1.0
    json-glib-1.0
    libsoup-2.4
    gee-0.8
    libxml-2.0
    sqlite3
    libsecret-1

OPTIONS
    --target-glib=2.32
    --library ${NAME}

CUSTOM_VAPIS
    ${CMAKE_BINARY_DIR}/FeedReader.vapi
    ${CMAKE_BINARY_DIR}/FeedReaderCommon.vapi
)

add_library(${NAME} SHARED ${VALA_C})


# ----------------------------------------------------------
# UI Plugin
# ----------------------------------------------------------


vala_precompile(VALA_C2 ${UITARGET}
    oldreaderLoginWidget.vala
    oldreaderUtils.vala

PACKAGES
    libpeas-1.0
    gtk+-3.0
    gee-0.8
    libsecret-1
    sqlite3
    libsoup-2.4
    WebKit2-4.0

OPTIONS
    --target-glib=2.32
    --library ${NAME}

CUSTOM_VAPIS
    ${CMAKE_BINARY_DIR}/FeedReaderUI.vapi
    ${CMAKE_BINARY_DIR}/FeedReaderCommon.vapi
    ${CMAKE_SOURCE_DIR}/vapi/gd-1.0.vapi
)

GLIB_COMPILE_RESOURCES(GRESOURCES SOURCE ${NAME}.gresource.xml)

add_library(${UINAME} SHARED ${VALA_C2} ${GRESOURCES})


# ----------------------------------------------------------


add_dependencies(${NAME} ${EXEC_NAME} ${DAEMON_NAME})
add_dependencies(${UINAME} ${EXEC_NAME} ${DAEMON_NAME})

add_schema("org.gnome.feedreader.${NAME}.gschema.xml")

install(TARGETS ${NAME} DESTINATION ${PKGDATADIR}/plugins)
install(TARGETS ${UINAME} DESTINATION ${PKGDATADIR}/pluginsUI)
install(FILES ${NAME}.plugin DESTINATION ${PKGDATADIR}/plugins)
install(FILES ${UINAME}.plugin DESTINATION ${PKGDATADIR}/pluginsUI)

