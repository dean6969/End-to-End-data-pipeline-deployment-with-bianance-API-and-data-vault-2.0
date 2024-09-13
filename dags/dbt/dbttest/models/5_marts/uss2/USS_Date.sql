select A.DATE_DAY as "_KEY_DATE",*
from  {{ ref('RAW__REF_Date') }} A