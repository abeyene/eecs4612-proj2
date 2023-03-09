#!/usr/bin/env tcsh
# Setup script for Synopsys VCS/Verdi T-2022.06-SP2
#
if( $?CMC_HOME == 0) then
	setenv CMC_HOME /CMC
endif

source $CMC_HOME/scripts/synopsys.2019.02.csh
# VCS
setenv VCS_HOME $CMC_HOME/tools/synopsys/vcs_vT-2022.06-SP2/vcs/T-2022.06-SP2
setenv PATH ${VCS_HOME}/bin:.:${PATH}
setenv VCS_TARGET_ARCH linux64

# VERDI
setenv VERDI_HOME $CMC_HOME/tools/synopsys/verdi_vT-2022.06-SP2/verdi/T-2022.06-SP2
setenv NOVAS_HOME $VERDI_HOME
setenv NOVAS_EXECUTABLE_ARCH LINUX64 
setenv PLATFORM linux64
setenv PATH ${VERDI_HOME}/bin:${PATH}

