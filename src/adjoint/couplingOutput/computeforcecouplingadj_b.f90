   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.3 (r3163) - 09/25/2009 09:03
   !
   !  Differentiation of computeforcecouplingadj in reverse (adjoint) mode:
   !   gradient, with respect to input variables: refpoint pts wadj
   !   of linear combination of output variables: moment refpoint
   !                force
   !
   !     ******************************************************************
   !     *                                                                *
   !     * File:          computeForceCouplingAdj.f90                     *
   !     * Author:        Gaetan Kenway                                   *
   !     * Starting date: 09-27-2010                                      *
   !     * Last modified: 09-27-2010                                      *
   !     *                                                                *
   !     ******************************************************************
   SUBROUTINE COMPUTEFORCECOUPLINGADJ_B(force, forceb, moment, momentb, pts&
   &  , ptsb, wadj, wadjb, refpoint, refpointb, fact, ibeg, iend, jbeg, jend&
   &  , inode, jnode, righthanded)
   USE CONSTANTS
   USE FLOWVARREFSTATE
   IMPLICIT NONE
   !nw
   !     Subroutine arguments.
   REAL(kind=realtype), INTENT(IN) :: pts(3, 3, 3)
   REAL(kind=realtype) :: ptsb(3, 3, 3)
   REAL(kind=realtype), INTENT(IN) :: wadj(2, 2, 2, nw)
   REAL(kind=realtype) :: wadjb(2, 2, 2, nw)
   REAL(kind=realtype), INTENT(IN) :: fact
   REAL(kind=realtype), INTENT(IN) :: refpoint(3)
   REAL(kind=realtype) :: refpointb(3)
   INTEGER(kind=inttype), INTENT(IN) :: ibeg, iend, jbeg, jend, inode, &
   &  jnode
   LOGICAL, INTENT(IN) :: righthanded
   REAL(kind=realtype) :: force(3)
   REAL(kind=realtype) :: forceb(3)
   REAL(kind=realtype) :: moment(3)
   REAL(kind=realtype) :: momentb(3)
   ! Local Variables
   INTEGER(kind=inttype) :: i, j, k, l, kk
   REAL(kind=realtype) :: padj(3, 2, 2)
   REAL(kind=realtype) :: padjb(3, 2, 2)
   REAL(kind=realtype) :: normadj(3, 2, 2)
   REAL(kind=realtype) :: normadjb(3, 2, 2)
   ! Compute the pressure in the 2x2x2 block
   padj = 0.0
   CALL COMPUTEFORCECOUPLINGPRESSUREADJ(wadj, padj(2:3, :, :))
   CALL GETSURFACENORMALSCOUPLINGADJ(pts, normadj, righthanded)
   CALL PUSHREAL8ARRAY(padj, realtype*3*2**2/8)
   CALL BCEULERWALLFORCECOUPLINGADJ(wadj, padj)
   CALL FORCESCOUPLINGADJ_B(padj, padjb, pts, ptsb, normadj, normadjb, &
   &                     refpoint, refpointb, force, forceb, moment, momentb&
   &                     , fact, ibeg, iend, jbeg, jend, inode, jnode)
   forceb = 0.0
   CALL POPREAL8ARRAY(padj, realtype*3*2**2/8)
   CALL BCEULERWALLFORCECOUPLINGADJ_B(wadj, padj, padjb)
   CALL GETSURFACENORMALSCOUPLINGADJ_B(pts, ptsb, normadj, normadjb, &
   &                                righthanded)
   CALL COMPUTEFORCECOUPLINGPRESSUREADJ_B(wadj, wadjb, padj(2:3, :, :), &
   &                                   padjb(2:3, :, :))
   END SUBROUTINE COMPUTEFORCECOUPLINGADJ_B
