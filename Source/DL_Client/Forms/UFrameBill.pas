{*******************************************************************************
  ����: dmzn@163.com 2017-09-22
  ����: �������
*******************************************************************************}
unit UFrameBill;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxCheckBox, cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameBill = class(TfFrameNormal)
    EditCus: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditCard: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    EditLID: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    Edit1: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    N5: TMenuItem;
    dxLayout1Item10: TdxLayoutItem;
    CheckDelete: TcxCheckBox;
    N6: TMenuItem;
    N7: TMenuItem;
    N2: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N15: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N14: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N1Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure CheckDeleteClick(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure N16Click(Sender: TObject);
    procedure N17Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N18Click(Sender: TObject);
    procedure N19Click(Sender: TObject);
    procedure N20Click(Sender: TObject);
  protected
    FStart,FEnd: TDate;
    //ʱ������
    FUseDate: Boolean;
    //ʹ������
    FPreFix: string;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure AfterInitFormData; override;
    {*��ѯSQL*}
    procedure SendMsgToWebMall(const nBillno:string);
    function ModifyWebOrderStatus(const nLId:string) : Boolean;
    function GetVal(const nRow: Integer; const nField: string): string;
    //��ȡָ���ֶ�
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysPopedom,
  USysConst, USysDB, USysBusiness, UFormDateFilter, UMgrRemotePrint, USysLoger,
  UBusinessPacker;

//------------------------------------------------------------------------------
class function TfFrameBill.FrameID: integer;
begin
  Result := cFI_FrameBill;
end;

procedure TfFrameBill.OnCreateFrame;
var nStr: string;
begin
  inherited;
  {$IFDEF SyncDataByDataBase}
  N10.Visible := True;
  N12.Visible := True;
  N13.Visible := True;
  N15.Visible := True;
  N16.Visible := False;
  N17.Visible := False;
  N14.Visible := True;
  {$ELSE}
  N10.Visible := False;
  N12.Visible := False;
  N13.Visible := False;
  N15.Visible := False;
  N16.Visible := True;
  N14.Visible := False;
  {$ENDIF}

  {$IFDEF UseWXERP}
  N10.Visible := False;
  N12.Visible := False;
  N13.Visible := False;
  N15.Visible := False;
  N16.Visible := False;
  N17.Visible := False;
  {$ENDIF}
  
  FPreFix := 'WY';
  nStr := 'Select B_Prefix From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    FPreFix := Fields[0].AsString;
  end;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameBill.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: ���ݲ�ѯSQL
function TfFrameBill.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  {$IFDEF SyncDataByWSDL}
  if gPopedomManager.HasPopedom(PopedomItem, sPopedom_Edit) then
  begin
    N17.Visible := True;
  end
  else
  begin
    N17.Visible := False;
  end;
  {$ENDIF}

  FEnableBackDB := True;

  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select * From $Bill ' +
            ' Left Join $ZK on O_Order=L_ZhiKa ' +
            ' Left Join $C on C_ID=L_CusID ' +
            ' Left Join $Truck on T_Truck=L_Truck ';
  //�����
  if (nWhere = '') or FUseDate then
  begin
    Result := Result + 'Where (L_Date>=''$ST'' and L_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  Result := MacroValue(Result, [MI('$ZK', sTable_SalesOrder),
            MI('$Truck', sTable_Truck),
            MI('$C', sTable_Customer),
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx

  if CheckDelete.Checked then
       Result := MacroValue(Result, [MI('$Bill', sTable_BillBak)])
  else Result := MacroValue(Result, [MI('$Bill', sTable_Bill)]);
end;

procedure TfFrameBill.AfterInitFormData;
begin
  FUseDate := True;
end;

function TfFrameBill.FilterColumnField: string;
begin
  if gPopedomManager.HasPopedom(PopedomItem, sPopedom_ViewPrice) then
       Result := ''
  else Result := 'L_Price';
end;

//Desc: ִ�в�ѯ
procedure TfFrameBill.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditLID then
  begin
    EditLID.Text := Trim(EditLID.Text);
    if EditLID.Text = '' then Exit;

    FUseDate := Length(EditLID.Text) <= 3;
    FWhere := 'L_ID like ''%' + EditLID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;
    {$IFDEF AHZC}
    FUseDate := True;
    {$ENDIF}
    FWhere := 'L_CusPY like ''%%%s%%'' Or L_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditCard then
  begin
    EditCard.Text := Trim(EditCard.Text);
    if EditCard.Text = '' then Exit;

    FUseDate := Length(EditCard.Text) <= 3;
    {$IFDEF AHZC}
    FUseDate := True;
    {$ENDIF}
    FWhere := Format('L_Truck like ''%%%s%%''', [EditCard.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: δ��ʼ����������
procedure TfFrameBill.N4Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
   10: FWhere := Format('(L_Status=''%s'')', [sFlag_BillNew]);
   20: FWhere := 'L_OutFact Is Null'
   else Exit;
  end;

  FUseDate := False;
  InitFormData(FWhere);
end;

//Desc: ����ɸѡ
procedure TfFrameBill.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

//Desc: ��ѯɾ��
procedure TfFrameBill.CheckDeleteClick(Sender: TObject);
begin
  InitFormData('');
end;

//------------------------------------------------------------------------------
//Desc: �������
procedure TfFrameBill.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  CreateBaseFormItem(cFI_FormBill, PopedomItem, @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: ɾ��
procedure TfFrameBill.BtnDelClick(Sender: TObject);
var nStr, nLID: string;
    nList: TStrings;
    nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  if Trim(SQLQuery.FieldByName('L_OutFact').AsString) <> '' then
  begin
    ShowMsg('������Ѿ�������������ɾ��',sHint);
    Exit;
  end;

  if Trim(SQLQuery.FieldByName('L_BDAX').AsString) = '1' then
  begin
    ShowMsg('��������ϴ�ERP��������ɾ��',sHint);
    Exit;
  end;

  nLID := SQLQuery.FieldByName('L_ID').AsString;

  nStr := 'ȷ��Ҫɾ�����Ϊ[ %s ]�ĵ�����?';
  nStr := Format(nStr, [SQLQuery.FieldByName('L_ID').AsString]);
  if not QueryDlg(nStr, sAsk) then Exit;

  with nP do
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    nStr := Format('����дɾ��[ %s ]���ݵ�ԭ��', [nStr]);

    FCommand := cCmd_EditData;
    FParamA := nStr;
    FParamB := 320;
    FParamD := 2;

    nStr := SQLQuery.FieldByName('R_ID').AsString;
    FParamC := 'Update %s Set L_Memo=''$Memo'' Where R_ID=%s';
    FParamC := Format(FParamC, [sTable_Bill, nStr]);

    CreateBaseFormItem(cFI_FormMemo, '', @nP);
    if (FCommand <> cCmd_ModalResult) or (FParamA <> mrOK) then Exit;
  end;

  {$IFNDEF UseWXERP}
    {$IFDEF SyncDataByWSDL}
    nList := TStringList.Create;
    nList.Values['ID'] := SQLQuery.FieldByName('L_ID').AsString;
    nList.Values['Delete'] := sFlag_Yes;

    nStr := PackerEncodeStr(nList.Text);
    try
      if not SyncHhSaleDetailWSDL(nStr) then
      begin
        ShowMsg('���������ʧ��',sHint);
        Exit;
      end;
    finally
      nList.Free;
    end;
    {$ENDIF}
  {$ELSE}
    //
  {$ENDIF}

  if DeleteBill(SQLQuery.FieldByName('L_ID').AsString) then
  begin
    InitFormData(FWhere);
    ShowMsg('�������ɾ��', sHint);
    try
      SaveWebOrderDelMsg(nLID,sFlag_Sale);
    except
    end;
    //����ɾ������
  end;
end;

//Desc: ��ӡ�����
procedure TfFrameBill.N1Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintBillReport(nStr, False);
  end;
end;

procedure TfFrameBill.PMenu1Popup(Sender: TObject);
begin
  //N2.Enabled := BtnEdit.Enabled;
  //�޸ĳ���
  N6.Enabled := BtnEdit.Enabled;
  //�޸�ж����
end;

//Desc: �޸�δ�������ƺ�
procedure TfFrameBill.N2Click(Sender: TObject);
var nStr,nTruck: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_Truck').AsString;
    nTruck := nStr;
    if not ShowInputBox('�������µĳ��ƺ���:', '�޸�', nTruck, 15) then Exit;

    if (nTruck = '') or (nStr = nTruck) then Exit;
    //��Ч��һ��

    nStr := SQLQuery.FieldByName('L_ID').AsString;
    if ChangeLadingTruckNo(nStr, nTruck) then
    begin
      nStr := '�޸ĳ��ƺ�[ %s -> %s ].';
      nStr := Format(nStr, [SQLQuery.FieldByName('L_Truck').AsString, nTruck]);
      FDM.WriteSysLog(sFlag_BillItem, SQLQuery.FieldByName('L_ID').AsString, nStr, False);

      InitFormData(FWhere);
      ShowMsg('���ƺ��޸ĳɹ�', sHint);
    end;
  end;
end;

//Desc: �޸�ж����
procedure TfFrameBill.N6Click(Sender: TObject);
var nStr: string;
    nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FParamA := SQLQuery.FieldByName('L_Unloading').AsString;
    CreateBaseFormItem(cFI_FormGetUnloading, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOk) then Exit;

    nStr := 'Update %s Set L_Unloading=''%s'' Where R_ID=%s';
    nStr := Format(nStr, [sTable_Bill, nP.FParamB,
            SQLQuery.FieldByName('R_ID').AsString]);
    //xxxxx

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('ж�����޸ĳɹ�', sHint);
  end;
end;

procedure TfFrameBill.N15Click(Sender: TObject);
var nStr,nID: string;
    nList: TStrings;
    nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ����ļ�¼', sHint);
    Exit;
  end;

  if Pos(FPreFix,SQLQuery.FieldByName('L_ZhiKa').AsString) > 0 then
  begin
    ShowMsg('��ɽ����ҵ������(�����ѯ--��ɽ���˷�����ϸ)���п���', sHint);
    Exit;
  end;

  nID := SQLQuery.FieldByName('L_ID').AsString;

  nList := TStringList.Create;
  try
    nList.Add(nID);

    nP.FCommand := cCmd_EditData;
    nP.FParamA := nList.Text;
    CreateBaseFormItem(cFI_FormSaleKw, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;

  finally
    nList.Free;
  end;

end;

procedure TfFrameBill.N7Click(Sender: TObject);
var nStr,nP: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ��ӡ�ļ�¼', sHint);
    Exit;
  end;

  nStr := '�Ƿ���Զ�̴�ӡ[ %s.%s ]����?';
  nStr := Format(nStr, [SQLQuery.FieldByName('L_ID').AsString,
                        SQLQuery.FieldByName('L_Truck').AsString]);
  if not QueryDlg(nStr, sAsk) then Exit;

  if gRemotePrinter.RemoteHost.FPrinter = '' then
       nP := ''
  else nP := #9 + gRemotePrinter.RemoteHost.FPrinter;

  nStr := SQLQuery.FieldByName('L_ID').AsString + nP + #7 + sFlag_Sale;
  gRemotePrinter.PrintBill(nStr);
end;

procedure TfFrameBill.SendMsgToWebMall(const nBillno: string);
var
  nStr:string;
  nList: TStrings;
begin
  nList := TStringList.Create;
  try
    //�����������Ϣ
    nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
            'L_StockName,L_Truck,L_Value,L_Card,L_Price ' +
            'From $Bill b ';
    //xxxxx

    nStr := nStr + 'Where L_ID=''$CD''';

    nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', nBillno)]);
    //xxxxx

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '������[ %s ]����Ч.';

        nStr := Format(nStr, [nBillno]);
        gSysLoger.AddLog(TfFrameBill,'SendMsgToWebMall',nStr);
        Exit;
      end;

      First;

      while not Eof do
      begin
        nList.Clear;

        nList.Values['CusID']      := FieldByName('L_CusID').AsString;
        nList.Values['MsgType']    := IntToStr(cSendWeChatMsgType_DelBill);
        nList.Values['BillID']     := FieldByName('L_ID').AsString;
        nList.Values['Card']       := FieldByName('L_Card').AsString;
        nList.Values['Truck']      := FieldByName('L_Truck').AsString;
        nList.Values['StockNo']    := FieldByName('L_StockNo').AsString;
        nList.Values['StockName']  := FieldByName('L_StockName').AsString;
        nList.Values['CusName']    := FieldByName('L_CusName').AsString;
        nList.Values['Value']      := FieldByName('L_Value').AsString;

        nStr := PackerEncodeStr(nList.Text);

        nStr := send_event_msg(nStr);
        gSysLoger.AddLog(TfFrameBill,'SendMsgToWebMall',nStr);

        Next;
      end;
    end;
  finally
    nList.Free;
  end;
end;

function TfFrameBill.ModifyWebOrderStatus(const nLId: string):Boolean;
var
  nWebOrderId:string;
  nXmlStr,nData,nSql:string;
  nList: TStrings;
begin
  Result := False;
  nList := TStringList.Create;

  try
    nWebOrderId := '';
    //��ѯ�����̳Ƕ���
//    nSql := 'select WOM_WebOrderID from %s where WOM_LID=''%s''';
//    nSql := Format(nSql,[sTable_WebOrderMatch,nLId]);
    with FDM.QueryTemp(nSql) do
    begin
      if recordcount>0 then
      begin
        nWebOrderId := FieldByName('WOM_WebOrderID').asstring;
      end;
    end;
    if nWebOrderId='' then Exit;

    nList.Clear;
    nList.Values['WOM_WebOrderID'] := nWebOrderId;
    nList.Values['WOM_LID']:= nLId;
    nList.Values['WOM_StatusType']:= IntToStr(c_WeChatStatusDeleted);

    nXmlStr := PackerEncodeStr(nList.Text);

    nData := complete_shoporders(nXmlStr);
    gSysLoger.AddLog(TfFrameBill,'ModifyWebOrderStatus',nData);

    if nData <> sFlag_Yes then
    begin
      Exit;
    end;
    Result:= True;
  finally
    nList.Free;
  end;
end;

procedure TfFrameBill.N8Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintCNSReport(nStr, False);
  end;
end;

procedure TfFrameBill.N10Click(Sender: TObject);
var nStr,nID: string;
    nList: TStrings;
    nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�޸ĵļ�¼', sHint);
    Exit;
  end;

  if Pos(FPreFix,SQLQuery.FieldByName('L_ZhiKa').AsString) <= 0 then
  if Length(SQLQuery.FieldByName('L_MValue').AsString) > 0 then
  begin
    ShowMsg('�����ѹ�ë��,������������', sHint);
    Exit;
  end;

  nID := SQLQuery.FieldByName('L_ID').AsString;

  nList := TStringList.Create;
  try
    nList.Add(nID);

    nP.FCommand := cCmd_EditData;
    nP.FParamA := nList.Text;
    CreateBaseFormItem(cFI_FormSaleModifyStock, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;

  finally
    nList.Free;
  end;
end;

procedure TfFrameBill.N12Click(Sender: TObject);
var nStr,nID: string;
    nList: TStrings;
    nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�����ļ�¼', sHint);
    Exit;
  end;

  if Pos(FPreFix,SQLQuery.FieldByName('L_ZhiKa').AsString) <= 0 then
  begin
    ShowMsg('�ǿ�ɽ���������,���ܽ��в���', sHint);
    Exit;
  end;

  nID := SQLQuery.FieldByName('L_ID').AsString;

  nList := TStringList.Create;
  try
    nList.Add(nID);

    nP.FCommand := cCmd_EditData;
    nP.FParamA := nList.Text;
    CreateBaseFormItem(cFI_FormSaleBuDanOther, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;

  finally
    nList.Free;
  end;
end;

procedure TfFrameBill.N13Click(Sender: TObject);
var nStr,nStatus: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�޸ĵļ�¼', sHint);
    Exit;
  end;

  if Pos(FPreFix,SQLQuery.FieldByName('L_ZhiKa').AsString) <= 0 then
  begin
    ShowMsg('�ǿ�ɽ���������,���ܽ����޸�', sHint);
    Exit;
  end;

  nStr := '�޸��������ǰ״̬[ %s -> %s ].ȷ��Ҫ�޸���?';
  nStr := Format(nStr, [SQLQuery.FieldByName('L_Status').AsString, sFlag_TruckOut]);
  if not QueryDlg(nStr, sHint) then Exit;

  nStr := 'Update %s Set L_Status=''%s'',L_NextStatus='''' ' +
          'Where L_ID=''%s''';

  nStr := Format(nStr, [sTable_Bill, sFlag_TruckOut,
                        SQLQuery.FieldByName('L_ID').AsString]);
  FDM.ExecuteSQL(nStr);
  
  InitFormData(FWhere);
  ShowMsg('�����״̬�޸ĳɹ�', sHint);
end;

procedure TfFrameBill.N16Click(Sender: TObject);
var nPID, nStr,nPreFix: string;
    nList: TStrings;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nPID := SQLQuery.FieldByName('L_ID').AsString;

    nPreFix := 'WY';
    nStr := 'Select B_Prefix From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      nPreFix := Fields[0].AsString;
    end;

    if Pos(nPreFix,SQLQuery.FieldByName('L_ZhiKa').AsString) > 0 then
    begin
      nStr := Format('�����[ %s ]��ERP����,�޷��ϴ�', [nPID]);
      ShowMsg(nStr, sHint);
      Exit;
    end;

    nStr := Format('ȷ���ϴ������[ %s ]��?', [nPID]);
    if not QueryDlg(nStr, sHint) then Exit;

    nList := TStringList.Create;
    nList.Values['ID'] := SQLQuery.FieldByName('L_ID').AsString;

    if SQLQuery.FieldByName('L_OutFact').AsString <> '' then
      nList.Values['Status'] := '1';

    nStr := PackerEncodeStr(nList.Text);
    try
      if not SyncHhSaleDetailWSDL(nStr) then
      begin
        ShowMsg('������ϴ�ʧ��',sHint);
        Exit;
      end;
    finally
      nList.Free;
    end;

    ShowMsg('�ϴ��ɹ�',sHint);
    InitFormData('');
  end;
end;

procedure TfFrameBill.N17Click(Sender: TObject);
var nStr,nID: string;
    nList: TStrings;
    nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�޸ĵļ�¼', sHint);
    Exit;
  end;

  nID := SQLQuery.FieldByName('L_ID').AsString;

  nList := TStringList.Create;
  try
    nList.Add(nID);

    nP.FCommand := cCmd_EditData;
    nP.FParamA := nList.Text;
    CreateBaseFormItem(cFI_FormSaleModifyStock, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;

  finally
    nList.Free;
  end;
end;

procedure TfFrameBill.N14Click(Sender: TObject);
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;

  nList := TStringList.Create;
  try
    for nIdx := 0 to cxView1.DataController.RowCount - 1  do
    begin
      if Pos(FPreFix,SQLQuery.FieldByName('L_ZhiKa').AsString) <= 0 then
      begin
        ShowMsg('ѡ��ļ�¼�д��ڷǿ�ɽ���������,���ܽ����޸�', sHint);
        Exit;
      end;

      nStr := GetVal(nIdx,'L_ID');
      if nStr = '' then
        Continue;

      nList.Add(nStr);
    end;

    nP.FCommand := cCmd_EditData;
    nP.FParamA := nList.Text;
    CreateBaseFormItem(cFI_FormSaleModifyStockMul, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;

  finally
    nList.Free;
  end;
end;

//Desc: ��ȡnRow��nField�ֶε�����
function TfFrameBill.GetVal(const nRow: Integer;
 const nField: string): string;
var nVal: Variant;
begin
  nVal := cxView1.ViewData.Rows[nRow].Values[
            cxView1.GetColumnByFieldName(nField).Index];
  //xxxxx

  if VarIsNull(nVal) then
       Result := ''
  else Result := nVal;
end;

procedure TfFrameBill.N18Click(Sender: TObject);
var nID,nMsg: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ��ӡ�ļ�¼', sHint);
    Exit;
  end;

  nID := SQLQuery.FieldByName('L_ID').AsString;
  PrintHuaYanReportEx(nID, nMsg);
  if nMsg <> '' then
  begin
    ShowMsg(nMsg, sHint);
    Exit;
  end;
end;

procedure TfFrameBill.N19Click(Sender: TObject);
var nStr,nBill: string;
begin
    if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ��ӡ�ļ�¼', sHint);
    Exit;
  end;

  nBill := SQLQuery.FieldByName('L_ID').AsString;

  nStr := 'Update %s Set L_HyPrintCount=0' +
          'Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);
  FDM.ExecuteSQL(nStr);
  ShowMsg('�������', sHint);
end;

procedure TfFrameBill.N20Click(Sender: TObject);
var nStr: string;
begin
  inherited;

  nStr := 'ȷ��ERP�ϴ�ʧ�ܼ�¼�����ϴ���?';
  if not QueryDlg(nStr, sHint) then Exit;

  nStr := ' Update %s Set H_SyncNum = 0 ' +
          ' Where H_Deleted = ''%s'' ';
  nStr := Format(nStr, [sTable_HHJYSync, sFlag_No]);
  FDM.ExecuteSQL(nStr);
  ShowMsg('ERP�ϴ�ʧ�ܼ�¼�����ϴ����', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFrameBill, TfFrameBill.FrameID);
end.
