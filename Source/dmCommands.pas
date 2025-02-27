{-----------------------------------------------------------------------------
 Unit Name: dmCommands
 Author:    Kiriakos Vlahos
 Date:      09-Mar-2005
 Purpose:   Data Module of PyScripter
 History:
-----------------------------------------------------------------------------}

unit dmCommands;

interface

uses
  WinApi.Windows,
  WinApi.Messages,
  System.Types,
  System.UITypes,
  System.SysUtils,
  System.Classes,
  System.Actions,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ActnList,
  Vcl.StdActns,
  Vcl.ImgList,
  Vcl.BaseImageCollection,
  SVGIconImageCollection,
  SVGIconImage,
  SynEdit,
  SynEditPrint,
  SynUnicode,
  SynEditRegexSearch,
  SynEditHighlighter,
  SynCompletionProposal,
  SynEditMiscClasses,
  SynEditSearch,
  SynEditTextBuffer,
  SynEditKeyCmds,
  SynEditCodeFolding,
  SynEditTypes,
  SynHighlighterPython,
  SynHighlighterIni,
  SynHighlighterWeb,
  SynHighlighterCpp,
  SynHighlighterYAML,
  SynHighlighterJSON,
  SynHighlighterGeneral,
  JvComponentBase,
  JvProgramVersionCheck,
  JvPropertyStore,
  JvStringHolder,
  VirtualExplorerTree,
  VirtualShellNotifier,
  dlgSynEditOptions,
  dlgOptionsEditor,
  uEditAppIntfs,
  cPyBaseDebugger;

type
  TSearchCaseSensitiveType = (scsAuto, scsNotCaseSenitive, scsCaseSensitive);

  TEditorSearchOptions = class(TPersistent)
  private
    fSearchBackwards: boolean;
    fSearchCaseSensitiveType: TSearchCaseSensitiveType;
    fSearchFromCaret: boolean;
    fSearchSelectionOnly: boolean;
    fSearchTextAtCaret: boolean;
    fSearchWholeWords: boolean;
    fUseRegExp: boolean;
    fIncrementalSearch: boolean;

    fSearchText: string;
    fSearchTextHistory: string;
    fReplaceText: string;
    fReplaceTextHistory: string;

    fTempSearchFromCaret: boolean;
    fInitBlockBegin : TBufferCoord;
    fInitBlockEnd : TBufferCoord;
    fInitCaretXY : TBufferCoord;
    fLastReplaceAction: TSynReplaceAction;
    fTempSelectionOnly : boolean;
    fNoReplaceCount : integer;
    fWrappedSearch : boolean;
    fCanWrapSearch : boolean;
    fBackwardSearch : boolean;
    fInterpreterIsSearchTarget : Boolean;
  public
    procedure Assign(Source: TPersistent); override;
    procedure InitSearch;
    procedure NewSearch(SynEdit : TSynEdit; ABackwards : Boolean);
    property SearchBackwards: boolean read fSearchBackwards write fSearchBackwards;
    property SearchText: string read fSearchText write fSearchText;
    property ReplaceText: string read fReplaceText write fReplaceText;
    property TempSearchFromCaret: boolean read fTempSearchFromCaret write fTempSearchFromCaret;
    property TempSelectionOnly: boolean read fTempSelectionOnly write fTempSelectionOnly;
    property NoReplaceCount: integer read fNoReplaceCount write fNoReplaceCount;
    property LastReplaceAction: TSynReplaceAction read fLastReplaceAction write fLastReplaceAction;
    property CanWrapSearch: boolean read fCanWrapSearch write fCanWrapSearch;
    property WrappedSearch: boolean read fWrappedSearch write fWrappedSearch;
    property BackwardSearch: boolean read fBackwardSearch write fBackwardSearch;
    property InitBlockBegin : TBufferCoord read fInitBlockBegin write fInitBlockBegin;
    property InitBlockEnd : TBufferCoord read fInitBlockEnd write fInitBlockEnd;
    property InitCaretXY : TBufferCoord read fInitCaretXY write fInitCaretXY;
    property InterpreterIsSearchTarget : Boolean read fInterpreterIsSearchTarget write fInterpreterIsSearchTarget;
  published
    property SearchTextHistory: string read fSearchTextHistory write fSearchTextHistory;
    property ReplaceTextHistory: string read fReplaceTextHistory write fReplaceTextHistory;
    property SearchSelectionOnly: boolean read fSearchSelectionOnly write fSearchSelectionOnly;
    property SearchCaseSensitiveType: TSearchCaseSensitiveType read fSearchCaseSensitiveType write fSearchCaseSensitiveType;
    property SearchFromCaret: boolean read fSearchFromCaret write fSearchFromCaret;
    property SearchTextAtCaret: boolean read fSearchTextAtCaret write fSearchTextAtCaret;
    property SearchWholeWords: boolean read fSearchWholeWords write fSearchWholeWords;
    property UseRegExp: boolean read fUseRegExp write fUseRegExp;
    property IncrementalSearch: boolean read fIncrementalSearch write fIncrementalSearch;
  end;

  TSynGeneralSyn = class(SynHighlighterGeneral.TSynGeneralSyn)
  public
    class function GetFriendlyLanguageName: string; override;
  end;

  TCommandsDataModule = class(TDataModule)
    SynEditPrint: TSynEditPrint;
    PrintDialog: TPrintDialog;
    PrinterSetupDialog: TPrinterSetupDialog;
    ParameterCompletion: TSynCompletionProposal;
    ModifierCompletion: TSynCompletionProposal;
    CodeTemplatesCompletion: TSynAutoComplete;
    ShellImages: TImageList;
    SynEditSearch: TSynEditSearch;
    SynEditRegexSearch: TSynEditRegexSearch;
    ProgramVersionCheck: TJvProgramVersionCheck;
    ProgramVersionHTTPLocation: TJvProgramVersionHTTPLocation;
    SynIniSyn: TSynIniSyn;
    JvMultiStringHolder: TJvMultiStringHolder;
    dlgFileOpen: TOpenDialog;
    dlgFileSave: TSaveDialog;
    SynWebHtmlSyn: TSynWebHtmlSyn;
    SynWebXmlSyn: TSynWebXmlSyn;
    SynWebCssSyn: TSynWebCssSyn;
    SynCppSyn: TSynCppSyn;
    SynWebEngine: TSynWebEngine;
    actlMain: TActionList;
    actPythonManuals: THelpContents;
    actHelpContents: THelpContents;
    actEditSelectAll: TEditSelectAll;
    actEditUndo: TEditUndo;
    actEditDelete: TEditDelete;
    actEditPaste: TEditPaste;
    actEditCopy: TEditCopy;
    actEditCut: TEditCut;
    actFileCloseAllOther: TAction;
    actHelpWebGroupSupport: TAction;
    actHelpWebProjectHome: TAction;
    actSearchGoToDebugLine: TAction;
    actEditWordWrap: TAction;
    actSearchHighlight: TAction;
    actSearchReplaceNow: TAction;
    actExportHighlighters: TAction;
    actImportHighlighters: TAction;
    actExportShortCuts: TAction;
    actImportShortcuts: TAction;
    actFileReload: TAction;
    actEditUTF16BE: TAction;
    actEditUTF16LE: TAction;
    actEditUTF8NoBOM: TAction;
    actEditUTF8: TAction;
    actFileTemplates: TAction;
    actEditToggleComment: TAction;
    actInterpreterEditorOptions: TAction;
    actUnitTestWizard: TAction;
    actCheckForUpdates: TAction;
    actHelpEditorShortcuts: TAction;
    actEditAnsi: TAction;
    actEditLBMac: TAction;
    actEditLBUnix: TAction;
    actEditLBDos: TAction;
    actFindNextReference: TAction;
    actFindPreviousReference: TAction;
    actEditShowSpecialChars: TAction;
    actEditLineNumbers: TAction;
    actFindFunction: TAction;
    actHelpExternalTools: TAction;
    actConfigureTools: TAction;
    actCodeTemplates: TAction;
    actIDEShortcuts: TAction;
    actCustomizeParameters: TAction;
    actInsertTemplate: TAction;
    actHelpParameters: TAction;
    actReplaceParameters: TAction;
    actModifierCompletion: TAction;
    actParameterCompletion: TAction;
    actFindInFiles: TAction;
    actSearchGoToSyntaxError: TAction;
    actSearchGoToLine: TAction;
    actAbout: TAction;
    actPythonPath: TAction;
    actEditUntabify: TAction;
    actEditTabify: TAction;
    actSearchMatchingBrace: TAction;
    actEditUncomment: TAction;
    actEditCommentOut: TAction;
    actEditDedent: TAction;
    actEditIndent: TAction;
    actIDEOptions: TAction;
    actEditorOptions: TAction;
    actPageSetup: TAction;
    actPrintPreview: TAction;
    actPrinterSetup: TAction;
    actFilePrint: TAction;
    actFileSaveAll: TAction;
    actSearchReplace: TAction;
    actSearchFindPrev: TAction;
    actSearchFindNext: TAction;
    actSearchFind: TAction;
    actEditRedo: TAction;
    actFileClose: TAction;
    actFileSaveAs: TAction;
    actFileSave: TAction;
    actEditCopyFileName: TAction;
    actToolsEditStartupScripts: TAction;
    SynWebEsSyn: TSynWebEsSyn;
    SynWebPhpPlainSyn: TSynWebPhpPlainSyn;
    actHelpWebBlog: TAction;
    actFoldVisible: TAction;
    actFoldAll: TAction;
    actUnfoldAll: TAction;
    actFoldNearest: TAction;
    actUnfoldNearest: TAction;
    actFoldRegions: TAction;
    actUnfoldRegions: TAction;
    actFoldLevel1: TAction;
    actUnfoldLevel1: TAction;
    actFoldLevel2: TAction;
    actUnfoldLevel2: TAction;
    actFoldLevel3: TAction;
    actUnfoldLevel3: TAction;
    actFoldClasses: TAction;
    actUnfoldClasses: TAction;
    actFoldFunctions: TAction;
    actUnfoldFunctions: TAction;
    SynGeneralSyn: TSynGeneralSyn;
    SynJSONSyn: TSynJSONSyn;
    actFileCloseAllToTheRight: TAction;
    actEditReadOnly: TAction;
    actFileSaveToRemote: TAction;
    actDonate: TAction;
    icBrowserImages: TSVGIconImageCollection;
    icCodeImages: TSVGIconImageCollection;
    icGutterGlyphs: TSVGIconImageCollection;
    icSVGImages: TSVGIconImageCollection;
    SynWebCompletion: TSynCompletionProposal;
    SynParamCompletion: TSynCompletionProposal;
    SynCodeCompletion: TSynCompletionProposal;
    actToolsRestartLS: TAction;
    function ProgramVersionHTTPLocationLoadFileFromRemote(
      AProgramVersionLocation: TJvProgramVersionHTTPLocation; const ARemotePath,
      ARemoteFileName, ALocalPath, ALocalFileName: string): string;
    procedure actCheckForUpdatesExecute(Sender: TObject);
    procedure actUnitTestWizardExecute(Sender: TObject);
    procedure actIDEShortcutsExecute(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure actFileSaveExecute(Sender: TObject);
    procedure actFileSaveAsExecute(Sender: TObject);
    procedure actFilePrintExecute(Sender: TObject);
    procedure actFileCloseExecute(Sender: TObject);
    procedure actEditCutExecute(Sender: TObject);
    procedure actEditCopyExecute(Sender: TObject);
    procedure actEditPasteExecute(Sender: TObject);
    procedure actEditDeleteExecute(Sender: TObject);
    procedure actEditSelectAllExecute(Sender: TObject);
    procedure actEditRedoExecute(Sender: TObject);
    procedure actEditUndoExecute(Sender: TObject);
    procedure actSearchFindExecute(Sender: TObject);
    procedure actSearchFindNextExecute(Sender: TObject);
    procedure actSearchFindPrevExecute(Sender: TObject);
    procedure actSearchReplaceExecute(Sender: TObject);
    procedure actFileSaveAllExecute(Sender: TObject);
    procedure actPrinterSetupExecute(Sender: TObject);
    procedure actPageSetupExecute(Sender: TObject);
    procedure actPrintPreviewExecute(Sender: TObject);
    procedure actEditorOptionsExecute(Sender: TObject);
    procedure actEditIndentExecute(Sender: TObject);
    procedure actEditDedentExecute(Sender: TObject);
    procedure actEditCommentOutExecute(Sender: TObject);
    procedure actEditUncommentExecute(Sender: TObject);
    procedure actSearchMatchingBraceExecute(Sender: TObject);
    procedure actEditTabifyExecute(Sender: TObject);
    procedure actEditUntabifyExecute(Sender: TObject);
    procedure actIDEOptionsExecute(Sender: TObject);
    procedure actPythonPathExecute(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure actPythonManualsExecute(Sender: TObject);
    procedure UpdateMainActions;
    procedure actSearchGoToLineExecute(Sender: TObject);
    procedure actFindInFilesExecute(Sender: TObject);
    procedure actHelpContentsExecute(Sender: TObject);
    procedure ParameterCompletionCodeCompletion(Sender: TObject;
      var Value: string; Shift: TShiftState; Index: Integer;
      EndToken: WideChar);
    procedure ModifierCompletionCodeCompletion(Sender: TObject;
      var Value: string; Shift: TShiftState; Index: Integer;
      EndToken: WideChar);
    procedure actParameterCompletionExecute(Sender: TObject);
    procedure actModifierCompletionExecute(Sender: TObject);
    procedure actReplaceParametersExecute(Sender: TObject);
    procedure actHelpParametersExecute(Sender: TObject);
    procedure actInsertTemplateExecute(Sender: TObject);
    procedure actCustomizeParametersExecute(Sender: TObject);
    procedure actCodeTemplatesExecute(Sender: TObject);
    procedure actConfigureToolsExecute(Sender: TObject);
    procedure actHelpExternalToolsExecute(Sender: TObject);
    procedure actFindFunctionExecute(Sender: TObject);
    procedure actEditLineNumbersExecute(Sender: TObject);
    procedure actEditShowSpecialCharsExecute(Sender: TObject);
    procedure actFindNextReferenceExecute(Sender: TObject);
    procedure actEditLBExecute(Sender: TObject);
    procedure actHelpEditorShortcutsExecute(Sender: TObject);
    procedure actInterpreterEditorOptionsExecute(Sender: TObject);
    procedure actEditToggleCommentExecute(Sender: TObject);
    procedure actFileTemplatesExecute(Sender: TObject);
    procedure actEditFileEncodingExecute(Sender: TObject);
    procedure actFileReloadExecute(Sender: TObject);
    procedure actExportShortCutsExecute(Sender: TObject);
    procedure actImportShortcutsExecute(Sender: TObject);
    procedure actExportHighlightersExecute(Sender: TObject);
    procedure actImportHighlightersExecute(Sender: TObject);
    procedure actSearchReplaceNowExecute(Sender: TObject);
    procedure actSearchGoToSyntaxErrorExecute(Sender: TObject);
    procedure actSearchHighlightExecute(Sender: TObject);
    procedure actEditWordWrapExecute(Sender: TObject);
    procedure actSearchGoToDebugLineExecute(Sender: TObject);
    procedure actHelpWebProjectHomeExecute(Sender: TObject);
    procedure actHelpWebGroupSupportExecute(Sender: TObject);
    procedure actFileCloseWorkspaceTabsExecute(Sender: TObject);
    procedure actEditCopyFileNameExecute(Sender: TObject);
    procedure actToolsEditStartupScriptsExecute(Sender: TObject);
    procedure actHelpWebBlogExecute(Sender: TObject);
    procedure actFoldVisibleExecute(Sender: TObject);
    procedure actFoldAllExecute(Sender: TObject);
    procedure actUnfoldAllExecute(Sender: TObject);
    procedure actFoldNearestExecute(Sender: TObject);
    procedure actUnfoldNearestExecute(Sender: TObject);
    procedure actUnfoldRegionsExecute(Sender: TObject);
    procedure actFoldRegionsExecute(Sender: TObject);
    procedure actUnfoldLevel1Execute(Sender: TObject);
    procedure actFoldLevel1Execute(Sender: TObject);
    procedure actFoldLevel2Execute(Sender: TObject);
    procedure actUnfoldLevel2Execute(Sender: TObject);
    procedure actFoldLevel3Execute(Sender: TObject);
    procedure actUnfoldLevel3Execute(Sender: TObject);
    procedure actFoldClassesExecute(Sender: TObject);
    procedure actUnfoldClassesExecute(Sender: TObject);
    procedure actFoldFunctionsExecute(Sender: TObject);
    procedure actUnfoldFunctionsExecute(Sender: TObject);
    procedure actEditReadOnlyExecute(Sender: TObject);
    procedure actFileSaveToRemoteExecute(Sender: TObject);
    procedure actDonateExecute(Sender: TObject);
    procedure actToolsRestartLSExecute(Sender: TObject);
    procedure ParameterCompletionExecute(Kind: SynCompletionType;
      Sender: TObject; var CurrentInput: string; var x, y: Integer;
      var CanExecute: Boolean);
    procedure ModifierCompletionExecute(Kind: SynCompletionType;
      Sender: TObject; var CurrentInput: string; var x, y: Integer;
      var CanExecute: Boolean);
  private
    fHighlighters: TStrings;
    fUntitledNumbers: TBits;
    fConfirmReplaceDialogRect: TRect;
    procedure PyIDEOptionsChanged(Sender: TObject);
  protected
    procedure Loaded; override;
  public
    SynPythonSyn: TSynPythonSyn;
    SynYAMLSyn: TSynYAMLSyn;
    SynCythonSyn: TSynCythonSyn;
    function GetHighlighterForFile(AFileName: string): TSynCustomHighlighter;
    class function IsHighlighterStored(Highlighter: TObject): Boolean;
    procedure SynEditOptionsDialogGetHighlighterCount(Sender: TObject;
                var Count: Integer);
    procedure SynEditOptionsDialogGetHighlighter(Sender: TObject;
                Index: Integer; var SynHighlighter: TSynCustomHighlighter);
    procedure SynEditOptionsDialogSetHighlighter(Sender: TObject;
                Index: Integer; SynHighlighter: TSynCustomHighlighter);
    procedure SynInterpreterOptionsDialogGetHighlighterCount(Sender: TObject;
                var Count: Integer);
    procedure SynInterpreterOptionsDialogGetHighlighter(Sender: TObject;
                Index: Integer; var SynHighlighter: TSynCustomHighlighter);
    procedure SynInterpreterOptionsDialogSetHighlighter(Sender: TObject;
                Index: Integer; SynHighlighter: TSynCustomHighlighter);
    function GetSaveFileName(var ANewName: string;
      AHighlighter: TSynCustomHighlighter; DefaultExtension : string): boolean;
    function GetUntitledNumber: integer;
    procedure ReleaseUntitledNumber(ANumber: integer);
    procedure PaintMatchingBrackets(SynEdit : TSynEdit; TransientType:
        TTransientType);
    function ShowPythonKeywordHelp(KeyWord : string) : Boolean;
    procedure PrepareParameterCompletion;
    procedure PrepareModifierCompletion;
    procedure GetEditorUserCommand(AUserCommand: Integer; var ADescription: string);
    procedure GetEditorAllUserCommands(ACommands: TStrings);
    function DoSearchReplaceText(SynEdit : TSynEdit;
      AReplace, ABackwards : Boolean ; IsIncremental : Boolean = False) : integer;
    procedure ShowSearchReplaceDialog(SynEdit : TSynEdit; AReplace: boolean);
    procedure SynEditReplaceText(Sender: TObject; const ASearch,
      AReplace: string; Line, Column: Integer; var Action: TSynReplaceAction);
    procedure IncrementalSearch;
    procedure ApplyEditorOptions;
    procedure ProcessShellNotify(Sender: TCustomVirtualExplorerTree; ShellEvent: TVirtualShellEvent);
    procedure ProcessFolderChange(const FolderName: string);
    function FindSearchTarget : ISearchCommands;
    procedure HighlightWordInActiveEditor(SearchWord : string);
    procedure UpdateImageCollections;
    property Highlighters : TStrings read fHighlighters;
  end;

{$SCOPEDENUMS ON}
  TCodeImages =(
    Python,
    Variable,
    Field,
    Func,
    Method,
    Klass,
    Namespace,
    List,
    Module,
    Keyword
  );
{$SCOPEDENUMS OFF}

function GetMatchingBracket(SynEdit : TSynEdit) : TBufferCoord;

var
  CommandsDataModule: TCommandsDataModule = nil;
  EditorSearchOptions : TEditorSearchOptions;

implementation

{$R *.DFM}

uses
  WinApi.WinInet,
  WinApi.ShlObj,
  WinApi.ShellAPI,
  System.Win.Registry,
  System.StrUtils,
  System.DateUtils,
  System.Variants,
  System.IOUtils,
  System.IniFiles,
  Vcl.Clipbrd,
  Vcl.Themes,
  MPShellUtilities,
  MPCommonUtilities,
  SpTBXMDIMRU,
  SpTBXItem,
  SpTBXTabs,
  PythonEngine,
  JclSysUtils,
  JclStrings,
  JclDebug,
  JvAppIniStorage,
  JvAppStorage,
  JvDSADialogs,
  JvJCLUtils,
  JvDynControlEngineVCL,
  JvGnugettext,
  StringResources,
  dlgSynPageSetup,
  dlgDirectoryList,
  dlgAboutPyScripter,
  dlgConfirmReplace,
  dlgCustomShortcuts,
  dlgUnitTestWizard,
  dlgFileTemplates,
  dlgPickList,
  dlgCodeTemplates,
  dlgCollectionEditor,
  dlgToolProperties,
  dlgCustomParams,
  frmPythonII,
  frmPyIDEMain,
  frmEditor,
  frmFindResults,
  frmFunctionList,
  JediLspClient,
  uHighlighterProcs,
  uParams,
  uCommonFunctions,
  uSearchHighlighter,
  cTools,
  cPySupportTypes,
  cPyScripterSettings,
  cParameters,
  cPyControl;


{ TEditorSearchOptions }

procedure TEditorSearchOptions.Assign(Source: TPersistent);
begin
  if Source is TEditorSearchOptions then
    with TEditorSearchOptions(Source) do begin
      Self.fSearchBackwards := SearchBackwards;
      Self.fSearchCaseSensitiveType := SearchCaseSensitiveType;
      Self.fSearchFromCaret := SearchFromCaret;
      Self.fTempSearchFromCaret := TempSearchFromCaret;
      Self.fSearchSelectionOnly := SearchSelectionOnly;
      Self.fSearchTextAtCaret := SearchTextAtCaret;
      Self.fSearchWholeWords := SearchWholeWords;
      Self.fUseRegExp := UseRegExp;
      Self.fIncrementalSearch := IncrementalSearch;

      Self.fSearchText := SearchText;
      Self.fSearchTextHistory := SearchTextHistory;
      Self.fReplaceText := ReplaceText;
      Self.fReplaceTextHistory := ReplaceTextHistory;
    end
  else
    inherited;
end;

procedure TEditorSearchOptions.InitSearch;
begin
  TempSearchFromCaret := SearchFromCaret;
  LastReplaceAction := raReplace;
  InitBlockBegin := BufferCoord(0, 0);
end;

procedure TEditorSearchOptions.NewSearch(SynEdit : TSynEdit; ABackwards : Boolean);

  function BC_GT(BC1, BC2 : TBufferCoord): Boolean;
  begin
    Result := (BC1.Line > BC2.Line) or (BC1.Line = BC2.Line) and (BC1.Char > BC2.Char);
  end;

  function FindTextInBlock(Strings : TStrings; BlockBegin, BlockEnd : TBufferCoord) : Boolean;
  Var
    Line :  integer;
    S : string;
  begin
    Result := False;
    // preconditions start
    Assert(BlockBegin.Line <= Strings.Count);
    Assert(BlockEnd.Line <= Strings.Count);
    Assert(BlockBegin.Line <= BlockEnd.Line);
    if BlockBegin.Line <= 0 then Exit;
    if BlockEnd.Line <= 0 then Exit;
    // preconditions end

    // work backwards
    Line := BlockEnd.Line;
    S := System.StrUtils.LeftStr(Strings[Line-1], BlockEnd.Char - 1);
    Repeat
      Result := SynEdit.SearchEngine.FindAll(S) > 0;
      Dec(Line);
      if Line >= BlockBegin.Line then
        S := Strings[Line-1]
      else
        break;
      if Line = BlockBegin.Line then
        Delete(S, 1, BlockBegin.Char -1);
    Until Result;
  end;

Var
  //TextLeft : string;
  SearchOptions : TSynSearchOptions;
begin
  InitSearch;
  BackwardSearch := ABackwards;
  WrappedSearch := False;
  TempSelectionOnly := SearchSelectionOnly and SynEdit.SelAvail;
  if TempSelectionOnly then begin
    InitBlockBegin := SynEdit.BlockBegin;
    InitBlockEnd := SynEdit.BlockEnd;
  end else begin
    InitBlockBegin := BufferCoord(1, 1);
    InitBlockEnd  := BufferCoord(Length(SynEdit.Lines[SynEdit.Lines.Count - 1]) + 1,
                                 SynEdit.Lines.Count);
  end;

  if TempSelectionOnly then begin
    if ABackwards then
      InitCaretXY := InitBlockEnd
    else
      InitCaretXY := InitBlockBegin;
  end else begin
    if ABackwards then
      SynEdit.CaretXY := SynEdit.BlockBegin
    else
      SynEdit.CaretXY := SynEdit.BlockEnd;
    InitCaretXY := SynEdit.CaretXY;
  end;

  CanWrapSearch := (ABackwards and BC_GT(InitBlockEnd, InitCaretXY) or
             (not ABackwards and BC_GT(InitCaretXY, InitBlockBegin)));
  if CanWrapSearch then begin
//    if ABackwards then
//      TextLeft := GetBlockText(SynEdit.Lines, InitCaretXY, InitBlockEnd)
//    else
//      TextLeft := GetBlockText(SynEdit.Lines, InitBlockBegin, InitCaretXY);
    SearchOptions := [];

    case SearchCaseSensitiveType of
      scsAuto:           if LowerCase(SearchText) <> SearchText then
                           Include(SearchOptions, ssoMatchCase);
      scsCaseSensitive : Include(SearchOptions, ssoMatchCase);
    end;
    if SearchWholeWords then
      Include(SearchOptions, ssoWholeWord);
    SynEdit.SearchEngine.Options := SearchOptions;
    try
      SynEdit.SearchEngine.Pattern := ''; //  To deal with case sensitivity
      SynEdit.SearchEngine.Pattern := SearchText;
      if ABackwards then
        CanWrapSearch := FindTextInBlock(SynEdit.Lines, InitCaretXY, InitBlockEnd)
      else
        CanWrapSearch := FindTextInBlock(SynEdit.Lines, InitBlockBegin, InitCaretXY);
    except
      on E: ESynRegEx do begin
        CanWrapSearch := False;
      end;
    end;
  end;
end;

{ TCommandsDataModule }

procedure TCommandsDataModule.DataModuleCreate(Sender: TObject);
var
  SHFileInfo: TSHFileInfo;
  Index : integer;
begin
  // Setup Highlighters
  SynPythonSyn := TSynPythonSyn.Create(Self);
  SynYAMLSyn := TSynYAMLSyn.Create(Self);
  SynCythonSyn := TSynCythonSyn.Create(Self);
  SynCythonSyn.Assign(SynPythonSyn);
  SynCythonSyn.DefaultFilter := PyIDEOptions.CythonFileFilter;
  fHighlighters := TStringList.Create;
  TStringList(fHighlighters).CaseSensitive := False;
  GetHighlighters(Self, fHighlighters, False);
  TStringList(fHighlighters).Sort;

  //  Place Python first
  Index := fHighlighters.IndexOf(SynPythonSyn.FriendlyLanguageName);
  if Index >= 0 then fHighlighters.Delete(Index);
  fHighlighters.InsertObject(0, SynPythonSyn.FriendlyLanguageName, SynPythonSyn);
  //  Place Cython before last
  Index := fHighlighters.IndexOf(SynCythonSyn.FriendlyLanguageName);
  if Index >= 0 then fHighlighters.Delete(Index);
  fHighlighters.AddObject(SynCythonSyn.FriendlyLanguageName, SynCythonSyn);
  //  Place General highlighter last
  Index := fHighlighters.IndexOf(SynGeneralSyn.FriendlyLanguageName);
  if Index >= 0 then fHighlighters.Delete(Index);
  fHighlighters.AddObject(SynGeneralSyn.FriendlyLanguageName, SynGeneralSyn);

  // SynWeb Highlighters do not provide default filters
  SynWebHTMLSyn.DefaultFilter := PyIDEOptions.HTMLFileFilter;
  SynWebXMLSyn.DefaultFilter := PyIDEOptions.XMLFileFilter;
  SynWebCssSyn.DefaultFilter := PyIDEOptions.CSSFileFilter;
  SynWebEsSyn.DefaultFilter := PyIDEOptions.JSFileFilter;
  SynWebPhpPlainSyn.DefaultFilter := PyIDEOptions.PHPFileFilter;

  MaskFPUExceptions(PyIDEOptions.MaskFPUExceptions);

  // Setup the ShellIcon imagelist
  ShellImages.Handle := SHGetFileInfo('', 0, SHFileInfo, SizeOf(SHFileInfo),
    SHGFI_SYSICONINDEX or SHGFI_SMALLICON);

  PyIDEOptions.OnChange.AddHandler(PyIDEOptionsChanged);

  TPyScripterSettings.ShellImages := ShellImages;

  // Completion
  ParameterCompletion.FontsAreScaled := True;
  ModifierCompletion.FontsAreScaled := True;

  SynCodeCompletion.EndOfTokenChr := WordBreakString;
  SynCodeCompletion.FontsAreScaled := True;

  SynParamCompletion.EndOfTokenChr := WordBreakString;
  SynParamCompletion.FontsAreScaled := True;

  // Translate
  TranslateComponent(Self);
end;

procedure TCommandsDataModule.DataModuleDestroy(Sender: TObject);
begin
  fHighlighters.Free;
  fUntitledNumbers.Free;
  CommandsDataModule := nil;
  ShellImages.Handle := 0;
  PyIDEOptions.OnChange.RemoveHandler(PyIDEOptionsChanged);
end;

// implementation

function TCommandsDataModule.GetHighlighterForFile(
  AFileName: string): TSynCustomHighlighter;
begin
  if AFileName <> '' then
//    Result := GetHighlighterFromFileExt(fHighlighters, ExtractFileExt(AFileName))
    Result := GetHighlighterFromFileName(fHighlighters, AFileName)
  else
    Result := nil;
end;

procedure TCommandsDataModule.SynEditOptionsDialogGetHighlighterCount(Sender: TObject;
  var Count: Integer);
begin
   Count := fHighlighters.Count + 1; // The last one is the Python Interpreter
end;

procedure TCommandsDataModule.SynEditOptionsDialogGetHighlighter(Sender: TObject;
  Index: Integer; var SynHighlighter: TSynCustomHighlighter);
begin
   if (Index >= 0) and (Index < fHighlighters.Count) then
      SynHighlighter := fHighlighters.Objects[Index] as TSynCustomHighlighter
   else if Index = fHighlighters.Count then
     SynHighlighter := PythonIIForm.SynEdit.Highlighter
   else
     SynHighlighter := nil;
end;

procedure TCommandsDataModule.SynEditOptionsDialogSetHighlighter(Sender: TObject;
  Index: Integer; SynHighlighter: TSynCustomHighlighter);
begin
   if (Index >= 0) and (Index < fHighlighters.Count) then
     (fHighlighters.Objects[Index] as TSynCustomHighlighter).Assign(SynHighlighter)
   else if Index = fHighlighters.Count then
     PythonIIForm.SynEdit.Highlighter.Assign(SynHighlighter);
end;

procedure TCommandsDataModule.SynInterpreterOptionsDialogGetHighlighter(
  Sender: TObject; Index: Integer; var SynHighlighter: TSynCustomHighlighter);
begin
  if Index = 0 then
    SynHighlighter := PythonIIForm.SynEdit.Highlighter
  else
    SynHighlighter := nil;
end;

procedure TCommandsDataModule.SynInterpreterOptionsDialogGetHighlighterCount(
  Sender: TObject; var Count: Integer);
begin
  Count := 1;
end;

procedure TCommandsDataModule.SynInterpreterOptionsDialogSetHighlighter(
  Sender: TObject; Index: Integer; SynHighlighter: TSynCustomHighlighter);
begin
  if Index = 0 then
    PythonIIForm.SynEdit.Highlighter.Assign(SynHighlighter);
end;

function TCommandsDataModule.GetSaveFileName(var ANewName: string;
  AHighlighter: TSynCustomHighlighter; DefaultExtension : string): boolean;
begin
  with dlgFileSave do begin
    if ANewName <> '' then begin
      InitialDir := ExtractFileDir(ANewName);
      FileName := XtractFileName(ANewName);
      Title := Format(_(SSaveAs), [FileName]);
    end else begin
      InitialDir := '';
      FileName := '';
      Title := _(SSaveFileAs);
    end;
    if AHighlighter <> nil then
      Filter := _(AHighlighter.DefaultFilter)
    else
      Filter := _(SFilterAllFiles);

    DefaultExt := DefaultExtension;
    //  Make the current file extension the default extension
    if DefaultExt = '' then
      DefaultExt := ExtractFileExt(ANewName);

    if Execute then begin
      ANewName := FileName;
      Result := TRUE;
    end else
      Result := FALSE;
  end;
end;

function TCommandsDataModule.GetUntitledNumber: integer;
begin
  if fUntitledNumbers = nil then
    fUntitledNumbers := TBits.Create;
  Result := fUntitledNumbers.OpenBit;
  if Result = fUntitledNumbers.Size then
    fUntitledNumbers.Size := fUntitledNumbers.Size + 32;
  fUntitledNumbers[Result] := TRUE;
  Inc(Result);
end;

procedure TCommandsDataModule.HighlightWordInActiveEditor(SearchWord: string);
Var
  OldWholeWords : Boolean;
  OldSearchText : string;
begin
  EditorSearchOptions.InitSearch;
  OldWholeWords := EditorSearchOptions.SearchWholeWords;
  OldSearchText := EditorSearchOptions.SearchText;

  EditorSearchOptions.SearchWholeWords := True;
  EditorSearchOptions.SearchText := SearchWord;
  actSearchHighlight.Checked := True;
  actSearchHighlightExecute(Self);

  EditorSearchOptions.SearchWholeWords := OldWholeWords;
  EditorSearchOptions.SearchText := OldSearchText;
end;

procedure TCommandsDataModule.ReleaseUntitledNumber(ANumber: integer);
begin
  Dec(ANumber);
  if (fUntitledNumbers <> nil) and (ANumber >= 0)
    and (ANumber < fUntitledNumbers.Size)
  then
    fUntitledNumbers[ANumber] := FALSE;
end;

procedure TCommandsDataModule.actFileSaveExecute(Sender: TObject);
begin
  if GI_FileCmds <> nil then
    GI_FileCmds.ExecSave;
end;

procedure TCommandsDataModule.actFileSaveToRemoteExecute(Sender: TObject);
begin
  if GI_FileCmds <> nil then
    GI_FileCmds.ExecSaveAsRemote;
end;

procedure TCommandsDataModule.actFileSaveAsExecute(Sender: TObject);
begin
  if GI_FileCmds <> nil then
    GI_FileCmds.ExecSaveAs;
end;

procedure TCommandsDataModule.actFileSaveAllExecute(Sender: TObject);
begin
  GI_EditorFactory.ApplyToEditors(procedure(Editor: IEditor)
  begin
    var FileCommands := Editor as IFileCommands;
    if Assigned(FileCommands) and FileCommands.CanSave then
      FileCommands.ExecSave;
  end);
end;

procedure TCommandsDataModule.actFilePrintExecute(Sender: TObject);
begin
  if GI_FileCmds <> nil then
    GI_FileCmds.ExecPrint;
end;

procedure TCommandsDataModule.actFileReloadExecute(Sender: TObject);
begin
  if GI_FileCmds <> nil then
    GI_FileCmds.ExecReload;
end;

procedure TCommandsDataModule.actPrintPreviewExecute(Sender: TObject);
begin
  if GI_FileCmds <> nil then
    GI_FileCmds.ExecPrintPreview;
end;

procedure TCommandsDataModule.actPrinterSetupExecute(Sender: TObject);
begin
  PrinterSetupDialog.Execute;
end;

procedure TCommandsDataModule.actPageSetupExecute(Sender: TObject);
begin
  with TPageSetupDlg.Create(Self) do begin
    SetValues(SynEditPrint);
    if ShowModal = mrOk then
      GetValues(SynEditPrint);
    Release;
  end;
end;

procedure TCommandsDataModule.actFileCloseWorkspaceTabsExecute(Sender: TObject);

  procedure WorkspaceCloseOtherTabs(Editor: IEditor; Backwards: Boolean);
  var
    NextTab: TSpTBXTabItem;
    NextEditor: IEditor;
  begin
    repeat
      NextTab := TEditorForm(Editor.Form).ParentTabItem.GetNextTab(not BackWards, sivtNormal);
      if Assigned(NextTab) then
      begin
        NextEditor := PyIDEMainForm.EditorFromTab(NextTab);
        if Assigned(NextEditor) then
          if NextEditor.AskSaveChanges then
            NextEditor.Close
          else
            break;
      end;
    until not Assigned(NextTab);
  end;

Var
  Editor : IEditor;
begin
  Editor := GI_PyIDEServices.ActiveEditor;
  if not Assigned(Editor) then Exit;

  WorkspaceCloseOtherTabs(Editor, False);
  if (Sender as TBasicAction).Tag > 0 then
    WorkspaceCloseOtherTabs(Editor, True);

  Editor.Activate;
end;

procedure TCommandsDataModule.actFileCloseExecute(Sender: TObject);
Var
  Editor : IEditor;
begin
  Editor := GI_PyIDEServices.ActiveEditor;
  if Assigned(Editor) then
    (Editor as IFileCommands).ExecClose;
end;

procedure TCommandsDataModule.actEditCutExecute(Sender: TObject);
begin
  if GI_EditCmds <> nil then
    GI_EditCmds.ExecCut;
end;

procedure TCommandsDataModule.actEditCopyExecute(Sender: TObject);
begin
  if GI_EditCmds <> nil then
    GI_EditCmds.ExecCopy;
end;

procedure TCommandsDataModule.actEditPasteExecute(Sender: TObject);
begin
  if GI_EditCmds <> nil then
    GI_EditCmds.ExecPaste;
end;

procedure TCommandsDataModule.actEditDeleteExecute(Sender: TObject);
begin
  if GI_EditCmds <> nil then
    GI_EditCmds.ExecDelete;
end;

procedure TCommandsDataModule.actEditSelectAllExecute(Sender: TObject);
begin
  if GI_EditCmds <> nil then
    GI_EditCmds.ExecSelectAll;
end;

procedure TCommandsDataModule.actEditReadOnlyExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ReadOnly := not GI_ActiveEditor.ReadOnly;
end;

procedure TCommandsDataModule.actEditRedoExecute(Sender: TObject);
begin
  if GI_EditCmds <> nil then
    GI_EditCmds.ExecRedo;
end;

procedure TCommandsDataModule.actEditUndoExecute(Sender: TObject);
begin
  if GI_EditCmds <> nil then
    GI_EditCmds.ExecUndo;
end;

procedure TCommandsDataModule.actSearchFindExecute(Sender: TObject);
Var
  SearchCommands : ISearchCommands;
begin
  SearchCommands := FindSearchTarget;
  if SearchCommands <> nil then
    SearchCommands.ExecFind
end;

procedure TCommandsDataModule.actSearchFindNextExecute(Sender: TObject);
Var
  SearchCommands : ISearchCommands;
begin
  SearchCommands := FindSearchTarget;
  if SearchCommands <> nil then
    SearchCommands.ExecFindNext
end;

procedure TCommandsDataModule.actSearchFindPrevExecute(Sender: TObject);
Var
  SearchCommands : ISearchCommands;
begin
  SearchCommands := FindSearchTarget;
  if SearchCommands <> nil then
    SearchCommands.ExecFindPrev
end;

procedure TCommandsDataModule.actSearchReplaceExecute(Sender: TObject);
Var
  SearchCommands : ISearchCommands;
begin
  SearchCommands := FindSearchTarget;
  if SearchCommands <> nil then
    SearchCommands.ExecReplace
end;

procedure TCommandsDataModule.IncrementalSearch;
Var
  SearchCmds : ISearchCommands;
begin
  SearchCmds := FindSearchTarget;
  if Assigned(SearchCmds) then with SearchCmds do begin
    SearchTarget.SetCaretAndSelection(SearchTarget.BlockBegin, SearchTarget.BlockBegin, SearchTarget.BlockBegin);
    EditorSearchOptions.InitSearch;
    DoSearchReplaceText(SearchTarget, False, False, True);
  end;
end;

class function TCommandsDataModule.IsHighlighterStored(
  Highlighter: TObject): Boolean;
begin
  Result :=  not (Highlighter is TSynCythonSyn) and
    (not (Highlighter is TSynWebBase) or (Highlighter is TSynWebHtmlSyn));
end;

procedure TCommandsDataModule.Loaded;
begin
  inherited;
  // SynEditPrint
  with SynEditPrint do begin
    Font.Name := DefaultCodeFontName;
    Font.Size := 10;
    with Header do begin
      Add('$TITLE$', nil, taCenter, 2);
      DefaultFont.Size := 10;
    end;
    with Footer do begin
      Add('$PAGENUM$/$PAGECOUNT$', nil, taCenter, 1);
      DefaultFont.Size := 10;
    end;
  end;

  //Program Version Check
  ProgramVersionCheck.ThreadDialog.DialogOptions.ShowModal := False;
  ProgramVersionCheck.ThreadDialog.DialogOptions.Caption := 'Downloading...';
  ProgramVersionCheck.ThreadDialog.DialogOptions.ResName := 'WebCopyAvi';
  {$IFDEF CPUX64}
  ProgramVersionHTTPLocation.VersionInfoFileName := 'PyScripterVersionInfo-x64.ini';
  {$ELSE}
  ProgramVersionHTTPLocation.VersionInfoFileName := 'PyScripterVersionInfo.ini';
  {$ENDIF}
end;

procedure TCommandsDataModule.actSearchReplaceNowExecute(Sender: TObject);
Var
  SearchCmds : ISearchCommands;
begin
  SearchCmds := FindSearchTarget;
  if Assigned(SearchCmds) then with SearchCmds do begin
    EditorSearchOptions.InitSearch;
    DoSearchReplaceText(SearchTarget, True, EditorSearchOptions.SearchBackwards);
  end;
end;

procedure TCommandsDataModule.actToolsEditStartupScriptsExecute(Sender: TObject);
begin
  PyIDEMainForm.DoOpenFile(TPyScripterSettings.PyScripterInitFile);
  PyIDEMainForm.DoOpenFile(TPyScripterSettings.EngineInitFile);
end;

procedure TCommandsDataModule.actSearchGoToDebugLineExecute(Sender: TObject);
begin
  with PyControl.CurrentPos do
    if (Line >= 1) and (PyControl.ActiveDebugger <> nil) and not GI_PyControl.Running then
      GI_PyIDEServices.ShowFilePosition(Editor.FileId , Line, 1, 0, True, True);
end;

procedure TCommandsDataModule.actSearchGoToLineExecute(Sender: TObject);
Var
  Line : string;
  LineNo : integer;
begin
  if Assigned(GI_ActiveEditor) then
    if InputQuery(_(SGoToLineNumber), _(SEnterLineNumber), Line) then begin
      try
        LineNo := StrToInt(Line);
        GI_ActiveEditor.ActiveSynEdit.CaretXY := BufferCoord(1, LineNo);
      except
        on E: EConvertError do begin
          StyledMessageDlg(Format(_(SNotAValidNumber), [Line]), mtError,
            [mbAbort], 0);
        end;
      end;
    end;
end;

procedure TCommandsDataModule.actSearchGoToSyntaxErrorExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    TEditorForm(GI_ActiveEditor.Form).GoToSyntaxError;
end;

procedure TCommandsDataModule.actSearchHighlightExecute(Sender: TObject);
Var
  SearchEngine : TSynEditSearchCustom;
  SearchOptions : TSynSearchOptions;
  Editor : IEditor;
begin
  Editor := GI_PyIDEServices.ActiveEditor;
  if Assigned(Editor) then begin
    if actSearchHighlight.Checked and (EditorSearchOptions.SearchText <> '') then
    begin
      SearchOptions := [];
      case EditorSearchOptions.SearchCaseSensitiveType of
        scsAuto:
          if LowerCase(EditorSearchOptions.SearchText) <> EditorSearchOptions.SearchText then
            Include(SearchOptions, ssoMatchCase);
        scsCaseSensitive : Include(SearchOptions, ssoMatchCase);
      end;
      if EditorSearchOptions.SearchWholeWords then
        Include(SearchOptions, ssoWholeWord);

      if EditorSearchOptions.UseRegExp then
        SearchEngine := SynEditRegexSearch
      else
        SearchEngine := SynEditSearch;
      try
        HighligthtSearchTerm(EditorSearchOptions.SearchText, Editor, SearchEngine,
          SearchOptions);
      except
        on E: ESynRegEx do begin
          MessageBeep(MB_ICONERROR);
          GI_PyIDEServices.WriteStatusMsg(Format(_(SInvalidRegularExpression), [E.Message]));
          Exit;
        end;
      end;
    end else if not actSearchHighlight.Checked then
      ClearAllHighlightedTerms;
  end;
end;

procedure TCommandsDataModule.actFindInFilesExecute(Sender: TObject);
begin
  if Assigned(FindResultsWindow) then
    FindResultsWindow.Execute(False)
end;

procedure TCommandsDataModule.actUnfoldAllExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.UncollapseAll;
end;

procedure TCommandsDataModule.actUnfoldClassesExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.UncollapseFoldType(3);
end;

procedure TCommandsDataModule.actUnfoldFunctionsExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.UncollapseFoldType(4);
end;

procedure TCommandsDataModule.actUnfoldLevel1Execute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.ExecuteCommand(ecUnfoldLevel1, ' ', nil);
end;

procedure TCommandsDataModule.actUnfoldLevel2Execute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.ExecuteCommand(ecUnfoldLevel2, ' ', nil);
end;

procedure TCommandsDataModule.actUnfoldLevel3Execute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.ExecuteCommand(ecUnfoldLevel3, ' ', nil);
end;

procedure TCommandsDataModule.actUnfoldNearestExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.ExecuteCommand(ecUnfoldNearest, ' ', nil);
end;

procedure TCommandsDataModule.actUnfoldRegionsExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.ExecuteCommand(ecUnfoldRegions, ' ', nil);
end;

procedure TCommandsDataModule.actUnitTestWizardExecute(Sender: TObject);
Var
  Tests : string;
  Editor : IEditor;
begin
  if Assigned(GI_ActiveEditor) and GI_ActiveEditor.HasPythonFile then begin
    Tests := TUnitTestWizard.GenerateTests(GI_ActiveEditor.FileId);
    if Tests <> '' then begin
      Editor := PyIDEMainForm.DoOpenFile('', 'Python');
      if Assigned(Editor) then
        Editor.SynEdit.SelText := Tests;
    end;
  end;
end;

procedure TCommandsDataModule.ApplyEditorOptions;
// Assign Editor Options to all open editors
begin
  GI_EditorFactory.ApplyToEditors(procedure(Editor: IEditor)
  begin
    Editor.SynEdit.Assign(EditorOptions);
    Editor.SynEdit2.Assign(EditorOptions);
  end);

  InterpreterEditorOptions.Keystrokes.Assign(EditorOptions.Keystrokes);
  InterpreterEditorOptions.Font := EditorOptions.Font;
  PythonIIForm.SynEdit.Assign(InterpreterEditorOptions);
  PythonIIForm.RegisterHistoryCommands;
  PythonIIForm.SynEdit.Highlighter.Assign(SynPythonSyn);
  SynCythonSyn.Assign(SynPythonSyn);
  SynCythonSyn.DefaultFilter := PyIDEOptions.CythonFileFilter;
end;

procedure TCommandsDataModule.actEditorOptionsExecute(Sender: TObject);
var
  TempEditorOptions: TSynEditorOptionsContainer;
  TempStream: TMemoryStream;
  TempIniFile: TMemIniFile;
begin
  TempEditorOptions := TSynEditorOptionsContainer.Create(Self);
  TempEditorOptions.Assign(EditorOptions);  // Initialize with defaults
  // SynWeb attribute changes are taking immediate effect in Web Engine
  // So Cancel does not work.  As a workaround we save the syntax attributes
  // and restore them if the dialog is cancelled.
  TempStream := TMemoryStream.Create;
  TempIniFile := TMemIniFile.Create(TempStream);
  SynWebHtmlSyn.SaveToIniFile(TempIniFile);
  try
    with TSynEditOptionsDialog.Create(Self) do begin
      if Assigned(GI_ActiveEditor) then begin
        TempEditorOptions.Assign(GI_ActiveEditor.ActiveSynEdit);
        Form.cbApplyToAll.Checked := True;
        Form.cbApplyToAll.Enabled := True;
      end else begin
        TempEditorOptions.Assign(EditorOptions);
        Form.cbApplyToAll.Checked := True;
        Form.cbApplyToAll.Enabled := False;
      end;
      OnGetHighlighterCount := SynEditOptionsDialogGetHighlighterCount;
      OnGetHighlighter := SynEditOptionsDialogGetHighlighter;
      OnSetHighlighter := SynEditOptionsDialogSetHighlighter;
      VisiblePages := [soDisplay, soOptions, soKeystrokes, soColor];
      TSynEditOptionsDialog.HighlighterFileDir := TPyScripterSettings.ColorThemesFilesDir;
      GetUserCommand := GetEditorUserCommand;
      GetAllUserCommands := GetEditorAllUserCommands;
      UseExtendedStrings := True;
      if Execute(TempEditorOptions) then begin
        UpdateHighlighters;
        if Form.cbApplyToAll.Checked then begin
          EditorOptions.Assign(TempEditorOptions);
          ApplyEditorOptions;
          PyIDEMainForm.StoreApplicationData;
        end else if Assigned(GI_ActiveEditor) then
          GI_ActiveEditor.ActiveSynEdit.Assign(TempEditorOptions);
      end else
        //  If canceled restore original settings
        SynWebHtmlSyn.LoadFromIniFile(TempIniFile);
      Free;
    end;
  finally
    TempEditorOptions.Free;
    TempIniFile.Free;
    TempStream.Free;
  end;
end;

procedure TCommandsDataModule.actInterpreterEditorOptionsExecute(
  Sender: TObject);
var
  TempEditorOptions : TSynEditorOptionsContainer;
begin
  TempEditorOptions := TSynEditorOptionsContainer.Create(Self);
  try
    with TSynEditOptionsDialog.Create(Self) do begin
      TempEditorOptions.Assign(PythonIIForm.SynEdit);
      Form.cbApplyToAll.Checked := False;
      Form.cbApplyToAll.Enabled := False;
      Form.Caption := 'Interpreter Editor Options';
      OnGetHighlighterCount := SynInterpreterOptionsDialogGetHighlighterCount;
      OnGetHighlighter := SynInterpreterOptionsDialogGetHighlighter;
      OnSetHighlighter := SynInterpreterOptionsDialogSetHighlighter;
      VisiblePages := [soDisplay, soOptions, soColor];
      TSynEditOptionsDialog.HighlighterFileDir := TPyScripterSettings.ColorThemesFilesDir;
      if Execute(TempEditorOptions) then begin
        UpdateHighlighters;
        InterpreterEditorOptions.Assign(TempEditorOptions);
        InterpreterEditorOptions.Options := (InterpreterEditorOptions.Options -
          [eoTrimTrailingSpaces, eoScrollPastEol]) + [eoTabsToSpaces];
        PythonIIForm.SynEdit.Assign(InterpreterEditorOptions);
      end;
      Free;
    end;
  finally
    TempEditorOptions.Free;
  end;
end;

procedure TCommandsDataModule.actEditIndentExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.ExecuteCommand(ecBlockIndent, ' ', nil);
end;

procedure TCommandsDataModule.actEditDedentExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.ExecuteCommand(ecBlockUnIndent, ' ', nil);
end;

procedure TCommandsDataModule.actEditToggleCommentExecute(Sender: TObject);
var
  i, EndLine : integer;
  BlockIsCommented : Boolean;
begin
  if Assigned(GI_ActiveEditor) then with GI_ActiveEditor.ActiveSynEdit do begin
    if (BlockBegin.Line <> BlockEnd.Line) and (BlockEnd.Char = 1) then
      EndLine := BlockEnd.Line - 1
    else
      EndLine := BlockEnd.Line;

    BlockIsCommented := True;
    for i  := BlockBegin.Line to EndLine do
      if Copy(Trim(Lines[i-1]), 1, 2) <> '##' then begin
        BlockIsCommented := False;
        Break;
      end;

    if BlockIsCommented then
      actEditUncommentExecute(Sender)
    else
      actEditCommentOutExecute(Sender);
  end;
end;

procedure TCommandsDataModule.actEditFileEncodingExecute(Sender: TObject);
begin
  if (Sender is TAction) and Assigned(GI_ActiveEditor) then begin
    GI_ActiveEditor.FileEncoding := TFileSaveFormat(TAction(Sender).Tag);
    GI_ActiveEditor.SynEdit.Modified := True;
  end;
end;

procedure TCommandsDataModule.actEditCommentOutExecute(Sender: TObject);
var
  S: string;
  Offset: integer;
  OldBlockBegin, OldBlockEnd : TBufferCoord;
begin
  if Assigned(GI_ActiveEditor) then with GI_ActiveEditor.ActiveSynEdit do begin
    OldBlockBegin := BlockBegin;
    OldBlockEnd := BlockEnd;
    if SelAvail then begin // has selection
      OldBlockBegin := BufferCoord(1, OldBlockBegin.Line);
      BlockBegin := OldBlockBegin;
      BlockEnd := OldBlockEnd;
      BeginUpdate;
      S:='##'+SelText;
      Offset:=0;
      if S[Length(S)]=#10 then begin // if the selection ends with a newline, eliminate it
        if S[Length(S)-1]=#13 then // do we ignore 1 or 2 chars?
          Offset:=2
        else
          Offset:=1;
        S:=Copy(S, 1, Length(S)-Offset);
      end;
      S := StringReplace(S, #10, #10'##', [rfReplaceAll]);
      if Offset=1 then
        S:=S+#10
      else if Offset=2 then
        S:=S + sLineBreak;
      SelText := S;
      EndUpdate;
      BlockBegin := OldBlockBegin;
      if Offset = 0 then
        Inc(OldBlockEnd.Char, 2);
      BlockEnd := BufferCoord(OldBlockEnd.Char, OldBlockEnd.Line);
    end
    else  begin // no selection; easy stuff ;)
      // Do with selection to be able to undo
      //LineText:='##'+LineText;
      CaretXY := BufferCoord(1, CaretY);
      SelText := '##';
      CaretXY := BufferCoord(OldBlockEnd.Char + 2, OldBlockEnd.Line);
    end;
    UpdateCaret;
  end;
end;

procedure TCommandsDataModule.actEditUncommentExecute(Sender: TObject);

var
  OldBlockBegin, OldBlockEnd : TBufferCoord;
begin
  if Assigned(GI_ActiveEditor) then with GI_ActiveEditor.ActiveSynEdit do begin
    OldBlockBegin := BlockBegin;
    OldBlockEnd := BlockEnd;
    if SelAvail then
    begin
      OldBlockBegin := BufferCoord(1, OldBlockBegin.Line);
      BlockBegin := OldBlockBegin;
      BlockEnd := OldBlockEnd;
      SelText := TPyRegExpr.CodeCommentLineRE.Replace(SelText, '$1');
      BlockBegin := OldBlockBegin;
      BlockEnd := BufferCoord(OldBlockEnd.Char - 2, OldBlockEnd.Line);
    end else begin
      BlockBegin := BufferCoord(1, CaretY);
      BlockEnd := BufferCoord(Length(LineText)+1, CaretY);
      SelText := TPyRegExpr.CodeCommentLineRE.Replace(SelText, '$1');
      CaretXY := BufferCoord(OldBlockEnd.Char - 2, OldBlockEnd.Line);
    end;
    UpdateCaret;
  end;
end;

procedure TCommandsDataModule.actEditTabifyExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then with GI_ActiveEditor.ActiveSynEdit do begin
    if SelAvail then
    begin
       SelText :=  StringReplace(SelText,
         StringOfChar(' ',GI_ActiveEditor.SynEdit.TabWidth), #9, [rfReplaceAll]);
       UpdateCaret;
    end;
  end;
end;

procedure TCommandsDataModule.actEditUntabifyExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then with GI_ActiveEditor.ActiveSynEdit do begin
    if SelAvail then
    begin
       SelText :=  StringReplace(SelText, #9,
         StringOfChar(' ',GI_ActiveEditor.SynEdit.TabWidth), [rfReplaceAll]);
       UpdateCaret;
    end;
  end;
end;

procedure TCommandsDataModule.actExportHighlightersExecute(Sender: TObject);
Var
  i : integer;
  AppStorage : TJvAppIniFileStorage;
  IP : TStringList;
begin
  with dlgFileSave do begin
    Title := _(SExportHighlighters);
    Filter := SynIniSyn.DefaultFilter;
    DefaultExt := 'ini';
    if Execute then begin
      IP := TStringList.Create;
      IP.Add('Name'); IP.Add('DefaultFilter'); IP.Add('DefaultExtension');
      AppStorage := TJvAppIniFileStorage.Create(nil);
      try
        AppStorage.FlushOnDestroy := True;
        AppStorage.Location := flCustom;
        AppStorage.FileName := FileName;
        AppStorage.StorageOptions.SetAsString := True;
        AppStorage.WriteString('PyScripter\Version', ApplicationVersion);
        AppStorage.WriteBoolean('PyScripter\SetAsString', True);
        AppStorage.DeleteSubTree('Highlighters');
        for i := 0 to Highlighters.Count - 1 do
          if IsHighlighterStored(Highlighters.Objects[i]) then
            AppStorage.WritePersistent('Highlighters\'+ Highlighters[i],
              TPersistent(Highlighters.Objects[i]), True, IP);
        AppStorage.WritePersistent('Highlighters\Python Interpreter',
          PythonIIForm.SynEdit.Highlighter, True, IP);
    finally
        AppStorage.Free;
        IP.Free;
      end;
    end;
  end;
end;

procedure TCommandsDataModule.actExportShortCutsExecute(Sender: TObject);
Var
  AppStorage : TJvAppIniFileStorage;
  ActionProxyCollection: TActionProxyCollection;
begin
  with dlgFileSave do begin
    Title := _(SExportShortcuts);
    Filter := SynIniSyn.DefaultFilter;
    DefaultExt := 'ini';
    if Execute then begin
      AppStorage := TJvAppIniFileStorage.Create(nil);
      try
        AppStorage.FlushOnDestroy := True;
        AppStorage.Location := flCustom;
        AppStorage.FileName := FileName;
        AppStorage.StorageOptions.StoreDefaultValues := False;
        AppStorage.WriteString('PyScripter\Version', ApplicationVersion);
        AppStorage.DeleteSubTree('IDE Shortcuts');
        ActionProxyCollection := TActionProxyCollection.Create(apcctAll);
        try
          AppStorage.WriteCollection('IDE Shortcuts', ActionProxyCollection, 'Action');
        finally
          ActionProxyCollection.Free;
        end;
        AppStorage.DeleteSubTree('Editor Shortcuts');
        AppStorage.WriteCollection('Editor Shortcuts', EditorOptions.Keystrokes);
      finally
        AppStorage.Free;
      end;
    end;
  end;
end;

procedure TCommandsDataModule.actImportHighlightersExecute(Sender: TObject);
Var
  i : integer;
  AppStorage : TJvAppIniFileStorage;
begin
  with dlgFileOpen do begin
    Title := _(SImportHighlighters);
    Filter := SynIniSyn.DefaultFilter;
    FileName := '';
    if Execute then begin
      AppStorage := TJvAppIniFileStorage.Create(nil);
      try
        AppStorage.FlushOnDestroy := False;
        AppStorage.Location := flCustom;
        AppStorage.FileName := FileName;
        AppStorage.StorageOptions.SetAsString :=
          AppStorage.ReadBoolean('PyScripter\SetAsString', False);
        for i := 0 to Highlighters.Count - 1 do
          AppStorage.ReadPersistent('Highlighters\'+Highlighters[i],
            TPersistent(Highlighters.Objects[i]));
        PythonIIForm.SynEdit.Highlighter.Assign(SynPythonSyn);
        SynCythonSyn.Assign(SynPythonSyn);
        SynCythonSyn.DefaultFilter := PyIDEOptions.CythonFileFilter;
        if AppStorage.IniFile.SectionExists('Highlighters\Python Interpreter') then
          AppStorage.ReadPersistent('Highlighters\Python Interpreter',
            PythonIIForm.SynEdit.Highlighter);
      finally
        AppStorage.Free;
      end;
    end;
  end;
end;

procedure TCommandsDataModule.actImportShortcutsExecute(Sender: TObject);
Var
  AppStorage : TJvAppIniFileStorage;
  ActionProxyCollection: TActionProxyCollection;
begin
  with dlgFileOpen do begin
    Title := _(SImportShortcuts);
    Filter := SynIniSyn.DefaultFilter;
    FileName := '';
    if Execute then begin
      AppStorage := TJvAppIniFileStorage.Create(nil);
      try
        AppStorage.Location := flCustom;
        AppStorage.FileName := FileName;

        if AppStorage.PathExists('IDE Shortcuts') then begin
          ActionProxyCollection := TActionProxyCollection.Create(apcctEmpty);
          try
            AppStorage.ReadCollection('IDE Shortcuts', ActionProxyCollection, True, 'Action');
            ActionProxyCollection.ApplyShortCuts;
          finally
            ActionProxyCollection.Free;
          end;
        end;
        if AppStorage.PathExists('Editor Shortcuts') then begin
          AppStorage.ReadCollection('Editor Shortcuts', EditorOptions.Keystrokes, True);
          GI_EditorFactory.ApplyToEditors(procedure(Editor: IEditor)
          begin
            Editor.SynEdit.Keystrokes.Assign(EditorOptions.Keystrokes);
          end);

          InterpreterEditorOptions.Keystrokes.Assign(EditorOptions.Keystrokes);
          PythonIIForm.SynEdit.Keystrokes.Assign(EditorOptions.Keystrokes);
          PythonIIForm.RegisterHistoryCommands;
        end;
      finally
        AppStorage.Free;
      end;
    end;
  end;
end;

procedure TCommandsDataModule.actEditLBExecute(Sender: TObject);
begin
  if (Sender is TAction) and Assigned(GI_ActiveEditor) then begin
    (GI_ActiveEditor.SynEdit.Lines as TSynEditStringList).FileFormat :=
      TSynEditFileFormat(TAction(Sender).Tag);
    GI_ActiveEditor.SynEdit.Modified := True;
  end;
end;

procedure TCommandsDataModule.actSearchMatchingBraceExecute(
  Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.CommandProcessor(ecMatchBracket, #0, nil);
end;

procedure GetMatchingBrackets(SynEdit : TSynEdit;
  var BracketPos : TBufferCoord; out MatchingBracketPos : TBufferCoord;
  out IsBracket, HasMatchingBracket : Boolean; out BracketCh, MatchCh : Char;
  out Attri: TSynHighlighterAttributes);

  procedure GetMatchingBracketsInt(const P : TBufferCoord);
  const
    Brackets  = '()[]{}';
  var
    S: string;
    I: Integer;
  begin
    IsBracket := False;
    HasMatchingBracket := False;
    SynEdit.GetHighlighterAttriAtRowCol(P, S, Attri);
    if Assigned(Attri) and (SynEdit.Highlighter.SymbolAttribute = Attri) and
        (SynEdit.CaretX<=length(SynEdit.LineText) + 1) then begin
      I := Brackets.IndexOf(S);
      if I >= 0 then
      begin
        BracketCh := Brackets.Chars[I];
        IsBracket := True;
        MatchingBracketPos := SynEdit.GetMatchingBracketEx(P, Brackets);
        if (MatchingBracketPos.Char > 0) then begin
          HasMatchingBracket := True;
          MatchCh := Brackets.Chars[I xor 1];
        end;
      end;
    end;
  end;

begin
  MatchingBracketPos := BufferCoord(0,0);
  BracketPos := SynEdit.CaretXY;

  // First Look at the previous character like Site
  if BracketPos.Char > 1 then Dec(BracketPos.Char);
  GetMatchingBracketsInt(BracketPos);

  //if it is not a bracket then look at the next character;
  if not IsBracket and (SynEdit.CaretX > 1) then begin
    Inc(BracketPos.Char);
    GetMatchingBracketsInt(BracketPos);
  end;
end;

function GetMatchingBracket(SynEdit : TSynEdit) : TBufferCoord;
var
  BracketPos : TBufferCoord;
  BracketCh, MatchCh : Char;
  IsBracket, HasMatchingBracket : Boolean;
  Attri: TSynHighlighterAttributes;
  IsOutside : Boolean;
Const
  OpenChars = ['(', '{', '['];
begin
  GetMatchingBrackets(SynEdit, BracketPos, Result, IsBracket, HasMatchingBracket,
    BracketCh, MatchCh, Attri);
  if HasMatchingBracket then begin
    IsOutside := (CharInSet(BracketCh, OpenChars) and
                  (BracketPos.Char = SynEdit.CaretXY.Char)) or
                 not (CharInSet(BracketCh, OpenChars) or
                  (BracketPos.Char = SynEdit.CaretXY.Char));
   if (IsOutSide and not CharInSet(MatchCh, OpenChars)) or
      (not IsOutSide and CharInSet(MatchCh, OpenChars))
   then
     Inc(Result.Char);
  end;
end;


procedure TCommandsDataModule.PaintMatchingBrackets(SynEdit : TSynEdit;
  TransientType: TTransientType);
{-----------------------------------------------------------------------------
  Based on code from devcpp (dev-cpp.sf.net)
-----------------------------------------------------------------------------}

var
  P, PM: TBufferCoord;
  PD, PMD : TDisplayCoord;
  Pix: TPoint;
  R : TRect;
  BracketCh, MatchCh : Char;
  IsBracket, HasMatchingBracket : Boolean;
  Attri: TSynHighlighterAttributes;
  FontColor, BkgColor: TColor;
  FontStyle: TFontStyles;
begin
  GetMatchingBrackets(SynEdit, P, PM, IsBracket, HasMatchingBracket, BracketCh,
    MatchCh, Attri);

  if IsBracket then begin
    PD := SynEdit.BufferToDisplayPos(P);
    Pix := SynEdit.RowColumnToPixels(PD);

    FontStyle := Attri.Style;
    FontColor := Attri.Foreground;

    if SynEdit.IsPointInSelection(P) then
      BkgColor := SynEdit.SelectedColor.Background
    else if (Synedit.ActiveLineColor <> clNone) and (SynEdit.CaretY = P.Line) then
      BkgColor := SynEdit.ActiveLineColor
    else if Attri.Background <> clNone then
      BkgColor := Attri.Background
    else if SynEdit.Highlighter.WhitespaceAttribute.Background <> clNone then
      BkgColor := SynEdit.Highlighter.WhitespaceAttribute.Background
    else
      BkgColor := Synedit.Color;


    if (TransientType = ttAfter) then begin
      if HasMatchingBracket then begin
        if not SynEdit.IsPointInSelection(P) then
        begin
          if SynPythonSyn.MatchingBraceAttri.Background <> clNone then
            BkgColor := SynPythonSyn.MatchingBraceAttri.Background;
          FontColor:= SynPythonSyn.MatchingBraceAttri.Foreground;
        end;
      end else begin
        if not SynEdit.IsPointInSelection(P) then
        begin
          if SynPythonSyn.UnbalancedBraceAttri.Background <> clNone then
            BkgColor := SynPythonSyn.UnbalancedBraceAttri.Background;
          FontColor:= SynPythonSyn.UnbalancedBraceAttri.Foreground;
        end;
      end;
      FontStyle := FontStyle + [fsBold];
    end
    else begin
      FontStyle := Attri.Style;
      if not SynEdit.IsPointInSelection(P) then
        FontColor:= Attri.Foreground;
    end;

    if (PD.Column >= SynEdit.LeftChar) and
      Rect(SynEdit.GutterWidth + SynEdit.TextMargin, 0, SynEdit.ClientWidth,
      SynEdit.ClientHeight).Contains(Pix) and
      (PD.Row > 0)and (PD.Row >= SynEdit.TopLine) and
      (PD.Row < SynEdit.TopLine + SynEdit.LinesInWindow) then
    begin
      R := Rect(Pix.X, Pix.Y, Pix.X + SynEdit.CharWidth, Pix.Y + SynEdit.LineHeight);
      SynEdit.PaintText(BracketCh, Point(0, 0), R, FontStyle, FontColor, BkgColor);
    end;

    if not HasMatchingBracket then Exit;

    PMD := SynEdit.BufferToDisplayPos(PM);
    Pix := SynEdit.RowColumnToPixels(PMD);
    if (PMD.Column >= SynEdit.LeftChar) and
      Rect(SynEdit.GutterWidth + SynEdit.TextMargin, 0, SynEdit.ClientWidth,
      SynEdit.ClientHeight).Contains(Pix) and
      (PMD.Row > 0)and (PMD.Row >= SynEdit.TopLine) and
      (PMD.Row < SynEdit.TopLine + SynEdit.LinesInWindow) then
    begin
      if SynEdit.IsPointInSelection(PM) then
        FontColor := SynEdit.SelectedColor.Foreground
      else if (TransientType = ttAfter) then
        FontColor:= SynPythonSyn.MatchingBraceAttri.Foreground;

      if SynEdit.IsPointInSelection(PM) then
        BkgColor := SynEdit.SelectedColor.Background
      else if (TransientType = ttAfter) and (SynPythonSyn.MatchingBraceAttri.Background <> clNone) then
        BkgColor := SynPythonSyn.MatchingBraceAttri.Background
      else if (Synedit.ActiveLineColor <> clNone) and (SynEdit.CaretY = PM.Line) then
        BkgColor := SynEdit.ActiveLineColor
      else if Attri.Background <> clNone then
        BkgColor := Attri.Background
      else if SynEdit.Highlighter.WhitespaceAttribute.Background <> clNone then
        BkgColor := SynEdit.Highlighter.WhitespaceAttribute.Background
      else
        BkgColor := Synedit.Color;

      R := Rect(Pix.X, Pix.Y, Pix.X + SynEdit.CharWidth, Pix.Y + SynEdit.LineHeight);
      SynEdit.PaintText(MatchCh, Point(0, 0), R, FontStyle, FontColor, BkgColor);
    end;
  end;
end;

procedure TCommandsDataModule.ProcessFolderChange(const FolderName: string);
var
  I : integer;
  ModifiedCount : integer;
  Editor : IEditor;
  ChangedFiles : TStringList;
  FTime : TDateTime;
begin
  if FolderName = '' then Exit;

  ChangedFiles := TSmartPtr.Make(TStringList.Create)();

  GI_EditorFactory.ApplyToEditors(procedure(Ed: IEditor)
  begin
    if (Ed.FileName <> '') and (ExtractFileDir(Ed.FileName) = FolderName) then begin
      if not FileAge(Ed.FileName, FTime) then begin
        if not FileExists(Ed.FileName) and (TEditorForm(Ed.Form).FileTime <> 0) then begin
          // File or directory has been moved or deleted
          // Mark as modified so that we try to save it
          Ed.SynEdit.Modified := True;
          // Set FileTime to zero to prevent further notifications
          TEditorForm(Ed.Form).FileTime := 0;
          StyledMessageDlg(Format(_(SFileRenamedOrDeleted), [Ed.FileName]) , mtWarning, [mbOK], 0);
        end;
      end else if not SameDateTime(TEditorForm(Ed.Form).FileTime, FTime) then begin
        ChangedFiles.AddObject(Ed.FileId, Ed.Form);
        // Prevent further notifications on this file
        TEditorForm(Ed.Form).FileTime := FTime;
      end;
    end;
  end);

  ModifiedCount := 0;
  for I := 0 to ChangedFiles.Count - 1 do begin
    Editor := TEditorForm(ChangedFiles.Objects[I]).GetEditor;
    if Editor.Modified then
      Inc(ModifiedCount);
    Editor.SynEdit.Modified := True;  //So that we are prompted to save changes
  end;

  if ChangedFiles.Count > 0 then
    if PyIDEOptions.AutoReloadChangedFiles and (ModifiedCount = 0) then begin
      for I := 0 to ChangedFiles.Count - 1 do begin
        Editor := TEditorForm(ChangedFiles.Objects[I]).GetEditor;
        (Editor as IFileCommands).ExecReload(True);
      end;
      MessageBeep(MB_ICONASTERISK);
      GI_PyIDEServices.WriteStatusMsg(_(SChangedFilesReloaded));
    end
    else with TPickListDialog.Create(Application.MainForm) do begin
      Caption := _(SFileChangeNotification);
      lbMessage.Caption := _(SFileReloadWarning);
      CheckListBox.Items.Assign(ChangedFiles);
      SetScrollWidth;
      mnSelectAllClick(nil);
      if ShowModal = IdOK then
        for I := CheckListBox.Count - 1 downto 0 do begin
          if CheckListBox.Checked[I] then begin
            Editor := TEditorForm(CheckListBox.Items.Objects[I]).GetEditor;
            (Editor as IFileCommands).ExecReload(True);
          end;
        end;
      Release;
    end;
end;

procedure TCommandsDataModule.ProcessShellNotify(Sender: TCustomVirtualExplorerTree;
  ShellEvent: TVirtualShellEvent);
var
  NS: TNamespace;
  WS: string;
  Dir: string;
begin
  if not (ShellEvent.ShellNotifyEvent in [vsneUpdateDir, vsneRenameFolder]) then Exit;

  Dir := '';
  NS := TNamespace.Create(ShellEvent.PIDL1, nil);
  try
    NS.FreePIDLOnDestroy := False;
    Dir := NS.NameForParsing;
    if PyIDEOptions.FileChangeNotification = fcnNoMappedDrives then begin
      // Do not process mapped drive
      WS := WideExtractFileDrive(Dir);
      if WideIsDrive(WS) and (GetDriveType(PWideChar(WS)) = DRIVE_REMOTE)then Exit;
    end;
    if not NS.Folder then // UpdateItem notifications
      Dir := ExtractFileDir(Dir);
  finally
    NS.Free;
  end;

  ProcessFolderChange(Dir);
end;

procedure TCommandsDataModule.PrepareParameterCompletion;
var
  i : integer;
  ParamName, ParamValue : string;
begin
  with ParameterCompletion do begin
    ItemList.Clear;
    InsertList.Clear;
    for i := 0 to Parameters.Count - 1 do begin
      Parameters.Split(i, ParamName, ParamValue, False);
      ItemList.Add(Format('\color{$FF8844}%s\color{clWindowText}\column{}%s',
         [ParamName, StringReplace(ParamValue, '\', '\\', [rfReplaceAll])]));
      InsertList.Add(ParamName);
    end;
  end;
end;

procedure TCommandsDataModule.PrepareModifierCompletion;
var
  i : integer;
  ModName, ModComment : string;
begin
  with ModifierCompletion do begin
    ItemList.Clear;
    InsertList.Clear;
    for i := 0 to Parameters.Modifiers.Count - 1 do begin
      ModName := Parameters.Modifiers.Names[i];
      ModComment := Parameters.Modifiers.Values[ModName];
      ItemList.Add(Format('\color{$FF8844}%s\color{clWindowText}\column{}%s', [ModName, ModComment]));
      InsertList.Add(ModName);
    end;
  end;
end;

procedure TCommandsDataModule.actIDEOptionsExecute(Sender: TObject);
Var
  Categories : array of TOptionCategory;
  Reg : TRegistry;
  IsRegistered : Boolean;
  Key : string;
begin
  SetLength(Categories, 11);
  with Categories[0] do begin
    DisplayName := _('IDE');
    SetLength(Options, 12);
    Options[0].PropertyName := 'AutoCheckForUpdates';
    Options[0].DisplayName := _('Check for updates automatically');
    Options[1].PropertyName := 'DaysBetweenChecks';
    Options[1].DisplayName := _('Days between update checks');
    Options[2].PropertyName := 'EditorsTabPosition';
    Options[2].DisplayName := _('Editor tab position');
    Options[3].PropertyName := 'SmartNextPrevPage';
    Options[3].DisplayName := _('Smart Next Previous Page');
    Options[4].PropertyName := 'ShowTabCloseButton';
    Options[4].DisplayName := _('Show tab close button');
    Options[5].PropertyName := 'DockAnimationInterval';
    Options[5].DisplayName := _('Dock animation interval (ms)');
    Options[6].PropertyName := 'DockAnimationMoveWidth';
    Options[6].DisplayName := _('Dock animation move width (pixels)');
    Options[7].PropertyName := 'FileTemplateForNewScripts';
    Options[7].DisplayName := _('File template for new Python scripts');
    Options[8].PropertyName := 'NoOfRecentFiles';
    Options[8].DisplayName := _('Number of recent files');
    Options[9].PropertyName := 'StyleMainWindowBorder';
    Options[9].DisplayName := _('Style Main Window Border');
    Options[10].PropertyName := 'RestoreOpenFiles';
    Options[10].DisplayName := _('Restore open files');
    Options[11].PropertyName := 'RestoreOpenProject';
    Options[11].DisplayName := _('Restore open project');
  end;
  with Categories[1] do begin
    DisplayName := _('Python Interpreter');
    SetLength(Options, 15);
    Options[0].PropertyName := 'SaveFilesBeforeRun';
    Options[0].DisplayName := _('Save files before run');
    Options[1].PropertyName := 'SaveEnvironmentBeforeRun';
    Options[1].DisplayName := _('Save environment before run');
    Options[2].PropertyName := 'TimeOut';
    Options[2].DisplayName := _('Timeout for running scripts in ms');
    Options[3].PropertyName := 'PythonEngineType';
    Options[3].DisplayName := _('Python engine type');
    Options[4].PropertyName := 'PrettyPrintOutput';
    Options[4].DisplayName := _('Pretty print output');
    Options[5].PropertyName := 'ClearOutputBeforeRun';
    Options[5].DisplayName := _('Clear output before run');
    Options[6].PropertyName := 'PostMortemOnException';
    Options[6].DisplayName := _('Post-mortem on exception');
    Options[7].PropertyName := 'InterpreterHistorySize';
    Options[7].DisplayName := _('Interpreter history size');
    Options[8].PropertyName := 'SaveInterpreterHistory';
    Options[8].DisplayName := _('Save interpreter history');
    Options[9].PropertyName := 'ReinitializeBeforeRun';
    Options[9].DisplayName := _('Reinitialize before run');
    Options[10].PropertyName := 'JumpToErrorOnException';
    Options[10].DisplayName := _('Jump to error on exception');
    Options[11].PropertyName := 'InternalInterpreterHidden';
    Options[11].DisplayName := _('Internal Interpreter hidden');
    Options[12].PropertyName := 'AlwaysUseSockets';
    Options[12].DisplayName := _('Always use sockets');
    Options[13].PropertyName := 'TraceOnlyIntoOpenFiles';
    Options[13].DisplayName := _('Step into open files only');
    Options[14].PropertyName := 'MaskFPUExceptions';
    Options[14].DisplayName := _('Mask FPU Exceptions');
  end;
  with Categories[2] do begin
    DisplayName := _('Code Explorer');
    SetLength(Options, 1);
    Options[0].PropertyName := 'ExporerInitiallyExpanded';
    Options[0].DisplayName := _('Initially expanded');
  end;
  with Categories[3] do begin
    DisplayName := _('Project Explorer');
    SetLength(Options, 1);
    Options[0].PropertyName := 'ProjectExporerInitiallyExpanded';
    Options[0].DisplayName := _('Initially expanded');
  end;
  with Categories[4] do begin
    DisplayName := _('File Filters');
    SetLength(Options, 12);
    Options[0].PropertyName := 'PythonFileFilter';
    Options[0].DisplayName := Format(_(SOpenDialogFilter), ['Python']);
    Options[1].PropertyName := 'HTMLFileFilter';
    Options[1].DisplayName := Format(_(SOpenDialogFilter), ['HTML']);
    Options[2].PropertyName := 'XMLFileFilter';
    Options[2].DisplayName := Format(_(SOpenDialogFilter), ['XML']);
    Options[3].PropertyName := 'CSSFileFilter';
    Options[3].DisplayName := Format(_(SOpenDialogFilter), ['CSS']);
    Options[4].PropertyName := 'CPPFileFilter';
    Options[4].DisplayName := Format(_(SOpenDialogFilter), ['CPP']);
    Options[5].PropertyName := 'YAMLFileFilter';
    Options[5].DisplayName := Format(_(SOpenDialogFilter), ['YAML']);
    Options[6].PropertyName := 'JSFileFilter';
    Options[6].DisplayName := Format(_(SOpenDialogFilter), ['JavaScript']);
    Options[7].PropertyName := 'PHPFileFilter';
    Options[7].DisplayName := Format(_(SOpenDialogFilter), ['PHP']);
    Options[8].PropertyName := 'FileExplorerFilter';
    Options[8].DisplayName := _('File explorer filter');
    Options[9].PropertyName := 'CythonFileFilter';
    Options[9].DisplayName := Format(_(SOpenDialogFilter), ['Cython']);
    Options[10].PropertyName := 'JSONFileFilter';
    Options[10].DisplayName := Format(_(SOpenDialogFilter), ['JSON']);
    Options[11].PropertyName := 'GeneralFileFilter';
    Options[11].DisplayName := Format(_(SOpenDialogFilter), [_('text file')]);
  end;
  with Categories[5] do begin
    DisplayName := _('Editor');
    SetLength(Options, 19);
    Options[0].PropertyName := 'SearchTextAtCaret';
    Options[0].DisplayName := _('Search text at caret');
    Options[1].PropertyName := 'CreateBackupFiles';
    Options[1].DisplayName := _('Create backup files');
    Options[2].PropertyName := 'UndoAfterSave';
    Options[2].DisplayName := _('Undo after save');
    Options[3].PropertyName := 'ShowCodeHints';
    Options[3].DisplayName := _('Show code hints');
    Options[4].PropertyName := 'ShowDebuggerHints';
    Options[4].DisplayName := _('Show debugger hints');
    Options[5].PropertyName := 'AutoCompleteBrackets';
    Options[5].DisplayName := _('Auto-complete brackets');
    Options[6].PropertyName := 'MarkExecutableLines';
    Options[6].DisplayName := _('Show executable line marks');
    Options[7].PropertyName := 'NewFileLineBreaks';
    Options[7].DisplayName := _('Default line break format for new files');
    Options[8].PropertyName := 'NewFileEncoding';
    Options[8].DisplayName := _('Default file encoding for new files');
    Options[9].PropertyName := 'DetectUTF8Encoding';
    Options[9].DisplayName := _('Detect UTF-8 encoding when opening files');
    Options[10].PropertyName := 'AutoReloadChangedFiles';
    Options[10].DisplayName := _('Auto-reload changed files');
    Options[11].PropertyName := 'AutoHideFindToolbar';
    Options[11].DisplayName := _('Auto-hide find toolbar');
    Options[12].PropertyName := 'HighlightSelectedWord';
    Options[12].DisplayName := _('Highlight selected word');
    Options[13].PropertyName := 'HighlightSelectedWordColor';
    Options[13].DisplayName := _('Highlight color of selected word');
    Options[14].PropertyName := 'DisplayPackageNames';
    Options[14].DisplayName := _('Display package names in editor tabs');
    Options[15].PropertyName := 'CodeFoldingEnabled';
    Options[15].DisplayName := _('Code folding enabled by default');
    Options[16].PropertyName := 'CodeFolding';
    Options[16].DisplayName := _('Code folding options');
    Options[17].PropertyName := 'CompactLineNumbers';
    Options[17].DisplayName := _('Compact Line Numbers');
    Options[18].PropertyName := 'TrimTrailingSpacesOnSave';
    Options[18].DisplayName := _('Trim trailing spaces when files are saved');
  end;
  with Categories[6] do begin
    DisplayName := _('Code Completion');
    SetLength(Options, 9);
    Options[0].PropertyName := 'CodeCompletionListSize';
    Options[0].DisplayName := _('Code completion list size');
    Options[1].PropertyName := 'EditorCodeCompletion';
    Options[1].DisplayName := _('Editor code completion');
    Options[2].PropertyName := 'InterpreterCodeCompletion';
    Options[2].DisplayName := _('Interpreter code completion');
    Options[3].PropertyName := 'CodeCompletionCaseSensitive';
    Options[3].DisplayName := _('Case sensitive');
    Options[4].PropertyName := 'CompleteKeywords';
    Options[4].DisplayName := _('Complete Python keywords');
    Options[5].PropertyName := 'CompleteAsYouType';
    Options[5].DisplayName := _('Complete as you type');
    Options[6].PropertyName := 'AutoCompletionFont';
    Options[6].DisplayName := _('Auto completion font');
    Options[7].PropertyName := 'CompleteWithWordBreakChars';
    Options[7].DisplayName := _('Complete with word-break characters');
    Options[8].PropertyName := 'CompleteWithOneEntry';
    Options[8].DisplayName := _('Auto-complete with one entry');
  end;
  with Categories[7] do begin
    DisplayName := _('Shell Integration');
    SetLength(Options, 1);
    Options[0].PropertyName := 'FileExplorerContextMenu';
    Options[0].DisplayName := _('File Explorer context menu');
  end;
  with Categories[8] do begin
    DisplayName := _('File Explorer');
    SetLength(Options, 2);
    Options[0].PropertyName := 'FileExplorerBackgroundProcessing';
    Options[0].DisplayName := _('File Explorer background processing');
    Options[1].PropertyName := 'FileChangeNotification';
    Options[1].DisplayName := _('File Change Notification');
  end;
  with Categories[9] do begin
    DisplayName := 'SSH';
    SetLength(Options, 5);
    Options[0].PropertyName := 'SSHCommand';
    Options[0].DisplayName := _('SSH command');
    Options[1].PropertyName := 'SSHOptions';
    Options[1].DisplayName := _('SSH options');
    Options[2].PropertyName := 'ScpCommand';
    Options[2].DisplayName := _('SCP command');
    Options[3].PropertyName := 'ScpOptions';
    Options[3].DisplayName := _('SCP options');
    Options[4].PropertyName := 'SSHDisableVariablesWin';
    Options[4].DisplayName := _('Disable Variables Window with SSH');
  end;
  with Categories[10] do begin
    DisplayName := _('Language Server');
    SetLength(Options, 3);
    Options[0].PropertyName := 'LspDebug';
    Options[0].DisplayName := _('Language server debug output');
    Options[1].PropertyName := 'CheckSyntaxAsYouType';
    Options[1].DisplayName := _('Check syntax as you type');
    Options[2].PropertyName := 'SpecialPackages';
    Options[2].DisplayName := _('Special packages');
  end;

  // Shell Integration
  IsRegistered := False;
  Reg := TRegistry.Create(KEY_READ and not KEY_NOTIFY);
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    Key := 'Python.File\shell\Edit with PyScripter';
    IsRegistered := Reg.KeyExists(Key);
  except
  end;
  FreeAndNil(Reg);

  PyIDEOptions.FileExplorerContextMenu := IsRegistered;

  PyIDEOptions.SearchTextAtCaret := EditorSearchOptions.SearchTextAtCaret;

  if InspectOptions(PyIDEOptions, Categories, _(SIDEOptions), 610) then begin
    PyIDEOptions.Changed;
    PyIDEMainForm.StoreApplicationData;
    if PyIDEOptions.FileExplorerContextMenu <> IsRegistered then begin
      Reg := TRegistry.Create;
      try
        Reg.RootKey := HKEY_CLASSES_ROOT;
        if IsRegistered then begin
          Reg.DeleteKey(Key)
        end else begin
          Reg.OpenKey(Key, True);
          Reg.CloseKey;
          Reg.OpenKey(Key + '\command', True);
          Reg.WriteString('', '"'+ Application.ExeName + ' "%1"');
          Reg.CloseKey;
        end;

        SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
      except
        StyledMessageDlg(_(SRegistryAccessDenied), mtError, [mbOK], 0);
      end;
      FreeAndNil(Reg);
    end;
  end;
end;

procedure TCommandsDataModule.actIDEShortcutsExecute(Sender: TObject);
begin
  with TfrmCustomKeyboard.Create(Self) do begin
    if Execute then
      PyIDEMainForm.StoreApplicationData;
    Release;
  end;
end;

procedure TCommandsDataModule.actPythonPathExecute(Sender: TObject);
Var
  Paths : TStringList;
begin
  if not GI_PyControl.PythonLoaded then Exit;

  Paths := TStringList.Create;
  try
    PyControl.ActiveInterpreter.SysPathToStrings(Paths);
    if EditFolderList(Paths, _('Python Path'), 870) then
      PyControl.ActiveInterpreter.StringsToSysPath(Paths);
  finally
    Paths.Free;
  end;
end;

procedure TCommandsDataModule.actAboutExecute(Sender: TObject);
begin
  with TAboutBox.Create(Self) do begin
    ShowModal;
    Release;
  end;
end;

procedure TCommandsDataModule.actPythonManualsExecute(Sender: TObject);
Var
  OldHelpFile : string;
begin
  if PyControl.PythonHelpFile <> '' then begin
    OldHelpFile := Application.HelpFile;
    Application.HelpFile := PyControl.PythonHelpFile;
    PyIDEMainForm.MenuHelpRequested := True;
    try
      Application.HelpCommand(HELP_CONTENTS, 0);
    finally
      Application.HelpFile := OldHelpFile;
      PyIDEMainForm.MenuHelpRequested := False;
    end;
  end;
end;

function TCommandsDataModule.ShowPythonKeywordHelp(KeyWord : string): Boolean;
Var
  OldHelpFile : string;
begin
  Result := False;
  if PyControl.PythonHelpFile <> '' then begin
    OldHelpFile := Application.HelpFile;
    Application.HelpFile := PyControl.PythonHelpFile;
    PyIDEMainForm.PythonKeywordHelpRequested := True;
    try
      Result := Application.HelpKeyword(KeyWord);
    finally
      PyIDEMainForm.PythonKeywordHelpRequested := False;
      Application.HelpFile := OldHelpFile;
    end;
  end;
end;

procedure TCommandsDataModule.UpdateImageCollections;
  procedure ProcessImageCollection(IC: TSVGIconImageCollection;
    FixedColor: TColor; AntiAliasColor: TColor= clDefault);
  begin
    IC.SVGIconItems.BeginUpdate;
    try
      IC.FixedColor := SvgFixedColor(FixedColor);

      if AntiAliasColor <> clDefault then
        IC.AntiAliasColor := StyleServices.GetSystemColor(AntiAliasColor);
    finally
      IC.SVGIconItems.EndUpdate;
    end;
  end;

var
  TextColor: TColor;
begin
  var Details := StyleServices.GetElementDetails(ttbButtonNormal);
  if not StyleServices.GetElementColor(Details, ecTextColor, TextColor) then
    TextColor := StyleServices.GetSystemColor(clBtnText);

  ProcessImageCollection(icBrowserImages, TextColor);
  ProcessImageCollection(icCodeImages, clWindowText, clWindow);
  ProcessImageCollection(icGutterGlyphs, TextColor);
  ProcessImageCollection(icSVGImages, TextColor);
end;

procedure TCommandsDataModule.UpdateMainActions;
Var
  SelAvail : Boolean;
  Editor : IEditor;
  SearchCommands : ISearchCommands;
begin
  Editor := GI_PyIDEServices.ActiveEditor;
  // Edit actions
//  actEditCut.Enabled := (GI_EditCmds <> nil) and GI_EditCmds.CanCut;
//  actEditCopy.Enabled := (GI_EditCmds <> nil) and GI_EditCmds.CanCopy;
//  actEditPaste.Enabled := (GI_EditCmds <> nil) and GI_EditCmds.CanPaste;
//  actEditDelete.Enabled := (GI_EditCmds <> nil) and GI_EditCmds.CanDelete;
//  actEditSelectAll.Enabled := (GI_EditCmds <> nil) and GI_EditCmds.CanSelectAll;
//  actEditUndo.Enabled := (GI_EditCmds <> nil) and GI_EditCmds.CanUndo;
  actEditRedo.Enabled := (GI_EditCmds <> nil) and GI_EditCmds.CanRedo;
  actEditCopyFileName.Enabled := Assigned(Editor);

  actFoldVisible.Enabled := Assigned(GI_ActiveEditor);
  actFoldVisible.Checked := Assigned(GI_ActiveEditor) and
    GI_ActiveEditor.SynEdit.UseCodeFolding;
  actFoldAll.Enabled := actFoldVisible.Checked;
  actUnfoldAll.Enabled := actFoldVisible.Checked;
  actFoldNearest.Enabled := actFoldVisible.Checked;
  actUnfoldNearest.Enabled := actFoldVisible.Checked;
  actFoldRegions.Enabled := actFoldVisible.Checked;
  actUnfoldRegions.Enabled := actFoldVisible.Checked;
  actFoldLevel1.Enabled := actFoldVisible.Checked;
  actUnfoldLevel1.Enabled := actFoldVisible.Checked;
  actFoldLevel2.Enabled := actFoldVisible.Checked;
  actUnfoldLevel2.Enabled := actFoldVisible.Checked;
  actFoldLevel3.Enabled := actFoldVisible.Checked;
  actUnfoldLevel3.Enabled := actFoldVisible.Checked;
  actFoldClasses.Enabled := actFoldVisible.Checked;
  actUnfoldClasses.Enabled := actFoldVisible.Checked;
  actFoldFunctions.Enabled := actFoldVisible.Checked;
  actUnfoldFunctions.Enabled := actFoldVisible.Checked;

  actEditLBDos.Enabled := Assigned(GI_ActiveEditor);
  actEditLBDos.Checked := Assigned(GI_ActiveEditor) and
    ((GI_ActiveEditor.SynEdit.Lines as TSynEditStringList).FileFormat = sffDos);
  actEditLBUnix.Enabled := Assigned(GI_ActiveEditor);
  actEditLBUnix.Checked := Assigned(GI_ActiveEditor) and
    ((GI_ActiveEditor.SynEdit.Lines as TSynEditStringList).FileFormat = sffUnix);
  actEditLBMac.Enabled := Assigned(GI_ActiveEditor);
  actEditLBMac.Checked := Assigned(GI_ActiveEditor) and
    ((GI_ActiveEditor.SynEdit.Lines as TSynEditStringList).FileFormat = sffMac);
  actEditAnsi.Enabled := Assigned(GI_ActiveEditor);
  actEditAnsi.Checked := Assigned(GI_ActiveEditor) and
    (GI_ActiveEditor.FileEncoding = sf_Ansi);
  actEditUTF8.Enabled := Assigned(GI_ActiveEditor);
  actEditUTF8.Checked := Assigned(GI_ActiveEditor) and
    (GI_ActiveEditor.FileEncoding = sf_UTF8);
  actEditUTF8NoBOM.Enabled := Assigned(GI_ActiveEditor);
  actEditUTF8NoBOM.Checked := Assigned(GI_ActiveEditor) and
    (GI_ActiveEditor.FileEncoding = sf_UTF8_NoBOM);
  actEditUTF16LE.Enabled := Assigned(GI_ActiveEditor);
  actEditUTF16LE.Checked := Assigned(GI_ActiveEditor) and
    (GI_ActiveEditor.FileEncoding = sf_UTF16LE);
  actEditUTF16BE.Enabled := Assigned(GI_ActiveEditor);
  actEditUTF16BE.Checked := Assigned(GI_ActiveEditor) and
    (GI_ActiveEditor.FileEncoding = sf_UTF16BE);

  SelAvail := Assigned(GI_ActiveEditor) and GI_ActiveEditor.ActiveSynEdit.SelAvail;
  // Source Code Actions
  actEditIndent.Enabled := SelAvail;
  actEditDedent.Enabled := SelAvail;
  actEditTabify.Enabled := SelAvail;
  actEditUnTabify.Enabled := SelAvail;
  actEditToggleComment.Enabled := Assigned(GI_ActiveEditor);
  actEditCommentOut.Enabled := Assigned(GI_ActiveEditor);
  actEditUncomment.Enabled := Assigned(GI_ActiveEditor);
  actEditLineNumbers.Enabled := Assigned(GI_ActiveEditor);
  actEditWordWrap.Enabled := Assigned(GI_ActiveEditor);
  actEditReadOnly.Enabled := Assigned(GI_ActiveEditor);
  actEditReadOnly.Checked := Assigned(GI_ActiveEditor) and GI_ActiveEditor.ReadOnly;
  actEditShowSpecialChars.Enabled := Assigned(GI_ActiveEditor);
  if Assigned(GI_ActiveEditor) then begin
    actEditLineNumbers.Checked := GI_ActiveEditor.ActiveSynEdit.Gutter.ShowLineNumbers;
    actEditWordWrap.Checked := GI_ActiveEditor.ActiveSynEdit.WordWrap;
    actEditShowSpecialChars.Checked := eoShowSpecialChars in GI_ActiveEditor.ActiveSynEdit.Options;
  end else begin
    actEditLineNumbers.Checked := False;
    actEditWordWrap.Checked := False;
    actEditShowSpecialChars.Checked := False;
  end;

  // File Actions
  actFileReload.Enabled := (GI_FileCmds <> nil) and GI_FileCmds.CanReload;
  actFileClose.Enabled := Assigned(Editor) and Editor.CanClose;
  actFilePrint.Enabled := (GI_FileCmds <> nil) and GI_FileCmds.CanPrint;
  actPrintPreview.Enabled := actFilePrint.Enabled;
  actFileSave.Enabled := (GI_FileCmds <> nil) and GI_FileCmds.CanSave;
  actFileSaveAs.Enabled := (GI_FileCmds <> nil) and GI_FileCmds.CanSaveAs;
  actFileSaveToRemote.Enabled := actFileSaveAs.Enabled;
  // Lesson to remember do not change the Enabled state of an Action from false to true
  // and back within an Update or OnIdle handler. The result is 100% CPU utilisation.
  actFileSaveAll.Enabled := Assigned(GI_EditorFactory.FirstEditorCond(
  function(Ed: IEditor): Boolean
  begin
    Result := (Ed as IFileCommands).CanSave;
  end));

  // Search Actions
  SearchCommands := FindSearchTarget;
  actSearchFind.Enabled := (SearchCommands <> nil) and SearchCommands.CanFind;
  actSearchFindNext.Enabled := (SearchCommands <> nil) and SearchCommands.CanFindNext;
  actSearchFindPrev.Enabled := actSearchFindNext.Enabled;
  actSearchReplace.Enabled := (SearchCommands <> nil) and SearchCommands.CanReplace;
  actSearchReplaceNow.Enabled := actSearchFindNext.Enabled and SearchCommands.CanReplace;

  SearchCommands := nil;
  if Assigned(Editor) then
    SearchCommands := Editor as ISearchCommands;
  actSearchHighlight.Checked := Assigned(Editor) and Editor.HasSearchHighlight;
  actSearchHighlight.Enabled := actSearchHighlight.Checked or Assigned(Editor) and
     (EditorSearchOptions.SearchText <> '') ;

  actSearchMatchingBrace.Enabled := Assigned(GI_ActiveEditor);
  actSearchGoToLine.Enabled := Assigned(GI_ActiveEditor);
  actSearchGoToSyntaxError.Enabled := Assigned(GI_ActiveEditor) and
    TEditorForm(GI_ActiveEditor.Form).HasSyntaxError;
  actSearchGoToDebugLine.Enabled := (PyControl.CurrentPos.Line >= 1) and
    (PyControl.ActiveDebugger <> nil) and not GI_PyControl.Running;
  actFindInFiles.Enabled := not FindResultsWindow.DoingSearchOrReplace;

  if Assigned(GI_ActiveEditor) and GI_ActiveEditor.HasPythonFile then begin
    actFindFunction.Enabled := True;
    actUnitTestWizard.Enabled := True;
  end else begin
    actFindFunction.Enabled := False;
    actUnitTestWizard.Enabled := False;
  end;

  // Parameter and Code Template Actions
  if Screen.ActiveControl is TSynEdit then begin
    actParameterCompletion.Enabled := True;
    actModifierCompletion.Enabled := True;
    actReplaceParameters.Enabled := Assigned(GI_ActiveEditor);
    actInsertTemplate.Enabled := Assigned(GI_ActiveEditor);
  end else begin
    actParameterCompletion.Enabled := False;
    actModifierCompletion.Enabled := False;
    actReplaceParameters.Enabled := False;
    actInsertTemplate.Enabled := False;
  end;
  // Other actions
  actPythonPath.Enabled := GI_PyControl.PythonLoaded;
end;

procedure TCommandsDataModule.actHelpContentsExecute(Sender: TObject);
begin
  PyIDEMainForm.MenuHelpRequested := True;
  Application.HelpCommand(HELP_CONTENTS, 0);
  PyIDEMainForm.MenuHelpRequested := False;
end;

procedure TCommandsDataModule.ParameterCompletionCodeCompletion(
  Sender: TObject; var Value: string; Shift: TShiftState; Index: Integer;
  EndToken: WideChar);
begin
  if ssCtrl in Shift then
    Value := Parameters.Values[Value]
  else
    Value := Parameters.MakeParameter(Value);
end;

procedure TCommandsDataModule.ParameterCompletionExecute(
  Kind: SynCompletionType; Sender: TObject; var CurrentInput: string; var x,
  y: Integer; var CanExecute: Boolean);
begin
  PrepareParameterCompletion;
end;

procedure TCommandsDataModule.ModifierCompletionCodeCompletion(
  Sender: TObject; var Value: string; Shift: TShiftState; Index: Integer;
  EndToken: WideChar);
var
  L: Integer;
begin
  if Assigned(ModifierCompletion.Editor) then
    with ModifierCompletion.Editor do begin
      SelText := '';
      L:= Length(Parameters.StopMask);
      if (CaretX > 0) and WideSameStr(Copy(LineText, CaretX-L, L), Parameters.StopMask) then begin
        CaretX:= CaretX - L;
        Value := '-' + Value;
      end else if not ((CaretX > 1) and (Lines[CaretY-1][CaretX-1] = '-')) then begin
        L:= StrLastPos(Parameters.StopMask, LineText);
        if L > 0 then CaretX:= L;
        Value := '-' + Value;
      end;
    end;
end;

procedure TCommandsDataModule.ModifierCompletionExecute(Kind: SynCompletionType;
  Sender: TObject; var CurrentInput: string; var x, y: Integer;
  var CanExecute: Boolean);
begin
  PrepareModifierCompletion;
end;

procedure TCommandsDataModule.actParameterCompletionExecute(
  Sender: TObject);
begin
  if Screen.ActiveControl is TSynedit then begin
    ParameterCompletion.Title := _('Parameters');
    ParameterCompletion.NbLinesInWindow := PyIDEOptions.CodeCompletionListSize;
    ParameterCompletion.Editor := TSynEdit(Screen.ActiveControl);
    ParameterCompletion.ActivateCompletion;
  end;
end;

procedure TCommandsDataModule.actModifierCompletionExecute(
  Sender: TObject);
begin
  if Screen.ActiveControl is TSynedit then begin
    ModifierCompletion.Title := _('Modifiers');
    ModifierCompletion.NbLinesInWindow := PyIDEOptions.CodeCompletionListSize;
    ModifierCompletion.Editor := TSynEdit(Screen.ActiveControl);
    ModifierCompletion.ActivateCompletion;
  end;
end;

procedure TCommandsDataModule.actReplaceParametersExecute(Sender: TObject);
var
  i, j: Integer;
  S : string;
  OldCaret : TBufferCoord;
begin
  if Screen.ActiveControl is TSynedit then
    with TSynEdit(Screen.ActiveControl) do begin
      OldCaret := CaretXY;
      if SelAvail then
        SelText:= Parameters.ReplaceInText(SelText)
      else try
        BeginUpdate;
        with Parameters do begin
          for i:= 0 to Lines.Count-1 do begin
            S:= Lines[i];
            j:= AnsiPos(StartMask, S);
            if j > 0 then begin
              BeginUndoBlock;
              try
                BlockBegin:= BufferCoord(j, i+1);
                BlockEnd:= BufferCoord(Length(S)+1, i+1);
                SelText:= ReplaceInText(Copy(S, j, MaxInt));
              finally
                EndUndoBlock;
              end;
            end;
          end;
        end;
      finally
        EndUpdate;
      end;
      CaretXY := OldCaret;
    end;
end;

type
  TCrackSynAutoComplete = class(TSynAutoComplete)
  end;

procedure TCommandsDataModule.actInsertTemplateExecute(Sender: TObject);
Var
  SynEdit : TSynEdit;
begin
  if (Screen.ActiveControl is TSynedit) and Assigned(GI_ActiveEditor) then begin
    SynEdit := TSynEdit(Screen.ActiveControl);
    CodeTemplatesCompletion.Execute(TCrackSynAutoComplete(CodeTemplatesCompletion).
      GetPreviousToken(SynEdit), SynEdit);
  end;
end;

procedure TCommandsDataModule.actHelpParametersExecute(Sender: TObject);
begin
  PyIDEMainForm.MenuHelpRequested := True;
  Application.HelpJump('parameters');
  PyIDEMainForm.MenuHelpRequested := False;
end;

procedure TCommandsDataModule.actHelpWebBlogExecute(Sender: TObject);
begin
  OpenObject('http://pyscripter.blogspot.com/');
end;

procedure TCommandsDataModule.actHelpWebGroupSupportExecute(Sender: TObject);
begin
  OpenObject('http://groups.google.com/group/PyScripter');
end;

procedure TCommandsDataModule.actHelpWebProjectHomeExecute(Sender: TObject);
begin
  OpenObject('https://github.com/pyscripter/pyscripter');
end;

procedure TCommandsDataModule.actDonateExecute(Sender: TObject);
begin
  OpenObject('https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=SX9B6G2GF5K4U');
end;

procedure TCommandsDataModule.actHelpExternalToolsExecute(Sender: TObject);
begin
  PyIDEMainForm.MenuHelpRequested := True;
  Application.HelpJump('externaltools');
  PyIDEMainForm.MenuHelpRequested := False;
end;

procedure TCommandsDataModule.actHelpEditorShortcutsExecute(
  Sender: TObject);
begin
  PyIDEMainForm.MenuHelpRequested := True;
  Application.HelpJump('editorshortcuts');
  PyIDEMainForm.MenuHelpRequested := False;
end;

procedure TCommandsDataModule.actCustomizeParametersExecute(
  Sender: TObject);
begin
  with TCustomizeParams.Create(Self) do begin
    SetItems(CustomParams);
    if ShowModal = mrOK then begin
      GetItems(CustomParams);
      RegisterCustomParams;
    end;
    Free;
  end;
end;

procedure TCommandsDataModule.actCodeTemplatesExecute(Sender: TObject);
begin
  with TCodeTemplates.Create(Self) do begin
    //SetItems(CodeTemplatesCompletion.AutoCompleteList);
    CodeTemplateText := CodeTemplatesCompletion.AutoCompleteList.Text;
    if ShowModal = mrOK then
      CodeTemplatesCompletion.AutoCompleteList.Text := CodeTemplateText;
    Free;
  end;
end;

procedure TCommandsDataModule.actFileTemplatesExecute(Sender: TObject);
begin
  with TFileTemplatesDialog.Create(Self) do begin
    SetItems;
    if ShowModal = mrOK then
      GetItems;
    Free;
  end;
end;

procedure TCommandsDataModule.actConfigureToolsExecute(Sender: TObject);
begin
  if EditCollection(ToolsCollection, TToolItem, _('Configure Tools'), EditToolItem, 710) then
  begin
    PyIDEMainForm.SetupToolsMenu;
    PyIDEMainForm.SetupCustomizer;
  end;
end;

procedure TCommandsDataModule.actEditCopyFileNameExecute(Sender: TObject);
Var
  Editor : IEditor;
begin
  Editor := GI_PyIDEServices.ActiveEditor;
  if Assigned(Editor) then
    Clipboard.AsText := Editor.FileId;
end;

procedure TCommandsDataModule.actFindFunctionExecute(Sender: TObject);
begin
  JumpToFunction;
end;

procedure TCommandsDataModule.actEditLineNumbersExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.Gutter.ShowLineNumbers := not
      GI_ActiveEditor.ActiveSynEdit.Gutter.ShowLineNumbers;
end;

procedure TCommandsDataModule.actEditWordWrapExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.WordWrap := not GI_ActiveEditor.ActiveSynEdit.WordWrap;
end;

procedure TCommandsDataModule.actEditShowSpecialCharsExecute(
  Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    if eoShowSpecialChars in GI_ActiveEditor.ActiveSynEdit.Options then
      GI_ActiveEditor.ActiveSynEdit.Options := GI_ActiveEditor.ActiveSynEdit.Options - [eoShowSpecialChars]
    else
      GI_ActiveEditor.ActiveSynEdit.Options := GI_ActiveEditor.ActiveSynEdit.Options + [eoShowSpecialChars]
end;

procedure TCommandsDataModule.actFindNextReferenceExecute(
  Sender: TObject);
var
  SearchOptions: TSynSearchOptions;
  SearchText : string;
  OldCaret : TBufferCoord;
begin
  if Assigned(GI_ActiveEditor) then with GI_ActiveEditor.ActiveSynEdit do begin
    SearchText :=  WordAtCursor;
    if SearchText <> '' then begin
      OldCaret := CaretXY;

      SearchEngine := SynEditSearch;
      SearchOptions := [];
      if (Sender as TComponent).Tag = 1 then
        Include(SearchOptions, ssoBackwards)
      else
        CaretX := CaretX + 1;  //  So that we find the next identifier
      Include(SearchOptions, ssoMatchCase);
      Include(SearchOptions, ssoWholeWord);
      GI_PyIDEServices.WriteStatusMsg('');
      if SearchReplace(SearchText, '', SearchOptions) = 0 then begin
        CaretXY := OldCaret;
        MessageBeep(MB_ICONASTERISK);
        GI_PyIDEServices.WriteStatusMsg(Format(_(SNotFound), [SearchText]));
      end else begin
        CaretXY := BlockBegin;
      end;
    end;
  end;
end;

procedure TCommandsDataModule.actFoldAllExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.CollapseAll;
end;

procedure TCommandsDataModule.actFoldClassesExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.CollapseFoldType(3);
end;

procedure TCommandsDataModule.actFoldFunctionsExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.CollapseFoldType(4);
end;

procedure TCommandsDataModule.actFoldLevel1Execute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.ExecuteCommand(ecFoldLevel1, ' ', nil);
end;

procedure TCommandsDataModule.actFoldLevel2Execute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.ExecuteCommand(ecFoldLevel2, ' ', nil);
end;

procedure TCommandsDataModule.actFoldLevel3Execute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.ExecuteCommand(ecFoldLevel3, ' ', nil);
end;

procedure TCommandsDataModule.actFoldNearestExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.ExecuteCommand(ecFoldNearest, ' ', nil);
end;

procedure TCommandsDataModule.actFoldRegionsExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.ExecuteCommand(ecFoldRegions, ' ', nil);
end;

procedure TCommandsDataModule.actFoldVisibleExecute(Sender: TObject);
begin
  if Assigned(GI_ActiveEditor) then
    GI_ActiveEditor.ActiveSynEdit.UseCodeFolding :=
      not GI_ActiveEditor.ActiveSynEdit.UseCodeFolding;
end;

procedure TCommandsDataModule.actCheckForUpdatesExecute(Sender: TObject);
Var
  PlatformSuffix : string;
begin
  {$IFDEF WIN64}
  PlatformSuffix := '-x64';
  {$ELSE}
  PlatformSuffix := '';
  {$ENDIF}
  ProgramVersionHTTPLocation.VersionInfoFileName := 'PyScripterVersionInfo' +
    PlatformSuffix + '.ini';
  try
    ProgramVersionCheck.LocalDirectory := TPyScripterSettings.UserDataPath + 'Updates';
    try
      FormatSettings.DateSeparator := '/';
      FormatSettings.ShortDateFormat := 'dd/MM/yyyy';
      ProgramVersionCheck.Execute;
    finally
      GetFormatSettings;
    end;
  except
    if Assigned(Sender) then
      raise
    else
      Exit;
  end;

  if Assigned(Sender) and not ProgramVersionCheck.IsRemoteProgramVersionNewer then
    if ProgramVersionCheck.DownloadError <> '' then
      StyledMessageDlg(_(SErrorWhileDownload) +
        ProgramVersionCheck.DownloadError, mtError, [mbOK], 0)
    else
      StyledMessageDlg(_(SCurrentVersionUptodate), mtInformation, [mbOK], 0);
  PyIDEOptions.DateLastCheckedForUpdates := Now;
end;

procedure TCommandsDataModule.actToolsRestartLSExecute(Sender: TObject);
begin
  TJedi.CreateServer;
end;

procedure TCommandsDataModule.GetEditorUserCommand(AUserCommand: Integer;
  var ADescription: string);
begin
  if AUserCommand = ecCodeCompletion then
    ADescription := _(SEdCmdCodeCompletion)
  else if AUserCommand = ecParamCompletion then
    ADescription := _(SEdCmdParameterCompletion)
  else if AUserCommand = ecSelMatchBracket then
    ADescription := _(SEdCmdSelectToBracket);
end;

procedure TCommandsDataModule.GetEditorAllUserCommands(ACommands: TStrings);
begin
  ACommands.AddObject(_(SEdCmdCodeCompletion), TObject(ecCodeCompletion));
  ACommands.AddObject(_(SEdCmdParameterCompletion), TObject(ecParamCompletion));
  ACommands.AddObject(_(SEdCmdSelectToBracket), TObject(ecSelMatchBracket));
end;

function TCommandsDataModule.DoSearchReplaceText(SynEdit : TSynEdit;
      AReplace, ABackwards : Boolean ; IsIncremental : Boolean = False) : integer;

  function EndReached(ABackWards, SelectionOnly : Boolean) : string;
  begin
    if ABackwards then
      Result := Format(_(SReachedTheStart),
              [iif(SelectionOnly, _(SOfTheSelection), _(SOfTheDocument))])
    else
      Result := Format(_(SReachedTheEnd),
              [iif(SelectionOnly, _(SOfTheSelection), _(SOfTheDocument))]);
  end;

var
  Options: TSynSearchOptions;
  IsNewSearch : Boolean;
  MsgText : string;
  OldCaretXY, OldBlockBegin, OldBlockEnd : TBufferCoord;
  dlgID : integer;
  OldNoReplaceCount : integer;
begin
  Result := 0;
  OldNoReplaceCount := 0;

  if EditorSearchOptions.SearchText = '' then Exit; //Nothing to Search
  if PyIDEOptions.AutoHideFindToolbar and not IsIncremental then begin
    PyIDEMainForm.FindToolbar.Visible := False;
  end;
  if EditorSearchOptions.UseRegExp then
    SynEdit.SearchEngine := SynEditRegexSearch
  else
    SynEdit.SearchEngine := SynEditSearch;

  IsNewSearch := (EditorSearchOptions.InitBlockBegin.Char = 0) or
                 (EditorSearchOptions.BackwardSearch <> ABackwards);
  if IsNewSearch then
    EditorSearchOptions.NewSearch(SynEdit, ABackwards);

  if AReplace then begin
    Options := [ssoPrompt, ssoReplace, ssoReplaceAll];
    EditorSearchOptions.NoReplaceCount := 0;
  end else
    Options := [];
  if ABackwards then
    Include(Options, ssoBackwards);
  case EditorSearchOptions.SearchCaseSensitiveType of
    scsAuto:
      if LowerCase(EditorSearchOptions.SearchText) <> EditorSearchOptions.SearchText then
        Include(Options, ssoMatchCase);
    scsCaseSensitive : Include(Options, ssoMatchCase);
  end;
  if not EditorSearchOptions.TempSearchFromCaret then
    Include(Options, ssoEntireScope);
  if EditorSearchOptions.SearchWholeWords then
    Include(Options, ssoWholeWord);

  if EditorSearchOptions.TempSelectionOnly then with EditorSearchOptions do begin
    Options := Options + [ssoSelectedOnly, ssoEntireScope];
    // we need to restrict the scope of search within the orginal selection
    if not IsNewSearch then begin
      OldCaretXY := SynEdit.CaretXY;
      OldBlockBegin := SynEdit.BlockBegin;
      OldBlockEnd := SynEdit.BlockEnd;
      if ABackwards then
        SynEdit.SetCaretAndSelection(SynEdit.BlockBegin, InitBlockBegin, SynEdit.BlockBegin)
      else
        SynEdit.SetCaretAndSelection(SynEdit.CaretXY, SynEdit.CaretXY, InitBlockEnd);
    end;
  end;

  with EditorSearchOptions do begin
    if WrappedSearch and CanWrapSearch then begin
      // we need to restrict the scope of search within the remaining space
      CanWrapSearch := False;  //Only do this block once
      TempSelectionOnly := True;
      Options := Options + [ssoSelectedOnly, ssoEntireScope];
      if ABackwards then begin
        InitBlockBegin := InitCaretXY;
        InitCaretXY := InitBlockEnd;
      end else begin
        InitBlockEnd := InitCaretXY;
        InitCaretXY := InitBlockBegin;
      end;
      SynEdit.SetCaretAndSelection(InitCaretXY, InitBlockBegin, InitBlockEnd);
      if (ssoReplace in Options) and (LastReplaceAction = raReplaceAll) then
        Options := Options - [ssoPrompt];
    end;
  end;

  GI_PyIDEServices.WriteStatusMsg('');

  if (EditorSearchOptions.TempSelectionOnly and
     (SynEdit.BlockBegin.Char = Synedit.BlockEnd.Char) and
     (SynEdit.BlockBegin.Line = Synedit.BlockEnd.Line))
  then
    Result := 0
  else
    try
        Result := SynEdit.SearchReplace(EditorSearchOptions.SearchText,
         EditorSearchOptions.ReplaceText, Options);
    except
      on E: ESynRegEx do begin
        Result := 0;
        MessageBeep(MB_ICONERROR);
        GI_PyIDEServices.WriteStatusMsg(Format(_(SInvalidRegularExpression), [E.Message]));
        Exit;
      end;
    end;

  if (Result = 0) or (ssoReplace in Options) then with EditorSearchOptions do begin
    MessageBeep(MB_ICONASTERISK);
    TempSearchFromCaret := False;
    if TempSelectionOnly and not WrappedSearch then
      // Restore the original selection
      SynEdit.SetCaretAndSelection(InitCaretXY, InitBlockBegin, InitBlockEnd)
    else if TempSelectionOnly and WrappedSearch and not (ssoReplace in Options) then
      SynEdit.SetCaretAndSelection(OldCaretXY, OldBlockBegin, OldBlockEnd);

    if WrappedSearch then begin
      MsgText := _(SStartReached);
      GI_PyIDEServices.WriteStatusMsg(MsgText);
      DSAMessageDlg(dsaSearchStartReached, 'PyScripter', MsgText,
         mtInformation, [mbOK], 0, dckActiveForm, 0, mbOK);
      InitSearch;
    end else begin
      MsgText := EndReached(ABackwards, TempSelectionOnly);
      if Result = 0 then
        GI_PyIDEServices.WriteStatusMsg(Format(_(SNotFound), [SearchText]))
      else
        GI_PyIDEServices.WriteStatusMsg(MsgText);
      if CanWrapSearch and (LastReplaceAction <> raCancel) then begin
        dlgID := iff(ssoReplace in Options, dsaReplaceFromStart, dsaSearchFromStart);
        MsgText :=  Format(MsgText + sLineBreak + _(SContinueSearch),
          [iff(ssoReplace in Options, _(STheSearchAndReplace), _(STheSearch)),
           iif(ABackwards, _(SFromTheEnd), _(SFromTheStart))]);

        if  IsIncremental or (DSAMessageDlg(dlgID, 'PyScripter', MsgText,
           mtConfirmation, [mbYes, mbNo], 0, dckActiveForm, 0, mbYes, mbNo) = mrYes) then
        begin
          WrappedSearch := True;
          OldNoReplaceCount := NoReplaceCount;
          Result := Result + DoSearchReplaceText(SynEdit,  AReplace, ABackwards, IsIncremental);
        end;
      end else begin
        MsgText := _(SStartReached);
        if (Result = 0) and not (ssoReplace in Options) then
          GI_PyIDEServices.WriteStatusMsg(Format(_(SNotFound), [SearchText]))
        else
          GI_PyIDEServices.WriteStatusMsg(MsgText);
        InitSearch;
      end;
      if (ssoReplace in Options) and (Result > 0) then begin
        MsgText := Format(_(SItemsReplaced), [Result, Result - NoReplaceCount - OldNoReplaceCount]);
        GI_PyIDEServices.WriteStatusMsg(MsgText);
        DSAMessageDlg(dsaReplaceNumber, 'PyScripter', MsgText,
           mtInformation, [mbOK], 0, dckActiveForm, 0, mbOK);
      end;
    end;
  end else
    EditorSearchOptions.TempSearchFromCaret := True;

  if ConfirmReplaceDialog <> nil then
    ConfirmReplaceDialog.Free;
end;

function TCommandsDataModule.FindSearchTarget: ISearchCommands;
Var
  Editor : IEditor;
begin
  Result := GI_SearchCmds;
  if not Assigned(GI_SearchCmds) then begin
    if EditorSearchOptions.InterpreterIsSearchTarget and CanActuallyFocus(PythonIIForm.SynEdit) then
      Result := PythonIIForm
    else begin
      Editor := GI_PyIDEServices.ActiveEditor;
      if Assigned(Editor) then
        Result := Editor as ISearchCommands
    end;
  end;
end;

procedure TCommandsDataModule.ShowSearchReplaceDialog(SynEdit : TSynEdit; AReplace: boolean);
Var
  S : string;
begin
  EditorSearchOptions.InitSearch;
  with PyIDEMainForm do begin
    tbiReplaceSeparator.Visible := AReplace;
    tbiReplaceLabel.Visible := AReplace;
    tbiReplaceText.Visible := AReplace;
    tbiReplaceExecute.Visible := AReplace;
    if AReplace then begin
      tbiReplaceText.Text := EditorSearchOptions.ReplaceText;
      tbiReplaceText.Items.CommaText := EditorSearchOptions.ReplaceTextHistory;
      PyIDEMainForm.tbiReplaceTextChange(Self);
    end;
    FindToolbar.Visible := True;
    FindToolbar.View.CancelMode;
    // start with last search text
    tbiSearchText.Text := EditorSearchOptions.SearchText;
    if EditorSearchOptions.SearchTextAtCaret then
    begin
      // if something is selected search for that text
      if SynEdit.SelAvail and (SynEdit.BlockBegin.Line = SynEdit.BlockEnd.Line)
      then
        tbiSearchText.Text := SynEdit.SelText
      else begin
        S := SynEdit.WordAtCursor;
        if S <> '' then
          tbiSearchText.Text := S;
      end;
    end;
    tbiSearchText.Items.CommaText := EditorSearchOptions.SearchTextHistory;
    PyIDEMainForm.tbiSearchTextChange(Self);

    if CanActuallyFocus(tbiSearchText) then
       tbiSearchText.SetFocus;
  end;
end;

procedure TCommandsDataModule.SynEditReplaceText(Sender: TObject; const ASearch,
  AReplace: string; Line, Column: Integer; var Action: TSynReplaceAction);
Var
  APos: TPoint;
  EditRect: TRect;
  SynEdit : TSynEdit;
begin
  SynEdit := Sender as TSynEdit;
  if ASearch = AReplace then
    Action := raSkip
  else begin
    APos := SynEdit.ClientToScreen(
      SynEdit.RowColumnToPixels(
      SynEdit.BufferToDisplayPos(
      BufferCoord(Column, Line) ) ) );
    EditRect := SynEdit.ClientRect;
    EditRect.TopLeft := SynEdit.ClientToScreen(EditRect.TopLeft);
    EditRect.BottomRight := SynEdit.ClientToScreen(EditRect.BottomRight);

    if ConfirmReplaceDialog = nil then begin
      ConfirmReplaceDialog := TConfirmReplaceDialog.Create(Application);
      ConfirmReplaceDialog.btnReplaceAll.ModalResult := mrYesToAll;  //http://www.bobswart.nl/Weblog/Blog.aspx?RootId=5:5029
      fConfirmReplaceDialogRect := ConfirmReplaceDialog.BoundsRect;
    end;
    if EqualRect(fConfirmReplaceDialogRect, ConfirmReplaceDialog.BoundsRect) then begin
      ConfirmReplaceDialog.PrepareShow(EditRect, APos.X, APos.Y,
        APos.Y + SynEdit.LineHeight, ASearch);
      fConfirmReplaceDialogRect := ConfirmReplaceDialog.BoundsRect;
    end else
      fConfirmReplaceDialogRect := Rect(0, 0, 0, 0);

    case ConfirmReplaceDialog.ShowModal of
      mrYes:      Action := raReplace;
      mrYesToAll: Action := raReplaceAll;
      mrNo:       Action := raSkip;
      else        Action := raCancel;
    end;
  end;
  EditorSearchOptions.LastReplaceAction := Action;
  if Action in [raSkip, raCancel] then
    Inc(EditorSearchOptions.fNoReplaceCount);
end;

function TCommandsDataModule.ProgramVersionHTTPLocationLoadFileFromRemote(
  AProgramVersionLocation: TJvProgramVersionHTTPLocation; const ARemotePath,
  ARemoteFileName, ALocalPath, ALocalFileName: string): string;
var
  LocalFileName, URL : string;
begin
  Result := '';
  if (DirectoryExists(ALocalPath) or (ALocalPath = '')) then
    if ALocalFileName = '' then
      LocalFileName := TPath.Combine(ALocalPath, ARemoteFileName)
    else
      LocalFileName := TPath.Combine(ALocalPath, ALocalFileName)
  else
    Exit;

  if Copy(ARemotePath, Length(ARemotePath), 1) <> '/' then
    URL := ARemotePath + '/' + ARemoteFileName
  else
    URL := ARemotePath + ARemoteFileName;

  if DownloadUrlToFile(URL, LocalFileName) and  FileExists(LocalFileName) then
    Result := LocalFileName
  else
  begin
    if FileExists(LocalFileName) then
      DeleteFile(LocalFileName);
    ProgramVersionHTTPLocation.DownloadError := _('File download failed');
  end;
      Result := LocalFileName;
end;

procedure TCommandsDataModule.PyIDEOptionsChanged(Sender: TObject);
begin
  // Parameter Completion
  ParameterCompletion.Font.Assign(PyIDEOptions.AutoCompletionFont);
  ParameterCompletion.TitleFont.Assign(PyIDEOptions.AutoCompletionFont);
  ParameterCompletion.TitleFont.Style := [fsBold];
  // Modifier completion
  ModifierCompletion.Font.Assign(PyIDEOptions.AutoCompletionFont);
  ModifierCompletion.TitleFont.Assign(PyIDEOptions.AutoCompletionFont);
  ModifierCompletion.TitleFont.Style := [fsBold];
  // Syntax Code Completion
  SynCodeCompletion.Font.Assign(PyIDEOptions.AutoCompletionFont);
  with SynCodeCompletion do begin
    if PyIDEOptions.CodeCompletionCaseSensitive then
      Options := Options + [scoCaseSensitive]
    else
      Options := Options - [scoCaseSensitive];
    if PyIDEOptions.CompleteWithWordBreakChars then
      Options := Options + [scoEndCharCompletion]
    else
      Options := Options - [scoEndCharCompletion];

    TriggerChars := '.';
    TimerInterval := 200;
    if PyIDEOptions.CompleteAsYouType then begin
      for var i := ord('a') to ord('z') do TriggerChars := TriggerChars + Chr(i);
      for var i := ord('A') to ord('Z') do TriggerChars := TriggerChars + Chr(i);
      if PyIDEOptions.CompleteWithWordBreakChars or PyIDEOptions.CompleteWithOneEntry then
        TimerInterval := 500
    end;
  end;
  // Syntax Parameter Completion
  SynParamCompletion.Font.Assign(PyIDEOptions.AutoCompletionFont);

  if Assigned(CodeTemplatesCompletion.GetCompletionProposal()) then
  begin
    CodeTemplatesCompletion.GetCompletionProposal().Font.Assign(PyIDEOptions.AutoCompletionFont);
    CodeTemplatesCompletion.GetCompletionProposal().FontsAreScaled := True;
  end;
end;

{ TSynGeneralSyn }

class function TSynGeneralSyn.GetFriendlyLanguageName: string;
begin
  Result := 'General';  // Do not localize
end;

initialization
  EditorSearchOptions := TEditorSearchOptions.Create;
  EditorSearchOptions.fSearchTextAtCaret := True;
  EditorSearchOptions.fSearchFromCaret := True;
  EditorSearchOptions.fIncrementalSearch := True;
  EditorSearchOptions.InitSearch;
  // gettext stuff
  // Classes that should not be translated
  TP_GlobalIgnoreClass(TCustomImageCollection);
  TP_GlobalIgnoreClass(TSVGIconImage);
  TP_GlobalIgnoreClass(TJvMultiStringHolder);
  TP_GlobalIgnoreClass(TSynEdit);
  TP_GlobalIgnoreClass(TSynCompletionProposal);
  TP_GlobalIgnoreClass(TSynAutoComplete);
  TP_GlobalIgnoreClass(TSpTBXMRUListItem);
  TP_GlobalIgnoreClass(TSynCustomHighLighter);
  TP_GlobalIgnoreClass(TCommonDialog);
  TP_GlobalIgnoreClass(TJvProgramVersionCheck);
  TP_GlobalIgnoreClass(TJvProgramVersionHTTPLocation);
  TP_GlobalIgnoreClass(TJvCustomAppStorage);
  TP_GlobalIgnoreClass(TPythonModule);
  // VCL stuff
  TP_GlobalIgnoreClass(TFont);
  TP_GlobalIgnoreClassProperty(TCustomAction,'Category');
  TP_GlobalIgnoreClassProperty(TCustomAction,'HelpKeyword');
  TP_GlobalIgnoreClassProperty(TObject,'ImageName');
  TP_GlobalIgnoreClassProperty(TControl,'HelpKeyword');
  TP_GlobalIgnoreClassProperty(TControl,'StyleName');

  //JCL Debug
  AddIgnoredException(EClipboardException);
finalization
  EditorSearchOptions.Free;
end.





