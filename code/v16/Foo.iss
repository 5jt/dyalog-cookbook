#define MyAppVersion "1.0.0"
#define MyAppName "Foo"
#define MyAppExeName "Foo.exe"
#define MyAppPublisher "My Company Ltd"
#define MyAppURL "http://MyCompanyLtd.com/Foo"
#define MyAppIcoName "Foo.ico"
#define MyBlank " "

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; It's a 36-character long vector called a UUID or GUID. 
AppId={{E0DF5CAB-97E5-4935-A2ED-A7D43DD958D9} 

AppName="{#MyAppName}"
AppVersion={#MyAppVersion}
AppVerName={#MyAppName}{#MyBlank}{#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf32}\{#MyAppPublisher}\{#MyAppName}
DefaultGroupName={#MyAppPublisher}\{#MyAppName}
AllowNoIcons=yes
OutputDir=ReadyToShip\Foo
OutputBaseFilename="SetUp_{#MyAppName}"
Compression=lzma
SolidCompression=yes
SetupIconFile={#MyAppIcoName}
UninstallDisplayIcon={app}\{#MyAppIcoName}


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"; \
  LicenseFile: "License.txt"; \
  InfoBeforeFile: "ReadMe_Before.txt"; \
  InfoAfterFile: "ReadMe_After.txt";


[Registry]
Root: HKLM32; Subkey: "Software\{#MyAppPublisher}"; Flags: uninsdeletekeyifempty
Root: HKLM32; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}"; Flags: uninsdeletekey
Root: HKLM32; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}"; \
ValueType: string; ValueName: "RecentFiles"; ValueData: ""; Flags: uninsdeletekey

[Dirs]
Name: "{commonappdata}\{#MyAppPublisher}\{#MyAppName}"; Permissions: users-modify

[Files]
Source: "ReadMe_late.html"; DestDir: "{app}";
Source: "Foo.ico"; DestDir: "{app}";
;Source: "bridge160_unicode.dll"; DestDir: "{app}";
;Source: "dyalognet.dll"; DestDir: "{app}";
Source: "{#MyAppExeName}"; DestDir: "{app}";
Source: "foo.ini.remove_me"; DestDir: "{app}"; DestName:"foo.ini"; Flags: onlyifdoesntexist;
Source: {#MyAppIcoName}; DestDir: "{app}";
Source: "C:\Windows\Fonts\apl385.ttf"; DestDir: "{fonts}"; FontInstall: "APL385 Unicode"; Flags: onlyifdoesntexist uninsneveruninstall
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

; ----------- For Ride: ---------------
;Source: "Conga*.dll"; DestDir: "{app}";
; -------------------------------------

[Icons]
Name: "{group}\Start Foo"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}\";  IconFilename: "{app}\{#MyAppIcoName}" 
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppIcoName}"; Tasks: desktopicon

[Run]
Filename: "{app}\ReadMe.html"; Description: "View the README file"; Flags: postinstall shellexec skipifsilent
Filename: "{app}\{#MyAppExeName}"; Description: "Launch Foo"; Flags: postinstall skipifsilent nowait


[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";

[Code]