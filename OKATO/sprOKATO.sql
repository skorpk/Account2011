select '<xs:enumeration value="'+ter+kod1+'"/>',ter+kod1,kod2,kod3,namel,centrum
from oms_nsi.dbo.sprOKATO
where kod1='000' and kod2='000' and kod3='000' and ter!='00' 
order by ter