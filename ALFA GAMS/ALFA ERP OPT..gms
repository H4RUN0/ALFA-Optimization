Sets
    i 'depo/okuma noktaları' /N1*N5/
    j 'cihaz türleri'        /mobile, fixed, printer/
    k 'yazılım paketleri'    /basic, pro, ent/;

Parameters
    flow(i) 'yıllık işlem (scan) sayısı'
        /N1 20000, N2 15000, N3 5000, N4 10000, N5 8000/
    cap(i,j) 'bir cihazın i noktasındaki yıllık işlem kapasitesi'
        /N1.mobile 6000, N1.fixed 12000, N1.printer 0
         N2.mobile 6000, N2.fixed 12000, N2.printer 0
         N3.mobile 4000, N3.fixed 8000,   N3.printer 0
         N4.mobile 5000, N4.fixed 10000,  N4.printer 0
         N5.mobile 5000, N5.fixed 9000,   N5.printer 0/
    cost_unit(j) 'cihaz birim maliyeti'
        /mobile 15000, fixed 20000, printer 8000/
    maint_unit(j) 'yıllık bakım maliyeti'
        /mobile 2000, fixed 2500, printer 800/
    acc(j) 'cihaz doğruluk oranı'
        /mobile 0.98, fixed 0.995, printer 1.0/
    sw_cost(k) 'yazılım paket maliyetleri'
        /basic 20000, pro 50000, ent 90000/
    swBenefitFactor(k) 'yazılım fayda katsayısı'
        /basic 1.0, pro 1.2, ent 1.5/;

Scalar
    Budget   'bütçe limiti' /300000/
    Acc_min  'minimum doğruluk' /0.98/;

Scalar
    time_saved_per_scan 'tasarruf (saniye)' /5/
    wage_per_hour       'işçilik maliyeti (TL/saat)' /200/
    error_cost_per_miss 'hata maliyeti (TL)' /50/
    error_reduction_by_device 'hata azaltma oranı' /0.9/;

Variables
    x(i,j)       'cihaz sayısı'
    y(k)         'yazılım seçimi'
    NetBenefit   'net fayda'
    TotalBenefit
    TotalCost;

Positive  Variable x;
Binary Variable y;


Equations
    CostDef
    Obj
    BenefitDef
    BudgetCon
    CapacityCon(i)
    AccCon
    SWSelect;
    
CostDef..
    TotalCost =e= sum((i,j), cost_unit(j)*x(i,j) + maint_unit(j)*x(i,j))
              + sum(k, sw_cost(k)*y(k));

Obj.. NetBenefit =e= TotalBenefit - TotalCost ;


BenefitDef..
    TotalBenefit =e=
      ( time_saved_per_scan* wage_per_hour )
      * sum((i,j), min(cap(i,j), flow(i)) * x(i,j))
      + error_cost_per_miss * error_reduction_by_device * sum((i,j), cap(i,j)*x(i,j));

BudgetCon..
    sum((i,j), cost_unit(j)*x(i,j)) + sum(k, sw_cost(k)*y(k)) =l= Budget;

CapacityCon(i)..
    sum(j, cap(i,j)*x(i,j)) =g= flow(i);

AccCon..
    sum(j, acc(j)*sum(i, cap(i,j)*x(i,j))) =g= Acc_min * sum((i,j), cap(i,j)*x(i,j));

SWSelect..
    sum(k, y(k)) =e= 1;

Model barcodeROI /all/;
option mip = cplex;
Solve barcodeROI maximizing NetBenefit using mip;
Display x.l, y.l, TotalBenefit.l, TotalCost.l, NetBenefit.l;