flights = LOAD '/input/flights.csv' USING PigStorage(',') AS
(Year:int, Month:int, DayOfMonth:int, DayOfWeek:int, DepTime:int, CRSDepTime:int,
 ArrTime:int, CRSArrTime:int, UniqueCarrier:chararray, FlightNum:int, TailNum:chararray,
 ActualElapsedTime:int, CRSElapsedTime:int, AirTime:int, ArrDelay:int, DepDelay:int,
 Origin:chararray, Dest:chararray, Distance:int, TaxiIn:int, TaxiOut:int, Cancelled:int,
 CancellationCode:chararray, Diverted:int, CarrierDelay:int, WeatherDelay:int,
 NASDelay:int, SecurityDelay:int, LateAircraftDelay:int);


-- Top 20 aéroports par volume
grp_origin = GROUP flights BY Origin;
grp_dest = GROUP flights BY Dest;
count_origin = FOREACH grp_origin GENERATE group AS airport, COUNT(flights) AS nb_vols_out;
count_dest = FOREACH grp_dest GENERATE group AS airport, COUNT(flights) AS nb_vols_in;
-- Join et calcul total vols
airport_total = JOIN count_origin BY airport, count_dest BY airport;
airport_total = FOREACH airport_total GENERATE count_origin::airport AS airport, nb_vols_out, nb_vols_in, (nb_vols_out + nb_vols_in) AS total_vols;
top20_airports = ORDER airport_total BY total_vols DESC;
top20_airports_limited = LIMIT top20_airports 20;
STORE top20_airports_limited INTO '/pigout/top20_airports';

-- Popularité transporteurs
grp_carrier_year = GROUP flights BY (UniqueCarrier, Year);
carrier_volume = FOREACH grp_carrier_year GENERATE group.UniqueCarrier AS carrier, group.Year AS year, COUNT(flights) AS nb_vols;
-- Pour log10:
carrier_volume_log = FOREACH carrier_volume GENERATE carrier, year, (double)LOG10(nb_vols) AS log_volume;
STORE carrier_volume_log INTO '/pigout/carrier_volume_log';

-- Proportion de vols retardés (>15min)
delayed = FILTER flights BY ArrDelay > 15;
grp_delayed_year = GROUP delayed BY Year;
grp_total_year = GROUP flights BY Year;
delay_ratio = FOREACH grp_total_year {
    d = FILTER delayed BY Year == group;
    GENERATE group AS year, (double)COUNT(d)/COUNT(flights) AS ratio_retard;
};
STORE delay_ratio INTO '/pigout/delay_ratio';

-- Itinéraires les plus fréquentés
routes = FOREACH flights GENERATE Origin, Dest;
grp_routes = GROUP routes BY (Origin, Dest);
route_count = FOREACH grp_routes GENERATE group.Origin AS origin, group.Dest AS dest, COUNT(routes) AS nb_vols;
top_routes = ORDER route_count BY nb_vols DESC;
STORE top_routes INTO '/pigout/top_routes';
