{*******************************************************************************
  ����: dmzn@163.com 2016-12-30
  ����: ģ��ҵ�����
*******************************************************************************}
unit UWorkerBusinessBill;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UWorkerBusiness, UBusinessConst, UMgrDBConn, ULibFun, UFormCtrl, UBase64,
  USysLoger, USysDB, UMITConst;

type
  TStockMatchItem = record
    FStock: string;         //Ʒ��
    FGroup: string;         //����
    FRecord: string;        //��¼
  end;

  TBillLadingLine = record
    FBill: string;          //������
    FLine: string;          //װ����
    FName: string;          //������
    FPerW: Integer;         //����
    FTotal: Integer;        //�ܴ���
    FNormal: Integer;       //����
    FBuCha: Integer;        //����
    FHKBills: string;       //�Ͽ���
  end;

  TWorkerBusinessBills = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    //io
    FSanMultiBill: Boolean;
    //ɢװ�൥
    FStockItems: array of TStockMatchItem;
    FMatchItems: array of TStockMatchItem;
    //����ƥ��
    FBillLines: array of TBillLadingLine;
    //װ����
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetStockGroup(const nStock: string): string;
    function GetMatchRecord(const nStock: string): string;
    //���Ϸ���
    function AllowedSanMultiBill: Boolean;
    function VerifyBeforSave(var nData: string): Boolean;
    function SaveBills(var nData: string): Boolean;
    //���潻����
    function DeleteBill(var nData: string): Boolean;
    //ɾ��������
    function ChangeBillTruck(var nData: string): Boolean;
    //�޸ĳ��ƺ�
    function SaveBillCard(var nData: string): Boolean;
    //�󶨴ſ�
    function LogoffCard(var nData: string): Boolean;
    //ע���ſ�
    function PickBill(const nParam: TStrings; var nData: string): Boolean;
    function PostBill(var nData: string): Boolean;
    //�������
    function ReverseBill(var nData: string): Boolean;
    //��������
    function GetPostBillItems(var nData: string): Boolean;
    //��ȡ��λ������
    function SavePostBillItems(var nData: string): Boolean;
    //�����λ������
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function VerifyTruckNO(nTruck: string; var nData: string): Boolean;
    //��֤�����Ƿ���Ч
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation

class function TWorkerBusinessBills.FunctionName: string;
begin
  Result := sBus_BusinessSaleBill;
end;

constructor TWorkerBusinessBills.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessBills.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessBills.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessBills.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TWorkerBusinessBills.CallMe(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nPacker.InitData(@nIn, True, False);
    //init
    
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(FunctionName);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-15
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessBills.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;

  case FIn.FCommand of
   cBC_SaveBills           : Result := SaveBills(nData);
   cBC_DeleteBill          : Result := DeleteBill(nData);
   cBC_PostBill            : Result := PostBill(nData);
   cBC_ReverseBill         : Result := ReverseBill(nData);
   cBC_ModifyBillTruck     : Result := ChangeBillTruck(nData);
   cBC_SaveBillCard        : Result := SaveBillCard(nData);
   cBC_LogoffCard          : Result := LogoffCard(nData);
   cBC_GetPostBills        : Result := GetPostBillItems(nData);
   cBC_SavePostBills       : Result := SavePostBillItems(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command,Code: %d).';
      nData := Format(nData, [FIn.FCommand]);
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014/7/30
//Parm: Ʒ�ֱ��
//Desc: ����nStock��Ӧ�����Ϸ���
function TWorkerBusinessBills.GetStockGroup(const nStock: string): string;
var nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FStockItems) to High(FStockItems) do
  if FStockItems[nIdx].FStock = nStock then
  begin
    Result := FStockItems[nIdx].FGroup;
    Exit;
  end;
end;

//Date: 2014/7/30
//Parm: Ʒ�ֱ��
//Desc: ����������������nStockͬƷ��,��ͬ��ļ�¼
function TWorkerBusinessBills.GetMatchRecord(const nStock: string): string;
var nStr: string;
    nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FStock = nStock then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;

  nStr := GetStockGroup(nStock);
  if nStr = '' then Exit;  

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FGroup = nStr then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;
end;

//Date: 2014-09-16
//Parm: ���ƺ�;
//Desc: ��֤nTruck�Ƿ���Ч
class function TWorkerBusinessBills.VerifyTruckNO(nTruck: string;
  var nData: string): Boolean;
var nIdx: Integer;
    nWStr: WideString;
begin
  Result := False;
  nIdx := Length(nTruck);
  if (nIdx < 3) or (nIdx > 10) then
  begin
    nData := '��Ч�ĳ��ƺų���Ϊ3-10.';
    Exit;
  end;

  nWStr := LowerCase(nTruck);
  //lower
  
  for nIdx:=1 to Length(nWStr) do
  begin
    case Ord(nWStr[nIdx]) of
     Ord('-'): Continue;
     Ord('0')..Ord('9'): Continue;
     Ord('a')..Ord('z'): Continue;
    end;

    if nIdx > 1 then
    begin
      nData := Format('���ƺ�[ %s ]��Ч.', [nTruck]);
      Exit;
    end;
  end;

  Result := True;
end;

//Date: 2014-10-07
//Desc: ����ɢװ�൥
function TWorkerBusinessBills.AllowedSanMultiBill: Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_SanMultiBill]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString = sFlag_Yes;
  end;
end;

//Date: 2014-09-15
//Desc: ��֤�ܷ񿪵�
function TWorkerBusinessBills.VerifyBeforSave(var nData: string): Boolean;
var nIdx: Integer;
    nStr,nTruck: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nTruck := FListA.Values['Truck'];
  if not VerifyTruckNO(nTruck, nData) then Exit;

  nStr := 'Select %s as T_Now,T_Valid From %s ' +
          'Where T_Truck=''%s''';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_Truck, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    if FieldByName('T_Valid').AsString = sFlag_No then
    begin
      nData := '����[ %s ]������Ա��ֹ����.';
      nData := Format(nData, [nTruck]);
      Exit;
    end;
  end;

  //----------------------------------------------------------------------------
  SetLength(FStockItems, 0);
  SetLength(FMatchItems, 0);
  //init

  {$IFDEF SanPreHK}
  FSanMultiBill := True;
  {$ELSE}
  FSanMultiBill := AllowedSanMultiBill;
  {$ENDIF}//ɢװ�����൥

  nStr := 'Select M_ID,M_Group From %s Where M_Status=''%s'' ';
  nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes]);
  //Ʒ�ַ���ƥ��

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FStockItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      FStockItems[nIdx].FStock := Fields[0].AsString;
      FStockItems[nIdx].FGroup := Fields[1].AsString;

      Inc(nIdx);
      Next;
    end;
  end;

  nStr := 'Select R_ID,T_Bill,T_StockNo,T_Type,T_InFact,T_Valid From %s ' +
          'Where T_Truck=''%s'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);
  //���ڶ����г���

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FMatchItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      if (FieldByName('T_Type').AsString = sFlag_San) and (not FSanMultiBill) then
      begin
        nStr := '����[ %s ]��δ���[ %s ]������֮ǰ��ֹ����.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end else

      if (FieldByName('T_Type').AsString = sFlag_Dai) and
         (FieldByName('T_InFact').AsString <> '') then
      begin
        nStr := '����[ %s ]��δ���[ %s ]������֮ǰ��ֹ����.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end else

      if FieldByName('T_Valid').AsString = sFlag_No then
      begin
        nStr := '����[ %s ]���ѳ��ӵĽ�����[ %s ],���ȴ���.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end;

      with FMatchItems[nIdx] do
      begin
        FStock := FieldByName('T_StockNo').AsString;
        FGroup := GetStockGroup(FStock);
        FRecord := FieldByName('R_ID').AsString;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck,
    FListA.Values['Phone'], @nOut);
  //���泵�ƺ�

  //----------------------------------------------------------------------------
  nStr := 'Select * From %s Where O_Order=''%s''';
  nStr := Format(nStr, [sTable_SalesOrder, FListA.Values['ZhiKa']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('����[ %s ]������.', [FListA.Values['ZhiKa']]);
      Exit;
    end;

//    if FieldByName('O_Valid').AsString <> sFlag_Yes then
//    begin
//      nData := Format('����[ %s ]����Ч.', [FListA.Values['ZhiKa']]);
//      Exit;
//    end;

    with FListB do
    begin
      Clear;
      Values['Order']      := FieldByName('O_Order').AsString;
      Values['StockName']  := Trim(FieldByName('O_StockName').AsString);
      Values['CusID']  := Trim(FieldByName('O_CusID').AsString);
      Values['CusName']  := Trim(FieldByName('O_CusName').AsString);
      Values['O_CusPY']    := FieldByName('O_CusPY').AsString;
      Values['Company']      := FieldByName('O_Company').AsString;

      {$IFNDEF UseWXERP}
      nStr := FieldByName('O_StockType').AsString;
      if Pos('��',nStr) > 0 then
           Values['Type'] := sFlag_Dai
      else Values['Type'] := sFlag_San;
      {$ENDIF}

      {$IFDEF SyncDataByWSDL}
      Values['ConsignCusName']       := FieldByName('O_ConsignCusName').AsString;
      {$ENDIF}
    end;

    {$IFDEF UseWXERP}
      FListB.Values['StockNo'] := FieldByName('O_StockID').AsString;
    {$ELSE}
      if Length(FListB.Values['StockName']) > 0 then
      begin
        nStr := 'Select D_ParamB From %s Where D_Name = ''%s'' ' +
                'And D_Memo=''%s'' and D_Value like ''%%%s%%''';
        nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem,
                              FListB.Values['Type'],
                              FListB.Values['StockName']]);

        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        if RecordCount > 0 then
        begin
          FListB.Values['StockNo'] := Fields[0].AsString;
        end;
      end;
    {$ENDIF}
  end;
  {$IFDEF UseWXERP}
  nStr := ' Select D_Memo From %s Where D_Name = ''%s''  And D_ParamB = ''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem,FListB.Values['StockNo']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    FListB.Values['Type'] := Fields[0].AsString;
  end;
  {$ENDIF}
  Result := True;
  //verify done
end;

//Date: 2017-09-15
//Desc: ���潻����
function TWorkerBusinessBills.SaveBills(var nData: string): Boolean;
var nStr,nSQL,nPreFix: string;
    nWorker: TBusinessWorkerBase;
    nPacker: TBusinessPackerBase;
    nIn, nOut, nTmp: TWorkerBusinessCommand;
    nLine: string;
    nLimitValue,nLeaveValue: Double;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if not VerifyBeforSave(nData) then Exit;

  //----------------------------------------------------------------------------
  nPreFix := 'WY';
  nStr := 'Select B_Prefix From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nPreFix := Fields[0].AsString;
  end;

  if Pos(nPreFix,FListB.Values['Order']) <= 0 then
  begin
    {$IFDEF SyncDataByDataBase}
    if not TWorkerBusinessCommander.CallMe(cBC_GetStockBatcode,
       FListB.Text, FListA.Values['Value'], @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    if nOut.FBase.FErrCode = sFlag_ForceHint then
    begin
      FOut.FBase.FErrCode := sFlag_ForceHint;
      FOut.FBase.FErrDesc := nOut.FBase.FErrDesc;
    end; //��ʾ���κ�ʹ�����

    FListA.Values['Batcode'] := nOut.FData;
    FListA.Values['BatcodeFirst'] := nOut.FExtParam;
    //���κ�

    {$IFDEF BatchInHYOfBill}
    FListA.Values['HYDan'] := nOut.FData;
    {$ELSE}
    if nOut.FData <> '' then
      FListA.Values['Seal'] := nOut.FData;
    //auto batcode
    {$ENDIF}
    {$ENDIF}
  end
  else
  begin
    FListA.Values['Batcode'] := 'None';
  end;

  {$IFDEF UseWXERP}
    if not TWorkerBusinessCommander.CallMe(cBC_GetStockBatcode,
       FListB.Text, FListA.Values['Value'], @nTmp) then
       raise Exception.Create(nTmp.FData);

    if nTmp.FBase.FErrCode = sFlag_ForceHint then
    begin
      FOut.FBase.FErrCode := sFlag_ForceHint;
      FOut.FBase.FErrDesc := nTmp.FBase.FErrDesc;
    end; //��ʾ���κ�ʹ�����

    FListA.Values['Batcode'] := nTmp.FData;
    FListA.Values['BatcodeFirst'] := nTmp.FExtParam;
    //���κ�

    {$IFDEF BatchInHYOfBill}
    FListA.Values['HYDan'] := nTmp.FData;
    {$ELSE}
    if nTmp.FData <> '' then
      FListA.Values['Seal'] := nTmp.FData;
    //auto batcode
    {$ENDIF}
  {$ENDIF}

  {$IFDEF UseTruckDayXT}
  //���ͻ����޶�
  nSQL := 'select D_Value from %s where D_Name=''%s'' and D_ParamB=''%s''';
  nSQL := Format(nSQL,[sTable_SysDict, sFlag_CusLoadLimit, FListB.Values['StockNo']]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if recordcount > 0 then
      if FieldByName('D_Value').AsString = sFlag_Yes then  //���÷�������
      begin
        nSQL := 'select * from %s where L_CusName=''%s'' and L_StockNo=''%s''';
        nSQL := Format(nSQL,[sTable_CusLimit,FListB.Values['CusName'],FListB.Values['StockNo']]);
        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        begin
          if recordcount > 0 then
          begin
            nLimitValue := FieldByName('L_Value').AsFloat;
            nSQL := 'Select sum(L_Value) as L_Value from %s where L_StockNo=''%s'''+
                    ' and L_Date >= ''%s'' and L_Date < ''%s'' and L_CusId=''%s''';
            nSQL := Format(nSQL,[sTable_Bill,FListB.Values['StockNo'],
                  Date2Str(Date,True)+' 08:00:00',Date2Str(Date+1,True)+' 08:00:00',
                  FListB.Values['CusID']]);
            with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
            begin
              nLeaveValue := nLimitValue - FieldByName('L_Value').AsFloat;
              if nLeaveValue <= 0 then
              begin
                nData := '�ͻ��޶�:����[ %s ]�ѳ����շ����������޷�����';
                nData := Format(nData,[FListB.Values['StockNO']+'-'+FListB.Values['StockName']]);
                exit;
              end
              else
              begin
                if nLeaveValue < StrToFloat(FListA.Values['Value']) then
                begin
                  nData := '�ͻ��޶�:��ǰ�ͻ�����[ %s ]'+#13#10+'���շ������޶[ %s ]��'+#13#10 +
                           '��ǰʣ����[ %s ]��';
                  nData := Format(nData,[FListB.Values['StockNO']+'-'+FListB.Values['StockName'],
                            FloatToStr(nLimitValue),FloatToStr(nLeaveValue)]);
                  Exit;
                end;
              end;
            end;
          end
          else
          begin      //���û�м�¼���������
//            nData := '�û� [ %s ] ���� [ %s ].';
//            nData := Format(nData,[FListA.Values['CusName'],FListC.Values['StockNO']]);
//            Exit;
          end;
        end;
      end;
  end;
  {$ENDIF}

  FDBConn.FConn.BeginTrans;
  try
    FListC.Values['Group'] :=sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_BillNo;
    //to get serial no

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //bill list

    nStr := MakeSQLByStr([
            SF('L_ID',         FOut.FData),
            SF('L_Status',     sFlag_TruckNone),
            SF('L_ZhiKa',      FListA.Values['ZhiKa']),
            SF('L_Order',      FListA.Values['ZhiKa']),
            SF('L_Area',       FListA.Values['Area']),
            SF('L_CusID',      FListB.Values['CusID']),
            SF('L_CusName',    FListB.Values['CusName']),
            SF('L_CusPY',      FListB.Values['O_CusPY']),

            SF('L_Type',       FListB.Values['Type']),
            SF('L_StockNo',    FListB.Values['StockNo']),
            SF('L_StockName',  FListB.Values['StockName']),
            SF('L_Value',      FListA.Values['Value'], sfVal),
            SF('L_PreValue',   FListA.Values['Value'], sfVal),

            {$IFDEF UseYSKDValue}
            SF('L_KDValue',    FListA.Values['Value'], sfVal),
            {$ENDIF}

            {$IFDEF PrintGLF}
            SF('L_PrintGLF',   FListA.Values['PrintGLF']),
            {$ENDIF} //�Զ���ӡ��·��

            {$IFDEF PrintHYEach}
            SF('L_PrintHY',     FListA.Values['PrintHY']),
            {$ENDIF} //�泵��ӡ���鵥

            {$IFDEF SyncDataByWSDL}
            SF('L_ConsignCusName',    FListB.Values['ConsignCusName']),
            {$ENDIF}

            SF('L_Price',       FListA.Values['Price']),
            SF('L_SaleMan',     FListA.Values['SaleMan']),
            SF('L_Truck',       FListA.Values['Truck']),
            SF('L_WebOrderID',  FListA.Values['WebOrderID']),
            SF('L_Phone',       FListA.Values['Phone']),
            SF('L_Lading',      FListA.Values['Lading']),
            SF('L_IsVIP',       FListA.Values['IsVIP']),
            SF('L_Seal',        FListA.Values['Seal']),
            SF('L_HYDan',       FListA.Values['HYDan']),
            SF('L_HYFirst',     FListA.Values['BatcodeFirst']),
            SF('L_Man',         FIn.FBase.FFrom.FUser),
            SF('L_Date',        sField_SQLServer_Now, sfVal),
            SF('L_WT',          FListA.Values['WT']),
            SF('L_MValueMax',   FListA.Values['MaxMValue'])
            ], sTable_Bill, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    {$IFDEF UseWXERP}
    nSQL := MakeSQLByStr([
          SF('H_ID'   , FOut.FData),
          SF('H_Order' , FListA.Values['ZhiKa']),
          SF('H_Status' , '0'),
          SF('H_BillType'  , sFlag_Sale),
          SF('H_PurType'   , 'Trk')
          ], sTable_HHJYSync, '', True);
    gDBConnManager.WorkerExec(FDBConn, nSQL);
    {$ENDIF}

    nStr := 'Update %s Set B_HasUse=B_HasUse+%s Where B_Batcode=''%s''';
    nStr := Format(nStr, [sTable_StockBatcode, FListA.Values['Value'],
            FListA.Values['Batcode']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //�������κ�ʹ����

    nStr := 'Update %s Set R_Used=R_Used+%s Where R_Batcode=''%s''';
    nStr := Format(nStr, [sTable_BatRecord, FListA.Values['Value'],
            FListA.Values['Batcode']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //�������μ�¼ʹ����

    if FListA.Values['BuDan'] = sFlag_Yes then //����
    begin
      nStr := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
              SF('L_InTime', FListA.Values['BuDanDate']),
              SF('L_PValue', 0, sfVal),
              SF('L_PDate', FListA.Values['BuDanDate']),
              SF('L_PMan', FIn.FBase.FFrom.FUser),
              SF('L_MValue', FListA.Values['Value'], sfVal),
              SF('L_MDate', FListA.Values['BuDanDate']),
              SF('L_MMan', FIn.FBase.FFrom.FUser),
              SF('L_OutFact', FListA.Values['BuDanDate']),
              SF('L_OutMan', FIn.FBase.FFrom.FUser),
              SF('L_Card', '')
              ], sTable_Bill, SF('L_ID', FOut.FData), False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      if FListB.Values['Type'] = sFlag_San then
      begin
        nStr := '';
        //ɢװ����ϵ�
      end else
      begin
        nStr := FListB.Values['StockNo'];
        nStr := GetMatchRecord(nStr);
        //��Ʒ����װ�������еļ�¼��
      end;

      if nStr <> '' then
      begin
        nSQL := 'Update $TK Set T_Value=T_Value + $Val,' +
                'T_HKBills=T_HKBills+''$BL.'' Where R_ID=$RD';
        nSQL := MacroValue(nSQL, [MI('$TK', sTable_ZTTrucks),
                MI('$RD', nStr), MI('$Val', FListA.Values['Value']),
                MI('$BL', FOut.FData)]);
        gDBConnManager.WorkerExec(FDBConn, nSQL);
      end else
      begin
        nLine := '';
        {$IFDEF MoreNumZDLine}
        nStr := 'Select D_Name From $Sys where D_Memo=''$ST'' and D_ParamB = ''$SA'' and D_Value <= $SV ';
        nStr := MacroValue(nStr, [MI('$Sys', sTable_SysDict),
                MI('$ST', FListB.Values['StockName']),
                MI('$SA', sFlag_ZDLineItem),
                MI('$SV', FListA.Values['Value'])]);
        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        begin
          if RecordCount > 0 then
          begin
            nLine := FieldByName('D_Name').AsString;
          end;
        end;
        {$ENDIF}
        
        nSQL := MakeSQLByStr([
          SF('T_Truck'   , FListA.Values['Truck']),
          SF('T_StockNo' , FListB.Values['StockNo']),
          SF('T_Stock'   , FListB.Values['StockName']),
          SF('T_Type'    , FListB.Values['Type']),
          SF('T_InTime'  , sField_SQLServer_Now, sfVal),
          SF('T_Bill'    , FOut.FData),
          {$IFDEF MoreNumZDLine}
          SF('T_Line',     nLine),
          {$ENDIF}
          SF('T_Valid'   , sFlag_Yes),
          SF('T_Value'   , FListA.Values['Value'], sfVal),
          SF('T_VIP'     , FListA.Values['IsVIP']),
          SF('T_HKBills' , FOut.FData + '.')
          ], sTable_ZTTrucks, '', True);
        gDBConnManager.WorkerExec(FDBConn, nSQL);
      end;
    end;

    if FListA.Values['BuDan'] = sFlag_Yes then //����
    begin
      nStr := 'Update %s Set O_HasDone=O_HasDone+%s Where O_Order=''%s''';
      nStr := Format(nStr, [sTable_SalesOrder, FListA.Values['Value'],
              FListA.Values['ZhiKa']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //has done
    end else
    begin
      nStr := 'Update %s Set O_Freeze=O_Freeze+%s Where O_Order=''%s''';
      nStr := Format(nStr, [sTable_SalesOrder, FListA.Values['Value'],
              FListA.Values['ZhiKa']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //freeze
    end;

    {$IFNDEF UseWXERP}
    nSQL := MakeSQLByStr([
          SF('H_ID'   , FOut.FData),
          SF('H_Order' , FListA.Values['ZhiKa']),
          SF('H_Status' , '0'),
          SF('H_BillType'   , sFlag_Sale),
          SF('H_PurType'   , 'S')
          ], sTable_HHJYSync, '', True);
    gDBConnManager.WorkerExec(FDBConn, nSQL);
    {$ENDIF}

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014-09-16
//Parm: ������[FIn.FData];���ƺ�[FIn.FExtParam]
//Desc: �޸�ָ���������ĳ��ƺ�
function TWorkerBusinessBills.ChangeBillTruck(var nData: string): Boolean;
var nIdx: Integer;
    nStr,nTruck: string;
begin
  Result := False;
  if not VerifyTruckNO(FIn.FExtParam, nData) then Exit;

  nStr := 'Select L_Truck,L_InTime From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <> 1 then
    begin
      nData := '������[ %s ]����Ч.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    {$IFNDEF TruckInNow}
    if Fields[1].AsString <> '' then
    begin
      nData := '������[ %s ]�����,�޷��޸ĳ��ƺ�.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    {$ENDIF}

    nTruck := Fields[0].AsString;
  end;

  nStr := 'Select R_ID,T_HKBills From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    FListA.Clear;
    FListB.Clear;
    First;

    while not Eof do
    begin
      SplitStr(Fields[1].AsString, FListC, 0, '.');
      FListA.AddStrings(FListC);
      FListB.Add(Fields[0].AsString);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //�����޸���Ϣ

    if (FListA.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListA.Count - 1 downto 0 do
      if CompareText(FIn.FData, FListA[nIdx]) <> 0 then
      begin
        nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
        nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FListA[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //ͬ���ϵ����ƺ�

        nStr := 'Update %s Set P_Truck=''%s'' Where P_Bill=''%s''';
        nStr := Format(nStr, [sTable_PoundLog, FIn.FExtParam, FListA[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //ͬ���ϵ�������¼���ƺ�
      end;
    end;

    if (FListB.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListB.Count - 1 downto 0 do
      begin
        nStr := 'Update %s Set T_Truck=''%s'' Where R_ID=%s';
        nStr := Format(nStr, [sTable_ZTTrucks, FIn.FExtParam, FListB[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //ͬ���ϵ����ƺ�
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-16
//Parm: ��������[FIn.FData]
//Desc: ɾ��ָ��������
function TWorkerBusinessBills.DeleteBill(var nData: string): Boolean;
var nIdx: Integer;
    nVal: Double;
    nHasOut: Boolean;
    nStr,nP,nFix,nRID,nBill,nZK,nHY: string;

    nWorker: TBusinessWorkerBase;
    nPacker: TBusinessPackerBase;
    nIn,nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nStr := 'Select L_ZhiKa,L_Truck,L_Value,L_OutFact,L_HYDan,L_Seal From %s ' +
          'Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '������[ %s ]����Ч.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nZK := FieldByName('L_ZhiKa').AsString;
    nVal := FieldByName('L_Value').AsFloat;
    nFix := FieldByName('L_Truck').AsString;
    nHasOut := FieldByName('L_OutFact').AsString <> '';

    {$IFDEF BatchInHYOfBill}
    nHY := FieldByName('L_HYDan').AsString;
    {$ELSE}
    nHY := FieldByName('L_Seal').AsString;
    {$ENDIF}
  end;
                   
  nStr := 'Select R_ID,T_HKBills,T_Bill From %s ' +
          'Where T_HKBills Like ''%%%s%%''';
  nStr := Format(nStr, [sTable_ZTTrucks, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    if RecordCount <> 1 then
    begin
      nData := '������[ %s ]�����ڶ�����¼��,�쳣��ֹ!';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nRID := Fields[0].AsString;
    nBill := Fields[2].AsString;
    SplitStr(Fields[1].AsString, FListA, 0, '.')
  end else
  begin
    nRID := '';
    FListA.Clear;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FListA.Count = 1 then
    begin
      nStr := 'Delete From %s Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nRID]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else

    if FListA.Count > 1 then
    begin
      nIdx := FListA.IndexOf(FIn.FData);
      if nIdx >= 0 then
        FListA.Delete(nIdx);
      //�Ƴ��ϵ��б�

      if nBill = FIn.FData then
        nBill := FListA[0];
      //����������

      nStr := 'Update %s Set T_Bill=''%s'',T_Value=T_Value-(%.2f),' +
              'T_HKBills=''%s'' Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nBill, nVal,
              CombinStr(FListA, '.'), nRID]);
      //xxxxx

      gDBConnManager.WorkerExec(FDBConn, nStr);
      //���ºϵ���Ϣ
    end;

    if nHasOut then
    begin
      nStr := 'Update %s Set O_HasDone=O_HasDone-(%.2f) Where O_Order=''%s''';
      nStr := Format(nStr, [sTable_SalesOrder, nVal, nZK]);
      gDBConnManager.WorkerExec(FDBConn, nStr); //�ѷ�
    end else
    begin
      nStr := 'Update %s Set O_Freeze=O_Freeze-(%.2f) Where O_Order=''%s''';
      nStr := Format(nStr, [sTable_SalesOrder, nVal, nZK]);
      gDBConnManager.WorkerExec(FDBConn, nStr); //����
    end;

    nStr := 'Update %s Set B_HasUse=B_HasUse-(%.2f) Where B_Batcode=''%s''';
    nStr := Format(nStr, [sTable_StockBatcode, nVal, nHY]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //�ͷ�ʹ�õ����κ�

    nStr := 'Update %s Set R_Used=R_Used-(%.2f) Where R_Batcode=''%s''';
    nStr := Format(nStr, [sTable_BatRecord, nVal, nHY]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //�ͷ����μ�¼ʹ����

    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_Bill]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('L_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //�����ֶ�,������ɾ��

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $BB($FL,L_DelMan,L_DelDate) ' +
            'Select $FL,''$User'',$Now From $BI Where L_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$BB', sTable_BillBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$BI', sTable_Bill), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: ������[FIn.FData];�ſ���[FIn.FExtParam]
//Desc: Ϊ�������󶨴ſ�
function TWorkerBusinessBills.SaveBillCard(var nData: string): Boolean;
var nStr,nSQL,nTruck,nType: string;
begin  
  nType := '';
  nTruck := '';
  Result := False;

  FListB.Text := FIn.FExtParam;
  //�ſ��б�
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //�������б�

  nSQL := 'Select L_ID,L_Card,L_Type,L_Truck,L_OutFact From %s ' +
          'Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('������[ %s ]�Ѷ�ʧ.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      if FieldByName('L_OutFact').AsString <> '' then
      begin
        nData := '������[ %s ]�ѳ���,��ֹ�쿨.';
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '������[ %s ]�ĳ��ƺŲ�һ��,���ܲ���.' + #13#10#13#10 +
                 '*.��������: %s' + #13#10 +
                 '*.��������: %s' + #13#10#13#10 +
                 '��ͬ�ƺŲ��ܲ���,���޸ĳ��ƺ�,���ߵ����쿨.';
        nData := Format(nData, [FieldByName('L_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('L_Type').AsString;
      if (nType <> '') and ((nStr <> nType) or (nStr = sFlag_San)) then
      begin
        if nStr = sFlag_San then
             nData := '������[ %s ]ͬΪɢװ,���ܲ���.'
        else nData := '������[ %s ]��ˮ�����Ͳ�һ��,���ܲ���.';
          
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      if nType = '' then
        nType := nStr;
      //xxxxx

      nStr := FieldByName('L_Card').AsString;
      //����ʹ�õĴſ�
        
      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  SplitStr(FIn.FData, FListA, 0, ',');
  //�������б�
  nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
  //�ſ��б�

  nSQL := 'Select L_ID,L_Type,L_Truck From %s Where L_Card In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := FieldByName('L_Type').AsString;
      if (nStr <> sFlag_Dai) or ((nType <> '') and (nStr <> nType)) then
      begin
        nData := '����[ %s ]����ʹ�øÿ�,�޷�����.';
        nData := Format(nData, [FieldByName('L_Truck').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '����[ %s ]����ʹ�øÿ�,��ͬ�ƺŲ��ܲ���.';
        nData := Format(nData, [nStr]);
        Exit;
      end;

      nStr := FieldByName('L_ID').AsString;
      if FListA.IndexOf(nStr) < 0 then
        FListA.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nSQL := 'Select T_HKBills From %s Where T_Truck=''%s'' ';
  nSQL := Format(nSQL, [sTable_ZTTrucks, nTruck]);

  //���ڶ����г���
  nStr := '';
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    try
      nStr := nStr + Fields[0].AsString;
    finally
      Next;
    end;

    nStr := Copy(nStr, 1, Length(nStr)-1);
    nStr := StringReplace(nStr, '.', ',', [rfReplaceAll]);
  end; 

  nStr := AdjustListStrFormat(nStr, '''', True, ',', False);
  //�����н������б�

  nSQL := 'Select L_Card From %s Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      if (Fields[0].AsString <> '') and
         (Fields[0].AsString <> FIn.FExtParam) then
      begin
        nData := '����[ %s ]�Ĵſ��Ų�һ��,���ܲ���.' + #13#10#13#10 +
                 '*.�����ſ�: [%s]' + #13#10 +
                 '*.�����ſ�: [%s]' + #13#10#13#10 +
                 '��ͬ�ſ��Ų��ܲ���,���޸ĳ��ƺ�,���ߵ����쿨.';
        nData := Format(nData, [nTruck, FIn.FExtParam, Fields[0].AsString]);
        Exit;
      end;

      Next;
    end;  
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nStr := AdjustListStrFormat2(FListA, '''', True, ',', False);
      //���¼����б�

      nSQL := 'Update %s Set L_Card=''%s'' Where L_ID In(%s)';
      nSQL := Format(nSQL, [sTable_Bill, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Sale),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
      nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Sale),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nStr, False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    nStr := Format('WOM_LID=''%s''', [FIn.FData]);
    nStr := MakeSQLByStr([SF('WOM_deleted', sFlag_No)
            ], sTable_WebOrderMatch, nStr, False);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //��ʼ����

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: �ſ���[FIn.FData]
//Desc: ע���ſ�
function TWorkerBusinessBills.LogoffCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set L_Card=Null Where L_Card=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'', C_Used=Null Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, sFlag_CardInvalid, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-10-09
//Parm: �������
//Desc: ִ�м��䶯��
function TWorkerBusinessBills.PickBill(const nParam: TStrings;
  var nData: string): Boolean;
var nStr: string;
    nWorker: TBusinessWorkerBase;
    nPacker: TBusinessPackerBase;
    nIn,nOut: TWorkerBusinessCommand;
begin
  nWorker := nil;
  nPacker := nil;
  try
    Result := False;
    nWorker := gBusinessWorkerManager.LockWorker(sBus_PickSaleBill);
    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);

    //nIn.FBase := FIn.FBase;
    nIn.FBase.FMsgNO := sFlag_ForceDone + sFlag_BillPick + nParam.Values['P_VBELN'];
    nIn.FData := PackerEncodeStr(nParam.Text);

    nStr := nPacker.PackIn(@nIn);
    if not nWorker.WorkActive(nStr) then
      raise Exception.Create(nStr);
    //xxxxx

    nPacker.UnPackOut(nStr, @nOut);
    if not nOut.FBase.FResult then
    begin
      with nOut.FBase do
        nData := Format('����������ʧ��,����: %s.%s', [FErrCode, FErrDesc]);
      Exit;
    end;

    Result := True;
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
    gBusinessPackerManager.RelasePacker(nPacker);
  end;
end;

//Date: 2017-10-09
//Parm: ��������[FIn.FData]
//Desc: ִ�й��˶���
function TWorkerBusinessBills.PostBill(var nData: string): Boolean;
var nStr: string;
    nWorker: TBusinessWorkerBase;
    nPacker: TBusinessPackerBase;
    nIn,nOut: TWorkerBusinessCommand;
begin
  nWorker := nil;
  nPacker := nil;
  try
    Result := False;
    nStr := 'Select L_ID,L_NewID,L_Value,L_Truck,L_PostOk,L_OutFact From %s ' +
            'Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('������[ %s ]����Ч.', [FIn.FData]);
        Exit;
      end;

      {nStr := FieldByName('L_PostOk').AsString;
      if nStr = sFlag_Yes then
      begin
        nData := Format('������[ %s ]�ѹ���.', [FIn.FData]);
        Exit;
      end;}

      with FListA do
      begin
        Clear;
        nStr := FieldByName('L_NewID').AsString;
        if nStr = '' then
          nStr := FieldByName('L_ID').AsString;
        //xxxxx

        Values['P_VBELN'] := nStr;
        Values['P_BUDAT'] := Date2Str(FieldByName('L_OutFact').AsDateTime, False);
        Values['P_LFIMG'] := FormatFloat('#0.00', FieldByName('L_Value').AsFloat);
        Values['P_CPH'] := FieldByName('L_Truck').AsString;
        Values['PostDate'] := DateTime2Str(Now);
      end;

      nIn.FBase := FIn.FBase;
      nStr := FieldByName('L_ID').AsString;
      nIn.FBase.FMsgNO := sFlag_ForceDone + sFlag_BillPost + nStr;
    end;

    Result := True;
    nWorker := gBusinessWorkerManager.LockWorker(sBus_PostSaleBill);
    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);

    nIn.FData := PackerEncodeStr(FListA.Text);
    nStr := nPacker.PackIn(@nIn); 

    if not nWorker.WorkActive(nStr) then
      raise Exception.Create(nStr);
    //xxxxx

    nPacker.UnPackOut(nStr, @nOut);
    if not nOut.FBase.FResult then
    begin
      with nOut.FBase do
        nData := Format('����������ʧ��,����: %s.%s', [FErrCode, FErrDesc]);
      Exit;
    end;
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
    gBusinessPackerManager.RelasePacker(nPacker);
  end;
end;

//Date: 2017-10-14
//Parm: ��������[FIn.FData]
//Desc: �Խ�����ִ�г�������
function TWorkerBusinessBills.ReverseBill(var nData: string): Boolean;
var nStr: string;
    nWorker: TBusinessWorkerBase;
    nPacker: TBusinessPackerBase;
    nIn,nOut: TWorkerBusinessCommand;
begin
  nWorker := nil;
  nPacker := nil;
  try
    Result := False;
    nStr := 'Select L_ID,L_NewID,L_Value,L_Truck,L_OutFact From %s ' +
            'Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('������[ %s ]����Ч.', [FIn.FData]);
        Exit;
      end;

      with FListA do
      begin
        Clear;
        nStr := FieldByName('L_NewID').AsString;
        if nStr = '' then
          nStr := FieldByName('L_ID').AsString;
        //xxxxx

        Values['P_VBELN'] := nStr;
        Values['P_BUDAT'] := Date2Str(FieldByName('L_OutFact').AsDateTime, False);
        Values['P_LFIMG'] := FormatFloat('#0.00', FieldByName('L_Value').AsFloat);
        Values['P_CPH'] := FieldByName('L_Truck').AsString;
        Values['ReverseDate'] := DateTime2Str(Now);
      end;

      nIn.FBase := FIn.FBase;
      nStr := FieldByName('L_ID').AsString;
      nIn.FBase.FMsgNO := sFlag_ForceDone + sFlag_BillReverse + nStr;
    end;

    Result := True;
    nWorker := gBusinessWorkerManager.LockWorker(sBus_ReverseSaleBill);
    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);

    nIn.FData := PackerEncodeStr(FListA.Text);
    nStr := nPacker.PackIn(@nIn); 

    if not nWorker.WorkActive(nStr) then
      raise Exception.Create(nStr);
    //xxxxx

    nPacker.UnPackOut(nStr, @nOut);
    FOut.FBase.FResult := nOut.FBase.FResult;
    FOut.FBase.FErrCode := nOut.FBase.FErrCode;
    FOut.FBase.FErrDesc := nOut.FBase.FErrDesc;

    if not nOut.FBase.FResult then
    begin
      with nOut.FBase do
        nData := Format('����������ʧ��,����: %s.%s', [FErrCode, FErrDesc]);
      Exit;
    end;
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
    gBusinessPackerManager.RelasePacker(nPacker);
  end;
end;

//Date: 2014-09-17
//Parm: �ſ���[FIn.FData];��λ[FIn.FExtParam]
//Desc: ��ȡ�ض���λ����Ҫ�Ľ������б�
function TWorkerBusinessBills.GetPostBillItems(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nIsBill: Boolean;
    nBills: TLadingBillItems;
begin
  Result := False;
  nIsBill := False;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_BillNo]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nIsBill := (Pos(Fields[0].AsString, FIn.FData) = 1) and
               (Length(FIn.FData) = Fields[1].AsInteger);
    //ǰ׺�ͳ��ȶ����㽻�����������,����Ϊ��������
  end;

  if not nIsBill then
  begin
    nStr := 'Select C_Status,C_Freeze From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FData]);
    //card status

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('�ſ�[ %s ]��Ϣ�Ѷ�ʧ.', [FIn.FData]);
        Exit;
      end;

      if Fields[0].AsString <> sFlag_CardUsed then
      begin
        nData := '�ſ�[ %s ]��ǰ״̬Ϊ[ %s ],�޷����.';
        nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
        Exit;
      end;

      if Fields[1].AsString = sFlag_Yes then
      begin
        nData := '�ſ�[ %s ]�ѱ�����,�޷����.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
    end;
  end;

  FListA.Clear;
  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_NFStock]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    First;
    while not Eof do
    begin
      FListA.Add(Fields[0].AsString);
      Next;
    end;
  end;

  FListC.Clear;
  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundMultiM]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    First;
    while not Eof do
    begin
      FListC.Add(Fields[0].AsString);
      Next;
    end;
  end; //�ɶ�ι��س�����

  nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
          'L_StockName,L_Truck,L_Value,L_Price,L_ZKMoney,L_Status,' +
          'L_NextStatus,L_Card,L_IsVIP,L_PValue,L_MValue,L_PrintHY,' +
          'L_HYDan,L_Seal,L_NewID,L_TruckEmpty,L_WebOrderID,L_MDate From $Bill b ';
  //xxxxx

  if nIsBill then
       nStr := nStr + 'Where L_ID=''$CD'''
  else nStr := nStr + 'Where L_Card=''$CD''';

  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', FIn.FData)]);
  FListB.Clear;
  //sql list

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nIsBill then
           nData := '������[ %s ]����Ч.'
      else nData := '�ſ���[ %s ]û�н�����.';

      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    with nBills[nIdx] do
    begin
      FID         := FieldByName('L_ID').AsString;
      FNewID      := FieldByName('L_NewID').AsString;
      FZhiKa      := FieldByName('L_ZhiKa').AsString;
      FCusID      := FieldByName('L_CusID').AsString;
      FCusName    := FieldByName('L_CusName').AsString;
      FTruck      := FieldByName('L_Truck').AsString;

      FType       := FieldByName('L_Type').AsString;
      FStockNo    := FieldByName('L_StockNo').AsString;
      FStockName  := FieldByName('L_StockName').AsString;
      FValue      := FieldByName('L_Value').AsFloat;
      FPrice      := FieldByName('L_Price').AsFloat;

      FCard       := FieldByName('L_Card').AsString;
      FIsVIP      := FieldByName('L_IsVIP').AsString;
      FStatus     := FieldByName('L_Status').AsString;
      FNextStatus := FieldByName('L_NextStatus').AsString;

      {$IFDEF BatchInHYOfBill}
      FHYDan      := FieldByName('L_HYDan').AsString;
      {$ELSE}
      FHYDan      := FieldByName('L_Seal').AsString;
      {$ENDIF}

      FPrintHY    := FieldByName('L_PrintHY').AsString = sFlag_Yes;
      FYSValid    := FieldByName('L_TruckEmpty').AsString; //�ճ��������
      FWebOrderID := FieldByName('L_WebOrderID').AsString; //�̳����뵥

      if FIsVIP = sFlag_TypeShip then
      begin
        FStatus    := sFlag_TruckZT;
        FNextStatus := sFlag_TruckOut;
      end;

      if FStatus = sFlag_BillNew then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;

      if (FType = sFlag_San) and
         (FStatus = sFlag_TruckBFM) and (FListA.IndexOf(FStockNo) >= 0) then//�ֳ�������
      begin
        FStatus     := sFlag_TruckFH;
        FNextStatus := sFlag_TruckBFM;

        nStr := 'Update %s Set L_Status=''%s'',L_NextStatus=''%s'' ' +
                'Where L_ID=''%s''';
        //xxxxx

        nStr := Format(nStr, [sTable_Bill, sFlag_TruckFH, sFlag_TruckBFM, FID]);
        FListB.Add(nStr);
        //ɢװ���غ󷵻��ֳ�,���¼�¼״̬
      end else
      if (FIn.FExtParam = sFlag_TruckFH) and (FType = sFlag_San) and
         (FStatus = sFlag_TruckBFM) and (FListC.IndexOf(FStockNo) >= 0) then
      begin
        FStatus     := sFlag_TruckFH;
        FNextStatus := sFlag_TruckBFM;

        nStr := 'Update %s Set L_Status=''%s'',L_NextStatus=''%s'' ' +
                'Where L_ID=''%s''';
        //xxxxx

        nStr := Format(nStr, [sTable_Bill, sFlag_TruckFH, sFlag_TruckBFM, FID]);
        FListB.Add(nStr);
        //ɢװ���غ󷵻��ֳ�,���¼�¼״̬
      end;

      FPData.FValue := FieldByName('L_PValue').AsFloat;
      FMData.FValue := FieldByName('L_MValue').AsFloat;
      FMData.FDate  := FieldByName('L_MDate').AsDateTime;
      FSelected := True;

      Inc(nIdx);
      Next;
    end;
  end;

  if (FListB.Count > 0) and (not gDBConnManager.ExecSQLs(FListB, True)) then
  begin
    nData := '���½�����״̬ʧ��.';
    Exit;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: ������[FIn.FData];��λ[FIn.FExtParam]
//Desc: ����ָ����λ�ύ�Ľ������б�
function TWorkerBusinessBills.SavePostBillItems(var nData: string): Boolean;
var nStr,nSQL,nTmp,nPreFix: string;
    nVal,nMVal: Double;
    i,nIdx,nInt: Integer;
    nBills: TLadingBillItems;
    nIsOtherOrder: Boolean;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nBills);
  nInt := Length(nBills);

  if nInt < 1 then
  begin
    nData := '��λ[ %s ]�ύ�ĵ���Ϊ��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  nPreFix := 'WY';
  nStr := 'Select B_Prefix From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nPreFix := Fields[0].AsString;
  end;

  if Pos(nPreFix,nBills[0].FZhiKa) > 0 then
    nIsOtherOrder := True
  else
    nIsOtherOrder := False;

  FListA.Clear;
  //���ڴ洢SQL�б�

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //����
  begin
    with nBills[0] do
    begin
      FStatus := sFlag_TruckIn;
      FNextStatus := sFlag_TruckBFP;
    end;

    if nBills[0].FType = sFlag_Dai then
    begin
      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_PoundIfDai]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
       if (RecordCount > 0) and (Fields[0].AsString = sFlag_No) then
        nBills[0].FNextStatus := sFlag_TruckZT;
      //��װ������
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    begin
      nStr := SF('L_ID', nBills[nIdx].FID);
      nSQL := MakeSQLByStr([
              SF('L_Status', nBills[0].FStatus),
              SF('L_NextStatus', nBills[0].FNextStatus),
              SF('L_InTime', sField_SQLServer_Now, sfVal),
              SF('L_InMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InFact=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
              nBills[nIdx].FID]);
      FListA.Add(nSQL);
      //���¶��г�������״̬
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //����Ƥ��
  begin
    FListB.Clear;
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_NFStock]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        FListB.Add(Fields[0].AsString);
        Next;
      end;
    end;

    nInt := -1;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPoundID = sFlag_Yes then
    begin
      nInt := nIdx;
      Break;
    end;

    if nInt < 0 then
    begin
      nData := '��λ[ %s ]�ύ��Ƥ������Ϊ0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    //--------------------------------------------------------------------------
    FListC.Clear;
    FListC.Values['Field'] := 'T_PValue';
    FListC.Values['Truck'] := nBills[nInt].FTruck;
    FListC.Values['Value'] := FloatToStr(nBills[nInt].FPData.FValue);

    if not TWorkerBusinessCommander.CallMe(cBC_UpdateTruckInfo,
          FListC.Text, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //���泵����ЧƤ��

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FStatus := sFlag_TruckBFP;
      if FType = sFlag_Dai then
           FNextStatus := sFlag_TruckZT
      else FNextStatus := sFlag_TruckFH;

      if FListB.IndexOf(FStockNo) >= 0 then
        FNextStatus := sFlag_TruckBFM;
      //�ֳ�������ֱ�ӹ���

      nSQL := MakeSQLByStr([
              SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF('L_PValue', nBills[nInt].FPData.FValue, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FOut.FData := nOut.FData;
      //���ذ񵥺�,�������հ�

      nSQL := MakeSQLByStr([
              SF('P_ID', nOut.FData),
              SF('P_Type', sFlag_Sale),
              SF('P_Bill', FID),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', FType),
              SF('P_LimValue', FValue),
              SF('P_PValue', nBills[nInt].FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', nBills[nInt].FFactory),
              SF('P_PStation', nBills[nInt].FPData.FStation),
              SF('P_Direction', '����'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_BDAX', 3, sfVal),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckZT then //ջ̨�ֳ�
  begin
    nInt := -1;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPData.FValue > 0 then
    begin
      nInt := nIdx;
      Break;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FStatus := sFlag_TruckZT;
      if nInt >= 0 then //�ѳ�Ƥ
           FNextStatus := sFlag_TruckBFM
      else FNextStatus := sFlag_TruckOut;

      nSQL := MakeSQLByStr([SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF_IF([SF('L_TruckEmpty', 'Null', sfVal),
                     SF('L_TruckEmpty', FYSValid)], Trim(FYSValid) = ''),
              //xxxxx

              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //���¶��г������״̬
    end;
  end else

  if FIn.FExtParam = sFlag_TruckFH then //�Ż��ֳ�
  begin
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckFH),
              SF('L_NextStatus', sFlag_TruckBFM),
              SF_IF([SF('L_TruckEmpty', 'Null', sfVal),
                     SF('L_TruckEmpty', FYSValid)], Trim(FYSValid) = ''),
              //xxxxx

              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //���¶��г������״̬
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    nInt := -1;
    nMVal := 0;

    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPoundID = sFlag_Yes then
    begin
      nMVal := nBills[nIdx].FMData.FValue;
      nInt := nIdx;
      Break;
    end;

    if nInt < 0 then
    begin
      nData := '��λ[ %s ]�ύ��ë������Ϊ0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    with nBills[0] do
    if FType = sFlag_San then //ɢװ
    begin
      nVal := FValue;
      FValue := nMVal - FPData.FValue;
      //�¾���,ʵ�������
      nVal := FValue - nVal;
      //����������

      if nBills[nInt].FPModel <> sFlag_PoundCC then //����ģʽ������
      begin

      end;

      nSQL := 'Update %s Set O_Freeze=O_Freeze+(%.2f) ' +
              'Where O_Order=''%s''';
      nSQL := Format(nSQL, [sTable_SalesOrder, nVal, FZhiKa]);
      FListA.Add(nSQL); //update order freeze

      nSQL := MakeSQLByStr([SF('L_Value', FValue, sfVal)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL); //update bill value

      nSQL := 'Update %s Set B_HasUse=B_HasUse+(%.2f) ' +
              'Where B_Batcode=''%s''';
      nSQL := Format(nSQL, [sTable_StockBatcode, nVal, FHYDan]);
      FListA.Add(nSQL); //update batcode

      nSQL := 'Update %s Set R_Used=R_Used+(%.2f) ' +
              'Where R_Batcode=''%s''';
      nSQL := Format(nSQL, [sTable_BatRecord, nVal, FHYDan]);
      FListA.Add(nSQL); //update batcode record
    end;

    nVal := 0;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if (FType = sFlag_Dai) and
         (nBills[nInt].FPModel <> sFlag_PoundCC) then //����ģʽ������
      begin

      end;

      if nIdx < High(nBills) then
      begin
        FMData.FValue := FPData.FValue + FValue;
        nVal := nVal + FValue;
        //�ۼƾ���

        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end else
      begin
        FMData.FValue := nMVal - nVal;
        //�ۼ����ۼƵľ���

        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end;
    end;

    FListB.Clear;
    if nBills[nInt].FPModel <> sFlag_PoundCC then //����ģʽ,ë�ز���Ч
    begin
      nSQL := 'Select L_ID From %s Where L_Card=''%s'' And L_MValue Is Null';
      nSQL := Format(nSQL, [sTable_Bill, nBills[nInt].FCard]);
      //δ��ë�ؼ�¼

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        First;

        while not Eof do
        begin
          FListB.Add(Fields[0].AsString);
          Next;
        end;
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      i := FListB.IndexOf(FID);
      if i >= 0 then
        FListB.Delete(i);
      //�ų����γ���

      {$IFDEF ZZZC}
      if FYSValid = sFlag_Yes then
      begin
        nSQL := MakeSQLByStr([SF('L_Value', 0, sfVal),
                SF('L_Status', sFlag_TruckBFM),
                SF('L_Price', 0, sfVal),
                SF('L_NextStatus', sFlag_TruckOut),

                SF('L_MValue', FMData.FValue , sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser)
                ], sTable_Bill, SF('L_ID', FID), False);
        WriteLog('�ճ�����ģʽSQL:' + nSQL);
      end
      else
      begin
        nSQL := MakeSQLByStr([SF('L_Value', FValue, sfVal),
                SF('L_Status', sFlag_TruckBFM),

                SF('L_NextStatus', sFlag_TruckOut),

                SF('L_MValue', FMData.FValue , sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser)
                ], sTable_Bill, SF('L_ID', FID), False);
      end;
      {$ELSE}
      nSQL := MakeSQLByStr([SF('L_Value', FValue, sfVal),
              SF('L_Status', sFlag_TruckBFM),

              SF('L_NextStatus', sFlag_TruckOut),

              SF('L_MValue', FMData.FValue , sfVal),
              SF('L_MDate', sField_SQLServer_Now, sfVal),
              SF('L_MMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      {$ENDIF}
      FListA.Add(nSQL);
    end;

    if FListB.Count > 0 then
    begin
      nTmp := AdjustListStrFormat2(FListB, '''', True, ',', False);
      //δ���ؽ������б�

      nStr := Format('L_ID In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('L_PValue', nMVal, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);
      //û�г�ë�ص������¼��Ƥ��,���ڱ��ε�ë��

      nStr := Format('P_Bill In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('P_PValue', nMVal, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_PStation', nBills[nInt].FMData.FStation)
              ], sTable_PoundLog, nStr, False);
      FListA.Add(nSQL);
      //û�г�ë�صĹ�����¼��Ƥ��,���ڱ��ε�ë��
    end;

    nSQL := 'Select P_ID From %s Where P_Bill=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nBills[nInt].FID]);
    //δ��ë�ؼ�¼

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //�������б�

      if nIsOtherOrder then
        nStr := FCard
      else
        nStr := '';
      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
              SF('L_NextStatus', ''),
              SF('L_Card', nStr),
              SF('L_OutFact', sField_SQLServer_Now, sfVal),
              SF('L_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL); //update bill

      if FYSValid = sFlag_Yes then
      begin
        nSQL := 'Update %s Set ' +
                'O_Freeze=O_Freeze-(%.2f) Where O_Order=''%s''';
        nSQL := Format(nSQL, [sTable_SalesOrder, FValue, FZhiKa]);
        FListA.Add(nSQL); //sale done
      end
      else
      begin
        {$IFDEF UseWXERP}
          nSQL := ' Update %s Set O_PlanRemain = O_PlanRemain-(%.2f), O_HasDone=O_HasDone+(%.2f),' +
                  ' O_Freeze=O_Freeze-(%.2f) Where O_Order=''%s''';
          nSQL := Format(nSQL, [sTable_SalesOrder, FValue, FValue, FValue, FZhiKa]);
          FListA.Add(nSQL); //sale done
        {$ELSE}
          nSQL := 'Update %s Set O_HasDone=O_HasDone+(%.2f),' +
                  'O_Freeze=O_Freeze-(%.2f) Where O_Order=''%s''';
          nSQL := Format(nSQL, [sTable_SalesOrder, FValue, FValue, FZhiKa]);
          FListA.Add(nSQL); //sale done
        {$ENDIF}
      end;

      {$IFDEF PrintHYEach}
      if (not nIsOtherOrder) or (not (FYSValid = sFlag_Yes)) then
      begin
        FListC.Values['Group'] :=sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_HYDan;
        //to get serial no

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
          raise Exception.Create(nOut.FData);
        //xxxxx

        nSQL := MakeSQLByStr([SF('H_No', nOut.FData),
                SF('H_Custom', FCusID),
                SF('H_CusName', FCusName),
                SF('H_SerialNo', FHYDan),
                SF('H_Truck', FTruck),
                SF('H_Value', FValue, sfVal),
                SF('H_Bill', FID),
                SF('H_BillDate', sField_SQLServer_Now, sfVal),
                SF('H_ReportDate', sField_SQLServer_Now, sfVal),
                //SF('H_EachTruck', sFlag_Yes),
                SF('H_Reporter', 'ZCDelivery')], sTable_StockHuaYan, '', True);
        FListA.Add(nSQL); //�Զ����ɻ��鵥
      end;
      {$ENDIF}
    end;
    if not nIsOtherOrder then
    begin
      nSQL := 'Update %s Set C_Status=''%s'' Where C_Card=''%s''';
      nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, nBills[0].FCard]);
      FListA.Add(nSQL); //update card
    end;

    nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
    //�������б�

    nSQL := 'Select T_Line,Z_Name as T_Name,T_Bill,T_PeerWeight,T_Total,' +
            'T_Normal,T_BuCha,T_HKBills From %s ' +
            ' Left Join %s On Z_ID = T_Line ' +
            'Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, sTable_ZTLines, nStr]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    begin
      SetLength(FBillLines, RecordCount);
      //init

      if RecordCount > 0 then
      begin
        nIdx := 0;
        First;

        while not Eof do
        begin
          with FBillLines[nIdx] do
          begin
            FBill    := FieldByName('T_Bill').AsString;
            FLine    := FieldByName('T_Line').AsString;
            FName    := FieldByName('T_Name').AsString;
            FPerW    := FieldByName('T_PeerWeight').AsInteger;
            FTotal   := FieldByName('T_Total').AsInteger;
            FNormal  := FieldByName('T_Normal').AsInteger;
            FBuCha   := FieldByName('T_BuCha').AsInteger;
            FHKBills := FieldByName('T_HKBills').AsString;
          end;

          Inc(nIdx);
          Next;
        end;
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nInt := -1;
      for i:=Low(FBillLines) to High(FBillLines) do
       if (Pos(FID, FBillLines[i].FHKBills) > 0) and
          (FID <> FBillLines[i].FBill) then
       begin
          nInt := i;
          Break;
       end;
      //�Ͽ�,��������

      if nInt < 0 then Continue;
      //����װ����Ϣ

      with FBillLines[nInt] do
      begin
        if FPerW < 1 then Continue;
        //������Ч

        i := Trunc(FValue * 1000 / FPerW);
        //����

        nSQL := MakeSQLByStr([SF('L_LadeLine', FLine),
                SF('L_LineName', FName),
                SF('L_DaiTotal', i, sfVal),
                SF('L_DaiNormal', i, sfVal),
                SF('L_DaiBuCha', 0, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //����װ����Ϣ

        FTotal := FTotal - i;
        FNormal := FNormal - i;
        //�ۼ��Ͽ�������װ����
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nInt := -1;
      for i:=Low(FBillLines) to High(FBillLines) do
       if FID = FBillLines[i].FBill then
       begin
          nInt := i;
          Break;
       end;
      //�Ͽ�����

      if nInt < 0 then Continue;
      //����װ����Ϣ

      with FBillLines[nInt] do
      begin
        nSQL := MakeSQLByStr([SF('L_LadeLine', FLine),
                SF('L_LineName', FName),
                SF('L_DaiTotal', FTotal, sfVal),
                SF('L_DaiNormal', FNormal, sfVal),
                SF('L_DaiBuCha', FBuCha, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //����װ����Ϣ
      end;
    end;

    nSQL := 'Delete From %s Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, nStr]);
    FListA.Add(nSQL); //����װ������

    {$IFNDEF UseWXERP}
      {$IFDEF SyncDataByWSDL}
      for nIdx:=Low(nBills) to High(nBills) do
      with nBills[nIdx] do
      begin
        nSQL := MakeSQLByStr([
              SF('H_ID'   , FID),
              SF('H_Order' , FZhiKa),
              SF('H_Status' , '1'),
              SF('H_BillType'   , sFlag_Sale)
              ], sTable_HHJYSync, '', True);
        FListA.Add(nSQL);
      end;
      {$ENDIF}
    {$ELSE}
      for nIdx:=Low(nBills) to High(nBills) do
      with nBills[nIdx] do
      begin
        nSQL := MakeSQLByStr([
              SF('H_ID'   , FID),
              SF('H_Order' , FZhiKa),
              SF('H_Status' , '1'),
              SF('H_BillType'  , sFlag_Sale),
              SF('H_PurType'   , sFlag_Sale)
              ], sTable_HHJYSync, '', True);
        FListA.Add(nSQL);
      end;
    {$ENDIF}
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;

  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    if nIsOtherOrder then
    begin
      nSQL := 'update %s set p_orderBak=P_Bill, P_Bill=null where P_Bill=''%s''';
      nSQL := format(nSQL,[sTable_PoundLog,nBills[0].FID]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    if Assigned(gHardShareData) then
    begin
      nSQL := 'Select D_Value From %s Where D_Name=''AutoOutStock'' and D_Value=''%s''';
      nSQL := Format(nSQL, [sTable_SysDict, nBills[0].FStockNo]);

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        gHardShareData('TruckOut:' + nBills[0].FCard);
        //���������Զ�����
        WriteLog('���������Զ�����');
      end;
    end;
    //���������Զ�����
  end;

  if FIn.FExtParam = sFlag_TruckOut then//��ʱ�����������¶���
  begin
    with nBills[0] do
    begin
      if nIsOtherOrder then
      begin
        nSQL := 'Select O_PlanAmount, O_HasDone From %s Where O_Order=''%s''';
        nSQL := Format(nSQL, [sTable_SalesOrder, FZhiKa]);

        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        if RecordCount > 0 then
        begin
          nVal := Fields[0].AsFloat - Fields[1].AsFloat;
        end;
        nSQL := 'Update %s Set O_PlanDone=O_HasDone,' +
                'O_PlanRemain=''%s'' Where O_Order=''%s''';
        nSQL := Format(nSQL, [sTable_SalesOrder, FloatToStr(nVal), FZhiKa]);
        gDBConnManager.WorkerExec(FDBConn, nSQL);
      end;
    end;
  end;

  {$IFDEF SyncDataByDataBase}
  if FIn.FExtParam = sFlag_TruckOut then //�����ϴ���ϸ
  begin
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if nIsOtherOrder then//��ʱ�������ϴ�
        Continue;
      if FYSValid = sFlag_Yes then//�ճ��������ϴ�
        Continue;
      if not TWorkerBusinessCommander.CallMe(cBC_SyncHhSaleDetail,
              FID, '', @nOut) then
      begin
        nStr := '�����������[ %s ]�ϴ�ʧ��.';
        nStr := Format(nStr, [FID]);
        WriteLog(nStr);
      end;
    end;
  end;
  {$ENDIF}
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessBills, sPlug_ModuleBus);
end.
