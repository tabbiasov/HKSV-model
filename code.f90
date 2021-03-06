
module share
    REAL(8), PARAMETER :: scalefactor=1.0
    !REAL(8), parameter :: delta=.0857 !depreciation rate of durable
    REAL(8), parameter :: delta=.03 !depreciation rate of durable
    REAL(8), parameter :: deltak=.02 !depreciation rate of capital
    REAL(8), parameter :: alpha= 0.3  ! capitals share in production function
    REAL(8) :: beta2   !Quarterly discount factor
    REAL(8), parameter :: elasticity= 2.0  !elasticity of substitution
    REAL(8) :: elasticity2
    REAL(8) :: durelasticity
    REAL(8), parameter :: theta=0.2 !down payment
    REAL(8) :: relutility
    REAL(8), parameter :: F = 0.05  ! fixed cost
    REAL(8), parameter :: r=.03
    REAL(8), parameter :: rborrow=.040
    REAL(8) :: r_rental
    REAL(8), parameter :: sigma_eps=.018
    REAL(8), parameter :: rho_eps=.947
    REAL(8) :: ret_wealth
    
    
    !REAL(8), parameter :: sigma_eta=.01**.5
    
    REAL(8), parameter :: epsmin=-2.0*(sigma_eps**2.0/(1-rho_eps**2.0))**.5
    REAL(8), parameter :: epsmax=2.0*(sigma_eps**2.0/(1-rho_eps**2.0))**.5

    REAL(8), parameter :: sigma_eps_init=(sigma_eps**2.0/(1-rho_eps**2.0))**.5

    REAL(8), parameter :: sigma_z=.2064
    REAL(8), parameter :: rho_z=.91

    REAL(8), parameter :: sigma_eta_init=(sigma_z**2.0/(1-rho_z**2.0))**.5

    REAL(8), parameter :: zmin=-2.5*(sigma_z**2.0/(1-rho_z**2.0))**.5
    REAL(8), parameter :: zmax=2.5*(sigma_z**2.0/(1-rho_z**2.0))**.5


    !REAL(8), parameter :: zmin=-2.5*(sigma_eta_init**2+34*sigma_eta**2)**.5
    !REAL(8), parameter :: zmax=2.5*(sigma_eta_init**2+34*sigma_eta**2)**.5

    REAL(8) :: phi_r
    !REAL(8), parameter :: phi_h=0.48

    REAL(8), parameter :: phi_h=0.48  !log hp on log employment (implies that a 1 std dev increase in employment increases house prices by .48*.056= 2.7%
    REAL(8), parameter :: phi_eps=1.0 !log employment is driving shock
    REAL(8), parameter :: phi_eps_responseto_h=0.0
    REAL(8), parameter :: phi_h_responseto_r=0.0
    REAL(8), parameter :: phi_eps_responseto_r=0.0
    REAL(8) :: phi_eps_extra  !will be equal to phi_r*phi_h_responseto_r*phi_eps_responseto_h
    REAL(8) :: phi_h_extra !will be equal to phi_r*phi_h_responseto_r

    REAL(8), parameter :: basispointvariation=25
 
    REAL(8), parameter :: amin=0    !minimum asset value (actually voluntary equity if theta!=1).  Note that if theta<1, we can have assets <0 even with amin=0 since a is vol. equity.  But with theta=1 & amin=0, no borrowing.
    REAL(8), parameter :: amax2=2   !max asset
    REAL(8), parameter :: amax=50   !max asset
    REAL(8), parameter :: Dmin=0    !minimum durable choice
    REAL(8), parameter :: Dmax=12   !maximum durable choice
    integer, parameter :: agridsize = 50 ! size of asset grid
    integer, parameter :: Dgridsize = 36 ! size of durable grid
    integer, parameter :: zgridsize=13  !size of perm shock grid
    integer, parameter :: epsgridsize=5 !size of temp shock grid


    REAL(8), DIMENSION(epsgridsize) :: consumptionbystateholder
    REAL(8) :: consumptionoverallholder

    
    
    
    REAL(8), DIMENSION(epsgridsize) :: epsnodes
    REAL(8), DIMENSION(agridsize) :: anodes  !Nodes for idiosyncratic assets (voluntary equity)
    REAL(8), DIMENSION(Dgridsize) :: Dnodes  !Nodes for idiosyncratic durable

    REAL(8), DIMENSION(zgridsize) :: Probinit,Probinitcum
    REAL(8), DIMENSION(epsgridsize) :: Probiniteps,Probinitepscum
    
    
    REAL(8), DIMENSION(zgridsize) :: znodes  !Nodes for idiosyncratic productivity
    
    REAL(8), DIMENSION(zgridsize,zgridsize) :: Probz,Probzcum  !while probability of being at any z will vary with time, transition probability will not, so max we need to loop over wont
    REAL(8), DIMENSION(zgridsize) :: maxexpectationz,minexpectationz  

    REAL(8), DIMENSION(epsgridsize,epsgridsize) :: Probeps,Probepscum
    
    REAL(8), DIMENSION(35) :: ageearnings
    REAL(8), DIMENSION(25) :: deathprob
    REAL(8), DIMENSION(zgridsize,epsgridsize) :: predictedlifetimeearnings,retirementincome
    REAL(8), DIMENSION(zgridsize,epsgridsize,60) :: income
    REAL(8) :: averagelifetimeearnings
    
    REAL(8), DIMENSION(:,:,:,:,:), ALLOCATABLE :: Vadjust,Vrent  !Conjectured value of not adjusting and adjusting, and new values of not adjusting and adjusting
    REAL(8), DIMENSION(:,:,:,:,:,:), ALLOCATABLE :: Vnoadjust, achoicenoadjust, Dchoicenoadjust, achoice, Dchoice,cchoice, Vadjustexpand,Vrentexpand  !Policy functions when solving problem
    REAL(8), DIMENSION(:,:,:,:,:), ALLOCATABLE :: achoiceadjust,achoicerent,  Dchoiceadjust,Dchoicerent
    
   
    REAL(8), DIMENSION(:,:,:,:,:,:), ALLOCATABLE :: rentalindicator
    REAL(8), DIMENSION(:,:,:,:,:,:), ALLOCATABLE :: EV
   
    
    REAL(8), parameter :: numhouseholds=100000    !Size of household panel
    integer, parameter :: burnin=1000    !Initial periods dropped in simulation
    REAL(8), parameter :: calculategap=1  !turn to 1 if you want to calculate price gap distribution
    
    REAL(8) :: diffmoments,diffmoments1,diffmoments2,diffmoments3,diffmoments4
    REAL(8), parameter :: difftol=.05
    !REAL(8), parameter :: difftol=.02
    REAL(8) :: numiter

    REAL(8) :: variablerindicator

    REAL(8) :: expostwelfare_variabler, expostwelfare_constantr, expostwelfare_variableryoung,expostwelfare_variablermiddle,expostwelfare_variablerold, expostwelfare_variablerlowincome,expostwelfare_variablermiddleincome,expostwelfare_variablerhighincome,expostwelfare_constantryoung,expostwelfare_constantrmiddle,expostwelfare_constantrold,expostwelfare_constantrlowincome,expostwelfare_constantrmiddleincome,expostwelfare_constantrhighincome
    REAL(8), dimension(epsgridsize) :: expostwelfarebystate_variabler, expostwelfarebystate_constantr, expostwelfarebystate_variableryoung,expostwelfarebystate_constantryoung, expostwelfarebystate_variablermiddle,expostwelfarebystate_constantrmiddle, expostwelfarebystate_variablerold,expostwelfarebystate_constantrold, expostwelfarebystate_variablerlowincome,expostwelfarebystate_constantrlowincome, expostwelfarebystate_variablermiddleincome,expostwelfarebystate_constantrmiddleincome, expostwelfarebystate_variablerhighincome,expostwelfarebystate_constantrhighincome
    REAL(8), dimension(epsgridsize,350) :: expostwelfarebystate_variablerCE, expostwelfarebystate_variableryoungCE,expostwelfarebystate_variablermiddleCE,expostwelfarebystate_variableroldCE, expostwelfarebystate_variablerlowincomeCE,expostwelfarebystate_variablermiddleincomeCE,expostwelfarebystate_variablerhighincomeCE
    REAL(8), dimension(1,350) :: expostwelfare_variablerCE, expostwelfare_variableryoungCE,expostwelfare_variablermiddleCE,expostwelfare_variableroldCE,expostwelfare_variablerlowincomeCE,expostwelfare_variablermiddleincomeCE,expostwelfare_variablerhighincomeCE


    REAL(8) :: FRMindicator

end module share


program durables  !Program shell
use share
USE OMP_LIB
implicit none
integer :: i,j,k,l,m,n,t, iter
EXTERNAL cdfnormal  !Fnc to compute normal cdf
REAL(8) :: cdfnormal
REAL(8) :: w,ll,rr,ww,niter
REAL(8) :: foundmin, foundmax
REAL(8) :: timestart, timeend
REAL(8) :: dd,m2,m2young,m2middle,m2old,m2lowincome,m2middleincome,m2highincome

OPEN (UNIT=21, FILE="CEresults.txt", STATUS="OLD", ACTION="WRITE", POSITION="REWIND")
21 format (F40.12, F40.12, F40.12, F40.12, F40.12, F40.12,F40.12, F40.12, F40.12, F40.12, F40.12, F40.12, F40.12,F40.12,F40.12, F40.12, F40.12, F40.12, F40.12, F40.12,F40.12,F40.12, F40.12, F40.12, F40.12, F40.12, F40.12,F40.12, F40.12, F40.12, F40.12, F40.12, F40.12, F40.12,F40.12,F40.12, F40.12, F40.12, F40.12, F40.12, F40.12,F40.12)

OPEN (UNIT=22, FILE="model_summary_results.txt", STATUS="OLD", ACTION="WRITE", POSITION="REWIND")
22 format (F10.6, F10.6, F40.12, F40.12, F40.12, F40.12,F40.12, F40.12, F40.12, F40.12, F40.12, F40.12, F40.12,F40.12,F40.12, F40.12, F40.12, F40.12, F40.12, F40.12,F40.12,F40.12, F40.12, F40.12, F40.12, F40.12, F40.12,F40.12, F40.12, F40.12, F40.12, F40.12, F40.12, F40.12,F40.12,F40.12, F40.12, F40.12, F40.12, F40.12, F40.12,F40.12)


FRMindicator=1

r_rental=.08
beta2 = .9549
elasticity2=0.762

r_rental=.0723208
beta2=.921026
elasticity2=.874365

r_rental=.071768
beta2=.92117
elasticity2=.87512

r_rental=.07213
beta2=.9263
elasticity2=.8807

r_rental=.0631
beta2=.9164
elasticity2=.881

r_rental=.0704
beta2=.9242
elasticity2=.8776

r_rental=.0774
beta2=.904
elasticity2=.878



beta2=.9161
ret_wealth=4.13
r_rental=.07366
elasticity2=.8793


!elasticity2=0.83

phi_r=0.0
variablerindicator=0

phi_eps_extra=phi_r*phi_h_responseto_r*phi_eps_responseto_h+phi_r*phi_eps_responseto_r  !will be equal to phi_r*phi_h_responseto_r*phi_eps_responseto_h
phi_h_extra=phi_r*phi_h_responseto_r !will be equal to phi_r*phi_h_responseto_r




ALLOCATE(Vnoadjust(agridsize,Dgridsize,zgridsize,epsgridsize,epsgridsize,61),Vrentexpand(agridsize,Dgridsize,zgridsize,epsgridsize,epsgridsize,61),Vadjustexpand(agridsize,Dgridsize,zgridsize,epsgridsize,epsgridsize,61),  Vadjust(agridsize,Dgridsize,zgridsize,epsgridsize,61),Vrent(agridsize,Dgridsize,zgridsize,epsgridsize,61))  !Conjectured value of not adjusting and adjusting, and new values of not adjusting and adjusting
ALLOCATE(achoiceadjust(agridsize,Dgridsize,zgridsize,epsgridsize,60),  achoicenoadjust(agridsize,Dgridsize,zgridsize,epsgridsize,epsgridsize,60),achoicerent(agridsize,Dgridsize,zgridsize,epsgridsize,60),  Dchoiceadjust(agridsize,Dgridsize,zgridsize,epsgridsize,60), Dchoicenoadjust(agridsize,Dgridsize,zgridsize,epsgridsize,epsgridsize,60),Dchoicerent(agridsize,Dgridsize,zgridsize,epsgridsize,60))
ALLOCATE(achoice(agridsize,Dgridsize,zgridsize,epsgridsize,epsgridsize,60), Dchoice(agridsize,Dgridsize,zgridsize,epsgridsize,epsgridsize,60),cchoice(agridsize,Dgridsize,zgridsize,epsgridsize,epsgridsize,60))  !Policy functions when solving problem
ALLOCATE(rentalindicator(agridsize,Dgridsize,zgridsize,epsgridsize,epsgridsize,60))
ALLOCATE(EV(agridsize,Dgridsize,zgridsize,epsgridsize,epsgridsize,61))

CALL OMP_SET_NUM_THREADS(12)

numiter=0

write(*,*) epsmin, epsmax

diffmoments=1
do while (diffmoments>difftol)
    numiter=numiter+1
    write(*,*) "numiter", numiter

    write(*,*) elasticity2, r_rental, beta2, ret_wealth



    !OPEN (UNIT=1, FILE="vfunc.txt", STATUS="OLD", ACTION="WRITE", POSITION="REWIND")
    !1 format (F16.6, F16.6, F16.6, F16.6, F16.6, F16.6,F16.6, F16.6, F16.6, F16.6, F16.6, F16.6)

    ! FILL IN ALL THE GRID POINTS

    do i=1,zgridsize
        znodes(i)=zmin+((zmax-zmin)/(zgridsize-1))*(1.0*i-1.0)
    end do
 
    DO i=1,epsgridsize
        epsnodes(i)=epsmin+ ((epsmax -epsmin)/(epsgridsize-1))*(1.0*i-1.0)
    END DO

    
    DO i=1,agridsize/2
        anodes(i)=amin + ((amax2 -amin)/(agridsize/2-1))*(1.0*i-1.0)
    end do
    DO i=1,agridsize/2
        anodes(i+agridsize/2)=amax2 + ((amax -amax2)/(agridsize/2))*(1.0*i)
    end do
    !DO i=1,agridsize
    !    anodes(i)=amin + ((amax -amin)/(agridsize-1))*(1.0*i-1.0)
   ! end do


    DO i=1,Dgridsize
        Dnodes(i)=Dmin +((Dmax -Dmin)/(Dgridsize-1))*(1.0*i-1.0)     
        !write(*,*) i,Dnodes(i) 
    end do
 
 
 
 
    !construct probability matrix for epsshock:
    w=epsnodes(2)-epsnodes(1)
    !Probeps(1)=cdfnormal((epsnodes(1)+w/2)/sigma_eps)
    !Probeps(epsgridsize)=1-cdfnormal((epsnodes(epsgridsize)-w/2)/sigma_eps)
    !do j=2,epsgridsize-1
    !    Probeps(j)=cdfnormal((epsnodes(j)+w/2)/sigma_eps)-cdfnormal((epsnodes(j)-w/2)/sigma_eps)
    !end do

    write(*,*) rho_eps, w/2, sigma_eps
    do j=1,epsgridsize
        Probeps(j,1)=cdfnormal((epsnodes(1)-rho_eps*epsnodes(j)+w/2)/(sigma_eps))
        Probeps(j,epsgridsize)=1-cdfnormal((epsnodes(epsgridsize)-rho_eps*epsnodes(j)-w/2)/(sigma_eps))
        do k=2,epsgridsize-1
            Probeps(j,k)=cdfnormal((epsnodes(k)-rho_eps*epsnodes(j)+w/2)/(sigma_eps))-cdfnormal((epsnodes(k)-rho_eps*epsnodes(j)-w/2)/(sigma_eps))
          !  write(*,*) "check1", j,Probeps(j,k)
        end do
    end do
    do j=1,epsgridsize
        do k=1,epsgridsize
            Probepscum(j,k)=sum(Probeps(j,1:k)) 
            write(*,*) "check2", j, Probepscum(j,k) 
        end do
    end do
    
    
    
    

    !construct probability matrix for epsshock:
    w=znodes(2)-znodes(1)
    Probinit(1)=cdfnormal((znodes(1)+w/2)/sigma_eta_init)
    Probinit(zgridsize)=1-cdfnormal((znodes(zgridsize)-w/2)/sigma_eta_init)
    do j=2,zgridsize-1
        Probinit(j)=cdfnormal((znodes(j)+w/2)/sigma_eta_init)-cdfnormal((znodes(j)-w/2)/sigma_eta_init)
    end do
    
    do j=1,zgridsize
        Probinitcum(j)=sum(Probinit(1:j))
    end do


    w=epsnodes(2)-epsnodes(1)
    Probiniteps(1)=cdfnormal((epsnodes(1)+w/2)/sigma_eps_init)
    Probiniteps(epsgridsize)=1-cdfnormal((epsnodes(epsgridsize)-w/2)/sigma_eps_init)
    do j=2,epsgridsize-1
        Probiniteps(j)=cdfnormal((epsnodes(j)+w/2)/sigma_eps_init)-cdfnormal((epsnodes(j)-w/2)/sigma_eps_init)
    end do
    
    do j=1,epsgridsize
        Probinitepscum(j)=sum(Probiniteps(1:j))
    end do


    !model debugging step:
   ! do j=1,epsgridsize
   !     do k=1,epsgridsize
   !         if (j==k) then
   !             Probeps(j,k)=1
   !         else
   !             Probeps(j,k)=0
   !         end if
   !     end do
   ! end do
   ! do j=1,epsgridsize
   !     do k=1,epsgridsize
   !         Probepscum(j,k)=sum(Probeps(j,1:k)) 
   !         write(*,*) "check2", j, Probepscum(j,k) 
   !     end do
   ! end do

    
 
    ! create transition matrix for log idiosyncratic labor shock using Tauchen 86
    w=znodes(2)-znodes(1)
    do j=1,zgridsize
        Probz(j,1)=cdfnormal((znodes(1)-rho_z*znodes(j)+w/2)/(sigma_z))
        Probz(j,zgridsize)=1-cdfnormal((znodes(zgridsize)-rho_z*znodes(j)-w/2)/(sigma_z))
        do k=2,zgridsize-1
            Probz(j,k)=cdfnormal((znodes(k)-rho_z*znodes(j)+w/2)/(sigma_z))-cdfnormal((znodes(k)-rho_z*znodes(j)-w/2)/(sigma_z))
        end do
    end do

    minexpectationz=1.0
    maxexpectationz=zgridsize
    do j=1,zgridsize
        foundmin=0.0
        foundmax=0.0
        do k=1,zgridsize
            if (Probz(j,k)>.01) then
                foundmin=1.0
            elseif (foundmin==0.0) then
                minexpectationz(j)=minexpectationz(j)+1
            end if
        end do
        do k=0,zgridsize-1
            if (Probz(j,zgridsize-k)>.01) then
                foundmax=1.0
            elseif (foundmax==0.0) then
                maxexpectationz(j)=maxexpectationz(j)-1
            end if
        end do
    end do



    do j=1,zgridsize
        do k=1,zgridsize
            if (k<minexpectationz(j)) then
                !write(*,*) Probz(j,k)
                Probz(j,k)=0.0
            end if
            if (k>maxexpectationz(j)) then
                !write(*,*) Probz(j,k)
                Probz(j,k)=0.0
            end if
        end do
    end do

    do j=1,zgridsize
        Probz(j,:)=Probz(j,:)/sum(Probz(j,:))
    end do
   

    do j=1,zgridsize
        do k=1,zgridsize
            Probzcum(j,k)=sum(Probz(j,1:k))  
        end do
    end do

   

 !this is data from kaplan and violante 2010.  In particular their earnings process (which is in log dollars) is K.  Our variable is then log(exp(K)/mean(k)).

 ageearnings(1)=-0.520437830949535
 ageearnings(2)=-0.445723729949535
 ageearnings(3)=-0.378341829949534
 ageearnings(4)=-0.317627929949534
 ageearnings(5)=-0.262959589949535
 ageearnings(6)=-0.213756129949534
 ageearnings(7)=-0.169478629949534
 ageearnings(8)=-0.129629929949534
 ageearnings(9)=-0.0937546299495352
 ageearnings(10)=-0.0614390899495344
 ageearnings(11)=-0.0323114299495341
 ageearnings(12)=-0.00604152994953496
 ageearnings(13)=0.0176589700504652
 ageearnings(14)=0.0390366700504658
 ageearnings(15)=0.0582964100504647
 ageearnings(16)=0.0756012700504658
 ageearnings(17)=0.0910725700504656
 ageearnings(18)=0.104789870050465
 ageearnings(19)=0.116790970050464
 ageearnings(20)=0.127071910050466
 ageearnings(21)=0.135586970050465
 ageearnings(22)=0.142248670050465
 ageearnings(23)=0.146927770050466
 ageearnings(24)=0.149453270050464
 ageearnings(25)=0.149612410050466
 ageearnings(26)=0.147150670050465
 ageearnings(27)=0.141771770050466
 ageearnings(28)=0.133137670050466
 ageearnings(29)=0.120868570050465
 ageearnings(30)=0.104542910050465
 ageearnings(31)=0.0836973700504653
 ageearnings(32)=0.0578268700504655
 ageearnings(33)=0.0263845700504652
 ageearnings(34)=-0.0112181299495353
 ageearnings(35)=-0.0556115899495339




    deathprob(1)=.012
    deathprob(2)=.013
    deathprob(3)=.014
    deathprob(4)=.015
    deathprob(5)=.016
    deathprob(6)=.018
    deathprob(7)=.02
    deathprob(8)=.021
    deathprob(9)=.022
    deathprob(10)=.024
    deathprob(11)=.027
    deathprob(12)=.03
    deathprob(13)=.032
    deathprob(14)=.035
    deathprob(15)=.038
    deathprob(16)=.042
    deathprob(17)=.046
    deathprob(18)=.051
    deathprob(19)=.056
    deathprob(20)=.061
    deathprob(21)=.068
    deathprob(22)=.075
    deathprob(23)=.083
    deathprob(24)=.092
    deathprob(25)=.11

    !deathprob=0


    averagelifetimeearnings=0.0

    !retirement regression needs to first run matlab program simulateearningsprocess
    do j=1,zgridsize
        do k=1,epsgridsize
            predictedlifetimeearnings(j,k)=0.3083*(znodes(j))*exp(epsnodes(k))**phi_eps
            predictedlifetimeearnings(j,k)=exp(predictedlifetimeearnings(j,k))/exp(averagelifetimeearnings)
            if (predictedlifetimeearnings(j,k)<=0.3) then
                retirementincome(j,k)=0.9*predictedlifetimeearnings(j,k)*exp(averagelifetimeearnings)
            elseif (predictedlifetimeearnings(j,k)>0.3 .and. predictedlifetimeearnings(j,k)<=2) then
                retirementincome(j,k)=(0.27+0.32*(predictedlifetimeearnings(j,k)-0.3))*exp(averagelifetimeearnings)
            elseif (predictedlifetimeearnings(j,k)>2 .and. predictedlifetimeearnings(j,k)<=4.1) then
                retirementincome(j,k)=(0.81+0.15*(predictedlifetimeearnings(j,k)-2))*exp(averagelifetimeearnings)
            else
                retirementincome(j,k)=1.13*exp(averagelifetimeearnings)
            end if
            !write(*,*) predictedlifetimeearnings(j,k), retirementincome(j,k)
        end do
    end do

    !retirementincome=exp(ageearnings(35))
    !retirementincome=0

    do j=1,zgridsize
        do k=1,epsgridsize
            do t=1,35
                income(j,k,t)=exp(znodes(j)+ageearnings(t))*exp(epsnodes(k))**(phi_eps+phi_eps_extra)
            end do
            do t=36,60
                !income(j,k,t)=exp(znodes(j)*exp(epsnodes(k))**phi_eps+ageearnings(35))
                income(j,k,t)=retirementincome(j,k)
            end do
        end do
    end do
     
    income(:,:,36)=income(:,:,36)+income(:,:,35)*ret_wealth
    write(*,*) "income"
    write(*,*) sum(income(:,1,:)),sum(income(:,2,:)),sum(income(:,3,:)),sum(income(:,4,:)),sum(income(:,5,:))






    call cpu_time(timestart)
    !call solveretirementproblem
    Vnoadjust(:,:,:,:,:,61)=0
    Vadjust(:,:,:,:,61)=0
    Vrent(:,:,:,:,61)=0

    !do i=1,agridsize
    !do j=1,Dgridsize
    !Vadjust(i,j,:,:,56)=max(-10000000.0,(.0001*(anodes(i)+theta*dnodes(j)))**(1-elasticity)/(1-elasticity))
    !Vnoadjust(i,j,:,:,56)=max(-10000000.0,(.0001*(anodes(i)+theta*dnodes(j)))**(1-elasticity)/(1-elasticity))
    !Vrent(i,j,:,:,56)=max(-10000000.0,(.0001*(anodes(i)+theta*dnodes(j)))**(1-elasticity)/(1-elasticity))
    !end do
    !end do

    EV=0
    
    
    OPEN (UNIT=1, FILE="vfunc.txt", ACTION="WRITE", POSITION="REWIND")
    1 format (F40.12, F40.12, F40.12, F40.12, F40.12, F40.12,F40.12, F40.12, F40.12, F40.12, F40.12, F40.12, F40.12,F40.12,F40.12, F40.12, F40.12, F40.12, F40.12, F40.12,F40.12)

   
    
    call cpu_time(timeend)
    write(*,*) (timeend-timestart)/8.0
    call cpu_time(timestart)
    call solveworkingproblem
    call cpu_time(timeend)
    write(*,*) (timeend-timestart)/8.0

    write(*,*) agridsize,Dgridsize,zgridsize,epsgridsize
    t=0
    do i=1,agridsize
    do j=1,Dgridsize
        do k=1,zgridsize
            do l=1,epsgridsize
            t=t+1
                !write(1,1) EV(i,j,k,l,1), achoice(i,j,k,l,1), dchoice(i,j,k,l,1), cchoice(i,j,k,l,1),rentalindicator(i,j,k,l,1)
            end do
        end do
    end do
  end do
  write(*,*) t

  call simulate_solveparams   !First pick parameters to match moments

    close(1)
end do




write(*,*) "solving with variable r"
phi_r=-log((basispointvariation/10000)/rborrow+1)/epsmin

!phi_h_extra=log(1+.00000001*basispointvariation/25)/epsmax
!phi_eps_extra=log(1+.00000001*basispointvariation/25)/epsmax

phi_h_extra=log(1+.004*basispointvariation/25)/epsmax
phi_eps_extra=log(1+.002*basispointvariation/25)/epsmax

write(*,*) "extra phis", phi_eps_extra, phi_h_extra

do j=1,zgridsize
        do k=1,epsgridsize
            do t=1,35
                income(j,k,t)=exp(znodes(j)+ageearnings(t))*exp(epsnodes(k))**(phi_eps+phi_eps_extra)
            end do
            do t=36,60
                !income(j,k,t)=exp(znodes(j)*exp(epsnodes(k))**phi_eps+ageearnings(35))
                income(j,k,t)=retirementincome(j,k)
            end do
        end do
    end do

    income(:,:,36)=income(:,:,36)+income(:,:,35)*ret_wealth

write(*,*) "new phis"
write(*,*) phi_eps_extra, phi_h_extra,phi_r

variablerindicator=1

 call cpu_time(timeend)
 write(*,*) (timeend-timestart)/8.0
 call cpu_time(timestart)
 call solveworkingproblem
 call cpu_time(timeend)
 write(*,*) (timeend-timestart)/8.0

 call simulate_solveparams

 write(*,*) "Percentage increase in welfare constant r over variable r"
 write(*,*) (expostwelfare_constantr-expostwelfare_variabler)/abs(expostwelfare_constantr), expostwelfare_constantr
 write(*,*) "by state:"
 do j=1,epsgridsize
    write(*,*) j, (expostwelfarebystate_constantr(j)-expostwelfarebystate_variabler(j))/abs(expostwelfarebystate_constantr(j)), expostwelfarebystate_constantr(j)
 end do

 write(*,*) "by state CE: "
 do j=1,epsgridsize
    write(*,*) j
    do k=1,350
        write(21,21) expostwelfarebystate_variabler(j), expostwelfarebystate_variablerCE(j,k), expostwelfarebystate_constantr(j), .97+(1.0*k)/5000.0, expostwelfare_variablerCE(1,k),expostwelfare_constantr, expostwelfare_variableryoungCE(1,k), expostwelfare_constantryoung, expostwelfare_variablermiddleCE(1,k), expostwelfare_constantrmiddle, expostwelfare_variableroldCE(1,k), expostwelfare_constantrold, expostwelfarebystate_variableryoung(j), expostwelfarebystate_variableryoungCE(j,k), expostwelfarebystate_constantryoung(j), expostwelfarebystate_variablermiddle(j), expostwelfarebystate_variablermiddleCE(j,k), expostwelfarebystate_constantrmiddle(j), expostwelfarebystate_variablerold(j), expostwelfarebystate_variableroldCE(j,k), expostwelfarebystate_constantrold(j), expostwelfarebystate_variablerlowincome(j), expostwelfarebystate_variablerlowincomeCE(j,k), expostwelfarebystate_constantrlowincome(j), expostwelfarebystate_variablermiddleincome(j), expostwelfarebystate_variablermiddleincomeCE(j,k), expostwelfarebystate_constantrmiddleincome(j), expostwelfarebystate_variablerhighincome(j), expostwelfarebystate_variablerhighincomeCE(j,k), expostwelfarebystate_constantrhighincome(j)
    end do
end do

do j=1,epsgridsize
m2=minloc(1.0*abs(1.0*expostwelfarebystate_variablerCE(j,:)-1.0*expostwelfarebystate_constantr(j)),1)
m2young=minloc(1.0*abs(1.0*expostwelfarebystate_variableryoungCE(j,:)-1.0*expostwelfarebystate_constantryoung(j)),1)
m2middle=minloc(1.0*abs(1.0*expostwelfarebystate_variablermiddleCE(j,:)-1.0*expostwelfarebystate_constantrmiddle(j)),1)
m2old=minloc(1.0*abs(1.0*expostwelfarebystate_variableroldCE(j,:)-1.0*expostwelfarebystate_constantrold(j)),1)

m2lowincome=minloc(1.0*abs(1.0*expostwelfarebystate_variablerlowincomeCE(j,:)-1.0*expostwelfarebystate_constantrlowincome(j)),1)
m2middleincome=minloc(1.0*abs(1.0*expostwelfarebystate_variablermiddleincomeCE(j,:)-1.0*expostwelfarebystate_constantrmiddleincome(j)),1)
m2highincome=minloc(1.0*abs(1.0*expostwelfarebystate_variablerhighincomeCE(j,:)-1.0*expostwelfarebystate_constantrhighincome(j)),1)

write(*,*) "CE state:",j, .97+(1.0*m2)/5000.0
write(*,*) "CE young state:",j, .97+(1.0*m2young)/5000.0
write(*,*) "CE middle state:",j, .97+(1.0*m2middle)/5000.0
write(*,*) "CE old state:",j, .97+(1.0*m2old)/5000.0

write(*,*) "CE low income state:",j, .97+(1.0*m2lowincome)/5000.0
write(*,*) "CE middle income state:",j, .97+(1.0*m2middleincome)/5000.0
write(*,*) "CE high income state:",j, .97+(1.0*m2highincome)/5000.0


write(22,22) 1.0,j*1.0, (.97+(1.0*m2)/5000.0-1.0)*100, (.97+(1.0*m2)/5000.0-1.0)*41885*consumptionbystateholder(j)/consumptionoverallholder
write(22,22) 2.0,j*1.0, (.97+(1.0*m2young)/5000.0-1.0)*100, (.97+(1.0*m2young)/5000.0-1.0)*41885*consumptionbystateholder(j)/consumptionoverallholder
write(22,22) 3.0,j*1.0, (.97+(1.0*m2middle)/5000.0-1.0)*100, (.97+(1.0*m2middle)/5000.0-1.0)*41885*consumptionbystateholder(j)/consumptionoverallholder
write(22,22) 4.0,j*1.0, (.97+(1.0*m2old)/5000.0-1.0)*100, (.97+(1.0*m2old)/5000.0-1.0)*41885*consumptionbystateholder(j)/consumptionoverallholder
write(22,22) 5.0,j*1.0, (.97+(1.0*m2lowincome)/5000.0-1.0)*100, (.97+(1.0*m2lowincome)/5000.0-1.0)*41885*consumptionbystateholder(j)/consumptionoverallholder
write(22,22) 6.0,j*1.0, (.97+(1.0*m2middleincome)/5000.0-1.0)*100, (.97+(1.0*m2middleincome)/5000.0-1.0)*41885*consumptionbystateholder(j)/consumptionoverallholder
write(22,22) 7.0,j*1.0, (.97+(1.0*m2highincome)/5000.0-1.0)*100, (.97+(1.0*m2highincome)/5000.0-1.0)*41885*consumptionbystateholder(j)/consumptionoverallholder



write(22,22)

end do





m2=minloc(1.0*abs(1.0*expostwelfare_variablerCE(1,:)-1.0*expostwelfare_constantr),1)
m2young=minloc(1.0*abs(1.0*expostwelfare_variableryoungCE(1,:)-1.0*expostwelfare_constantryoung),1)
m2middle=minloc(1.0*abs(1.0*expostwelfare_variablermiddleCE(1,:)-1.0*expostwelfare_constantrmiddle),1)
m2old=minloc(1.0*abs(1.0*expostwelfare_variableroldCE(1,:)-1.0*expostwelfare_constantrold),1)
write(*,*) "CE overall", .97+(1.0*m2)/5000.0
write(*,*) "CE overall young", .97+(1.0*m2young)/5000.0
write(*,*) "CE overall middle", .97+(1.0*m2middle)/5000.0
write(*,*) "CE overall old", .97+(1.0*m2old)/5000.0




end program durables






subroutine simulate_solveparams
USE nrtype; USE nrutil
USE nr
USE share
USE OMP_LIB
IMPLICIT NONE

REAL(8), dimension(numhouseholds,6) :: currenthouseholdstate, newhouseholdstate
REAL(8), dimension(numhouseholds,60) :: consumption,durableconsumption, currenttemp,currentperm,incomeholder,rentalind,durableinvestment,actualwealth,financialwealth,housingnet,housinggross,actualwealthdividedbyincome,totalnetworthdividedbyincome,taxrate,welfare, constrainedhousehold
REAL(8), dimension(numhouseholds,60) :: changec,changetemp,changeperm,changey,changeyconditional,changed,changedconditional,changetempconditional,changepermconditional,demeanedindicator
REAL(8), dimension(numhouseholds,60) :: alive
REAL(8), dimension(numhouseholds,60) :: housingstock, rentalstock
REAL(8), dimension(numhouseholds,2) :: nearestnode
REAL(8), dimension(numhouseholds,60,6) :: householdresultsholder
REAL(8) :: shock
integer, dimension(2) :: seedvalue
integer :: j,t,i,k
REAL(8), dimension(numhouseholds) :: insurancetemp, insuranceperm, cov1, cov2, cov3, cov4, insurancedtemp,insurancedperm,numown, insurancedtempconditional,insurancedpermconditional
REAL(8) :: adjust
REAL(8) :: conditionalindicator
EXTERNAL brentmindist
REAL(8) :: brentmindist
EXTERNAL calcpretax
REAL(8) :: calcpretax
EXTERNAL calcpretaxss
REAL(8) :: calcpretaxss
REAL(8) :: ax,bx,cx,tol
REAL(8) :: cov1est, cov2est, cov3est, cov4est,minest, constrained
REAL(8) :: m_eps2, m_eta2, m_cFy, m_yFy, m_epsc, m_etac, m_cIVy, m_yIVy, m_eps, m_eta, m_c, m_y, m_IVy, m_Fy, m_d, m_dFy, m_dIVy, m_epsd, m_etad
REAL(8) :: numrent
REAL(8) :: pretaxcalcholder,pretaxincome
REAL(8) :: tot1,tot2,tot3,adjustt,changedconditionalholder,changeyconditionalholder
REAL(8) :: numowntotal
REAL(8) :: rep
REAL(8) :: actualwealthtotal
REAL(8) :: exanteEVborn,exanteEVoverall,numobswelfare
REAL(8), dimension(epsgridsize,1) :: housingbystate,exanteEVbornstate, numobsstate, overallwelfarebystate,overallobsbystate, consumptionbystate, overallwelfarebystateyoung,overallwelfarebystatemiddle,overallwelfarebystateold,overallobsbystateyoung,overallobsbystatemiddle,overallobsbystateold, consumptionbystateyoung,consumptionbystatemiddle,consumptionbystateold, overallwelfarebystatelowincome, overallwelfarebystatemiddleincomE, overallwelfarebystatehighincome, overallobsbystatelowincome, overallobsbystatemiddleincome, overallobsbystatehighincome, consumptionbystatelowincome, consumptionbystatemiddleincome, consumptionbystatehighincome
REAL(8), dimension(epsgridsize,350) :: overallwelfarebystateCE, overallwelfarebystateyoungCE,overallwelfarebystatemiddleCE,overallwelfarebystateoldCE, overallwelfarebystatelowincomeCE, overallwelfarebystatemiddleincomeCE, overallwelfarebystatehighincomeCE
REAL(8), dimension(epsgridsize) :: mortgagedebtbystate,mortgagedebtbystateyoung,mortgagedebtbystatemiddle,mortgagedebtbystateold, nummortgagedebtbystate, nummortgagedebtbystateyoung,nummortgagedebtbystatemiddle,nummortgagedebtbystateold
REAL(8) :: mortgagedebtoverall
REAL(8), dimension(epsgridsize) :: cutoff
REAL(8), dimension(350,1) :: CE
REAL(8) :: negshocktot,negshocknum
REAL(8) :: nummortgagedebtoverall
REAL(8), dimension(numhouseholds,60) :: stateindicator1,stateindicator2,stateindicator5

REAL(8), dimension(numhouseholds,60) :: usercost, spendratio

REAL(8) :: numreset, numdiffer, numreset1, numdiffer1, numreset5, numdiffer5,num1,num5

REAL(8) :: fracincreaseworking,fracincrease


mortgagedebtoverall=0
mortgagedebtbystate=0
mortgagedebtbystateyoung=0
mortgagedebtbystatemiddle=0
mortgagedebtbystateold=0
nummortgagedebtoverall=0
nummortgagedebtbystate=0
nummortgagedebtbystateyoung=0
nummortgagedebtbystatemiddle=0
nummortgagedebtbystateold=0

do i=1,350
CE(i,1)=.97+(1.0*i)/5000.0
!write(*,*) CE(i,1)
end do

tol=.000000001

OPEN (UNIT=2, FILE="singlehouseholdsim.txt", ACTION="WRITE", POSITION="REWIND")
2 format (F16.6, F16.6, F16.6, F16.6, F16.6, F16.6,F16.6, F16.6, F16.6, F16.6, F16.6, F16.6)

OPEN (UNIT=3, FILE="agecoefficients.txt", ACTION="WRITE", POSITION="REWIND")
3 format (F16.6, F16.6, F16.6, F16.6, F16.6, F16.6,F16.6, F16.6, F16.6, F16.6, F16.6, F16.6)

4 format (F16.6, F16.6, F16.6, F16.6, F16.6, F16.6,F16.6, F16.6, F16.6, F16.6, F16.6, F16.6)

OPEN (UNIT=5, FILE="lifecycleprofiles.txt", ACTION="WRITE", POSITION="REWIND")
5 format (F16.6, F16.6, F16.6, F16.6, F16.6, F16.6,F16.6, F16.6, F16.6, F16.6, F16.6, F16.6)

OPEN (UNIT=6, FILE="lifecycleprofiles1.txt", ACTION="WRITE", POSITION="REWIND")
6 format (F16.6, F16.6, F16.6, F16.6, F16.6, F16.6,F16.6, F16.6, F16.6, F16.6, F16.6, F16.6)

OPEN (UNIT=7, FILE="lifecycleprofiles2.txt", ACTION="WRITE", POSITION="REWIND")
7 format (F16.6, F16.6, F16.6, F16.6, F16.6, F16.6,F16.6, F16.6, F16.6, F16.6, F16.6, F16.6)

OPEN (UNIT=8, FILE="lifecycleprofiles5.txt", ACTION="WRITE", POSITION="REWIND")
8 format (F16.6, F16.6, F16.6, F16.6, F16.6, F16.6,F16.6, F16.6, F16.6, F16.6, F16.6, F16.6)

OPEN (UNIT=9, FILE="householdresults.txt", ACTION="WRITE", POSITION="REWIND")
9 format (F16.6, F16.6, F16.6, F16.6, F16.6, F16.6,F16.6, F16.6, F16.6, F16.6, F16.6, F16.6)



negshocktot=0
negshocknum=0

seedvalue(1)=1
seedvalue(2)=1
CALL random_seed(put=seedvalue(1:2))


fracincrease=0
fracincreaseworking=0

housingbystate=0


currenthouseholdstate(:,4)=3


call random_number(shock)

alive=1

write(*,*) "cumprobs:"
write(*,*) Probepscum(currenthouseholdstate(1,4),1)
write(*,*) Probepscum(currenthouseholdstate(1,4),2)
write(*,*) Probepscum(currenthouseholdstate(1,4),3)
write(*,*) Probepscum(currenthouseholdstate(1,4),4)
write(*,*) Probepscum(currenthouseholdstate(1,4),5)

write(*,*) Probepscum(currenthouseholdstate(1,4),5)-Probepscum(currenthouseholdstate(1,4),4)
write(*,*) Probepscum(currenthouseholdstate(1,4),4)-Probepscum(currenthouseholdstate(1,4),3)
write(*,*) Probepscum(currenthouseholdstate(1,4),3)-Probepscum(currenthouseholdstate(1,4),2)
write(*,*) Probepscum(currenthouseholdstate(1,4),2)-Probepscum(currenthouseholdstate(1,4),1)

do i=1,numhouseholds
    if (i/numhouseholds<Probinitepscum(1)) then
        currenthouseholdstate(i,4)=1
    else
        do j=1,epsgridsize-1
            if (i/numhouseholds > Probinitepscum(j) .AND. i/numhouseholds<=Probinitepscum(j+1)) then
                currenthouseholdstate(i,4)=j+1
            end if
        end do
    end if
end do
do j=1,epsgridsize
cutoff(j)=floor(Probinitepscum(j)*numhouseholds)
end do

currenthouseholdstate(:,5)=currenthouseholdstate(:,4)


    do i=1,cutoff(1)
        if (i/cutoff(1) < Probinitcum(1)) then
            currenthouseholdstate(i,3)=1
        else
            do j=1,zgridsize-1
                if (i/cutoff(1) > Probinitcum(j) .AND. i/cutoff(1)<=Probinitcum(j+1)) then
                    currenthouseholdstate(i,3)=j+1
                end if
            end do
        end if
    end do

    do k=1,epsgridsize-1
    do i=cutoff(k)+1,cutoff(k+1)
        if ((i-cutoff(k))/(cutoff(k+1)-cutoff(k)) < Probinitcum(1)) then
            currenthouseholdstate(i,3)=1
        else
            do j=1,zgridsize-1
                if ((i-cutoff(k))/(cutoff(k+1)-cutoff(k)) > Probinitcum(j) .AND. (i-cutoff(k))/(cutoff(k+1)-cutoff(k))<=Probinitcum(j+1)) then
                    currenthouseholdstate(i,3)=j+1
                end if
            end do
        end if
    end do
    end do
   


currenthouseholdstate(:,1)=0
currenthouseholdstate(:,2)=0

do i=1,numhouseholds
    call random_number(shock)
     if (Probinitcum(currenthouseholdstate(i,3))<.25) then    
            if (shock<.1156) then
            currenthouseholdstate(i,2)=2.3214
            currenthouseholdstate(i,1)=.3145
            else
            currenthouseholdstate(i,2)=0
            currenthouseholdstate(i,1)=0.0
            end if
            
            


    elseif (Probinitcum(currenthouseholdstate(i,3))>=.25 .and. Probinitcum(currenthouseholdstate(i,3))<0.5) then  
        if (shock<.2433) then
            currenthouseholdstate(i,2)=1.7857
            currenthouseholdstate(i,1)=.2556
            
        else
            currenthouseholdstate(i,2)=0
            currenthouseholdstate(i,1)=0.0075
            
        end if
    elseif (Probinitcum(currenthouseholdstate(i,3))>=.5 .and. Probinitcum(currenthouseholdstate(i,3))<0.75) then  
        if (shock<.2658) then
            currenthouseholdstate(i,2)=2.8571
            currenthouseholdstate(i,1)=.1611
            
        else
            currenthouseholdstate(i,2)=0
            currenthouseholdstate(i,1)=0.0289
            
        end if
    else
        if (shock<.5406) then
            currenthouseholdstate(i,2)=4.0357
            currenthouseholdstate(i,1)=0.4902
            
        else
            currenthouseholdstate(i,2)=0
            currenthouseholdstate(i,1)=0.1689
            
        end if
    end if
end do






!currenthouseholdstate(:,4)=newhouseholdstate(:,4)

adjust=0
constrained=0
numown=0
changedconditional=0
changeyconditional=0
demeanedindicator=0

numowntotal=0
numrent=0
actualwealthtotal=0

housingstock=0
rentalstock=0

!do i=1,numhouseholds
!nearestnode(i,1)=minloc(currenthouseholdstate(i,1)-anodes,1)
!nearestnode(i,2)=minloc(currenthouseholdstate(i,2)-dnodes,1)
!end do

!currenthouseholdstate(:,3)=7

exanteEVborn=0
exanteEVoverall=0
numobswelfare=0
numobsstate=0
exanteEVbornstate=0

overallwelfarebystate=0
overallobsbystate=0
overallwelfarebystateCE=0
consumptionbystate=0
consumptionbystateyoung=0
consumptionbystatemiddle=0
consumptionbystateold=0

overallwelfarebystateyoung=0
overallwelfarebystatemiddle=0
overallwelfarebystateold=0
overallobsbystateyoung=0
overallobsbystatemiddle=0
overallobsbystateold=0

consumptionbystatelowincome=0
consumptionbystatemiddleincome=0
consumptionbystatehighincome=0

overallwelfarebystatelowincome=0
overallwelfarebystatemiddleincome=0
overallwelfarebystatehighincome=0
overallobsbystatelowincome=0
overallobsbystatemiddleincome=0
overallobsbystatehighincome=0

constrainedhousehold=0


do i=1,numhouseholds
exanteEVborn=exanteEVborn+EV(1,1,currenthouseholdstate(i,3),currenthouseholdstate(i,4),currenthouseholdstate(i,5),1)
    do j=1,epsgridsize
        if (currenthouseholdstate(i,4)==j) then
            exanteEVbornstate(j,1)=exanteEVbornstate(j,1)+EV(1,1,currenthouseholdstate(i,3),currenthouseholdstate(i,4),currenthouseholdstate(i,5),1)
            numobsstate(j,1)=numobsstate(j,1)+1
        end if
    end do
end do
exanteEVborn=exanteEVborn/numhouseholds
write(*,*) "Ex ante welfare", exanteEVborn
write(*,*) "Ex ante welfare by state"
do j=1,5
write(*,*) exanteEVbornstate(j,1)/numobsstate(j,1), exanteEVbornstate(j,1), numobsstate(j,1)
end do



write(*,*) "start"
do t=1,60

numreset=0
numdiffer=0
numreset1=0 
numdiffer1=0 
numreset5=0
numdiffer5=0
num1=0
num5=0

    stateindicator1=0
    stateindicator2=0
    stateindicator5=0
    

    adjustt=0
    changedconditionalholder=0
    changeyconditionalholder=0

    currenthouseholdstate(:,6)=t
    do i=1,numhouseholds
        


        if (alive(i,t)==1) then
        
        numobswelfare=numobswelfare+1
        end if

        if (t>35) then
            if (alive(i,1)==1) then
                call random_number(shock)
                if (shock<deathprob(t-35)) then
                    alive(i,t:60)=0
                end if
            end if
        end if


        if (currenthouseholdstate(i,3)<1) then
            currenthouseholdstate(i,3)=1
        end if
    
        currentperm(i,t)=znodes(currenthouseholdstate(i,3))
        currenttemp(i,t)=epsnodes(currenthouseholdstate(i,4))
        if (t<=35) then
            incomeholder(i,t)=income(currenthouseholdstate(i,3),currenthouseholdstate(i,4),currenthouseholdstate(i,6))
            ax=0
            cx=20*30000
            bx=incomeholder(i,t)*30000
            pretaxcalcholder=brentmindist(ax,bx,cx,calcpretax,incomeholder(i,t)*30000,tol,pretaxincome)
            !write(*,*) incomeholder(i,t), pretaxincome, (pretaxincome-incomeholder(i,t))/pretaxincome
            taxrate(i,t)=(pretaxincome-incomeholder(i,t)*30000)/pretaxincome
            incomeholder(i,t)=pretaxincome/30000
            actualwealth(i,t)=currenthouseholdstate(i,1)+theta*currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**((phi_h+phi_h_extra))  !total wealth is voluntary equity plus equity in durable
            financialwealth(i,t)=currenthouseholdstate(i,1)-(1-theta)*currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**((phi_h+phi_h_extra))
            !if (financialwealth(i,t)<0) then
            !write(*,*) financialwealth(i,t), currenthouseholdstate(i,1), currenthouseholdstate(i,2), (1-theta)*currenthouseholdstate(i,2)
            !end if
            housingnet(i,t)=theta*currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**((phi_h+phi_h_extra))
            housinggross(i,t)=currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**((phi_h+phi_h_extra))
        else
            incomeholder(i,t)=retirementincome(currenthouseholdstate(i,3),currenthouseholdstate(i,4))
            ax=0
            cx=20*30000
            bx=incomeholder(i,t)*30000
            pretaxcalcholder=brentmindist(ax,bx,cx,calcpretaxss,incomeholder(i,t)*30000,tol,pretaxincome)
            !write(*,*) incomeholder(i,t), pretaxincome, (pretaxincome-incomeholder(i,t))/pretaxincome
            taxrate(i,t)=(pretaxincome-incomeholder(i,t)*30000)/pretaxincome
            incomeholder(i,t)=pretaxincome/30000
            actualwealth(i,t)=currenthouseholdstate(i,1)+theta*currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**((phi_h+phi_h_extra))
            financialwealth(i,t)=currenthouseholdstate(i,1)-(1-theta)*currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**((phi_h+phi_h_extra))
            housingnet(i,t)=theta*currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**((phi_h+phi_h_extra))
            housinggross(i,t)=currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**((phi_h+phi_h_extra))
        end if
   

        call pol_linworking(currenthouseholdstate(i,1),currenthouseholdstate(i,2),currenthouseholdstate(i,3),currenthouseholdstate(i,4),currenthouseholdstate(i,5),currenthouseholdstate(i,6),newhouseholdstate(i,1),newhouseholdstate(i,2),consumption(i,t),rentalind(i,t),welfare(i,t))
        
        usercost(i,t)=rentalind(i,t)*r_rental*newhouseholdstate(i,2)+(1-rentalind(i,t))*(rborrow+delta)/(1+rborrow)*newhouseholdstate(i,2)
        spendratio(i,t)=usercost(i,t)/(usercost(i,t)+consumption(i,t))
        
        householdresultsholder(i,t,1)=currenthouseholdstate(i,3)
        householdresultsholder(i,t,2)=alive(i,t)
        householdresultsholder(i,t,3)=welfare(i,t)
        householdresultsholder(i,t,4)=consumption(i,t)
        householdresultsholder(i,t,5)=newhouseholdstate(i,2)
        householdresultsholder(i,t,6)=((consumption(i,t))**elasticity2*(newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity)

        
        

        if (currenthouseholdstate(i,1)-(1-theta)*currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**(phi_h+phi_h_extra)<0) then
            mortgagedebtoverall=mortgagedebtoverall+currenthouseholdstate(i,1)-(1-theta)*currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**(phi_h+phi_h_extra)
            nummortgagedebtoverall=nummortgagedebtoverall+1

            if (newhouseholdstate(i,1)-(1-theta)*newhouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**(phi_h+phi_h_extra) <0) then
            if (newhouseholdstate(i,1)-(1-theta)*newhouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**(phi_h+phi_h_extra) - (currenthouseholdstate(i,1)-(1-theta)*currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**(phi_h+phi_h_extra)) < -.05 .and. abs(newhouseholdstate(i,2)-currenthouseholdstate(i,2))<.075 .and. currenthouseholdstate(i,2)>0 .and. currenthouseholdstate(i,4) < currenthouseholdstate(i,5)) then
            fracincrease=fracincrease+1
            if (t<=35) then
            fracincreaseworking=fracincreaseworking+1
            end if
            end if
            end if
        end if

        do j=1,epsgridsize
            if (currenthouseholdstate(i,4)==j .and. alive(i,t)==1) then
                if (t<=35) then
                    overallwelfarebystate(j,1)=overallwelfarebystate(j,1)+welfare(i,t)
                    consumptionbystate(j,1)=consumptionbystate(j,1)+consumption(i,t)**(elasticity2)*(newhouseholdstate(i,2))**(1-elasticity2)
                    housingbystate(j,1)=housingbystate(j,1)+newhouseholdstate(i,2)*(1-rentalind(i,t))
                    overallobsbystate(j,1)=overallobsbystate(j,1)+1

                    if (currenthouseholdstate(i,1)-(1-theta)*currenthouseholdstate(i,2)*exp(epsnodes(j))**(phi_h+phi_h_extra)<0) then
                        mortgagedebtbystate(j)=mortgagedebtbystate(j)+currenthouseholdstate(i,1)-(1-theta)*currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**(phi_h+phi_h_extra)
                        nummortgagedebtbystate(j)=nummortgagedebtbystate(j)+1
                    end if

                    if (variablerindicator==1) then
                        do k=1,350
                            overallwelfarebystateCE(j,k)=overallwelfarebystateCE(j,k)+(welfare(i,t)-((consumption(i,t))**elasticity2*(newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity)+((CE(k,1)*consumption(i,t))**elasticity2*(CE(k,1)*newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity))
                        end do
                    end if
                end if
                if (t<=35) then
                if (currenthouseholdstate(i,3)<=4) then
                    overallwelfarebystatelowincome(j,1)=overallwelfarebystatelowincome(j,1)+welfare(i,t)
                    consumptionbystatelowincome(j,1)=consumptionbystatelowincome(j,1)+consumption(i,t)**(elasticity2)*(newhouseholdstate(i,2))**(1-elasticity2)
                    overallobsbystatelowincome(j,1)=overallobsbystatelowincome(j,1)+1
                    if (variablerindicator==1) then
                    do k=1,350
                        overallwelfarebystatelowincomeCE(j,k)=overallwelfarebystatelowincomeCE(j,k)+(welfare(i,t)-((consumption(i,t))**elasticity2*(newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity)+((CE(k,1)*consumption(i,t))**elasticity2*(CE(k,1)*newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity))
                    end do
                    end if
                elseif (currenthouseholdstate(i,3)>=5 .and. currenthouseholdstate(i,3)<=9) then
                    overallwelfarebystatemiddleincome(j,1)=overallwelfarebystatemiddleincome(j,1)+welfare(i,t)
                    consumptionbystatemiddleincome(j,1)=consumptionbystatemiddleincome(j,1)+consumption(i,t)**(elasticity2)*(newhouseholdstate(i,2))**(1-elasticity2)
                    overallobsbystatemiddleincome(j,1)=overallobsbystatemiddleincome(j,1)+1
                    if (variablerindicator==1) then
                    do k=1,350
                        overallwelfarebystatemiddleincomeCE(j,k)=overallwelfarebystatemiddleincomeCE(j,k)+(welfare(i,t)-((consumption(i,t))**elasticity2*(newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity)+((CE(k,1)*consumption(i,t))**elasticity2*(CE(k,1)*newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity))
                    end do
                    end if
                else
                    overallwelfarebystatehighincome(j,1)=overallwelfarebystatehighincome(j,1)+welfare(i,t)
                    consumptionbystatehighincome(j,1)=consumptionbystatehighincome(j,1)+consumption(i,t)**(elasticity2)*(newhouseholdstate(i,2))**(1-elasticity2)
                    overallobsbystatehighincome(j,1)=overallobsbystatehighincome(j,1)+1
                    if (variablerindicator==1) then
                    do k=1,350
                        overallwelfarebystatehighincomeCE(j,k)=overallwelfarebystatehighincomeCE(j,k)+(welfare(i,t)-((consumption(i,t))**elasticity2*(newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity)+((CE(k,1)*consumption(i,t))**elasticity2*(CE(k,1)*newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity))
                    end do
                    end if
                end if
                end if
                if (t<=10) then
                    overallwelfarebystateyoung(j,1)=overallwelfarebystateyoung(j,1)+welfare(i,t)
                    consumptionbystateyoung(j,1)=consumptionbystateyoung(j,1)+consumption(i,t)**(elasticity2)*(newhouseholdstate(i,2))**(1-elasticity2)
                    overallobsbystateyoung(j,1)=overallobsbystateyoung(j,1)+1
                   if (currenthouseholdstate(i,1)-(1-theta)*currenthouseholdstate(i,2)*exp(epsnodes(j))**(phi_h+phi_h_extra)<0) then
                        mortgagedebtbystateyoung(j)=mortgagedebtbystateyoung(j)+currenthouseholdstate(i,1)-(1-theta)*currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**(phi_h+phi_h_extra)
                        nummortgagedebtbystateyoung(j)=nummortgagedebtbystateyoung(j)+1
                    end if
                    if (variablerindicator==1) then
                    do k=1,350
                        overallwelfarebystateyoungCE(j,k)=overallwelfarebystateyoungCE(j,k)+(welfare(i,t)-((consumption(i,t))**elasticity2*(newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity)+((CE(k,1)*consumption(i,t))**elasticity2*(CE(k,1)*newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity))
                    end do
                    end if
                elseif (t> 10 .and. t<=35) then
                    overallwelfarebystatemiddle(j,1)=overallwelfarebystatemiddle(j,1)+welfare(i,t)
                    consumptionbystatemiddle(j,1)=consumptionbystatemiddle(j,1)+consumption(i,t)**(elasticity2)*(newhouseholdstate(i,2))**(1-elasticity2)
                    overallobsbystatemiddle(j,1)=overallobsbystatemiddle(j,1)+1
                    if (currenthouseholdstate(i,1)-(1-theta)*currenthouseholdstate(i,2)*exp(epsnodes(j))**(phi_h+phi_h_extra)<0) then
                        mortgagedebtbystatemiddle(j)=mortgagedebtbystatemiddle(j)+currenthouseholdstate(i,1)-(1-theta)*currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**(phi_h+phi_h_extra)
                        nummortgagedebtbystatemiddle(j)=nummortgagedebtbystatemiddle(j)+1
                    end if
                    if (variablerindicator==1) then
                    do k=1,350
                        overallwelfarebystatemiddleCE(j,k)=overallwelfarebystatemiddleCE(j,k)+(welfare(i,t)-((consumption(i,t))**elasticity2*(newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity)+((CE(k,1)*consumption(i,t))**elasticity2*(CE(k,1)*newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity))
                    end do
                    end if
                elseif (t>35 .and. t<60) then
                    overallwelfarebystateold(j,1)=overallwelfarebystateold(j,1)+welfare(i,t)
                    consumptionbystateold(j,1)=consumptionbystateold(j,1)+consumption(i,t)**(elasticity2)*(newhouseholdstate(i,2))**(1-elasticity2)
                    overallobsbystateold(j,1)=overallobsbystateold(j,1)+1
                    if (currenthouseholdstate(i,1)-(1-theta)*currenthouseholdstate(i,2)*exp(epsnodes(j))**(phi_h+phi_h_extra)<0) then
                        mortgagedebtbystateold(j)=mortgagedebtbystateold(j)+currenthouseholdstate(i,1)-(1-theta)*currenthouseholdstate(i,2)*exp(epsnodes(currenthouseholdstate(i,4)))**(phi_h+phi_h_extra)
                        nummortgagedebtbystateold(j)=nummortgagedebtbystateold(j)+1
                    end if
                    if (variablerindicator==1) then
                    do k=1,350
                        overallwelfarebystateoldCE(j,k)=overallwelfarebystateoldCE(j,k)+(welfare(i,t)-((consumption(i,t))**elasticity2*(newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity)+((CE(k,1)*consumption(i,t))**elasticity2*(CE(k,1)*newhouseholdstate(i,2))**(1-elasticity2))**(1-elasticity)/(1-elasticity))
                    end do
                    end if
                end if
            end if
        end do
                
        
        
        
        
        if (i==1) then
            !write(2,2) currenthouseholdstate(1,1), currenthouseholdstate(1,2),newhouseholdstate(1,2),consumption(1,t),rentalind(1,t), currenthouseholdstate(1,3), currenthouseholdstate(1,4), income(currenthouseholdstate(1,3),currenthouseholdstate(1,4),currenthouseholdstate(1,5))
            write(2,2) currenthouseholdstate(1,1), currenthouseholdstate(1,2),newhouseholdstate(1,2),consumption(1,t),rentalind(1,t), currenthouseholdstate(1,3), currenthouseholdstate(1,4), currenthouseholdstate(1,1)-(1-theta)*currenthouseholdstate(1,2)
        end if
        
        if (newhouseholdstate(i,1)<0.0001 .and. t==1) then
            constrained=constrained+1
        end if
        if (newhouseholdstate(i,1)<0.05) then
            constrainedhousehold(i,t)=1
        end if
        
        durableconsumption(i,t)=newhouseholdstate(i,2)+.0000001
        
        
        if (currenthouseholdstate(i,4)==1) then
        stateindicator1(i,t)=1
        elseif (currenthouseholdstate(i,4)==2) then
        stateindicator2(i,t)=1
        elseif (currenthouseholdstate(i,4)==5) then
        stateindicator5(i,t)=1
        end if
        
       
        
        
        call random_number(shock)
        if (shock < Probepscum(currenthouseholdstate(i,4),1)) then
            newhouseholdstate(i,4)=1
        else
            do j=1,epsgridsize-1
                if (shock > Probepscum(currenthouseholdstate(i,4),j) .AND. shock<=Probepscum(currenthouseholdstate(i,4),j+1)) then
                    newhouseholdstate(i,4)=j+1
                end if
            end do
        end if


        if (currenthouseholdstate(i,4) .ne. currenthouseholdstate(i,5)) then
            numdiffer=numdiffer+1
        end if
        if (currenthouseholdstate(i,4)==1) then
                num1=num1+1
                if (currenthouseholdstate(i,4) .ne. currenthouseholdstate(i,5)) then
                    numdiffer1=numdiffer1+1
                end if
                if (abs(newhouseholdstate(i,2)-currenthouseholdstate(i,2))>.075 .and. currenthouseholdstate(i,2)>0) then
                    numreset1=numreset1+1
                end if
        end if
        if (currenthouseholdstate(i,4)==5) then
                num5=num5+1
                if (currenthouseholdstate(i,4) .ne. currenthouseholdstate(i,5)) then
                    numdiffer5=numdiffer5+1
                end if
                if (abs(newhouseholdstate(i,2)-currenthouseholdstate(i,2))>.075 .and. currenthouseholdstate(i,2)>0) then
                    numreset5=numreset5+1
                end if
        end if


         if (abs(newhouseholdstate(i,2)-currenthouseholdstate(i,2))>.075) then
            newhouseholdstate(i,5)=newhouseholdstate(i,4)
            if (currenthouseholdstate(i,2)>0) then
            numreset=numreset+1
            end if
        else
            newhouseholdstate(i,5)=currenthouseholdstate(i,5)
        end if
        if (rentalind(i,t)>.8) then
            rentalstock(i,t)=newhouseholdstate(i,2)
            newhouseholdstate(i,2)=0
            newhouseholdstate(i,5)=newhouseholdstate(i,4)
            if (alive(i,t)==1) then
                numrent=numrent+1
            end if
        else
            housingstock(i,t)=newhouseholdstate(i,2)
            if (alive(i,t)==1) then
                numowntotal=numowntotal+1
            end if
        end if
            
        durableinvestment(i,t)=newhouseholdstate(i,2)-(1-delta)*currenthouseholdstate(i,2)
        
        if (t<36) then
            call random_number(shock)
        
            if (shock < Probzcum(currenthouseholdstate(i,3),1)) then
                    newhouseholdstate(i,3)=1
            else
                do j=1,zgridsize-1
                    if (shock > Probzcum(currenthouseholdstate(i,3),j) .AND. shock<=Probzcum(currenthouseholdstate(i,3),j+1)) then
                        newhouseholdstate(i,3)=j+1
                    end if
                end do
            end if
        else
            newhouseholdstate(i,3)=currenthouseholdstate(i,3)
        end if
        
        newhouseholdstate(i,1)=newhouseholdstate(i,1)+newhouseholdstate(i,2)*(1-theta)*(exp(epsnodes(newhouseholdstate(i,4)))**(phi_h+phi_h_extra)-exp(epsnodes(currenthouseholdstate(i,4)))**(phi_h+phi_h_extra))

        if (newhouseholdstate(i,2)*(1-theta)*(exp(epsnodes(newhouseholdstate(i,4)))**(phi_h+phi_h_extra)-exp(epsnodes(currenthouseholdstate(i,4)))**(phi_h+phi_h_extra))<0) then
        negshocktot=negshocktot+newhouseholdstate(i,2)*(1-theta)*(exp(epsnodes(newhouseholdstate(i,4)))**(phi_h+phi_h_extra)-exp(epsnodes(currenthouseholdstate(i,4)))**(phi_h+phi_h_extra))
        negshocknum=negshocknum+1
        end if
        

    end do
    
    !write(*,*) "minfinwealth", minval(1.0*financialwealth(:,1)),minval(1.0*financialwealth(:,2))

    write(5,5) sum(financialwealth(:,t)*alive(:,t))/numhouseholds,sum(currenthouseholdstate(:,2)*alive(:,t))/numhouseholds, sum(consumption(:,t)*alive(:,t))/numhouseholds, sum(actualwealth(:,t)*alive(:,t))/numhouseholds, sum(newhouseholdstate(:,2)*alive(:,t))/numhouseholds, sum(newhouseholdstate(:,2)*rentalind(:,t)*alive(:,t))/numhouseholds, sum(rentalind(:,t)*alive(:,t))/numhouseholds, sum(alive(:,t))/numhouseholds, sum(consumption(:,t))/numhouseholds, sum(currenthouseholdstate(:,5))/numhouseholds, sum(usercost(:,t)*alive(:,t))/numhouseholds, sum(spendratio(:,t)*alive(:,t))/numhouseholds
    
    write(6,6) sum(financialwealth(:,t)*stateindicator1(:,t))/sum(stateindicator1(:,t)),sum(currenthouseholdstate(:,2)*stateindicator1(:,t))/sum(stateindicator1(:,t)), sum(consumption(:,t)*stateindicator1(:,t))/sum(stateindicator1(:,t)),sum(newhouseholdstate(:,2)*rentalind(:,t)*stateindicator1(:,t))/sum(stateindicator1(:,t)), sum(rentalind(:,t)*stateindicator1(:,t))/sum(stateindicator1(:,t)), sum(currenthouseholdstate(:,1)*stateindicator1(:,t))/sum(stateindicator1(:,t)), sum(newhouseholdstate(:,1)*stateindicator1(:,t))/sum(stateindicator1(:,t)),  sum(currenthouseholdstate(:,5)*stateindicator1(:,t))/sum(stateindicator1(:,t))
    write(7,7) sum(financialwealth(:,t)*stateindicator2(:,t))/sum(stateindicator2(:,t)),sum(currenthouseholdstate(:,2)*stateindicator2(:,t))/sum(stateindicator2(:,t)), sum(consumption(:,t)*stateindicator2(:,t))/sum(stateindicator2(:,t)),sum(newhouseholdstate(:,2)*rentalind(:,t)*stateindicator2(:,t))/sum(stateindicator2(:,t)), sum(rentalind(:,t)*stateindicator2(:,t))/sum(stateindicator2(:,t)), sum(currenthouseholdstate(:,1)*stateindicator2(:,t))/sum(stateindicator2(:,1)), sum((currenthouseholdstate(:,1)-(1-theta)*currenthouseholdstate(:,2))*stateindicator2(:,1))/sum(stateindicator2(:,1)),  sum(currenthouseholdstate(:,5)*stateindicator2(:,t))/sum(stateindicator2(:,t))
    write(8,8) sum(financialwealth(:,t)*stateindicator5(:,t))/sum(stateindicator5(:,t)),sum(currenthouseholdstate(:,2)*stateindicator5(:,t))/sum(stateindicator5(:,t)), sum(consumption(:,t)*stateindicator5(:,t))/sum(stateindicator5(:,t)),sum(newhouseholdstate(:,2)*rentalind(:,t)*stateindicator5(:,t))/sum(stateindicator5(:,t)), sum(rentalind(:,t)*stateindicator5(:,t))/sum(stateindicator5(:,t)), sum(currenthouseholdstate(:,1)*stateindicator5(:,t))/sum(stateindicator5(:,1)), sum((currenthouseholdstate(:,1)-(1-theta)*currenthouseholdstate(:,2))*stateindicator5(:,1))/sum(stateindicator5(:,1)),  sum(currenthouseholdstate(:,5)*stateindicator5(:,t))/sum(stateindicator5(:,t))
    
    currenthouseholdstate=newhouseholdstate

   ! write(*,*) "numreset", numreset/numhouseholds
   !write(*,*) "numdiffer", numdiffer/numhouseholds
   ! write(*,*) "numreset 1 vs 5", numreset1/num1, numreset5/num5
   ! write(*,*) "numdiffer 1 vs 5", numdiffer1/num1, numdiffer5/num5

    
end do

write(*,*) "frac increase balance with fixed rate", fracincreaseworking/(35*numhouseholds)



write(*,*) "end"
write(*,*) "welfare overall:", sum(welfare*alive)/sum(alive)

write(*,*) "housing stock", sum(housingstock*alive)/sum(alive)
write(*,*) "rental stock", sum(rentalstock*alive)/sum(alive)
write(*,*) "total residential investment", sum(housingstock*delta*alive+rentalstock*(r_rental-r)*alive)/sum(alive)
write(*,*) "total non dur consumption", sum(consumption*alive)/sum(alive)

write(*,*) "H/(H+W)", sum(housingnet*alive)/(sum(actualwealth*alive)), sum(housinggross*alive)/(sum(actualwealth*alive)),sum(housinggross*alive)/(sum(actualwealth*alive-housingnet*alive+housinggross*alive))


write(*,*) "wealth over income", sum(actualwealth*alive)/sum(incomeholder*alive)  !Target = 1.52 (median net worth / earnings in 2001 SCF (see Kaplan and Violante table 2)

write(*,*) "liquid wealth net of debt over income", sum(financialwealth*alive)/sum(incomeholder*alive) !Target = -0.21 (no retirement accounts), -.05 (include retirement accounts for old) 0.46 (include retirement accounts for all ages) 
write(*,*) "liquid wealth net of debt over income: working age", sum(financialwealth(:,1:35)*alive(:,1:35))/sum(incomeholder(:,1:35)*alive(:,1:35))
write(*,*) "liquid wealth net of debt over income: retired", sum(financialwealth(:,36:60)*alive(:,36:60))/sum(incomeholder(:,36:60)*alive(:,36:60))


write(*,*) "C / I_d", sum(consumption*alive)/sum(housingstock*delta*alive+rentalstock*(r_rental-r)*alive)   !Target = 15 from BEA Nondura+Services / Residential investment 1999-2012 chained dollars table 1.1.6
write(*,*) "fracown", numowntotal/(numowntotal+numrent)  !Target 69% from SCF 98 (luengo-prado and diaz)

write(*,*) beta2, r_rental, elasticity2, ret_wealth





diffmoments1=log(.69/(numowntotal/(numowntotal+numrent)))**2
!diffmoments2=log(1.52/(sum(actualwealth*alive)/sum(incomeholder*alive)))**2
!diffmoments2=log(-.21/(sum(financialwealth*alive)/sum(incomeholder*alive)))**2
diffmoments2=((-.05-sum(financialwealth*alive)/sum(incomeholder*alive))/(sum(financialwealth*alive)/sum(incomeholder*alive)))**2
diffmoments3=log((sum(consumption*alive)/sum(housingstock*delta*alive+rentalstock*(r_rental-r)*alive))/15)**2
diffmoments4=((1.26-sum(financialwealth(:,36:60)*alive(:,36:60))/sum(incomeholder(:,36:60)*alive(:,36:60)))/(sum(financialwealth(:,36:60)*alive(:,36:60))/sum(incomeholder(:,36:60)*alive(:,36:60))))**2
!diffmoments3=0

diffmoments=max(max(max(diffmoments2,diffmoments3),diffmoments1),diffmoments4)
write(*,*) "diff", diffmoments,diffmoments1,diffmoments2,diffmoments3,diffmoments4

if (diffmoments>difftol) then
!beta2=beta2+.007*(1.52-sum(actualwealth*alive)/sum(incomeholder*alive))
beta2=beta2+.007*(-0.05-sum(financialwealth*alive)/sum(incomeholder*alive))
elasticity2=elasticity2-.012*(sum(consumption*alive)/sum(housingstock*delta*alive+rentalstock*(r_rental-r)*alive)-15)
r_rental=r_rental+.018*(.69-numowntotal/(numowntotal+numrent))
ret_wealth=ret_wealth+.1*(1.26-sum(financialwealth(:,36:60)*alive(:,36:60))/sum(incomeholder(:,36:60)*alive(:,36:60)))
elseif (diffmoments<=difftol .or. variablerindicator==1) then

if (variablerindicator==0) then
OPEN (UNIT=99, FILE="mortgagedebt.txt", STATUS="OLD", ACTION="WRITE", POSITION="REWIND")
99 format (F16.6, F16.6, F16.6, F16.6, F16.6, F16.6,F16.6, F16.6, F16.6, F16.6, F16.6, F16.6)
end if

write(99,99) mortgagedebtoverall/(numhouseholds*60), mortgagedebtoverall, numhouseholds*60
write(99,99) variablerindicator
do j=1,epsgridsize
write(99,99) mortgagedebtbystate(j)/overallobsbystate(j,1),mortgagedebtbystate(j),overallobsbystate(j,1), nummortgagedebtbystate(j)
end do
write(99,99) variablerindicator
do j=1,epsgridsize
write(99,99) mortgagedebtbystateyoung(j)/overallobsbystateyoung(j,1),mortgagedebtbystateyoung(j),overallobsbystateyoung(j,1),nummortgagedebtbystateyoung(j)
end do
write(99,99) variablerindicator
do j=1,epsgridsize
write(99,99) mortgagedebtbystatemiddle(j)/overallobsbystatemiddle(j,1),mortgagedebtbystatemiddle(j),overallobsbystatemiddle(j,1),nummortgagedebtbystatemiddle(j)
end do
write(99,99) variablerindicator
do j=1,epsgridsize
write(99,99) mortgagedebtbystateold(j)/overallobsbystateold(j,1),mortgagedebtbystateold(j),overallobsbystateold(j,1),nummortgagedebtbystateold(j)
end do

end if

write(*,*) "ex post welfare by state:"
do j=1,epsgridsize
write(*,*) overallwelfarebystate(j,1)/overallobsbystate(j,1), overallobsbystate(j,1)
end do

write(*,*) "ex post welfare weighted by states:"
write(*,*) sum(overallwelfarebystate)/sum(overallobsbystate)

write(*,*) "consumption by states:"
do j=1,epsgridsize
write(*,*) consumptionbystate(j,1)/overallobsbystate(j,1),housingbystate(j,1)/overallobsbystate(j,1)
consumptionbystateholder(j)=consumptionbystate(j,1)/overallobsbystate(j,1)
consumptionoverallholder=sum(consumptionbystate)/sum(overallobsbystate)
end do

    

if (variablerindicator==0) then
    expostwelfare_constantr=sum(overallwelfarebystate)/sum(overallobsbystate)
    expostwelfare_constantryoung=sum(overallwelfarebystateyoung)/sum(overallobsbystateyoung)
    expostwelfare_constantrmiddle=sum(overallwelfarebystatemiddle)/sum(overallobsbystatemiddle)
    expostwelfare_constantrold=sum(overallwelfarebystateold)/sum(overallobsbystateold)

    expostwelfare_constantrlowincome=sum(overallwelfarebystatelowincome)/sum(overallobsbystatelowincome)
    expostwelfare_constantrmiddleincome=sum(overallwelfarebystatemiddleincome)/sum(overallobsbystatemiddleincome)
    expostwelfare_constantrhighincome=sum(overallwelfarebystatehighincome)/sum(overallobsbystatehighincome)

    do j=1,epsgridsize
        expostwelfarebystate_constantr(j)=overallwelfarebystate(j,1)/overallobsbystate(j,1)
        expostwelfarebystate_constantryoung(j)=overallwelfarebystateyoung(j,1)/overallobsbystateyoung(j,1)
        expostwelfarebystate_constantrmiddle(j)=overallwelfarebystatemiddle(j,1)/overallobsbystatemiddle(j,1)
        expostwelfarebystate_constantrold(j)=overallwelfarebystateold(j,1)/overallobsbystateold(j,1)

        expostwelfarebystate_constantrlowincome(j)=overallwelfarebystatelowincome(j,1)/overallobsbystatelowincome(j,1)
        expostwelfarebystate_constantrmiddleincome(j)=overallwelfarebystatemiddleincome(j,1)/overallobsbystatemiddleincome(j,1)
        expostwelfarebystate_constantrhighincome(j)=overallwelfarebystatehighincome(j,1)/overallobsbystatehighincome(j,1)
    end do
else
    expostwelfare_variabler=sum(overallwelfarebystate)/sum(overallobsbystate)
    expostwelfare_variableryoung=sum(overallwelfarebystateyoung)/sum(overallobsbystateyoung)
    expostwelfare_variablermiddle=sum(overallwelfarebystatemiddle)/sum(overallobsbystatemiddle)
    expostwelfare_variablerold=sum(overallwelfarebystateold)/sum(overallobsbystateold)

    expostwelfare_variablerlowincome=sum(overallwelfarebystatelowincome)/sum(overallobsbystatelowincome)
    expostwelfare_variablermiddleincome=sum(overallwelfarebystatemiddleincome)/sum(overallobsbystatemiddleincome)
    expostwelfare_variablerhighincome=sum(overallwelfarebystatehighincome)/sum(overallobsbystatehighincome)

    do k=1,350
    expostwelfare_variablerCE(1,k)=sum(overallwelfarebystateCE(:,k))/sum(overallobsbystate)
    expostwelfare_variableryoungCE(1,k)=sum(overallwelfarebystateyoungCE(:,k))/sum(overallobsbystateyoung)
    expostwelfare_variablermiddleCE(1,k)=sum(overallwelfarebystatemiddleCE(:,k))/sum(overallobsbystatemiddle)
    expostwelfare_variableroldCE(1,k)=sum(overallwelfarebystateoldCE(:,k))/sum(overallobsbystateold)

    expostwelfare_variablerlowincomeCE(1,k)=sum(overallwelfarebystatelowincomeCE(:,k))/sum(overallobsbystatelowincome)
    expostwelfare_variablermiddleincomeCE(1,k)=sum(overallwelfarebystatemiddleincomeCE(:,k))/sum(overallobsbystatemiddleincome)
    expostwelfare_variablerhighincomeCE(1,k)=sum(overallwelfarebystatehighincomeCE(:,k))/sum(overallobsbystatehighincome)
    end do
    do j=1,epsgridsize
        expostwelfarebystate_variabler(j)=overallwelfarebystate(j,1)/overallobsbystate(j,1)
        expostwelfarebystate_variableryoung(j)=overallwelfarebystateyoung(j,1)/overallobsbystateyoung(j,1)
        expostwelfarebystate_variablermiddle(j)=overallwelfarebystatemiddle(j,1)/overallobsbystatemiddle(j,1)
        expostwelfarebystate_variablerold(j)=overallwelfarebystateold(j,1)/overallobsbystateold(j,1)

        expostwelfarebystate_variablerlowincome(j)=overallwelfarebystatelowincome(j,1)/overallobsbystatelowincome(j,1)
        expostwelfarebystate_variablermiddleincome(j)=overallwelfarebystatemiddleincome(j,1)/overallobsbystatemiddleincome(j,1)
        expostwelfarebystate_variablerhighincome(j)=overallwelfarebystatehighincome(j,1)/overallobsbystatehighincome(j,1)
        do k=1,350
            expostwelfarebystate_variablerCE(j,k)=overallwelfarebystateCE(j,k)/overallobsbystate(j,1)
            expostwelfarebystate_variableryoungCE(j,k)=overallwelfarebystateyoungCE(j,k)/overallobsbystateyoung(j,1)
            expostwelfarebystate_variablermiddleCE(j,k)=overallwelfarebystatemiddleCE(j,k)/overallobsbystatemiddle(j,1)
            expostwelfarebystate_variableroldCE(j,k)=overallwelfarebystateoldCE(j,k)/overallobsbystateold(j,1)

            expostwelfarebystate_variablerlowincomeCE(j,k)=overallwelfarebystatelowincomeCE(j,k)/overallobsbystatelowincome(j,1)
            expostwelfarebystate_variablermiddleincomeCE(j,k)=overallwelfarebystatemiddleincomeCE(j,k)/overallobsbystatemiddleincome(j,1)
            expostwelfarebystate_variablerhighincomeCE(j,k)=overallwelfarebystatehighincomeCE(j,k)/overallobsbystatehighincome(j,1)
        end do
    end do
end if



!do t=1,60
!do i=1,numhouseholds
!write(9,9) householdresultsholder(i,t,1),householdresultsholder(i,t,2),householdresultsholder(i,t,3),householdresultsholder(i,t,4),householdresultsholder(i,t,5),householdresultsholder(i,t,6)
!end do
!end do

close(2)
close(3)
close(5)
close(6)
close(7)
close(8)
close(9)

end subroutine simulate_solveparams




REAL(8) FUNCTION calcpretax(x,aftertax)  
USE SHARE
IMPLICIT NONE
REAL(8) :: aftertax
REAL(8) :: x


calcpretax=(x-.258*(x-(x**(-.768)+.031)**(-1/.768))-aftertax)**2

end FUNCTION calcpretax

REAL(8) FUNCTION calcpretaxss(x,aftertax)  !The tax inversion needs to be modified for social security since only 85% of benefits are taxed
USE SHARE
IMPLICIT NONE
REAL(8) :: aftertax
REAL(8) :: x


calcpretaxss=(x-.258*(.85*x-(.85*x**(-.768)+.031)**(-1/.768))-aftertax)**2

end FUNCTION calcpretaxss

  

subroutine pol_linworking(astate,Dstate,zstate,epsstate,epsoldstate,t,achoicelin,Dchoicelin,cchoicelin,rentallin,welfare)
    USE nrtype; USE nrutil
    USE nr
    USE share
    USE OMP_LIB
    IMPLICIT NONE
    REAL(8) :: weightal, weightDl
    REAL(8) :: nearestanode, nearestDnode
    REAL(8) :: al,ah, Dl,Dh
    REAL(8) :: astate,Dstate,zstate,epsstate,epsoldstate,t,achoicelin,Dchoicelin,cchoicelin,rentallin,welfare
    
    if (astate>amax) then
    astate=amax
    elseif (astate<amin) then
    astate=amin
    end if
    
    nearestanode=minloc(abs(astate-anodes),1)
    if (astate==anodes(nearestanode)) then
        if (nearestanode<agridsize) then
            al=nearestanode
            ah=nearestanode+1
            weightal=1.0
        else
            al=nearestanode-1
            ah=nearestanode
            weightal=0.0
        end if
    else
        if (astate-anodes(nearestanode)>0) then
            al=nearestanode
            ah=nearestanode+1
            weightal=1-(astate-anodes(al))/(anodes(ah)-anodes(al))
        else
            al=nearestanode-1
            ah=nearestanode
            weightal=1-(astate-anodes(al))/(anodes(ah)-anodes(al))
        end if
    end if


    nearestDnode=minloc(abs(Dstate-Dnodes),1)
    if (Dstate==Dnodes(nearestDnode)) then
        if (nearestDnode<Dgridsize) then
            Dl=nearestDnode
            Dh=nearestDnode+1
            weightDl=1.0
        else
            Dl=nearestDnode-1
            Dh=nearestDnode
            weightDl=0.0
        end if
    else
        if (Dstate-Dnodes(nearestDnode)>0) then
            Dl=nearestDnode
            Dh=nearestDnode+1
            weightDl=1-(Dstate-Dnodes(Dl))/(Dnodes(Dh)-Dnodes(Dl))
        else
            Dl=nearestDnode-1
            Dh=nearestDnode
            weightDl=1-(Dstate-Dnodes(Dl))/(Dnodes(Dh)-Dnodes(Dl))
        end if
    end if
    
    !write(*,*) weightal, weightDl,al,Dl,estate,Dchoice(al,Dl,estate)
    
    !write(*,*) "r  ", "r  ", al,ah,Dl,Dh,zstate,epsstate,t

    achoicelin=weightal*weightDl*achoice(al,Dl,zstate,epsstate,epsoldstate,t)+(1-weightal)*weightDl*achoice(ah,Dl,zstate,epsstate,epsoldstate,t)+weightal*(1-weightDl)*achoice(al,Dh,zstate,epsstate,epsoldstate,t)+(1-weightal)*(1-weightDl)*achoice(ah,Dh,zstate,epsstate,epsoldstate,t)
    Dchoicelin=weightal*weightDl*Dchoice(al,Dl,zstate,epsstate,epsoldstate,t)+(1-weightal)*weightDl*Dchoice(ah,Dl,zstate,epsstate,epsoldstate,t)+weightal*(1-weightDl)*Dchoice(al,Dh,zstate,epsstate,epsoldstate,t)+(1-weightal)*(1-weightDl)*Dchoice(ah,Dh,zstate,epsstate,epsoldstate,t)
    cchoicelin=weightal*weightDl*cchoice(al,Dl,zstate,epsstate,epsoldstate,t)+(1-weightal)*weightDl*cchoice(ah,Dl,zstate,epsstate,epsoldstate,t)+weightal*(1-weightDl)*cchoice(al,Dh,zstate,epsstate,epsoldstate,t)+(1-weightal)*(1-weightDl)*cchoice(ah,Dh,zstate,epsstate,epsoldstate,t)
    rentallin=weightal*weightDl*rentalindicator(al,Dl,zstate,epsstate,epsoldstate,t)+(1-weightal)*weightDl*rentalindicator(ah,Dl,zstate,epsstate,epsoldstate,t)+weightal*(1-weightDl)*rentalindicator(al,Dh,zstate,epsstate,epsoldstate,t)+(1-weightal)*(1-weightDl)*rentalindicator(ah,Dh,zstate,epsstate,epsoldstate,t)
    welfare=weightal*weightDl*EV(al,Dl,zstate,epsstate,epsoldstate,t)+(1-weightal)*weightDl*EV(ah,Dl,zstate,epsstate,epsoldstate,t)+weightal*(1-weightDl)*EV(al,Dh,zstate,epsstate,epsoldstate,t)+(1-weightal)*(1-weightDl)*EV(ah,Dh,zstate,epsstate,epsoldstate,t)
    
end subroutine pol_linworking

subroutine solveworkingproblem
    USE nrtype; USE nrutil
    USE nr
    USE share
    USE OMP_LIB
    IMPLICIT NONE
    INTEGER :: i,j,k,l,m,t
    REAL(8) :: timestart2, timeend2
    REAL(8), dimension(agridsize,Dgridsize,zgridsize,epsgridsize,2) :: optpolicyadjust
    REAL(8), dimension(agridsize,Dgridsize,zgridsize,epsgridsize,epsgridsize,2) :: optpolicynoadjust
    REAL(8), dimension(agridsize,Dgridsize,zgridsize,epsgridsize,3,2) :: pstartadjust
    REAL(8), dimension(agridsize,Dgridsize,zgridsize,epsgridsize,3) :: ystartadjust
    REAL(8), dimension(agridsize,Dgridsize,zgridsize,epsgridsize,epsgridsize) :: ax,bx,cx, adjust
    INTEGER, dimension(agridsize,Dgridsize,zgridsize,epsgridsize) :: iter
    REAL(8), dimension(agridsize,Dgridsize,zgridsize,epsgridsize,epsgridsize,6) :: stateno
    REAL(8), dimension(agridsize,Dgridsize,zgridsize,epsgridsize,5) :: stateadjust

    REAL(8), DIMENSION(2) :: p2
    
    EXTERNAL valfuncnoadjust
    REAL(8) :: valfuncnoadjust

    REAL(8) valfuncadjust
    EXTERNAL valfuncadjust
    
    EXTERNAL valfuncadjust2
    REAL(8) valfuncadjust2
    
    REAL(8) valfuncrent
    EXTERNAL valfuncrent
    
    EXTERNAL valfuncrent2
    REAL(8) valfuncrent2

    EXTERNAL valfuncrent3
    REAL(8) valfuncrent3
       
    EXTERNAL brentnew
    REAL(8) brentnew
    REAL(8) ftol
    
    

    ftol=.000000001
    iter=0
    
    adjust=0
    
    do t=60,1,-1
        write(*,*) t
        !$OMP PARALLEL
        !$OMP DO
        do i=1,agridsize
            do j=1,Dgridsize
                do k=1,zgridsize
                    do l=1,epsgridsize
                        pstartadjust(i,j,k,l,1,1)=.1*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,1,2)=.8*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,2,1)=.25*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,2,2)=.25*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,3,1)=.5*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,3,2)=.2*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))

                        
                    
                        stateadjust(i,j,k,l,1)=anodes(i)
                        stateadjust(i,j,k,l,2)=Dnodes(j)
                        stateadjust(i,j,k,l,3)=k
                        stateadjust(i,j,k,l,4)=l
                        stateadjust(i,j,k,l,5)=t
                    
                        ystartadjust(i,j,k,l,1)=valfuncadjust2(pstartadjust(i,j,k,l,1,:),stateadjust(i,j,k,l,:))
                        ystartadjust(i,j,k,l,2)=valfuncadjust2(pstartadjust(i,j,k,l,2,:),stateadjust(i,j,k,l,:))
                        ystartadjust(i,j,k,l,3)=valfuncadjust2(pstartadjust(i,j,k,l,3,:),stateadjust(i,j,k,l,:))

                        if (i==35 .and. j==1 .and. k==12 .and. l==1 .and. t==1) then
                        write(*,*) "one"
                        write(*,*) ystartadjust(i,j,k,l,:)
                        end if
                    
                        call amoeba(pstartadjust(i,j,k,l,:,:),ystartadjust(i,j,k,l,:),ftol,valfuncadjust,iter(i,j,k,l),stateadjust(i,j,k,l,:))
                    
                    
                        Vadjust(i,j,k,l,t)=ystartadjust(i,j,k,l,1)
                        achoiceadjust(i,j,k,l,t)=pstartadjust(i,j,k,l,1,1)
                        Dchoiceadjust(i,j,k,l,t)=pstartadjust(i,j,k,l,1,2)
                    
                    
                        pstartadjust(i,j,k,l,1,1)=.01*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,1,2)=.01*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,2,1)=.05*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,2,2)=.1*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,3,1)=.4*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,3,2)=.21*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        
                        
                    
                        ystartadjust(i,j,k,l,1)=valfuncadjust2(pstartadjust(i,j,k,l,1,:),stateadjust(i,j,k,l,:))
                        ystartadjust(i,j,k,l,2)=valfuncadjust2(pstartadjust(i,j,k,l,2,:),stateadjust(i,j,k,l,:))
                        ystartadjust(i,j,k,l,3)=valfuncadjust2(pstartadjust(i,j,k,l,3,:),stateadjust(i,j,k,l,:))

                        if (i==35 .and. j==1 .and. k==12 .and. l==1 .and. t==1) then
                        write(*,*) "two"
                        write(*,*) ystartadjust(i,j,k,l,:)
                        end if

                        call amoeba(pstartadjust(i,j,k,l,:,:),ystartadjust(i,j,k,l,:),ftol,valfuncadjust,iter(i,j,k,l),stateadjust(i,j,k,l,:))
                    
                    
                        if (ystartadjust(i,j,k,l,1)<Vadjust(i,j,k,l,t)) then  !(again we're minimizing)
                            Vadjust(i,j,k,l,t)=ystartadjust(i,j,k,l,1)
                            achoiceadjust(i,j,k,l,t)=pstartadjust(i,j,k,l,1,1)
                            Dchoiceadjust(i,j,k,l,t)=pstartadjust(i,j,k,l,1,2)
                        end if
                        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                        pstartadjust(i,j,k,l,1,1)=.1*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,1,2)=.8*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,2,1)=.25*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,2,2)=.25*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,3,1)=.5*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,3,2)=.2*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                    
                        stateadjust(i,j,k,l,1)=anodes(i)
                        stateadjust(i,j,k,l,2)=Dnodes(j)
                        stateadjust(i,j,k,l,3)=k
                        stateadjust(i,j,k,l,4)=l
                        stateadjust(i,j,k,l,5)=t
                    
                        ystartadjust(i,j,k,l,1)=valfuncrent2(pstartadjust(i,j,k,l,1,:),stateadjust(i,j,k,l,:))
                        ystartadjust(i,j,k,l,2)=valfuncrent2(pstartadjust(i,j,k,l,2,:),stateadjust(i,j,k,l,:))
                        ystartadjust(i,j,k,l,3)=valfuncrent2(pstartadjust(i,j,k,l,3,:),stateadjust(i,j,k,l,:))

                        if (i==35 .and. j==1 .and. k==12 .and. l==1 .and. t==1) then
                        write(*,*) "three"
                        write(*,*) ystartadjust(i,j,k,l,:)
                        end if
                    
                        call amoeba(pstartadjust(i,j,k,l,:,:),ystartadjust(i,j,k,l,:),ftol,valfuncrent,iter(i,j,k,l),stateadjust(i,j,k,l,:))
                    
                    
                        Vrent(i,j,k,l,t)=ystartadjust(i,j,k,l,1)
                        achoicerent(i,j,k,l,t)=pstartadjust(i,j,k,l,1,1)
                        Dchoicerent(i,j,k,l,t)=pstartadjust(i,j,k,l,1,2)
                    
                    
                        pstartadjust(i,j,k,l,1,1)=.01*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,1,2)=.01*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,2,1)=.05*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,2,2)=.1*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,3,1)=.4*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
                        pstartadjust(i,j,k,l,3,2)=.21*((1+r)*anodes(i)+income(k,l,t)-(1+r)*(1-theta)*Dnodes(j)+(1-F)*(1-delta)*Dnodes(j))
 
                    
                        ystartadjust(i,j,k,l,1)=valfuncrent2(pstartadjust(i,j,k,l,1,:),stateadjust(i,j,k,l,:))
                        ystartadjust(i,j,k,l,2)=valfuncrent2(pstartadjust(i,j,k,l,2,:),stateadjust(i,j,k,l,:))
                        ystartadjust(i,j,k,l,3)=valfuncrent2(pstartadjust(i,j,k,l,3,:),stateadjust(i,j,k,l,:))

                        if (i==35 .and. j==1 .and. k==12 .and. l==1 .and. t==1) then
                        write(*,*) "four"
                        write(*,*) ystartadjust(i,j,k,l,:)
                        end if

                        call amoeba(pstartadjust(i,j,k,l,:,:),ystartadjust(i,j,k,l,:),ftol,valfuncrent,iter(i,j,k,l),stateadjust(i,j,k,l,:))
                    
                    
                        if (ystartadjust(i,j,k,l,1)<Vrent(i,j,k,l,t)) then  !(again we're minimizing)
                            Vrent(i,j,k,l,t)=ystartadjust(i,j,k,l,1)
                            achoicerent(i,j,k,l,t)=pstartadjust(i,j,k,l,1,1)
                            Dchoicerent(i,j,k,l,t)=pstartadjust(i,j,k,l,1,2)
                        end if
                        
                        
                        do m=1,epsgridsize
                            ax(i,j,k,l,m)=0
                            cx(i,j,k,l,m)=amax
                            bx(i,j,k,l,m)=0
                            stateno(i,j,k,l,m,1)=anodes(i)
                            stateno(i,j,k,l,m,2)=j
                            stateno(i,j,k,l,m,3)=k
                            stateno(i,j,k,l,m,4)=l
                            stateno(i,j,k,l,m,5)=m
                            stateno(i,j,k,l,m,6)=t
                            if (anodes(i)+Dnodes(j)*(1-theta)*(exp(epsnodes(1))**(phi_h+phi_h_extra)-exp(epsnodes(l))**(phi_h+phi_h_extra))+income(k,l,t)>0 .and. Dnodes(j)>0) then
                                Vnoadjust(i,j,k,l,m,t)=brentnew(ax(i,j,k,l,m),bx(i,j,k,l,m),cx(i,j,k,l,m),valfuncnoadjust,ftol,stateno(i,j,k,l,m,1),stateno(i,j,k,l,m,2),stateno(i,j,k,l,m,3),stateno(i,j,k,l,m,4),stateno(i,j,k,l,m,5),stateno(i,j,k,l,m,6),achoicenoadjust(i,j,k,l,m,t))
                                Dchoicenoadjust(i,j,k,l,m,t)=Dnodes(j)
                            else
                                Vnoadjust(i,j,k,l,m,t)=1000000000000
                            end if
                        

                        if (Vadjust(i,j,k,l,t)<Vnoadjust(i,j,k,l,m,t) .and. Vadjust(i,j,k,l,t)<Vrent(i,j,k,l,t)) then  ! since V = - V from minimization
                            achoice(i,j,k,l,m,t)=achoiceadjust(i,j,k,l,t)
                            Dchoice(i,j,k,l,m,t)=Dchoiceadjust(i,j,k,l,t)
                            if (anodes(i)-(1-theta)*Dnodes(j)*exp(epsnodes(l))**(phi_h+phi_h_extra)<0) then
                                cchoice(i,j,k,l,m,t)=income(k,l,t)+(1+rborrow*exp(epsnodes(l))**(-phi_r))*anodes(i)+Dnodes(j)*(1-delta)*(1-F)*exp(epsnodes(l))**(phi_h+phi_h_extra)-theta*Dchoice(i,j,k,l,m,t)*exp(epsnodes(l))**(phi_h+phi_h_extra)-achoice(i,j,k,l,m,t)-(1+rborrow*exp(epsnodes(l))**(-phi_r))*(1-theta)*(1-F)*Dnodes(j)*exp(epsnodes(l))**(phi_h+phi_h_extra)
                                !write(*,*) "diff1", income(k,l,t)+(1+rborrow*exp(epsnodes(l))**(-phi_r))*anodes(i)+Dnodes(j)*(1-delta)*(1-F)*exp(epsnodes(l))**(phi_h+phi_h_extra)-theta*Dchoice(i,j,k,l,t)*exp(epsnodes(l))**(phi_h+phi_h_extra)-achoice(i,j,k,l,t)-(1+rborrow*exp(epsnodes(l))**(-phi_r))*(1-theta)*(1-F)*Dnodes(j)*exp(epsnodes(l))**(phi_h+phi_h_extra)-(income(k,l,t)+(1+rborrow*exp(epsnodes(l))**(-0.0))*anodes(i)+Dnodes(j)*(1-delta)*(1-F)*exp(epsnodes(l))**(phi_h+phi_h_extra)-theta*Dchoice(i,j,k,l,t)*exp(epsnodes(l))**(phi_h+phi_h_extra)-achoice(i,j,k,l,t)-(1+rborrow*exp(epsnodes(l))**(-0.0))*(1-theta)*(1-F)*Dnodes(j)*exp(epsnodes(l))**(phi_h+phi_h_extra))
                            else
                                cchoice(i,j,k,l,m,t)=income(k,l,t)+(1+r)*anodes(i)+Dnodes(j)*(1-delta)*(1-F)*exp(epsnodes(l))**(phi_h+phi_h_extra)-theta*Dchoice(i,j,k,l,m,t)*exp(epsnodes(l))**(phi_h+phi_h_extra)-achoice(i,j,k,l,m,t)-(1+r)*(1-theta)*Dnodes(j)*(1-F)*exp(epsnodes(l))**(phi_h+phi_h_extra)
                            end if
                            rentalindicator(i,j,k,l,m,t)=0
                        elseif (Vnoadjust(i,j,k,l,m,t)<Vadjust(i,j,k,l,t) .and. Vnoadjust(i,j,k,l,m,t)<Vrent(i,j,k,l,t)) then
                            achoice(i,j,k,l,m,t)=achoicenoadjust(i,j,k,l,m,t)
                            Dchoice(i,j,k,l,m,t)=Dchoicenoadjust(i,j,k,l,m,t)


                            if (anodes(i)-(1-theta)*Dnodes(j)*exp(epsnodes(l))**(phi_h+phi_h_extra)<0) then
                                if (FRMindicator==1) then
                                cchoice(i,j,k,l,m,t)=income(k,l,t)+(1+rborrow*exp(max(epsnodes(m),epsnodes(l)))**(-phi_r))*anodes(i)+Dnodes(j)*(1-delta)*exp(epsnodes(l))**(phi_h+phi_h_extra)-theta*Dchoice(i,j,k,l,m,t)*exp(epsnodes(l))**(phi_h+phi_h_extra)-achoice(i,j,k,l,m,t)-(1+rborrow*exp(max(epsnodes(m),epsnodes(l)))**(-phi_r))*(1-theta)*Dnodes(j)*exp(epsnodes(l))**(phi_h+phi_h_extra)
                                else
                                cchoice(i,j,k,l,m,t)=income(k,l,t)+(1+rborrow*exp(epsnodes(l))**(-phi_r))*anodes(i)+Dnodes(j)*(1-delta)*exp(epsnodes(l))**(phi_h+phi_h_extra)-theta*Dchoice(i,j,k,l,m,t)*exp(epsnodes(l))**(phi_h+phi_h_extra)-achoice(i,j,k,l,m,t)-(1+rborrow*exp(epsnodes(l))**(-phi_r))*(1-theta)*Dnodes(j)*exp(epsnodes(l))**(phi_h+phi_h_extra)
                                end if
                            else
                                cchoice(i,j,k,l,m,t)=income(k,l,t)+(1+r)*anodes(i)+Dnodes(j)*(1-delta)*exp(epsnodes(l))**(phi_h+phi_h_extra)-theta*Dchoice(i,j,k,l,m,t)*exp(epsnodes(l))**(phi_h+phi_h_extra)-achoice(i,j,k,l,m,t)-(1+r)*(1-theta)*Dnodes(j)*exp(epsnodes(l))**(phi_h+phi_h_extra)
                            end if
                            rentalindicator(i,j,k,l,m,t)=0
                        else
                            achoice(i,j,k,l,m,t)=achoicerent(i,j,k,l,t)
                            Dchoice(i,j,k,l,m,t)=Dchoicerent(i,j,k,l,t)
                            if (anodes(i)-(1-theta)*Dnodes(j)*exp(epsnodes(l))**(phi_h+phi_h_extra)<0) then
                                cchoice(i,j,k,l,m,t)=income(k,l,t)+(1+rborrow*exp(epsnodes(l))**(-phi_r))*anodes(i)+Dnodes(j)*(1-delta)*(1-F)*exp(epsnodes(l))**(phi_h+phi_h_extra)-r_rental*Dchoice(i,j,k,l,m,t)*exp(epsnodes(l))**(phi_h+phi_h_extra)-achoice(i,j,k,l,m,t)-(1+rborrow*exp(epsnodes(l))**(-phi_r))*(1-theta)*(1-F)*Dnodes(j)*exp(epsnodes(l))**(phi_h+phi_h_extra)
                                !write(*,*) "diff3", income(k,l,t)+(1+rborrow*exp(epsnodes(l))**(-phi_r))*anodes(i)+Dnodes(j)*(1-delta)*(1-F)*exp(epsnodes(l))**(phi_h+phi_h_extra)-r_rental*Dchoice(i,j,k,l,t)*exp(epsnodes(l))**(phi_h+phi_h_extra)-achoice(i,j,k,l,t)-(1+rborrow*exp(epsnodes(l))**(-phi_r))*(1-theta)*(1-F)*Dnodes(j)*exp(epsnodes(l))**(phi_h+phi_h_extra) - (income(k,l,t)+(1+rborrow*exp(epsnodes(l))**(-0.0))*anodes(i)+Dnodes(j)*(1-delta)*(1-F)*exp(epsnodes(l))**(phi_h+phi_h_extra)-r_rental*Dchoice(i,j,k,l,t)*exp(epsnodes(l))**(phi_h+phi_h_extra)-achoice(i,j,k,l,t)-(1+rborrow*exp(epsnodes(l))**(-0.0))*(1-theta)*(1-F)*Dnodes(j)*exp(epsnodes(l))**(phi_h+phi_h_extra))
                            else
                                cchoice(i,j,k,l,m,t)=income(k,l,t)+(1+r)*anodes(i)+Dnodes(j)*(1-delta)*(1-F)*exp(epsnodes(l))**(phi_h+phi_h_extra)-r_rental*Dchoice(i,j,k,l,m,t)*exp(epsnodes(l))**(phi_h+phi_h_extra)-achoice(i,j,k,l,m,t)-(1+r)*(1-theta)*(1-F)*Dnodes(j)*exp(epsnodes(l))**(phi_h+phi_h_extra)
                            end if
                            !write(*,*) l,(1+rborrow*exp(epsnodes(l))**(-phi_r))
                            rentalindicator(i,j,k,l,m,t)=1
                        end if

                        end do
                    end do
                end do
            end do
        end do
        !$OMP END DO
        !$OMP END PARALLEL
        Vnoadjust(:,:,:,:,:,t)=-Vnoadjust(:,:,:,:,:,t)
        Vadjust(:,:,:,:,t)=-Vadjust(:,:,:,:,t)
        Vrent(:,:,:,:,t)=-Vrent(:,:,:,:,t)

        

        do m=1,epsgridsize
        Vadjustexpand(:,:,:,:,m,t)=Vadjust(:,:,:,:,t)
        Vrentexpand(:,:,:,:,m,t)=Vrent(:,:,:,:,t)
        end do
        EV(:,:,:,:,:,t)=max(Vrentexpand(:,:,:,:,:,t),max(Vnoadjust(:,:,:,:,:,t),Vadjustexpand(:,:,:,:,:,t)))
end do

     
end subroutine solveworkingproblem










REAL(8) FUNCTION valfuncadjust(p,state)  !p is choice variables optimized over (a' and D', C is residual from budget constraint), state is current state
USE SHARE
IMPLICIT NONE
REAL(8), DIMENSION(2) :: p
REAL(8), DIMENSION(5) :: state
REAL(8) :: a, D, z, eps, t, zindex,epsindex
REAL(8) :: currentincome
REAL(8) :: aprime, Dprime, consumption, Dcurrent
REAL(8) :: nearestDnode, nearestanode, Dprimel, Dprimeh, aprimel, aprimeh, weightDprimel, weightaprimel
INTEGER i,j
REAL(8) :: laborsupply
REAL(8) :: aprimeholder
REAL(8) :: EVholder
REAL(8) :: Vadjustretireholder, Vnoadjustretireholder, Vretirerentholder
REAL(8) :: pholder,epsholder
REAL(8) :: aprimeholder2

!write(*,*) state

!write(*,*) state

a=state(1)
D=state(2)
zindex=state(3)
epsindex=state(4)
t=state(5)

epsholder=epsnodes(epsindex)

currentincome=income(zindex,epsindex,t)

aprime=p(1)
Dcurrent=p(2)
Dprime=Dcurrent
aprimeholder=aprime
if (aprime>anodes(agridsize)) then
aprime=anodes(agridsize)
end if
aprimeholder2=aprime



if (aprime>=0 .AND. aprime<=anodes(agridsize) .AND. Dprime>=Dnodes(1) .AND. Dprime<=Dnodes(Dgridsize) .AND. Dcurrent>=0) then
    nearestDnode=minloc(abs(Dprime-Dnodes),1)
    if (Dprime==Dnodes(nearestDnode)) then
        if (nearestDnode<Dgridsize) then
            Dprimel=nearestDnode
            Dprimeh=nearestDnode+1
            weightDprimel=1.0
        else
            Dprimel=nearestDnode-1
            Dprimeh=nearestDnode
            weightDprimel=0.0
        end if
    else
        if (Dprime-Dnodes(nearestDnode)>0) then
            Dprimel=nearestDnode
            Dprimeh=nearestDnode+1
            weightDprimel=1-(Dprime-Dnodes(Dprimel))/(Dnodes(Dprimeh)-Dnodes(Dprimel))
        else
            Dprimel=nearestDnode-1
            Dprimeh=nearestDnode
            weightDprimel=1-(Dprime-Dnodes(Dprimel))/(Dnodes(Dprimeh)-Dnodes(Dprimel))
        end if
    end if
    if ((a-D*(1-theta)*exp(epsholder)**(phi_h+phi_h_extra))<0) then
        consumption=(currentincome+(1+rborrow*exp(epsholder)**(-phi_r))*a+D*(1-F)*(1-delta)*exp(epsholder)**(phi_h+phi_h_extra)-theta*Dcurrent*exp(epsholder)**(phi_h+phi_h_extra)-aprimeholder-(1+rborrow*exp(epsholder)**(-phi_r))*(1-theta)*D*(1-F)*exp(epsholder)**(phi_h+phi_h_extra))
    else
        consumption=(currentincome+(1+r)*a+D*(1-F)*(1-delta)*exp(epsholder)**(phi_h+phi_h_extra)-theta*Dcurrent*exp(epsholder)**(phi_h+phi_h_extra)-aprimeholder-(1+r)*(1-theta)*D*(1-F)*exp(epsholder)**(phi_h+phi_h_extra))
    end if

    !need to figure out Vadjust and Vnoadjust at offgrid points tomorrow.  Find nearest grid points and linearly interpolate.
    if (consumption>0) then
        valfuncadjust=((consumption+0)**elasticity2*(Dcurrent+0)**(1-elasticity2))**(1-elasticity)/(1-elasticity)
        EVholder=0
        if (t<=35) then
            do j=1,epsgridsize
                        aprime=aprimeholder2+(1-theta)*Dprime*(exp(epsnodes(j))**(phi_h+phi_h_extra)-exp(epsholder)**(phi_h+phi_h_extra))
                        if (aprime>anodes(agridsize)) then
                            aprime=anodes(agridsize)
                        elseif (aprime<anodes(1)) then
                            aprime=anodes(1)
                        end if

                        nearestanode=minloc(abs(aprime-anodes),1)
                        if (aprime==anodes(nearestanode)) then
                            if (nearestanode<agridsize) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1.0
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=0.0
                            end if
                        else
                            if (aprime-anodes(nearestanode)>0) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            end if
                        end if

                do i=minexpectationz(zindex),maxexpectationz(zindex)
                
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*weightaprimel*weightDprimel*EV(aprimel,Dprimel,i,j,j,t+1)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*(1-weightaprimel)*weightDprimel*EV(aprimeh,Dprimel,i,j,j,t+1)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*weightaprimel*(1-weightDprimel)*EV(aprimel,Dprimeh,i,j,j,t+1)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*(1-weightaprimel)*(1-weightDprimel)*EV(aprimeh,Dprimeh,i,j,j,t+1)
                end do
            end do
            valfuncadjust=valfuncadjust+beta2*EVholder
        else
            do j=1,epsgridsize
                        aprime=aprimeholder2+(1-theta)*Dprime*(exp(epsnodes(j))**(phi_h+phi_h_extra)-exp(epsholder)**(phi_h+phi_h_extra))
                        if (aprime>anodes(agridsize)) then
                            aprime=anodes(agridsize)
                        elseif (aprime<anodes(1)) then
                            aprime=anodes(1)
                        end if

                        nearestanode=minloc(abs(aprime-anodes),1)
                        if (aprime==anodes(nearestanode)) then
                            if (nearestanode<agridsize) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1.0
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=0.0
                            end if
                        else
                            if (aprime-anodes(nearestanode)>0) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            end if
                        end if

                    EVholder=EVholder+Probeps(epsindex,j)*weightaprimel*weightDprimel*EV(aprimel,Dprimel,zindex,j,j,t+1)
                    EVholder=EVholder+Probeps(epsindex,j)*(1-weightaprimel)*weightDprimel*EV(aprimeh,Dprimel,zindex,j,j,t+1)
                    EVholder=EVholder+Probeps(epsindex,j)*weightaprimel*(1-weightDprimel)*EV(aprimel,Dprimeh,zindex,j,j,t+1)
                    EVholder=EVholder+Probeps(epsindex,j)*(1-weightaprimel)*(1-weightDprimel)*EV(aprimeh,Dprimeh,zindex,j,j,t+1)
            end do
            valfuncadjust=valfuncadjust+beta2*(1-deathprob(t-35))*EVholder
        end if

        
    else
        valfuncadjust=-10000000000
    end if
else
     valfuncadjust=-10000000000
end if



valfuncadjust=-valfuncadjust  !powell minimizes



END FUNCTION valfuncadjust


REAL(8) FUNCTION valfuncrent(p,state)  !p is choice variables optimized over (a' and D', C is residual from budget constraint), state is current state
USE SHARE
IMPLICIT NONE
REAL(8), DIMENSION(2) :: p
REAL(8), DIMENSION(5) :: state
REAL(8) :: a, D, z, eps, t, zindex,epsindex
REAL(8) :: currentincome
REAL(8) :: aprime, Dprime, consumption, Dcurrent
REAL(8) :: nearestDnode, nearestanode, Dprimel, Dprimeh, aprimel, aprimeh, weightDprimel, weightaprimel
INTEGER i,j
REAL(8) :: laborsupply
REAL(8) :: aprimeholder
REAL(8) :: EVholder
REAL(8) :: Vadjustretireholder, Vnoadjustretireholder, Vretirerentholder
REAL(8) :: pholder,epsholder
REAL(8) :: aprimeholder2
!write(*,*) state

!write(*,*) state

a=state(1)
D=state(2)
zindex=state(3)
epsindex=state(4)
t=state(5)

epsholder=epsnodes(epsindex)

currentincome=income(zindex,epsindex,t)

aprime=p(1)
Dcurrent=p(2)
Dprime=Dcurrent
aprimeholder=aprime
if (aprime>anodes(agridsize)) then
aprime=anodes(agridsize)
end if
aprimeholder2=aprime


if (aprime>=0 .AND. aprime<=anodes(agridsize) .AND. Dprime>=Dnodes(1) .AND. Dprime<=Dnodes(Dgridsize) .AND. Dcurrent>=0) then
    nearestanode=minloc(abs(aprime-anodes),1)
    if ((a-D*(1-theta)*exp(epsholder)**(phi_h+phi_h_extra))<0) then
        consumption=(currentincome+(1+rborrow*exp(epsholder)**(-phi_r))*a+D*(1-F)*(1-delta)*exp(epsholder)**(phi_h+phi_h_extra)-r_rental*Dcurrent*exp(epsholder)**(phi_h+phi_h_extra)-aprimeholder-(1+rborrow*exp(epsholder)**(-phi_r))*(1-theta)*D*(1-F)*exp(epsholder)**(phi_h+phi_h_extra))
    else
        consumption=(currentincome+(1+r)*a+D*(1-F)*(1-delta)*exp(epsholder)**(phi_h+phi_h_extra)-r_rental*Dcurrent*exp(epsholder)**(phi_h+phi_h_extra)-aprimeholder-(1+r)*(1-theta)*D*(1-F)*exp(epsholder)**(phi_h+phi_h_extra))
    end if
    !need to figure out Vadjust and Vnoadjust at offgrid points tomorrow.  Find nearest grid points and linearly interpolate.
    if (consumption>0) then
        valfuncrent=((consumption+0)**elasticity2*(Dcurrent+0)**(1-elasticity2))**(1-elasticity)/(1-elasticity)
        EVholder=0
        if (t<=35) then
            do j=1,epsgridsize
                    aprime=aprimeholder2+(1-theta)*Dprime*(exp(epsnodes(j))**(phi_h+phi_h_extra)-exp(epsholder)**(phi_h+phi_h_extra))
                        if (aprime>anodes(agridsize)) then
                            aprime=anodes(agridsize)
                        elseif (aprime<anodes(1)) then
                            aprime=anodes(1)
                        end if

                        nearestanode=minloc(abs(aprime-anodes),1)
                        if (aprime==anodes(nearestanode)) then
                            if (nearestanode<agridsize) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1.0
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=0.0
                            end if
                        else
                            if (aprime-anodes(nearestanode)>0) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            end if
                        end if


                do i=minexpectationz(zindex),maxexpectationz(zindex)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*weightaprimel*EV(aprimel,1,i,j,j,t+1)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*(1-weightaprimel)*EV(aprimeh,1,i,j,j,t+1)
                end do
            end do
            valfuncrent=valfuncrent+beta2*EVholder
        else
            do j=1,epsgridsize
                        aprime=aprimeholder2+(1-theta)*Dprime*(exp(epsnodes(j))**(phi_h+phi_h_extra)-exp(epsholder)**(phi_h+phi_h_extra))
                        if (aprime>anodes(agridsize)) then
                            aprime=anodes(agridsize)
                        elseif (aprime<anodes(1)) then
                            aprime=anodes(1)
                        end if

                        nearestanode=minloc(abs(aprime-anodes),1)
                        if (aprime==anodes(nearestanode)) then
                            if (nearestanode<agridsize) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1.0
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=0.0
                            end if
                        else
                            if (aprime-anodes(nearestanode)>0) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            end if
                        end if


                    EVholder=EVholder+Probeps(epsindex,j)*weightaprimel*EV(aprimel,1,zindex,j,j,t+1)
                    EVholder=EVholder+Probeps(epsindex,j)*(1-weightaprimel)*EV(aprimeh,1,zindex,j,j,t+1)
            end do
            valfuncrent=valfuncrent+beta2*(1-deathprob(t-35))*EVholder
        end if
        
        
    else
        valfuncrent=-10000000000
    end if
else
     valfuncrent=-10000000000
end if



valfuncrent=-valfuncrent  !powell minimizes



END FUNCTION valfuncrent



REAL(8) FUNCTION valfuncadjust2(p,state)  !p is choice variables optimized over (a' and D', C is residual from budget constraint), state is current state
USE SHARE
IMPLICIT NONE
REAL(8), DIMENSION(2) :: p
REAL(8), DIMENSION(5) :: state
REAL(8) :: a, D, z, eps, t, zindex,epsindex
REAL(8) :: currentincome
REAL(8) :: aprime, Dprime, consumption, Dcurrent
REAL(8) :: nearestDnode, nearestanode, Dprimel, Dprimeh, aprimel, aprimeh, weightDprimel, weightaprimel
INTEGER i,j
REAL(8) :: laborsupply
REAL(8) :: aprimeholder
REAL(8) :: EVholder
REAL(8) :: Vadjustretireholder, Vnoadjustretireholder, Vretirerentholder
REAL(8) :: pholder,epsholder
REAL(8) :: aprimeholder2

!write(*,*) state

!write(*,*) state

a=state(1)
D=state(2)
zindex=state(3)
epsindex=state(4)
t=state(5)

epsholder=epsnodes(epsindex)

currentincome=income(zindex,epsindex,t)

aprime=p(1)
Dcurrent=p(2)
Dprime=Dcurrent
aprimeholder=aprime
if (aprime>anodes(agridsize)) then
aprime=anodes(agridsize)
end if
aprimeholder2=aprime



if (aprime>=0 .AND. aprime<=anodes(agridsize) .AND. Dprime>=Dnodes(1) .AND. Dprime<=Dnodes(Dgridsize) .AND. Dcurrent>=0) then
    nearestDnode=minloc(abs(Dprime-Dnodes),1)
    if (Dprime==Dnodes(nearestDnode)) then
        if (nearestDnode<Dgridsize) then
            Dprimel=nearestDnode
            Dprimeh=nearestDnode+1
            weightDprimel=1.0
        else
            Dprimel=nearestDnode-1
            Dprimeh=nearestDnode
            weightDprimel=0.0
        end if
    else
        if (Dprime-Dnodes(nearestDnode)>0) then
            Dprimel=nearestDnode
            Dprimeh=nearestDnode+1
            weightDprimel=1-(Dprime-Dnodes(Dprimel))/(Dnodes(Dprimeh)-Dnodes(Dprimel))
        else
            Dprimel=nearestDnode-1
            Dprimeh=nearestDnode
            weightDprimel=1-(Dprime-Dnodes(Dprimel))/(Dnodes(Dprimeh)-Dnodes(Dprimel))
        end if
    end if
    if ((a-D*(1-theta)*exp(epsholder)**(phi_h+phi_h_extra))<0) then
        consumption=(currentincome+(1+rborrow*exp(epsholder)**(-phi_r))*a+D*(1-F)*(1-delta)*exp(epsholder)**(phi_h+phi_h_extra)-theta*Dcurrent*exp(epsholder)**(phi_h+phi_h_extra)-aprimeholder-(1+rborrow*exp(epsholder)**(-phi_r))*(1-theta)*D*(1-F)*exp(epsholder)**(phi_h+phi_h_extra))
    else
        consumption=(currentincome+(1+r)*a+D*(1-F)*(1-delta)*exp(epsholder)**(phi_h+phi_h_extra)-theta*Dcurrent*exp(epsholder)**(phi_h+phi_h_extra)-aprimeholder-(1+r)*(1-theta)*D*(1-F)*exp(epsholder)**(phi_h+phi_h_extra))
    end if

    !need to figure out Vadjust and Vnoadjust at offgrid points tomorrow.  Find nearest grid points and linearly interpolate.
    if (consumption>0) then
        valfuncadjust2=((consumption+0)**elasticity2*(Dcurrent+0)**(1-elasticity2))**(1-elasticity)/(1-elasticity)
        EVholder=0
        if (t<=35) then
            do j=1,epsgridsize
                        aprime=aprimeholder2+(1-theta)*Dprime*(exp(epsnodes(j))**(phi_h+phi_h_extra)-exp(epsholder)**(phi_h+phi_h_extra))
                        if (aprime>anodes(agridsize)) then
                            aprime=anodes(agridsize)
                        elseif (aprime<anodes(1)) then
                            aprime=anodes(1)
                        end if

                        nearestanode=minloc(abs(aprime-anodes),1)
                        if (aprime==anodes(nearestanode)) then
                            if (nearestanode<agridsize) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1.0
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=0.0
                            end if
                        else
                            if (aprime-anodes(nearestanode)>0) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            end if
                        end if

                do i=minexpectationz(zindex),maxexpectationz(zindex)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*weightaprimel*weightDprimel*EV(aprimel,Dprimel,i,j,j,t+1)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*(1-weightaprimel)*weightDprimel*EV(aprimeh,Dprimel,i,j,j,t+1)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*weightaprimel*(1-weightDprimel)*EV(aprimel,Dprimeh,i,j,j,t+1)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*(1-weightaprimel)*(1-weightDprimel)*EV(aprimeh,Dprimeh,i,j,j,t+1)
                end do
            end do
            valfuncadjust2=valfuncadjust2+beta2*EVholder
        else
            do j=1,epsgridsize
                        aprime=aprimeholder2+(1-theta)*Dprime*(exp(epsnodes(j))**(phi_h+phi_h_extra)-exp(epsholder)**(phi_h+phi_h_extra))
                        if (aprime>anodes(agridsize)) then
                            aprime=anodes(agridsize)
                        elseif (aprime<anodes(1)) then
                            aprime=anodes(1)
                        end if

                        nearestanode=minloc(abs(aprime-anodes),1)
                        if (aprime==anodes(nearestanode)) then
                            if (nearestanode<agridsize) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1.0
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=0.0
                            end if
                        else
                            if (aprime-anodes(nearestanode)>0) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            end if
                        end if

                    EVholder=EVholder+Probeps(epsindex,j)*weightaprimel*weightDprimel*EV(aprimel,Dprimel,zindex,j,j,t+1)
                    EVholder=EVholder+Probeps(epsindex,j)*(1-weightaprimel)*weightDprimel*EV(aprimeh,Dprimel,zindex,j,j,t+1)
                    EVholder=EVholder+Probeps(epsindex,j)*weightaprimel*(1-weightDprimel)*EV(aprimel,Dprimeh,zindex,j,j,t+1)
                    EVholder=EVholder+Probeps(epsindex,j)*(1-weightaprimel)*(1-weightDprimel)*EV(aprimeh,Dprimeh,zindex,j,j,t+1)
            end do
            valfuncadjust2=valfuncadjust2+beta2*(1-deathprob(t-35))*EVholder
        end if

        
    else
        valfuncadjust2=-10000000000
    end if
else
     valfuncadjust2=-10000000000
end if



valfuncadjust2=-valfuncadjust2  !powell minimizes



END FUNCTION valfuncadjust2


REAL(8) FUNCTION valfuncrent2(p,state)  !p is choice variables optimized over (a' and D', C is residual from budget constraint), state is current state
USE SHARE
IMPLICIT NONE
REAL(8), DIMENSION(2) :: p
REAL(8), DIMENSION(5) :: state
REAL(8) :: a, D, z, eps, t, zindex,epsindex
REAL(8) :: currentincome
REAL(8) :: aprime, Dprime, consumption, Dcurrent
REAL(8) :: nearestDnode, nearestanode, Dprimel, Dprimeh, aprimel, aprimeh, weightDprimel, weightaprimel
INTEGER i,j
REAL(8) :: laborsupply
REAL(8) :: aprimeholder
REAL(8) :: EVholder
REAL(8) :: Vadjustretireholder, Vnoadjustretireholder, Vretirerentholder
REAL(8) :: pholder,epsholder
REAL(8) :: aprimeholder2
!write(*,*) state

!write(*,*) state

a=state(1)
D=state(2)
zindex=state(3)
epsindex=state(4)
t=state(5)

epsholder=epsnodes(epsindex)

currentincome=income(zindex,epsindex,t)

aprime=p(1)
Dcurrent=p(2)
Dprime=Dcurrent
aprimeholder=aprime
if (aprime>anodes(agridsize)) then
aprime=anodes(agridsize)
end if
aprimeholder2=aprime


if (aprime>=0 .AND. aprime<=anodes(agridsize) .AND. Dprime>=Dnodes(1) .AND. Dprime<=Dnodes(Dgridsize) .AND. Dcurrent>=0) then
    nearestanode=minloc(abs(aprime-anodes),1)
    if ((a-D*(1-theta)*exp(epsholder)**(phi_h+phi_h_extra))<0) then
        consumption=(currentincome+(1+rborrow*exp(epsholder)**(-phi_r))*a+D*(1-F)*(1-delta)*exp(epsholder)**(phi_h+phi_h_extra)-r_rental*Dcurrent*exp(epsholder)**(phi_h+phi_h_extra)-aprimeholder-(1+rborrow*exp(epsholder)**(-phi_r))*(1-theta)*D*(1-F)*exp(epsholder)**(phi_h+phi_h_extra))
    else
        consumption=(currentincome+(1+r)*a+D*(1-F)*(1-delta)*exp(epsholder)**(phi_h+phi_h_extra)-r_rental*Dcurrent*exp(epsholder)**(phi_h+phi_h_extra)-aprimeholder-(1+r)*(1-theta)*D*(1-F)*exp(epsholder)**(phi_h+phi_h_extra))
    end if
    !need to figure out Vadjust and Vnoadjust at offgrid points tomorrow.  Find nearest grid points and linearly interpolate.
    if (consumption>0) then
        valfuncrent2=((consumption+0)**elasticity2*(Dcurrent+0)**(1-elasticity2))**(1-elasticity)/(1-elasticity)
        EVholder=0
        if (t<=35) then
            do j=1,epsgridsize
                    aprime=aprimeholder2+(1-theta)*Dprime*(exp(epsnodes(j))**(phi_h+phi_h_extra)-exp(epsholder)**(phi_h+phi_h_extra))
                        if (aprime>anodes(agridsize)) then
                            aprime=anodes(agridsize)
                        elseif (aprime<anodes(1)) then
                            aprime=anodes(1)
                        end if

                        nearestanode=minloc(abs(aprime-anodes),1)
                        if (aprime==anodes(nearestanode)) then
                            if (nearestanode<agridsize) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1.0
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=0.0
                            end if
                        else
                            if (aprime-anodes(nearestanode)>0) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            end if
                        end if


                do i=minexpectationz(zindex),maxexpectationz(zindex)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*weightaprimel*EV(aprimel,1,i,j,j,t+1)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*(1-weightaprimel)*EV(aprimeh,1,i,j,j,t+1)
                end do
            end do
            valfuncrent2=valfuncrent2+beta2*EVholder
        else
            do j=1,epsgridsize
                        aprime=aprimeholder2+(1-theta)*Dprime*(exp(epsnodes(j))**(phi_h+phi_h_extra)-exp(epsholder)**(phi_h+phi_h_extra))
                        if (aprime>anodes(agridsize)) then
                            aprime=anodes(agridsize)
                        elseif (aprime<anodes(1)) then
                            aprime=anodes(1)
                        end if

                        nearestanode=minloc(abs(aprime-anodes),1)
                        if (aprime==anodes(nearestanode)) then
                            if (nearestanode<agridsize) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1.0
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=0.0
                            end if
                        else
                            if (aprime-anodes(nearestanode)>0) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            end if
                        end if


                    EVholder=EVholder+Probeps(epsindex,j)*weightaprimel*EV(aprimel,1,zindex,j,j,t+1)
                    EVholder=EVholder+Probeps(epsindex,j)*(1-weightaprimel)*EV(aprimeh,1,zindex,j,j,t+1)
            end do
            valfuncrent2=valfuncrent2+beta2*(1-deathprob(t-35))*EVholder
        end if
        
        
    else
        valfuncrent2=-10000000000
    end if
else
     valfuncrent2=-10000000000
end if



valfuncrent2=-valfuncrent2  !powell minimizes



END FUNCTION valfuncrent2






REAL(8) FUNCTION valfuncrent3(p,state)  !p is choice variables optimized over (a' and D', C is residual from budget constraint), state is current state
USE SHARE
IMPLICIT NONE
REAL(8), DIMENSION(2) :: p
REAL(8), DIMENSION(5) :: state
REAL(8) :: a, D, z, eps, t, zindex,epsindex
REAL(8) :: currentincome
REAL(8) :: aprime, Dprime, consumption, Dcurrent
REAL(8) :: nearestDnode, nearestanode, Dprimel, Dprimeh, aprimel, aprimeh, weightDprimel, weightaprimel
INTEGER i,j
REAL(8) :: laborsupply
REAL(8) :: aprimeholder
REAL(8) :: EVholder
REAL(8) :: Vadjustretireholder, Vnoadjustretireholder, Vretirerentholder
REAL(8) :: pholder,epsholder
REAL(8) :: aprimeholder2
!write(*,*) state

!write(*,*) state

a=state(1)
D=state(2)
zindex=state(3)
epsindex=state(4)
t=state(5)

epsholder=epsnodes(epsindex)

currentincome=income(zindex,epsindex,t)

aprime=p(1)
Dcurrent=p(2)
Dprime=Dcurrent
aprimeholder=aprime
if (aprime>anodes(agridsize)) then
aprime=anodes(agridsize)
end if
aprimeholder2=aprime


if (aprime>=0 .AND. aprime<=anodes(agridsize) .AND. Dprime>=Dnodes(1) .AND. Dprime<=Dnodes(Dgridsize) .AND. Dcurrent>=0) then
    nearestanode=minloc(abs(aprime-anodes),1)
    if ((a-D*(1-theta)*exp(epsholder)**(phi_h+phi_h_extra))<0) then
        consumption=(currentincome+(1+rborrow*exp(epsholder)**(-phi_r))*a+D*(1-F)*(1-delta)*exp(epsholder)**(phi_h+phi_h_extra)-r_rental*Dcurrent*exp(epsholder)**(phi_h+phi_h_extra)-aprimeholder-(1+rborrow*exp(epsholder)**(-phi_r))*(1-theta)*D*(1-F)*exp(epsholder)**(phi_h+phi_h_extra))
    else
        consumption=(currentincome+(1+r)*a+D*(1-F)*(1-delta)*exp(epsholder)**(phi_h+phi_h_extra)-r_rental*Dcurrent*exp(epsholder)**(phi_h+phi_h_extra)-aprimeholder-(1+r)*(1-theta)*D*(1-F)*exp(epsholder)**(phi_h+phi_h_extra))
    end if
    !need to figure out Vadjust and Vnoadjust at offgrid points tomorrow.  Find nearest grid points and linearly interpolate.
    if (consumption>0) then
        valfuncrent3=((consumption+0)**elasticity2*(Dcurrent+0)**(1-elasticity2))**(1-elasticity)/(1-elasticity)
        EVholder=0
        if (t<=35) then
            do j=1,epsgridsize
                    aprime=aprimeholder2+(1-theta)*Dprime*(exp(epsnodes(j))**(phi_h+phi_h_extra)-exp(epsholder)**(phi_h+phi_h_extra))
                        if (aprime>anodes(agridsize)) then
                            aprime=anodes(agridsize)
                        elseif (aprime<anodes(1)) then
                            aprime=anodes(1)
                        end if

                        nearestanode=minloc(abs(aprime-anodes),1)
                        if (aprime==anodes(nearestanode)) then
                            if (nearestanode<agridsize) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1.0
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=0.0
                            end if
                        else
                            if (aprime-anodes(nearestanode)>0) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            end if
                        end if


                do i=minexpectationz(zindex),maxexpectationz(zindex)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*weightaprimel*EV(aprimel,1,i,j,j,t+1)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*(1-weightaprimel)*EV(aprimeh,1,i,j,j,t+1)
                end do
            end do
            valfuncrent3=valfuncrent3+beta2*EVholder
        else
            do j=1,epsgridsize
                        aprime=aprimeholder2+(1-theta)*Dprime*(exp(epsnodes(j))**(phi_h+phi_h_extra)-exp(epsholder)**(phi_h+phi_h_extra))
                        if (aprime>anodes(agridsize)) then
                            aprime=anodes(agridsize)
                        elseif (aprime<anodes(1)) then
                            aprime=anodes(1)
                        end if

                        nearestanode=minloc(abs(aprime-anodes),1)
                        if (aprime==anodes(nearestanode)) then
                            if (nearestanode<agridsize) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1.0
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=0.0
                            end if
                        else
                            if (aprime-anodes(nearestanode)>0) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            end if
                        end if


                    EVholder=EVholder+Probeps(epsindex,j)*weightaprimel*EV(aprimel,1,zindex,j,j,t+1)
                    EVholder=EVholder+Probeps(epsindex,j)*(1-weightaprimel)*EV(aprimeh,1,zindex,j,j,t+1)
            end do
            valfuncrent3=valfuncrent3+beta2*(1-deathprob(t-35))*EVholder
        end if
        
        
    else
        valfuncrent3=-10000000000
    end if
else
     valfuncrent3=-10000000000
end if



valfuncrent3=-valfuncrent3  !powell minimizes



END FUNCTION valfuncrent3





REAL(8) FUNCTION valfuncnoadjust(aprime,a,Dindex,zindex,epsindex,epsindexold,t)  !p is choice variables optimized over (a' and D', C is residual from budget constraint), state is current state
USE SHARE
IMPLICIT NONE
REAL(8), DIMENSION(2) :: p
REAL(8) :: a, z, eps, t, zindex,epsindex,Dindex,epsindexold
REAL(8) :: currentincome
REAL(8) :: aprime, Dprime, consumption, Dcurrent
REAL(8) :: nearestDnode, nearestanode, Dprimel, Dprimeh, aprimel, aprimeh, weightDprimel, weightaprimel, EVholder
REAL(8) :: i,j
REAL(8) :: laborsupply
REAL(8) :: aprimeholder
REAL(8) :: Vadjustholder,Vnoadjustholder
REAL(8) :: Vadjustretireholder,Vnoadjustretireholder
REAL(8) :: epsholder,epsholderold
REAL(8) :: aprimeholder2
!write(*,*) state

!write(*,*) state

currentincome=income(zindex,epsindex,t)

epsholder=epsnodes(epsindex)
epsholderold=epsnodes(epsindexold)

Dcurrent=Dnodes(Dindex)
Dprime=Dnodes(Dindex)
aprimeholder=aprime
if (aprime>anodes(agridsize)) then
aprime=anodes(agridsize)
end if
aprimeholder2=aprime


if (aprime>=0 .AND. aprime<=anodes(agridsize)) then
 
    
    !using that Dprime=D
    if ((a-Dcurrent*(1-theta)*exp(epsholder)**(phi_h+phi_h_extra))<0) then
        if (FRMindicator==1) then
        consumption=(currentincome+(1+rborrow*exp(max(epsholderold,epsholder))**(-phi_r))*a+Dprime*(1-delta)*exp(epsholder)**(phi_h+phi_h_extra)-theta*Dprime*exp(epsholder)**(phi_h+phi_h_extra)-aprimeholder-(1+rborrow*exp(max(epsholderold,epsholder))**(-phi_r))*(1-theta)*Dprime*exp(epsholder)**(phi_h+phi_h_extra))
        else
        consumption=(currentincome+(1+rborrow*exp(epsholder)**(-phi_r))*a+Dprime*(1-delta)*exp(epsholder)**(phi_h+phi_h_extra)-theta*Dprime*exp(epsholder)**(phi_h+phi_h_extra)-aprimeholder-(1+rborrow*exp(epsholder)**(-phi_r))*(1-theta)*Dprime*exp(epsholder)**(phi_h+phi_h_extra))
        end if
    else
        consumption=(currentincome+(1+r)*a+Dprime*(1-delta)*exp(epsholder)**(phi_h+phi_h_extra)-theta*Dprime*exp(epsholder)**(phi_h+phi_h_extra)-aprimeholder-(1+r)*(1-theta)*Dprime*exp(epsholder)**(phi_h+phi_h_extra))
    end if

    !need to figure out Vadjust and Vnoadjust at offgrid points tomorrow.  Find nearest grid points and linearly interpolate.
    if (consumption>0) then
        valfuncnoadjust=((consumption+0)**elasticity2*(Dcurrent+0)**(1-elasticity2))**(1-elasticity)/(1-elasticity)
        
        EVholder=0
        if (t<=35) then
            do j=1,epsgridsize
                 aprime=aprimeholder2+(1-theta)*Dprime*(exp(epsnodes(j))**(phi_h+phi_h_extra)-exp(epsholder)**(phi_h+phi_h_extra))
                        if (aprime>anodes(agridsize)) then
                            aprime=anodes(agridsize)
                        elseif (aprime<anodes(1)) then
                            aprime=anodes(1)
                        end if

                        nearestanode=minloc(abs(aprime-anodes),1)
                        if (aprime==anodes(nearestanode)) then
                            if (nearestanode<agridsize) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1.0
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=0.0
                            end if
                        else
                            if (aprime-anodes(nearestanode)>0) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            end if
                        end if

                do i=minexpectationz(zindex),maxexpectationz(zindex)
                    if (FRMindicator==1) then
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*weightaprimel*EV(aprimel,Dindex,i,j,max(epsindexold,j),t+1)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*(1-weightaprimel)*EV(aprimeh,Dindex,i,j,max(epsindexold,j),t+1)
                    else
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*weightaprimel*EV(aprimel,Dindex,i,j,j,t+1)
                    EVholder=EVholder+Probz(zindex,i)*Probeps(epsindex,j)*(1-weightaprimel)*EV(aprimeh,Dindex,i,j,j,t+1)
                    end if
                end do
            end do
        valfuncnoadjust=valfuncnoadjust+beta2*EVholder
        else
                do j=1,epsgridsize
                        aprime=aprimeholder2+(1-theta)*Dprime*(exp(epsnodes(j))**(phi_h+phi_h_extra)-exp(epsholder)**(phi_h+phi_h_extra))
                        if (aprime>anodes(agridsize)) then
                            aprime=anodes(agridsize)
                        elseif (aprime<anodes(1)) then
                            aprime=anodes(1)
                        end if

                        nearestanode=minloc(abs(aprime-anodes),1)
                        if (aprime==anodes(nearestanode)) then
                            if (nearestanode<agridsize) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1.0
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=0.0
                            end if
                        else
                            if (aprime-anodes(nearestanode)>0) then
                                aprimel=nearestanode
                                aprimeh=nearestanode+1
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            else
                                aprimel=nearestanode-1
                                aprimeh=nearestanode
                                weightaprimel=1-(aprime-anodes(aprimel))/(anodes(aprimeh)-anodes(aprimel))
                            end if
                        end if

                    if (FRMindicator==1) then
                    EVholder=EVholder+Probeps(epsindex,j)*weightaprimel*EV(aprimel,Dindex,zindex,j,max(epsindexold,j),t+1)
                    EVholder=EVholder+Probeps(epsindex,j)*(1-weightaprimel)*EV(aprimeh,Dindex,zindex,j,max(epsindexold,j),t+1)
                    else
                    EVholder=EVholder+Probeps(epsindex,j)*weightaprimel*EV(aprimel,Dindex,zindex,j,j,t+1)
                    EVholder=EVholder+Probeps(epsindex,j)*(1-weightaprimel)*EV(aprimeh,Dindex,zindex,j,j,t+1)
                    end if
                end do
        valfuncnoadjust=valfuncnoadjust+beta2*(1-deathprob(t-35))*EVholder
        end if

        
        
    else
        valfuncnoadjust=-10000000000
    end if
else
     valfuncnoadjust=-10000000000
end if



valfuncnoadjust=-valfuncnoadjust  !powell minimizes

aprime=aprimeholder


END FUNCTION valfuncnoadjust











SUBROUTINE amoeba(p,y,ftol,valfuncadjust,iter,stateholder)
	USE nrtype; USE nrutil, ONLY : assert_eq,imaxloc,iminloc,nrerror,swap
	IMPLICIT NONE
	INTEGER(I4B), INTENT(OUT) :: iter
	REAL(SP), INTENT(IN) :: ftol
	REAL(SP), DIMENSION(3), INTENT(INOUT) :: y
	REAL(SP), DIMENSION(3,2), INTENT(INOUT) :: p
	REAL(SP), DIMENSION(5), INTENT(IN) :: stateholder
	INTERFACE
		FUNCTION valfuncadjust(x,stateholder)
		USE nrtype
		IMPLICIT NONE
		REAL(SP), DIMENSION(2), INTENT(IN) :: x
		REAL(8), DIMENSION(5), INTENT(IN) :: stateholder
		REAL(SP) :: valfuncadjust
		END FUNCTION valfuncadjust
	END INTERFACE
	INTEGER(I4B), PARAMETER :: ITMAX=1000000
	REAL(SP), PARAMETER :: TINY=1.0e-10
	INTEGER(I4B) :: ihi,ndim
	REAL(SP), DIMENSION(size(p,2)) :: psum
	call amoeba_private
	CONTAINS
!BL
	SUBROUTINE amoeba_private
	IMPLICIT NONE
	INTEGER(I4B) :: i,ilo,inhi
	REAL(SP) :: rtol,ysave,ytry,ytmp
	ndim=assert_eq(size(p,2),size(p,1)-1,size(y)-1,'amoeba')
	iter=0
	psum(:)=sum(p(:,:),dim=1)
	
	!write(*,*) "11",stateholder
	do
		ilo=iminloc(y(:))
		ihi=imaxloc(y(:))
		ytmp=y(ihi)
		y(ihi)=y(ilo)
		inhi=imaxloc(y(:))
		y(ihi)=ytmp
		
		!write(*,*) y(ihi), y(ilo)
		
		rtol=2.0_sp*abs(y(ihi)-y(ilo))/(abs(y(ihi))+abs(y(ilo))+TINY)
		if (rtol < ftol) then
			call swap(y(1),y(ilo))
			call swap(p(1,:),p(ilo,:))
			RETURN
		end if
		if (iter >= ITMAX) call nrerror('ITMAX exceeded in amoeba')
		
		!write(*,*) "2",stateholder
		
		ytry=amotry(-1.0_sp,stateholder)
		iter=iter+1
		if (ytry <= y(ilo)) then
		
		!write(*,*) stateholder
		
			ytry=amotry(2.0_sp,stateholder)
			iter=iter+1
		else if (ytry >= y(inhi)) then
			ysave=y(ihi)
			
			!write(*,*) "3", stateholder
			
			ytry=amotry(0.5_sp,stateholder)
			iter=iter+1
			if (ytry >= ysave) then
				p(:,:)=0.5_sp*(p(:,:)+spread(p(ilo,:),1,size(p,1)))
				do i=1,ndim+1
				
				!write(*,*) "4", stateholder
				
					if (i /= ilo) y(i)=valfuncadjust(p(i,:),stateholder)
					!write(*,*) y(i)
				end do
				iter=iter+ndim
				psum(:)=sum(p(:,:),dim=1)
			end if
		end if
	end do
	END SUBROUTINE amoeba_private
!BL
	FUNCTION amotry(fac,stateholder)
	IMPLICIT NONE
	REAL(SP), INTENT(IN) :: fac
	REAL(SP) :: amotry
	REAL(SP) :: fac1,fac2,ytry
	REAL(8), DIMENSION(5) :: stateholder
	REAL(SP), DIMENSION(size(p,2)) :: ptry
	fac1=(1.0_sp-fac)/ndim
	fac2=fac1-fac
	ptry(:)=psum(:)*fac1-p(ihi,:)*fac2
	!write(*,*) "private", stateholder
	ytry=valfuncadjust(ptry,stateholder)
	!write(*,*) "done?"
	if (ytry < y(ihi)) then
		y(ihi)=ytry
		psum(:)=psum(:)-p(ihi,:)+ptry(:)
		p(ihi,:)=ptry(:)
	end if
	amotry=ytry
	END FUNCTION amotry
END SUBROUTINE amoeba
	




FUNCTION brentnew(ax,bx,cx,value,tol,aholder,Dholder,zholder,epsholder,epsholderold,tholder,xmin)
USE nrtype; USE nrutil, ONLY : nrerror
USE share
IMPLICIT NONE
REAL(SP), INTENT(IN) :: ax,bx,cx,tol,aholder,Dholder,zholder,epsholder,tholder,epsholderold
REAL(SP), INTENT(OUT) :: xmin
REAL(SP) :: brentnew
EXTERNAL :: value
REAL(SP) :: value



INTEGER(I4B), PARAMETER :: ITMAX=300
REAL(SP), PARAMETER :: CGOLD=0.3819660_sp,ZEPS=1.0e-3_sp*epsilon(ax)
INTEGER(I4B) :: iter
REAL(SP) :: a,b,d,e,etemp,fu,fv,fw,fx,p,q,r2,tol1,tol2,u,v,w,x,xm
a=min(ax,cx)
b=max(ax,cx)
v=bx
w=v
x=v
e=0.0
fx=value(x,aholder,Dholder,zholder,epsholder,epsholderold,tholder)
fv=fx
fw=fx
do iter=1,ITMAX
    xm=0.5_sp*(a+b)
    tol1=tol*abs(x)+ZEPS
    tol2=2.0_sp*tol1
    if (abs(x-xm) <= (tol2-0.5_sp*(b-a))) then
        xmin=x
        brentnew=fx
        RETURN
    end if
    if (abs(e) > tol1) then
        r2=(x-w)*(fx-fv)
        q=(x-v)*(fx-fw)
        p=(x-v)*q-(x-w)*r2
        q=2.0_sp*(q-r2)
        if (q > 0.0) p=-p
        q=abs(q)
        etemp=e
        e=d
        if (abs(p) >= abs(0.5_sp*q*etemp) .or. &
            p <= q*(a-x) .or. p >= q*(b-x)) then
            e=merge(a-x,b-x, x >= xm )
            d=CGOLD*e
        else
            d=p/q
            u=x+d
            if (u-a < tol2 .or. b-u < tol2) d=sign(tol1,xm-x)
        end if
    else
        e=merge(a-x,b-x, x >= xm )
        d=CGOLD*e
    end if
    u=merge(x+d,x+sign(tol1,d), abs(d) >= tol1 )
    fu=value(u,aholder,Dholder,zholder,epsholder,epsholderold,tholder)
    if (fu <= fx) then
        if (u >= x) then
            a=x
        else
            b=x
        end if
        call shft(v,w,x,u)
        call shft(fv,fw,fx,fu)
    else
        if (u < x) then
            a=u
        else
            b=u
        end if
        if (fu <= fw .or. w == x) then
            v=w
            fv=fw
            w=u
            fw=fu
        else if (fu <= fv .or. v == x .or. v == w) then
            v=u
            fv=fu
        end if
    end if
end do

call nrerror('brentnew: exceed maximum iterations')
CONTAINS
!BL
SUBROUTINE shft(a,b,c,d)
REAL(SP), INTENT(OUT) :: a
REAL(SP), INTENT(INOUT) :: b,c
REAL(SP), INTENT(IN) :: d
a=b
b=c
c=d
END SUBROUTINE shft
END FUNCTION brentnew




FUNCTION brentmindist(ax,bx,cx,value,aftertax,tol,xmin)
USE nrtype; USE nrutil, ONLY : nrerror
USE share
IMPLICIT NONE
REAL(SP), INTENT(IN) :: ax,bx,cx,tol
REAL(8), DIMENSION(numhouseholds) :: aftertax
REAL(SP), INTENT(OUT) :: xmin
REAL(SP) :: brentmindist
EXTERNAL :: value
REAL(SP) :: value



INTEGER(I4B), PARAMETER :: ITMAX=200
REAL(SP), PARAMETER :: CGOLD=0.3819660_sp,ZEPS=1.0e-3_sp*epsilon(ax)
INTEGER(I4B) :: iter
REAL(SP) :: a,b,d,e,etemp,fu,fv,fw,fx,p,q,r2,tol1,tol2,u,v,w,x,xm
a=min(ax,cx)
b=max(ax,cx)
v=bx
w=v
x=v
e=0.0
fx=value(x,aftertax)
fv=fx
fw=fx
do iter=1,ITMAX
    xm=0.5_sp*(a+b)
    tol1=tol*abs(x)+ZEPS
    tol2=2.0_sp*tol1
    if (abs(x-xm) <= (tol2-0.5_sp*(b-a))) then
        xmin=x
        brentmindist=fx
        RETURN
    end if
    if (abs(e) > tol1) then
        r2=(x-w)*(fx-fv)
        q=(x-v)*(fx-fw)
        p=(x-v)*q-(x-w)*r2
        q=2.0_sp*(q-r2)
        if (q > 0.0) p=-p
        q=abs(q)
        etemp=e
        e=d
        if (abs(p) >= abs(0.5_sp*q*etemp) .or. &
            p <= q*(a-x) .or. p >= q*(b-x)) then
            e=merge(a-x,b-x, x >= xm )
            d=CGOLD*e
        else
            d=p/q
            u=x+d
            if (u-a < tol2 .or. b-u < tol2) d=sign(tol1,xm-x)
        end if
    else
        e=merge(a-x,b-x, x >= xm )
        d=CGOLD*e
    end if
    u=merge(x+d,x+sign(tol1,d), abs(d) >= tol1 )
    fu=value(u,aftertax)
    if (fu <= fx) then
        if (u >= x) then
            a=x
        else
            b=x
        end if
        call shft(v,w,x,u)
        call shft(fv,fw,fx,fu)
    else
        if (u < x) then
            a=u
        else
            b=u
        end if
        if (fu <= fw .or. w == x) then
            v=w
            fv=fw
            w=u
            fw=fu
        else if (fu <= fv .or. v == x .or. v == w) then
            v=u
            fv=fu
        end if
    end if
end do
call nrerror('brentnew: exceed maximum iterations')
CONTAINS
!BL
SUBROUTINE shft(a,b,c,d)
REAL(SP), INTENT(OUT) :: a
REAL(SP), INTENT(INOUT) :: b,c
REAL(SP), INTENT(IN) :: d
a=b
b=c
c=d
END SUBROUTINE shft
END FUNCTION brentmindist





   REAL(8) FUNCTION cdfnormal (x)
!
!*******************************************************************************
!
!! cdfnormal evaluates the Normal 01 CDF.
!
!
!  Reference: 
!
!    A G Adams,
!    Areas Under the Normal Curve,
!    Algorithm 39, 
!    Computer j., 
!    Volume 12, pages 197-198, 1969.
!
!  Modified:
!
!    10 February 1999
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, real X, the argument of the CDF.
!
!    Output, real CDF, the value of the CDF.
!
  implicit none
!
  real, parameter :: a1 = 0.398942280444E+00
  real, parameter :: a2 = 0.399903438504E+00
  real, parameter :: a3 = 5.75885480458E+00
  real, parameter :: a4 = 29.8213557808E+00
  real, parameter :: a5 = 2.6813121679E+00
  real, parameter :: a6 = 48.6959930692E+00
  real, parameter :: a7 = 5.92885724438E+00
  real, parameter :: b0 = 0.398942280385E+00
  real, parameter :: b1 = 3.8052E-08
  real, parameter :: b2 = 1.00000615302E+00
  real, parameter :: b3 = 3.98064794E-04
  real, parameter :: b4 = 1.98615381364E+00
  real, parameter :: b5 = 0.151679116635E+00
  real, parameter :: b6 = 5.29330324926E+00
  real, parameter :: b7 = 4.8385912808E+00
  real, parameter :: b8 = 15.1508972451E+00
  real, parameter :: b9 = 0.742380924027E+00
  real, parameter :: b10 = 30.789933034E+00
  real, parameter :: b11 = 3.99019417011E+00
  !real cdfnormal
  real q
  real(8), intent(in) :: x
  real y
!
!  |X| <= 1.28.
!

  if ( abs ( x ) <= 1.28 ) then

    y = 0.5E+00 * x**2

    q = 0.5E+00 - abs ( x ) * ( a1 - a2 * y / ( y + a3 - a4 / ( y + a5 &
      + a6 / ( y + a7 ) ) ) )

!
!  1.28 < |X| <= 12.7
!
  else if ( abs ( x ) <= 12.7E+00 ) then

    y = 0.5E+00 * x**2

    q = exp ( - y ) * b0 / ( abs ( x ) - b1 &
      + b2 / ( abs ( x ) + b3 &
      + b4 / ( abs ( x ) - b5 &
      + b6 / ( abs ( x ) + b7 &
      - b8 / ( abs ( x ) + b9 &
      + b10 / ( abs ( x ) + b11 ) ) ) ) ) )
!
!  12.7 < |X|
!
  else

    q = 0.0E+00

  end if
!
!  Take account of negative X.
!
  if ( x < 0.0E+00 ) then
    cdfnormal = q
  else
    cdfnormal = 1.0E+00 - q
  end if

  return
end
