{*******************************************************************************
  ����: dmzn@163.com 2017-09-22
  ����: ģ��ҵ�����
*******************************************************************************}
unit UWorkerBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ULibFun, UFormCtrl, UBase64, ZnMD5, 
  USysLoger, USysDB, UMITConst,DateUtils, IdHTTP, uSuperObject;

type
  TBusWorkerQueryField = class(TBusinessWorkerBase)
  private
    FIn: TWorkerQueryFieldData;
    FOut: TWorkerQueryFieldData;
  public
    class function FunctionName: string; override;
    function GetFlagStr(const nFlag: Integer): string; override;
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
  end;

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

  TWorkerBusinessCommander = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    FListD,FListE,FListF: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetCardUsed(var nData: string): Boolean;
    //��ȡ��Ƭ����
    function Login(var nData: string):Boolean;
    function LogOut(var nData: string): Boolean;
    //��¼ע���������ƶ��ն�
    function GetServerNow(var nData: string): Boolean;
    //��ȡ������ʱ��
    function GetSerailID(var nData: string): Boolean;
    //��ȡ����
    function IsSystemExpired(var nData: string): Boolean;
    //ϵͳ�Ƿ��ѹ���
    function SaveTruck(var nData: string): Boolean;
    function UpdateTruck(var nData: string): Boolean;
    //���泵����Truck��
    function GetTruckPoundData(var nData: string): Boolean;
    function SaveTruckPoundData(var nData: string): Boolean;
    //��ȡ������������
    function GetStockBatcode(var nData: string): Boolean;
    //��ȡƷ�����κ�
    function IsTruckTimeOut(var nData: string): Boolean;
    //��֤�����Ƿ������ʱ
    function SyncHhSaleMateriel(var nData: string): Boolean;
    //ͬ���������ϵ�DL
    function SyncHhProvideMateriel(var nData: string): Boolean;
    //ͬ���ɹ����ϵ�DL
    function SyncHhCustomer(var nData: string): Boolean;
    //ͬ���ͻ���Ϣ��DL
    function SyncHhProvider(var nData: string): Boolean;
    //ͬ����Ӧ����Ϣ��DL
    function GetHhOrderPlan(var nData: string): Boolean;
    //��ȡԭ���Ͻ����ƻ�
    function SyncHhOrderPoundData(var nData: string): Boolean;
    //ͬ��ԭ���ϰ���
    function GetHhNeiDaoOrderPlan(var nData: string): Boolean;
    //��ȡ�ڵ�ԭ���Ͻ����ƻ�
    function SyncHhNeiDaoOrderPoundData(var nData: string): Boolean;
    //ͬ��ԭ�����ڵ�����
    function SyncHhOtherOrderPoundData(var nData: string): Boolean;
    //ͬ��ԭ������������
    function GetUserName(const nLoginName: string) : string;
    //��ȡ�û�����
    function GetMoney(const nPrice, nValue: string) : string;
    //������
    function GetID(const nKeyName: string) : string;
    //��ȡID
    function GetVersion : string;
    //��ȡ�û�����
    function GetHhSalePlan(var nData: string): Boolean;
    //ͬ�����۶�����DL
    function SyncHhSaleDetail(var nData: string): Boolean;
    //ͬ�����۷�����ϸ
    function GetHhSaleWTTruck(var nData: string): Boolean;
    //��ȡί�г���
    procedure SaveHyDanEvent(const nStockno,nEvent,
          nFrom,nSolution,nDepartment: string);
    //���ɻ��鵥�����¼�
    function VerifyTruckStatus(var nData: string): Boolean;
    //У�鳵��״̬
    function VerifyTruckLicense(var nData: string): Boolean;
    //����ʶ��
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

  TWorkerBusinessOrders = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton

    function SaveOrder(var nData: string):Boolean;
    function DeleteOrder(var nData: string): Boolean;
    function SaveOrderCard(var nData: string): Boolean;
    function GetPostOrderItems(var nData: string): Boolean;
    //��ȡ��λ�ɹ���
    function SavePostOrderItems(var nData: string): Boolean;
    //�����λ�ɹ���
    function GetCardUsed(const nCard: string;var nCardType: string): Boolean;
    //��ȡ��Ƭ����
    function LogoffOrderCard(var nData: string): Boolean;
    function getPrePInfo(const nTruck:string;var nPrePValue:Double;
                          var nPrePMan:string;var nPrePTime:TDateTime):Boolean;
    function GetLastPInfo(const nID:string;var nPValue: Double; var nPMan: string;
                          var nPTime: TDateTime):Boolean;
    function GetOrderInfo(const nOID: string;
                          var nBID,nModel,nShip,nYear,nKD: string): Boolean;
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

const HhOrderDefDepotID     = '100000404';
const HhOrderPoundAuditMenu = 'ԭȼ�������ϵ����';
const HhOrderNdPoundAuditMenu = 'ԭȼ���ϳ��ڵ��ϵ����';
const HhCompanyID     = '100000104';

implementation

uses UHardBusiness;

class function TBusWorkerQueryField.FunctionName: string;
begin
  Result := sBus_GetQueryField;
end;

function TBusWorkerQueryField.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_GetQueryField;
  end;
end;

function TBusWorkerQueryField.DoWork(var nData: string): Boolean;
begin
  FOut.FData := '*';
  FPacker.UnPackIn(nData, @FIn);

  case FIn.FType of
   cQF_Bill: 
    FOut.FData := '*';
  end;

  Result := True;
  FOut.FBase.FResult := True;
  nData := FPacker.PackOut(@FOut);
end;

//------------------------------------------------------------------------------
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
      nData := FPacker.PackOut(FDataOut);

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
class function TWorkerBusinessCommander.FunctionName: string;
begin
  Result := sBus_BusinessCommand;
end;

constructor TWorkerBusinessCommander.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListD := TStringList.Create;
  FListE := TStringList.Create;
  FListF := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessCommander.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  FreeAndNil(FListD);
  FreeAndNil(FListE);
  FreeAndNil(FListF);
  inherited;
end;

function TWorkerBusinessCommander.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessCommander.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TWorkerBusinessCommander.CallMe(const nCmd: Integer;
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

//Date: 2012-3-22
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessCommander.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;

  case FIn.FCommand of
   cBC_GetCardUsed         : Result := GetCardUsed(nData);
   cBC_ServerNow           : Result := GetServerNow(nData);
   cBC_GetSerialNO         : Result := GetSerailID(nData);
   cBC_IsSystemExpired     : Result := IsSystemExpired(nData);

   cBC_SaveTruckInfo       : Result := SaveTruck(nData);
   cBC_UpdateTruckInfo     : Result := UpdateTruck(nData);
   cBC_GetTruckPoundData   : Result := GetTruckPoundData(nData);
   cBC_SaveTruckPoundData  : Result := SaveTruckPoundData(nData);

   cBC_UserLogin           : Result := Login(nData);
   cBC_UserLogOut          : Result := LogOut(nData);
   cBC_GetStockBatcode     : Result := GetStockBatcode(nData);
   cBC_TruckTimeOut        : Result := IsTruckTimeOut(nData);
   cBC_VerifyTruckStatus   : Result := VerifyTruckStatus(nData);
   //ERP
   cBC_SyncHhSaleMateriel  : Result := SyncHhSaleMateriel(nData);
   cBC_SyncHhProvideMateriel : Result := SyncHhProvideMateriel(nData);
   cBC_SyncHhCustomer      : Result := SyncHhCustomer(nData);
   cBC_SyncHhProvider      : Result := SyncHhProvider(nData);
   cBC_GetHhOrderPlan      : Result := GetHhOrderPlan(nData);
   cBC_SyncHhOrderPoundData : Result := SyncHhOrderPoundData(nData);
   cBC_GetHhNeiDaoOrderPlan : Result := GetHhNeiDaoOrderPlan(nData);
   cBC_SyncHhNdOrderPoundData : Result := SyncHhNeiDaoOrderPoundData(nData);
   cBC_SyncHhOtOrderPoundData : Result := SyncHhOtherOrderPoundData(nData);

   cBC_GetHhSalePlan       : Result := GetHhSalePlan(nData);
   cBC_SyncHhSaleDetail    : Result := SyncHhSaleDetail(nData);
   cBC_SyncHhSaleWTTruck   : Result := GetHhSaleWTTruck(nData);

   cBC_VeryTruckLicense    : Result := VerifyTruckLicense(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Code: %d Invalid Command).';
      nData := Format(nData, [FIn.FCommand]);
    end;
  end;
end;

//Date: 2014-09-05
//Desc: ��ȡ��Ƭ���ͣ�����S;�ɹ�P;����O
function TWorkerBusinessCommander.GetCardUsed(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  nStr := 'Select C_Used From %s Where C_Card=''%s'' ' +
          'or C_Card3=''%s'' or C_Card2=''%s''';
  nStr := Format(nStr, [sTable_Card, FIn.FData, FIn.FData, FIn.FData]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then
    begin
      nData := '�ſ�[ %s ]��Ϣ������.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FOut.FData := Fields[0].AsString;
    Result := True;
  end;
end;

//Date: 2019-06-15
//Desc: ��ȡ����״̬
function TWorkerBusinessCommander.VerifyTruckStatus(var nData: string): Boolean;
var nStr: string;
    nHint: string;
    nEID:string;
begin
  Result := True;

  nStr := 'Select T_Valid,T_Truck, L_NextStatus From %s left join %s on T_Bill = L_ID Where T_Bill=''%s'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then
    begin
      nHint := '�Ŷ�˳���ѯ�������[ %s ]��Ϣ������,����[ %s ]ˢ��.';
      nHint := Format(nHint, [FIn.FData, FIn.FExtParam]);
      WriteLog(nHint);
      Exit;
    end;

    if FieldByName('T_Valid').AsString = sFlag_No then
    begin
      nHint := '�Ŷ�˳���ѯ�������[ %s ]����[ %s ]�ѳ���,����[ %s ]ˢ��.';
      nHint := Format(nHint, [FIn.FData, FieldByName('T_Truck').AsString,
                              FIn.FExtParam]);
      WriteLog(nHint);
      Exit;
    end;

    if (FieldByName('L_NextStatus').AsString = sFlag_TruckBFM) or
       (FieldByName('L_NextStatus').AsString = sFlag_TruckOut) then
    begin
      nHint := '�Ŷ�˳���ѯ�������[ %s ]����[ %s ]��ˢ��,����[ %s ]ˢ��.';
      nHint := Format(nHint, [FIn.FData, FieldByName('T_Truck').AsString,
                              FIn.FExtParam]);
      WriteLog(nHint);
      Exit;
    end;

    nData := '�Ŷ�˳���ѯ�������[ %s ]����[ %s ]δװ��,��[ %s ]�ȴ�.';
    nData := Format(nData, [FIn.FData, FieldByName('T_Truck').AsString,
                              FIn.FExtParam]);
    WriteLog(nData);
    try
      nEID := FIn.FExtParam + sFlag_ManualG;
      nStr := 'Delete From %s Where E_ID=''%s''';
      nStr := Format(nStr, [sTable_ManualEvent, nEID]);

      gDBConnManager.WorkerExec(FDBConn, nStr);

      nStr := MakeSQLByStr([
          SF('E_ID', nEID),
          SF('E_Key', FIn.FExtParam),
          SF('E_From', sFlag_DepJianZhuang),
          SF('E_Event', nData),
          SF('E_Solution', sFlag_Solution_OK),
          SF('E_Departmen', sFlag_DepJianZhuang),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    except
      on E: Exception do
      begin
        WriteLog(e.message);
      end;
    end;
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: �û���,����;�����û�����
//Desc: �û���¼
function TWorkerBusinessCommander.Login(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if FListA.Values['User'] = '' then Exit;
  //δ�����û���

  nStr := 'Select U_Password From %s Where U_Name=''%s''';
  nStr := Format(nStr, [sTable_User, FListA.Values['User']]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then Exit;

    nStr := Fields[0].AsString;
    if nStr <> FListA.Values['Password'] then Exit;
    Result := True;
  end;
end;

//Date: 2015/9/9
//Parm: �û���;��֤����
//Desc: �û�ע��
function TWorkerBusinessCommander.LogOut(var nData: string): Boolean;
begin
  Result := True;
end;

//Date: 2014-09-05
//Desc: ��ȡ��������ǰʱ��
function TWorkerBusinessCommander.GetServerNow(var nData: string): Boolean;
var nStr: string;
begin
  nStr := 'Select ' + sField_SQLServer_Now;
  //sql

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    FOut.FData := DateTime2Str(Fields[0].AsDateTime);
    Result := True;
  end;
end;

//Date: 2012-3-25
//Desc: �������������б��
function TWorkerBusinessCommander.GetSerailID(var nData: string): Boolean;
var nInt: Integer;
    nStr,nP,nB: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    Result := False;
    FListA.Text := FIn.FData;
    //param list

    nStr := 'Update %s Set B_Base=B_Base+1 ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, FListA.Values['Group'],
            FListA.Values['Object']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Select B_Prefix,B_IDLen,B_Base,B_Date,%s as B_Now From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now, sTable_SerialBase,
            FListA.Values['Group'], FListA.Values['Object']]);
    //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := 'û��[ %s.%s ]�ı�������.';
        nData := Format(nData, [FListA.Values['Group'], FListA.Values['Object']]);

        FDBConn.FConn.RollbackTrans;
        Exit;
      end;

      nP := FieldByName('B_Prefix').AsString;
      nB := FieldByName('B_Base').AsString;
      nInt := FieldByName('B_IDLen').AsInteger;

      if FIn.FExtParam = sFlag_Yes then //�����ڱ���
      begin
        nStr := Date2Str(FieldByName('B_Date').AsDateTime, False);
        //old date

        if (nStr <> Date2Str(FieldByName('B_Now').AsDateTime, False)) and
           (FieldByName('B_Now').AsDateTime > FieldByName('B_Date').AsDateTime) then
        begin
          nStr := 'Update %s Set B_Base=1,B_Date=%s ' +
                  'Where B_Group=''%s'' And B_Object=''%s''';
          nStr := Format(nStr, [sTable_SerialBase, sField_SQLServer_Now,
                  FListA.Values['Group'], FListA.Values['Object']]);
          gDBConnManager.WorkerExec(FDBConn, nStr);

          nB := '1';
          nStr := Date2Str(FieldByName('B_Now').AsDateTime, False);
          //now date
        end;

        System.Delete(nStr, 1, 2);
        //yymmdd
        nInt := nInt - Length(nP) - Length(nStr) - Length(nB);
        FOut.FData := nP + nStr + StringOfChar('0', nInt) + nB;
      end else
      begin
        nInt := nInt - Length(nP) - Length(nB);
        nStr := StringOfChar('0', nInt);
        FOut.FData := nP + nStr + nB;
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-05
//Desc: ��֤ϵͳ�Ƿ��ѹ���
function TWorkerBusinessCommander.IsSystemExpired(var nData: string): Boolean;
var nStr: string;
    nDate: TDate;
    nInt: Integer;
begin
  nDate := Date();
  //server now

  nStr := 'Select D_Value,D_ParamB From %s ' +
          'Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ValidDate]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := 'dmzn_stock_' + Fields[0].AsString;
    nStr := MD5Print(MD5String(nStr));

    if nStr = Fields[1].AsString then
      nDate := Str2Date(Fields[0].AsString);
    //xxxxx
  end;

  nInt := Trunc(nDate - Date());
  Result := nInt > 0;

  if nInt <= 0 then
  begin
    nStr := 'ϵͳ�ѹ��� %d ��,����ϵ����Ա!!';
    nData := Format(nStr, [-nInt]);
    Exit;
  end;

  FOut.FData := IntToStr(nInt);
  //last days

  if nInt <= 7 then
  begin
    nStr := Format('ϵͳ�� %d ������', [nInt]);
    FOut.FBase.FErrDesc := nStr;
    FOut.FBase.FErrCode := sFlag_ForceHint;
  end;
end;

//Date: 2014-10-02
//Parm: ���ƺ�[FIn.FData];
//Desc: ���泵����sTable_Truck��
function TWorkerBusinessCommander.SaveTruck(var nData: string): Boolean;
var nStr: string;
begin
  Result := True;
  FIn.FData := UpperCase(FIn.FData);
  
  nStr := 'Select T_Phone From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, FIn.FData]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nStr := MakeSQLByStr([
              SF('T_Truck', FIn.FData),
              SF('T_PY', GetPinYinOfStr(FIn.FData)),
              SF('T_Phone', FIn.FExtParam),
              SF('T_Valid', sFlag_Yes)
              ], sTable_Truck, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      First;
      if (FIn.FExtParam <> '') and (FIn.FExtParam <> Fields[0].AsString) then
      begin
        nStr := 'Update %s Set T_Phone=''%s'' Where T_Truck=''%s''';
        nStr := Format(nStr, [sTable_Truck, FIn.FExtParam, FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
    end;
  end;
end;

//Date: 2016-02-16
//Parm: ���ƺ�(Truck); ���ֶ���(Field);����ֵ(Value)
//Desc: ���³�����Ϣ��sTable_Truck��
function TWorkerBusinessCommander.UpdateTruck(var nData: string): Boolean;
var nStr: string;
    nValInt: Integer;
    nValFloat: Double;
begin
  Result := True;
  FListA.Text := FIn.FData;

  if FListA.Values['Field'] = 'T_PValue' then
  begin
    nStr := 'Select T_PValue, T_PTime From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, FListA.Values['Truck']]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nValInt := Fields[1].AsInteger;
      nValFloat := Fields[0].AsFloat;
    end else Exit;

    nValFloat := nValFloat * nValInt + StrToFloatDef(FListA.Values['Value'], 0);
    nValFloat := nValFloat / (nValInt + 1);
    nValFloat := Float2Float(nValFloat, cPrecision);

    nStr := 'Update %s Set T_PValue=%.2f, T_PTime=T_PTime+1 Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nValFloat, FListA.Values['Truck']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2014-09-25
//Parm: ���ƺ�[FIn.FData]
//Desc: ��ȡָ�����ƺŵĳ�Ƥ����(ʹ�����ģʽ,δ����)
function TWorkerBusinessCommander.GetTruckPoundData(var nData: string): Boolean;
var nStr: string;
    nPound: TLadingBillItems;
begin
  SetLength(nPound, 1);
  FillChar(nPound[0], SizeOf(TLadingBillItem), #0);

  nStr := 'Select * From %s Where P_Truck=''%s'' And ' +
          'P_MValue Is Null And P_PModel=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, FIn.FData, sFlag_PoundPD]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr),nPound[0] do
  begin
    if RecordCount > 0 then
    begin
      FCusID      := FieldByName('P_CusID').AsString;
      FCusName    := FieldByName('P_CusName').AsString;
      FTruck      := FieldByName('P_Truck').AsString;

      FType       := FieldByName('P_MType').AsString;
      FStockNo    := FieldByName('P_MID').AsString;
      FStockName  := FieldByName('P_MName').AsString;

      with FPData do
      begin
        FStation  := FieldByName('P_PStation').AsString;
        FValue    := FieldByName('P_PValue').AsFloat;
        FDate     := FieldByName('P_PDate').AsDateTime;
        FOperator := FieldByName('P_PMan').AsString;
      end;  

      FFactory    := FieldByName('P_FactID').AsString;
      FPModel     := FieldByName('P_PModel').AsString;
      FPType      := FieldByName('P_Type').AsString;
      FPoundID    := FieldByName('P_ID').AsString;

      FStatus     := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;
      FSelected   := True;
    end else
    begin
      FTruck      := FIn.FData;
      FPModel     := sFlag_PoundPD;

      FStatus     := '';
      FNextStatus := sFlag_TruckBFP;
      FSelected   := True;
    end;
  end;

  FOut.FData := CombineBillItmes(nPound);
  Result := True;
end;

//Date: 2014-09-25
//Parm: ��������[FIn.FData]
//Desc: ��ȡָ�����ƺŵĳ�Ƥ����(ʹ�����ģʽ,δ����)
function TWorkerBusinessCommander.SaveTruckPoundData(var nData: string): Boolean;
var nStr,nSQL: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  AnalyseBillItems(FIn.FData, nPound);
  //��������

  with nPound[0] do
  begin
    if FPoundID = '' then
    begin
      TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, FTruck, '', @nOut);
      //���泵�ƺ�

      FListC.Clear;
      FListC.Values['Group'] := sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_PoundID;

      if not CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FPoundID := nOut.FData;
      //new id

      if FPModel = sFlag_PoundLS then
           nStr := sFlag_Other
      else nStr := sFlag_Provide;

      nSQL := MakeSQLByStr([
              SF('P_ID', FPoundID),
              SF('P_Type', nStr),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', sFlag_San),
              SF('P_PValue', FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', FFactory),
              SF('P_PStation', FPData.FStation),
              SF('P_Direction', '����'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end else
    begin
      nStr := SF('P_ID', FPoundID);
      //where

      if FNextStatus = sFlag_TruckBFP then
      begin
        nSQL := MakeSQLByStr([
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_PStation', FPData.FStation),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', DateTime2Str(FMData.FDate)),
                SF('P_MMan', FMData.FOperator),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //����ʱ,����Ƥ�ش�,����Ƥë������
      end else
      begin
        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //xxxxx
      end;

      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    FOut.FData := FPoundID;
    Result := True;
  end;
end;

//Date: 2016-02-24
//Parm: ��������[FIn.FData];Ԥ�ۼ���[FIn.ExtParam];
//Desc: ����������ָ��Ʒ�ֵ����α��
function TWorkerBusinessCommander.GetStockBatcode(var nData: string): Boolean;
var nStr,nP,nStockNo,nCusName: string;
    nNew,nHasFH: Boolean;
    nInt,nInc,nRID: Integer;
    nVal,nPer: Double;
    nList: TStrings;
    nDs: TDataSet;

    //���������κ�
    function NewBatCode(const nBID: Integer): string;
    var nOld,nID,nName: string;
    begin
      nStr := 'Select * From %s Where R_ID=%d';
      nStr := Format(nStr, [sTable_StockBatcode, nBID]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        nP := FieldByName('B_Prefix').AsString;
        nStr := FieldByName('B_UseYear').AsString;
        nOld := FieldByName('B_Batcode').AsString;

        nID := FieldByName('B_Stock').AsString;
        nName := FieldByName('B_Name').AsString;
        nVal := FieldByName('B_Value').AsFloat;

        if nStr = sFlag_Yes then
        begin
          nStr := Copy(Date2Str(Now()), 3, 2);
          nP := nP + nStr;
          //ǰ׺����λ���
        end;

        nStr := FieldByName('B_Base').AsString;
        nInt := FieldByName('B_Length').AsInteger;
        nInt := nInt - Length(nP + nStr);

        if nInt > 0 then
             Result := nP + StringOfChar('0', nInt) + nStr
        else Result := nP + nStr;

        nStr := '����[ %s.%s ]������ʹ�����κ�[ %s ],��֪ͨ������ȷ���Ѳ���.';
        nStr := Format(nStr, [FieldByName('B_Stock').AsString,
                              FieldByName('B_Name').AsString, Result]);
        //xxxxx

        FOut.FBase.FErrCode := sFlag_ForceHint;
        FOut.FBase.FErrDesc := nStr;
      end;

      FDBConn.FConn.BeginTrans;
      try
        nStr := MakeSQLByStr([SF('B_Batcode', Result),
                SF('B_FirstDate', sField_SQLServer_Now, sfVal),
                SF('B_HasUse', 0, sfVal),
                SF('B_LastDate', sField_SQLServer_Now, sfVal)
                ], sTable_StockBatcode, SF('R_ID', nBID, sfVal), False);
        gDBConnManager.WorkerExec(FDBConn, nStr);

        FOut.FExtParam := DateTime2Str(Now);
        //���κ�����ʱ��

        nStr := MakeSQLByStr([
                SF('R_LastDate', sField_SQLServer_Now, sfVal)
                ], sTable_BatRecord, SF('R_Batcode', nOld), False);
        gDBConnManager.WorkerExec(FDBConn, nStr); //���ɱ��

        nStr := MakeSQLByStr([SF('R_Batcode', Result),
                SF('R_Stock', nID),
                SF('R_Name', nName),
                SF('R_Value', nVal, sfVal),
                SF('R_Used', 0, sfVal),
                SF('R_FirstDate', sField_SQLServer_Now, sfVal)
                ], sTable_BatRecord, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr); //����±��

        FDBConn.FConn.CommitTrans;
      except
        on nErr: Exception do
        begin
          FDBConn.FConn.RollbackTrans;
          //rollback

          nData := '��������[ %s ]���κ�ʧ��,����: %s';
          nData := Format(nData, [nName, nErr.Message]);
          raise Exception.Create(nData);
        end;
      end;
    end;
begin
  Result := True;
  FOut.FData := '';

  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_BatchAuto]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := Fields[0].AsString;
    if nStr <> sFlag_Yes then Exit;
  end  else Exit;
  //Ĭ�ϲ�ʹ�����κ�

  Result := False; //Init

  nList := TStringList.Create;
  try
    nList.Text := FIn.FData;
    nStockNo := nList.Values['StockNo'];
    nCusName := nList.Values['CusName'];
  finally
    nList.Free;
  end;

  nStr := 'Select R_ID From %s Where L_StockNo=''%s''';
  nStr := Format(nStr, [sTable_Bill, nStockNo]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    nHasFH := RecordCount > 0;
  end;
  //�������Ƿ��з�����¼

  nStr := 'Select *,%s as ServerNow From %s Where B_Stock=''%s'' ' +
          'And B_Customer like ''%%%s%%''';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_StockBatcode,
                        nStockNo, nCusName]);

  nDs := gDBConnManager.WorkerQuery(FDBConn, nStr);//���Ȳ�ѯ�ͻ�ר�����κ�

  if nDs.RecordCount <= 0 then
  begin
    nStr := 'Select *,%s as ServerNow From %s Where B_Stock=''%s'' ' +
            'And (B_Customer = '''' or B_Customer is null)';
    nStr := Format(nStr, [sField_SQLServer_Now, sTable_StockBatcode, nStockNo]);
    nDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
  end;

  with nDs do
  begin
    if RecordCount < 1 then
    begin
      nData := '����[ %s ]δ�������κŹ���.';
      nData := Format(nData, [FIn.FData]);
      SaveHyDanEvent(FIn.FData,nData,sFlag_DepDaTing,sFlag_Solution_OK,sFlag_DepDaTing);
      Exit;
    end;

    FOut.FData := FieldByName('B_Batcode').AsString;
    FOut.FExtParam := DateTime2Str(FieldByName('B_FirstDate').AsDateTime);
    nInc := FieldByName('B_Incement').AsInteger;
    nRID := FieldByName('R_ID').AsInteger;

    nNew := False;
    if FieldByName('B_UseDate').AsString = sFlag_Yes then
    begin
      nP := FieldByName('B_Prefix').AsString;
      nStr := Date2Str(FieldByName('ServerNow').AsDateTime, False);

      nInt := FieldByName('B_Length').AsInteger;
      nInt := Length(nP + nStr) - nInt;

      if nInt > 0 then
      begin
        System.Delete(nStr, 1, nInt);
        FOut.FData := nP + nStr;
      end else
      begin
        nStr := StringOfChar('0', -nInt) + nStr;
        FOut.FData := nP + nStr;
      end;

      nNew := True;
    end;

    if (not nNew) and (FieldByName('B_AutoNew').AsString = sFlag_Yes) then      //Ԫ������
    begin
      nStr := Date2Str(FieldByName('ServerNow').AsDateTime);
      nStr := Copy(nStr, 1, 4);
      nP := Date2Str(FieldByName('B_LastDate').AsDateTime);
      nP := Copy(nP, 1, 4);

      if nStr <> nP then
      begin
        nStr := 'Update %s Set B_Base=1 Where R_ID=%d';
        nStr := Format(nStr, [sTable_StockBatcode, nRID]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        FOut.FData := NewBatCode(nRID);
        nNew := True;
      end;
    end;

    if not nNew then //��ų���
    if nHasFH then//���ڷ�����¼
    begin
      nStr := Date2Str(FieldByName('ServerNow').AsDateTime);
      nP := Date2Str(FieldByName('B_FirstDate').AsDateTime);

      if (Str2Date(nP) > Str2Date('2000-01-01')) and
         (Str2Date(nStr) - Str2Date(nP) > FieldByName('B_Interval').AsInteger) then
      begin
        nStr := 'Update %s Set B_Base=B_Base+%d Where R_ID=%d';
        nStr := Format(nStr, [sTable_StockBatcode, nInc, nRID]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        FOut.FData := NewBatCode(nRID);
        nNew := True;
      end;
    end;

    if not nNew then //��ų���
    begin
      nVal := FieldByName('B_HasUse').AsFloat + StrToFloat(FIn.FExtParam);
      //��ʹ��+Ԥʹ��
      nPer := FieldByName('B_Value').AsFloat * FieldByName('B_High').AsFloat / 100;
      //��������

      if nVal >= nPer then //����
      begin
        nStr := 'Update %s Set B_Base=B_Base+%d Where R_ID=%d';
        nStr := Format(nStr, [sTable_StockBatcode, nInc, nRID]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        FOut.FData := NewBatCode(nRID);
      end else
      begin
        nPer := FieldByName('B_Value').AsFloat * FieldByName('B_Low').AsFloat / 100;
        //����

        if nVal >= nPer then //��������
        begin
          nStr := '����[ %s.%s ]�����������κ�,��֪ͨ������׼��ȡ��.';
          nStr := Format(nStr, [FieldByName('B_Stock').AsString,
                                FieldByName('B_Name').AsString]);
          //xxxxx

          FOut.FBase.FErrCode := sFlag_ForceHint;
          FOut.FBase.FErrDesc := nStr;
        end;
      end;
    end;
  end;

  if FOut.FData = '' then
    FOut.FData := NewBatCode(nRID);
  //xxxxx
  if FOut.FBase.FErrCode = sFlag_ForceHint then
  begin
    SaveHyDanEvent(FIn.FData,FOut.FBase.FErrDesc,
                   sFlag_DepDaTing,sFlag_Solution_OK,sFlag_DepDaTing);
  end;

  Result := True;
  FOut.FBase.FResult := True;
end;

//Date: 2018-04-03
//Desc: ��֤�����Ƿ������ʱ
function TWorkerBusinessCommander.IsTruckTimeOut(var nData: string): Boolean;
var nStr: string;
    nDate: TDate;
    nInt: Integer;
    nTruck,nEvent,nMDate: string;
    nUpdate: Boolean;
begin
  Result := False;

  if Trim(FIn.FData) = '' then
    Exit;

  nStr := 'Select D_Value From %s ' +
          'Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_TimeOutValue]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then//������ʱ
    begin
      Exit;
    end;

    nInt := Fields[0].AsInteger;
    //xxxxx
  end;

  nStr := 'Select L_MDate,L_Truck From %s ' +
          'Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
    begin
      Exit;
    end;

    nDate := Fields[0].AsDateTime;
    nMDate := Fields[0].AsString;
    nTruck := Fields[1].AsString;
    //xxxxx
  end;

  nDate := IncMinute(nDate,nInt);
  Result := nDate < Now;

  if Result then
  begin
    nStr := 'Select * From %s Where E_ID=''%s''';
    nStr := Format(nStr, [sTable_ManualEvent, FIn.FData+sFlag_ManualF]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount > 0 then
      begin
        nUpdate := True;
      end
      else
      begin
        nUpdate := False;
      end;
    end;

    nEvent := '����[ %s ]ë��ʱ�������ʱ��������,��������:' + #13#10 +
              '��.ë��ʱ��: [ %s ]' + #13#10 +
              '��.����ʱ��: [ %s ]' + #13#10 +
              '��֪ͨ˾�����¹���.';
    nEvent := Format(nEvent, [nTruck,nMDate,
                     FormatDateTime('YYYY-MM-DD HH:MM:SS',Now)]);

    nStr := SF('E_ID', FIn.FData+sFlag_ManualF);
    nStr := MakeSQLByStr([
            SF('E_ID', FIn.FData+sFlag_ManualF),
            SF('E_Key', nTruck),
            SF('E_From', sFlag_DepBangFang),
            SF('E_Result', 'Null', sfVal),

            SF('E_Event', nEvent),
            SF('E_Solution', sFlag_Solution_OK),
            SF('E_Departmen', sFlag_DepDaTing),
            SF('E_Date', sField_SQLServer_Now, sfVal)
            ], sTable_ManualEvent, nStr, (not nUpdate));
    //xxxxx
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2015-8-5
//Desc: ����ɹ���
function TWorkerBusinessOrders.SaveOrder(var nData: string): Boolean;
var nStr,nPost: string;
    nIdx: Integer;
    nVal,nOppositeValue: Double;
    nOut,nOutTemp: TWorkerBusinessCommand;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  nVal := StrToFloat(FListA.Values['Value']);
  nOppositeValue := StrToFloat(FListA.Values['OppositeValue']);
  //unpack Order

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    FOut.FData := '';
    //bill list

    FListC.Values['Group'] :=sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_Order;
    //to get serial no

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := FOut.FData + nOut.FData + ',';
    //combine Order

    nStr := MakeSQLByStr([SF('O_ID', nOut.FData),

            SF('O_CType', FListA.Values['CardType']),
            SF('O_Project', FListA.Values['Project']),
            SF('O_Area', FListA.Values['Area']),

            SF('O_BID', FListA.Values['SQID']),
            SF('O_Value', nVal,sfVal),
            SF('O_OppositeValue', nOppositeValue,sfVal),

            SF('O_ProID', FListA.Values['ProviderID']),
            SF('O_ProName', FListA.Values['ProviderName']),
            SF('O_ProPY', GetPinYinOfStr(FListA.Values['ProviderName'])),

            SF('O_SaleID', FListA.Values['SaleID']),
            SF('O_SaleMan', FListA.Values['SaleMan']),
            SF('O_SalePY', GetPinYinOfStr(FListA.Values['SaleMan'])),

            SF('O_Type', sFlag_San),
            SF('O_StockNo', FListA.Values['StockNO']),
            SF('O_StockName', FListA.Values['StockName']),
            SF('O_YSTDNo', FListA.Values['YSTDNO']),
            SF('O_Truck', FListA.Values['Truck']),
            SF('O_Man', FIn.FBase.FFrom.FUser),
            SF('O_Date', sField_SQLServer_Now, sfVal),
            SF('O_BRecID', FListA.Values['RecID']),
            SF('O_IfNeiDao', FListA.Values['NeiDao']),
            SF('O_Ship', FListA.Values['ShipName']),
            SF('O_Model', FListA.Values['Model']),
            SF('O_KD', FListA.Values['KD']),
            SF('O_Year', FListA.Values['Year']),
            SF('O_Memo', FListA.Values['Memo']),
            SF('O_PrintBD', FListA.Values['PrintBD']),
            {$IFDEF UseWXERP}
            SF('O_WebOrderID', FListA.Values['WebOrderID']),
            SF('O_RestValue', StrToFloatDef(FListA.Values['RestValue'],0),sfVal),
            {$ENDIF}
            SF('O_expiretime', FListA.Values['expiretime'],sfDateTime)
            ], sTable_Order, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    if FListA.Values['CardType'] = sFlag_OrderCardL then
    begin
      nStr := 'Update %s Set B_FreezeValue=B_FreezeValue+%.2f ' +
              'Where B_ID = ''%s'' and B_Value>0';
      nStr := Format(nStr, [sTable_OrderBase, nVal,FListA.Values['SQID']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    nIdx := Length(FOut.FData);
    if Copy(FOut.FData, nIdx, 1) = ',' then
      System.Delete(FOut.FData, nIdx, 1);
    //xxxxx

    FDBConn.FConn.CommitTrans;

    TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, FListA.Values['Truck'], '', @nOutTemp);
    //���泵�ƺ�

    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
  nStr := 'Select D_Value From %s ' +
          'Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_OrderCardID]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nPost := Fields[0].AsString;
  end;

  if nPost <> '' then
  begin
    nStr := 'Select D_Value From %s ' +
            'Where D_Name=''%s'' and D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_PlayVoiceStock, FListA.Values['StockNo']]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      if Fields[0].AsString = sFlag_Yes then
      begin
        nStr := 'ԭ����' + FListA.Values['StockName'] + '��Ӧ��' +
                FListA.Values['ProviderName'] + '�ѿ���,�뻯����ע��ȡ��';
        PlayNetVoice(nStr,nPost);
      end;
    end;
  end;
end;

//Date: 2015-8-5
//Desc: ����ɹ���
function TWorkerBusinessOrders.DeleteOrder(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
begin
  Result := False;
  //init

  nStr := 'Select Count(*) From %s Where ((D_Status<>''%s'') and (D_Status<>''%s'')) and D_OID=''%s''';
  nStr := Format(nStr, [sTable_OrderDtl, sFlag_TruckNone, sFlag_TruckIn, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if Fields[0].AsInteger > 0 then
    begin
      nData := '�ɹ���[ %s ]��ʹ�ã���ֹɾ����';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_Order]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('O_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //�����ֶ�,������ɾ��

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $OB($FL,O_DelMan,O_DelDate) ' +
            'Select $FL,''$User'',$Now From $OO Where O_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$OB', sTable_OrderBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_Order), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where O_ID=''%s''';
    nStr := Format(nStr, [sTable_Order, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

{ TWorkerBusinessOrders }
//Date: 2015-8-5
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessOrders.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;
  case FIn.FCommand of
   cBC_SaveOrder            : Result := SaveOrder(nData);
   cBC_DeleteOrder          : Result := DeleteOrder(nData);
//   cBC_SaveOrderBase        : Result := SaveOrderBase(nData);
//   cBC_DeleteOrderBase      : Result := DeleteOrderBase(nData);
   cBC_SaveOrderCard        : Result := SaveOrderCard(nData);
   cBC_LogoffOrderCard      : Result := LogoffOrderCard(nData);
//   cBC_ModifyBillTruck      : Result := ChangeOrderTruck(nData);
   cBC_GetPostOrders        : Result := GetPostOrderItems(nData);
   cBC_SavePostOrders       : Result := SavePostOrderItems(nData);
//   cBC_GetGYOrderValue      : Result := GetGYOrderValue(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;  
end;

procedure TWorkerBusinessOrders.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

class function TWorkerBusinessOrders.CallMe(const nCmd: Integer;
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

constructor TWorkerBusinessOrders.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessOrders.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

class function TWorkerBusinessOrders.FunctionName: string;
begin
  Result := sBus_BusinessPurchase;
end;

function TWorkerBusinessOrders.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

//Date: 2014-09-17
//Parm: �ɹ�����[FIn.FData];�ſ���[FIn.FExtParam]
//Desc: Ϊ�ɹ����󶨴ſ�
function TWorkerBusinessOrders.SaveOrderCard(var nData: string): Boolean;
var nStr,nSQL,nTruck: string;
begin
  Result := False;
  nTruck := '';

  FListB.Text := FIn.FExtParam;
  //�ſ��б�
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //�ɹ����б�

  nSQL := 'Select O_ID,O_Card,O_Truck From %s Where O_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Order, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('�ɹ�����[ %s ]�Ѷ�ʧ.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      nStr := FieldByName('O_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '�ɹ���[ %s ]�ĳ��ƺŲ�һ��,���ܲ���.' + #13#10#13#10 +
                 '*.��������: %s' + #13#10 +
                 '*.��������: %s' + #13#10#13#10 +
                 '��ͬ�ƺŲ��ܲ���,���޸ĳ��ƺ�,���ߵ����쿨.';
        nData := Format(nData, [FieldByName('O_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('O_Card').AsString;
      //����ʹ�õĴſ�
        
      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nSQL := 'Select O_ID,O_Truck From %s Where O_Card In (''%s'')';
  nSQL := Format(nSQL, [sTable_Order, FIn.FExtParam]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    nData := '����[ %s ]����ʹ�øÿ�,�޷�����.';
    nData := Format(nData, [FieldByName('O_Truck').AsString]);
    Exit;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
      //���¼����б�

      nSQL := 'Update %s Set O_Card=''%s'' Where O_ID In (%s)';
      nSQL := Format(nSQL, [sTable_Order, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);

      nSQL := 'Update %s Set D_Card=''%s'' Where D_OID In(%s) and D_OutFact Is NULL';
      nSQL := Format(nSQL, [sTable_OrderDtl, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Provide),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
      nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Provide),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nStr, False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: �ſ���[FIn.FData];��λ[FIn.FExtParam]
//Desc: ��ȡ�ض���λ����Ҫ�Ľ������б�
function TWorkerBusinessOrders.GetPostOrderItems(
  var nData: string): Boolean;
var nStr: string;
    nIdx, nPoundIdx: Integer;
    nIsOrder: Boolean;
    nBills: TLadingBillItems;
    nCardType:string;
    nCType:string;
    nexpiretime:TDateTime;
    nProNameList, nMNameList: TStrings;
begin
  Result := False;
  nIsOrder := False;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_Order]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nIsOrder := (Pos(Fields[0].AsString, FIn.FData) = 1) and
               (Length(FIn.FData) = Fields[1].AsInteger);
    //ǰ׺�ͳ��ȶ�����ɹ����������,����Ϊ�ɹ�����
  end;

  if not nIsOrder then
  begin
    nStr := 'Select C_Status,C_Freeze,C_Used From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FData]);
    //card status

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('�ſ�[ %s ]��Ϣ�Ѷ�ʧ.', [FIn.FData]);
        WriteLog(nData);
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

      nCardType := FieldByName('C_Used').AsString;
    end;
  end;

	if nCardType = sFlag_Provide then
	begin
	  nStr := 'Select O_ID,O_Card,O_ProID,O_ProName,O_Type,O_StockNo,O_PrintBD,' +
	          'O_StockName,O_Truck,O_Value,O_BRecID,O_IfNeiDao,o_ystdno,O_expiretime,o_ctype ' +
	          'From $OO oo ';
	  //xxxxx

	  if nIsOrder then
	       nStr := nStr + 'Where O_ID=''$CD'''
	  else nStr := nStr + 'Where O_Card=''$CD''';

	  nStr := MacroValue(nStr, [MI('$OO', sTable_Order),MI('$CD', FIn.FData)]);
	  //xxxxx

	  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
	  begin
      if RecordCount > 0 then
      begin
        nCType := FieldByName('o_ctype').AsString;
        nexpiretime := FieldByName('O_expiretime').AsDateTime;
        if (nCType=sFlag_OrderCardG) and (nexpiretime<Now) then
        begin
          nData := '�ſ���[ %s ]�ѹ���';
          nData := Format(nData, [FIn.FData]);
          WriteLog(nData);
          Exit;
        end;
      end;
	    if RecordCount < 1 then
	    begin
	      if nIsOrder then
	           nData := '�ɹ���[ %s ]����Ч.'
	      else nData := '�ſ���[ %s ]�޶���';

	      nData := Format(nData, [FIn.FData]);
	      Exit;
	    end else
	    with FListA do
	    begin
	      Clear;

	      Values['O_ID']         := FieldByName('O_ID').AsString;
	      Values['O_ProID']      := FieldByName('O_ProID').AsString;
	      Values['O_ProName']    := FieldByName('O_ProName').AsString;
	      Values['O_Truck']      := FieldByName('O_Truck').AsString;

	      Values['O_Type']       := FieldByName('O_Type').AsString;
	      Values['O_StockNo']    := FieldByName('O_StockNo').AsString;
	      Values['O_StockName']  := FieldByName('O_StockName').AsString;

	      Values['O_Card']       := FieldByName('O_Card').AsString;
	      Values['O_Value']      := FloatToStr(FieldByName('O_Value').AsFloat);
	      Values['O_BRecID']     := FieldByName('O_BRecID').AsString;

	      Values['NeiDao']       := FieldByName('O_IfNeiDao').AsString;
        Values['expiretime']   := FieldByName('o_expiretime').asstring;
        Values['PrintBD']      := FieldByName('O_PrintBD').AsString;
        Values['ctype']        := nCType;
	    end;
	  end;

	  nStr := 'Select top 1 D_ID,D_OID,D_PID,D_YLine,D_Status,D_NextStatus,' +
	          'D_KZValue,D_Memo,D_YSResult,' +
	          'P_PStation,P_PValue,P_PDate,P_PMan,' +
	          'P_MStation,P_MValue,P_MDate,P_MMan ' +
	          'From $OD od Left join $PD pd on pd.P_Order=od.D_ID ' +
	          'Where D_OutFact Is Null And D_OID=''$OID'' order by pd.R_ID desc';
	  //xxxxx

	  nStr := MacroValue(nStr, [MI('$OD', sTable_OrderDtl),
	                            MI('$PD', sTable_PoundLog),
	                            MI('$OID', FListA.Values['O_ID'])]);
	  //xxxxx

	  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
	  begin
	    if RecordCount<1 then
	    begin
	      SetLength(nBills, 1);

	      with nBills[0], FListA do
	      begin
	        FZhiKa      := Values['O_ID'];
	        FCusID      := Values['O_ProID'];
	        FCusName    := Values['O_ProName'];
	        FTruck      := Values['O_Truck'];

	        FType       := Values['O_Type'];
	        FStockNo    := Values['O_StockNo'];
	        FStockName  := Values['O_StockName'];
	        FValue      := StrToFloat(Values['O_Value']);

	        FCard       := Values['O_Card'];
	        FStatus     := sFlag_TruckNone;
	        FNextStatus := sFlag_TruckNone;
	        FNeiDao     := Values['NeiDao'];
          Fexpiretime := Values['expiretime'];
          FCtype  := nCType;
          FPoundIdx   := 0;
          FPrintBD    := Values['PrintBD'] = sFlag_Yes;
	        FSelected := True;
	      end;
	    end else
	    begin
	      SetLength(nBills, RecordCount);

	      nIdx := 0;

	      First;
	      while not Eof do
	      with nBills[nIdx], FListA do
	      begin
	        FID         := FieldByName('D_ID').AsString;
	        FZhiKa      := FieldByName('D_OID').AsString;
	        FPoundID    := FieldByName('D_PID').AsString;

	        FCusID      := Values['O_ProID'];
	        FCusName    := Values['O_ProName'];
	        FTruck      := Values['O_Truck'];

	        FType       := Values['O_Type'];
	        FStockNo    := Values['O_StockNo'];
	        FStockName  := Values['O_StockName'];
	        FValue      := StrToFloat(Values['O_Value']);

	        FCard       := Values['O_Card'];
	        FStatus     := FieldByName('D_Status').AsString;
	        FNextStatus := FieldByName('D_NextStatus').AsString;

	        if (FStatus = '') or (FStatus = sFlag_BillNew) then
	        begin
	          FStatus     := sFlag_TruckNone;
	          FNextStatus := sFlag_TruckNone;
	        end;

	        with FPData do
	        begin
	          FStation  := FieldByName('P_PStation').AsString;
	          FValue    := FieldByName('P_PValue').AsFloat;
	          FDate     := FieldByName('P_PDate').AsDateTime;
	          FOperator := FieldByName('P_PMan').AsString;
	        end;

	        with FMData do
	        begin
	          FStation  := FieldByName('P_MStation').AsString;
	          FValue    := FieldByName('P_MValue').AsFloat;
	          FDate     := FieldByName('P_MDate').AsDateTime;
	          FOperator := FieldByName('P_MMan').AsString;
	        end;

	        FKZValue  := FieldByName('D_KZValue').AsFloat;
	        FMemo     := FieldByName('D_Memo').AsString;
	        FYSValid  := FieldByName('D_YSResult').AsString;
	        FNeiDao     := Values['NeiDao'];
          Fexpiretime := Values['expiretime'];
          FCtype  := nCType;
          FPoundIdx  := 0;
          FPrintBD    := Values['PrintBD'] = sFlag_Yes;
	        FSelected := True;

	        Inc(nIdx);
	        Next;
	      end;
	    end;
	  end;
	end
	else if nCardType = sFlag_Mul then
	begin
	  nStr := 'Select * From $CO ';
	  //xxxxx

	  if nIsOrder then
	       nStr := nStr + 'Where R_ID=''$CD'''
	  else nStr := nStr + 'Where O_Card=''$CD''';

	  nStr := MacroValue(nStr, [MI('$CO', sTable_CardOther),MI('$CD', FIn.FData)]);
	  //xxxxx

	  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
	  begin
	    if RecordCount < 1 then
	    begin
	      if nIsOrder then
	           nData := '�ɹ���[ %s ]����Ч.'
	      else nData := '�ſ���[ %s ]�޶���';

	      nData := Format(nData, [FIn.FData]);
	      Exit;
	    end else
	    with FListA do
	    begin
	      Clear;

	      Values['O_ID']         := FieldByName('R_ID').AsString;
	      Values['O_ProName']    := FieldByName('O_CusNameUse').AsString;
	      Values['O_Truck']      := FieldByName('O_Truck').AsString;

	      Values['O_Type']       := FieldByName('O_MType').AsString;
	      Values['O_StockName']  := FieldByName('O_MNameUse').AsString;

	      Values['O_Card']       := FieldByName('O_Card').AsString;
        Values['O_PoundIdx']   := FieldByName('O_PoundIdx').AsString;
        Values['O_Status']     := FieldByName('O_Status').AsString;
        Values['O_NextStatus'] := FieldByName('O_NextStatus').AsString;
        Values['O_KeepCard']   := FieldByName('O_KeepCard').AsString;
	    end;
	  end;

    if FListA.Values['O_KeepCard'] = sFlag_Yes then
    begin
      nStr := 'Select top 1 * From $PD Where ' +
              '(P_Order =''$OID'' or P_OrderBak =''$OID'') And P_PoundIdx=''$PI'''
              + ' Order by R_ID Desc';
      //xxxxx
    end
    else
    begin
      nStr := 'Select * From $PD Where ' +
              '(P_Order =''$OID'' or P_OrderBak =''$OID'') And P_PoundIdx=''$PI''';
      //xxxxx
    end;
    
	  nStr := MacroValue(nStr, [MI('$PI', FListA.Values['O_PoundIdx']),
	                            MI('$PD', sTable_PoundLog),
	                            MI('$OID', FListA.Values['O_ID'])]);
	  //xxxxx

	  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
	  begin
      try
        nProNameList := TStringList.Create;
        nMNameList := TStringList.Create;

        nProNameList.Text := FListA.Values['O_ProName'];
        nMNameList.Text   := FListA.Values['O_StockName'];
        nPoundIdx          := StrToIntDef(FListA.Values['O_PoundIdx'],1);

        if RecordCount<1 then
        begin
          SetLength(nBills, 1);

          with nBills[0], FListA do
          begin
            FZhiKa      := Values['O_ID'];
            FID         := Values['O_ID'];
	          FCusName    := nProNameList.Strings[nPoundIdx-1];
            FTruck      := Values['O_Truck'];

            if Values['O_KeepCard'] = sFlag_Yes then
              FCType       := sFlag_CardGuDing
            else
              FCType       := sFlag_CardLinShi;

            FType       := Values['O_Type'];
	          FStockName  := nMNameList.Strings[nPoundIdx-1];

            FCard       := Values['O_Card'];
            FStatus     := Values['O_Status'];
            FNextStatus := Values['O_NextStatus'];
            FNeiDao     := sFlag_No;
            FPoundIdx   := nPoundIdx;
            FPoundMax   := nProNameList.Count;
            FSelected := True;
          end;
        end else
        begin
          SetLength(nBills, RecordCount);

          nIdx := 0;

          First;
          while not Eof do
          with nBills[nIdx], FListA do
          begin
            FZhiKa      := Values['O_ID'];
            FID         := Values['O_ID'];
            FPoundID    := FieldByName('P_ID').AsString;

            FCusID      := '';
            FCusName    := nProNameList.Strings[nPoundIdx-1];
            FTruck      := Values['O_Truck'];

            FType       := Values['O_Type'];
            FStockNo    := '';
            FStockName  := nMNameList.Strings[nPoundIdx-1];
            FValue      := 0;

            FCard       := Values['O_Card'];
            FStatus     := Values['O_Status'];
            FNextStatus := Values['O_NextStatus'];

            if (FStatus = '') or (FStatus = sFlag_BillNew) then
            begin
              FStatus     := sFlag_TruckNone;
              FNextStatus := sFlag_TruckNone;
            end;

            if Values['O_KeepCard'] = sFlag_Yes then
              FCType       := sFlag_CardGuDing
            else
              FCType       := sFlag_CardLinShi;

            if FCtype = sFlag_CardGuDing then
            begin
              if FNextStatus = sFlag_TruckBFM then
              begin
                with FPData do
                begin
                  FStation  := FieldByName('P_PStation').AsString;
                  FValue    := FieldByName('P_PValue').AsFloat;
                  FDate     := FieldByName('P_PDate').AsDateTime;
                  FOperator := FieldByName('P_PMan').AsString;
                end;

                with FMData do
                begin
                  FStation  := FieldByName('P_MStation').AsString;
                  FValue    := FieldByName('P_MValue').AsFloat;
                  FDate     := FieldByName('P_MDate').AsDateTime;
                  FOperator := FieldByName('P_MMan').AsString;
                end;
                FKZValue  := FieldByName('P_KZValue').AsFloat;
              end;
            end
            else
            begin
              with FPData do
              begin
                FStation  := FieldByName('P_PStation').AsString;
                FValue    := FieldByName('P_PValue').AsFloat;
                FDate     := FieldByName('P_PDate').AsDateTime;
                FOperator := FieldByName('P_PMan').AsString;
              end;

              with FMData do
              begin
                FStation  := FieldByName('P_MStation').AsString;
                FValue    := FieldByName('P_MValue').AsFloat;
                FDate     := FieldByName('P_MDate').AsDateTime;
                FOperator := FieldByName('P_MMan').AsString;
              end;
              FKZValue  := FieldByName('P_KZValue').AsFloat;
            end;


            FNeiDao     := sFlag_No;
            //FCtype  := sFlag_OrderCardL;
            FPoundIdx   := nPoundIdx;
            FPoundMax  := nProNameList.Count;
            FPrintBD   := True;
            FSelected := True;

            Inc(nIdx);
            Next;
          end;
        end;
      finally
        nProNameList.Free;
        nMNameList.Free;
	    end;
	  end;
	end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: ������[FIn.FData];��λ[FIn.FExtParam]
//Desc: ����ָ����λ�ύ�Ľ������б�
function TWorkerBusinessOrders.SavePostOrderItems(
  var nData: string): Boolean;
var nVal, nNet, nAKVal: Double;
    nIdx: Integer;
    nStr,nSQL: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
    nCardType:string;
//    nysline:Pysline;
  nIsPreTruck:Boolean;
  nPrePValue:Double;
  nPrePMan:string;
  nPrePTime:TDateTime;
  nStatus,nNextStatus,nYS,nPID:string;
  nBID,nModel,nShip,nYear,nKD:string;
begin
  Result := False;

  AnalyseBillItems(FIn.FData, nPound);
  //��������

  nIsPreTruck := getPrepinfo(nPound[0].Ftruck,nPrePValue,nPrePMan,nPrePTime);

  FListA.Clear;
  //���ڴ洢SQL�б�

  nCardType := '';
  if not GetCardUsed(nPound[0].Fcard, nCardType) then Exit;

  nBID :='';nModel := '';nShip := '';nYear := '';nKD := '';
  if nCardType = sFlag_Provide then
  begin
    GetOrderInfo(nPound[0].FZhiKa,nBID,nModel,nShip,nYear,nKD);
  end;
  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //����
  begin
    if nCardType=sFlag_Mul then
    begin
      nSQL := MakeSQLByStr([
              SF('O_Status', sFlag_TruckIn),
              SF('O_NextStatus', sFlag_TruckBFP),
              SF('O_InMan', FIn.FBase.FFrom.FUser),
              SF('O_InTime', sField_SQLServer_Now, sfVal)
              ], sTable_CardOther, SF('R_ID', nPound[0].FID), False);
      FListA.Add(nSQL);
    end
    else
    begin
      FListC.Clear;
      FListC.Values['Group'] := sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_OrderDtl;

      if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      with nPound[0] do
      begin
        nSQL := MakeSQLByStr([
              SF('D_ID', nOut.FData),
              SF('D_Card', FCard),
              SF('D_OID', FZhiKa),
              SF('D_Truck', FTruck),
              SF('D_ProID', FCusID),
              SF('D_ProName', FCusName),
              SF('D_ProPY', GetPinYinOfStr(FCusName)),

              SF('D_Type', FType),
              SF('D_StockNo', FStockNo),
              SF('D_StockName', FStockName),

              SF('D_Status', sFlag_TruckIn),
              SF('D_NextStatus', sFlag_TruckBFP),
              SF('D_InMan', FIn.FBase.FFrom.FUser),
              SF('D_InTime', sField_SQLServer_Now, sfVal)
  //            SF('D_RecID', FRecID)
              ], sTable_OrderDtl, '', True);
        FListA.Add(nSQL);

        {$IFDEF UseWXERP}
        nSQL := MakeSQLByStr([
              SF('H_ID'    , nOut.FData),
              SF('H_Order' , nBID),
              SF('H_Status' , '0'),
              SF('H_BillType'  , sFlag_Provide),
              SF('H_PurType'   , 'Trk')
              ], sTable_HHJYSync, '', True);
        gDBConnManager.WorkerExec(FDBConn, nSQL);
        {$ENDIF}
      end;
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

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //���ذ񵥺�,�������հ�
    with nPound[0] do
    begin
      FStatus := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckXH;

      nStr := 'Select D_Value From %s Where D_Name=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_StockIfYS]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
           nYS := Fields[0].AsString
      else nYS := sFlag_No;

      if nYS = sFlag_Yes then
      begin
        nStr := 'Select D_Value From %s Where ((D_Name=''%s'') or (D_Name=''%s'')) and D_Value=''%s'' ';
        nStr := Format(nStr, [sTable_SysDict, sFlag_NFStock, sFlag_NFPurch, FStockNo]);

        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        if RecordCount > 0 then
        begin
          FNextStatus := sFlag_TruckBFM;
        end;
        //�ֳ�������ֱ�ӹ���
      end
      else
        FNextStatus := sFlag_TruckBFM;

      if nCardType=sFlag_Mul then
        FNextStatus := sFlag_TruckBFM;
        
      nSQL := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_Type', sFlag_Provide),
            SF('P_Order', FID),
            SF('P_Truck', FTruck),
            SF('P_CusID', FCusID),
            SF('P_CusName', FCusName),
            SF('P_MID', FStockNo),
            SF('P_MName', FStockName),
            SF('P_MType', FType),
            SF('P_LimValue', 0),
            SF('P_PValue', FPData.FValue, sfVal),
            SF('P_PDate', sField_SQLServer_Now, sfVal),
            SF('P_PMan', FIn.FBase.FFrom.FUser),
            SF('P_FactID', FFactory),
            SF('P_PStation', FPData.FStation),
            SF('P_Direction', '����'),
            SF('P_PModel', FPModel),
            SF('P_Status', sFlag_TruckBFP),
            SF('P_Valid', sFlag_Yes),
            SF('P_PoundIdx', IntToStr(FPoundIdx)),
            SF('P_BID', nBID),
            SF('P_Model', nModel),
            SF('P_Ship', nShip),
            SF('P_Year', nYear),
            SF('P_KD', nKD),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      if nCardType=sFlag_Mul then
      begin
        nSQL := MakeSQLByStr([
                SF('O_Status', FStatus),
                SF('O_NextStatus', FNextStatus),
                SF('O_BFPValue', FPData.FValue, sfVal),
                SF('O_BFPTime', sField_SQLServer_Now, sfVal),
                SF('O_BFPMan', FIn.FBase.FFrom.FUser)
                ], sTable_CardOther, SF('R_ID', FID), False);
        FListA.Add(nSQL);
      end
      else
      begin
        nSQL := MakeSQLByStr([
                SF('D_Status', FStatus),
                SF('D_NextStatus', FNextStatus),
                SF('D_PValue', FPData.FValue, sfVal),
                SF('D_PDate', sField_SQLServer_Now, sfVal),
                SF('D_PMan', FIn.FBase.FFrom.FUser)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL);
      end;
      if nIsPreTruck then
      begin
        nSQL := 'update %s set T_PrePValue=%f,T_PrePMan=''%s'',T_PrePTime=%s where t_truck=''%s'' and T_PrePUse=''%s''';
        nSQL := format(nSQL,[sTable_Truck,FPData.FValue,FIn.FBase.FFrom.FUser,sField_SQLServer_Now,FTruck,sflag_yes]);
        FListA.Add(nSQL);
      end;
    end;

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckXH then //�����ֳ�
  begin
    with nPound[0] do
    begin
      FStatus := sFlag_TruckXH;
      FNextStatus := sFlag_TruckBFM;

      nStr := SF('P_Order', FID);
      //where
      nSQL := MakeSQLByStr([
                SF('P_KZValue', FKZValue, sfVal)
                ], sTable_PoundLog, nStr, False);
        //���տ���
       FListA.Add(nSQL);

      if nCardType=sFlag_Mul then
      begin
        nSQL := MakeSQLByStr([
                SF('O_Status', FStatus),
                SF('O_NextStatus', FNextStatus)
                ], sTable_CardOther, SF('R_ID', FID), False);
        FListA.Add(nSQL);
      end
      else
      begin
        nSQL := MakeSQLByStr([
                SF('D_Status', FStatus),
                SF('D_NextStatus', FNextStatus),
                SF('D_YTime', sField_SQLServer_Now, sfVal),
                SF('D_YMan', FIn.FBase.FFrom.FUser),
                SF('D_KZValue', FKZValue, sfVal),
                SF('D_YSResult', FYSValid),
                SF('D_Memo', FMemo)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL);
      end;
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    with nPound[0] do
    begin
      nStr := SF('P_Order', FID);
      //where
      nStatus := sFlag_TruckBFM;
      nNextStatus := sFlag_TruckOut;
      //���ڿ�+Ԥ��Ƥ�أ���һ״̬Ϊë��
      if (FCtype=sFlag_CardGuDing) and nIsPreTruck then
      begin
        nNextStatus := sFlag_TruckBFM;
      end;
      //�ڵ�����һ״̬ΪƤ��
      if FNeiDao=sFlag_Yes then
      begin
        nStatus := sFlag_TruckIn;
        nNextStatus := sFlag_TruckBFP;
      end;

      nVal := FMData.FValue - FPData.FValue;
      if (nCardType=sFlag_Mul) and (FPoundIdx > 1) then
      begin
        FListC.Clear;
        FListC.Values['Group'] := sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_PoundID;

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
                FListC.Text, sFlag_Yes, @nOut) then
          raise Exception.Create(nOut.FData);
        FOut.FData := nOut.FData;

        getLastPInfo(FID,nPrePValue,nPrePMan,nPrePTime);

        nSQL := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_Type', sFlag_Provide),
            SF('P_Order', FID),
            SF('P_Truck', FTruck),
            SF('P_CusID', FCusID),
            SF('P_CusName', FCusName),
            SF('P_MID', FStockNo),
            SF('P_MName', FStockName),
            SF('P_MType', FType),
            SF('P_LimValue', 0),
            SF('P_PValue', FPData.FValue, sfVal),
            SF('P_MDate', nPrePTime, sfDateTime),
            SF('P_MMan', nPrePMan),
            SF('P_MValue', FMData.FValue, sfVal),
            SF('P_PDate', sField_SQLServer_Now, sfVal),
            SF('P_PMan', FIn.FBase.FFrom.FUser),
            SF('P_FactID', FFactory),
            SF('P_PStation', FPData.FStation),
            SF('P_Direction', '����'),
            SF('P_PModel', FPModel),
            SF('P_Status', sFlag_TruckBFP),
            SF('P_Valid', sFlag_Yes),
            SF('P_PoundIdx', IntToStr(FPoundIdx)),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
        FListA.Add(nSQL);
      end
      else
      if (nCardType=sFlag_Mul) and (FCtype = sFlag_CardGuDing) then
      begin
        nPrePMan := '';
        nPrePTime := Now;

        nSQL := 'Select top 1 P_ID,P_PValue,P_PMan,P_PDate From %s Where P_Order=''%s'' order by R_ID desc ';
        nSQL := Format(nSQL, [sTable_PoundLog, FID]);
        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        if RecordCount > 0 then
        begin
          nStr := Fields[0].AsString;
          nPrePTime := FieldByName('P_PDate').asDateTime;
          nPrePMan := FieldByName('P_PMan').asString;
        end;

        getLastPInfo(FID,nPrePValue,nPrePMan,nPrePTime);

        nStr := SF('P_ID', nStr);
        nSQL := MakeSQLByStr([
                SF('P_PValue', FPData.FValue, sfVal),
//                SF('P_PDate', nPrePTime, sfDateTime),
//                SF('P_PMan', nPrePMan),
                SF('P_PStation', FPData.FStation),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //xxxxx
        WriteLog('��ʱҵ��̶�������ë��SQL:' + nSQL);
        FListA.Add(nSQL);
      end
      else
      if (FStatus=sFlag_TruckBFM) and (FNextStatus=sFlag_TruckBFM) then
      begin
        FListC.Clear;
        FListC.Values['Group'] := sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_PoundID;

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
                FListC.Text, sFlag_Yes, @nOut) then
          raise Exception.Create(nOut.FData);
        FOut.FData := nOut.FData;

        nSQL := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_Type', sFlag_Provide),
            SF('P_Order', FID),
            SF('P_Truck', FTruck),
            SF('P_CusID', FCusID),
            SF('P_CusName', FCusName),
            SF('P_MID', FStockNo),
            SF('P_MName', FStockName),
            SF('P_MType', FType),
            SF('P_LimValue', 0),
            SF('P_PValue', FPData.FValue, sfVal),
            SF('P_PDate', FPData.FDate, sfDateTime),
            SF('P_PMan', FPData.FOperator),
            SF('P_MValue', FMData.FValue, sfVal),
            SF('P_MDate', sField_SQLServer_Now, sfVal),
            SF('P_MMan', FIn.FBase.FFrom.FUser),
            SF('P_FactID', FFactory),
            SF('P_PStation', FPData.FStation),
            SF('P_Direction', '����'),
            SF('P_PModel', FPModel),
            SF('P_Status', sFlag_TruckBFP),
            SF('P_Valid', sFlag_Yes),
            SF('P_BID', nBID),
            SF('P_Model', nModel),
            SF('P_Ship', nShip),
            SF('P_Year', nYear),
            SF('P_KD', nKD),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
              SF('D_Status', nStatus),
              SF('D_NextStatus', FNextStatus),
              SF('D_PValue', FPData.FValue, sfVal),
              SF('D_PDate', FPData.FDate, sfDateTime),
              SF('D_PMan', FPData.FOperator),

              SF('D_MValue', FMData.FValue, sfVal),
              SF('D_MDate', sField_SQLServer_Now, sfVal),
              SF('D_MMan', FIn.FBase.FFrom.FUser)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL);
      end
      else if FNextStatus = sFlag_TruckBFP then
      begin
        nSQL := MakeSQLByStr([
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_PStation', FPData.FStation),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', DateTime2Str(FMData.FDate)),
                SF('P_MMan', FMData.FOperator),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //����ʱ,����Ƥ�ش�,����Ƥë������
        FListA.Add(nSQL);

        if FNeiDao=sFlag_Yes then
        begin
          nStatus := sFlag_TruckBFM;
          nNextStatus := sFlag_TruckOut;
        end;

        nSQL := MakeSQLByStr([
                SF('D_Status', nStatus),
                SF('D_NextStatus', nNextStatus),
                SF('D_PValue', FPData.FValue, sfVal),
                SF('D_PDate', sField_SQLServer_Now, sfVal),
                SF('D_PMan', FIn.FBase.FFrom.FUser),
                SF('D_MValue', FMData.FValue, sfVal),
                SF('D_MDate', DateTime2Str(FMData.FDate)),
                SF('D_MMan', FMData.FOperator),
                SF('D_AKValue', nAKVal, sfVal),
                SF('D_Value', nVal, sfVal)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL);
      end
      else
      begin
        nSQL := MakeSQLByStr([
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', FPData.FDate, sfDateTime),
                SF('P_PMan', FPData.FOperator),
                SF('P_PStation', FPData.FStation),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //xxxxx
        FListA.Add(nSQL);

        if FNeiDao=sFlag_Yes then
        begin
          nStatus := sFlag_TruckBFM;
          nNextStatus := sFlag_TruckOut;
        end;

        nSQL := MakeSQLByStr([
                SF('D_PValue', FPData.FValue, sfVal),
                SF('D_PDate', FPData.FDate, sfDateTime),
                SF('D_PMan', FPData.FOperator),
                SF('D_Status', nStatus),
                SF('D_NextStatus', nNextStatus),
                SF('D_MValue', FMData.FValue, sfVal),
                SF('D_MDate', sField_SQLServer_Now, sfVal),
                SF('D_MMan', FMData.FOperator),
                SF('D_Value', nVal, sfVal)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL);
      end;

      if FNeiDao=sFlag_Yes then
      begin
        nSQL := 'update %s set p_orderBak=p_order, p_order=null where p_order=''%s''';
        nSQL := format(nSQL,[sTable_PoundLog,FID]);
        FListA.Add(nSQL);
      end
      else
      begin
        nSQL := 'update %s set p_orderBak=p_order where p_order=''%s''';
        nSQL := format(nSQL,[sTable_PoundLog,FID]);
        FListA.Add(nSQL);
      end;

      if nCardType=sFlag_Mul then
      begin
        WriteLog('��ǰ����˳��:'+IntToStr(FPoundIdx)+'�ܳ��ش���:'+IntToStr(FPoundMax)
                 +'��ǰ״̬:'+FStatus+'��һ״̬:'+FNextStatus);
        if FPoundIdx < FPoundMax then
        begin
          nIdx := FPoundIdx + 1;
          FStatus := sFlag_TruckBFP;
          FNextStatus := sFlag_TruckBFM;
        end
        else
        begin
          nIdx := FPoundIdx;
          FStatus := sFlag_TruckBFM;
          FNextStatus := sFlag_TruckOut;
        end;
        nSQL := MakeSQLByStr([
                SF('O_PoundIdx', IntToStr(nIdx)),
                SF('O_Status', FStatus),
                SF('O_NextStatus', FNextStatus)
                ], sTable_CardOther, SF('R_ID', FID), False);
        FListA.Add(nSQL);
      end;
//      nSQL := 'Update $OrderBase Set B_SentValue=B_SentValue+$Val, ' +
//              'B_RestValue=B_Value-B_SentValue-$Val '+
//              'Where B_RecID = ''$RID'' ';
//      nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
//              MI('$RID', FRecID), MI('$Val', FloatToStr(nVal))]);
//      FListA.Add(nSQL);
      //�������ջ���

      if (nCardType=sFlag_Mul) and (FCtype = sFlag_CardGuDing) then
      begin
        nSQL := 'Select top 1 P_ID From %s Where P_Order=''%s'' order by R_ID desc ';
        nSQL := Format(nSQL, [sTable_PoundLog, FID]);
        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        if RecordCount > 0 then
        begin
          FOut.FData := Fields[0].AsString;
        end;
      end
      else
      begin
        nSQL := 'Select P_ID From %s Where P_Order=''%s'' ';
        nSQL := Format(nSQL, [sTable_PoundLog, FID]);
        //δ��ë�ؼ�¼
        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        if RecordCount > 0 then
        begin
          FOut.FData := Fields[0].AsString;
        end;
      end;
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    if nCardType=sFlag_Mul then
    begin
      if nPound[0].FCtype = sFlag_CardGuDing then
      begin
        nSQL := 'Update %s Set O_InTime=NULL,O_InMan=NULL,' +
                'O_BFPTime=NULL,O_BFPMan=NULL,O_BFPValue=0,' +
                'O_Status=''%s'', O_NextStatus=''%s'' ' +
                'Where R_ID=''%s''';
        nSQL := Format(nSQL, [sTable_CardOther, sFlag_TruckNone,
                sFlag_TruckIn, nPound[0].FID]);
        FListA.Add(nSQL);
      end
      else
      begin
        nSQL := MakeSQLByStr([
                SF('O_Status', sFlag_TruckOut),
                SF('O_NextStatus', ''),
                SF('O_Card', ''),
                SF('O_OutTime', sField_SQLServer_Now, sfVal),
                SF('O_OutMan', FIn.FBase.FFrom.FUser)
                ], sTable_CardOther, SF('R_ID', nPound[0].FID), False);
        FListA.Add(nSQL);

        if not CallMe(cBC_LogOffOrderCard, nPound[0].FCard, '', @nOut) then
        begin
          nData := nOut.FData;
          Exit;
        end;
      end;
    end
    else
    begin
      with nPound[0] do
      begin
        nSQL := MakeSQLByStr([SF('D_Status', sFlag_TruckOut),
                SF('D_NextStatus', ''),
                SF('D_Card', ''),
                SF('D_OutFact', sField_SQLServer_Now, sfVal),
                SF('D_OutMan', FIn.FBase.FFrom.FUser)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL); //���²ɹ���
      end;

      nSQL := 'Select O_CType,O_Card From %s Where O_ID=''%s''';
      nSQL := Format(nSQL, [sTable_Order, nPound[0].FZhiKa]);

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        nStr := FieldByName('O_Card').AsString;
        if FieldByName('O_CType').AsString = sFlag_OrderCardL then
        if not CallMe(cBC_LogOffOrderCard, nStr, '', @nOut) then
        begin
          nData := nOut.FData;
          Exit;
        end;
      end;
      //�������ʱ��Ƭ����ע����Ƭ
    end;
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

  {$IFDEF SyncDataByWSDL}
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  with nPound[0] do
  begin
    nSQL := 'Select Top 1 P_ID,P_BID From %s Where P_OrderBak=''%s'' order by R_ID desc ';
    nSQL := Format(nSQL, [sTable_PoundLog, FID]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      nPID := Fields[0].AsString;
      if FNeiDao=sFlag_Yes then
      begin
        nSQL := MakeSQLByStr([
              SF('H_ID'   , nPID),
              SF('H_Order' , Fields[1].AsString),
              SF('H_Status' , '1'),
              SF('H_PurType' , sFlag_PurND),
              SF('H_BillType'   , sFlag_Provide)
              ], sTable_HHJYSync, '', True);
      end
      else
      if FPoundIdx > 0 then//��Ʒ����
      begin
        nSQL := MakeSQLByStr([
              SF('H_ID'   , nPID),
              SF('H_Order' , Fields[1].AsString),
              SF('H_Status' , '1'),
              SF('H_PurType' , sFlag_PurBP),
              SF('H_BillType'   , sFlag_Provide)
              ], sTable_HHJYSync, '', True);
        FListA.Add(nSQL);
      end
      else
      begin
        nSQL := MakeSQLByStr([
              SF('H_ID'   , nPID),
              SF('H_Order' , Fields[1].AsString),
              SF('H_Status' , '1'),
              SF('H_PurType' , sFlag_PurPT),
              SF('H_BillType'   , sFlag_Provide)
              ], sTable_HHJYSync, '', True);
        FListA.Add(nSQL);
      end;
      WriteLog('�ɹ���д��ͬ����Ϣ:' + nSQL);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;
  end;
  {$ENDIF}


  {$IFDEF UseWXERP}
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    with nPound[0] do
    begin
      nSQL := 'Select Top 1 P_ID,P_BID From %s Where P_OrderBak=''%s'' order by R_ID desc ';
      nSQL := Format(nSQL, [sTable_PoundLog, FID]);

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        nPID := Fields[0].AsString;
        nSQL := MakeSQLByStr([
              SF('H_ID'        , nPID),
              SF('H_Order'     , Fields[1].AsString),
              SF('H_Status'    , '1'),
              SF('H_PurType'   , sFlag_PurPT),
              SF('H_BillType'  , sFlag_Provide)
              ], sTable_HHJYSync, '', True);
      
        gDBConnManager.WorkerExec(FDBConn, nSQL);
      end;
    end;
  end;
  {$ENDIF}

  {$IFDEF SyncDataByDataBase}
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  with nPound[0] do
  begin
    nSQL := 'Select Top 1 P_ID From %s Where P_OrderBak=''%s'' order by R_ID desc ';
    nSQL := Format(nSQL, [sTable_PoundLog, FID]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      nPID := Fields[0].AsString;
      if FNeiDao=sFlag_Yes then
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_SyncHhNdOrderPoundData,
                nPID, '', @nOut) then
        begin
          nStr := '�ڵ�������[ %s ]�����ϴ�ʧ��.';
          nStr := Format(nStr, [nPID]);
          WriteLog(nStr);
        end;
      end
      else
      if FPoundIdx > 0 then//��Ʒ����
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_SyncHhOtOrderPoundData,
                nPID, '', @nOut) then
        begin
          nStr := '��Ʒ����������[ %s ]�����ϴ�ʧ��.';
          nStr := Format(nStr, [nPID]);
          WriteLog(nStr);
        end;
      end
      else
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_SyncHhOrderPoundData,
                nPID, '', @nOut) then
        begin
          nStr := '������[ %s ]�����ϴ�ʧ��.';
          nStr := Format(nStr, [nPID]);
          WriteLog(nStr);
        end;
      end;
    end;
  end;
  {$ENDIF}

  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    //���ڿ�+Ԥ��Ƥ�أ����Զ�����
    if (nPound[0].FCtype=sFlag_CardGuDing) and nIsPreTruck then
    begin
      //null;
    end
    //�ڵ��������Զ�����
    else if (nPound[0].FNeiDao=sFlag_yes)then begin
      //null;
    end
    else begin
      if Assigned(gHardShareData) then
      begin
        {$IFDEF GGJC}
        gHardShareData('TruckOut:' + nPound[0].FCard);
        //���������Զ�����
        WriteLog('���������Զ�����');
        {$ELSE}
        nSQL := 'Select D_Value From %s Where D_Name=''AutoOutStock'' and D_Value=''%s''';
        nSQL := Format(nSQL, [sTable_SysDict, nPound[0].FStockNo]);

        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        if RecordCount > 0 then
        begin
          gHardShareData('TruckOut:' + nPound[0].FCard);
          //���������Զ�����
          WriteLog('���������Զ�����');
        end;
        {$ENDIF}
      end;
    end;
  end;
end;

function TWorkerBusinessOrders.GetCardUsed(const nCard: string;
  var nCardType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := TWorkerBusinessCommander.Callme(cBC_GetCardUsed, nCard, '', @nOut);

  if Result then
       nCardType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2015-8-5
//Desc: ע���ſ�
function TWorkerBusinessOrders.LogoffOrderCard(var nData: string): Boolean;
var nStr: string;
  nNeiDao:string;
begin
  nNeiDao := FIn.FExtParam;
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set O_Card=Null Where O_Card=''%s''';
    nStr := Format(nStr, [sTable_Order, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    if nNeiDao=sflag_yes then
    begin
      nStr := 'Update %s Set d_status=''%s'',d_nextstatus='''' Where D_Card=''%s'' and d_status=''%s'' and d_nextstatus=''%s''';
      nStr := Format(nStr, [sTable_OrderDtl, sFlag_TruckOut, FIn.FData, sFlag_TruckIn, sFlag_TruckBFP]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;
    nStr := 'Update %s Set D_Card=Null Where D_Card=''%s''';
    nStr := Format(nStr, [sTable_OrderDtl, FIn.FData]);
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

function TWorkerBusinessOrders.getPrePInfo(const nTruck: string;
  var nPrePValue: Double; var nPrePMan: string;
  var nPrePTime: TDateTime): Boolean;
var
  nStr:string;
begin
  Result := False;
  nPrePValue := 0;
  nPrePMan := '';
  nPrePTime := now;
  nStr := 'select T_PrePValue,T_PrePMan,T_PrePTime from %s where t_truck=''%s'' and T_PrePUse=''%s''';
  nStr := format(nStr,[sTable_Truck,nTruck,sflag_yes]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount>0 then
    begin
      nPrePValue := FieldByName('T_PrePValue').asFloat;;
      nPrePMan := FieldByName('T_PrePMan').asString;
      nPrePTime := FieldByName('T_PrePTime').asDateTime;
      Result := True;
    end;
  end;
end;

function TWorkerBusinessOrders.GetLastPInfo(const nID:string;var nPValue: Double; var nPMan: string;
  var nPTime: TDateTime):Boolean;
var
  nStr:string;
begin
  Result := False;
  nPValue := 0;
  nPMan := '';
  nPTime := Now;

  nStr := 'select top 1 P_PValue,P_PMan,P_PDate from %s' +
          ' where P_OrderBak=''%s'' order by R_ID desc';
  nStr := format(nStr,[sTable_PoundLog,nID]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount>0 then
    begin
      nPTime := FieldByName('P_PDate').asDateTime;
      nPValue := FieldByName('P_PValue').asFloat;;
      nPMan := FieldByName('P_PMan').asString;
      Result := True;
    end;
  end;
end;

function TWorkerBusinessOrders.GetOrderInfo(const nOID: string;
  var nBID,nModel,nShip,nYear,nKD: string): Boolean;
var
  nStr:string;
begin
  Result := False;
  nBID :='';nModel := '';nShip := '';nYear := '';nKD := '';
  nStr := 'select O_BID,O_Model,O_Ship,O_Year,O_KD from %s where O_ID =''%s''';
  nStr := format(nStr,[sTable_Order,nOID]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount>0 then
    begin
      nBID   := FieldByName('O_BID').asString;
      nModel := FieldByName('O_Model').asString;
      nShip  := FieldByName('O_Ship').asString;
      nYear  := FieldByName('O_Year').asString;
      nKD    := FieldByName('O_KD').asString;
      Result := True;
    end;
  end;
end;

//Date:2018-02-01
//ͬ������������Ϣ��DL
function TWorkerBusinessCommander.SyncHhSaleMateriel(
  var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select FMaterielTypeID From $Mt where FParentID in (' +
            'Select FMaterielTypeID From $Mt where ' +
    '(FMaterielName like ''%%ˮ��%%'') or (FMaterielName like ''%%����%%'')'+
    ' or (FMaterielName like ''%%����%%''))';
    nStr := MacroValue(nStr, [MI('$Mt', sTable_HH_MaterielType)]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        FListA.Add(Fields[0].AsString);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

//  for nIdx := 0 to FListA.Count - 1 do
//  begin
//    nDBWorker := nil;
//    try
//      nStr := 'Select FMaterielTypeID From %s where FParentID = %s';
//      nStr := Format(nStr, [sTable_HH_MaterielType, FListA[nIdx]]);
//      //xxxxx
//
//      with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
//      if RecordCount > 0 then
//      begin
//        First;
//
//        while not Eof do
//        begin
//          FListB.Add(Fields[0].AsString);
//          Next;
//        end;
//      end;
//    finally
//      gDBConnManager.ReleaseConnection(nDBWorker);
//    end;
//  end;
//
//  FListA.Add(FListB.Text);
  FListB.Clear;


  for nIdx := 0 to FListA.Count - 1 do
  begin

    if FListA.Strings[nIdx] = '' then
      Continue;
    if not IsNumber(FListA.Strings[nIdx],False) then
      Continue;
    nDBWorker := nil;
    try
      nStr := 'select FMaterielNumber, FMaterielName, FModel from %s ' +
              ' where FMaterielTypeID = %s and FStatus = 1';
      nStr := Format(nStr, [sTable_HH_Materiel, FListA[nIdx]]);
      //xxxxx

      with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
      if RecordCount > 0 then
      begin
        First;

        while not Eof do
        begin
          if Pos('P',Fields[1].AsString) > 0 then
          begin
            nStr := SF('D_Name', 'StockItem')+' and '+SF('D_Memo', 'D')+
                    ' and '+SF('D_ParamB', Fields[0].AsString+'D');
            nStr := MakeSQLByStr([SF('D_Value',
                    Fields[1].AsString + Fields[2].AsString + '��װ')
                    ], sTable_SysDict, nStr, False);
            //xxxxx
            FListB.Add(nStr);

            nStr := SF('D_Name', 'StockItem')+' and '+SF('D_Memo', 'S')+
                    ' and '+SF('D_ParamB', Fields[0].AsString+'S');
            nStr := MakeSQLByStr([SF('D_Value',
                    Fields[1].AsString + Fields[2].AsString + 'ɢװ')
                    ], sTable_SysDict, nStr, False);
            //xxxxx
            FListB.Add(nStr);

            nStr := MakeSQLByStr([SF('D_Name', 'StockItem'),
                    SF('D_ParamB', Fields[0].AsString+'D'),
                    SF('D_Value', Fields[1].AsString+Fields[2].AsString+'��װ'),
                    SF('D_Memo', 'D')
                    ], sTable_SysDict, '', True);
            //xxxxx
            FListC.Add(nStr);

            nStr := MakeSQLByStr([SF('D_Name', 'StockItem'),
                    SF('D_ParamB', Fields[0].AsString+'S'),
                    SF('D_Value', Fields[1].AsString+Fields[2].AsString+'ɢװ'),
                    SF('D_Memo', 'S')
                    ], sTable_SysDict, '', True);
            //xxxxx
            FListC.Add(nStr);
          end
          else
          begin
            nStr := SF('D_Name', 'StockItem')+' and '+SF('D_Memo', 'S')+
                    ' and '+SF('D_ParamB', Fields[0].AsString);
            nStr := MakeSQLByStr([SF('D_Value',
                    Fields[1].AsString + Fields[2].AsString)
                    ], sTable_SysDict, nStr, False);
            //xxxxx
            FListB.Add(nStr);

            nStr := MakeSQLByStr([SF('D_Name', 'StockItem'),
                    SF('D_ParamB', Fields[0].AsString),
                    SF('D_Value', Fields[1].AsString+Fields[2].AsString),
                    SF('D_Memo', 'S')
                    ], sTable_SysDict, '', True);
            //xxxxx
            FListC.Add(nStr);
          end;
          Next;
        end;
      end;
    finally
      gDBConnManager.ReleaseConnection(nDBWorker);
    end;
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

//Date:2018-02-01
//ͬ���ɹ�������Ϣ��DL
function TWorkerBusinessCommander.SyncHhProvideMateriel(
  var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select FMaterielTypeID From $Mt where FParentID in (' +
            'Select FMaterielTypeID From $Mt where FParentID=-1' +
    ' and ((FMaterielName like ''%%ԭȼ����%%'') or (FMaterielName like ''%%��Ʒ���%%''))) ';
    nStr := MacroValue(nStr, [MI('$Mt', sTable_HH_MaterielType)]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        FListA.Add(Fields[0].AsString);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;


  for nIdx := 0 to FListA.Count - 1 do
  begin
    nDBWorker := nil;
    try
        nStr := 'Select FMaterielTypeID From %s where FParentID = %s';
        nStr := Format(nStr, [sTable_HH_MaterielType, FListA.Strings[nIdx]]);
        //xxxxx

        with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
        if RecordCount > 0 then
        begin
          First;

          while not Eof do
          begin
            FListB.Add(Fields[0].AsString);
            Next;
          end;
        end;
    finally
      gDBConnManager.ReleaseConnection(nDBWorker);
    end
  end;

  FListA.Add(FListB.Text);
  FListB.Clear;
  WriteLog('ERP����ID:'+ FListA.Text);
  for nIdx := 0 to FListA.Count - 1 do
  begin
    if FListA.Strings[nIdx] = '' then
      Continue;
    if not IsNumber(FListA.Strings[nIdx],False) then
      Continue;
      
    nDBWorker := nil;
    try
      nStr := 'select FMaterielNumber, FMaterielName, FModel from %s ' +
              ' where FMaterielTypeID = %s and FStatus = 1';
      nStr := Format(nStr, [sTable_HH_Materiel, FListA.Strings[nIdx]]);
      //xxxxx

      with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
      if RecordCount > 0 then
      begin
        First;

        while not Eof do
        begin
          nStr := SF('M_ID', Fields[0].AsString);
          nStr := MakeSQLByStr([SF('M_Name', Fields[1].AsString),
                  SF('M_PY', GetPinYinOfStr(Fields[1].AsString))
                  ], sTable_Materails, nStr, False);
          //xxxxx
          FListB.Add(nStr);

          nStr := MakeSQLByStr([SF('M_ID', Fields[0].AsString),
                  SF('M_Name', Fields[1].AsString),
                  SF('M_PY', GetPinYinOfStr(Fields[1].AsString))
                  ], sTable_Materails, '', True);
          //xxxxx
          FListC.Add(nStr);

          Next;
        end;
      end;
    finally
      gDBConnManager.ReleaseConnection(nDBWorker);
    end;
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

//Date:2018-02-02
//ͬ��ERP�ͻ���Ϣ��DL
function TWorkerBusinessCommander.SyncHhCustomer(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  FListB.Clear;
  Result := True;

  nDBWorker := nil;
  try
    if FIn.FData='' then
    begin
      nStr := 'Select SC.FCustomerID, SC.FCustomerName, CI.FAddress, CI.FPhone,' +
              ' CI.FTaxAccounts, CI.FBankNames, CI.FBankAccounts' +
              ' From $SC SC Left join $CI CI on CI.FCustomerID=SC.FCustomerID';

      nStr := MacroValue(nStr, [MI('$SC', sTable_HH_Customer),
                                MI('$CI', sTable_HH_CusInv)]);
    end else
    begin
      nStr := 'Select SC.FCustomerID, SC.FCustomerName, CI.FAddress, CI.FPhone,' +
              ' CI.FTaxAccounts, CI.FBankNames, CI.FBankAccounts' +
              ' From $SC SC Left join $CI CI on CI.FCustomerID=SC.FCustomerID' +
              ' where SC.FCustomerID=''$ID''';

      nStr := MacroValue(nStr, [MI('$SC', sTable_HH_Customer),
                                MI('$CI', sTable_HH_CusInv),
                                MI('$ID', FIn.FData)]);
    end;
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        nStr := MakeSQLByStr([SF('C_ID', FieldByName('FCustomerID').AsString),
                SF('C_Name', FieldByName('FCustomerName').AsString),
                SF('C_PY', GetPinYinOfStr(FieldByName('FCustomerName').AsString)),
                SF('C_Addr', FieldByName('FAddress').AsString),
                SF('C_Phone', FieldByName('FPhone').AsString),
                SF('C_Tax', FieldByName('FTaxAccounts').AsString),
                SF('C_Bank', FieldByName('FBankNames').AsString),
                SF('C_Account', FieldByName('FBankAccounts').AsString),
                SF('C_XuNi', sFlag_No)
                ], sTable_Customer, '', True);
        FListA.Add(nStr);

        nStr := SF('C_ID', FieldByName('FCustomerID').AsString);
        nStr := MakeSQLByStr([
                SF('C_Name', FieldByName('FCustomerName').AsString),
                SF('C_PY', GetPinYinOfStr(FieldByName('FCustomerName').AsString)),
                SF('C_Addr', FieldByName('FAddress').AsString),
                SF('C_Phone', FieldByName('FPhone').AsString),
                SF('C_Tax', FieldByName('FTaxAccounts').AsString),
                SF('C_Bank', FieldByName('FBankNames').AsString),
                SF('C_Account', FieldByName('FBankAccounts').AsString)
                ], sTable_Customer, nStr, False);
        FListB.Add(nStr);
      finally
        Next;
      end;
    end else
    begin
      Result:=False;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if (FListB.Count > 0) then
  try
    FDBConn.FConn.BeginTrans;
    //��������
    for nIdx:=0 to FListB.Count - 1 do
    begin
      if gDBConnManager.WorkerExec(FDBConn,FListB[nIdx]) <= 0 then
      begin
        gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
      end;
    end;
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date:2018-02-02
//ͬ��ERP�ͻ���Ϣ��DL
function TWorkerBusinessCommander.SyncHhProvider(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  FListB.Clear;
  Result := True;

  nDBWorker := nil;
  try
    if FIn.FData='' then
    begin
      nStr := 'Select FProviderID,FProviderName From %s ';
      nStr := Format(nStr, [sTable_HH_Provider]);
    end else
    begin
      nStr := 'Select FProviderID,FProviderName From %s where FProviderID=''%s'' ';
      nStr := Format(nStr, [sTable_HH_Provider, FIn.Fdata]);
    end;
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        nStr := MakeSQLByStr([SF('P_ID', FieldByName('FProviderID').AsString),
                SF('P_Name', FieldByName('FProviderName').AsString),
                SF('P_PY', GetPinYinOfStr(FieldByName('FProviderName').AsString))
                ], sTable_Provider, '', True);
        FListA.Add(nStr);

        nStr := SF('P_ID', FieldByName('FProviderID').AsString);
        nStr := MakeSQLByStr([
                SF('P_Name', FieldByName('FProviderName').AsString),
                SF('P_PY', GetPinYinOfStr(FieldByName('FProviderName').AsString))
                ], sTable_Provider, nStr, False);
        FListB.Add(nStr);
      finally
        Next;
      end;
    end else
    begin
      Result:=False;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if (FListB.Count > 0) then
  try
    FDBConn.FConn.BeginTrans;
    //��������
    for nIdx:=0 to FListB.Count - 1 do
    begin
      if gDBConnManager.WorkerExec(FDBConn,FListB[nIdx]) <= 0 then
      begin
        gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
      end;
    end;
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessCommander.GetHhOrderPlan(
  var nData: string): Boolean;
var nStr, nProStr, nMatStr, nYearStr: string;
    nValue: Double;
    nDBWorker: PDBWorker;
begin
  Result := False;

  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FData);

  nDBWorker := nil;
  try
    nStr := 'Select FMaterialProviderName,FMaterialProviderID,FMaterielName,' +
            'FMaterielID,FMaterielNumber,FEntryPlanNumber,FApproveAmount,' +
            'FEntryAmount, FModel, FProducerName From %s where 1=1 ';
    //xxxxx

    nStr := Format(nStr, [sTable_HH_OrderPlan]);

    if FListA.Values['Provider'] <> '' then
    begin
      if not IsNumber(FListA.Values['Provider'],False) then
        nProStr :=  'And (FMaterialProviderName like ''%%%s%%'') '
      else
        nProStr :=  'And (FMaterialProviderID like ''%%%s%%'') ';
      nProStr := Format(nProStr, [FListA.Values['Provider']]);
    end;

    if FListA.Values['Materiel'] <> '' then
    begin
      if not IsNumber(FListA.Values['Materiel'],False) then
        nMatStr :=  'And (FMaterielName like ''%%%s%%'') '
      else
        nMatStr :=  'And (FMaterielNumber like ''%%%s%%'') ';
      nMatStr := Format(nMatStr, [FListA.Values['Materiel']]);
    end;

    if FListA.Values['YearPeriod'] <> '' then
    begin
      nYearStr := nYearStr + 'And (FYearPeriod like ''%%%s%%'') ';
      nYearStr := Format(nYearStr, [FListA.Values['YearPeriod']]);
    end;
    nStr := nStr + nProStr + nMatStr + nYearStr;

    WriteLog('��ȡ��ͨԭ���Ͻ����ƻ�:'+nStr);

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount < 1 then
      begin
        nData := 'δ��ѯ���������.';
        Exit;
      end;

      FListA.Clear;
      FListB.Clear;

      First;

      while not Eof do
      with FListB do
      begin
        Values['Order']         := FieldByName('FEntryPlanNumber').AsString;
        Values['ProName']       := FieldByName('FMaterialProviderName').AsString;
        Values['ProID']         := FieldByName('FMaterialProviderID').AsString;
        Values['StockName']     := FieldByName('FMaterielName').AsString;
        Values['StockID']       := FieldByName('FMaterielID').AsString;
        Values['StockNo']       := FieldByName('FMaterielNumber').AsString;
        try
          nValue := FieldByName('FApproveAmount').AsFloat
                    - FieldByName('FEntryAmount').AsFloat;
          nValue := Float2PInt(nValue, cPrecision, False) / cPrecision;
        except
          nValue := 0;
        end;
        Values['PlanValue']     := FieldByName('FApproveAmount').AsString;//������
        Values['EntryValue']    := FieldByName('FEntryAmount').AsString;//�ѽ�����
        Values['Value']         := FloatToStr(nValue);//ʣ����
        Values['Model']         := FieldByName('FModel').AsString;//�ͺ�
        Values['KD']            := FieldByName('FProducerName').AsString;//���
        FListA.Add(PackerEncodeStr(FListB.Text));

        Next;
      end;
    end;

    FOut.FData := PackerEncodeStr(FListA.Text);
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

function TWorkerBusinessCommander.SyncHhOrderPoundData(
  var nData: string): Boolean;
var nStr, nDate:string;
    nSQL: string;
    nDBWorker: PDBWorker;
    nPDate, nMDate: TDateTime;
begin
  Result := False;

  nSQL := 'select *,(P_MValue-P_PValue - isnull(P_KZValue,0)) as D_NetWeight From %s a,'+
  ' %s b, %s c where a.D_OID=b.O_ID and a.D_ID=c.P_OrderBak and c.P_ID = ''%s'' ';

  nSQL := Format(nSQL,[sTable_OrderDtl,sTable_Order,sTable_PoundLog,FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  begin
    if RecordCount < 1 then
    begin
      nData := '������Ϊ[ %s ]�Ĳɹ�����������.';
      nData := Format(nData, [FIn.FData]);
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
    FListA.Values['FGrossWeightPersonnel']  := GetUserName(
                                               FieldByName('P_MMan').AsString);
    FListA.Values['FGrossWeightTime']       := FieldByName('P_MDate').AsString;
    FListA.Values['FReceiveGrossWeight']    := FieldByName('P_MValue').AsString;

    FListA.Values['FReceivePersonnel']      := GetUserName(
                                               FieldByName('P_MMan').AsString);
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
    FListA.Values['FTarePersonnel']         := GetUserName(
                                               FieldByName('P_PMan').AsString);
    FListA.Values['FTareTime']              := FieldByName('P_PDate').AsString;
    FListA.Values['FReceiveTare']           := FieldByName('P_PValue').AsString;

    FListA.Values['FReceiveNetWeight']      := FieldByName('D_NetWeight').AsString;

    FListA.Values['FCreator']               := GetUserName(
                                               FieldByName('O_Man').AsString);
    FListA.Values['FCreateTime']            := FieldByName('O_Date').AsString;
    FListA.Values['FShipNumber']            := FieldByName('P_Ship').AsString;
    FListA.Values['FConveyanceNumber']      := FieldByName('P_Truck').AsString;
    FListA.Values['FImpurity']              := FloatToStr(StrToFLoatDef(
                                         FieldByName('D_KZValue').AsString,0));

    FListA.Values['FStatus']                := '1';
    FListA.Values['FCancelStatus']          := '0';
    FListA.Values['FDataStatus']            := '0';
    FListA.Values['FMaterialStockInStatus'] := '0';
    FListA.Values['FFreightStockInStatus']  := '0';
    FListA.Values['FLabStatus']             := '0';
    FListA.Values['FMaterialStockInStatus'] := '0';
    FListA.Values['FMaterialStockInStatus'] := '0';
  end;

  nDBWorker := nil;
  try
    nStr := 'Select * From %s where FEntryPlanNumber = ''%s'' ';
    //xxxxx

    nStr := Format(nStr, [sTable_HH_OrderPlan, FListA.Values['FEntryPlanNumber']]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount < 1 then
      begin
        nData := 'δ��ѯ��ERP�����ƻ�[ %s ]�������.';
        nData := Format(nData, [FListA.Values['FEntryPlanNumber']]);
        Exit;
      end;

      with FListA do
      begin
        Values['FEntryPlanID']          := FieldByName('FEntryPlanID').AsString;
        Values['FCompanyID']            := FieldByName('FCompanyID').AsString;
        Values['FUseDepartmentID']      := FieldByName('FUseDepartmentID').AsString;
        Values['FRequirementPlanID']    := FieldByName('FRequirementPlanID').AsString;
        Values['FRequirementPlanDetailID'] := FieldByName('FRequirementPlanDetailID').AsString;

        Values['FYearPeriod']           := FieldByName('FYearPeriod').AsString;
        Values['FMaterielID']           := FieldByName('FMaterielID').AsString;
        Values['FMaterialProviderID']   := FieldByName('FMaterialProviderID').AsString;
        Values['FMaterialContractDetailID'] := FieldByName('FMaterialContractDetailID').AsString;
        Values['FProducerID']           := FieldByName('FProducerID').AsString;

        Values['FPlanAmount']           := FieldByName('FPlanAmount').AsString;
        Values['FApproveAmount']        := FieldByName('FApproveAmount').AsString;
        Values['FBillAmount']           := FieldByName('FBillAmount').AsString;
        Values['FSurplusPlanAmount']    := FieldByName('FSurplusPlanAmount').AsString;
        Values['FEntryAmount']          := FieldByName('FEntryAmount').AsString;

        Values['FMaterialPriceTax']     := FieldByName('FMaterialPriceTax').AsString;
        Values['FMaterialMoneyTax']     := GetMoney(
        FieldByName('FMaterialPriceTax').AsString,Values['FReceiveNetWeight']);

        Values['FMaterialInvoiceTypeID']:= FieldByName('FMaterialInvoiceTypeID').AsString;
        Values['FMaterialTaxRate']      := FieldByName('FMaterialTaxRate').AsString;
        Values['FMaterialPrice']        := FieldByName('FMaterialPrice').AsString;

        Values['FMaterialMoney']        := GetMoney(
        FieldByName('FMaterialPrice').AsString,Values['FReceiveNetWeight']);

        Values['FFreightContractDetailID'] := FieldByName('FFreightContractDetailID').AsString;
        Values['FFreightProviderID']    := FieldByName('FFreightProviderID').AsString;
        Values['FFreightPriceTax']      := FieldByName('FFreightPriceTax').AsString;
        Values['FFreightMoneyTax']      := GetMoney(
        FieldByName('FFreightPriceTax').AsString,Values['FReceiveNetWeight']);

        Values['FFreightInvoiceTypeID'] := FieldByName('FFreightInvoiceTypeID').AsString;
        Values['FFreightTaxRate']       := FieldByName('FFreightTaxRate').AsString;
        Values['FFreightPrice']         := FieldByName('FFreightPrice').AsString;
        Values['FFreightMoney']         := GetMoney(
        FieldByName('FFreightPrice').AsString,Values['FReceiveNetWeight']);
        Values['FMaterialSettlementFashion'] := FieldByName('FMaterialSettlementFashion').AsString;

        Values['FFreightSettlementFashion']  := FieldByName('FFreightSettlementFashion').AsString;
        Values['FMender']               := FieldByName('FMender').AsString;
        Values['FVer']                  := FieldByName('FVer').AsString;
        Values['FMaterielNumber']       := FieldByName('FMaterielNumber').AsString;
        Values['FMaterialSettlementRate'] := FieldByName('FMaterialSettlementRate').AsString;
        Values['FFreightSettlementRate']  := FieldByName('FFreightSettlementRate').AsString;
      end;
    end;

    nStr := GetID(sFlag_SMRB);
    if nStr <> '' then
      FListA.Values['FBillID'] := nStr;

    nStr := GetID(sFlag_SAFP);
    if nStr <> '' then
      FListA.Values['FAuditID'] := nStr;

  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nDBWorker := nil;
  try
    nStr := 'Select FUserID From %s where (FLoginName = ''%s'' or FUserName = ''%s'')';
    //xxxxx

    nStr := Format(nStr, [sTable_HH_SysUser, FListA.Values['FGrossWeightPersonnel'],
                          FListA.Values['FGrossWeightPersonnel']]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount > 0 then
        FListA.Values['FUserID'] := Fields[0].AsString;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Values['FUserID'] <> '' then
  begin
    nDBWorker := nil;
    try
      nStr := 'execute %s @UserID = %s, @CompanyID = %s';
      nStr := Format(nStr, [sTable_HH_SupplyMD, FListA.Values['FUserID'],
                                               FListA.Values['FCompanyID']]);
      with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
      begin
        if RecordCount > 0 then
          FListA.Values['FDepotID'] := Fields[0].AsString;
      end;
      //��ȡ�������
    finally
      gDBConnManager.ReleaseConnection(nDBWorker);
    end;
  end;

  if FListA.Values['FDepotID'] = '' then
    FListA.Values['FDepotID'] := HhOrderDefDepotID;//def

  nDBWorker := nil;
  try
    nStr := 'Select a.FFlowID, a.FProcessID From %s a , %s b' +
    ' where a.FFlowID = b.FFlowID and  b.FFLowName like ''%%%s%%'''+
    ' and b.FCompanyID = ''%s''';
    //xxxxx

    nStr := Format(nStr, [sTable_HH_AuditPro, sTable_HH_AuditMenu,
                          HhOrderPoundAuditMenu,FListA.Values['FCompanyID']]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount > 0 then
      begin
        FListA.Values['FFlowID']    := Fields[0].AsString;
        FListA.Values['FProcessID'] := Fields[1].AsString;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nDBWorker := nil;
  try
    nDBWorker := gDBConnManager.GetConnection(sFlag_DB_HH, FErrNum);
    if not Assigned(nDBWorker) then
    begin
      nData := '�������ݿ�ʧ��(DBConn Is Null).';
      Exit;
    end;

    if not nDBWorker.FConn.Connected then
      nDBWorker.FConn.Connected := True;
    //conn db

    nDBWorker.FConn.BeginTrans;
    try
      nStr := 'Delete From %s where FBillNumber = ''%s'' ';
      nStr := Format(nStr, [sTable_HH_OrderPoundData, FListA.Values['FBillNumber']]);

      gDBConnManager.WorkerExec(nDBWorker, nStr);
      //xxxxx
      nSQL := MakeSQLByStr([
        SF('FBillID', FListA.Values['FBillID']),
        SF('FBillNumber', FListA.Values['FBillNumber']),
        SF('FOldBillNumber', FListA.Values['FOldBillNumber']),
        SF('FBillTypeID', FListA.Values['FBillTypeID']),
        SF('FCompanyID', FListA.Values['FCompanyID']),
        SF('FUseDepartmentID', FListA.Values['FUseDepartmentID']),
        SF('FDepotID', FListA.Values['FDepotID']),
        SF('FYearPeriod', FListA.Values['FYearPeriod']),
        SF('FMaterielID', FListA.Values['FMaterielID']),
        SF('FEntryPlanID', FListA.Values['FEntryPlanID']),
        SF('FRequirementPlanID', FListA.Values['FRequirementPlanID']),
        SF('FRequirementPlanDetailID', FListA.Values['FRequirementPlanDetailID']),
        SF('FMaterialProviderID', FListA.Values['FMaterialProviderID']),
        SF('FMaterialContractDetailID', FListA.Values['FMaterialContractDetailID']),
        SF('FProducerID', FListA.Values['FProducerID']),
        SF('FMaterialPriceTax', FListA.Values['FMaterialPriceTax']),
        SF('FMaterialMoneyTax', FListA.Values['FMaterialMoneyTax']),
        SF('FMaterialInvoiceTypeID', FListA.Values['FMaterialInvoiceTypeID']),
        SF('FMaterialTaxRate', FListA.Values['FMaterialTaxRate']),
        SF('FMaterialPrice', FListA.Values['FMaterialPrice']),
        SF('FMaterialMoney', FListA.Values['FMaterialMoney']),
        SF('FFreightProviderID', FListA.Values['FFreightProviderID']),
        SF('FFreightContractDetailID', FListA.Values['FFreightContractDetailID']),
        SF('FFreightPriceTax', FListA.Values['FFreightPriceTax']),
        SF('FFreightMoneyTax', FListA.Values['FFreightMoneyTax']),
        SF('FFreightInvoiceTypeID', FListA.Values['FFreightInvoiceTypeID']),
        SF('FFreightTaxRate', FListA.Values['FFreightTaxRate']),
        SF('FFreightPrice', FListA.Values['FFreightPrice']),
        SF('FFreightMoney', FListA.Values['FFreightMoney']),
        SF('FBillAmount', FListA.Values['FBillAmount']),
        SF('FReceiveGrossWeight', FListA.Values['FReceiveGrossWeight']),
        SF('FReceiveTare', FListA.Values['FReceiveTare']),
        SF('FImpurity', FListA.Values['FImpurity']),
        SF('FDeductAmount', '0'),
        SF('FReceiveNetWeight', FListA.Values['FReceiveNetWeight']),
        SF('FConsignmentGrossWeight', '0'),
        SF('FConsignmentTare', '0'),
        SF('FConsignmentNetWeight', '0'),
        SF('FConveyanceNumber', FListA.Values['FConveyanceNumber']),
        SF('FMaterialSettlementFashion', FListA.Values['FMaterialSettlementFashion']),
        SF('FFreightSettlementFashion', FListA.Values['FFreightSettlementFashion']),
        SF('FGrossWeightStatus', FListA.Values['FGrossWeightStatus']),
        SF('FGrossWeightPersonnel', FListA.Values['FGrossWeightPersonnel']),
        SF('FGrossWeightTime', FListA.Values['FGrossWeightTime']),
        SF('FAgainWeightStatus', '0'),
        SF('FTareStatus', FListA.Values['FTareStatus']),
        SF('FTarePersonnel', FListA.Values['FTarePersonnel']),
        SF('FTareTime', FListA.Values['FTareTime']),
        SF('FIsManpowerUnload', '0'),
        SF('FUnloadMoney', '0'),
        SF('FReceivePersonnel', FListA.Values['FReceivePersonnel']),
        SF('FReceiveTime', FListA.Values['FReceiveTime']),
        SF('FMaterialSettlementStatus', '0'),
        SF('FMaterialSettlementPersonnel', FListA.Values['FMaterialSettlementPersonnel']),
        //SF('FMaterialSettlementTime', FListA.Values['FMaterialSettlementTime']),
        SF('FFreightSettlementStatus', '0'),
        SF('FFreightSettlementPersonnel', FListA.Values['FFreightSettlementPersonnel']),
        //SF('FFreightSettlementTime', FListA.Values['FFreightSettlementTime']),
        SF('FDataStatus', FListA.Values['FDataStatus']),
        SF('FMaterialStockInStatus', FListA.Values['FMaterialStockInStatus']),
        SF('FFreightStockInStatus', FListA.Values['FFreightStockInStatus']),
        SF('FStatus', FListA.Values['FStatus']),
        SF('FCancelStatus', FListA.Values['FCancelStatus']),
        SF('FCreator', FListA.Values['FCreator']),
        SF('FCreateTime', FListA.Values['FCreateTime']),
        SF('FRemark', FListA.Values['FRemark']),
        SF('FVer', FListA.Values['FVer']),
        SF('FMaterialSettlementRate', FListA.Values['FMaterialSettlementRate']),
        SF('FFreightSettlementRate', FListA.Values['FFreightSettlementRate']),
        SF('FShipNumber', FListA.Values['FShipNumber'])
        ], sTable_HH_OrderPoundData, '', True);

      gDBConnManager.WorkerExec(nDBWorker, nSQL);

      nStr := 'Delete From %s where FBusinessID = ''%s'' ';
      nStr := Format(nStr, [sTable_HH_AuditRecord, FListA.Values['FBillID']]);

      gDBConnManager.WorkerExec(nDBWorker, nStr);
      //xxxxx
      nStr := MakeSQLByStr([
        SF('FID', FListA.Values['FAuditID']),
        SF('FCompanyID', FListA.Values['FCompanyID']),
        SF('FFlowID', FListA.Values['FFlowID']),
        SF('FProcessID', FListA.Values['FProcessID']),
        SF('FBusinessID', FListA.Values['FBillID']),
        SF('FAuditingStatus', '1'),
        SF('FVer', FListA.Values['FVer'])
        ], sTable_HH_AuditRecord, '', True);

      gDBConnManager.WorkerExec(nDBWorker, nStr);

      nDBWorker.FConn.CommitTrans;
    except
      nDBWorker.FConn.RollbackTrans;
      nData := '�ɹ�����[ %s ]�����ϴ�ʧ��.';
      nData := Format(nData, [FIn.FData]);
      nStr := nData + nSQL;
      WriteLog(nStr);
      Exit;
    end;

    nStr := SF('FID', FListA.Values['FAuditID'])+' and '+
            SF('FCompanyID', FListA.Values['FCompanyID'])+' and '+
            SF('FBusinessID', FListA.Values['FBillID']);

    nStr := MakeSQLByStr([
    SF('FFlowID', FListA.Values['FFlowID']),
    SF('FProcessID', FListA.Values['FProcessID']),
    SF('FAuditingStatus', '2'),
    SF('FVer', FListA.Values['FVer'])
    ], sTable_HH_AuditRecord, nStr, False);

    gDBConnManager.WorkerExec(nDBWorker, nStr);

    nStr :='update %s set P_BDAX=''1'',P_BDNUM=P_BDNUM+1 where P_ID = ''%s'' ';
    nStr := Format(nStr,[sTable_PoundLog,FListA.Values['FPoundID']]);

    gDBConnManager.WorkerExec(FDBConn,nStr);

    FOut.FData := sFlag_Yes;
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

end;

function TWorkerBusinessCommander.GetUserName(
  const nLoginName: string): string;
var nStr: string;
    nDBWorker: PDBWorker;
begin
  Result := nLoginName;

  nDBWorker := nil;
  try
    nStr := 'Select FUserName From %s where FLoginName = ''%s'' ';
    //xxxxx

    nStr := Format(nStr, [sTable_HH_SysUser, nLoginName]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount > 0 then
        Result := Fields[0].AsString;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

function TWorkerBusinessCommander.GetMoney(const nPrice,
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

function TWorkerBusinessCommander.GetHhNeiDaoOrderPlan(
  var nData: string): Boolean;
var nStr, nProStr, nMatStr, nYearStr: string;
    nValue: Double;
    nDBWorker: PDBWorker;
begin
  Result := False;

  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FData);

  nDBWorker := nil;
  try
    nStr := 'Select FMaterielName,' +
            'FMaterielID,FMaterielNumber,FBillNumber,FApproveAmount,' +
            'FExecuteAmount, FModel From %s where 1=1 ';
    //xxxxx

    nStr := Format(nStr, [sTable_HH_NdOrderPlan]);

    if FListA.Values['Provider'] <> '' then
    begin
      if not IsNumber(FListA.Values['Provider'],False) then
        nProStr :=  'And (FMaterialProviderName like ''%%%s%%'') '
      else
        nProStr :=  'And (FMaterialProviderID like ''%%%s%%'') ';
      nProStr := Format(nProStr, [FListA.Values['Provider']]);
    end;

    if FListA.Values['Materiel'] <> '' then
    begin
      if not IsNumber(FListA.Values['Materiel'],False) then
        nMatStr :=  'And (FMaterielName like ''%%%s%%'') '
      else
        nMatStr :=  'And (FMaterielNumber like ''%%%s%%'') ';
      nMatStr := Format(nMatStr, [FListA.Values['Materiel']]);
    end;

    if FListA.Values['YearPeriod'] <> '' then
    begin
      nYearStr := nYearStr + 'And (FYearPeriod like ''%%%s%%'') ';
      nYearStr := Format(nYearStr, [FListA.Values['YearPeriod']]);
    end;
    nStr := nStr + nProStr + nMatStr + nYearStr;

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount < 1 then
      begin
        nData := 'δ��ѯ���������.';
        Exit;
      end;

      FListA.Clear;
      FListB.Clear;

      First;

      while not Eof do
      with FListB do
      begin
        Values['Order']         := FieldByName('FBillNumber').AsString;
        Values['StockName']     := FieldByName('FMaterielName').AsString;
        Values['StockID']       := FieldByName('FMaterielID').AsString;
        Values['StockNo']       := FieldByName('FMaterielNumber').AsString;
        try
          nValue := FieldByName('FApproveAmount').AsFloat
                    - FieldByName('FExecuteAmount').AsFloat;
          nValue := Float2PInt(nValue, cPrecision, False) / cPrecision;
        except
          nValue := 0;
        end;
        Values['PlanValue']     := FieldByName('FApproveAmount').AsString;//������
        Values['EntryValue']    := FieldByName('FExecuteAmount').AsString;//�ѽ�����
        Values['Value']         := FloatToStr(nValue);//ʣ����
        Values['Model']         := FieldByName('FModel').AsString;//�ͺ�

        FListA.Add(PackerEncodeStr(FListB.Text));

        Next;
      end;
    end;

    FOut.FData := PackerEncodeStr(FListA.Text);
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

function TWorkerBusinessCommander.SyncHhNeiDaoOrderPoundData(
  var nData: string): Boolean;
var nStr:string;
    nSQL: string;
    nDBWorker: PDBWorker;
begin
  Result := False;

  nSQL := 'select *,(P_MValue-P_PValue - isnull(P_KZValue,0)) as D_NetWeight From %s a,'+
  ' %s b, %s c where a.D_OID=b.O_ID and a.D_ID=c.P_OrderBak and c.P_ID = ''%s'' ';

  nSQL := Format(nSQL,[sTable_OrderDtl,sTable_Order,sTable_PoundLog,FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  begin
    if RecordCount < 1 then
    begin
      nData := '�ڵ��ɹ�����[ %s ]������.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FListA.Clear;

    FListA.Values['FTransferPlanID']        := FieldByName('P_BID').AsString;
    FListA.Values['FBillID']                := FieldByName('P_ID').AsString;
    FListA.Values['FBillNumber']            := FieldByName('P_ID').AsString;
    FListA.Values['FPoundID']               := FieldByName('P_ID').AsString;
    FListA.Values['FAuditID']               := FieldByName('P_ID').AsString;
    FListA.Values['FBillTypeID']            := '37';

    FListA.Values['FConsignmentGrossWeightStatus'] := '1';
    FListA.Values['FConsignmentGrossWeightPersonnel']  := GetUserName(
                                               FieldByName('P_MMan').AsString);
    FListA.Values['FConsignmentGrossWeightTime']:= FieldByName('P_MDate').AsString;
    FListA.Values['FConsignmentGrossWeight']    := FieldByName('P_MValue').AsString;

    FListA.Values['FConsignmentStatus']         := '1';
    FListA.Values['FConsignmentPersonnel']      := GetUserName(
                                               FieldByName('P_PMan').AsString);
    FListA.Values['FConsignmentTime']           := FieldByName('P_PDate').AsString;

    FListA.Values['FConsignmentTareStatus']     := '1';
    FListA.Values['FConsignmentTarePersonnel']  := GetUserName(
                                               FieldByName('P_PMan').AsString);;
    FListA.Values['FConsignmentTareTime']       := FieldByName('P_PDate').AsString;
    FListA.Values['FConsignmentTare']           := FieldByName('P_PValue').AsString;

    FListA.Values['FConsignmentNetWeight']      := FieldByName('D_NetWeight').AsString;


    FListA.Values['FReceiveGrossWeightStatus']   := '1';
    FListA.Values['FReceiveGrossWeightPersonnel']:= GetUserName(
                                               FieldByName('P_MMan').AsString);
    FListA.Values['FReceiveGrossWeightTime']     := FieldByName('P_MDate').AsString;
    FListA.Values['FReceiveGrossWeight']         := FieldByName('P_MValue').AsString;

    FListA.Values['FReceiveStatus']         := '2';
    FListA.Values['FReceivePersonnel']      := GetUserName(
                                               FieldByName('P_MMan').AsString);;
    FListA.Values['FReceiveTime']           := FieldByName('P_MDate').AsString;

    FListA.Values['FReceiveTareStatus']     := '1';
    FListA.Values['FReceiveTarePersonnel']  := GetUserName(
                                               FieldByName('P_PMan').AsString);;
    FListA.Values['FReceiveTareTime']       := FieldByName('P_PDate').AsString;
    FListA.Values['FReceiveTare']           := FieldByName('P_PValue').AsString;

    FListA.Values['FReceiveNetWeight']      := FieldByName('D_NetWeight').AsString;

    FListA.Values['FCreator']               := GetUserName(
                                               FieldByName('O_Man').AsString);;
    FListA.Values['FCreateTime']            := FieldByName('O_Date').AsString;

    FListA.Values['FConveyanceNumber']      := FieldByName('P_Truck').AsString;

    FListA.Values['FStatus']                := '1';
    FListA.Values['FCancelStatus']          := '0';
  end;

  nDBWorker := nil;
  try
    nStr := 'Select * From %s where FBillNumber = ''%s'' ';
    //xxxxx

    nStr := Format(nStr, [sTable_HH_NdOrderPlan, FListA.Values['FTransferPlanID']]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount < 1 then
      begin
        nData := 'δ��ѯ��ERP�ڵ��ƻ�[ %s ]�������.';
        nData := Format(nData, [FListA.Values['FTransferPlanID']]);
        Exit;
      end;

      with FListA do
      begin
        Values['FTransferPlanBillID']     := FieldByName('FBillID').AsString;
        Values['FCompanyID']              := FieldByName('FCompanyID').AsString;
        Values['FConsignmentDepartmentID']:= FieldByName('FConsignmentDepartmentID').AsString;
        Values['FConsignmentDepotID']     := FieldByName('FConsignmentDepotID').AsString;
        Values['FReceiveDepartmentID']    := FieldByName('FReceiveDepartmentID').AsString;
        Values['FReceiveDepotID']         := FieldByName('FReceiveDepotID').AsString;

        Values['FYearPeriod']           := FieldByName('FYearPeriod').AsString;
        Values['FMaterielID']           := FieldByName('FMaterielID').AsString;
        Values['FMaterielNumber']       := FieldByName('FMaterielNumber').AsString;
        Values['FModel']                := FieldByName('FModel').AsString;
        Values['FSpecification']        := FieldByName('FSpecification').AsString;

        Values['FBrand']                := FieldByName('FBrand').AsString;
        Values['FUnitID']               := FieldByName('FUnitID').AsString;

        Values['FFreightContractDetailID'] := FieldByName('FFreightContractDetailID').AsString;
        Values['FFreightProviderID']    := FieldByName('FFreightProviderID').AsString;
        Values['FFreightPriceTax']      := FieldByName('FFreightPriceTax').AsString;
        Values['FFreightMoneyTax']      := GetMoney(
        FieldByName('FFreightPriceTax').AsString,Values['FReceiveNetWeight']);

        Values['FFreightInvoiceTypeID'] := FieldByName('FFreightInvoiceTypeID').AsString;
        Values['FFreightTaxRate']       := FieldByName('FFreightTaxRate').AsString;
        Values['FFreightPrice']         := FieldByName('FFreightPrice').AsString;
        Values['FFreightMoney']         := GetMoney(
        FieldByName('FFreightPrice').AsString,Values['FReceiveNetWeight']);

        Values['FFreightSettlementFashion']  := FieldByName('FFreightSettlementFashion').AsString;
        Values['FMakeBillFashion']      := FieldByName('FMakeBillFashion').AsString;
        Values['FWeightFashion']        := FieldByName('FWeightFashion').AsString;
        Values['FVer']                  := FieldByName('FVer').AsString;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nStr := GetID(sFlag_SMTB);
  if nStr <> '' then
    FListA.Values['FBillID'] := nStr;

  nStr := GetID(sFlag_SAFP);
  if nStr <> '' then
    FListA.Values['FAuditID'] := nStr;

  nDBWorker := nil;
  try
    nStr := 'Select FUserID From %s where (FLoginName = ''%s'' or FUserName = ''%s'')';
    //xxxxx

    nStr := Format(nStr, [sTable_HH_SysUser, FListA.Values['FReceiveGrossWeightPersonnel'],
                          FListA.Values['FReceiveGrossWeightPersonnel']]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount > 0 then
        FListA.Values['FUserID'] := Fields[0].AsString;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nDBWorker := nil;
  try
    nStr := 'Select a.FFlowID, a.FProcessID From %s a , %s b' +
    ' where a.FFlowID = b.FFlowID and  b.FFLowName like ''%%%s%%'''+
    ' and b.FCompanyID = ''%s''';
    //xxxxx

    nStr := Format(nStr, [sTable_HH_AuditPro, sTable_HH_AuditMenu,
                          HhOrderNdPoundAuditMenu,FListA.Values['FCompanyID']]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount > 0 then
      begin
        FListA.Values['FFlowID']    := Fields[0].AsString;
        FListA.Values['FProcessID'] := Fields[1].AsString;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nDBWorker := nil;
  try
    nDBWorker := gDBConnManager.GetConnection(sFlag_DB_HH, FErrNum);
    if not Assigned(nDBWorker) then
    begin
      nData := '�������ݿ�ʧ��(DBConn Is Null).';
      Exit;
    end;

    if not nDBWorker.FConn.Connected then
      nDBWorker.FConn.Connected := True;
    //conn db

    nDBWorker.FConn.BeginTrans;
    try
      nStr := 'Delete From %s where FBillNumber = ''%s'' ';
      nStr := Format(nStr, [sTable_HH_NdOrderPoundData, FListA.Values['FBillNumber']]);

      gDBConnManager.WorkerExec(nDBWorker, nStr);
      //xxxxx
      nSQL := MakeSQLByStr([
        SF('FBillID', FListA.Values['FBillID']),
        SF('FBillNumber', FListA.Values['FBillNumber']),
        SF('FBillTypeID', FListA.Values['FBillTypeID']),
        SF('FCompanyID', FListA.Values['FCompanyID']),
        SF('FYearPeriod', FListA.Values['FYearPeriod']),
        SF('FMaterielID', FListA.Values['FMaterielID']),
        SF('FConveyanceNumber', FListA.Values['FConveyanceNumber']),
        SF('FTransferPlanID', FListA.Values['FTransferPlanBillID']),
        SF('FFreightProviderID', FListA.Values['FFreightProviderID']),
        SF('FFreightContractDetailID', FListA.Values['FFreightContractDetailID']),
        SF('FFreightPriceTax', FListA.Values['FFreightPriceTax']),
        SF('FFreightMoneyTax', FListA.Values['FFreightMoneyTax']),
        SF('FFreightInvoiceTypeID', FListA.Values['FFreightInvoiceTypeID']),
        SF('FFreightTaxRate', FListA.Values['FFreightTaxRate']),
        SF('FFreightPrice', FListA.Values['FFreightPrice']),
        SF('FFreightMoney', FListA.Values['FFreightMoney']),
        SF('FFreightSettlementFashion', FListA.Values['FFreightSettlementFashion']),
        SF('FFreightSettlementStatus', '0'),
        SF('FWeightFashion', FListA.Values['FWeightFashion']),
        SF('FConsignmentDepartmentID', FListA.Values['FConsignmentDepartmentID']),
        SF('FConsignmentDepotID', FListA.Values['FConsignmentDepotID']),
        SF('FConsignmentGrossWeight', FListA.Values['FConsignmentGrossWeight']),
        SF('FConsignmentTare', FListA.Values['FConsignmentTare']),
        SF('FConsignmentNetWeight', FListA.Values['FConsignmentNetWeight']),

        SF('FConsignmentAgainWeightStatus', '0'),
        SF('FConsignmentGrossWeightStatus', FListA.Values['FConsignmentGrossWeightStatus']),
        SF('FConsignmentGrossWeightPersonnel', FListA.Values['FConsignmentGrossWeightPersonnel']),
        SF('FConsignmentGrossWeightTime', FListA.Values['FConsignmentGrossWeightTime']),

        SF('FConsignmentTarePersonnel', FListA.Values['FConsignmentTarePersonnel']),
        SF('FConsignmentTareTime', FListA.Values['FConsignmentTareTime']),
        SF('FConsignmentTareStatus', FListA.Values['FConsignmentTareStatus']),

        SF('FConsignmentStatus', FListA.Values['FConsignmentStatus']),
        SF('FConsignmentPersonnel', FListA.Values['FConsignmentPersonnel']),
        SF('FConsignmentTime', FListA.Values['FConsignmentTime']),

        SF('FReceiveDepartmentID', FListA.Values['FReceiveDepartmentID']),
        SF('FReceiveDepotID', FListA.Values['FReceiveDepotID']),
        SF('FReceiveGrossWeight', FListA.Values['FReceiveGrossWeight']),
        SF('FReceiveTare', FListA.Values['FReceiveTare']),
        SF('FReceiveNetWeight', FListA.Values['FReceiveNetWeight']),

        SF('FReceiveAgainWeightStatus', '0'),
        SF('FReceiveGrossWeightStatus', FListA.Values['FReceiveGrossWeightStatus']),
        SF('FReceiveGrossWeightPersonnel', FListA.Values['FReceiveGrossWeightPersonnel']),
        SF('FReceiveGrossWeightTime', FListA.Values['FReceiveGrossWeightTime']),

        SF('FReceiveTareStatus', FListA.Values['FReceiveTareStatus']),
        SF('FReceiveTarePersonnel', FListA.Values['FReceiveTarePersonnel']),
        SF('FReceiveTareTime', FListA.Values['FReceiveTareTime']),

        SF('FReceiveStatus', FListA.Values['FReceiveStatus']),
        SF('FReceivePersonnel', FListA.Values['FReceivePersonnel']),
        SF('FReceiveTime', FListA.Values['FReceiveTime']),

        SF('FCancelStatus', FListA.Values['FCancelStatus']),
        SF('FCreator', FListA.Values['FCreator']),
        SF('FCreateTime', FListA.Values['FCreateTime']),
        SF('FRemark', FListA.Values['FRemark']),
        SF('FVer', FListA.Values['FVer'])
        ], sTable_HH_NdOrderPoundData, '', True);

      gDBConnManager.WorkerExec(nDBWorker, nSQL);

      nStr := 'Delete From %s where FBusinessID = ''%s'' ';
      nStr := Format(nStr, [sTable_HH_AuditRecord, FListA.Values['FBillID']]);

      gDBConnManager.WorkerExec(nDBWorker, nStr);
      //xxxxx
      nStr := MakeSQLByStr([
        SF('FID', FListA.Values['FAuditID']),
        SF('FCompanyID', FListA.Values['FCompanyID']),
        SF('FFlowID', FListA.Values['FFlowID']),
        SF('FProcessID', FListA.Values['FProcessID']),
        SF('FBusinessID', FListA.Values['FBillID']),
        SF('FAuditingStatus', '1'),
        SF('FVer', FListA.Values['FVer'])
        ], sTable_HH_AuditRecord, '', True);

      gDBConnManager.WorkerExec(nDBWorker, nStr);

      nDBWorker.FConn.CommitTrans;
    except
      nDBWorker.FConn.RollbackTrans;
      nData := '�ڵ��ɹ�����[ %s ]�����ϴ�ʧ��.';
      nData := Format(nData, [FIn.FData]);
      nStr := nData + nSQL;
      WriteLog(nStr);
      Exit;
    end;

    nStr := SF('FID', FListA.Values['FAuditID'])+' and '+
            SF('FCompanyID', FListA.Values['FCompanyID'])+' and '+
            SF('FBusinessID', FListA.Values['FBillID']);

    nStr := MakeSQLByStr([
    SF('FFlowID', FListA.Values['FFlowID']),
    SF('FProcessID', FListA.Values['FProcessID']),
    SF('FAuditingStatus', '2'),
    SF('FVer', FListA.Values['FVer'])
    ], sTable_HH_AuditRecord, nStr, False);

    gDBConnManager.WorkerExec(nDBWorker, nStr);

    nStr :='update %s set P_BDAX=''1'',P_BDNUM=P_BDNUM+1 where P_ID = ''%s'' ';
    nStr := Format(nStr,[sTable_PoundLog,FListA.Values['FPoundID']]);

    gDBConnManager.WorkerExec(FDBConn,nStr);

    FOut.FData := sFlag_Yes;
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

end;

function TWorkerBusinessCommander.GetID(
  const nKeyName: string): string;
var nStr: string;
    nDBWorker: PDBWorker;
    nSucc : Boolean;
begin
  Result := '';
  nSucc := False;

  nDBWorker := nil;
  try
    nDBWorker := gDBConnManager.GetConnection(sFlag_DB_HH, FErrNum);
    if not Assigned(nDBWorker) then
    begin
      Exit;
    end;

    if not nDBWorker.FConn.Connected then
      nDBWorker.FConn.Connected := True;
    //conn db
    nStr := 'exec P_SYS_SYSTEMCOUNTER @FKeyName=N''%s'' ';
    //xxxxx

    nStr := Format(nStr, [nKeyName]);

    if gDBConnManager.WorkerExec(nDBWorker, nStr) > 0 then
      nSucc := True;

  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if not nSucc then
    Exit;

  nDBWorker := nil;
  try
    nStr := 'Select FCurrentID From %s where FKeyName = ''%s'' ';
    //xxxxx

    nStr := Format(nStr, [sTable_HH_SysCounter, nKeyName]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount > 0 then
        Result := Fields[0].AsString;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

function TWorkerBusinessCommander.SyncHhOtherOrderPoundData(
  var nData: string): Boolean;
var nStr:string;
    nSQL: string;
    nDBWorker: PDBWorker;
begin
  Result := False;

  nSQL := 'select *,(P_MValue-P_PValue - isnull(P_KZValue,0)) as D_NetWeight From %s a,'+
  ' %s b where a.R_ID=b.P_OrderBak and b.P_ID = ''%s'' ';

  nSQL := Format(nSQL,[sTable_CardOther,sTable_PoundLog,FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  begin
    if RecordCount < 1 then
    begin
      nData := '��Ʒ�����ɹ�����[ %s ]������.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FListA.Clear;

    FListA.Values['FBillID']                := FieldByName('P_ID').AsString;
    FListA.Values['FBillNumber']            := FieldByName('P_ID').AsString;
    FListA.Values['FPoundID']               := FieldByName('P_ID').AsString;
    FListA.Values['FAuditID']               := FieldByName('P_ID').AsString;

    FListA.Values['FFirstWeighStatus']      := '1';
    FListA.Values['FFirstWeighPersonnel']   := GetUserName(
                                               FieldByName('P_MMan').AsString);
    FListA.Values['FFirstWeighTime']        := FieldByName('P_MDate').AsString;
    FListA.Values['FGrossWeight']           := FieldByName('P_MValue').AsString;

    FListA.Values['FSecondWeighStatus']     := '1';
    FListA.Values['FSecondWeighPersonnel']  := GetUserName(
                                               FieldByName('P_PMan').AsString);
    FListA.Values['FSecondWeighTime']       := FieldByName('P_PDate').AsString;
    FListA.Values['FTare']                  := FieldByName('P_PValue').AsString;
    FListA.Values['FNetWeight']             := FieldByName('D_NetWeight').AsString;

    FListA.Values['FCreator']               := GetUserName(
                                               FieldByName('O_Man').AsString);;
    FListA.Values['FCreateTime']            := FieldByName('O_Date').AsString;

    FListA.Values['FConveryanceNumber']     := FieldByName('P_Truck').AsString;
    FListA.Values['FCompanyID']             := HhCompanyID;
    FListA.Values['FVer']                   := GetVersion;
    FListA.Values['FReamrk']                := '';
    FListA.Values['FStatus']                := '2';
    FListA.Values['FWeighTimes']            := '2';
    FListA.Values['FMaterielName']          := FieldByName('P_MName').AsString;

    FListA.Values['FConsignmentCompanyName']:= FieldByName('P_CusName').AsString;
    FListA.Values['FReceiveCompanyName']    := FieldByName('O_RevName').AsString;
  end;

  nStr := GetID(sFlag_SWB);
  if nStr <> '' then
    FListA.Values['FBillID'] := nStr;

  nDBWorker := nil;
  try
    nStr := 'Select FUserID From %s where (FLoginName = ''%s'' or FUserName = ''%s'')';
    //xxxxx

    nStr := Format(nStr, [sTable_HH_SysUser, FListA.Values['FFirstWeighPersonnel'],
                          FListA.Values['FFirstWeighPersonnel']]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount > 0 then
        FListA.Values['FUserID'] := Fields[0].AsString;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nDBWorker := nil;
  try
    nDBWorker := gDBConnManager.GetConnection(sFlag_DB_HH, FErrNum);
    if not Assigned(nDBWorker) then
    begin
      nData := '�������ݿ�ʧ��(DBConn Is Null).';
      Exit;
    end;

    if not nDBWorker.FConn.Connected then
      nDBWorker.FConn.Connected := True;
    //conn db

    nDBWorker.FConn.BeginTrans;
    try
      nStr := 'Delete From %s where FBillNumber = ''%s'' ';
      nStr := Format(nStr, [sTable_HH_OtherOrderPoundData, FListA.Values['FBillNumber']]);

      gDBConnManager.WorkerExec(nDBWorker, nStr);
      //xxxxx
      nSQL := MakeSQLByStr([
        SF('FBillID', FListA.Values['FBillID']),
        SF('FBillNumber', FListA.Values['FBillNumber']),
        SF('FCompanyID', FListA.Values['FCompanyID']),
        SF('FMaterielName', FListA.Values['FMaterielName']),
        SF('FConveryanceNumber', FListA.Values['FConveryanceNumber']),
        SF('FConsignmentCompanyName', FListA.Values['FConsignmentCompanyName']),
        SF('FReceiveCompanyName', FListA.Values['FReceiveCompanyName']),
        SF('FWeighTimes', FListA.Values['FWeighTimes']),
        SF('FWeighMoney', FListA.Values['FWeighMoney']),
        SF('FGrossWeight', FListA.Values['FGrossWeight']),
        SF('FTare', FListA.Values['FTare']),
        SF('FNetWeight', FListA.Values['FNetWeight']),
        SF('FFirstWeighStatus', FListA.Values['FFirstWeighStatus']),
        SF('FFirstWeighPersonnel', FListA.Values['FFirstWeighPersonnel']),
        SF('FFirstWeighTime', FListA.Values['FFirstWeighTime']),
        SF('FSecondWeighStatus', FListA.Values['FSecondWeighStatus']),
        SF('FSecondWeighPersonnel', FListA.Values['FSecondWeighPersonnel']),
        SF('FSecondWeighTime', FListA.Values['FSecondWeighTime']),

        SF('FStatus', FListA.Values['FStatus']),
        SF('FCreator', FListA.Values['FCreator']),
        SF('FCreateTime', FListA.Values['FCreateTime']),
        SF('FVer', FListA.Values['FVer'])
        ], sTable_HH_OtherOrderPoundData, '', True);

      gDBConnManager.WorkerExec(nDBWorker, nSQL);

      nDBWorker.FConn.CommitTrans;
    except
      nDBWorker.FConn.RollbackTrans;
      nData := '��ʱ�ɹ�����[ %s ]�����ϴ�ʧ��.';
      nData := Format(nData, [FIn.FData]);
      nStr := nData + nSQL;
      WriteLog(nStr);
      Exit;
    end;

    nStr :='update %s set P_BDAX=''1'',P_BDNUM=P_BDNUM+1 where P_ID = ''%s'' ';
    nStr := Format(nStr,[sTable_PoundLog,FListA.Values['FPoundID']]);

    gDBConnManager.WorkerExec(FDBConn,nStr);

    FOut.FData := sFlag_Yes;
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

function TWorkerBusinessCommander.GetVersion: string;
var nStr: string;
    nDBWorker: PDBWorker;
begin
  Result := '';

  nDBWorker := nil;
  try
    nStr := 'select dbo.F_Sys_ServerID() ';
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount > 0 then
        Result := Fields[0].AsString;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date:2018-03-06
//ͬ��ERP���ۼƻ�
function TWorkerBusinessCommander.GetHhSalePlan(var nData: string): Boolean;
var nStr,nPreFix: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  FListB.Clear;
  Result := True;

  nPreFix := 'WY';
  nStr := 'Select B_Prefix From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nPreFix := Fields[0].AsString;
  end;

  if FIn.FData='' then
  begin
    nStr := 'Update %s Set O_Valid = ''%s'' where O_Order not like''%%%s%%''';
    nStr := Format(nStr, [sTable_SalesOrder, sFlag_No, nPreFix]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end else
  begin
    nStr := 'Update %s Set O_Valid = ''%s'' Where O_Factory=''%s'' and O_Order not like''%%%s%%''';
    nStr := Format(nStr, [sTable_SalesOrder, sFlag_No, FIn.FData, nPreFix]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;

  nDBWorker := nil;
  try
    if FIn.FData='' then
    begin
      nStr := 'Select * From %s where FTransportID = 1 and FStatus = 1 ';//����
      nStr := Format(nStr, [sTable_HH_SalePlan]);
    end else
    begin
      nStr := 'Select * From %s where FTransportID = 1 ' +
              'and FStatus = 1 and FFactoryName like ''%%%s%%'' ';
      nStr := Format(nStr, [sTable_HH_SalePlan, FIn.Fdata]);
    end;
    //xxxxx
    WriteLog('��ȡ���ۼƻ�SQL:'+nStr);
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        nStr := MakeSQLByStr([SF('O_Order', FieldByName('FBillCode').AsString),
                SF('O_Factory', FieldByName('FFactoryName').AsString),
                SF('O_CusName', FieldByName('FCustomerName').AsString),
                SF('O_StockName', FieldByName('FMaterielName').AsString),
                SF('O_StockType', FieldByName('FPacking').AsString),
                SF('O_Lading', FieldByName('FDelivery').AsString),
                SF('O_CusPY', GetPinYinOfStr(FieldByName('FCustomerName').AsString)),
                SF('O_PlanAmount', FieldByName('FPlanAmount').AsString),
                SF('O_PlanDone', FieldByName('FBillAmount').AsString),
                SF('O_PlanRemain', FieldByName('FRemainAmount').AsString),
                SF('O_PlanBegin', FieldByName('FBeginDate').AsDateTime,sfDateTime),
                SF('O_PlanEnd', FieldByName('FEndDate').AsDateTime,sfDateTime),
                SF('O_Company', FieldByName('FCompanyName').AsString),
                SF('O_Depart', FieldByName('FSaleOrgName').AsString),
                SF('O_SaleMan', FieldByName('FEmployeeName').AsString),
                SF('O_Remark', FieldByName('FRemark').AsString),
                SF('O_Price', FieldByName('FGoodsPrice').AsFloat,sfVal),
                SF('O_Valid', sFlag_Yes),
                SF('O_Freeze', 0, sfVal),
                SF('O_HasDone', 0, sfVal),
                SF('O_CompanyID', FieldByName('FCompayID').AsString),
                SF('O_CusID', FieldByName('FCustomerID').AsString),
                SF('O_StockID', FieldByName('FMaterielID').AsString),
                SF('O_PackingID', FieldByName('FPackingID').AsString),
                SF('O_Create', FieldByName('FCreateTime').AsDateTime,sfDateTime),
                SF('O_Modify', FieldByName('FModifyTime').AsDateTime,sfDateTime)
                ], sTable_SalesOrder, '', True);
        FListA.Add(nStr);

        nStr := SF('O_Order', FieldByName('FBillCode').AsString);
        nStr := MakeSQLByStr([
                SF('O_Factory', FieldByName('FFactoryName').AsString),
                SF('O_CusName', FieldByName('FCustomerName').AsString),
                SF('O_StockName', FieldByName('FMaterielName').AsString),
                SF('O_StockType', FieldByName('FPacking').AsString),
                SF('O_Lading', FieldByName('FDelivery').AsString),
                SF('O_CusPY', GetPinYinOfStr(FieldByName('FCustomerName').AsString)),
                SF('O_PlanAmount', FieldByName('FPlanAmount').AsString),
                SF('O_PlanDone', FieldByName('FBillAmount').AsString),
                SF('O_PlanRemain', FieldByName('FRemainAmount').AsString),
                SF('O_PlanBegin', FieldByName('FBeginDate').AsDateTime,sfDateTime),
                SF('O_PlanEnd', FieldByName('FEndDate').AsDateTime,sfDateTime),
                SF('O_Company', FieldByName('FCompanyName').AsString),
                SF('O_Depart', FieldByName('FSaleOrgName').AsString),
                SF('O_SaleMan', FieldByName('FEmployeeName').AsString),
                SF('O_Remark', FieldByName('FRemark').AsString),
                SF('O_Price', FieldByName('FGoodsPrice').AsFloat,sfVal),
                SF('O_Valid', sFlag_Yes),
                SF('O_CompanyID', FieldByName('FCompayID').AsString),
                SF('O_CusID', FieldByName('FCustomerID').AsString),
                SF('O_StockID', FieldByName('FMaterielID').AsString),
                SF('O_PackingID', FieldByName('FPackingID').AsString),
                SF('O_Create', FieldByName('FCreateTime').AsDateTime,sfDateTime),
                SF('O_Modify', FieldByName('FModifyTime').AsDateTime,sfDateTime)
                ], sTable_SalesOrder, nStr, False);
        FListB.Add(nStr);
      finally
        Next;
      end;
    end else
    begin
      Result:=False;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if (FListB.Count > 0) then
  try
    FDBConn.FConn.BeginTrans;
    //��������
    for nIdx:=0 to FListB.Count - 1 do
    begin
      if gDBConnManager.WorkerExec(FDBConn,FListB[nIdx]) <= 0 then
      begin
        gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
      end;
    end;
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessCommander.SyncHhSaleDetail(
  var nData: string): Boolean;
var nStr,nDate:string;
    nSQL: string;
    nDBWorker: PDBWorker;
begin
  Result := False;

  nDBWorker := nil;
  try
    nStr := 'Select FBillNumber From %s where FBillNumber = ''%s'' and FStatus = 2 ';
    nStr := Format(nStr, [sTable_HH_SaleDetail, FIn.FData]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount > 0 then
      begin
        nData := '�������[ %s ]δ�������,��ֹ�ϴ�.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nSQL := 'select * From %s where L_ID = ''%s'' ';

  nSQL := Format(nSQL,[sTable_Bill, FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  begin
    if RecordCount < 1 then
    begin
      nData := '�������[ %s ]������.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FListA.Clear;

    FListA.Values['FConsignPlanNumber']     := FieldByName('L_Order').AsString;
    FListA.Values['FBillID']                := FieldByName('L_ID').AsString;
    FListA.Values['FBillNumber']            := FieldByName('L_ID').AsString;
    FListA.Values['FBillNumber']            := FieldByName('L_ID').AsString;
    FListA.Values['FOldNumber']             := FieldByName('L_WT').AsString;

    FListA.Values['FGrossSign']             := '1';
    FListA.Values['FGrossPerson']           := GetUserName(
                                               FieldByName('L_MMan').AsString);
    FListA.Values['FGrossTime']             := FieldByName('L_MDate').AsString;
    FListA.Values['FGross']                 := FieldByName('L_MValue').AsString;
    FListA.Values['FGrossName']             := GetUserName(
                                               FieldByName('L_MMan').AsString);

    FListA.Values['FTareSign']              := '1';
    FListA.Values['FTarePerson']            := GetUserName(
                                               FieldByName('L_PMan').AsString);
    FListA.Values['FTareTime']              := FieldByName('L_PDate').AsString;
    FListA.Values['FTare']                  := FieldByName('L_PValue').AsString;
    FListA.Values['FTareName']              := GetUserName(
                                               FieldByName('L_PMan').AsString);
    FListA.Values['FPlanAmount']            := FieldByName('L_PreValue').AsString;
    FListA.Values['FSuttle']                := FieldByName('L_Value').AsString;
    FListA.Values['FDeliveryAmount']        := FieldByName('L_Value').AsString;

    FListA.Values['FCreator']               := GetUserName(
                                               FieldByName('L_Man').AsString);
    FListA.Values['FCreateTime']            := FieldByName('L_Date').AsString;
    FListA.Values['FTransportNumber']       := FieldByName('L_Truck').AsString;

    {$IFDEF BatchInHYOfBill}
    FListA.Values['FWareNumber']            := FieldByName('L_HYDan').AsString;
    {$ELSE}
    FListA.Values['FWareNumber']            := FieldByName('L_Seal').AsString;
    {$ENDIF}

    FListA.Values['FDeliveryer']            := GetUserName(
                                               FieldByName('L_MMan').AsString);
    FListA.Values['FDeliveryTime']          := FormatDateTime('YYYY-MM-DD',
                                               FieldByName('L_OutFact').AsDateTime);

    FListA.Values['FShopID']                := '100015004';
    try
      nDate := FormatDateTime('DD',FieldByName('L_OutFact').AsDateTime);
      if StrToIntDef(nDate,0) > 25 then
       nDate := FormatDateTime('YYYY-MM',IncMonth(FieldByName('L_OutFact').AsDateTime))
      else
       nDate := FormatDateTime('YYYY-MM',FieldByName('L_OutFact').AsDateTime);
    except
       nDate := FormatDateTime('YYYY-MM',FieldByName('L_OutFact').AsDateTime);
    end;
    FListA.Values['FYearPeriod']            := nDate;

    if FieldByName('L_Type').AsString = sFlag_Dai then
      FListA.Values['FBagAmount']           := IntToStr(Round(
                                            FieldByName('L_Value').AsFloat * 200))
    else
      FListA.Values['FBagAmount']           := '0';

    FListA.Values['FAuditingSign']          := '0';
    FListA.Values['FAssessor']              := GetUserName(
                                               FieldByName('L_MMan').AsString);
    FListA.Values['FAuditingTime']          := FieldByName('L_MDate').AsString;

    FListA.Values['FStatus']                := '1';
    FListA.Values['FIsdelete']              := '0';
    FListA.Values['FDataSign']              := '0';
    FListA.Values['FGoodsSign']             := '0';
    FListA.Values['FCFreightSign']          := '0';
    FListA.Values['FTFreightSign']          := '0';
    FListA.Values['FBackSign']              := '0';
    FListA.Values['FBangChSign']            := '0';
    FListA.Values['FScheduleVanID']         := '-1';
    FListA.Values['FRemainder']             := '0.0000';
    FListA.Values['FGroupNO']               := '0';
    FListA.Values['FFactGross']             := FieldByName('L_MValue').AsString;
    FListA.Values['FKeepDate']              := FormatDateTime('YYYY-MM-DD',
                                               FieldByName('L_OutFact').AsDateTime);
    FListA.Values['FDepotID']               := '-1';
    FListA.Values['FIsReSave']              := '0';
    FListA.Values['FChangeBalanceSign']     := '0';
  end;

  nDBWorker := nil;
  try
    nStr := 'Select * From %s where FBillCode = ''%s'' ';
    //xxxxx

    nStr := Format(nStr, [sTable_HH_SalePlan, FListA.Values['FConsignPlanNumber']]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount < 1 then
      begin
        nData := 'δ��ѯ��ERP���ۼƻ�[ %s ]�������.';
        nData := Format(nData, [FListA.Values['FConsignPlanNumber']]);
        Exit;
      end;

      with FListA do
      begin
        Values['FConsignPlanID']        := FieldByName('FBillId').AsString;
        Values['FCompanyID']            := FieldByName('FCompayID').AsString;
        Values['FFactoryID']            := FieldByName('FFactoryID').AsString;
        Values['FCustomerID']           := FieldByName('FCustomerID').AsString;
        Values['FCarrierID']            := FieldByName('FCarrierID').AsString;

        Values['FCustomerName']         := FieldByName('FCustomerName').AsString;
        Values['FMaterielID']           := FieldByName('FMaterielID').AsString;
        Values['FSaleManID']            := FieldByName('FSaleManID').AsString;
        Values['FContractDetailID']     := FieldByName('FContractDetailID').AsString;
        Values['FPackingID']            := FieldByName('FPackingID').AsString;
        Values['FDeliveryID']           := FieldByName('FDeliveryID').AsString;

        Values['FTransportID']          := FieldByName('FTransportID').AsString;
        Values['FTAreaID']              := FieldByName('FTransportAreaID').AsString;
        Values['FDeliveryAddress']      := FieldByName('FDeliveryAddress').AsString;
        Values['FPriceModeID']          := FieldByName('FPriceModeID').AsString;
        Values['FGoodsPrice']           := FieldByName('FGoodsPrice').AsString;

        Values['FCFreightPrice']        := FieldByName('FCFreightPrice').AsString;
        Values['FTFreightPrice']        := FieldByName('FTFreightPrice').AsString;

        Values['FMidWayPrice']          := FieldByName('FMidWayPrice').AsString;
        Values['FLoadingPrice']         := FieldByName('FLoadingPrice').AsString;
        Values['FUnloadPrice']          := FieldByName('FUnloadPrice').AsString;

        Values['FLoadingSite']          := FieldByName('FLoadingSite').AsString;
        Values['Fver']                  := FieldByName('Fver').AsString;
        Values['FAccountCompid']        := FieldByName('FAccountCompid').AsString;

        Values['FAccountCustid']        := FieldByName('FAccountCustid').AsString;
        Values['FDepartmentid']         := FieldByName('FDepartmentid').AsString;
        Values['FMidWaySign']           := FieldByName('FMidWaySign').AsString;
        Values['FLoadingSign']          := FieldByName('FLoadingSign').AsString;

        Values['FUnloadSign']           := FieldByName('FUnloadSign').AsString;
        Values['FCustomerAreaID']       := FieldByName('FCustomerAreaID').AsString;
        Values['FConsignDepositBillID'] := FieldByName('FBillID').AsString;
        Values['FConsignDepositNumber'] := FieldByName('FBillCode').AsString;
        Values['FCGoodsprice']          := FieldByName('FCGoodsprice').AsString;
      end;
    end;

    nStr := GetID(sFlag_SCB);
    if nStr <> '' then
      FListA.Values['FBillID'] := nStr;

  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nDBWorker := nil;
  try
    nStr := 'Select FUserID From %s where (FLoginName = ''%s'' or FUserName = ''%s'')';
    //xxxxx

    nStr := Format(nStr, [sTable_HH_SysUser, FListA.Values['FGrossWeightPersonnel'],
                          FListA.Values['FGrossWeightPersonnel']]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount > 0 then
        FListA.Values['FUserID'] := Fields[0].AsString;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nDBWorker := nil;
  try
    nDBWorker := gDBConnManager.GetConnection(sFlag_DB_HH, FErrNum);
    if not Assigned(nDBWorker) then
    begin
      nData := '�������ݿ�ʧ��(DBConn Is Null).';
      Exit;
    end;

    if not nDBWorker.FConn.Connected then
      nDBWorker.FConn.Connected := True;
    //conn db

    nDBWorker.FConn.BeginTrans;
    try
      nStr := 'Delete From %s where FBillNumber = ''%s'' ';
      nStr := Format(nStr, [sTable_HH_SaleDetail, FListA.Values['FBillNumber']]);

      gDBConnManager.WorkerExec(nDBWorker, nStr);
      //xxxxx
      nSQL := MakeSQLByStr([
        SF('FBillID', FListA.Values['FBillID']),
        SF('FBillNumber', FListA.Values['FBillNumber']),
        SF('FOldNumber', FListA.Values['FOldNumber']),
        SF('FFactoryID', FListA.Values['FFactoryID']),
        SF('FCompanyID', FListA.Values['FCompanyID']),
        SF('FShopID', FListA.Values['FShopID']),
        SF('FYearPeriod', FListA.Values['FYearPeriod']),
        SF('FMaterielID', FListA.Values['FMaterielID']),
        SF('FConsignPlanID', FListA.Values['FConsignPlanID']),
        SF('FContractDetailID', FListA.Values['FContractDetailID']),
        SF('FConsignPlanNumber', FListA.Values['FConsignPlanNumber']),
        SF('FCustomerID', FListA.Values['FCustomerID']),
        SF('FCarrierID', FListA.Values['FCarrierID']),
        SF('FCustomerName', FListA.Values['FCustomerName']),
        SF('FSaleManID', FListA.Values['FSaleManID']),
        SF('FPackingID', FListA.Values['FPackingID']),
        SF('FDeliveryID', FListA.Values['FDeliveryID']),
        SF('FTransportID', FListA.Values['FTransportID']),
        SF('FPlanAmount', FListA.Values['FPlanAmount']),
        SF('FGross', FListA.Values['FGross']),
        SF('FTare', FListA.Values['FTare']),
        SF('FSuttle', FListA.Values['FSuttle']),
        SF('FDeliveryAmount', FListA.Values['FDeliveryAmount']),
        SF('FTAreaID', FListA.Values['FTAreaID']),
        SF('FDeliveryAddress', FListA.Values['FDeliveryAddress']),
        SF('FCreateTime', FListA.Values['FCreateTime']),
        SF('FCreator', FListA.Values['FCreator']),
        SF('FTransportNumber', FListA.Values['FTransportNumber']),
        SF('FPriceModeID', FListA.Values['FPriceModeID']),
        SF('FGoodsPrice', FListA.Values['FGoodsPrice']),
        SF('FCFreightPrice', FListA.Values['FCFreightPrice']),
        SF('FTFreightPrice', FListA.Values['FTFreightPrice']),
        SF('FMidWayPrice', FListA.Values['FMidWayPrice']),
        SF('FLoadingPrice', FListA.Values['FLoadingPrice']),
        SF('FUnloadPrice', FListA.Values['FUnloadPrice']),
        SF('FDepotNumber', FListA.Values['FDepotNumber']),
        SF('FWareNumber', FListA.Values['FWareNumber']),
        SF('FBagAmount', FListA.Values['FBagAmount']),
        SF('FTareSign', FListA.Values['FTareSign']),
        SF('FTarePerson', FListA.Values['FTarePerson']),
        SF('FTareTime', FListA.Values['FTareTime']),
        SF('FTareName', FListA.Values['FTareName']),
        SF('FGrossSign', FListA.Values['FGrossSign']),
        SF('FGrossPerson', FListA.Values['FGrossPerson']),
        SF('FGrossTime', FListA.Values['FGrossTime']),
        SF('FGrossName', FListA.Values['FGrossName']),
        SF('FDeliveryer', FListA.Values['FDeliveryer']),
        SF('FDeliveryTime', FListA.Values['FDeliveryTime']),
        SF('FAuditingSign', FListA.Values['FAuditingSign']),

        SF('FLoadingSite', FListA.Values['FLoadingSite']),
        SF('FDataSign', FListA.Values['FDataSign']),
        SF('FStatus', FListA.Values['FStatus']),
        SF('FIsdelete', FListA.Values['FIsdelete']),
        SF('FGoodsSign', FListA.Values['FGoodsSign']),
        SF('FCFreightSign', FListA.Values['FCFreightSign']),
        SF('FTFreightSign', FListA.Values['FTFreightSign']),
        SF('FBackSign', FListA.Values['FBackSign']),
        SF('FBackPerson', FListA.Values['FBackPerson']),
        SF('FRemark', FListA.Values['FRemark']),
        SF('FVer', FListA.Values['FVer']),
        SF('FAccountCompid', FListA.Values['FAccountCompid']),
        SF('FAccountCustid', FListA.Values['FAccountCustid']),
        SF('FDepartmentid', FListA.Values['FDepartmentid']),
        SF('FMidWaySign', FListA.Values['FMidWaySign']),
        SF('FLoadingSign', FListA.Values['FLoadingSign']),
        SF('FUnloadSign', FListA.Values['FUnloadSign']),
        SF('FBangChSign', FListA.Values['FBangChSign']),

        SF('FScheduleVanID', FListA.Values['FScheduleVanID']),
        SF('FRemainder', FListA.Values['FRemainder']),
        SF('FGroupNO', FListA.Values['FGroupNO']),
        SF('FFactGross', FListA.Values['FFactGross']),
        SF('FKeepDate', FListA.Values['FKeepDate']),
        SF('FCustomerAreaID', FListA.Values['FCustomerAreaID']),
        SF('FDepotID', FListA.Values['FDepotID']),
        SF('FConsignDepositBillID', FListA.Values['FConsignDepositBillID']),
        SF('FConsignDepositNumber', FListA.Values['FConsignDepositNumber']),
        SF('FIsReSave', FListA.Values['FIsReSave']),
        SF('FCGoodsprice', FListA.Values['FCGoodsprice']),
        SF('FChangeBalanceSign', FListA.Values['FChangeBalanceSign'])
        ], sTable_HH_SaleDetail, '', True);

      gDBConnManager.WorkerExec(nDBWorker, nSQL);

//      nStr :='update $TK set FEntryAmount=FEntryAmount + $Val' +
//             ' where FEntryPlanID = ''$ID'' ';
//      nStr := MacroValue(nStr, [MI('$TK', sTable_HH_OrderPlanT),
//                  MI('$Val', FListA.Values['FReceiveNetWeight']),
//                  MI('$ID', FListA.Values['FEntryPlanID'])]);
//
//      gDBConnManager.WorkerExec(nDBWorker, nStr);
      //���¼ƻ�������

      nDBWorker.FConn.CommitTrans;
    except
      nDBWorker.FConn.RollbackTrans;
      nData := '�������[ %s ]�ϴ�ʧ��.';
      nData := Format(nData, [FIn.FData]);
      nStr := nData + nSQL;
      WriteLog(nStr);
      Exit;
    end;

    nStr := SF('FBillNumber', FListA.Values['FBillNumber']);

    nStr := MakeSQLByStr([
    SF('FStatus', '2'),
    SF('FVer', FListA.Values['FVer'])
    ], sTable_HH_SaleDetail, nStr, False);

    WriteLog('ģ�ⷢ�����:'+nStr);
    gDBConnManager.WorkerExec(nDBWorker, nStr);

//    nStr := SF('FBillNumber', FListA.Values['FBillNumber']);
//
//    nStr := MakeSQLByStr([
//    SF('FAssessor', FListA.Values['FAssessor']),
//    SF('FAuditingTime', FListA.Values['FAuditingTime']),
//    SF('FAuditingSign', '1'),
//    SF('FVer', FListA.Values['FVer'])
//    ], sTable_HH_SaleDetail, nStr, False);
//
//    WriteLog('ģ���������:'+nStr);
//
//    gDBConnManager.WorkerExec(nDBWorker, nStr);

    nStr :='update %s set L_BDAX=''1'',L_BDNUM=L_BDNUM+1 where L_ID = ''%s'' ';
    nStr := Format(nStr,[sTable_Bill,FIn.FData]);

    gDBConnManager.WorkerExec(FDBConn,nStr);

    FOut.FData := sFlag_Yes;
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

function TWorkerBusinessCommander.GetHhSaleWTTruck(
  var nData: string): Boolean;
var nStr, nProStr, nMatStr, nYearStr: string;
    nValue: Double;
    nDBWorker: PDBWorker;
begin
  Result := False;

  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FData);

  nDBWorker := nil;
  try
    nStr := 'Select * From %s where (FBeginDate < dateadd(dd,1,GETDATE()))'+
            ' And FEndDate > dateadd(dd,-1,GETDATE())'+
            ' And FStatus = 1 And FTransportID = 1'+
            ' And FCustomerID = ''%s'''+
            ' And FCompanyID = ''%s'''+
            ' And FMaterielID = ''%s'''+
            ' And FPackingID = ''%s''';
    //xxxxx

    nStr := Format(nStr, [sTable_HH_SaleWTTruck,FListA.Values['CusID'],
                                                FListA.Values['CompanyID'],
                                                FListA.Values['StockID'],
                                                FListA.Values['PackingID']]);

    WriteLog('��ȡ����ί�к�:'+nStr);

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_HH) do
    begin
      if RecordCount < 1 then
      begin
        nData := 'δ��ѯ���������.';
        Exit;
      end;

      FListA.Clear;
      FListB.Clear;

      First;

      while not Eof do
      with FListB do
      begin
        Values['Truck']       := FieldByName('FTransportation').AsString;
        Values['Value']       := FieldByName('FAmount').AsString;
        Values['FBillNumber'] := FieldByName('FBillNumber').AsString;
        FListA.Add(PackerEncodeStr(FListB.Text));

        Next;
      end;
    end;

    FOut.FData := PackerEncodeStr(FListA.Text);
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

procedure TWorkerBusinessCommander.SaveHyDanEvent(const nStockno,nEvent,
          nFrom,nSolution,nDepartment: string);
var
  nStr:string;
  nEID:string;
begin
  try
    nEID := nStockno + FormatDateTime('YYYYMMDD',Now);
    nStr := 'Delete From %s Where E_ID=''%s''';
    nStr := Format(nStr, [sTable_ManualEvent, nEID]);

    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := MakeSQLByStr([
        SF('E_ID', nEID),
        SF('E_Key', ''),
        SF('E_From', nFrom),
        SF('E_Event', nEvent),
        SF('E_Solution', nSolution),
        SF('E_Departmen', nDepartment),
        SF('E_Date', sField_SQLServer_Now, sfVal)
        ], sTable_ManualEvent, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  except
    on E: Exception do
    begin
      WriteLog(e.message);
    end;
  end;
end;

function TWorkerBusinessCommander.VerifyTruckLicense(
  var nData: string): Boolean;
var nStr: string;
    nTruck, nBill, nPos, nEvent, nDept, nPicName: string;
    nUpdate, nNeedManu: Boolean;
    nLastTime: TDateTime;
begin
  Result := False;
  FListA.Text := FIn.FData;
  nPos := sFlag_DepBangFang;
  nDept:= sFlag_DepDaTing;
  nEvent:= '' ;
  nNeedManu := False;

  nTruck := FListA.Values['Truck'];
  nBill  := FListA.Values['Bill'];

  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_TruckInNeedManu,nPos]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      nNeedManu := FieldByName('D_Value').AsString = sFlag_Yes;
    end;
  end;

  if not nNeedManu then
  begin
    WriteLog('����ʶ��:'+'��λ:'+nPos+'�¼����ղ���:'+nDept+'�˹���Ԥ:��');
  end
  else
    WriteLog('����ʶ��:'+'��λ:'+nPos+'�¼����ղ���:'+nDept+'�˹���Ԥ:��');

  nStr := 'Select isnull(T_LastTime,''2000-12-12 09:00:00'') as T_LastTime From %s Where T_Truck=''%s''  ';
  nStr := Format(nStr, [sTable_Truck, nTruck]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      Result:= False;
      nData := '����[ %s ]ʶ���쳣';
      nData := Format(nData, [nTruck]);
      FOut.FData := nData;
      Exit;
    end;
    
    nLastTime := FieldByName('T_LastTime').AsDateTime;
    if Now - nLastTime <= 0.1 then
    begin
      nData := '����[ %s ]����ʶ��ɹ�';
      nData:= Format(nData, [nTruck]);
      FOut.FData := nData;
      Result := True;
      Exit;
    end;
    //����ʶ��ɹ�
  end;

  if not nNeedManu then
  begin
   // Result := True;
    Exit;
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nBill+sFlag_ManualE]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      if FieldByName('E_Result').AsString = 'N' then
      begin
        nData := '����[ %s ]����ʶ��ʧ��,����Ա��ֹ����';
        nData := Format(nData, [nTruck]);
        FOut.FData := nData;
        Exit;
      end;
      if FieldByName('E_Result').AsString = 'Y' then
      begin
        Result := True;
        nData := '����[ %s ]����ʶ��ʧ��,����Ա����';
        nData := Format(nData, [nTruck]);
        FOut.FData := nData;
        Exit;
      end;
      nUpdate := True;
    end
    else
    begin
      nData := '����[ %s ]����ʶ��ʧ��';
      nData := Format(nData, [nTruck]);
      FOut.FData := nData;
      nUpdate := False;
      Result  := False;
    end;
  end;

  nEvent := '����[ %s ]����ʶ��ʧ��';
  nEvent := Format(nEvent, [nTruck]);

  nStr := SF('E_ID', nBill+sFlag_ManualE);
  nStr := MakeSQLByStr([
          SF('E_ID', nBill+sFlag_ManualE),
          SF('E_Key', nPicName),
          SF('E_From', nPos),
          SF('E_Result', 'Null', sfVal),

          SF('E_Event', nEvent),
          SF('E_Solution', sFlag_Solution_YN),
          SF('E_Departmen', nDept),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  //xxxxx
  gDBConnManager.WorkerExec(FDBConn, nStr);
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerQueryField, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessCommander, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessOrders, sPlug_ModuleBus);
end.
