module state_methods

use dims
use system_state,    only: ssv, ssv_temp
use site_parameters, only: ssp
use pft_parameters,  only: pft, pft_tab
use misc_values
use tuning_parameters

implicit none

contains

!**********************************************************************!
!                                                                      !
!                restrict_cohort_numbers :: state_methods              !
!                ----------------------------------------              !
!                                                                      !
! subroutine restrict_cohort_numbers()                                 !
!                                                                      !
!**********************************************************************!
subroutine restrict_cohort_numbers()
!**********************************************************************!
integer co1,co2,i,ft,j,nlcs,co
!----------------------------------------------------------------------!

!print*,'cohorts ',ssp%cohorts
!print*,ssv(ssp%cohorts)%slc

!print*,ssv(1)%no_stem_comps,ssv(1)%stem
!print*,ssv(1)%stem_comps(1:ssv(1)%no_stem_comps,2)
!print*,ssv(1)%stem_comps(1:ssv(1)%no_stem_comps,1)
!print*,ssv(1)%dslc
!print*
!print*,ssv(2)%no_stem_comps,ssv(2)%stem
!print*,ssv(2)%stem_comps(1:ssv(2)%no_stem_comps,2)
!print*,ssv(2)%stem_comps(1:ssv(2)%no_stem_comps,1)
!print*,ssv(2)%dslc
call make_co2ftmap(.false.)
!print*,ssp%cohorts

!print*
co1 = 1
co2 = 2
do ft=1,ssp%nft
  j = ssp%co2ftmap(ft,1)
  do i=2,j
    co1 = ssp%co2ftmap(ft,i)
    co2 = ssp%co2ftmap(ft,i+1)
    if (co2 < ssp%co2ftmap(ft,ssp%co2ftmap(ft,1))) then
!      IF (ssv(co1)%age - ssv(co2)%age < 3.0) THEN
      if (((ssv(co1)%age - ssv(co2)%age)/ssv(co2)%age)**0.2 < 0.7) then
        if (((pft(co1)%lls > 360).or.(abs(ssv(co1)%bb-ssv(co2)%bb) < 14)) &
.and.(ssv(co1)%nppstore(1) > 100.0).and.(ssv(co2)%nppstore(1) > 100.0)) then
          call COMBINE_COHORTS(co1,co2)
        endif
      endif
    endif
  enddo
enddo
!print*,ssp%cohorts
!print*,ssv(1)%no_stem_comps,ssv(1)%stem
!print*,ssv(1)%stem_comps(1:ssv(1)%no_stem_comps,2)
!print*,ssv(1)%stem_comps(1:ssv(1)%no_stem_comps,1)
!print*,ssv(1)%dslc
!print*

!print*,ssv(1:ssp%cohorts)%dslc
!print*,ssv(1:ssp%cohorts)%age

!print*,'new soil res ',ssp%new_slc

call MAKE_CO2FTMAP(.false.)
!print*,ssp%cohorts

!do co=1,ssp%cohorts
!  nlcs=ssv(co)%no_lai_comps
!  print*,'slkdj ',nlcs,ssp%jday-ssv(co)%lai_comps(1:nlcs,2)
!enddo

end subroutine RESTRICT_COHORT_NUMBERS





!**********************************************************************!
!                                                                      !
!                restrict_cohort_numbers :: combine_cohorts            !
!                ------------------------------------------            !
!                                                                      !
! subroutine combine_cohorts(co1,co2)                                  !
!                                                                      !
!**********************************************************************!
subroutine combine_cohorts(co1,co2)
!**********************************************************************!
integer co1,co2,i,j,k,co
real(dp) :: old_total_carbon,total_carbon,t1,t2,t12,comps(5000),ans,oldest
!----------------------------------------------------------------------!

call SUM_CARBON(old_total_carbon,.false.)

t1 = ssv(co1)%cov
t2 = ssv(co2)%cov
t12 = t1 + t2

do i=1,12
  ssv_temp%assj(i,1) = (ssv(co1)%assj(i,1)*t1 + ssv(co2)%assj(i,1)*t2)/t12
  ssv_temp%assj(i,2) = (ssv(co1)%assj(i,2)*t1 + ssv(co2)%assj(i,2)*t2)/t12
  ssv_temp%assv(i)   = (ssv(co1)%assv(i  )*t1 + ssv(co2)%assv(i  )*t2)/t12
enddo
ssv_temp%age = (ssv(co1)%age*t1 + ssv(co2)%age*t2)/t12
do i=1,2
  ssv_temp%bio(i) = (ssv(co1)%bio(i)*t1 + ssv(co2)%bio(i)*t2)/t12
enddo
ssv_temp%cov = (ssv(co1)%cov*t1 + ssv(co2)%cov*t2)/t12
ssv_temp%ppm = (ssv(co1)%ppm*t1 + ssv(co2)%ppm*t2)/t12
ssv_temp%hgt = (ssv(co1)%hgt*t1 + ssv(co2)%hgt*t2)/t12
do i=1,4
  ssv_temp%soil_h2o(i) = (ssv(co1)%soil_h2o(i)*t1 + ssv(co2)%soil_h2o(i)*t2)/t12
enddo
ssv_temp%snow   = (ssv(co1)%snow*t1   + ssv(co2)%snow*t2  )/t12
ssv_temp%l_snow = (ssv(co1)%l_snow*t1 + ssv(co2)%l_snow*t2)/t12
do i=1,8
  ssv_temp%c(i) = (ssv(co1)%c(i)*t1 + ssv(co2)%c(i)*t2)/t12
  ssv_temp%n(i) = (ssv(co1)%n(i)*t1 + ssv(co2)%n(i)*t2)/t12
enddo
do i=1,3
  ssv_temp%minn(1) = (ssv(co1)%minn(1)*t1 + ssv(co2)%minn(1)*t2)/t12
enddo
do i=1,3
  ssv_temp%nppstore(i) = (ssv(co1)%nppstore(i)*t1 + ssv(co2)%nppstore(i)*t2)/t12
enddo
ssv_temp%slc = ssv(co1)%slc + ssv(co2)%slc
ssv_temp%rlc = ssv(co1)%rlc + ssv(co2)%rlc
ssv_temp%sln = ssv(co1)%sln + ssv(co2)%sln
ssv_temp%rln = ssv(co1)%rln + ssv(co2)%rln
do i=1,30
  ssv_temp%sm_trig(i) = (ssv(co1)%sm_trig(i)*t1 + ssv(co2)%sm_trig(i)*t2)/t12
enddo
ssv_temp%bb =      int((real(ssv(co1)%bb)     *t1 + real(ssv(co2)%bb)     *t2)/t12 + 0.5)
ssv_temp%ss =      int((real(ssv(co1)%ss)     *t1 + real(ssv(co2)%ss)     *t2)/t12 + 0.5)
ssv_temp%bbgs =    int((real(ssv(co1)%bbgs)   *t1 + real(ssv(co2)%bbgs)   *t2)/t12 + 0.5)
ssv_temp%dsbb =    int((real(ssv(co1)%dsbb)   *t1 + real(ssv(co2)%dsbb)   *t2)/t12 + 0.5)
ssv_temp%chill =   int((real(ssv(co1)%chill)  *t1 + real(ssv(co2)%chill)  *t2)/t12 + 0.5)
ssv_temp%dschill = int((real(ssv(co1)%dschill)*t1 + real(ssv(co2)%dschill)*t2)/t12 + 0.5)

!----------------------------------------------------------------------*
!print*,ssv(co1)%no_lai_comps,ssv(co1)%no_stem_comps,ssv(co1)%no_root_comps,ssv(co1)%no_suma_comps
!print*,ssv(co2)%no_lai_comps,ssv(co2)%no_stem_comps,ssv(co2)%no_root_comps,ssv(co2)%no_suma_comps
!----------------------------------------------------------------------*
!print*,ssv(co1)%no_lai_comps
!print*,ssp%jday - ssv(co1)%lai_comps(1:ssv(co1)%no_lai_comps,2)
!print*,ssv(co1)%lai_comps(1:ssv(co1)%no_lai_comps,1)
!print*,ssv(co2)%no_lai_comps
!print*,ssp%jday - ssv(co2)%lai_comps(1:ssv(co2)%no_lai_comps,2)
!print*,ssv(co2)%lai_comps(1:ssv(co2)%no_lai_comps,1)

oldest = ssp%jday
if (ssv(co1)%no_lai_comps > 0) oldest = min(oldest,ssv(co1)%lai_comps(1,2))
if (ssv(co2)%no_lai_comps > 0) oldest = min(oldest,ssv(co2)%lai_comps(1,2))

do i=1,max_lai_comps*lai_comp_length
  comps(i) = 0.0
enddo

do i=1,ssv(co1)%no_lai_comps
  do k=1,lai_comp_length
    j = int(ssv(co1)%lai_comps(i,2) - oldest + 0.5) + k
    j = min(j,ssp%jday-int(oldest)+1)
    comps(j) = comps(j) + ssv(co1)%lai_comps(i,1)*t1/real(lai_comp_length)
  enddo
enddo

do i=1,ssv(co2)%no_lai_comps
  do k=1,lai_comp_length
    j = int(ssv(co2)%lai_comps(i,2) - oldest + 0.5) + k
    j = min(j,ssp%jday-int(oldest)+1)
    comps(j) = comps(j) + ssv(co2)%lai_comps(i,1)*t2/real(lai_comp_length)
  enddo
enddo

do i=1,max_lai_comps*lai_comp_length
  comps(i) = comps(i)/t12
enddo
ssv_temp%no_lai_comps = 0
do i=1,max_lai_comps
  ans = 0.0
  do j=1,lai_comp_length
    ans = ans + comps((i-1)*lai_comp_length+j)
  enddo
  if (ans > 0.0) then
    ssv_temp%no_lai_comps = ssv_temp%no_lai_comps + 1
    ssv_temp%lai_comps(ssv_temp%no_lai_comps,1) = ans 
    ssv_temp%lai_comps(ssv_temp%no_lai_comps,2) = real((i-1)*lai_comp_length) + oldest
  endif
enddo
ssv_temp%lai = (ssv(co1)%lai*t1 + ssv(co2)%lai*t2)/t12

!----------------------------------------------------------------------*
oldest = ssp%jday
if (ssv(co1)%no_stem_comps > 0) oldest = min(oldest,ssv(co1)%stem_comps(1,2))
if (ssv(co2)%no_stem_comps > 0) oldest = min(oldest,ssv(co2)%stem_comps(1,2))

do i=1,max_stem_comps*stem_comp_length
  comps(i) = 0.0
enddo
do i=1,ssv(co1)%no_stem_comps
  do k=1,stem_comp_length
    j = int(ssv(co1)%stem_comps(i,2) - oldest + 0.5) + k
    comps(j) = comps(j) + ssv(co1)%stem_comps(i,1)*t1/real(stem_comp_length)
  enddo
enddo
do i=1,ssv(co2)%no_stem_comps
  do k=1,stem_comp_length
    j = int(ssv(co2)%stem_comps(i,2) - oldest + 0.5) + k 
    comps(j) = comps(j) + ssv(co2)%stem_comps(i,1)*t2/real(stem_comp_length)
  enddo
enddo
do i=1,max_stem_comps*stem_comp_length
  comps(i) = comps(i)/t12
enddo
ssv_temp%no_stem_comps = 0
do i=1,max_stem_comps
  ans = 0.0
  do j=1,stem_comp_length
    ans = ans + comps((i-1)*stem_comp_length+j)
  enddo
  if (ans > 0.0) then
    ssv_temp%no_stem_comps = ssv_temp%no_stem_comps + 1
    ssv_temp%stem_comps(ssv_temp%no_stem_comps,1) = ans 
    ssv_temp%stem_comps(ssv_temp%no_stem_comps,2) = real((i-1)*stem_comp_length) + oldest
  endif
enddo
ssv_temp%stem = (ssv(co1)%stem*t1 + ssv(co2)%stem*t2)/t12

!----------------------------------------------------------------------*
oldest = ssp%jday
if (ssv(co1)%no_root_comps > 0) oldest = min(oldest,ssv(co1)%root_comps(1,2))
if (ssv(co2)%no_root_comps > 0) oldest = min(oldest,ssv(co2)%root_comps(1,2))

do i=1,max_root_comps*root_comp_length
  comps(i) = 0.0
enddo
do i=1,ssv(co1)%no_root_comps
  do k=1,root_comp_length
    j = int(ssv(co1)%root_comps(i,2) - oldest + 0.5) + k
    comps(j) = comps(j) + ssv(co1)%root_comps(i,1)*t1/real(root_comp_length)
  enddo
enddo
do i=1,ssv(co2)%no_root_comps
  do k=1,root_comp_length
    j = int(ssv(co2)%root_comps(i,2) - oldest + 0.5) + k 
    comps(j) = comps(j) + ssv(co2)%root_comps(i,1)*t2/real(root_comp_length)
  enddo
enddo
do i=1,max_root_comps*root_comp_length
  comps(i) = comps(i)/t12
enddo
ssv_temp%no_root_comps = 0
do i=1,max_root_comps
  ans = 0.0
  do j=1,root_comp_length
    ans = ans + comps((i-1)*root_comp_length+j)
  enddo
  if (ans > 0.0) then
    ssv_temp%no_root_comps = ssv_temp%no_root_comps + 1
    ssv_temp%root_comps(ssv_temp%no_root_comps,1) = ans 
    ssv_temp%root_comps(ssv_temp%no_root_comps,2) = real((i-1)*root_comp_length) + oldest
  endif
enddo
ssv_temp%root = (ssv(co1)%root*t1 + ssv(co2)%root*t2)/t12

!----------------------------------------------------------------------*
oldest = ssp%jday
if (ssv(co1)%no_suma_comps > 0) oldest = min(oldest,ssv(co1)%suma_comps(1,2))
if (ssv(co2)%no_suma_comps > 0) oldest = min(oldest,ssv(co2)%suma_comps(1,2))

do i=1,max_suma_comps*suma_comp_length
  comps(i) = 0.0
enddo
do i=1,ssv(co1)%no_suma_comps
  do k=1,suma_comp_length
    j = int(ssv(co1)%suma_comps(i,2) - oldest + 0.5) + k
    comps(j) = comps(j) + ssv(co1)%suma_comps(i,1)*t1/real(suma_comp_length)
  enddo
enddo
do i=1,ssv(co2)%no_suma_comps
  do k=1,suma_comp_length
    j = int(ssv(co2)%suma_comps(i,2) - oldest + 0.5) + k 
    comps(j) = comps(j) + ssv(co2)%suma_comps(i,1)*t2/real(suma_comp_length)
  enddo
enddo
do i=1,max_suma_comps*suma_comp_length
  comps(i) = comps(i)/t12
enddo
ssv_temp%no_suma_comps = 0
do i=1,max_suma_comps
  ans = 0.0
  do j=1,suma_comp_length
    ans = ans + comps((i-1)*suma_comp_length+j)
  enddo
  if (ans > 0.0) then
    ssv_temp%no_suma_comps = ssv_temp%no_suma_comps + 1
    ssv_temp%suma_comps(ssv_temp%no_suma_comps,1) = ans 
    ssv_temp%suma_comps(ssv_temp%no_suma_comps,2) = real((i-1)*suma_comp_length) + oldest
  endif
enddo
ssv_temp%suma = (ssv(co1)%suma*t1 + ssv(co2)%suma*t2)/t12

!----------------------------------------------------------------------*
ssv_temp%stemfr = (ssv(co1)%stemfr*t1 + ssv(co2)%stemfr*t2)/t12
ssv_temp%npp = (ssv(co1)%npp*t1 + ssv(co2)%npp*t2)/t12
ssv_temp%nps = (ssv(co1)%nps*t1 + ssv(co2)%nps*t2)/t12
ssv_temp%npl = (ssv(co1)%npl*t1 + ssv(co2)%npl*t2)/t12
ssv_temp%evp = (ssv(co1)%evp*t1 + ssv(co2)%evp*t2)/t12
ssv_temp%dslc = (ssv(co1)%dslc*t1 + ssv(co2)%dslc*t2)/t12
ssv_temp%drlc = (ssv(co1)%drlc*t1 + ssv(co2)%drlc*t2)/t12
ssv_temp%dsln = (ssv(co1)%dsln*t1 + ssv(co2)%dsln*t2)/t12
ssv_temp%drln = (ssv(co1)%drln*t1 + ssv(co2)%drln*t2)/t12

!----------------------------------------------------------------------*
! Set the combined cohort to the co1 slot and remove co2
!----------------------------------------------------------------------*
ssv(co1) = ssv_temp
ssv(co1)%cov = t12
call REMOVE_COHORT(co2)
!----------------------------------------------------------------------*

call SUM_CARBON(total_carbon,.false.)
if (abs(total_carbon-old_total_carbon) > 1.0e-3) then
  write(*,*) 'Breach of carbon closure in COMBINE_COHORTS:',total_carbon-old_total_carbon,' g/m^2.'
endif

end subroutine COMBINE_COHORTS





!**********************************************************************!
!                                                                      !
!                restrict_cohort_numbers :: make_co2ftmap              !
!                ----------------------------------------              !
!                                                                      !
! subroutine make_co2ftmap(show)                                       !
!                                                                      !
!**********************************************************************!
subroutine make_co2ftmap(show)
!**********************************************************************!
integer :: ft
logical :: show
!----------------------------------------------------------------------!

do ft=1,max_pftps
  ssp%co2ftmap(ft,1) = 0
enddo

do ft=1,ssp%cohorts
  ssp%co2ftmap(pft(ft)%itag,1) = ssp%co2ftmap(pft(ft)%itag,1) + 1
  ssp%co2ftmap(pft(ft)%itag,ssp%co2ftmap(pft(ft)%itag,1)+1) = ft
enddo

if (show) then
  do ft=1,ssp%nft
    if (ssp%co2ftmap(ft,1) > 0) then
      write(*,'(i3,1x,a6,i3,'':'',(20i4))') ft,pft_tab(ft)%tag,ssp%co2ftmap(ft,1:ssp%co2ftmap(ft,1)+1)
      write(*,'(13x,'':'',10f8.1)') ssv(ssp%co2ftmap(ft,2:ssp%co2ftmap(ft,1)+1))%age
      write(*,'(13x,'':'',10f8.5)') ssv(ssp%co2ftmap(ft,2:ssp%co2ftmap(ft,1)+1))%cov
    endif
  enddo
endif

end subroutine make_co2ftmap





!**********************************************************************!
!                                                                      !
!                restrict_cohort_numbers :: remove_cohort              !
!                ----------------------------------------              !
!                                                                      !
! subroutine remove_cohort(co)                                         !
!                                                                      !
!**********************************************************************!
subroutine remove_cohort(co)
!**********************************************************************!
integer co,i
!----------------------------------------------------------------------!

if (co < ssp%cohorts) then
  do i=co,ssp%cohorts-1
    ssv(i) = ssv(i+1)
    pft(i) = pft(i+1)
  enddo
  ssp%cohorts = ssp%cohorts - 1
elseif (co == ssp%cohorts) then
  ssp%cohorts = ssp%cohorts - 1
else
  write(*,*) 'Trying to remove a cohort that doesn''t exist: cohort number',co
  stop
endif

call MAKE_CO2FTMAP(.false.)

end subroutine REMOVE_COHORT





!**********************************************************************!
!                                                                      !
!        restrict_cohort_numbers :: initialise_state_cohort            !
!        --------------------------------------------------            !
!                                                                      !
! subroutine initialise_state_cohort(cohort)                           !
!                                                                      !
!**********************************************************************!
subroutine initialise_state_cohort(cohort)
!***********************************************************************
integer :: cohort,i
!----------------------------------------------------------------------!

do i=1,12
  ssv(cohort)%assj(i,1) = 0.0
  ssv(cohort)%assj(i,2) = 0.0
  ssv(cohort)%assv(i) = 0.0
enddo
ssv(cohort)%age = 0.0
do i=1,2
  ssv(cohort)%bio(i) = 0.0
enddo
ssv(cohort)%cov = 0.0
ssv(cohort)%ppm = 0.0
ssv(cohort)%hgt = 0.0
do i=1,4
  ssv(cohort)%soil_h2o(i) = 0.0
enddo
ssv(cohort)%snow = 0.0
ssv(cohort)%l_snow = 0.0
do i=1,8
  ssv(cohort)%c(i) = 0.0
  ssv(cohort)%n(i) = 0.0
enddo
do i=1,3
  ssv(cohort)%minn(1) = 0.0
enddo
do i=1,3
  ssv(cohort)%nppstore(i) = 0.0
enddo
ssv(cohort)%slc = 0.0
ssv(cohort)%rlc = 0.0
ssv(cohort)%sln = 0.0
ssv(cohort)%rln = 0.0
do i=1,30
  ssv(cohort)%sm_trig(i) = 0.0
enddo
ssv(cohort)%bb = 0
ssv(cohort)%ss = 0
ssv(cohort)%bbgs = 0
ssv(cohort)%dsbb = 0
ssv(cohort)%chill = 0
ssv(cohort)%dschill = 0

do i=1,int(pft(cohort)%lls/lai_comp_length)+1
  ssv(cohort)%lai_comps(i,1) = 0.0
  ssv(cohort)%lai_comps(i,2) = 0.0
enddo
ssv(cohort)%no_lai_comps = 0
ssv(cohort)%lai = 0.0

do i=1,int(pft(cohort)%sls/stem_comp_length)+1
  ssv(cohort)%stem_comps(i,1) = 0.0
  ssv(cohort)%stem_comps(i,2) = 0.0
enddo
ssv(cohort)%no_stem_comps = 0
ssv(cohort)%stem = 0.0

do i=1,int(pft(cohort)%rls/root_comp_length)+1
  ssv(cohort)%root_comps(i,1) = 0.0
  ssv(cohort)%root_comps(i,2) = 0.0
enddo
ssv(cohort)%no_root_comps = 0
ssv(cohort)%root = 0.0

do i=1,int(360/suma_comp_length)+1
  ssv(cohort)%suma_comps(i,1) = 0.0
  ssv(cohort)%suma_comps(i,2) = 0.0
enddo
ssv(cohort)%no_suma_comps = 0
ssv(cohort)%suma = 0.0

ssv(cohort)%stemfr = 0.0
ssv(cohort)%npp = 0.0
ssv(cohort)%nps = 0.0
ssv(cohort)%npl = 0.0
ssv(cohort)%evp = 0.0
ssv(cohort)%dslc = 0.0
ssv(cohort)%drlc = 0.0
ssv(cohort)%dsln = 0.0
ssv(cohort)%drln = 0.0

end subroutine initialise_state_cohort




!**********************************************************************!
!                                                                      !
!            restrict_cohort_numbers :: sum_carbon                     !
!            -------------------------------------                     !
!                                                                      !
! subroutine sum_carbon(total_carbon,show_all)                         !
!                                                                      !
!**********************************************************************!
subroutine sum_carbon(total_carbon,show_all)
!**********************************************************************!
real(dp) :: total_carbon,ans,ft_carbon,ans2
integer :: ft,i
logical :: show_all
!----------------------------------------------------------------------!

total_carbon = 0.0
ft_carbon = 0.0
do ft=1,ssp%cohorts
  ans = 0.0

  if (pft(ft)%sla > 0.0)  ans = ans + ssv(ft)%lai*12.0/pft(ft)%sla/18.0

  ans2 = ans

  do i=1,8
    ans = ans + ssv(ft)%c(i)
  enddo

  ans = ans + ssv(ft)%stem
  ans = ans + ssv(ft)%root

  ans = ans + ssv(ft)%nppstore(1) + ssv(ft)%bio(1) + ssv(ft)%bio(2)

  total_carbon = total_carbon + ans*ssv(ft)%cov + ssv(ft)%slc + ssv(ft)%rlc

  if (show_all)  write(*,'(i3,10f8.1)') ft,ssv(ft)%age,ssv(ft)%cov,total_carbon-ft_carbon,ans2, &
 (ssv(ft)%c(1)+ssv(ft)%c(2)+ssv(ft)%c(3)+ssv(ft)%c(4)+ssv(ft)%c(5)+ssv(ft)%c(6)+ &
 ssv(ft)%c(7)+ssv(ft)%c(8)),ssv(ft)%lai*12.0/pft(ft)%sla/18.0,ssv(ft)%stem,ssv(ft)%root,ssv(ft)%slc,ssv(ft)%rlc
  ft_carbon = total_carbon

enddo

if (show_all) write(*,*) 'Total ft carbon ',total_carbon
do i=1,8
  total_carbon = total_carbon + ssp%new_c(i)
enddo
total_carbon = total_carbon + ssp%new_slc + ssp%new_rlc

if (show_all) write(*,*) 'Available       ',total_carbon-ft_carbon
if (show_all) write(*,*) 'Grand total     ',total_carbon

end subroutine sum_carbon





!**********************************************************************!
!                                                                      !
!          restrict_cohort_numbers :: accumulate_dist_soil_res         !
!          ---------------------------------------------------         !
!                                                                      !
! subroutine accumulate_dist_soil_res(total_carbon,show_all)           !
!                                                                      !
!**********************************************************************!
subroutine accumulate_dist_soil_res(ft,x)
!**********************************************************************!
integer :: ft,i
real(dp) :: x,active_leaf(max_cohorts),active_stem(max_cohorts),active_root(max_cohorts)
!----------------------------------------------------------------------!

  if (pft(ft)%sla > 0.0) then
    active_leaf(ft) = ssv(ft)%lai*12.0/pft(ft)%sla/18.0
  else
    active_leaf(ft) = 0.0
  endif
  active_stem(ft) = ssv(ft)%stem
  active_root(ft) = ssv(ft)%root

  do i=1,8
    ssp%new_c(i) = ssp%new_c(i) + ssv(ft)%c(i)*ssv(ft)%cov*x
    ssp%new_n(i) = ssp%new_n(i) + ssv(ft)%n(i)*ssv(ft)%cov*x
  enddo

  do i=1,3
    ssp%new_minn(i) = ssp%new_minn(i) + ssv(ft)%minn(i)*ssv(ft)%cov*x
  enddo
  do i=1,4
    ssp%new_soil_h2o(i) = ssp%new_soil_h2o(i) + ssv(ft)%soil_h2o(i)*ssv(ft)%cov*x
  enddo
  ssp%new_snow = ssp%new_snow + ssv(ft)%snow*ssv(ft)%cov*x
  ssp%new_l_snow = ssp%new_l_snow + ssv(ft)%l_snow*ssv(ft)%cov*x
  ssp%new_slc = ssp%new_slc + (ssv(ft)%bio(1) + active_leaf(ft) + active_stem(ft) + &
 active_root(ft) + ssv(ft)%nppstore(1))*ssv(ft)%cov*x + ssv(ft)%slc*x
  ssp%new_rlc = ssp%new_rlc + ssv(ft)%bio(2)*ssv(ft)%cov*x + ssv(ft)%rlc*x
  ssp%new_sln = ssp%new_sln + ssv(ft)%sln*x
  ssp%new_rln = ssp%new_rln + ssv(ft)%rln*x

  if (x > 0.99999) then
    ssp%new_cov = ssp%new_cov + ssv(ft)%cov
    call INITIALISE_STATE_COHORT(ft)
  else
    ssp%new_cov    = ssp%new_cov + ssv(ft)%cov*x
    ssv(ft)%cov    = ssv(ft)%cov*(1.0 - x)
    ssv(ft)%slc    = ssv(ft)%slc*(1.0 - x)
    ssv(ft)%rlc    = ssv(ft)%rlc*(1.0 - x)
    ssv(ft)%sln    = ssv(ft)%sln*(1.0 - x)
    ssv(ft)%rln    = ssv(ft)%rln*(1.0 - x)
  endif

end subroutine accumulate_dist_soil_res





!***********************************************************************
subroutine ACCUMULATE_BURNT_SOIL_RES(ft,x,firec)
!***********************************************************************
integer ft,i
real(dp) :: x,firec,active_leaf(max_cohorts),active_stem(max_cohorts),active_root(max_cohorts)
!***********************************************************************

  if (pft(ft)%sla > 0.0) then
    active_leaf(ft) = ssv(ft)%lai*12.0/pft(ft)%sla/18.0
  else
    active_leaf(ft) = 0.0
  endif
  active_stem(ft) = ssv(ft)%stem
  active_root(ft) = ssv(ft)%root

  do i=1,8
    ssp%new_c(i) = ssp%new_c(i) + ssv(ft)%c(i)*ssv(ft)%cov*x
    ssp%new_n(i) = ssp%new_n(i) + ssv(ft)%n(i)*ssv(ft)%cov*x
  enddo
  do i=1,3
    ssp%new_minn(i) = ssp%new_minn(i) + ssv(ft)%minn(i)*ssv(ft)%cov*x
  enddo
  do i=1,4
    ssp%new_soil_h2o(i) = ssp%new_soil_h2o(i) + ssv(ft)%soil_h2o(i)*ssv(ft)%cov*x
  enddo
  ssp%new_snow = ssp%new_snow + ssv(ft)%snow*ssv(ft)%cov*x
  ssp%new_l_snow = ssp%new_l_snow + ssv(ft)%l_snow*ssv(ft)%cov*x

  ssp%new_slc = ssp%new_slc + (ssv(ft)%bio(1) + active_leaf(ft) + active_stem(ft) + &
 ssv(ft)%nppstore(1))*ssv(ft)%cov*x*0.2 + ssv(ft)%slc*x
  ssp%new_rlc = ssp%new_rlc + (ssv(ft)%bio(2) + active_root(ft))*ssv(ft)%cov*x + ssv(ft)%rlc*x
  ssp%new_sln = ssp%new_sln + ssv(ft)%sln*x
  ssp%new_rln = ssp%new_rln + ssv(ft)%rln*x

  firec = firec + (ssv(ft)%bio(1) + active_leaf(ft) + active_stem(ft) + &
 ssv(ft)%nppstore(1))*ssv(ft)%cov*x*0.8

  if (x > 0.99999) then
    ssp%new_cov = ssp%new_cov + ssv(ft)%cov
    ssv(ft)%cov    = 0.0
    ssv(ft)%bio(1) = 0.0
    ssv(ft)%bio(2) = 0.0
    ssv(ft)%ppm    = 0.0
    ssv(ft)%slc    = 0.0
    ssv(ft)%rlc    = 0.0
    ssv(ft)%sln    = 0.0
    ssv(ft)%rln    = 0.0
  else
    ssp%new_cov    = ssp%new_cov + ssv(ft)%cov*x
    ssv(ft)%cov    = ssv(ft)%cov*(1.0 - x)
    ssv(ft)%slc    = ssv(ft)%slc*(1.0 - x)
    ssv(ft)%rlc    = ssv(ft)%rlc*(1.0 - x)
    ssv(ft)%sln    = ssv(ft)%sln*(1.0 - x)
    ssv(ft)%rln    = ssv(ft)%rln*(1.0 - x)
  endif

end subroutine ACCUMULATE_BURNT_SOIL_RES





!***********************************************************************
subroutine SET_NEW_SOIL_RES(ft,x)
!***********************************************************************
integer ft,i
real(dp) :: x,ans
!----------------------------------------------------------------------*
  ans = 0.0
  do i=1,8
    ssv(ft)%c(i) = ssp%new_c(i)*x/ssv(ft)%cov
    ssv(ft)%n(i) = ssp%new_n(i)*x/ssv(ft)%cov
    ans = ans + ssp%new_c(i)*x
  enddo
  do i=1,3
    ssv(ft)%minn(i) = ssp%new_minn(i)*x/ssv(ft)%cov
  enddo
  do i=1,4
    ssv(ft)%soil_h2o(i) = ssp%new_soil_h2o(i)*x/ssv(ft)%cov
  enddo
  ssv(ft)%snow   = ssp%new_snow  *x/ssv(ft)%cov
  ssv(ft)%l_snow = ssp%new_l_snow*x/ssv(ft)%cov

  ssv(ft)%slc = ssp%new_slc*x
  ssv(ft)%rlc = ssp%new_rlc*x
  ssv(ft)%sln = ssp%new_sln*x
  ssv(ft)%rln = ssp%new_rln*x

  ans = ans + ssp%new_slc*x + ssp%new_rlc*x

end subroutine SET_NEW_SOIL_RES





!***********************************************************************
subroutine RESET_SOIL_RES()
!***********************************************************************
integer i
!----------------------------------------------------------------------*
  do i=1,8
    ssp%new_c(i) = 0.0
    ssp%new_n(i) = 0.0
  enddo
  do i=1,3
    ssp%new_minn(i) = 0.0
  enddo
  do i=1,4
    ssp%new_soil_h2o(i) = 0.0
  enddo
  ssp%new_snow = 0.0
  ssp%new_l_snow = 0.0

  ssp%new_slc = 0.0
  ssp%new_rlc = 0.0
  ssp%new_sln = 0.0
  ssp%new_rln = 0.0

  ssp%new_cov = 0.0

end subroutine RESET_SOIL_RES





!***********************************************************************
!                                                                      *
!                          SUBROUTINE INITIALISE_STATE                 *
!                          ***************************                 *
!                                                                      *
! Initialise the system state.                                         *
!                                                                      *
!***********************************************************************
subroutine INITIALISE_STATE(initise,nft,cluse,xtmpv,soilt)
!***********************************************************************
logical initise
integer i,nft,ft,day,age,cohort
real(dp) :: cluse(max_cohorts,max_years),sum,soilt
integer xtmpv(500,12,31)
!***********************************************************************

do day=1,200
  ssp%tmem(day) = real(xtmpv(1,(day-1)/30+1,mod(day-1,30)+1))/100.0
enddo

call RESET_SOIL_RES()

if (initise) then
  cohort = 0
  do ft=1,nft
    if (cluse(ft,1)>0.0) then
      do age=pft_tab(ft)%mort,1,-1
        cohort = cohort + 1
        pft(cohort) = pft_tab(ft)
        ssv(cohort)%age = age
        ssv(cohort)%cov = cluse(ft,1)/100.0/real(pft(cohort)%mort)
        if (ft>2) then
          ssv(cohort)%bio(1) = 1000.0
          ssv(cohort)%bio(2) = 100.0
          ssv(cohort)%ppm = 0.1
          ssv(cohort)%hgt = 5.0
          do i=1,3
            ssv(ft)%nppstore(i) = pft(ft)%stemx
          enddo
        else
          ssv(cohort)%bio(1) = 0.0
          ssv(cohort)%bio(2) = 0.0
          ssv(cohort)%ppm = 0.0
          ssv(cohort)%hgt = 0.0
          do i=1,3
            ssv(ft)%nppstore(i) = 0.0
          enddo
        endif

        do i=1,3
          ssv(cohort)%nppstore(i) = pft(cohort)%stemx
        enddo

        do i=1,max_lai_comps
          ssv(cohort)%lai_comps(i,1) = 0.0
          ssv(cohort)%lai_comps(i,2) = 0.0
        enddo
        ssv(cohort)%no_lai_comps = 0
        ssv(cohort)%lai = 0.0

        do i=1,max_stem_comps
          ssv(cohort)%stem_comps(i,1) = 0.0
          ssv(cohort)%stem_comps(i,2) = 0.0
        enddo
        ssv(cohort)%no_stem_comps = 0
        ssv(cohort)%stem = 0.0

        do i=1,max_root_comps
          ssv(cohort)%root_comps(i,1) = 0.0
          ssv(cohort)%root_comps(i,2) = 0.0
        enddo
        ssv(cohort)%no_root_comps = 0
        ssv(cohort)%root = 0.0

        do i=1,max_suma_comps
          ssv(cohort)%suma_comps(i,1) = 0.0
          ssv(cohort)%suma_comps(i,2) = 0.0
        enddo
        ssv(cohort)%no_suma_comps = 0
        ssv(cohort)%suma = 0.0

        ssv(cohort)%slc = 0.0
        ssv(cohort)%rlc = 0.0
        ssv(cohort)%sln = 0.0
        ssv(cohort)%rln = 0.0
        ssv(cohort)%bb = 0
        ssv(cohort)%ss = 0
        ssv(cohort)%bbgs = 0
        ssv(cohort)%dsbb = 0
        ssv(cohort)%chill = 0
        ssv(cohort)%dschill = 0

        do day=1,30
          ssv(cohort)%sm_trig(day) = 0.0
        enddo

        ssv(cohort)%stemfr = 120.0

        do i=1,8
          ssv(cohort)%c(i) = 1000.0
          ssv(cohort)%n(i) = 100.0
        enddo
        ssv(cohort)%c(7) = 5000.0
        ssv(cohort)%c(8) =  5000.0
        ssv(cohort)%minn(1) = 0.0
        ssv(cohort)%minn(2) = 0.0
        ssv(cohort)%minn(3) = 0.0

        ssv(cohort)%npp = 400.0
        ssv(cohort)%nps = 40.0
        ssv(cohort)%npl = 40.0
        ssv(cohort)%evp = 1.0

        ssv(cohort)%dslc = 0.0
        ssv(cohort)%drlc = 0.0
        ssv(cohort)%dsln = 0.0
        ssv(cohort)%drln = 0.0

        ssv(cohort)%soil_h2o(1) = 5.0
        ssv(cohort)%soil_h2o(2) = 50.0
        ssv(cohort)%soil_h2o(3) = 50.0
        ssv(cohort)%soil_h2o(4) = 50.0
        ssv(cohort)%snow = 0.0
        ssv(cohort)%l_snow = 0.0
      enddo
    endif
  enddo
  ssp%cohorts = cohort
endif

!----------------------------------------------------------------------*
! Ensure cover array sums to 1.                                        *
!----------------------------------------------------------------------*
sum = 0.0
do ft=1,ssp%cohorts
  sum = sum + ssv(ft)%cov
enddo
do ft=1,ssp%cohorts
  ssv(ft)%cov = ssv(ft)%cov/sum
enddo

!----------------------------------------------------------------------*
! Make cohort to ft map array co2ftmap.                                *
!----------------------------------------------------------------------*
do ft=1,max_pftps
  ssp%co2ftmap(ft,1) = 0
enddo

call MAKE_CO2FTMAP(.false.)

!----------------------------------------------------------------------*

soilt = 10.0

end subroutine INITIALISE_STATE





!***********************************************************************
!                                                                      *
!                           COMPRESS_STATE                             *
!                           **************                             *
! Remove cohorts with zero cover.                                      *
!***********************************************************************
subroutine COMPRESS_STATE()
!***********************************************************************
integer new_cohorts,ft
!***********************************************************************

new_cohorts = 0
do ft=1,ssp%cohorts
  if (ssv(ft)%cov > 0.0) then
    new_cohorts = new_cohorts + 1
    ssv(new_cohorts) = ssv(ft)
    pft(new_cohorts) = pft(ft)
  endif
enddo
do ft=new_cohorts+1,ssp%cohorts
  call INITIALISE_STATE_COHORT(ft)
enddo
ssp%cohorts = new_cohorts
call MAKE_CO2FTMAP(.false.)

end subroutine COMPRESS_STATE  





!***********************************************************************
subroutine FT_COVER()
!***********************************************************************
integer ft

do ft=1,max_pftps
  ssp%ftcov(ft) = 0.0
enddo

do ft=1,ssp%cohorts
  ssp%ftcov(pft(ft)%itag) = ssp%ftcov(pft(ft)%itag) + ssv(ft)%cov
enddo

end subroutine FT_COVER





!***********************************************************************
subroutine SET_MISC_VALUES(sla,t)
!***********************************************************************
real(dp) :: sla,sapresp,t
integer :: co
!***********************************************************************

co = ssp%cohort

!----------------------------------------------------------------------*
! Leaf molecular weight.
!----------------------------------------------------------------------*
if (sla>0.0) then
  msv%mv_leafmol = 1.0/(sla*18.0)
else
  msv%mv_leafmol =0.0
endif

!----------------------------------------------------------------------*
!Computation of soil moisture; total & density.
!----------------------------------------------------------------------*
msv%mv_soilw = ssv(co)%soil_h2o(1) + ssv(co)%soil_h2o(2) + &
 ssv(co)%soil_h2o(3) + ssv(co)%soil_h2o(4)
msv%mv_soil2g = msv%mv_soilw/(ssp%soil_depth*10.0)

!----------------------------------------------------------------------*
! Computation of respref.
!----------------------------------------------------------------------*
if (t>0) then
!Sapwood respiration N.B. 8.3144 J/K/mol= Universal gas constant.
!sapresp = exp(21.6 - 5.367e4/(8.3144*tk))
  sapresp = 0.4*exp(0.06*t)*0.1
  sapresp = 0.4*exp(0.02*t)*0.35

! Converted to a monthly figure (N.B. 24 hour day).
! sapresp = (sapresp*3600.0*24.0*30.0)/1000000.0
! Use daily value
  sapresp = (sapresp*3600.0*24.0)/1000000.0

! Totalled for the year.
  if (msv%mv_soil2g>ssp%wilt) then
    msv%mv_respref = sapresp*tgp%p_resp*((msv%mv_soil2g - ssp%wilt)&
 /min(1.0,(ssp%field - ssp%wilt)))**tgp%p_kgw
  else
    msv%mv_respref = 0.0
  endif
else
  msv%mv_respref = 0.0
endif

end subroutine SET_MISC_VALUES


end module state_methods

