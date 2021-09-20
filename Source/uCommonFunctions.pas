﻿{-----------------------------------------------------------------------------
 Unit Name: uCommonFunctions
 Author:    Kiriakos Vlahos
 Date:      23-Jun-2005
 Purpose:   Functions common to many units in PyScripter
 History:
-----------------------------------------------------------------------------}

unit uCommonFunctions;

interface
Uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Diagnostics,
  System.RegularExpressionsAPI,
  System.RegularExpressionsCore,
  System.RegularExpressions,
  Vcl.Controls,
  Vcl.ComCtrls,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Dialogs,
  SynEditTypes,
  SynUnicode,
  SynEdit,
  uEditAppIntfs;

const
  UTF8BOMString : RawByteString = AnsiChar($EF) + AnsiChar($BB) + AnsiChar($BF);
  SFileExpr = '(([a-zA-Z]:)?[^\*\?="<>|:,;\+\^]+)'; // fwd slash (/) is allowed
  STracebackFilePosExpr =  '"\<?' + SFileExpr + '\>?", line (\d+)(, in ([\<\>\?\w]+))?';
  SWarningFilePosExpr = '\<?' +SFileExpr + '\>?:(\d+):';
  WideLF = WideChar(#10);
  WideNull = WideChar(#0);
  AnsiLineFeed       = AnsiChar(#10);
  AnsiCarriageReturn = AnsiChar(#13);
  AnsiCrLf           = AnsiString(#13#10);
  WordBreakString = ',.;:"�`�^!?&$@�%#~[](){}<>-=+*/\| ';

(* returns the System ImageList index of the icon of a given file *)
function GetIconIndexFromFile(const AFileName: string;
  const ASmall: boolean): integer;

(* returns long file name even for nonexisting files *)
function GetLongFileName(const APath: string): string;

(* from cStrings *)
(* checks if AText starts with ALeft *)
function StrIsLeft(AText, ALeft: PWideChar): Boolean;

(* checks if AText ends with ARight *)
function StrIsRight(AText, ARight: PChar): Boolean;

(* returns next token - based on Classes.ExtractStrings *)
function StrGetToken(var Content: PChar;
  Separators, WhiteSpace, QuoteChars: TSysCharSet): string;

(* removes quotes to AText, if needed *)
function StrUnQuote(const AText: string): string;

(* Lighten a given Color by a certain percentage *)
function LightenColor(Color:TColor; Percentage:integer):TColor;

(* Darken a given Color by a certain percentage *)
function DarkenColor(Color:TColor; Percentage:integer):TColor;

(* Get Exe File Version string *)
function ApplicationVersion : string;

(* Checks whether we are connected to the Internet *)
function ConnectedToInternet : boolean;

(* Extracts the nth line from a string *)
function GetNthLine(const S : string; LineNo : integer) : string;

(* Extracts a range of lines from a string *)
function GetLineRange(const S : string; StartLine, EndLine : integer;
  HtmlBreaks: Boolean = False) : string;

(* Extracts a word from a string *)
function GetWordAtPos(const LineText: string; Start: Integer;
  AllowDot: boolean; ScanBackwards: boolean = True; ScanForward: boolean = True;
  HandleBrackets: Boolean = False) : string;

(* Format a doc string by removing left space and blank lines at start and bottom *)
function FormatDocString(const DocString : string) : string;

(* Calculate the indentation level of a line *)
function CalcIndent(S : string; TabWidth : integer = 4): integer;

(* check if a directory is a Python Package *)
function DirIsPythonPackage(Dir : string): boolean;

(* check if a directory is a Python Package *)
function FileIsPythonPackage(FileName : string): boolean;

(* Get Python Package Root directory *)
function GetPackageRootDir(Dir : string): string;

(* Python FileName to possibly dotted ModuleName accounting for packages *)
function FileNameToModuleName(const FileName : string): string;

(* Convert <  > to &lt; &gt; *)
function HTMLSafe(const S : string): string;

(* Parses command line parameters *)
// From Delphi's system.pas unit! Need to rewrite
function GetParamStr(P: PChar; var Param: string): PChar;

(* Parse a line for a Python encoding spec *)
function ParsePySourceEncoding(Textline : string): string;

(* Version of InputQuery that can be called from threads and executes in the main thread *)
function SyncWideInputQuery(const ACaption, APrompt: string; var Value: string): Boolean;

(* Covert all line breaks to #10 *)
function CleanEOLs(S: AnsiString): AnsiString; overload;
function CleanEOLs(S: string): string; overload;

(* Similar to Delphi's IdentToInt but operating on sorted IdentMapEntries *)
function SortedIdentToInt(const Ident: string; var Int: Longint;
                          const SortedMap: array of TIdentMapEntry;
                          CaseSensitive : Boolean = False): Boolean;

(* Used for sorting Python Identifiers *)
function ComparePythonIdents(const S1, S2 : string): Integer; overload;
function ComparePythonIdents(List: TStringList; Index1, Index2: Integer): Integer; overload;

(* Used to get Vista and code fonts *)
function DefaultCodeFontName: string;
procedure SetDefaultUIFont(const AFont: TFont);
procedure SetContentFont(const AFont: TFont);

(* Visual Studio replacement for SynEdits NextWord *)
function VSNextWordPos(SynEdit: TCustomSynEdit; const XY: TBufferCoord): TBufferCoord;

(* Visual Studio replacement for SynEdits PrevWord *)
function VSPrevWordPos(SynEdit: TCustomSynEdit; const XY: TBufferCoord): TBufferCoord;

(* Get the text between two Synedit Block coordinates *)
function GetBlockText(Strings : TStrings; BlockBegin, BlockEnd : TBufferCoord) : string;

(* Extract Error information from a VarPyth variant containing the Python error *)
procedure ExtractPyErrorInfo(E: Variant; var FileName: string; var LineNo: Integer; var Offset: Integer);

(* Get Encoded Ansi string from WideStrings ttaking into account Python file encodings *)
function WideStringsToEncodedText(const AFileName: string;
  Lines : TStrings; var EncodedText: AnsiString;
  InformationLossWarning: Boolean = False;
  IsPython: Boolean = False) : Boolean;

(* Load file into WideStrings taking into account Python file encodings *)
function LoadFileIntoWideStrings(const AFileName: string;
  Lines : TStrings): boolean;

(* Save WideStrings to file taking into account Python file encodings *)
function SaveWideStringsToFile(const AFileName: string;
  Lines : TStrings;  DoBackup : Boolean = True) : boolean;

(* Read File contents. Allows reading of locked files *)
function FileToAnsiStr(const FileName: string): AnsiString;

(* Read File contents into encoded string. Takes into account Python encodings *)
function FileToEncodedStr(const AFileName : string) : AnsiString;

(* Read File contents into Widestring. Takes into account Python encodings *)
function FileToStr(const AFileName : string) : string;

(* Get Nth Line of file *)
function GetNthSourceLine(const AFileName : string; LineNo: integer): string;


type
  TDirectoryWalkProc = reference to function (const Path: string;
      const FileInfo: TSearchRec): Boolean;

(*
   Directory traversal function.  Paths and Masks are semi-colon delimited lists.
*)
procedure WalkThroughDirectories(const Paths, Masks: string;
  const PreCallback: TDirectoryWalkProc;
  const Recursive: Boolean);

(*
   Find files and place them in FileList. Paths and Masks are semi-colon delimited lists.
*)
procedure GetFilesInPaths(Paths, Masks : string; FileList: TStrings; Recursive : Boolean = True);

(*
   Find directories and place them in DirList. Paths and Masks are semi-colon delimited lists.
*)
procedure GetDirectoriesInPaths(Paths, Masks : string; DirList: TStrings; Recursive : Boolean = True);

(* Check whether is S is likely to be a number *)
//function WideStrConsistsofNumberChars(const S: WideString): Boolean;

(* Trim certain chars from left of string *)
function StrTrimCharsLeft(const S: string; const Chars: TSysCharSet): string;

(* Trim certain chars from right of string *)
function StrTrimCharsRight(const S: string; const Chars: TSysCharSet): string;

(* Extracts a token and returns the remainder of a string *)
function StrToken(var S: string; Separator: Char): string;

(* Strips a given character from a string *)
function StrStripChar(const S: string; const AChar: Char): string;

(* Improved CanFocus *)
function CanActuallyFocus(WinControl: TWinControl): Boolean;

(* Create a PCRE Regular Expression and compile it *)
function CompiledRegEx(Expr : string; Options: TRegExOptions = [roNotEmpty];
  UCP : Boolean = True): TRegEx;

(* Checks whether S contains digits only *)
function IsDigits(S : string): Boolean;

(* Remove the white space in front of the first line from all lines *)
function Dedent (const S : string) : string;

(* Returns true for dark colors *)
function IsColorDark(AColor : TColor) : boolean;

(* Returns true if the styled clWindows system oolor is dark *)
function IsStyledWindowsColorDark : boolean;

(* Adds formated text to a Richedit control *)
procedure AddFormatText(RE : TRichEdit; const S: string;  FontStyle: TFontStyles = [];
 const FontColor: TColor = clDefault; FontSize: Integer = 0);

(* Resize Bitmap *)
procedure ResizeBitmap(Bitmap: TBitmap; const NewWidth, NewHeight: integer);

(* Returns string with Desktop size *)
function MonitorProfile: string;

(* Downlads a file from the Interent *)
function DownloadUrlToFile(const URL, Filename: string): Boolean;

(* ExtracFileName that works with both Windows and Unix file names *)
function XtractFileName(const FileName: string): string;

(* ExtractFileDir that works with both Windows and Unix file names *)
function XtractFileDir(const FileName: string): string;

(* Raises a keyword interrupt in another process *)
procedure RaiseKeyboardInterrupt(ProcessId: DWORD);

(* Terminates a process and all child processes *)
function TerminateProcessTree(ProcessID: DWORD): Boolean;

(* Executes a Command using CreateProcess and captures output *)
function ExecuteCmd(Command : string; out CmdOutput: string): cardinal; overload;
function ExecuteCmd(Command : string; out CmdOutput, CmdError: string): cardinal; overload;

(* Checks if a file extension is contained in a file filter *)
function FileExtInFileFilter(FileExt, FileFilter: string): Boolean;

(* Checks if a file name is indicates a Python source file *)
function FileIsPythonSource(FileName: string): Boolean;

(* Simple routine to hook/detour a function *)
procedure RedirectFunction(OrgProc, NewProc: Pointer);

{ Styled MessageDlg (do not use TaskDialog) }
function StyledMessageDlg(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer; overload;
function StyledMessageDlg(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; DefaultButton: TMsgDlgBtn): Integer; overload;

{Style adjusted svg FixedColor}
function SvgFixedColor(Color: TColor): TColor;

type
  (*  Extends System.RegularExperssions.TRegEx *)
  TRegExHelper = record helper for TRegEx
  public
    procedure Study;
    procedure SetAdditionalPCREOptions(PCREOptions : Integer);
    function PerlRegEx : TPerlRegEx;
  end;

  TMatchHelper = record helper for TMatch
  public
    function GroupIndex(Index: integer): integer;
    function GroupLength(Index: integer): integer;
    function GroupValue(Index: integer): string;
  end;

  (*  Helper method for forms *)
  TControlHelper = class helper for TControl
  public
    (* Scale a value according to the FCurrentPPI *)
    function PPIScale(ASize: integer): integer;
    (* Reverse PPI Scaling  *)
    function PPIUnScale(ASize: integer): integer;
  end;

  (*
     TSynStringList is a general purpose TStringList descendent that adds
     the following features:
     - LoadFromFile followed by SaveToFile results in an identical file
     - Detects the LineBreak in the read stream and uses it in SaveToStream
     - UseBOM is set when reading a stream depending on whether BOM exists
     - When reading a file without a BOM it tries to detect whether the e
       encoding is UTF8
     - Event handler for dealing with information loss in Unicode to ANSI
       conversion
  *)
  TXStringList = class(TStringList)
  private
    fUTF8CheckLen: Integer;
    fFileFormat: TSynEditFileFormat;
    fOnInfoLoss: TSynInfoLossEvent;
    fDetectUTF8: Boolean;
  public
    constructor Create; overload;
    procedure SetTextAndFileFormat(const Value: string);
    procedure LoadFromStream(Stream: TStream; Encoding: TEncoding); override;
    procedure SaveToStream(Stream: TStream; Encoding: TEncoding); override;
    property FileFormat: TSynEditFileFormat read FFileFormat write fFileFormat;
  published
    property UTF8CheckLen: Integer read fUTF8CheckLen write fUTF8CheckLen default -1;
    property DetectUTF8: Boolean read fDetectUTF8 write fDetectUTF8 default True;
    property OnInfoLoss: TSynInfoLossEvent read fOnInfoLoss write fOnInfoLoss;
  end;

  (*
    Interfaced based Timer that can be used with anonymous methods
     Developed by  : Nuno Picado (https://github.com/nunopicado/Reusable-Objects)
  *)
  ITimer = interface(IInvokable)
  ['{1C06BCF6-1C6D-473E-993F-2B231B17D4F5}']
    function Start(const Action: TProc): ITimer;
    function Stop: ITimer;
    function Restart: ITimer;
  end;

  function NewTimer(Interval: Cardinal): ITimer;

type
(*
  Minimalist SmartPointer implementation based on a blog post by Barry Kelly:
  http://blog.barrkel.com/2008/11/reference-counted-pointers-revisited.html,
  https://stackoverflow.com/questions/30153682/why-does-this-optimization-of-a-smartpointer-not-work
*)
  TObjectHandle<T: class> = class(TInterfacedObject, TFunc<T>)
  // used by TSmartPointer
  private
    FValue:  T;
  public
    constructor  Create(AValue:  T);
    destructor  Destroy;  override;
    function  Invoke:  T;
  end;

  TSmartPtr = record
    class function Make<T: class>(AValue: T): TFunc<T>; static;
  end;

Var
  StopWatch : TStopWatch;

implementation
Uses
  Winapi.UrlMon,
  Winapi.CommCtrl,
  Winapi.TlHelp32,
  Winapi.Wincodec,
  System.Types,
  System.StrUtils,
  System.AnsiStrings,
  System.UITypes,
  System.IOUtils,
  System.Character,
  System.Math,
  Vcl.ExtCtrls,
  Vcl.Themes,
  JclFileUtils,
  JclBase,
  JclStrings,
  JclPeImage,
  JclSysUtils,
  JvJCLUtils,
  JvGnugettext,
  MPCommonUtilities,
  MPCommonObjects,
  MPShellUtilities,
  SynEditMiscClasses,
  SynEditTextBuffer,
  VarPyth,
  PythonEngine,
  cInternalPython,
  StringResources,
  cPyScripterSettings,
  cParameters,
  cSSHSupport;

function GetIconIndexFromFile(const AFileName: string;
  const ASmall: boolean): integer;
Var
  NameSpace : TNameSpace;
  IconSize : TIconSize;
begin
  Result:= -1;
  // swallow any exceptions (bug report by Colin Williams)
  try
    if FileExists(AFileName) then begin
      if ASmall then
        IconSize := icSmall
      else
        IconSize := icLarge;
      NameSpace := TNameSpace.CreateFromFileName(AFileName);
      try
        Result := NameSpace.GetIconIndex(False, IconSize);
      finally
        NameSpace.Free;
      end;
    end;
  except
  end;
end;

function GetLongFileName(const APath: string): string;
(* returns long file name even for nonexisting files *)
begin
  if APath = '' then Result:= ''
  else begin
    Result:= PathGetLongName(APath);
    // if different - function is working
    if (Result = '') or
       ((Result = APath) and
         not (FileExists(ExcludeTrailingPathDelimiter(APath)) or
           System.SysUtils.DirectoryExists(ExcludeTrailingPathDelimiter(APath)))) then
    begin
      Result:= ExtractFilePath(APath);
      // we are up to top level
      if (Result = '') or (Result[Length(Result)] = ':') then
        Result:= APath
      else Result:= Concat(GetLongFileName(ExcludeTrailingPathDelimiter(Result)),
                           PathDelim, ExtractFileName(APath));
    end;
  end;
end;

(* from cStrings *)

function StrIsLeft(AText, ALeft: PChar): Boolean;
(* checks if AText starts with ALeft *)
begin
  while (ALeft^ <> #0) and (AText^ <> #0) and (ALeft^ = AText^) do begin
    Inc(ALeft);
    Inc(AText);
  end;
  Result := ALeft^ = #0;
end;

function StrIsRight(AText, ARight: PChar): Boolean;
(* checks if AText ends with ARight *)
var
  LenDiff: Integer;
begin
  Result:= ARight = nil;
  LenDiff := StrLen(AText) - StrLen(ARight);
  if not Result and (LenDiff >= 0) then begin
    Inc(AText, LenDiff);
    Result := StrIsLeft(AText, ARight);
  end;
end;

function StrGetToken(var Content: PChar;
                     Separators, WhiteSpace, QuoteChars: TSysCharSet): string;
(* returns next token - based on Classes.ExtractStrings *)
var
  Head, Tail: PChar;
  InQuote: Boolean;
  QuoteChar: Char;
begin
  Result:= '';
  if (Content = nil) or (Content^=#0) then Exit;
  Tail := Content;
  InQuote := False;
  QuoteChar := #0;
  while CharInSet(Tail^, WhiteSpace) do Inc(Tail);
  Head := Tail;
  while True do begin
    while (InQuote and not CharInSet(Tail^, QuoteChars + [#0])) or
      not CharInSet(Tail^, Separators + WhiteSpace + QuoteChars + [#0]) do Inc(Tail);
    if CharInSet(Tail^, QuoteChars) then begin
      if (QuoteChar <> #0) and (QuoteChar = Tail^) then
        QuoteChar := #0
      else QuoteChar := Tail^;
      InQuote := QuoteChar <> #0;
      Inc(Tail);
    end else Break;
  end;
  if (Head <> Tail) and (Head^ <> #0) then begin
    SetString(Result, Head, Tail - Head);
    Content:= Tail;
  end;
end;

function StrUnQuote(const AText: string): string;
(* removes quotes to AText, if needed *)
var
  PText: PChar;
begin
  if CharInSet(PChar(AText)^, ['"', '''']) then begin
    PText:= PChar(AText);
    Result:= AnsiExtractQuotedStr(PText, PText^);
  end
  else Result:= AText;
end;

(* from cStrings end *)

function LightenColor(Color:TColor; Percentage:integer):TColor;
var
   wRGB, wR, wG, wB : longint;
begin
   wRGB := ColorToRGB(Color);
   wR := Min(round(GetRValue(wRGB) * (1+(percentage / 100))), 255);
   wG := Min(round(GetGValue(wRGB) * (1+(percentage / 100))), 255);
   wB := Min(round(GetBValue(wRGB) * (1+(percentage / 100))), 255);
   result := RGB(wR, wG, wB);
end;

function DarkenColor(Color:TColor; Percentage:integer):TColor;
var
   wRGB, wR, wG, wB : longint;
begin
   wRGB := ColorToRGB(Color);
   wR := round(GetRValue(wRGB) / (1+(percentage / 100)));
   wG := round(GetGValue(wRGB) / (1+(percentage / 100)));
   wB := round(GetBValue(wRGB) / (1+(percentage / 100)));
   result := RGB(wR, wG, wB);
end;

function ApplicationVersion : string;
var
  ExeFile : string;
begin
  ExeFile := Application.ExeName;
  if VersionResourceAvailable(ExeFile) then begin
    with TJclFileVersionInfo.Create(ExeFile) do begin
      Result := BinFileVersion;
      Free;
    end;
  end else
    Result := '1.0.0';
end;

function ConnectedToInternet : boolean;
{
Call SHELL32.DLL for Win < Win98
otherwise call URL.dll
}
{button code:}
const
  WininetDLL = 'wininet.dll';
  URLDLL = 'url.dll';
  INTERNET_CONNECTION_MODEM = 1;
  INTERNET_CONNECTION_LAN = 2;
  INTERNET_CONNECTION_PROXY = 4;
  INTERNET_CONNECTION_MODEM_BUSY = 8;
var
  hURLDLL: THandle;
  hWininetDLL: THandle;
  dwReserved: DWORD;
  dwConnectionTypes: DWORD;
  fn_InternetGetConnectedState: function(lpdwFlags: LPDWORD; dwReserved: DWORD): BOOL; stdcall;
  InetIsOffline : function(dwFlags: DWORD): BOOL; stdcall;
begin
  Result := False;
  hURLDLL := SafeLoadLibrary(URLDLL);
  if hURLDLL > 0 then
  begin
    @InetIsOffline := GetProcAddress(hURLDLL,'InetIsOffline');
    if Assigned(InetIsOffline) then begin
      if InetIsOffLine(0) then
        Result := False
      else
        Result := True;
    end;
    FreeLibrary(hURLDLL);
  end;

  // Double checking
  if Result then begin
    hWininetDLL := SafeLoadLibrary(WininetDLL);
    if hWininetDLL > 0 then
    begin
      @fn_InternetGetConnectedState := GetProcAddress(hWininetDLL,'InternetGetConnectedState');
      if Assigned(fn_InternetGetConnectedState) then
      begin
        dwReserved := 0;
        dwConnectionTypes := INTERNET_CONNECTION_MODEM or INTERNET_CONNECTION_LAN
          or INTERNET_CONNECTION_PROXY or INTERNET_CONNECTION_MODEM_BUSY;
        Result := fn_InternetGetConnectedState(@dwConnectionTypes, dwReserved);
      end;
      FreeLibrary(hWininetDLL);
    end;
  end;
end;

function GetNthLine(const S : string; LineNo : integer) : string;
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Text := S;
    if LineNo <= SL.Count then
      Result := SL[LineNo-1]
    else
      Result := '';
  finally
    SL.Free;
  end;
end;

function GetLineRange(const S : string; StartLine, EndLine : integer;
   HtmlBreaks: Boolean) : string;
var
  SL : TStringList;
  i, LastLine : integer;
  LB: string;
begin
  Result := '';
  if HtmlBreaks then
    LB := '<br>'
  else
    LB:= SLineBreak;
  SL := TStringList.Create;
  try
    SL.Text := S;
    LastLine := Min(EndLine-1, SL.Count -1);
    for i := Max(0, StartLine-1) to LastLine do
      if i = LastLine then
        Result := Result + SL[i]
      else
        Result := Result + SL[i] + LB;
  finally
    SL.Free;
  end;
end;

function GetWordAtPos(const LineText: string; Start: Integer;
  AllowDot: boolean; ScanBackwards: boolean = True; ScanForward: boolean = True;
  HandleBrackets: Boolean = False) : string;

  function IsIdentChar(C: Char): boolean;
  begin
    Result := C.IsLetterOrDigit or (C = '_') or (AllowDot and (C = '.'));
  end;

Var
  i : integer;
  L, WordStart, WordEnd, ParenCounter, NewStart : integer;
  Bracket, MatchingBracket : WideChar;
Const
  AllBrackets = '()[]{}';
  CloseBrackets = [')', ']', '}'];
  OpenBrackets = ['(', '[', '{'];
begin
  L := Length(LineText);
  WordStart := Start;
  WordEnd := Start;
  if (Start <= 0) or (Start > L) then
    Exit('')
  else if not IsIdentChar(LineText[Start]) then
    Result := ''
  else begin
    if ScanBackwards then begin
      i := Start;
      while (i > 1) and IsIdentChar(LineText[i-1])
      do
        Dec(i);
      WordStart := i;
    end;
    if ScanForward then begin
      i := Start;
      while (i < L) and IsIdentChar(LineText[i+1]) do
        Inc(i);
      WordEnd := i;
    end;
    Result := Copy(LineText, WordStart, WordEnd - WordStart + 1);
  end;

  if HandleBrackets and ScanBackwards then begin
    if (Result = '') then
      NewStart := Start
    else
      NewStart := WordStart - 1;

    if (NewStart > 0) and CharInSet(LineText[NewStart], CloseBrackets) then begin
      //We found a close, go till it's opening paren

      Bracket := LineText[NewStart];
      MatchingBracket := AllBrackets[AllBrackets.IndexOf(Bracket)]; // IndexOf is zero based!

      ParenCounter := 1;
      i := NewStart - 1;
      while (i > 0) and (ParenCounter > 0) do
      begin
        if Linetext[i] = Bracket then inc(ParenCounter)
        else if Linetext[i] = MatchingBracket then dec(ParenCounter);
        Dec(i);
      end;
      WordStart := i+1;
      Result := Copy(LineText, WordStart, NewStart - WordStart + 1) + Result;
      if WordStart > 1 then
        // Recursive call
        Result := GetWordAtPos(LineText, WordStart - 1, AllowDot,
          ScanBackWards, False, True) + Result;
    end;
  end;
end;

function FormatDocString(const DocString : string) : string;
var
  SL : TStringList;
  i, Margin : integer;
begin
  Result := DocString;
  if Result = '' then Exit;

  // Expand Tabs
  Result := StringReplace(Result, #9, '    ', [rfReplaceAll]);

  //Find minimum indentation of any non-blank lines after first line.
  Margin := MaxInt;
  SL := TStringList.Create;
  try
    SL.Text := Result;
    // Trim First Line
    if SL.Count > 0 then
      SL[0] := Trim(SL[0]);

    //  Remove left margin and clear empty lines
    for i := 1 to SL.Count - 1 do
      if Trim(SL[i]) = '' then
        SL[i] := ''
      else
        Margin := Min(Margin, CalcIndent(SL[i]));
    if (Margin > 0) and (Margin < MaxInt) then
      for i := 1 to SL.Count - 1 do
        if SL[i] <> '' then
          SL[i] := Copy(SL[i], Margin+1, Length(SL[i]) - Margin);
    Result := SL.Text;
    // Remove any trailing or leading blank lines.
    Result := StrTrimCharsRight(Result, [#10, #13]);
    Result := StrTrimCharsLeft(Result, [#10, #13]);
  finally
    SL.Free;
  end;
end;

function CalcIndent(S : string; TabWidth : integer = 4): integer;
Var
  i : integer;
begin
  Result := 0;
  for i := 1 to Length(S) do
    if S[i] = WideChar(#9) then
      Inc(Result, TabWidth)
    else if S[i] = ' ' then
      Inc(Result)
    else
      break;
end;

function DirIsPythonPackage(Dir : string): boolean;
begin
  Result :=  System.SysUtils.DirectoryExists(Dir) and
    FileExists(IncludeTrailingPathDelimiter(Dir) + '__init__.py');
end;

function FileIsPythonPackage(FileName : string): boolean;
begin
  Result := (ExtractFileExt(FileName) = '.py') and
    (ChangeFileExt(ExtractFileName(FileName), '') = '__init__');
end;

function GetPackageRootDir(Dir : string): string;
Var
  S : string;
begin
  if not DirIsPythonPackage(Dir) then
    raise Exception.CreateFmt('"%s" is not a Python package', [Dir]);
  S := Dir;
  Repeat
    Result := S;
    S := ExtractFileDir(S);
  Until (Result = S) or (not DirIsPythonPackage(S));
end;

function FileNameToModuleName(const FileName : string): string;
Var
  Path, Dir, Server : string;
begin
  Result := ChangeFileExt(XtractFileName(FileName), '');
  if TSSHFileName.Parse(FileName, Server, Path) then Exit;

  Path := ExtractFileDir(FileName);
  Dir := ExtractFileName(Path);

  if Path <> '' then begin
    while DirIsPythonPackage(Path) and (Dir <> '') do begin
      Result := Dir + '.' + Result;
      Path := ExtractFileDir(Path);
      Dir := ExtractFileName(Path);
    end;
    if StrIsRight(PChar(Result), '.__init__') then
      Delete(Result, Length(Result) - 8, 9);
  end;
end;

function HTMLSafe(const S : string): string;
begin
  Result := StringReplace(S, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '<br>', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '<br>', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '<br>', [rfReplaceAll]);
end;

function GetParamStr(P: PChar; var Param: string): PChar;
// From Delphi's system.pas unit!
var
  i, Len: Integer;
  Start, S, Q: PChar;
begin
  while True do
  begin
    while (P[0] <> #0) and (P[0] <= ' ') do
      P := CharNext(P);
     {if (P[0] = '"') and (P[1] = '"') then Inc(P, 2) else} Break;    // Issue 371
  end;
  Len := 0;
  Start := P;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      P := CharNext(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Q := CharNext(P);
        Inc(Len, Q - P);
        P := Q;
      end;
      if P[0] <> #0 then
        P := CharNext(P);
    end
    else
    begin
      Q := CharNext(P);
      Inc(Len, Q - P);
      P := Q;
    end;
  end;

  SetLength(Param, Len);

  P := Start;
  S := Pointer(Param);
  i := 0;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      P := CharNext(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Q := CharNext(P);
        while P < Q do
        begin
          S[i] := P^;
          Inc(P);
          Inc(i);
        end;
      end;
      if P[0] <> #0 then P := CharNext(P);
    end
    else
    begin
      Q := CharNext(P);
      while P < Q do
      begin
        S[i] := P^;
        Inc(P);
        Inc(i);
      end;
    end;
  end;

  Result := P;
end;

function ParsePySourceEncoding(Textline : string): string;
begin
  Result := '';
  with TRegEx.Match(TextLine, 'coding[:=]\s*([-\w.]+)') do
    if Success then
      Exit(Groups[1].Value);
end;

function GetAveCharSize(Canvas: TCanvas): TPoint;
var
  I: Integer;
  Buffer: array[0..51] of WideChar;
  tm: TTextMetric;
begin
  for I := 0 to 25 do Buffer[I] := WideChar(I + Ord('A'));
  for I := 0 to 25 do Buffer[I + 26] := WideChar(I + Ord('a'));
  GetTextMetrics(Canvas.Handle, tm);
  GetTextExtentPointW(Canvas.Handle, Buffer, 52, TSize(Result));
  Result.X := (Result.X div 26 + 1) div 2;
  Result.Y := tm.tmHeight;
end;

type
  TSyncInputQuery = class
    public
    Caption, Prompt, Value : string;
    Res : Boolean;
    constructor Create(ACaption, APrompt, AValue : string);
    procedure InputQuery;
  end;

{ TSyncInputQuery }

constructor TSyncInputQuery.Create(ACaption, APrompt, AValue: string);
begin
  Caption := ACaption;
  Prompt := APrompt;
  Value := AValue;
end;

procedure TSyncInputQuery.InputQuery;
begin
  Res := Vcl.Dialogs.InputQuery(Caption, Prompt, Value);
end;

function SyncWideInputQuery(const ACaption, APrompt: string; var Value: string): Boolean;
var
  SyncInputQuery : TSyncInputQuery;
  SaveThreadState: PPyThreadState;
begin
  if GetCurrentThreadId = MainThreadId then
    Result := InputQuery(ACaption, APrompt, Value)
  else begin
    SyncInputQuery := TSyncInputQuery.Create(ACaption, APrompt, Value);
    try
      with GetPythonEngine do begin
        SaveThreadState := PyEval_SaveThread();
        try
          TThread.Synchronize(nil, SyncInputQuery.InputQuery);
        finally
          PyEval_RestoreThread(SaveThreadState);
        end;
      end;
      Result := SyncInputQuery.Res;
      Value := SyncInputQuery.Value;
    finally
      SyncInputQuery.Free;
    end;
  end;
end;

function CleanEOLs(S: AnsiString): AnsiString;
begin
  Result := System.AnsiStrings.AdjustLineBreaks(S, System.tlbsLF)
end;

function CleanEOLs(S: string): string;
begin
  Result := System.SysUtils.AdjustLineBreaks(S, System.tlbsLF)
end;

function SortedIdentToInt(const Ident: string; var Int: Longint;
                          const SortedMap: array of TIdentMapEntry;
                          CaseSensitive : Boolean = False): Boolean;
var
  m, n, k, I: Integer;
begin
  m := Low(SortedMap); n := High(SortedMap);
  while m<=n do
    begin
      k := m+(n-m) div 2;
      if CaseSensitive then
        I := CompareStr(Ident, SortedMap[k].Name)
      else
        I := CompareText(Ident, SortedMap[k].Name);
      if I = 0 then begin
          Result := true;
          Int := SortedMap[k].Value;
          exit;
      end else if I > 0 then
         m := k+1
      else
        n := k-1;
    end;
  Result := false
end;

function ComparePythonIdents(const S1, S2 : string): Integer; overload;
Var
  L1, L2 : integer;
begin
  L1 := Length(S1);
  L2 := Length(S2);
  if (L1 > 0) and (S1[1] = Char('_')) and (L2>0) and (S2[1] = Char('_')) then
    Result := CompareText(S1, S2)
  else if (L1 > 0) and (S1[1] = Char('_')) then
    Result := 1
  else if (L2>0) and (S2[1] = Char('_')) then
    Result := -1
  else
    Result := CompareText(S1, S2)
end;

function ComparePythonIdents(List: TStringList; Index1, Index2: Integer): Integer; overload;
Var
  S1, S2 : string;
begin
  S1 := List[Index1];
  S2 := List[Index2];
  Result := ComparePythonIdents(S1, S2);
end;

function DefaultCodeFontName: string;
begin
    if CheckWin32Version(6) then
      Result := 'Consolas'
    else
      Result := 'Courier New';
end;

procedure SetDefaultUIFont(const AFont: TFont);
Const
  UIFont = 'Segoe UI';
begin
  if CheckWin32Version(6)
    and not SameText(AFont.Name, UIFont)
    and (Screen.Fonts.IndexOf(UIFont) >= 0) then
  begin
    AFont.Size := 9;
    AFont.Name := UIFont;
  end;
end;

procedure SetContentFont(const AFont: TFont);
Const
  VistaContentFont = 'Calibri';
begin
  if CheckWin32Version(6)
    and not SameText(AFont.Name, VistaContentFont)
    and (Screen.Fonts.IndexOf(VistaContentFont) >= 0) then
  begin
    AFont.Size := 9;
    AFont.Name := VistaContentFont;
  end;
end;

function GetBlockText(Strings : TStrings; BlockBegin, BlockEnd : TBufferCoord) : string;
Var
  Line :  integer;
begin
  // preconditions start
  Assert(BlockBegin.Line <= Strings.Count);
  Assert(BlockEnd.Line <= Strings.Count);
  Assert(BlockBegin.Line <= BlockEnd.Line);
  if BlockBegin.Line <= 0 then Exit;
  if BlockEnd.Line <= 0 then Exit;
  // preconditions end

  // work backwards
  Line := BlockEnd.Line;
  Result := System.StrUtils.LeftStr(Strings[Line-1], BlockEnd.Char - 1);
  While (Line > BlockBegin.Line) and (Line > 1) do begin
    Dec(Line);
    Result := Strings[Line-1] + WideCRLF + Result;
  end;
  if Line = BlockBegin.Line then
    Delete(Result, 1, BlockBegin.Char -1);
end;

function VSNextWordPos(SynEdit: TCustomSynEdit; const XY: TBufferCoord): TBufferCoord;
var
  CX, CY, LineLen: Integer;
  Line: UnicodeString;
begin
  CX := XY.Char;
  CY := XY.Line;

  // valid line?
  if (CY >= 1) and (CY <= SynEdit.Lines.Count) then
  with SynEdit do begin
    Line := Lines[CY - 1];

    LineLen := Length(Line);
    if CX > LineLen then
    begin
      // invalid char
      // find first char in the next line
      if CY < Lines.Count then
      begin
        Line := Lines[CY];
        LineLen := Length(Line);
        Inc(CY);
        CX := 1;
        while (CX <= LineLen) and IsWhiteChar(Line[CX]) do
          Inc(CX);
      end;
    end
    else
    begin
      if CX = 0 then
        CX := 1;
      // valid char
      if IsIdentChar(Line[CX]) then begin
        while (CX <= LineLen) and IsIdentChar(Line[CX]) do
          Inc(CX);
        while (CX <= LineLen) and IsWhiteChar(Line[CX]) do
          Inc(CX);
      end else if IsWhiteChar(Line[CX]) then begin
        while (CX <= LineLen) and IsWhiteChar(Line[CX]) do
          Inc(CX);
      end else begin
        // breakchar and not whitechar
        while (CX <= LineLen) and (IsWordBreakChar(Line[CX]) and not IsWhiteChar(Line[CX])) do
          Inc(CX);
        while (CX <= LineLen) and IsWhiteChar(Line[CX]) do
          Inc(CX);
      end;
    end;
  end;
  Result.Char := CX;
  Result.Line := CY;
end;

function VSPrevWordPos(SynEdit: TCustomSynEdit; const XY: TBufferCoord): TBufferCoord;
var
  CX, CY: Integer;
  Line: UnicodeString;
begin
  CX := XY.Char;
  CY := XY.Line;

  // valid line?
  if (CY >= 1) and (CY <= SynEdit.Lines.Count) then
  with SynEdit do begin
    Line := Lines[CY - 1];
    CX := Min(CX, Length(Line) + 1);

    if CX <= 1 then
    begin
      // find last IdentChar in the previous line
      if CY > 1 then
      begin
        Dec(CY);
        Line := Lines[CY - 1];
        CX := Length(Line) + 1;
        while (CX > 1) and IsWhiteChar(Line[CX-1]) do
          Dec(CX);
      end;
    end
    else
    begin
      // CX > 1 and <= LineLenght + 1
      if IsIdentChar(Line[CX-1]) then begin
        while (CX > 1) and IsIdentChar(Line[CX-1]) do
          Dec(CX);
      end else if IsWhiteChar(Line[CX-1]) then begin
        while (CX > 1) and IsWhiteChar(Line[CX-1]) do
          Dec(CX);
        if CX <= 1 then begin
          // find last IdentChar in the previous line
          if CY > 1 then
          begin
            Dec(CY);
            Line := Lines[CY - 1];
            CX := Length(Line) + 1;
            while (CX > 1) and IsWhiteChar(Line[CX-1]) do
              Dec(CX);
          end;
        end else if IsIdentChar(Line[CX-1]) then begin
          while (CX > 1) and IsIdentChar(Line[CX-1]) do
            Dec(CX);
        end else begin
          // breakchar and not whitechar
          while (CX > 1) and (IsWordBreakChar(Line[CX-1]) and not IsWhiteChar(Line[CX-1])) do
            Dec(CX);
        end;
      end else begin
        // breakchar and not whitechar
        while (CX > 1) and (IsWordBreakChar(Line[CX-1]) and not IsWhiteChar(Line[CX-1])) do
          Dec(CX);
      end;
    end;
  end;
  Result.Char := CX;
  Result.Line := CY;
end;

procedure ExtractPyErrorInfo(E: Variant; var FileName: string; var LineNo: Integer; var Offset: Integer);
begin
  try
    FileName := E.filename;
  except
    FileName := '';
  end;
  try
    LineNo := E.lineno;
  except
    LineNo := 0;
  end;
  try
    Offset := E.offset;
  except
    Offset := 0;
  end;
end;

function WideStringsToEncodedText(const AFileName: string;
  Lines : TStrings; var EncodedText: AnsiString;
  InformationLossWarning: Boolean = False;
  IsPython: Boolean = False) : Boolean;
// AFileName is passed just for the warning
var
  PyEncoding : string;
  UniPy, EncodedString : PPyObject;
  wStr: string;
  SuppressOutput : IInterface;
  OldLineBreak : string;
begin
  Result := True;

  //  Encoded strings cannot contain WideLineSeparator
  OldLineBreak := Lines.LineBreak;
  if Lines.LineBreak = WideLineSeparator then
    Lines.LineBreak := sLineBreak;

  wStr := Lines.Text;
  Lines.LineBreak := OldLineBreak;

  if GI_PyControl.PythonLoaded and
    (IsPython or FileIsPythonSource(AFileName)) then
  begin
    PyEncoding := '';
    if Lines.Count > 0 then
      PyEncoding := ParsePySourceEncoding(Lines[0]);
    if (PyEncoding = '') and (Lines.Count > 1) then
      PyEncoding := ParsePySourceEncoding(Lines[1]);

    with SafePyEngine.PythonEngine do begin
      if PyEncoding = '' then
        PyEncoding := SysModule.getdefaultencoding();
      SuppressOutput := GI_PyInterpreter.OutputSuppressor; // Do not show errors
      UniPy := nil;
      EncodedString := nil;
      try
        try
          UniPy := PyUnicode_FromWideChar(PWideChar(wStr), Length(wStr));
          CheckError;
          if InformationLossWarning then begin
            try
              EncodedString := PyUnicode_AsEncodedString(UniPy, PAnsiChar(AnsiString(PyEncoding)), 'strict');
              CheckError;
              EncodedText := PyBytesAsAnsiString(EncodedString);
              CheckError;
            except
              on UnicodeEncodeError do begin
                Result :=
                  StyledMessageDlg(Format(_(SFileEncodingWarning),
                    [AFileName, PyEncoding]), mtWarning, [mbYes, mbCancel], 0)= mrYes;
                if Result then begin
                  EncodedString := PyUnicode_AsEncodedString(UniPy,
                    PAnsiChar(AnsiString(PyEncoding)), PAnsiChar(AnsiString('replace')));
                  CheckError;
                  EncodedText := PyBytesAsAnsiString(EncodedString);
                  CheckError;
                end;
              end;
            end;
          end else begin
            EncodedString := PyUnicode_AsEncodedString(UniPy, PAnsiChar(AnsiString(PyEncoding)), 'replace');
            CheckError;
            EncodedText := PyBytesAsAnsiString(EncodedString);
            CheckError;
          end;
        finally
          Py_XDECREF(UniPy);
          Py_XDECREF(EncodedString);
        end;
      except
        PyErr_Clear;
        EncodedText := AnsiString(wStr);
        if InformationLossWarning then
          Result :=
            StyledMessageDlg(Format(_(SFileEncodingWarning),
              [AFileName, PyEncoding]), mtWarning, [mbYes, mbCancel], 0)= mrYes ;
      end;
    end;
  end else begin
    EncodedText := AnsiString(wStr);
    if InformationLossWarning and not IsAnsiOnly(wStr) then begin
      Result :=
        StyledMessageDlg(Format(_(SFileEncodingWarning),
        [AFileName, 'ANSI']), mtWarning, [mbYes, mbCancel], 0)= mrYes ;
    end;
  end;
end;

function LoadFileIntoWideStrings(const AFileName: string; Lines : TStrings): boolean;

  procedure LoadFromString(S: string);
  begin
    if Lines is TSynEditStringList then begin
      TSynEditStringList(Lines).SetTextAndFileFormat(S);
      TSynEditStringList(Lines).SetEncoding(TEncoding.ANSI);
    end else if Lines is TXStringList then begin
      TXStringList(Lines).SetTextAndFileFormat(S);
      TXStringList(Lines).SetEncoding(TEncoding.ANSI);
    end else
      Lines.Text := S;
  end;

Var
  Reader : TStreamReader;
  FileStream: TFileStream;
  FileText, PyEncoding : AnsiString;
  S: String;
  Len : integer;
  PyWstr : PPyObject;
begin
  Result := True;
  if (AFileName = '') or not FileExists(AFileName) then Exit(False);

  try
    if not FileIsPythonSource(AFileName) then
    begin
      Lines.LoadFromFile(AFileName);
      Exit(True);
    end;

    // Special processing for python files
    // Try to use an encoding comment if present
    Reader := TStreamReader.Create(AFileName, TEncoding.Default, True, 128);
    try
      // Reads the first Line - Also sets the CurrentEncoding
      S := Reader.ReadLine;
      if Reader.CurrentEncoding <> TEncoding.ANSI then
      begin
          // BOM found
        Lines.LoadFromFile(AFileName);
        Exit(True);
      end;

      // Detect an encoding spec
      PyEncoding := AnsiString(ParsePySourceEncoding(S));
      if PyEncoding = '' then begin
        S := Reader.ReadLine;
        PyEncoding := AnsiString(ParsePySourceEncoding(S));
      end;
    finally
      Reader.Free;
    end;

    // if there is no encoding line or Python is not loaded use default encoding UTF8
    if not GI_PyControl.PythonLoaded or (PyEncoding = '') or
      (LowerCase(PyEncoding) = 'utf-8') or (LowerCase(PyEncoding) = 'utf8')
    then
    begin
      Lines.LoadFromFile(AFileName, TEncoding.UTF8);
      Exit(True);
    end;

    // we have an encoding we can use with python
    FileStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
    // Read the file into FileText
    try
      Len := FileStream.Size;
      SetLength(FileText, Len);
      FileStream.ReadBuffer(FileText[1], Len);
    finally
      FileStream.Free;
    end;

    PyWstr := nil;
    try
      var Py := SafePyEngine;
      with Py.PythonEngine do begin
        try
            PyWstr := PyUnicode_Decode(PAnsiChar(FileText),
              Length(FileText),
              PAnsiChar(PyEncoding), 'replace');
            CheckError;
            LoadFromString(PyUnicodeAsString(PyWstr));
        finally
          Py_XDECREF(PyWstr);
        end;
      end;
    except
      StyledMessageDlg(Format(_(SDecodingError),
         [AFileName, PyEncoding]), mtWarning, [mbOK], 0);
      LoadFromString(string(FileText));
    end

  except
    on E: Exception do begin
      StyledMessageDlg(Format(_(SFileOpenError), [AFileName, E.Message]), mtError, [mbOK], 0);
      Result := False;
    end;
  end;
end;

type
  TSynEditStringListAccess = class(TSynEditStringList);

(* Save WideStrings to file taking into account Python file encodings *)
function SaveWideStringsToFile(const AFileName: string;
  Lines : TStrings;  DoBackup : Boolean = True) : boolean;
Var
  FileStream : TFileStream;
  S : AnsiString;
  OldLineBreak: string;
begin
  try
    // Create Backup
    if DoBackup and
      FileExists(AFileName) then
    begin
      try
        FileBackup(AFileName);
      except
        StyledMessageDlg(Format(_(SFailedToBackupFile), [AFileName]),
          mtWarning, [mbOK], 0);
      end;
    end;

    if not FileIsPythonSource(AFileName) or (Lines.Encoding <> TEncoding.Ansi) then
    begin
      Lines.SaveToFile(AFileName);
      Exit(True);
    end;

    // For Ansi encoded Python files you have deal with coding comments
    OldLineBreak := Lines.LineBreak;
    if Lines is TSynEditStringList then
      Lines.LineBreak := LineBreakFromFileFormat(TSynEditStringListAccess(Lines).FileFormat)
    else if Lines is TXStringList then
      Lines.LineBreak := LineBreakFromFileFormat(TXStringList(Lines).FileFormat);

    Result := WideStringsToEncodedText(AFileName, Lines, S, True);

    Lines.LineBreak := OldLineBreak;

    if Result then begin
      FileStream := TFileStream.Create(AFileName, fmCreate);
      try
        FileStream.WriteBuffer(S[1], Length(S))
      finally
        FileStream.Free;
      end;
    end;
  except
    on E: Exception do begin
      StyledMessageDlg(Format(_(SFileSaveError), [AFileName, E.Message]), mtError, [mbOK], 0);
      Result := False;
    end;
  end;
end;

function FileToAnsiStr(const FileName: string): AnsiString;
(* allows reading of locked files *)
var
  fs: TFileStream;
  len: Integer;
begin
  fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    len := fs.Size;
    SetLength(Result, len);
    if len > 0 then
      fs.ReadBuffer(Result[1], len);
  finally
    fs.Free;
  end;
end;

function FileToEncodedStr(const AFileName : string) : AnsiString;
Var
  SL : TStrings;
  Server, FName, TempFileName, ErrorMsg : string;
begin
  if TSSHFileName.Parse(AFileName, Server, FName) then
  begin
    TempFileName := ChangeFileExt(FileGetTempName('PyScripter'), ExtractFileExt(AFileName));
    if not ScpDownload(Server, FName, TempFileName, ErrorMsg) then
    begin
      StyledMessageDlg(Format(_(SFileSaveError), [FName, ErrorMsg]), mtError, [mbOK], 0);
      Abort;
    end;
  end
  else
     TempFileName := AFileName;

  SL := TStringList.Create;
  try
    if not LoadFileIntoWideStrings(TempFileName, SL) then Abort;
    WideStringsToEncodedText(AFileName, SL, Result, False);
  finally
    SL.Free;
  end;
  if Server <> '' then DeleteFile(TempFileName);
end;


function FileToStr(const AFileName : string) : string;
Var
  SL : TStrings;
  Server, FName, TempFileName, ErrorMsg : string;
begin
  if TSSHFileName.Parse(AFileName, Server, FName) then
  begin
    TempFileName := ChangeFileExt(FileGetTempName('PyScripter'), ExtractFileExt(AFileName));
    if not ScpDownload(Server, FName, TempFileName, ErrorMsg) then
    begin
      StyledMessageDlg(Format(_(SFileSaveError), [FName, ErrorMsg]), mtError, [mbOK], 0);
      Abort;
    end;
  end
  else
     TempFileName := AFileName;

  SL := TStringList.Create;
  try
    if not LoadFileIntoWideStrings(TempFileName, SL) then Abort;
    Result := SL.Text;
  finally
    SL.Free;
  end;
  if Server <> '' then DeleteFile(TempFileName);
end;


function GetNthSourceLine(const AFileName : string; LineNo: integer): string;
var
  TempS: string;
begin
  Result := '';
  var Editor := GI_EditorFactory.GetEditorByNameOrTitle(AFileName);
  if Assigned(Editor) then begin
    if Editor.SynEdit.Lines.Count >= LineNo then
      Exit(Editor.SynEdit.Lines[LineNo - 1])
    else
      Exit;
  end
  else if FileExists(AFileName) then
  try
    var SR := TSmartPtr.Make(TStreamReader.Create(AFileName))();
    for var I := 1 to LineNo do
      if SR.EndOfStream then
        Exit
      else
        TempS := SR.ReadLine;
    Result := TempS;
  except
  end;
end;

(*
   Single directory traversal function used in WalkThroughDirectories
*)
procedure WalkThroughDirectory(const Path: string; Masks : TStringDynArray;
  const PreCallback: TDirectoryWalkProc;
  const Recursive: Boolean);
var
  SearchRec: TSearchRec;
  Match: Boolean;
  Stop: Boolean;
  PathWithSep, Mask : string;
begin
  PathWithSep := IncludeTrailingPathDelimiter(Path);
  if FindFirst(PathWithSep + '*', faAnyFile, SearchRec) = 0 then
  try
    Stop := False;

    repeat
      Match := Length(Masks) = 0;
      for Mask in Masks do begin
        Match := TPath.MatchesPattern(SearchRec.Name, Mask, False);
        if Match then Break;
      end;

      // call the preorder callback method
      if Match and Assigned(PreCallback) then
        Stop := not PreCallback(PathWithSep, SearchRec);

      if not Stop then
      begin
        // go recursive in subdirectories
        if Recursive and (SearchRec.Attr and System.SysUtils.faDirectory <> 0) and
           (SearchRec.Attr and System.SysUtils.faHidden = 0) and
           (SearchRec.Name <> '.') and
           (SearchRec.Name <> '..') then
          WalkThroughDirectory(PathWithSep + SearchRec.Name,
            Masks, PreCallback, Recursive);

      end;
    until Stop or (FindNext(SearchRec) <> 0);
  finally
    FindClose(SearchRec);
  end;
end;

procedure WalkThroughDirectories(const Paths, Masks: string;
  const PreCallback: TDirectoryWalkProc;
  const Recursive: Boolean);
Var
  Path, PathName : string;
  PathList, MaskList : TStringDynArray;
begin
  PathList := SplitString(Paths, ';');
  MaskList := SplitString(Masks, ';');
  for Path in PathList do
  begin
    PathName := Parameters.ReplaceInText(Path);
    if  System.SysUtils.DirectoryExists(PathName) then
      WalkThroughDirectory(PathName, MaskList, PreCallback, Recursive);
  end;
end;

procedure GetFilesInPaths(Paths, Masks : string; FileList: TStrings; Recursive : Boolean = True);
Var
  PreCallback: TDirectoryWalkProc;
begin
  PreCallback :=
    function (const Path: string; const FileInfo: TSearchRec): Boolean
    begin
      Result := True;

      if FileInfo.Attr and System.SysUtils.faDirectory = 0 then
        FileList.Add(Path+FileInfo.Name);
    end;

  WalkThroughDirectories(Paths, Masks, PreCallback, Recursive);
end;

procedure GetDirectoriesInPaths(Paths, Masks : string; DirList: TStrings; Recursive : Boolean = True);
Var
  PreCallback: TDirectoryWalkProc;
begin
  PreCallback :=
    function (const Path: string; const FileInfo: TSearchRec): Boolean
    begin
      Result := True;

      if (FileInfo.Attr and System.SysUtils.faDirectory <> 0) and
         (FileInfo.Name <> '.') and (FileInfo.Name <> '..') then
        DirList.Add(Path+FileInfo.Name);
    end;

  WalkThroughDirectories(Paths, Masks, PreCallback, Recursive);
end;

function StrTrimCharsLeft(const S: string; const Chars: TSysCharSet): string;
var
  I, L: Integer;
begin
  I := 1;
  L := Length(S);
  while (I <= L) and CharInSet(S[I], Chars) do Inc(I);
  Result := Copy(S, I, L - I + 1);
end;

function StrTrimCharsRight(const S: string; const Chars: TSysCharSet): string;
var
  I: Integer;
begin
  I := Length(S);
  while (I >= 1) and CharInSet(S[I], Chars) do Dec(I);
  Result := Copy(S, 1, I);
end;

function StrToken(var S: string; Separator: WideChar): string;
var
  I: Integer;
begin
  I := CharPos(S, Separator);
  if I <> 0 then
  begin
    Result := Copy(S, 1, I - 1);
    Delete(S, 1, I);
  end
  else
  begin
    Result := S;
    S := '';
  end;
end;

function StrStripChar(const S: string; const AChar: Char): string;
var
  Source, Dest: PChar;
  Len, Index:   NativeInt;
begin
  Len := Length(S);
  SetLength(Result, Len);
  UniqueString(Result);
  Source := PChar(S);
  Dest := PChar(Result);
  for Index := 0 to Len - 1 do
  begin
    if Source^ <> AChar then
    begin
      Dest^ := Source^;
      Inc(Dest);
    end;
    Inc(Source);
  end;
  SetLength(Result, Dest - PChar(Result));
end;

function CanActuallyFocus(WinControl: TWinControl): Boolean;
var
  Form: TCustomForm;
begin
  Result := False;
  if Assigned(WinControl) and not WinControl.Focused then begin
    Form := GetParentForm(WinControl);
    if Assigned(Form) and Form.Enabled and Form.Visible then
      Result := WinControl.CanFocus;
  end;
end;

function IsDigits(S : string): Boolean;
Var
  i : integer;
begin
  Result := True;
  for I := 1 to Length(S) do
    if not CharInSet(S[I], ['0'..'9']) then begin
      Result := False;
      break;
    end;
end;

function Dedent(const S : string) : string;
begin
  with TRegEx.Match(S, '^\s+') do
    if Success then
      // to avoid repeated replacements of initial space
      Exit(TRegEx.Replace(TRegEx.Replace(S,
         '^'+Groups[0].Value , '!', [roNotEmpty, roMultiLine]),
         '^!' , '', [roNotEmpty, roMultiLine]))
    else
      Exit(S)
end;

function CompiledRegEx(Expr : string; Options: TRegExOptions = [roNotEmpty];
  UCP : Boolean = True): TRegEx;
begin
  try
    Result.Create(Expr, Options);
    if UCP then
      Result.SetAdditionalPCREOptions(PCRE_UCP);
    Result.Study
  except
    on E: ERegularExpressionError do
      begin
        StyledMessageDlg(Format(_(SInvalidRegularExpression), [E.Message]),
          mtError, [mbOK], 0);
        Abort;
      end
    else
      raise;
  end;
end;

function IsColorDark(AColor : TColor) : boolean;
var
  ACol: Longint;
begin
  ACol := ColorToRGB(AColor) and $00FFFFFF;
  Result := ((2.99 * GetRValue(ACol) + 5.87 * GetGValue(ACol) +
                 1.14 * GetBValue(ACol)) < $400);
end;

function IsStyledWindowsColorDark : boolean;
begin
  Result := IsColorDark(StyleServices.GetSystemColor(clWindow));
end;

{ TXStringList }

constructor TXStringList.Create;
begin
  inherited Create;
  fUTF8CheckLen := -1;
  Options := Options - [soWriteBOM, soTrailingLineBreak];
  fDetectUTF8 := True;
  fFileFormat := sffDos;
end;

procedure TXStringList.LoadFromStream(Stream: TStream; Encoding: TEncoding);
var
  Size: Integer;
  Buffer: TBytes;
begin
  BeginUpdate;
  try
    Size := Stream.Size - Stream.Position;
    SetLength(Buffer, Size);
    Stream.Read(Buffer, 0, Size);
    Size := TEncoding.GetBufferEncoding(Buffer, Encoding, DefaultEncoding);
    WriteBOM := Size > 0; // Keep WriteBom in case the stream is saved
    // If the encoding is ANSI and DetectUtf8 is True try to Detect UTF8
    if (Encoding = TEncoding.ANSI) and DetectUTF8 and IsUTF8(Buffer, Size) then
      Encoding := TEncoding.UTF8;
    SetEncoding(Encoding); // Keep Encoding in case the stream is saved
    SetTextAndFileFormat(Encoding.GetString(Buffer, Size, Length(Buffer) - Size));
  finally
    EndUpdate;
  end;
end;

procedure TXStringList.SaveToStream(Stream: TStream; Encoding: TEncoding);
Var
  Cancel: Boolean;
  OldLineBreak: string;
  S: string;
  Buffer, Preamble: TBytes;
begin
  if Encoding = nil then
    Encoding := DefaultEncoding;

  OldLineBreak := LineBreak;
  try
    LineBreak := LineBreakFromFileFormat(fFileFormat);
    S := GetTextStr;
  finally
    LineBreak := OldLineBreak;
  end;

  Cancel := False;
  if (Encoding = TEncoding.ANSI) and Assigned(fOnInfoLoss) and not IsAnsiOnly(S) then
  begin
    fOnInfoLoss(Encoding, Cancel);
    if Cancel then
      Exit;
    if Encoding <> TEncoding.ANSI then
      SetEncoding(Encoding);
  end;

  Buffer := Encoding.GetBytes(S);
  if WriteBOM then
  begin
    Preamble := Encoding.GetPreamble;
    if Length(Preamble) > 0 then
      Stream.WriteBuffer(Preamble, Length(Preamble));
  end;
  Stream.WriteBuffer(Buffer, Length(Buffer));
end;

procedure TXStringList.SetTextAndFileFormat(const Value: string);
var
  S: string;
  Size: Integer;
  P, Start, Pmax: PWideChar;
  fCR, fLF, fLINESEPARATOR: Boolean;
begin
  fLINESEPARATOR := False;
  fCR := False;
  fLF := False;
  BeginUpdate;
  try
    Clear;
    P := Pointer(Value);
    if P <> nil then
    begin
      Size := Length(Value);
      Pmax := @Value[Size];
      while (P <= Pmax) do
      begin
        Start := P;
        while not (Ord(P^) in [0, $A, $D]) and (P^ <> WideLineSeparator) do
        begin
          Inc(P);
        end;
        if P<>Start then
        begin
          SetString(S, Start, P - Start);
          Insert(Count, S);
        end else Insert(Count, '');
        if P^ = WideLineSeparator then
        begin
          fLINESEPARATOR := True;
          Inc(P);
        end;
        if P^ = WideCR then
        begin
          fCR := True;
          Inc(P);
        end;
        if P^ = WideLF then
        begin
          fLF := True;
          Inc(P);
        end;
      end;
      // keep the old format of the file
      if not TrailingLineBreak and
        (CharInSet(Value[Size], [#10, #13]) or (Value[Size] = WideLineSeparator))
      then
        Insert(Count, '');
    end;
  finally
    EndUpdate;
  end;
  if fLINESEPARATOR then
    FileFormat := sffUnicode
  else if fCR and not fLF then
    FileFormat := sffMac
  else if fLF and not fCR then
    FileFormat := sffUnix
  else
    FileFormat := sffDos;
end;

procedure AddFormatText(RE : TRichEdit; const S: string;  FontStyle: TFontStyles = [];
 const FontColor: TColor = clDefault; FontSize: Integer = 0);
begin
  with RE do
  begin
    //move caret to end
    SelStart := GetTextLen;
    SelAttributes.Style := FontStyle;
    if FontSize <> 0 then
      SelAttributes.Size := FontSize
    else
      SelAttributes.Size := DefAttributes.Size;
    if FontColor <> clDefault then
      SelAttributes.Color := FontColor
    else
      SelAttributes.Color := DefAttributes.Color;

    SelText := S;
  end;
end;

//procedure ResizeBitmap(Bitmap: TBitmap; const NewWidth, NewHeight: integer);
//var
//  buffer: TBitmap;
//begin
//  buffer := TBitmap.Create;
//  try
//    buffer.SetSize(NewWidth, NewHeight);
//    buffer.AlphaFormat := afDefined;
//    buffer.Canvas.StretchDraw(Rect(0, 0, NewWidth, NewHeight), Bitmap);
//    Bitmap.SetSize(NewWidth, NewHeight);
//    Bitmap.Canvas.Draw(0, 0, buffer);
//  finally
//    buffer.Free;
//  end;
//end;

procedure ResizeBitmap(Bitmap: TBitmap; const NewWidth, NewHeight: integer);
var
  Factory: IWICImagingFactory;
  Scaler: IWICBitmapScaler;
  Source : TWICImage;
begin
  //Bitmap.AlphaFormat := afDefined;
  Source := TWICImage.Create;
  try
    Source.Assign(Bitmap);
    Factory := TWICImage.ImagingFactory;
    Factory.CreateBitmapScaler(Scaler);
    try
      Scaler.Initialize(Source.Handle, NewWidth, NewHeight,
        WICBitmapInterpolationModeHighQualityCubic);
      Source.Handle := IWICBitmap(Scaler);
    finally
      Scaler := nil;
      Factory := nil;
    end;
    Bitmap.Assign(Source);
  finally
    Source.Free;
  end;
end;

function MonitorProfile: string;

  function DesktopSizeString: string;
  begin
    Result := Format('(%dx%d)', [Screen.DesktopWidth, Screen.DesktopHeight]);
  end;
Const
  strMask = '%d:%dDPI(%s,%d,%d,%d,%d)';
Var
  iMonitor: Integer;
  M: TMonitor;
Begin
  Result := DesktopSizeString;
  for iMonitor := 0 To Screen.MonitorCount - 1 Do
    begin
        M := Screen.Monitors[iMonitor];
        Result := Result + Format(strMask, [
        M.MonitorNum,
        M.PixelsPerInch,
        BoolToStr(M.Primary, True),
        M.Left,
        M.Top,
        M.Width,
        M.Height
      ]);
    end;
End;

function DownloadUrlToFile(const URL, Filename: string): Boolean;
begin
  Result := Succeeded(URLDownloadToFile(nil, PWideChar(URL), PWideChar(Filename), 0, nil));
end;

{ ITimer implementation }
type
  TTimer = class(TInterfacedObject, ITimer)
  private var
    FTimer: VCL.ExtCtrls.TTimer;
    FAction: TProc;
  private
    procedure RunAction(Sender: TObject);
  public
    constructor Create(const Interval: Cardinal);
    destructor Destroy; override;
    class function New(const Interval: Cardinal): ITimer;
    function Start(const Action: TProc): ITimer;
    function Stop: ITimer;
    function Restart: ITimer;
  end;

{ TTimer }

constructor TTimer.Create(const Interval: Cardinal);
begin
  FTimer          := VCL.ExtCtrls.TTimer.Create(nil);
  FTimer.Enabled  := False;
  FTimer.Interval := Interval;
  FTimer.OnTimer  := RunAction;
end;

destructor TTimer.Destroy;
begin
  FTimer.Free;
  inherited;
end;

class function TTimer.New(const Interval: Cardinal): ITimer;
begin
  Result := Create(Interval);
end;

procedure TTimer.RunAction(Sender: TObject);
begin
  FAction;
end;

function TTimer.Start(const Action: TProc): ITimer;
begin
  Result         := Self;
  FAction        := Action;
  FTimer.Enabled := True;
end;

function TTimer.Stop: ITimer;
begin
  Result         := Self;
  FTimer.Enabled := False;
end;

function TTimer.ReStart: ITimer;
begin
  Result         := Self;
  FTimer.Enabled := True;
end;

function NewTimer(Interval: Cardinal): ITimer;
begin
  Result := TTimer.Create(Interval);
end;

function XtractFileName(const FileName: string): string;
var
  I: Integer;
begin
  I := FileName.LastDelimiter(PathDelim + DriveDelim + '/');
  Result := FileName.SubString(I + 1);
end;

function XtractFileDir(const FileName: string): string;
var
  I: Integer;
begin
  I := FileName.LastDelimiter(PathDelim + DriveDelim + '/');
  if (I > 0) and ((FileName.Chars[I] = PathDelim) or (FileName.Chars[I] = '/')) and
    (not FileName.IsDelimiter(PathDelim + DriveDelim + '/', I-1)) then Dec(I);
  Result := FileName.SubString(0, I + 1);
end;

function CtrlHandler( fdwCtrlType : DWORD): LongBool; stdcall;
begin
  Result := True;
end;

procedure RaiseKeyboardInterrupt(ProcessId: DWORD);
Var
  AttachConsole: Function (dwProcessId: DWORD): LongBool; stdCall;
begin
  AttachConsole := GetProcAddress (GetModuleHandle ('kernel32.dll'), 'AttachConsole');
  if Assigned(AttachConsole) then
  try
    OSCheck(AttachConsole(ProcessId));
    OSCheck(SetConsoleCtrlHandler(@CtrlHandler, True));
    try
      OSCheck(GenerateConsoleCtrlEvent(CTRL_C_EVENT, 0));
      Sleep(100);
    finally
      OSCheck(SetConsoleCtrlHandler(@CtrlHandler, False));
      OSCheck(FreeConsole);
    end;
  except
  end;
end;

type
  TProcessArray = array of DWORD;

 function TerminateProcessTree(ProcessID: DWORD): Boolean;

  function GetChildrenProcesses(const Process: DWORD; const IncludeParent: Boolean): TProcessArray;
  var
    Snapshot: Cardinal;
    ProcessList: PROCESSENTRY32;
    Current: Integer;
  begin
    Current := 0;
    SetLength(Result, 1);
    Result[0] := Process;
    repeat
      ProcessList.dwSize := SizeOf(PROCESSENTRY32);
      Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
      if (Snapshot = INVALID_HANDLE_VALUE) or not Process32First(Snapshot, ProcessList) then
        Continue;
      repeat
        if ProcessList.th32ParentProcessID = Result[Current] then
        begin
          SetLength(Result, Length(Result) + 1);
          Result[Length(Result) - 1] := ProcessList.th32ProcessID;
        end;
      until Process32Next(Snapshot, ProcessList) = False;
      Inc(Current);
    until Current >= Length(Result);
    if not IncludeParent then
      Result := Copy(Result, 2, Length(Result));
  end;

var
  Handle: THandle;
  List: TProcessArray;
  I: Integer;
begin
  Result := True;
  List := GetChildrenProcesses(ProcessID, True);
  for I := Length(List) - 1 downto 0 do
    if Result then
    begin
      Handle := OpenProcess(PROCESS_TERMINATE, false, List[I]);
      Result := (Handle <> 0) and TerminateProcess(Handle, 0) and CloseHandle(Handle);
    end;
end;

function ExecuteCmd(Command : string; out CmdOutput, CmdError: string): cardinal; overload;
Var
  ProcessOptions : TJclExecuteCmdProcessOptions;
begin
  ProcessOptions := TJclExecuteCmdProcessOptions.Create(Command);
  try
    ProcessOptions.MergeError := False;
    ProcessOptions.RawOutput := True;
    ProcessOptions.RawError := True;
    ProcessOptions.AutoConvertOEM := False;
    ProcessOptions.CreateProcessFlags :=
      ProcessOptions.CreateProcessFlags or
       CREATE_UNICODE_ENVIRONMENT or CREATE_NEW_CONSOLE;
    ExecuteCmdProcess(ProcessOptions);
    Result := ProcessOptions.ExitCode;
    CmdOutput := ProcessOptions.Output;
    CmdError := ProcessOptions.Error;
  finally
    ProcessOptions.Free;
  end;
end;

function ExecuteCmd(Command : string; out CmdOutput: string): cardinal; overload;
Var
  CmdError: string;
begin
  Result := ExecuteCmd(Command, CmdOutput, CmdError);
end;

function FileExtInFileFilter(FileExt, FileFilter: string): Boolean;
var
  j, ExtLen: Integer;
begin
  Result := False;
  ExtLen := FileExt.Length;
  if ExtLen = 0 then
    Exit;
  FileExt := LowerCase(FileExt);
  FileFilter := LowerCase(FileFilter);
  j := Pos('|', FileFilter);
  if j > 0 then begin
    Delete(FileFilter, 1, j);
    j := Pos(FileExt, FileFilter);
    if (j > 0) and
       ((j + ExtLen > Length(FileFilter)) or (FileFilter[j + ExtLen] = ';'))
    then
      Exit(True);
  end;
end;

function FileIsPythonSource(FileName: string): Boolean;
Var
  Ext: string;
begin
  Ext := ExtractFileExt(FileName);
  if Ext = '' then
    Exit(False);
  Result := FileExtInFileFilter(Ext, PyIDEOptions.PythonFileFilter);
end;

function StyledMessageDlg(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;
begin
  UseLatestCommonDialogs := False;
  Result := Vcl.Dialogs.MessageDlg(Msg, DlgType, Buttons, HelpCtx);
  UseLatestCommonDialogs := True;
end;

function StyledMessageDlg(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; DefaultButton: TMsgDlgBtn): Integer;
begin
  UseLatestCommonDialogs := False;
  Result := Vcl.Dialogs.MessageDlg(Msg, DlgType, Buttons, HelpCtx, DefaultButton);
  UseLatestCommonDialogs := True;
end;

function SvgFixedColor(Color: TColor): TColor;
begin
  Result := StyleServices.GetSystemColor(Color);
  if Result = clBlack then
    Result := $191919
  else if Result = clWhite then
    Result := $E6E6E6;
end;

//  Regular Expressions Start
type
  { TPerlRegExHelper }
  TPerlRegExHelper = class helper for TPerlRegEx
    procedure SetAdditionalPCREOptions(PCREOptions : Integer);
  end;

procedure TPerlRegExHelper.SetAdditionalPCREOptions(PCREOptions: Integer);
begin
  with Self do FPCREOptions := FPCREOptions or PCREOptions;
end;

{ TRegExHelper }
procedure TRegExHelper.Study;
begin
  with Self do FRegEx.Study;
end;

function TRegExHelper.PerlRegEx: TPerlRegEx;
begin
  with Self do
    Result := FregEx;
end;

procedure TRegExHelper.SetAdditionalPCREOptions(PCREOptions: Integer);
begin
  with Self do FRegEx.SetAdditionalPCREOptions(PCREOptions);
end;

{ TMatchHelper }

function TMatchHelper.GroupIndex(Index: integer): integer;
begin
  if Index < Groups.Count then
    Result := Groups[Index].Index
  else
    Result := -1;
end;

function TMatchHelper.GroupLength(Index: integer): integer;
begin
  if Index < Groups.Count then
    Result := Groups[Index].Length
  else
    Result := 0;
end;

function TMatchHelper.GroupValue(Index: integer): string;
begin
  if Index < Groups.Count then
    Result := Groups[Index].Value
  else
    Result := '';
end;
//  Regular Expressions End

procedure RedirectFunction(OrgProc, NewProc: Pointer);
{
  From spring4d
  See https://devblogs.microsoft.com/oldnewthing/20181206-00/?p=100415
  in relation to the use of WriteProcessMemory
}
type
  TJmpBuffer = packed record
    Jmp: Byte;
    Offset: Integer;
  end;
var
  n: NativeUInt;
  JmpBuffer: TJmpBuffer;
begin
  JmpBuffer.Jmp := $E9;
  JmpBuffer.Offset := PByte(NewProc) - (PByte(OrgProc) + 5);
  if not WriteProcessMemory(GetCurrentProcess, OrgProc, @JmpBuffer, SizeOf(JmpBuffer), n) then
    RaiseLastOSError;
  FlushInstructionCache(GetCurrentProcess, OrgProc, SizeOf(JmpBuffer))
end;


{https://stackoverflow.com/questions/20142166/explain-errors-from-getkeystate-getcursorpos}

function PatchedGetCursorPos(var lpPoint: TPoint): BOOL; stdcall;
(* The GetCursorPos API in user32 fails if it is passed a memory address >2GB
   which breaks LARGEADDRESSAWARE apps.  We counter this by calling GetCursorInfo
   instead which does not suffer from the same problem.

   In addition we have had problems with GetCursorPos failing when called
   immediately after a password protected screensaver or a locked workstation
   re-authenticates. This problem initially appeared with XP SP1 and is brought
   about because TMouse.GetCursorPos checks the return value of the GetCursorPos
   API call and raises an OS exception if the API has failed.
*)
var
  CursorInfo: TCursorInfo;
begin
  CursorInfo.cbSize := SizeOf(CursorInfo);
  Result := GetCursorInfo(CursorInfo);
  if Result then begin
    lpPoint := CursorInfo.ptScreenPos;
  end else begin
    lpPoint := Point(0, 0);
  end;
end;

var
  OldGetCursorPos: function(var lpPoint: TPoint): BOOL; stdcall = nil;

{ TFormHelper }

function TControlHelper.PPIScale(ASize: integer): integer;
begin
   Result := MulDiv(ASize, FCurrentPPI, 96);
end;

function TControlHelper.PPIUnScale(ASize: integer): integer;
begin
   Result := MulDiv(ASize, 96, FCurrentPPI);
end;

{ TObjectHandle }

constructor  TObjectHandle<T>.Create(AValue:  T);
begin
  FValue  :=  AValue;
end;

destructor  TObjectHandle<T>.Destroy;
begin
  FValue.Free;
end;

function  TObjectHandle<T>.Invoke:  T;
begin
  Result  :=  FValue;
end;


{ TSmartPointer }

class function TSmartPtr.Make<T>(AValue: T): TFunc<T>;
begin
  Result := TObjectHandle<T>.Create(AValue);
end;


initialization
  StopWatch := TStopWatch.StartNew;

  @OldGetCursorPos := GetProcAddress(GetModuleHandle(user32), 'GetCursorPos');
  with TJclPeMapImgHooks do
    ReplaceImport(SystemBase, user32, @OldGetCursorPos, @PatchedGetCursorPos);

finalization
 with TJclPeMapImgHooks do
   ReplaceImport(SystemBase, user32, @PatchedGetCursorPos, @OldGetCursorPos);
end.
