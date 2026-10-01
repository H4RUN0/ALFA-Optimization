Sets
    i /N1*N5/
    j /mobile, fixed, printer/
    k /basic, pro, ent/;

Parameters
    flow(i) /N1 20000, N2 15000, N3 5000, N4 10000, N5 8000/
    cap(i,j) /N1.mobile 6000, N1.fixed 12000, N1.printer 0
              N2.mobile 6000, N2.fixed 12000, N2.printer 0
              N3.mobile 4000, N3.fixed 8000,   N3.printer 0
              N4.mobile 5000, N4.fixed 10000,  N4.printer 0
              N5.mobile 5000, N5.fixed 9000,   N5.printer 0/
    cost_unit(j) /mobile 15000, fixed 20000, printer 8000/
    maint_unit(j) /mobile 2000, fixed 2500, printer 800/
    acc(j) /mobile 0.98, fixed 0.995, printer 1.0/
    sw_cost(k) /basic 20000, pro 50000, ent 90000/
    swBenefitFactor(k) /basic 1.0, pro 1.2, ent 1.5/
    time_saved_per_scan /5/
    wage_per_hour /200/
    error_cost_per_miss /50/
    error_reduction_by_device /0.9/
    Budget /300000/
    Acc_min /0.98/;

Parameter minCapFlow(i,j);
loop((i,j), minCapFlow(i,j) = min(cap(i,j), flow(i)));

Scalar ep /1e-6/;

Variables
    x(i,j)
    y(k)
    TotalBenefit
    TotalCost
    ROI;

Positive Variable x;
Positive Variable y;

Equations
    CostDef
    BenefitDef
    BudgetCon
    CapacityCon(i)
    AccCon
    SWSelect
    ROIObj;

CostDef.. 
    TotalCost =e= sum((i,j), (cost_unit(j)+maint_unit(j))*x(i,j)) 
              + sum(k, sw_cost(k)*y(k));

BenefitDef..
    TotalBenefit =e= sum(k, swBenefitFactor(k)*y(k)) *
        (time_saved_per_scan*wage_per_hour*sum((i,j), minCapFlow(i,j)*x(i,j))
         + error_cost_per_miss*error_reduction_by_device*sum((i,j), cap(i,j)*x(i,j)));

BudgetCon.. TotalCost =l= Budget;

CapacityCon(i).. sum(j, cap(i,j)*x(i,j)) =g= flow(i);

AccCon.. sum(j, acc(j)*sum(i, cap(i,j)*x(i,j))) =g= Acc_min * sum((i,j), cap(i,j)*x(i,j));

SWSelect.. sum(k, y(k)) =e= 1;

ROIObj.. ROI =e= TotalBenefit / (TotalCost + ep);

Model barcodeROI /all/;

Solve barcodeROI maximizing ROI using nlp;

Display x.l, y.l, TotalBenefit.l, TotalCost.l, ROI.l;
