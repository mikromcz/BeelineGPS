//Installation script for GIP packages

function InstallWork: string;
begin
  // Do install tasks here.

  {uklid po starsich verzich}
  if FileExists(GEOGET_DATADIR+'\gpxBeeline.gge.pas') then DeleteFile(GEOGET_DATADIR+'\gpxBeeline.gge.pas');
  if FileExists(GEOGET_SCRIPTDIR+'\gpxBeeline.gge.pas') then DeleteFile(GEOGET_SCRIPTDIR+'\gpxBeeline.gge.pas');
  if FileExists(GEOGET_SCRIPTDIR+'\export\gpxBeeline.gge.pas') then DeleteFile(GEOGET_SCRIPTDIR+'\export\gpxBeeline.gge.pas');

  {changelog}
  if FileExists(GEOGET_SCRIPTDIR + '\BeelineGPS\BeelineGPS.changelog.txt') then ShowLongMessage('Changelog', FileToString(GEOGET_SCRIPTDIR + '\BeelineGPS\BeelineGPS.changelog.txt'));

  Result := '';  // probehlo bez chyby
end;

function UninstallWork: string;
begin
  // Do Uninstall tasks here.
end;
