   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.3 (r3163) - 09/25/2009 09:03
   !
   !  Differentiation of bceulerwallforcecouplingadj in reverse (adjoint) mode:
   !   gradient, with respect to input variables: padj
   !   of linear combination of output variables: padj
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          bcEulerWallAdj.f90                              *
   !      * Author:        Edwin van der Weide                             *
   !      *                Seongim Choi,C.A.(Sandy) Mader                  *
   !      * Starting date: 03-21-2006                                      *
   !      * Last modified: 06-09-2008                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE BCEULERWALLFORCECOUPLINGADJ_B(wadj, padj, padjb)
   USE INPUTDISCRETIZATION
   USE FLOWVARREFSTATE
   IMPLICIT NONE
   !
   !      ******************************************************************
   !      *                                                                *
   !      * bcEulerWallAdj applies inviscid wall pplies the inviscid wall boundary condition to  *
   !      * subface nn of the block to which the pointers in blockPointers *
   !      * currently point.                                               *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Subroutine Arguments
   REAL(kind=realtype), INTENT(IN) :: wadj(2, 2, 2, nw)
   REAL(kind=realtype), INTENT(INOUT) :: padj(3, 2, 2)
   REAL(kind=realtype) :: padjb(3, 2, 2)
   ! Local variables.
   INTEGER(kind=inttype) :: i, j, k
   EXTERNAL TERMINATE
   INTEGER :: branch
   INTRINSIC MAX
   SELECT CASE  (wallbctreatment) 
   CASE (constantpressure) 
   DO j=1,2
   DO i=1,2
   padj(1, i, j) = zero
   END DO
   END DO
   CALL PUSHINTEGER4(1)
   CASE (linextrapolpressure) 
   DO j=1,2
   DO i=1,2
   padj(1, i, j) = padj(3, i, j) - padj(2, i, j)
   END DO
   END DO
   CALL PUSHINTEGER4(2)
   CASE (quadextrapolpressure) 
   CALL PUSHINTEGER4(0)
   CASE (normalmomentum) 
   CALL PUSHINTEGER4(0)
   CASE DEFAULT
   CALL PUSHINTEGER4(0)
   END SELECT
   ! Determine the state in the halo cell. Again loop over
   ! the cell range for this subface.
   DO j=1,2
   DO i=1,2
   IF (zero .LT. padj(2, i, j) - padj(1, i, j)) THEN
   CALL PUSHINTEGER4(2)
   ELSE
   CALL PUSHINTEGER4(1)
   END IF
   END DO
   END DO
   DO j=2,1,-1
   DO i=2,1,-1
   CALL POPINTEGER4(branch)
   IF (branch .LT. 2) THEN
   padjb(1, i, j) = 0.0
   ELSE
   padjb(2, i, j) = padjb(2, i, j) + padjb(1, i, j)
   padjb(1, i, j) = -padjb(1, i, j)
   END IF
   END DO
   END DO
   CALL POPINTEGER4(branch)
   IF (branch .LT. 2) THEN
   IF (.NOT.branch .LT. 1) THEN
   DO j=2,1,-1
   DO i=2,1,-1
   padjb(1, i, j) = 0.0
   END DO
   END DO
   END IF
   ELSE
   DO j=2,1,-1
   DO i=2,1,-1
   padjb(3, i, j) = padjb(3, i, j) + padjb(1, i, j)
   padjb(2, i, j) = padjb(2, i, j) - padjb(1, i, j)
   padjb(1, i, j) = 0.0
   END DO
   END DO
   END IF
   END SUBROUTINE BCEULERWALLFORCECOUPLINGADJ_B
