{*******************************************************************************
  ����: juner11212436@163.com 2018-10-25
  ����: ��Ӿ�Զ���ҵ������ݴ���
*******************************************************************************}
unit UWorkerBussinessHHJY;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, DB, ADODB, NativeXml, UBusinessWorker,
  UBusinessPacker, UBusinessConst, UMgrDBConn, UMgrParam, UFormCtrl, USysLoger,
  ZnMD5, ULibFun, USysDB, UMITConst, UMgrChannel, UWorkerBusiness,IdHTTP,Graphics,
  Variants, uLkJSON,DateUtils, V_Sys_Materiel_Intf, T_Sys_SaleCustomer_Intf,
  T_SupplyProvider_Intf, V_SaleConsignPlanBill_Intf, V_SaleValidConsignPlanBill_Intf,
  T_SaleConsignBill_Intf, V_QControlWareNumberNoticeBill_Intf,
  T_SaleTransportForCustomer_Intf, V_SupplyMaterialEntryPlan_Intf,
  T_SupplyMaterialReceiveBill_Intf, V_SupplyMaterialTransferPlan_Intf, uSuperObject,
  T_SupplyMaterialTransferBill_Intf, T_SupplyWeighBill_Intf, T_SaleScheduleVan_Intf,
  MsMultiPartFormData,V_QChemistryTestBill_Intf, V_QPhysicsRecord_Intf, V_QPhysicsWRONCRecord_Intf,
  V_QPhysicsSettingTimeRecord_Intf,V_QPhysicsFinenessRecord_Intf,
  V_QPhysicsSpecificSurfaceAreaRecord_Intf,V_QPhysicsIntensityRecord_Intf,
  QAdmixtureDataBrief_WS_Intf,QAdmixtureDataDetail_WS_Intf;

const
  cHttpTimeOut          = 10;
  
type
  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //������
    FDBConn: PDBWorker;
    //����ͨ��
    FDataIn,FDataOut: PBWDataBase;
    //��γ���
    FDataOutNeedUnPack: Boolean;
    //��Ҫ���
    FPackOut: Boolean;
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //�������
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //��֤���
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //����ҵ��
  public
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
    procedure WriteLog(const nEvent: string);
    //��¼��־
  end;

  TBusWorkerBusinessHHJY = class(TMITDBWorker)
  private
    FListA,FListB,FListC,FListD,FListE,FListF: TStrings;
    //list
    FIn: TWorkerHHJYData;
    FOut: TWorkerHHJYData;
    //in out
    {$IFDEF UseWXERP}
    FIdHttp : TIdHTTP;
    FUrl    : string;
    Ftoken  : string;
    {$ENDIF}
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function SyncHhSaleMateriel(var nData:string):boolean;
    //ͬ����������
    function SyncHhCustomer(var nData:string):boolean;
    //ͬ�����ۿͻ�
    function SyncHhProvider(var nData:string):boolean;
    //ͬ����Ӧ��
    function SyncHhSalePlan(var nData:string):boolean;
    //ͬ�����ۼƻ�
    function PoundVerifyHhSalePlan(var nData:string):boolean;
    //���ۼƻ�����У��
    function BillVerifyHhSalePlan(var nData:string):boolean;
    //���ۼƻ�����У��
    function SyncHhSaleDetail(var nData: string): Boolean;
    //ͬ�����۷�����ϸ
    function IsHhSaleDetailExits(var nData: string): Boolean;
    //��ѯ���۷�����ϸ
    function GetHhSaleDetailID(var nData: string): Boolean;
    //��ȡ�������۷�����ϸID
    function GetHhSaleWareNumber(var nData: string): Boolean;
    //��ȡ���κ�
    function GetHhSaleWTTruck(var nData: string): Boolean;
    //��ȡ�ɳ���
    function SyncHhSaleWareNumber(var nData: string): Boolean;
    //ͬ�����κ�
    function GetHhSaleRealPrice(var nData: string): Boolean;
    //��ȡ���¼۸�
    function GetSaleDetailJSonString(const nLID, nDelete: string; var nExits: Boolean;
                                     var nInit: string; var nNewStr: string): string;
    function GetMoney(const nPrice, nValue: string) : string;
    //������
    function SyncHhOrderPlan(var nData: string): Boolean;
    //��ȡ��ͨԭ���Ͻ����ƻ�
    function SyncHhOrderDetail(var nData: string): Boolean;
    //ͬ����ͨԭ�����ջ���ϸ
    function IsHhOrderDetailExits(var nData: string): Boolean;
    //��ѯ��ͨԭ�����ջ���ϸ
    function GetHhOrderDetailID(var nData: string): Boolean;
    //��ȡ������ͨԭ�����ջ���ϸID
    function GetOrderDetailJSonString(const nLID, nDelete: string; var nExits: Boolean;
                                     var nInit: string; var nNewStr: string): string;
    //��ȡ��ͨԭ���ϲɹ����ϴ���ϸ����
    function SyncHhNdOrderPlan(var nData: string): Boolean;
    //��ȡ�ڵ�ԭ���Ͻ����ƻ�
    function SyncHhNdOrderDetail(var nData: string): Boolean;
    //ͬ���ڵ�ԭ�����ջ���ϸ
    function IsHhNdOrderDetailExits(var nData: string): Boolean;
    //��ѯ�ڵ�ԭ�����ջ���ϸ
    function GetHhNdOrderDetailID(var nData: string): Boolean;
    //��ȡ�����ڵ�ԭ�����ջ���ϸID
    function GetNdOrderDetailJSonString(const nLID, nDelete: string; var nExits: Boolean;
                                     var nInit: string; var nNewStr: string): string;
    //��ȡ�ڵ�ԭ���ϲɹ����ϴ���ϸ����
    function SyncHhOtherOrderDetail(var nData: string): Boolean;
    //ͬ���ڵ�ԭ�����ջ���ϸ
    function IsHhOtherOrderDetailExits(var nData: string): Boolean;
    //��ѯ�ڵ�ԭ�����ջ���ϸ
    function GetHhOtherOrderDetailID(var nData: string): Boolean;
    //��ȡ�����ڵ�ԭ�����ջ���ϸID
    function GetOtherOrderDetailJSonString(const nLID, nDelete: string; var nExits: Boolean;
                                     var nInit: string; var nNewStr: string): string;
    //��ȡ�ڵ�ԭ���ϲɹ����ϴ���ϸ����
    function NewHhWTDetail(var nData: string): Boolean;
    //�����ɳ�����ϸ�������ɳ���ID
    function SaveHhHYData(var nData: string): Boolean;
    //��ȡ�����滯�鵥����
    function GetHhHYHxDetail(var nData: string): Boolean;
    //��ȡ���鵥��ѧ��������
    function GetHhHYWlDetail(var nData: string): Boolean;
    //��ȡ���鵥�����������
    function GetHhHYWlBZCD(var nData: string): Boolean;
    //��ȡ���鵥����������ݱ�׼�����ˮ��
    function GetHhHYWlNjTime(var nData: string): Boolean;
    //��ȡ���鵥���������������ʱ��
    function GetHhHYWlXD(var nData: string): Boolean;
    //��ȡ���鵥�����������ϸ��
    function GetHhHYWlBiBiao(var nData: string): Boolean;
    //��ȡ���鵥����������ݱȱ����
    function GetHhHYWlQD(var nData: string): Boolean;
    //��ȡ���鵥�����������ǿ��
    function GetHhHYHhcDetail(var nData: string): Boolean;
    //��ȡ���鵥��ϲ�
    function GetHhHYHhcRecord(var nData: string): Boolean;
    //��ȡ���鵥��ϲ���ϸ
    {$IFDEF UseWXERP}
    //��¼�ӿ�
    function UnicodeToChinese(inputstr: string): string;
    function GetLoginToken(var nData: string): Boolean;
    function GetDepotInfo(var nData: string): Boolean;
    function GetUserInfo(var nData: string): Boolean;
    function GetCusProInfo(var nData: string): Boolean;
    function GetStockType(var nData: string): Boolean;
    function GetStockInfo(var nData: string): Boolean;
    function GetOrderInfo(var nData: string): Boolean;
    function GetOrderInfoEx(var nData: string): Boolean;
    function SynWxOrderPound(var nData: string): Boolean;
    function GetSaleInfo(var nData: string): Boolean;
    function GetSaleInfo_One(var nData: string): Boolean;
    function SynWxSalePound(var nData: string): Boolean;
    function GetHYInfo(var nData: string): Boolean;
    function SynWxPoundKW(var nData: string): Boolean;
    function SynOrderTruckNum(var nData: string): Boolean;
    function SynSaleTruckNum(var nData: string): Boolean;
    {$ENDIF}
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation

//Date: 2012-3-13
//Parm: ���������
//Desc: ��ȡ�������ݿ��������Դ
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '�������ݿ�ʧ��(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: '+FunctionName+' InData:'+ FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then Exit;
    //invalid input parameter

    FPacker.InitData(FDataOut, False, True, False);
    //init exclude base
    FDataOut^ := FDataIn^;

    Result := DoDBWork(nData);
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(nData, FDataOut);
      //xxxxx

      Result := DoAfterDBWork(nData, True);
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      if FPackOut then
      begin
        WriteLog('���');
        nData := FPacker.PackOut(FDataOut);
      end;

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Date: 2012-3-22
//Parm: �������;���
//Desc: ����ҵ��ִ����Ϻ����β����
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: �������
//Desc: ��֤��������Ƿ���Ч
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: ��¼nEvent��־
procedure TMITDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMITDBWorker, FunctionName, nEvent);
end;

//------------------------------------------------------------------------------
class function TBusWorkerBusinessHHJY.FunctionName: string;
begin
  Result := sBus_BusinessHHJY;
end;

constructor TBusWorkerBusinessHHJY.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListD := TStringList.Create;
  FListE := TStringList.Create;
  FListF := TStringList.Create;
  {$IFDEF UseWXERP}
  FidHttp := TIdHTTP.Create(nil);
  FidHttp.ConnectTimeout := cHttpTimeOut * 1000;
  FidHttp.ReadTimeout := cHttpTimeOut * 1000;
  {$ENDIF}
  inherited;
end;

destructor TBusWorkerBusinessHHJY.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  FreeAndNil(FListD);
  FreeAndNil(FListE);
  FreeAndNil(FListF);
  {$IFDEF UseWXERP}
  FreeAndNil(FidHttp);
  {$ENDIF}
  inherited;
end;

function TBusWorkerBusinessHHJY.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessHHJY;
  end;
end;

procedure TBusWorkerBusinessHHJY.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TBusWorkerBusinessHHJY.CallMe(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerHHJYData;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand  := nCmd;
    nIn.FData     := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessHHJY);
    nPacker.InitData(@nIn, True, False);
    //init

    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessHHJY);
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

//Date: 2012-3-22
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TBusWorkerBusinessHHJY.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;
  FPackOut := True;

//  case FIn.FCommand of
//   cBC_SyncHhSaleDetail        : FPackOut := False;
//  end;

  case FIn.FCommand of
   cBC_SyncHhSaleMateriel      : Result := SyncHhSaleMateriel(nData);
   cBC_SyncHhCustomer          : Result := SyncHhCustomer(nData);
   cBC_SyncHhProvider          : Result := SyncHhProvider(nData);
   cBC_GetHhSalePlan           : Result := SyncHhSalePlan(nData);
   cBC_PoundVerifyHhSalePlan   : Result := PoundVerifyHhSalePlan(nData);
   cBC_BillVerifyHhSalePlan    : Result := BillVerifyHhSalePlan(nData);
   cBC_SyncHhSaleDetail        : Result := SyncHhSaleDetail(nData);
   cBC_IsHhSaleDetailExits     : Result := IsHhSaleDetailExits(nData);
   cBC_GetHhSaleDetailID       : Result := GetHhSaleDetailID(nData);
   cBC_GetHhSaleWareNumber     : Result := GetHhSaleWareNumber(nData);
   cBC_SyncHhSaleWTTruck       : Result := GetHhSaleWTTruck(nData);
   cBC_SyncHhSaleWareNumber    : Result := SyncHhSaleWareNumber(nData);
   cBC_GetHhSaleRealPrice      : Result := GetHhSaleRealPrice(nData);

   cBC_GetHhOrderPlan          : Result := SyncHhOrderPlan(nData);
   cBC_SyncHhOrderPoundData    : Result := SyncHhOrderDetail(nData);
   cBC_IsHhOrderDetailExits    : Result := IsHhOrderDetailExits(nData);
   cBC_GetHhOrderDetailID      : Result := GetHhOrderDetailID(nData);

   cBC_GetHhNeiDaoOrderPlan    : Result := SyncHhNdOrderPlan(nData);
   cBC_SyncHhNdOrderPoundData  : Result := SyncHhNdOrderDetail(nData);
   cBC_IsHhNdOrderDetailExits  : Result := IsHhNdOrderDetailExits(nData);
   cBC_GetHhNdOrderDetailID    : Result := GetHhNdOrderDetailID(nData);

   cBC_SyncHhOtOrderPoundData  : Result := SyncHhOtherOrderDetail(nData);
   cBC_IsHhOtherOrderDetailExits: Result := IsHhOtherOrderDetailExits(nData);
   cBC_GetHhOtherOrderDetailID : Result := GetHhOtherOrderDetailID(nData);

   cBC_NewHhWTDetail           : Result := NewHhWTDetail(nData);

   cBC_SaveHhHyData            : Result := SaveHhHYData(nData);
   cBC_GetHhHyHxDetail         : Result := GetHhHYHxDetail(nData);

   cBC_GetHhHyWlDetail         : Result := GetHhHYWlDetail(nData);
   cBC_GetHhHyWlBZCD           : Result := GetHhHYWlBZCD(nData);
   cBC_GetHhHyWlNjTime         : Result := GetHhHYWlNjTime(nData);
   cBC_GetHhHyWlXD             : Result := GetHhHyWlXD(nData);
   cBC_GetHhHyWlBiBiao         : Result := GetHhHyWlBiBiao(nData);
   cBC_GetHhHyWlQD             : Result := GetHhHyWlQD(nData);

   cBC_GetHhHyHhcDetail        : Result := GetHhHyHhcDetail(nData);
   cBC_GetHhHyHhcRecord        : Result := GetHhHyHhcRecord(nData);
   {$IFDEF UseWXERP}
   cBC_GetLoginToken           : Result := GetLoginToken(nData);
   cBC_GetDepotInfo            : Result := GetDepotInfo(nData);
   cBC_GetUserInfo             : Result := GetUserInfo(nData);
   cBC_GetCusProInfo           : Result := GetCusProInfo(nData);
   cBC_GetStockType            : Result := GetStockType(nData);
   cBC_GetStockInfo            : Result := GetStockInfo(nData);
   cBC_GetOrderInfo            : Result := GetOrderInfo(nData);
   cBC_GetOrderInfoEx          : Result := GetOrderInfoEx(nData);
   cBC_GetOrderPound           : Result := SynWxOrderPound(nData);
   cBC_GetSaleInfo             : Result := GetSaleInfo(nData);
   cBC_GetSalePound            : Result := SynWxSalePound(nData);
   cBC_GetHYInfo               : Result := GetHYInfo(nData);
   cBC_GetPoundKW              : Result := SynWxPoundKW(nData);
   cBC_GetOrderTruckNum        : Result := SynOrderTruckNum(nData);
   cBC_GetSaleTruckNum         : Result := SynSaleTruckNum(nData);
   cBC_GetSaleInfoOne          : Result := GetSaleInfo_One(nData);
   {$ENDIF}
  else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Code: %d Invalid Command).';
      nData := Format(nData, [FIn.FCommand]);
    end;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhSaleMateriel(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  nStr := PackerDecodeStr(FIn.FData);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        if nStr = '' then
          nStr := FDefWhere
        else
        if FDefWhere <> '' then
          nStr := nStr + ' And ' + FDefWhere;
        Break;
      end;
    end;
    WriteLog('ͬ���������'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_Sys_Materiel.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel

    
    nStr := IV_Sys_Materiel(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                            nStr, '');


    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := 'ͬ�����Ͻӿڵ����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    FListB.Clear;
    FListC.Clear;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := 'ͬ�����Ͻӿڵ����쳣.' + FIn.FData + 'Data�ڵ�Ϊ��';
        WriteLog(nData);
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        FListA.Clear;
        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;

        if (Pos('ˮ��',FListA.Values['FMaterielTypeName']) > 0) then
        begin
          nStr := SF('D_Name', 'StockItem')+' and '+SF('D_Memo', 'D')+
                  ' and '+SF('D_ParamB', FListA.Values['FMaterielID']+'D');
          nStr := MakeSQLByStr([SF('D_Value',
                  FListA.Values['FMaterielName'] + FListA.Values['FModel'] + '��װ')
                  ], sTable_SysDict, nStr, False);
          //xxxxx
          FListB.Add(nStr);

          nStr := SF('D_Name', 'StockItem')+' and '+SF('D_Memo', 'S')+
                  ' and '+SF('D_ParamB', FListA.Values['FMaterielID']+'S');
          nStr := MakeSQLByStr([SF('D_Value',
                  FListA.Values['FMaterielName'] + FListA.Values['FModel'] + 'ɢװ')
                  ], sTable_SysDict, nStr, False);
          //xxxxx
          FListB.Add(nStr);

          nStr := MakeSQLByStr([SF('D_Name', 'StockItem'),
                  SF('D_ParamB', FListA.Values['FMaterielID']+'D'),
                  SF('D_Value', FListA.Values['FMaterielName'] + FListA.Values['FModel'] + '��װ'),
                  SF('D_Memo', 'D')
                  ], sTable_SysDict, '', True);
          //xxxxx
          FListC.Add(nStr);

          nStr := MakeSQLByStr([SF('D_Name', 'StockItem'),
                  SF('D_ParamB', FListA.Values['FMaterielID']+'S'),
                  SF('D_Value', FListA.Values['FMaterielName'] + FListA.Values['FModel'] + 'ɢװ'),
                  SF('D_Memo', 'S')
                  ], sTable_SysDict, '', True);
          //xxxxx
          FListC.Add(nStr);
        end
        else
        begin
          nStr := SF('D_Name', 'StockItem')+' and '+SF('D_Memo', 'S')+
                  ' and '+SF('D_ParamB', FListA.Values['FMaterielID']);
          nStr := MakeSQLByStr([SF('D_Value',
                  FListA.Values['FMaterielName'] + FListA.Values['FModel'])
                  ], sTable_SysDict, nStr, False);
          //xxxxx
          FListB.Add(nStr);

          nStr := MakeSQLByStr([SF('D_Name', 'StockItem'),
                  SF('D_ParamB', FListA.Values['FMaterielID']),
                  SF('D_Value', FListA.Values['FMaterielName'] + FListA.Values['FModel']),
                  SF('D_Memo', 'S')
                  ], sTable_SysDict, '', True);
          //xxxxx
          FListC.Add(nStr);
        end;
      end;
    end
    else
    begin
      nData := '�ӿڵ����쳣.Data�ڵ��쳣';
      WriteLog(nData);
      Exit;
    end;

    if FListB.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;

      for nIdx:=0 to FListB.Count - 1 do
      begin
        if gDBConnManager.WorkerExec(FDBConn,FListB[nIdx]) <= 0 then
        begin
          gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhCustomer(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  nStr := PackerDecodeStr(FIn.FData);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        if nStr = '' then
          nStr := FDefWhere
        else
        if FDefWhere <> '' then
          nStr := nStr + ' And ' + FDefWhere;
        Break;
      end;
    end;
    WriteLog('ͬ�����ۿͻ����'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;
      FChannel := CoT_SaleCustomer.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel

    
    nStr := IT_SaleCustomer(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                            nStr, '');


    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := 'ͬ�����ۿͻ��ӿڵ����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    FListB.Clear;
    FListC.Clear;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := 'ͬ�����ۿͻ��ӿڵ����쳣.' + FIn.FData + 'Data�ڵ�Ϊ��';
        WriteLog(nData);
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        FListA.Clear;
        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;

        nStr := SF('C_ID', FListA.Values['FCustomerID']);
        nStr := MakeSQLByStr([
                SF('C_Name', FListA.Values['FCustomerName']),
                SF('C_PY', GetPinYinOfStr(FListA.Values['FCustomerName'])),
                SF('C_Addr', FListA.Values['FAddress']),
                SF('C_Phone', FListA.Values['FOfficeTelCode']),
                SF('C_Tax', FListA.Values['FFaxCode']),
                SF('C_Bank', FListA.Values['FBankNames']),
                SF('C_Memo', FListA.Values['FCustomerCode']),
                SF('C_Account', FListA.Values['FIDcardnumber'])
                ], sTable_Customer, nStr, False);
        FListB.Add(nStr);

        nStr := MakeSQLByStr([SF('C_ID', FListA.Values['FCustomerID']),
                SF('C_Name', FListA.Values['FCustomerName']),
                SF('C_PY', GetPinYinOfStr(FListA.Values['FCustomerName'])),
                SF('C_Addr', FListA.Values['FAddress']),
                SF('C_Phone', FListA.Values['FOfficeTelCode']),
                SF('C_Tax', FListA.Values['FFaxCode']),
                SF('C_Bank', FListA.Values['FBankNames']),
                SF('C_Account', FListA.Values['FIDcardnumber']),
                SF('C_Memo', FListA.Values['FCustomerCode']),
                SF('C_XuNi', sFlag_No)
                ], sTable_Customer, '', True);
        FListC.Add(nStr);
      end;
    end
    else
    begin
      nData := '�ӿڵ����쳣.Data�ڵ��쳣';
      WriteLog(nData);
      Exit;
    end;

    if FListB.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;

      for nIdx:=0 to FListB.Count - 1 do
      begin
        if gDBConnManager.WorkerExec(FDBConn,FListB[nIdx]) <= 0 then
        begin
          gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhProvider(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  nStr := PackerDecodeStr(FIn.FData);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        if nStr = '' then
          nStr := FDefWhere
        else
        if FDefWhere <> '' then
          nStr := nStr + ' And ' + FDefWhere;
        Break;
      end;
    end;
    WriteLog('ͬ����Ӧ�����'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyProvider.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel

    
    nStr := IT_SupplyProvider(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                            nStr, '');

    WriteLog('ͬ����Ӧ�̳���'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := 'ͬ����Ӧ�̽ӿڵ����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    FListB.Clear;
    FListC.Clear;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := 'ͬ����Ӧ�̽ӿڵ����쳣.' + FIn.FData + 'Data�ڵ�Ϊ��';
        WriteLog(nData);
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        FListA.Clear;
        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;

        nStr := SF('P_ID', FListA.Values['FProviderID']);
        nStr := MakeSQLByStr([
                SF('P_Name', FListA.Values['FProviderName']),
                SF('P_Memo', FListA.Values['FProviderNumber']),
                SF('P_PY', GetPinYinOfStr(FListA.Values['FProviderName']))
                ], sTable_Provider, nStr, False);
        FListB.Add(nStr);

        nStr := MakeSQLByStr([SF('P_ID', FListA.Values['FProviderID']),
                SF('P_Name', FListA.Values['FProviderName']),
                SF('P_Memo', FListA.Values['FProviderNumber']),
                SF('P_PY', GetPinYinOfStr(FListA.Values['FProviderName']))
                ], sTable_Provider, '', True);
        FListC.Add(nStr);
      end;
    end
    else
    begin
      nData := '��Ӧ�̽ӿڵ����쳣.Data�ڵ��쳣';
      WriteLog(nData);
      Exit;
    end;

    if FListB.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;

      for nIdx:=0 to FListB.Count - 1 do
      begin
        if gDBConnManager.WorkerExec(FDBConn,FListB[nIdx]) <= 0 then
        begin
          gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhSalePlan(
  var nData: string): boolean;
var nStr, nUrl, nPreFix, nFactory: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  nStr := PackerDecodeStr(FIn.FData);
  nFactory := PackerDecodeStr(FIn.FExtParam);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        if nStr = '' then
          nStr := FDefWhere
        else
        if FDefWhere <> '' then
          nStr := nStr + ' And ' + FDefWhere;
        Break;
      end;
    end;

    WriteLog('��ȡ���۶������'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

        FChannel := CoV_SaleConsignPlanBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel

    
    nStr := IV_SaleConsignPlanBill(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                            nStr, '');

    if Pos('FBillCode', PackerDecodeStr(FIn.FData)) > 0 then
      WriteLog('��ȡ���۶�������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ���۶����ӿڵ����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    FListB.Clear;
    FListC.Clear;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡ���۶����ӿڵ����쳣.' + FIn.FData + 'Data�ڵ�Ϊ��';
        WriteLog(nData);
        Exit;
      end;

      if Pos('FBillCode', PackerDecodeStr(FIn.FData)) > 0 then
      begin
        for nIdx := 0 to nJSRow.Count - 1 do
        begin
          nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

          FListE.Clear;
          for nInt := 0 to nJSCol.Count - 1 do
          begin
            FListE.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
          end;
          nData := PackerEncodeStr(FListE.Text);
        end;
      end
      else
      begin
        nPreFix := 'WY';
        nStr := 'Select B_Prefix From %s ' +
                'Where B_Group=''%s'' And B_Object=''%s''';
        nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        if RecordCount > 0 then
        begin
          nPreFix := Fields[0].AsString;
        end;

//        if nFactory ='' then
//        begin
//          nStr := 'Update %s Set O_Valid = ''%s'' where O_Order not like''%%%s%%''';
//          nStr := Format(nStr, [sTable_SalesOrder, sFlag_No, nPreFix]);
//          gDBConnManager.WorkerExec(FDBConn, nStr);
//        end else
//        begin
//          nStr := 'Update %s Set O_Valid = ''%s'' Where O_Factory=''%s'' and O_Order not like''%%%s%%''';
//          nStr := Format(nStr, [sTable_SalesOrder, sFlag_No, nFactory, nPreFix]);
//          gDBConnManager.WorkerExec(FDBConn, nStr);
//        end;

        for nIdx := 0 to nJSRow.Count - 1 do
        begin
          nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

          FListA.Clear;
          for nInt := 0 to nJSCol.Count - 1 do
          begin
            FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
          end;

          if FListA.Values['FStatus'] = '1' then
            FListA.Values['FStatus'] := sFlag_Yes
          else
            FListA.Values['FStatus'] := sFlag_No;

          nStr := SF('O_Order', FListA.Values['FBillCode']);
          nStr := MakeSQLByStr([
                  SF('O_Factory', FListA.Values['FFactoryName']),
                  SF('O_CusName', FListA.Values['FCustomerName']),
                  SF('O_ConsignCusName', FListA.Values['FConsignName']),
                  SF('O_StockName', FListA.Values['FMaterielName']),
                  SF('O_StockType', FListA.Values['FPacking']),
                  SF('O_Lading', FListA.Values['FDelivery']),
                  SF('O_CusPY', GetPinYinOfStr(FListA.Values['FCustomerName'])),
                  SF('O_PlanAmount', FListA.Values['FPlanAmount']),
                  SF('O_PlanDone', FListA.Values['FBillAmount']),
                  SF('O_PlanRemain', FListA.Values['FRemainAmount']),
                  SF('O_PlanBegin', StrToDateDef(FListA.Values['FBeginDate'],Now),sfDateTime),
                  SF('O_PlanEnd', StrToDateDef(FListA.Values['FEndDate'],Now),sfDateTime),
                  SF('O_Company', FListA.Values['FCompanyName']),
                  SF('O_Depart', FListA.Values['FSaleOrgName']),
                  SF('O_SaleMan', FListA.Values['FSaleManID']),
                  SF('O_Remark', FListA.Values['FRemark']),
                  SF('O_Price', StrToFloatDef(FListA.Values['FGoodsPrice'],0),sfVal),
                  SF('O_Valid', FListA.Values['FStatus']),
                  SF('O_CompanyID', FListA.Values['FCompanyID']),
                  SF('O_CusID', FListA.Values['FCustomerID']),
                  SF('O_StockID', FListA.Values['FMaterielID']),
                  SF('O_PackingID', FListA.Values['FPackingID']),
                  SF('O_FactoryID', FListA.Values['FFactoryID']),
                  SF('O_Create', StrToDateDef(FListA.Values['FCreateTime'],Now),sfDateTime),
                  SF('O_Modify', StrToDateDef(FListA.Values['FModifyTime'],Now),sfDateTime)
                  ], sTable_SalesOrder, nStr, False);
          FListB.Add(nStr);

          nStr := MakeSQLByStr([SF('O_Order', FListA.Values['FBillCode']),
                  SF('O_Factory', FListA.Values['FFactoryName']),
                  SF('O_CusName', FListA.Values['FCustomerName']),
                  SF('O_ConsignCusName', FListA.Values['FConsignName']),
                  SF('O_StockName', FListA.Values['FMaterielName']),
                  SF('O_StockType', FListA.Values['FPacking']),
                  SF('O_Lading', FListA.Values['FDelivery']),
                  SF('O_CusPY', GetPinYinOfStr(FListA.Values['FCustomerName'])),
                  SF('O_PlanAmount', FListA.Values['FPlanAmount']),
                  SF('O_PlanDone', FListA.Values['FBillAmount']),
                  SF('O_PlanRemain', FListA.Values['FRemainAmount']),
                  SF('O_PlanBegin', StrToDateDef(FListA.Values['FBeginDate'],Now),sfDateTime),
                  SF('O_PlanEnd', StrToDateDef(FListA.Values['FEndDate'],Now),sfDateTime),
                  SF('O_Company', FListA.Values['FCompanyName']),
                  SF('O_Depart', FListA.Values['FSaleOrgName']),
                  SF('O_SaleMan', FListA.Values['FSaleManID']),
                  SF('O_Remark', FListA.Values['FRemark']),
                  SF('O_Price', StrToFloatDef(FListA.Values['FGoodsPrice'],0),sfVal),
                  SF('O_Valid', FListA.Values['FStatus']),
                  SF('O_Freeze', 0, sfVal),
                  SF('O_HasDone', 0, sfVal),
                  SF('O_CompanyID', FListA.Values['FCompanyID']),
                  SF('O_CusID', FListA.Values['FCustomerID']),
                  SF('O_StockID', FListA.Values['FMaterielID']),
                  SF('O_PackingID', FListA.Values['FPackingID']),
                  SF('O_FactoryID', FListA.Values['FFactoryID']),
                  SF('O_Create', StrToDateDef(FListA.Values['FCreateTime'],Now),sfDateTime),
                  SF('O_Modify', StrToDateDef(FListA.Values['FModifyTime'],Now),sfDateTime)
                  ], sTable_SalesOrder, '', True);
          FListC.Add(nStr);
        end;

        if FListB.Count > 0 then
        try
          FDBConn.FConn.BeginTrans;

          for nIdx:=0 to FListB.Count - 1 do
          begin
            if gDBConnManager.WorkerExec(FDBConn,FListB[nIdx]) <= 0 then
            begin
              gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
            end;
          end;
          FDBConn.FConn.CommitTrans;
        except
          if FDBConn.FConn.InTransaction then
            FDBConn.FConn.RollbackTrans;
          raise;
        end;
      end;
    end
    else
    begin
      nData := '��ȡ���۶����ӿڵ����쳣.Data�ڵ��쳣';
      WriteLog(nData);
      Exit;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.PoundVerifyHhSalePlan(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nUrl := '';

  FListD.Clear;
  FListD.Text := PackerDecodeStr(FIn.FData);

  nStr := 'FBillCode = ''%s''';
  nStr := Format(nStr, [FListD.Values['FConsignPlanNumber']]);

  if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhSalePlan
           ,PackerEncodeStr(nStr),'',@nOut) then
  begin
    nData := '�������[ %s ]��ȡ��ǰ����[ %s ]��Ϣʧ��.';
    nData := Format(nData, [FListD.Values['FBillNumber'],
                             FListD.Values['FConsignPlanNumber']]);
    WriteLog(nData);
    Exit;
  end;
  FListB.Clear;
  FListB.Text := PackerDecodeStr(nOut.FData);

  if FListD.Values['FPriceDate'] = '' then
    FListD.Values['FPriceDate'] := FormatDateTime('YYYY-MM-DD HH:MM:SS', Now);

  FListB.Values['FPriceDate'] := FListD.Values['FPriceDate'];

  WriteLog('�ͻ�����:' + FListB.Values['FCustomerTypeID']);

  if FListB.Values['FCustomerTypeID'] = '1' then
  begin
    if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhSaleRealPrice
             ,PackerEncodeStr(FListB.Text),'',@nOut) then
    begin
      nData := '�������[ %s ]��ȡʵʱ�۸�ʧ��.';
      nData := Format(nData, [FListD.Values['FBillNumber']]);
      WriteLog(nData);
      Exit;
    end;

    FListB.Clear;
    FListB.Text := PackerDecodeStr(nOut.FData);

    nStr := '�������[ %s ]ԭʼ�۸�[ %s ]���¼۸�[ %s ]�����[ %s ]';
    nStr := Format(nStr, [FListD.Values['FBillNumber'],
                          FListD.Values['FGoodsPrice'],
                          FListB.Values['FGoodsPrice'],
                          FListD.Values['FPoundValue']]);

    WriteLog(nStr);
                          
    if not IsNumber(FListB.Values['FGoodsPrice'], True) then
    begin
      nData := '�������[ %s ]ʵʱ�۸�Ƿ�����.';
      nData := Format(nData, [FListD.Values['FBillNumber']]);
      WriteLog(nData);
      Exit;
    end;

    nStr :='update %s set L_Price=%s where L_ID = ''%s'' ';
    nStr := Format(nStr,[sTable_Bill, FListB.Values['FGoodsPrice'],
                                      FListD.Values['FBillNumber']]);

    gDBConnManager.WorkerExec(FDBConn,nStr);

    FListD.Values['FMoney'] := Format('%.2f', [StrToFloat(FListB.Values['FGoodsPrice'])
                                              * StrToFloat(FListD.Values['FPoundValue'])]);
  end;

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;
    nStr := '����У�����۶������:FCustomerID[ %s ],FMoney[ %s ],FBillID[ %s ],FSaleManID[ %s ]';
    nStr := Format(nStr,[FListD.Values['FCustomerID'],FListD.Values['FMoney'],
                         FListD.Values['FBillID'],FListD.Values['FSaleManID']]);
    WriteLog(nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_SaleConsignPlanBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_SaleConsignPlanBill(nHHJYChannel^.FChannel).P_SaleComputCredit(nSoapHeader,
                                   FListD.Values['FCustomerID'],
                                   FListD.Values['FMoney'],
                                   FListD.Values['FBillID'],
                                   FListD.Values['FSaleManID']);

    WriteLog('����У�����۶�������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '����У�����۶��������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if Trim(VarToStr(nJS.Field['Data'].Value)) <> '' then
    begin
      nData := '����У�����۶���ʧ��.' + VarToStr(nJS.Field['Data'].Value);
      WriteLog(nData);
      Exit;
    end;

    Result := True;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.BillVerifyHhSalePlan(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Text := PackerDecodeStr(FIn.FData);
                           //1003415304
  FListA.Values['Order'] := '1015578701';
  FListA.Values['Value'] := '10';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('����У�����۶������'+FListA.Text);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_SaleValidConsignPlanBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_SaleValidConsignPlanBill(nHHJYChannel^.FChannel).ValidConsignPlanBill(nSoapHeader,
                                   1003415304,
                                   1);

    WriteLog('����У�����۶�������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '����У�����۶��������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['Data'].Value))) <= 0 then
    begin
      nData := '����У�����۶���ʧ��.' + VarToStr(nJS.Field['Data'].Value);
      WriteLog(nData);
      Exit;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhSaleDetail(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
    nExits: Boolean;
    nInitStr, nNewStr: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nExits := False;
  nUrl := '';
  FListD.Text := PackerDecodeStr(FIn.FData);

  WriteLog('ͬ�������׼���������:' + FListD.Text);

  nStr := GetSaleDetailJSonString(FListD.Values['ID'], FListD.Values['Delete'], nExits,
                                    nInitStr, nNewStr);
  if nStr <> '' then
  begin
    nData := nStr;
    WriteLog('ͬ�������׼�����ݽ��:' + nStr);
    Exit;
  end;

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('ͬ����������'+FListD.Text);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SaleConsignBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel

    if nExits then
    begin
      nStr := IT_SaleConsignBill(nHHJYChannel^.FChannel).Update(nSoapHeader,
                                     nInitStr, nNewStr);
    end
    else
    begin
      nStr := IT_SaleConsignBill(nHHJYChannel^.FChannel).Insert(nSoapHeader,
                                     nNewStr);
    end;

    WriteLog('ͬ�����������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := 'ͬ������������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    FListA.Clear;

    nJS := TlkJSON.ParseText(nNewStr) as TlkJSONobject;

    FlistA.Values['FFactoryID'] := VarToStr(nJS.Field['FFactoryID'].Value);
    FlistA.Values['FMaterielID'] := VarToStr(nJS.Field['FMaterielID'].Value);
    FlistA.Values['FPackingID'] := VarToStr(nJS.Field['FPackingID'].Value);
    FlistA.Values['FWareNumber'] := VarToStr(nJS.Field['FWareNumber'].Value);
    FlistA.Values['FConsignBillID'] := VarToStr(nJS.Field['FBillID'].Value);

    if FListD.Values['Status'] = '1' then//������Ϣ
    begin
      nStr :='update %s set L_BDAX=''1'',L_BDNUM=L_BDNUM+1 where L_ID = ''%s'' ';
      nStr := Format(nStr,[sTable_Bill,FListD.Values['ID']]);

      gDBConnManager.WorkerExec(FDBConn,nStr);
    end;

    Result := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;

  if Result and (FListD.Values['Status'] = '1') then//������ͬ��
  begin
    if not TBusWorkerBusinessHHJY.CallMe(cBC_SyncHhSaleWareNumber
             ,PackerEncodeStr(FListA.Text),'',@nOut) then
    begin
      Result := False;
      nData := nOut.FData;
      Exit;
    end;

    nStr :='update %s set L_SealSync=''1'' where L_ID = ''%s'' ';
    nStr := Format(nStr,[sTable_Bill,FListD.Values['ID']]);

    gDBConnManager.WorkerExec(FDBConn,nStr);

    FOut.FData := '';
    FOut.FBase.FResult := True;
  end;
end;

function TBusWorkerBusinessHHJY.GetMoney(const nPrice,
  nValue: string): string;
var nMoney : Double;
begin
  Result := '0';
  try
    nMoney := StrToFloat(nPrice) * StrToFloat(nValue);
    nMoney := Float2PInt(nMoney, cPrecision, False) / cPrecision;
    Result := FloatToStr(nMoney);
  except
  end;
end;

function TBusWorkerBusinessHHJY.GetSaleDetailJSonString(const nLID, nDelete: string;
 var nExits: Boolean; var nInit, nNewStr: string): string;
var nStr, nSQL, nUrl, nDate: string;
    nInt, nIdx: Integer;
    nJSInit, nJSNew: TlkJSONobject;
    nOut: TWorkerBusinessCommand;
begin
  Result := '';
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;

  nExits := TBusWorkerBusinessHHJY.CallMe(cBC_IsHhSaleDetailExits
           ,PackerEncodeStr(nLID),'',@nOut);
  if nExits then
    FListB.Text := PackerDecodeStr(nOut.FData);

  if nExits and (nDelete = sFlag_Yes) then
  begin
    if FListB.Values['FStatus'] = '2' then
    begin
      Result := '�������[ %s ]�����,�޷�ɾ��,����ERP�Ƚ��з����.';
      Result := Format(Result, [nLID]);
      Exit;
    end;
  end;

  nSQL := 'select * From %s where L_ID = ''%s'' ';

  nSQL := Format(nSQL,[sTable_Bill, nLID]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  begin
    if RecordCount < 1 then
    begin
      Result := '�������[ %s ]������.';
      Result := Format(Result, [nLID]);
      Exit;
    end;

    FListA.Values['FConsignPlanNumber']     := FieldByName('L_Order').AsString;
    FListA.Values['FBillID']                := FieldByName('L_ID').AsString;
    FListA.Values['FBillNumber']            := FieldByName('L_ID').AsString;
    FListA.Values['FOldNumber']             := FieldByName('L_WT').AsString;

    FListA.Values['FGrossSign']             := '0';
    FListA.Values['FTareSign']              := '0';
    FListA.Values['FTare']                  := '0';
    FListA.Values['FGross']                 := '0';

    FListA.Values['FAuditingSign']          := '0';

    FListA.Values['FStatus']                := '1';

    FListA.Values['FGrossPerson']           := FieldByName('L_MMan').AsString;
    FListA.Values['FGrossTime']             := FieldByName('L_MDate').AsString;
    FListA.Values['FGrossName']             := FieldByName('L_MMan').AsString;


    FListA.Values['FTarePerson']            := FieldByName('L_PMan').AsString;
    FListA.Values['FTareTime']              := FieldByName('L_PDate').AsString;
    FListA.Values['FTareName']              := FieldByName('L_PMan').AsString;
    FListA.Values['FPlanAmount']            := FieldByName('L_PreValue').AsString;
    FListA.Values['FSuttle']                := FieldByName('L_Value').AsString;
    FListA.Values['FDeliveryAmount']        := FieldByName('L_Value').AsString;

    FListA.Values['FCreator']               := FieldByName('L_Man').AsString;
    FListA.Values['FCreateTime']            := FieldByName('L_Date').AsString;
    FListA.Values['FTransportNumber']       := FieldByName('L_Truck').AsString;

    try
      nDate := FormatDateTime('DD',FieldByName('L_Date').AsDateTime);
      if StrToIntDef(nDate,0) > 25 then
       nDate := FormatDateTime('YYYY-MM',IncMonth(FieldByName('L_Date').AsDateTime))
      else
       nDate := FormatDateTime('YYYY-MM',FieldByName('L_Date').AsDateTime);
    except
       nDate := FormatDateTime('YYYY-MM',FieldByName('L_Date').AsDateTime);
    end;

    if FieldByName('L_OutFact').AsString <> '' then
    begin
      FListA.Values['FGrossSign']             := '1';
      if FieldByName('L_MValue').AsString <> ''  then
        FListA.Values['FGross']               := FieldByName('L_MValue').AsString;

      FListA.Values['FTareSign']              := '1';
      if FieldByName('L_PValue').AsString <> ''  then
        FListA.Values['FTare']                := FieldByName('L_PValue').AsString;

      FListA.Values['FAuditingSign']          := '1';
      FListA.Values['FAssessor']              := FieldByName('L_MMan').AsString;
      FListA.Values['FAuditingTime']          := FieldByName('L_MDate').AsString;

      FListA.Values['FStatus']                := '2';

      FListA.Values['FDeliveryer']            := FieldByName('L_MMan').AsString;
      FListA.Values['FDeliveryTime']          := FieldByName('L_OutFact').AsString;
      FListA.Values['FKeepDate']              := FormatDateTime('YYYY-MM-DD',
                                               FieldByName('L_OutFact').AsDateTime);
      FListA.Values['FGoodsPrice']            := FieldByName('L_Price').AsString;

      try
        nDate := FormatDateTime('DD',FieldByName('L_OutFact').AsDateTime);
        if StrToIntDef(nDate,0) > 25 then
         nDate := FormatDateTime('YYYY-MM',IncMonth(FieldByName('L_OutFact').AsDateTime))
        else
         nDate := FormatDateTime('YYYY-MM',FieldByName('L_OutFact').AsDateTime);
      except
         nDate := FormatDateTime('YYYY-MM',FieldByName('L_OutFact').AsDateTime);
      end;
    end;

    {$IFDEF BatchInHYOfBill}
    FListA.Values['FWareNumber']            := FieldByName('L_HYDan').AsString;
    {$ELSE}
    FListA.Values['FWareNumber']            := FieldByName('L_Seal').AsString;
    {$ENDIF}
    FListA.Values['FType']                  := FieldByName('L_Type').AsString;

    FListA.Values['FYearPeriod']            := nDate;

    if FieldByName('L_Type').AsString = sFlag_Dai then
      FListA.Values['FBagAmount']           := IntToStr(Round(
                                            FieldByName('L_Value').AsFloat * 200))
    else
      FListA.Values['FBagAmount']           := '0';

    if nDelete = sFlag_Yes then
    begin
      FListA.Values['FIsdelete']            := '1';
      FListA.Values['FDeleteName']          := FieldByName('L_MMan').AsString;
      FListA.Values['FDeleteTime']          := FieldByName('L_MDate').AsString;
    end
    else
      FListA.Values['FIsdelete']            := '0';

    FListA.Values['FDataSign']              := '0';
    FListA.Values['FGoodsSign']             := '0';
    FListA.Values['FCFreightSign']          := '0';
    FListA.Values['FTFreightSign']          := '0';
    FListA.Values['FBackSign']              := '0';
    FListA.Values['FBangChSign']            := '0';
    FListA.Values['FScheduleVanID']         := FieldByName('L_WT').AsString;
    FListA.Values['FRemainder']             := '0.0000';
    FListA.Values['FGroupNO']               := '0';
    FListA.Values['FFactGross']             := FieldByName('L_MValue').AsString;
    FListA.Values['FDepotID']               := '-1';
    FListA.Values['FIsReSave']              := '0';
    FListA.Values['FChangeBalanceSign']     := '0';

    FListA.Values['FMidWaySign']            := '0';
    FListA.Values['FUnloadSign']            := '0';
  end;

  if FListA.Values['FConsignPlanNumber'] = '' then
  begin
    Result := '�������[ %s ]��ǰ������Ϊ��.';
    Result := Format(Result, [nLID]);
    Exit;
  end;

  nSQL := 'FBillCode = ''%s''';
  nSQL := Format(nSQL, [FListA.Values['FConsignPlanNumber']]);

  if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhSalePlan
           ,PackerEncodeStr(nSQL),'',@nOut) then
  begin
    Result := '�������[ %s ]��ȡ��ǰ����[ %s ]��Ϣʧ��.';
    Result := Format(Result, [nLID, FListA.Values['FConsignPlanNumber']]);
    Exit;
  end;

  FListC.Text := PackerDecodeStr(nOut.FData);

  if FListA.Values['FKeepDate'] <> '' then//�ѳ���
  begin
    if FListC.Values['FCustomerTypeID'] = '1' then
    begin
      if FListA.Values['FGoodsPrice'] = '' then
      begin
        Result := '�������[ %s ]���¼۸�[ %s ]�쳣.';
        Result := Format(Result, [nLID, FListA.Values['FGoodsPrice']]);
        Exit;
      end;
      FListC.Values['FGoodsPrice'] := FListA.Values['FGoodsPrice'];
    end;
  end;

  try
    if nExits then//���ϴ�
    begin
      nJSInit := TlkJSONobject.Create();

      with nJSInit do//ԭʼ����
      begin
        Add('FBillID', FListB.Values['FBillID']);//�����ID
        Add('FBillNumber', FListA.Values['FBillID']);//�������
        Add('FBillTypeID', '3');
        Add('FAccountCompID', FListB.Values['FAccountCompID']);
        Add('FCompanyID', FListB.Values['FCompanyID']);

        Add('FFactoryID', FListB.Values['FFactoryID']);
        Add('FShopID', FListB.Values['FShopID']);
        Add('FDepartmentID', FListB.Values['FDepartmentID']);
        Add('FSaleManID', FListB.Values['FSaleManID']);
        Add('FCustomerID', FListB.Values['FCustomerID']);

        Add('FConsignCustomerID', FListB.Values['FConsignCustomerID']);
        Add('FConsignName', FListB.Values['FConsignName']);
        Add('FConsignPlanID', FListB.Values['FConsignPlanID']);
        Add('FContractDetailID', FListB.Values['FContractDetailID']);
        Add('FTContractDetailID', FListB.Values['FTContractDetailID']);

        Add('FCurrencyID', '1');
        Add('FConsignPlanNumber', FListB.Values['FConsignPlanNumber']);
        Add('FMainUnit', '');
        Add('FAuxiliaryUnit', '');
        Add('FCoefficient', '');

        Add('FMaterielID', FListB.Values['FMaterielID']);
        Add('FTransportID', FListB.Values['FTransportID']);
        Add('FPriceModeID', FListB.Values['FPriceModeID']);
        Add('FInvoiceModeID', FListB.Values['FInvoiceModeID']);
        Add('FPackingID', FListB.Values['FPackingID']);

        Add('FDeliveryID', FListB.Values['FDeliveryID']);
        Add('FCarrierID', FListB.Values['FCarrierID']);
        Add('FTAreaID', FListB.Values['FTAreaID']);
        Add('FAddressID', FListB.Values['FAddressID']);
        Add('FDeliveryAddress', FListB.Values['FDeliveryAddress']);

        Add('FTransportNumber', FListB.Values['FTransportNumber']);
        Add('FPlanAmount', FListB.Values['FPlanAmount']);
        Add('FGross', FListB.Values['FGross']);
        Add('FTare', FListB.Values['FTare']);
        Add('FSuttle', FListB.Values['FSuttle']);

        Add('FDeliveryAmount', FListB.Values['FDeliveryAmount']);
        Add('FBagAmount', FListB.Values['FBagAmount']);
        Add('FCFreightAmount', '');
        Add('FWareNumber', FListB.Values['FWareNumber']);
        Add('FLoadingSiteID', FListB.Values['FLoadingSiteID']);

        Add('FYearPeriod', FListB.Values['FYearPeriod']);
        Add('FCreateTime', FListB.Values['FCreateTime']);
        Add('FCreator', FListB.Values['FCreator']);

        Add('FGoodsPrice', FListB.Values['FGoodsPrice']);
        Add('FCGoodsprice', FListB.Values['FCGoodsprice']);
        Add('FCFreightPrice', FListB.Values['FCFreightPrice']);
        Add('FTFreightPrice', FListB.Values['FTFreightPrice']);
        Add('FMidWayPrice', FListB.Values['FMidWayPrice']);
        Add('FUnloadPrice', FListB.Values['FUnloadPrice']);

        Add('FGoodsMoney', FListB.Values['FGoodsMoney']);
        Add('FCFreightMoney', FListB.Values['FCFreightMoney']);
        Add('FTFreightMoney', FListB.Values['FTFreightMoney']);
        Add('FMidWayMoney', FListB.Values['FMidWayMoney']);
        Add('FUnloadMoney', FListB.Values['FUnloadMoney']);

        Add('FTareSign', FListB.Values['FTareSign']);
        Add('FTarePerson', FListB.Values['FTarePerson']);
        Add('FTareTime', FListB.Values['FTareTime']);
        Add('FTareName', FListB.Values['FTareName']);
        Add('FGrossSign', FListB.Values['FGrossSign']);
        Add('FGrossPerson', FListB.Values['FGrossPerson']);
        Add('FGrossTime', FListB.Values['FGrossTime']);
        Add('FGrossName', FListB.Values['FGrossName']);
        Add('FDeliveryer', FListB.Values['FDeliveryer']);
        Add('FDeliveryTime', FListB.Values['FDeliveryTime']);
        Add('FAuditingSign', FListB.Values['FAuditingSign']);

        Add('FAssessor', FListB.Values['FAssessor']);
        Add('FAuditingTime', FListB.Values['FAuditingTime']);
        Add('FDataSign', FListB.Values['FDataSign']);
        Add('FStatus', FListB.Values['FStatus']);
        Add('FIsdelete', FListB.Values['FIsdelete']);

        Add('FGoodsSign', FListB.Values['FGoodsSign']);
        Add('FCFreightSign', FListB.Values['FCFreightSign']);
        Add('FTFreightSign', FListB.Values['FTFreightSign']);
        Add('FMidWaySign', FListB.Values['FMidWaySign']);
        Add('FUnloadSign', FListB.Values['FUnloadSign']);

        Add('FUnloadDate', '');
        Add('FBackSign', '0');
        Add('FBackPerson', '');
        Add('FBackTime', '');
        Add('FBangChSign', '0');

        Add('FScheduleVanID', FListB.Values['FScheduleVanID']);
        Add('FRemark', FListB.Values['FRemark']);
        Add('FRemainder', '0');
        Add('FGroupNO', '0');
        Add('FFactGross', FListB.Values['FFactGross']);

        Add('FDeleteName', FListB.Values['FDeleteName']);
        Add('FDeleteTime', FListB.Values['FDeleteTime']);
        Add('FKeepDate', FListB.Values['FKeepDate']);
        Add('FDepotID', '-1');
        Add('FConsignDepositBillID', '1');

        Add('FConsignDepositNumber', '');
        Add('FMaterielChangeID', '-1');
        Add('FIsReSave', '0');
        Add('FOldNumber', '');
        Add('FMender', FListB.Values['FMender']);

        Add('FModifyTime', FListB.Values['FModifyTime']);
        Add('FChangeBalanceSign', '0');
        Add('FDescription', '');
        Add('FIshedge', '0');
        Add('FOrigBillID', '-1');

        Add('FOrigBillNumber', '');
        Add('FSplitSign', '-1');
        Add('FCloseSign', '0');
        Add('FVer', FListB.Values['FVer']);
      end;

      nInit := TlkJSON.GenerateText(nJSInit);
      nInit := UTF8Decode(nInit);
      WriteLog('������ϴ�ԭʼ����:' + nInit);

      nJSNew := TlkJSONobject.Create();

      with nJSNew do
      begin
        Add('FBillID', FListB.Values['FBillID']);//�����ID
        Add('FBillNumber', FListA.Values['FBillID']);//�������
        Add('FBillTypeID', '3');
        Add('FAccountCompID', FListC.Values['FAccountCompID']);
        Add('FCompanyID', FListC.Values['FCompanyID']);

        Add('FFactoryID', FListC.Values['FFactoryID']);
        Add('FShopID', FListC.Values['FFactoryID']);
        Add('FDepartmentID', FListC.Values['FDepartmentID']);
        Add('FSaleManID', FListC.Values['FSaleManID']);
        Add('FCustomerID', FListC.Values['FCustomerID']);

        Add('FConsignCustomerID', FListC.Values['FConsignCustomerID']);
        Add('FConsignName', FListC.Values['FConsignName']);
        Add('FConsignPlanID', FListC.Values['FBillID']);
        Add('FContractDetailID', FListC.Values['FContractDetailID']);
        Add('FTContractDetailID', FListC.Values['FTContractDetailID']);

        Add('FCurrencyID', '1');
        Add('FConsignPlanNumber', FListC.Values['FBillCode']);
        Add('FMainUnit', '');
        Add('FAuxiliaryUnit', '');
        Add('FCoefficient', '');

        Add('FMaterielID', FListC.Values['FMaterielID']);
        Add('FTransportID', FListC.Values['FTransportID']);
        Add('FPriceModeID', FListC.Values['FPriceModeID']);
        Add('FInvoiceModeID', FListC.Values['FInvoiceModeID']);
        Add('FPackingID', FListC.Values['FPackingID']);

        Add('FDeliveryID', FListC.Values['FDeliveryID']);
        Add('FCarrierID', FListC.Values['FCarrierID']);
        Add('FTAreaID', FListC.Values['FTransportAreaID']);
        Add('FAddressID', FListC.Values['FAdressID']);
        Add('FDeliveryAddress', FListC.Values['FDeliveryAddress']);

        Add('FTransportNumber', FListA.Values['FTransportNumber']);
        Add('FPlanAmount', FListA.Values['FPlanAmount']);
        Add('FGross', FListA.Values['FGross']);
        Add('FTare', FListA.Values['FTare']);
        Add('FSuttle', FListA.Values['FSuttle']);

        Add('FDeliveryAmount', FListA.Values['FDeliveryAmount']);
        Add('FBagAmount', FListA.Values['FBagAmount']);
        Add('FCFreightAmount', '');
        Add('FWareNumber', FListA.Values['FWareNumber']);
        Add('FLoadingSiteID', FListC.Values['FLoadingSiteID']);

        Add('FYearPeriod', FListA.Values['FYearPeriod']);
        Add('FCreateTime', FListA.Values['FCreateTime']);
        Add('FCreator', FListA.Values['FCreator']);

        Add('FGoodsPrice', FListC.Values['FGoodsPrice']);
        Add('FCGoodsprice', FListC.Values['FCGoodsprice']);
        Add('FCFreightPrice', FListC.Values['FCFreightPrice']);
        Add('FTFreightPrice', FListC.Values['FTFreightPrice']);
        Add('FMidWayPrice', FListC.Values['FMidWayPrice']);
        Add('FUnloadPrice', FListC.Values['FUnloadPrice']);

        Add('FGoodsMoney', GetMoney(FListC.Values['FGoodsPrice'],
                                    FListA.Values['FSuttle']));
        Add('FCFreightMoney', GetMoney(FListC.Values['FCFreightPrice'],
                                    FListA.Values['FSuttle']));
        Add('FTFreightMoney', GetMoney(FListC.Values['FTFreightPrice'],
                                    FListA.Values['FSuttle']));
        Add('FMidWayMoney', GetMoney(FListC.Values['FMidWayPrice'],
                                    FListA.Values['FSuttle']));
        Add('FUnloadMoney', GetMoney(FListC.Values['FUnloadPrice'],
                                    FListA.Values['FSuttle']));

        Add('FTareSign', FListA.Values['FTareSign']);
        Add('FTarePerson', FListA.Values['FTarePerson']);
        Add('FTareTime', FListA.Values['FTareTime']);
        Add('FTareName', FListA.Values['FTareName']);
        Add('FGrossSign', FListA.Values['FGrossSign']);
        Add('FGrossPerson', FListA.Values['FGrossPerson']);
        Add('FGrossTime', FListA.Values['FGrossTime']);
        Add('FGrossName', FListA.Values['FGrossName']);
        Add('FDeliveryer', FListA.Values['FDeliveryer']);
        Add('FDeliveryTime', FListA.Values['FDeliveryTime']);
        Add('FAuditingSign', FListA.Values['FAuditingSign']);

        Add('FAssessor', FListA.Values['FAssessor']);
        Add('FAuditingTime', FListA.Values['FAuditingTime']);
        Add('FDataSign', FListB.Values['FDataSign']);
        Add('FStatus', FListA.Values['FStatus']);
        Add('FIsdelete', FListA.Values['FIsdelete']);

        Add('FGoodsSign', FListB.Values['FGoodsSign']);
        Add('FCFreightSign', FListB.Values['FCFreightSign']);
        Add('FTFreightSign', FListB.Values['FTFreightSign']);
        Add('FMidWaySign', FListB.Values['FMidWaySign']);
        Add('FUnloadSign', FListB.Values['FUnloadSign']);

        Add('FUnloadDate', '');
        Add('FBackSign', '0');
        Add('FBackPerson', '');
        Add('FBackTime', '');
        Add('FBangChSign', '0');

        Add('FScheduleVanID', FListA.Values['FOldNumber']);
        Add('FRemark', FListC.Values['FRemark']);
        Add('FRemainder', '0');
        Add('FGroupNO', '0');
        Add('FFactGross', FListA.Values['FFactGross']);

        Add('FDeleteName', FListB.Values['FDeleteName']);
        Add('FDeleteTime', FListB.Values['FDeleteTime']);
        Add('FKeepDate', FListA.Values['FKeepDate']);
        Add('FDepotID', '-1');
        Add('FConsignDepositBillID', '1');

        Add('FConsignDepositNumber', '');
        Add('FMaterielChangeID', '-1');
        Add('FIsReSave', '0');
        Add('FOldNumber', '');
        Add('FMender', FListA.Values['FCreator']);

        Add('FModifyTime', FListA.Values['FCreateTime']);
        Add('FChangeBalanceSign', '0');
        Add('FDescription', '');
        Add('FIshedge', '0');
        Add('FOrigBillID', '-1');

        Add('FOrigBillNumber', '');
        Add('FSplitSign', '-1');
        Add('FCloseSign', '0');
        Add('FVer', FListC.Values['FVer']);
      end;
      nNewStr := TlkJSON.GenerateText(nJSNew);
      nNewStr := UTF8Decode(nNewStr);
      WriteLog('������ϴ���ǰ����:' + nNewStr);
    end
    else
    begin
      if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhSaleDetailID,
           '','',@nOut) then
      begin
        Result := '[' + nLID + ']��ȡ���������IDʧ��.';
        Exit;
      end;

      nStr := PackerDecodeStr(nOut.FData);
      nJSNew := TlkJSONobject.Create();

      with nJSNew do
      begin
        Add('FBillID', nStr);//�����ID
        Add('FBillNumber', FListA.Values['FBillID']);//�������
        Add('FBillTypeID', '3');
        Add('FAccountCompID', FListC.Values['FAccountCompID']);
        Add('FCompanyID', FListC.Values['FCompanyID']);

        Add('FFactoryID', FListC.Values['FFactoryID']);
        Add('FShopID', FListC.Values['FFactoryID']);
        Add('FDepartmentID', FListC.Values['FDepartmentID']);
        Add('FSaleManID', FListC.Values['FSaleManID']);
        Add('FCustomerID', FListC.Values['FCustomerID']);

        Add('FConsignCustomerID', FListC.Values['FConsignCustomerID']);
        Add('FConsignName', FListC.Values['FConsignName']);
        Add('FConsignPlanID', FListC.Values['FBillID']);
        Add('FContractDetailID', FListC.Values['FContractDetailID']);
        Add('FTContractDetailID', FListC.Values['FTContractDetailID']);

        Add('FCurrencyID', '1');
        Add('FConsignPlanNumber', FListC.Values['FBillCode']);
        Add('FMainUnit', '');
        Add('FAuxiliaryUnit', '');
        Add('FCoefficient', '');

        Add('FMaterielID', FListC.Values['FMaterielID']);
        Add('FTransportID', FListC.Values['FTransportID']);
        Add('FPriceModeID', FListC.Values['FPriceModeID']);
        Add('FInvoiceModeID', FListC.Values['FInvoiceModeID']);
        Add('FPackingID', FListC.Values['FPackingID']);

        Add('FDeliveryID', FListC.Values['FDeliveryID']);
        Add('FCarrierID', FListC.Values['FCarrierID']);
        Add('FTAreaID', FListC.Values['FTransportAreaID']);
        Add('FAddressID', FListC.Values['FAdressID']);
        Add('FDeliveryAddress', FListC.Values['FDeliveryAddress']);

        Add('FTransportNumber', FListA.Values['FTransportNumber']);
        Add('FPlanAmount', FListA.Values['FPlanAmount']);
        Add('FGross', FListA.Values['FGross']);
        Add('FTare', FListA.Values['FTare']);
        Add('FSuttle', FListA.Values['FSuttle']);

        Add('FDeliveryAmount', FListA.Values['FDeliveryAmount']);
        Add('FBagAmount', FListA.Values['FBagAmount']);
        Add('FCFreightAmount', '');
        Add('FWareNumber', FListA.Values['FWareNumber']);
        Add('FLoadingSiteID', FListC.Values['FLoadingSiteID']);

        Add('FYearPeriod', FListA.Values['FYearPeriod']);
        Add('FCreateTime', FListA.Values['FCreateTime']);
        Add('FCreator', FListA.Values['FCreator']);

        Add('FGoodsPrice', FListC.Values['FGoodsPrice']);
        Add('FCGoodsprice', FListC.Values['FCGoodsprice']);
        Add('FCFreightPrice', FListC.Values['FCFreightPrice']);
        Add('FTFreightPrice', FListC.Values['FTFreightPrice']);
        Add('FMidWayPrice', FListC.Values['FMidWayPrice']);
        Add('FUnloadPrice', FListC.Values['FUnloadPrice']);

        Add('FGoodsMoney', GetMoney(FListC.Values['FGoodsPrice'],
                                    FListA.Values['FSuttle']));
        Add('FCFreightMoney', GetMoney(FListC.Values['FCFreightPrice'],
                                    FListA.Values['FSuttle']));
        Add('FTFreightMoney', GetMoney(FListC.Values['FTFreightPrice'],
                                    FListA.Values['FSuttle']));
        Add('FMidWayMoney', GetMoney(FListC.Values['FMidWayPrice'],
                                    FListA.Values['FSuttle']));
        Add('FUnloadMoney', GetMoney(FListC.Values['FUnloadPrice'],
                                    FListA.Values['FSuttle']));

        Add('FTareSign', FListA.Values['FTareSign']);
        Add('FTarePerson', FListA.Values['FTarePerson']);
        Add('FTareTime', FListA.Values['FTareTime']);
        Add('FTareName', FListA.Values['FTareName']);
        Add('FGrossSign', FListA.Values['FGrossSign']);
        Add('FGrossPerson', FListA.Values['FGrossPerson']);
        Add('FGrossTime', FListA.Values['FGrossTime']);
        Add('FGrossName', FListA.Values['FGrossName']);
        Add('FDeliveryer', FListA.Values['FDeliveryer']);
        Add('FDeliveryTime', FListA.Values['FDeliveryTime']);
        Add('FAuditingSign', '0');

        Add('FAssessor', FListA.Values['FAssessor']);
        Add('FAuditingTime', FListA.Values['FAuditingTime']);
        Add('FDataSign', FListA.Values['FDataSign']);
        Add('FStatus', FListA.Values['FStatus']);
        Add('FIsdelete', FListA.Values['FIsdelete']);

        Add('FGoodsSign', FListA.Values['FGoodsSign']);
        Add('FCFreightSign', FListA.Values['FCFreightSign']);
        Add('FTFreightSign', FListA.Values['FTFreightSign']);
        Add('FMidWaySign', FListA.Values['FMidWaySign']);
        Add('FUnloadSign', FListA.Values['FUnloadSign']);

        Add('FUnloadDate', '');
        Add('FBackSign', '0');
        Add('FBackPerson', '');
        Add('FBackTime', '');
        Add('FBangChSign', '0');

        Add('FScheduleVanID', FListA.Values['FOldNumber']);
        Add('FRemark', FListC.Values['FRemark']);
        Add('FRemainder', '0');
        Add('FGroupNO', '0');
        Add('FFactGross', FListA.Values['FFactGross']);

        Add('FDeleteName', FListA.Values['FDeleteName']);
        Add('FDeleteTime', FListA.Values['FDeleteTime']);
        Add('FKeepDate', FListA.Values['FKeepDate']);
        Add('FDepotID', '-1');
        Add('FConsignDepositBillID', '1');

        Add('FConsignDepositNumber', '');
        Add('FMaterielChangeID', '-1');
        Add('FIsReSave', '0');
        Add('FOldNumber', '');
        Add('FMender', FListA.Values['FCreator']);

        Add('FModifyTime', FListA.Values['FCreateTime']);
        Add('FChangeBalanceSign', '0');
        Add('FDescription', '');
        Add('FIshedge', '0');
        Add('FOrigBillID', '-1');

        Add('FOrigBillNumber', '');
        Add('FSplitSign', '-1');
        Add('FCloseSign', '0');
        Add('FVer', FListC.Values['FVer']);
      end;
      nNewStr := TlkJSON.GenerateText(nJSNew);
      nNewStr := UTF8Decode(nNewStr);
      WriteLog('������ϴ���ǰ����:' + nNewStr);
    end;
    finally
    if Assigned(nJSInit) then
      nJSInit.Free;
    if Assigned(nJSNew) then
      nJSNew.Free;
  end;
end;

function TBusWorkerBusinessHHJY.IsHhSaleDetailExits(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Clear;
  nStr := 'FBillNumber = ''%s''';
  nStr := Format(nStr,[PackerDecodeStr(FIn.FData)]);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('��ѯ���ϴ���������'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SaleConsignBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SaleConsignBill(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                   nStr, '');

    WriteLog('��ѯ���ϴ����������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ѯ���ϴ�����������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ѯ���ϴ�����������쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListA.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
      end;
    end;
    nData := PackerEncodeStr(FListA.Text);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhSaleDetailID(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListE.Clear;

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('��ȡ���������ID���'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SaleConsignBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SaleConsignBill(nHHJYChannel^.FChannel).InitializationModel(nSoapHeader);

    WriteLog('��ȡ���������ID����'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ���������ID�����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    nJsCol := nJS.Field['Data'] as TlkJSONobject;

    nStr := VarToStr(nJSCol.Field['FBillID'].Value);

    if nStr = '' then
    begin
      nData := '��ȡ���������ID�ӿڵ����쳣.Data�ڵ�FBillIDΪ��';
      Exit;
    end;

    nData := PackerEncodeStr(nStr);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;


function TBusWorkerBusinessHHJY.GetHhSaleWareNumber(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Text := PackerDecodeStr(FIn.FData);
//  FlistA.Values['FactoryID'] := '100000104';
//  FlistA.Values['PackingID'] := '1';
//  FlistA.Values['StockID'] := '11';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('��ȡ���κ����'+FListA.Text);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QControlWareNumberNoticeBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_QControlWareNumberNoticeBill(nHHJYChannel^.FChannel).GetWareNumberNoticeBill(nSoapHeader,
                                   FlistA.Values['FactoryID'],
                                   FlistA.Values['StockID'],
                                   FlistA.Values['PackingID']);

    WriteLog('��ȡ���κų���'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ���κŵ����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡ���κŵ����쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListA.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
      end;
    end;
    nData := PackerEncodeStr(FListA.Text);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhSaleWTTruck(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Text := PackerDecodeStr(FIn.FData);
//  FlistA.Values['FactoryID'] := '100000104';
//  FlistA.Values['PackingID'] := '1';
//  FlistA.Values['StockID'] := '11';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('��ȡί�е����'+FListA.Text);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SaleTransportForCustomer.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SaleTransportForCustomer(nHHJYChannel^.FChannel).GetTransportListForCustomer(nSoapHeader,
                                   FlistA.Values['CusID'],
                                   FlistA.Values['SaleManID'],
                                   FlistA.Values['StockID'],
                                   FlistA.Values['PackingID']);

    WriteLog('��ȡί�е�����'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡί�е������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡί�е������쳣.Data�ڵ�Ϊ��';
        Exit;
      end;
      FListB.Clear;
      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListA.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        FListB.Add(PackerEncodeStr(FListA.Text));
      end;
    end;
    nData := PackerEncodeStr(FListB.Text);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhSaleWareNumber(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Text := PackerDecodeStr(FIn.FData);

  WriteLog('ͬ����������κ����:' + FListA.Text);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QControlWareNumberNoticeBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel

    nStr := IV_QControlWareNumberNoticeBill(nHHJYChannel^.FChannel).P_SaleUpdateQControlWareNumber(nSoapHeader,
                                   FlistA.Values['FFactoryID'],
                                   FlistA.Values['FMaterielID'],
                                   FlistA.Values['FPackingID'],
                                   FlistA.Values['FWareNumber'],
                                   FlistA.Values['FConsignBillID']);


    WriteLog('ͬ����������κų���'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := 'ͬ����������κŵ����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := 'ͬ����������κŵ����쳣.Data�ڵ�Ϊ��';
        Exit;
      end;
      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListA.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
      end;

      nStr := FlistA.Values['FResult'];

      if Length(nStr) > 0 then
      begin
        nData := 'ͬ����������κ�ʧ��,���ؽ��:[' + nStr + ']' + ',ˮ����δ�ҵ�����ע��';
        Exit;
      end;

      Result := True;
      FOut.FData := '';
      FOut.FBase.FResult := True;
    end;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhSaleRealPrice(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  FListE.Clear;
  FListE.Text := PackerDecodeStr(FIn.FData);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := '��ȡ�������¼۸����:FContractDetailID[ %s ],' +
            'FTContractDetailID[ %s ],FLoadingSiteID[ %s ]dateTime[ %s ]';
    nStr := Format(nStr,[FListE.Values['FContractDetailID'],
                         FListE.Values['FTContractDetailID'],
                         FListE.Values['FLoadingSiteID'],
                         FListE.Values['FPriceDate']]);
    WriteLog(nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_SaleConsignPlanBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_SaleConsignPlanBill(nHHJYChannel^.FChannel).F_Sale_GetPriceForConsignBill(nSoapHeader,
                                   FlistE.Values['FContractDetailID'],
                                   FlistE.Values['FTContractDetailID'],
                                   FlistE.Values['FLoadingSiteID'],
                                   FListE.Values['FPriceDate']);

    WriteLog('��ȡ�������¼۸����'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ�������¼۸�����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡ�������¼۸�����쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListE.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListE.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
      end;
    end;

    nData := PackerEncodeStr(FListE.Text);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhOrderPlan(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
    nValue: Double;
begin
  Result := False;
  nUrl := '';
  nStr := PackerDecodeStr(FIn.FData);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        if nStr = '' then
          nStr := FDefWhere
        else
        if FDefWhere <> '' then
          nStr := nStr + ' And ' + FDefWhere;
        Break;
      end;
    end;

    WriteLog('��ȡ��ͨԭ���϶������'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

        FChannel := CoV_SupplyMaterialEntryPlan.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_SupplyMaterialEntryPlan(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                            nStr, '');

    if Pos('FEntryPlanNumber', PackerDecodeStr(FIn.FData)) > 0 then
      WriteLog('��ȡ��ͨԭ���϶�������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ��ͨԭ���϶����ӿڵ����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡ��ͨԭ���϶����ӿڵ����쳣.' + FIn.FData + 'Data�ڵ�Ϊ��';
        WriteLog(nData);
        Exit;
      end;

      if Pos('FEntryPlanNumber', PackerDecodeStr(FIn.FData)) > 0 then
      begin
        for nIdx := 0 to nJSRow.Count - 1 do
        begin
          nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

          FListE.Clear;
          for nInt := 0 to nJSCol.Count - 1 do
          begin
            FListE.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
          end;
        end;
        nData := PackerEncodeStr(FListE.Text);
      end
      else
      begin
        FListA.Clear;
        FListC.Clear;
        for nIdx := 0 to nJSRow.Count - 1 do
        begin
          nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

          FListB.Clear;
          FListC.Clear;
          for nInt := 0 to nJSCol.Count - 1 do
          begin
            FListC.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
          end;

          with FListB do
          begin
            Values['Order']         := FListC.Values['FEntryPlanNumber'];
            Values['ProName']       := FListC.Values['FMaterialProviderName'];
            Values['ProID']         := FListC.Values['FMaterialProviderID'];
            Values['StockName']     := FListC.Values['FMaterielName'];
            Values['StockID']       := FListC.Values['FMaterielID'];
            Values['StockNo']       := FListC.Values['FMaterielNumber'];
            try
              nValue := StrToFloat(FListC.Values['FApproveAmount'])
                        - StrToFloat(FListC.Values['FEntryAmount']);
              nValue := Float2PInt(nValue, cPrecision, False) / cPrecision;
            except
              nValue := 0;
            end;
            Values['PlanValue']     := FListC.Values['FApproveAmount'];//������
            Values['EntryValue']    := FListC.Values['FEntryAmount'];//�ѽ�����
            Values['Value']         := FloatToStr(nValue);//ʣ����
            Values['Model']         := FListC.Values['FModel'];//�ͺ�
            Values['KD']            := FListC.Values['FProducerName'];//���

            FListA.Add(PackerEncodeStr(FListB.Text));
          end;
        end;
        nData := PackerEncodeStr(FListA.Text);
      end;
    end
    else
    begin
      nData := '��ȡ��ͨԭ���϶����ӿڵ����쳣.Data�ڵ��쳣';
      WriteLog(nData);
      Exit;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.IsHhOrderDetailExits(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Clear;
  nStr := 'FBillNumber = ''%s''';
  nStr := Format(nStr,[PackerDecodeStr(FIn.FData)]);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('��ѯ���ϴ���ͨԭ���ϲɹ������'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyMaterialReceiveBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SupplyMaterialReceiveBill(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                   nStr, '');

    WriteLog('��ѯ���ϴ���ͨԭ���ϲɹ�������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ѯ���ϴ���ͨԭ���ϲɹ��������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ѯ���ϴ���ͨԭ���ϲɹ��������쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListA.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
      end;
    end;
    nData := PackerEncodeStr(FListA.Text);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhOrderDetailID(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListE.Clear;

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('��ȡ������ͨԭ���ϲɹ���ID���'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyMaterialReceiveBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SupplyMaterialReceiveBill(nHHJYChannel^.FChannel).InitializationModel(nSoapHeader);

    WriteLog('��ȡ������ͨԭ���ϲɹ���ID����'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ������ͨԭ���ϲɹ���ID�����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    nJsCol := nJS.Field['Data'] as TlkJSONobject;

    nStr := VarToStr(nJSCol.Field['FBillID'].Value);

    if nStr = '' then
    begin
      nData := '��ȡ������ͨԭ���ϲɹ���ID�ӿڵ����쳣.Data�ڵ�FBillIDΪ��';
      Exit;
    end;

    nData := PackerEncodeStr(nStr);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhOrderDetail(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
    nExits: Boolean;
    nInitStr, nNewStr: string;
begin
  Result := False;
  nExits := False;
  nUrl := '';
  FListD.Text := PackerDecodeStr(FIn.FData);

  WriteLog('ͬ����ͨԭ���ϲɹ���׼���������:' + FListD.Text);

  nData := GetOrderDetailJSonString(FListD.Values['ID'], FListD.Values['Delete'], nExits,
                                    nInitStr, nNewStr);
  if nData <> '' then
  begin
    WriteLog('ͬ����ͨԭ���ϲɹ���׼�����ݽ��:' + nData);
    Exit;
  end;

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('ͬ����ͨԭ���ϲɹ������'+FListD.Text);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyMaterialReceiveBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel

    if nExits then
    begin
      nStr := IT_SupplyMaterialReceiveBill(nHHJYChannel^.FChannel).Update(nSoapHeader,
                                     nInitStr, nNewStr);
    end
    else
    begin
      nStr := IT_SupplyMaterialReceiveBill(nHHJYChannel^.FChannel).Insert(nSoapHeader,
                                     nNewStr);
    end;

    WriteLog('ͬ����ͨԭ���ϲɹ�������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := 'ͬ����ͨԭ���ϲɹ��������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    nStr :='update %s set P_BDAX=''1'',P_BDNUM=P_BDNUM+1 where P_ID = ''%s'' ';
    nStr := Format(nStr,[sTable_PoundLog,FListD.Values['ID']]);

    gDBConnManager.WorkerExec(FDBConn,nStr);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetOrderDetailJSonString(const nLID, nDelete: string;
 var nExits: Boolean; var nInit, nNewStr: string): string;
var nStr, nSQL, nUrl, nDate: string;
    nInt, nIdx: Integer;
    nJSInit, nJSNew: TlkJSONobject;
    nOut: TWorkerBusinessCommand;
    nPDate, nMDate: TDateTime;
    nDepot: string;
begin
  Result := '';
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;

  nSQL := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s'' ';
  nSQL := Format(nSQL, [sTable_SysDict, sFlag_SysParam, sFlag_HHJYDepotID]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  begin
    if RecordCount < 1 then
    begin
      Result := '������Ϊ[ %s ]�Ĵ����ID������.';
      Result := Format(Result, [nLID]);
      Exit;
    end;
    nDepot := Fields[0].AsString;
  end;

  nExits := TBusWorkerBusinessHHJY.CallMe(cBC_IsHhOrderDetailExits
           ,PackerEncodeStr(nLID),'',@nOut);
  if nExits then
    FListB.Text := PackerDecodeStr(nOut.FData);

  if nExits and (nDelete = sFlag_Yes) then
  begin
    if FListB.Values['FStatus'] = '254' then
    begin
      Result := '������[ %s ]�����,�޷�ɾ��,����ERP�Ƚ��з����.';
      Result := Format(Result, [nLID]);
      Exit;
    end;
  end;

  nSQL := 'select *,(P_MValue-P_PValue - isnull(P_KZValue,0)) as D_NetWeight From %s a,'+
  ' %s b, %s c where a.D_OID=b.O_ID and a.D_ID=c.P_OrderBak and c.P_ID = ''%s'' ';

  nSQL := Format(nSQL,[sTable_OrderDtl,sTable_Order,sTable_PoundLog,nLID]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  begin
    if RecordCount < 1 then
    begin
      Result := '������Ϊ[ %s ]�Ĳɹ�����������.';
      Result := Format(Result, [nLID]);
      Exit;
    end;

    FListA.Clear;

    FListA.Values['FEntryPlanNumber']       := FieldByName('P_BID').AsString;
    FListA.Values['FBillID']                := FieldByName('P_ID').AsString;
    FListA.Values['FBillNumber']            := FieldByName('P_ID').AsString;
    FListA.Values['FPoundID']               := FieldByName('P_ID').AsString;
    FListA.Values['FAuditID']               := FieldByName('P_ID').AsString;
    FListA.Values['FBillTypeID']            := '36';

    FListA.Values['FGrossWeightStatus']     := '1';
    FListA.Values['FGrossWeightPersonnel']  := FieldByName('P_MMan').AsString;
    FListA.Values['FGrossWeightTime']       := FieldByName('P_MDate').AsString;

    if FieldByName('P_MValue').AsString = '' then
      FListA.Values['FReceiveGrossWeight']    := '0'
    else
      FListA.Values['FReceiveGrossWeight']    := FieldByName('P_MValue').AsString;

    FListA.Values['FReceivePersonnel']      := FieldByName('P_MMan').AsString;
    try
      nPDate := FieldByName('P_PDate').AsDateTime;
      nMDate := FieldByName('P_MDate').AsDateTime;
      if nMDate > nPDate then
        nDate := FieldByName('P_MDate').AsString
      else
        nDate := FieldByName('P_PDate').AsString;
    except
        nDate := FieldByName('P_PDate').AsString;
    end;

    FListA.Values['FReceiveTime']           := nDate;

    FListA.Values['FTareStatus']            := '1';
    FListA.Values['FTarePersonnel']         := FieldByName('P_PMan').AsString;
    FListA.Values['FTareTime']              := FieldByName('P_PDate').AsString;

    if FieldByName('P_PValue').AsString = '' then
      FListA.Values['FReceiveTare']    := '0'
    else
      FListA.Values['FReceiveTare']    := FieldByName('P_PValue').AsString;

    if FieldByName('D_NetWeight').AsString = '' then
      FListA.Values['FReceiveNetWeight']    := '0'
    else
      FListA.Values['FReceiveNetWeight']    := FieldByName('D_NetWeight').AsString;

    FListA.Values['FCreator']               := FieldByName('P_PMan').AsString;
    FListA.Values['FCreateTime']            := nDate;
    FListA.Values['FShipNumber']            := FieldByName('P_Ship').AsString;
    FListA.Values['FConveyanceNumber']      := FieldByName('P_Truck').AsString;
    FListA.Values['FImpurity']              := FloatToStr(StrToFLoatDef(
                                         FieldByName('D_KZValue').AsString,0));
    FListA.Values['FDeductAmount']          := '0';
    FListA.Values['FStatus']                := '254';
    FListA.Values['FDepotID']               := nDepot;

    if nDelete = sFlag_Yes then
    begin
      FListA.Values['FCancelStatus']        := '1';
      FListA.Values['FCancelPersonnel']     := FieldByName('P_PMan').AsString;
      FListA.Values['FCancelTime']          := nDate;
    end
    else
      FListA.Values['FCancelStatus']          := '0';
      
    FListA.Values['FDataStatus']            := '0';
    FListA.Values['FMaterialStockInStatus'] := '0';
    FListA.Values['FFreightStockInStatus']  := '0';
    FListA.Values['FLabStatus']             := '0';
  end;

  if FListA.Values['FEntryPlanNumber'] = '' then
  begin
    Result := '��ͨԭ���ϲɹ�����[ %s ]��ǰ������Ϊ��.';
    Result := Format(Result, [nLID]);
    Exit;
  end;

  nSQL := 'FEntryPlanNumber = ''%s''';
  nSQL := Format(nSQL, [FListA.Values['FEntryPlanNumber']]);

  if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhOrderPlan
           ,PackerEncodeStr(nSQL),'',@nOut) then
  begin
    Result := '��ͨԭ���ϲɹ�����[ %s ]��ȡ��ǰ����[ %s ]��Ϣʧ��.';
    Result := Format(Result, [nLID, FListA.Values['FEntryPlanNumber']]);
    Exit;
  end;

  FListC.Text := PackerDecodeStr(nOut.FData);

  try
    if nExits then//���ϴ�
    begin
      nJSInit := TlkJSONobject.Create();

      with nJSInit do//ԭʼ����
      begin
        Add('FBillID', FListB.Values['FBillID']);//�����ID
        Add('FBillNumber', FListA.Values['FBillID']);//�������
        Add('FBillTypeID', '36');
        Add('FCompanyID', FListB.Values['FCompanyID']);
        Add('FUseDepartmentID', FListB.Values['FUseDepartmentID']);

        Add('FDepotID', FListB.Values['FDepotID']);//???
        Add('FYearPeriod', FListB.Values['FYearPeriod']);
        Add('FMaterielID', FListB.Values['FMaterielID']);
        Add('FUnitID', FListB.Values['FUnitID']);
        Add('FUnitID_Auxiliary', FListB.Values['FUnitID_Auxiliary']);

        Add('FUnitIsFloat', FListB.Values['FUnitIsFloat']);
        Add('FUnitCoefficient', FListB.Values['FUnitCoefficient']);
        Add('FValueID', FListB.Values['FValueID']);

        Add('FEntryPlanID', FListB.Values['FEntryPlanID']);
        Add('FRequirementPlanID', FListB.Values['FRequirementPlanID']);
        Add('FRequirementPlanDetailID', FListB.Values['FRequirementPlanDetailID']);

        Add('FMaterialProviderID', FListB.Values['FMaterialProviderID']);
        Add('FMaterialContractDetailID', FListB.Values['FMaterialContractDetailID']);
        Add('FProducerID', FListB.Values['FProducerID']);

        Add('FMaterialPriceTax', FListB.Values['FMaterialPriceTax']);
        Add('FMaterialMoneyTax', FListB.Values['FMaterialMoneyTax']);

        Add('FMaterialInvoiceTypeID', FListB.Values['FMaterialInvoiceTypeID']);
        Add('FMaterialInvoiceClassID', FListB.Values['FMaterialInvoiceClassID']);
        Add('FMaterialTaxRate', FListB.Values['FMaterialTaxRate']);

        Add('FMaterialPrice', FListB.Values['FMaterialPrice']);
        Add('FMaterialMoney', FListB.Values['FMaterialMoney']);

        Add('FFreightProviderID', FListB.Values['FFreightProviderID']);
        Add('FFreightContractDetailID', FListB.Values['FFreightContractDetailID']);

        Add('FFreightPriceTax', FListB.Values['FFreightPriceTax']);
        Add('FFreightMoneyTax', FListB.Values['FFreightMoneyTax']);

        Add('FFreightInvoiceTypeID', FListB.Values['FFreightInvoiceTypeID']);
        Add('FFreightInvoiceClassID', FListB.Values['FFreightInvoiceClassID']);
        Add('FFreightTaxRate', FListB.Values['FFreightTaxRate']);

        Add('FFreightPrice', FListB.Values['FFreightPrice']);
        Add('FFreightMoney', FListB.Values['FFreightMoney']);

        Add('FBillAmount', FListB.Values['FReceiveNetWeight']);
        Add('FBillAmount_Auxiliary', FListB.Values['FBillAmount_Auxiliary']);
        Add('FReceiveGrossWeight', FListB.Values['FReceiveGrossWeight']);
        Add('FReceiveGrossWeight_Auxiliary', FListB.Values['FReceiveGrossWeight_Auxiliary']);
        Add('FReceiveTare', FListB.Values['FReceiveTare']);
        Add('FReceiveTare_Auxiliary', FListB.Values['FReceiveTare_Auxiliary']);
        Add('FImpurity', FListB.Values['FImpurity']);
        Add('FImpurity_Auxiliary', FListB.Values['FImpurity_Auxiliary']);
        Add('FDeductAmount', FListB.Values['FDeductAmount']);
        Add('FDeductAmount_Auxiliary', FListB.Values['FDeductAmount_Auxiliary']);
        Add('FReceiveNetWeight', FListB.Values['FReceiveNetWeight']);
        Add('FReceiveNetWeight_Auxiliary', FListB.Values['FReceiveNetWeight_Auxiliary']);

        Add('FConsignmentGrossWeight', FListB.Values['FConsignmentGrossWeight']);
        Add('FConsignmentGrossWeight_Auxiliary', FListB.Values['FConsignmentGrossWeight_Auxiliary']);
        Add('FConsignmentTare', FListB.Values['FConsignmentTare']);
        Add('FConsignmentTare_Auxiliary', FListB.Values['FConsignmentTare_Auxiliary']);
        Add('FConsignmentNetWeight', FListB.Values['FConsignmentNetWeight']);
        Add('FConsignmentNetWeight_Auxiliary', FListB.Values['FConsignmentNetWeight_Auxiliary']);

        Add('FDock', FListB.Values['FDock']);//???
        Add('FConveyanceNumber', FListB.Values['FConveyanceNumber']);
        Add('FShipNumber', FListB.Values['FShipNumber']);

        Add('FMaterialSettlementFashion', FListB.Values['FMaterialSettlementFashion']);
        Add('FMaterialSettlementRate', FListB.Values['FMaterialSettlementRate']);
        Add('FFreightSettlementFashion', FListB.Values['FFreightSettlementFashion']);
        Add('FFreightSettlementRate', FListB.Values['FFreightSettlementRate']);

        Add('FArrivePortBillID', FListB.Values['FArrivePortBillID']);//???
        Add('FDisembarkFlag', FListB.Values['FDisembarkFlag']);//???
        Add('FEntryFactoryWeighFashion', FListB.Values['FEntryFactoryWeighFashion']);//???
        Add('FDisembarkGetAmountFashion', FListB.Values['FDisembarkGetAmountFashion']);//???

        Add('FGrossWeightStatus_Consignment', FListB.Values['FGrossWeightStatus_Consignment']);
        Add('FGrossWeightPersonnel_Consignment', FListB.Values['FGrossWeightPersonnel_Consignment']);
        Add('FGrossWeightTime_Consignment', FListB.Values['FGrossWeightTime_Consignment']);
        Add('FTareStatus_Consignment', FListB.Values['FTareStatus_Consignment']);
        Add('FTarePersonnel_Consignment', FListB.Values['FTarePersonnel_Consignment']);
        Add('FTareTime_Consignment ', FListB.Values['FTareTime_Consignment']);

        Add('FGrossWeightStatus', FListB.Values['FGrossWeightStatus']);
        Add('FGrossWeightPersonnel', FListB.Values['FGrossWeightPersonnel']);
        Add('FGrossWeightTime', FListB.Values['FGrossWeightTime']);
        Add('FAgainWeightStatus', FListB.Values['FAgainWeightStatus']);//???
        Add('FTareStatus', FListB.Values['FTareStatus']);
        Add('FTarePersonnel', FListB.Values['FTarePersonnel']);
        Add('FTareTime ', FListB.Values['FTareTime']);

        Add('FIsManpowerUnload', FListB.Values['FIsManpowerUnload']);//???
        Add('FUnloadMoney', FListB.Values['FUnloadMoney']);//???

        Add('FReceivePersonnel', FListB.Values['FReceivePersonnel']);
        Add('FReceiveTime', FListB.Values['FReceiveTime']);

        Add('FMaterialSettlementStatus', FListB.Values['FMaterialSettlementStatus']);//???
        Add('FMaterialSettlementPersonnel', FListB.Values['FMaterialSettlementPersonnel']);//???
        Add('FMaterialSettlementTime', FListB.Values['FMaterialSettlementTime']);//???
        Add('FFreightSettlementStatus', FListB.Values['FFreightSettlementStatus']);//???
        Add('FFreightSettlementPersonnel', FListB.Values['FFreightSettlementPersonnel']);//???
        Add('FFreightSettlementTime', FListB.Values['FFreightSettlementTime']);//???

        Add('FDataStatus', FListB.Values['FDataStatus']);
        Add('FUnloadMoney', FListB.Values['FUnloadMoney']);//???
        Add('FIsManpowerUnload', FListB.Values['FIsManpowerUnload']);//???
        Add('FMaterialStockInStatus', FListB.Values['FMaterialStockInStatus']);//???
        Add('FFreightStockInStatus', FListB.Values['FFreightStockInStatus']);//???
        Add('FLabStatus', FListB.Values['FLabStatus']);//???
        Add('FStatus', FListB.Values['FStatus']);

        Add('FCancelStatus', FListB.Values['FCancelStatus']);
        Add('FCancelPersonnel', FListB.Values['FCancelPersonnel']);
        Add('FCancelTime', FListB.Values['FCancelTime']);
        Add('FCreator', FListB.Values['FCreator']);
        Add('FCreateTime', FListB.Values['FCreateTime']);

        Add('FRemark', FListB.Values['FRemark']);
        Add('FVer', FListB.Values['FVer']);
      end;

      nInit := TlkJSON.GenerateText(nJSInit);
      nInit := UTF8Decode(nInit);
      WriteLog('��ͨԭ���ϲɹ����ϴ�ԭʼ����:' + nInit);

      nJSNew := TlkJSONobject.Create();

      with nJSNew do
      begin
        Add('FBillID', FListB.Values['FBillID']);//�����ID
        Add('FBillNumber', FListA.Values['FBillID']);//�������
        Add('FBillTypeID', '36');
        Add('FCompanyID', FListC.Values['FCompanyID']);
        Add('FUseDepartmentID', FListC.Values['FUseDepartmentID']);

        Add('FDepotID', FListA.Values['FDepotID']);//???
        Add('FYearPeriod', FListC.Values['FYearPeriod']);
        Add('FMaterielID', FListC.Values['FMaterielID']);
        Add('FUnitID', FListC.Values['FUnitID']);
        Add('FUnitID_Auxiliary', FListC.Values['FUnitID_Auxiliary']);

        Add('FUnitIsFloat', FListC.Values['FUnitIsFloat']);
        Add('FUnitCoefficient', FListC.Values['FUnitCoefficient']);
        Add('FValueID', FListC.Values['FValueID']);

        Add('FEntryPlanID', FListC.Values['FEntryPlanID']);
        Add('FRequirementPlanID', FListC.Values['FRequirementPlanID']);
        Add('FRequirementPlanDetailID', FListC.Values['FRequirementPlanDetailID']);

        Add('FMaterialProviderID', FListC.Values['FMaterialProviderID']);
        Add('FMaterialContractDetailID', FListC.Values['FMaterialContractDetailID']);
        Add('FProducerID', FListC.Values['FProducerID']);

        Add('FMaterialPriceTax', FListC.Values['FMaterialPriceTax']);
        Add('FMaterialMoneyTax', GetMoney(FListC.Values['FMaterialPriceTax'],
                                    FListA.Values['FReceiveNetWeight']));

        Add('FMaterialInvoiceTypeID', FListC.Values['FMaterialInvoiceTypeID']);
        Add('FMaterialInvoiceClassID', FListC.Values['FMaterialInvoiceClassID']);
        Add('FMaterialTaxRate', FListC.Values['FMaterialTaxRate']);

        Add('FMaterialPrice', FListC.Values['FMaterialPrice']);
        Add('FMaterialMoney', GetMoney(FListC.Values['FMaterialPrice'],
                                    FListA.Values['FReceiveNetWeight']));

        Add('FFreightProviderID', FListC.Values['FFreightProviderID']);
        Add('FFreightContractDetailID', FListC.Values['FFreightContractDetailID']);

        Add('FFreightPriceTax', FListC.Values['FFreightPriceTax']);
        Add('FFreightMoneyTax', GetMoney(FListC.Values['FFreightPriceTax'],
                                    FListA.Values['FReceiveNetWeight']));

        Add('FFreightInvoiceTypeID', FListC.Values['FFreightInvoiceTypeID']);
        Add('FFreightInvoiceClassID', FListC.Values['FFreightInvoiceClassID']);
        Add('FFreightTaxRate', FListC.Values['FFreightTaxRate']);

        Add('FFreightPrice', FListC.Values['FFreightPrice']);
        Add('FFreightMoney', GetMoney(FListC.Values['FFreightPrice'],
                                    FListA.Values['FReceiveNetWeight']));

        Add('FBillAmount', FListA.Values['FReceiveNetWeight']);
        Add('FBillAmount_Auxiliary', FListA.Values['FReceiveNetWeight']);
        Add('FReceiveGrossWeight', FListA.Values['FReceiveGrossWeight']);
        Add('FReceiveGrossWeight_Auxiliary', FListA.Values['FReceiveGrossWeight']);
        Add('FReceiveTare', FListA.Values['FReceiveTare']);
        Add('FReceiveTare_Auxiliary', FListA.Values['FReceiveTare']);
        Add('FImpurity', FListA.Values['FImpurity']);
        Add('FImpurity_Auxiliary', FListA.Values['FImpurity']);
        Add('FDeductAmount', FListA.Values['FDeductAmount']);
        Add('FDeductAmount_Auxiliary', FListA.Values['FDeductAmount']);
        Add('FReceiveNetWeight', FListA.Values['FReceiveNetWeight']);
        Add('FReceiveNetWeight_Auxiliary', FListA.Values['FReceiveNetWeight']);

        Add('FConsignmentGrossWeight', FListA.Values['FReceiveGrossWeight']);
        Add('FConsignmentGrossWeight_Auxiliary', FListA.Values['FReceiveGrossWeight']);
        Add('FConsignmentTare', FListA.Values['FReceiveTare']);
        Add('FConsignmentTare_Auxiliary', FListA.Values['FReceiveTare']);
        Add('FConsignmentNetWeight', FListA.Values['FReceiveNetWeight']);
        Add('FConsignmentNetWeight_Auxiliary', FListA.Values['FReceiveNetWeight']);

        Add('FDock', FListA.Values['FDock']);
        Add('FConveyanceNumber', FListA.Values['FConveyanceNumber']);
        Add('FShipNumber', FListA.Values['FShipNumber']);

        Add('FMaterialSettlementFashion', FListC.Values['FMaterialSettlementFashion']);
        Add('FMaterialSettlementRate', FListC.Values['FMaterialSettlementRate']);
        Add('FFreightSettlementFashion', FListC.Values['FFreightSettlementFashion']);
        Add('FFreightSettlementRate', FListC.Values['FFreightSettlementRate']);

        Add('FArrivePortBillID', '-1');
        Add('FDisembarkFlag', '0');
        Add('FEntryFactoryWeighFashion', '0');
        Add('FDisembarkGetAmountFashion', '0');

        Add('FGrossWeightStatus_Consignment', FListA.Values['FGrossWeightStatus']);
        Add('FGrossWeightPersonnel_Consignment', FListA.Values['FGrossWeightPersonnel']);
        Add('FGrossWeightTime_Consignment', FListA.Values['FGrossWeightTime']);
        Add('FTareStatus_Consignment', FListA.Values['FTareStatus']);
        Add('FTarePersonnel_Consignment', FListA.Values['FTarePersonnel']);
        Add('FTareTime_Consignment ', FListA.Values['FTareTime']);

        Add('FGrossWeightStatus', FListA.Values['FGrossWeightStatus']);
        Add('FGrossWeightPersonnel', FListA.Values['FGrossWeightPersonnel']);
        Add('FGrossWeightTime', FListA.Values['FGrossWeightTime']);
        Add('FAgainWeightStatus', '0');
        Add('FTareStatus', FListA.Values['FTareStatus']);
        Add('FTarePersonnel', FListA.Values['FTarePersonnel']);
        Add('FTareTime ', FListA.Values['FTareTime']);

        Add('FIsManpowerUnload', '0');
        Add('FUnloadMoney', '0');

        Add('FReceivePersonnel', FListA.Values['FTarePersonnel']);
        Add('FReceiveTime', FListA.Values['FReceiveTime']);

        Add('FMaterialSettlementStatus', '0');
        Add('FMaterialSettlementPersonnel', '');
        Add('FMaterialSettlementTime', '');
        Add('FFreightSettlementStatus', '0');
        Add('FFreightSettlementPersonnel', '');
        Add('FFreightSettlementTime', '');

        Add('FDataStatus', FListA.Values['FDataStatus']);
        Add('FUnloadMoney', '0');
        Add('FIsManpowerUnload', '0');
        Add('FMaterialStockInStatus', FListA.Values['FMaterialStockInStatus']);
        Add('FFreightStockInStatus', FListA.Values['FFreightStockInStatus']);
        Add('FLabStatus', FListA.Values['FLabStatus']);
        Add('FStatus', FListA.Values['FStatus']);

        Add('FCancelStatus', FListA.Values['FCancelStatus']);
        Add('FCancelPersonnel', FListA.Values['FCancelPersonnel']);
        Add('FCancelTime', FListA.Values['FCancelTime']);
        Add('FCreator', FListA.Values['FCreator']);
        Add('FCreateTime', FListA.Values['FCreateTime']);

        Add('FRemark', FListC.Values['FRemark']);
        Add('FVer', FListC.Values['FVer']);
      end;
      nNewStr := TlkJSON.GenerateText(nJSNew);
      nNewStr := UTF8Decode(nNewStr);
      WriteLog('��ͨԭ���ϲɹ����ϴ���ǰ����:' + nNewStr);
    end
    else
    begin
      if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhOrderDetailID,
           '','',@nOut) then
      begin
        Result := '[' + nLID + ']��ȡ������ͨԭ���ϲɹ���IDʧ��.';
        Exit;
      end;

      nStr := PackerDecodeStr(nOut.FData);
      nJSNew := TlkJSONobject.Create();

      with nJSNew do
      begin
        Add('FBillID', nStr);//�����ID
        Add('FBillNumber', FListA.Values['FBillID']);//�������
        Add('FBillTypeID', '36');
        Add('FCompanyID', FListC.Values['FCompanyID']);
        Add('FUseDepartmentID', FListC.Values['FUseDepartmentID']);

        Add('FDepotID', FListA.Values['FDepotID']);//???
        Add('FYearPeriod', FListC.Values['FYearPeriod']);
        Add('FMaterielID', FListC.Values['FMaterielID']);
        Add('FUnitID', FListC.Values['FUnitID']);
        Add('FUnitID_Auxiliary', FListC.Values['FUnitID_Auxiliary']);

        Add('FUnitIsFloat', FListC.Values['FUnitIsFloat']);
        Add('FUnitCoefficient', FListC.Values['FUnitCoefficient']);
        Add('FValueID', FListC.Values['FValueID']);

        Add('FEntryPlanID', FListC.Values['FEntryPlanID']);
        Add('FRequirementPlanID', FListC.Values['FRequirementPlanID']);
        Add('FRequirementPlanDetailID', FListC.Values['FRequirementPlanDetailID']);

        Add('FMaterialProviderID', FListC.Values['FMaterialProviderID']);
        Add('FMaterialContractDetailID', FListC.Values['FMaterialContractDetailID']);
        Add('FProducerID', FListC.Values['FProducerID']);

        Add('FMaterialPriceTax', FListC.Values['FMaterialPriceTax']);
        Add('FMaterialMoneyTax', GetMoney(FListC.Values['FMaterialPriceTax'],
                                    FListA.Values['FReceiveNetWeight']));

        Add('FMaterialInvoiceTypeID', FListC.Values['FMaterialInvoiceTypeID']);
        Add('FMaterialInvoiceClassID', FListC.Values['FMaterialInvoiceClassID']);
        Add('FMaterialTaxRate', FListC.Values['FMaterialTaxRate']);

        Add('FMaterialPrice', FListC.Values['FMaterialPrice']);
        Add('FMaterialMoney', GetMoney(FListC.Values['FMaterialPrice'],
                                    FListA.Values['FReceiveNetWeight']));

        Add('FFreightProviderID', FListC.Values['FFreightProviderID']);
        Add('FFreightContractDetailID', FListC.Values['FFreightContractDetailID']);

        Add('FFreightPriceTax', FListC.Values['FFreightPriceTax']);
        Add('FFreightMoneyTax', GetMoney(FListC.Values['FFreightPriceTax'],
                                    FListA.Values['FReceiveNetWeight']));

        Add('FFreightInvoiceTypeID', FListC.Values['FFreightInvoiceTypeID']);
        Add('FFreightInvoiceClassID', FListC.Values['FFreightInvoiceClassID']);
        Add('FFreightTaxRate', FListC.Values['FFreightTaxRate']);

        Add('FFreightPrice', FListC.Values['FFreightPrice']);
        Add('FFreightMoney', GetMoney(FListC.Values['FFreightPrice'],
                                    FListA.Values['FReceiveNetWeight']));

        Add('FBillAmount', FListA.Values['FReceiveNetWeight']);
        Add('FBillAmount_Auxiliary', FListA.Values['FReceiveNetWeight']);
        Add('FReceiveGrossWeight', FListA.Values['FReceiveGrossWeight']);
        Add('FReceiveGrossWeight_Auxiliary', FListA.Values['FReceiveGrossWeight']);
        Add('FReceiveTare', FListA.Values['FReceiveTare']);
        Add('FReceiveTare_Auxiliary', FListA.Values['FReceiveTare']);
        Add('FImpurity', FListA.Values['FImpurity']);
        Add('FImpurity_Auxiliary', FListA.Values['FImpurity']);
        Add('FDeductAmount', FListA.Values['FDeductAmount']);
        Add('FDeductAmount_Auxiliary', FListA.Values['FDeductAmount']);
        Add('FReceiveNetWeight', FListA.Values['FReceiveNetWeight']);
        Add('FReceiveNetWeight_Auxiliary', FListA.Values['FReceiveNetWeight']);

        Add('FConsignmentGrossWeight', FListA.Values['FReceiveGrossWeight']);
        Add('FConsignmentGrossWeight_Auxiliary', FListA.Values['FReceiveGrossWeight']);
        Add('FConsignmentTare', FListA.Values['FReceiveTare']);
        Add('FConsignmentTare_Auxiliary', FListA.Values['FReceiveTare']);
        Add('FConsignmentNetWeight', FListA.Values['FReceiveNetWeight']);
        Add('FConsignmentNetWeight_Auxiliary', FListA.Values['FReceiveNetWeight']);

        Add('FDock', FListA.Values['FDock']);
        Add('FConveyanceNumber', FListA.Values['FConveyanceNumber']);
        Add('FShipNumber', FListA.Values['FShipNumber']);

        Add('FMaterialSettlementFashion', FListC.Values['FMaterialSettlementFashion']);
        Add('FMaterialSettlementRate', FListC.Values['FMaterialSettlementRate']);
        Add('FFreightSettlementFashion', FListC.Values['FFreightSettlementFashion']);
        Add('FFreightSettlementRate', FListC.Values['FFreightSettlementRate']);

        Add('FArrivePortBillID', '-1');
        Add('FDisembarkFlag', '0');
        Add('FEntryFactoryWeighFashion', '0');
        Add('FDisembarkGetAmountFashion', '0');

        Add('FGrossWeightStatus_Consignment', FListA.Values['FGrossWeightStatus']);
        Add('FGrossWeightPersonnel_Consignment', FListA.Values['FGrossWeightPersonnel']);
        Add('FGrossWeightTime_Consignment', FListA.Values['FGrossWeightTime']);
        Add('FTareStatus_Consignment', FListA.Values['FTareStatus']);
        Add('FTarePersonnel_Consignment', FListA.Values['FTarePersonnel']);
        Add('FTareTime_Consignment ', FListA.Values['FTareTime']);

        Add('FGrossWeightStatus', FListA.Values['FGrossWeightStatus']);
        Add('FGrossWeightPersonnel', FListA.Values['FGrossWeightPersonnel']);
        Add('FGrossWeightTime', FListA.Values['FGrossWeightTime']);
        Add('FAgainWeightStatus', '0');
        Add('FTareStatus', FListA.Values['FTareStatus']);
        Add('FTarePersonnel', FListA.Values['FTarePersonnel']);
        Add('FTareTime ', FListA.Values['FTareTime']);

        Add('FIsManpowerUnload', '0');
        Add('FUnloadMoney', '0');

        Add('FReceivePersonnel', FListA.Values['FTarePersonnel']);
        Add('FReceiveTime', FListA.Values['FReceiveTime']);

        Add('FMaterialSettlementStatus', '0');
        Add('FMaterialSettlementPersonnel', '');
        Add('FMaterialSettlementTime', '');
        Add('FFreightSettlementStatus', '0');
        Add('FFreightSettlementPersonnel', '');
        Add('FFreightSettlementTime', '');

        Add('FDataStatus', FListA.Values['FDataStatus']);
        Add('FUnloadMoney', '0');
        Add('FIsManpowerUnload', '0');
        Add('FMaterialStockInStatus', FListA.Values['FMaterialStockInStatus']);
        Add('FFreightStockInStatus', FListA.Values['FFreightStockInStatus']);
        Add('FLabStatus', FListA.Values['FLabStatus']);
        Add('FStatus', FListA.Values['FStatus']);

        Add('FCancelStatus', FListA.Values['FCancelStatus']);
        Add('FCancelPersonnel', FListA.Values['FCancelPersonnel']);
        Add('FCancelTime', FListA.Values['FCancelTime']);
        Add('FCreator', FListA.Values['FCreator']);
        Add('FCreateTime', FListA.Values['FCreateTime']);

        Add('FRemark', FListC.Values['FRemark']);
        Add('FVer', FListC.Values['FVer']);
      end;
      nNewStr := TlkJSON.GenerateText(nJSNew);
      nNewStr := UTF8Decode(nNewStr);
      WriteLog('��ͨԭ���ϲɹ����ϴ���ǰ����:' + nNewStr);
    end;
  finally
    if Assigned(nJSInit) then
      nJSInit.Free;
    if Assigned(nJSNew) then
      nJSNew.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhNdOrderPlan(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
    nValue: Double;
begin
  Result := False;
  nUrl := '';
  nStr := PackerDecodeStr(FIn.FData);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        if nStr = '' then
          nStr := FDefWhere
        else
        if FDefWhere <> '' then
          nStr := nStr + ' And ' + FDefWhere;
        Break;
      end;
    end;

    WriteLog('��ȡ�ڵ�ԭ���϶������'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

        FChannel := CoV_SupplyMaterialTransferPlan.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_SupplyMaterialTransferPlan(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                            nStr, '');

    if Pos('FBillNumber', PackerDecodeStr(FIn.FData)) > 0 then
      WriteLog('��ȡ�ڵ�ԭ���϶�������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ�ڵ�ԭ���϶����ӿڵ����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡ�ڵ�ԭ���϶����ӿڵ����쳣.' + FIn.FData + 'Data�ڵ�Ϊ��';
        WriteLog(nData);
        Exit;
      end;

      if Pos('FBillNumber', PackerDecodeStr(FIn.FData)) > 0 then
      begin
        for nIdx := 0 to nJSRow.Count - 1 do
        begin
          nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

          FListE.Clear;
          for nInt := 0 to nJSCol.Count - 1 do
          begin
            FListE.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
          end;
          nData := PackerEncodeStr(FListE.Text);
        end;
      end
      else
      begin
        FListA.Clear;
        FListC.Clear;
        for nIdx := 0 to nJSRow.Count - 1 do
        begin
          nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

          FListB.Clear;
          FListC.Clear;
          for nInt := 0 to nJSCol.Count - 1 do
          begin
            FListC.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
          end;

          with FListB do
          begin
            Values['Order']         := FListC.Values['FBillNumber'];
            Values['StockName']     := FListC.Values['FMaterielName'];
            Values['StockID']       := FListC.Values['FMaterielID'];
            Values['StockNo']       := FListC.Values['FMaterielNumber'];
            try
              nValue := StrToFloat(FListC.Values['FApproveAmount'])
                        - StrToFloat(FListC.Values['FExecuteAmount']);
              nValue := Float2PInt(nValue, cPrecision, False) / cPrecision;
            except
              nValue := 0;
            end;
            Values['PlanValue']     := FListC.Values['FApproveAmount'];//������
            Values['EntryValue']    := FListC.Values['FExecuteAmount'];//�ѽ�����
            Values['Value']         := FloatToStr(nValue);//ʣ����
            Values['Model']         := FListC.Values['FModel'];//�ͺ�

            FListA.Add(PackerEncodeStr(FListB.Text));
          end;
        end;
        nData := PackerEncodeStr(FListA.Text);
      end;
    end
    else
    begin
      nData := '��ȡ�ڵ�ԭ���϶����ӿڵ����쳣.Data�ڵ��쳣';
      WriteLog(nData);
      Exit;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.IsHhNdOrderDetailExits(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Clear;
  nStr := 'FBillNumber = ''%s''';
  nStr := Format(nStr,[PackerDecodeStr(FIn.FData)]);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('��ѯ���ϴ��ڵ�ԭ���ϲɹ������'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyMaterialTransferBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SupplyMaterialTransferBill(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                   nStr, '');

    WriteLog('��ѯ���ϴ��ڵ�ԭ���ϲɹ�������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ѯ���ϴ��ڵ�ԭ���ϲɹ��������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ѯ���ϴ��ڵ�ԭ���ϲɹ��������쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListA.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
      end;
    end;
    nData := PackerEncodeStr(FListA.Text);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhNdOrderDetailID(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListE.Clear;

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('��ȡ�����ڵ�ԭ���ϲɹ���ID���'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyMaterialTransferBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SupplyMaterialTransferBill(nHHJYChannel^.FChannel).InitializationModel(nSoapHeader);

    WriteLog('��ȡ�����ڵ�ԭ���ϲɹ���ID����'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ�����ڵ�ԭ���ϲɹ���ID�����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    nJsCol := nJS.Field['Data'] as TlkJSONobject;

    nStr := VarToStr(nJSCol.Field['FBillID'].Value);

    if nStr = '' then
    begin
      nData := '��ȡ�����ڵ�ԭ���ϲɹ���ID�ӿڵ����쳣.Data�ڵ�FBillIDΪ��';
      Exit;
    end;

    nData := PackerEncodeStr(nStr);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhNdOrderDetail(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
    nExits: Boolean;
    nInitStr, nNewStr: string;
begin
  Result := False;
  nExits := False;
  nUrl := '';
  FListD.Text := PackerDecodeStr(FIn.FData);

  WriteLog('ͬ���ڵ�ԭ���ϲɹ���׼���������:' + FListD.Text);

  nData := GetNdOrderDetailJSonString(FListD.Values['ID'], FListD.Values['Delete'], nExits,
                                    nInitStr, nNewStr);
  if nData <> '' then
  begin
    WriteLog('ͬ���ڵ�ԭ���ϲɹ���׼�����ݽ��:' + nData);
    Exit;
  end;

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('ͬ���ڵ�ԭ���ϲɹ������'+FListD.Text);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyMaterialTransferBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel

    if nExits then
    begin
      nStr := IT_SupplyMaterialTransferBill(nHHJYChannel^.FChannel).Update(nSoapHeader,
                                     nInitStr, nNewStr);
    end
    else
    begin
      nStr := IT_SupplyMaterialTransferBill(nHHJYChannel^.FChannel).Insert(nSoapHeader,
                                     nNewStr);
    end;

    WriteLog('ͬ���ڵ�ԭ���ϲɹ�������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := 'ͬ���ڵ�ԭ���ϲɹ��������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    nStr :='update %s set P_BDAX=''1'',P_BDNUM=P_BDNUM+1 where P_ID = ''%s'' ';
    nStr := Format(nStr,[sTable_PoundLog,FListD.Values['ID']]);

    gDBConnManager.WorkerExec(FDBConn,nStr);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetNdOrderDetailJSonString(const nLID, nDelete: string;
 var nExits: Boolean; var nInit, nNewStr: string): string;
var nStr, nSQL, nUrl, nDate: string;
    nInt, nIdx: Integer;
    nJSInit, nJSNew: TlkJSONobject;
    nOut: TWorkerBusinessCommand;
    nPDate, nMDate: TDateTime;
begin
  Result := '';
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;

  nExits := TBusWorkerBusinessHHJY.CallMe(cBC_IsHhNdOrderDetailExits
           ,PackerEncodeStr(nLID),'',@nOut);
  if nExits then
    FListB.Text := PackerDecodeStr(nOut.FData);

  if nExits and (nDelete = sFlag_Yes) then
  begin
    if FListB.Values['FStatus'] = '254' then
    begin
      Result := '������[ %s ]�����,�޷�ɾ��,����ERP�Ƚ��з����.';
      Result := Format(Result, [nLID]);
      Exit;
    end;
  end;
  
  nSQL := 'select *,(P_MValue-P_PValue - isnull(P_KZValue,0)) as D_NetWeight From %s a,'+
  ' %s b, %s c where a.D_OID=b.O_ID and a.D_ID=c.P_OrderBak and c.P_ID = ''%s'' ';

  nSQL := Format(nSQL,[sTable_OrderDtl,sTable_Order,sTable_PoundLog,nLID]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  begin
    if RecordCount < 1 then
    begin
      Result := '������Ϊ[ %s ]�Ĳɹ�����������.';
      Result := Format(Result, [nLID]);
      Exit;
    end;

    FListA.Clear;

    FListA.Values['FTransferPlanNumber']    := FieldByName('P_BID').AsString;
    FListA.Values['FBillID']                := FieldByName('P_ID').AsString;
    FListA.Values['FBillNumber']            := FieldByName('P_ID').AsString;
    FListA.Values['FPoundID']               := FieldByName('P_ID').AsString;
    FListA.Values['FAuditID']               := FieldByName('P_ID').AsString;
    FListA.Values['FBillTypeID']            := '49';

    FListA.Values['FConsignmentGrossWeightStatus']     := '1';
    FListA.Values['FConsignmentGrossWeightPersonnel']  := FieldByName('P_MMan').AsString;
    FListA.Values['FConsignmentGrossWeightTime']       := FieldByName('P_MDate').AsString;

    if FieldByName('P_MValue').AsString = '' then
      FListA.Values['FConsignmentGrossWeight']    := '0'
    else
      FListA.Values['FConsignmentGrossWeight']    := FieldByName('P_MValue').AsString;

    FListA.Values['FConsignmentStatus']         := '1';
    FListA.Values['FConsignmentPersonnel']      := FieldByName('P_MMan').AsString;
    try
      nPDate := FieldByName('P_PDate').AsDateTime;
      nMDate := FieldByName('P_MDate').AsDateTime;
      if nMDate > nPDate then
        nDate := FieldByName('P_MDate').AsString
      else
        nDate := FieldByName('P_PDate').AsString;
    except
        nDate := FieldByName('P_PDate').AsString;
    end;

    FListA.Values['FConsignmentTime']           := nDate;

    FListA.Values['FConsignmentTareStatus']            := '1';
    FListA.Values['FConsignmentTarePersonnel']         := FieldByName('P_PMan').AsString;
    FListA.Values['FConsignmentTareTime']              := FieldByName('P_PDate').AsString;

    if FieldByName('P_PValue').AsString = '' then
      FListA.Values['FConsignmentTare']    := '0'
    else
      FListA.Values['FConsignmentTare']    := FieldByName('P_PValue').AsString;

    if FieldByName('D_NetWeight').AsString = '' then
      FListA.Values['FConsignmentNetWeight']    := '0'
    else
      FListA.Values['FConsignmentNetWeight']    := FieldByName('D_NetWeight').AsString;

    FListA.Values['FReceiveGrossWeightStatus']     := '1';
    FListA.Values['FReceiveGrossWeightPersonnel']  := FieldByName('P_MMan').AsString;
    FListA.Values['FReceiveGrossWeightTime']       := FieldByName('P_MDate').AsString;

    if FieldByName('P_MValue').AsString = '' then
      FListA.Values['FReceiveGrossWeight']    := '0'
    else
      FListA.Values['FReceiveGrossWeight']    := FieldByName('P_MValue').AsString;

    FListA.Values['FReceiveStatus']         := '1';
    FListA.Values['FReceivePersonnel']      := FieldByName('P_MMan').AsString;
    FListA.Values['FReceiveTime']           := nDate;

    FListA.Values['FReceiveTareStatus']            := '1';
    FListA.Values['FReceiveTarePersonnel']         := FieldByName('P_PMan').AsString;
    FListA.Values['FReceiveTareTime']              := FieldByName('P_PDate').AsString;

    if FieldByName('P_PValue').AsString = '' then
      FListA.Values['FReceiveTare']    := '0'
    else
      FListA.Values['FReceiveTare']    := FieldByName('P_PValue').AsString;

    if FieldByName('D_NetWeight').AsString = '' then
      FListA.Values['FReceiveNetWeight']    := '0'
    else
      FListA.Values['FReceiveNetWeight']    := FieldByName('D_NetWeight').AsString;

    FListA.Values['FCreator']               := FieldByName('P_PMan').AsString;
    FListA.Values['FCreateTime']            := nDate;
    FListA.Values['FConveyanceNumber']      := FieldByName('P_Truck').AsString;
    FListA.Values['FStatus']                := '254';
    if nDelete = sFlag_Yes then
    begin
      FListA.Values['FCancelStatus']        := '1';
      FListA.Values['FCancelPersonnel']     := FieldByName('P_PMan').AsString;
      FListA.Values['FCancelTime']          := nDate;
    end
    else
      FListA.Values['FCancelStatus']          := '0';

    FListA.Values['FDataStatus']            := '0';
  end;

  if FListA.Values['FTransferPlanNumber'] = '' then
  begin
    Result := '�ڵ�ԭ���ϲɹ�����[ %s ]��ǰ������Ϊ��.';
    Result := Format(Result, [nLID]);
    Exit;
  end;

  nSQL := 'FBillNumber = ''%s''';
  nSQL := Format(nSQL, [FListA.Values['FTransferPlanNumber']]);

  if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhNeiDaoOrderPlan
           ,PackerEncodeStr(nSQL),'',@nOut) then
  begin
    Result := '�ڵ�ԭ���ϲɹ�����[ %s ]��ȡ��ǰ����[ %s ]��Ϣʧ��.';
    Result := Format(Result, [nLID, FListA.Values['FTransferPlanNumber']]);
    Exit;
  end;

  FListC.Text := PackerDecodeStr(nOut.FData);

  try
    if nExits then//���ϴ�
    begin
      nJSInit := TlkJSONobject.Create();

      with nJSInit do//ԭʼ����
      begin
        Add('FBillID', FListB.Values['FBillID']);//�����ID
        Add('FBillNumber', FListA.Values['FBillID']);//�������
        Add('FBillTypeID', '49');
        Add('FCompanyID', FListB.Values['FCompanyID']);

        Add('FTransferPlanID', FListB.Values['FBillID']);
        Add('FYearPeriod', FListB.Values['FYearPeriod']);
        Add('FMaterielID', FListB.Values['FMaterielID']);
        Add('FValueID', FListB.Values['FValueID']);

        Add('FUnitID', FListB.Values['FUnitID']);
        Add('FUnitID_Auxiliary', FListB.Values['FUnitID_Auxiliary']);
        Add('FUnitIsFloat', FListB.Values['FUnitIsFloat']);
        Add('FUnitCoefficient', FListB.Values['FUnitCoefficient']);

        Add('FProducerID', FListB.Values['FProducerID']);
        Add('FFreightProviderID', FListB.Values['FFreightProviderID']);
        Add('FFreightContractDetailID', FListB.Values['FFreightContractDetailID']);
        Add('FConveyanceNumber', FListB.Values['FConveyanceNumber']);

        Add('FFreightPriceTax', FListB.Values['FFreightPriceTax']);
        Add('FFreightMoneyTax', FListB.Values['FFreightMoneyTax']);

        Add('FFreightInvoiceTypeID', FListB.Values['FFreightInvoiceTypeID']);
        Add('FFreightInvoiceClassID', FListB.Values['FFreightInvoiceClassID']);
        Add('FFreightTaxRate', FListB.Values['FFreightTaxRate']);

        Add('FFreightPrice', FListB.Values['FFreightPrice']);
        Add('FFreightMoney', FListB.Values['FFreightMoney']);

        Add('FFreightSettlementFashion', FListB.Values['FFreightSettlementFashion']);
        Add('FFreightSettlementStatus', FListB.Values['FFreightSettlementStatus']);//???
        Add('FWeightFashion', FListB.Values['FWeightFashion']);

        Add('FConsignmentDepartmentID', FListB.Values['FConsignmentDepartmentID']);
        Add('FConsignmentDepotID', FListB.Values['FConsignmentDepotID']);
        Add('FConsignmentGrossWeight', FListB.Values['FConsignmentGrossWeight']);
        Add('FConsignmentGrossWeight_Auxiliary', FListB.Values['FConsignmentGrossWeight']);
        Add('FConsignmentTare', FListB.Values['FConsignmentTare']);
        Add('FConsignmentTare_Auxiliary', FListB.Values['FConsignmentTare']);
        Add('FConsignmentNetWeight', FListB.Values['FConsignmentNetWeight']);
        Add('FConsignmentNetWeight_Auxiliary', FListB.Values['FConsignmentNetWeight']);
        Add('FConsignmentAgainWeightStatus', FListB.Values['FConsignmentAgainWeightStatus']);
        Add('FConsignmentGrossWeightStatus', FListB.Values['FConsignmentGrossWeightStatus']);
        Add('FConsignmentGrossWeightPersonnel', FListB.Values['FConsignmentGrossWeightPersonnel']);
        Add('FConsignmentGrossWeightTime', FListB.Values['FConsignmentGrossWeightTime']);
        Add('FConsignmentTareStatus', FListB.Values['FConsignmentTareStatus']);
        Add('FConsignmentTarePersonnel', FListB.Values['FConsignmentTarePersonnel']);
        Add('FConsignmentTareTime ', FListB.Values['FConsignmentTareTime']);
        Add('FConsignmentStatus', FListB.Values['FConsignmentStatus']);
        Add('FConsignmentPersonnel ', FListB.Values['FConsignmentPersonnel']);
        Add('FConsignmentTime', FListB.Values['FConsignmentTime']);

        Add('FReceiveDepartmentID', FListB.Values['FReceiveDepartmentID']);
        Add('FReceiveDepotID', FListB.Values['FReceiveDepotID']);
        Add('FReceiveGrossWeight', FListB.Values['FReceiveGrossWeight']);
        Add('FReceiveGrossWeight_Auxiliary', FListB.Values['FReceiveGrossWeight']);
        Add('FReceiveTare', FListB.Values['FReceiveTare']);
        Add('FReceiveTare_Auxiliary', FListB.Values['FReceiveTare']);
        Add('FReceiveNetWeight', FListB.Values['FReceiveNetWeight']);
        Add('FReceiveNetWeight_Auxiliary', FListB.Values['FReceiveNetWeight']);
        Add('FReceiveAgainWeightStatus', FListB.Values['FReceiveAgainWeightStatus']);
        Add('FReceiveGrossWeightStatus', FListB.Values['FReceiveGrossWeightStatus']);
        Add('FReceiveGrossWeightPersonnel', FListB.Values['FReceiveGrossWeightPersonnel']);
        Add('FReceiveGrossWeightTime', FListB.Values['FReceiveGrossWeightTime']);
        Add('FReceiveTareStatus', FListB.Values['FReceiveTareStatus']);
        Add('FReceiveTarePersonnel', FListB.Values['FReceiveTarePersonnel']);
        Add('FReceiveTareTime ', FListB.Values['FReceiveTareTime']);
        Add('FReceiveStatus', FListB.Values['FReceiveStatus']);
        Add('FReceivePersonnel ', FListB.Values['FReceivePersonnel']);
        Add('FReceiveTime', FListB.Values['FReceiveTime']);

        Add('FCancelStatus', FListB.Values['FCancelStatus']);
        Add('FCancelPersonnel', FListB.Values['FCancelPersonnel']);
        Add('FCancelTime', FListB.Values['FCancelTime']);
        Add('FCreator', FListB.Values['FCreator']);
        Add('FCreateTime', FListB.Values['FCreateTime']);

        Add('FRemark', FListB.Values['FRemark']);
        Add('FVer', FListB.Values['FVer']);
      end;

      nInit := TlkJSON.GenerateText(nJSInit);
      nInit := UTF8Decode(nInit);
      WriteLog('�ڵ�ԭ���ϲɹ����ϴ�ԭʼ����:' + nInit);

      nJSNew := TlkJSONobject.Create();

      with nJSNew do
      begin
        Add('FBillID', FListB.Values['FBillID']);//�����ID
        Add('FBillNumber', FListA.Values['FBillID']);//�������
        Add('FBillTypeID', '49');
        Add('FCompanyID', FListC.Values['FCompanyID']);

        Add('FTransferPlanID', FListC.Values['FBillID']);
        Add('FYearPeriod', FListC.Values['FYearPeriod']);
        Add('FMaterielID', FListC.Values['FMaterielID']);
        Add('FValueID', FListC.Values['FValueID']);

        Add('FUnitID', FListC.Values['FUnitID']);
        Add('FUnitID_Auxiliary', FListC.Values['FUnitID_Auxiliary']);
        Add('FUnitIsFloat', FListC.Values['FUnitIsFloat']);
        Add('FUnitCoefficient', FListC.Values['FUnitCoefficient']);

        Add('FProducerID', FListC.Values['FProducerID']);
        Add('FFreightProviderID', FListC.Values['FFreightProviderID']);
        Add('FFreightContractDetailID', FListC.Values['FFreightContractDetailID']);
        Add('FConveyanceNumber', FListA.Values['FConveyanceNumber']);

        Add('FFreightPriceTax', FListC.Values['FFreightPriceTax']);
        Add('FFreightMoneyTax', GetMoney(FListC.Values['FFreightPriceTax'],
                                    FListA.Values['FReceiveNetWeight']));

        Add('FFreightInvoiceTypeID', FListC.Values['FFreightInvoiceTypeID']);
        Add('FFreightInvoiceClassID', FListC.Values['FFreightInvoiceClassID']);
        Add('FFreightTaxRate', FListC.Values['FFreightTaxRate']);

        Add('FFreightPrice', FListC.Values['FFreightPrice']);
        Add('FFreightMoney', GetMoney(FListC.Values['FFreightPrice'],
                                    FListA.Values['FReceiveNetWeight']));

        Add('FFreightSettlementFashion', FListC.Values['FFreightSettlementFashion']);
        Add('FFreightSettlementStatus', '0');//???
        Add('FWeightFashion', FListC.Values['FWeightFashion']);

        Add('FConsignmentDepartmentID', FListC.Values['FConsignmentDepartmentID']);
        Add('FConsignmentDepotID', FListC.Values['FConsignmentDepotID']);
        Add('FConsignmentGrossWeight', FListA.Values['FConsignmentGrossWeight']);
        Add('FConsignmentGrossWeight_Auxiliary', FListA.Values['FConsignmentGrossWeight']);
        Add('FConsignmentTare', FListA.Values['FConsignmentTare']);
        Add('FConsignmentTare_Auxiliary', FListA.Values['FConsignmentTare']);
        Add('FConsignmentNetWeight', FListA.Values['FConsignmentNetWeight']);
        Add('FConsignmentNetWeight_Auxiliary', FListA.Values['FConsignmentNetWeight']);
        Add('FConsignmentAgainWeightStatus', '0');
        Add('FConsignmentGrossWeightStatus', FListA.Values['FConsignmentGrossWeightStatus']);
        Add('FConsignmentGrossWeightPersonnel', FListA.Values['FConsignmentGrossWeightPersonnel']);
        Add('FConsignmentGrossWeightTime', FListA.Values['FConsignmentGrossWeightTime']);
        Add('FConsignmentTareStatus', FListA.Values['FConsignmentTareStatus']);
        Add('FConsignmentTarePersonnel', FListA.Values['FConsignmentTarePersonnel']);
        Add('FConsignmentTareTime ', FListA.Values['FConsignmentTareTime']);
        Add('FConsignmentStatus', FListA.Values['FConsignmentStatus']);
        Add('FConsignmentPersonnel ', FListA.Values['FConsignmentPersonnel']);
        Add('FConsignmentTime', FListA.Values['FConsignmentTime']);

        Add('FReceiveDepartmentID', FListC.Values['FReceiveDepartmentID']);
        Add('FReceiveDepotID', FListC.Values['FReceiveDepotID']);
        Add('FReceiveGrossWeight', FListA.Values['FReceiveGrossWeight']);
        Add('FReceiveGrossWeight_Auxiliary', FListA.Values['FReceiveGrossWeight']);
        Add('FReceiveTare', FListA.Values['FReceiveTare']);
        Add('FReceiveTare_Auxiliary', FListA.Values['FReceiveTare']);
        Add('FReceiveNetWeight', FListA.Values['FReceiveNetWeight']);
        Add('FReceiveNetWeight_Auxiliary', FListA.Values['FReceiveNetWeight']);
        Add('FReceiveAgainWeightStatus', '0');
        Add('FReceiveGrossWeightStatus', FListA.Values['FReceiveGrossWeightStatus']);
        Add('FReceiveGrossWeightPersonnel', FListA.Values['FReceiveGrossWeightPersonnel']);
        Add('FReceiveGrossWeightTime', FListA.Values['FReceiveGrossWeightTime']);
        Add('FReceiveTareStatus', FListA.Values['FReceiveTareStatus']);
        Add('FReceiveTarePersonnel', FListA.Values['FReceiveTarePersonnel']);
        Add('FReceiveTareTime ', FListA.Values['FReceiveTareTime']);
        Add('FReceiveStatus', FListA.Values['FReceiveStatus']);
        Add('FReceivePersonnel ', FListA.Values['FReceivePersonnel']);
        Add('FReceiveTime', FListA.Values['FReceiveTime']);

        Add('FCancelStatus', FListA.Values['FCancelStatus']);
        Add('FCancelPersonnel', FListA.Values['FCancelPersonnel']);
        Add('FCancelTime', FListA.Values['FCancelTime']);
        Add('FCreator', FListA.Values['FCreator']);
        Add('FCreateTime', FListA.Values['FCreateTime']);

        Add('FRemark', FListC.Values['FRemark']);
        Add('FVer', FListC.Values['FVer']);
      end;
      nNewStr := TlkJSON.GenerateText(nJSNew);
      nNewStr := UTF8Decode(nNewStr);
      WriteLog('�ڵ�ԭ���ϲɹ����ϴ���ǰ����:' + nNewStr);
    end
    else
    begin
      if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhNdOrderDetailID,
           '','',@nOut) then
      begin
        Result := '[' + nLID + ']��ȡ�����ڵ�ԭ���ϲɹ���IDʧ��.';
        Exit;
      end;

      nStr := PackerDecodeStr(nOut.FData);
      nJSNew := TlkJSONobject.Create();

      with nJSNew do
      begin
        Add('FBillID', nStr);//�����ID
        Add('FBillNumber', FListA.Values['FBillID']);//�������
        Add('FBillTypeID', '49');
        Add('FCompanyID', FListC.Values['FCompanyID']);

        Add('FTransferPlanID', FListC.Values['FBillID']);
        Add('FYearPeriod', FListC.Values['FYearPeriod']);
        Add('FMaterielID', FListC.Values['FMaterielID']);
        Add('FValueID', FListC.Values['FValueID']);

        Add('FUnitID', FListC.Values['FUnitID']);
        Add('FUnitID_Auxiliary', FListC.Values['FUnitID_Auxiliary']);
        Add('FUnitIsFloat', FListC.Values['FUnitIsFloat']);
        Add('FUnitCoefficient', FListC.Values['FUnitCoefficient']);

        Add('FProducerID', FListC.Values['FProducerID']);
        Add('FFreightProviderID', FListC.Values['FFreightProviderID']);
        Add('FFreightContractDetailID', FListC.Values['FFreightContractDetailID']);
        Add('FConveyanceNumber', FListA.Values['FConveyanceNumber']);

        Add('FFreightPriceTax', FListC.Values['FFreightPriceTax']);
        Add('FFreightMoneyTax', GetMoney(FListC.Values['FFreightPriceTax'],
                                    FListA.Values['FReceiveNetWeight']));

        Add('FFreightInvoiceTypeID', FListC.Values['FFreightInvoiceTypeID']);
        Add('FFreightInvoiceClassID', FListC.Values['FFreightInvoiceClassID']);
        Add('FFreightTaxRate', FListC.Values['FFreightTaxRate']);

        Add('FFreightPrice', FListC.Values['FFreightPrice']);
        Add('FFreightMoney', GetMoney(FListC.Values['FFreightPrice'],
                                    FListA.Values['FReceiveNetWeight']));

        Add('FFreightSettlementFashion', FListC.Values['FFreightSettlementFashion']);
        Add('FFreightSettlementStatus', '0');//???
        Add('FWeightFashion', FListC.Values['FWeightFashion']);

        Add('FConsignmentDepartmentID', FListC.Values['FConsignmentDepartmentID']);
        Add('FConsignmentDepotID', FListC.Values['FConsignmentDepotID']);
        Add('FConsignmentGrossWeight', FListA.Values['FConsignmentGrossWeight']);
        Add('FConsignmentGrossWeight_Auxiliary', FListA.Values['FConsignmentGrossWeight']);
        Add('FConsignmentTare', FListA.Values['FConsignmentTare']);
        Add('FConsignmentTare_Auxiliary', FListA.Values['FConsignmentTare']);
        Add('FConsignmentNetWeight', FListA.Values['FConsignmentNetWeight']);
        Add('FConsignmentNetWeight_Auxiliary', FListA.Values['FConsignmentNetWeight']);
        Add('FConsignmentAgainWeightStatus', '0');
        Add('FConsignmentGrossWeightStatus', FListA.Values['FConsignmentGrossWeightStatus']);
        Add('FConsignmentGrossWeightPersonnel', FListA.Values['FConsignmentGrossWeightPersonnel']);
        Add('FConsignmentGrossWeightTime', FListA.Values['FConsignmentGrossWeightTime']);
        Add('FConsignmentTareStatus', FListA.Values['FConsignmentTareStatus']);
        Add('FConsignmentTarePersonnel', FListA.Values['FConsignmentTarePersonnel']);
        Add('FConsignmentTareTime ', FListA.Values['FConsignmentTareTime']);
        Add('FConsignmentStatus', FListA.Values['FConsignmentStatus']);
        Add('FConsignmentPersonnel ', FListA.Values['FConsignmentPersonnel']);
        Add('FConsignmentTime', FListA.Values['FConsignmentTime']);

        Add('FReceiveDepartmentID', FListC.Values['FReceiveDepartmentID']);
        Add('FReceiveDepotID', FListC.Values['FReceiveDepotID']);
        Add('FReceiveGrossWeight', FListA.Values['FReceiveGrossWeight']);
        Add('FReceiveGrossWeight_Auxiliary', FListA.Values['FReceiveGrossWeight']);
        Add('FReceiveTare', FListA.Values['FReceiveTare']);
        Add('FReceiveTare_Auxiliary', FListA.Values['FReceiveTare']);
        Add('FReceiveNetWeight', FListA.Values['FReceiveNetWeight']);
        Add('FReceiveNetWeight_Auxiliary', FListA.Values['FReceiveNetWeight']);
        Add('FReceiveAgainWeightStatus', '0');
        Add('FReceiveGrossWeightStatus', FListA.Values['FReceiveGrossWeightStatus']);
        Add('FReceiveGrossWeightPersonnel', FListA.Values['FReceiveGrossWeightPersonnel']);
        Add('FReceiveGrossWeightTime', FListA.Values['FReceiveGrossWeightTime']);
        Add('FReceiveTareStatus', FListA.Values['FReceiveTareStatus']);
        Add('FReceiveTarePersonnel', FListA.Values['FReceiveTarePersonnel']);
        Add('FReceiveTareTime ', FListA.Values['FReceiveTareTime']);
        Add('FReceiveStatus', FListA.Values['FReceiveStatus']);
        Add('FReceivePersonnel ', FListA.Values['FReceivePersonnel']);
        Add('FReceiveTime', FListA.Values['FReceiveTime']);

        Add('FCancelStatus', FListA.Values['FCancelStatus']);
        Add('FCancelPersonnel', FListA.Values['FCancelPersonnel']);
        Add('FCancelTime', FListA.Values['FCancelTime']);
        Add('FCreator', FListA.Values['FCreator']);
        Add('FCreateTime', FListA.Values['FCreateTime']);

        Add('FRemark', FListC.Values['FRemark']);
        Add('FVer', FListC.Values['FVer']);
      end;
      nNewStr := TlkJSON.GenerateText(nJSNew);
      nNewStr := UTF8Decode(nNewStr);
      WriteLog('�ڵ�ԭ���ϲɹ����ϴ���ǰ����:' + nNewStr);
    end;
  finally
    if Assigned(nJSInit) then
      nJSInit.Free;
    if Assigned(nJSNew) then
      nJSNew.Free;
  end;
end;

function TBusWorkerBusinessHHJY.IsHhOtherOrderDetailExits(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Clear;
  nStr := 'FBillNumber = ''%s''';
  nStr := Format(nStr,[PackerDecodeStr(FIn.FData)]);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('��ѯ���ϴ���ʱ���زɹ������'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyWeighBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SupplyWeighBill(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                   nStr, '');

    WriteLog('��ѯ���ϴ���ʱ���زɹ�������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ѯ���ϴ���ʱ���زɹ��������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ѯ���ϴ���ʱ���زɹ��������쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListA.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
      end;
    end;
    nData := PackerEncodeStr(FListA.Text);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhOtherOrderDetailID(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListE.Clear;

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('��ȡ������ʱ���زɹ���ID���'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyWeighBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SupplyWeighBill(nHHJYChannel^.FChannel).InitializationModel(nSoapHeader);

    WriteLog('��ȡ������ʱ���زɹ���ID����'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ������ʱ���زɹ���ID�����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    nJsCol := nJS.Field['Data'] as TlkJSONobject;

    nStr := VarToStr(nJSCol.Field['FBillID'].Value);

    if nStr = '' then
    begin
      nData := '��ȡ������ʱ���زɹ���ID�ӿڵ����쳣.Data�ڵ�FBillIDΪ��';
      Exit;
    end;

    nData := PackerEncodeStr(nStr);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhOtherOrderDetail(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
    nExits: Boolean;
    nInitStr, nNewStr: string;
begin
  Result := False;
  nExits := False;
  nUrl := '';
  FListD.Text := PackerDecodeStr(FIn.FData);

  WriteLog('ͬ����ʱ���زɹ���׼���������:' + FListD.Text);

  nData := GetOtherOrderDetailJSonString(FListD.Values['ID'], FListD.Values['Delete'], nExits,
                                    nInitStr, nNewStr);
  if nData <> '' then
  begin
    WriteLog('ͬ����ʱ���زɹ���׼�����ݽ��:' + nData);
    Exit;
  end;

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('ͬ����ʱ���زɹ������'+FListD.Text);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyWeighBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel

    if nExits then
    begin
      nStr := IT_SupplyWeighBill(nHHJYChannel^.FChannel).Update(nSoapHeader,
                                     nInitStr, nNewStr);
    end
    else
    begin
      nStr := IT_SupplyWeighBill(nHHJYChannel^.FChannel).Insert(nSoapHeader,
                                     nNewStr);
    end;

    WriteLog('ͬ����ʱ���زɹ�������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := 'ͬ����ʱ���زɹ��������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    nStr :='update %s set P_BDAX=''1'',P_BDNUM=P_BDNUM+1 where P_ID = ''%s'' ';
    nStr := Format(nStr,[sTable_PoundLog,FListD.Values['ID']]);

    gDBConnManager.WorkerExec(FDBConn,nStr);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetOtherOrderDetailJSonString(const nLID, nDelete: string;
 var nExits: Boolean; var nInit, nNewStr: string): string;
var nStr, nSQL, nUrl, nDate: string;
    nInt, nIdx: Integer;
    nJSInit, nJSNew: TlkJSONobject;
    nOut: TWorkerBusinessCommand;
    nPDate, nMDate: TDateTime;
    nCompany, nVer: string;
begin
  Result := '';
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;

  nSQL := 'Select D_ParamB,D_Desc From %s Where D_Name=''%s'' and D_Memo=''%s'' ';
  nSQL := Format(nSQL, [sTable_SysDict, sFlag_SysParam, sFlag_FactoryName]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  begin
    if RecordCount < 1 then
    begin
      Result := '������Ϊ[ %s ]�Ĺ�˾ID���汾�Ų�����.';
      Result := Format(Result, [nLID]);
      Exit;
    end;
    nCompany := Fields[0].AsString;
    nVer := Fields[1].AsString;
  end;

  nExits := TBusWorkerBusinessHHJY.CallMe(cBC_IsHhOtherOrderDetailExits
           ,PackerEncodeStr(nLID),'',@nOut);
  if nExits then
    FListB.Text := PackerDecodeStr(nOut.FData);

  if nExits and (nDelete = sFlag_Yes) then
  begin
    if FListB.Values['FStatus'] = '254' then
    begin
      Result := '������[ %s ]�����,�޷�ɾ��,����ERP�Ƚ��з����.';
      Result := Format(Result, [nLID]);
      Exit;
    end;
  end;
  
  nSQL := 'select *,(P_MValue-P_PValue - isnull(P_KZValue,0)) as D_NetWeight From %s a,'+
  ' %s b where a.R_ID=b.P_OrderBak and b.P_ID = ''%s'' ';

  nSQL := Format(nSQL,[sTable_CardOther,sTable_PoundLog,nLID]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  begin
    if RecordCount < 1 then
    begin
      Result := '������Ϊ[ %s ]�Ĳɹ�����������.';
      Result := Format(Result, [nLID]);
      Exit;
    end;

    FListA.Clear;

    FListA.Values['FBillID']                := FieldByName('P_ID').AsString;
    FListA.Values['FBillNumber']            := FieldByName('P_ID').AsString;
    FListA.Values['FPoundID']               := FieldByName('P_ID').AsString;
    FListA.Values['FAuditID']               := FieldByName('P_ID').AsString;

    FListA.Values['FFirstWeighStatus']      := '1';
    FListA.Values['FFirstWeighPersonnel']   := FieldByName('P_MMan').AsString;
    FListA.Values['FFirstWeighTime']        := FieldByName('P_MDate').AsString;
    if FieldByName('P_MValue').AsString = '' then
      FListA.Values['FGrossWeight']    := '0'
    else
      FListA.Values['FGrossWeight']    := FieldByName('P_MValue').AsString;

    FListA.Values['FSecondWeighStatus']     := '1';
    FListA.Values['FSecondWeighPersonnel']  := FieldByName('P_PMan').AsString;
    FListA.Values['FSecondWeighTime']       := FieldByName('P_PDate').AsString;
    if FieldByName('P_PValue').AsString = '' then
      FListA.Values['FTare']    := '0'
    else
      FListA.Values['FTare']    := FieldByName('P_PValue').AsString;

    if FieldByName('D_NetWeight').AsString = '' then
      FListA.Values['FNetWeight']    := '0'
    else
      FListA.Values['FNetWeight']    := FieldByName('D_NetWeight').AsString;

    FListA.Values['FCreator']               := FieldByName('O_Man').AsString;
    FListA.Values['FCreateTime']            := FieldByName('O_Date').AsString;

    FListA.Values['FConveryanceNumber']     := FieldByName('P_Truck').AsString;
    FListA.Values['FCompanyID']             := nCompany;
    FListA.Values['FVer']                   := nVer;
    FListA.Values['FReamrk']                := '';
    FListA.Values['FStatus']                := '254';
    FListA.Values['FWeighTimes']            := '2';
    FListA.Values['FMaterielName']          := FieldByName('P_MName').AsString;

    FListA.Values['FConsignmentCompanyName']:= FieldByName('P_CusName').AsString;
    FListA.Values['FReceiveCompanyName']    := FieldByName('O_RevName').AsString;
  end;

  try
    if nExits then//���ϴ�
    begin
      nJSInit := TlkJSONobject.Create();

      with nJSInit do//ԭʼ����
      begin
        Add('FBillID', FListB.Values['FBillID']);//�����ID
        Add('FBillNumber', FListA.Values['FBillID']);//�������
        Add('FBillTypeID', '3011');
        Add('FCompanyID', FListB.Values['FCompanyID']);
        Add('FMaterielName', FListB.Values['FMaterielName']);
        Add('FConveryanceNumber', FListB.Values['FConveryanceNumber']);
        Add('FConsignmentCompanyName', FListB.Values['FConsignmentCompanyName']);
        Add('FReceiveCompanyName', FListB.Values['FReceiveCompanyName']);
        Add('FWeighTimes', FListB.Values['FWeighTimes']);
        Add('FWeighMoney', FListB.Values['FWeighMoney']);
        Add('FGrossWeight', FListB.Values['FGrossWeight']);
        Add('FTare', FListB.Values['FTare']);
        Add('FNetWeight', FListB.Values['FNetWeight']);
        Add('FFirstWeighStatus', FListB.Values['FFirstWeighStatus']);
        Add('FFirstWeighPersonnel', FListB.Values['FFirstWeighPersonnel']);
        Add('FFirstWeighTime', FListB.Values['FFirstWeighTime']);
        Add('FSecondWeighStatus', FListB.Values['FSecondWeighStatus']);
        Add('FSecondWeighPersonnel', FListB.Values['FSecondWeighPersonnel']);
        Add('FSecondWeighTime', FListB.Values['FSecondWeighTime']);

        Add('FStatus', FListB.Values['FStatus']);
        Add('FCreator', FListB.Values['FCreator']);
        Add('FCreateTime', FListB.Values['FCreateTime']);
        Add('FVer', FListB.Values['FVer']);
      end;

      nInit := TlkJSON.GenerateText(nJSInit);
      nInit := UTF8Decode(nInit);
      WriteLog('��ʱ���زɹ����ϴ�ԭʼ����:' + nInit);

      nJSNew := TlkJSONobject.Create();

      with nJSNew do
      begin
        Add('FBillID', FListB.Values['FBillID']);//�����ID
        Add('FBillNumber', FListA.Values['FBillID']);//�������
        Add('FBillTypeID', '3011');
        Add('FCompanyID', FListA.Values['FCompanyID']);
        Add('FMaterielName', FListA.Values['FMaterielName']);
        Add('FConveryanceNumber', FListA.Values['FConveryanceNumber']);
        Add('FConsignmentCompanyName', FListA.Values['FConsignmentCompanyName']);
        Add('FReceiveCompanyName', FListA.Values['FReceiveCompanyName']);
        Add('FWeighTimes', FListA.Values['FWeighTimes']);
        Add('FWeighMoney', '0');
        Add('FGrossWeight', FListA.Values['FGrossWeight']);
        Add('FTare', FListA.Values['FTare']);
        Add('FNetWeight', FListA.Values['FNetWeight']);
        Add('FFirstWeighStatus', FListA.Values['FFirstWeighStatus']);
        Add('FFirstWeighPersonnel', FListA.Values['FFirstWeighPersonnel']);
        Add('FFirstWeighTime', FListA.Values['FFirstWeighTime']);
        Add('FSecondWeighStatus', FListA.Values['FSecondWeighStatus']);
        Add('FSecondWeighPersonnel', FListA.Values['FSecondWeighPersonnel']);
        Add('FSecondWeighTime', FListA.Values['FSecondWeighTime']);

        Add('FStatus', FListA.Values['FStatus']);
        Add('FCreator', FListA.Values['FCreator']);
        Add('FCreateTime', FListA.Values['FCreateTime']);
        Add('FVer', FListA.Values['FVer']);
      end;
      nNewStr := TlkJSON.GenerateText(nJSNew);
      nNewStr := UTF8Decode(nNewStr);
      WriteLog('��ʱ���زɹ����ϴ���ǰ����:' + nNewStr);
    end
    else
    begin
      if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhOtherOrderDetailID,
           '','',@nOut) then
      begin
        Result := '[' + nLID + ']��ȡ������ʱ���زɹ���IDʧ��.';
        Exit;
      end;

      nStr := PackerDecodeStr(nOut.FData);
      nJSNew := TlkJSONobject.Create();

      with nJSNew do
      begin
        Add('FBillID', nStr);//�����ID
        Add('FBillNumber', FListA.Values['FBillID']);//�������
        Add('FBillTypeID', '3011');
        Add('FCompanyID', FListA.Values['FCompanyID']);
        Add('FMaterielName', FListA.Values['FMaterielName']);
        Add('FConveryanceNumber', FListA.Values['FConveryanceNumber']);
        Add('FConsignmentCompanyName', FListA.Values['FConsignmentCompanyName']);
        Add('FReceiveCompanyName', FListA.Values['FReceiveCompanyName']);
        Add('FWeighTimes', FListA.Values['FWeighTimes']);
        Add('FWeighMoney', '0');
        Add('FGrossWeight', FListA.Values['FGrossWeight']);
        Add('FTare', FListA.Values['FTare']);
        Add('FNetWeight', FListA.Values['FNetWeight']);
        Add('FFirstWeighStatus', FListA.Values['FFirstWeighStatus']);
        Add('FFirstWeighPersonnel', FListA.Values['FFirstWeighPersonnel']);
        Add('FFirstWeighTime', FListA.Values['FFirstWeighTime']);
        Add('FSecondWeighStatus', FListA.Values['FSecondWeighStatus']);
        Add('FSecondWeighPersonnel', FListA.Values['FSecondWeighPersonnel']);
        Add('FSecondWeighTime', FListA.Values['FSecondWeighTime']);

        Add('FStatus', FListA.Values['FStatus']);
        Add('FCreator', FListA.Values['FCreator']);
        Add('FCreateTime', FListA.Values['FCreateTime']);
        Add('FVer', FListA.Values['FVer']);
      end;
      nNewStr := TlkJSON.GenerateText(nJSNew);
      nNewStr := UTF8Decode(nNewStr);
      WriteLog('��ʱ���زɹ����ϴ���ǰ����:' + nNewStr);
    end;
  finally
    if Assigned(nJSInit) then
      nJSInit.Free;
    if Assigned(nJSNew) then
      nJSNew.Free;
  end;
end;

function TBusWorkerBusinessHHJY.NewHhWTDetail(
  var nData: string): boolean;
var nStr, nUrl, nWTID, nWTNo: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS, nJSNew: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nUrl := '';
  FListD.Text := PackerDecodeStr(FIn.FData);

  WriteLog('�����ɳ�����ϸ���:' + FListD.Text);

  nStr := 'FBillCode = ''%s''';
  nStr := Format(nStr, [FListD.Values['FConsignPlanNumber']]);

  if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhSalePlan
           ,PackerEncodeStr(nStr),'',@nOut) then
  begin
    nData := '��ȡ��ǰ����[ %s ]��Ϣʧ��.';
    nData := Format(nData, [FListD.Values['FConsignPlanNumber']]);
    Exit;
  end;

  FListA.Text := PackerDecodeStr(nOut.FData);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SaleScheduleVan.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel

    WriteLog('��ȡ�����ɳ���ID���');

    nStr := IT_SaleScheduleVan(nHHJYChannel^.FChannel).InitializationModel(nSoapHeader);

    WriteLog('��ȡ�����ɳ���ID����'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ�����ɳ���ID�����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    nJsCol := nJS.Field['Data'] as TlkJSONobject;

    nWTID := VarToStr(nJSCol.Field['FBillID'].Value);
    nWTNo := VarToStr(nJSCol.Field['FBillCode'].Value);
    if (nWTID = '') or (nWTNo = '') then
    begin
      nData := '��ȡ�����ɳ���ID�ӿڵ����쳣.Data�ڵ�FBillID��FBillCodeΪ��';
      Exit;
    end;

    nJSNew := TlkJSONobject.Create();

    with nJSNew do
    begin
      Add('FBillID', nWTID);//�ɳ���ID
      Add('FBillCode', nWTNo);//�ɳ�����
      Add('FBillTypeID', '105');
      Add('FConsignPlanID', FListA.Values['FBillID']);
      Add('FConsignPlanCode', FListA.Values['FBillCode']);

      Add('FDeptID', FListA.Values['FDepartmentID']);
      Add('FSaleManID', FListA.Values['FSaleManID']);
      Add('FCustomerID', FListA.Values['FCustomerID']);
      Add('FMaterielID', FListA.Values['FMaterielID']);
      Add('FPackingID', FListA.Values['FPackingID']);

      Add('FOrgBillCode', FListA.Values['FOrgBillCode']);
      Add('FTransportation', FListD.Values['Truck']);
      Add('FTransportTypeID', '1');
      Add('FLinkMan', '');
      Add('FMobilephone', '');

      Add('FBeginDate', FormatDateTime('YYYY-MM-DD HH:MM:SS', Now));
      Add('FEndDate', FormatDateTime('YYYY-MM-DD HH:MM:SS', IncDay(Now, 1)));
      Add('FVerifyCode', '');
      Add('FAmount', FListD.Values['Value']);
      Add('FIsLimit', '1');
      Add('FCount', '1');
      Add('FUsedCount', '0');

      Add('FCreator', FIn.FBase.FFrom.FUser);
      Add('FCreateTime', FormatDateTime('YYYY-MM-DD HH:MM:SS', Now));
      Add('FMender', '');
      //Add('FModifyTime', '');
      Add('FDeleteMan', '');
      //Add('FDeleteTime', '');
      Add('FAssessor', FIn.FBase.FFrom.FUser);
      Add('FAuditingTime', FormatDateTime('YYYY-MM-DD HH:MM:SS', Now));

      Add('FAppTypeID', '2');
      Add('FStatus', '0');
      Add('FAuditingSign', '1');
      Add('FIsDelete', '0');
      Add('FRemark', '');
      Add('FVer', FListA.Values['FVer']);
    end;
    nStr := TlkJSON.GenerateText(nJSNew);
    nStr := UTF8Decode(nStr);

    WriteLog('�����ɳ������:' + nStr);

    nStr := IT_SaleScheduleVan(nHHJYChannel^.FChannel).Insert(nSoapHeader,
                                   nStr);

    WriteLog('�����ɳ�������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '�����ɳ��������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    nData := nWTID;
    
    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    if Assigned(nJSNew) then
      nJSNew.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SaveHhHYData(
  var nData: string): boolean;
var nStr, nMID, nDate, nHYDan, nHhcStr: string;
    nOut: TWorkerBusinessCommand;
    nIdx: Integer;
begin
  Result := False;

  FListA.Clear;

  FListA.Text := PackerDecodeStr(FIn.FData);
  nMID   := FListA.Values['StockID'];
  nDate  := FListA.Values['Date'];
  nHYDan := FListA.Values['HYDan'];

  FListA.Clear;

  //1
  if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhHyHxDetail
           ,nHYDan,'',@nOut) then
  begin
    nData := '���κ�[ %s ]��ȡ���鵥��ѧ��������ʧ��.';
    nData := Format(nData, [nHYDan]);
    Exit;
  end;
  FListA.Text := PackerDecodeStr(nOut.FData);//ALL

  //2
  if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhHyWlDetail
           ,nHYDan,'',@nOut) then
  begin
    nData := '���κ�[ %s ]��ȡ���鵥��������ܼ�¼����ʧ��.';
    nData := Format(nData, [nHYDan]);
    Exit;
  end;

  FListB.Clear;
  FListB.Text := PackerDecodeStr(nOut.FData);

  FListA.Values['WlRecord'] := FListB.Values['FRecordID'];//����������

  //2.1
  if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhHyWlBZCD
           ,FListA.Values['WlRecord'],'',@nOut) then
  begin
    nData := '���κ�[ %s ]��ȡ���鵥���������׼�������ʧ��.';
    nData := Format(nData, [nHYDan]);
    Exit;
  end;

  FListB.Clear;
  FListB.Text := PackerDecodeStr(nOut.FData);

  FListA.Values['FWRONC'] := FListB.Values['FWRONC'];//��׼���

  //2.2
  if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhHyWlNjTime
           ,FListA.Values['WlRecord'],'',@nOut) then
  begin
    nData := '���κ�[ %s ]��ȡ���鵥�����������ʱ������ʧ��.';
    nData := Format(nData, [nHYDan]);
    Exit;
  end;

  FListB.Clear;
  FListB.Text := PackerDecodeStr(nOut.FData);

  FListA.Values['FInitialSetResult'] := FListB.Values['FInitialSetResult'];//����ʱ��
  FListA.Values['FFinalSetResult'] := FListB.Values['FFinalSetResult'];//����ʱ��

  //2.3
  if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhHyWlXD
           ,FListA.Values['WlRecord'],'',@nOut) then
  begin
    nData := '���κ�[ %s ]��ȡ���鵥�������ϸ������ʧ��.';
    nData := Format(nData, [nHYDan]);
    Exit;
  end;

  FListB.Clear;
  FListB.Text := PackerDecodeStr(nOut.FData);

  FListA.Values['FXDResult'] := FListB.Values['FResult'];//ϸ��

  //2.3
  if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhHyWlBiBiao
           ,FListA.Values['WlRecord'],'',@nOut) then
  begin
    nData := '���κ�[ %s ]��ȡ���鵥��������ȱ��������ʧ��.';
    nData := Format(nData, [nHYDan]);
    Exit;
  end;

  FListB.Clear;
  FListB.Text := PackerDecodeStr(nOut.FData);

  FListA.Values['FSampleDensity'] := FListB.Values['FSampleDensity'];//�ܶ�
  FListA.Values['FSpecificSurfaceAreaAverage']
                                  := FListB.Values['FSpecificSurfaceAreaAverage'];//�ȱ����

  //2.4
  if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhHyWlQD
           ,FListA.Values['WlRecord'],'',@nOut) then
  begin
    nData := '���κ�[ %s ]��ȡ���鵥�������ǿ������ʧ��.';
    nData := Format(nData, [nHYDan]);
    Exit;
  end;

  FListB.Clear;
  FListB.Text := PackerDecodeStr(nOut.FData);

  FListA.Values['FFluidityAverage'] := FListB.Values['FFluidityAverage'];//������

  FListA.Values['FRuptureStrength3D1'] := FListB.Values['FRuptureStrength3D1'];//3�쿹��
  FListA.Values['FRuptureStrength3D2'] := FListB.Values['FRuptureStrength3D2'];
  FListA.Values['FRuptureStrength3D3'] := FListB.Values['FRuptureStrength3D3'];
  FListA.Values['FRuptureStrength3DAverage'] := FListB.Values['FRuptureStrength3DAverage'];

  FListA.Values['FRuptureStrength28D1'] := FListB.Values['FRuptureStrength28D1'];//28�쿹��
  FListA.Values['FRuptureStrength28D2'] := FListB.Values['FRuptureStrength28D2'];
  FListA.Values['FRuptureStrength28D3'] := FListB.Values['FRuptureStrength28D3'];
  FListA.Values['FRuptureStrength28DAverage'] := FListB.Values['FRuptureStrength28DAverage'];

  FListA.Values['FCompressiveStrength3D1'] := FListB.Values['FCompressiveStrength3D1'];//3�쿹ѹ
  FListA.Values['FCompressiveStrength3D2'] := FListB.Values['FCompressiveStrength3D2'];
  FListA.Values['FCompressiveStrength3D3'] := FListB.Values['FCompressiveStrength3D3'];
  FListA.Values['FCompressiveStrength3D4'] := FListB.Values['FCompressiveStrength3D4'];
  FListA.Values['FCompressiveStrength3D5'] := FListB.Values['FCompressiveStrength3D5'];
  FListA.Values['FCompressiveStrength3D6'] := FListB.Values['FCompressiveStrength3D6'];
  FListA.Values['FCompressiveStrength3DAverage'] := FListB.Values['FCompressiveStrength3DAverage'];

  FListA.Values['FCompressiveStrength28D1'] := FListB.Values['FCompressiveStrength28D1'];//3�쿹ѹ
  FListA.Values['FCompressiveStrength28D2'] := FListB.Values['FCompressiveStrength28D2'];
  FListA.Values['FCompressiveStrength28D3'] := FListB.Values['FCompressiveStrength28D3'];
  FListA.Values['FCompressiveStrength28D4'] := FListB.Values['FCompressiveStrength28D4'];
  FListA.Values['FCompressiveStrength28D5'] := FListB.Values['FCompressiveStrength28D5'];
  FListA.Values['FCompressiveStrength28D6'] := FListB.Values['FCompressiveStrength28D6'];
  FListA.Values['FCompressiveStrength28DAverage'] := FListB.Values['FCompressiveStrength28DAverage'];

  //3
  if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhHyHhcDetail
           ,nHYDan,'',@nOut) then
  begin
    nData := '���κ�[ %s ]��ȡ���鵥��ϲ��ܼ�¼����ʧ��.';
    nData := Format(nData, [nHYDan]);
    Exit;
  end;

  FListB.Clear;
  FListB.Text := PackerDecodeStr(nOut.FData);

  FListA.Values['HhcRecord'] := FListB.Values['FRecordID'];//��ϲĽ������

  //3.1
  if not TBusWorkerBusinessHHJY.CallMe(cBC_GetHhHyHhcRecord
           ,FListA.Values['HhcRecord'],'',@nOut) then
  begin
    nData := '���κ�[ %s ]��ȡ���鵥��ϲ���ϸ����ʧ��.';
    nData := Format(nData, [nHYDan]);
    Exit;
  end;
  nHhcStr := nOut.FData;

  FListB.Clear;
  FListC.Clear;


  nStr := SF('R_SerialNo', nHYDan);
  nStr := MakeSQLByStr([
          SF('R_SGType', ''),
          SF('R_SGValue', ''),
          SF('R_HHCType', ''),
          SF('R_HHCValue', ''),
          SF('R_MgO', FListA.Values['FMgO']),
          SF('R_SO3', FListA.Values['FSO3']),
          SF('R_ShaoShi', FListA.Values['FLOSS']),
          SF('R_CL', FListA.Values['FCL_Ion']),
          SF('R_BiBiao', FListA.Values['FSpecificSurfaceAreaAverage']),
          SF('R_ChuNing', FListA.Values['FInitialSetResult']),
          SF('R_ZhongNing', FListA.Values['FFinalSetResult']),
          SF('R_AnDing', ''),
          SF('R_XiDu', FListA.Values['FXDResult']),
          SF('R_MIDu', FListA.Values['FSampleDensity']),
          SF('R_Jian', FListA.Values['FR2O']),
          SF('R_ChouDu', FListA.Values['FWRONC']),
          SF('R_BuRong', ''),
          SF('R_YLiGai', FListA.Values['FF_CaO']),
          SF('R_FC3A', FListA.Values['FC3A']),
          SF('R_Water', ''),
          SF('R_KuangWu', ''),
          SF('R_GaiGui', ''),
          SF('R_Liudong', FListA.Values['FFluidityAverage']),
          SF('R_3DZhe1', FListA.Values['FRuptureStrength3D1']),
          SF('R_3DZhe2', FListA.Values['FRuptureStrength3D2']),
          SF('R_3DZhe3', FListA.Values['FRuptureStrength3D3']),
          SF('R_28Zhe1', FListA.Values['FRuptureStrength28D1']),
          SF('R_28Zhe2', FListA.Values['FRuptureStrength28D2']),
          SF('R_28Zhe3', FListA.Values['FRuptureStrength28D3']),
          SF('R_3DZheAve', FListA.Values['FRuptureStrength3DAverage']),
          SF('R_28DZheAve', FListA.Values['FRuptureStrength28DAverage']),
          SF('R_3DYa1', FListA.Values['FCompressiveStrength3D1']),
          SF('R_3DYa2', FListA.Values['FCompressiveStrength3D2']),
          SF('R_3DYa3', FListA.Values['FCompressiveStrength3D3']),
          SF('R_3DYa4', FListA.Values['FCompressiveStrength3D4']),
          SF('R_3DYa5', FListA.Values['FCompressiveStrength3D5']),
          SF('R_3DYa6', FListA.Values['FCompressiveStrength3D6']),
          SF('R_28Ya1', FListA.Values['FCompressiveStrength28D1']),
          SF('R_28Ya2', FListA.Values['FCompressiveStrength28D2']),
          SF('R_28Ya3', FListA.Values['FCompressiveStrength28D3']),
          SF('R_28Ya4', FListA.Values['FCompressiveStrength28D4']),
          SF('R_28Ya5', FListA.Values['FCompressiveStrength28D5']),
          SF('R_28Ya6', FListA.Values['FCompressiveStrength28D6']),
          SF('R_3DYaAve', FListA.Values['FCompressiveStrength3DAverage']),
          SF('R_28DYaAve', FListA.Values['FCompressiveStrength28DAverage']),
          SF('R_Date', StrToDateDef(FListA.Values['FTestTime'],Now),sfDateTime),
          SF('R_Man', FListA.Values['FTester'])
          ], sTable_StockRecord, nStr, False);
  FListB.Add(nStr);

  nStr := MakeSQLByStr([SF('R_SerialNo', nHYDan),
          SF('R_SGType', ''),
          SF('R_SGValue', ''),
          SF('R_HHCType', ''),
          SF('R_HHCValue', ''),
          SF('R_MgO', FListA.Values['FMgO']),
          SF('R_SO3', FListA.Values['FSO3']),
          SF('R_ShaoShi', FListA.Values['FLOSS']),
          SF('R_CL', FListA.Values['FCL_Ion']),
          SF('R_BiBiao', FListA.Values['FSpecificSurfaceAreaAverage']),
          SF('R_ChuNing', FListA.Values['FInitialSetResult']),
          SF('R_ZhongNing', FListA.Values['FFinalSetResult']),
          SF('R_AnDing', ''),
          SF('R_XiDu', FListA.Values['FXDResult']),
          SF('R_MIDu', FListA.Values['FSampleDensity']),
          SF('R_Jian', FListA.Values['FR2O']),
          SF('R_ChouDu', FListA.Values['FWRONC']),
          SF('R_BuRong', ''),
          SF('R_YLiGai', FListA.Values['FF_CaO']),
          SF('R_FC3A', FListA.Values['FC3A']),
          SF('R_Water', ''),
          SF('R_KuangWu', ''),
          SF('R_GaiGui', ''),
          SF('R_Liudong', FListA.Values['FFluidityAverage']),
          SF('R_3DZhe1', FListA.Values['FRuptureStrength3D1']),
          SF('R_3DZhe2', FListA.Values['FRuptureStrength3D2']),
          SF('R_3DZhe3', FListA.Values['FRuptureStrength3D3']),
          SF('R_28Zhe1', FListA.Values['FRuptureStrength28D1']),
          SF('R_28Zhe2', FListA.Values['FRuptureStrength28D2']),
          SF('R_28Zhe3', FListA.Values['FRuptureStrength28D3']),
          SF('R_3DZheAve', FListA.Values['FRuptureStrength3DAverage']),
          SF('R_28DZheAve', FListA.Values['FRuptureStrength28DAverage']),
          SF('R_3DYa1', FListA.Values['FCompressiveStrength3D1']),
          SF('R_3DYa2', FListA.Values['FCompressiveStrength3D2']),
          SF('R_3DYa3', FListA.Values['FCompressiveStrength3D3']),
          SF('R_3DYa4', FListA.Values['FCompressiveStrength3D4']),
          SF('R_3DYa5', FListA.Values['FCompressiveStrength3D5']),
          SF('R_3DYa6', FListA.Values['FCompressiveStrength3D6']),
          SF('R_28Ya1', FListA.Values['FCompressiveStrength28D1']),
          SF('R_28Ya2', FListA.Values['FCompressiveStrength28D2']),
          SF('R_28Ya3', FListA.Values['FCompressiveStrength28D3']),
          SF('R_28Ya4', FListA.Values['FCompressiveStrength28D4']),
          SF('R_28Ya5', FListA.Values['FCompressiveStrength28D5']),
          SF('R_28Ya6', FListA.Values['FCompressiveStrength28D6']),
          SF('R_3DYaAve', FListA.Values['FCompressiveStrength3DAverage']),
          SF('R_28DYaAve', FListA.Values['FCompressiveStrength28DAverage']),
          SF('R_Date', StrToDateDef(FListA.Values['FTestTime'],Now),sfDateTime),
          SF('R_Man', FListA.Values['FTester'])
          ], sTable_StockRecord, '', True);
  FListC.Add(nStr);

  if FListB.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;

    for nIdx:=0 to FListB.Count - 1 do
    begin
      if gDBConnManager.WorkerExec(FDBConn,FListB[nIdx]) <= 0 then
      begin
        gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
      end;
    end;

    if nHhcStr <> '' then
    begin
      nStr := 'Update %s Set %s where R_SerialNo =''%s''';
      nStr := Format(nStr, [sTable_StockRecord, nHhcStr, nHYDan]);
      WriteLog('��ϵ�����Sql:' + nStr);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;

  Result := True;
  FOut.FData := nData;
  FOut.FBase.FResult := True;
end;

function TBusWorkerBusinessHHJY.GetHhHYHxDetail(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := 'FTestSampleCode = ''%s'' ';
    nStr := Format(nStr, [FIn.FData]);

    WriteLog('��ȡ���鵥��ѧ�������:' + nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QChemistryTestBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_QChemistryTestBill(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                  nStr, '');

    WriteLog('��ȡ���鵥��ѧ��������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ���鵥��ѧ���������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡ���鵥��ѧ���������쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListB.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListB.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        nData := PackerEncodeStr(FListB.Text);
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhHYWlDetail(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := 'FTestSampleCode = ''%s'' ';
    nStr := Format(nStr, [FIn.FData]);

    WriteLog('��ȡ���鵥����������:' + nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QPhysicsRecord.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_QPhysicsRecord(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                  nStr, '');

    WriteLog('��ȡ���鵥�����������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ���鵥������������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡ���鵥������������쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListB.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListB.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        nData := PackerEncodeStr(FListB.Text);
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhHYWlBZCD(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := 'FRecordID = ''%s'' ';
    nStr := Format(nStr, [FIn.FData]);

    WriteLog('��ȡ���鵥���������׼������:' + nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QPhysicsWRONCRecord.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_QPhysicsWRONCRecord(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                  nStr, '');

    WriteLog('��ȡ���鵥���������׼��ȳ���'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ���鵥���������׼��ȵ����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡ���鵥���������׼��ȵ����쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListB.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListB.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        nData := PackerEncodeStr(FListB.Text);
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhHYWlNjTime(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := 'FRecordID = ''%s'' ';
    nStr := Format(nStr, [FIn.FData]);

    WriteLog('��ȡ���鵥�����������ʱ�����:' + nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QPhysicsSettingTimeRecord.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_QPhysicsSettingTimeRecord(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                  nStr, '');

    WriteLog('��ȡ���鵥�����������ʱ�����'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ���鵥�����������ʱ������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡ���鵥�����������ʱ������쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListB.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListB.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        nData := PackerEncodeStr(FListB.Text);
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhHYWlXD(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := 'FRecordID = ''%s'' ';
    nStr := Format(nStr, [FIn.FData]);

    WriteLog('��ȡ���鵥�������ϸ�����:' + nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QPhysicsFinenessRecord.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_QPhysicsFinenessRecord(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                  nStr, '');

    WriteLog('��ȡ���鵥�������ϸ�ȳ���'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ���鵥�������ϸ�ȵ����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡ���鵥�������ϸ�ȵ����쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListB.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListB.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        nData := PackerEncodeStr(FListB.Text);
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhHYWlBiBiao(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := 'FRecordID = ''%s'' ';
    nStr := Format(nStr, [FIn.FData]);

    WriteLog('��ȡ���鵥��������ȱ�������:' + nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QPhysicsSpecificSurfaceAreaRecord.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_QPhysicsSpecificSurfaceAreaRecord(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                  nStr, '');

    WriteLog('��ȡ���鵥��������ȱ��������'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ���鵥��������ȱ���������쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡ���鵥��������ȱ���������쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListB.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListB.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        nData := PackerEncodeStr(FListB.Text);
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhHYWlQD(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := 'FRecordID = ''%s'' ';
    nStr := Format(nStr, [FIn.FData]);

    WriteLog('��ȡ���鵥�������ǿ�����:' + nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QPhysicsSpecificSurfaceAreaRecord.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_QPhysicsSpecificSurfaceAreaRecord(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                  nStr, '');

    WriteLog('��ȡ���鵥�������ǿ�ȳ���'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ���鵥�������ǿ�ȵ����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡ���鵥�������ǿ�ȵ����쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListB.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListB.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        nData := PackerEncodeStr(FListB.Text);
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhHYHhcDetail(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := 'FTestSampleCode = ''%s'' ';
    nStr := Format(nStr, [FIn.FData]);

    WriteLog('��ȡ���鵥��ϲ����:' + nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoQAdmixtureDataBrief_WS.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IQAdmixtureDataBrief_WS(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                  nStr, '');

    WriteLog('��ȡ���鵥��ϲĳ���'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ���鵥��ϲĵ����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡ���鵥��ϲĵ����쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListB.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListB.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        nData := PackerEncodeStr(FListB.Text);
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhHYHhcRecord(
  var nData: string): Boolean;
var nStr, nUrl, nUpDate: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := 'FRecordID = ''%s'' ';
    nStr := Format(nStr, [FIn.FData]);

    WriteLog('��ȡ���鵥��ϲ���ϸ���:' + nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '���Ӻ�Ӿ�Զ����ʧ��(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoQAdmixtureDataDetail_WS.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IQAdmixtureDataDetail_WS(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                  nStr, '');

    WriteLog('��ȡ���鵥��ϲ���ϸ����'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '��ȡ���鵥��ϲ���ϸ�����쳣.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '��ȡ���鵥��ϲ���ϸ�����쳣.Data�ڵ�Ϊ��';
        Exit;
      end;

      FListB.Clear;
      nUpDate := '';

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListC.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListC.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;

        if FListC.Values['FMaterielNumber'] = '' then
          Continue;

        nStr := 'Select D_Value From %s ' +
                'Where D_Name=''%s'' And D_Memo=''%s''';
        nStr := Format(nStr, [sTable_SysDict, sFlag_HhcField,
                              FListC.Values['FMaterielNumber']]);

        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        if RecordCount > 0 then
        begin
          nStr := '%s=''%s'',';
          nStr := Format(nStr,[Fields[0].AsString,FListC.Values['FPercent']]);
          nUpDate := nUpDate + nStr;
        end;
      end;
      nData := '';
      if nUpDate <> '' then
      begin
        if Copy(nUpDate, Length(nUpDate), 1) = ',' then
          System.Delete(nUpDate, Length(nUpDate), 1);
        nData := nUpDate;
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

{$IFDEF UseWXERP}
function TBusWorkerBusinessHHJY.UnicodeToChinese(inputstr: string): string;
var
    i: Integer;
    index: Integer;
    temp, top, last: string;
begin
    index := 1;
    while index >= 0 do
    begin
        index := Pos('\u', inputstr) - 1;
        if index < 0 then
        begin
            last := inputstr;
            Result := Result + last;
            Exit;
        end;
        top := Copy(inputstr, 1, index); // ȡ�� �����ַ�ǰ�� �� unic ������ַ���������
        temp := Copy(inputstr, index + 1, 6); // ȡ�����룬���� \u,��\u4e3f
        Delete(temp, 1, 2);
        Delete(inputstr, 1, index + 6);
        Result := Result + top + WideChar(StrToInt('$' + temp));
    end;
end;


function TBusWorkerBusinessHHJY.GetLoginToken(
  var nData: string): Boolean;
var
  nStr, szUrl: string;
  ReJo, ReSubJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream:TStringstream;
begin
  Result   := True;
  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');

  try
    wParam.Clear;
    wParam.Values['username']:= FIn.FData;
    wParam.Values['password']:= FIn.FExtParam;
    nStr := 'username:'+FIn.FData+'password'+FIn.FExtParam;
    WriteLog('��¼�ӿ���Σ�' + nStr);

    szUrl := gSysParam.FWXERPUrl+'/login';
    WriteLog('��¼�ӿڵ�ַ��' + szUrl);
    FidHttp.Request.ContentType := 'application/x-www-form-urlencoded';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);

    WriteLog('��¼�ӿڳ��Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReSubJo := SO(ReJo.S['Response']);
      if ReSubJo.S['token'] <> '' then
      begin
        Ftoken := ReSubJo.S['token'];
        WriteLog('���ŵ�¼Token��' + Ftoken);
        Result := True;
        FOut.FData := sFlag_Yes;
        FOut.FBase.FResult := True;
      end
      else
      begin
        WriteLog('���ŵ�¼ʧ�ܣ�' + ReSubJo.S['Message']);
        Result     := True;
        FOut.FData := ReSubJo.S['Message'];
        FOut.FBase.FResult := True;
      end;
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetDepotInfo(var nData: string): Boolean;
var
  nStr, szUrl: string;
  ReJo, OneJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream:TStringstream;
  nIdx: Integer;
begin
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;
  FListD.Clear;
  FListE.Clear;
  Result   := True;
  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');

  try
    wParam.Clear;
    wParam.Values['token']   := Ftoken;

    nStr := 'token:'+Ftoken;
    WriteLog('��ѯ���ŵ�����Σ�' + nStr);

    szUrl := gSysParam.FWXERPUrl + '/dept';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);

    WriteLog('���ŵ������Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if ArrsJa <> nil then
      begin
        for nIdx := 0 to ArrsJa.Length - 1 do
        begin
          OneJo  := SO(ArrsJa.S[nIdx]);

          nStr := MakeSQLByStr([SF('G_PROGID', 'ZXSOFT'),
                  SF('G_NAME', OneJo.S['name']),
                  SF('G_WXID', OneJo.S['departmentno'])
                  ], sTable_Group, '', True);
          FListA.Add(nStr);

          nStr := SF('G_WXID', OneJo.S['departmentno']);
          nStr := MakeSQLByStr([
                  SF('G_NAME', OneJo.S['name'])
                  ], sTable_Group, nStr, False);
          FListC.Add(nStr);

          nStr:='select * from %s where G_WXID=''%s'' ';
          nStr := Format(nStr, [sTable_Group, OneJo.S['departmentno']]);
          FListD.Add(nStr);
        end;
      end
      else
      begin
        WriteLog('��ȡ���ŵ���ʧ��');
        Result     := False;
        FOut.FData :='��ȡ���ŵ���ʧ��';
        FOut.FBase.FResult := True;
      end;
    end;

    if (FListD.Count > 0) then
    try
      FDBConn.FConn.BeginTrans;
      //��������
      for nIdx:=0 to FListD.Count - 1 do
      begin
        with gDBConnManager.WorkerQuery(FDBConn,FListD[nIdx]) do
        begin
          if RecordCount>0 then
          begin
            gDBConnManager.WorkerExec(FDBConn,FListC[nIdx]);
          end else
          begin
            gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
          end;
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetUserInfo(var nData: string): Boolean;
var
  nStr, szUrl: string;
  ReJo, OneJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream:TStringstream;
  nIdx: Integer;
begin
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;
  FListD.Clear;
  FListE.Clear;
  Result   := True;
  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');

  try
    wParam.Clear;
    wParam.Values['token']   := Ftoken;

    nStr := 'token:'+Ftoken;
    WriteLog('��ѯ��Ա������Σ�' + nStr);

    szUrl := gSysParam.FWXERPUrl + '/personnel';   //'http://jxcpa.eicp.net:8068/personal';  
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);

    WriteLog('��Ա�������Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if ArrsJa <> nil then
      begin
        for nIdx := 0 to ArrsJa.Length - 1 do
        begin
          OneJo  := SO(ArrsJa.S[nIdx]);

          nStr := MakeSQLByStr([SF('U_Name', OneJo.S['name']),
                  SF('U_WXID', OneJo.S['employeeno'])
                  ], sTable_User, '', True);
          FListA.Add(nStr);

          nStr := SF('U_WXID', OneJo.S['employeeno']);
          nStr := MakeSQLByStr([
                  SF('U_Name', OneJo.S['name'])
                  ], sTable_User, nStr, False);
          FListC.Add(nStr);

          nStr:='select * from %s where U_WXID=''%s'' ';
          nStr := Format(nStr, [sTable_User, OneJo.S['employeeno']]);
          FListD.Add(nStr);
        end;
      end
      else
      begin
        WriteLog('��ȡ��Ա����ʧ��');
        Result     := False;
        FOut.FData :='��ȡ��Ա����ʧ��';
        FOut.FBase.FResult := True;
      end;
    end;

    if (FListD.Count > 0) then
    try
      FDBConn.FConn.BeginTrans;
      //��������
      for nIdx:=0 to FListD.Count - 1 do
      begin
        with gDBConnManager.WorkerQuery(FDBConn,FListD[nIdx]) do
        begin
          if RecordCount>0 then
          begin
            gDBConnManager.WorkerExec(FDBConn,FListC[nIdx]);
          end else
          begin
            gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
          end;
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetCusProInfo(
  var nData: string): Boolean;
var
  nStr, szUrl: string;
  ReJo, OneJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream:TStringstream;
  nIdx: Integer;
begin
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;
  FListD.Clear;
  FListE.Clear;
  FListF.Clear;
  Result   := True;
  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');

  try
    wParam.Clear;
    wParam.Values['token']   := Ftoken;

    nStr := 'token:'+Ftoken;
    WriteLog('��ѯ������Ϣ��Σ�' + nStr);

    szUrl := gSysParam.FWXERPUrl + '/partner';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);

    WriteLog('������Ϣ���Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if ArrsJa <> nil then
      begin
        for nIdx := 0 to ArrsJa.Length - 1 do
        begin
          OneJo  := SO(ArrsJa.S[nIdx]);

          if OneJo.S['customer'] = 'true' then
          begin
            nStr := MakeSQLByStr([SF('C_Name', OneJo.S['name']),
                    SF('C_ID', OneJo.S['partnerno'])
                    ], sTable_Customer, '', True);
            FListA.Add(nStr);

            nStr := SF('C_ID', OneJo.S['partnerno']);
            nStr := MakeSQLByStr([
                    SF('C_Name', OneJo.S['name'])
                    ], sTable_Customer, nStr, False);
            FListC.Add(nStr);

            nStr:='select * from %s where C_ID=''%s'' ';
            nStr := Format(nStr, [sTable_Customer, OneJo.S['partnerno']]);
            FListD.Add(nStr);
          end;

          if OneJo.S['supplier'] = 'true' then
          begin
            nStr := MakeSQLByStr([SF('P_Name', OneJo.S['name']),
                    SF('P_ID', OneJo.S['partnerno'])
                    ], sTable_Provider, '', True);
            FListB.Add(nStr);

            nStr := SF('P_ID', OneJo.S['partnerno']);
            nStr := MakeSQLByStr([
                    SF('P_Name', OneJo.S['name'])
                    ], sTable_Provider, nStr, False);
            FListE.Add(nStr);

            nStr:='select * from %s where P_ID=''%s'' ';
            nStr := Format(nStr, [sTable_Provider, OneJo.S['partnerno']]);
            FListF.Add(nStr);
          end;
        end;
      end
      else
      begin
        WriteLog('��ȡ������Ϣʧ��');
        Result     := False;
        FOut.FData :='��ȡ������Ϣʧ��';
        FOut.FBase.FResult := True;
      end;
    end;

    if (FListD.Count > 0) then
    try
      FDBConn.FConn.BeginTrans;
      //��������
      for nIdx:=0 to FListD.Count - 1 do
      begin
        with gDBConnManager.WorkerQuery(FDBConn,FListD[nIdx]) do
        begin
          if RecordCount>0 then
          begin
            gDBConnManager.WorkerExec(FDBConn,FListC[nIdx]);
          end else
          begin
            gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
          end;
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;

    if (FListF.Count > 0) then
    try
      FDBConn.FConn.BeginTrans;
      //��������
      for nIdx:=0 to FListF.Count - 1 do
      begin
        with gDBConnManager.WorkerQuery(FDBConn,FListF[nIdx]) do
        begin
          if RecordCount>0 then
          begin
            gDBConnManager.WorkerExec(FDBConn,FListE[nIdx]);
          end else
          begin
            gDBConnManager.WorkerExec(FDBConn,FListB[nIdx]);
          end;
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetStockType(var nData: string): Boolean;
var
  nStr, szUrl, nStockName : string;
  ReJo, OneJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream:TStringstream;
  nIdx: Integer;
begin
  Result   := True;
  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');

  nStockName := '����Ʒ';
  nStr := ' Select D_Value From %s Where D_Name = ''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_WXStockName]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStockName := Fields[0].AsString;
  end;

  try
    wParam.Clear;
    wParam.Values['token']   := Ftoken;

    nStr := 'token:'+Ftoken;
    WriteLog('��ѯ���������Σ�' + nStr);

    szUrl := gSysParam.FWXERPUrl + '/invcategory';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);

    WriteLog('���������Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if ArrsJa <> nil then
      begin
        for nIdx := 0 to ArrsJa.Length - 1 do
        begin
          OneJo  := SO(ArrsJa.S[nIdx]);
          if OneJo.S['name'] = nStockName then
          begin
            nStr := SF('D_Name', 'WXStockName');
            nStr := MakeSQLByStr([
                    SF('D_ParamB', OneJo.S['categoryno'])
                    ], sTable_SysDict, nStr, False);

            gDBConnManager.WorkerExec(FDBConn,nStr);
         end;
        end;
      end
      else
      begin
        WriteLog('��ȡ�������ʧ��');
        Result     := False;
        FOut.FData :='��ȡ�������ʧ��';
        FOut.FBase.FResult := True;
      end;
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetStockInfo(var nData: string): Boolean;
var
  nStr, szUrl, ncateg_id, nType : string;
  ReJo, OneJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream:TStringstream;
  nIdx: Integer;
begin
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;
  FListD.Clear;
  FListE.Clear;
  Result   := True;
  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');

  ncateg_id := '';
  nStr := ' Select D_ParamB From %s Where D_Name = ''%s'' ';
  nStr := Format(nStr, [sTable_SysDictEx, sFlag_WXStockName]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    ncateg_id := Fields[0].AsString;
  end;

  try
    wParam.Clear;
    wParam.Values['token']   := Ftoken;
    if ncateg_id <> '' then
      wParam.Values['categ_id']:= ncateg_id;

    nStr := 'token:'+Ftoken;
    WriteLog('��ѯ���������Σ�' + nStr);

    szUrl := gSysParam.FWXERPUrl + '/inventory';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);

    WriteLog('����������Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if ArrsJa <> nil then
      begin
        for nIdx := 0 to ArrsJa.Length - 1 do
        begin
          OneJo  := SO(ArrsJa.S[nIdx]);

          if Pos('��',OneJo.S['specification']) > 0 then
            nType := 'D'
          else
            nType := 'S';
            
          nStr := MakeSQLByStr([SF('D_Name', 'StockItem'),
                  SF('D_Desc', 'ˮ������'),
                  SF('D_Value', OneJo.S['name']),
                  SF('D_Memo', nType),
                  SF('D_ParamB', OneJo.S['productid'])
                  ], sTable_SysDictEx, '', True);
          FListA.Add(nStr);

          nStr := SF('D_ParamB', OneJo.S['productid']);
          nStr := nStr +' and ' + SF('D_Name', 'StockItem');
          nStr := MakeSQLByStr([
                  SF('D_Name', 'StockItem'),
                  SF('D_Desc', 'ˮ������'),
                  SF('D_Value', OneJo.S['name']),
                  SF('D_Memo', nType)
                  ], sTable_SysDictEx, nStr, False);
          FListC.Add(nStr);

          nStr := ' select * from %s where D_ParamB=''%s'' and D_Name = ''%s'' ';
          nStr := Format(nStr, [sTable_SysDictEx, OneJo.S['productid'], 'StockItem']);
          FListD.Add(nStr);
        end;
      end
      else
      begin
        WriteLog('��ȡ�������ʧ��');
        Result     := False;
        FOut.FData :='��ȡ�������ʧ��';
        FOut.FBase.FResult := True;
      end;
    end;

    if (FListD.Count > 0) then
    try
      FDBConn.FConn.BeginTrans;
      //��������
      for nIdx:=0 to FListD.Count - 1 do
      begin
        with gDBConnManager.WorkerQuery(FDBConn,FListD[nIdx]) do
        begin
          if RecordCount>0 then
          begin
            gDBConnManager.WorkerExec(FDBConn,FListC[nIdx]);
          end else
          begin
            gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
          end;
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetOrderInfo(var nData: string): Boolean;
var nStr, nProStr, nMatStr, nYearStr, nSQL : string;
    nHasDone: Double;
    nYearMonth,szUrl : string;
    ReJo, OneJo : ISuperObject;
    ArrsJa,ArrsJaSub: TSuperArray;
    wParam: TStrings;
    ReStream:TStringstream;
    nIdx: Integer;
    nO_Valid: string;
    nYear, nMonth, nDays : Word;
    nDataStream: TMsMultiPartFormDataStream;
begin
  Result := False;

  FListA.Clear;
  FListB.Clear;
  FListC.Clear;
  FListD.Clear;
  FListE.Clear;
  Result      := True;
  wParam      := TStringList.Create;
  ReStream    := TStringstream.Create('');
  nDataStream := TMsMultiPartFormDataStream.Create;

  FListA.Text := PackerDecodeStr(FIn.FData);
  try
    wParam.Clear;
    wParam.Values['token']     := Ftoken;

    if FListA.Values['YearPeriod'] <> '' then
    begin
      nYearMonth := FListA.Values['YearPeriod'];
      nYear      := StrToInt(Copy(nYearMonth,1,Pos('-',nYearMonth)-1));
      nMonth     := StrToInt(Copy(nYearMonth,Pos('-',nYearMonth)+1,MaxInt));
      nDays      := DaysInAMonth(nYear,nMonth);
      wParam.Values['starttime'] := FListA.Values['YearPeriod']+'-01 00:00:00';
      wParam.Values['endtime']   := FListA.Values['YearPeriod']+'-'+inttostr(nDays)+' 23:59:59';
    end
    else
    begin
      wParam.Values['starttime'] := DateTime2Str(IncMonth(Now,-1));
      wParam.Values['endtime']   := DateTime2Str(Now);
    end;
    if FListA.Values['Materiel'] <> '' then
      wParam.Values['product_name'] := FListA.Values['Materiel'];
    if FListA.Values['Provider'] <> '' then
      wParam.Values['partner_name'] := FListA.Values['Provider'];

    nStr := 'token:'+Ftoken;
    WriteLog('��ѯ�ɹ�������Σ�' + nStr);

    nDataStream.AddFormField('token', Ftoken);
    if FListA.Values['YearPeriod'] <> '' then
    begin
      nYearMonth := FListA.Values['YearPeriod'];
      nYear      := StrToInt(Copy(nYearMonth,1,Pos('-',nYearMonth)-1));
      nMonth     := StrToInt(Copy(nYearMonth,Pos('-',nYearMonth)+1,MaxInt));
      nDays      := DaysInAMonth(nYear,nMonth);
      nDataStream.AddFormField('starttime', FListA.Values['YearPeriod']+'-01 00:00:00');
      if (FListA.Values['Materiel'] = '') and (FListA.Values['Provider'] = '') then
        nDataStream.AddFormField('endtime', FListA.Values['YearPeriod']+'-'+inttostr(nDays)+' 23:59:59'+ CRLF)
      else
        nDataStream.AddFormField('endtime', FListA.Values['YearPeriod']+'-'+inttostr(nDays)+' 23:59:59');
    end
    else
    begin
      nDataStream.AddFormField('starttime', DateTime2Str(IncMonth(Now,-1)));
      if (FListA.Values['Materiel'] = '') and (FListA.Values['Provider'] = '') then
        nDataStream.AddFormField('endtime', DateTime2Str(Now)+ CRLF)
      else
        nDataStream.AddFormField('endtime', DateTime2Str(Now));
    end;

    if FListA.Values['Materiel'] <> '' then
    begin
      nDataStream.AddFormField('product_name', FListA.Values['Materiel']);
    end;
    if FListA.Values['Provider'] <> '' then
    begin
      nDataStream.AddFormField('partner_name', FListA.Values['Provider']);
    end;
    nDataStream.done;

    szUrl := gSysParam.FWXERPUrl + '/purchaseorder';
    FIdHttp.HTTPOptions:=FIdHttp.HTTPOptions+[hoKeepOrigProtocol];
    FidHttp.ProtocolVersion:= pv1_1;
    FidHttp.Request.ContentType := nDataStream.RequestContentType;
    FidHttp.Post(szUrl, nDataStream, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);


    WriteLog('�ɹ��������Σ�' + nStr);
    FListA.Clear;
    FListB.Clear;
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if ArrsJa <> nil then
      begin
        if ArrsJa.Length = 0 then
        begin
          WriteLog('���ڼ��޲ɹ�����');
          Result     := True;
          FOut.FData :='';
          FOut.FBase.FResult := True;
        end
        else
        begin
          for nIdx := 0 to ArrsJa.Length - 1 do
          begin
            OneJo := SO(ArrsJa.S[nIdx]);

//            nSQL := ' select isnull(sum(P_MValue-P_PValue - isnull(P_KZValue,0)),0) as D_NetWeight From %s a, '+
//            ' %s b, %s c where a.D_OID=b.O_ID and a.D_ID=c.P_OrderBak and c.P_BID = ''%s'' ';
//
//            nSQL := Format(nSQL,[sTable_OrderDtl,sTable_Order,sTable_PoundLog,OneJo.S['order_name']]);
//            with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
//            begin
//              if RecordCount > 0 then
//                nHasDone := FieldByName('D_NetWeight').AsFloat
//              else
//                nHasDone := 0;
//            end;

            WriteLog('��ȡ��ͨԭ���Ͻ����ƻ�:'+OneJo.S['ordername']);

            nO_Valid := 'Y';
            if OneJo.B['is_closed'] then
              nO_Valid := 'N'
            else
              nO_Valid := 'Y';

            if nO_Valid = 'Y' then
            begin
              with FListB do
              begin
                Values['Order']         := OneJo.S['ordername'];
                Values['ProName']       := OneJo.S['partner_name'];
                Values['ProID']         := OneJo.S['partner_name'];
                ArrsJaSub               := OneJo.A['products'];
                Values['StockName']     := SO(ArrsJaSub.S[0]).S['product_name'];
                Values['StockID']       := SO(ArrsJaSub.S[0]).S['productid'];
                Values['StockNo']       := SO(ArrsJaSub.S[0]).S['productid'];
                try
                  nHasDone := StrToFloatDef(SO(ArrsJaSub.S[0]).S['product_qty'],0)
                              - StrToFloatDef(SO(ArrsJaSub.S[0]).S['remainder'],0);
                  nHasDone := Float2PInt(nHasDone, cPrecision, False) / cPrecision;
                  if nHasDone <= 0 then
                    nHasDone := 0;
                except
                  nHasDone := 0;
                end;
                Values['PlanValue']     := SO(ArrsJaSub.S[0]).S['product_qty'];//������
                Values['EntryValue']    := FloatToStr(nHasDone);//�ѽ�����
                Values['Value']         := FloatToStr(StrToFloatDef(SO(ArrsJaSub.S[0]).S['remainder'], StrToFloat(SO(ArrsJaSub.S[0]).S['product_qty'])));//ʣ����
                Values['Model']         := '';//�ͺ�
                Values['KD']            := '';//���
                FListA.Add(PackerEncodeStr(FListB.Text));
              end;
            end;

            FOut.FData := PackerEncodeStr(FListA.Text);
            Result := True;
          end;
        end;
      end                                                             
      else
      begin
        WriteLog('��ȡ�ɹ�����ʧ��');
        Result     := False;
        FOut.FData :='��ȡ�ɹ�����ʧ��';
        FOut.FBase.FResult := True;
      end;
    end;
  finally
    ReStream.Free;
    nDataStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SynWxOrderPound(var nData: string): Boolean;
var
  nStr, szUrl, nSQL, nType, nDate : string;
  ReJo, OneJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream:TStringstream;
  nIdx: Integer;
  nPDate, nMDate: TDateTime;
  nDataStream: TMsMultiPartFormDataStream;
begin
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;
  FListD.Clear;
  FListE.Clear;
  Result   := True;
  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');
  nDataStream := TMsMultiPartFormDataStream.Create;

  try
    wParam.Clear;
    wParam.Values['token']   := Ftoken;

    nSQL := 'select *,(P_MValue-P_PValue - isnull(P_KZValue,0)) as D_NetWeight From %s a,'+
    ' %s b, %s c where a.D_OID=b.O_ID and a.D_ID=c.P_OrderBak and c.P_ID = ''%s'' and isnull(a.D_YSResult,''Y'') <> ''N'' ';

    nSQL := Format(nSQL,[sTable_OrderDtl,sTable_Order,sTable_PoundLog,FIn.FData]);
    with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
    begin
      if RecordCount < 1 then
      begin
        nData := '������Ϊ[ %s ]�Ĳɹ�����������.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;

      try
        nPDate := FieldByName('P_PDate').AsDateTime;
        nMDate := FieldByName('P_MDate').AsDateTime;
        if nMDate > nPDate then
          nDate := FieldByName('P_MDate').AsString
        else
          nDate := FieldByName('P_PDate').AsString;
      except
          nDate := FieldByName('P_PDate').AsString;
      end;


      wParam.Values['ordername']     := FieldByName('O_BID').AsString;
      wParam.Values['weightime']     := nDate;
      wParam.Values['trucknumber']   := FieldByName('P_Truck').AsString;
      wParam.Values['productid']     := FieldByName('P_MID').AsString;
      wParam.Values['tareweight']    := FieldByName('P_PValue').AsString;
      wParam.Values['grossweight']   := FieldByName('P_MValue').AsString;

      wParam.Values['weight']        := FieldByName('D_NetWeight').AsString;
      wParam.Values['deductweight']  := FloatToStr(StrToFLoatDef(
                                           FieldByName('D_KZValue').AsString,0));
      wParam.Values['remainder']     := FloatToStr(StrToFLoatDef(FieldByName('O_RestValue').AsString,0)
                                         - StrToFLoatDef(FieldByName('D_NetWeight').AsString,0));

      nDataStream.AddFormField('token', Ftoken);
      nDataStream.AddFormField('ordername', FieldByName('O_BID').AsString);
      nDataStream.AddFormField('weightime', nDate);
      nDataStream.AddFormField('trucknumber', Ansitoutf8(FieldByName('P_Truck').AsString));
      nDataStream.AddFormField('productid', FieldByName('P_MID').AsString);
      nDataStream.AddFormField('tareweight', FieldByName('P_PValue').AsString);
      nDataStream.AddFormField('grossweight', FieldByName('P_MValue').AsString);
      nDataStream.AddFormField('weight', FieldByName('D_NetWeight').AsString);
      nDataStream.AddFormField('deductweight', FloatToStr(StrToFLoatDef(
                                           FieldByName('D_KZValue').AsString,0)));
      nDataStream.AddFormField('remainder', FloatToStr(StrToFLoatDef(FieldByName('O_RestValue').AsString,0)
                                         - StrToFLoatDef(FieldByName('D_NetWeight').AsString,0)) + CRLF);

      nDataStream.done;
    end;

    nStr := 'token:'+Ftoken;
    WriteLog('��ѯ�ɹ�������Σ�' + wParam.Text);

    szUrl := gSysParam.FWXERPUrl + '/purchaseweigh';
    FIdHttp.HTTPOptions:=FIdHttp.HTTPOptions+[hoKeepOrigProtocol];
    FidHttp.ProtocolVersion:= pv1_1;
    FidHttp.Request.ContentType := nDataStream.RequestContentType;
    FidHttp.Post(szUrl, nDataStream, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);

    WriteLog('�ɹ��������Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if ArrsJa <> nil then
      begin
        if ArrsJa.Length > 0 then
        begin
          nStr := ' update %s set P_BDAX=''1'',P_BDNUM=P_BDNUM+1, P_stockpickname=''%s'',' +
                  ' P_stockmovelineid=''%s'',P_Batchno=''%s'' where P_ID = ''%s'' ';
          nStr := Format(nStr,[sTable_PoundLog, ArrsJa[0].S['stockpickname'], ArrsJa[0].S['stockmovelineid'],ArrsJa[0].S['batchno'], FIn.FData]);

          gDBConnManager.WorkerExec(FDBConn,nStr);

          FOut.FData := sFlag_Yes;
          Result := True;
        end;
      end
      else
      begin
        WriteLog('��ȡ�ɹ�����ʧ��');
        Result     := False;
        FOut.FData :='��ȡ�ɹ�����ʧ��';
        FOut.FBase.FResult := True;
      end;
    end;

  finally
    ReStream.Free;
    nDataStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetSaleInfo(var nData: string): Boolean;
var nStr, nProStr, nMatStr, nYearStr,nSQL: string;
    nO_Valid, nStockName : string;
    nValue: Double;
    nYearMonth,szUrl, nType : string;
    ReJo, OneJo : ISuperObject;
    ArrsJa,ArrsJaSub: TSuperArray;
    wParam: TStrings;
    ReStream,PostStream:TStringstream;
    nIdx: Integer;
    nYear, nMonth, nDays : Word;
    nDataStream: TMsMultiPartFormDataStream;
begin
  Result := True;

  wParam      := TStringList.Create;
  ReStream    := TStringstream.Create('');
  nDataStream := TMsMultiPartFormDataStream.Create;

  FListA.Text := PackerDecodeStr(FIn.FData);
  try
    wParam.Clear;
    wParam.Values['token']     := Ftoken;

    wParam.Values['starttime'] := DateTime2Str(IncMonth(Now,-12));
    wParam.Values['endtime']   := DateTime2Str(Now);

    if FListA.Text <> '' then
      wParam.Values['partner_name'] := FListA.Text;

    nStr := 'token:'+Ftoken;
    WriteLog('��ѯ���۶�����Σ�' + wParam.Text);

    nDataStream.AddFormField('token', Ftoken);
    nDataStream.AddFormField('starttime', DateTime2Str(IncMonth(Now,-12)));


    if FListA.Text <> '' then
    begin
      nDataStream.AddFormField('endtime', DateTime2Str(Now));
      nDataStream.AddFormField('partner_name', Ansitoutf8(FListA.Text));
    end
    else
      nDataStream.AddFormField('endtime', DateTime2Str(Now) + CRLF);
    nDataStream.done;

    szUrl := gSysParam.FWXERPUrl + '/saleorder';
    nStr      := Ansitoutf8(wParam.Text);
    PostStream:= TStringStream.Create(nStr);

    FIdHttp.HTTPOptions:=FIdHttp.HTTPOptions+[hoKeepOrigProtocol];
    FidHttp.ProtocolVersion:= pv1_1;
    FidHttp.Request.ContentType := nDataStream.RequestContentType;
    FidHttp.Post(szUrl, nDataStream, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);


    WriteLog('���۶������Σ�' + nStr);
    FListA.Clear;
    FListC.Clear;
    FListD.Clear;
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if ArrsJa <> nil then
      begin
        if ArrsJa.Length = 0 then
        begin
          WriteLog('���ڼ������۶���');
          Result     := True;
          FOut.FData :='';
          FOut.FBase.FResult := True;
        end
        else
        begin
          for nIdx := 0 to ArrsJa.Length - 1 do
          begin
            OneJo := SO(ArrsJa.S[nIdx]);

            ArrsJaSub  := OneJo.A['products'];

            if StrToFloatDef(SO(ArrsJaSub.S[0]).S['remainder'],0) <> 0 then
            begin
              //
            end;
            
            nO_Valid := 'Y';
            if OneJo.B['is_closed'] then
              nO_Valid := 'N'
            else
              nO_Valid := 'Y';

            if (Trim(SO(ArrsJaSub.S[0]).S['specification']) <> 'null')
              and (Trim(SO(ArrsJaSub.S[0]).S['specification']) <> '') then
              nStockName := SO(ArrsJaSub.S[0]).S['specification']
            else
              nStockName := SO(ArrsJaSub.S[0]).S['product_name'];

            if Pos('��',nStockName) > 0 then
              nType := '��װ'
            else
              nType := 'ɢװ';

            nStr := MakeSQLByStr([SF('O_Order', OneJo.S['ordername']),
                SF('O_Factory', ''),
                SF('O_CusName', OneJo.S['partner_name']),
                SF('O_ConsignCusName', ''),
                SF('O_StockName', nStockName),
                SF('O_StockType', nType),
                SF('O_Lading', '������'),
                SF('O_CusPY', GetPinYinOfStr(OneJo.S['partner_name'])),
                SF('O_PlanAmount', FloatToStr(SO(ArrsJaSub.S[0]).D['product_qty'])),        //����
                SF('O_PlanDone', '0'),
                SF('O_PlanRemain', FloatToStr(SO(ArrsJaSub.S[0]).D['remainder'])),          //ʣ��δ������
                SF('O_PlanBegin', StrToDateDef(OneJo.S['confirmation_date'],Now),sfDateTime),
                SF('O_PlanEnd', StrToDateDef(OneJo.S['confirmation_date'],Now),sfDateTime),
                SF('O_Company', ''),
                SF('O_Depart', ''),
                SF('O_SaleMan', OneJo.S['seller']),
                SF('O_Remark', ''),
                SF('O_Price', SO(ArrsJaSub.S[0]).D['price_unit'],sfVal),
                SF('O_Valid', nO_Valid),
                SF('O_Freeze', 0, sfVal),
                SF('O_HasDone', 0, sfVal),
                SF('O_CompanyID', ''),
                SF('O_CusID', OneJo.S['partner_name']),
                SF('O_StockID', SO(ArrsJaSub.S[0]).S['productid']),
                SF('O_PackingID', ''),
                SF('O_FactoryID', ''),
                SF('O_Create', Now,sfDateTime),
                SF('O_Modify', Now,sfDateTime)
                ], sTable_SalesOrder, '', True);
            FListA.Add(nStr);

            nStr := SF('O_Order', OneJo.S['ordername']);
            nStr := MakeSQLByStr([
                SF('O_Factory', ''),
                SF('O_CusName', OneJo.S['partner_name']),
                SF('O_ConsignCusName', ''),
                SF('O_StockName', nStockName),
                SF('O_StockType', nType),
                SF('O_Lading', '������'),
                SF('O_CusPY',      GetPinYinOfStr(OneJo.S['partner_name'])),
                SF('O_PlanAmount', FloatToStr(SO(ArrsJaSub.S[0]).D['product_qty'])),
                SF('O_PlanDone', '0'),
                SF('O_PlanRemain',FloatToStr(SO(ArrsJaSub.S[0]).D['remainder'])),
                SF('O_PlanBegin', StrToDateDef(OneJo.S['confirmation_date'],Now),sfDateTime),
                SF('O_PlanEnd', StrToDateDef(OneJo.S['confirmation_date'],Now),sfDateTime),
                SF('O_Company', ''),
                SF('O_Depart', ''),
                SF('O_SaleMan', OneJo.S['seller']),
                SF('O_Remark', ''),
                SF('O_Price', SO(ArrsJaSub.S[0]).D['price_unit'],sfVal),
                SF('O_Valid',  nO_Valid),
                SF('O_Freeze', 0, sfVal),
                SF('O_HasDone', 0, sfVal),
                SF('O_CompanyID', ''),
                SF('O_CusID',   OneJo.S['partner_name']),
                SF('O_StockID', SO(ArrsJaSub.S[0]).S['productid']),
                SF('O_PackingID', ''),
                SF('O_FactoryID', ''),
                SF('O_Create', Now,sfDateTime),
                SF('O_Modify', Now,sfDateTime)
                ], sTable_SalesOrder, nStr, False);
            FListC.Add(nStr);

            nStr := 'Select * from %s where O_Order = ''%s'' ';
            nStr := Format(nStr, [sTable_SalesOrder, OneJo.S['ordername']]);
            FListD.Add(nStr);
          end;
        end;
      end
      else
      begin
        WriteLog('��ȡ���۶���ʧ��');
        Result     := False;
        FOut.FData :='��ȡ���۶���ʧ��';
        FOut.FBase.FResult := True;
      end;
    end;

    if (FListD.Count > 0) then
    try
      FDBConn.FConn.BeginTrans;
      //��������
      for nIdx:=0 to FListD.Count - 1 do
      begin
        with gDBConnManager.WorkerQuery(FDBConn,FListD[nIdx]) do
        begin
          if nIdx = 0 then
          begin
            nSQL := ' Update %s Set O_Valid = ''%s'' ';
            nSQL := Format(nSQL, [sTable_SalesOrder,'N']);
            gDBConnManager.WorkerExec(FDBConn, nSQL);
          end;
          if RecordCount>0 then
          begin
            gDBConnManager.WorkerExec(FDBConn,FListC[nIdx]);
          end else
          begin
            gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
          end;
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    ReStream.Free;
    nDataStream.Free;
    PostStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SynWxSalePound(var nData: string): Boolean;
var
  nStr, szUrl, nSQL, nType, nDate, nInTime : string;
  ReJo, OneJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream:TStringstream;
  nIdx: Integer;
  nPDate, nMDate: TDateTime;
  nDataStream: TMsMultiPartFormDataStream;
begin
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;
  FListD.Clear;
  FListE.Clear;
  Result   := False;
  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');
  nDataStream := TMsMultiPartFormDataStream.Create;
  
  try
    wParam.Clear;
    wParam.Values['token']   := Ftoken;

    nSQL := ' select *,(P_MValue-P_PValue) as D_NetWeight From %s a, '+
    ' %s b, %s c where a.O_Order=b.L_Order and b.L_ID=c.P_Bill and c.P_Bill = ''%s'' ';

    nSQL := Format(nSQL,[sTable_SalesOrder,sTable_Bill,sTable_PoundLog,FIn.FData]);
    with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
    begin
      if RecordCount < 1 then
      begin
        nData := '������Ϊ[ %s ]�����۰���������.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;

      try
        nInTime := FieldByName('L_InTime').AsString;
        nPDate  := FieldByName('P_PDate').AsDateTime;
        nMDate  := FieldByName('P_MDate').AsDateTime;
        if nMDate > nPDate then
          nDate := FieldByName('P_MDate').AsString
        else
          nDate := FieldByName('P_PDate').AsString;
      except
          nDate := FieldByName('P_PDate').AsString;
      end;
      if Length(Trim(nDate)) <= 10 then
        nDate := nDate + ' 00:00:01';

      if Length(Trim(nInTime)) <= 10 then
        nInTime := nInTime + ' 00:00:01';

      wParam.Values['yktorderno']    := FieldByName('L_ID').AsString;
      wParam.Values['batchno']       := FieldByName('L_HYDan').AsString;
      wParam.Values['approachtime']  := nInTime;
      wParam.Values['ordername']     := FieldByName('O_Order').AsString;
      wParam.Values['weightime']     := nDate;
      wParam.Values['trucknumber']   := FieldByName('P_Truck').AsString;
      wParam.Values['productid']     := FieldByName('P_MID').AsString;
      wParam.Values['tareweight']    := FieldByName('P_PValue').AsString;
      wParam.Values['grossweight']   := FieldByName('P_MValue').AsString;
      if Trim(FieldByName('L_CKValue').AsString) <> '' then
      begin
        wParam.Values['rotorweight'] := FieldByName('L_CKValue').AsString;
      end;
      wParam.Values['weight']        := FieldByName('D_NetWeight').AsString;
      wParam.Values['remainder']     := FloatToStr(StrToFLoatDef(FieldByName('O_PlanRemain').AsString,0)
                                         - StrToFLoatDef(FieldByName('D_NetWeight').AsString,0));

      nDataStream.AddFormField('token', Ftoken);
      nDataStream.AddFormField('yktorderno', FieldByName('L_ID').AsString);
      nDataStream.AddFormField('batchno',    FieldByName('L_HYDan').AsString);
      nDataStream.AddFormField('approachtime', nInTime);
      nDataStream.AddFormField('ordername', FieldByName('O_Order').AsString);
      nDataStream.AddFormField('weightime', nDate);
      nDataStream.AddFormField('trucknumber', Ansitoutf8(FieldByName('P_Truck').AsString));
      nDataStream.AddFormField('productid', FieldByName('P_MID').AsString);
      nDataStream.AddFormField('tareweight', FieldByName('P_PValue').AsString);
      nDataStream.AddFormField('grossweight', FieldByName('P_MValue').AsString);
      if Trim(FieldByName('L_CKValue').AsString) <> '' then
      begin
        nDataStream.AddFormField('rotorweight', FieldByName('L_CKValue').AsString);
      end;

      nDataStream.AddFormField('weight', FieldByName('D_NetWeight').AsString);
      nDataStream.AddFormField('remainder', FloatToStr(StrToFLoatDef(FieldByName('O_PlanRemain').AsString,0)
                                         - StrToFLoatDef(FieldByName('D_NetWeight').AsString,0)) + CRLF);

      nDataStream.done;
    end;

    nStr := 'token:'+Ftoken;
    WriteLog('��ѯ���۰�����Σ�' + wParam.Text);

    szUrl := gSysParam.FWXERPUrl + '/saleweigh';

    FIdHttp.HTTPOptions:=FIdHttp.HTTPOptions+[hoKeepOrigProtocol];
    FidHttp.ProtocolVersion:= pv1_1;
    FidHttp.Request.ContentType := nDataStream.RequestContentType;
    FidHttp.Post(szUrl, nDataStream, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);

    WriteLog('���۰������Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if (ArrsJa <> nil) and (ArrsJa.Length > 0) then
      begin
        OneJo := SO(ArrsJa.S[0]);
        WriteLog('�������:' +OneJo.S['batchno'] );
        //���°������κ�
        nStr := ' update %s set P_BDAX=''1'',P_BDNUM=P_BDNUM+1, P_stockpickname=''%s'', ' +
                ' P_stockmovelineid=''%s'', P_Batchno = ''%s'' where P_Bill = ''%s'' ';
        nStr := Format(nStr,[sTable_PoundLog,OneJo.S['stockpickname'], OneJo.S['stockmovelineid'],OneJo.S['batchno'],FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn,nStr);

        //����ͬ��״̬
        nStr := ' update %s set L_BDAX=''1'',L_BDNUM=L_BDNUM+1 where L_ID = ''%s'' ';
        nStr := Format(nStr,[sTable_Bill,FIn.FData]);

        gDBConnManager.WorkerExec(FDBConn,nStr);
//        nStr := ' update %s set L_HYDan = ''%s'' where L_ID = ''%s'' ';
//        nStr := Format(nStr,[sTable_Bill,OneJo.S['batchno'],FIn.FData]);
//        gDBConnManager.WorkerExec(FDBConn,nStr);

        //���»��鵥���κ�
        nStr := ' update %s set H_SerialNo = ''%s'' where H_Bill= ''%s'' ';
        nStr := Format(nStr,[sTable_StockHuaYan,OneJo.S['batchno'],FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn,nStr);

        FOut.FData := sFlag_Yes;
        Result := True;
      end
      else
      begin
        WriteLog('��ȡ���۰���ʧ��');
        Result     := False;
        FOut.FData :='��ȡ���۰���ʧ��';
        FOut.FBase.FResult := True;
      end;
    end;

  finally
    ReStream.Free;
    nDataStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHYInfo(var nData: string): Boolean;
var nStr, nProStr, nMatStr, nSQL: string;
    nValue: Double;
    nYearMonth,szUrl  : string;
    ReJo, OneJo : ISuperObject;
    ArrsJa,ArrsJaSub,Arrskz3,Arrskz28,Arrsky3,Arrsky28: TSuperArray;
    wParam: TStrings;
    ReStream:TStringstream;
    nIdx, k : Integer;
    nYear, nMonth, nDays : Word;
    kz31,kz32,kz33,kz281,kz282,kz283:string;
    ky31,ky32,ky33,ky34,ky35,ky36:string;
    ky281,ky282,ky283,ky284,ky285,ky286:string;
begin
  Result := False;

  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');

  try
    wParam.Clear;
    wParam.Values['token']     := Ftoken;

    nSQL := ' select * From %s a, %s b, %s c where a.O_Order=b.L_Order '+
            ' and b.L_ID=c.P_Bill and c.P_Bill = ''%s'' ';

    nSQL := Format(nSQL,[sTable_SalesOrder,sTable_Bill,sTable_PoundLog,FIn.FData]);
    with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
    begin
      if RecordCount < 1 then
      begin
        nData := '������Ϊ[ %s ]�����۰���������.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;

      wParam.Values['batchno'] := FieldByName('P_Batchno').AsString;
      wParam.Values['ordername'] := FieldByName('L_Order').AsString;
    end;

    WriteLog('��ѯ�ʼ���Ϣ��Σ�' + wParam.Text);

    szUrl := gSysParam.FWXERPUrl + '/qualityreport';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);


    WriteLog('�ʼ���Ϣ���Σ�' + nStr);
    FListA.Clear;
    FListC.Clear;
    FListD.Clear;
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if ArrsJa <> nil then
      begin
        for nIdx := 0 to ArrsJa.Length - 1 do
        begin
          OneJo := SO(ArrsJa.S[nIdx]);

          ArrsJaSub   := OneJo.A['prdcomponent'];
          Arrskz3     := OneJo.A['kz3'];
          Arrskz28    := OneJo.A['kz28'];
          Arrsky3     := OneJo.A['ky3'];
          Arrsky28    := OneJo.A['ky28'];

          if Arrskz3 <> nil then
          begin
            for k := 0 to Arrskz3.Length - 1 do
            begin
              if k = 0 then
                kz31 := Arrskz3.S[k]
              else if k = 1 then
                kz32 := Arrskz3.S[k]
              else if k = 2 then
                kz33 := Arrskz3.S[k];
            end;
          end;

          if Arrskz28 <> nil then
          begin
            for k := 0 to Arrskz28.Length - 1 do
            begin
              if k = 0 then
                kz281 := Arrskz28.S[k]
              else if k = 1 then
                kz282 := Arrskz28.S[k]
              else if k = 2 then
                kz283 := Arrskz28.S[k];
            end;
          end;

          if Arrsky3 <> nil then
          begin
            for k := 0 to Arrsky3.Length - 1 do
            begin
              if k = 0 then
                ky31 := Arrsky3.S[k]
              else if k = 1 then
                ky32 := Arrsky3.S[k]
              else if k = 2 then
                ky33 := Arrsky3.S[k]
              else if k = 3 then
                ky34 := Arrsky3.S[k]
              else if k = 4 then
                ky35 := Arrsky3.S[k]
              else if k = 5 then
                ky36 := Arrsky3.S[k];
            end;
          end;

          if Arrsky28 <> nil then
          begin
            for k := 0 to Arrsky28.Length - 1 do
            begin
              if k = 0 then
                ky281 := Arrsky28.S[k]
              else if k = 1 then
                ky282 := Arrsky28.S[k]
              else if k = 2 then
                ky283 := Arrsky28.S[k]
              else if k = 3 then
                ky284 := Arrsky28.S[k]
              else if k = 4 then
                ky285 := Arrsky28.S[k]
              else if k = 5 then
                ky286 := Arrsky28.S[k];
            end;
          end;

          nStr := MakeSQLByStr([SF('R_SerialNo', OneJo.S['batchno']),
              SF('R_PID', OneJo.S['prdtype']),
              SF('R_SGType', ''),
              SF('R_SGValue', ''),
              SF('R_HHCType', ''),
              SF('R_HHCValue', ''),
              SF('R_MgO', OneJo.S['yhm']),
              SF('R_SO3', OneJo.S['syhl']),
              SF('R_ShaoShi', OneJo.S['ssl']),
              SF('R_CL', OneJo.S['llz']),
              SF('R_BiBiao', OneJo.S['bbmj']),
              SF('R_ChuNing',OneJo.S['cy']),
              SF('R_ZhongNing', OneJo.S['zy']),
              SF('R_AnDing',''),
              SF('R_XiDu', OneJo.S['prdstrength']),
              SF('R_Jian',OneJo.S['jhl']),
              SF('R_ChouDu', OneJo.S['bzcd']),
              SF('R_BuRong',''),
              SF('R_YLiGai', OneJo.S['ylyhg']),
              SF('R_Water',''),
              SF('R_KuangWu',''),
              SF('R_GaiGui', ''),
              SF('R_3DZhe1',kz31),
              SF('R_3DZhe2',kz32),
              SF('R_3DZhe3',kz33),
              SF('R_28Zhe1',kz281),
              SF('R_28Zhe2',kz282),
              SF('R_28Zhe3',kz283),
              SF('R_3DYa1',ky31),
              SF('R_3DYa2',ky32),
              SF('R_3DYa3',ky33),
              SF('R_3DYa4',ky34),
              SF('R_3DYa5',ky35),
              SF('R_3DYa6',ky36),
              SF('R_28Ya1',ky281),
              SF('R_28Ya2',ky282),
              SF('R_28Ya3',ky283),
              SF('R_28Ya4',ky284),
              SF('R_28Ya5',ky285),
              SF('R_28Ya6',ky286),
              SF('R_Date', StrToDateDef(OneJo.S['reportdate'],Now),sfDateTime),
              SF('R_reportid', OneJo.S['reportid']),
              SF('R_Memo', OneJo.S['prdresult'])
              ], sTable_StockRecord, '', True);
          FListA.Add(nStr);

          nStr := SF('R_reportid', OneJo.S['reportid']);
          nStr := MakeSQLByStr([SF('R_SerialNo', OneJo.S['batchno']),
              SF('R_PID', OneJo.S['prdtype']),
              SF('R_SGType', ''),
              SF('R_SGValue', ''),
              SF('R_HHCType', ''),
              SF('R_HHCValue', ''),
              SF('R_MgO', OneJo.S['yhm']),
              SF('R_SO3', OneJo.S['syhl']),
              SF('R_ShaoShi', OneJo.S['ssl']),
              SF('R_CL', OneJo.S['llz']),
              SF('R_BiBiao', OneJo.S['bbmj']),
              SF('R_ChuNing',OneJo.S['cy']),
              SF('R_ZhongNing', OneJo.S['zy']),
              SF('R_AnDing',''),
              SF('R_XiDu', OneJo.S['prdstrength']),
              SF('R_Jian',OneJo.S['jhl']),
              SF('R_ChouDu', OneJo.S['bzcd']),
              SF('R_BuRong',''),
              SF('R_YLiGai', OneJo.S['ylyhg']),
              SF('R_Water',''),
              SF('R_KuangWu',''),
              SF('R_GaiGui', ''),
              SF('R_3DZhe1',kz31),
              SF('R_3DZhe2',kz32),
              SF('R_3DZhe3',kz33),
              SF('R_28Zhe1',kz281),
              SF('R_28Zhe2',kz282),
              SF('R_28Zhe3',kz283),
              SF('R_3DYa1',ky31),
              SF('R_3DYa2',ky32),
              SF('R_3DYa3',ky33),
              SF('R_3DYa4',ky34),
              SF('R_3DYa5',ky35),
              SF('R_3DYa6',ky36),
              SF('R_28Ya1',ky281),
              SF('R_28Ya2',ky282),
              SF('R_28Ya3',ky283),
              SF('R_28Ya4',ky284),
              SF('R_28Ya5',ky285),
              SF('R_28Ya6',ky286),
              SF('R_Date', StrToDateDef(OneJo.S['reportdate'],Now),sfDateTime),
              SF('R_Memo', OneJo.S['prdresult'])
              ], sTable_StockRecord, nStr, False);
          FListC.Add(nStr);

          nStr := ' Select * from %s where R_reportid = ''%s'' ';
          nStr := Format(nStr, [sTable_StockRecord, OneJo.S['reportid']]);
          FListD.Add(nStr);
        end;
      end
      else
      begin
        WriteLog('��ȡ�ʼ���Ϣʧ��');
        Result     := False;
      end;
    end;

    if (FListD.Count > 0) then
    try
      FDBConn.FConn.BeginTrans;
      //��������
      for nIdx:=0 to FListD.Count - 1 do
      begin
        with gDBConnManager.WorkerQuery(FDBConn,FListD[nIdx]) do
        begin
          if RecordCount>0 then
          begin
            gDBConnManager.WorkerExec(FDBConn,FListC[nIdx]);
          end else
          begin
            gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
          end;
        end;
      end;
      Result := True;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SynWxPoundKW(var nData: string): Boolean;
var
  nStr, szUrl, nSQL, nType, nDate : string;
  ReJo, OneJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream:TStringstream;
  nIdx: Integer;
  nDataStream: TMsMultiPartFormDataStream;
begin
  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FData);
  Result      := False;
  wParam      := TStringList.Create;
  ReStream    := TStringstream.Create('');
  nDataStream := TMsMultiPartFormDataStream.Create;
  try
    wParam.Clear;
    wParam.Values['token']   := Ftoken;
    
    nDataStream.AddFormField('token', Ftoken);

    if FListA.Values['P_TYPE'] = 'S' then
    begin
      nSQL := 'select *,(P_MValue-P_PValue) as D_NetWeight From %s a,'+
      ' %s b, %s c where a.O_Order=b.L_Order and b.L_ID=c.P_Bill and c.P_ID = ''%s'' ';

      nSQL := Format(nSQL,[sTable_SalesOrder,sTable_Bill,sTable_PoundLog,FListA.Values['P_ID']]);
    end
    else
    begin
      nSQL := 'select *,(P_MValue-P_PValue - isnull(P_KZValue,0)) as D_NetWeight From %s a,'+
      ' %s b, %s c where a.D_OID=b.O_ID and a.D_ID=c.P_OrderBak and c.P_ID = ''%s'' ';

      nSQL := Format(nSQL,[sTable_OrderDtl,sTable_Order,sTable_PoundLog,FListA.Values['P_ID']]);
    end;

    with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
    begin
      if RecordCount < 1 then
      begin
        nData := '������Ϊ[ %s ]�İ���������.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
      
      if FieldByName('P_Type').AsString = 'S' then
      begin
        wParam.Values['ordertype']     := '2';
        wParam.Values['ordername']     := FieldByName('O_Order').AsString;
        wParam.Values['rotorweight']   := FieldByName('L_CKValue').AsString;

        nDataStream.AddFormField('ordertype', '2');
        nDataStream.AddFormField('ordername',   FieldByName('O_Order').AsString);
        nDataStream.AddFormField('rotorweight', FieldByName('L_CKValue').AsString);
      end
      else
      begin
        wParam.Values['ordertype']     := '1';
        wParam.Values['ordername']     := FieldByName('O_BID').AsString;

        nDataStream.AddFormField('ordertype', '1');
        nDataStream.AddFormField('ordername',   FieldByName('O_BID').AsString);
      end;
      wParam.Values['status']          := FListA.Values['P_Status'];
      wParam.Values['stockpickname']   := FieldByName('P_stockpickname').AsString;
      wParam.Values['stockmovelineid'] := FieldByName('P_stockmovelineid').AsString;
      wParam.Values['trucknumber']     := FieldByName('P_Truck').AsString;
      wParam.Values['productid']       := FieldByName('P_MID').AsString;
      wParam.Values['tareweight']      := FieldByName('P_PValue').AsString;
      wParam.Values['grossweight']     := FieldByName('P_MValue').AsString;
      wParam.Values['weight']          := FieldByName('D_NetWeight').AsString;
      wParam.Values['deductweight']    := FieldByName('P_KZValue').AsString;
      wParam.Values['batchno']         := FieldByName('P_Batchno').AsString;

      nDataStream.AddFormField('status',          FListA.Values['P_Status']);
      nDataStream.AddFormField('stockpickname',   Ansitoutf8(FieldByName('P_stockpickname').AsString));
      nDataStream.AddFormField('stockmovelineid', FieldByName('P_stockmovelineid').AsString);
      nDataStream.AddFormField('trucknumber',     Ansitoutf8(FieldByName('P_Truck').AsString));
      nDataStream.AddFormField('productid',       FieldByName('P_MID').AsString);
      nDataStream.AddFormField('tareweight',      FieldByName('P_PValue').AsString);
      nDataStream.AddFormField('grossweight',     FieldByName('P_MValue').AsString);
      nDataStream.AddFormField('weight',          FieldByName('D_NetWeight').AsString);
      nDataStream.AddFormField('deductweight',    FieldByName('P_KZValue').AsString);
      nDataStream.AddFormField('batchno',         FieldByName('P_Batchno').AsString + CRLF);
      nDataStream.done;
    end;

    nStr := 'token:'+Ftoken;
    WriteLog('��ѯ���������Σ�' + wParam.Text);

    szUrl := gSysParam.FWXERPUrl + '/modifyweigh';

    FIdHttp.HTTPOptions:=FIdHttp.HTTPOptions+[hoKeepOrigProtocol];
    FidHttp.ProtocolVersion:= pv1_1;
    FidHttp.Request.ContentType := nDataStream.RequestContentType;
    FidHttp.Post(szUrl, nDataStream, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);

    WriteLog('����������Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if (ArrsJa <> nil) and (ArrsJa.Length > 0) then
      begin
        FOut.FData := sFlag_Yes;
        Result := True;
      end
      else
      begin
        WriteLog('��ȡ�������ʧ��');
        Result     := False;
        FOut.FData :='��ȡ�������ʧ��';
        FOut.FBase.FResult := True;
      end;
    end;
  finally
    ReStream.Free;
    nDataStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SynOrderTruckNum(
  var nData: string): Boolean;
var
  nStr, szUrl, nSQL, nType, nDate : string;
  ReJo, OneJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream:TStringstream;
  nIdx,nTruckNum: Integer;
  nDataStream: TMsMultiPartFormDataStream;
begin
  Result      := False;
  wParam      := TStringList.Create;
  ReStream    := TStringstream.Create('');
  nDataStream := TMsMultiPartFormDataStream.Create;
  try
    wParam.Clear;
    wParam.Values['token']   := Ftoken;

    nSQL := ' Select COUNT(*) From %s o  Where o.O_BID=''%s'' ' +
            ' And not exists(Select R_ID from P_OrderDtl od where o.O_ID=od.D_OID and od.D_Status = ''O'' ) ';

    nSQL := Format(nSQL,[sTable_Order,FIn.FData]);

    nTruckNum := 0;
    with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
    begin
      nTruckNum := Fields[0].AsInteger;
      
      wParam.Values['ordername']    := FIn.FData;
      wParam.Values['vehiclenum']   := IntToStr(nTruckNum);
    end;

    nStr := 'token:'+Ftoken;


    nDataStream.AddFormField('token', Ftoken);
    nDataStream.AddFormField('ordername', FIn.FData);
    nDataStream.AddFormField('vehiclenum', IntToStr(nTruckNum) + CRLF);
    nDataStream.done;

    szUrl := gSysParam.FWXERPUrl + '/purchaseorder/vehiclenum';
    WriteLog('�ɹ������������볡������Σ�' + szUrl + wParam.Text);
    FIdHttp.HTTPOptions:=FIdHttp.HTTPOptions+[hoKeepOrigProtocol];
    FidHttp.ProtocolVersion:= pv1_1;
    FidHttp.Request.ContentType := nDataStream.RequestContentType;
    FidHttp.Post(szUrl, nDataStream, ReStream);
    
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);

    WriteLog('�ɹ������������볡�������Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if (ArrsJa <> nil) and (ArrsJa.Length > 0) then
      begin
        FOut.FData := sFlag_Yes;
        Result := True;
      end
      else
      begin
        WriteLog('�ɹ������������볡����ʧ��');
        Result     := False;
        FOut.FData :='�ɹ������������볡����ʧ��';
        FOut.FBase.FResult := True;
      end;
    end;
  finally
    ReStream.Free;
    nDataStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SynSaleTruckNum(
  var nData: string): Boolean;
var
  nStr, szUrl, nSQL, nType, nDate : string;
  ReJo, OneJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream:TStringstream;
  nIdx,nTruckNum: Integer;
begin
  Result      := False;
  wParam      := TStringList.Create;
  ReStream    := TStringstream.Create('');
  try
    wParam.Clear;
    wParam.Values['token']   := Ftoken;

    nSQL := ' select count(*) From %s  '+
    ' where L_ZhiKa = ''%s'' and L_OutFact is null ';

    nSQL := Format(nSQL,[sTable_Bill,FIn.FData]);

    nTruckNum := 0;
    with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
    begin
      nTruckNum := Fields[0].AsInteger;
      
      wParam.Values['ordername']    := FIn.FData;
      wParam.Values['vehiclenum']   := IntToStr(nTruckNum);
    end;

    nStr := 'token:'+Ftoken;
    WriteLog('���۶����������볡������Σ�' + wParam.Text);

    szUrl := gSysParam.FWXERPUrl + '/saleorder/vehiclenum';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);

    WriteLog('���۶����������볡�������Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if (ArrsJa <> nil) and (ArrsJa.Length > 0) then
      begin
        FOut.FData := sFlag_Yes;
        Result := True;
      end
      else
      begin
        WriteLog('���۶����������볡����ʧ��');
        Result     := False;
        FOut.FData :='���۶����������볡����ʧ��';
        FOut.FBase.FResult := True;
      end;
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetSaleInfo_One(
  var nData: string): Boolean;
var nStr, nProStr, nMatStr, nYearStr,nSQL: string;
    nO_Valid, nStockName : string;
    nValue: Double;
    nYearMonth,szUrl, nType : string;
    ReJo, OneJo : ISuperObject;
    ArrsJa,ArrsJaSub: TSuperArray;
    wParam: TStrings;
    ReStream,PostStream:TStringstream;
    nIdx: Integer;
    nYear, nMonth, nDays : Word;
    nDataStream: TMsMultiPartFormDataStream;
    nOut: TWorkerBusinessCommand;
    nOrderName,nToken:string;
function GetLoginToken: string;
var
  nStr, szUrl: string;
  ReJo, ReSubJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream:TStringstream;
begin
  Result   := '';
  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');

  try
    wParam.Clear;
    wParam.Values['username'] := gSysParam.FWXZhangHu;
    wParam.Values['password'] := gSysParam.FWXMiMa;

    szUrl := gSysParam.FWXERPUrl+'/login';
    FidHttp.Request.ContentType := 'application/x-www-form-urlencoded';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);

    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReSubJo := SO(ReJo.S['Response']);
      if ReSubJo.S['token'] <> '' then
      begin
        Result := ReSubJo.S['token'];
      end
      else
      begin
        Result := '';
      end;
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;
begin
  Result := True;
  nToken := '';
  nToken := GetLoginToken;
  if nToken <> '' then
  begin
    wParam      := TStringList.Create;
    ReStream    := TStringstream.Create('');
    nDataStream := TMsMultiPartFormDataStream.Create;

    FListA.Text := PackerDecodeStr(FIn.FData);
    nOrderName  := PackerDecodeStr(FIn.FData);
    try
      wParam.Clear;
      wParam.Values['token']     := nToken;

      wParam.Values['starttime'] := DateTime2Str(IncMonth(Now,-12));
      wParam.Values['endtime']   := DateTime2Str(Now);

      if FListA.Text <> '' then
        wParam.Values['ordername'] := FListA.Text;

      nStr := 'token:'+Ftoken;
      WriteLog('��ѯ���۶�����Σ�' + wParam.Text);

      nDataStream.AddFormField('token', Ftoken);
      nDataStream.AddFormField('starttime', DateTime2Str(IncMonth(Now,-12)));


      if FListA.Text <> '' then
      begin
        nDataStream.AddFormField('endtime', DateTime2Str(Now));
        nDataStream.AddFormField('ordername', Ansitoutf8(FListA.Text));
      end
      else
        nDataStream.AddFormField('endtime', DateTime2Str(Now) + CRLF);
      nDataStream.done;

      szUrl := gSysParam.FWXERPUrl + '/saleorder';
      nStr      := Ansitoutf8(wParam.Text);
      PostStream:= TStringStream.Create(nStr);

      FIdHttp.HTTPOptions:=FIdHttp.HTTPOptions+[hoKeepOrigProtocol];
      FidHttp.ProtocolVersion:= pv1_1;
      FidHttp.Request.ContentType := nDataStream.RequestContentType;
      FidHttp.Post(szUrl, nDataStream, ReStream);
      nStr := ReStream.DataString;
      nStr := UTF8Decode(ReStream.DataString);
      nStr := UnicodeToChinese(nStr);


      WriteLog('���۶������Σ�' + nStr);
      FListA.Clear;
      FListC.Clear;
      FListD.Clear;
      if nStr <> '' then
      begin
        ReJo    := SO(nStr);
        ReJo    := SO(ReJo.S['Response']);
        ArrsJa  := ReJo.A['Infos'];
        if ArrsJa <> nil then
        begin
          if ArrsJa.Length = 0 then
          begin
            WriteLog('���ڼ������۶���');
            Result     := True;
            FOut.FData :='';
            FOut.FBase.FResult := True;
          end
          else
          begin
            for nIdx := 0 to ArrsJa.Length - 1 do
            begin
              OneJo := SO(ArrsJa.S[nIdx]);

              ArrsJaSub  := OneJo.A['products'];

              if Pos('��',SO(ArrsJaSub.S[0]).S['product_uom']) > 0 then
                nType := '��װ'
              else
                nType := 'ɢװ';

              if StrToFloatDef(SO(ArrsJaSub.S[0]).S['remainder'],0) <> 0 then
              begin
                //
              end;

              nO_Valid := 'Y';
              if OneJo.B['is_closed'] then
                nO_Valid := 'N'
              else
                nO_Valid := 'Y';

              if (Trim(SO(ArrsJaSub.S[0]).S['specification']) <> 'null')
                and (Trim(SO(ArrsJaSub.S[0]).S['specification']) <> '') then
                nStockName := SO(ArrsJaSub.S[0]).S['specification']
              else
                nStockName := SO(ArrsJaSub.S[0]).S['product_name'];

              nStr := MakeSQLByStr([SF('O_Order', OneJo.S['ordername']),
                  SF('O_Factory', ''),
                  SF('O_CusName', OneJo.S['partner_name']),
                  SF('O_ConsignCusName', ''),
                  SF('O_StockName', nStockName),
                  SF('O_StockType', nType),
                  SF('O_Lading', '������'),
                  SF('O_CusPY', GetPinYinOfStr(OneJo.S['partner_name'])),
                  SF('O_PlanAmount', FloatToStr(SO(ArrsJaSub.S[0]).D['product_qty'])),        //����
                  SF('O_PlanDone', '0'),
                  SF('O_PlanRemain', FloatToStr(SO(ArrsJaSub.S[0]).D['remainder'])),          //ʣ��δ������
                  SF('O_PlanBegin', StrToDateDef(OneJo.S['confirmation_date'],Now),sfDateTime),
                  SF('O_PlanEnd', StrToDateDef(OneJo.S['confirmation_date'],Now),sfDateTime),
                  SF('O_Company', ''),
                  SF('O_Depart', ''),
                  SF('O_SaleMan', OneJo.S['seller']),
                  SF('O_Remark', ''),
                  SF('O_Price', SO(ArrsJaSub.S[0]).D['price_unit'],sfVal),
                  SF('O_Valid', nO_Valid),
                  SF('O_Freeze', 0, sfVal),
                  SF('O_HasDone', 0, sfVal),
                  SF('O_CompanyID', ''),
                  SF('O_CusID', OneJo.S['partner_name']),
                  SF('O_StockID', SO(ArrsJaSub.S[0]).S['productid']),
                  SF('O_PackingID', ''),
                  SF('O_FactoryID', ''),
                  SF('O_Create', Now,sfDateTime),
                  SF('O_Modify', Now,sfDateTime)
                  ], sTable_SalesOrder, '', True);
              FListA.Add(nStr);

              nStr := SF('O_Order', OneJo.S['ordername']);
              nStr := MakeSQLByStr([
                  SF('O_Factory', ''),
                  SF('O_CusName', OneJo.S['partner_name']),
                  SF('O_ConsignCusName', ''),
                  SF('O_StockName', nStockName),
                  SF('O_StockType', nType),
                  SF('O_Lading', '������'),
                  SF('O_CusPY',      GetPinYinOfStr(OneJo.S['partner_name'])),
                  SF('O_PlanAmount', FloatToStr(SO(ArrsJaSub.S[0]).D['product_qty'])),
                  SF('O_PlanDone', '0'),
                  SF('O_PlanRemain',FloatToStr(SO(ArrsJaSub.S[0]).D['remainder'])),
                  SF('O_PlanBegin', StrToDateDef(OneJo.S['confirmation_date'],Now),sfDateTime),
                  SF('O_PlanEnd', StrToDateDef(OneJo.S['confirmation_date'],Now),sfDateTime),
                  SF('O_Company', ''),
                  SF('O_Depart', ''),
                  SF('O_SaleMan', OneJo.S['seller']),
                  SF('O_Remark', ''),
                  SF('O_Price', SO(ArrsJaSub.S[0]).D['price_unit'],sfVal),
                  SF('O_Valid',  nO_Valid),
                  SF('O_Freeze', 0, sfVal),
                  SF('O_HasDone', 0, sfVal),
                  SF('O_CompanyID', ''),
                  SF('O_CusID',   OneJo.S['partner_name']),
                  SF('O_StockID', SO(ArrsJaSub.S[0]).S['productid']),
                  SF('O_PackingID', ''),
                  SF('O_FactoryID', ''),
                  SF('O_Create', Now,sfDateTime),
                  SF('O_Modify', Now,sfDateTime)
                  ], sTable_SalesOrder, nStr, False);
              FListC.Add(nStr);

              nStr := 'Select * from %s where O_Order = ''%s'' ';
              nStr := Format(nStr, [sTable_SalesOrder, OneJo.S['ordername']]);
              FListD.Add(nStr);
            end;
          end;
        end
        else
        begin
          WriteLog('��ȡ���۶���ʧ��');
          Result     := False;
          FOut.FData :='��ȡ���۶���ʧ��';
          FOut.FBase.FResult := True;
        end;
      end;

      if (FListD.Count > 0) then
      try
        FDBConn.FConn.BeginTrans;
        //��������
        for nIdx:=0 to FListD.Count - 1 do
        begin
          with gDBConnManager.WorkerQuery(FDBConn,FListD[nIdx]) do
          begin
            if nIdx = 0 then
            begin
              nSQL := ' Update %s Set O_Valid = ''%s'' where  O_Order = ''%s'' ';
              nSQL := Format(nSQL, [sTable_SalesOrder,'N', nOrderName]);
              gDBConnManager.WorkerExec(FDBConn, nSQL);
            end;
            if RecordCount>0 then
            begin
              gDBConnManager.WorkerExec(FDBConn,FListC[nIdx]);
            end else
            begin
              gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
            end;
          end;
        end;
        FDBConn.FConn.CommitTrans;
      except
        if FDBConn.FConn.InTransaction then
          FDBConn.FConn.RollbackTrans;
        raise;
      end;
    finally
      ReStream.Free;
      nDataStream.Free;
      PostStream.Free;
      wParam.Free;
    end;
  end;
end;
{$ENDIF}

function TBusWorkerBusinessHHJY.GetOrderInfoEx(var nData: string): Boolean;
var nStr, nProStr, nMatStr, nYearStr, nSQL : string;
    nHasDone: Double;
    nYearMonth,szUrl : string;
    ReJo, OneJo : ISuperObject;
    ArrsJa,ArrsJaSub: TSuperArray;
    wParam: TStrings;
    ReStream:TStringstream;
    nIdx: Integer;
    nO_Valid: string;
    nYear, nMonth, nDays : Word;
    nDataStream: TMsMultiPartFormDataStream;
begin
  Result := False;

  FListA.Clear;
  FListB.Clear;
  FListC.Clear;
  FListD.Clear;
  FListE.Clear;
  Result      := True;
  wParam      := TStringList.Create;
  ReStream    := TStringstream.Create('');
  nDataStream := TMsMultiPartFormDataStream.Create;

  FListA.Text := PackerDecodeStr(FIn.FData);
  try
    wParam.Clear;
    wParam.Values['token']     := Ftoken;

    if FListA.Values['YearPeriod'] <> '' then
    begin
      nYearMonth := FListA.Values['YearPeriod'];
      nYear      := StrToInt(Copy(nYearMonth,1,Pos('-',nYearMonth)-1));
      nMonth     := StrToInt(Copy(nYearMonth,Pos('-',nYearMonth)+1,MaxInt));
      nDays      := DaysInAMonth(nYear,nMonth);
      wParam.Values['starttime'] := FListA.Values['YearPeriod']+'-01 00:00:00';
      wParam.Values['endtime']   := FListA.Values['YearPeriod']+'-'+inttostr(nDays)+' 23:59:59';
    end
    else
    begin
      wParam.Values['starttime'] := DateTime2Str(IncMonth(Now,-1));
      wParam.Values['endtime']   := DateTime2Str(Now);
    end;
    if FListA.Values['Materiel'] <> '' then
      wParam.Values['product_name'] := FListA.Values['Materiel'];
    if FListA.Values['Provider'] <> '' then
      wParam.Values['partner_name'] := FListA.Values['Provider'];

    nStr := 'token:'+Ftoken;
    WriteLog('��ѯ�ɹ�������Σ�' + nStr);

    nDataStream.AddFormField('token', Ftoken);
    if FListA.Values['YearPeriod'] <> '' then
    begin
      nYearMonth := FListA.Values['YearPeriod'];
      nYear      := StrToInt(Copy(nYearMonth,1,Pos('-',nYearMonth)-1));
      nMonth     := StrToInt(Copy(nYearMonth,Pos('-',nYearMonth)+1,MaxInt));
      nDays      := DaysInAMonth(nYear,nMonth);
      nDataStream.AddFormField('starttime', FListA.Values['YearPeriod']+'-01 00:00:00');
      if (FListA.Values['Materiel'] = '') and (FListA.Values['Provider'] = '') then
        nDataStream.AddFormField('endtime', FListA.Values['YearPeriod']+'-'+inttostr(nDays)+' 23:59:59'+ CRLF)
      else
        nDataStream.AddFormField('endtime', FListA.Values['YearPeriod']+'-'+inttostr(nDays)+' 23:59:59');
    end
    else
    begin
      nDataStream.AddFormField('starttime', DateTime2Str(IncMonth(Now,-1)));
      if (FListA.Values['Materiel'] = '') and (FListA.Values['Provider'] = '') then
        nDataStream.AddFormField('endtime', DateTime2Str(Now)+ CRLF)
      else
        nDataStream.AddFormField('endtime', DateTime2Str(Now));
    end;

    if FListA.Values['Materiel'] <> '' then
    begin
      nDataStream.AddFormField('product_name', FListA.Values['Materiel']);
    end;
    if FListA.Values['Provider'] <> '' then
    begin
      nDataStream.AddFormField('partner_name', FListA.Values['Provider']);
    end;
    nDataStream.done;

    szUrl := gSysParam.FWXERPUrl + '/purchaseorder';
    FIdHttp.HTTPOptions:=FIdHttp.HTTPOptions+[hoKeepOrigProtocol];
    FidHttp.ProtocolVersion:= pv1_1;
    FidHttp.Request.ContentType := nDataStream.RequestContentType;
    FidHttp.Post(szUrl, nDataStream, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);


    WriteLog('�ɹ��������Σ�' + nStr);
    FListA.Clear;
    FListB.Clear;
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if ArrsJa <> nil then
      begin
        if ArrsJa.Length = 0 then
        begin
          WriteLog('���ڼ��޲ɹ�����');
          Result     := True;
          FOut.FData :='';
          FOut.FBase.FResult := True;
        end
        else
        begin
          for nIdx := 0 to ArrsJa.Length - 1 do
          begin
            OneJo := SO(ArrsJa.S[nIdx]);
            
            WriteLog('��ȡ��ͨԭ���Ͻ����ƻ�:'+OneJo.S['ordername']);

            nO_Valid := 'Y';
            if OneJo.B['is_closed'] then
              nO_Valid := 'N'
            else
              nO_Valid := 'Y';

            ArrsJaSub          := OneJo.A['products'];
            try
              nHasDone := SO(ArrsJaSub.S[0]).D['product_qty']
                          - SO(ArrsJaSub.S[0]).D['remainder'];
              nHasDone := Float2PInt(nHasDone, cPrecision, False) / cPrecision;
              if nHasDone <= 0 then
                nHasDone := 0;
            except
              nHasDone := 0;
            end;
            nStr := MakeSQLByStr([
                SF('B_ID',        OneJo.S['ordername']),
                SF('B_ProID',     OneJo.S['partner_name']),
                SF('B_ProName',   OneJo.S['partner_name']),
                SF('B_StockNo',   SO(ArrsJaSub.S[0]).S['productid']),
                SF('B_StockName', SO(ArrsJaSub.S[0]).S['product_name']),
                SF('B_Value',     SO(ArrsJaSub.S[0]).S['product_qty']),
                SF('B_SentValue', FloatToStr(nHasDone)),
                SF('B_RestValue', FloatToStr(SO(ArrsJaSub.S[0]).D['remainder'])),
                SF('B_BStatus',   nO_Valid),
                SF('B_Date',  Now,sfDateTime)
                ], sTable_OrderBase, '', True);
            FListA.Add(nStr);

            nStr := SF('B_ID', OneJo.S['ordername']);
            nStr := MakeSQLByStr([
                SF('B_ProID',     OneJo.S['partner_name']),
                SF('B_ProName',   OneJo.S['partner_name']),
                SF('B_StockNo',   SO(ArrsJaSub.S[0]).S['productid']),
                SF('B_StockName', SO(ArrsJaSub.S[0]).S['product_name']),
                SF('B_Value',     FloatToStr(SO(ArrsJaSub.S[0]).D['product_qty'])),
                SF('B_SentValue', FloatToStr(nHasDone)),
                SF('B_RestValue', FloatToStr(SO(ArrsJaSub.S[0]).D['remainder'])),
                SF('B_BStatus',   nO_Valid),
                SF('B_Date',  Now,sfDateTime)
                ], sTable_OrderBase, nStr, False);
            FListC.Add(nStr);

            nStr := 'Select * from %s where B_ID = ''%s'' ';
            nStr := Format(nStr, [sTable_OrderBase, OneJo.S['ordername']]);
            FListD.Add(nStr);
            
//            if nO_Valid = 'Y' then
//            begin
//              with FListB do
//              begin
//                Values['Order']         := OneJo.S['ordername'];
//                Values['ProName']       := OneJo.S['partner_name'];
//                Values['ProID']         := OneJo.S['partner_name'];
//                ArrsJaSub               := OneJo.A['products'];
//                Values['StockName']     := SO(ArrsJaSub.S[0]).S['product_name'];
//                Values['StockID']       := SO(ArrsJaSub.S[0]).S['productid'];
//                Values['StockNo']       := SO(ArrsJaSub.S[0]).S['productid'];
//                try
//                  nHasDone := StrToFloatDef(SO(ArrsJaSub.S[0]).S['product_qty'],0)
//                              - StrToFloatDef(SO(ArrsJaSub.S[0]).S['remainder'],0);
//                  nHasDone := Float2PInt(nHasDone, cPrecision, False) / cPrecision;
//                  if nHasDone <= 0 then
//                    nHasDone := 0;
//                except
//                  nHasDone := 0;
//                end;
//                Values['PlanValue']     := SO(ArrsJaSub.S[0]).S['product_qty'];//������
//                Values['EntryValue']    := FloatToStr(nHasDone);//�ѽ�����
//                Values['Value']         := FloatToStr(StrToFloatDef(SO(ArrsJaSub.S[0]).S['remainder'], StrToFloat(SO(ArrsJaSub.S[0]).S['product_qty'])));//ʣ����
//                Values['Model']         := '';//�ͺ�
//                Values['KD']            := '';//���
//                FListA.Add(PackerEncodeStr(FListB.Text));
//              end;
//            end;

            FOut.FData := PackerEncodeStr(FListA.Text);
            Result := True;
          end;
        end;
      end                                                             
      else
      begin
        WriteLog('��ȡ�ɹ�����ʧ��');
        Result     := False;
        FOut.FData :='��ȡ�ɹ�����ʧ��';
        FOut.FBase.FResult := True;
      end;
    end;

    if (FListD.Count > 0) then
    try
      FDBConn.FConn.BeginTrans;
      //��������
      for nIdx:=0 to FListD.Count - 1 do
      begin
        with gDBConnManager.WorkerQuery(FDBConn,FListD[nIdx]) do
        begin
          if RecordCount>0 then
          begin
            gDBConnManager.WorkerExec(FDBConn,FListC[nIdx]);
          end else
          begin
            gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
          end;
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    ReStream.Free;
    nDataStream.Free;
    wParam.Free;
  end;
end;


initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerBusinessHHJY, sPlug_ModuleBus);
end.
