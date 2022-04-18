ALWAYS, ALWAYS have a backup of master.csv!

This concerns master.csv, what each column stants for, and how to edit it.

The columns are ordered like so:

STATION NAME, COOPS ID, NWSLI, LAT, LON, HAT, MHHW, MSL, 
MLLW, OBS?, TIDE?, TIDE TYPE, REF STATION, STATUS, TIME ZONE, BASIN

So what do they mean?

STATION NAME: Name of the station. Notice spaces between words are replaced with
              '-'. This is important since FORTRAN reads this file and counts both
              spaces and commas as delimiters. Therefore, we have to get rid of 
              spaces or else FORTRAN will think each word in the station name is a
              distinct column, throwing off the entire process.
COOPS ID:     The Center for Operational Oceanographic Products and Services (COOPS)
              provides the tide constituents, obs, and stations used here (for the
              most part). If a station has a COOPS ID (and most of them do), then it
              is listed in this column as a seven-digit number. If a station doesn't
              have a COOPS ID, '0000000' is used instead. Don't attempt to use another
              type of placeholder. The surge text parsing script, getsurge.f, looks for
              '0000000' to determine which stations don't have a COOPS ID.
NWSLI:        Non-COOPS stations are identified using the National Weather Service
              Location Identifier (NWSLI). It's a five-character code that indicates
              a station's location. River forecast centers, USGS, and other organizations
              have their own stations and tide gauges not covered by COOPS. This identifier
              is used by getsurge.f to identify stations without a COOPS ID in the surge
              text product. If a station doesn't have an NWSLI (some COOPS stations don't),
              it is replaced with 'ZZZZZ'. This is another placeholder you don't want to
              change since fdebufr.f and ufdump.f (in the mybufr lib) use NWSLI to search
              for station obs in BUFR files. If a station is 'ZZZZZ', then it's not in 
              the BUFR files and doesn't have obs, so fdebufr.f and ufdump.f skip it.
LAT:          Simple, the station's latitude.
LON:          Also simple, the station's longitude (in degrees E, so -100 is 100 degrees
              west of the Prime Meridian).
HAT:          Highest astronomical tide (HAT) datum. All datums are in feet.
MHHW:         Mean higher high water (MHHW) datum.
MSL:          Mean sea level (MSL) datum.
MLLW:         Mean lower low water (MLLW) datum.
OBS?:         Boolean (0 = no; 1 = yes) on whether station has water level obs.
TIDE?:        Boolean (0 = no; 1 = yes) on whether station has tide predictions.
TIDE TYPE:    P for Primary and S for Secondary. Tide constituents are stored in
              parm/tide/constits as .csv files where each file contains the tide
              constituents for one station. So file 8454000.csv contains the tide
              constituents for station with COOPS ID 8454000 in master.csv. Primary tide
              files have 37 tide constituents from COOPS. These should be updated on
              occaision in case COOPS puts out new numbers. Secondary stations have no 
              tide constituents are are simply based on nearby primary stations which *do* 
              have constits. Secondary tide files have one row of numbers which represent 
              adjustments from the reference station.
REF STATION:  If this station is a secondary tide station (TIDE TYPE is S), then REF STATION 
              is the COOPS ID representing its reference station. If this station has no
              tides or TYPE TYPE is P, then REF STATION is set to '0000000'.
STATUS:       The website uses this column to store a station's flood status (1, 2, or 3).
              A 9 is placed in this master.csv file because it's only used by ETSS post-
              processing which doesn't care about flood status. Just leave the '9' there.
TIME ZONE:    Some stations on this list are legacy ETSurge1.0 stations using legacy tide
              constituents that are only available relative to local time, not UTC. Those 
              stations must have an offset in hours from their time zone to UTC so that the
              tides can be adjusted to UTC for standardized output. If this field has a '0',
              that means the station is not legacy; it's up-to-date. New stations have tide
              constits that are already in UTC.
BASIN:        CombineAll.f and makeSHEF.f use this field to determine which SHEF basin (based
              on our WMO headers and AWIPS IDs) a station is located in. This is how
              the output SHEF bulletins are sorted. In the future, some Pacfic (P) stations 
              may be included the the Gulf of Alaska (C) basin, so those may need to change.
              Until then, don't touch this!

If you need to add a station, simply fill in these columns in the appropriate manner and
paste it onto the end of the file. For example, a station called 'Tuckanuck Point, ME' with
COOPS ID 1234567 and NWSLI TUCP1 located at 44.4N by -68.2E with known tidal datums, obs,
and recently updated tide constituents would look like:

Tuckanuck-Point-ME,1234567,TUCP1,44.4,-68.2,15.2,14.0,12.5,10.7,1,1,P,0000000,9,0,E

Say this station was missing a COOPS ID...just replace 1234567 with 0000000. If it's missing
the NWSLI, put ZZZZZ. If the station doesn't have tides (we're only predicting surge at
that lat/lon), then put 0 for the TIDE? boolean. In the no-tides case, the station wouldn't
have datums or a reference station, so put 0,0,0,0 for the datums, 0000000 for REF STATION
and P TIDE TYPE (it's a no-tide station anyway, so tide type doesn't matter).

Once you have a complete station entry, just paste it at the end of the file. Make sure there
are no empty lines at the end of the file (FORTRAN might misinterpret these).
