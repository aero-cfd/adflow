!        generated by tapenade     (inria, tropics team)
!  tapenade 3.10 (r5363) -  9 sep 2014 09:53
!
!  differentiation of bcturbwall in reverse (adjoint) mode (with options i4 dr8 r8 noisize):
!   gradient     of useful results: *bvtj1 *bvtj2 *w *rlv *bvtk1
!                *bvtk2 *d2wall *bvti1 *bvti2
!   with respect to varying inputs: *bvtj1 *bvtj2 *w *rlv *bvtk1
!                *bvtk2 *d2wall *bvti1 *bvti2
!   plus diff mem management of: bvtj1:in bvtj2:in w:in rlv:in
!                bvtk1:in bvtk2:in d2wall:in bvti1:in bvti2:in
!                bcdata:in
!
!      ******************************************************************
!      *                                                                *
!      * file:          bcturbwall.f90                                  *
!      * author:        georgi kalitzin, edwin van der weide            *
!      * starting date: 06-26-2003                                      *
!      * last modified: 06-12-2005                                      *
!      *                                                                *
!      ******************************************************************
!
subroutine bcturbwall_b(nn)
!
!      ******************************************************************
!      *                                                                *
!      * bcturbwall applies the implicit treatment of the viscous       *
!      * wall boundary condition for the turbulence model used to the   *
!      * given subface nn.                                              *
!      * it is assumed that the pointers in blockpointers are           *
!      * already set to the correct block.                              *
!      *                                                                *
!      ******************************************************************
!
  use blockpointers
  use bctypes
  use flowvarrefstate
  use inputphysics
  use constants
  use paramturb
  implicit none
!
!      subroutine arguments.
!
  integer(kind=inttype), intent(in) :: nn
!
!      local variables.
!
  integer(kind=inttype) :: i, j, ii, jj, iimax, jjmax
  real(kind=realtype) :: tmpd, tmpe, tmpf, nu
  real(kind=realtype) :: tmpdd, nud
  real(kind=realtype), dimension(:, :, :, :), pointer :: bmt
  real(kind=realtype), dimension(:, :, :), pointer :: bvt, ww2
  real(kind=realtype), dimension(:, :), pointer :: rlv2, dd2wall
  intrinsic min
  intrinsic max
  integer :: branch
  real(kind=realtype) :: temp3
  real(kind=realtype) :: temp2
  real(kind=realtype) :: temp1
  real(kind=realtype) :: temp0
  real(kind=realtype) :: temp10
  integer(kind=inttype) :: y12
  integer(kind=inttype) :: y11
  integer(kind=inttype) :: y10
  real(kind=realtype) :: tempd
  real(kind=realtype) :: tempd4
  real(kind=realtype) :: tempd3
  real(kind=realtype) :: tempd2
  real(kind=realtype) :: tempd1
  real(kind=realtype) :: tempd0
  integer(kind=inttype) :: y9
  real(kind=realtype) :: temp
  integer(kind=inttype) :: y8
  integer(kind=inttype) :: y7
  integer(kind=inttype) :: y6
  real(kind=realtype) :: temp9
  integer(kind=inttype) :: y5
  real(kind=realtype) :: temp8
  integer(kind=inttype) :: y4
  real(kind=realtype) :: temp7
  integer(kind=inttype) :: y3
  real(kind=realtype) :: temp6
  integer(kind=inttype) :: y2
  real(kind=realtype) :: temp5
  integer(kind=inttype) :: y1
  real(kind=realtype) :: temp4
!        ================================================================
!
!      ******************************************************************
!      *                                                                *
!      * begin execution                                                *
!      *                                                                *
!      ******************************************************************
!
! determine the turbulence model used and loop over the faces
! of the subface and set the values of bmt and bvt for an
! implicit treatment.
  select case  (turbmodel) 
  case (spalartallmaras, spalartallmarasedwards) 

  case (komegawilcox, komegamodified, mentersst) 
!        ================================================================
! k-omega type of models. k is zero on the wall and thus the
! halo value is the negative of the first internal cell.
! for omega the situation is a bit more complicated.
! theoretically omega is infinity, but it is set to a large
! value, see menter's paper. the halo value is constructed
! such that the wall value is correct. make sure that i and j
! are limited to physical dimensions of the face for the wall
! distance. due to the usage of the dd2wall pointer and the
! fact that the original d2wall array starts at 2, there is
! an offset of -1 present in dd2wall.
    select case  (bcfaceid(nn)) 
    case (imin) 
      iimax = jl
      jjmax = kl
      do j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
        if (j .gt. jjmax) then
          y1 = jjmax
        else
          y1 = j
        end if
        if (2 .lt. y1) then
          call pushinteger4(jj)
          jj = y1
          call pushcontrol1b(0)
        else
          call pushinteger4(jj)
          jj = 2
          call pushcontrol1b(1)
        end if
        do i=bcdata(nn)%icbeg,bcdata(nn)%icend
          if (i .gt. iimax) then
            y2 = iimax
          else
            y2 = i
          end if
          if (2 .lt. y2) then
            call pushinteger4(ii)
            ii = y2
            call pushcontrol1b(0)
          else
            call pushinteger4(ii)
            ii = 2
            call pushcontrol1b(1)
          end if
        end do
      end do
      do j=bcdata(nn)%jcend,bcdata(nn)%jcbeg,-1
        do i=bcdata(nn)%icend,bcdata(nn)%icbeg,-1
          nu = rlv(2, i, j)/w(2, i, j, irho)
          tmpd = one/(rkwbeta1*d2wall(2, ii, jj)**2)
          tempd = two*60.0_realtype*bvti1d(i, j, itu2)
          nud = tmpd*tempd
          tmpdd = nu*tempd
          bvti1d(i, j, itu2) = 0.0_8
          temp0 = rkwbeta1*d2wall(2, ii, jj)**2
          d2walld(2, ii, jj) = d2walld(2, ii, jj) - rkwbeta1*one*2*&
&           d2wall(2, ii, jj)*tmpdd/temp0**2
          temp = w(2, i, j, irho)
          rlvd(2, i, j) = rlvd(2, i, j) + nud/temp
          wd(2, i, j, irho) = wd(2, i, j, irho) - rlv(2, i, j)*nud/temp&
&           **2
          call popcontrol1b(branch)
          if (branch .eq. 0) then
            call popinteger4(ii)
          else
            call popinteger4(ii)
          end if
        end do
        call popcontrol1b(branch)
        if (branch .eq. 0) then
          call popinteger4(jj)
        else
          call popinteger4(jj)
        end if
      end do
    case (imax) 
      iimax = jl
      jjmax = kl
      do j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
        if (j .gt. jjmax) then
          y3 = jjmax
        else
          y3 = j
        end if
        if (2 .lt. y3) then
          call pushinteger4(jj)
          jj = y3
          call pushcontrol1b(0)
        else
          call pushinteger4(jj)
          jj = 2
          call pushcontrol1b(1)
        end if
        do i=bcdata(nn)%icbeg,bcdata(nn)%icend
          if (i .gt. iimax) then
            y4 = iimax
          else
            y4 = i
          end if
          if (2 .lt. y4) then
            call pushinteger4(ii)
            ii = y4
            call pushcontrol1b(0)
          else
            call pushinteger4(ii)
            ii = 2
            call pushcontrol1b(1)
          end if
        end do
      end do
      do j=bcdata(nn)%jcend,bcdata(nn)%jcbeg,-1
        do i=bcdata(nn)%icend,bcdata(nn)%icbeg,-1
          nu = rlv(jl, i, j)/w(il, i, j, irho)
          tmpd = one/(rkwbeta1*d2wall(il, ii, jj)**2)
          tempd0 = two*60.0_realtype*bvti2d(i, j, itu2)
          nud = tmpd*tempd0
          tmpdd = nu*tempd0
          bvti2d(i, j, itu2) = 0.0_8
          temp2 = rkwbeta1*d2wall(il, ii, jj)**2
          d2walld(il, ii, jj) = d2walld(il, ii, jj) - rkwbeta1*one*2*&
&           d2wall(il, ii, jj)*tmpdd/temp2**2
          temp1 = w(il, i, j, irho)
          rlvd(jl, i, j) = rlvd(jl, i, j) + nud/temp1
          wd(il, i, j, irho) = wd(il, i, j, irho) - rlv(jl, i, j)*nud/&
&           temp1**2
          call popcontrol1b(branch)
          if (branch .eq. 0) then
            call popinteger4(ii)
          else
            call popinteger4(ii)
          end if
        end do
        call popcontrol1b(branch)
        if (branch .eq. 0) then
          call popinteger4(jj)
        else
          call popinteger4(jj)
        end if
      end do
    case (jmin) 
      iimax = il
      jjmax = kl
      do j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
        if (j .gt. jjmax) then
          y5 = jjmax
        else
          y5 = j
        end if
        if (2 .lt. y5) then
          call pushinteger4(jj)
          jj = y5
          call pushcontrol1b(0)
        else
          call pushinteger4(jj)
          jj = 2
          call pushcontrol1b(1)
        end if
        do i=bcdata(nn)%icbeg,bcdata(nn)%icend
          if (i .gt. iimax) then
            y6 = iimax
          else
            y6 = i
          end if
          if (2 .lt. y6) then
            call pushinteger4(ii)
            ii = y6
            call pushcontrol1b(0)
          else
            call pushinteger4(ii)
            ii = 2
            call pushcontrol1b(1)
          end if
        end do
      end do
      do j=bcdata(nn)%jcend,bcdata(nn)%jcbeg,-1
        do i=bcdata(nn)%icend,bcdata(nn)%icbeg,-1
          nu = rlv(i, 2, j)/w(i, 2, j, irho)
          tmpd = one/(rkwbeta1*d2wall(ii, 2, jj)**2)
          tempd1 = two*60.0_realtype*bvtj1d(i, j, itu2)
          nud = tmpd*tempd1
          tmpdd = nu*tempd1
          bvtj1d(i, j, itu2) = 0.0_8
          temp4 = rkwbeta1*d2wall(ii, 2, jj)**2
          d2walld(ii, 2, jj) = d2walld(ii, 2, jj) - rkwbeta1*one*2*&
&           d2wall(ii, 2, jj)*tmpdd/temp4**2
          temp3 = w(i, 2, j, irho)
          rlvd(i, 2, j) = rlvd(i, 2, j) + nud/temp3
          wd(i, 2, j, irho) = wd(i, 2, j, irho) - rlv(i, 2, j)*nud/temp3&
&           **2
          call popcontrol1b(branch)
          if (branch .eq. 0) then
            call popinteger4(ii)
          else
            call popinteger4(ii)
          end if
        end do
        call popcontrol1b(branch)
        if (branch .eq. 0) then
          call popinteger4(jj)
        else
          call popinteger4(jj)
        end if
      end do
    case (jmax) 
      iimax = il
      jjmax = kl
      do j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
        if (j .gt. jjmax) then
          y7 = jjmax
        else
          y7 = j
        end if
        if (2 .lt. y7) then
          call pushinteger4(jj)
          jj = y7
          call pushcontrol1b(0)
        else
          call pushinteger4(jj)
          jj = 2
          call pushcontrol1b(1)
        end if
        do i=bcdata(nn)%icbeg,bcdata(nn)%icend
          if (i .gt. iimax) then
            y8 = iimax
          else
            y8 = i
          end if
          if (2 .lt. y8) then
            call pushinteger4(ii)
            ii = y8
            call pushcontrol1b(0)
          else
            call pushinteger4(ii)
            ii = 2
            call pushcontrol1b(1)
          end if
        end do
      end do
      do j=bcdata(nn)%jcend,bcdata(nn)%jcbeg,-1
        do i=bcdata(nn)%icend,bcdata(nn)%icbeg,-1
          nu = rlv(i, jl, j)/w(i, jl, j, irho)
          tmpd = one/(rkwbeta1*d2wall(ii, jl, jj)**2)
          tempd2 = two*60.0_realtype*bvtj2d(i, j, itu2)
          nud = tmpd*tempd2
          tmpdd = nu*tempd2
          bvtj2d(i, j, itu2) = 0.0_8
          temp6 = rkwbeta1*d2wall(ii, jl, jj)**2
          d2walld(ii, jl, jj) = d2walld(ii, jl, jj) - rkwbeta1*one*2*&
&           d2wall(ii, jl, jj)*tmpdd/temp6**2
          temp5 = w(i, jl, j, irho)
          rlvd(i, jl, j) = rlvd(i, jl, j) + nud/temp5
          wd(i, jl, j, irho) = wd(i, jl, j, irho) - rlv(i, jl, j)*nud/&
&           temp5**2
          call popcontrol1b(branch)
          if (branch .eq. 0) then
            call popinteger4(ii)
          else
            call popinteger4(ii)
          end if
        end do
        call popcontrol1b(branch)
        if (branch .eq. 0) then
          call popinteger4(jj)
        else
          call popinteger4(jj)
        end if
      end do
    case (kmin) 
      iimax = il
      jjmax = jl
      do j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
        if (j .gt. jjmax) then
          y9 = jjmax
        else
          y9 = j
        end if
        if (2 .lt. y9) then
          call pushinteger4(jj)
          jj = y9
          call pushcontrol1b(0)
        else
          call pushinteger4(jj)
          jj = 2
          call pushcontrol1b(1)
        end if
        do i=bcdata(nn)%icbeg,bcdata(nn)%icend
          if (i .gt. iimax) then
            y10 = iimax
          else
            y10 = i
          end if
          if (2 .lt. y10) then
            call pushinteger4(ii)
            ii = y10
            call pushcontrol1b(0)
          else
            call pushinteger4(ii)
            ii = 2
            call pushcontrol1b(1)
          end if
        end do
      end do
      do j=bcdata(nn)%jcend,bcdata(nn)%jcbeg,-1
        do i=bcdata(nn)%icend,bcdata(nn)%icbeg,-1
          nu = rlv(i, j, 2)/w(i, j, 2, irho)
          tmpd = one/(rkwbeta1*d2wall(ii, jj, 2)**2)
          tempd3 = two*60.0_realtype*bvtk1d(i, j, itu2)
          nud = tmpd*tempd3
          tmpdd = nu*tempd3
          bvtk1d(i, j, itu2) = 0.0_8
          temp8 = rkwbeta1*d2wall(ii, jj, 2)**2
          d2walld(ii, jj, 2) = d2walld(ii, jj, 2) - rkwbeta1*one*2*&
&           d2wall(ii, jj, 2)*tmpdd/temp8**2
          temp7 = w(i, j, 2, irho)
          rlvd(i, j, 2) = rlvd(i, j, 2) + nud/temp7
          wd(i, j, 2, irho) = wd(i, j, 2, irho) - rlv(i, j, 2)*nud/temp7&
&           **2
          call popcontrol1b(branch)
          if (branch .eq. 0) then
            call popinteger4(ii)
          else
            call popinteger4(ii)
          end if
        end do
        call popcontrol1b(branch)
        if (branch .eq. 0) then
          call popinteger4(jj)
        else
          call popinteger4(jj)
        end if
      end do
    case (kmax) 
      iimax = il
      jjmax = jl
      do j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
        if (j .gt. jjmax) then
          y11 = jjmax
        else
          y11 = j
        end if
        if (2 .lt. y11) then
          call pushinteger4(jj)
          jj = y11
          call pushcontrol1b(0)
        else
          call pushinteger4(jj)
          jj = 2
          call pushcontrol1b(1)
        end if
        do i=bcdata(nn)%icbeg,bcdata(nn)%icend
          if (i .gt. iimax) then
            y12 = iimax
          else
            y12 = i
          end if
          if (2 .lt. y12) then
            call pushinteger4(ii)
            ii = y12
            call pushcontrol1b(0)
          else
            call pushinteger4(ii)
            ii = 2
            call pushcontrol1b(1)
          end if
        end do
      end do
      do j=bcdata(nn)%jcend,bcdata(nn)%jcbeg,-1
        do i=bcdata(nn)%icend,bcdata(nn)%icbeg,-1
          nu = rlv(i, j, kl)/w(i, j, kl, irho)
          tmpd = one/(rkwbeta1*d2wall(ii, jj, kl)**2)
          tempd4 = two*60.0_realtype*bvtk2d(i, j, itu2)
          nud = tmpd*tempd4
          tmpdd = nu*tempd4
          bvtk2d(i, j, itu2) = 0.0_8
          temp10 = rkwbeta1*d2wall(ii, jj, kl)**2
          d2walld(ii, jj, kl) = d2walld(ii, jj, kl) - rkwbeta1*one*2*&
&           d2wall(ii, jj, kl)*tmpdd/temp10**2
          temp9 = w(i, j, kl, irho)
          rlvd(i, j, kl) = rlvd(i, j, kl) + nud/temp9
          wd(i, j, kl, irho) = wd(i, j, kl, irho) - rlv(i, j, kl)*nud/&
&           temp9**2
          call popcontrol1b(branch)
          if (branch .eq. 0) then
            call popinteger4(ii)
          else
            call popinteger4(ii)
          end if
        end do
        call popcontrol1b(branch)
        if (branch .eq. 0) then
          call popinteger4(jj)
        else
          call popinteger4(jj)
        end if
      end do
    end select
  end select
end subroutine bcturbwall_b
