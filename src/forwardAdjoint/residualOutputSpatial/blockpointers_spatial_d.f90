   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.4 (r3375) - 10 Feb 2010 15:08
   !
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          blockPointers.f90                               *
   !      * Author:        Edwin van der Weide, Steve Repsher              *
   !      * Starting date: 03-07-2003                                      *
   !      * Last modified: 11-21-2007                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   MODULE BLOCKPOINTERS_SPATIAL_D
   USE BLOCK
   IMPLICIT NONE
   !
   !      ******************************************************************
   !      *                                                                *
   !      * This module contains the pointers for all variables inside a   *
   !      * block. The pointers are set via the subroutine setPointers,    *
   !      * which can be found in the utils directory. In this way the     *
   !      * code becomes much more readable. The relation to the original  *
   !      * multiblock grid is not copied, because it does not affect the  *
   !      * computation.                                                   *
   !      *                                                                *
   !      * See the module block for the meaning of the variables.         *
   !      *                                                                *
   !      * Note that the dimensions are not pointers, but integers.       *
   !      * Consequently changing dimensions of a block must be done only  *
   !      * with the variables of floDoms.                                 *
   !      *                                                                *
   !      ******************************************************************
   !
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Additional info, such that it is known to which block the data *
   !      * inside this module belongs.                                    *
   !      *                                                                *
   !      ******************************************************************
   !
   ! sectionID:   the section to which this block belongs.
   ! nbkLocal :   local block number.
   ! nbkGlobal:   global block number in the original cgns grid.
   ! mgLevel:     the multigrid level.
   ! spectralSol: the spectral solution index of this block.
   INTEGER(kind=inttype) :: sectionid
   INTEGER(kind=inttype) :: nbklocal, nbkglobal, mglevel
   INTEGER(kind=inttype) :: spectralsol
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Variables, which are either copied or the pointer is set to    *
   !      * the correct variable in the block. See the module block for    *
   !      * meaning of the variables.                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   INTEGER(kind=inttype) :: nx, ny, nz, il, jl, kl
   INTEGER(kind=inttype) :: ie, je, ke, ib, jb, kb
   LOGICAL :: righthanded
   INTEGER(kind=inttype) :: ibegor, iendor, jbegor, jendor
   INTEGER(kind=inttype) :: kbegor, kendor
   INTEGER(kind=inttype) :: nsubface, n1to1, nbocos, nviscbocos
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: bctype
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: bctyped
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: bcfaceid
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: bcfaceidd
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: nnodessubface
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: cgnssubface
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: inbeg, inend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: inbegd, inendd
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: jnbeg, jnend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: jnbegd, jnendd
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: knbeg, knend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: knbegd, knendd
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: dinbeg, dinend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: djnbeg, djnend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: dknbeg, dknend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: icbeg, icend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: icbegd, icendd
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: jcbeg, jcend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: jcbegd, jcendd
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: kcbeg, kcend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: kcbegd, kcendd
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: neighblock
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: neighproc
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: l1, l2, l3
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: groupnum
   INTEGER(kind=inttype) :: ncellsoverset, ncellsoversetall
   INTEGER(kind=inttype) :: nholes, norphans
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: iblank
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: iblankd
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: ibndry
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: idonor
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: overint
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: neighblockover
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: neighprocover
   TYPE(BCDATATYPE), DIMENSION(:), POINTER :: bcdata
   TYPE(BCDATATYPE_SPATIAL_D), DIMENSION(:), POINTER :: bcdatad
   TYPE(VISCSUBFACETYPE), DIMENSION(:), POINTER :: viscsubface
   TYPE(VISCSUBFACETYPE), DIMENSION(:), POINTER :: viscsubfaced
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: visciminpointer
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: visciminpointerd
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: viscimaxpointer
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: viscimaxpointerd
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: viscjminpointer
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: viscjminpointerd
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: viscjmaxpointer
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: viscjmaxpointerd
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: visckminpointer
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: visckminpointerd
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: visckmaxpointer
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: visckmaxpointerd
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: x
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: xd
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: xold
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: xoldd
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: si, sj, sk
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: sid, sjd, skd
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: vol
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: vold
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: volold
   INTEGER(kind=portype), DIMENSION(:, :, :), POINTER :: pori
   INTEGER(kind=portype), DIMENSION(:, :, :), POINTER :: porid
   INTEGER(kind=portype), DIMENSION(:, :, :), POINTER :: porj
   INTEGER(kind=portype), DIMENSION(:, :, :), POINTER :: porjd
   INTEGER(kind=portype), DIMENSION(:, :, :), POINTER :: pork
   INTEGER(kind=portype), DIMENSION(:, :, :), POINTER :: porkd
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: indfamilyi
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: indfamilyid
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: indfamilyj
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: indfamilyjd
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: indfamilyk
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: indfamilykd
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: factfamilyi
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: factfamilyid
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: factfamilyj
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: factfamilyjd
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: factfamilyk
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: factfamilykd
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: rotmatrixi
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: rotmatrixid
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: rotmatrixj
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: rotmatrixjd
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: rotmatrixk
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: rotmatrixkd
   LOGICAL :: blockismoving, addgridvelocities
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: sfacei
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: sfaceid
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: sfacej
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: sfacejd
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: sfacek
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: sfacekd
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: w
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: wd
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: wold
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: p, gamma
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: pd, gammad
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: rlv, rev
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: rlvd, revd
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: s
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: sd
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: p1
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: dw, fw
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: dwd, fwd
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: dwoldrk
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: w1, wr
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: mgifine
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: mgjfine
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: mgkfine
   REAL(kind=realtype), DIMENSION(:), POINTER :: mgiweight
   REAL(kind=realtype), DIMENSION(:), POINTER :: mgjweight
   REAL(kind=realtype), DIMENSION(:), POINTER :: mgkweight
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: mgicoarse
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: mgjcoarse
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: mgkcoarse
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: wn
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: pn
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: dtl
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: dtld
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: radi
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: radid
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: radj
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: radjd
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: radk
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: radkd
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: d2wall
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: bmti1
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: bmti2
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: bmtj1
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: bmtj2
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: bmtk1
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: bmtk2
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: bvti1, bvti2
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: bvtj1, bvtj2
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: bvtk1, bvtk2
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: globalnode
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: globalcell
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: psiadj
   TYPE(WARP_COMM_TYPE), DIMENSION(:), POINTER :: warp_comm
   !INTEGER(KIND=INTTYPE),dimension(:),pointer :: incrementI,&
   !       IncrementJ,incrementK
   !INTEGER(KIND=INTTYPE),dimension(:),pointer :: incrementdI,&
   !       IncrementdJ,incrementdK
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: ifaceptb, iedgeptb
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: &
   &  w_offtimeinstance
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: &
   &  w_offtimeinstanced
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: &
   &  vol_offtimeinstance
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: &
   &  vol_offtimeinstanced
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: d2walld
   END MODULE BLOCKPOINTERS_SPATIAL_D
