
########################
## CONFIG FILE FOR AC ##
########################

# M4 PREABLE

m4_define([RedPitaya_mdsplus_major_version], [1])
m4_define([RedPitaya_mdsplus_minor_version], [0])
# if the minor version number is odd, then we want debugging.  Otherwise
# we only want minimal debugging support.
##m4_define([_debug_default],
##	  [m4_if(m4_eval(_minor_version % 2), [1], [yes])])



########### INIT #######################################
AC_INIT([RedPitaya-mdsplus],[RedPitaya_mdsplus_major_version.RedPitaya_mdsplus_minor_version],[andrea.rigoni@igi.cnr.it])

AC_CONFIG_AUX_DIR([conf])
AC_CONFIG_SRCDIR([Common.am])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])


dnl docker helpers
DK_SET_DOCKER_BUILD

AC_CANONICAL_TARGET
AM_INIT_AUTOMAKE([subdir-objects])
AM_MAINTAINER_MODE


# Checks for programs.
CFLAGS=""
CXXFLAGS=""
AC_PROG_CC
AC_PROG_CXX


######### LIBTOOL ########################################

AM_PROG_CC_C_O

AC_PROG_LIBTOOL
LIBADD_DL="-ldl"
AC_SUBST(LIBADD_DL)

AC_SEARCH_LIBS([strerror],[cposix])

LT_INIT()
AC_SUBST([LIBTOOL_DEPS])



######### CHECKS ########################################

### Checks for header files.
AC_CHECK_HEADERS([stdlib.h string.h assert.h])

### Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_INLINE
AC_TYPE_SIZE_T

### Checks for library functions.
AC_FUNC_MALLOC
AC_CHECK_FUNCS([fesetround floor pow sqrt strdup strstr])

### Checks for libraries
AC_SEARCH_LIBS([strerror],[cposix])

### Checks for programs
AC_CHECK_PROG(MKDIR_P, mkdir, [mkdir -p])
AC_SUBST([MKDIR_P])


# ///////////////////////////////////////////////////////////////////////////////////////////////// #
# /////  MDSPLUS  AS SUBMODULE  /////////////////////////////////////////////////////////////////// #
# ///////////////////////////////////////////////////////////////////////////////////////////////// #


AC_ARG_ENABLE([mdsplus-build],
              [AS_HELP_STRING([--enable-mdsplus-build],[build mdsplus as submodule])])              
AS_VAR_SET_IF([enable_mdsplus_build],[
               echo "ENABLE SUBMODULE MDSPLUS"
               pushd ${srcdir}; source ./conf/update_submodules.sh; popd
	       # pushd ${srcdir}/mdsplus; source ./bootstrap; popd
               AC_CONFIG_SUBDIRS([mdsplus])
              ])
AM_CONDITIONAL(BUILD_MDSPLUS, test x"${enable_mdsplus_build}" = x"yes")
AS_VAR_IF([enable_mdsplus_build],[yes],
          # mdsplus_build enabled.           
          # A version of mdsplus alpha should be cloned in ${srcdir}/mdsplus
          # directory, we will need to set all env manually no library search
          # is possible now as mdsplus is not compiled yet. We are going to
          # clone the latest alpha so the streaming feature will already be
          # present int the code and we don't need to check for that.          
          [
           AS_VAR_SET([have_mdsplus],[yes])
           AS_VAR_SET([have_streaming],[yes])
           AS_VAR_SET([MDSPLUS_DIR],$(pwd)/mdsplus)
           AS_VAR_SET([MDS_SRCDIR],$(cd ${srcdir}/mdsplus; pwd))
           AS_VAR_SET([MDS_BUILDDIR],${MDSPLUS_DIR})
           AS_VAR_SET([MDS_LIBDIR],${MDS_BUILDDIR}/lib64)
           AS_VAR_SET([MDS_BINDIR],${MDS_BUILDDIR}/bin64)
           AS_VAR_SET([MDS_CPPFLAGS],"-I${MDS_BUILDDIR}/include -I${MDS_SRCDIR}/include")
           AS_VAR_SET([MDS_LDFLAGS],"-L${MDS_LIBDIR}")
           _jars="\
                  javascope/jScope.jar \
                  javascope/WaveDisaply.jar \
                  mdsobjects/java/mdsobjects.jar \
                  javatraverser/DeviceBeans.jar \
                  javatraverser/jTraverser.jar \
                  javadevices/jDevices.jar \
                  javadispatcher/jDispatcher.jar \
                 "           
                 for j in ${_jars}; do
                   AS_VAR_SET_IF([mdsplus_classpath],
                                 [AS_VAR_SET([mdsplus_classpath],"${MDSPLUS_DIR}/${j}:${mdsplus_classpath}")],
                                 [AS_VAR_SET([mdsplus_classpath],"${MDSPLUS_DIR}/${j}")])
                 done
                 AC_SUBST(MDS_CLASSPATH,"${mdsplus_classpath}")
          ],
          
          # mdsplus_build disabled.           
          # We will look if a mdsplus is installed looking for the MDSPLUS_DIR
          # env variable or the --with-mdsplus-dir argument.          
          [
           # defines: have_mdsplus MDS_CPPFLAGS MDS_LDFLAGS MDSPLUS_DIR 
           #          MDS_SRCDIR MDS_BUILDDIR MDS_LIBDIR MDS_BINDIR MDS_PATH
           AC_SEARCH_MDSPLUS([MDS])           
           # defines: MDS_CLASSPATH
           AC_SEARCH_MDSPLUS_JAVA([MDS])
           # search streaming feature in mdsplus (FINIRE)
           AC_CHECK_MDSPLUS_LIB([MdsObjectsCppShr],[registerListener],
                                [AS_VAR_SET([have_streaming],[yes])],
                                [
                                 AS_VAR_SET([have_streaming],[no])
                                 AC_MSG_WARN([The selected mdsplus version does not support streaming])
                                ])
          ])

AM_CONDITIONAL([HAVE_MDSPLUS], test x"${have_mdsplus}" = x"yes")
AM_CONDITIONAL([HAVE_MDSPLUS_STREAMING], test x"${have_streaming}" = x"yes")

AC_SUBST([MDSPLUS_DIR])
AC_SUBST([MDS_CPPFLAGS])
AC_SUBST([MDS_LDFLAGS])
AC_SUBST([MDS_SRCDIR])
AC_SUBST([MDS_BUILDDIR])
AC_SUBST([MDS_LIBDIR])
AC_SUBST([MDS_BINDIR])
AC_SUBST([MDS_PATH])

# debug
AS_ECHO(["MDS_SRCDIR   = ${MDS_SRCDIR}"])
AS_ECHO(["MDS_BUILDDIR = ${MDS_BUILDDIR}"])
AS_ECHO(["MDS_CPPFLAGS = ${MDS_CPPFLAGS}"])
AS_ECHO(["MDS_LDFLAGS = ${MDS_LDFLAGS}"])
AS_ECHO(["MDS_CLASSPATH = ${MDS_CLASSPATH}"])          





# //////////////////////////////////////////////////////////////////////////// #
# ///  CONFIG_H  ///////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

dnl Here we define all custom autoheader adds to config.h.in 
dnl Needed because mdsplus uses config.h in headers

dnl add here what goes on tom of config.h
AH_TOP()

AH_VERBATIM([_LL_CONSTANTS], [
#ifdef HAVE_LL_CONSTANTS
#define LONG_LONG_CONSTANT(value) value##ll
#else
#define LONG_LONG_CONSTANT(value) value
#endif
])


AH_VERBATIM([_WIN32], [
#ifdef _WIN32
#define EXPORT __declspec(dllexport)
#elif HAVE_VISIBILITY
# define EXPORT __attribute__((__visibility__("default")))
#else
#define EXPORT
#endif
])

dnl add here what goes on bottom of config.h
AH_BOTTOM()



# //////////////////////////////////////////////////////////////////////////// #
# ///  MAKEFILES  //////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

AC_CONFIG_FILES([
        Makefile
        src/Makefile
        fpga/Makefile
        fpga/driver/Makefile
        OS/buildroot/Makefile
        OS/debian/Makefile
	])
AC_OUTPUT

		 
