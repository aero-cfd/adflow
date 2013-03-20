   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.6 (r4159) - 21 Sep 2011 10:11
   !
   !  Differentiation of timestep_block in reverse (adjoint) mode:
   !   gradient     of useful results: *p *sfacei *sfacej *sfacek
   !                *w *si *sj *sk *radi *radj *radk
   !   with respect to varying inputs: *p *sfacei *sfacej *sfacek
   !                *w *si *sj *sk adis
   !   Plus diff mem management of: rev:in p:in sfacei:in sfacej:in
   !                gamma:in sfacek:in w:in rlv:in vol:in si:in sj:in
   !                sk:in radi:in radj:in radk:in
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          timeStep.f90                                    *
   !      * Author:        Edwin van der Weide                             *
   !      * Starting date: 03-17-2003                                      *
   !      * Last modified: 06-28-2005                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE TIMESTEP_BLOCK_B(onlyradii)
   USE INPUTITERATION
   USE BLOCKPOINTERS_B
   USE SECTION
   USE INPUTTIMESPECTRAL
   USE INPUTPHYSICS
   USE INPUTDISCRETIZATION
   USE CONSTANTS
   USE ITERATION
   USE FLOWVARREFSTATE
   IMPLICIT NONE
   !
   !      ******************************************************************
   !      *                                                                *
   !      * timeStep computes the time step, or more precisely the time    *
   !      * step divided by the volume per unit CFL, in the owned cells.   *
   !      * However, for the artificial dissipation schemes, the spectral  *
   !      * radIi in the halo's are needed. Therefore the loop is taken    *
   !      * over the the first level of halo cells. The spectral radIi are *
   !      * stored and possibly modified for high aspect ratio cells.      *
   !      *                                                                *
   !      ******************************************************************
   !
   !
   !      Subroutine argument.
   !
   LOGICAL, INTENT(IN) :: onlyradii
   !
   !      Local parameters.
   !
   REAL(kind=realtype), PARAMETER :: b=2.0_realType
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: sps, nn, i, j, k
   REAL(kind=realtype) :: plim, rlim, clim2
   REAL(kind=realtype) :: ux, uy, uz, cc2, qs, sx, sy, sz, rmu
   REAL(kind=realtype) :: uxb, uyb, uzb, cc2b, qsb, sxb, syb, szb
   REAL(kind=realtype) :: ri, rj, rk, rij, rjk, rki
   REAL(kind=realtype) :: rib, rjb, rkb, rijb, rjkb, rkib
   REAL(kind=realtype) :: vsi, vsj, vsk, rfl, dpi, dpj, dpk
   REAL(kind=realtype) :: sface, tmp
   REAL(kind=realtype) :: sfaceb
   LOGICAL :: radiineeded
   INTEGER :: branch
   REAL(kind=realtype) :: temp2
   REAL(kind=realtype) :: temp1
   REAL(kind=realtype) :: temp0
   REAL(kind=realtype) :: abs1b
   REAL(kind=realtype) :: temp0b
   INTRINSIC MAX
   REAL(kind=realtype) :: temp3b
   INTRINSIC ABS
   REAL(kind=realtype) :: temp2b0
   REAL(kind=realtype) :: abs0b
   REAL(kind=realtype) :: tempb
   REAL(kind=realtype) :: temp0b0
   REAL(kind=realtype) :: temp2b
   REAL(kind=realtype) :: temp3b4
   REAL(kind=realtype) :: temp3b3
   REAL(kind=realtype) :: temp3b2
   REAL(kind=realtype) :: temp3b1
   REAL(kind=realtype) :: temp3b0
   REAL(kind=realtype) :: abs5
   REAL(kind=realtype) :: abs4
   REAL(kind=realtype) :: abs3
   REAL(kind=realtype) :: abs2
   REAL(kind=realtype) :: abs1
   REAL(kind=realtype) :: abs0
   REAL(kind=realtype) :: abs2b
   REAL(kind=realtype) :: temp1b
   INTRINSIC SQRT
   REAL(kind=realtype) :: temp
   REAL(kind=realtype) :: temp1b0
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Determine whether or not the spectral radii are needed for the
   ! flux computation.
   radiineeded = radiineededcoarse
   IF (currentlevel .LE. groundlevel) radiineeded = radiineededfine
   ! Return immediately if only the spectral radii must be computed
   ! and these are not needed for the flux computation.
   IF (.NOT.(onlyradii .AND. (.NOT.radiineeded))) THEN
   ! Set the value of plim. To be fully consistent this must have
   ! the dimension of a pressure. Therefore a fraction of pInfCorr
   ! is used. Idem for rlim; compute clim2 as well.
   clim2 = 0.000001_realType*gammainf*pinfcorr/rhoinf
   ! Initialize sFace to zero. This value will be used if the
   ! block is not moving.
   sface = zero
   !
   !          **************************************************************
   !          *                                                            *
   !          * Inviscid contribution, depending on the preconditioner.    *
   !          * Compute the cell centered values of the spectral radii.    *
   !          *                                                            *
   !          **************************************************************
   !
   SELECT CASE  (precond) 
   CASE (noprecond) 
   ! No preconditioner. Simply the standard spectral radius.
   ! Loop over the cells, including the first level halo.
   DO k=1,ke
   DO j=1,je
   DO i=1,ie
   ! Compute the velocities and speed of sound squared.
   ux = w(i, j, k, ivx)
   uy = w(i, j, k, ivy)
   uz = w(i, j, k, ivz)
   CALL PUSHREAL8(cc2)
   cc2 = gamma(i, j, k)*p(i, j, k)/w(i, j, k, irho)
   IF (cc2 .LT. clim2) THEN
   cc2 = clim2
   CALL PUSHCONTROL1B(0)
   ELSE
   CALL PUSHCONTROL1B(1)
   cc2 = cc2
   END IF
   ! Set the dot product of the grid velocity and the
   ! normal in i-direction for a moving face. To avoid
   ! a number of multiplications by 0.5 simply the sum
   ! is taken.
   IF (addgridvelocities) THEN
   sface = sfacei(i-1, j, k) + sfacei(i, j, k)
   CALL PUSHCONTROL1B(1)
   ELSE
   CALL PUSHCONTROL1B(0)
   END IF
   ! Spectral radius in i-direction.
   sx = si(i-1, j, k, 1) + si(i, j, k, 1)
   sy = si(i-1, j, k, 2) + si(i, j, k, 2)
   sz = si(i-1, j, k, 3) + si(i, j, k, 3)
   qs = ux*sx + uy*sy + uz*sz - sface
   IF (qs .GE. 0.) THEN
   abs0 = qs
   CALL PUSHCONTROL1B(0)
   ELSE
   abs0 = -qs
   CALL PUSHCONTROL1B(1)
   END IF
   radi(i, j, k) = half*(abs0+SQRT(cc2*(sx**2+sy**2+sz**2)))
   ! The grid velocity in j-direction.
   IF (addgridvelocities) THEN
   sface = sfacej(i, j-1, k) + sfacej(i, j, k)
   CALL PUSHCONTROL1B(1)
   ELSE
   CALL PUSHCONTROL1B(0)
   END IF
   ! Spectral radius in j-direction.
   sx = sj(i, j-1, k, 1) + sj(i, j, k, 1)
   sy = sj(i, j-1, k, 2) + sj(i, j, k, 2)
   sz = sj(i, j-1, k, 3) + sj(i, j, k, 3)
   qs = ux*sx + uy*sy + uz*sz - sface
   IF (qs .GE. 0.) THEN
   abs1 = qs
   CALL PUSHCONTROL1B(0)
   ELSE
   abs1 = -qs
   CALL PUSHCONTROL1B(1)
   END IF
   radj(i, j, k) = half*(abs1+SQRT(cc2*(sx**2+sy**2+sz**2)))
   ! The grid velocity in k-direction.
   IF (addgridvelocities) THEN
   sface = sfacek(i, j, k-1) + sfacek(i, j, k)
   CALL PUSHCONTROL1B(1)
   ELSE
   CALL PUSHCONTROL1B(0)
   END IF
   ! Spectral radius in k-direction.
   sx = sk(i, j, k-1, 1) + sk(i, j, k, 1)
   sy = sk(i, j, k-1, 2) + sk(i, j, k, 2)
   sz = sk(i, j, k-1, 3) + sk(i, j, k, 3)
   qs = ux*sx + uy*sy + uz*sz - sface
   IF (qs .GE. 0.) THEN
   abs2 = qs
   CALL PUSHCONTROL1B(0)
   ELSE
   abs2 = -qs
   CALL PUSHCONTROL1B(1)
   END IF
   radk(i, j, k) = half*(abs2+SQRT(cc2*(sx**2+sy**2+sz**2)))
   ! Compute the inviscid contribution to the time step.
   END DO
   END DO
   END DO
   CALL PUSHCONTROL1B(0)
   CASE (turkel) 
   CALL PUSHCONTROL1B(1)
   CASE (choimerkle) 
   CALL PUSHCONTROL1B(1)
   CASE DEFAULT
   CALL PUSHCONTROL1B(1)
   END SELECT
   !
   !          **************************************************************
   !          *                                                            *
   !          * Adapt the spectral radii if directional scaling must be    *
   !          * applied.                                                   *
   !          *                                                            *
   !          **************************************************************
   !
   IF (dirscaling .AND. currentlevel .LE. groundlevel) THEN
   ! if( dirScaling ) then
   DO k=1,ke
   DO j=1,je
   DO i=1,ie
   IF (radi(i, j, k) .LT. eps) THEN
   CALL PUSHREAL8(ri)
   ri = eps
   CALL PUSHCONTROL1B(0)
   ELSE
   CALL PUSHREAL8(ri)
   ri = radi(i, j, k)
   CALL PUSHCONTROL1B(1)
   END IF
   IF (radj(i, j, k) .LT. eps) THEN
   CALL PUSHREAL8(rj)
   rj = eps
   CALL PUSHCONTROL1B(0)
   ELSE
   CALL PUSHREAL8(rj)
   rj = radj(i, j, k)
   CALL PUSHCONTROL1B(1)
   END IF
   IF (radk(i, j, k) .LT. eps) THEN
   CALL PUSHREAL8(rk)
   rk = eps
   CALL PUSHCONTROL1B(0)
   ELSE
   CALL PUSHREAL8(rk)
   rk = radk(i, j, k)
   CALL PUSHCONTROL1B(1)
   END IF
   ! Compute the scaling in the three coordinate
   ! directions.
   rij = (ri/rj)**adis
   rjk = (rj/rk)**adis
   rki = (rk/ri)**adis
   CALL PUSHREAL8(radi(i, j, k))
   ! Create the scaled versions of the aspect ratios.
   ! Note that the multiplication is done with radi, radJ
   ! and radK, such that the influence of the clipping
   ! is negligible.
   !   radi(i,j,k) = third*radi(i,j,k)*(one + one/rij + rki)
   !   radJ(i,j,k) = third*radJ(i,j,k)*(one + one/rjk + rij)
   !   radK(i,j,k) = third*radK(i,j,k)*(one + one/rki + rjk)
   radi(i, j, k) = radi(i, j, k)*(one+one/rij+rki)
   CALL PUSHREAL8(radj(i, j, k))
   radj(i, j, k) = radj(i, j, k)*(one+one/rjk+rij)
   CALL PUSHREAL8(radk(i, j, k))
   radk(i, j, k) = radk(i, j, k)*(one+one/rki+rjk)
   END DO
   END DO
   END DO
   DO k=ke,1,-1
   DO j=je,1,-1
   DO i=ie,1,-1
   rjk = (rj/rk)**adis
   rki = (rk/ri)**adis
   CALL POPREAL8(radk(i, j, k))
   temp3b = radk(i, j, k)*radkb(i, j, k)
   radkb(i, j, k) = (one+one/rki+rjk)*radkb(i, j, k)
   rij = (ri/rj)**adis
   CALL POPREAL8(radj(i, j, k))
   temp3b1 = radj(i, j, k)*radjb(i, j, k)
   rjkb = temp3b - one*temp3b1/rjk**2
   radjb(i, j, k) = (one+one/rjk+rij)*radjb(i, j, k)
   CALL POPREAL8(radi(i, j, k))
   temp3b0 = radi(i, j, k)*radib(i, j, k)
   rkib = temp3b0 - one*temp3b/rki**2
   rijb = temp3b1 - one*temp3b0/rij**2
   radib(i, j, k) = (one+one/rij+rki)*radib(i, j, k)
   IF (rk/ri .LE. 0.0 .AND. (adis .EQ. 0.0 .OR. adis .NE. INT(&
   &                adis))) THEN
   temp3b2 = 0.0
   ELSE
   temp3b2 = adis*(rk/ri)**(adis-1)*rkib/ri
   END IF
   IF (rj/rk .LE. 0.0 .AND. (adis .EQ. 0.0 .OR. adis .NE. INT(&
   &                adis))) THEN
   temp3b3 = 0.0
   ELSE
   temp3b3 = adis*(rj/rk)**(adis-1)*rjkb/rk
   END IF
   rkb = temp3b2 - rj*temp3b3/rk
   IF (ri/rj .LE. 0.0 .AND. (adis .EQ. 0.0 .OR. adis .NE. INT(&
   &                adis))) THEN
   temp3b4 = 0.0
   ELSE
   temp3b4 = adis*(ri/rj)**(adis-1)*rijb/rj
   END IF
   rib = temp3b4 - rk*temp3b2/ri
   rjb = temp3b3 - ri*temp3b4/rj
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) THEN
   CALL POPREAL8(rk)
   ELSE
   CALL POPREAL8(rk)
   radkb(i, j, k) = radkb(i, j, k) + rkb
   END IF
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) THEN
   CALL POPREAL8(rj)
   ELSE
   CALL POPREAL8(rj)
   radjb(i, j, k) = radjb(i, j, k) + rjb
   END IF
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) THEN
   CALL POPREAL8(ri)
   ELSE
   CALL POPREAL8(ri)
   radib(i, j, k) = radib(i, j, k) + rib
   END IF
   END DO
   END DO
   END DO
   END IF
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) THEN
   sfaceb = 0.0_8
   DO k=ke,1,-1
   DO j=je,1,-1
   DO i=ie,1,-1
   sx = sk(i, j, k-1, 1) + sk(i, j, k, 1)
   sy = sk(i, j, k-1, 2) + sk(i, j, k, 2)
   sz = sk(i, j, k-1, 3) + sk(i, j, k, 3)
   temp2 = sx**2 + sy**2 + sz**2
   IF (cc2*temp2 .EQ. 0.0) THEN
   temp2b = 0.0
   ELSE
   temp2b = half*radkb(i, j, k)/(2.0*SQRT(cc2*temp2))
   END IF
   temp2b0 = cc2*temp2b
   abs2b = half*radkb(i, j, k)
   cc2b = temp2*temp2b
   sxb = 2*sx*temp2b0
   syb = 2*sy*temp2b0
   szb = 2*sz*temp2b0
   radkb(i, j, k) = 0.0_8
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) THEN
   qsb = abs2b
   ELSE
   qsb = -abs2b
   END IF
   ux = w(i, j, k, ivx)
   uy = w(i, j, k, ivy)
   uz = w(i, j, k, ivz)
   uxb = sx*qsb
   sxb = sxb + ux*qsb
   uyb = sy*qsb
   syb = syb + uy*qsb
   uzb = sz*qsb
   szb = szb + uz*qsb
   sfaceb = sfaceb - qsb
   skb(i, j, k-1, 3) = skb(i, j, k-1, 3) + szb
   skb(i, j, k, 3) = skb(i, j, k, 3) + szb
   skb(i, j, k-1, 2) = skb(i, j, k-1, 2) + syb
   skb(i, j, k, 2) = skb(i, j, k, 2) + syb
   skb(i, j, k-1, 1) = skb(i, j, k-1, 1) + sxb
   skb(i, j, k, 1) = skb(i, j, k, 1) + sxb
   CALL POPCONTROL1B(branch)
   IF (branch .NE. 0) THEN
   sfacekb(i, j, k-1) = sfacekb(i, j, k-1) + sfaceb
   sfacekb(i, j, k) = sfacekb(i, j, k) + sfaceb
   sfaceb = 0.0_8
   END IF
   sx = sj(i, j-1, k, 1) + sj(i, j, k, 1)
   sy = sj(i, j-1, k, 2) + sj(i, j, k, 2)
   sz = sj(i, j-1, k, 3) + sj(i, j, k, 3)
   temp1 = sx**2 + sy**2 + sz**2
   IF (cc2*temp1 .EQ. 0.0) THEN
   temp1b = 0.0
   ELSE
   temp1b = half*radjb(i, j, k)/(2.0*SQRT(cc2*temp1))
   END IF
   temp1b0 = cc2*temp1b
   abs1b = half*radjb(i, j, k)
   cc2b = cc2b + temp1*temp1b
   sxb = 2*sx*temp1b0
   syb = 2*sy*temp1b0
   szb = 2*sz*temp1b0
   radjb(i, j, k) = 0.0_8
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) THEN
   qsb = abs1b
   ELSE
   qsb = -abs1b
   END IF
   uxb = uxb + sx*qsb
   sxb = sxb + ux*qsb
   uyb = uyb + sy*qsb
   syb = syb + uy*qsb
   uzb = uzb + sz*qsb
   szb = szb + uz*qsb
   sfaceb = sfaceb - qsb
   sjb(i, j-1, k, 3) = sjb(i, j-1, k, 3) + szb
   sjb(i, j, k, 3) = sjb(i, j, k, 3) + szb
   sjb(i, j-1, k, 2) = sjb(i, j-1, k, 2) + syb
   sjb(i, j, k, 2) = sjb(i, j, k, 2) + syb
   sjb(i, j-1, k, 1) = sjb(i, j-1, k, 1) + sxb
   sjb(i, j, k, 1) = sjb(i, j, k, 1) + sxb
   CALL POPCONTROL1B(branch)
   IF (branch .NE. 0) THEN
   sfacejb(i, j-1, k) = sfacejb(i, j-1, k) + sfaceb
   sfacejb(i, j, k) = sfacejb(i, j, k) + sfaceb
   sfaceb = 0.0_8
   END IF
   sx = si(i-1, j, k, 1) + si(i, j, k, 1)
   sy = si(i-1, j, k, 2) + si(i, j, k, 2)
   sz = si(i-1, j, k, 3) + si(i, j, k, 3)
   temp0 = sx**2 + sy**2 + sz**2
   IF (cc2*temp0 .EQ. 0.0) THEN
   temp0b = 0.0
   ELSE
   temp0b = half*radib(i, j, k)/(2.0*SQRT(cc2*temp0))
   END IF
   temp0b0 = cc2*temp0b
   abs0b = half*radib(i, j, k)
   cc2b = cc2b + temp0*temp0b
   sxb = 2*sx*temp0b0
   syb = 2*sy*temp0b0
   szb = 2*sz*temp0b0
   radib(i, j, k) = 0.0_8
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) THEN
   qsb = abs0b
   ELSE
   qsb = -abs0b
   END IF
   uxb = uxb + sx*qsb
   sxb = sxb + ux*qsb
   uyb = uyb + sy*qsb
   syb = syb + uy*qsb
   uzb = uzb + sz*qsb
   szb = szb + uz*qsb
   sfaceb = sfaceb - qsb
   sib(i-1, j, k, 3) = sib(i-1, j, k, 3) + szb
   sib(i, j, k, 3) = sib(i, j, k, 3) + szb
   sib(i-1, j, k, 2) = sib(i-1, j, k, 2) + syb
   sib(i, j, k, 2) = sib(i, j, k, 2) + syb
   sib(i-1, j, k, 1) = sib(i-1, j, k, 1) + sxb
   sib(i, j, k, 1) = sib(i, j, k, 1) + sxb
   CALL POPCONTROL1B(branch)
   IF (branch .NE. 0) THEN
   sfaceib(i-1, j, k) = sfaceib(i-1, j, k) + sfaceb
   sfaceib(i, j, k) = sfaceib(i, j, k) + sfaceb
   sfaceb = 0.0_8
   END IF
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) cc2b = 0.0_8
   CALL POPREAL8(cc2)
   temp = w(i, j, k, irho)
   tempb = gamma(i, j, k)*cc2b/temp
   pb(i, j, k) = pb(i, j, k) + tempb
   wb(i, j, k, irho) = wb(i, j, k, irho) - p(i, j, k)*tempb/&
   &              temp
   wb(i, j, k, ivz) = wb(i, j, k, ivz) + uzb
   wb(i, j, k, ivy) = wb(i, j, k, ivy) + uyb
   wb(i, j, k, ivx) = wb(i, j, k, ivx) + uxb
   END DO
   END DO
   END DO
   END IF
   END IF
   adisb = 0.0_8
   END SUBROUTINE TIMESTEP_BLOCK_B