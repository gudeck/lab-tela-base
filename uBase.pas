unit uBase;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, DB, ComCtrls, DBCtrls, ToolWin, StdCtrls, ExtCtrls, Grids, DBGrids, DBClient,
  Menus, Provider, ImageList, ImgList, Data.Win.ADODB;

type
  TfBase = class(TForm)
    Panel1: TPanel;
    Botoes: TToolBar;
    Imagens: TImageList;
    btNovo: TToolButton;
    btEditar: TToolButton;
    btSalvar: TToolButton;
    btCancelar: TToolButton;
    btExcluir: TToolButton;
    btImprimir: TToolButton;
    btAtualizar: TToolButton;
    btSair: TToolButton;
    DataSource: TDataSource;
    gbCabecalho: TGroupBox;
    PageControl: TPageControl;
    tabInformacoes: TTabSheet;
    tabFiltros: TTabSheet;
    gbInformacoes: TGroupBox;
    gbFiltros: TGroupBox;
    DBGrid: TDBGrid;
    StatusBar: TStatusBar;
    procedure DataSourceStateChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btNovoClick(Sender: TObject);
    procedure btEditarClick(Sender: TObject);
    procedure btSalvarClick(Sender: TObject);
    procedure btCancelarClick(Sender: TObject);
    procedure btExcluirClick(Sender: TObject);
    procedure btImprimirClick(Sender: TObject);
    procedure btAtualizarClick(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure DBGridDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fBase: TfBase;

implementation

{$R *.dfm}

procedure TfBase.btAtualizarClick(Sender: TObject);
begin
  ActiveControl := nil;

  PageControl.SetFocus;

  DataSource.DataSet.Close;
  DataSource.DataSet.Open;

  StatusBar.Panels[1].Text := IntToStr(DataSource.DataSet.RecordCount);

end;

procedure TfBase.btCancelarClick(Sender: TObject);
begin
  ActiveControl := nil;
  if not(Sender is TForm) then
    if Application.MessageBox('Deseja realmente cancelar o registro atual?',
      'Cancelar', MB_YESNO + MB_ICONQUESTION) = ID_YES then
      DataSource.DataSet.Cancel;

end;

procedure TfBase.btEditarClick(Sender: TObject);
begin
  if not DataSource.DataSet.IsEmpty then
  begin
    DataSource.DataSet.Edit;
    PageControl.ActivePage := tabInformacoes;
  end
  else
    ShowMessage('Não há registros a alterar!');
end;

procedure TfBase.btExcluirClick(Sender: TObject);
begin
  if DataSource.DataSet.Active then
    if not DataSource.DataSet.IsEmpty then
      if Application.MessageBox('Deseja realmente excluir o registro atual?',
        'Excluir', MB_YESNO + MB_ICONQUESTION) = ID_YES then
        DataSource.DataSet.Delete
      else
        ShowMessage('Não há registros a excluir!');
end;

procedure TfBase.btImprimirClick(Sender: TObject);
begin
  if (DataSource.DataSet.IsEmpty) or (not DataSource.DataSet.Active) then
  begin
    ShowMessage('Não há registros a imprimir!');
    Abort;
  end;

end;

procedure TfBase.btNovoClick(Sender: TObject);
begin
  if ActiveControl = DBGrid then
    ActiveControl := nil;
  if not DataSource.DataSet.Active then
    DataSource.DataSet.Open;

  DataSource.DataSet.Append;
  PageControl.ActivePage := tabInformacoes;
end;

procedure TfBase.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfBase.btSalvarClick(Sender: TObject);
begin
  ActiveControl := nil;
  DataSource.DataSet.Post;

  btAtualizarClick(btAtualizar);
end;

procedure TfBase.DataSourceStateChange(Sender: TObject);
begin
  tabFiltros.TabVisible := DataSource.DataSet.State in [dsBrowse, dsInactive];
  gbInformacoes.Enabled := DataSource.DataSet.State in dsEditModes;
  gbCabecalho.Enabled := DataSource.DataSet.State in dsEditModes;

  btNovo.Enabled := not(DataSource.DataSet.State in dsEditModes);
  btEditar.Enabled := not(DataSource.DataSet.State in dsEditModes) and
    not DataSource.DataSet.IsEmpty;
  btSalvar.Enabled := (DataSource.DataSet.State in dsEditModes);
  btCancelar.Enabled := (DataSource.DataSet.State in dsEditModes);
  btAtualizar.Enabled := not(DataSource.DataSet.State in dsEditModes);
  btExcluir.Enabled := not(DataSource.DataSet.State in dsEditModes) and
    not DataSource.DataSet.IsEmpty;
  btImprimir.Enabled := not(DataSource.DataSet.State in dsEditModes);
  btSair.Enabled := not(DataSource.DataSet.State in dsEditModes);
end;

procedure TfBase.DBGridDblClick(Sender: TObject);
begin
  PageControl.ActivePage := tabInformacoes;
end;

procedure TfBase.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DataSource.DataSet.Close;
  Action := caFree;
  TForm(Sender) := nil;
end;

procedure TfBase.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if DataSource.State in dsEditModes then
    if Application.MessageBox('Deseja gravar as alterações?',
      pchar(Application.Title), MB_YESNO + MB_ICONQUESTION) = ID_YES then
      btSalvarClick(btSalvar)
    else
      btCancelarClick(btCancelar);

end;

procedure TfBase.FormCreate(Sender: TObject);
begin
  TForm(Sender) := Self;
end;

procedure TfBase.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and not(ActiveControl is TDBGrid) and
    not(ActiveControl is TMemo)
   and not (ActiveControl is TDBMemo) and not (ActiveControl is TDBRichEdit)
  then
    Perform(WM_NEXTDLGCTL, 0, 0);
end;

procedure TfBase.FormShow(Sender: TObject);
begin
  DataSourceStateChange(DataSource);
  PageControl.ActivePage := tabFiltros;
end;

end.
