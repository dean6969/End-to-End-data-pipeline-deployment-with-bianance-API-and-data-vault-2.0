select TIME_OF_DAY_HH24 as "_KEY_TIME",*
from  {{ ref('RAW__REF_Time') }}