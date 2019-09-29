{*******************************************************************************
  ����: juner11212436@163.com 2017-12-28
  ����: �����쿨����--������
*******************************************************************************}
unit uZXNewCard;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, Menus, StdCtrls, cxButtons, cxGroupBox,
  cxRadioGroup, cxTextEdit, cxCheckBox, ExtCtrls, dxLayoutcxEditAdapters,
  dxLayoutControl, cxDropDownEdit, cxMaskEdit, cxButtonEdit,
  USysConst, cxListBox, ComCtrls,Contnrs,UFormCtrl, UMgrSDTReader;

type

  TfFormNewCard = class(TForm)
    editWebOrderNo: TcxTextEdit;
    labelIdCard: TcxLabel;
    btnQuery: TcxButton;
    PanelTop: TPanel;
    PanelBody: TPanel;
    dxLayout1: TdxLayoutControl;
    BtnOK: TButton;
    BtnExit: TButton;
    EditValue: TcxTextEdit;
    EditCus: TcxTextEdit;
    EditCName: TcxTextEdit;
    EditStock: TcxTextEdit;
    EditSName: TcxTextEdit;
    EditType: TcxComboBox;
    EditPrice: TcxButtonEdit;
    dxLayoutGroup1: TdxLayoutGroup;
    dxGroup1: TdxLayoutGroup;
    dxlytmLayout1Item3: TdxLayoutItem;
    dxlytmLayout1Item4: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    dxlytmLayout1Item9: TdxLayoutItem;
    dxlytmLayout1Item10: TdxLayoutItem;
    dxGroupLayout1Group5: TdxLayoutGroup;
    dxlytmLayout1Item13: TdxLayoutItem;
    dxLayout1Item11: TdxLayoutItem;
    dxGroupLayout1Group6: TdxLayoutGroup;
    dxLayout1Item8: TdxLayoutItem;
    dxLayoutGroup3: TdxLayoutGroup;
    dxLayoutItem1: TdxLayoutItem;
    dxLayout1Item2: TdxLayoutItem;
    dxLayout1Group1: TdxLayoutGroup;
    pnlMiddle: TPanel;
    cxLabel1: TcxLabel;
    lvOrders: TListView;
    Label1: TLabel;
    btnClear: TcxButton;
    TimerAutoClose: TTimer;
    dxLayout1Group2: TdxLayoutGroup;
    PrintHY: TcxCheckBox;
    EditMemo: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditTruck: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Item4: TdxLayoutItem;
    EditMaxNum: TcxTextEdit;
    procedure BtnExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure TimerAutoCloseTimer(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure lvOrdersClick(Sender: TObject);
    procedure editWebOrderNoKeyPress(Sender: TObject; var Key: Char);
    procedure btnClearClick(Sender: TObject);
  private
    { Private declarations }
    FSellMan: string;
    FAutoClose:Integer; //�����Զ��رյ���ʱ�����ӣ�
    FWebOrderIndex:Integer; //�̳Ƕ�������
    FWebOrderItems:array of stMallOrderItem; //�̳Ƕ�������
    FCardData:TStrings; //����ϵͳ���صĴ�Ʊ����Ϣ
    Fbegin:TDateTime;
    FListA : TStrings;
    procedure InitListView;
    procedure SetControlsReadOnly;
    function DownloadOrder(const nCard:string):Boolean;
    procedure Writelog(nMsg:string);
    procedure AddListViewItem(var nWebOrderItem:stMallOrderItem);
    procedure LoadSingleOrder;
    function IsRepeatCard(const nWebOrderItem:string):Boolean;
    //��ȡ���ʣ����
    function GetMaxENum(const ncontractno:string): Double;
    //��ȡ��������
    function GetMaxTHNum: Double;
    function IsLastTime(const nTruck:string; var nTime:Integer):Boolean;
    function VerifyCtrl(Sender: TObject; var nHint: string): Boolean;
    function SaveBillProxy:Boolean;
    function SaveWebOrderMatch(const nBillID,nWebOrderID,nBillType:string):Boolean;
  public
    { Public declarations }
    procedure SetControlsClear;
  end;

var
  fFormNewCard: TfFormNewCard;

implementation
uses
  ULibFun,UBusinessPacker,USysLoger,UBusinessConst,UFormMain,USysBusiness,USysDB,
  UAdjustForm,UFormBase,UDataReport,UDataModule,NativeXml,UMgrTTCEDispenser,UFormWait,
  DateUtils;
{$R *.dfm}

{ TfFormNewCard }

procedure TfFormNewCard.SetControlsClear;
var
  i:Integer;
  nComp:TComponent;
begin
  editWebOrderNo.Clear;
  for i := 0 to dxLayout1.ComponentCount-1 do
  begin
    nComp := dxLayout1.Components[i];
    if nComp is TcxTextEdit then
    begin
      TcxTextEdit(nComp).Clear;
    end;
  end;
end;
procedure TfFormNewCard.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormNewCard.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FListA.Free;
  FCardData.Free;
  Action:=  caFree;
  fFormNewCard := nil;
  gSDTReaderManager.OnSDTEvent := nil;  
end;

procedure TfFormNewCard.FormShow(Sender: TObject);
begin
  SetControlsReadOnly;
  dxlytmLayout1Item13.Visible := False;
  ActiveControl := editWebOrderNo;
  btnOK.Enabled := False;
  FAutoClose := gSysParam.FAutoClose_Mintue;
  TimerAutoClose.Interval := 60*1000;
  TimerAutoClose.Enabled := True;
  EditPrice.Properties.Buttons[0].Visible := False;
  dxLayout1Item11.Visible := False;
  {$IFDEF PrintHYEach}
  PrintHY.Checked := True;
  PrintHY.Enabled := False;
  {$ELSE}
  PrintHY.Checked := False;
  PrintHY.Enabled := True;
  {$ENDIF}
end;

procedure TfFormNewCard.SetControlsReadOnly;
var
  i:Integer;
  nComp:TComponent;
begin
  for i := 0 to dxLayout1.ComponentCount-1 do
  begin
    nComp := dxLayout1.Components[i];
    if nComp is TcxTextEdit then
    begin
      TcxTextEdit(nComp).Properties.ReadOnly := True;
    end;
  end;
  EditPrice.Properties.ReadOnly := True;
end;

procedure TfFormNewCard.TimerAutoCloseTimer(Sender: TObject);
begin
  if FAutoClose=0 then
  begin
    TimerAutoClose.Enabled := False;
    Close;
  end;
  Dec(FAutoClose);
end;

procedure TfFormNewCard.btnQueryClick(Sender: TObject);
var
  nCardNo,nStr:string;
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  btnQuery.Enabled := False;
  editWebOrderNo.SelectAll;
  try
    nCardNo := Trim(editWebOrderNo.Text);
    if nCardNo='' then
    begin
      nStr := '���������ɨ�趩����';
      ShowMsg(nStr,sHint);
      Writelog(nStr);
      Exit;
    end;
    lvOrders.Items.Clear;

//    if IsRepeatCard(editWebOrderNo.Text) then
//    begin
//      nStr := '����'+editWebOrderNo.Text+'�ѳɹ��Ƶ��������ظ�����';
//      ShowMsg(nStr,sHint);
//      Writelog(nStr);
//      Exit;
//    end;

    if not DownloadOrder(nCardNo) then Exit;
    btnOK.Enabled := True;
  finally
    btnQuery.Enabled := True;
  end;
end;

function TfFormNewCard.DownloadOrder(const nCard: string): Boolean;
var
  nXmlStr,nData:string;
  nListA,nListB,nListC:TStringList;
  i:Integer;
  nWebOrderCount:Integer;
begin
  Result := False;
  FWebOrderIndex := 0;

  nXmlStr := PackerEncodeStr(nCard);

  FBegin := Now;
  nData := get_shoporderbyno(nXmlStr);
  if nData='' then
  begin
    ShowMsg('δ��ѯ�������̳Ƕ�����ϸ��Ϣ�����鶩�����Ƿ���ȷ',sHint);
    Writelog('δ��ѯ�������̳Ƕ�����ϸ��Ϣ�����鶩�����Ƿ���ȷ');
    Exit;
  end;
  Writelog('TfFormNewCard.DownloadOrder(nCard='''+nCard+''') ��ѯ�̳Ƕ���-��ʱ��'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
  //�������Ƕ�����Ϣ
  Writelog('get_shoporderbyno res:'+nData);

  {$IFDEF UseWXServiceEx}
    nListA := TStringList.Create;
    nListB := TStringList.Create;
    nListC := TStringList.Create;
    EditTruck.Clear;
    try
      nListA.Text := PackerDecodeStr(nData);

      nListB.Text := PackerDecodeStr(nListA.Values['details']);
      nWebOrderCount := nListB.Count;
      SetLength(FWebOrderItems,1);
      for i := 0 to nWebOrderCount-1 do
      begin
        nListC.Text := PackerDecodeStr(nListB[i]);
        with nListC do
        begin
          EditTruck.Properties.Items.Add(Values['truckLicense']);
        end;
      end;

      FWebOrderItems[0].FOrder_id       := nListA.Values['orderId'];
      FWebOrderItems[0].FOrdernumber    := nListA.Values['orderNo'];
      FWebOrderItems[0].FfactoryName    := nListA.Values['factoryName'];
      FWebOrderItems[0].FdriverId       := '';
      FWebOrderItems[0].FdrvName        := '';
      FWebOrderItems[0].FdrvPhone       := '';
      FWebOrderItems[0].FType           := nListA.Values['type'];
      FWebOrderItems[0].FXHSpot         := nListA.Values['orderRemark'];
      FWebOrderItems[0].FPrice          := '';
      FWebOrderItems[0].FCusID          := nListA.Values['clientNo'];
      FWebOrderItems[0].FCusName        := nListA.Values['clientName'];
      FWebOrderItems[0].FGoodsID        := nListA.Values['materielNo'];
      FWebOrderItems[0].FGoodstype      := '';
      FWebOrderItems[0].FGoodsname      := nListA.Values['materielName'];
      FWebOrderItems[0].FData           := '';
      FWebOrderItems[0].ForderDetailType:= '';
      FWebOrderItems[0].FYunTianOrderId := nListA.Values['contractNo'];
      FWebOrderItems[0].FMaxNum         := StrToFloatDef(nListA.Values['totalQuantity'],0);
      AddListViewItem(FWebOrderItems[0]);
    finally
      nListC.Free;
      nListB.Free;
      nListA.Free;
    end;
  {$ELSE}
    nListA := TStringList.Create;
    nListB := TStringList.Create;
    try
      nListA.Text := nData;

      nWebOrderCount := nListA.Count;
      SetLength(FWebOrderItems,nWebOrderCount);
      for i := 0 to nWebOrderCount-1 do
      begin
        nListB.Text := PackerDecodeStr(nListA.Strings[i]);
        FWebOrderItems[i].FOrder_id       := nListB.Values['order_id'];
        FWebOrderItems[i].FOrdernumber    := nListB.Values['ordernumber'];
        FWebOrderItems[i].FGoodsID        := nListB.Values['goodsID'];
        FWebOrderItems[i].FGoodstype      := nListB.Values['goodstype'];
        FWebOrderItems[i].FGoodsname      := nListB.Values['goodsname'];
        FWebOrderItems[i].FData           := nListB.Values['data'];
        FWebOrderItems[i].Ftracknumber    := nListB.Values['tracknumber'];
        FWebOrderItems[i].FYunTianOrderId := nListB.Values['fac_order_no'];
        AddListViewItem(FWebOrderItems[i]);
      end;
    finally
      nListB.Free;
      nListA.Free;
    end;
  {$ENDIF}
  LoadSingleOrder;
  Result := True;
end;

procedure TfFormNewCard.Writelog(nMsg: string);
var
  nStr:string;
begin
  nStr := 'weborder[%s]clientid[%s]clientname[%s]sotckno[%s]stockname[%s]';
  nStr := Format(nStr,[editWebOrderNo.Text,EditCus.Text,EditCName.Text,EditStock.Text,EditSName.Text]);
  gSysLoger.AddLog(nStr+nMsg);
end;

procedure TfFormNewCard.AddListViewItem(
  var nWebOrderItem: stMallOrderItem);
var
  nListItem:TListItem;
begin
  nListItem := lvOrders.Items.Add;
  nlistitem.Caption := nWebOrderItem.FOrdernumber;

  nlistitem.SubItems.Add(nWebOrderItem.FGoodsID);
  nlistitem.SubItems.Add(nWebOrderItem.FGoodsname);
  nlistitem.SubItems.Add(nWebOrderItem.Ftracknumber);
  nlistitem.SubItems.Add(nWebOrderItem.FData);
  nlistitem.SubItems.Add(nWebOrderItem.FYunTianOrderId);
end;

procedure TfFormNewCard.InitListView;
var
  col:TListColumn;
begin
  lvOrders.ViewStyle := vsReport;
  col := lvOrders.Columns.Add;
  col.Caption := '���϶������';
  col.Width := 300;
  col := lvOrders.Columns.Add;
  col.Caption := 'ˮ���ͺ�';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := 'ˮ������';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := '�������';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := '�������';
  col.Width := 150;
  col := lvOrders.Columns.Add;
  col.Caption := '�������';
  col.Width := 250;
end;

procedure TfFormNewCard.FormCreate(Sender: TObject);
begin
  editWebOrderNo.Properties.MaxLength := gSysParam.FWebOrderLength;
  FCardData := TStringList.Create;
  if not Assigned(FDR) then
  begin
    FDR := TFDR.Create(Application);
  end;
  InitListView;
  gSysParam.FUserID := 'AICM';
  FListA := TStringList.Create;
end;

procedure TfFormNewCard.LoadSingleOrder;
var
  nOrderItem:stMallOrderItem;
  nRepeat, nIsSale : Boolean;
  nWebOrderID:string;
  nMsg,nStr:string;
  nNum1, nNum2: Double;
begin
  nOrderItem := FWebOrderItems[FWebOrderIndex];
  nWebOrderID := nOrderItem.FOrdernumber;

  FBegin := Now;
  nRepeat:= False;
//  nRepeat := IsRepeatCard(nWebOrderID);

//  if nRepeat then
//  begin
//    nMsg := '�˶����ѳɹ��쿨�������ظ�����';
//    ShowMsg(nMsg,sHint);
//    Writelog(nMsg);
//    Exit;
//  end;
  writelog('TfFormNewCard.LoadSingleOrder ����̳Ƕ����Ƿ��ظ�ʹ��-��ʱ��'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');

  {$IFDEF UseWXServiceEx}
    if nOrderItem.FType = '1' then
      nIsSale := True
    else
      nIsSale := False;

    if not nIsSale then
    begin
      nMsg := '�˶����������۶�����';
      ShowMsg(nMsg,sHint);
      Writelog(nMsg);
      Exit;
    end;

    //��������Ϣ
    //������Ϣ
    EditCus.Text    := '';
    EditCName.Text  := '';

    nStr := 'select O_Price,O_SaleMan from %s where O_Order=''%s''';

    nStr := Format(nStr,[sTable_SalesOrder,nOrderItem.FYunTianOrderId]);
    with fdm.QueryTemp(nStr) do
    begin
      if RecordCount <= 0 then
      begin
        ShowMsg('����' + nOrderItem.FYunTianOrderId + '�������۶���,�޷��쿨', sHint);
        Exit;
      end;
      if RecordCount = 1 then
      begin
        EditPrice.Text  := Fields[0].AsString;
        FSellMan        := Fields[1].AsString;
      end;
    end;

    //�ᵥ��Ϣ
    EditType.ItemIndex := 0;
    EditStock.Text  := nOrderItem.FGoodsID;
    EditSName.Text  := nOrderItem.FGoodsname;
    EditValue.Text  := nOrderItem.FData;
    EditTruck.Text  := nOrderItem.Ftracknumber;
    EditCus.Text    := nOrderItem.FCusID;
    EditCName.Text  := nOrderItem.FCusName;
    EditMemo.Text   := nOrderItem.FXHSpot;
    nNum1           := GetMaxENum(nOrderItem.FYunTianOrderId);
    nNum2           := nOrderItem.FMaxNum - GetUsedNum(nWebOrderID);
    if nNum1 <= nNum2 then
      EditMaxNum.Text := FloatToStr(nNum1)
    else if nNum1 > nNum2 then
      EditMaxNum.Text := FloatToStr(nNum2);
  {$ELSE}
    //��������Ϣ
    //������Ϣ
    EditCus.Text    := '';
    EditCName.Text  := '';

    nStr := 'Select C_Name From %s Where C_ID=''%s'' ';
    nStr := Format(nStr, [sTable_Customer, EditCus.Text]);
    with fdm.QueryTemp(nStr) do
    begin
      if RecordCount>0 then
      begin
        EditCName.Text  := Fields[0].AsString;
      end;
    end;

    //�ᵥ��Ϣ
    EditType.ItemIndex := 0;
    EditStock.Text  := nOrderItem.FGoodsID;
    EditSName.Text  := nOrderItem.FGoodsname;
    EditValue.Text := nOrderItem.FData;
    EditTruck.Text := nOrderItem.Ftracknumber;
  {$ENDIF}

  BtnOK.Enabled := not nRepeat;
end;

function TfFormNewCard.IsRepeatCard(const nWebOrderItem: string): Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := 'select * from %s where WOM_WebOrderID=''%s''';
  nStr := Format(nStr,[sTable_WebOrderMatch,nWebOrderItem]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      Result := True;
    end;
  end;
end;

function TfFormNewCard.VerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    if not Result then
    begin
      nHint := '���ƺų���Ӧ����2λ';
      Writelog(nHint);
      Exit;
    end;
  end;
  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    if not Result then
    begin
      nHint := '����д��Ч�İ�����';
      Writelog(nHint);
      Exit;
    end;
  end;
end;

procedure TfFormNewCard.BtnOKClick(Sender: TObject);
var nIdx : Integer;
begin
  BtnOK.Enabled := False;
  try
    if not SaveBillProxy then
    begin
      BtnOK.Enabled := True;
      Exit;
    end;
    
    Close;
  except
  end;
end;

function TfFormNewCard.SaveBillProxy: Boolean;
var
  nHint,nMsg:string;
  nList,nTmp,nStocks: TStrings;
  nPrint,nInFact:Boolean;
  nBillData:string;
  nBillID :string;
  nWebOrderID:string;
  nNewCardNo:string;
  nidx:Integer;
  i,nTimes:Integer;
  nRet: Boolean;
  nOrderItem:stMallOrderItem;
  nCard:string;
  nMaxNum, nTHNum,nNum1,nNum2 : Double;
  nStr : string;
begin
  Result      := False;
  nOrderItem  := FWebOrderItems[FWebOrderIndex];
  nWebOrderID := editWebOrderNo.Text;

  if (Trim(EditValue.Text) = '') or (StrToFloatDef(Trim(EditValue.Text),0) <= 0)  then
  begin
    ShowMsg('�����������Ϊ�ջ���С�ڵ����㣡',sHint);
    Writelog('��ȡ���ϼ۸��쳣������ϵ����Ա');
    Exit;
  end;

  nTHNum := GetMaxTHNum;
  if nTHNum > 0 then
  begin
    if StrToFloatDef(Trim(EditValue.Text),0) > nTHNum  then
    begin
      ShowMsg('����������ܴ�����������'+Floattostr(nTHNum)+'��',sHint);
      Exit;
    end;
  end;

  if not VerifyCtrl(EditTruck,nHint) then
  begin
    ShowMsg(nHint,sHint);
    Writelog(nHint);
    Exit;
  end;

  {$IFDEF UseTruckXTNum}
    if not IsEnoughNum(EditTruck.Text, StrToFloatDef(EditValue.Text,0)) then
    begin
      ShowMsg('�������������ᵥ�����������ϵ����Ա', sHint);
      Exit;
    end;
  {$ENDIF}

  if not IsLastTime(EditTruck.Text,nTimes) then
  begin
    nStr := '����[ %s ]����δ��'+inttostr(nTimes)+'����,��ֹ����.';
    nStr := Format(nStr, [EditTruck.Text]);
    ShowMsg(nStr, sHint);
    Exit;
  end;
  //�ж��ᵥ��
  nNum1           := GetMaxENum(nOrderItem.FYunTianOrderId);
  nNum2           := nOrderItem.FMaxNum - GetUsedNum(nWebOrderID);
  if nNum1 <= nNum2 then
    nMaxNum := nNum1
  else if nNum1 > nNum2 then
    nMaxNum := nNum2;
    
  if StrToFloatDef(EditValue.Text,0) > nMaxNum then
  begin
    ShowMsg('�����������ʣ����'+Floattostr(nMaxNum), sHint);
    Exit;
  end;

  if not VerifyCtrl(EditValue,nHint) then
  begin
    ShowMsg(nHint,sHint);
    Writelog(nHint);
    Exit;
  end;

  for nIdx:=0 to 3 do
  begin
    nCard := gDispenserManager.GetCardNo(gSysParam.FTTCEK720ID, nHint, False);
    if nCard <> '' then
      Break;
    Sleep(500);
  end;
  //�������ζ���,�ɹ����˳���
 // nCard := '5678';

  if nCard = '' then
  begin
    nMsg := '�����쳣,��鿴�Ƿ��п�.';
    ShowMsg(nMsg, sWarn);
    Exit;
  end;

  WriteLog('��ȡ����Ƭ: ' + nCard);
  //������Ƭ
  if not IsCardValid(nCard) then
  begin
    gDispenserManager.RecoveryCard(gSysParam.FTTCEK720ID, nHint);
    nMsg := '����' + nCard + '�Ƿ�,������,���Ժ�����ȡ��';
    WriteLog(nMsg);
    ShowMsg(nMsg, sWarn);
    Exit;
  end;

//  if IFHasBill(EditTruck.Text) then
//  begin
//    ShowMsg('��������δ��ɵ������,�޷�����,����ϵ����Ա',sHint);
//    Exit;
//  end;

  //���������
  nStocks := TStringList.Create;
  nList := TStringList.Create;
  nTmp := TStringList.Create;
  try
    LoadSysDictItem(sFlag_PrintBill, nStocks);
    if Pos('ɢ',EditSName.Text) > 0 then
      nTmp.Values['Type'] := 'S'
    else
      nTmp.Values['Type'] := 'D';
    nTmp.Values['StockNO'] := EditStock.Text;
    nTmp.Values['StockName'] := EditSName.Text;

    if PrintHY.Checked  then
         nTmp.Values['PrintHY'] := sFlag_Yes
    else nTmp.Values['PrintHY'] := sFlag_No;

    nList.Add(PackerEncodeStr(nTmp.Text));
    nPrint := nStocks.IndexOf(EditStock.Text) >= 0;

    with nList do
    begin
      Values['Bills']      := PackerEncodeStr(nList.Text);
      Values['ZhiKa']      := nOrderItem.FYunTianOrderId;
      Values['Price']      := FloatToStr(StrToFloatDef(EditPrice.Text,0));
      Values['Value']      := EditValue.Text;
      Values['MaxMValue']  := FloatToStr(nMaxNum);
      Values['Truck']      := EditTruck.Text;
      Values['Lading']     := sFlag_TiHuo;
      Values['Memo']       := EmptyStr;
      Values['IsVIP']      := Copy(GetCtrlData(EditType),1,1);
      Values['Seal']       := '';
      Values['HYDan']      := '';
      Values['WebOrderID'] := nWebOrderID;
      Values['SaleMan']    := FSellMan;
      {$IFDEF UseXHSpot}
      Values['L_XHSpot'] := EditMemo.Text;
      {$ENDIF}
      {$IFDEF IdentCard}
      Values['Ident'] := EditIdent.Text;
      Values['SJName']:= EditSJName.Text;
      {$ENDIF}
    end;
    nBillData := PackerEncodeStr(nList.Text);
    FBegin := Now;
    nBillID := SaveBill(nBillData);
    if nBillID = '' then
    begin
      nHint := '���������ʧ��';
      ShowMsg(nHint,sError);
      Writelog(nHint);
      Exit;
    end;
    writelog('TfFormNewCard.SaveBillProxy ���������['+nBillID+']-��ʱ��'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
    FBegin := Now;
    SaveWebOrderMatch(nBillID,nWebOrderID,sFlag_Sale);
    writelog('TfFormNewCard.SaveBillProxy �����̳Ƕ�����-��ʱ��'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
  finally
    nStocks.Free;
    nList.Free;
    nTmp.Free;
  end;

  nRet := SaveBillCard(nBillID, nCard);

  if not nRet then
  begin
    nMsg := '����ſ�ʧ��,������.';
    ShowMsg(nMsg, sHint);
    Exit;
  end;

  nRet := gDispenserManager.SendCardOut(gSysParam.FTTCEK720ID, nHint);
  //����

  if nRet then
  begin
    nMsg := '�����[ %s ]�����ɹ�,����[ %s ],���պ����Ŀ�Ƭ';
    nMsg := Format(nMsg, [nBillID, nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end
  else begin
    gDispenserManager.RecoveryCard(gSysParam.FTTCEK720ID, nHint);

    nMsg := '����[ %s ]��������ʧ��,�뵽��Ʊ�������¹���.';
    nMsg := Format(nMsg, [nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end;
  Result := True;
  if nPrint then
    PrintBillReport(nBillID, True);
  //print report
end;

function TfFormNewCard.SaveWebOrderMatch(const nBillID,
  nWebOrderID,nBillType: string):Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := MakeSQLByStr([
  SF('WOM_WebOrderID'   , nWebOrderID),
  SF('WOM_LID'          , nBillID),
  SF('WOM_StatusType'   , c_WeChatStatusCreateCard),
  SF('WOM_MsgType'      , cSendWeChatMsgType_AddBill),
  SF('WOM_BillType'     , nBillType),
  SF('WOM_deleted'     , sFlag_No)
  ], sTable_WebOrderMatch, '', True);
  fdm.ADOConn.BeginTrans;
  try
    fdm.ExecuteSQL(nStr);
    fdm.ADOConn.CommitTrans;
    Result := True;
  except
    fdm.ADOConn.RollbackTrans;
  end;
end;
procedure TfFormNewCard.lvOrdersClick(Sender: TObject);
var
  nSelItem:TListItem;
  i:Integer;
begin
  nSelItem := lvorders.Selected;
  if Assigned(nSelItem) then
  begin
    for i := 0 to lvOrders.Items.Count-1 do
    begin
      if nSelItem = lvOrders.Items[i] then
      begin
        FWebOrderIndex := i;
        LoadSingleOrder;
        Break;
      end;
    end;
  end;
end;

procedure TfFormNewCard.editWebOrderNoKeyPress(Sender: TObject;
  var Key: Char);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  if Key=Char(vk_return) then
  begin
    key := #0;
    if btnQuery.CanFocus then
      btnQuery.SetFocus;
    btnQuery.Click;
  end;
end;

procedure TfFormNewCard.btnClearClick(Sender: TObject);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  editWebOrderNo.Clear;
  ActiveControl := editWebOrderNo;
end;

function TfFormNewCard.IsLastTime(const nTruck: string; var nTime:Integer): Boolean;
var
  nStr : string;
  sFlag_Between2BillsTime : Integer;
begin
  Result := True;
  {$IFDEF Between2BillTime}
  sFlag_Between2BillsTime := 30;

  nStr := ' select d_value from %s where d_name = ''%s'' and d_memo = ''%s'' ';
  nStr := Format(nStr,[sTable_SysDict, sFlag_SysParam, sFag_Between2Time]);
  with FDM.QuerySQL(nStr) do
  begin
    if RecordCount>0 then
    begin
      sFlag_Between2BillsTime := FieldByName('d_value').AsInteger;
    end;
  end;
  
  nTime := sFlag_Between2BillsTime;

  nStr := 'select top 1 L_OutFact from %s where '+
          'l_truck=''%s'' order by L_OutFact desc';
  nStr := Format(nStr,[sTable_Bill,nTruck]);
  with fdm.QueryTemp(nStr) do
  begin
    if recordcount > 0 then
    begin
      if (Now - FieldByName('L_OutFact').AsDateTime)*24*60 < sFlag_Between2BillsTime then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
  {$ENDIF}
end;

function TfFormNewCard.GetMaxTHNum: Double;
var
  nStr:string;
begin
  Result := 0;
  nStr   := ' Select D_Value from %s where  D_Name = ''%s'' and D_Memo = ''%s'' ';
  nStr   := Format(nStr,[sTable_SysDict,sFlag_SysParam,'AicmMaxTHNum']);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      Result := FieldByName('D_Value').AsFloat;
    end;
  end;
end;

function TfFormNewCard.GetMaxENum(const ncontractno:string): Double;
var
  nStr : string;
  num1,num2, nValue : Double;
begin
  Result := 0;
  num1   := 0;
  num2   := 0;
  nValue := 0;
  nStr   := ' Select O_PlanRemain from %s where O_Order = ''%s'' ';
  nStr   := Format(nStr,[sTable_SalesOrder,ncontractno]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      num1 := FieldByName('O_PlanRemain').AsFloat;
    end;
  end;

  nStr   := ' Select sum(L_Value) as L_Value  from %s where L_ZhiKa = ''%s'' and  L_OutFact Is Null ';
  nStr   := Format(nStr,[sTable_Bill,ncontractno]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      num2 := FieldByName('L_Value').AsFloat;
    end;
  end;

  if num1 > num2 then
  begin
    nValue := num1 - num2;
    nValue := Float2Float(nValue,100, False);
  end;

  Result := nValue;
end;

end.
