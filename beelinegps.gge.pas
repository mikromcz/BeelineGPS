{ geoget 2
  mod by mikrom
  
  v1.0, 20090427, upraveny informace waypointu, nyní nadm. výška, hodnocení, hint..
  v1.1, 20090609, pridava nadmorskou vysku a poznamku do listingu
  v1.2, 20090611, opraveno poznámka -> poznamka
  v1.3, 20090615, exportuje se max 5 logu ke kazdy kesi
  v1.4, 20090616, upravena poznamka, ze umi novy radek, zobrazi se jen kdyz existuje a tak..
  v1.5, 20101004, upraveno do balicku GIP
  v1.5.1, 20101114, par nastaveni v configu
 
  mod Arne1
   20100316  odlisna ikona pro nalezenou finalovku
   20101025  prehozeno generovani waypointu a kese kvuli prekryvu ikon na mape
   20101124  upraveno dle 1.5.1

  ToDo:
  - My Cache...
}

{$INCLUDE beelinegps.config.pas}

function ExportExtension: string;
begin
  result := 'GPX';
end;

function ExportDescription: string;
begin
  result := 'GPX pro BeeLineGPS';
end;

function ExportHeader: string;
begin
  Result := '<?xml version="1.0" encoding="utf-8" ?>' + CRLF;
  Result := Result + '<gpx' + CRLF;
  Result := Result + ' creator="GeoGet ' + Geoget_Version + ' - http://geoget.ararat.cz"' + CRLF;
  Result := Result + ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + CRLF;
  Result := Result + ' version="1.0"' + CRLF;
  Result := Result + ' xsi:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd">' + CRLF;
  Result := Result + ' <desc>GPX Waypoint File Generated with GeoGet ' + Geoget_Version + '</desc>' + CRLF;
  Result := Result + ' <author>GeoGet ' + Geoget_Version + '</author>' + CRLF;
  Result := Result + ' <time>' + formatdatetime('yyyy"-"mm"-"dd"T"hh":"nn":"ss"."zzz', now) + '</time>' + CRLF;
  //Result := Result + ' <bounds minlat="33.795986" minlon="-117.806280" maxlat="33.805216" maxlon="-117.792993"/>' + CRLF + CRLF;
  Result := Result + CRLF;
end;

function ExportFooter: string;
begin
  result := '</gpx>' + CRLF;
end;


Procedure Waypointy(var resultw:string; hint:string);
var
  n: integer;
begin
  for n := 0 to GC.Waypoints.Count - 1 do
    if GC.Waypoints[n].IsListed then
    begin
      Resultw := Resultw + ' <wpt lat="' + GC.Waypoints[n].Lat + '" lon="' + GC.Waypoints[n].Lon + '">' + CRLF;
      Resultw := Resultw + '  <time>' + formatdatetime('yyyy"-"mm"-"dd"T"hh":"nn":"ss"."zzz', GC.Hidden) + '</time>' + CRLF;
      Resultw := Resultw + '  <name>' + cdata(UtfToAscii(GC.Waypoints[n].Name + ' (' + GC.Name)) + ')</name>' + CRLF;
      Resultw := Resultw + '  <cmt>' + cdata(UtfToAscii(GC.Waypoints[n].Description)) +'</cmt>' + CRLF;
      if GC.Waypoints[n].IsFinal then
        Resultw := Resultw + '  <desc>' + cdata(UtfToAscii(GC.ID + hint)) +'</desc>' + CRLF
      else
        Resultw := Resultw + '  <desc>' + cdata(UtfToAscii(GC.ID)) +'</desc>' + CRLF;
      Resultw := Resultw + '  <url>' + cdata(GC.Waypoints[n].URL) +'</url>' + CRLF;
      Resultw := Resultw + '  <urlname>' + cdata(GC.Waypoints[n].Name) + '</urlname>' + CRLF;
      if GC.Waypoints[n].IsFinal then
      begin
        if GC.IsFound then
          // Lze pouzit nasledujici ikony:
          // Airport, Beach, Bridge, Boat Ramp, Car, Cemetery, Danger Area, Fishing Area, Gas Station, Golf Course, Information, Lighthouse,
          // Marina, Mine, Museum, Parachute Area, Park, Picnic Area, Post Office, Restroom, Shopping Center, Stadium, Summit
          Resultw := Resultw + '  <sym>Golf Course</sym>' + CRLF
        else
          Resultw := Resultw + '  <sym>Final Location</sym>' + CRLF
      end
      else
        Resultw := Resultw + '  <sym>' + GC.Waypoints[n].WptType + '</sym>' + CRLF;
      Resultw := Resultw + '  <type>Waypoint|' + GC.Waypoints[n].WptType + '</type>' + CRLF;
      Resultw := Resultw + ' </wpt>' + CRLF + CRLF;
    end;
end;

function ExportPoint: string;
var
  s, hodnoceni, hint, vyska, ele, poznamka, cachetype: string;
  n, GCLogsCount: integer;

begin
  Result := '';
  //Export for Geocaches
  if GC.IsListed then
  begin
    // nadmorska vyska
    ele := GC.TagValues('Elevation');
    if ele <> '' then vyska := ', ' + ele + 'm n.m.'
    else vyska := ', ';
    
    // hodnoceni
    if GC.TagValues('Hodnoceni') <> '' then hodnoceni := ', Hodnoceni: ' + GC.TagValues('Hodnoceni');

    // hint
    if GC.Hint <> '' then hint := ', Hint: ' + GC.Hint
    else hint := ', Hint: -';

    // Export for Waypoints
    // waypointy pred cache - to ma smysl, pokud maji stejne souradnice v puvodni verzi byla kes prekryta waypointem
    // - typicky parking - a nebylo jasne, ze zrovna tak nejaka kes je.
    // Zde se napred vygeneruji waypointy a ty jsou pak na mape pripadne prekryty ikonou kese.
    if ExportWaypoints = '1' then Waypointy(result, hint);

    // Export for cache
    Result := Result + ' <wpt lat="' + GC.Lat + '" lon="' + GC.Lon + '">' + CRLF;
    Result := Result + '  <ele>' + ele + '</ele>' + CRLF;
    Result := Result + '  <time>' + formatdatetime('yyyy"-"mm"-"dd"T"hh":"nn":"ss"."zzz', GC.Hidden) + '</time>' + CRLF;
    //Result := Result + '  <name>' + cdata(UtfToAscii(GC.Name) + ' od ' + GC.Author) + '</name>' + CRLF;
    Result := Result + '  <name>' + cdata(UtfToAscii(GC.Name)                     ) + '</name>' + CRLF;
    Result := Result + '  <desc>' + cdata(GC.ID + ', ' + GC.IDTag + ', O:' + GC.Difficulty + ', T:' + GC.Terrain + vyska + hodnoceni + hint) +'</desc>' + CRLF;
    Result := Result + '  <url>' + cdata(GC.URL) +'</url>' + CRLF;
    Result := Result + '  <urlname>' + cdata(UtfToAscii(GC.Name + ' by ' + GC.Author)) + '</urlname>' + CRLF;
    
{   //<sym><![CDATA[Geocache-ToDo]]></sym>
    //<sym><![CDATA[Geocache-Bonus]]></sym>
    //<sym><![CDATA[Geocache-Milestone]]></sym>
    //<sym><![CDATA[Geocache-New and Not Found]]></sym>
    //<sym><![CDATA[Geocache-Attemted]]></sym>
    //<sym><![CDATA[Geocache-Future Cache]]></sym>
    //<sym><![CDATA[Geocache-Mystery]]></sym>
    //<sym><![CDATA[Geocache-Needs Maintenance]]></sym>
    //<sym><![CDATA[Geocache-Found and Logged]]></sym>
    if GC.IsFound then cachetype := ' Found'            //<sym><![CDATA[Geocache-Found]]></sym>
    else if GC.IsOwner then cachetype := '-My Cache'    //<sym><![CDATA[Geocache-My Cache]]></sym>
    else if GC.IsArchived then cachetype := '-Archived' //<sym><![CDATA[Geocache-Archived]]></sym>
    else if GC.TagHaveCategory('FTF') and (GC.TagValues('FTF') = 'FTF') then cachetype := '-First to Find' //<sym><![CDATA[Geocache-First to Find]]></sym>
    else
      case GC.Type of
      //'C' : cachetype := '-';
        'U' : cachetype := '-Unknown';    //<sym><![CDATA[Geocache-Unknown]]></sym>
        'M' : cachetype := '-Multi';      //<sym><![CDATA[Geocache-Multi]]></sym>
        'G' : cachetype := '-Earthcache'; //<sym><![CDATA[Geocache-Earthcache]]></sym>
        'H' : cachetype := '-Letterbox';  //<sym><![CDATA[Geocache-Letterbox]]></sym>
        'V' : cachetype := '-Virtual';    //<sym><![CDATA[Geocache-Virtual]]></sym>
      end;
    else cachetype := '';
    Result := Result + '  <sym>Geocache' + cachetype + '</sym>' + CRLF; //<sym><![CDATA[Geocache]]></sym>}

    Result := Result + '  <sym>Geocache</sym>' + CRLF;
    Result := Result + '  <type>Geocache|' + GC.CacheType + '</type>' + CRLF;

    // disablovana, nebo archivovana
    if GC.IsDisabled then s := 'available="False"'
    else s := 'available="True"';
    if GC.IsArchived then s := s + ' archived="True"'
    else s := s + ' archived="False"';
    s := 'id="' + GC.CacheID +'" ' + s;

    Result := Result + '  <groundspeak:cache ' + s + ' xmlns:groundspeak="http://www.groundspeak.com/cache/1/0">' + CRLF;
    Result := Result + '   <groundspeak:name>' + cdata(UtfToAscii(GC.Name)) + '</groundspeak:name>' + CRLF;
    Result := Result + '   <groundspeak:placed_by>' + cdata(UtfToAscii(GC.Author)) +'</groundspeak:placed_by>' + CRLF;
    if GC.OwnerID <> '' then Result := Result + '   <groundspeak:owner id="' + GC.OwnerID + '">' + cdata(UtfToAscii(GC.Author)) +'</groundspeak:owner>' + CRLF;
    Result := Result + '   <groundspeak:type>' + GC.CacheType +'</groundspeak:type>' + CRLF;
    Result := Result + '   <groundspeak:container>' + GC.Size +'</groundspeak:container>' + CRLF;
    Result := Result + '   <groundspeak:difficulty>' + GC.Difficulty +'</groundspeak:difficulty>' + CRLF;
    Result := Result + '   <groundspeak:terrain>' + GC.Terrain +'</groundspeak:terrain>' + CRLF;
    Result := Result + '   <groundspeak:country>' + GC.Country +'</groundspeak:country>' + CRLF;
    Result := Result + '   <groundspeak:state>' + GC.State +'</groundspeak:state>' + CRLF;

    //Export poznamky
    if ExportComment = '1' then
    begin
      if GC.Comment <> '' then poznamka := '<table border="0" id="table1" width="100%" bgcolor="#E1E1FF"><tr><td><font face="Verdana" size="2"><b>Poznamka:</b><br><i>' + ReplaceString(GC.Comment, CRLF, '<br>') + '</i></font></td></tr></table><br>' + CRLF;
      Result := Result + '   <groundspeak:short_description html="True">' + cdata(poznamka + GC.ShortDescription) +'</groundspeak:short_description>' + CRLF;
    end
    else
      Result := Result + '   <groundspeak:short_description html="True">' + cdata(GC.ShortDescription) +'</groundspeak:short_description>' + CRLF;

    //Export listingu
    if ExportListing = '1' then
      Result := Result + '   <groundspeak:long_description html="True">' + cdata(GC.LongDescription) +'</groundspeak:long_description>' + CRLF;

    //Export hintu
    Result := Result + '   <groundspeak:encoded_hints>' + cdata(GC.Hint) +'</groundspeak:encoded_hints>' + CRLF;

    //Export logu
    if StrToInt(ExportLogs) > 0 then
    begin
      Result := Result + '   <groundspeak:logs>' + CRLF;
      //max. pocet logu
      if GC.Logs.Count > StrToInt(ExportLogs) then GCLogsCount := StrToInt(ExportLogs)
      else GCLogsCount := Gc.Logs.Count;
      for n := 0 to GCLogsCount - 1 do
      begin
        Result := Result + '    <groundspeak:log id="' + GC.Logs[n].LogID + '">' + CRLF;
        Result := Result + '     <groundspeak:date>' + formatdatetime('yyyy"-"mm"-"dd"T"hh":"nn":"ss"."zzz', GC.Logs[n].Date) + '</groundspeak:date>' + CRLF;
        Result := Result + '     <groundspeak:type>' + GC.Logs[n].LogType + '</groundspeak:type>' + CRLF;
        s := '';
        if GC.Logs[n].FinderID <> '' then s := ' id="' + GC.Logs[n].FinderID + '"';
        Result := Result + '     <groundspeak:finder' + s + '>' + cdata(GC.Logs[n].Finder) + '</groundspeak:finder>' + CRLF;
        Result := Result + '     <groundspeak:text encoded="False">' + cdata(GC.Logs[n].Text) + '</groundspeak:text>' + CRLF;
        Result := Result + '    </groundspeak:log>' + CRLF;
      end;
      Result := Result + '   </groundspeak:logs>' + CRLF;
    end;

    Result := Result + '  </groundspeak:cache>' + CRLF;
    Result := Result + ' </wpt>' + CRLF + CRLF;

    // Export for Waypoints
    // waypointy za cache, ikona kese muze byt prekryta ikonou waypointu
    if ExportWaypoints = '2' then Waypointy(result, hint);
    
  end;
end;
