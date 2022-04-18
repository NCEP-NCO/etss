!-------------------------------------------------------------------------------
!c   Haversine formula to calculate distance :    
!c   a = sin²(delta_f/2) + cos(f1).cos(f2).sin²(delta_e/2)
!c   c = 2.atan2(va, v(1-a))
!c   d = R.c
!c   where f is latitude, e is longitude, R is earth<92>s radius (mean radius = 6,371km)
!c   note that angles need to be converted from Degree to radians!
!c   Authors:
!c       Huiqing.Liu /MDL (AceInfo)    
!c           
!c    History:
!c       08/2017--Huiqing.Liu Created the routine
!c-------------------------------------------------------------------------------       
       real function distance(lat11,lat12,lon1,lon2)
       implicit none
       integer,parameter:: R = 6371 ! Earth Radius (Km)
       real,parameter:: Pi=3.141592653589793
       real ::lat1,lat2,lon1,lon2,dLat,dLon,a,c,d,lat11,lat12

       dLat = (lat12-lat11)*Pi/180.
       dLon = (lon2-lon1)*Pi/180.
       lat1 = lat11*Pi/180.
       lat2 = lat12*Pi/180.

       a = sin(dLat/2)*sin(dLat/2)+sin(dLon/2)*sin(dLon/2)*
     $     cos(lat1)*cos(lat2) 
       c = 2*atan2(sqrt(a),sqrt(1-a))
       d = R * c
       distance = d
       return
       end


